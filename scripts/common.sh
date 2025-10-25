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

set_owner_to_invoker() {
  local target="$1"
  [[ -e "$target" ]] || return 0
  if [[ "$(id -u)" -ne 0 ]]; then
    return 0
  fi
  local uid="${SUDO_UID:-}"
  local gid="${SUDO_GID:-}"
  if [[ -z "$uid" ]]; then
    uid="$(stat -c '%u' "$target" 2>/dev/null || true)"
  fi
  if [[ -z "$gid" ]]; then
    if [[ -n "${SUDO_USER:-}" ]]; then
      gid="$(id -g "$SUDO_USER" 2>/dev/null || true)"
    fi
  fi
  if [[ -z "$gid" ]]; then
    gid="$(stat -c '%g' "$target" 2>/dev/null || true)"
  fi
  if [[ -n "$uid" ]]; then
    if [[ -n "$gid" ]]; then
      chown -R "$uid:$gid" "$target"
    else
      chown -R "$uid" "$target"
    fi
  fi
}
