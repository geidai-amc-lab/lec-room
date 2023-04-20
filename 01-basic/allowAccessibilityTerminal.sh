#!/bin/bash


osascript << EOF
on run
	
	tell application "System Settings"
		
		do shell script "open " & "/System/Library/PreferencePanes/Security.prefPane"
		delay 1
	end tell
	
	tell application "System Events"
		tell application process "System Settings"
			try
				-- set uiElements to UI elements
				tell window 1
					tell group 1's splitter group 1
						tell group 2's group 1's scroll area 1
							set uiElements to entire contents
							click group 1's button 15
						end tell
					end tell
				end tell
				
			end try
		end tell
	end tell
	
	delay 0.5
	
	tell application "System Events"
		tell application process "System Settings"
			try
				tell window 1's group 1's splitter group 1's group 2's group 1's scroll area 1's group 1's scroll area 1's table 1
					-- set uiElements to UI elements
					
					set RowsList to row 2
					set devList to {}
					repeat with i in RowsList
						tell i's UI element 1's static text
							set dev to name
							
						end tell
						tell i's UI element 1
							click checkbox 1
							-- set uiElements to UI elements
						end tell
					end repeat
				end tell
				
				
			end try
		end tell
	end tell
	
end run
