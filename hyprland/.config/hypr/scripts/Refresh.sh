#!/usr/bin/bash

# Source the Utils.sh script
source "$HOME/.config/hypr/scripts/Utils.sh"

# Refresh waybar
refresh_waybar() {
    if is_running "waybar"; then
        log_message "INFO" "Refreshing waybar"
        if killall -SIGUSR2 waybar; then
            log_message "INFO" "Waybar refreshed successfully"
            return 0
        else
            log_message "ERROR" "Failed to refresh waybar"
            return 1
        fi
    else
        log_message "WARN" "Waybar not running, attempting to start"
        if waybar &> /dev/null & then
            log_message "INFO" "Waybar started successfully"
            return 0
        else
            log_message "ERROR" "Failed to start waybar"
            return 1
        fi
    fi
}

# Refresh swaync
refresh_swaync() {
    if is_running "swaync"; then
        log_message "INFO" "Refreshing swaync"
        local config_result=0
        local css_result=0

        if ! swaync-client --reload-config 2>> "$LOG_FILE"; then
            log_message "ERROR" "Failed to reload swaync config"
            config_result=1
        fi

        if ! swaync-client --reload-css 2>> "$LOG_FILE"; then
            log_message "ERROR" "Failed to reload swaync CSS"
            css_result=1
        fi

        if [[ $config_result -eq 0 && $css_result -eq 0 ]]; then
            log_message "INFO" "Swaync refreshed successfully"
            return 0
        else
            return 1
        fi
    else
        log_message "WARN" "Swaync not running, attempting to start"
        if swaync &> /dev/null & then
            log_message "INFO" "Swaync started successfully"
            return 0
        else
            log_message "ERROR" "Failed to start swaync"
            return 1
        fi
    fi
}

# Refresh the Hyprland configuration
refresh_hyprland() {
    log_message "INFO" "Refreshing Hyprland configuration"
    if hyprctl reload 2>> "$LOG_FILE"; then
        log_message "INFO" "Hyprland configuration reloaded successfully"
        return 0
    else
        log_message "ERROR" "Failed to reload Hyprland configuration"
        return 1
    fi
}

main() {
    rotate_log
    log_message "INFO" "Starting Hyprland session refresh"

    local failed_components=()

    # Refresh components
    if ! refresh_waybar; then
        failed_components+=("Waybar")
    fi

    if ! refresh_swaync; then
        failed_components+=("Swaync")
    fi

    if ! refresh_hyprland; then
        failed_components+=("Hyprland")
    fi

    # Report results
    if [[ ${#failed_components[@]} -eq 0 ]]; then
        log_message "INFO" "All components refreshed successfully"
    else
        local failed_list=$(IFS=", "; echo "${failed_components[*]}")
        log_message "ERROR" "Some components failed to refresh: $failed_list"
        notify-send -u critical "Refresh Failed" "Failed components: $failed_list\nCheck log: $LOG_FILE"
        exit 1
    fi
}

main
