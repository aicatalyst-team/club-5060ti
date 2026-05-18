# Project Goals

This repo exists because 5060 Ti local LLM results are easier to compare when the setup details are recorded consistently:

- exact hardware specs
- native Linux vs WSL behavior
- how multiple GPUs share work
- whether NVLink or P2P is required
- which runtime is actually stable
- which model/quant fits
- client behavior under tool-calling, streaming, and long context
- how to compare tokens/sec without hiding caveats

The goal is to keep those reports searchable, comparable, and easy to reproduce.

## Principles

- Be specific: exact commands beat general advice.
- Keep receipts: benchmarks need context, model, quant, runtime, and generated token count.
- Keep caveats specific and tied to reproducibility.
- Keep public hygiene: no private hosts, keys, or copied logs with secrets.

## What Would Be Useful Next

- Dual 5060 Ti results from different CPUs/motherboards.
- Clearly labeled mixed-GPU results, especially RTX 40/50-series 16GB combinations.
- PCIe lane layout notes.
- Power limit and thermal notes.
- vLLM version drift reports.
- llama.cpp MTP build instructions once the correct upstream path stabilizes.
- Client notes for Open WebUI, Cline, Cursor, OpenCode, and other OpenAI-compatible clients.
