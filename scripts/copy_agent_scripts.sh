#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

TARGET_DIR="${1:-$PWD}"
mkdir -p "$TARGET_DIR/scripts/agent"
cp "$SCRIPT_DIR/agent_run_julia.sh" "$TARGET_DIR/scripts/agent/run_julia.sh"
cp "$SCRIPT_DIR/agent_run_tests.sh" "$TARGET_DIR/scripts/agent/run_tests.sh"
chmod +x "$TARGET_DIR/scripts/agent"/*.sh
echo "Copied agent scripts to $TARGET_DIR/scripts/agent"
