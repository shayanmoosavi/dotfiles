#!/bin/bash


set -euo pipefail

# Source utilities
source "$HOME/maintenance/utils.sh"

# Initialize logging with monthly log file
CURRENT_MONTH=$(date +'%Y-%m')
init_logging "cleanup/${CURRENT_MONTH}.log"

# Clean systemd journal logs
clean_journal() {
    print_status "Cleaning systemd journal logs..."
    log "INFO" "Starting journal cleanup"

    # Check current journal size
    local journal_size
    journal_size=$(journalctl --disk-usage 2>/dev/null | grep -oP '\d+\.\d+[A-Z]' | head -1)

    log "INFO" "Current journal size: $journal_size"

    # Vacuum to 2 weeks
    sudo journalctl --vacuum-time=2weeks

    # Check new size
    local new_size
    new_size=$(journalctl --disk-usage 2>/dev/null | grep -oP '\d+\.\d+[A-Z]' | head -1)

    print_success "Journal cleaned (was: $journal_size, now: $new_size)"
    log "SUCCESS" "Journal cleaned from $journal_size to $new_size"
}

# Remove orphaned packages
remove_orphans() {
    print_status "Checking for orphaned packages..."
    log "INFO" "Starting orphan package check"

    local orphans
    orphans=$(pacman -Qtdq 2>/dev/null || true)

    if [[ -z "$orphans" ]]; then
        print_success "No orphaned packages found"
        log "INFO" "No orphaned packages"
        return 0
    fi

    local orphan_count
    orphan_count=$(echo "$orphans" | wc -l)

    print_status "Found $orphan_count orphaned packages"
    log "INFO" "Found $orphan_count orphaned packages: $(echo $orphans | tr '\n' ' ')"

    echo "$orphans" | sudo pacman -Rns - --noconfirm

    print_success "Removed $orphan_count orphaned packages"
    log "SUCCESS" "Removed $orphan_count orphaned packages"
}

# Main execution
main() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║       System Cleanup Maintenance       ║"
    echo "╚════════════════════════════════════════╝"
    echo ""

    log "INFO" "========== Cleanup script started =========="

    clean_journal
    echo ""

    remove_orphans
    echo ""

    print_success "Cleanup completed successfully!"
    log "INFO" "========== Cleanup script completed successfully =========="

    echo ""
    print_status "Log saved to: $(get_log_file)"
    echo ""
}

main "$@"
