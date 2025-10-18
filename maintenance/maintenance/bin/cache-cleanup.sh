#!/usr/bin/bash


set -Eeuo pipefail
trap 'print_error "Unexpected error occurred at line $LINENO"; exit 1' ERR

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

# Initialize logging with monthly log file
CURRENT_MONTH=$(date +'%Y-%m')
init_logging "cleanup/${CURRENT_MONTH}.log"

AGE_THRESHOLD_DAYS=45
DRY_RUN=true  # Default to dry-run mode

source "$SCRIPT_DIR/../cleanup/cache-config.sh"
source "$SCRIPT_DIR/../cleanup/cache-status.sh"

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                DRY_RUN=false
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Show help message
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Clean user cache directory (~/.cache) safely.

OPTIONS:
    --force     Actually delete files (default is dry-run)
    --help, -h  Show this help message

BEHAVIOR:
    - Removes caches from uninstalled packages
    - Removes files not accessed in $AGE_THRESHOLD_DAYS+ days
    - Excludes critical caches (browsers, paru, system caches)
    - Dry-run by default (use --force to actually delete)

EXAMPLES:
    $(basename "$0")           # Dry-run, show what would be deleted
    $(basename "$0") --force   # Actually delete files

CONFIG:
    Mappings: $MAPPINGS_FILE
EOF
}

# Find caches from uninstalled packages
find_uninstalled_package_caches() {
    local -n mappings_ref=$1
    local -n results_ref=$2

    print_info "Scanning for caches from uninstalled packages..."

    local found_count=0

    for package in "${!mappings_ref[@]}"; do
        local cache_dir="${mappings_ref[$package]}"
        local full_path="$CACHE_DIR/$cache_dir"

        # Check if directory exists
        [[ ! -d "$full_path" ]] && continue

        # Check if package is installed
        if ! pacman -Q "$package" &> /dev/null; then
            local size
            size=$(get_dir_size "$full_path")

            results_ref["$full_path"]="UNINSTALLED|$size|$package"
            ((found_count+=1))
        fi
    done

    print_info "Found $found_count caches from uninstalled packages"
}

# Find old cache files (not accessed in AGE_THRESHOLD_DAYS days)
find_old_caches() {
    local -n results_ref=$1
    local use_atime="$2"

    print_info "Scanning for old cache files (>$AGE_THRESHOLD_DAYS days)..."

    # Get excluded directories
    local excluded_dirs=()
    while IFS= read -r dir; do
        excluded_dirs+=("$dir")
    done < <(get_excluded_dirs)

    # Build find exclude expression
    local exclude_expr=""
    for exclude in "${excluded_dirs[@]}"; do
        exclude_expr="$exclude_expr -path $CACHE_DIR/$exclude -prune -o"
    done

    local found_count=0

    # Find all directories in cache (excluding known patterns)
    while IFS= read -r cache_subdir; do
        # Skip if already marked for deletion (uninstalled package)
        [[ -n "${results_ref[$cache_subdir]:-}" ]] && continue

        local days_old
        days_old=$(get_days_since_access "$cache_subdir" "$use_atime")

        if [[ $days_old -ge $AGE_THRESHOLD_DAYS ]]; then
            local size
            size=$(get_dir_size "$cache_subdir")

            results_ref["$cache_subdir"]="OLD|$size|${days_old}d"
            ((found_count+=1))
        fi
    done < <(eval "find '$CACHE_DIR' -mindepth 1 -maxdepth 1 -type d $exclude_expr -print 2>/dev/null")

    print_info "Found $found_count old cache directories"
}

# Find unmapped cache directories (for review)
find_unmapped_caches() {
    local -n mappings_ref=$1
    local -n results_ref=$2
    local -n unmapped_ref=$3

    print_info "Scanning for unmapped cache directories..."

    # Get excluded directories
    local excluded_dirs=()
    while IFS= read -r dir; do
        excluded_dirs+=("$dir")
    done < <(get_excluded_dirs)

    # Get mapped cache directories
    local mapped_caches=()
    for cache_dir in "${mappings_ref[@]}"; do
        mapped_caches+=("$cache_dir")
    done

    local found_count=0

    # Find all directories in cache
    while IFS= read -r cache_subdir; do
        local dir_name
        dir_name=$(basename "$cache_subdir")

        # Skip if excluded
        local is_excluded=false
        for exclude in "${excluded_dirs[@]}"; do
            if [[ "$dir_name" == "$exclude" ]]; then
                is_excluded=true
                break
            fi
        done
        [[ "$is_excluded" == "true" ]] && continue

        # Skip if already in results (will be deleted)
        [[ -n "${results_ref[$cache_subdir]:-}" ]] && continue

        # Skip if in mappings
        local is_mapped=false
        for mapped in "${mapped_caches[@]}"; do
            if [[ "$dir_name" == "$mapped" ]]; then
                is_mapped=true
                break
            fi
        done
        [[ "$is_mapped" == "true" ]] && continue

        # This is an unmapped directory
        local size
        size=$(get_dir_size "$cache_subdir")

        unmapped_ref["$cache_subdir"]="$size"
        ((found_count+=1))
    done < <(find "$CACHE_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)

    if [[ $found_count -gt 0 ]]; then
        print_info "Found $found_count unmapped cache directories for review"
    fi
}

# Display only unmapped directories for when there are no results to clean
display_unmapped_only() {
    local -n unmapped_arr=$1

    echo -e "${BOLD}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║                      Unmapped Caches (For Review)                          ║${NC}"
    echo -e "${BOLD}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${DIM}These cache directories don't match any known package mappings.${NC}"
    echo -e "${DIM}Add mappings to $MAPPINGS_FILE if needed.${NC}"
    echo ""

    printf "%-60s %10s\n" "Cache Directory" "Size"
    printf "%s\n" "$(printf '─%.0s' {1..90})"

    for path in "${!unmapped_arr[@]}"; do
        local dir_name
        dir_name=$(basename "$path")
        local size="${unmapped_arr[$path]}"
        local size_human
        size_human=$(human_readable_size "$size")

        printf "%-60s %10s\n" "$dir_name" "$size_human"
    done
    echo ""
}

# Display results in table format
display_results() {
    local -n results_ref=$1
    local -n unmapped_ref=$2

    local result_count=0
    # Temporarily disable unset variable checking for array length check
    set +u
    result_count=${#results_ref[@]}
    set -u

    if [[ $result_count -eq 0 ]]; then
        print_success "No caches to clean!"
        # Still show unmapped directories if any exist
        local unmapped_count=0
        set +u
        unmapped_count=${#unmapped_ref[@]}
        set -u

        if [[ $unmapped_count -gt 0 ]]; then
            echo ""
            display_unmapped_only unmapped_ref
        fi
        return 0
    fi

    echo ""
    echo -e "${BOLD}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║                          Caches To Be Cleaned                              ║${NC}"
    echo -e "${BOLD}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Group by reason
    local -a uninstalled_items=()
    local -a old_items=()
    local total_size=0

    for path in "${!results_ref[@]}"; do
        IFS='|' read -r reason size extra <<< "${results_ref[$path]}"
        total_size=$((total_size + size))

        if [[ "$reason" == "UNINSTALLED" ]]; then
            uninstalled_items+=("$path|$size|$extra")
        else
            old_items+=("$path|$size|$extra")
        fi
    done

    # Display uninstalled packages section
    if [[ ${#uninstalled_items[@]} -gt 0 ]]; then
        echo -e "${BOLD}Caches from uninstalled packages:${NC}"
        printf "%-60s %10s %s\n" "Cache Directory" "Size" "Package"
        printf "%s\n" "$(printf '─%.0s' {1..90})"

        for item in "${uninstalled_items[@]}"; do
            IFS='|' read -r path size package <<< "$item"
            local dir_name
            dir_name=$(basename "$path")
            local size_human
            size_human=$(human_readable_size "$size")

            printf "%-60s %10s %s\n" "$dir_name" "$size_human" "$package"
        done
        echo ""
    fi

    # Display old files section
    if [[ ${#old_items[@]} -gt 0 ]]; then
        echo -e "${BOLD}Old cache directories (>$AGE_THRESHOLD_DAYS days):${NC}"
        printf "%-60s %10s %s\n" "Cache Directory" "Size" "Age"
        printf "%s\n" "$(printf '─%.0s' {1..90})"

        for item in "${old_items[@]}"; do
            IFS='|' read -r path size age <<< "$item"
            local dir_name
            dir_name=$(basename "$path")
            local size_human
            size_human=$(human_readable_size "$size")

            printf "%-60s %10s %s\n" "$dir_name" "$size_human" "$age"
        done
        echo ""
    fi

    # Display total
    local total_human
    total_human=$(human_readable_size "$total_size")
    echo -e "${BOLD}Total space to be freed: $total_human${NC}"
    echo ""

    # Display unmapped directories if any
    if [[ ${#unmapped_ref[@]} -gt 0 ]]; then
        echo ""
        echo -e "${BOLD}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BOLD}║                      Unmapped Caches (For Review)                          ║${NC}"
        echo -e "${BOLD}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${DIM}These cache directories don't match any known package mappings.${NC}"
        echo -e "${DIM}Add mappings to $MAPPINGS_FILE if needed.${NC}"
        echo ""

        printf "%-60s %10s\n" "Cache Directory" "Size"
        printf "%s\n" "$(printf '─%.0s' {1..90})"

        for path in "${!unmapped_ref[@]}"; do
            local dir_name
            dir_name=$(basename "$path")
            local size="${unmapped_ref[$path]}"
            local size_human
            size_human=$(human_readable_size "$size")

            printf "%-60s %10s\n" "$dir_name" "$size_human"
        done
        echo ""
    fi
}

# Perform deletion
perform_cleanup() {
    local -n results_ref=$1

    local result_count=0
    set +u
    result_count=${#results_ref[@]}
    set -u

    if [[ $result_count -eq 0 ]]; then
        return 0
    fi

    print_info "Deleting cache directories..."

    local deleted_count=0
    local failed_count=0
    local total_freed=0

    for path in "${!results_ref[@]}"; do
        IFS='|' read -r reason size extra <<< "${results_ref[$path]}"

        if rm -rf "$path" 2>/dev/null; then
            ((deleted_count+=1))
            total_freed=$((total_freed + size))
            print_info "Deleted: $path ($(human_readable_size "$size"))"
        else
            ((failed_count+=1))
            print_error "Failed to delete: $path"
        fi
    done

    local freed_human
    freed_human=$(human_readable_size "$total_freed")

    if [[ $failed_count -eq 0 ]]; then
        print_success "Deleted $deleted_count cache directories, freed $freed_human"
        print_success "Cleanup completed: $deleted_count deleted, $freed_human freed"
    else
        print_warning "Deleted $deleted_count, failed $failed_count. Freed $freed_human"
        print_warning "Cleanup completed with errors: $deleted_count deleted, $failed_count failed"
    fi
}

# Main execution
main() {
    parse_args "$@"

    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║  User Cache Cleanup                    ║"
    echo "╚════════════════════════════════════════╝"
    echo ""

    if [[ "$DRY_RUN" == "true" ]]; then
        print_warning "DRY-RUN MODE: No files will be deleted"
        print_info "Use --force to actually delete files"
        echo ""
    fi

    print_info "========== Cache cleanup started (dry-run: $DRY_RUN) =========="

    # Create config if needed
    create_default_config

    echo ""

    # Load mappings
    declare -A package_mappings
    load_mappings package_mappings

    # Check atime tracking
    local use_atime=true
    if ! check_atime_tracking; then
        use_atime=false
    fi

    echo ""

    # Find caches to clean
    declare -A caches_to_clean
    find_uninstalled_package_caches package_mappings caches_to_clean
    find_old_caches caches_to_clean "$use_atime"

    # Find unmapped caches
    declare -A unmapped_caches
    find_unmapped_caches package_mappings caches_to_clean unmapped_caches

    echo ""

    # Display results
    display_results caches_to_clean unmapped_caches

    # Perform cleanup if not dry-run
    if [[ "$DRY_RUN" == "false" ]]; then
        perform_cleanup caches_to_clean
        echo ""
        print_success "Cache cleanup completed!"
        print_info "========== Cache cleanup completed =========="
    else
        print_info "This was a dry-run. Use --force to actually delete files."
        print_info "========== Cache cleanup dry-run completed =========="
    fi

    echo ""
    print_info "Log saved to: $(get_log_file)"
    if [[ ${#unmapped_caches[@]} -gt 0 ]]; then
        print_info "Review unmapped caches and add mappings to: $MAPPINGS_FILE"
    fi
    echo ""
}

main "$@"
