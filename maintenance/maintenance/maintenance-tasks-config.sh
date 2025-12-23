#!/usr/bin/bash


# Create default config if it doesn't exist
create_default_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        return 0
    fi

    print_info "Creating default tasks configuration..."

    mkdir -p "$CONFIG_DIR"
    cat > "$CONFIG_FILE" << 'EOF'
# Maintenance Tasks Configuration
# Format:
#   [task-name]
#   type = automated|manual
#   frequency = <days between runs>
#   description = <description>
#   command = <script in bin/ directory>
#   enabled = true|false

# ============================================================================
# AUTOMATED TASKS
# ============================================================================

[mirrorlist-update]
type = automated
frequency = 7
description = Update pacman mirror list
command = update-mirrorlist
enabled = true

[journal-cleanup]
type = automated
frequency = 30
description = Clean old systemd journal logs
command = cleanup-journal
enabled = true

[btrfs-scrub]
type = automated
frequency = 30
description = Verify Btrfs filesystem integrity
command = btrfs-scrub
enabled = true

[orphan-removal]
type = automated
frequency = 30
description = Remove orphaned packages
command = orphan-removal
enabled = true

# ============================================================================
# MANUAL TASKS
# ============================================================================

[system-update]
type = automated
frequency = 7
description = Update system packages and clean caches
command = update-system
enabled = true

[cache-cleanup]
type = manual
frequency = 30
description = Clean user cache directories (~/.cache)
command = cleanup-cache
enabled = true

[pacnew-review]
type = manual
frequency = 30
description = Review and merge .pacnew/.pacsave files
command = pacnew-review
enabled = true

[failed-services]
type = manual
frequency = 30
description = Check for failed systemd services
command = failed-services
enabled = true

[health-check]
type = manual
frequency = 30
description = Perform health checks on system components
command = check-health
enabled = true

[disk-space-review]
type = manual
frequency = 90
description = Review large files and disk space usage
command = disk-space-review
enabled = true
EOF

    print_success "Config created at: $CONFIG_FILE"
}

# Parse INI-style config file
# Args: $1 = section name, $2 = key name
# Returns: value for the key in that section
get_config_value() {
    local section="$1"
    local key="$2"
    local in_section=false

    while IFS= read -r line; do
        # Trim whitespace
        line=$(echo "$line" | xargs echo -n)

        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        # Check for section header
        if [[ "$line" =~ ^\[(.+)\]$ ]]; then
            local current_section="${BASH_REMATCH[1]}"
            if [[ "$current_section" == "$section" ]]; then
                in_section=true
            else
                in_section=false
            fi
            continue
        fi

        # If in the right section, look for key
        if [[ "$in_section" == true && "$line" =~ ^([^=]+)=(.+)$ ]]; then
            local current_key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"

            # Trim whitespace from key and value
            current_key=$(echo "$current_key" | xargs echo -n)
            value=$(echo "$value" | xargs echo -n)

            if [[ "$current_key" == "$key" ]]; then
                echo "$value"
                return 0
            fi
        fi
    done < "$CONFIG_FILE"

    return 1
}
