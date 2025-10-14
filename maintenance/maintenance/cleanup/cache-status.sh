#!/usr/bin/bash


set -Eeuo pipefail
trap 'print_error "Unexpected error occurred at line $LINENO"; exit 1' ERR

# Check if atime tracking is enabled
check_atime_tracking() {
    print_info "Checking filesystem atime tracking..."

    # Get mount options for home directory
    local mount_point
    mount_point=$(df "$HOME" | tail -1 | awk '{print $1}')

    local mount_options
    mount_options=$(findmnt -n -o OPTIONS "$mount_point" 2>/dev/null || echo "")

    if [[ "$mount_options" =~ noatime|relatime ]]; then
        print_warning "Filesystem has reduced atime tracking ($mount_options)"
        print_warning "Will use modification time (mtime) as fallback for age detection"
        return 1
    else
        print_success "Full atime tracking is enabled"
        return 0
    fi
}

# Calculate days since last access
get_days_since_access() {
    local dir="$1"
    local use_atime="$2"

    if [[ "$use_atime" == "true" ]]; then
        # Find newest atime in directory
        local newest_atime
        newest_atime=$(find "$dir" -type f -printf '%A@\n' 2>/dev/null | sort -n | tail -1)

        if [[ -z "$newest_atime" ]]; then
            echo "0"
            return
        fi

        local current_time
        current_time=$(date +%s)
        local days=$(( (current_time - ${newest_atime%.*}) / 86400 ))
        echo "$days"
    else
        # Fallback to mtime
        local newest_mtime
        newest_mtime=$(find "$dir" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1)

        if [[ -z "$newest_mtime" ]]; then
            echo "0"
            return
        fi

        local current_time
        current_time=$(date +%s)
        local days=$(( (current_time - ${newest_mtime%.*}) / 86400 ))
        echo "$days"
    fi
}
