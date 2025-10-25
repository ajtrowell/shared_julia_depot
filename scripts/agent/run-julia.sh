#!/usr/bin/env bash
set -euo pipefail

resolve_vendored_julia() {
  local project_root="$1"
  local toolchains="$project_root/.julia/juliaup"
  local meta=""
  for candidate in "$project_root/.juliaup/juliaup.json" \
                   "$project_root/.juliaup/juliaup/juliaup.json"; do
    if [[ -f "$candidate" ]]; then
      meta="$candidate"
      break
    fi
  done
  if [[ -z "$meta" ]]; then
    echo "Expected Juliaup metadata under $project_root/.juliaup" >&2
    return 1
  fi
  if [[ ! -d "$toolchains" ]]; then
    echo "Expected Julia toolchains at $toolchains" >&2
    return 1
  fi
  if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 is required to resolve the vendored Julia binary." >&2
    return 1
  fi
  python3 - "$meta" "$toolchains" <<'PY' || exit 1
import json
import os
import sys
from pathlib import Path

meta = Path(sys.argv[1])
toolchains = Path(sys.argv[2])
data = json.loads(meta.read_text())
channel = data.get("Default")
version = None
if channel:
    version = data.get("InstalledChannels", {}).get(channel, {}).get("Version")
if version is None:
    installed = data.get("InstalledVersions") or {}
    if installed:
        version = next(iter(installed))
if version is None:
    print("Unable to determine Julia version from juliaup metadata", file=sys.stderr)
    sys.exit(1)
entry = data.get("InstalledVersions", {}).get(version, {}).get("Path")
if not entry:
    print(f"Toolchain path missing for version {version}", file=sys.stderr)
    sys.exit(1)
if entry.startswith("./"):
    entry = entry[2:]
binary = toolchains / entry / "bin" / "julia"
binary = binary.resolve()
if not binary.exists():
    print(f"Julia binary not found at {binary}", file=sys.stderr)
    sys.exit(1)
print(binary)
PY
}

PROJ_DIR="$PWD"
if [[ ! -f "$PROJ_DIR/Project.toml" && -f "$PROJ_DIR/../Project.toml" ]]; then
  PROJ_DIR="$PROJ_DIR/.."
fi

export JULIA_DEPOT_PATH="$PROJ_DIR/.julia"

JULIA_BIN_PATH="$(resolve_vendored_julia "$PROJ_DIR")"

exec "$JULIA_BIN_PATH" --color=yes --project="$PROJ_DIR" "$@"
