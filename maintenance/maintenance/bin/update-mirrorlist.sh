#!/bin/bash

# Wrapper: Update Mirrorlist Task
# Sources and Executes: updates/mirrorlist.sh
# Purpose: Single entry point for maintenance task system

set -Eeuo pipefail
trap 'print_error "Unexpected error occurred at line $LINENO"; exit 1' ERR

# Source utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/../utils.sh"

# Initialize logging with bi-weekly log file
CURRENT_DATE=$(date +'%Y-%m-%d')
init_logging "updates/${CURRENT_DATE}.log"

# Define the actual script to execute
ACTUAL_SCRIPT="$SCRIPT_DIR/../updates/mirrorlist.sh"

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
    echo "╔════════════════════════════════════════╗"
    echo "║        Pacman Mirrorlist Update        ║"
    echo "╚════════════════════════════════════════╝"
    echo ""

    print_info "========== Mirrorlist update started =========="

    # Pre-flight checks
    print_info "Pre-flight checks:"
    check_privileges
    check_dependencies

    # Backup current mirrorlist
    if ! backup_mirrorlist; then
        print_error "Cannot proceed without backup"
        print_error "Update aborted: backup failed"
        exit 1
    fi

    echo ""

    # Update mirrorlist
    if ! update_mirrorlist; then
        print_error "Failed to update mirrorlist"
        restore_mirrorlist
        print_error "========== Mirrorlist update failed, restored from backup =========="
        exit 1
    fi

    echo ""

    # Clean old backups
    clean_old_backups

    echo ""
    print_success "========== Mirrorlist update completed successfully =========="
    echo ""
}

main "$@"
