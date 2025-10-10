#!/bin/bash


set -Eeuo pipefail
trap 'print_error "Unexpected error occurred at line $LINENO"; exit 1' ERR

# Sourcing the functions
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source $SCRIPT_DIR/update-packages.sh
source $SCRIPT_DIR/post-update-hooks.sh
source $SCRIPT_DIR/update-mirrorlist.sh

# Main execution
main() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║        Arch Linux System Update        ║"
    echo "╚════════════════════════════════════════╝"
    echo ""

    print_info "========== Update script started =========="

    # Pre-flight checks
    check_privileges
    check_dependencies
    verify_snapper_hooks
    check_arch_news

    echo ""

    print_info "------ Mirrorlist update started ------"

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
        print_error "------ Mirrorlist update failed, restored from backup ------"
        exit 1
    fi

    echo ""

    # Clean old backups
    clean_old_backups

    echo ""
    print_success "------ Mirrorlist update completed successfully ------"
    echo ""

    # Perform update
    if perform_update; then
        echo ""

        # Clean caches only if update succeeded
        clean_pacman_cache
        clean_paru_cache

        echo ""
        print_info "========== Update script completed successfully =========="
    else
        echo ""
        print_error "Update failed. Skipping cache cleaning for troubleshooting."
        print_info "Check the log at: $(get_log_file)"
        print_error "========== Update script failed with errors =========="
        exit 1
    fi

    echo ""
    print_info "Log saved to: $(get_log_file)"
    echo ""
}

# Run main function
main "$@"
