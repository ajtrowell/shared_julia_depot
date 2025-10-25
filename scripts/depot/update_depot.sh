#!/usr/bin/env bash
set -euo pipefail
THIS_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "$THIS_DIR/../common.sh"
"$JULIA_BIN" --color=yes --project=@stdlib "$THIS_DIR/bootstrap_depot.jl"
