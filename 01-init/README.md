# ログイン時実行スクリプト



#### Installation

main
```
sh -c "$(curl -fsSl https://raw.githubusercontent.com/geidai-amc-lab/lec-room/main/01-init/_setup.sh
)"
```
develop
```
sh -c "$(curl -fsSl https://raw.githubusercontent.com/geidai-amc-lab/lec-room/develop/01-init/_setup.sh
)"
```

#### Test Remote Script
main
```
sh -c "$(curl -fsSl https://raw.githubusercontent.com/geidai-amc-lab/lec-room/main/01-init/amcmac-remote-init.sh
)"
```
develop
```
sh -c "$(curl -fsSl https://raw.githubusercontent.com/geidai-amc-lab/lec-room/develop/01-init/amcmac-remote-init.sh
)"
```

#### How to confirm
```
USER=""
PASS=""

osascript <<EOF
tell application "System Events"
  keystroke "${USER}"
  keystroke tab
  delay 0.5
  keystroke "${PASS}"
  delay 0.5
  keystroke return
end tell
EOF
```
