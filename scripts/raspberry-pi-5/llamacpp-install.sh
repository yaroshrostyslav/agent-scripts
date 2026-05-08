#!/bin/bash

# Description: Install llama.cpp with BLIS on Raspberry Pi 5
# Run as: bash llamacpp-install.sh

set -euo pipefail

# 1. Dependencies
sudo apt update && sudo apt install -y build-essential git cmake pkg-config libcurl4-openssl-dev

# 2. Build BLIS (BLIS outperforms OpenBLAS on Pi 5)
git clone https://github.com/flame/blis
(
  cd blis
  CFLAGS="-O3 -mcpu=cortex-a76" ./configure --enable-cblas -t openmp,pthreads auto
  make -j
  sudo make install  # installs into /usr/local/ by default
)

# 3. Clone and build llama.cpp
git clone https://github.com/ggml-org/llama.cpp
(
  cd llama.cpp
  # GGML_BLAS=ON: enables BLAS acceleration
  # GGML_BLAS_VENDOR=FLAME: use BLIS installed above
  # GGML_NATIVE=ON: -march=native, auto-enables dotprod and fp16 on A76
  # GGML_LTO=ON: link-time optimization, enables inlining across translation units
  cmake -B build \
    -DGGML_BLAS=ON \
    -DGGML_BLAS_VENDOR=FLAME \
    -DCMAKE_BUILD_TYPE=Release \
    -DGGML_NATIVE=ON \
    -DGGML_LTO=ON
  cmake --build build --config Release -j"$(nproc)"
)

# 4. Install binaries globally
sudo ln -sf "$(pwd)/llama.cpp/build/bin/llama-server" /usr/local/bin/llama-server
sudo ln -sf "$(pwd)/llama.cpp/build/bin/llama-cli" /usr/local/bin/llama-cli

# 5. Validate
llama-cli --version