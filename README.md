# club-5060ti

Practical local LLM recipes, benchmark receipts, and setup notes for RTX 5060 Ti 16GB systems.

The project focus is simple: make low-VRAM Blackwell local inference less guessy. Every useful result should come with the launch shape, hardware context, model details, benchmark method, and caveats needed for someone else to reproduce or improve it.

## Start Here

| Path | Use this when | Entry point |
| --- | --- | --- |
| 1x RTX 5060 Ti | You want the best single-card fits and conservative starter configs. | docs/single-5060ti.md |
| 2x RTX 5060 Ti | You want dual-16GB recipes for 27B-class and long-context models. | docs/llamacpp-qwen36.md |
| Results explorer | You want to compare benchmark receipts and imported legacy data. | https://5p00kyy.github.io/club-5060ti/ |
| Benchmark protocol | You want to submit or compare a result without mixing methods. | docs/benchmark-protocol.md |

## Current Direction

club-5060ti is the canonical source of truth for tested RTX 5060 Ti recipes and benchmark receipts. The results explorer is built from checked-in JSON under data/results/ so docs, scripts, and the static site all describe the same evidence.

Imported llm-bench rows are marked as deprecated migration data until they are rerun under the benchmark protocol. They are useful history, not headline evidence.

## Tested Baseline

Seed hardware:

- GPUs: 2x NVIDIA GeForce RTX 5060 Ti 16GB
- Driver: 595.58.03
- Total VRAM: 32GB across two cards
- System: Dell Precision Tower 7810, Dell 0GWHMW board
- CPU: 2x Intel Xeon E5-2680 v4
- Host memory: 128GB DDR4-2133
- Inference environment: Proxmox LXC with 16 vCPU and 60GB RAM assigned
- PCIe link width: both RTX 5060 Ti cards run at x8 in this host

See docs/hardware.md for the full baseline and hardware notes.

## Recipe Status

| Lane | Model | Status | Notes |
| --- | --- | --- | --- |
| upstream llama.cpp | Qwen3.6 27B MTP GGUF | Working baseline | Current recipe uses Q4_K_XL, q8 KV, tensor split, and draft-MTP. |
| upstream llama.cpp | Qwen3.5 9B MTP GGUF | Working baseline | Small long-context route; useful sanity lane for 1x and 2x cards. |
| upstream llama.cpp | Qwen3.6 35B A3B GGUF | Working recipe | Strong MoE/active-parameter comparison route. |
| ik_llama.cpp | Qwen3.6 27B IQ4/IQ5 | Planned | Needs controlled testing on CUDA and graph split. |
| BeeLlama | Qwen3.6 27B DFlash/TurboQuant | Planned | Test after current release work; only compare with equal target/KV/context settings. |
| vLLM | Qwen3.6 27B NVFP4/MTP | Working historical lane | Needs fresh protocol-shaped results. |
| vLLM | BNB4/AutoRound routes | Experimental | Do not promote CPU-offload health checks as useful recipes. |

## Results And Data

Canonical result files live under data/results/ and follow data/schema/benchmark-result.schema.json.

Build the static site data:

~~~bash
python3 scripts/build_site_data.py
~~~

Validate result JSON:

~~~bash
python3 scripts/validate_results.py data/results
~~~

Run a protocol-shaped OpenAI-compatible benchmark:

~~~bash
python3 scripts/run_openai_bench.py \
  --base-url http://127.0.0.1:8080/v1 \
  --model Qwen3.6-27B \
  --prompt-set short-chat \
  --prompt-set code-generate \
  --prompt-set agent-tool \
  --runs 1 \
  --no-thinking \
  --output data/results/my-run.json
~~~

The old llm-bench summary rows have been imported into data/results/llm-bench-legacy-import.json as deprecated data. They are useful migration material, not new headline evidence.

## Repo Map

- docs/benchmark-protocol.md - comparable-result rules, prompt sets, context tiers, and promotion levels
- docs/FAQ.md - short answers to common setup questions
- docs/community-goals.md - project goals and contribution priorities
- docs/client-examples.md - OpenAI-compatible client examples
- docs/reporting-results.md - how to capture a useful result report
- docs/single-5060ti.md - conservative single-card starter configs
- docs/vllm-qwen36.md - vLLM NVFP4/MTP notes
- docs/llamacpp-qwen36.md - llama.cpp Qwen3.6 27B MTP GGUF route
- docs/llamacpp-qwen35-9b-mtp.md - Qwen3.5 9B native max-context route
- docs/qwen36-35b-a3b.md - Qwen3.6 35B A3B checks
- docs/benchmarks.md - current human-readable result notes
- docs/troubleshooting.md - observed failures and fixes
- data/ - canonical result data and schemas
- examples/ - sanitized launch/config snippets
- scripts/ - validation, report, smoke, import, and benchmark helpers
- site/ - static results explorer generated from data/

## Model Downloads

The public download helper wraps the Hugging Face CLI for model files used by the examples:

~~~bash
scripts/download-models.sh qwen36-27b-vllm
scripts/download-models.sh qwen36-27b-gguf-q6
scripts/download-models.sh qwen36-27b-gguf-iq4xs
scripts/download-models.sh qwen35-9b-mtp-gguf-q4
scripts/download-models.sh qwen36-35b-a3b-vllm
scripts/download-models.sh qwen36-35b-a3b-gguf
scripts/download-models.sh qwen36-35b-a3b-gguf-iq3xxs
~~~

Set MODEL_DIR for GGUF downloads if you do not want to use ~/models. For large GGUF files on constrained storage, HF_HUB_DISABLE_XET=1 is the safer default used by the helper.

## llama.cpp Build Helper

~~~bash
scripts/update-llama.sh
~~~

This builds the upstream llama.cpp tree used by the Qwen3.6 GGUF examples. The helper is a reproducible public build path, not a service manager for a specific deployment.

## Contribution Standard

Contributions are most useful when they include exact GPU model, motherboard/PCIe layout, negotiated link width/generation, driver/runtime versions, launch commands, context length, KV cache settings, prompt shape, generated token count, tokens/sec, and relevant caveats.

Start with CONTRIBUTING.md and docs/benchmark-protocol.md.

## Verification

~~~bash
python3 -m py_compile scripts/*.py
bash -n scripts/*.sh examples/*.sh
python3 scripts/validate_results.py data/results
python3 scripts/build_site_data.py
./scripts/check_repo.sh
~~~
