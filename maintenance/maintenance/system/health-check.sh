#!/bin/bash

set -Eeuo pipefail
trap 'print_error "Unexpected error occurred at line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/../utils.sh"

# Initialize logging with monthly log file
CURRENT_MONTH=$(date +'%Y-%m')
init_logging "system/${CURRENT_MONTH}.log"

# Checking whether the pacman database is intact
check_pacman_database_integrity() {
    print_info "Checking pacman package database (pacman -Dk)..."
    if pacman -Dk; then
        print_success "No issues found"
    else
        print_error "pacman -Dk reported issues"
    fi
}

# Checking whether installed packages have missing or changed files
check_package_file_integrity() {
    print_info "Checking file integrity of installed packages (pacman -Qkq)..."
    if sudo pacman -Qkq | tee /tmp/pacman_qk.txt; then
        if [[ -s /tmp/pacman_qk.txt ]]; then
            print_warning "possible missing/changed files. See log for details."
            print_info "pacman -Qkq output:\n$(< /tmp/pacman_qk.txt)"
        else
            print_success "No issues found"
        fi
        rm -f /tmp/pacman_qk.txt
    else
        print_error "pacman -Qkq failed"
    fi
}

# Listing the orphaned packages
list_orphans() {
    print_info "Listing orphaned packages (pacman -Qtdq)..."
    orphans=$(pacman -Qtdq || true)
    if [[ -n "$orphans" ]]; then
        print_warning "Found orphaned packages:\n$orphans"
        print_info "Orphans:\n$orphans"
    else
        print_success "No orphaned packages found"
    fi
}

# Checking for .pacnew and .pacsave files
run_pacdiff() {
    print_info "Checking for .pacnew and .pacsave files..."
    if pacdiff 2>&1 | tee /tmp/pacdiff_check.txt; then
        if [[ -s /tmp/pacdiff_check.txt ]]; then
            print_warning "pacdiff reports config file differences. Inspect and merge as needed."
            print_info "pacdiff output:\n$(< /tmp/pacdiff_check.txt)"
        else
            print_success "pacdiff reports no differences"
        fi
        rm -f /tmp/pacdiff_check.txt
    fi
}

# Checking for failed systemd units
run_systemd_checks() {
    print_info "Checking for failed systemd units..."
    failed=$(systemctl --failed --no-legend || true)
    if [[ -n "$failed" ]]; then
        print_warning "Some systemd units have failed:\n$failed"
        print_info "systemctl --failed output:\n$failed"
    else
        print_success "No failed systemd units"
    fi
}

# Security checks
run_security_checks() {
    print_info "Running arch-audit for known Vulnerabalities..."
    if arch-audit -rf "%n | %t | Fixed version: %v | %s | Required by: %r" | tee /tmp/arch_audit.txt; then
        if [[ -s /tmp/arch_audit.txt ]]; then
            print_warning "arch-audit found vulnerable packages. See log."
            print_info "arch-audit:\n$(< /tmp/arch_audit.txt)"
        else
            print_success "arch-audit found no vulnerable packages"
        fi
        rm -f /tmp/arch_audit.txt
    fi
}

# Checking for journal error messages since last boot
run_journal_checks() {
    print_info "Collecting recent journal errors (last boot)..."
    journalctl -p 3 -xb --no-pager | tee /tmp/journal_errors.txt || true
    if [[ -s /tmp/journal_errors.txt ]]; then
        print_warning "Recent journald errors found. See logs."
        print_info "journalctl -p 3 -xb:\n$(< /tmp/journal_errors.txt)"
    else
        print_success "No recent critical journal errors"
    fi
    rm -f /tmp/journal_errors.txt
}

# Main execution
main() {
    echo ""
    echo "╔══════════════════════════════════════════════╗"
    echo "║        Arch Linux System Health Check        ║"
    echo "╚══════════════════════════════════════════════╝"
    echo ""

    print_info "========== System health check started =========="

    # Pre-flight checks
    print_info "Pre-flight checks:"
    check_privileges
    check_dependencies

    echo ""

    print_info "------ Package related checks ------"

    check_pacman_database_integrity
    check_package_file_integrity
    list_orphans
    run_pacdiff

    echo ""

    print_info "------ System related checks ------"

    run_systemd_checks
    run_journal_checks
    run_security_checks

    print_info "========== System health check finished =========="

    echo ""
    print_info "Log saved to: $(get_log_file)"
    echo ""
}

main "$@"
