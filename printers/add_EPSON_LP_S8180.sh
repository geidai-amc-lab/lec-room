#!/bin/bash

# Web経由で実行
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ytr0/setup/main/add_EPSON_LP_S8180.sh)"

# プリンタ一覧取得
lpstat -s

# 以下メイン処理
cd Users/autologin
curl -fsSL https://raw.githubusercontent.com/ytr0/setup/main/S8180.ppd --output /Users/autologin/S8180.ppd
lpadmin -p EPSON_LP_S8180 -E -v $(ippfind | head -1) -P /Users/autologin/S8180.ppd
rm /Users/autologin/S8180.ppd

# 新しいプリンタをデフォルトに設定
lpoptions -d EPSON_LP_S8180
