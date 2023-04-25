#!/bin/bash

# スクリプト名のリスト
scripts=("amcmac-init.sh" "add-login-item.sh" "openLaunchAgents.command")

# リソースのURLとインストール先ディレクトリの定義
resource="https://raw.githubusercontent.com/geidai-amc-lab/lec-room/main/01-init"
install_dir="/Users/amc-scripts"

# インストール先ディレクトリを作成し、書き込み権限を付与
mkdir -p "$install_dir"
chmod u+w "$install_dir"

# スクリプトをダウンロードしてインストール先ディレクトリに保存
for script in "${scripts[@]}"; do
  curl -fsSL "$resource/$script" --output "$install_dir/$script"
done

# add-login-item.shを実行してamcmac-init.shをログインアイテムに追加
sh "$install_dir/add-login-item.sh" "$install_dir/amcmac-init.sh"
