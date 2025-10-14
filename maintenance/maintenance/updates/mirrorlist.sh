#!/bin/bash

set -Eeuo pipefail
trap 'print_error "Unexpected error occurred at line $LINENO"; exit 1' ERR

# Configuration
MIRRORLIST="/etc/pacman.d/mirrorlist"
BACKUP_DIR="/etc/pacman.d/mirrorlist.backup"
COUNTRIES=("Germany" "France" "Sweden")
MIRROR_COUNT=10
SORT_BY="score"  # Options: rate, age, country, score, delay

# Create backup of current mirrorlist
backup_mirrorlist() {
    print_info "Backing up current mirrorlist..."

    # Create backup directory if it doesn't exist
    if ! sudo mkdir -p "$BACKUP_DIR" 2>/dev/null; then
        print_error "Failed to create backup directory: $BACKUP_DIR"
        return 1
    fi

    # Create timestamped backup
    local timestamp
    timestamp=$(date +'%Y-%m-%d_%H-%M-%S')
    local backup_file="$BACKUP_DIR/mirrorlist.${timestamp}"

    if ! sudo cp "$MIRRORLIST" "$backup_file" 2>/dev/null; then
        print_error "Failed to backup mirrorlist to $backup_file"
        return 1
    fi

    print_success "Mirrorlist backed up to: $backup_file"

    # Store backup path for potential restoration
    BACKUP_FILE="$backup_file"

    return 0
}

# Restore mirrorlist from backup
restore_mirrorlist() {
    print_warning "Restoring mirrorlist from backup..."

    if [[ -z "${BACKUP_FILE:-}" ]]; then
        print_error "Restoration failed: no backup file is available"
        return 1
    fi

    if ! sudo cp "$BACKUP_FILE" "$MIRRORLIST" 2>/dev/null; then
        print_error "Failed to restore mirrorlist from $BACKUP_FILE"
        return 1
    fi

    print_success "Mirrorlist restored from $BACKUP_FILE"

    return 0
}

# Update mirrorlist using reflector
update_mirrorlist() {
    print_info "Updating mirrorlist using reflector..."

    # Join countries array into comma-separated string
    local countries_str
    countries_str=$(IFS=,; echo "${COUNTRIES[*]}")

    print_info "Fetching mirrors from countries: $countries_str"
    print_info "Configuration: latest $MIRROR_COUNT mirrors, sorted by $SORT_BY"

    # Run reflector with error handling
    # We use a temporary file to avoid corrupting mirrorlist if reflector fails mid-write
    local temp_mirrorlist
    temp_mirrorlist="$HOME/mirrorlist.tmp"

    set +e
    sudo reflector \
        --country "$countries_str" \
        --latest "$MIRROR_COUNT" \
        --protocol https \
        --sort "$SORT_BY" \
        --save "$temp_mirrorlist" 2>&1 | tee -a "$(get_log_file)"
    local reflector_status=$?
    set -e

    if [[ $reflector_status -ne 0 ]]; then
        print_error "Reflector failed with exit code $reflector_status"
        rm -f "$temp_mirrorlist"
        return 1
    fi

    # Verify the temporary mirrorlist is not empty
    if [[ ! -s "$temp_mirrorlist" ]]; then
        print_error "Generated mirrorlist is empty"
        rm -f "$temp_mirrorlist"
        return 1
    fi

    # Count mirrors in new mirrorlist
    local mirror_count
    mirror_count=$(grep -c "^Server = " "$temp_mirrorlist" || true)

    if [[ $mirror_count -eq 0 ]]; then
        print_error "No valid mirrors in generated mirrorlist"
        rm -f "$temp_mirrorlist"
        return 1
    fi

    # Move temporary mirrorlist to actual location
    if ! sudo mv "$temp_mirrorlist" "$MIRRORLIST" 2>/dev/null; then
        print_error "Failed to move temporary mirrorlist to $MIRRORLIST"
        rm -f "$temp_mirrorlist"
        return 1
    fi

    print_success "Mirrorlist updated successfully with $mirror_count mirrors"

    return 0
}

# Verify the new mirrorlist works
verify_mirrorlist() {
    print_info "Verifying new mirrorlist..."

    # Use checkupdates to verify mirrors work without touching system database
    # checkupdates uses a temporary copy of the sync database
    set +e
    checkupdates &> /dev/null
    local check_status=$?
    set -e

    # checkupdates returns:
    # 0 = updates available (mirrors work!)
    # 2 = no updates available (mirrors work!)
    # other = error (mirrors might not work)

    if [[ $check_status -eq 0 ]] || [[ $check_status -eq 2 ]]; then
        print_success "Mirrorlist verified successfully"
        return 0
    else
        print_error "Mirrorlist verification failed (exit code: $check_status)"
        return 1
    fi
}

# Clean old backups (keep last 5)
clean_old_backups() {
    print_info "Cleaning old mirrorlist backups..."

    if [[ ! -d "$BACKUP_DIR" ]]; then
        return 0
    fi

    # Count backups
    local backup_count
    backup_count=$(ls -1 "$BACKUP_DIR"/mirrorlist.* 2>/dev/null | wc -l)

    if [[ $backup_count -le 5 ]]; then
        print_info "No old backups to clean ($backup_count backups)"
        print_info "Backup count: $backup_count (keeping all)"
        return 0
    fi

    # Remove oldest backups, keeping only the 5 most recent
    local removed_count=0
    while [[ $(ls -1 "$BACKUP_DIR"/mirrorlist.* 2>/dev/null | wc -l) -gt 5 ]]; do
        local oldest
        oldest=$(ls -1t "$BACKUP_DIR"/mirrorlist.* | tail -1)
        sudo rm "$oldest"
        ((removed_count+=1))
    done

    print_success "Removed $removed_count old backup(s)"
}
