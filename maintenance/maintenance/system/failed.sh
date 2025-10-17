#!/bin/bash


set -Eeuo pipefail
trap 'print_error "Unexpected error occurred at line $LINENO"; exit 1' ERR

# Colors for table output
BOLD='\033[1m'

# Default ignore list for services that commonly "fail" harmlessly
get_default_ignore_list() {
    cat << 'EOF'
# Services that commonly show as failed but are generally harmless
# One service name per line, comments allowed

# Network waiting service (fails on systems without network-online.target dependency)
systemd-networkd-wait-online.service

# Sometimes fails on desktop systems
systemd-backlight@backlight:intel_backlight.service

# Add your custom ignores below:

EOF
}

# Load ignore list from config
load_ignore_list() {
    local config_file="$HOME/.config/maintenance-tasks/ignored-services.conf"

    # Create default config if doesn't exist
    if [[ ! -f "$config_file" ]]; then
        mkdir -p "$(dirname "$config_file")"
        get_default_ignore_list > "$config_file"
    fi

    # Read non-comment, non-empty lines
    grep -v '^#' "$config_file" | grep -v '^[[:space:]]*$' || true
}

# Get all failed services (system and user)
get_failed_services() {
    local scope="$1"  # "system", "user", or "all"

    case "$scope" in
        system)
            systemctl --failed --no-legend --plain | awk '{print $1}'
            ;;
        user)
            systemctl --user --failed --no-legend --plain 2>/dev/null | awk '{print $1}' || true
            ;;
        all)
            # System services
            systemctl --failed --no-legend --plain | awk '{print $1}'
            # User services
            systemctl --user --failed --no-legend --plain 2>/dev/null | awk '{print $1}' || true
            ;;
        *)
            echo "Invalid scope: $scope" >&2
            return 1
            ;;
    esac
}

# Filter out ignored services
filter_ignored_services() {
    local -a ignore_list=()

    # Load ignore list into array
    while IFS= read -r service; do
        ignore_list+=("$service")
    done < <(load_ignore_list)

    # Read services from stdin and filter
    while IFS= read -r service; do
        local should_ignore=false

        for ignored in "${ignore_list[@]}"; do
            if [[ "$service" == "$ignored" ]]; then
                should_ignore=true
                break
            fi
        done

        if [[ "$should_ignore" == false ]]; then
            echo "$service"
        fi
    done
}

# Get brief status for a service
get_service_status() {
    local service="$1"

    # Determine if it's a user or system service
    if systemctl --user list-units --all --no-legend 2>/dev/null | grep -q "^$service"; then
        systemctl --user status "$service" --no-pager -l -n 0 2>/dev/null | head -3
    else
        systemctl status "$service" --no-pager -l -n 0 2>/dev/null | head -3
    fi
}

# Get recent journal logs for a service
get_service_logs() {
    local service="$1"
    local lines="${2:-20}"

    # Determine if it's a user or system service
    if systemctl --user list-units --all --no-legend 2>/dev/null | grep -q "^$service"; then
        journalctl --user -u "$service" -n "$lines" --no-pager 2>/dev/null
    else
        sudo journalctl -u "$service" -n "$lines" --no-pager 2>/dev/null
    fi
}

# Display failed services in a table
display_failed_services() {
    local -a services=("$@")

    if [[ ${#services[@]} -eq 0 ]]; then
        print_success "No failed services found!"
        return 0
    fi

    echo ""
    echo -e "${BOLD}Failed Services:${NC}"
    printf "%-50s %s\n" "Service" "Status"
    printf "%s\n" "$(printf '─%.0s' {1..90})"

    for service in "${services[@]}"; do
        # Get one-line status
        local status_line
        status_line=$(systemctl show "$service" -p ActiveState --value 2>/dev/null || echo "unknown")

        # Color code status
        local colored_status
        case "$status_line" in
            failed)
                colored_status="${RED}failed${NC}"
                ;;
            *)
                colored_status="$status_line"
                ;;
        esac

        printf "%-50s %s\n" "$service" "$(echo -e "$colored_status")"
    done

    echo ""
}

# Interactive service review
review_failed_service() {
    local service="$1"

    while true; do
        echo ""
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║  Service: $service                                             ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo ""

        # Show brief status
        get_service_status "$service"

        echo ""
        echo "Options:"
        echo "  [l] View logs"
        echo "  [r] Restart service"
        echo "  [s] Skip (ignore for now)"
        echo "  [i] Add to ignore list"
        echo "  [d] Disable service"
        echo "  [q] Quit review"
        echo ""

        read -rp "Choose an option: " choice

        case "$choice" in
            l|L)
                echo ""
                print_info "Recent logs for $service:"
                echo ""
                get_service_logs "$service" 30
                echo ""
                read -rp "Press Enter to continue..."
                ;;
            r|R)
                echo ""
                print_info "Restarting $service..."

                if systemctl --user list-units --all --no-legend 2>/dev/null | grep -q "^$service"; then
                    systemctl --user restart "$service"
                else
                    sudo systemctl restart "$service"
                fi

                sleep 2

                # Check if it's still failed
                if systemctl is-failed "$service" &>/dev/null; then
                    print_error "Service still failed after restart"
                else
                    print_success "Service restarted successfully"
                    return 0  # Exit review for this service
                fi
                ;;
            s|S)
                print_info "Skipping $service"
                return 0
                ;;
            i|I)
                local config_file="$HOME/.config/maintenance-tasks/ignored-services.conf"
                echo "$service" >> "$config_file"
                print_success "Added $service to ignore list"
                return 0
                ;;
            d|D)
                echo ""
                print_warning "This will permanently disable $service"
                read -rp "Are you sure? (y/N): " confirm

                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    if systemctl --user list-units --all --no-legend 2>/dev/null | grep -q "^$service"; then
                        systemctl --user disable "$service"
                    else
                        sudo systemctl disable "$service"
                    fi
                    print_success "Disabled $service"
                    return 0
                fi
                ;;
            q|Q)
                return 1  # Signal to stop reviewing
                ;;
            *)
                print_error "Invalid option"
                ;;
        esac
    done
}

# Main function to check and report failed services
check_failed_services() {
    print_info "========== Failed services check started =========="

    # Get all failed services
    local -a all_failed=()
    while IFS= read -r service; do
        [[ -n "$service" ]] && all_failed+=("$service")
    done < <(get_failed_services "all")

    print_info "Found ${#all_failed[@]} failed services (before filtering)"

    # Filter ignored services
    local -a filtered_failed=()
    local -a ignored_services=()

    for service in "${all_failed[@]}"; do
        if echo "$service" | filter_ignored_services | grep -q .; then
            filtered_failed+=("$service")
        else
            ignored_services+=("$service")
        fi
    done

    # Log ignored services
    if [[ ${#ignored_services[@]} -gt 0 ]]; then
        print_info "Ignored ${#ignored_services[@]} services: ${ignored_services[*]}"
    fi

    # Display results
    if [[ ${#filtered_failed[@]} -eq 0 ]]; then
        print_success "No failed services found (${#ignored_services[@]} ignored)"
        print_info "========== Failed services check completed =========="
        return 0
    fi

    print_warning "Found ${#filtered_failed[@]} failed services: ${filtered_failed[*]}"

    # Display table
    display_failed_services "${filtered_failed[@]}"

    # Ask if user wants to review interactively
    echo ""
    read -rp "Review failed services interactively? (y/N): " review_choice

    if [[ "$review_choice" =~ ^[Yy]$ ]]; then
        for service in "${filtered_failed[@]}"; do
            if ! review_failed_service "$service"; then
                # User chose to quit review
                break
            fi
        done
    else
        print_status "Run 'systemctl status <service>' to investigate"
        print_status "Run 'journalctl -u <service>' to view logs"
    fi

    print_info "========== Failed services check completed =========="

    # Return error if there are still failed services (for task tracking)
    if [[ ${#filtered_failed[@]} -gt 0 ]]; then
        return 1
    else
        return 0
    fi
}
