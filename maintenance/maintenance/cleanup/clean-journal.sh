#!/bin/bash


set -Eeuo pipefail
trap 'print_error "Unexpected error occurred at line $LINENO"; exit 1' ERR

# Source utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/../utils.sh"

# Initialize logging with monthly log file
CURRENT_MONTH=$(date +'%Y-%m')
init_logging "cleanup/${CURRENT_MONTH}.log"

# Clean systemd journal logs
clean_journal() {
    print_info "Cleaning systemd journal logs..."

    # Check current journal size
    local journal_size
    journal_size=$(journalctl --disk-usage 2>/dev/null | grep -oP '\d+\.\d+[A-Z]' | head -1)

    print_info "Current journal size: $journal_size"

    # Vacuum to 2 weeks
    sudo journalctl --vacuum-time=2weeks

    # Check new size
    local new_size
    new_size=$(journalctl --disk-usage 2>/dev/null | grep -oP '\d+\.\d+[A-Z]' | head -1)

    print_success "Journal cleaned (was: $journal_size, now: $new_size)"
}
