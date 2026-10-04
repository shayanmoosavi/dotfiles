#!/bin/bash

# Setup systemd timer for battery-notify
sudo tee "/etc/systemd/system/battery-notify.timer" > /dev/null << EOF
[Unit]
Description= Battery Notification Service Timer
Requires=battery-notify.service

[Timer]
OnBootSec=1min
OnUnitActiveSec=1min
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Setup systemd servicce for battery-notify
sudo tee "/etc/systemd/system/battery-notify.service" > /dev/null << EOF
[Unit]
Description= Battery Notification Service

[Service]
Type=oneshot
ExecStart=$HOME/battery-notify/battery-notify.sh
User=$USER
Environment=DISPLAY=:0
Environment=DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus
StandardOutput=journal
StandardError=journal

# Security hardening
PrivateTmp=yes
NoNewPrivileges=yes
ProtectSystem=strict
EOF

sudo systemctl enable battery-notify.timer
sudo systemctl start battery-notify.timer
