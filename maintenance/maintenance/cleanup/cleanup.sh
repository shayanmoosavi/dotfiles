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

# Remove orphaned packages
remove_orphans() {
    print_info "Checking for orphaned packages..."

    local orphans
    orphans=$(pacman -Qtdq 2>/dev/null || true)

    if [[ -z "$orphans" ]]; then
        print_success "No orphaned packages found"
        return 0
    fi

    local orphan_count
    orphan_count=$(echo "$orphans" | wc -l)

    print_info "Found $orphan_count orphaned packages: $(echo $orphans | tr '\n' ' ')"

    echo "$orphans" | sudo pacman -Rns - --noconfirm

    print_success "Removed $orphan_count orphaned packages"
}

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
