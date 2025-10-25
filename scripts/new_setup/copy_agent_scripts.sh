#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "$SCRIPT_DIR/../common.sh"
AGENT_SRC_DIR="$(cd -- "$SCRIPT_DIR/../agent" && pwd)"
LIB_SRC_DIR="$(cd -- "$SCRIPT_DIR/../lib" && pwd)"

TARGET_DIR="${1:-$PWD}"
mkdir -p "$TARGET_DIR/scripts/agent"
mkdir -p "$TARGET_DIR/scripts/lib"
cp "$AGENT_SRC_DIR/run-julia.sh" "$TARGET_DIR/scripts/agent/run-julia.sh"
cp "$AGENT_SRC_DIR/run-tests.sh" "$TARGET_DIR/scripts/agent/run-tests.sh"
cp "$LIB_SRC_DIR/resolve_vendored_julia.py" "$TARGET_DIR/scripts/lib/resolve_vendored_julia.py"
chmod +x "$TARGET_DIR/scripts/agent"/*.sh
chmod +x "$TARGET_DIR/scripts/lib/"*.py
set_owner_to_invoker "$TARGET_DIR/scripts"
set_owner_to_invoker "$TARGET_DIR/scripts/agent"
set_owner_to_invoker "$TARGET_DIR/scripts/lib"
echo "Copied agent scripts to $TARGET_DIR/scripts/agent"
