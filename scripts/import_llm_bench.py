#!/usr/bin/env python3
import argparse
import json
import re
from datetime import datetime, timezone
from pathlib import Path


KEEP_FAMILIES = ("Qwen3.5", "Qwen3.6", "Gemma4", "Gemma 4")


def slugify(value):
    value = value.lower()
    value = re.sub(r"[^a-z0-9._-]+", "-", value)
    return value.strip("-") or "result"


def family_for(item):
    family = item.get("family") or ""
    name = item.get("name") or item.get("id") or ""
    combined = f"{family} {name}"
    for keep in KEEP_FAMILIES:
        if keep in combined:
            return keep.replace(" ", "")
    return ""


def arch_for(item):
    arch = item.get("arch") or "unknown"
    if arch in {"dense", "moe"}:
        return arch
    return "unknown"


def convert(item, source_label, timestamp):
    family = family_for(item)
    model_id = item.get("id") or item.get("name") or "unknown"
    context_k = item.get("context_k")
    context_tokens = int(context_k * 1024) if isinstance(context_k, (int, float)) else None
    gpu_count = 2
    gpu_label = item.get("gpus") or ""
    match = re.search(r"(\d+)x", gpu_label)
    if match:
        gpu_count = int(match.group(1))

    return {
        "schema_version": "1.0",
        "id": f"llm-bench-import-{slugify(model_id)}",
        "timestamp_utc": timestamp,
        "source": {
            "type": "imported",
            "label": source_label,
            "notes": "Imported from the old llm-bench summary data. Re-benchmark before promoting.",
        },
        "promotion_level": "deprecated",
        "hardware": {
            "gpu_count": gpu_count,
            "gpu_model": "RTX 5060 Ti",
            "vram_per_gpu_gb": 16,
            "driver": "",
            "cpu": "",
            "host_ram_gb": None,
            "inference_ram_gb": 60,
            "pcie": "",
            "notes": item.get("gpus") or "",
        },
        "runtime": {
            "engine": "llama.cpp",
            "notes": "Legacy llm-bench entry; exact runtime commit may be absent.",
        },
        "model": {
            "id": model_id,
            "family": family,
            "architecture": arch_for(item),
            "parameter_class": item.get("params") or "",
            "quant": item.get("quant") or "unknown",
            "file_size_mb": item.get("file_size_mb"),
            "notes": item.get("notes") or "",
        },
        "serving": {
            "route": "server",
            "context_tokens": context_tokens,
            "notes": "Imported legacy row; launch command not captured in schema form.",
        },
        "benchmark": {
            "prompt_set": "legacy",
            "configured_context_tokens": context_tokens,
            "runs": 1,
            "warmups": 0,
            "stream": False,
            "notes": "Legacy llm-bench prompt mix; not comparable with the new protocol.",
        },
        "metrics": {
            "prompt_tok_s": item.get("pp_tok_s"),
            "decode_tok_s": item.get("gen_tok_s"),
            "load_seconds": item.get("load_time_s"),
        },
        "caveats": [
            "Legacy import only; redo under docs/benchmark-protocol.md before using in headline comparisons.",
            "Importer keeps only rows selected for the migration pass; the old source repo remains the provenance archive.",
        ],
    }


def strip_nones(value):
    if isinstance(value, dict):
        return {key: strip_nones(item) for key, item in value.items() if item is not None and item != ""}
    if isinstance(value, list):
        return [strip_nones(item) for item in value if item is not None and item != ""]
    return value


def main():
    parser = argparse.ArgumentParser(description="Import selected newer llm-bench rows into the club-5060ti result schema.")
    parser.add_argument("--summary", required=True, help="Path to old llm-bench data/summary.json")
    parser.add_argument("--output", required=True)
    parser.add_argument("--source-label", default="llm-bench legacy import")
    args = parser.parse_args()

    summary = json.loads(Path(args.summary).read_text(encoding="utf-8"))
    timestamp = datetime.now(timezone.utc).isoformat()
    converted = []
    for item in summary.get("models", []):
        if family_for(item):
            converted.append(strip_nones(convert(item, args.source_label, timestamp)))

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps({"results": converted}, indent=2) + "\n", encoding="utf-8")
    print(f"imported {len(converted)} result(s) to {output}")


if __name__ == "__main__":
    raise SystemExit(main())
