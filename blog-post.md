## What is club-5060ti?

Club-5060ti is a community-driven knowledge base and benchmarking project focused on running local LLM inference on NVIDIA RTX 5060 Ti GPUs. It's not a deployable application in the traditional sense — it's a curated collection of benchmark results stored as JSON, configuration recipes for llama.cpp and vLLM, Python utility scripts for running and validating benchmarks, and a static HTML site for exploring the data.

Think of it as the "lab notebook" for a community of developers who want to know exactly what performance to expect when they run Llama, Mistral, or other open models on a specific consumer GPU. The project includes a schema-validated result format, an OpenAI-compatible benchmarking harness, and tooling to aggregate individual results into a browsable dataset.

The interesting bit for our purposes: that benchmarking harness (`run_openai_bench.py`) targets the same OpenAI-compatible API surface that OpenShift AI's model-serving components expose. That makes it a natural candidate for containerization as a reusable benchmark tool.

## Why this matters for OpenShift AI

At first glance, a consumer GPU benchmarking project doesn't scream "enterprise AI platform." The RHOAI fitness score of 38/100 reflects that honestly — there's no deployable model, no training pipeline, no platform integration out of the box. So why bother?

Because benchmark tooling is infrastructure, and infrastructure PoCs have real value. The `run_openai_bench.py` script speaks the same OpenAI-compatible protocol that vLLM and KServe expose in OpenShift AI. Containerizing this toolkit means we get a portable, reproducible benchmark harness that can be pointed at any ODH inference endpoint. Run it as a Kubernetes Job, collect the JSON results, compare performance across model-serving configurations. That's a practical addition to any platform engineer's toolkit.

This PoC also exercises a common real-world pattern: taking a loose collection of scripts and data files — the kind of thing that lives on someone's laptop — and packaging it into something that runs reliably in a cluster. If we can containerize it, validate it, and run it as a Job, we've proven the path for similar community tooling.

## Setting up the PoC

The infrastructure requirements here are refreshingly minimal. This is a CPU-only toolkit that talks to GPU-backed servers over HTTP — the scripts themselves don't need a GPU.

- **Resource profile:** Small — 256Mi RAM, 250m CPU
- **GPU:** Not required
- **Inference server:** None (the project *benchmarks* inference servers; it doesn't include one)
- **Vector database:** None
- **Persistent storage:** None
- **Sidecar containers:** None
- **Deployment model:** Kubernetes Job (not a long-running Deployment)

The key decision was treating this as a Job-based PoC rather than trying to force it into a server model. These are CLI scripts that run, produce output, and exit. Jobs are the right abstraction.

--------------------
**[Image Placeholder 1: Architecture diagram showing the club-5060ti toolkit container running as a Kubernetes Job]**

**Placement rationale**: Readers benefit from seeing the simple architecture — a Job pod running validation scripts against bundled data, with a future arrow pointing toward an ODH inference endpoint.

**Image generation prompt**: A clean architectural diagram on a white background showing a Kubernetes Job pod labeled "club-5060ti scripts" containing icons for Python scripts and JSON data files. An arrow labeled "OpenAI API (future)" points from the pod toward a separate box labeled "ODH Model Serving (vLLM)". Use flat design, Red Hat brand colors (red #EE0000, dark gray #333), and a 16:9 aspect ratio. Include the OpenShift logo on the cluster boundary.

**Alt text**: Architecture diagram showing a Kubernetes Job pod containing Python benchmark scripts and JSON data, with a future integration arrow pointing to an OpenShift AI model-serving endpoint.
--------------------

## Containerizing with UBI

We built two images — one for the static site and one for the scripts — but the scripts image is where the interesting work happened. The challenge was packaging a loose collection of Python scripts, shell scripts, and JSON data into something that runs cleanly on a UBI base.

The Dockerfile uses `ubi9/python-311` as the base, copies in the full repository, and installs the Python dependencies. Since there's no `requirements.txt` in the upstream repo, we had to inspect the scripts' imports and pin the dependencies ourselves. The key packages are `aiohttp` and `jsonschema` — the former for the async OpenAI benchmark client, the latter for result validation.

```dockerfile
FROM registry.access.redhat.com/ubi9/python-311:latest

WORKDIR /opt/app-root/src

COPY . .

RUN pip install --no-cache-dir \
    aiohttp \
    jsonschema \
    && chmod +x scripts/*.sh

USER 1001

ENTRYPOINT ["python3"]
```

One detail worth noting: the `check_repo.sh` script assumes it's running from the repository root and checks for specific directory structures. By setting `WORKDIR` to the source root and copying everything in, we preserved those path assumptions without modification. Small thing, but it's the kind of detail that burns 30 minutes if you miss it.

## Deploying to Kubernetes

Each test scenario runs as a separate Kubernetes Job. The pattern is straightforward — override the container's command to run the specific script, set resource limits, and let it complete. Here's the Job manifest for the schema validation scenario:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: club-5060ti-validate-results
  labels:
    app: club-5060ti
    scenario: validate-results
spec:
  backoffLimit: 0
  activeDeadlineSeconds: 30
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: validate
          image: quay.io/aicatalyst/club-5060ti-scripts:latest
          command: ["python3", "scripts/validate_results.py", "data/results"]
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 250m
              memory: 256Mi
```

No Services, no PVCs, no Secrets, no sidecars. This is about as clean as a Kubernetes deployment gets. Each Job has `backoffLimit: 0` because we want to see failures immediately — no retries masking intermittent issues. The `activeDeadlineSeconds` acts as our test timeout.

The four Jobs were deployed sequentially, and we collected exit codes and logs from each. In a more mature setup, you'd orchestrate this with a Tekton Pipeline or an Argo Workflow, but for a PoC, `kubectl apply` followed by `kubectl wait` works fine.

--------------------
**[Image Placeholder 2: Terminal screenshot showing all four Jobs completing successfully]**

**Placement rationale**: Showing the actual Job completion output gives readers confidence in the results and a sense of what the workflow looks like in practice.

**Image generation prompt**: A dark terminal window (dark gray background #1e1e1e, monospace font) showing kubectl output for four completed Kubernetes Jobs. Each line shows a Job name (validate-results, build-site-data, bench-help, check-repo) with status "Complete" and duration under 1 second. Use green text (#4ec9b0) for the "Complete" status. 16:9 aspect ratio, slight drop shadow on the terminal window.

**Alt text**: Terminal output showing four Kubernetes Jobs — validate-results, build-site-data, bench-help, and check-repo — all completed successfully with sub-second durations.
--------------------

## Test results

All four scenarios passed cleanly on the first run:

| Scenario | Description | Status | Duration |
|----------|-------------|--------|----------|
| validate-results | JSON schema validation of all bundled benchmark results | ✅ PASS | 0.3s |
| build-site-data | Regenerate aggregated `results.json` from individual files | ✅ PASS | 0.5s |
| bench-help | Verify benchmark script starts and prints usage info | ✅ PASS | 0.3s |
| check-repo | Repository structure health-check | ✅ PASS | 0.3s |

**Overall: 4/4 passed.**

The sub-second durations reflect the lightweight nature of these scripts — they're validating local files and checking imports, not running actual inference benchmarks. The `bench-help` scenario confirmed that `run_openai_bench.py` is importable and exposes the expected CLI flags (`--base-url`, `--model`, `--concurrency`), which means it's ready to be pointed at a live inference endpoint.

The `build-site-data` scenario is slightly more interesting because it exercises the data aggregation pipeline — reading individual JSON result files and producing a combined dataset. At 0.5s, it was the "slowest" of the bunch, which gives you a sense of the scale we're working with.

No failures to report here, which is actually slightly unusual for our PoCs. The simplicity of the project — pure Python, no compiled dependencies, no GPU requirements — meant fewer things could go wrong during containerization.

--------------------
**[Image Placeholder 3: Results summary card showing 4/4 tests passed with the project details]**

**Placement rationale**: A visual summary card provides a scannable takeaway for readers who scroll to results first.

**Image generation prompt**: A clean summary card with a white background and subtle gray border. Header shows "club-5060ti PoC Results" in dark text. A large green checkmark icon sits next to "4/4 Tests Passed". Below, four rows show each test name with a small green dot and its duration. Footer shows "Resource profile: small (256Mi / 250m CPU) | No GPU required". Use flat design, 4:3 aspect ratio, Red Hat brand colors for accents.

**Alt text**: Summary card showing club-5060ti proof-of-concept results: four out of four tests passed, with durations ranging from 0.3 to 0.5 seconds, running on a small resource profile with no GPU required.
--------------------

## What we learned

**The toolkit containerizes cleanly, and that's the point.** The value here isn't in the benchmark results themselves — it's in proving that a community-maintained collection of scripts can be packaged into a portable, reproducible container that runs in any Kubernetes environment. The path from "scripts on a laptop" to "Jobs in a cluster" was smooth.

**The OpenAI-compatible benchmark harness has real potential.** The `run_openai_bench.py` script targets the same API surface as vLLM-based model serving in OpenShift AI. In a follow-up integration, you could deploy a model via ODH's KServe stack, then run this toolkit as a Job to benchmark throughput, latency at various concurrency levels, and token generation rates. That's a legitimate testing workflow.

**What we'd do differently:** We'd add a Tekton Pipeline to orchestrate the test scenarios instead of running Jobs manually. We'd also wire up a fifth scenario that actually hits a live inference endpoint — even a small model on CPU — to validate the end-to-end benchmark flow, not just the `--help` output.

**Is this production-ready?** As a standalone PoC, no — and it's not meant to be. The RHOAI fitness score of 38/100 is fair. The project is documentation and tooling, not a deployable ML workload. But as a *component* in a larger testing pipeline — specifically, as a benchmark harness for ODH inference deployments — it has a clear role. The gap is integration: connecting this toolkit to an actual model-serving endpoint and automating result collection.

**ODH components that would improve this:** A vLLM ServingRuntime would give the benchmark script something to talk to. Tekton Pipelines would orchestrate the run-benchmark-collect-results workflow. And S3-compatible storage (via ODH's MinIO or Ceph) would provide a natural place to persist benchmark results across runs.

## Try it yourself

If you want to reproduce this PoC or extend it with a live inference endpoint:

- **Forked repository:** [github.com/aicatalyst-team/club-5060ti](https://github.com/aicatalyst-team/club-5060ti.git) — includes the Dockerfiles and Job manifests we used
- **Container images:**
  - `quay.io/aicatalyst/club-5060ti-scripts:latest`
  - `quay.io/aicatalyst/club-5060ti-site:latest`
- **Original project:** [github.com/5p00kyy/club-5060ti](https://github.com/5p00kyy/club-5060ti)
- **Open Data Hub documentation:** [opendatahub.io/docs](https://opendatahub.io/docs)

Pull the scripts image, run the validation Job, and see for yourself. If you've got an OpenShift AI cluster with a vLLM endpoint, try pointing `run_openai_bench.py` at it — that's where this toolkit starts to earn its keep.
