#!/bin/bash

set -Eeuo pipefail
trap 'print_error "Unexpected error occurred at line $LINENO"; exit 1' ERR

# Source utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/../utils.sh"

# Initialize logging with bi-weekly log file
CURRENT_DATE=$(date +'%Y-%m-%d')
init_logging "system/${CURRENT_DATE}.log"

# Define the actual script to execute
ACTUAL_SCRIPT="$SCRIPT_DIR/../system/pacnew.sh"

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
    check_privileges

    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              Pacnew/Pacsave Configuration Review              ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""

    # Execute the review
    if review_pacnew_files; then
        echo ""
        print_success "Pacnew review completed!"
        echo ""
        print_info "Log saved to: $(get_log_file)"
        echo ""
        exit 0
    else
        local exit_code=$?
        echo ""
        print_warning "Pacnew review exited"
        echo ""
        print_info "Log saved to: $(get_log_file)"
        echo ""
        exit $exit_code
    fi
}

main "$@"
