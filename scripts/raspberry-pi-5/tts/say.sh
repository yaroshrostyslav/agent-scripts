#!/bin/bash

# Description: Synthesize text to speech via piper
# Usage: tts --text "Привіт"

set -euo pipefail

# Resolve symlink so /usr/local/bin/tts finds the real script dir
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

usage() {
  echo "Usage: tts --text \"text to speak\""
}

# 1. Parse args
TEXT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --text) TEXT="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage >&2; exit 1 ;;
  esac
done

if [[ -z "$TEXT" ]]; then
  usage >&2
  exit 1
fi

# 2. Run piper, pipe raw audio to paplay
# shellcheck disable=SC1091
source "$SCRIPT_DIR/venv/bin/activate"
python "$SCRIPT_DIR/say.py" "$TEXT"