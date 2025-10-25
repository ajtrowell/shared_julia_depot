#!/usr/bin/env bash
set -euo pipefail
THIS_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "$THIS_DIR/../common.sh"
"$JULIA_BIN" --color=yes --project=@stdlib "$THIS_DIR/bootstrap_depot.jl"

sync_juliaup_payload() {
  if [[ -d "$HOST_JULIAUP_DIR" ]]; then
    echo "Syncing Juliaup metadata from $HOST_JULIAUP_DIR -> $JULIAUP_DEPOT_DIR"
    copy_dir "$HOST_JULIAUP_DIR/" "$JULIAUP_DEPOT_DIR/"
  else
    echo "Warning: HOST_JULIAUP_DIR ($HOST_JULIAUP_DIR) not found; skipping Juliaup metadata copy." >&2
  fi
  if [[ -d "$HOST_JULIAUP_TOOLCHAINS_DIR" ]]; then
    echo "Syncing Julia toolchains from $HOST_JULIAUP_TOOLCHAINS_DIR -> $DEPOT_DIR/juliaup"
    copy_dir "$HOST_JULIAUP_TOOLCHAINS_DIR/" "$DEPOT_DIR/juliaup/"
  else
    echo "Warning: HOST_JULIAUP_TOOLCHAINS_DIR ($HOST_JULIAUP_TOOLCHAINS_DIR) not found; skipping Julia binaries copy." >&2
  fi
}

sync_juliaup_payload
