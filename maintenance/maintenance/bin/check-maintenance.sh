#!/usr/bin/bash


# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

# Initialize logging with daily log file
CURRENT_DATE=$(date +'%Y-%m-%d')
init_logging "maintenance-tasks/${CURRENT_DATE}.log"

# Configuration
STATE_DIR="$HOME/.local/share/maintenance-tasks"
PENDING_FLAG="$STATE_DIR/pending-reminders"

# Check if notify-send is available
check_notifications() {
    if ! command -v notify-send &> /dev/null; then
        print_warning "notify-send not found, desktop notifications disabled"
        return 1
    fi
    return 0
}

# Send desktop notification
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"  # low, normal, critical

    if check_notifications; then
        notify-send \
            --urgency="$urgency" \
            --app-name="Maintenance Tasks" \
            --icon=system-software-update \
            "$title" \
            "$message"

        print_info "Sent notification: $title"
    fi
}

# Main check function
check_and_notify() {
    print_info "========== Maintenance check started =========="

    # Run the maintenance-tasks check command
    local check_output
    set +e
    check_output=$("$SCRIPT_DIR/../maintenance-tasks.sh" check 2>&1)
    local check_status=$?
    set -e

    print_info "Check output: $check_output"

    if [[ $check_status -eq 0 ]]; then
        # Tasks are due
        if [[ -f "$PENDING_FLAG" ]]; then
            local due_count
            due_count=$(cat "$PENDING_FLAG")

            local title="Maintenance Reminder"
            local message

            if [[ $due_count -eq 1 ]]; then
                message="1 maintenance task is due. Run 'maintenance-tasks' to review."
            else
                message="$due_count maintenance tasks are due. Run 'maintenance-tasks' to review."
            fi

            send_notification "$title" "$message" "normal"
            print_info "$due_count task(s) due"
        fi
    else
        # No tasks due
        print_info "No tasks due"
    fi

    print_info "========== Maintenance check completed =========="
}

# Main execution
main() {
    print_info "Checking maintenance tasks..."

    check_and_notify

    echo ""
    print_info "Log saved to: $(get_log_file)"
}

main "$@"
