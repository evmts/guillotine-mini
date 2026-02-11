# Guillotine Workflow — Smithers Build Pipeline

Automated multi-phase build workflow for the Guillotine Ethereum execution client. Uses Smithers (workflow engine) to orchestrate CLI agents (Claude Code / Codex) across 11 build phases.

## Quick Start

```bash
cd scripts/guillotine-workflow

# Run all phases for Effect.ts target
SKIP_PHASES="" WORKFLOW_TARGET="effect" SMITHERS_DEBUG=1 \
  bun run ../../smithers/src/cli/index.ts run workflow.tsx \
  --input '{"phase": "phase-0-db", "target": "effect"}' \
  --root-dir /Users/williamcory/guillotine-mini

# Or use the shell wrapper (defaults to zig target)
./run.sh phase0_db effect
```

## Architecture

### Phases (11 total, sequential)

| Phase | ID | Description |
|-------|----|-------------|
| 0 | `phase-0-db` | DB Abstraction Layer |
| 1 | `phase-1-trie` | Merkle Patricia Trie |
| 2 | `phase-2-world-state` | World State (Journal + Snapshot/Restore) |
| 3 | `phase-3-evm-state` | EVM <-> WorldState Integration |
| 4 | `phase-4-blockchain` | Block Chain Management |
| 5 | `phase-5-txpool` | Transaction Pool |
| 6 | `phase-6-jsonrpc` | JSON-RPC Server |
| 7 | `phase-7-engine-api` | Engine API (CL Interface) |
| 8 | `phase-8-networking` | Networking (devp2p) |
| 9 | `phase-9-sync` | Synchronization |
| 10 | `phase-10-runner` | Runner (Entry Point + CLI) |

### Steps per Phase (8 tasks per phase)

Each phase runs these tasks sequentially:

1. **Context** (`{id}:context`) — Reads specs, reference code, existing code to build context
2. **Implement Pass 1** (`{id}:implement-1`) — First implementation pass
3. **Implement Pass 2** (`{id}:implement-2`) — Second pass, builds on pass 1
4. **Test** (`{id}:test`) — Run tests, capture results
5. **Review** (`{id}:review`) — Code review with severity rating
6. **Review Fix** (`{id}:review-fix`) — Fix issues from review (skipped if severity=none)
7. **Review Response** (`{id}:review-response`) — Verify fixes address review (skipped if severity=none)
8. **Refactor** (`{id}:refactor`) — Clean up code
9. **Benchmark** (`{id}:benchmark`) — Performance benchmarks
10. **Final Review** (`{id}:final-review`) — Decide if phase is complete (`ready_to_move_on`)

### Multi-Pass System

- Up to `MAX_PASSES=5` passes through all phases
- Each pass re-visits incomplete phases (where `ready_to_move_on=0`)
- Phases with `ready_to_move_on=1` are skipped on subsequent passes
- `pass-tracker` task records pass completion

### Targets

| Target | ID | Client Dir | DB File | Build | Test |
|--------|----|-----------|---------|-------|------|
| Zig | `zig` | `client/` | `zig-guillotine.db` | `zig build` | `zig build test` |
| Effect.ts | `effect` | `client-ts/` | `effect-guillotine.db` | `cd client-ts && bun run build` | `cd client-ts && bun test` |

Target determines: prompts used, build/test commands, code style, DI patterns, review checklists.

### Agents

Two agent modes (controlled by `USE_CLI_AGENTS` env var):

- **CLI mode** (default): Spawns `claude` or `codex` CLI as subprocesses
  - Claude: `ClaudeCodeAgent` with `dangerouslySkipPermissions: true`
  - Codex: `CodexAgent` with `yolo: true`
- **API mode** (`USE_CLI_AGENTS=0`): Uses AI SDK `ToolLoopAgent` with API calls

The workflow uses Codex as the default agent (`makeCodex()` in `agents/codex.ts`).

## Environment Variables

| Var | Default | Description |
|-----|---------|-------------|
| `SKIP_PHASES` | (varies) | Comma-separated phase IDs to skip |
| `WORKFLOW_TARGET` | `zig` | Target: `zig` or `effect` |
| `SMITHERS_DEBUG` | unset | Set to `1` for verbose engine logs |
| `USE_CLI_AGENTS` | (truthy) | Set to `0` or `false` for API mode |
| `CODEX_MODEL` | `gpt-5.3-codex` | Model for Codex agent |
| `CLAUDE_MODEL` | `claude-opus-4-6` | Model for Claude agent |
| `ANTHROPIC_API_KEY` | unset | Unset to force CLI mode (run.sh does this) |

## Database (SQLite)

DB file: `{target}-guillotine.db` (e.g., `effect-guillotine.db`)

### Tables

| Table | Key Columns | Purpose |
|-------|-------------|---------|
| `context` | `node_id`, `iteration`, `summary` | Context gathering results |
| `implement` | `node_id`, `iteration`, `files_created`, `commit_message` | Implementation work |
| `test_results` | `node_id`, `unit_tests_passed`, `failing_summary` | Test outcomes |
| `review` | `node_id`, `severity`, `feedback`, `issues` | Code review |
| `review_fix` | `node_id`, `fixes_made`, `summary` | Review fix actions |
| `review_response` | `node_id`, `fixes_accepted`, `remaining_issues` | Fix verification |
| `refactor` | `node_id`, `changes_description`, `files_changed` | Refactoring |
| `benchmark` | `node_id`, `results`, `meets_targets` | Performance results |
| `final_review` | `node_id`, `ready_to_move_on`, `reasoning` | Phase completion decision |
| `output` | `node_id`, `total_iterations`, `summary` | Pass tracking |

## Monitoring

### SQLite Queries

```bash
DB=scripts/guillotine-workflow/effect-guillotine.db

# Latest completed tasks
sqlite3 $DB "SELECT node_id, iteration FROM implement ORDER BY rowid DESC LIMIT 10;"

# Phase completion status
sqlite3 $DB "SELECT node_id, ready_to_move_on, reasoning FROM final_review ORDER BY rowid DESC LIMIT 10;"

# Test results
sqlite3 $DB "SELECT node_id, unit_tests_passed, failing_summary FROM test_results ORDER BY rowid DESC LIMIT 10;"

# Review severity
sqlite3 $DB "SELECT node_id, severity, feedback FROM review ORDER BY rowid DESC LIMIT 5;"

# All tables overview
sqlite3 $DB ".tables"

# Row counts per table
sqlite3 $DB "SELECT 'context', COUNT(*) FROM context UNION ALL SELECT 'implement', COUNT(*) FROM implement UNION ALL SELECT 'test_results', COUNT(*) FROM test_results UNION ALL SELECT 'review', COUNT(*) FROM review UNION ALL SELECT 'final_review', COUNT(*) FROM final_review;"
```

### Git Log

```bash
# Recent commits from agents
git log --oneline --since="10 minutes ago"

# Commits in client-ts/
git log --oneline --since="1 hour ago" -- client-ts/
```

### Execution Logs

```bash
# Smithers execution logs
ls -lt scripts/guillotine-workflow/.smithers/executions/*/logs/ 2>/dev/null | head -20
```

## Debugging

### Common Issues

1. **Agent hangs**: Check if CLI subprocess is waiting for input. Kill and restart.
2. **DB locked**: Only one workflow instance can run at a time per DB file.
3. **No JSON output**: Agent didn't end response with required JSON code fence. Task will fail/retry.
4. **Phase stuck**: If `final_review.ready_to_move_on=0` repeatedly, add to `SKIP_PHASES` and restart.

### Restart with Skipped Phases

```bash
# Skip completed phases
SKIP_PHASES="phase-0-db,phase-1-trie" WORKFLOW_TARGET="effect" SMITHERS_DEBUG=1 \
  bun run ../../smithers/src/cli/index.ts run workflow.tsx \
  --input '{"phase": "phase-0-db", "target": "effect"}' \
  --root-dir /Users/williamcory/guillotine-mini
```

### Inspect DB Directly

```bash
sqlite3 scripts/guillotine-workflow/effect-guillotine.db
.tables
.schema implement
SELECT * FROM final_review;
```

## File Map

| File | Role |
|------|------|
| `workflow.tsx` | Main workflow definition (JSX, Smithers primitives) |
| `phases.ts` | Phase ID/name definitions |
| `targets.ts` | Target configs (zig, effect) — build/test commands, style |
| `run.sh` | Shell entry point |
| `agents/codex.ts` | Codex agent setup (CLI + API modes) |
| `agents/claude.ts` | Claude agent setup + system instructions |
| `db/index.ts` | SQLite DB init + schema |
| `db/schemas.ts` | Zod output schemas for structured extraction |
| `db/*.ts` | Drizzle table definitions |
| `steps/0_context.mdx` | Context gathering prompt |
| `steps/1_implement.mdx` | Zig implementation prompt |
| `steps/2_test.mdx` | Zig test prompt |
| `steps/3_review.mdx` | Review prompt |
| `steps/4_review-fix.mdx` | Review fix prompt |
| `steps/4.5_review-response.mdx` | Review response prompt |
| `steps/5_refactor.mdx` | Zig refactor prompt |
| `steps/6_benchmark.mdx` | Benchmark prompt |
| `steps/7_final-review.mdx` | Final review prompt |
| `steps/effect/1_implement.ts` | Effect.ts implementation prompt |
| `steps/effect/2_test.ts` | Effect.ts test prompt |
| `steps/effect/5_refactor.ts` | Effect.ts refactor prompt |
| `steps/render.ts` | MDX/TS prompt rendering |
| `steps/types.ts` | TypeScript types for step outputs |
