#!/bin/bash

# Description: Synthesize text to speech via piper
# Usage: tts "Привіт"

set -euo pipefail

# Resolve symlink so /usr/local/bin/tts finds the real script dir
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo "Usage: tts \"text to speak\""
  exit 0
fi

if [[ $# -ne 1 ]]; then
  echo "Usage: tts \"text to speak\"" >&2
  exit 1
fi

# Run piper, pipe raw audio to paplay
# shellcheck disable=SC1091
source "$SCRIPT_DIR/venv/bin/activate"
python "$SCRIPT_DIR/say.py" "$1"