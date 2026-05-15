#!/usr/bin/env bash
set -euo pipefail

# Build the pinned MTP-capable llama.cpp tree used for the Qwen3.6 GGUF
# examples. PR 22673 is moving quickly; newer tips may change speculative
# flag spelling/defaults, so benchmark reports should include the exact ref.
#
# Defaults:
#   LLAMA_CPP_DIR=$HOME/llama.cpp-mtp
#   LLAMA_CPP_REPO=https://github.com/ggml-org/llama.cpp.git
#   LLAMA_CPP_PR=22673
#   LLAMA_CPP_REF=5d5f1b46e4f56885801c86363d4677a5f72f83af
#
# Use --fresh to move the existing source tree aside before cloning again.

LLAMA_CPP_DIR="${LLAMA_CPP_DIR:-$HOME/llama.cpp-mtp}"
LLAMA_CPP_REPO="${LLAMA_CPP_REPO:-https://github.com/ggml-org/llama.cpp.git}"
LLAMA_CPP_PR="${LLAMA_CPP_PR:-22673}"
LLAMA_CPP_REF="${LLAMA_CPP_REF:-5d5f1b46e4f56885801c86363d4677a5f72f83af}"
INSTALL_PREFIX="${INSTALL_PREFIX:-}"
JOBS="${JOBS:-12}"
CUDA_ARCHITECTURES="${CUDA_ARCHITECTURES:-120a}"
FRESH=0

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

usage() {
  cat <<'USAGE'
Usage: scripts/update-llama.sh [--fresh] [--ref <git-ref>] [--dir <path>] [--install-prefix <path>]

Builds the MTP-capable llama.cpp PR/commit used by the repo examples.

Environment overrides:
  LLAMA_CPP_DIR           source/build directory, default ~/llama.cpp-mtp
  LLAMA_CPP_REPO          llama.cpp remote, default ggml-org/llama.cpp
  LLAMA_CPP_PR            PR ref to fetch, default 22673
  LLAMA_CPP_REF           commit/ref to checkout, default tested commit 5d5f1b46...
  CUDA_ARCHITECTURES      default 120a for RTX 5060 Ti / Blackwell
  JOBS                    default 12
  INSTALL_PREFIX          optional symlink target for built binaries
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --fresh)
      FRESH=1
      shift
      ;;
    --ref)
      LLAMA_CPP_REF="$2"
      shift 2
      ;;
    --dir)
      LLAMA_CPP_DIR="$2"
      shift 2
      ;;
    --install-prefix)
      INSTALL_PREFIX="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

need git
need cmake

if [[ "$FRESH" -eq 1 && -d "$LLAMA_CPP_DIR" ]]; then
  trash_parent="${LLAMA_CPP_DIR%/*}/.trash"
  mkdir -p "$trash_parent"
  mv "$LLAMA_CPP_DIR" "$trash_parent/llama.cpp.$(date +%Y%m%d-%H%M%S)"
fi

if [[ ! -d "$LLAMA_CPP_DIR/.git" ]]; then
  git clone "$LLAMA_CPP_REPO" "$LLAMA_CPP_DIR"
else
  git -C "$LLAMA_CPP_DIR" remote set-url origin "$LLAMA_CPP_REPO"
fi

git -C "$LLAMA_CPP_DIR" fetch --tags origin main
git -C "$LLAMA_CPP_DIR" fetch origin "pull/$LLAMA_CPP_PR/head:pr-$LLAMA_CPP_PR" || true
git -C "$LLAMA_CPP_DIR" checkout --detach "$LLAMA_CPP_REF"

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

if [[ -n "$INSTALL_PREFIX" ]]; then
  mkdir -p "$INSTALL_PREFIX"
  ln -sf "$LLAMA_CPP_DIR/build/bin/llama-server" "$INSTALL_PREFIX/llama-server"
  ln -sf "$LLAMA_CPP_DIR/build/bin/llama-bench" "$INSTALL_PREFIX/llama-bench"
  ln -sf "$LLAMA_CPP_DIR/build/bin/llama-fit-params" "$INSTALL_PREFIX/llama-fit-params"
fi

"$LLAMA_CPP_DIR/build/bin/llama-server" --version 2>&1 | head -1
"$LLAMA_CPP_DIR/build/bin/llama-bench" --version 2>&1 | head -1
"$LLAMA_CPP_DIR/build/bin/llama-fit-params" --version 2>&1 | head -1
