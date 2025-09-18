#!/usr/bin/bash

# Volume Control Script for Hyprland
# ==============================================================================
# Usage:
#   ./Volume.sh up    - Increase volume by 5%
#   ./Volume.sh down  - Decrease volume by 5%
#   ./Volume.sh mute  - Toggle mute/unmute
# ==============================================================================

# Get the default sink (audio output device)
get_default_sink() {
    pactl get-default-sink
}

# Get current volume percentage
get_volume() {
    local sink=$(get_default_sink)
    pactl get-sink-volume "$sink" | grep -Po '\d+(?=%)' | head -n1
}

# Get mute status
is_muted() {
    local sink=$(get_default_sink)
    pactl get-sink-mute "$sink" | grep -q "yes"
}

# Send notification with volume info
send_notification() {
    local volume=$(get_volume)
    local icon

    if is_muted; then
        icon="audio-volume-muted"
        notify-send -t 2000 -h string:x-canonical-private-synchronous:volume \
                   -h int:value:0 "Volume Muted" "" -i "$icon"
    else
        if [ "$volume" -gt 60 ]; then
            icon="audio-volume-high"
        elif [ "$volume" -gt 30 ]; then
            icon="audio-volume-medium"
        else
            icon="audio-volume-low"
        fi

        notify-send -t 2000 -h string:x-canonical-private-synchronous:volume \
                   -h int:value:"$volume" "Volume: ${volume}%" "" -i "$icon"
    fi
}

# Play sound feedback
play_sound() {
    local sound_file="/usr/share/sounds/freedesktop/stereo/audio-volume-change.oga"
    if [ -f "$sound_file" ] && ! is_muted; then
        paplay "$sound_file" &
    fi
}

# Main logic
case "$1" in
    "up")
        # Increase volume by 5%, max 100%
        pactl set-sink-volume @DEFAULT_SINK@ +5%
        # Ensure we don't go above 100%
        current_vol=$(get_volume)
        if [ "$current_vol" -gt 100 ]; then
            pactl set-sink-volume @DEFAULT_SINK@ 100%
        fi
        # Unmute if it was muted
        pactl set-sink-mute @DEFAULT_SINK@ 0
        send_notification
        play_sound
        ;;
    "down")
        # Decrease volume by 5%
        pactl set-sink-volume @DEFAULT_SINK@ -5%
        # Unmute if it was muted
        pactl set-sink-mute @DEFAULT_SINK@ 0
        send_notification
        play_sound
        ;;
    "mute")
        # Toggle mute
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        send_notification
        ;;
    *)
        echo "Usage: $0 {up|down|mute}"
        echo "  up    - Increase volume by 5%"
        echo "  down  - Decrease volume by 5%"
        echo "  mute  - Toggle mute/unmute"
        exit 1
        ;;
esac
