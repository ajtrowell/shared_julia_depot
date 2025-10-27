#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
TARGET_DIR="${1:-$PWD}"
TARGET_DIR="$(cd -- "$TARGET_DIR" && pwd)"
BIND_MOUNT_CMD="${BIND_MOUNT_CMD:-mount}"
BIND_MOUNT_PRIVATE="${BIND_MOUNT_PRIVATE:-0}"

source "$THIS_DIR/../common.sh"

warned_private=0

mount_depot() {
  local src="$1" dst="$2"
  if is_linux; then
    "$BIND_MOUNT_CMD" --bind "$src" "$dst"
    if [[ "$BIND_MOUNT_PRIVATE" -eq 1 ]]; then
      "$BIND_MOUNT_CMD" --make-private "$dst"
    fi
  elif is_macos; then
    "$BIND_MOUNT_CMD" -t nullfs "$src" "$dst"
    if [[ "$BIND_MOUNT_PRIVATE" -eq 1 && "$warned_private" -eq 0 ]]; then
      echo "BIND_MOUNT_PRIVATE is not supported on macOS; ignoring the flag." >&2
      warned_private=1
    fi
  else
    echo "Unsupported platform for bind mounting: $UNAME" >&2
    exit 1
  fi
}

SHARED_DEPOT="$DEPOT_DIR"
SHARED_JULIAUP="$JULIAUP_DEPOT_DIR"
if [[ ! -d "$SHARED_DEPOT" ]]; then
  echo "Shared depot not found at $SHARED_DEPOT" >&2
  exit 1
fi
if [[ ! -d "$SHARED_JULIAUP" ]]; then
  echo "Shared Juliaup metadata not found at $SHARED_JULIAUP" >&2
  exit 1
fi

if is_mountpoint "$TARGET_DIR/.julia"; then
  echo "$TARGET_DIR/.julia is already a mountpoint; unmount before re-running." >&2
  exit 1
fi
if is_mountpoint "$TARGET_DIR/.juliaup"; then
  echo "$TARGET_DIR/.juliaup is already a mountpoint; unmount before re-running." >&2
  exit 1
fi

rm -rf "$TARGET_DIR/.julia" "$TARGET_DIR/.juliaup"
mkdir -p "$TARGET_DIR/.julia" "$TARGET_DIR/.juliaup"

if [[ "$EUID" -ne 0 ]]; then
  if is_macos; then
    echo "Note: bind mounting typically requires elevated privileges; you may need to re-run with sudo (e.g. sudo /sbin/mount)." >&2
  else
    echo "Note: bind mounting typically requires elevated privileges; you may need to re-run with sudo." >&2
  fi
fi

mount_depot "$SHARED_DEPOT" "$TARGET_DIR/.julia"
mount_depot "$SHARED_JULIAUP" "$TARGET_DIR/.juliaup"

if [[ ! -f "$TARGET_DIR/AGENTS.md" ]]; then
  cp "$ROOT_DIR/AGENTS_TEMPLATE.md" "$TARGET_DIR/AGENTS.md"
fi
if [[ -f "$TARGET_DIR/AGENTS.md" ]]; then
  set_owner_to_invoker "$TARGET_DIR/AGENTS.md"
fi

"$THIS_DIR/copy_agent_scripts.sh" "$TARGET_DIR"

echo "Bind-mounted $TARGET_DIR/.julia to $SHARED_DEPOT and $TARGET_DIR/.juliaup to $SHARED_JULIAUP, then installed agent scaffolding."
