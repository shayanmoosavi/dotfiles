#!/usr/bin/bash

# Toggles the blue light filter by starting or killing hyprsunset.

if pidof "hyprsunset" > /dev/null 2>&1; then
    killall -SIGHUP "hyprsunset"
    hyprctl notify 1 1500 0 "fontsize:20 󱩌 Night mode off"
else
    hyprsunset & disown > /dev/null 2>&1
    hyprctl notify 1 1500 0 "fontsize:20 󱩌 Night mode on"
fi
