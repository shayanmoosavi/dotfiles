#!/bin/bash

cat << 'EOF'
╔════════════════════════════════════════════════════════════╗
║            Mirrorlist Update Timer Installation            ║
╚════════════════════════════════════════════════════════════╝

This script will create systemd service and timer files to automatically
update your mirrorlist every week.

Files to be created:
  /etc/systemd/system/update-mirrorlist.service
  /etc/systemd/system/update-mirrorlist.timer

EOF

read -rp "Continue with installation? (y/N): " response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

# Get the absolute path to the update-mirrorlist.sh script
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
UPDATE_SCRIPT="$SCRIPT_DIR/update-mirrorlist.sh"

# Username (edit to your actual username)
USER_NAME="shayan"

if [[ ! -f "$UPDATE_SCRIPT" ]]; then
    echo "Error: update-mirrorlist.sh not found at $UPDATE_SCRIPT"
    exit 1
fi

echo ""
echo "Creating systemd service file..."

# Create the service file
sudo tee /etc/systemd/system/update-mirrorlist.service > /dev/null << EOF
[Unit]
Description=Update Arch Linux Mirrorlist
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=$UPDATE_SCRIPT
User=root
StandardOutput=journal
StandardError=journal

# Environment for logging to user directory
Environment="MAINTENANCE_USER=$USER_NAME"

# Security hardening
PrivateTmp=yes
NoNewPrivileges=yes
ProtectSystem=strict
ReadWritePaths=/etc/pacman.d /home/$USER_NAME/.local/share/maintenance-logs
EOF

echo "✓ Service file created"

echo "Creating systemd timer file..."

# Create the timer file
sudo tee /etc/systemd/system/update-mirrorlist.timer > /dev/null << 'EOF'
[Unit]
Description=Update Arch Linux Mirrorlist every week
Requires=update-mirrorlist.service

[Timer]
# Run every week
OnCalendar=weekly
# Run on boot if missed (e.g., system was off)
Persistent=true
# Add random delay to avoid all systems updating at once
RandomizedDelaySec=2h

[Install]
WantedBy=timers.target
EOF

echo "✓ Timer file created"

echo ""
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo ""
echo "Enabling and starting timer..."
sudo systemctl enable update-mirrorlist.timer
sudo systemctl start update-mirrorlist.timer

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                   Installation Complete!                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Timer Status:"
systemctl status update-mirrorlist.timer --no-pager
echo ""
echo "Next scheduled run:"
systemctl list-timers update-mirrorlist.timer --no-pager
echo ""
echo "Useful commands:"
echo "  View timer status:      systemctl status update-mirrorlist.timer"
echo "  View service status:    systemctl status update-mirrorlist.service"
echo "  View service logs:      journalctl -u update-mirrorlist.service"
echo "  Run manually now:       sudo systemctl start update-mirrorlist.service"
echo "  Disable timer:          sudo systemctl disable --now update-mirrorlist.timer"
echo ""
