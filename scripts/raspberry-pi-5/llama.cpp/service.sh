#!/bin/bash

# Description: Install llama-server as a systemd service on Raspberry Pi 5
# Run as: bash llamacpp-service-install.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_NAME="llama-server"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"
RUN_SCRIPT="$SCRIPT_DIR/start-server.sh"

# 1. Create systemd service
sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=llama-server
After=network.target

[Service]
ExecStart=/bin/bash $RUN_SCRIPT
Restart=on-failure
User=$USER

[Install]
WantedBy=multi-user.target
EOF

# 2. Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl start "$SERVICE_NAME"

echo "Service status:"
sudo systemctl status "$SERVICE_NAME" --no-pager
echo ""
echo "Logs: journalctl -u $SERVICE_NAME -f"