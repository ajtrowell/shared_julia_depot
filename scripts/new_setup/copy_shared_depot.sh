#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
TARGET_DIR="${1:-$PWD}"
TARGET_DIR="$(cd -- "$TARGET_DIR" && pwd)"

source "$THIS_DIR/../common.sh"

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

mkdir -p "$TARGET_DIR/.julia"
copy_dir "$SHARED_DEPOT/" "$TARGET_DIR/.julia/"
set_owner_to_invoker "$TARGET_DIR/.julia"

mkdir -p "$TARGET_DIR/.juliaup"
copy_dir "$SHARED_JULIAUP/" "$TARGET_DIR/.juliaup/"
set_owner_to_invoker "$TARGET_DIR/.juliaup"

if [[ ! -f "$TARGET_DIR/AGENTS.md" ]]; then
  cp "$ROOT_DIR/AGENTS_TEMPLATE.md" "$TARGET_DIR/AGENTS.md"
fi
if [[ -f "$TARGET_DIR/AGENTS.md" ]]; then
  set_owner_to_invoker "$TARGET_DIR/AGENTS.md"
fi

"$THIS_DIR/copy_agent_scripts.sh" "$TARGET_DIR"

echo "Copied shared depot into $TARGET_DIR/.julia and Juliaup metadata into $TARGET_DIR/.juliaup, then installed agent scaffolding."
