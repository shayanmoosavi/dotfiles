#!/usr/bin/bash


set -Eeuo pipefail
trap 'print_error "Unexpected error occurred at line $LINENO"; exit 1' ERR

# Get disk space summary
get_disk_summary() {
    print_info "Disk Space Summary:"
    echo ""

    # Use df with human-readable sizes
    df -h --output=source,fstype,size,used,avail,pcent,target | grep -v "tmpfs\|devtmpfs\|loop"

    echo ""
}

# Find largest directories in a path
find_largest_directories() {
    local path="$1"
    local count="${2:-10}"

    print_info "Top $count largest directories in $path:"
    echo ""

    # Use du to find large directories, excluding some paths
    sudo du -h "$path" --max-depth=3 --exclude="./proc" --exclude="./sys" --exclude="./dev" \
        2>/dev/null | sort -rh | head -n "$count"

    echo ""
}

# Find largest files in a path
find_largest_files() {
    local path="$1"
    local count="${2:-20}"

    print_info "Top $count largest files in $path:"
    echo ""

    # Find files, sort by size
    sudo find "$path" -type f -not -path "*/proc/*" -not -path "*/sys/*" -not -path "*/dev/*" \
        -printf "%s %p\n" 2>/dev/null | sort -rn | head -n "$count" | while read -r size file; do
        printf "%-10s %s\n" "$(human_readable_size "$size")" "$file"
    done

    echo ""
}

# Find old large files (potential cleanup candidates)
find_old_large_files() {
    local path="$1"
    local size_mb="${2:-500}"  # Files larger than this (in MB)
    local age_days="${3:-90}"   # Files older than this (in days)

    print_info "Large files (>${size_mb}MB) not accessed in $age_days+ days in $path:"
    echo ""

    local found_any=false

    sudo find "$path" -type f -size "+${size_mb}M" -atime "+$age_days" \
        -not -path "*/proc/*" -not -path "*/sys/*" -not -path "*/dev/*" \
        -printf "%s %A@ %p\n" 2>/dev/null | sort -rn | head -n 20 | while read -r size atime file; do

        found_any=true
        local size_human
        size_human=$(human_readable_size "$size")

        local days_ago=$(( ($(date +%s) - ${atime%.*}) / 86400 ))

        printf "%-10s %-8s %s\n" "$size_human" "${days_ago}d" "$file"
    done

    if [[ "$found_any" == false ]]; then
        echo "  None found"
    fi

    echo ""
}

# Analyze common bloat areas
analyze_common_bloat() {
    print_info "Common Bloat Areas:"
    echo ""

    local -a paths=(
        "$HOME/.cache"
        "$HOME/Downloads"
        "$HOME/.local/share/Trash"
        "/var/cache/pacman/pkg"
        "/var/log"
        "/tmp"
    )

    printf "%-40s %s\n" "Location" "Size"
    printf "%s\n" "$(printf '─%.0s' {1..60})"

    for path in "${paths[@]}"; do
        if [[ -d "$path" ]]; then
            local size
            size=$(sudo du -sh "$path" 2>/dev/null | awk '{print $1}')
            printf "%-40s %s\n" "$path" "$size"
        fi
    done

    echo ""
}

# Analyze home directory specifically
analyze_home_directory() {
    print_info "Home Directory Analysis ($HOME):"
    echo ""

    # Get top-level directories in home
    du -h --max-depth=1 "$HOME" 2>/dev/null | sort -rh | head -n 15

    echo ""
}

# Main disk space review function
review_disk_space() {
    print_info "========== Disk space review started =========="

    echo ""

    # Overall disk summary
    get_disk_summary

    # Common bloat areas
    analyze_common_bloat

    # Home directory analysis
    analyze_home_directory

    # Ask if user wants detailed analysis
    echo ""
    read -rp "Run detailed analysis? (finds largest files/dirs - may take a while) (y/N): " detailed

    if [[ "$detailed" =~ ^[Yy]$ ]]; then
        echo ""

        # Largest directories in home
        find_largest_directories "$HOME" 10

        # Largest files in home
        find_largest_files "$HOME" 20

        # Old large files in home
        find_old_large_files "$HOME" 500 90

        # Ask about system-wide analysis
        echo ""
        read -rp "Analyze entire system? (requires sudo, slow) (y/N): " system_wide

        if [[ "$system_wide" =~ ^[Yy]$ ]]; then
            echo ""
            print_info "Analyzing system-wide (this may take several minutes)..."

            # Largest directories system-wide
            find_largest_directories "/" 15

            # Largest files system-wide
            find_largest_files "/" 30
        fi
    fi

    echo ""
    print_info "========== Disk space review completed =========="

    return 0
}
