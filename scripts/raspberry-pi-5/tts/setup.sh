#!/bin/bash

# Description: Full piper TTS setup — install + download models
# Run as: bash setup.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPT_DIR/install.sh"
bash "$SCRIPT_DIR/models.sh"