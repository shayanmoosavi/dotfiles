#!/usr/bin/bash

# Source utility functions
source "$(dirname "$0")/Utils.sh"

# Function to show usage information
show_usage() {
    echo "Usage: $0 [--browser|--file-manager|--terminal] [additional_args...]" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $0 --browser" >&2
    echo "  $0 --browser --new-tab https://google.com" >&2
    echo "  $0 --file-manager ~/Downloads" >&2
    echo "  $0 --terminal --hold -e htop" >&2
}

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    echo "Error: No arguments provided" >&2
    show_usage
    exit 1
fi

# Parse the first argument to determine application type
app_type=""
case "$1" in
    --browser)
        app_type="browser"
        ;;
    --file-manager)
        app_type="file-manager"
        ;;
    --terminal)
        app_type="terminal"
        ;;
    --help|-h)
        show_usage
        exit 0
        ;;
    *)
        echo "Error: Unknown option '$1'" >&2
        show_usage
        exit 1
        ;;
esac

# Get the default application
app=$(get_default_app "$app_type")

# Check if we successfully got an application
if [ $? -ne 0 ] || [ -z "$app" ]; then
    echo "Error: Could not determine application for $app_type" >&2
    exit 1
fi

# Remove the first argument (the app type flag) and pass the rest to the application
shift

# Launch the application with remaining arguments
exec "$app" "$@"
