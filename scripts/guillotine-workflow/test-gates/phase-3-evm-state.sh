#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

unit_status="skipped"
spec_status="skipped"
integration_status="skipped"
diff_status="skipped"
failing_summary=""

run_step() {
  local label="$1"
  shift
  if "$@"; then
    printf "[PASS] %s\n" "$label"
    return 0
  fi
  printf "[FAIL] %s\n" "$label"
  return 1
}

if [ -f "$ROOT_DIR/client-ts/package.json" ]; then
  if run_step "unit tests (client-ts)" bash -lc "cd \"$ROOT_DIR/client-ts\" && bun run test"; then
    unit_status="passed"
  else
    unit_status="failed"
    failing_summary+="unit tests failed; "
  fi
fi

# Spec suite execution depends on local Zig + native deps. Run only when explicitly enabled.
if [ "${RUN_PHASE3_SPEC_GATE:-0}" = "1" ]; then
  if run_step "spec tests (zig build test)" bash -lc "cd \"$ROOT_DIR\" && zig build test"; then
    spec_status="passed"
  else
    spec_status="failed"
    failing_summary+="spec tests failed; "
  fi
fi

if [ -f "$ROOT_DIR/client-ts/package.json" ]; then
  if run_step "integration build (client-ts)" bash -lc "cd \"$ROOT_DIR/client-ts\" && bun run build"; then
    integration_status="passed"
  else
    integration_status="failed"
    failing_summary+="integration build failed; "
  fi
fi

# Differential runner is optional and phase-specific; mark skipped unless a dedicated script is added.
if [ -x "$ROOT_DIR/scripts/guillotine-workflow/test-gates/phase-3-evm-state-diff.sh" ]; then
  if run_step "nethermind differential gate" "$ROOT_DIR/scripts/guillotine-workflow/test-gates/phase-3-evm-state-diff.sh"; then
    diff_status="passed"
  else
    diff_status="failed"
    failing_summary+="nethermind diff failed; "
  fi
fi

if [ -z "$failing_summary" ]; then
  failing_summary="null"
else
  failing_summary="\"${failing_summary%'; '}\""
fi

cat <<EOF
{
  "unitTestsPassed": $([ "$unit_status" = "passed" ] && echo true || echo false),
  "specTestsPassed": $([ "$spec_status" = "passed" ] && echo true || echo false),
  "integrationTestsPassed": $([ "$integration_status" = "passed" ] && echo true || echo false),
  "nethermindDiffPassed": $([ "$diff_status" = "passed" ] && echo true || echo false),
  "failingSummary": $failing_summary,
  "testOutput": "unit=$unit_status, spec=$spec_status, integration=$integration_status, diff=$diff_status"
}
EOF

if [ "$unit_status" = "failed" ] || [ "$spec_status" = "failed" ] || [ "$integration_status" = "failed" ] || [ "$diff_status" = "failed" ]; then
  exit 1
fi

exit 0
