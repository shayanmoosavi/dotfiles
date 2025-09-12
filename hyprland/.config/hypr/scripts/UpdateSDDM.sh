#!/usr/bin/bash

if [[ $# -ne 1 ]]; then
    exit 1
fi

current_wallpaper="$1"
SDDM_THEME="sddm-astronaut-theme"
SDDM_BG_PATH="/usr/share/sddm/themes/$SDDM_THEME/current_wallpaper"

# Launch in a terminal for authentication
echo "Updating SDDM background..."
echo "Wallpaper: $current_wallpaper"
sudo cp "$current_wallpaper" "$SDDM_BG_PATH" && 
sudo chmod 644 "$SDDM_BG_PATH" &&
sudo chown root:root "$SDDM_BG_PATH" &&
echo "SDDM background updated successfully!" ||
echo "Failed to update SDDM background"
echo "Press Enter to close..."
read
