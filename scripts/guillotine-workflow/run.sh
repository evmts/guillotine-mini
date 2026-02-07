#!/usr/bin/env bash
# Run the Guillotine build workflow
# Usage: ./run.sh [phase]
# Example: ./run.sh phase0_db

set -euo pipefail

PHASE="${1:-phase0_db}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$SCRIPT_DIR"

echo "Starting Guillotine build workflow — Phase: $PHASE"
echo "Root directory: $ROOT_DIR"
echo "Press Ctrl+C to stop."
echo ""

bun run ../../smithers/src/cli/index.ts run workflow.tsx --input "{\"phase\": \"$PHASE\"}" --root-dir "$ROOT_DIR"
