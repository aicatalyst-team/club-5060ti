#!/usr/bin/env bash
set -euo pipefail

URL=""
MODEL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url)
      URL="$2"
      shift 2
      ;;
    --model)
      MODEL="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: bash scripts/report.sh --url http://127.0.0.1:8000 --model model-name"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

BASE_URL=$(printf '%s' "$URL" | sed 's#/*$##')
if [[ "$BASE_URL" == */v1 ]]; then
  API_BASE="$BASE_URL"
  HEALTH_BASE=$(printf '%s' "$BASE_URL" | sed 's#/v1$##')
else
  API_BASE="$BASE_URL/v1"
  HEALTH_BASE="$BASE_URL"
fi

echo "# club-5060ti result report"
echo
echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo
echo "## Hardware"
echo
if command -v nvidia-smi >/dev/null 2>&1; then
  echo '~~~text'
  nvidia-smi --query-gpu=index,name,pci.bus_id,pcie.link.gen.current,pcie.link.gen.max,pcie.link.width.current,pcie.link.width.max,memory.total,driver_version,power.limit --format=csv,noheader || true
  echo '~~~'
else
  echo "nvidia-smi not found."
fi
echo
if [[ -r /sys/class/dmi/id/product_name ]]; then
  echo "System: $(cat /sys/class/dmi/id/product_name)"
fi
if [[ -r /sys/class/dmi/id/board_vendor && -r /sys/class/dmi/id/board_name ]]; then
  echo "Motherboard: $(cat /sys/class/dmi/id/board_vendor) $(cat /sys/class/dmi/id/board_name)"
fi
if command -v lscpu >/dev/null 2>&1; then
  CPU_MODEL=$(lscpu | awk -F: '/Model name/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')
  if [[ -n "$CPU_MODEL" ]]; then
    echo "CPU: $CPU_MODEL"
  else
    echo "CPU: $(uname -m)"
  fi
else
  echo "CPU: $(uname -m)"
fi
echo "Kernel: $(uname -sr)"
if command -v free >/dev/null 2>&1; then
  echo "RAM: $(free -h | awk '/^Mem:/ {print $2}')"
fi
echo
echo "## Endpoint"
echo
echo "- Health URL: $HEALTH_BASE/health"
echo "- API URL: $API_BASE"
if [[ -n "$MODEL" ]]; then
  echo "- Model: $MODEL"
else
  echo "- Model: not provided"
fi
echo
if [[ -n "$URL" ]]; then
  echo "### Health"
  echo
  if curl -fsS --max-time 10 "$HEALTH_BASE/health" >/tmp/club5060ti-health.$$ 2>/tmp/club5060ti-health-err.$$; then
    echo '~~~text'
    cat /tmp/club5060ti-health.$$
    echo
    echo '~~~'
  else
    echo '~~~text'
    cat /tmp/club5060ti-health-err.$$ || true
    echo '~~~'
  fi
  rm -f /tmp/club5060ti-health.$$ /tmp/club5060ti-health-err.$$
fi
echo
if [[ -n "$URL" && -n "$MODEL" ]]; then
  echo "### Smoke"
  echo
  echo '~~~json'
  python3 scripts/openai_compat_smoke.py --base-url "$API_BASE" --model "$MODEL" || true
  echo '~~~'
  echo
  echo "### Decode Bench"
  echo
  echo '~~~json'
  python3 scripts/simple_decode_bench.py --base-url "$API_BASE" --model "$MODEL" --max-tokens 256 || true
  echo '~~~'
fi
echo
echo "## Launch Config"
echo
echo "Paste sanitized launch command/config here."
echo
echo "## Notes"
echo
echo "- Context length:"
echo "- KV cache:"
echo "- Tensor parallel / split:"
echo "- PCIe layout / link width:"
echo "- Thinking enabled:"
echo "- Warnings/caveats:"
