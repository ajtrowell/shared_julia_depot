#!/usr/bin/env bash
set -euo pipefail
PROJ_DIR="$PWD"
if [[ ! -f "$PROJ_DIR/Project.toml" && -f "$PROJ_DIR/../Project.toml" ]]; then
  PROJ_DIR="$PROJ_DIR/.."
fi
export JULIA_DEPOT_PATH="$PROJ_DIR/.julia"
exec julia --color=yes --project="$PROJ_DIR" -e 'using Pkg; Pkg.test()'
