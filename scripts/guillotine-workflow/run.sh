#!/usr/bin/env bash
# Run the Guillotine build workflow
# Usage: ./run.sh [phase] [target]
# Example: ./run.sh phase0_db effect

set -euo pipefail

PHASE="${1:-phase0_db}"
TARGET="${2:-zig}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$SCRIPT_DIR"

# Use CLI agents, not API agents
unset ANTHROPIC_API_KEY

# Show engine errors instead of swallowing them
export SMITHERS_DEBUG=1

# Target-specific DB isolation
export WORKFLOW_TARGET="$TARGET"

echo "Starting Guillotine build workflow — Phase: $PHASE, Target: $TARGET"
echo "Root directory: $ROOT_DIR"
echo "Press Ctrl+C to stop."
echo ""

bun run ../../smithers/src/cli/index.ts run workflow.tsx --input "{\"phase\": \"$PHASE\", \"target\": \"$TARGET\"}" --root-dir "$ROOT_DIR"
