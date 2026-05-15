# Benchmarks

Benchmarks here are receipts, not universal claims. Always include the setup details needed to reproduce them.

## Current Seed Results

Seed hardware is a Dell Precision Tower 7810 with a Dell 0GWHMW board, 2x Intel Xeon E5-2680 v4, 128GB DDR4-2133 host RAM, and 2x RTX 5060 Ti 16GB. Both GPUs are running at PCIe x8 link width. The inference environment is a Proxmox LXC with 16 vCPU and 60GB RAM assigned. PCIe-sensitive comparisons should still include full slot topology and negotiated link generation.

| Date | Hardware | Runtime | Model | Context | Config | Result |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-05-14 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 27B Q4 GGUF | 8K | q8 KV, no MTP | 21.31 tok/s |
| 2026-05-14 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 27B Q4 GGUF | 8K | q8 KV, MTP draft 2 | 34.63 tok/s, acceptance 0.607 |
| 2026-05-14 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 27B Q6 GGUF | 8K | q8 KV, no MTP | 15.61 tok/s |
| 2026-05-14 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 27B Q6 GGUF | 8K | q8 KV, MTP draft 2 | 27.33 tok/s, acceptance 0.628 |
| 2026-05-15 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 27B Q6 GGUF | 65K | q8 KV, MTP draft 2 | 24.83 tok/s over 512 generated tokens |
| 2026-05-15 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 27B Q6 GGUF | 204800 | q8 KV, MTP draft 2 | direct server chat OK; tight long-context fit |
| 2026-05-15 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.5 9B MTP Q4 GGUF | 262144 | q8 KV, MTP draft 2 | native max context loaded; 72.50 tok/s over 512 generated tokens |
| 2026-05-15 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 35B A3B IQ4_XS GGUF | 8K | q8 KV, no MTP | 90.45 tok/s over 256 generated tokens |
| 2026-05-16 | 1x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 27B IQ4_XS GGUF | 32K | q8 KV, GPU-only | 24.65 tok/s over 64 generated tokens |
| 2026-05-16 | 1x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 27B IQ4_XS GGUF | 65K | q4 KV, GPU-only | 24.56 tok/s over 64 generated tokens |
| 2026-05-16 | 1x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 35B A3B IQ3_XXS GGUF | 32K | q8 KV, GPU-only | 89.06 tok/s over 64 generated tokens |
| 2026-05-16 | 1x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 35B A3B IQ3_XXS GGUF | 131K | q8 KV, GPU-only | 93.04 tok/s over 64 generated tokens |
| 2026-05-16 | 1x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 35B A3B IQ3_XXS GGUF | 204800 | q8 KV, GPU-only | 92.83 tok/s over 64 generated tokens |
| 2026-05-16 | 1x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 35B A3B IQ3_XXS GGUF | 262144 | q8 KV, GPU-only | 93636-token needle retrieval OK; 938 tok/s prompt eval, 46.48 tok/s decode over 16 generated tokens |
| 2026-05-15 | 1x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 27B Q4_K_M GGUF | 4K | q8 KV, partial CPU offload, n-gpu-layers 60 | 12.36 tok/s over 64 generated tokens |
| 2026-05-15 | 1x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 35B A3B IQ4_XS GGUF | 4K | q8 KV, partial CPU offload, n-gpu-layers 32 | 17.08 tok/s over 64 generated tokens |
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

Qwen3.5 9B MTP Q4 is a separate small-model check. It fits the GGUF's native 262144-token max context with q8 KV and MTP draft 2 without RoPE scaling or metadata overrides. Larger extrapolated contexts are deliberately not treated as the public recipe for this model.

Single-card Qwen3.6 27B and 35B A3B GGUF checks work best with lower quants. Qwen3.6 27B IQ4_XS ran GPU-only at 32768 context with q8 KV and at 65536 context with q4 KV; q8 KV failed at 65536, and q4 KV failed at 98304 and 110080 on the seed card. Qwen3.6 35B A3B IQ3_XXS was the stronger long-context single-card fit: it loaded native 262144 context with q8 KV and recovered a needle from a 93636-token prompt. Larger quants are fallback/partial-offload territory: GPU-only/no-unified-memory tests failed at 4096 context for Qwen3.6 27B Q4_K_M, Qwen3.6 27B MTP Q4_XL, and Qwen3.6 35B A3B IQ4_XS.
