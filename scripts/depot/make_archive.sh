#!/usr/bin/env bash
set -euo pipefail
THIS_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SCRIPTS_ROOT="$(cd -- "$THIS_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$SCRIPTS_ROOT/.." && pwd)"
DEPOT_DIR="$ROOT_DIR/.agent_julia_depot"
OUT="${1:-$ROOT_DIR/agent_julia_depot.tgz}"
tar -C "$DEPOT_DIR" -czf "$OUT" .
echo "Wrote $OUT"
