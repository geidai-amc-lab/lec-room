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
killall	-9 Terminal
