#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "$SCRIPT_DIR/common.sh"

BIND_MOUNT_DEPOT="${BIND_MOUNT_DEPOT:-}"
BIND_MOUNT_PRIVATE="${BIND_MOUNT_PRIVATE:-0}"
BIND_MOUNT_CMD="${BIND_MOUNT_CMD:-mount}"

TARGET_DIR="${1:-}"
if [[ -z "$TARGET_DIR" ]]; then
  echo "Usage: $(basename "$0") /path/to/project" >&2
  exit 1
fi
TARGET_DIR="$(cd -- "$TARGET_DIR" && pwd)"

if [[ -n "$BIND_MOUNT_DEPOT" ]]; then
  if [[ ! -d "$BIND_MOUNT_DEPOT" ]]; then
    echo "BIND_MOUNT_DEPOT must point to an existing depot directory" >&2
    exit 1
  fi
  if [[ "$EUID" -ne 0 ]]; then
    echo "Note: bind mounting typically requires root privileges. Re-run with sudo if this fails." >&2
  fi
  if mountpoint -q "$TARGET_DIR/.julia"; then
    echo "$TARGET_DIR/.julia is already a mountpoint; unmount it before re-provisioning." >&2
    exit 1
  fi
  rm -rf "$TARGET_DIR/.julia"
  mkdir -p "$TARGET_DIR/.julia"
  "$BIND_MOUNT_CMD" --bind "$BIND_MOUNT_DEPOT" "$TARGET_DIR/.julia"
  if [[ "$BIND_MOUNT_PRIVATE" -eq 1 ]]; then
    "$BIND_MOUNT_CMD" --make-private "$TARGET_DIR/.julia"
  fi
else
  mkdir -p "$TARGET_DIR/.julia"
  copy_dir "$DEPOT_DIR/" "$TARGET_DIR/.julia/"
fi

if [[ ! -f "$TARGET_DIR/AGENTS.md" ]]; then
  cp "$ROOT_DIR/AGENTS_TEMPLATE.md" "$TARGET_DIR/AGENTS.md"
fi

mkdir -p "$TARGET_DIR/scripts/agent"
cp "$SCRIPT_DIR/agent_run_julia.sh" "$TARGET_DIR/scripts/agent/run_julia.sh"
cp "$SCRIPT_DIR/agent_run_tests.sh" "$TARGET_DIR/scripts/agent/run_tests.sh"
chmod +x "$TARGET_DIR/scripts/agent"/*.sh

echo "Provisioned: $TARGET_DIR"
