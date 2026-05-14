# Contributing

Good contributions make the setup easier to reproduce.

Please include:

- GPU model and VRAM, including whether it is one card or multiple cards
- CPU and system RAM if long context matters
- driver version
- runtime and runtime version or commit
- model, quant, and source
- exact launch command or config
- context length and KV cache dtype
- tensor parallel or split settings
- benchmark prompt length and generated token count
- tokens/sec and whether it is prompt, decode, or end-to-end
- caveats and warnings

Do not paste API keys, private IP addresses, private hostnames, full logs with secrets, or benchmark claims without enough setup detail.
