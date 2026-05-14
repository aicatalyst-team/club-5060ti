# Benchmarks

Benchmarks here are receipts, not universal claims. Always include the setup details needed to reproduce them.

## Current Seed Results

| Date | Hardware | Runtime | Model | Context | Config | Result |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-05-14 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 27B Q4 GGUF | 8K | q8 KV, no MTP | 21.31 tok/s |
| 2026-05-14 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 27B Q4 GGUF | 8K | q8 KV, MTP draft 2 | 34.63 tok/s, acceptance 0.607 |
| 2026-05-14 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 27B Q6 GGUF | 8K | q8 KV, no MTP | 15.61 tok/s |
| 2026-05-14 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 27B Q6 GGUF | 8K | q8 KV, MTP draft 2 | 27.33 tok/s, acceptance 0.628 |
| 2026-05-15 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 27B Q6 GGUF | 65K | q8 KV, MTP draft 2 | 24.83 tok/s over 512 generated tokens |
| 2026-05-15 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 27B Q6 GGUF | 204800 | q8 KV, MTP draft 2 | direct server chat OK; tight long-context fit |
| 2026-05-15 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 35B A3B IQ4_XS GGUF | 8K | q8 KV, no MTP | 90.45 tok/s over 256 generated tokens |
| 2026-05-14 | 2x RTX 5060 Ti 16GB | vLLM | Qwen3.6 27B NVFP4/MTP | 8K | fp8 KV, MTP n=3 | about 62-66 tok/s decode |
| 2026-05-14 | 2x RTX 5060 Ti 16GB | vLLM | Qwen3.6 27B NVFP4/MTP | 200K | fp8 KV, prefix caching, MTP n=3 | reached health and passed long-context retrieval checks |
| 2026-05-04 | 2x RTX 5060 Ti 16GB | vLLM | Qwen3.6 35B A3B NVFP4/MTP | 131K | fp8 KV, MTP n=3, FlashInfer MoE | startup OK; /v1/models OK |

## Quality Smoke

The vLLM NVFP4/MTP setup passed a deterministic no-thinking suite at 23/23 across math, logic, code, JSON, instruction following, knowledge, robustness, tool-calling, and long-context retrieval.

Long-context needle retrieval passed at actual prompt token counts around 22,228, 88,685, and 177,317.

## Benchmark Hygiene

When adding results, say whether tokens/sec is decode-only or end-to-end, include generated token count, prompt/context size, runtime version, quant, KV cache dtype, and whether thinking/reasoning was enabled.

## llama.cpp Context Notes

The Q6 llama.cpp MTP route was checked with q8 KV at 65K, 98K, 131K, 160K, 180K, and 200K context. The 204800 preset is useful as a long-context recipe, but it is tight. Router setups that use no-mmap or different split/headroom settings may need a lower context such as 65536.
