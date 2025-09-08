#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

### ===== 設定 =====
SHARE_URL="smb://172.16.1.23/shared"   # 共有URL（基本はIP直指定）
MOUNT_POINT="/Volumes/shared"
CAFFEINATE_DURATION=3600               # 秒
USE_KEYCHAIN=false                     # trueならsecurityコマンドでKeychain参照（TCCダイアログ出ることあり）
KEYCHAIN_SERVICE="amc-share"           # USE_KEYCHAIN=trueのときのサービス名
MOUNT_TIMEOUT=6                        # mount_smbfsコマンド全体の打ち切り秒（外部timeout未導入でも動作）
SMB_T=3                                # mount_smbfsの内部タイムアウト(-T)
SMB_R=0                                # mount_smbfsのリトライ回数(-R)

### ===== ヘルパ =====
log()   { printf '[%s] %s\n' "$(date '+%F %T')" "$*"; }
error() { printf '[%s] ERROR: %s\n' "$(date '+%F %T')" "$*" >&2; }

notify() {
  # 通知は失敗しても続行
  local title="$1" msg="$2"
  osascript -e "display notification \"${msg//\"/\\\"}\" with title \"${title//\"/\\\"}\"" >/dev/null 2>&1 || true
}

# gtimeout/timeout が無ければ内蔵タイムアウト（bg+sleep+kill）を使う
with_timeout() {
  local sec="$1"; shift
  if command -v gtimeout >/dev/null 2>&1; then
    gtimeout "$sec" "$@"
  elif command -v timeout >/dev/null 2>&1; then
    timeout "$sec" "$@"
  else
    # poor man's timeout
    ("$@" & pid=$!
      { sleep "$sec"; kill -0 "$pid" 2>/dev/null && kill -9 "$pid" 2>/dev/null || true; } &
      wait "$pid"
    )
  fi
}

precheck_445() {
  local host="${1#smb://}"; host="${host%%/*}"   # smb://HOST/...
  # 445/TCP 疎通（2秒）
  nc -z -G 2 "$host" 445 >/dev/null 2>&1
}

already_mounted() {
  mount | grep -q " on ${MOUNT_POINT} "
}

# Finder/アプリが掴んでいても外せるように強制アンマウント
force_unmount_if_stuck() {
  if already_mounted; then
    # /Volumes/shared配下をカレントにしているシェルを逃がす
    if pwd | grep -q "^${MOUNT_POINT}"; then cd ~; fi

    # 使用中プロセスが見えるならログに出すだけ（殺さない）
    if command -v lsof >/dev/null 2>&1; then
      lsof +D "$MOUNT_POINT" 2>/dev/null | head -n 20 || true
    fi

    # まず通常アンマウント、ダメなら強制
    diskutil unmount "$MOUNT_POINT" >/dev/null 2>&1 || true
    diskutil unmount force "$MOUNT_POINT" >/dev/null 2>&1 || \
      sudo umount -f "$MOUNT_POINT" >/dev/null 2>&1 || true
    sleep 0.3
  fi
}

# 読み出し開始までを健康チェック（ls が即返るか）
wait_share_ready() {
  local tries=5
  while (( tries-- > 0 )); do
    if ls -1 "$MOUNT_POINT" >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.3
  done
  return 1
}

get_creds() {
  # 既定は .nsmbrc/Keychain 自動（-N）。USE_KEYCHAIN=true の場合のみ security を使う
  if "$USE_KEYCHAIN"; then
    # TCC（管理許可）ダイアログが出る可能性あり
    local account pass
    account=$(security find-generic-password -s "$KEYCHAIN_SERVICE" -g 2>&1 | awk -F'"' '/"acct"/{print $2; exit}') || return 1
    pass=$(security find-generic-password -s "$KEYCHAIN_SERVICE" -w 2>/dev/null || true)
    printf '%s:%s\n' "$account" "$pass"
  else
    printf ':\n'
  fi
}

build_target_url() {
  local base="$1" user="$2" pass="$3"
  if [[ -n "$user" && -n "$pass" ]]; then
    local esc_pass="${pass//:/%3A}"; esc_pass="${esc_pass//@/%40}"
    printf "//%s:%s@%s" "$user" "$esc_pass" "${base#smb://}"
  else
    # 認証は .nsmbrc/Keychain に任せる
    printf "%s" "$base"
  fi
}

### ===== 本体 =====

# 軽いフィードバックとスリープ抑止（権限ダイアログを避けたいなら音/osascriptは切ってOK）
afplay /System/Library/Sounds/Blow.aiff >/dev/null 2>&1 || true
if ! pgrep -x caffeinate >/dev/null; then
  caffeinate -d -i -u -t "$CAFFEINATE_DURATION" >/dev/null 2>&1 &
  log "caffeinate 起動 (${CAFFEINATE_DURATION}s)"
fi

# 既存が半死状態で残っていたら外す
force_unmount_if_stuck

# 既にマウント済なら終了
if already_mounted; then
  log "${MOUNT_POINT} は既にマウント済み"
  exit 0
fi

# 事前疎通（遅い待ちを食らわない）
if ! precheck_445 "$SHARE_URL"; then
  error "445/TCP unreachable. サーバが応答しません: ${SHARE_URL}"
  notify "マウント失敗" "サーバに到達できません（445/TCP）"
  exit 1
fi

# 認証（デフォルトは.nsmbrc/Keychain自動。TCC回避のため security は使わない）
userpass=$(get_creds || true)
user="${userpass%%:*}"; pass="${userpass#*:}"; [[ "$user" == "$pass" ]] && user="" && pass=""

target="$(build_target_url "$SHARE_URL" "$user" "$pass")"
mkdir -p "$MOUNT_POINT"

# mount_smbfs：交渉最小化 & Finderの覗き込み抑制
SMB_ARGS=(-o nobrowse -T "$SMB_T" -R "$SMB_R")
# 認証を.nsmbrc/Keychainに委ねるなら -N
[[ -z "$user" ]] && SMB_ARGS+=(-N)

log "mount_smbfs 接続試行: $target -> $MOUNT_POINT  (opts: ${SMB_ARGS[*]})"

if with_timeout "$MOUNT_TIMEOUT" mount_smbfs "${SMB_ARGS[@]}" "$target" "$MOUNT_POINT" 2>/dev/null; then
  if wait_share_ready; then
    log "マウント成功: $MOUNT_POINT"
    notify "マウント完了" "$MOUNT_POINT をマウントしました"
    exit 0
  else
    error "マウント直後の読み出しが不安定（lsが返らない）→ 再試行"
    force_unmount_if_stuck
  fi
else
  error "mount_smbfs 失敗（タイムアウト/応答なし）"
fi

# ワンモアリトライ（短時間）
log "リトライ 1 回目"
if with_timeout "$MOUNT_TIMEOUT" mount_smbfs "${SMB_ARGS[@]}" "$target" "$MOUNT_POINT" 2>/dev/null && wait_share_ready; then
  log "マウント成功: $MOUNT_POINT"
  notify "マウント完了" "$MOUNT_POINT をマウントしました（リトライ）"
  exit 0
fi

error "共有ドライブのマウントに失敗しました"
notify "マウント失敗" "共有ドライブをマウントできませんでした"
exit 1
