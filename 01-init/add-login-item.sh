#!/bin/bash

# run
# ./add-login-item.sh ./test.sh

# 引数でログイン項目に追加するスクリプトのパスを受け取る
script_path=$1
chmod +x $script_path

# パスからファイル名を取得し、拡張子を除いたファイル名をscript_nameとする
script_name="$(basename "$script_path" | sed 's/\.[^.]*$//')"

cd /

# ログイン項目に追加するためのプロパティリストを作成する
plist_path="/Library/LaunchAgents/com.$script_name.plist"
cat > "$plist_path" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>Label</key>
        <string>com.$script_name</string>
        <key>ProgramArguments</key>
        <array>
                <string>$1</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
</dict>
</plist>
EOF

# ログイン項目に追加する
launchctl load "$plist_path"
