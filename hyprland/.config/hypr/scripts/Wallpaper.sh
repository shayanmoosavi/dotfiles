#!/usr/bin/bash

# Store config modification time before running waypaper
config_file="$HOME/.config/waypaper/config.ini"
if [[ -f "$config_file" ]]; then
    old_mtime=$(stat -c %Y "$config_file" 2>/dev/null)
else
    old_mtime=0
fi

# Choose the wallpaper with waypaper
waypaper &> /dev/null
WAYPAPER_EXIT_CODE=$?

# Check if waypaper exited successfully
if [[ $WAYPAPER_EXIT_CODE -ne 0 ]]; then
    echo "Waypaper failed. Exiting..." >&2
    exit 1
fi

# Check if config was actually modified (wallpaper was selected)
if [[ -f "$config_file" ]]; then
    new_mtime=$(stat -c %Y "$config_file" 2>/dev/null)
    if [[ "$old_mtime" -eq "$new_mtime" ]]; then
        echo "No wallpaper was selected. Exiting..." >&2
        exit 0
    fi
else
    echo "ERROR: Config file not found after waypaper. Exiting..." >&2
    exit 1
fi

# Storing the current wallpaper
current_wallpaper=$(awk -F'=' '/^wallpaper/{gsub(/^ +| +$/, "", $2); print $2}' ~/.config/waypaper/config.ini)

# Expand ~ to $HOME
if [[ $current_wallpaper == ~* ]]; then
    current_wallpaper="${HOME}${current_wallpaper:1}"
fi

# Linking the current wallpaper to hyprlock config path
ln -sf "$current_wallpaper" "$HOME/.config/hypr/current_wallpaper"

echo "Updating SDDM background..."

# Development version. Will change once completed
# sddm_script="$HOME/.config/hypr/scripts/UpdateSDDM.sh"
sddm_script="$HOME/dotfiles/hyprland/.config/hypr/scripts/UpdateSDDM.sh"

cmd="kitty -e $sddm_script \"$current_wallpaper\""
hyprctl dispatch exec "$cmd"

# Giving the current wallpaper to wallust for color palette generation
echo "Generating color palette from current wallpaper..."
wallust run "$current_wallpaper" &> /dev/null
matugen image "$current_wallpaper" &> /dev/null

# Reloading swaync
swaync-client --reload-config
swaync-client --reload-css

