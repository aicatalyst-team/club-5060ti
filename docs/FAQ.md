# FAQ

## What exactly is this?

A practical repo for running local LLMs on RTX 5060 Ti 16GB cards. The current recipes focus on Qwen3.6 27B because that is what has been tested deeply so far.

## Why care about 5060 Ti cards?

They are consumer cards with 16GB VRAM. One card is constrained, but two cards give 32GB total VRAM, which is enough for useful 27B-class experiments with the right quant/runtime choices.

## Do I need Linux?

For vLLM, yes in practice: Linux + CUDA + NVIDIA container runtime is the target for these recipes.

llama.cpp can run on more platforms, but the recipes here assume Linux paths and NVIDIA CUDA.

## Does VRAM combine across cards?

Sort of, depending on runtime.

vLLM tensor parallel splits model work across GPUs. That is the useful path for dual 5060 Ti 16GB serving.

llama.cpp can split layers/weights across GPUs with tensor split settings. It is not the same thing as vLLM tensor parallel, but it is useful and handles some uneven setups.

## Do I need NVLink?

RTX 5060 Ti cards do not have NVLink. The tested setup works over PCIe. Faster interconnects can help some workloads, but they are not required for the documented recipes.

## Should I use vLLM or llama.cpp?

Start with vLLM if you want OpenAI-compatible serving, throughput, MTP, tool-calling experiments, and long-context work on the NVFP4 checkpoint.

Use llama.cpp if you want GGUF workflows, simpler host binaries, long-context Q6 serving, or to compare Q4/Q6 behavior with the MTP GGUF files.

## What should I benchmark?

At minimum:

- one short no-thinking generation
- one longer decode run with generated token count
- context length used
- whether reasoning/thinking was enabled
- VRAM use before and during serving
- any warnings or crashes

Use docs/reporting-results.md and scripts/report.sh.
