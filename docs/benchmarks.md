# Benchmarks

Benchmarks here are receipts, not universal claims. Always include the setup details needed to reproduce them.

## 2026-05-19 Protocol-Shaped Seed Run

Fresh seed results are stored as schema-validated JSON under data/results/ and rendered through the hosted explorer at https://5p00kyy.github.io/club-5060ti/. Imported llm-bench rows are archived historical data and should be redone before comparison use.

The explorer defaults to one card per model/setup, with prompt-specific benchmark rows inside each card. Repeated runs are collapsed to the highest-generation row for each prompt while keeping averages and the run count visible. MTP/speculation is shown on each card and can be filtered directly. Use the raw-runs toggle when inspecting repeated measurements.

Seed run files:

- data/results/seed-qwen35-server-20260519.json
- data/results/seed-qwen35-qwen36-server-20260519.json
- data/results/seed-qwen35-qwen36-long-retrieval-20260519.json

Best decode results by model/prompt from the first run:

| Model | Prompt set | Best decode tok/s | Best prompt tok/s | Generated tokens |
| --- | --- | ---: | ---: | ---: |
| Qwen3.5-0.8B | short-chat | 268.65 | 1832.80 | 256 |
| Qwen3.5-0.8B | code-generate | 269.99 | 3095.07 | 768 |
| Qwen3.5-0.8B | agent-tool | 270.52 | 241.08 | 512 |
| Qwen3.5-0.8B | long-retrieval | 194.78 | 26.66 | 17 |
| Qwen3.5-2B | short-chat | 182.50 | 1669.63 | 256 |
| Qwen3.5-2B | code-generate | 178.30 | 2607.75 | 768 |
| Qwen3.5-2B | agent-tool | 177.99 | 212.04 | 512 |
| Qwen3.5-2B | long-retrieval | 145.73 | 26.03 | 17 |
| Qwen3.5-4B | short-chat | 97.73 | 1159.83 | 256 |
| Qwen3.5-4B | code-generate | 94.68 | 1802.11 | 768 |
| Qwen3.5-4B | agent-tool | 94.69 | 126.31 | 512 |
| Qwen3.5-4B | long-retrieval | 77.74 | 21.68 | 17 |
| Qwen3.5-9B | short-chat | 70.99 | 508.23 | 256 |
| Qwen3.5-9B | code-generate | 90.99 | 726.45 | 768 |
| Qwen3.5-9B | agent-tool | 72.74 | 94.87 | 512 |
| Qwen3.5-9B | long-retrieval | 104.45 | 19.62 | 17 |
| Qwen3.6-27B | short-chat | 34.39 | 196.19 | 256 |
| Qwen3.6-27B | code-generate | 37.78 | 288.80 | 768 |
| Qwen3.6-27B | agent-tool | 29.03 | 35.03 | 512 |
| Qwen3.6-27B | long-retrieval | 38.76 | 14.66 | 17 |
| Qwen3.6-35B-A3B-Instruct | short-chat | 92.37 | 625.15 | 256 |
| Qwen3.6-35B-A3B-Instruct | code-generate | 90.11 | 839.47 | 768 |
| Qwen3.6-35B-A3B-Instruct | agent-tool | 90.07 | 104.70 | 512 |
| Qwen3.6-35B-A3B-Instruct | long-retrieval | 74.41 | 22.55 | 17 |

These are OpenAI-compatible server benchmark results from the 2x RTX 5060 Ti seed system using scripts/run_openai_bench.py. Long-retrieval rows use a synthetic filler prompt and short answer budget, so they primarily measure long-prompt handling rather than sustained decode.

## Current Seed Results

Seed hardware is a Dell Precision Tower 7810 with a Dell 0GWHMW board, 2x Intel Xeon E5-2680 v4, 128GB DDR4-2133 host RAM, and 2x RTX 5060 Ti 16GB. Both GPUs are running at PCIe x8 link width. The inference environment is a Proxmox LXC with 16 vCPU and 60GB RAM assigned. PCIe-sensitive comparisons should still include full slot topology and negotiated link generation.

| Date | Hardware | Runtime | Model | Context | Config | Result |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-05-14 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 27B Q4 GGUF | 8K | q8 KV, no MTP | 21.31 tok/s |
| 2026-05-14 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 27B Q4 GGUF | 8K | q8 KV, MTP draft 2 | 34.63 tok/s, acceptance 0.607 |
| 2026-05-14 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 27B Q6 GGUF | 8K | q8 KV, no MTP | 15.61 tok/s |
| 2026-05-14 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 27B Q6 GGUF | 8K | q8 KV, MTP draft 2 | 27.33 tok/s, acceptance 0.628 |
| 2026-05-17 | 2x RTX 5060 Ti 16GB | llama.cpp 9190-b64739ea3 | Qwen3.6 27B MTP Q6 GGUF | 8K | q8 KV, no MTP, fit off | 15.66 tok/s over 384 generated tokens |
| 2026-05-17 | 2x RTX 5060 Ti 16GB | llama.cpp 9190-b64739ea3 | Qwen3.6 27B MTP Q6 GGUF | 8K | q8 KV, draft-mtp n=2, p-min 0.75, fit off | 28.34 tok/s over 384 generated tokens; acceptance 0.704 |
| 2026-05-17 | 2x RTX 5060 Ti 16GB | llama.cpp 9190-b64739ea3 | Qwen3.6 27B MTP Q6 GGUF | 8K | q8 KV, draft-mtp n=3, p-min 0.75, fit off | 30.46 tok/s over 384 generated tokens; acceptance 0.628 |
| 2026-05-17 | 2x RTX 5060 Ti 16GB | llama.cpp 9190-b64739ea3 | Qwen3.6 27B MTP Q6 GGUF | 8K | q8 KV, draft-mtp n=6, p-min 0.75, fit off | 23.64 tok/s over 384 generated tokens; acceptance 0.345 |
| 2026-05-17 | 2x RTX 5060 Ti 16GB | llama.cpp 9190-b64739ea3 | Qwen3.6 27B MTP Q6 GGUF | 65K | q8 KV, draft-mtp n=2, p-min 0.75, fit off | 32.04 tok/s over 64 generated tokens; acceptance 0.889 |
| 2026-05-17 | 2x RTX 5060 Ti 16GB | llama.cpp 9190-b64739ea3 | Qwen3.6 27B MTP Q6 GGUF | 65K | q8 KV, draft-mtp n=3, p-min 0.75, fit off | 37.48 tok/s over 64 generated tokens; acceptance 0.833 |
| 2026-05-17 | 2x RTX 5060 Ti 16GB | llama.cpp 9190-b64739ea3 | Qwen3.6 27B MTP Q6 GGUF | 131K | q8 KV, draft-mtp n=2, p-min 0.75, fit off | 30.02 tok/s over 32 generated tokens; acceptance 0.826 |
| 2026-05-17 | 2x RTX 5060 Ti 16GB | llama.cpp 9190-b64739ea3 | Qwen3.6 27B MTP Q6 GGUF | 200000 | q8 KV, draft-mtp n=3, p-min 0.75, fit off | 87031-token needle retrieval OK; prompt eval 298 tok/s; decode 23.16 tok/s over 26 generated tokens; about 15847/15825 MiB during request |
| 2026-05-17 | 2x RTX 5060 Ti 16GB | llama.cpp 9190-b64739ea3 | Qwen3.6 27B MTP Q6 GGUF | 204800 | q8 KV, draft-mtp n=2, p-min 0.75, fit off | loaded and generated 16 tokens; about 15105/15825 MiB VRAM loaded |
| 2026-05-17 | 2x RTX 5060 Ti 16GB | llama.cpp 9190-b64739ea3 | Qwen3.6 27B MTP Q6 GGUF | 204800 | q8 KV, draft-mtp n=3, p-min 0.75, fit off | 87031-token needle retrieval OK; prompt eval 294 tok/s; decode 24.22 tok/s over 26 generated tokens; about 15847/15825 MiB during request |
| 2026-05-15 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 27B Q6 GGUF | 65K | q8 KV, MTP draft 2 | 24.83 tok/s over 512 generated tokens |
| 2026-05-15 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 27B Q6 GGUF | 204800 | q8 KV, MTP draft 2 | direct server chat OK; tight long-context fit |
| 2026-05-15 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.5 9B MTP Q4 GGUF | 262144 | q8 KV, MTP draft 2 | native max context loaded; 72.50 tok/s over 512 generated tokens |
| 2026-05-15 | 2x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.6 35B A3B IQ4_XS GGUF | 8K | q8 KV, no MTP | 90.45 tok/s over 256 generated tokens |
| 2026-05-16 | 1x RTX 5060 Ti 16GB | llama.cpp MTP 9032-5d5f1b46e | Qwen3.5 9B MTP Q4 GGUF | 262144 | q8 KV, MTP draft 2, GPU-only | 126053-token needle retrieval OK; 1006 tok/s prompt eval, 53.36 tok/s decode over 10 generated tokens |
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

In one local smoke suite, the vLLM NVFP4/MTP setup passed a deterministic no-thinking check at 23/23 across math, logic, code, JSON, instruction following, knowledge, robustness, tool-calling, and long-context retrieval. This is not a general quality evaluation.

Long-context needle retrieval passed at actual prompt token counts around 22,228, 88,685, and 177,317.

## Benchmark Hygiene

When adding results, say whether tokens/sec is decode-only or end-to-end, include generated token count, prompt/context size, runtime version, quant, KV cache dtype, and whether thinking/reasoning was enabled.

## llama.cpp Context Notes

The Q6 llama.cpp MTP route was checked with q8 KV at 65K, 98K, 131K, 160K, 180K, and 200K context. On upstream `9190-b64739ea3`, 200000 and 204800 both passed an 87031-token needle retrieval with `draft-mtp` n=3. The 200000 setting is slightly safer because it leaves about 4800 more context slots; llama.cpp rounded it to an internal `n_ctx_seq` of 200192 in this build. Both are still tight: the long runs used about 15847/15825 MiB during the request. Router setups that use no-mmap or different split/headroom settings may need a lower context such as 65536.

Qwen3.5 9B MTP Q4 is a separate small-model check. It fits the GGUF's native 262144-token max context with q8 KV and MTP draft 2 on both 2x and 1x RTX 5060 Ti 16GB using the stock GGUF metadata. The single-card run also recovered a needle from a 126053-token prompt. Larger extrapolated contexts are deliberately not treated as the public recipe for this model.

Single-card Qwen3.6 27B and 35B A3B GGUF checks work best with lower quants. Qwen3.6 27B IQ4_XS ran GPU-only at 32768 context with q8 KV and at 65536 context with q4 KV; q8 KV failed at 65536, and q4 KV failed at 98304 and 110080 on the seed card. Qwen3.6 35B A3B IQ3_XXS was the stronger long-context single-card fit: it loaded native 262144 context with q8 KV and recovered a needle from a 93636-token prompt. Larger quants are fallback/partial-offload territory: GPU-only/no-unified-memory tests failed at 4096 context for Qwen3.6 27B Q4_K_M, Qwen3.6 27B MTP Q4_XL, and Qwen3.6 35B A3B IQ4_XS.
