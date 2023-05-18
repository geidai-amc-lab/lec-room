# lec-room
AMC演習室PCを管理するためのスクリプトなどを置いていくリポジトリです。(2023.04 川田)

# 運用方針
- このリポジトリにはpublicにしてよいものだけを置く。
  - パスワードやAPI keyが記載されたファイルをアップロードしない。（.gitignoreする）
  - ネットワーク構成などが類推できそうなものは出来るだけ置かない。
  
# よく使う （コピペ用）

#### DeepFreeze解除
```
/Library/Zool/sbin/df_disable.sh
```

#### DeepFreeze保護 
```
/Library/Zool/sbin/df_enable.sh
```

```
sudo dscl . delete /Users/autologin Password
sudo defaults write /Library/Preferences/com.apple.loginwindow autoLoginUser autologin
```

#### ファイル作成
```
echo -e "[default]\nsigning_required=no" | sudo tee /Library/Preferences/nsmb.conf > /dev/null
```

#### ファイル移動
```
mv "/Users/admin/Documents/Max\\ 8/Packages/"* "/Users/autologin/Documents/Max 8/Packages/"
```

# テクニック
```
sh -c "$(curl -fsSl https://raw.githubusercontent.com/ytr0/setup/main/AllowAccess.sh
)"
```

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

```
#!/bin/bash

run_osascript() {
osascript << EOF
on run
tell application "Finder"
    activate
    tell application "System Events"
        keystroke "k" using {command down}
        delay 0.5
        keystroke return
        delay 0.5
        keystroke return
        delay 2
    end tell
end tell
end run
EOF
}

run_osascript
```

ダウンロード
```
target="/Users/amc-scripts"
resource="https://raw.githubusercontent.com/geidai-amc-lab/lec-room/main/01-init"

mkdir $target
chmod u+w $target

curl -fsSL $resource/amcmac-init.sh --output $target/amcmac-init.sh
```

sudo pmset repeat shutdown MTWRFSU 20:00:00
pmset -g sched

