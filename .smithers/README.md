# guillotine-mini Coding Factory

Public Smithers Cloud workspace, incremental CI, personalized Maintainer / Contributor / Viewer UI, Lighthouse Backpressure Audit, Obsidian Wiki & Mythical History, and agent flows for `evmts/guillotine-mini` (`https://smithers.sh/evmts/guillotine-mini`).

## Files

- `WORKSPACE.ts` — Workspace declaration, host tool binaries, local cache (`.smithers/cache`), and shared Smithers Cloud object store (`https://build.smithers.sh`) with split read/write secrets.
- `FACTORY.ts` -> `factory.json` — Featured flows, Dispatcher `on` triggers, GitHub switchover policy (`mirror: "push"`, `issues: "two-way"`, `changes: "land"`), protected trust roots, person-only approval/merge policy, saved issue views, and transitions.
- `HOME.ts` -> `home.json` — Personalized Smithers Cloud UI with `docs: "https://mini.tevm.sh/llms.txt"` and `contributors: "role"` sections for **Maintainers** (`Today`), **Contributors** (`Contribute`), and **Viewers** (`everyone`).
- `PACKAGE.ts` — Repository-wide Smithers targets (`factory-check`, `home-check`, `home-write`, `wiki-check`, `audit-check`, `factory-scripts-test`, `fmt-check`, `build`).
- `flows/` — Durable Smithers Cloud flows (`ci`, `uphill`, `audit-report`, `wiki-refresh`, `docs-publish`, `release`, `checks/review`, `spec-fix`, `issue/repro`, `issue/poc`, `pr-triage`).
- `wiki/` — Obsidian-compatible knowledge base (`Overview.md`, `Architecture.md`, `Mythical-History.md`, `Hardforks-and-Specs.md`, `Decisions.md`, `Trust-and-Security.md`, `Factory-and-Operations.md`, `Backpressure-and-Quality.md`).
- `audit/` — Generated Lighthouse-style Backpressure Audit (`index.html`, `report.json`, `latest.md`, `pr-comment.md`), also published to `https://mini.tevm.sh/audit/`.
- `scripts/` — Trust & cache-isolation guard (`trust-policy.ts`, `run-trusted-ci.ts`), Lighthouse audit engine (`generate-audit-report.ts`), Home projection validator (`project-home.ts`), Wiki & feed publisher (`sync-wiki-feed.ts`), and one-time sandbox auth helper (`mint-sandbox-auth.ts`).
- `run-zig.sh` — Serializes `zig` invocations across targets while Voltaire builds `blst` in-tree.

## Common Commands

```sh
# Incremental Smithers CI (untrusted read-only cache mode for contributors)
bun .smithers/scripts/run-trusted-ci.ts --untrusted ci '//...'

# Run factory, trust, auth, home, wiki, and audit tests
bun test ./.smithers/scripts/

# Generate the Lighthouse-style Backpressure Audit Report (and stage for docs)
bun .smithers/scripts/generate-audit-report.ts --publish-docs

# Validate Obsidian wiki & Mythical History wikilinks
bun .smithers/scripts/sync-wiki-feed.ts --check

# Re-project home.json after editing HOME.ts
bun .smithers/scripts/project-home.ts --write

# Print one-time sandbox auth or BYOA MCP bootstrap prompt
bun .smithers/scripts/mint-sandbox-auth.ts prompt
bun .smithers/scripts/mint-sandbox-auth.ts attach --branch main
```
