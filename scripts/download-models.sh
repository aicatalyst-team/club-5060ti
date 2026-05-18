#!/usr/bin/env bash
set -euo pipefail

MODEL_DIR="${MODEL_DIR:-$HOME/models}"
export HF_HUB_DISABLE_XET="${HF_HUB_DISABLE_XET:-1}"

usage() {
  cat <<'USAGE'
Usage:
  scripts/download-models.sh <owner> <model> [quant-or-file] [local-dir]
  scripts/download-models.sh <owner/model> [quant-or-file] [local-dir]

Examples:
  scripts/download-models.sh unsloth Qwen3.6-27B-MTP-GGUF Q4_K_XL ~/models/Qwen3.6-27B-MTP-GGUF
  scripts/download-models.sh unsloth/Qwen3.6-27B-MTP-GGUF Qwen3.6-27B-UD-Q4_K_XL.gguf ~/models/Qwen3.6-27B-MTP-GGUF
  scripts/download-models.sh RedHatAI Qwen3.6-35B-A3B-NVFP4 '' ~/models/Qwen3.6-35B-A3B-NVFP4

Compatibility targets:
  qwen36-27b-vllm          sakamakismile/Qwen3.6-27B-Text-NVFP4-MTP
  qwen36-27b-gguf-q6       unsloth Qwen3.6-27B Q6_K_XL GGUF
  qwen36-27b-gguf-q4       unsloth Qwen3.6-27B Q4_K_XL GGUF
  qwen36-27b-gguf-iq4xs    unsloth Qwen3.6-27B IQ4_XS GGUF
  qwen35-9b-mtp-gguf-q4    unsloth Qwen3.5-9B MTP Q4_K_XL GGUF
  qwen36-35b-a3b-vllm      RedHatAI/Qwen3.6-35B-A3B-NVFP4
  qwen36-35b-a3b-gguf      unsloth Qwen3.6-35B-A3B IQ4_XS GGUF
  qwen36-35b-a3b-gguf-iq3xxs
                             unsloth Qwen3.6-35B-A3B IQ3_XXS GGUF

When quant-or-file ends in .gguf, it is treated as an exact file name.
Otherwise it is treated as a GGUF include pattern, for example Q4_K_XL becomes
*Q4_K_XL*.gguf. Leave quant-or-file empty to download the full repository.

Set MODEL_DIR to choose the default download root. HF_HUB_DISABLE_XET defaults
to 1 because large GGUF downloads were more reliable that way on constrained
storage. Hugging Face downloads require either the hf CLI or huggingface-cli to
be installed and logged in when a model requires authentication.
USAGE
}

download_repo() {
  local repo="$1"
  local dir="${2:-}"
  if [[ -n "$dir" ]]; then
    mkdir -p "$dir"
    hf download "$repo" --local-dir "$dir"
  else
    hf download "$repo"
  fi
}

download_file() {
  local repo="$1"
  local file="$2"
  local dir="$3"
  mkdir -p "$dir"
  hf download "$repo" "$file" --local-dir "$dir"
}

download_pattern() {
  local repo="$1"
  local pattern="$2"
  local dir="$3"
  mkdir -p "$dir"
  hf download "$repo" --include "$pattern" --local-dir "$dir"
}

default_dir_for_repo() {
  local repo="$1"
  printf '%s/%s\n' "$MODEL_DIR" "${repo##*/}"
}

download_custom() {
  local repo="$1"
  local selector="${2:-}"
  local dir="${3:-}"
  if [[ -z "$dir" ]]; then
    dir="$(default_dir_for_repo "$repo")"
  fi

  if [[ -z "$selector" ]]; then
    download_repo "$repo" "$dir"
  elif [[ "$selector" == *.gguf ]]; then
    download_file "$repo" "$selector" "$dir"
  else
    download_pattern "$repo" "*${selector}*.gguf" "$dir"
  fi
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
    if [[ "$target" == */* ]]; then
      download_custom "$target" "${2:-}" "${3:-}"
    elif [[ $# -ge 2 ]]; then
      owner="$1"
      model="$2"
      selector="${3:-}"
      dir="${4:-}"
      download_custom "$owner/$model" "$selector" "$dir"
    else
      echo "Unknown target or incomplete model reference: $target" >&2
      usage >&2
      exit 1
    fi
    ;;
esac
