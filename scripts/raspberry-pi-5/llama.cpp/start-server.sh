#!/bin/bash

# Description: Run llama-server on Raspberry Pi 5 with BLIS and optimized threading
# Run as: bash llamacpp-run.sh

# 1. Set CPU governor to performance mode — keeps all cores at max frequency so the
#    first inference request doesn't stall waiting for the CPU to ramp up from idle
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null

# 2. Detect llama.cpp path via llama-cli symlink
LLAMACPP_BIN=$(dirname "$(readlink -f "$(which llama-cli)")")
LLAMACPP_DIR=$(dirname "$(dirname "$LLAMACPP_BIN")")

# 3. Run llama-server
# BLAS/OMP threads set to 1 — llama.cpp owns its threads, suppress nested parallelism
# taskset -c 0-2 — pin process to 3 cores, leave core 3 for OS
# --mlock: pin model pages in RAM, prevents eviction to swap
# --threads-batch: number of threads for prompt processing (prefill)
BLIS_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 \
taskset -c 0-2 \
llama-server \
    -m "$LLAMACPP_DIR/models/gemma-4-E4B-it-Q4_K_M.gguf" \
    --mmproj "$LLAMACPP_DIR/models/mmproj-gemma-4-E4B-it-Q8_0.gguf" \
    --host 0.0.0.0 \
    --port 8080 \
    --ctx-size 16384 \
    --threads 3 \
    --threads-batch "$(nproc)" \
    --mlock \
    --reasoning off