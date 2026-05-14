---
name: Result report
about: Share a reproducible RTX 5060 Ti local LLM result
title: "[result] "
labels: result
---

## Hardware

- GPU(s):
- VRAM per GPU:
- Driver:
- CPU:
- RAM:
- OS/container:

## Runtime

- Runtime:
- Version/commit:
- Model:
- Quant:
- Launch command/config:

## Settings

- Context length:
- KV cache:
- Tensor parallel / tensor split:
- MTP/speculative settings:
- Thinking/reasoning enabled:

## Result

- Prompt tokens:
- Generated tokens:
- Decode tok/s:
- End-to-end tok/s if measured:
- Notes/warnings:

## Optional Report Output

Paste reviewed output from:

~~~bash
bash scripts/report.sh --url http://127.0.0.1:8000 --model your-model-name
~~~
