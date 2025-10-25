#!/usr/bin/env bash
set -euo pipefail

COMMON_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SCRIPTS_ROOT="$COMMON_DIR"
ROOT_DIR="$(cd -- "$COMMON_DIR/.." && pwd)"
DEPOT_DIR="${DEPOT_DIR:-"$ROOT_DIR/.agent_julia_depot"}"
JULIAUP_DEPOT_DIR="${JULIAUP_DEPOT_DIR:-"$ROOT_DIR/.agent_juliaup_depot"}"
HOST_JULIAUP_DIR="${HOST_JULIAUP_DIR:-"$HOME/.juliaup"}"
HOST_JULIAUP_TOOLCHAINS_DIR="${HOST_JULIAUP_TOOLCHAINS_DIR:-"$HOME/.julia/juliaup"}"
JULIA_BIN="${JULIA_BIN:-julia}"
PACKAGES_FILE="${PACKAGES_FILE:-"$ROOT_DIR/packages.toml"}"

export JULIA_DEPOT_PATH="$DEPOT_DIR"
mkdir -p "$DEPOT_DIR"
mkdir -p "$JULIAUP_DEPOT_DIR"

have_cmd() { command -v "$1" >/dev/null 2>&1; }

copy_dir() {
  local src="$1" dst="$2"
  mkdir -p "$dst"
  if have_cmd rsync; then
    rsync -a --delete "$src" "$dst"
  else
    (cd "$src" && tar cf - .) | (cd "$dst" && tar xpf -)
  fi
}
