#!/bin/bash

# Wrapper: Update Mirrorlist Task
# Executes: bin/update-mirrorlist.sh
# Purpose: Single entry point for maintenance task system

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

source "$PARENT_DIR/utils.sh"

# Define the actual script to execute
ACTUAL_SCRIPT="$PARENT_DIR/bin/update-mirrorlist.sh"

# Verify the script exists and is executable
if [[ ! -f "$ACTUAL_SCRIPT" ]]; then
    print_error "Script not found: $ACTUAL_SCRIPT"
    exit 1
fi

if [[ ! -x "$ACTUAL_SCRIPT" ]]; then
    print_error "Script is not executable: $ACTUAL_SCRIPT"
    print_info "Run: chmod +x $ACTUAL_SCRIPT"
    exit 1
fi

# Execute the actual script, passing all arguments
if "$ACTUAL_SCRIPT" "$@"; then
    exit 0
else
    local exit_code=$?
    print_error "Task failed with exit code: $exit_code"
    exit $exit_code
fi
