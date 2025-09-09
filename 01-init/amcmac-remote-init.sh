#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

### 設定 ###
SHARE_URL="smb://172.16.1.23/shared"   # 実際の共有先
MOUNT_POINT="/Volumes/shared"
CAFFEINATE_DURATION=3600  # 秒
KEYCHAIN_SERVICE="amc-share"  # キーチェーンに登録したサービス名

### ヘルパー ###
log() { printf '[%s] %s\n' "$(date '+%F %T')" "$*"; }
error() { printf '[%s] ERROR: %s\n' "$(date '+%F %T')" "$*" >&2; }

notify() {
  local title="$1"
  local message="$2"
  osascript -e "display notification \"${message//\"/\\\"}\" with title \"${title//\"/\\\"}\""
}

ifconfig | grep 'inet ' | awk '{print $2}' | pbcopy

### 起動音 ###
afplay /System/Library/Sounds/Blow.aiff &

# if ! pgrep -x caffeinate >/dev/null; then
#   caffeinate -d -i -u -t "$CAFFEINATE_DURATION" >/dev/null 2>&1 &
#   log "caffeinate 起動 (duration=${CAFFEINATE_DURATION}s)"
# else
#   log "既に caffeinate 動作中"
# fi

### スリープ&スクリーンセーバ防止
caffeinate -d -i >/dev/null 2>&1 &
/usr/bin/caffeinate -u -t 5 >/dev/null 2>&1 &
( while sleep 240; do /usr/bin/caffeinate -u -t 5; done ) >/dev/null 2>&1 &


### 2. ディスプレイを叩き起こす ###
osascript <<'EOF' &
tell application "System Events"
  keystroke " "  -- 軽いアクティビティで画面起こし
end tell
EOF

### 3. 接続情報通知 ###
SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I 2>/dev/null | awk -F': ' '/ SSID/ {print $2}' || echo "<不明>")
computer_name=$(scutil --get ComputerName 2>/dev/null || echo "unknown")
log "SSID=${SSID}"
notify "初期化完了" "[$computer_name] ${SSID} に接続しました"

### 4. 共有ドライブマウント関連 ###
# 既にマウント済みか？
if mount | grep -q " on ${MOUNT_POINT} "; then
  log "${MOUNT_POINT} は既にマウント済み"
  exit 0
fi

# ①: mount_smbfs でキーチェーン or 環境変数から認証して直接マウントを試みる
try_mount_native() {
  local user pass credpart
  if [ -n "${SHARE_USER-}" ] && [ -n "${SHARE_PASSWORD-}" ]; then
    user="$SHARE_USER"
    pass="$SHARE_PASSWORD"
    log "環境変数から認証情報を使用して native マウント"
  else
    # キーチェーンから取り出す（アカウントはキーに含める必要あり）
    # account はキーチェーンの entry から引き出す。ここでは service 名一致の最初のアカウントを取る。
    if account=$(security find-generic-password -s "$KEYCHAIN_SERVICE" -g 2>&1 | awk -F'"' '/"acct"/ {print $2; exit}'); then
      user="$account"
      pass=$(security find-generic-password -s "$KEYCHAIN_SERVICE" -w 2>/dev/null || true)
      log "キーチェーンから認証情報を取得 (user=$user)"
    fi
  fi

  if [ -n "${user-}" ] && [ -n "${pass-}" ]; then
    # smb URL を分解して host/path を取り出す
    # mount_smbfs 形式: //user:password@host/share
    # パスワードに特殊文字がある場合は要エスケープ（簡易版ではそのまま）
    local target="//${user}:${pass}@${SHARE_URL#smb://}"
    log "mount_smbfs を使って接続試行: ${target}"
    mkdir -p "$MOUNT_POINT"
    if mount_smbfs "$target" "$MOUNT_POINT" 2>/dev/null; then
      log "native mount_smbfs 成功: ${MOUNT_POINT}"
      return 0
    else
      error "mount_smbfs によるマウント失敗"
    fi
  else
    log "認証情報が取れなかったので native マウントはスキップ"
  fi
  return 1
}

# ②: Finder GUI 経由で接続（ダイアログ操作）
try_mount_via_ui() {
  log "Finder 経由で接続を試みる (Connect to Server ダイアログ)"
  osascript <<EOF
tell application "Finder"
  activate
  delay 0.3
  -- Connect to Server ダイアログを開く
  tell application "System Events"
    keystroke "k" using {command down}
    delay 0.5
    -- ダイアログのテキストフィールドに共有 URL を入力
    keystroke "${SHARE_URL}"
    delay 0.3
    keystroke return
    delay 1
  end tell
end tell

-- 認証ダイアログが出たら自動入力（キーチェーン情報は事前に保存されていることが望ましい）
tell application "System Events"
  delay 0.5
  -- 可能なら「接続」ボタンを押す（macOS の言語設定によってボタン名が変わるため Enter で代替）
  keystroke return
end tell
EOF

  # 少し待ってマウントされるか確認
  for i in {1..10}; do
    if [ -d "$MOUNT_POINT" ]; then
      log "UI 経由でマウント成功: ${MOUNT_POINT}"
      return 0
    fi
    sleep 1
  done

  error "UI 経由でもマウントできなかった"
  return 1
}

# ③: 最終フォールバックで何度か Enter を送る（ダイアログが残ってるケース用）
fallback_brute_force() {
  log "フォールバック: 無理やり Enter を複数回送る"
  osascript <<'EOF'
tell application "System Events"
  repeat 5 times
    keystroke return
    delay 0.3
  end repeat
end tell
EOF
}

# 実行順
if try_mount_native; then
  notify "マウント完了" "${MOUNT_POINT} をネイティブ方式でマウントしました"
  exit 0
fi

if try_mount_via_ui; then
  notify "マウント完了" "${MOUNT_POINT} を Finder 経由でマウントしました"
  exit 0
fi

# 最後のごり押し
fallback_brute_force

# 再確認
if [ -d "$MOUNT_POINT" ]; then
  log "最終的にマウント成功: ${MOUNT_POINT}"
  notify "マウント完了" "${MOUNT_POINT} がマウントされました（フォールバック）"
else
  error "共有ドライブのマウントに失敗しました"
  notify "マウント失敗" "共有ドライブをマウントできませんでした"
  exit 1
fi
