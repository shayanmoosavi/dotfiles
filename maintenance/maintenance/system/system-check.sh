#!/bin/bash


# Get failed services count
get_failed_services_count() {
    systemctl --failed --no-legend --plain | wc -l
}

# Check Btrfs health
check_btrfs_health() {
    local filesystems=("/" "/home")
    local total_errors=0

    for fs in "${filesystems[@]}"; do
        if mountpoint -q "$fs" 2>/dev/null; then
            local fstype
            fstype=$(findmnt -n -o FSTYPE "$fs" 2>/dev/null)

            if [[ "$fstype" == "btrfs" ]]; then
                # Check for errors in last scrub
                local status
                status=$(sudo btrfs scrub status "$fs" 2>/dev/null)

                if [[ -n "$status" ]]; then
                    local errors
                    errors=$(echo "$status" | grep -oP "(uncorrectable_errors|corrected_errors): \K\d+" | awk '{s+=$1} END {print s}')
                    total_errors=$((total_errors + ${errors:-0}))
                fi
            fi
        fi
    done

    echo "$total_errors"
}

# Get last Btrfs scrub date
get_last_scrub_date() {
    local status
    status=$(sudo btrfs scrub status / 2>/dev/null)

    if echo "$status" | grep -q "no scrub"; then
        echo "Never"
        return
    fi

    local scrub_date
    scrub_date=$(echo "$status" | grep "Scrub started:" | sed 's/Scrub started:[[:space:]]*//')

    if [[ -n "$scrub_date" ]]; then
        local scrub_timestamp
        scrub_timestamp=$(date -d "$scrub_date" +%s 2>/dev/null)

        if [[ -n "$scrub_timestamp" ]]; then
            local days_ago=$(( ($(date +%s) - scrub_timestamp) / 86400 ))
            echo "${days_ago}d ago"
        else
            echo "$scrub_date"
        fi
    else
        echo "Unknown"
    fi
}

# Check critical services
check_critical_services() {
    local -a critical=("dbus" "systemd-logind" "systemd-journald")
    local failed=0

    for service in "${critical[@]}"; do
        if ! systemctl is-active --quiet "$service"; then
            ((failed+=1))
        fi
    done

    echo "$failed"
}

# Get maintenance task last run date
get_task_last_run() {
    local task="$1"
    local state_dir="$HOME/.local/share/maintenance-tasks/last-run"
    local last_run_file="$state_dir/$task"

    if [[ -f "$last_run_file" ]]; then
        local timestamp
        timestamp=$(cat "$last_run_file")

        local days_ago=$(( ($(date +%s) - timestamp) / 86400 ))
        echo "${days_ago}d ago"
    else
        echo "Never"
    fi
}
