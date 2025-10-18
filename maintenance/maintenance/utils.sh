#!/bin/bash


# Colors for output
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
    BOLD='\033[1m'
    DIM='\033[2m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
    BOLD=''
    DIM=''
fi

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
    printf "[%s] %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$*" >>"$LOG_FILE"
}

# Print colored messages and log them at the same time
print_info() {
    printf "${BLUE}[]${NC} %s\n" "$*"
    log "[INFO] $*"
}

print_success() {
    printf "${GREEN}[✓]${NC} %s\n" "$*"
    log "[SUCCESS] $*"
}

print_warning() {
    printf "${YELLOW}[⚠]${NC} %s\n" "$*" >&2
    log "[WARN] $*"
}

print_error() {
    printf "${RED}[✗]${NC} %s\n" "$*"
    log "[ERROR] $*"
}

# Get the current log file path (useful for displaying to user)
get_log_file() {
    echo "$LOG_FILE"
}

# Check if logging is initialized
is_logging_initialized() {
    [[ -n "$LOG_FILE" ]]
}

# Check if running with appropriate privileges
check_privileges() {
    print_info "Checking privileges..."
    # Skip check if running via systemd (as root is expected)
    if [[ -n "${INVOCATION_ID:-}" ]]; then
        # INVOCATION_ID is set by systemd
        return 0
    fi
    if [[ $EUID -eq 0 ]]; then
        print_error "Do not run this script as root. It will request sudo when needed."
        exit 1
    fi
}

# Check required commands
check_dependencies() {
    local missing_deps=()

    print_info "Checking dependencies..."
    for cmd in paru pacman informant snap-pac reflector pacman-contrib arch-audit; do
        if ! pacman -Q "$cmd" &> /dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing required packages: ${missing_deps[*]}"
        print_info "Install them with: paru -S ${missing_deps[*]}"
        exit 1
    fi
}

# Get human-readable size
human_readable_size() {
    local bytes=$1
    local -a units=('B' 'KB' 'MB' 'GB' 'TB')
    local unit=0
    local size=$bytes

    while (( size > 1024 && unit < 4 )); do
        size=$((size / 1024))
        ((unit+=1))
    done

    echo "${size}${units[$unit]}"
}

# Calculate directory size in bytes
get_dir_size() {
    local dir="$1"
    du -sb "$dir" 2>/dev/null | awk '{print $1}'
}
