#!/bin/bash


# Get count of packages needing updates
get_update_count() {
    checkupdates 2>/dev/null | wc -l || echo "0"
}

# Get last system update date
get_last_update_date() {
    if [[ -f /var/log/pacman.log ]]; then
        local last_update
        last_update=$(tac /var/log/pacman.log | grep -m1 "starting full system upgrade" | awk '{print $1}')

        if [[ -n "$last_update" ]]; then
            # Parse date and calculate days ago
            local update_timestamp
            update_timestamp=$(echo "$last_update" | date -d - +%s 2>/dev/null)

            if [[ -n "$update_timestamp" ]]; then
                local days_ago=$(( ($(date +%s) - update_timestamp) / 86400 ))
                echo "${days_ago}d ago"
            else
                echo "Unknown"
            fi
        else
            echo "Unknown"
        fi
    else
        echo "Unknown"
    fi
}

# Listing the orphaned packages
list_orphans() {
    pacman -Qtdq || true
}

# Get .pacnew/.pacsave count
get_pacnew_count() {
    sudo find /etc -name "*.pacnew" -o -name "*.pacsave" 2>/dev/null | wc -l
}

# Checking whether the pacman database is intact
check_pacman_database_integrity() {
    if pacman -Dk; then
        return 0 # Success
    else
        return 1 # Failure
    fi
}

# Checking whether installed packages have missing or changed files
check_package_file_integrity() {
    if sudo pacman -Qkq >/dev/null 2>&1; then
        return 0 # Success
    else
        return 1 # Failure
    fi
}
