#!/bin/bash
export LANG=ja_JP.UTF-8
export LC_CTYPE=ja_JP.UTF-8

afplay /System/Library/Sounds/Basso.aiff
SSID=$( /System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I  | awk -F' SSID: '  '/ SSID: / {print $2}' )
computer_name=$(scutil --get ComputerName)

show_dialog() {
osascript << EOF
on run
tell app "System Events" to display dialog "[$computer_name] $SSIDに接続しました" buttons {"OK"} default button "OK" giving up after 2
end run
EOF
}

# mount shared drive
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

show_dialog
run_osascript
