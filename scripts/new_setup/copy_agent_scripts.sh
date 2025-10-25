#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "$SCRIPT_DIR/../common.sh"
AGENT_SRC_DIR="$(cd -- "$SCRIPT_DIR/../agent" && pwd)"

TARGET_DIR="${1:-$PWD}"
mkdir -p "$TARGET_DIR/scripts/agent"
cp "$AGENT_SRC_DIR/run-julia.sh" "$TARGET_DIR/scripts/agent/run-julia.sh"
cp "$AGENT_SRC_DIR/run-tests.sh" "$TARGET_DIR/scripts/agent/run-tests.sh"
chmod +x "$TARGET_DIR/scripts/agent"/*.sh
set_owner_to_invoker "$TARGET_DIR/scripts"
set_owner_to_invoker "$TARGET_DIR/scripts/agent"
echo "Copied agent scripts to $TARGET_DIR/scripts/agent"
