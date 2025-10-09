#!/bin/bash


set -euo pipefail

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Keep current package version and the previous one
PACMAN_KEEP_VERSIONS=2

# Initialize logging with monthly log file
CURRENT_MONTH=$(date +'%Y-%m')
init_logging "updates/${CURRENT_MONTH}.log"

# Clean pacman cache
clean_pacman_cache() {
    print_status "Cleaning pacman cache (keeping $PACMAN_KEEP_VERSIONS versions)..."

    # paccache is part of pacman-contrib
    if ! command -v paccache &> /dev/null; then
        print_error "paccache not found. Install pacman-contrib package."
        log "ERROR" "paccache not available for cache cleaning"
        return 1
    fi

    # Keep specified number of versions
    sudo paccache -rk "$PACMAN_KEEP_VERSIONS"

    # Remove uninstalled packages cache
    sudo paccache -ruk0

    print_success "Pacman cache cleaned"
    log "INFO" "Pacman cache cleaned (kept $PACMAN_KEEP_VERSIONS versions)"
}

# Clean paru cache (orphaned AUR package clones)
clean_paru_cache() {
    print_status "Cleaning paru cache (orphaned AUR clones)..."

    local paru_cache_dir="$HOME/.cache/paru/clone"

    if [[ ! -d "$paru_cache_dir" ]]; then
        print_warning "Paru cache directory not found, skipping"
        return 0
    fi

    # Get list of installed AUR packages
    local installed_aur
    installed_aur=$(pacman -Qmq)

    local removed_count=0
    local total_size=0

    # Iterate through cached clones
    for clone_dir in "$paru_cache_dir"/*; do
        if [[ ! -d "$clone_dir" ]]; then
            continue
        fi

        local pkg_name
        pkg_name=$(basename "$clone_dir")

        # Check if package is still installed
        if ! echo "$installed_aur" | grep -q "^${pkg_name}$"; then
            # Calculate size before removal
            local size
            size=$(du -sb "$clone_dir" 2>/dev/null | awk '{print $1}')
            total_size=$((total_size + size))

            rm -rf "$clone_dir"
            ((removed_count++))
        fi
    done

    # Convert bytes to human readable
    local size_mb=$((total_size / 1024 / 1024))

    if [[ $removed_count -gt 0 ]]; then
        print_success "Removed $removed_count orphaned AUR clones (freed ${size_mb}MB)"
        log "INFO" "Paru cache cleaned: $removed_count clones removed, ${size_mb}MB freed"
    else
        print_success "No orphaned AUR clones found"
        log "INFO" "Paru cache: no orphaned clones"
    fi
}
