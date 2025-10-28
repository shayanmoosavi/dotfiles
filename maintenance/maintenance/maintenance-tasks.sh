#!/usr/bin/bash

# Maintenance Tasks Management Script
# Interactive TUI for viewing and running maintenance tasks

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Initialize logging with daily log file
CURRENT_DATE=$(date +'%Y-%m-%d')
init_logging "maintenance-tasks/${CURRENT_DATE}.log"

# Configuration
if [[ -n "${INVOCATION_ID:-}" ]]; then
    # Changing the directory to user home instead of root home when run from systemd
    if [[ $USER == "root" ]]; then
        CONFIG_DIR="/home/$MAINTENANCE_USER/.config/maintenance-tasks"
        STATE_DIR="/home/$MAINTENANCE_USER/.local/share/maintenance-tasks"
    else
        CONFIG_DIR="$HOME/.config/maintenance-tasks"
        STATE_DIR="$HOME/.local/share/maintenance-tasks"
    fi
else
    CONFIG_DIR="$HOME/.config/maintenance-tasks"
    STATE_DIR="$HOME/.local/share/maintenance-tasks"
fi
LAST_RUN_DIR="$STATE_DIR/last-run"
CONFIG_FILE="$CONFIG_DIR/tasks.conf"
PENDING_FLAG="$STATE_DIR/pending-reminders"
BIN_DIR="$SCRIPT_DIR/bin"

# Ensure directories exist
mkdir -p "$CONFIG_DIR" "$LAST_RUN_DIR"

# Parse command line arguments
COMMAND="${1:-show}"

# Show help message
show_help() {
    cat << EOF
Usage: $(basename "$0") [COMMAND]

Manage system maintenance tasks.

COMMANDS:
    show            Show all tasks and their status (default)
    list            List tasks in simple format
    run <task>      Run a specific task
    mark <task>     Mark a task as completed without running
    status <task>   Show detailed status of a task
    check           Check for due tasks and update reminders
    setup <tool>    Set up systemd timers and infrastructure
    clear           Clear pending reminders flag
    help            Show this help message

EXAMPLES:
    $(basename "$0")                           # Show interactive task list
    $(basename "$0") run cache-cleanup         # Run cache cleanup task
    $(basename "$0") status system-update      # Show update details
    $(basename "$0") check                     # Check what's due
    $(basename "$0") setup mirror-timer        # Set up mirror update timer
    $(basename "$0") setup maintenance-check   # Set up daily check timer

FILES:
    Config:  $CONFIG_FILE
    State:   $STATE_DIR
    Scripts: $BIN_DIR

EOF
}

source "$SCRIPT_DIR/maintenance-tasks-config.sh"

# Get list of all task names from config
get_all_tasks() {
    grep -oP '^\[\K[^\]]+' "$CONFIG_FILE" 2>/dev/null || true
}

# Get list of available setup scripts
get_available_setups() {
    find "$BIN_DIR" -maxdepth 1 -name "setup-*.sh" -type f 2>/dev/null | xargs basename | sed 's/setup-//;s/.sh$//' || true
}

source "$SCRIPT_DIR/maintenance-tasks-status.sh"

# Show all tasks in a formatted table
show_tasks() {
    create_default_config

    echo ""
    echo "╔════════════════════════════════════════════════════════════════════════════╗"
    echo "║                        Maintenance Tasks Status                            ║"
    echo "╚════════════════════════════════════════════════════════════════════════════╝"
    echo ""

    # Check if there are pending reminders
    if [[ -f "$PENDING_FLAG" ]]; then
        local pending_count
        pending_count=$(cat "$PENDING_FLAG")
        print_warning "You have $pending_count pending maintenance task(s)"
        echo ""
    fi

    # Get all tasks
    local tasks
    tasks=$(get_all_tasks)

    if [[ -z "$tasks" ]]; then
        print_error "No tasks defined in $CONFIG_FILE"
        return 1
    fi

    # Separate automated and manual tasks
    local -a automated_tasks=()
    local -a manual_tasks=()

    while IFS= read -r task; do
        local type
        type=$(get_config_value "$task" "type" || echo "manual")

        if [[ "$type" == "automated" ]]; then
            automated_tasks+=("$task")
        else
            manual_tasks+=("$task")
        fi
    done <<< "$tasks"

    # Display automated tasks
    if [[ ${#automated_tasks[@]} -gt 0 ]]; then
        echo -e "${BOLD}Automated Tasks:${NC}"
        printf "%-25s %-12s %-15s %s\n" "Task" "Status" "Last Run" "Description"
        printf "%s\n" "$(printf '─%.0s' {1..90})"

        for task in "${automated_tasks[@]}"; do
            display_task_row "$task"
        done
        echo ""
    fi

    # Display manual tasks
    if [[ ${#manual_tasks[@]} -gt 0 ]]; then
        echo -e "${BOLD}Manual Tasks:${NC}"
        printf "%-25s %-12s %-15s %s\n" "Task" "Status" "Last Run" "Description"
        printf "%s\n" "$(printf '─%.0s' {1..90})"

        for task in "${manual_tasks[@]}"; do
            display_task_row "$task"
        done
        echo ""
    fi

    echo "Commands:"
    echo "  maintenance-tasks run <task>    - Run a specific task"
    echo "  maintenance-tasks status <task> - Show detailed task status"
    echo ""
}

# Display a single task row in the table
display_task_row() {
    local task="$1"

    local status
    status=$(get_task_status "$task")

    local last_run
    last_run=$(format_last_run "$task")

    local description
    description=$(get_config_value "$task" "description" || echo "No description")

    # Truncate description if too long
    if [[ ${#description} -gt 30 ]]; then
        description="${description:0:27}..."
    fi

    # Color-code status
    local status_colored
    case "$status" in
        overdue)
            status_colored="${RED}OVERDUE${NC}"
            ;;
        due)
            status_colored="${YELLOW}DUE${NC}"
            ;;
        never-run)
            status_colored="${BLUE}NEVER RUN${NC}"
            ;;
        ok)
            status_colored="${GREEN}OK${NC}"
            ;;
        disabled)
            status_colored="${DIM}DISABLED${NC}"
            ;;
        *)
            status_colored="$status"
            ;;
    esac

    printf "%-25s %-20s %-15s %s\n" "$task" "$(echo -e "$status_colored")" "$last_run" "$description"
}

# Show detailed status of a single task
show_task_status() {
    local task="$1"

    if ! get_config_value "$task" "type" &>/dev/null; then
        print_error "Task not found: $task"
        return 1
    fi

    echo ""
    echo "╔════════════════════════════════════════════════════════════════════════════╗"
    echo "║                           Task Details                                     ║"
    echo "╚════════════════════════════════════════════════════════════════════════════╝"
    echo ""

    echo "Task:        $task"
    echo "Type:        $(get_config_value "$task" "type")"
    echo "Frequency:   Every $(get_config_value "$task" "frequency") days"
    echo "Description: $(get_config_value "$task" "description")"
    echo "Command:     $(get_config_value "$task" "command")"
    echo "Enabled:     $(get_config_value "$task" "enabled" || echo "true")"
    echo ""
    echo "Status:      $(get_task_status "$task")"
    echo "Last Run:    $(format_last_run "$task")"

    local last_run
    last_run=$(get_last_run "$task")

    if [[ "$last_run" != "never" ]]; then
        local frequency
        frequency=$(get_config_value "$task" "frequency")

        local days_since
        days_since=$(get_days_since_run "$task")

        local days_until=$((frequency - days_since))

        if [[ $days_until -gt 0 ]]; then
            echo "Next Due:    In $days_until days"
        else
            echo "Next Due:    Now (overdue by ${days_until#-} days)"
        fi
    fi

    echo ""
}

# Run a specific task
run_task() {
    local task="$1"

    if ! get_config_value "$task" "type" &>/dev/null; then
        print_error "Task not found: $task"
        return 1
    fi

    local command
    command=$(get_config_value "$task" "command")

    local script_path="$BIN_DIR/$command"

    # Try with and without .sh extension
    if [[ ! -f "$script_path" && ! -f "$script_path.sh" ]]; then
        print_error "Task script not found: $script_path (or $script_path.sh)"
        return 1
    fi

    # Use .sh version if it exists
    if [[ -f "$script_path.sh" ]]; then
        script_path="$script_path.sh"
    fi

    if [[ ! -x "$script_path" ]]; then
        print_error "Task script is not executable: $script_path"
        print_info "Run: chmod +x $script_path"
        return 1
    fi

    print_info "Running task: $task"
    echo ""

    # Run the task script
    if "$script_path"; then
        # Reset logging path
        init_logging "maintenance-tasks/${CURRENT_DATE}.log"

        print_success "Task completed: $task"
        set_last_run "$task"
        return 0
    else
        # Reset logging path
        init_logging "maintenance-tasks/${CURRENT_DATE}.log"

        print_error "Task failed: $task"
        return 1
    fi
}

# Mark task as completed without running
mark_complete() {
    local task="$1"

    if ! get_config_value "$task" "type" &>/dev/null; then
        print_error "Task not found: $task"
        return 1
    fi

    set_last_run "$task"
    print_success "Marked task as completed: $task"
}

# Run a setup script
run_setup() {
    local tool="$1"
    local setup_script="$BIN_DIR/setup-$tool.sh"

    if [[ ! -f "$setup_script" ]]; then
        print_error "Setup script not found: $setup_script"
        print_info "Available setups:"
        get_available_setups | sed 's/^/  - /'
        return 1
    fi

    if [[ ! -x "$setup_script" ]]; then
        chmod +x "$setup_script"
    fi

    print_info "Running setup: $tool"
    echo ""

    if "$setup_script"; then
        print_success "Setup completed: $tool"
        return 0
    else
        print_error "Setup failed: $tool"
        return 1
    fi
}

# Check for due tasks and update pending flag
check_due_tasks() {
    create_default_config

    local tasks
    tasks=$(get_all_tasks)

    local due_count=0
    local -a due_tasks=()

    while IFS= read -r task; do
        local type
        type=$(get_config_value "$task" "type" || echo "manual")

        local enabled
        enabled=$(get_config_value "$task" "enabled" || echo "true")

        # Only check manual tasks that are enabled
        if [[ "$type" == "manual" && "$enabled" == "true" ]]; then
            if is_task_due "$task"; then
                ((due_count+=1))
                due_tasks+=("$task")
            fi
        fi
    done <<< "$tasks"

    if [[ $due_count -gt 0 ]]; then
        echo "$due_count" > "$PENDING_FLAG"
        echo "Due tasks: ${due_tasks[*]}"
        return 0
    else
        rm -f "$PENDING_FLAG"
        echo "No tasks due"
        return 1
    fi
}

# Clear pending reminders flag
clear_reminders() {
    rm -f "$PENDING_FLAG"
    print_success "Cleared pending reminders"
}

# List tasks in simple format
list_tasks() {
    create_default_config

    local tasks
    tasks=$(get_all_tasks)

    while IFS= read -r task; do
        local status
        status=$(get_task_status "$task")
        echo "$task: $status"
    done <<< "$tasks"
}

# Main execution
main() {
    case "$COMMAND" in
        show)
            show_tasks
            ;;
        list)
            list_tasks
            ;;
        run)
            if [[ $# -lt 2 ]]; then
                print_error "Usage: $(basename "$0") run <task>"
                exit 1
            fi
            run_task "$2"
            ;;
        mark)
            if [[ $# -lt 2 ]]; then
                print_error "Usage: $(basename "$0") mark <task>"
                exit 1
            fi
            mark_complete "$2"
            ;;
        status)
            if [[ $# -lt 2 ]]; then
                print_error "Usage: $(basename "$0") status <task>"
                exit 1
            fi
            show_task_status "$2"
            ;;
        check)
            check_due_tasks
            ;;
        setup)
            if [[ $# -lt 2 ]]; then
                print_error "Usage: $(basename "$0") setup <tool>"
                print_info "Available setups:"
                get_available_setups | sed 's/^/  - /'
                exit 1
            fi
            run_setup "$2"
            ;;
        clear)
            clear_reminders
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $COMMAND"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
