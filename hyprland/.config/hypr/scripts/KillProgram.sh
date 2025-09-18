#!/usr/bin/bash

# Get id of an active window
active_pid=$(hyprctl activewindow | grep -o 'pid: [0-9]*' | cut -d' ' -f2)

# Close active window
kill $active_pid

# DOOM shotgun sound
paplay $HOME/.config/hypr/scripts/sounds/SHOTGUN16.WAV

notify-send "󰓾  Kill Program" "Target Neutralized"
