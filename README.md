# club-5060ti

Practical local LLM recipes for RTX 5060 Ti 16GB cards.

This repo collects tested RTX 5060 Ti local LLM configurations with the commands, benchmark context, and reporting templates needed to reproduce and compare results.

The first documented setup is a dual RTX 5060 Ti 16GB machine running Qwen3.6 27B through two working paths:

- vLLM with Blackwell-friendly NVFP4/MTP on 2x16GB
- llama.cpp MTP GGUF on 2x16GB

## Current Recipes

| Runtime | Model | Status | Notes |
| --- | --- | --- | --- |
| vLLM | sakamakismile/Qwen3.6-27B-Text-NVFP4-MTP | Working | Primary dual-card serving path. |
| llama.cpp MTP branch | unsloth/Qwen3.6-27B-MTP-GGUF Q4/Q6 | Working | GGUF path with Q4/Q6 speed notes, a stable router preset, and Q6 long-context fit checks. Requires an MTP-capable llama.cpp build. |
| llama.cpp MTP branch | unsloth/Qwen3.5-9B-MTP-GGUF Q4 | Early checks | Small-model GGUF path that fits the native 262144-token max context with q8 KV, without RoPE scaling or metadata override. |
| llama.cpp | Qwen3.6 27B IQ4_XS / 35B A3B IQ3_XXS | Single-card checks | One RTX 5060 Ti 16GB can run these lower GGUF quants GPU-only; 35B A3B IQ3_XXS also passed a native-262144 fit and 93636-token retrieval check. |
| llama.cpp / vLLM | Qwen3.6 35B A3B | Early checks | Small-context GGUF smoke result and vLLM NVFP4/MTP launch example. |

## Tested Baseline

- GPUs: 2x NVIDIA GeForce RTX 5060 Ti 16GB
- Driver: 595.58.03
- Total VRAM: 32GB across two cards
- System: Dell Precision Tower 7810, Dell 0GWHMW board
- CPU: 2x Intel Xeon E5-2680 v4
- Host memory: 128GB DDR4-2133
- Inference environment: Proxmox LXC with 16 vCPU and 60GB RAM assigned
- PCIe link width: both RTX 5060 Ti cards are running at x8 in this host
- Useful assumption: tensor parallel across both cards for 27B-class models

See docs/hardware.md for the full baseline and hardware notes.

## Repo Map

- docs/FAQ.md - short answers to the questions people ask first
- docs/community-goals.md - project goals and contribution priorities
- docs/client-examples.md - connecting OpenAI-compatible clients
- docs/reporting-results.md - how to capture a useful result report
- docs/single-5060ti.md - conservative single-card starter configs
- docs/vllm-qwen36.md - working vLLM NVFP4/MTP recipe
- docs/llamacpp-qwen36.md - working llama.cpp MTP GGUF recipe
- docs/llamacpp-qwen35-9b-mtp.md - Qwen3.5 9B GGUF native max-context fit check
- docs/qwen36-35b-a3b.md - additional Qwen3.6 35B A3B checks
- docs/benchmarks.md - benchmark notes and current result table
- docs/troubleshooting.md - problems seen during testing
- examples/ - sanitized config snippets
- scripts/ - small reproducible health/bench helpers
- data/community-results.csv - community result table seed

## Model Downloads

The public download helper wraps the Hugging Face CLI for the model files used by the examples. It mirrors the model IDs used in the tested LXC workflow, but keeps the script generic and free of private host details:

~~~bash
scripts/download-models.sh qwen36-27b-vllm
scripts/download-models.sh qwen36-27b-gguf-q6
scripts/download-models.sh qwen36-27b-gguf-iq4xs
scripts/download-models.sh qwen35-9b-mtp-gguf-q4
scripts/download-models.sh qwen36-35b-a3b-vllm
scripts/download-models.sh qwen36-35b-a3b-gguf
scripts/download-models.sh qwen36-35b-a3b-gguf-iq3xxs
~~~

Set MODEL_DIR for GGUF downloads if you do not want to use ~/models. For large GGUF files on slower or constrained storage, HF_HUB_DISABLE_XET=1 is the safer default used by the helper.

## Building The llama.cpp MTP Tree

~~~bash
scripts/update-llama.sh
~~~

This builds the MTP-capable llama.cpp tree used by the Qwen3.6 GGUF examples, pinned by default to the tested PR/commit. The live lab setup runs the service through its own LXC wrapper and preset files; the repo script is the reproducible public build helper, not a service manager. Use the --fresh flag if you want to move the existing source tree aside and clone again.

## Quick Health Check

Once you have a local OpenAI-compatible endpoint running:

~~~bash
python3 scripts/openai_compat_smoke.py --base-url http://127.0.0.1:8000/v1 --model your-model-name
~~~

For a simple decode speed check:

~~~bash
python3 scripts/simple_decode_bench.py --base-url http://127.0.0.1:8000/v1 --model your-model-name --max-tokens 512
~~~

These scripts only use the Python standard library.

## Share A Result

Generate a paste-ready local report:

~~~bash
bash scripts/report.sh --url http://127.0.0.1:8000 --model your-model-name > my-5060ti-result.md
~~~

Then open a result issue using the template in this repo. The report script avoids API keys and private paths, but review the output before posting it publicly.

## Scope

The current focus is practical 2x RTX 5060 Ti 16GB serving for Qwen3.6 27B, with additional checks for nearby models when we have reproducible evidence. Single-card and mixed-GPU notes are included where they help people get started, but they should be reported separately from the dual-5060 Ti baseline.

## Contributing

Contributions are most useful when they include exact GPU model, motherboard/PCIe layout, negotiated link width/generation, driver/runtime versions, launch commands, context length, KV cache settings, tokens/sec, and relevant caveats.

Start with CONTRIBUTING.md.
