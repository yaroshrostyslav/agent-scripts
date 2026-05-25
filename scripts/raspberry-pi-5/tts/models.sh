#!/bin/bash

# Description: Download piper TTS models into tts install directory
# Run as: bash models.sh

set -euo pipefail

# 1. Detect TTS install dir via tts symlink
TTS_DIR=$(dirname "$(readlink -f "$(which tts)")")
MODELS_DIR="$TTS_DIR/models"

mkdir -p "$MODELS_DIR"

# shellcheck disable=SC1091
source "$TTS_DIR/venv/bin/activate"

# 2. Download model: uk_UA-oleksa-high
(
  cd "$MODELS_DIR"
  python -m piper.download_voices uk_UA-oleksa-high
)

echo "Models downloaded to: $MODELS_DIR"
ls -lh "$MODELS_DIR"