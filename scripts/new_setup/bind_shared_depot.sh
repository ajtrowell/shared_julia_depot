#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
TARGET_DIR="${1:-$PWD}"
TARGET_DIR="$(cd -- "$TARGET_DIR" && pwd)"
BIND_MOUNT_CMD="${BIND_MOUNT_CMD:-mount}"
BIND_MOUNT_PRIVATE="${BIND_MOUNT_PRIVATE:-0}"

source "$THIS_DIR/../common.sh"

SHARED_DEPOT="$DEPOT_DIR"
if [[ ! -d "$SHARED_DEPOT" ]]; then
  echo "Shared depot not found at $SHARED_DEPOT" >&2
  exit 1
fi

if mountpoint -q "$TARGET_DIR/.julia"; then
  echo "$TARGET_DIR/.julia is already a mountpoint; unmount before re-running." >&2
  exit 1
fi

rm -rf "$TARGET_DIR/.julia"
mkdir -p "$TARGET_DIR/.julia"

if [[ "$EUID" -ne 0 ]]; then
  echo "Note: bind mounting typically requires elevated privileges; you may need to re-run with sudo." >&2
fi

"$BIND_MOUNT_CMD" --bind "$SHARED_DEPOT" "$TARGET_DIR/.julia"
if [[ "$BIND_MOUNT_PRIVATE" -eq 1 ]]; then
  "$BIND_MOUNT_CMD" --make-private "$TARGET_DIR/.julia"
fi

if [[ ! -f "$TARGET_DIR/AGENTS.md" ]]; then
  cp "$ROOT_DIR/AGENTS_TEMPLATE.md" "$TARGET_DIR/AGENTS.md"
fi

"$THIS_DIR/copy_agent_scripts.sh" "$TARGET_DIR"

echo "Bind-mounted $TARGET_DIR/.julia to $SHARED_DEPOT and installed agent scaffolding."
