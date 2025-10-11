#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "$SCRIPT_DIR/common.sh"

if [[ ! -f "$PACKAGES_FILE" ]]; then
  echo "packages.toml not found at $PACKAGES_FILE" >&2
  exit 1
fi

"$JULIA_BIN" --color=yes --project=@stdlib "$SCRIPT_DIR/bootstrap_depot.jl"
