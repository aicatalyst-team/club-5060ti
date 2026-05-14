#!/usr/bin/env bash
set -euo pipefail

# Build llama.cpp with CUDA settings used for RTX 5060 Ti / Blackwell testing.
#
# Defaults:
#   LLAMA_CPP_DIR=$HOME/llama.cpp
#   PREFIX=/usr/local/bin
#
# Use --fresh to move the existing source tree aside before cloning again.

LLAMA_CPP_DIR="${LLAMA_CPP_DIR:-$HOME/llama.cpp}"
PREFIX="${PREFIX:-/usr/local/bin}"
JOBS="${JOBS:-12}"
CUDA_ARCHITECTURES="${CUDA_ARCHITECTURES:-120a}"
FRESH=0

if [[ "${1:-}" == "--fresh" ]]; then
  FRESH=1
fi

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

need git
need cmake

if [[ "$FRESH" -eq 1 && -d "$LLAMA_CPP_DIR" ]]; then
  trash_parent="${LLAMA_CPP_DIR%/*}/.trash"
  mkdir -p "$trash_parent"
  mv "$LLAMA_CPP_DIR" "$trash_parent/llama.cpp.$(date +%Y%m%d-%H%M%S)"
fi

if [[ ! -d "$LLAMA_CPP_DIR/.git" ]]; then
  git clone https://github.com/ggml-org/llama.cpp.git "$LLAMA_CPP_DIR"
else
  git -C "$LLAMA_CPP_DIR" pull --ff-only
fi

cmake -S "$LLAMA_CPP_DIR" -B "$LLAMA_CPP_DIR/build" \
  -DGGML_CUDA=ON \
  -DGGML_CUDA_FA_ALL_QUANTS=ON \
  -DGGML_CUDA_GRAPHS=ON \
  -DGGML_CUDA_FORCE_MMQ=ON \
  -DGGML_CUDA_PEER_MAX_BATCH_SIZE=512 \
  -DGGML_NATIVE=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLAMA_CURL=OFF \
  -DCMAKE_CUDA_ARCHITECTURES="$CUDA_ARCHITECTURES"

cmake --build "$LLAMA_CPP_DIR/build" --config Release --clean-first -j "$JOBS" \
  --target llama-server \
  --target llama-bench \
  --target llama-fit-params

mkdir -p "$PREFIX"
ln -sf "$LLAMA_CPP_DIR/build/bin/llama-server" "$PREFIX/llama-server"
ln -sf "$LLAMA_CPP_DIR/build/bin/llama-bench" "$PREFIX/llama-bench"
ln -sf "$LLAMA_CPP_DIR/build/bin/llama-fit-params" "$PREFIX/llama-fit-params"

"$PREFIX/llama-server" --version 2>&1 | head -1
"$PREFIX/llama-bench" --version 2>&1 | head -1
"$PREFIX/llama-fit-params" --version 2>&1 | head -1
