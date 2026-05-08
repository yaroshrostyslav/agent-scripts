#!/bin/bash

# Description: Download GGUF models into llama.cpp models directory
# Run as: bash llamacpp-models.sh

# 1. Detect llama.cpp path via llama-cli symlink
LLAMACPP_BIN=$(dirname "$(readlink -f "$(which llama-cli)")")
LLAMACPP_DIR=$(dirname "$(dirname "$LLAMACPP_BIN")")

# 2. Download model
MODEL_URL="https://huggingface.co/ggml-org/gemma-4-E4B-it-GGUF/resolve/main/gemma-4-E4B-it-Q4_K_M.gguf"
wget "$MODEL_URL" -O "$LLAMACPP_DIR/models/$(basename "$MODEL_URL")"

echo "Downloaded: $(basename "$MODEL_URL")"
echo "Location: $LLAMACPP_DIR/models/"
ls -lh "$LLAMACPP_DIR/models/$(basename "$MODEL_URL")"