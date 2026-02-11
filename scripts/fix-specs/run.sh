#!/usr/bin/env bash
# Run the spec-fixer workflow
# Usage: ./run.sh                        # All suites
#        ./run.sh cancun-tstore-basic     # Single suite
set -euo pipefail

cd "$(dirname "$0")"
ROOT_DIR="$(cd "../.." && pwd)"

export SMITHERS_DEBUG=1

SUITE="${1:-}"
if [ -n "$SUITE" ]; then
  export FIX_SPECS_SUITE="$SUITE"
  echo "Running spec-fixer for suite: $SUITE"
else
  echo "Running spec-fixer for ALL suites"
fi

echo "Root directory: $ROOT_DIR"
echo "Press Ctrl+C to stop."
echo ""

bun run ../../smithers/src/cli/index.ts run workflow.tsx \
  --input "{}" --root-dir "$ROOT_DIR"
