#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "$SCRIPT_DIR/common.sh"
"$JULIA_BIN" --color=yes --project=@stdlib "$SCRIPT_DIR/bootstrap_depot.jl"
