#!/bin/bash


set -Eeuo pipefail
trap 'print_error "Unexpected error occurred at line $LINENO"; exit 1' ERR

# Source utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/../utils.sh"

# Initialize logging with daily log file
CURRENT_DATE=$(date +'%Y-%m-%d')
init_logging "system/${CURRENT_DATE}.log"

# Define the actual script to execute
ACTUAL_SCRIPT="$SCRIPT_DIR/../system/failed.sh"

# Verify the script exists and is executable
if [[ ! -f "$ACTUAL_SCRIPT" ]]; then
    print_error "Script not found: $ACTUAL_SCRIPT"
    exit 1
fi

if [[ ! -x "$ACTUAL_SCRIPT" ]]; then
    print_error "Script is not executable: $ACTUAL_SCRIPT"
    print_info "Run: chmod +x $ACTUAL_SCRIPT"
    exit 1
fi

source "$ACTUAL_SCRIPT"

# Main function
main() {

    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                 Failed Systemd Services Check                 ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""

    # Execute the check
    if check_failed_services; then
        echo ""
        print_success "Failed services check completed!"
        echo ""
        print_info "Log saved to: $(get_log_file)"
        echo ""
        exit 0
    else
        echo ""
        print_warning "Failed services check completed with warnings"
        echo ""
        print_info "Log saved to: $(get_log_file)"
        print_info "Edit ignore list: ~/.config/maintenance-tasks/ignored-services.conf"
        echo ""
        exit 0  # Don't fail the task - just informational
    fi
}

main "$@"
