#!/usr/bin/bash


# Get last run timestamp for a task
get_last_run() {
    local task="$1"
    local last_run_file="$LAST_RUN_DIR/$task"

    if [[ -f "$last_run_file" ]]; then
        cat "$last_run_file"
    else
        echo "never"
    fi
}

# Set last run timestamp for a task
set_last_run() {
    local task="$1"
    local timestamp="${2:-$(date +%s)}"

    echo "$timestamp" > "$LAST_RUN_DIR/$task"
}

# Calculate days since last run
get_days_since_run() {
    local task="$1"
    local last_run
    last_run=$(get_last_run "$task")

    if [[ "$last_run" == "never" ]]; then
        echo "never"
        return
    fi

    local current_time
    current_time=$(date +%s)
    local days=$(( (current_time - last_run) / 86400 ))

    echo "$days"
}

# Check if task is due
is_task_due() {
    local task="$1"

    local frequency
    frequency=$(get_config_value "$task" "frequency" || echo "30")

    local days_since
    days_since=$(get_days_since_run "$task")

    if [[ "$days_since" == "never" ]]; then
        return 0
    fi

    if [[ $days_since -ge $frequency ]]; then
        return 0  # Due
    else
        return 1  # Not due yet
    fi
}

# Get task status (due, ok, overdue)
get_task_status() {
    local task="$1"

    local enabled
    enabled=$(get_config_value "$task" "enabled" || echo "true")

    if [[ "$enabled" != "true" ]]; then
        echo "disabled"
        return
    fi

    local frequency
    frequency=$(get_config_value "$task" "frequency" || echo "30")

    local days_since
    days_since=$(get_days_since_run "$task")

    if [[ "$days_since" == "never" ]]; then
        echo "never-run"
        return
    fi

    if [[ $days_since -ge $((frequency * 2)) ]]; then
        echo "overdue"
    elif [[ $days_since -ge $frequency ]]; then
        echo "due"
    else
        echo "ok"
    fi
}

# Format last run time as human readable
format_last_run() {
    local task="$1"
    local last_run
    last_run=$(get_last_run "$task")

    if [[ "$last_run" == "never" ]]; then
        echo "Never"
        return
    fi

    local days_since
    days_since=$(get_days_since_run "$task")

    local date_str
    date_str=$(date -d "@$last_run" "+%Y-%m-%d")

    echo "$date_str (${days_since}d ago)"
}
