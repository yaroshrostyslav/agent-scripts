#!/bin/bash

# Description: Run llama-server on Raspberry Pi 5 with BLIS and optimized threading
# Run as: bash llamacpp-run.sh

# 1. Detect llama.cpp path via llama-cli symlink
LLAMACPP_BIN=$(dirname "$(readlink -f "$(which llama-cli)")")
LLAMACPP_DIR=$(dirname "$(dirname "$LLAMACPP_BIN")")

# 2. Run llama-server
# BLAS/OMP threads set to 1 — llama.cpp owns its threads, suppress nested parallelism
# taskset -c 0-2 — pin process to 3 cores, leave core 3 for OS
# --mlock: pin model pages in RAM, prevents eviction to swap
BLIS_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 \
taskset -c 0-2 \
llama-server \
    -m "$LLAMACPP_DIR/models/gemma-4-E4B-it-Q4_K_M.gguf" \
    --host 0.0.0.0 \
    --port 8080 \
    --ctx-size 8192 \
    --threads 3 \
    --mlock \
    --reasoning off