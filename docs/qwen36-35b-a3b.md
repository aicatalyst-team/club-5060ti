# Qwen3.6 35B A3B Checks

The 35B A3B model is included as an additional dual-5060 Ti reference point.
It is not the main documented serving recipe yet.

## llama.cpp GGUF

Small-context text smoke test:

| Field | Value |
| --- | --- |
| Runtime | llama.cpp MTP build 9032-5d5f1b46e |
| Model | unsloth/Qwen3.6-35B-A3B-GGUF |
| File | Qwen3.6-35B-A3B-UD-IQ4_XS.gguf |
| Context | 8192 |
| KV cache | q8_0 / q8_0 |
| GPU split | 1,1 |
| Result | 90.45 tok/s over 256 generated tokens |

See examples/llamacpp-qwen36-35b-a3b.ini for the sanitized preset.

## vLLM NVFP4/MTP

The vLLM path uses RedHatAI/Qwen3.6-35B-A3B-NVFP4 with tensor parallel across both cards, fp8 KV cache, FlashInfer MoE, and MTP speculative decoding.

The public example uses 32768 context as a conservative starting point. Larger-context startup checks need fresh speed rows before they belong in the benchmark table.

Observed startup checks include 32768 and 131072 context reaching the OpenAI-compatible model list endpoint. The current benchmark table only includes this as a fit/startup receipt, not a speed claim.

See examples/vllm-qwen36-35b-a3b-nvfp4.sh for the sanitized launch command.
