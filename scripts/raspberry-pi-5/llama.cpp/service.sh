#!/bin/bash

# Description: Install llama-server as a systemd service on Raspberry Pi 5
# Run as: bash service.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_NAME="llama-server"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"
GOVERNOR_SERVICE_NAME="cpu-performance-governor"
GOVERNOR_SERVICE_FILE="/etc/systemd/system/$GOVERNOR_SERVICE_NAME.service"
RUN_SCRIPT="$SCRIPT_DIR/start-server.sh"

# 1. Create CPU governor service (runs as root at boot, no sudo needed)
#    Sets performance mode — keeps all cores at max frequency so the first inference
#    request doesn't stall waiting for the CPU to ramp up from idle
sudo tee "$GOVERNOR_SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Set CPU governor to performance
Before=$SERVICE_NAME.service

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# 2. Create llama-server service
sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=llama-server
After=network.target $GOVERNOR_SERVICE_NAME.service
Requires=$GOVERNOR_SERVICE_NAME.service

[Service]
ExecStart=/bin/bash $RUN_SCRIPT
Restart=on-failure
User=$USER

[Install]
WantedBy=multi-user.target
EOF

# 3. Enable and start both services
sudo systemctl daemon-reload
sudo systemctl enable "$GOVERNOR_SERVICE_NAME"
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl start "$GOVERNOR_SERVICE_NAME"
sudo systemctl start "$SERVICE_NAME"

echo "Service status:"
sudo systemctl status "$SERVICE_NAME" --no-pager
echo ""
echo "Logs: journalctl -u $SERVICE_NAME -f"