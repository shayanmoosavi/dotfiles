#!/bin/bash

set -Eeuo pipefail
trap 'print_error "Unexpected error occurred at line $LINENO"; exit 1' ERR

# Health status indicators
STATUS_OK="✓"
STATUS_WARN="⚠"
STATUS_ERROR="✗"
STATUS_INFO="ℹ"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Sourcing the helper functions
source $SCRIPT_DIR/hardware-check.sh
source $SCRIPT_DIR/pacman-check.sh
source $SCRIPT_DIR/system-check.sh

# Quick health check
health_check_quick() {
    echo ""
    echo -e "${BOLD}Hardware status:${NC}"

    # Uptime
    local uptime_str
    uptime_str=$(uptime -p)
    echo -e "  ${GREEN}${STATUS_OK} Uptime: $uptime_str${NC}"

    # Load
    local load
    load=$(get_load_averages)
    local cores
    cores=$(get_cpu_cores)

    if is_load_high; then
        echo -e "  ${YELLOW}${STATUS_WARN} Load: $load ($cores cores) - High load${NC}"
    else
        echo -e "  ${GREEN}${STATUS_OK} Load: $load ($cores cores)${NC}"
    fi

    # Memory
    local mem_usage
    mem_usage=$(get_memory_usage)
    local mem_percent
    mem_percent=$(get_memory_percent)

    if [[ $mem_percent -gt 85 ]]; then
        echo -e "  ${YELLOW}${STATUS_WARN} Memory: $mem_usage - High usage${NC}"
    else
        echo -e "  ${GREEN}${STATUS_OK} Memory: $mem_usage${NC}"
    fi

    # Disk
    local disk_usage
    disk_usage=$(get_disk_usage)
    DISK_PERCENT=$(get_disk_percent)

    if [[ $DISK_PERCENT -gt 90 ]]; then
        echo "  ${STATUS_ERROR} Disk: $disk_usage - Critical${NC}"
    elif [[ $DISK_PERCENT -gt 80 ]]; then
        echo -e "  ${YELLOW}${STATUS_WARN} Disk: $disk_usage - Consider cleanup${NC}"
    else
        echo -e "  ${GREEN}${STATUS_OK} Disk: $disk_usage${NC}"
    fi

    echo ""
    echo -e "${BOLD}Packages and updates status:${NC}"

    # Last update
    local last_update
    last_update=$(get_last_update_date)
    echo -e "  ${BLUE}${STATUS_INFO} Last update: $last_update${NC}"

    # Updates available
    UPDATES=$(get_update_count)

    if [[ $UPDATES -gt 0 ]]; then
        echo -e "  ${YELLOW}${STATUS_WARN} Updates available: $UPDATES packages${NC}"
    else
        echo -e "  ${GREEN}${STATUS_OK} System up to date${NC}"
    fi

    # Package file integrity
    if ! check_package_file_integrity; then
        POTENTIAL_PARTIAL_UPGRADE=true
        echo "  ${STATUS_ERROR} Missing/Changed package files detected. (Partial upgrade?)${NC}"
    else
        POTENTIAL_PARTIAL_UPGRADE=false
        echo -e "  ${GREEN}${STATUS_OK} No missing/changed package files.${NC}"
    fi

    # Orphans
    ORPHANS=$(list_orphans)

    if [[ $ORPHANS -gt 0 ]]; then
        echo -e "  ${YELLOW}${STATUS_WARN} Orphaned packages: $ORPHANS${NC}"
    else
        echo -e "  ${GREEN}${STATUS_OK} No orphaned packages${NC}"
    fi

    # .pacnew files
    PACNEW_COUNT=$(get_pacnew_count)

    if [[ $PACNEW_COUNT -gt 0 ]]; then
        echo -e "  ${YELLOW}${STATUS_WARN} .pacnew/.pacsave files: $PACNEW_COUNT need review${NC}"
    else
        echo -e "  ${GREEN}${STATUS_OK} No .pacnew/.pacsave files${NC}"
    fi

    echo ""
    echo -e "${BOLD}Services:${NC}"

    # Failed services
    FAILED_SERVICES=$(get_failed_services_count)

    if [[ $FAILED_SERVICES -gt 0 ]]; then
        echo "  ${STATUS_WARN} Failed services: $FAILED_SERVICES${NC}"
    else
        echo -e "  ${GREEN}${STATUS_OK} No failed services${NC}"
    fi

    # Critical services
    local critical_failed
    critical_failed=$(check_critical_services)

    if [[ $critical_failed -gt 0 ]]; then
        echo "  ${STATUS_ERROR} Critical services down: $critical_failed${NC}."
    else
        echo -e "  ${GREEN}${STATUS_OK} All critical services running${NC}"
    fi

    echo ""
    echo -e "${BOLD}Filesystem:${NC}"

    # Btrfs errors
    BTRFS_ERRORS=$(check_btrfs_health)

    if [[ $BTRFS_ERRORS -gt 0 ]]; then
        echo "  ${STATUS_ERROR} Btrfs: $BTRFS_ERRORS error(s) found${NC}"
    else
        echo -e "  ${GREEN}${STATUS_OK} Btrfs: No errors${NC}"
    fi

    # Last scrub
    local last_scrub
    last_scrub=$(get_last_scrub_date)
    echo -e "  ${BLUE}${STATUS_INFO} Last scrub: $last_scrub${NC}"
}

# Standard health check
health_check_standard() {
    health_check_quick

    echo ""
    echo -e "${BOLD}Thermals:${NC}"

    # CPU temperature
    local cpu_temp
    cpu_temp=$(get_cpu_temp)

    if [[ "$cpu_temp" != "N/A" ]]; then
        local temp_value
        temp_value=$(echo "$cpu_temp" | grep -oP '\d+' | head -1)

        if [[ $temp_value -gt 90 ]]; then
            echo -e "  ${RED}${STATUS_ERROR} CPU Temp: $cpu_temp - Critical${NC}"
        elif [[ $temp_value -gt 80 ]]; then
            echo -e "  ${YELLOW}${STATUS_WARN} CPU Temp: $cpu_temp - High${NC}"
        else
            echo -e "  ${GREEN}${STATUS_OK} CPU Temp: $cpu_temp${NC}"
        fi
    else
        echo -e "  ${BLUE}${STATUS_INFO} CPU Temp: Not available (install lm_sensors)${NC}"
    fi

    echo ""
    echo -e "${BOLD}Maintenance Tasks:${NC}"

    # Task last run dates
    local -a tasks=("cache-cleanup" "journal-cleanup")

    for task in "${tasks[@]}"; do
        local last_run
        last_run=$(get_task_last_run "$task")
        echo -e "  ${BLUE}${STATUS_INFO} ${task}: $last_run${NC}"
    done
}

health_check_full() {
    health_check_standard

    echo ""
    echo -e "${BOLD}Performance:${NC}"

    # Top CPU processes
    echo "  Top 5 CPU processes:"
    ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "    %s (%.1f%%)\n", $11, $3}'

    # Top memory processes
    echo "  Top 5 memory processes:"
    ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "    %s (%.1f%%)\n", $11, $4}'

    echo ""
    echo -e "${BOLD}Logs:${NC}"

    # Recent kernel errors
    local kernel_errors
    kernel_errors=$(dmesg -l err,crit,alert,emerg 2>/dev/null | tail -5 | wc -l)

    if [[ $kernel_errors -gt 0 ]]; then
        echo -e "  ${YELLOW}${STATUS_WARN} Recent kernel errors: $kernel_errors${NC}"
        echo -e "  ${YELLOW}Run 'dmesg -l err' to view${NC}"
    else
        echo -e "  ${BLUE}${STATUS_OK} No recent kernel errors${NC}"
    fi

    # Journal errors
    local journal_errors
    journal_errors=$(journalctl -p err -b 2>/dev/null | wc -l)

    if [[ $journal_errors -gt 10 ]]; then
        echo -e "  ${YELLOW}${STATUS_WARN} Journal errors (this boot): $journal_errors${NC}"
        echo -e "  ${YELLOW}Run 'journalctl -p err -b' to view${NC}"
    else
        echo -e "  ${BLUE}${STATUS_OK} Few journal errors: $journal_errors${NC}"
    fi
}

# Main health check function
run_health_check() {
    local mode="${1:-quick}"  # quick, standard, full

    print_info "========== System health check started (mode: $mode) =========="

    case "$mode" in
        quick)
            health_check_quick
            ;;
        standard)
            health_check_standard
            ;;
        full)
            health_check_full
            ;;
        *)
            print_error "Invalid mode: $mode"
            print_status "Valid modes: quick, standard, full"
            return 1
            ;;
    esac

    # Count warnings and errors
    local warnings=0
    local errors=0

    # Check key indicators
    [[ $DISK_PERCENT -gt 80 ]] && ((warnings+=1))
    [[ $DISK_PERCENT -gt 90 ]] && ((errors+=1))
    [[ $UPDATES -gt 0 ]] && ((warnings+=1))
    [[ $ORPHANS -gt 0 ]] && ((warnings+=1))
    [[ $FAILED_SERVICES -gt 0 ]] && ((warnings+=1))
    [[ $PACNEW_COUNT -gt 0 ]] && ((warnings+=1))
    [[ $BTRFS_ERRORS -gt 0 ]] && ((errors+=1))
    $POTENTIAL_PARTIAL_UPGRADE && ((errors+=1))

    echo ""

    if [[ $errors -gt 0 ]]; then
        echo -e "${BOLD}Overall Status: ${RED}NEEDS ATTENTION${NC} ($errors critical, $warnings warnings)${NC}"
    elif [[ $warnings -gt 0 ]]; then
        echo -e "${BOLD}Overall Status: ${YELLOW}GOOD${NC} ($warnings warnings)${NC}"
    else
        echo -e "${BOLD}Overall Status: ${GREEN}EXCELLENT${NC}${NC}"
    fi

    # Provide suggestions
    if [[ $warnings -gt 0 ]] || [[ $errors -gt 0 ]]; then
        echo ""
        echo -e "${BOLD}Suggestions:${NC}"

        [[ $UPDATES -gt 0 ]] && echo "  - Run system update (maintenance-tasks run system-update)"
        [[ $PACNEW_COUNT -gt 0 ]] && echo "  - Review .pacnew files (maintenance-tasks run pacnew-review)"
        [[ $DISK_PERCENT -gt 80 ]] && echo "  - Free up disk space (maintenance-tasks run disk-space-review)"
        [[ $ORPHANS -gt 0 ]] && echo "  - Remove orphaned packages (maintenance-tasks run orphan-removal)"
        [[ $FAILED_SERVICES -gt 0 ]] && echo "  - Check failed services (maintenance-tasks run failed-services)"
        [[ $BTRFS_ERRORS -gt 0 ]] && echo "  - Check Btrfs errors (sudo btrfs scrub status /)"
        $POTENTIAL_PARTIAL_UPGRADE && echo "  - Fix partial upgrade (sudo pacman -Syu)"
    fi

    print_info "========== System health check completed =========="

    return 0
}
