#!/usr/bin/env bash
set -euo pipefail
THIS_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SCRIPTS_ROOT="$(cd -- "$THIS_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$SCRIPTS_ROOT/.." && pwd)"
DEPOT_DIR="$ROOT_DIR/.agent_julia_depot"
JULIAUP_DEPOT_DIR="$ROOT_DIR/.agent_juliaup_depot"
OUT="${1:-$ROOT_DIR/agent_julia_assets.tgz}"

if [[ ! -d "$DEPOT_DIR" ]]; then
  echo "Depot directory not found at $DEPOT_DIR" >&2
  exit 1
fi

if [[ ! -d "$JULIAUP_DEPOT_DIR" ]]; then
  echo "Juliaup directory not found at $JULIAUP_DEPOT_DIR" >&2
  exit 1
fi

tar -C "$ROOT_DIR" -czf "$OUT" .agent_julia_depot .agent_juliaup_depot
echo "Wrote $OUT"
