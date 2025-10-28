#!/bin/bash

set -Eeuo pipefail
trap 'print_error "Unexpected error occurred at line $LINENO"; exit 1' ERR

cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║            Maintenance Tasks - Complete Timer Setup            ║
╚════════════════════════════════════════════════════════════════╝

This script will set up systemd timers for all automated maintenance tasks:

  Daily:
    - maintenance-check (checks for due manual tasks, sends reminders)

  Weekly:
    - mirrorlist-update (updates pacman mirrors)

  Monthly:
    - btrfs-scrub (verifies filesystem integrity)
    - journal-cleanup (removes old journal entries)

Note: System updates should be run manually via maintenance-tasks

EOF

read -rp "Continue with installation? (y/N): " response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo ""

# Sourcing the utils script
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

MAINTENANCE_SCRIPT="$SCRIPT_DIR/../maintenance-tasks.sh"

# Initialize logging with bi-weekly log file
CURRENT_DATE=$(date +'%Y-%m-%d')
init_logging "maintenance-tasks/${CURRENT_DATE}.log"


# Array of timers to create: name:script:schedule:description
declare -A TIMERS=(
    [maintenance-check]="check-maintenance.sh:daily:Check for due maintenance tasks"
    [mirrorlist-update]="update-mirrorlist.sh:weekly:Update pacman mirrorlist"
    [btrfs-scrub]="btrfs-scrub.sh:monthly:Btrfs filesystem scrub"
    [journal-cleanup]="cleanup-journal.sh:monthly:Clean up old journal logs"
)

# Create service and timer for each task
for timer_name in "${!TIMERS[@]}"; do
    IFS=':' read -r script schedule description <<< "${TIMERS[$timer_name]}"

    print_info "Setting up: $timer_name"

    # Verify script exists
    if [[ ! -f "$SCRIPT_DIR/$script" ]]; then
        print_error "Script not found: $SCRIPT_DIR/$script"
        continue
    fi

    # Make script executable
    chmod +x "$SCRIPT_DIR/$script"

    # Determine User setting based on task
    if [[ "$timer_name" == "maintenance-check" ]]; then
        # Check task runs as user (for notifications)
        service_user="$USER"
        environment_vars="Environment=DISPLAY=:0
Environment=DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus"
        read_write_paths=""
    else
        # Other tasks run as root
        service_user="root"
        environment_vars="Environment=MAINTENANCE_USER=$USER"
        read_write_paths="ReadWritePaths=/etc/pacman.d $HOME/.local/share/maintenance-logs"
    fi

    # Create service file
    print_info "  Creating service file..."
    sudo tee "/etc/systemd/system/${timer_name}.service" > /dev/null << EOF
[Unit]
Description=$description
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=$MAINTENANCE_SCRIPT run $timer_name
User=$service_user
StandardOutput=journal
StandardError=journal

$environment_vars

# Security hardening
PrivateTmp=yes
NoNewPrivileges=yes
ProtectSystem=strict
$read_write_paths
EOF
    # Create timer file with appropriate schedule
    print_info "  Creating timer file..."

    case "$schedule" in
        daily)
            on_calendar="daily
    OnCalendar=*-*-* 09:00:00
    OnBootSec=15min"
            ;;
        weekly)
            on_calendar="weekly
    OnCalendar=Mon *-*-* 10:00:00"
            ;;
        monthly)
            on_calendar="monthly
    OnCalendar=*-*-01 11:00:00"
            ;;
        *)
            on_calendar="$schedule"
            ;;
    esac

    sudo tee "/etc/systemd/system/${timer_name}.timer" > /dev/null << EOF
[Unit]
Description=$description ($schedule)
Requires=${timer_name}.service

[Timer]
OnCalendar=$on_calendar
Persistent=true
RandomizedDelaySec=1h

[Install]
WantedBy=timers.target
EOF

    print_success "  Created $timer_name timer"
done

echo ""
print_info "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo ""
print_info "Enabling and starting timers..."

for timer_name in "${!TIMERS[@]}"; do
    sudo systemctl enable "${timer_name}.timer"
    sudo systemctl start "${timer_name}.timer"
    print_success "  Enabled: $timer_name"
done

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                     Installation Complete!                     ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

print_info "Timer Status:"
systemctl list-timers maintenance-check.timer mirrorlist-update.timer btrfs-scrub.timer journal-cleanup.timer orphan-removal.timer --no-pager

echo ""
echo "Useful Commands:"
echo "  View all timers:        systemctl list-timers"
echo "  View specific timer:    systemctl status <timer-name>.timer"
echo "  View service logs:      journalctl -u <service-name>.service"
echo "  Run service manually:   sudo systemctl start <service-name>.service"
echo "  Disable timer:          sudo systemctl disable --now <timer-name>.timer"
echo ""
echo "  View maintenance tasks: maintenance-tasks show"
echo "  Run manual task:        maintenance-tasks run <task-name>"
echo ""
