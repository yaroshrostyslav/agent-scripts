#!/bin/bash

# Description: Full piper TTS setup — install + download models
# Run as: bash setup.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPT_DIR/install.sh"
bash "$SCRIPT_DIR/models.sh"

echo
echo "Installation complete in: $(pwd)/tts"
echo "Manual steps remaining:"
echo "  1. Reboot to activate pipewire: sudo reboot"
echo "  2. Pair Bluetooth speaker (bluetoothctl)"
echo "  3. Set default audio sink:"
echo "       pactl list short sinks"
echo "       pactl set-default-sink <sink_name>"
echo "       paplay /usr/share/sounds/alsa/Front_Center.wav"