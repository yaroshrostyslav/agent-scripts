#!/bin/bash

# Description: First-run setup script for Raspberry Pi 5
# Run as: bash first-run.sh

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

CONFIG=/boot/firmware/config.txt

echo -e "${GREEN}=== Raspberry Pi 5 First-Run Setup ===${NC}"
echo ""

# Step 1: Enable PCIe 3.0
echo -e "${YELLOW}[1] Enabling PCIe 3.0...${NC}"

echo "PCIe link status before:"
sudo lspci -vv | grep -i "LnkSta:"
echo ""

if grep -q "dtparam=pciex1_gen=3" "$CONFIG"; then
    echo "PCIe 3.0 already enabled, skipping."
else
    echo "dtparam=pciex1_gen=3" | sudo tee -a "$CONFIG" > /dev/null
    echo -e "${GREEN}Done.${NC}"
fi
echo ""
echo "After reboot, run to verify: sudo lspci -vv | grep -i \"LnkSta:\""
echo ""

# Step 2: Install packages
echo -e "${YELLOW}[2] Installing packages...${NC}"
sudo apt update && sudo apt install -y git curl btop mpg123 ffmpeg
echo -e "${GREEN}Done.${NC}"
echo ""

# Step 3: Enable SSH
echo -e "${YELLOW}[3] Enabling SSH...${NC}"
sudo systemctl enable ssh
sudo systemctl start ssh
echo -e "${GREEN}Done.${NC}"
echo ""

# Step 4: Install Node.js (NodeSource LTS) and PM2
echo -e "${YELLOW}[4] Installing Node.js and PM2...${NC}"

if [ -f /etc/apt/sources.list.d/nodesource.list ]; then
    echo "NodeSource repo already added, skipping."
else
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
fi
sudo apt install -y nodejs

if command -v pm2 > /dev/null; then
    echo "pm2 $(pm2 --version) already installed, skipping."
else
    sudo npm install -g pm2
fi

# Register pm2 with systemd so the saved process list is restored on boot.
# Passing -u/--hp runs the setup non-interactively instead of printing a
# sudo command for the user to copy-paste.
sudo env PATH="$PATH:/usr/bin" pm2 startup systemd -u "$USER" --hp "$HOME"

# Seed an empty process list only on the very first run — re-running
# first-run.sh must not wipe a dump saved after adding real apps.
if [ ! -f "$HOME/.pm2/dump.pm2" ]; then
    pm2 save --force
fi

echo -e "${GREEN}Done.${NC}"
echo ""
echo "node $(node --version) / npm $(npm --version) / pm2 $(pm2 --version)"
echo ""

# Step 5: Install PHP 8.4 CLI
#         Trixie ships 8.4 in the stock repos, so no third-party repo is needed
#         (unlike Node, where Debian only has 20.x and NodeSource was required)
echo -e "${YELLOW}[5] Installing PHP 8.4 CLI...${NC}"
sudo apt install -y \
    php8.4-cli \
    php8.4-curl \
    php8.4-mbstring \
    php8.4-xml \
    php8.4-zip \
    php8.4-bcmath \
    php8.4-intl \
    php8.4-sqlite3 \
    php8.4-opcache
echo -e "${GREEN}Done.${NC}"
echo ""
echo "$(php -v | head -1)"
echo "php binary: $(command -v php)"
echo ""

echo -e "${GREEN}=== Setup complete! ===${NC}"