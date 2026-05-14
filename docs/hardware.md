# Tested Hardware

Initial results come from one dual-GPU Linux system.

| Component | Value |
| --- | --- |
| GPU | 2x NVIDIA GeForce RTX 5060 Ti |
| VRAM | 16GB per card, 32GB total |
| Driver | 595.58.03 |
| GPU architecture | Blackwell-class, compute 12.0 |
| System RAM | 60GB |
| CPU allocation | 16 vCPU class host |
| Runtime style | Linux host, CUDA containers for vLLM |

## What Seems To Matter

- 16GB per card is tight for 27B-class models, so quantization and KV cache choices matter.
- Tensor parallel across both cards is the useful default for vLLM 27B NVFP4 serving.
- fp8 KV cache is important for long context experiments.
- Blackwell support is still moving quickly. Runtime version and container image matter more than they would on older, mature cards.
- Motherboard layout matters for community reports. Include PCIe slot wiring if you know it.
- Power limits and thermals matter for sustained decode. Include them when sharing numbers.

## What Not To Generalize Yet

- Single RTX 5060 Ti results may look very different.
- Motherboard PCIe layout may matter for multi-GPU setups.
- Different CPUs and RAM bandwidth may change long-context behavior.
- New vLLM, CUDA, and modelopt builds may change the best flags.

## Hardware Report Template

When sharing a result, this level of detail is enough to help others:

~~~text
GPU: 2x RTX 5060 Ti 16GB
Driver:
CPU:
RAM:
Motherboard:
PCIe layout:
Power limits:
Runtime:
Model:
Context:
KV cache:
Decode tok/s:
Notes:
~~~
