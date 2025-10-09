#!/bin/bash


# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global logging variables
LOG_BASE_DIR="$HOME/.local/share/maintenance-logs"
LOG_FILE=""  # Will be set by init_logging()

# Initialize logging for a script
# Usage: init_logging "category/filename.log"
# Example: init_logging "updates/2025-10.log"
#          init_logging "cleanup/daily-2025-10-09.log"
init_logging() {
    if [[ $# -ne 1 ]]; then
        echo "Error: init_logging requires exactly one argument (log file path relative to $LOG_BASE_DIR)" >&2
        return 1
    fi

    local log_path="$1"

    # Construct full log file path
    LOG_FILE="$LOG_BASE_DIR/$log_path"

    # Extract directory from log file path
    local log_dir
    log_dir=$(dirname "$LOG_FILE")

    # Create directory structure if it doesn't exist
    if ! mkdir -p "$log_dir" 2>/dev/null; then
        echo "Error: Failed to create log directory: $log_dir" >&2
        return 1
    fi

    # Create log file if it doesn't exist (touch creates empty file)
    if ! touch "$LOG_FILE" 2>/dev/null; then
        echo "Error: Failed to create/access log file: $LOG_FILE" >&2
        return 1
    fi

    # Verify LOG_FILE is writable
    if [[ ! -w "$LOG_FILE" ]]; then
        echo "Error: Log file is not writable: $LOG_FILE" >&2
        return 1
    fi

    return 0
}

log() {
    if [[ $# -lt 2 ]]; then
        echo "Error: log requires at least 2 arguments (level and message)" >&2
        return 1
    fi

    # Check if logging has been initialized
    if [[ -z "$LOG_FILE" ]]; then
        echo "Error: Logging not initialized. Call init_logging() first." >&2
        return 1
    fi

    local level="$1"
    shift  # Remove first argument, rest is the message

    local timestamp
    timestamp=$(date +'%Y-%m-%d %H:%M:%S')

    local log_entry="[$timestamp] [$level] $*"

    # Write to both terminal and log file
    echo "$log_entry" | tee -a "$LOG_FILE"
}

# Print colored messages
print_status() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Get the current log file path (useful for displaying to user)
get_log_file() {
    echo "$LOG_FILE"
}

# Check if logging is initialized
is_logging_initialized() {
    [[ -n "$LOG_FILE" ]]
}
