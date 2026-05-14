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
| llama.cpp / vLLM | Qwen3.6 35B A3B | Early checks | Small-context GGUF smoke result and vLLM NVFP4/MTP launch example. |

## Tested Baseline

- GPUs: 2x NVIDIA GeForce RTX 5060 Ti 16GB
- Driver: 595.58.03
- Total VRAM: 32GB across two cards
- Host memory: 60GB RAM
- CPU: 16 vCPU class Linux host
- Useful assumption: tensor parallel across both cards for 27B-class models

See docs/hardware.md for the full baseline and hardware notes.

## Repo Map

- docs/FAQ.md - short answers to the questions people ask first
- docs/community-goals.md - project goals and contribution priorities
- docs/client-examples.md - connecting OpenAI-compatible clients
- docs/reporting-results.md - how to capture a useful result report
- docs/vllm-qwen36.md - working vLLM NVFP4/MTP recipe
- docs/llamacpp-qwen36.md - working llama.cpp MTP GGUF recipe
- docs/qwen36-35b-a3b.md - additional Qwen3.6 35B A3B checks
- docs/benchmarks.md - benchmark notes and current result table
- docs/troubleshooting.md - problems seen during testing
- examples/ - sanitized config snippets
- scripts/ - small reproducible health/bench helpers
- data/community-results.csv - community result table seed

## Model Downloads

The download helper wraps the Hugging Face CLI for the model files used by the examples:

~~~bash
scripts/download-models.sh qwen36-27b-vllm
scripts/download-models.sh qwen36-27b-gguf-q6
scripts/download-models.sh qwen36-35b-a3b-vllm
scripts/download-models.sh qwen36-35b-a3b-gguf
~~~

Set MODEL_DIR for GGUF downloads if you do not want to use ~/models.

## Updating llama.cpp

~~~bash
scripts/update-llama.sh
~~~

This rebuilds llama.cpp with the CUDA/Blackwell flags used for the llama.cpp examples. Use the --fresh flag if you want to move the existing source tree aside and clone again.

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

The current focus is practical 2x RTX 5060 Ti 16GB serving for Qwen3.6 27B, with additional checks for nearby models when we have reproducible evidence.

## Contributing

Contributions are most useful when they include exact GPU model, driver/runtime versions, launch commands, context length, KV cache settings, tokens/sec, and relevant caveats.

Start with CONTRIBUTING.md.
