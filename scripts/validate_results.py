#!/usr/bin/env python3
import argparse
import json
import sys
from pathlib import Path


REQUIRED_TOP = {
    "schema_version",
    "id",
    "timestamp_utc",
    "source",
    "promotion_level",
    "hardware",
    "runtime",
    "model",
    "serving",
    "benchmark",
    "metrics",
}

PROMOTION_LEVELS = {"exploratory", "recipe", "benchmark", "verified", "deprecated"}
ENGINES = {"llama.cpp", "ik_llama.cpp", "BeeLlama", "vLLM", "SGLang", "other"}
PROMPT_SETS = {
    "short-chat",
    "code-generate",
    "agent-tool",
    "long-retrieval",
    "vision-smoke",
    "legacy",
    "custom",
}


def load_results(path):
    with path.open("r", encoding="utf-8") as handle:
        data = json.load(handle)
    if isinstance(data, list):
        return data
    if isinstance(data, dict) and "results" in data:
        results = data["results"]
        if not isinstance(results, list):
            raise ValueError(f"{path}: results must be a list")
        return results
    if isinstance(data, dict):
        return [data]
    raise ValueError(f"{path}: expected object, list, or object with results")


def require(condition, errors, message):
    if not condition:
        errors.append(message)


def validate_result(result, label):
    errors = []
    require(isinstance(result, dict), errors, f"{label}: result must be an object")
    if errors:
        return errors

    missing = sorted(REQUIRED_TOP - set(result))
    require(not missing, errors, f"{label}: missing required fields: {', '.join(missing)}")
    require(result.get("schema_version") == "1.0", errors, f"{label}: schema_version must be 1.0")
    require(result.get("promotion_level") in PROMOTION_LEVELS, errors, f"{label}: invalid promotion_level")

    source = result.get("source") or {}
    require(isinstance(source, dict), errors, f"{label}: source must be an object")
    require(bool(source.get("type")), errors, f"{label}: source.type is required")
    require(bool(source.get("label")), errors, f"{label}: source.label is required")

    hardware = result.get("hardware") or {}
    require(isinstance(hardware, dict), errors, f"{label}: hardware must be an object")
    require(isinstance(hardware.get("gpu_count"), int), errors, f"{label}: hardware.gpu_count must be an integer")
    require(bool(hardware.get("gpu_model")), errors, f"{label}: hardware.gpu_model is required")
    require(isinstance(hardware.get("vram_per_gpu_gb"), (int, float)), errors, f"{label}: hardware.vram_per_gpu_gb must be numeric")

    runtime = result.get("runtime") or {}
    require(runtime.get("engine") in ENGINES, errors, f"{label}: runtime.engine is invalid")

    model = result.get("model") or {}
    require(bool(model.get("id")), errors, f"{label}: model.id is required")
    require(bool(model.get("family")), errors, f"{label}: model.family is required")
    require(bool(model.get("quant")), errors, f"{label}: model.quant is required")

    benchmark = result.get("benchmark") or {}
    require(benchmark.get("prompt_set") in PROMPT_SETS, errors, f"{label}: benchmark.prompt_set is invalid")

    metrics = result.get("metrics") or {}
    metric_names = {"prompt_tok_s", "decode_tok_s", "end_to_end_tok_s", "wall_seconds", "ttft_seconds", "load_seconds", "quality_score"}
    for name in metric_names:
        if name in metrics and metrics[name] is not None:
            require(isinstance(metrics[name], (int, float)), errors, f"{label}: metrics.{name} must be numeric")

    return errors


def main():
    parser = argparse.ArgumentParser(description="Validate club-5060ti result JSON files.")
    parser.add_argument("paths", nargs="+", help="JSON files or directories under data/results")
    args = parser.parse_args()

    files = []
    for raw in args.paths:
        path = Path(raw)
        if path.is_dir():
            files.extend(sorted(path.glob("*.json")))
        else:
            files.append(path)

    all_errors = []
    count = 0
    for path in files:
        try:
            results = load_results(path)
        except Exception as exc:
            all_errors.append(str(exc))
            continue
        for index, result in enumerate(results):
            count += 1
            label = f"{path}:{index}"
            all_errors.extend(validate_result(result, label))

    if all_errors:
        for error in all_errors:
            print(error, file=sys.stderr)
        return 1

    print(f"validated {count} result(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
