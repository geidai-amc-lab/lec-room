#!/bin/bash

# run
# $ sh ./remove-login-item.sh script_name

# 引数で削除するスクリプトの名前を受け取る
script_name="$1"

# プロパティリストのパスを取得する
plist_path="$HOME/Library/LaunchAgents/com.$script_name.plist"

# ログイン項目から削除する
if [[ -f "$plist_path" ]]; then
    launchctl unload "$plist_path"
    rm "$plist_path"
    echo "Removed $script_name from login items."
else
    echo "$script_name is not in login items."
fi
