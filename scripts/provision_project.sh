#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "$SCRIPT_DIR/common.sh"

TARGET_DIR="${1:-}"
if [[ -z "$TARGET_DIR" ]]; then
  echo "Usage: $(basename "$0") /path/to/project" >&2
  exit 1
fi
TARGET_DIR="$(cd -- "$TARGET_DIR" && pwd)"

mkdir -p "$TARGET_DIR/.julia"
copy_dir "$DEPOT_DIR/" "$TARGET_DIR/.julia/"

if [[ ! -f "$TARGET_DIR/AGENTS.md" ]]; then
  cp "$ROOT_DIR/AGENTS_TEMPLATE.md" "$TARGET_DIR/AGENTS.md"
fi

mkdir -p "$TARGET_DIR/scripts/agent"
cp "$SCRIPT_DIR/agent_run_julia.sh" "$TARGET_DIR/scripts/agent/run_julia.sh"
cp "$SCRIPT_DIR/agent_run_tests.sh" "$TARGET_DIR/scripts/agent/run_tests.sh"
chmod +x "$TARGET_DIR/scripts/agent"/*.sh

echo "Provisioned: $TARGET_DIR"
