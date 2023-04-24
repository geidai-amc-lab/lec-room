# ログイン時実行スクリプト



#### How to setup

```
target="/Users/amc-scripts"
resource="https://raw.githubusercontent.com/geidai-amc-lab/lec-room/main/01-init"

mkdir $target
chmod u+w $target

curl -fsSL $resource/amcmac-init.sh --output $target/amcmac-init.sh
curl -fsSL $resource/add-login-item.sh --output $target/add-login-item.sh

sh $target/add-login-item.sh $target/amcmac-init.sh
```

```
mkdir /Users/amc-scripts

curl -fsSL https://raw.githubusercontent.com/geidai-amc-lab/lec-room/main/01-init/amcmac-init.sh --output /Users/amc-scripts/amcmac-init.sh
curl -fsSL https://raw.githubusercontent.com/geidai-amc-lab/lec-room/main/01-init/add-login-item.sh --output /Users/amc-scripts/add-login-item.sh
sh /Users/amc-scripts/add-login-item.sh /Users/amc-scripts/amcmac-init.sh
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

#### Test
```
  sh -c "$(curl -fsSl https://raw.githubusercontent.com/geidai-amc-lab/lec-room/main/01-init/amcmac-remote-init.sh
)"
```
