# vLLM: Qwen3.6 27B NVFP4/MTP

This is the primary tested path so far for dual RTX 5060 Ti 16GB serving.

## Model

- Model: sakamakismile/Qwen3.6-27B-Text-NVFP4-MTP
- Served name used in testing: qwen36-27b-nvfp4-mtp
- Runtime image used in testing: vllm/vllm-openai:cu130-nightly
- vLLM build observed in testing: 0.19.2rc1.dev134+gfe9c3d6c5
- Torch/CUDA observed in testing: Torch 2.11.0+cu130, CUDA 13.0

## Core Flags

~~~bash
python3 -m vllm.entrypoints.openai.api_server \
  --model sakamakismile/Qwen3.6-27B-Text-NVFP4-MTP \
  --served-model-name qwen36-27b-nvfp4-mtp \
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
~~~

See examples/vllm-qwen36-nvfp4.sh for a sanitized Docker example.

## Observed Results

On 2x RTX 5060 Ti 16GB:

| Config | Result |
| --- | --- |
| 8K context, MTP n=1 | about 50-52 tok/s decode |
| 8K context, MTP n=3 | about 62-66 tok/s decode |
| 32K context, fp8 KV, MTP n=3 | about 59-66 tok/s decode |
| 200K context, fp8 KV, prefix caching on, MTP n=3 | reached health and reported max_model_len 200000 |

The long-context validation also passed needle retrieval at actual prompt token counts around 22K, 88K, and 177K.

## Caveats

- First boot can take several minutes because of compile/autotune work.
- Startup may show OOM fallback warnings during autotuning; that does not always mean the server has failed.
- Use fp8 KV cache, not fp8_e5m2, for this checkpoint.
- TRITON_ATTN was the stable attention backend in testing.
- Keep max-num-seqs at 1 for this constrained dual-16GB setup.
- Thinking mode can consume the entire output budget. Use a large enough max_tokens if you expect final content.
- For coding agents, test streaming and tool calls separately from basic chat completion.
