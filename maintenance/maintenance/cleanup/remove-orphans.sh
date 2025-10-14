#!/bin/bash


set -Eeuo pipefail
trap 'print_error "Unexpected error occurred at line $LINENO"; exit 1' ERR

# Remove orphaned packages
remove_orphans() {
    print_info "Checking for orphaned packages..."

    local orphans
    orphans=$(pacman -Qtdq 2>/dev/null || true)

    if [[ -z "$orphans" ]]; then
        print_success "No orphaned packages found"
        return 0
    fi

    local orphan_count
    orphan_count=$(echo "$orphans" | wc -l)

    print_info "Found $orphan_count orphaned packages: $(echo $orphans | tr '\n' ' ')"

    echo "$orphans" | sudo pacman -Rns - --noconfirm

    print_success "Removed $orphan_count orphaned packages"
}
