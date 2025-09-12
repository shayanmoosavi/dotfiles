#!/usr/bin/bash


# Function to show usage
show_usage() {
    echo "Usage: $0 [--inc|--dec] [percent_amount]" >&2
    echo "" >&2
    echo "OPTIONS" >&2
    echo "  --inc  increase the brightness" >&2
    echo "  --dec  decrease the brightness" >&2
}

# Validating number of arguments
if [ $# -eq 0 ]; then
    echo "ERROR: No arguments provided!" >&2
    show_usage
    exit 1
elif [ $# -ne 2 ]; then
    echo "ERROR: Wrong number of arguments!" >&2
    show_usage
    exit 1
fi

# Validating the second argument
if [[ ! $2 =~ ^[0-9]+$ ]]; then
    echo "ERROR: percent_amount should be a number!" >&2
    show_usage
    exit 1
elif [[ $2 -gt 100 || $2 -lt 1 ]]; then
    echo "ERROR: percent_amount should be between 1 and 100!" >&2
    show_usage
    exit 1
fi

# Validating first argument
case "$1" in
    --inc)
        brightnessctl set "$2%+"
    ;;
    --dec)
        brightnessctl set "$2%-"
    ;;
    *)
        echo "ERROR: Invalid argument!" >&2
        show_usage
        exit 1
    ;;
esac

