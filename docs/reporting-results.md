# Reporting Results

A useful result is reproducible. A vague tok/s number is not.

## Quick Report

~~~bash
bash scripts/report.sh --url http://127.0.0.1:8000 --model qwen36-27b-nvfp4-mtp > my-result.md
~~~

Review the output before posting it publicly.

## Include These Details

- GPU model and count
- VRAM per GPU
- driver version
- CPU, host RAM, inference/container RAM allocation, and motherboard/system model
- PCIe slot layout and negotiated link width/gen per GPU
- OS/container setup
- runtime and version
- model and quant
- launch command or config
- context length
- KV cache dtype
- tensor parallel or tensor split
- generated token count
- decode tok/s
- warnings, restarts, or caveats

## Issue Reports

For runtime or client problems, include the exact command/config, the last meaningful error, whether a basic chat completion still works, and whether the issue changes between single-GPU and multi-GPU launch modes.
