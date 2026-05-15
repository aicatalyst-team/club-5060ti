#!/usr/bin/env bash
set -euo pipefail

MODEL_DIR="${MODEL_DIR:-$HOME/models}"
export HF_HUB_DISABLE_XET="${HF_HUB_DISABLE_XET:-1}"

usage() {
  cat <<'USAGE'
Usage: scripts/download-models.sh <target>

Targets:
  qwen36-27b-vllm          sakamakismile/Qwen3.6-27B-Text-NVFP4-MTP
  qwen36-27b-gguf-q6       unsloth Qwen3.6-27B Q6_K_XL GGUF
  qwen36-27b-gguf-q4       unsloth Qwen3.6-27B Q4_K_XL GGUF
  qwen36-27b-gguf-iq4xs    unsloth Qwen3.6-27B IQ4_XS GGUF
  qwen35-9b-mtp-gguf-q4    unsloth Qwen3.5-9B MTP Q4_K_XL GGUF
  qwen36-35b-a3b-vllm      RedHatAI/Qwen3.6-35B-A3B-NVFP4
  qwen36-35b-a3b-gguf      unsloth Qwen3.6-35B-A3B IQ4_XS GGUF
  qwen36-35b-a3b-gguf-iq3xxs
                             unsloth Qwen3.6-35B-A3B IQ3_XXS GGUF

Set MODEL_DIR to choose the GGUF download root. HF_HUB_DISABLE_XET defaults
to 1 because large GGUF downloads were more reliable that way on the tested
LXC storage path. Hugging Face downloads require either the hf CLI or
huggingface-cli to be installed and logged in when a model requires
authentication.
USAGE
}

download_repo() {
  local repo="$1"
  hf download "$repo"
}

download_file() {
  local repo="$1"
  local file="$2"
  local dir="$3"
  mkdir -p "$dir"
  hf download "$repo" "$file" --local-dir "$dir"
}

if ! command -v hf >/dev/null 2>&1; then
  if command -v huggingface-cli >/dev/null 2>&1; then
    hf() { huggingface-cli "$@"; }
  else
    echo "Missing Hugging Face CLI. Install with: pip install -U huggingface_hub" >&2
    exit 1
  fi
fi

target="${1:-}"
case "$target" in
  qwen36-27b-vllm)
    download_repo "sakamakismile/Qwen3.6-27B-Text-NVFP4-MTP"
    ;;
  qwen36-27b-gguf-q6)
    download_file "unsloth/Qwen3.6-27B-MTP-GGUF" "Qwen3.6-27B-UD-Q6_K_XL.gguf" "$MODEL_DIR/Qwen3.6-27B-MTP-GGUF"
    ;;
  qwen36-27b-gguf-q4)
    download_file "unsloth/Qwen3.6-27B-MTP-GGUF" "Qwen3.6-27B-UD-Q4_K_XL.gguf" "$MODEL_DIR/Qwen3.6-27B-MTP-GGUF"
    ;;
  qwen36-27b-gguf-iq4xs)
    download_file "unsloth/Qwen3.6-27B-GGUF" "Qwen3.6-27B-IQ4_XS.gguf" "$MODEL_DIR/Qwen3.6-27B-GGUF"
    ;;
  qwen35-9b-mtp-gguf-q4)
    download_file "unsloth/Qwen3.5-9B-MTP-GGUF" "Qwen3.5-9B-UD-Q4_K_XL.gguf" "$MODEL_DIR/Qwen3.5-9B-MTP-GGUF"
    ;;
  qwen36-35b-a3b-vllm)
    download_repo "RedHatAI/Qwen3.6-35B-A3B-NVFP4"
    ;;
  qwen36-35b-a3b-gguf)
    download_file "unsloth/Qwen3.6-35B-A3B-GGUF" "Qwen3.6-35B-A3B-UD-IQ4_XS.gguf" "$MODEL_DIR/Qwen3.6-35B-A3B-GGUF"
    ;;
  qwen36-35b-a3b-gguf-iq3xxs)
    download_file "unsloth/Qwen3.6-35B-A3B-GGUF" "Qwen3.6-35B-A3B-UD-IQ3_XXS.gguf" "$MODEL_DIR/Qwen3.6-35B-A3B-GGUF"
    ;;
  -h|--help|"")
    usage
    ;;
  *)
    echo "Unknown target: $target" >&2
    usage >&2
    exit 1
    ;;
esac
