#!/usr/bin/bash


# Path to default applications
# HYPR_CONFIG="$HOME/.config/hypr/defaults.conf"
DEFAULTS_DIR="$HOME/dotfiles/hyprland/.config/hypr/defaults.conf"

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
