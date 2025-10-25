#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "$THIS_DIR/../common.sh"

export JULIA_DEPOT_PATH="$DEPOT_DIR"
export JULIAUP_DEPOT_PATH="$JULIAUP_DEPOT_DIR"
export JULIAUP_HOME="$JULIAUP_DEPOT_DIR"

"$JULIA_BIN" --color=yes "$@"
