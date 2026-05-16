# Troubleshooting

## vLLM Takes A Long Time To Start

Blackwell plus nightly CUDA/vLLM builds can spend several minutes compiling and autotuning. Wait for the health endpoint before assuming startup is stuck:

~~~bash
curl -fsS http://127.0.0.1:8000/health
~~~

## OOM Warnings During Startup

Some autotuners try shapes that fail and then fall back. If the server eventually reaches health, the warnings may be noisy rather than fatal.

Fatal OOMs usually appear near KV cache allocation or workspace allocation and the process exits.

## KV Cache Dtype

For the tested NVFP4 checkpoint, fp8_e5m2 KV was not the right setting. Use:

~~~bash
--kv-cache-dtype fp8
~~~

## llama.cpp MTP GGUF Missing Tensor

If llama.cpp fails with:

~~~text
missing tensor 'blk.64.ssm_conv1d.weight'
~~~

you are probably using a binary that does not support the Qwen3.6 MTP GGUF architecture. Use an MTP-capable llama.cpp build.

## Thinking Mode Gives No Final Answer

Qwen reasoning can consume the full max_tokens budget. If the API returns reasoning but no final content, increase max_tokens.

Practical starting points:

- no thinking: 512-1024
- brief thinking: 1024-4096
- hard reasoning: 8192+

## Streaming Or Tool Calls Break

A server that passes one short curl is not necessarily stable for streaming, tool calls, coding agents, and long tool outputs. Test those paths separately if you plan to use them.

When reporting this kind of problem, include:

- client name and version
- whether streaming was enabled
- whether OpenAI tool calling was enabled
- approximate tool output size
- server logs around the disconnect
- whether a normal non-tool chat completion still works

For vLLM/Qwen, also note whether tool parsing flags are enabled and whether thinking/reasoning consumed the whole output budget.

## Multi-GPU Questions

If performance is far lower than expected, collect:

- PCIe lane layout from your motherboard manual or lspci
- GPU utilization during prefill and decode
- whether tensor parallel is actually set to 2
- whether both GPUs show memory allocation
- whether P2P is supported or patched on your driver

Do not assume NVLink is required. The seed dual-5060 Ti setup works over PCIe, but the exact motherboard layout can still matter.

## CPU Threads Matter For Partial Offload

If a model spills work to CPU, the `--threads` setting can materially change speed. Report the value you used, plus the CPU model and whether the number maps to performance cores, physical cores, or logical threads.

For GPU-only rows, CPU thread tuning should matter less during decode, but it is still worth recording for reproducibility.
