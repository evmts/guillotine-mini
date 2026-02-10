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

# Skip phases that are already implemented
# Comma-separated list of phase IDs from phases.ts
# Override with SKIP_PHASES="" to run all phases
export SKIP_PHASES="${SKIP_PHASES:-phase-0-db,phase-1-trie,phase-2-world-state,phase-3-evm-state,phase-10-runner}"

# Target-specific DB isolation
export WORKFLOW_TARGET="$TARGET"

echo "Starting Guillotine build workflow — Phase: $PHASE, Target: $TARGET"
echo "Root directory: $ROOT_DIR"
echo "Press Ctrl+C to stop."
echo ""

bun run ../../smithers/src/cli/index.ts run workflow.tsx --input "{\"phase\": \"$PHASE\", \"target\": \"$TARGET\"}" --root-dir "$ROOT_DIR"
