#!/bin/bash


set -Eeuo pipefail
trap 'print_error "Unexpected error occurred at line $LINENO"; exit 1' ERR

# Source utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/../utils.sh"

# Initialize logging with monthly log file
CURRENT_MONTH=$(date +'%Y-%m')
init_logging "cleanup/${CURRENT_MONTH}.log"

source "$SCRIPT_DIR/../cleanup/clean-journal.sh"
source "$SCRIPT_DIR/../cleanup/remove-orphans.sh"

# Main execution
main() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║       System Cleanup Maintenance       ║"
    echo "╚════════════════════════════════════════╝"
    echo ""

    print_info "========== Cleanup script started =========="

    clean_journal
    echo ""

    remove_orphans
    echo ""

    print_success "Cleanup completed successfully!"
    print_info "========== Cleanup script completed successfully =========="

    echo ""
    print_info "Log saved to: $(get_log_file)"
    echo ""
}

main "$@"
