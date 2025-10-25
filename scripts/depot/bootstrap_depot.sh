#!/usr/bin/env bash
set -euo pipefail
THIS_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "$THIS_DIR/../common.sh"

if [[ ! -f "$PACKAGES_FILE" ]]; then
  echo "packages.toml not found at $PACKAGES_FILE" >&2
  exit 1
fi

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

prewarm_juliaup_cache() {
  echo "Prewarming Julia toolchain metadata via Juliaup..."
  if output="$("$THIS_DIR/run_shared_julia.sh" --version 2>&1)"; then
    echo "$output"
  else
    echo "Warning: Juliaup prewarm failed: $output" >&2
  fi
}

prewarm_juliaup_cache
