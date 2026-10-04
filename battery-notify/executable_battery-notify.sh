#!/bin/bash

# Battery percentage at which to notify
WARNING_LEVEL=20
CRITICAL_LEVEL=10
BATTERY_STATE=$(upower -b | grep -P "state:" | awk '{print $2}')
BATTERY_LEVEL=$(upower -b | grep -P "percentage:" | awk '{print $2}' | sed s/%//)

# Use files to store whether we've shown a notification or not (to prevent multiple notifications)
STATE_DIR=$HOME/.local/share/battery-notify
FULL_FILE=$STATE_DIR/battery_full
SUFFICIENT_FILE=$STATE_DIR/battery_sufficient
WARNING_FILE=$STATE_DIR/battery_warning
CRITICAL_FILE=$STATE_DIR/battery_critical

# Ensure the directory exists
mkdir -p "$STATE_DIR"

# Reset notifications if the computer is charging/discharging
if [ "$BATTERY_STATE" == "discharging" ] && ([ -f "$FULL_FILE" ] || [ -f "$SUFFICIENT_FILE" ]); then
	rm $FULL_FILE $SUFFICIENT_FILE
elif [ "$BATTERY_STATE" == "charging" ] && [ -f "$WARNING_FILE" ]; then
	rm "$WARNING_FILE"
fi

# If the battery is charging and is full (and has not shown notification yet)
if [ "$BATTERY_LEVEL" -gt 99 ] && [ "$BATTERY_STATE" == "charging" ] && [ ! -f "$FULL_FILE" ]; then
	notify-send -t 4000 \
	"Battery Full" "Battery is full. Please disconnect your charger." \
	-i "battery-full-charging-symbolic"
	touch "$FULL_FILE"

# If the battery is charging and is sufficiently charged (and has not shown notification yet)
elif [ "$BATTERY_LEVEL" -gt 85 ] && [ "$BATTERY_STATE" == "charging" ] && [ ! -f "$SUFFICIENT_FILE" ]; then
	notify-send -t 4000 \
	"Battery Charged" "Battery is sufficiently charged. Stop charging to prevent premature battery wear." \
	-i "battery-good-charging-symbolic"
	touch "$SUFFICIENT_FILE"

# If the battery is low and is not charging (and has not shown notification yet)
elif [ "$BATTERY_LEVEL" -le $WARNING_LEVEL ] && [ "$BATTERY_STATE" == "discharging" ] && [ ! -f "$WARNING_FILE" ]; then
	notify-send "Low Battery" "${BATTERY_LEVEL}% of battery remaining. Consider plugging in your charger." \
	-u critical -i "battery-caution-symbolic"
	touch "$WARNING_FILE"

# If the battery is critical and is not charging (and has not shown notification yet)
elif [ "$BATTERY_LEVEL" -le $CRITICAL_LEVEL ] && [ "$BATTERY_STATE" == "discharging" ] && [ ! -f "$CRITICAL_FILE" ]; then
	notify-send "Battery Critical" "The computer will shutdown soon. Please plug in your charger as soon as possible." \
	-u critical -i "battery-empty-symbolic"
	touch "$CRITICAL_FILE"
fi
