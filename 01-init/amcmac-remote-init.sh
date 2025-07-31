#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

### 設定部分 ###
SHARE_URL="smb://your.server.example/shared"  # ← 実際の共有先に書き換える
MOUNT_POINT="/Volumes/shared"
CAFFEINATE_DURATION=3600  # 秒

### ヘルパー ###
log() { printf '[%s] %s\n' "$(date '+%F %T')" "$*"; }
error() { printf '[%s] ERROR: %s\n' "$(date '+%F %T')" "$*" >&2; }

# 通知（非ブロッキング）
notify() {
  local title="$1"
  local message="$2"
  # エスケープして渡す
  osascript -e "display notification \"${message//\"/\\\"}\" with title \"${title//\"/\\\"}\""
}

### 前提チェック（必要に応じて追加してもよい） ###
command -v afplay >/dev/null || { error "afplay が見つかりません"; exit 1; }
command -v osascript >/dev/null || { error "osascript が見つかりません"; exit 1; }

### 1. 音を鳴らす（非同期） ###
afplay /System/Library/Sounds/Blow.aiff &

### 2. スリープ防止 ###
if pgrep -x caffeinate >/dev/null; then
  log "既に caffeinate が動作中"
else
  caffeinate -d -i -u -t "$CAFFEINATE_DURATION" >/dev/null 2>&1 &
  CAF_PID=$!
  log "caffeinate を起動しました (pid=${CAF_PID}) 有効時間: ${CAFFEINATE_DURATION}s"
fi

### 3. 画面を起こすための軽いアクティビティ ###
# 何度も return を押すより、1回の harmless なキーで十分なことが多い
osascript <<'EOF' &
tell application "System Events"
  -- 表示を起こす目的でスペースを送る（アクティビティ）
  keystroke " "
end tell
EOF

### 4. 接続情報取得 ###
SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I 2>/dev/null | awk -F': ' '/ SSID/ {print $2}' || echo "<不明>")
computer_name=$(scutil --get ComputerName 2>/dev/null || echo "unknown")

log "SSID=${SSID}"
notify "初期化完了" "[$computer_name] ${SSID} に接続しました"

### 5. 共有ドライブのマウント ###
if mount | grep -q " on ${MOUNT_POINT} "; then
  log "${MOUNT_POINT} は既にマウント済み"
else
  log "共有先をマウント: ${SHARE_URL}"
  if open "$SHARE_URL"; then
    # Finder 側でマウントされるのを待つ（最大 10 秒）
    for i in {1..10}; do
      if [ -d "$MOUNT_POINT" ]; then
        log "マウント成功: ${MOUNT_POINT}"
        break
      fi
      sleep 1
    done
    if [ ! -d "$MOUNT_POINT" ]; then
      error "open でのマウントに失敗。フォールバックへ"
      # フォールバックで Connect to Server ダイアログ＋URL 入力
      osascript <<EOF
tell application "Finder"
  activate
  tell application "System Events"
    keystroke "k" using {command down}
    delay 0.5
    keystroke "$SHARE_URL"
    delay 0.5
    keystroke return
  end tell
end tell
EOF
    fi
  else
    error "open ${SHARE_URL} に失敗。フォールバックへ"
    osascript <<EOF
tell application "Finder"
  activate
  tell application "System Events"
    keystroke "k" using {command down}
    delay 0.5
    keystroke "$SHARE_URL"
    delay 0.5
    keystroke return
  end tell
end tell
EOF
  fi
fi





# #!/bin/bash
# afplay /System/Library/Sounds/Blow.aiff
# caffeinate -d -i -u -t 3600 &>/dev/null &

# # turn and keep display ON for a while
# osascript << EOF
# on run
#     tell application "System Events"
#         delay 0.5
#         keystroke return
#         delay 0.5
#         keystroke return
#         delay 0.5
#         keystroke return
#     end tell
# end run
# EOF

# osascript << EOF
# on run
#     tell application "System Events"
#         delay 0.5
#         keystroke return
#         delay 0.5
#         keystroke return
#         delay 0.5
#         keystroke return
#     end tell
# end run
# EOF


# SSID=$( /System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I  | awk -F' SSID: '  '/ SSID: / {print $2}' )
# computer_name=$(scutil --get ComputerName)

# show_dialog() {
# osascript << EOF
# on run
# set computer_name to do shell script "scutil --get ComputerName" as text
# set dialog_text to "[$computer_name] " & "$SSID" & "に接続しました" as text
# tell app "System Events" to display dialog dialog_text buttons {"OK"} default button "OK" giving up after 2
# end run
# EOF
# }


# # mount shared drive
# mount_shared() {
# osascript << EOF
# on run
# tell application "Finder"
#     activate
#     tell application "System Events"
#         keystroke "k" using {command down}
#         delay 0.5
#         keystroke return
#         delay 0.5
#         keystroke return
#         delay 2
#     end tell
# end tell
# end run
# EOF
# }

# main() {
#     show_dialog
#     if [ -d "/Volumes/shared" ]; then
#     echo "/Volumes/shared exists"
#     else
#         echo "/Volumes/shared does not exist"
#         mount_shared
#     fi
# }

# main
