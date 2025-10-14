#!/bin/bash

# Wrapper: Orphan Removal Task
# Sources and Executes: cleanup/cleanup-journal.sh
# Purpose: Single entry point for maintenance task system

set -Eeuo pipefail
trap 'print_error "Unexpected error occurred at line $LINENO"; exit 1' ERR

# Source utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/../utils.sh"

# Initialize logging with bi-weekly log file
CURRENT_DATE=$(date +'%Y-%m-%d')
init_logging "cleanup/${CURRENT_DATE}.log"

# Define the actual script to execute
ACTUAL_SCRIPT="$SCRIPT_DIR/../cleanup/remove-orphans.sh"

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
    echo "╔═════════════════════════════════════════╗"
    echo "║        Orphaned Packages Removal        ║"
    echo "╚═════════════════════════════════════════╝"
    echo ""

    print_info "========== Purging orphans started =========="

    # Pre-flight checks
    print_info "Pre-flight checks:"
    check_privileges

    # Execute the actual script
    remove_orphans

    echo ""
    print_success "========== Orphans purged successfully =========="
    echo ""
}

main "$@"
