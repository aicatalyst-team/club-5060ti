# FAQ

## What exactly is this?

A practical repo for running local LLMs on RTX 5060 Ti 16GB cards. The tested baseline is Blackwell/5060 Ti, but some llama.cpp/GGUF recipes are useful starting points for other NVIDIA cards when they are reported as separate hardware lanes.

## Why care about 5060 Ti cards?

They are consumer cards with 16GB VRAM. One card is constrained, but two cards give 32GB total VRAM, which is enough for useful 27B-class experiments with the right quant/runtime choices.

## Do I need Linux?

For vLLM, yes in practice: Linux + CUDA + NVIDIA container runtime is the target for these recipes.

llama.cpp can run on more platforms, but the recipes here assume Linux paths and NVIDIA CUDA.

## Do I need the exact tested NVIDIA driver?

No. The seed rows report driver `595.58.03` because that is what was used for those tests, not because the repo requires that exact version.

If you are already on another recent 595-series driver, try it first and report the exact driver, CUDA/runtime version, and whether the launch worked. Do not downgrade just to match the seed rows unless you are chasing a specific regression.

## Does VRAM combine across cards?

Sort of, depending on runtime.

vLLM tensor parallel splits model work across GPUs. That is the useful path for dual 5060 Ti 16GB serving.

llama.cpp can split layers/weights across GPUs with tensor split settings. It is not the same thing as vLLM tensor parallel, but it is useful and handles some uneven setups.

## Do the cards need to be identical?

Not always, but mixed cards should be treated as a separate result.

llama.cpp is the more forgiving path. A mixed pair may work for GGUF serving if the CUDA build supports all GPUs and the tensor split fits within each card's VRAM. Expect the slower card, PCIe layout, CUDA architecture support, and split choice to affect results.

vLLM tensor parallel is less forgiving. The documented NVFP4/MTP recipes were tested on two RTX 5060 Ti 16GB cards. Do not assume those exact vLLM NVFP4 flags work unchanged on another architecture or mixed-architecture setup, because the NVFP4 path depends on newer Blackwell-oriented CUDA/runtime support.

If you test mixed cards, report the exact GPU names, VRAM, driver, CUDA/runtime build, PCIe link widths, model, quant, context, KV cache, tensor split or tensor-parallel size, and whether single-GPU and multi-GPU launches both work.

For non-5060 Ti or mixed-architecture systems, start with llama.cpp/GGUF before vLLM. Similar VRAM does not mean the cards behave the same, so the best working config may be different from the dual-5060 Ti NVFP4 recipe.

See docs/gpu-compatibility.md for build and reporting notes.

## Is there a single 5060 Ti setup?

Yes, but treat it as a starter path rather than the main tested baseline. A single 16GB card is a better fit for smaller GGUF models, lower context, or aggressive quantization than for the dual-card 27B recipes.

See docs/single-5060ti.md and examples/llamacpp-single-5060ti.ini.

## Do I need NVLink?

RTX 5060 Ti cards do not have NVLink. The tested setup works over PCIe. Faster interconnects can help some workloads, but they are not required for the documented recipes.

## Should I install patched P2P drivers?

Not for the basic recipes. The seed results do not require NVLink or patched P2P support.

Patched P2P drivers are system-dependent and should be treated as a separate experiment. If you test them, report stock vs patched driver state, `nvidia-smi topo -p2p`, PCIe topology, and whether tokens/sec or prompt eval actually changed.

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
