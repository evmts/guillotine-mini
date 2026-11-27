---
title: Architectural Decisions (ADRs)
tags: [decisions, adr, architecture, smithers, security]
---

# Architectural Decisions

Durable product and engineering decisions for `evmts/guillotine-mini`. Every decision links back to the subsystems it governs. See [[Overview]], [[Architecture]], and [[Trust-and-Security]].

## ADR-001: Zig 0.15.2 with Transaction-Scoped Arena Allocation
- **Decision**: Pin Zig `0.15.2` and manage transaction-scoped scratch memory through an arena freed on transaction exit.
- **Why**: Deterministic memory ownership without GC pauses, clean C/WASM export without a heavy runtime, and zero leak risk across deeply nested reverted `CALL`/`CREATE` trees.

## ADR-002: Official EEST 100% Gate + 210-Theorem Lean 4 Executable Oracle
- **Decision**: Gate every push to `main` on all **66,652** Frontier through Osaka official EEST `tests@v21.0.3` state tests (`zig build eest-runner`) and **14,784** differential fuzz vectors against the **210-theorem** Lean 4 specification (`spec/lean/`, 0 `sorry`, 0 custom axioms).
- **Why**: Prevents test-specific hacks in `src/` and catches subtle gas-order, 1024-stack-cap, fork-guard, and multi-frame rollback bugs immediately. See [[Hardforks-and-Specs]].

## ADR-003: 51-Symbol C/WASM ABI, EVMC ABI 12 Shared Lib, and Modular WASI Reactor
- **Decision**: Export **51** `evm_*` symbols from `src/root_c.zig` (sync + async state injection + SVG/folded gas flamegraphs + ABI revert decoding) documented in `include/guillotine_mini.h`, ship `libguillotine_mini_evmc.{so,dylib}` (`src/evmc_exports.zig`), and keep modular WASM bundles under tight byte ceilings (`guillotine_mini_core.wasm <= 240,000 B`, `guillotine_mini.wasm <= 605,000 B`) via comptime DCE (`enable_compiled_interpreter = !is_wasm`, `enable_bal_recorder = !is_wasm`).
- **Why**: Enables embedding in C, C++, Rust, Go, EVMC hosts (Reth/Erigon/Besu/Silkworm), browsers, Cloudflare Workers, Deno, Bun, and Node 22+ while keeping the modular core at `92.8 KiB` gzipped.

## ADR-004: Standalone URL+Hash Pinned Voltaire in `build.zig.zon`
- **Decision**: Pin `evmts/voltaire` by immutable GitHub archive URL and Zig content hash in `build.zig.zon` (matching `native-dependencies.json`), eliminating the sibling `../voltaire` path dependency.
- **Why**: Allows any Zig `0.15.2` consumer to integrate Guillotine Mini in one command via `zig fetch --save` with zero external repository checkouts, verified on every CI run via a clean-room tarball consumer build.

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

## ADR-009: Minimalist Carve-Out of `client/` & `client-ts/` and Zero-Dep Universal TS SDK
- **Decision**: Remove the duplicated 57.6K-LOC `client/` and `client-ts/` execution-client prototypes in `v0.2.0` (preserving `test/specs/header_validator.zig` and `src/bench_utils.zig`, and archiving full history at commit `577c5fab`), and ship `@tevm/guillotine-mini` (`ts/`) as a zero-dependency universal TypeScript/WASM SDK with an inline ~1 KB WASI Preview 1 shim and Cloudflare Edge EVM Worker.
- **Why**: Active full execution client engineering belongs in `evmts/zevm` and `evmts/guillotine`; keeping `guillotine-mini` laser-focused on the embeddable EVM, debugger, formal proofs, and universal WASM/C/EVMC surface protects auditability, compile times, and adoption.

## Related Pages

- [[Overview]]
- [[Architecture]]
- [[Mythical-History]]
- [[Trust-and-Security]]
- [[Factory-and-Operations]]
