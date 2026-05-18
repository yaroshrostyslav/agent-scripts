#!/bin/bash

# Description: Download GGUF models into llama.cpp models directory
# Run as: bash models.sh

# 1. Detect llama.cpp path via llama-cli symlink
LLAMACPP_BIN=$(dirname "$(readlink -f "$(which llama-cli)")")
LLAMACPP_DIR=$(dirname "$(dirname "$LLAMACPP_BIN")")

# 2. Download model: gemma-4-E4B-it-Q4_K_M (ggml-org)
MODEL_URL="https://huggingface.co/ggml-org/gemma-4-E4B-it-GGUF/resolve/main/gemma-4-E4B-it-Q4_K_M.gguf"
wget "$MODEL_URL" -O "$LLAMACPP_DIR/models/$(basename "$MODEL_URL")"

echo "Downloaded: $(basename "$MODEL_URL")"
echo "Location: $LLAMACPP_DIR/models/"
ls -lh "$LLAMACPP_DIR/models/$(basename "$MODEL_URL")"

# 2.1. Download mmproj: gemma-4-E4B-it-Q8_0 (ggml-org)
MODEL_URL="https://huggingface.co/ggml-org/gemma-4-E4B-it-GGUF/resolve/main/mmproj-gemma-4-E4B-it-Q8_0.gguf"
wget "$MODEL_URL" -O "$LLAMACPP_DIR/models/$(basename "$MODEL_URL")"

echo "Downloaded: $(basename "$MODEL_URL")"
echo "Location: $LLAMACPP_DIR/models/"
ls -lh "$LLAMACPP_DIR/models/$(basename "$MODEL_URL")"

# 3. Download model: gemma-4-E2B-it-Q4_K_L (bartowski)
MODEL_URL="https://huggingface.co/bartowski/google_gemma-4-E2B-it-GGUF/resolve/main/google_gemma-4-E2B-it-Q4_K_L.gguf"
wget "$MODEL_URL" -O "$LLAMACPP_DIR/models/$(basename "$MODEL_URL")"

echo "Downloaded: $(basename "$MODEL_URL")"
echo "Location: $LLAMACPP_DIR/models/"
ls -lh "$LLAMACPP_DIR/models/$(basename "$MODEL_URL")"