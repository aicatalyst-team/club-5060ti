#!/usr/bin/env bash
set -euo pipefail

# Sanitized example for 2x RTX 5060 Ti 16GB.
# Requires a working NVIDIA container runtime and Hugging Face access if the
# model is not already cached.

PORT="${PORT:-8000}"
HF_HOME="${HF_HOME:-$HOME/.cache/huggingface}"
MODEL="${MODEL:-sakamakismile/Qwen3.6-27B-Text-NVFP4-MTP}"
SERVED_MODEL="${SERVED_MODEL:-qwen36-27b-nvfp4-mtp}"

docker run --rm --gpus all --ipc=host \
  -p "${PORT}:8000" \
  -v "${HF_HOME}:/root/.cache/huggingface" \
  vllm/vllm-openai:cu130-nightly \
  --model "${MODEL}" \
  --served-model-name "${SERVED_MODEL}" \
  --quantization modelopt \
  --tensor-parallel-size 2 \
  --max-model-len 200000 \
  --max-num-batched-tokens 8192 \
  --max-num-seqs 1 \
  --gpu-memory-utilization 0.95 \
  --kv-cache-dtype fp8 \
  --speculative-config '{"method":"mtp","num_speculative_tokens":3}' \
  --reasoning-parser qwen3 \
  --language-model-only \
  --generation-config vllm \
  --disable-custom-all-reduce \
  --attention-backend TRITON_ATTN \
  --default-chat-template-kwargs '{"enable_thinking":true}' \
  --enable-prefix-caching

