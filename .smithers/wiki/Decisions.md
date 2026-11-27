---
title: Architectural Decisions (ADRs)
tags: [decisions, adr, architecture, smithers, security]
---

# Architectural Decisions

Durable product and engineering decisions for `evmts/guillotine-mini`. Every decision links back to the subsystems it governs. See [[Overview]], [[Architecture]], and [[Trust-and-Security]].

## ADR-001: Zig 0.15.2 with Transaction-Scoped Arena Allocation
- **Decision**: Pin Zig `0.15.2` and manage transaction-scoped scratch memory through an arena freed on transaction exit.
- **Why**: Deterministic memory ownership without GC pauses, clean C/WASM export without a heavy runtime, and zero leak risk across deeply nested reverted `CALL`/`CREATE` trees.

## ADR-002: Python `execution-specs` as Ground Truth + Lean 4 Executable Oracle
- **Decision**: Resolve every semantic ambiguity directly against `ethereum/execution-specs`, backed by machine-checked theorems and differential fuzzing in `spec/lean/`.
- **Why**: Prevents test-specific hacks in `src/` and catches subtle gas-order, overflow, and rollback bugs across 14,784+ differential vectors. See [[Hardforks-and-Specs]].

## ADR-003: Stable 42-Symbol C ABI and Modular WASI Preview 1 WASM Reactor
- **Decision**: Keep `src/root_c.zig` exporting its 42 `evm_*` symbols (sync + async state injection) and split heavy precompiles into modular WASM bundles under a strict `<= 2.5 MiB` raw budget.
- **Why**: Enables embedding in C, Rust, Go, Python, Node 22+, and browsers while keeping bundle size verifiable on every commit (`wasm.yml`).

## ADR-004: Pinned Sibling Voltaire Revision (`native-dependencies.json`)
- **Decision**: Pin `evmts/voltaire` by exact commit SHA in `native-dependencies.json` and build its audited Rust cryptography archive deterministically in CI.
- **Why**: Eliminates cryptographic re-implementation drift and guarantees reproducible native and WASM builds across `guillotine-mini`, `voltaire`, and `zevm`.

## ADR-005: Smithers Cloud Switchover (`mirror: "push"`, `changes: "land"`, `issues: "two-way"`)
- **Decision**: Run `evmts/guillotine-mini` as a public Smithers Cloud coding factory at `https://smithers.sh/evmts/guillotine-mini`, mirroring to GitHub `evmts/guillotine-mini` and triggering automated releases and docs deploys on merge.
- **Why**: Unifies TODOs, stacked changesets, incremental builds, wiki, and agent MCP collaboration into one public, inspectable control plane. See [[Factory-and-Operations]].

## ADR-006: Strict Trusted vs Untrusted Execution & Cache-Poisoning Prevention
- **Decision**: Only Smithers-controlled sandboxes and verified maintainers (`roninjin10`, `fucory`) may write to the shared `build.smithers.sh` object store or satisfy merge gates. External contributors and fork PRs are actively encouraged to run everything untrusted with read-only cache access.
- **Why**: Open-source velocity requires welcoming untrusted runs without ever allowing a malicious PR to poison cached test results or bypass merge checks. See [[Trust-and-Security]].

## ADR-007: Lighthouse-Style Backpressure Audit Over Uphill Metrics
- **Decision**: Combine Uphill continuous metrics (`safety`, `style`, `footprint`, `verification`, `documentation`, `factory`) with execution trust attestations into a self-contained Lighthouse-grade HTML/JSON/Markdown audit report published at `https://mini.tevm.sh/audit/` and surfaced on the Smithers Cloud homepage.
- **Why**: Makes engineering health, regressions, and top score opportunities immediately legible to maintainers, contributors, and prospective open-source adopters. See [[Backpressure-and-Quality]].

## ADR-008: One-Time-Use Auth & Authenticated Cloud MCP for All Agents
- **Decision**: Connect every agent (Claude Code, Codex, Antigravity, Cursor, sandboxed workers) via `https://smithers.sh/evmts/guillotine-mini/mcp` using OAuth 2.1 + PKCE S256 or one-time-use attach/scoped tokens (`.smithers/scripts/mint-sandbox-auth.ts`). Person-only actions (merge, approve, triage override, secrets) are enforced server-side and never delegated.
- **Why**: Eliminates long-lived static credentials in sandboxes and gives every agent first-class, attributed access to issues, PRs, TODOs, docs, and flows.

## Related Pages

- [[Overview]]
- [[Architecture]]
- [[Mythical-History]]
- [[Trust-and-Security]]
- [[Factory-and-Operations]]
