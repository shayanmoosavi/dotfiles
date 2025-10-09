#!/bin/bash


set -euo pipefail

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Initialize logging with monthly log file
CURRENT_MONTH=$(date +'%Y-%m')
init_logging "updates/${CURRENT_MONTH}.log"

# Check if running with appropriate privileges
check_privileges() {
    if [[ $EUID -eq 0 ]]; then
        print_error "Do not run this script as root. It will request sudo when needed."
        exit 1
    fi
}

# Check required commands
check_dependencies() {
    local missing_deps=()

    for cmd in paru pacman informant snap-pac; do
        if ! command -v "$cmd" &> /dev/null && ! pacman -Q "$cmd" &> /dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing required packages: ${missing_deps[*]}"
        print_status "Install them with: paru -S ${missing_deps[*]}"
        exit 1
    fi
}

# Verify snapper hooks are active
verify_snapper_hooks() {
    print_status "Verifying snapper hooks..."

    if ! pacman -Q snap-pac &> /dev/null; then
        print_warning "snap-pac is not installed. Automatic snapshots will not be created!"
        read -rp "Continue without automatic snapshots? (y/N): " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log "WARN" "Update cancelled: snap-pac not installed"
            exit 0
        fi
    else
        # Check if the pacman hook exists
        if [[ -f /usr/share/libalpm/hooks/05-snap-pac-pre.hook && -f /usr/share/libalpm/hooks/zz-snap-pac-post.hook ]]; then
            print_success "snap-pac hooks are active"
        else
            print_warning "snap-pac hooks may not be properly configured"
        fi
    fi
}

# Check Arch news using informant
check_arch_news() {
    print_status "Checking for Arch Linux news..."

    # Run informant check and capture output
    if ! sudo informant check &> /dev/null; then
        print_warning "There is unread Arch news!"
        echo ""
        sudo informant check 2>&1 || true
        echo ""
        read -rp "Have you read and understood the news? Mark as read and continue? (y/N): " response

        if [[ "$response" =~ ^[Yy]$ ]]; then
            sudo informant read
            print_success "News marked as read"
        else
            log "INFO" "Update cancelled: Unread Arch news"
            print_status "Run 'sudo informant read' after reviewing the news, then run this script again"
            exit 0
        fi
    else
        print_success "No unread Arch news"
    fi
}

# Perform system update
perform_update() {
    print_status "Starting system update..."
    log "INFO" "Starting system update"

    # Count packages before update
    local before_count
    before_count=$(pacman -Q | wc -l)

    # Run paru update
    # The 'set +e' temporarily disables exit-on-error so we can handle failures
    set +e
    paru -Syu --noconfirm 2>&1 | tee -a "$LOG_FILE"
    local update_status=${PIPESTATUS[0]}
    set -e

    if [[ $update_status -eq 0 ]]; then
        local after_count
        after_count=$(pacman -Q | wc -l)
        local updated_count=$((after_count - before_count))

        print_success "System update completed successfully"
        log "SUCCESS" "Update completed. Packages: $after_count (changed: $updated_count)"
        return 0
    else
        print_error "System update failed with exit code $update_status"
        log "ERROR" "Update failed with exit code $update_status"
        return 1
    fi
}
