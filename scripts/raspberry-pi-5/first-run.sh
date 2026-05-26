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
sudo apt update && sudo apt install -y git btop mpg123 ffmpeg
echo -e "${GREEN}Done.${NC}"
echo ""

# Step 3: Enable SSH
echo -e "${YELLOW}[3] Enabling SSH...${NC}"
sudo systemctl enable ssh
sudo systemctl start ssh
echo -e "${GREEN}Done.${NC}"

echo -e "${GREEN}=== Setup complete! Rebooting in 15 seconds... ===${NC}"
echo "Press Ctrl+C to cancel."
sleep 15
sudo reboot