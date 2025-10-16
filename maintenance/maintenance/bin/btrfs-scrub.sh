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
ACTUAL_SCRIPT="$SCRIPT_DIR/../btrfs/scrub.sh"

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
    echo "║          Btrfs Scrub Utility           ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    print_info "========== Btrfs scrub started =========="

    # First, check results of any previous scrubs
    local previous_errors=false
    if ! check_previous_scrub_results; then
        previous_errors=true
    fi

    echo ""

    # Get all Btrfs filesystems
    local filesystems
    filesystems=$(get_btrfs_filesystems)

    if [[ -z "$filesystems" ]]; then
        print_error "No Btrfs filesystems found"
        return 1
    fi

    print_info "Found Btrfs filesystems:"
    while IFS= read -r mountpoint; do
        echo "  - $mountpoint"
    done <<< "$filesystems"

    echo ""

    # Start scrubs on each filesystem
    local started_count=0
    local failed_count=0

    while IFS= read -r mountpoint; do
        if start_scrub "$mountpoint"; then
            ((started_count+=1))
        else
            ((failed_count+=1))
        fi

        # Small delay between starting scrubs
        sleep 1
    done <<< "$filesystems"

    echo ""

    # Summary
    if [[ $failed_count -eq 0 ]]; then
        print_success "Finished scrub(s) on $started_count filesystem(s)"
    else
        print_warning "Finished $started_count scrub(s), failed $failed_count"
    fi

    echo ""

    # Return error if previous scrubs found errors (even if new scrubs started successfully)
    if [[ "$previous_errors" == true ]]; then
        echo ""
        print_info "Log saved to: $(get_log_file)"
        echo ""
        print_error "========== Btrfs scrub failed with errors =========="
        return 1
    else
        echo ""
        print_info "Log saved to: $(get_log_file)"
        echo ""
        print_success "========== Btrfs scrub completed =========="
        return 0
    fi
}

main "$@"
