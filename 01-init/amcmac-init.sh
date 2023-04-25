#!/bin/bash

# SSID
SSID="amc-lec"
resource="https://raw.githubusercontent.com/geidai-amc-lab/lec-room/main/01-init/amcmac-remote-init.sh"
echo $SSID"に接続を試みます..."

remote_script() {
      sh -c "$(curl -fsSl $resource
  )"
}

# Wi-Fiインタフェースの取得
get_wifi_interface() {
    networksetup -listallhardwareports \
        | grep -A 1 Wi-Fi \
        | grep "Device" \
        | awk '{print $2}'
}

# Wi-Fiの電源がオフの場合はオンにする
turn_on_wifi() {
    wifi_interface=$1
    if ! networksetup -getairportpower $wifi_interface | grep -q "On"; then
        networksetup -setairportpower $wifi_interface on
    fi
}

# Wi-Fiの一覧表示
show_wifi_list() {
    /System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport scan
}

# 指定したSSIDに接続する
connect_to_wifi() {
    wifi_interface=$1
    ssid=$2
    networksetup -setairportnetwork $wifi_interface $ssid
}

# 指定したSSIDに接続ができるまで10秒間試行し、結果に応じて処理を行う
wait_and_handle_connection() {
    ssid=$1
    for i in {1..10}; do
        if /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep -q " SSID: $ssid"; then
            echo $ssid"に接続しました。"
            after_connected
            exit 0
        fi
        printf "."
        sleep 1
    done

    # 接続に失敗した場合は別のSSIDに接続し、エラーメッセージを表示する
    ssid2=$( /System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I  | awk -F' SSID: '  '/ SSID: / {print $2}' )
    echo $ssid"に接続できませんでした。"
    echo $ssid2"に接続しました。"
    after_connected
    exit 1
}

# 目的のSSIDに接続できた場合の処理
after_connected() {
    remote_script
}

# メイン処理
main() {
    wifi_interface=$(get_wifi_interface)
    turn_on_wifi $wifi_interface
    show_wifi_list
    connect_to_wifi $wifi_interface $SSID
    wait_and_handle_connection $SSID
}

# 実行
main
