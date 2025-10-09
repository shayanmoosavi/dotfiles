#!/bin/bash


set -euo pipefail

# Sourcing the update and post-update scripts
source $HOME/maintenance/updates/update-packages.sh
source $HOME/maintenance/updates/post-update-hooks.sh

# Main execution
main() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║        Arch Linux System Update        ║"
    echo "╚════════════════════════════════════════╝"
    echo ""

    log "INFO" "========== Update script started =========="

    # Pre-flight checks
    check_privileges
    check_dependencies
    verify_snapper_hooks
    check_arch_news

    echo ""

    # Perform update
    if perform_update; then
        echo ""

        # Clean caches only if update succeeded
        clean_pacman_cache
        clean_paru_cache

        echo ""
        print_success "All tasks completed successfully!"
        log "INFO" "========== Update script completed successfully =========="
    else
        echo ""
        print_warning "Update failed. Skipping cache cleaning for troubleshooting."
        print_status "Check the log at: $(get_log_file)"
        log "INFO" "========== Update script completed with errors =========="
        exit 1
    fi

    echo ""
    print_status "Log saved to: $(get_log_file)"
    echo ""
}

# Run main function
main "$@"
