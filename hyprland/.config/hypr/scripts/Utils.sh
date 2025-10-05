#!/usr/bin/bash


# Path to default applications
DEFAULTS_DIR="$HOME/.config/hypr/modules/defaults.conf"

# Function to extract variable value from hyprland config
get_hypr_variable() {
    local var_name="$1"
    # Parse the config file to find the variable definition
    # This handles the format: $VARIABLE = value
    grep "^\s*\$$var_name\s*=" "$DEFAULTS_DIR" | sed 's/.*=\s*//' | tr -d '"' | xargs
}

# Function to get default application with fallback
get_default_app() {
    local app_type="$1"
    local var_name=""
    local fallback=""

    case "$app_type" in
        "browser")
            var_name="browser"
            fallback="firefox"
            ;;
        "file-manager")
            var_name="filemanager"
            fallback="thunar"
            ;;
        "terminal")
            var_name="terminal"
            fallback="kitty"
            ;;
        *)
            echo "Unknown application type: $app_type" >&2
            return 1
            ;;
    esac

    local app=$(get_hypr_variable "$var_name")
    echo "${app:-$fallback}"
}

LOG_FILE="$HOME/.local/state/hypr/refresh.log"
MAX_LOG_SIZE=1048576  # 1MB

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Function to log messages
log_message() {
    local level="$1"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_FILE"
}

# Function to rotate log if too large
rotate_log() {
    if [[ -f "$LOG_FILE" ]]; then
        local log_size=$(stat -c %s "$LOG_FILE" 2>/dev/null || echo 0)
        if [[ $log_size -gt $MAX_LOG_SIZE ]]; then
            mv "$LOG_FILE" "$LOG_FILE.old"
            log_message "INFO" "Log rotated due to size"
        fi
    fi
}

# Function to check if a process is running
is_running() {
    pgrep -x "$1" > /dev/null
}
