#!/bin/bash


set -Eeuo pipefail
trap 'print_error "Unexpected error occurred at line $LINENO"; exit 1' ERR

BTRFS_FILESYSTEMS=("/" "/home")

# Get all mounted Btrfs filesystems
get_btrfs_filesystems() {
    # Verify each filesystem exists and is Btrfs
    for fs in "${BTRFS_FILESYSTEMS[@]}"; do
        if mountpoint -q "$fs" 2>/dev/null; then
            local fstype
            fstype=$(findmnt -n -o FSTYPE "$fs" 2>/dev/null)
            if [[ "$fstype" == "btrfs" ]]; then
                echo "$fs"
            fi
        fi
    done
}

# Check if a scrub is currently running on a filesystem
is_scrub_running() {
    local mountpoint="$1"

    local status_output
    status_output=$(sudo btrfs scrub status "$mountpoint" 2>/dev/null)

    if echo "$status_output" | grep -q "Status:.*running"; then
        return 0  # Running
    else
        return 1  # Not running
    fi
}

# Get scrub status for a filesystem
get_scrub_status() {
    local mountpoint="$1"

    sudo btrfs scrub status "$mountpoint" 2>/dev/null
}

# Parse scrub status to extract error count
get_scrub_errors() {
    local mountpoint="$1"

    local status_output
    status_output=$(get_scrub_status "$mountpoint")

    # Look for error lines in status
    local errors=0

    # Check for uncorrectable errors
    local uncorrectable
    uncorrectable=$(echo "$status_output" | grep -oP "uncorrectable_errors: \K\d+" || echo "0")

    # Check for corrected errors
    local corrected
    corrected=$(echo "$status_output" | grep -oP "corrected_errors: \K\d+" || echo "0")

    errors=$((uncorrectable + corrected))

    echo "$errors"
}

# Check if last scrub had errors
check_last_scrub_errors() {
    local mountpoint="$1"

    local status_output
    status_output=$(get_scrub_status "$mountpoint")

    if [[ -z "$status_output" ]]; then
        return 2  # No previous scrub data
    fi

    local errors
    errors=$(get_scrub_errors "$mountpoint")

    if [[ $errors -gt 0 ]]; then
        return 0  # Has errors
    else
        return 1  # No errors
    fi
}

# Get last scrub completion time
get_last_scrub_time() {
    local mountpoint="$1"

    local status_output
    status_output=$(get_scrub_status "$mountpoint")

    # Check if no scrub has ever run
    if echo "$status_output" | grep -q "no scrub"; then
        echo "Never"
        return
    fi

    # Extract the "Scrub started:" line
    local scrub_date
    scrub_date=$(echo "$status_output" | grep "Scrub started:" | sed 's/Scrub started:[[:space:]]*//')

    if [[ -n "$scrub_date" ]]; then
        echo "$scrub_date"
    else
        echo "Never"
    fi
}

# Start scrub on a filesystem (background)
start_scrub() {
    local mountpoint="$1"

    print_info "Starting scrub on: $mountpoint"

    # Check if already running
    if is_scrub_running "$mountpoint"; then
        print_warning "Scrub already running on $mountpoint"
        return 1
    fi

    if sudo btrfs scrub start "$mountpoint" 2>&1 | tee -a "$(get_log_file)"; then
        print_success "Scrub finished on $mountpoint"
        return 0
    else
        print_error "Failed to start scrub on $mountpoint"
        return 1
    fi
}

# Send urgent notification for filesystem errors
send_error_notification() {
    local mountpoint="$1"
    local error_count="$2"

    if command -v notify-send &> /dev/null; then
        notify-send \
            --urgency=critical \
            --app-name="Btrfs Scrub" \
            --icon=dialog-error \
            "Btrfs Errors Detected!" \
            "Filesystem $mountpoint has $error_count error(s). Check logs immediately!"
    fi
}

# Check and report errors from previous scrubs
check_previous_scrub_results() {
    local filesystems
    filesystems=$(get_btrfs_filesystems)

    if [[ -z "$filesystems" ]]; then
        print_warning "No Btrfs filesystems detected"
        return 0
    fi

    print_info "Checking previous scrub results..."

    local found_errors=false
    local total_errors=0

    while IFS= read -r mountpoint; do
        local errors
        errors=$(get_scrub_errors "$mountpoint")

        if [[ $errors -gt 0 ]]; then
            found_errors=true
            total_errors=$((total_errors + errors))

            print_error "Filesystem $mountpoint: $errors error(s) found!"

            # Get detailed status
            local status
            status=$(get_scrub_status "$mountpoint")
            print_error "Scrub status for $mountpoint: $status"

            # Send urgent notification
            send_error_notification "$mountpoint" "$errors"
        else
            local last_scrub
            last_scrub=$(get_last_scrub_time "$mountpoint")

            if [[ "$last_scrub" != "Never" ]]; then
                print_success "Filesystem $mountpoint: No errors (last scrub: $last_scrub)"
                print_info "Filesystem $mountpoint: clean, last scrub: $last_scrub"
            else
                print_info "Filesystem $mountpoint: No previous scrub data"
            fi
        fi
    done <<< "$filesystems"

    if [[ "$found_errors" == true ]]; then
        echo ""
        print_error "CRITICAL: Total of $total_errors error(s) found across all filesystems!"
        print_info "Run 'sudo btrfs scrub status <mountpoint>' for details"
        print_info "Consider checking disk health and backing up data"
        return 1
    else
        print_success "All filesystems clean - no errors found"
        print_info "All filesystems passed scrub checks"
        return 0
    fi
}
