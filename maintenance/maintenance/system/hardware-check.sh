#!/bin/bash


# Get system load averages
get_load_averages() {
    awk '{print $1", "$2", "$3}' /proc/loadavg
}

# Get CPU core count
get_cpu_cores() {
    nproc
}

# Check if load is high
is_load_high() {
    local load_1min
    load_1min=$(awk '{print $1}' /proc/loadavg)

    local cores
    cores=$(get_cpu_cores)

    # Load is high if 1-min average > number of cores
    if (( $(echo "$load_1min > $cores" | bc -l) )); then
        return 0  # High
    else
        return 1  # Normal
    fi
}

# Get memory usage
get_memory_usage() {
    free -h | awk '/^Mem:/ {print $3" / "$2" ("int($3/$2*100)"%)"}'
}

# Get memory usage percentage
get_memory_percent() {
    free | awk '/^Mem:/ {print int($3/$2*100)}'
}

# Get disk usage for root
get_disk_usage() {
    df -h / | awk 'NR==2 {print $3" / "$2" ("$5")"}'
}

# Get disk usage percentage
get_disk_percent() {
    df / | awk 'NR==2 {print int($5)}'
}

# Get CPU temperature (if available)
get_cpu_temp() {
    if command -v sensors &>/dev/null; then
        sensors 2>/dev/null | grep -i "Tctl" | head -1 | awk '{print $2}' | tr -d '+'
    else
        echo "N/A"
    fi
}
