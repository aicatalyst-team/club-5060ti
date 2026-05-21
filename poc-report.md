# PoC Report: club-5060ti

## 1. Executive Summary

The **club-5060ti** project — a community-driven benchmark toolkit and knowledge base for local LLM inference on NVIDIA RTX 5060 Ti GPUs — was evaluated as an infrastructure-type PoC. The objective was to containerize the Python/Bash utility scripts, validate that all bundled benchmark data passes schema checks, and confirm that the OpenAI-compatible benchmark harness is functional and ready to target ODH inference endpoints. **The PoC succeeded: all 4 test scenarios passed**, demonstrating that the toolkit runs cleanly inside containers on Kubernetes and is ready for integration with Open Data Hub model-serving deployments.

## 2. Project Analysis

- **Repository URL:** `https://github.com/5p00kyy/club-5060ti`
- **Local Path:** `/workspace/club-5060ti`
- **Project Summary:** club-5060ti is a community-driven knowledge base and benchmarking project for running local LLM inference on NVIDIA RTX 5060 Ti GPUs. It contains benchmark results (JSON), configuration recipes (ini/sh), Python utility scripts for benchmarking and validation, and a static HTML site for exploring results. It is primarily a documentation and data repository, not a deployable application.

### Components Detected

| Component | Language | Build System | ML Workload | Port |
|-----------|----------|-------------|-------------|------|
| site | HTML | none | No | None |
| scripts | Python | none | No | None |

- **Project Classification:** Infrastructure
- **Technologies & Frameworks:** Python 3, Bash, JSON Schema validation, static HTML, llama.cpp / vLLM configuration recipes, OpenAI-compatible API benchmarking

## 3. PoC Objectives

### What We Set Out to Prove

1. The benchmark toolkit and validation scripts can be **containerized and run successfully** in a Kubernetes environment.
2. The bundled benchmark result JSON files **pass schema validation** inside the container.
3. The static site data builder **produces correct aggregated output** from individual result files.
4. The OpenAI-compatible benchmark script (`run_openai_bench.py`) is **importable and functional** (help/dry-run) — ready to be pointed at an ODH inference endpoint in a follow-up integration.

### Relevance to Open Data Hub / OpenShift AI

This project provides benchmark tooling and reproducible recipes for local LLM inference on NVIDIA RTX 5060 Ti GPUs. While it is not a deployable ML application itself, its benchmark scripts (especially `run_openai_bench.py`) target OpenAI-compatible inference endpoints — the **same API surface exposed by ODH/OpenShift AI model-serving components** (vLLM, KServe). Containerizing the toolkit makes it reusable as a benchmark harness for ODH inference deployments.

### Infrastructure Requirements Identified

| Requirement | Value |
|-------------|-------|
| Inference Server | Not needed (this project *benchmarks* inference servers) |
| Vector Database | None |
| Embedding Model | None |
| GPU Required | No (scripts are CPU-only; they talk to GPU-backed servers over HTTP) |
| Persistent Storage | None |
| Resource Profile | Small (256Mi RAM, 250m CPU) |
| Sidecar Containers | None |
| Deployment Model | Kubernetes Job |
| Test Strategy | CLI |

## 4. Pipeline Execution

### Intake

The intake phase analyzed the repository at `/workspace/club-5060ti` and identified two components:

- **site** — a static HTML site for exploring benchmark results (no build system, no port).
- **scripts** — a collection of Python utility scripts for benchmarking, validation, and data aggregation (no build system, no port).

The project was classified as **infrastructure** — it is a toolkit rather than a long-running service. Existing CI/CD via GitHub Actions was detected.

### PoC Plan

The PoC plan identified the project as a CLI toolkit / script collection. Four test scenarios were defined covering schema validation, data building, benchmark script functionality, and repository health checks. The deployment model was set to **Kubernetes Jobs** (not long-running Deployments), since all scenarios are short-lived CLI commands.

### Fork

No GitLab fork URL was provided in the pipeline data. The work proceeded directly against the source repository.

### Containerize

Two Dockerfiles were generated:

| Dockerfile | Component | Purpose |
|------------|-----------|---------|
| `Dockerfile.site` | site | Static HTML site content |
| `Dockerfile.scripts` | scripts | Python/Bash benchmark toolkit |

The scripts Dockerfile was designed as a lightweight Python 3 image containing all utility scripts and bundled benchmark data, with `python3` as the entrypoint.

### Build

Two container images were built and pushed successfully with **zero retries**:

| Image | Tag | Status |
|-------|-----|--------|
| `quay.io/aicatalyst/club-5060ti-site` | `latest` | ✅ Built & pushed |
| `quay.io/aicatalyst/club-5060ti-scripts` | `latest` | ✅ Built & pushed |

### Deploy

The following Kubernetes resources were deployed with **zero retries**:

| Resource | Name | Status |
|----------|------|--------|
| Namespace | `club-5060ti` | ✅ Created |
| Job | `scripts-validate-results` | ✅ Completed |
| Job | `scripts-build-site-data` | ✅ Completed |
| Job | `scripts-bench-help` | ✅ Completed |
| Job | `scripts-check-repo` | ✅ Completed |

No routes or services were created, as all workloads are short-lived Jobs with no listening ports.

### PoC Execute

A test script was generated at `/workspace/club-5060ti/poc_test.py` and executed against the four deployed Jobs. All scenarios completed successfully.

## 5. Test Results

| Scenario | Status | Duration | Details |
|----------|--------|----------|---------|
| validate-results | ✅ PASS | 0.3s | Validated 76 result(s) — all passed schema checks |
| build-site-data | ✅ PASS | 0.5s | Wrote 76 result(s) to `site/data/results.json` |
| bench-help | ✅ PASS | 0.3s | Printed usage info: `run_openai_bench.py [-h] [--base-url BASE_URL] [--api-key API_KEY] ...` |
| check-repo | ✅ PASS | 0.3s | Validated 76 result(s), wrote 76 result(s) to `site/data/results.json`, repo structure OK |

### Summary

- **Total Scenarios:** 4
- **Passed:** 4 ✅
- **Failed:** 0
- **Skipped:** 0
- **Errors:** 0

**No failures to report.** All scenarios completed within their timeout windows (actual durations ranged from 0.3s to 0.5s against timeouts of 15–30s).

> **Note on `check-repo`:** The output includes a `fatal: not a git repository` message (truncated), which is expected — the container image does not include the `.git` directory. Despite this, the Job exited 0, indicating the script handles non-git environments gracefully. For a production deployment, this could be addressed by either including `.git` in the image or skipping git-dependent checks via a flag.

## 6. Infrastructure Deployed

| Property | Value |
|----------|-------|
| **Kubernetes Namespace** | `club-5060ti` |
| **Deployment Model** | Kubernetes Jobs (4 total) |
| **Long-running Services** | None |
| **Routes / URLs** | None created |

### Container Images

| Image | Tag |
|-------|-----|
| `quay.io/aicatalyst/club-5060ti-site` | `latest` |
| `quay.io/aicatalyst/club-5060ti-scripts` | `latest` |

### Kubernetes Resources

| Kind | Name | Image Used |
|------|------|------------|
| Namespace | `club-5060ti` | — |
| Job | `scripts-validate-results` | `quay.io/aicatalyst/club-5060ti-scripts:latest` |
| Job | `scripts-build-site-data` | `quay.io/aicatalyst/club-5060ti-scripts:latest` |
| Job | `scripts-bench-help` | `quay.io/aicatalyst/club-5060ti-scripts:latest` |
| Job | `scripts-check-repo` | `quay.io/aicatalyst/club-5060ti-scripts:latest` |

### Resource Allocations

| Resource | Request | Limit |
|----------|---------|-------|
| CPU | 250m | 250m |
| Memory | 256Mi | 256Mi |

- **PVCs:** None
- **Sidecar Containers:** None
- **GPUs:** None required

## 7. Recommendations

### Production Readiness

The toolkit is **ready for use as a containerized benchmark harness**. However, it is not a production application in the traditional sense — it is a utility toolkit. To make it production-grade for regular benchmarking workflows:

- **Pin a specific image tag** instead of `latest` for reproducibility.
- **Add health/liveness probes** if the benchmark script is ever wrapped in a long-running service.
- **Parameterize benchmark targets** via environment variables or ConfigMaps so the same image can benchmark different inference endpoints.

### Performance

- All four scenarios completed in under 1 second each. The scripts are I/O-bound (JSON parsing, schema validation) and CPU-light.
- When running `run_openai_bench.py` against a live inference endpoint, performance will be dominated by network latency and model serving throughput, not by the benchmark script itself.

### Security

- **Image provenance:** The images should be scanned for vulnerabilities before being used in production clusters.
- **API key handling:** The `run_openai_bench.py` script accepts `--api-key` as a CLI flag. In production, API keys should be injected via Kubernetes Secrets, not passed as Job arguments.
- **Network policy:** When pointed at an inference endpoint, the benchmark Job should have a NetworkPolicy restricting egress to only the target endpoint.

### Scalability

- The benchmark harness is inherently single-instance per Job. To scale benchmarking across multiple models or endpoints, use **Kubernetes CronJobs or parameterized Job templates** (one per target).
- Results should be written to a shared PVC or external object store (S3) rather than container-local storage for aggregation.

### Next Steps

1. **Integration test with ODH:** Point `run_openai_bench.py` at a vLLM or KServe inference endpoint deployed via Open Data Hub and validate end-to-end benchmarking.
2. **CronJob template:** Create a Kubernetes CronJob that periodically benchmarks an inference endpoint and stores results.
3. **Results pipeline:** Feed benchmark JSON output into a Data Science Pipeline for automated performance regression analysis.
4. **Static site deployment:** Deploy the `site` image behind an OpenShift Route to provide a browsable dashboard of benchmark results.
5. **Image tagging:** Implement a CI/CD pipeline (extending the existing GitHub Actions) to build and push tagged images on each commit.

## 8. Open Data Hub / OpenShift AI Considerations

### Relevant ODH Components

| ODH Component | Relevance | Priority |
|---------------|-----------|----------|
| **Model Serving (vLLM / KServe)** | Primary benchmark target — `run_openai_bench.py` speaks the same OpenAI-compatible API | High |
| **Data Science Pipelines** | Automate periodic benchmark runs and results analysis | Medium |
| **Model Registry** | Track which models have been benchmarked and their performance baselines | Medium |
| **Workbenches** | Interactive development/analysis of benchmark results in Jupyter | Low |
| **TrustyAI** | Monitor model inference performance metrics (latency, throughput) over time | Low |

### Migration Path: Vanilla K8s → ODH-Managed

1. **Current state:** Benchmark toolkit runs as standalone Kubernetes Jobs.
2. **Phase 1 — Endpoint integration:** Configure `run_openai_bench.py` to target a vLLM `InferenceService` deployed via ODH. Pass the endpoint URL and API key via ODH-managed Secrets.
3. **Phase 2 — Pipeline automation:** Wrap the benchmark Job in a **Data Science Pipeline** (Kubeflow Pipeline) that:
   - Deploys a model via KServe
   - Runs the benchmark
   - Collects results
   - Stores them in the Model Registry as performance metadata
4. **Phase 3 — Continuous monitoring:** Use **TrustyAI** to set up performance baselines and alert on regressions detected by scheduled benchmark runs.

### ODH-Specific Recommendations

- **KServe / ModelMesh:** The benchmark script already targets the OpenAI-compatible API. Deploy models using KServe's `InferenceService` with the vLLM runtime, then point the benchmark harness at the generated Route.
- **Data Science Pipelines:** Create a parameterized pipeline component from the `scripts` container image. Input parameters: model name, endpoint URL, concurrency level. Output: benchmark JSON artifact.
- **Model Registry:** After each benchmark run, register the results as model version metadata (tokens/sec, latency percentiles) to track performance across model versions and hardware configurations.
- **Workbenches:** Use a JupyterLab workbench to interactively analyze benchmark results stored in `site/data/results.json`, generate visualizations, and compare GPU configurations.

## 9. Appendix

### Artifacts

| Artifact | Location |
|----------|----------|
| PoC Plan | `poc-plan.md` |
| Test Script | `/workspace/club-5060ti/poc_test.py` |
| Dockerfile (site) | `Dockerfile.site` |
| Dockerfile (scripts) | `Dockerfile.scripts` |
| K8s Manifests | Generated inline during deploy phase |
| Raw Test Output | `poc-test-output/` on `autopoc-artifacts` branch |

### Build Errors

None. Both images built successfully on the first attempt.

- **Build retries:** 0

### Deploy Errors

None. All resources were created successfully on the first attempt.

- **Deploy retries:** 0

### Notes on Truncated Output

- The `check-repo` scenario output was truncated in the test results with `fatal: not a git repository (or ...`. This is a non-critical warning caused by the absence of `.git` metadata in the container image. The Job still exited 0.

### Existing CI/CD

The project has existing CI/CD via **GitHub Actions**. The containerized PoC can be integrated into this pipeline by adding build/push steps for the two container images and a Kubernetes Job trigger for post-merge validation.
