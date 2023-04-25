#!/bin/bash

# SSID
SSID="amc-lec"
resource="https://raw.githubusercontent.com/geidai-amc-lab/lec-room/main/01-init/amcmac-remote-init.sh"
echo $SSID"に接続を試みます..."

# networksetupコマンドでWi-Fiの状態を取得し、Wi-Fiがオフになっている場合はオンにする
if ! networksetup -getairportpower Wi-Fi | grep -q "On"; then
    networksetup -setairportpower Wi-Fi on
fi

wifi_interface=$(networksetup -listallhardwareports | grep -A 1 Wi-Fi | grep "Device" | awk '{print $2}')

#一覧表示
/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport scan

#接続
networksetup -setairportnetwork $wifi_interface $SSID

# 20秒間接続を試みる
for i in {1..20}; do
  if /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep -q " SSID: $SSID"; then
  echo $SSID"に接続しました。"
  sh -c "$(curl -fsSl $resource
)"

    exit 0
  fi
  printf "."
  sleep 1
done

# 接続に失敗した場合はエラーメッセージを表示して終了
echo $SSID"に接続できませんでした。"
exit 1

&
