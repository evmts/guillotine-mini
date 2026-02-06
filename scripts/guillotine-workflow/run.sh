#!/usr/bin/env bash
# Run the Guillotine build workflow
# Usage: ./run.sh [phase]
# Example: ./run.sh phase0_db

set -euo pipefail

PHASE="${1:-phase0_db}"

cd "$(dirname "$0")"

echo "Starting Guillotine build workflow — Phase: $PHASE"
echo "Press Ctrl+C to stop."
echo ""

bun run workflow.tsx --input "{\"phase\": \"$PHASE\"}"
