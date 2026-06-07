#!/usr/bin/bash

# Toggles between power-saver and whatever profile was active before.
# The previous profile is saved to a temp file so it survives multiple toggles.
# Falls back to "balanced" if no previous profile is recorded.

PREV_PROFILE=/tmp/hypr-power-profile-previous

current=$(powerprofilesctl get)

if [ "$current" = "power-saver" ]; then
    # Restore the saved profile, defaulting to balanced if the file is missing.
    prev=$(cat "$PREV_PROFILE" 2>/dev/null || echo "balanced")
    powerprofilesctl set "$prev"
    rm -f "$PREV_PROFILE"
    hyprctl notify 1 1500 0 "fontsize:20 󱤅 Power saver mode off (current: $prev)"
else
    # Save the current profile before switching away from it.
    echo "$current" > "$PREV_PROFILE"
    powerprofilesctl set "power-saver"
    hyprctl notify 1 1500 0 "fontsize:20 󱤅 Power saver mode on"
fi
