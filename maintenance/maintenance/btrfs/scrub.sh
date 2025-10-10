#!/bin/bash

set -Eeuo pipefail
trap 'print_error "Unexpected error occurred at line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/../utils.sh"

# Initialize logging with monthly log file
CURRENT_MONTH=$(date +'%Y-%m')
init_logging "btrfs/${CURRENT_MONTH}.log"

# Target mount(s) - default to root
TARGETS=("/")

# If BTRFS_MOUNTS env is set, use that (comma-separated)
if [[ -n "${BTRFS_MOUNTS:-}" ]]; then
IFS=',' read -r -a TARGETS <<<"$BTRFS_MOUNTS"
fi

# Main function
main () {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║          Btrfs Scrub Utility           ║"
    echo "╚════════════════════════════════════════╝"
    echo ""

    print_info "========== Btrfs scrub started =========="
    check_privileges

    print_info "Starting btrfs scrub for targets: ${TARGETS[*]}"

    local btrfs_scrub_status=0

    for target in "${TARGETS[@]}"; do
        # check mount exists and is btrfs
        if ! mountpoint -q "$target"; then
            print_warning "Target is not a mountpoint: $target. Skipping."
            continue
        fi

        fs_type=$(findmnt -n -o FSTYPE --target "$target") || fs_type=""

        if [[ "$fs_type" != "btrfs" ]]; then
            print_warning "Target $target is not btrfs (type: $fs_type). Skipping."
            continue
        fi

        print_info "Starting scrub on $target"

        if sudo btrfs scrub start -Bd -- "${target}"; then

            print_success "Scrub completed successfully for $target"

            # Retrieve scrub stats
            if sudo btrfs scrub status -- "${target}" > /tmp/btrfs_scrub_status.txt 2>&1; then
                print_info "btrfs scrub status for $target:"
                print_info "$(< /tmp/btrfs_scrub_status.txt)"
                rm -f /tmp/btrfs_scrub_status.txt
            fi
        else
            print_error "Scrub failed for $target"
            btrfs_scrub_status+=1
        fi
    done

    if [[ $btrfs_scrub_status -ne 0 ]]; then
        print_info "Some targets failed scrub"
        print_error "========== Btrfs scrub finished with errors =========="
        exit 1
    else
        print_success "========== Btrfs scrub finished successfully =========="
    fi

    echo ""
    print_info "Log saved to: $(get_log_file)"
    echo ""
}

main "$@"
