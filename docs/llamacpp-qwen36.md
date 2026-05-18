# llama.cpp: Qwen3.6 27B MTP GGUF

This path is useful for GGUF workflows and for people who prefer llama.cpp-style serving.

## Important Requirement

Use a llama.cpp build that supports the Qwen3.6 MTP GGUF files. In testing, a regular upstream binary failed to load the MTP GGUF with this missing tensor error:

~~~text
missing tensor 'blk.64.ssm_conv1d.weight'
~~~

The current working setup uses upstream llama.cpp `9190 (b64739ea3)`, after Qwen3.6 MTP support from PR 22673 merged. Earlier seed results used PR-tip build `9032-5d5f1b46e`; keep benchmark rows tied to the exact runtime version.

The public helper scripts/update-llama.sh builds the tested upstream commit by default. Deployment wrappers vary by machine; the important reproducible pieces are the model path shape, build commit, CUDA flags, and preset settings below.

## MTP Flag Compatibility

Unsloth's 2026-05-15 update says newer Qwen3.6 MTP GGUF runs can benefit from `--spec-draft-p-min 0.75`, higher draft counts such as `--spec-draft-n-max 6`, and newer llama.cpp argument spelling around MTP.

Merged upstream llama.cpp `9190 (b64739ea3)` accepts `--spec-type draft-mtp`, `--spec-draft-p-min 0.75`, and `--spec-draft-n-max`. Older PR-tip seed results used `--spec-type mtp` on `9032-5d5f1b46e`. Do not mix those flag spellings without recording the build version.

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
spec-type = draft-mtp
spec-draft-p-min = 0.75
spec-draft-n-max = 2
jinja = on
parallel = 1
~~~

See examples/llamacpp-qwen36-preset.ini.

This is the public long-context preset shape. The direct tested setup uses Q6, q8 KV, tensor split 1,1, MTP draft 2, and 204800 context on 2x RTX 5060 Ti 16GB.

For an always-on router setup with extra headroom, the current stable preset uses 65536 context, mmap disabled, q8 KV, MTP draft 3, p-min 0.75, and tensor split 51,49. See examples/llamacpp-qwen36-router.ini.

## Observed Q4 vs Q6 Benchmark

Test shape:

- llama.cpp MTP-capable build
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

## Merged Upstream Draft Count Check

After PR 22673 merged, upstream llama.cpp `9190 (b64739ea3)` was checked with Qwen3.6 27B MTP Q6 at 8K context, q8 KV, tensor split 1,1, `--fit off`, and 384 generated tokens.

| MTP | Decode | Draft acceptance |
| --- | --- | --- |
| off | 15.66 tok/s | n/a |
| draft 2, p-min 0.75 | 28.34 tok/s | 0.704 |
| draft 3, p-min 0.75 | 30.46 tok/s | 0.628 |
| draft 6, p-min 0.75 | 23.64 tok/s | 0.345 |

For this Q6 test, draft 3 beat draft 2 and draft 6. The larger draft-6 window generated more draft tokens, but acceptance fell enough to lose throughput.

## Observed Router Result

The stable router-style shape at 65536 context, q8 KV, tensor split 1,1, and upstream `draft-mtp` produced 32.04 tok/s with draft 2 and 37.48 tok/s with draft 3 over 64 generated tokens. The live router preset uses draft 3.

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

The long-context preset uses 204800 context. Merged upstream llama.cpp `9190 (b64739ea3)` recovered a needle from an 87031-token prompt at both 200000 and 204800 context with q8 KV and `draft-mtp` n=3. The 200000 setting is slightly safer because it gives back about 4800 context slots, though this build rounded it to internal `n_ctx_seq = 200192`. Both are tight: the long runs reached about 15847 MiB on GPU0 and 15825 MiB on GPU1 during the request. Treat 200000/204800 as long-context recipes, not universal defaults for every router/build flag combination.

## Caveats

- Do not assume draft/speculative decoding is working just because flags are present. Check logs for real MTP/speculative acceptance.
- Treat MTP flag names as build-specific. Current upstream examples use `--spec-type draft-mtp`; older seed rows in this repo used `--spec-type mtp` on the pre-merge PR-tip build.
- Older speculative paths for recurrent/hybrid Qwen models can produce corrupt output. Avoid unsafe pre-guard builds unless you are explicitly experimenting.
- Keep one clean preset per model family. Swap the quant path instead of accumulating many stale preset sections.
