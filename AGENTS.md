# Agents Operating Contract — `evmts/guillotine-mini`

Follow the [Uphill rules](.agents/uphill/rules.md), which `uphill rules --write` rewrites from each metric's description: @.agents/uphill/rules.md

`evmts/guillotine-mini` runs publicly as a **Smithers Cloud coding factory** at **[https://smithers.sh/evmts/guillotine-mini](https://smithers.sh/evmts/guillotine-mini)**, mirroring to GitHub and powering downstream `evmts/zevm` and `evmts/tevm` development.

Every AI agent (Claude Code, Codex, Antigravity, Cursor, or sandboxed worker) MUST follow this contract.

## 1. Connect via Authenticated Smithers Cloud MCP First

Configure the repository's live Streamable HTTP MCP server (already declared in `.mcp.json`):

```sh
claude mcp add guillotine-mini --transport http https://smithers.sh/evmts/guillotine-mini/mcp
codex mcp add guillotine-mini --url https://smithers.sh/evmts/guillotine-mini/mcp
agy mcp add guillotine-mini --transport http https://smithers.sh/evmts/guillotine-mini/mcp
```

Use Smithers Cloud MCP tools for all coordination:
- **Inspect**: `repo_tree`, `repo_read_file`, `repo_refs`, `docs_list`, `docs_read`, `flows_list`, `flow_get`
- **Track work**: `issues_list`, `issue_get`, `issue_create`, `issue_comment`, `pulls_list`, `pull_get`, `pull_files`, `todo_list`, `work_link_post`
- **Fleet observability**: `fleet_heartbeat`, `fleet_sessions_report`, `fleet_overview`

All MCP writes are attributed as `<login> (agent)`. Person-only actions (merging, approving human gates, final triage overrides, committing/dropping TODOs, editing secrets) are enforced server-side and are never available to agents.

## 2. One-Time-Use Sandbox Authentication

Never pass static long-lived secrets to sandboxes or sub-agents. Print or mint short-lived, single-use credentials via:

```sh
bun .smithers/scripts/mint-sandbox-auth.ts prompt
bun .smithers/scripts/mint-sandbox-auth.ts attach --branch main
bun .smithers/scripts/mint-sandbox-auth.ts envelope --agent <worker> --ttl 300
bun .smithers/scripts/mint-sandbox-auth.ts gateway --scope read:runs --ttl 15m --run <run-id>
```

## 3. Version Control: Jujutsu (`jj`) Only

Use `jj --no-pager` for every repository version-control operation (status, diff, log, stacked changesets, workspaces, bookmarks, fetch, push). Never invoke raw `git` CLI directly. Use isolated `jj workspace` checkouts for concurrent work.

## 4. Trust Boundaries & Shared Object Store (`build.smithers.sh`)

- **Shared Cache**: `.smithers/WORKSPACE.ts` connects to `https://build.smithers.sh`.
- **Untrusted Execution (Encouraged!)**: Contributors, fork PRs, and local runs are welcomed to run everything untrusted:
  ```sh
  bun .smithers/scripts/run-trusted-ci.ts --untrusted ci '//...'
  bun .smithers/scripts/generate-audit-report.ts --untrusted
  ```
- **Cache-Poisoning & Gate Protection**: Only Smithers-controlled sandboxes and verified maintainers (`roninjin10`, `fucory`) receive `SMITHERS_CACHE_WRITE_TOKEN` or satisfy merge gates. Untrusted runs are strictly read-only/local-only and informational.

## 5. Backpressure: Lighthouse Audit Report & Uphill

Run backpressure before handing work off:

```sh
uphill --compact                                    # 6-category continuous metrics
bun .smithers/scripts/generate-audit-report.ts      # Lighthouse HTML/JSON/MD report
bun .smithers/scripts/sync-wiki-feed.ts --check     # Obsidian wiki & Mythical History links
bun test ./.smithers/scripts/                       # Trust, auth, home, audit & wiki tests
zig build unit && zig build test-trace              # Core Zig EVM & EIP-3155 trace tests
```

## 6. Knowledge Base: Obsidian Wiki & Mythical History

Read and maintain `.smithers/wiki/`:
- `.smithers/wiki/Overview.md`
- `.smithers/wiki/Architecture.md`
- `.smithers/wiki/Mythical-History.md`
- `.smithers/wiki/Hardforks-and-Specs.md`
- `.smithers/wiki/Decisions.md`
- `.smithers/wiki/Trust-and-Security.md`
- `.smithers/wiki/Factory-and-Operations.md`
- `.smithers/wiki/Backpressure-and-Quality.md`

See `CLAUDE.md` for deep EVM debugging workflows (7-checkpoint spec-fix method, `scripts/isolate-test.ts`, Lean 4 oracle, and hardfork invariants).
