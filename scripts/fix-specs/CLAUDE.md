# Fix-Specs Workflow — Smithers Spec Fixer Pipeline

Automated pipeline that runs Ethereum spec test suites, uses AI agents to fix failures, and commits fixes. Built on Smithers for durable SQLite state and resumable runs.

## Quick Start

```bash
cd scripts/fix-specs
bun install

# Run all suites
./run.sh

# Run single suite
./run.sh cancun-tstore-basic
```

## Architecture

### Per-Suite Flow

Each test suite goes through:

1. **Test** (`{suite}:test`) — Run `zig build specs-{suite}`, report pass/fail counts
2. **Fix** (`{suite}:fix`) — AI agent analyzes failures, reads Python reference, fixes Zig code (skipped if tests pass)
3. **Retry** — Ralph loop retries test+fix up to 2 iterations
4. **Commit** (`{suite}:commit`) — Create git commit for the fix (skipped if nothing was fixed)

After all suites: **Summary** task generates narrative report.

### Agents

All use `ClaudeCodeAgent` (spawns `claude --print`):

| Agent | Purpose | Max Turns |
|-------|---------|-----------|
| `testRunner` | Run test command, parse output | 5 |
| `fixer` | Analyze failures, fix Zig code | 350 |
| `committer` | Review diff, create commit | 10 |
| `summaryAgent` | Generate narrative summary | 3 |

### Database

SQLite file: `spec-fixer.db`

| Table | Key Columns | Purpose |
|-------|-------------|---------|
| `test_result` | `passed`, `passed_count`, `failed_count` | Test outcomes |
| `fix_result` | `success`, `what_was_fixed`, `files_modified` | Fix attempts |
| `commit_result` | `committed`, `commit_message` | Commit tracking |
| `summary` | `total_passed`, `total_failed`, `narrative` | Run summary |

All tables have PK `(run_id, node_id, iteration)`.

## Monitoring

```bash
# Check test results
sqlite3 spec-fixer.db "SELECT node_id, passed, passed_count, failed_count FROM test_result ORDER BY rowid DESC LIMIT 10;"

# Check fix results
sqlite3 spec-fixer.db "SELECT node_id, success, what_was_fixed FROM fix_result ORDER BY rowid DESC LIMIT 10;"

# Check commits
sqlite3 spec-fixer.db "SELECT node_id, committed, commit_message FROM commit_result;"

# Overall summary
sqlite3 spec-fixer.db "SELECT total_passed, total_failed, narrative FROM summary ORDER BY rowid DESC LIMIT 1;"
```

## Environment Variables

| Var | Default | Description |
|-----|---------|-------------|
| `FIX_SPECS_SUITE` | (all) | Single suite name to run |
| `CLAUDE_MODEL` | `claude-sonnet-4-5-20250929` | Model for all agents |
| `SMITHERS_DEBUG` | unset | Set to `1` for verbose engine logs |

## File Map

| File | Purpose |
|------|---------|
| `workflow.tsx` | Main Smithers workflow (JSX) |
| `db/index.ts` | SQLite init + Drizzle schema |
| `db/test-result.ts` | Test result table |
| `db/fix-result.ts` | Fix result table |
| `db/commit-result.ts` | Commit result table |
| `db/summary.ts` | Summary table |
| `schemas.ts` | Zod output schemas |
| `agents.ts` | ClaudeCodeAgent configs |
| `suites.ts` | Test suite definitions |
| `known-issues.ts` | Known issues loader (from `../known-issues.json`) |
| `prompts/test.ts` | Test runner prompt |
| `prompts/fix.ts` | Fixer prompt (with EVM debugging context) |
| `prompts/commit.ts` | Commit prompt |
| `prompts/summary.ts` | Summary prompt |
| `run.sh` | Shell entry point |
