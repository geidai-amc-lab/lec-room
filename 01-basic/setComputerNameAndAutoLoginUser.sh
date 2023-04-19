#!/bin/bash

# 実行
# sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/ytr0/setup/main/amc_mac.sh)"
# sudo sh -c "$(curl -fsSL https://to2.pw/LBMmj)"

echo "+-------------------------------------------------------+"
echo "AMC演習室用のMac 設定ツール"
echo "+-------------------------------------------------------+"

# ユーザにコンピュータ名を尋ねる
echo "現在のComputerName　-> "
sudo scutil --get ComputerName
read -p "新しい名前を入力してください (eg:AMCMAC-01): " new_name

# 新しいコンピュータ名が入力された場合、設定を変更する
if [[ -n "$new_name" ]]; then
    sudo scutil --set ComputerName "$new_name"
    sudo scutil --set LocalHostName "$new_name"
    sudo scutil --set HostName "$new_name"
    echo "コンピュータ名を設定しました [ComputerName, LocalHostName, HostName] -> "
    sudo scutil --get ComputerName
fi
echo ""

echo "'autologin'をデフォルトのログインユーザに設定します"
sudo defaults write /Library/Preferences/com.apple.loginwindow autoLoginUser autologin
sudo defaults write /Library/Preferences/com.apple.loginwindow autoLoginUser -string autologin

echo "現在の[autoLoginUser] -> "
sudo defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser
