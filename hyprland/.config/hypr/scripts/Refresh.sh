#!/usr/bin/bash

# Refresh waybar
killall -SIGUSR2 waybar

# Refresh swaync
swaync-client --reload-config
swaync-client --reload-css

# Refresh the Hyprland configuration
hyprctl reload
