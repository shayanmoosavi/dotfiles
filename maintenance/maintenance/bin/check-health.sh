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
ACTUAL_SCRIPT="$SCRIPT_DIR/../system/health-check.sh"

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

# Parse mode argument
MODE="${1:-quick}"

# Validate mode
if [[ ! "$MODE" =~ ^(quick|standard|full)$ ]]; then
    print_error "Invalid mode: $MODE"
    echo "Usage: $(basename "$0") [quick|standard|full]"
    echo ""
    echo "Modes:"
    echo "  quick    - Fast essential checks (default)"
    echo "  standard - More thorough checks"
    echo "  full     - Comprehensive analysis"
    exit 1
fi

# Main function
main() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                Arch Linux System Health Check                ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""

    # Execute the health check
    if run_health_check $MODE; then
        echo ""
        print_success "Health check completed!"
        echo ""
        print_info "Log saved to: $(get_log_file)"
        echo ""
        exit 0
    else
        local exit_code=$?
        echo ""
        print_error "Health check failed!"
        echo ""
        print_info "Log saved to: $(get_log_file)"
        echo ""
        exit $exit_code
    fi
}

main "$@"
