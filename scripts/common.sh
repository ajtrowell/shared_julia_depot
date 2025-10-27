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

UNAME="$(uname -s)"

is_macos() { [[ "$UNAME" == "Darwin" ]]; }
is_linux() { [[ "$UNAME" == "Linux" ]]; }

export JULIA_DEPOT_PATH="$DEPOT_DIR"
mkdir -p "$DEPOT_DIR"
mkdir -p "$JULIAUP_DEPOT_DIR"

have_cmd() { command -v "$1" >/dev/null 2>&1; }

stat_field() {
  local fmt_linux="$1" fmt_macos="$2" target="$3"
  local result=""
  if is_macos; then
    result="$(stat -f "$fmt_macos" "$target" 2>/dev/null || true)"
  else
    result="$(stat -c "$fmt_linux" "$target" 2>/dev/null || true)"
  fi
  printf '%s' "$result"
}

stat_uid() { stat_field '%u' '%u' "$1"; }
stat_gid() { stat_field '%g' '%g' "$1"; }
stat_dev() { stat_field '%d' '%d' "$1"; }

is_mountpoint() {
  local candidate="${1:-}"
  if [[ -z "$candidate" ]]; then
    return 1
  fi
  if [[ ! -e "$candidate" ]]; then
    return 1
  fi
  if is_linux && have_cmd mountpoint; then
    mountpoint -q "$candidate"
    return $?
  fi
  local abs_path parent_path path_dev parent_dev
  abs_path="$(cd -- "$candidate" && pwd)"
  parent_path="$(cd -- "$(dirname "$abs_path")" && pwd)"
  path_dev="$(stat_dev "$abs_path")"
  parent_dev="$(stat_dev "$parent_path")"
  [[ -n "$path_dev" && -n "$parent_dev" && "$path_dev" != "$parent_dev" ]]
}

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
    uid="$(stat_uid "$target")"
  fi
  if [[ -z "$gid" ]]; then
    if [[ -n "${SUDO_USER:-}" ]]; then
      gid="$(id -g "$SUDO_USER" 2>/dev/null || true)"
    fi
  fi
  if [[ -z "$gid" ]]; then
    gid="$(stat_gid "$target")"
  fi
  if [[ -n "$uid" ]]; then
    if [[ -n "$gid" ]]; then
      chown -R "$uid:$gid" "$target"
    else
      chown -R "$uid" "$target"
    fi
  fi
}
