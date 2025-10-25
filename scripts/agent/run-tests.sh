#!/usr/bin/env bash
set -euo pipefail
PROJ_DIR="$PWD"
if [[ ! -f "$PROJ_DIR/Project.toml" && -f "$PROJ_DIR/../Project.toml" ]]; then
  PROJ_DIR="$PROJ_DIR/.."
fi
export JULIA_DEPOT_PATH="$PROJ_DIR/.julia"
export JULIAUP_DEPOT_PATH="$PROJ_DIR/.juliaup"
export JULIAUP_HOME="$PROJ_DIR/.juliaup"
exec julia --color=yes --project="$PROJ_DIR" -e 'using Pkg; Pkg.test()'
