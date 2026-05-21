# PoC Plan: club-5060ti

## Project Classification
- **Type:** infrastructure
- **Key Technologies:** Python 3, Bash, JSON Schema validation, static HTML site, llama.cpp / vLLM configuration recipes
- **ODH Relevance:** This project provides benchmark tooling and reproducible recipes for local LLM inference on NVIDIA RTX 5060 Ti GPUs. While it is not a deployable ML application itself, its benchmark scripts (especially `run_openai_bench.py`) target OpenAI-compatible inference endpoints — the same API surface exposed by ODH/OpenShift AI model-serving components (vLLM, KServe). Containerizing the toolkit makes it reusable as a benchmark harness for ODH inference deployments.

## PoC Objectives
What we want to prove:
1. The benchmark toolkit and validation scripts can be containerized and run successfully in a Kubernetes environment
2. The bundled benchmark result JSON files pass schema validation inside the container
3. The static site data builder produces correct aggregated output from individual result files
4. The OpenAI-compatible benchmark script (`run_openai_bench.py`) is importable and functional (help/dry-run) — ready to be pointed at an ODH inference endpoint in a follow-up integration

## Infrastructure Requirements
- **Inference Server:** none (this project *benchmarks* inference servers; it does not include one)
- **Vector Database:** none
- **Embedding Model:** none
- **GPU Required:** No (the scripts themselves are CPU-only; they talk to GPU-backed servers over HTTP)
- **Persistent Storage:** none
- **Resource Profile:** small (256Mi RAM, 250m CPU — scripts are lightweight)
- **Sidecar Containers:** none

## Test Scenarios

### Scenario 1: validate-results
- **Description:** Run the JSON schema validator against all bundled benchmark results under `data/results/`
- **Type:** cli
- **Input:** `python3 scripts/validate_results.py data/results`
- **Expected:** Job exits 0; output lists each result file and confirms schema compliance
- **Timeout:** 30s

### Scenario 2: build-site-data
- **Description:** Run the site data builder to regenerate `site/data/results.json` from individual result files
- **Type:** cli
- **Input:** `python3 scripts/build_site_data.py`
- **Expected:** Job exits 0; `results.json` is written without errors
- **Timeout:** 30s

### Scenario 3: bench-help
- **Description:** Verify the primary benchmark script starts correctly and prints usage info
- **Type:** cli
- **Input:** `python3 scripts/run_openai_bench.py --help`
- **Expected:** Job exits 0; output shows CLI flags including `--base-url`, `--model`, `--concurrency`, etc.
- **Timeout:** 15s

### Scenario 4: check-repo
- **Description:** Run the repository health-check shell script
- **Type:** cli
- **Input:** `bash scripts/check_repo.sh`
- **Expected:** Job exits 0; outputs pass/fail status for repository structure conventions
- **Timeout:** 30s

## Dockerfile Considerations

This is a **CLI toolkit / script collection**, not a server. The Dockerfile should:

- Use a Python 3.11+ slim base image
- Install minimal dependencies: `requests`, `jsonschema`, and any other imports used by the scripts (check `scripts/*.py` imports — likely `argparse`, `json`, `csv`, `pathlib`, `statistics`, `datetime` which are all stdlib, plus `requests` and possibly `jsonschema` or `fastjsonschema`)
- Copy the entire repository into the image (scripts need access to `data/`, `site/`, and `data/schema/`)
- Set `WORKDIR` to the repository root
- Set `ENTRYPOINT ["python3"]` so individual scripts can be run as arguments
- Set `CMD ["scripts/run_openai_bench.py", "--help"]` as a sensible default
- Do **NOT** add `EXPOSE` — there is no port to expose. This container does not listen on any port.
- Ensure `bash` is available (for `check_repo.sh`)

## Deployment Considerations

- **Deployment model: Job** — This is a CLI toolkit. Each test runs as a Kubernetes Job that executes a specific command and exits. Do **NOT** deploy as a Deployment — the process exits immediately and would CrashLoopBackOff endlessly.
- **Do NOT create a Service** — There is no port. The container does not listen for incoming connections.
- **Testing:** Each scenario is a separate `kubectl run --rm` or Job that runs a CLI command. Success is determined by the Job's exit code (0 = pass) and output captured via `kubectl logs`.
- **No environment variables required** — The validation and build scripts operate on bundled data. The benchmark script (`run_openai_bench.py`) accepts `--base-url` as a CLI flag, so no env vars are needed for the PoC scenarios (which only test `--help`).
- **Future integration note:** In a follow-up, `run_openai_bench.py` could be pointed at a live ODH/KServe vLLM endpoint by passing `--base-url http://<service>:8080/v1 --model <model-name>`. This would validate ODH inference performance using the club-5060ti benchmark protocol.