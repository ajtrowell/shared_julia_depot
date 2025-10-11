#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
DEPOT_DIR="$ROOT_DIR/.agent_julia_depot"
OUT="${1:-$ROOT_DIR/agent_julia_depot.tgz}"
tar -C "$DEPOT_DIR" -czf "$OUT" .
echo "Wrote $OUT"
