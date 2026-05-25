#!/bin/bash

# Description: Install piper-tts on Raspberry Pi 5
# Run as: bash install.sh
# Installs into <CWD>/tts/ (analogous to llama.cpp install layout).

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Audio stack (pipewire + bluetooth support) and venv tooling
sudo apt update && sudo apt install -y \
    python3-venv \
    pipewire pipewire-pulse wireplumber \
    libspa-0.2-bluetooth \
    pulseaudio-utils

# 2. Create install dir + Python venv + piper-tts
[[ ! -d tts ]] && mkdir tts
(
  cd tts
  [[ ! -d venv ]] && python3 -m venv venv
  # shellcheck disable=SC1091
  source venv/bin/activate
  pip install --upgrade pip
  pip install piper-tts
  deactivate

  # Copy runtime scripts so `tts` symlink resolves inside install dir
  cp "$SOURCE_DIR/say.sh" "$SOURCE_DIR/say.py" .
  chmod +x say.sh
)

# 3. Install say.sh as system command `tts`
sudo ln -sf "$(pwd)/tts/say.sh" /usr/local/bin/tts

# 4. Validate
tts --help

echo
echo "Installation complete in: $(pwd)/tts"
echo "Manual steps remaining:"
echo "  1. Reboot to activate pipewire: sudo reboot"
echo "  2. Pair Bluetooth speaker (bluetoothctl)"
echo "  3. Set default audio sink:"
echo "       pactl list short sinks"
echo "       pactl set-default-sink <sink_name>"
echo "       paplay /usr/share/sounds/alsa/Front_Center.wav"