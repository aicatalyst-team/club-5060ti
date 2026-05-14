#!/usr/bin/env bash
set -euo pipefail

: "${MODEL:=RedHatAI/Qwen3.6-35B-A3B-NVFP4}"
: "${SERVED_MODEL_NAME:=qwen36-35b-a3b-nvfp4-mtp}"
: "${PORT:=8000}"
: "${MAX_MODEL_LEN:=32768}"
: "${GPU_MEMORY_UTILIZATION:=0.90}"
: "${MAX_NUM_BATCHED_TOKENS:=8192}"
: "${MAX_NUM_SEQS:=1}"

docker run --rm --gpus all --ipc=host --network host --shm-size=16g \
  -v "$HOME/.cache/huggingface:/root/.cache/huggingface" \
  vllm/vllm-openai:cu130-nightly \
  --model "$MODEL" \
  --served-model-name "$SERVED_MODEL_NAME" \
  --host 0.0.0.0 \
  --port "$PORT" \
  --moe-backend flashinfer_cutlass \
  --tensor-parallel-size 2 \
  --max-model-len "$MAX_MODEL_LEN" \
  --gpu-memory-utilization "$GPU_MEMORY_UTILIZATION" \
  --kv-cache-dtype fp8 \
  --enable-prefix-caching \
  --max-num-batched-tokens "$MAX_NUM_BATCHED_TOKENS" \
  --max-num-seqs "$MAX_NUM_SEQS" \
  --speculative-config '{"method":"mtp","num_speculative_tokens":3}' \
  --reasoning-parser qwen3 \
  --language-model-only \
  --generation-config vllm \
  --disable-custom-all-reduce \
  --attention-backend TRITON_ATTN \
  --default-chat-template-kwargs '{"enable_thinking":true}' \
  --tool-call-parser qwen3_coder \
  --enable-auto-tool-choice \
  --trust-remote-code
