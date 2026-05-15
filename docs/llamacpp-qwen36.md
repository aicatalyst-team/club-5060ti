# llama.cpp: Qwen3.6 27B MTP GGUF

This path is useful for GGUF workflows and for people who prefer llama.cpp-style serving.

## Important Requirement

Use a llama.cpp build that supports the Qwen3.6 MTP GGUF files. In testing, a regular upstream binary failed to load the MTP GGUF with this missing tensor error:

~~~text
missing tensor 'blk.64.ssm_conv1d.weight'
~~~

The working setup used llama.cpp MTP build `9032-5d5f1b46e`.

The public helper scripts/update-llama.sh builds the same MTP-capable PR/commit by default. The live service wrapper and preset files in the tested LXC are separate from this repo; the important public pieces are the model path shape, build commit, CUDA flags, and preset settings below.

## Working Long-Context Preset

~~~ini
[Qwen3.6-27B]
model = /path/to/Qwen3.6-27B-UD-Q6_K_XL.gguf
ctx-size = 204800
cache-type-k = q8_0
cache-type-v = q8_0
n-gpu-layers = 99
tensor-split = 1,1
temp = 0.7
top-k = 20
top-p = 0.95
min-p = 0
presence-penalty = 0.8
batch-size = 2048
ubatch-size = 512
spec-type = mtp
spec-draft-n-max = 2
jinja = on
parallel = 1
~~~

See examples/llamacpp-qwen36-preset.ini.

This is the public long-context preset shape. The direct tested setup uses Q6, q8 KV, tensor split 1,1, MTP draft 2, and 204800 context on 2x RTX 5060 Ti 16GB.

For an always-on router setup with extra headroom, the current stable preset uses 65536 context, mmap disabled, q8 KV, MTP draft 2, and tensor split 51,49. See examples/llamacpp-qwen36-router.ini.

## Observed Q4 vs Q6 Benchmark

Test shape:

- llama.cpp MTP branch
- 2x RTX 5060 Ti 16GB
- 8K context
- q8 KV
- tensor split 1,1
- 768 generated tokens

| Quant | MTP | Decode |
| --- | --- | --- |
| Q4 | off | 21.31 tok/s |
| Q4 | draft 2 | 34.63 tok/s |
| Q6 | off | 15.61 tok/s |
| Q6 | draft 2 | 27.33 tok/s |

Q6 fit GPU-only at 8K in testing, but it was tighter on VRAM and slower than Q4. Treat Q6 as a quality/speed tradeoff, not a straight replacement.

## Observed Router Result

The stable router preset at 65536 context, q8 KV, tensor split 51,49, and MTP draft 2 produced 24.83 tok/s over 512 generated tokens with thinking disabled.

## Observed Q6 Context Fit

The Q6 q8/q8 llama.cpp MTP setup loaded and completed chat checks at:

| Context | Result |
| --- | --- |
| 65,536 | chat OK |
| 98,304 | chat OK |
| 131,072 | chat OK |
| 160,000 | chat OK |
| 180,000 | chat OK |
| 200,000 | chat OK |

The long-context preset uses 204800 context. Focused direct-load checks also loaded larger contexts, but 204800 is a tight fit and should be treated as a long-context recipe, not a universal default for every router/build flag combination.

## Caveats

- Do not assume draft/speculative decoding is working just because flags are present. Check logs for real MTP/speculative acceptance.
- Older speculative paths for recurrent/hybrid Qwen models can produce corrupt output. Avoid unsafe pre-guard builds unless you are explicitly experimenting.
- Keep one clean preset per model family. Swap the quant path instead of accumulating many stale preset sections.
