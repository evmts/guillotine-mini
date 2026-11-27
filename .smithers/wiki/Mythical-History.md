---
title: Mythical History of Guillotine Mini
tags: [history, mythical-history, chronicle, milestones, releases]
---

# Mythical History of Guillotine Mini

> *"From a single `zig init` extracted out of Guillotine to the SQLite of EVMs: 66,652/66,652 EEST conformance, 210 Lean 4 proofs, Glamsterdam EIPs, and a 92.8 KiB gzipped universal WASM engine."*

This chronicle traces the real, commit-verified evolution of `evmts/guillotine-mini` across **1,620+ commits on `main`**. Every milestone cites the exact historical commit SHA so humans and agents can inspect the living lineage of every architectural decision. See [[Overview]] and [[Decisions]].

## Era Timeline

```mermaid
flowchart LR
  E1["Era I: Genesis Extraction (Sep 2025)"] --> E2["Era II: Spec Parity & WASI WASM (Oct 2025 - Sep 2026)"]
  E2 --> E3["Era III: Observability, Osaka & Docs (Nov 22-23, 2026)"]
  E3 --> E4["Era IV: Lean 4 Oracle & 3-Round Audit (Nov 24-25, 2026)"]
  E4 --> E5["Era V: v0.1.0 & Smithers Cloud Switchover (Nov 25-27, 2026)"]
  E5 --> E6["Era VI: v0.2.0 — 66,652 EEST, 210 Proofs, Universal SDK & Glamsterdam (Nov 27, 2026)"]
```

## Era I: Genesis Extraction (September 30 - October 1, 2025)

- **`4e5d05e3` (2025-09-30)** — `chore: zig init`. The repository begins with a clean Zig scaffold.
- **`81ce7a60` (2025-09-30)** — `feat: extract mini EVM implementation from guillotine`. Guillotine Mini splits out as the minimal, readable, specification-first counterpart to full Guillotine, prioritizing auditable code over speculative complexity.
- **`60181a2b` & `fa840760` (2025-10-01)** — Refactors to a clean library-only package with centralized EVM errors (`c9a20c25`), WASM targets, and a dedicated test runner utility (`707c4fb4`).

## Era II: Execution-Specs Authority & WASI Reactor (2025-10 - 2026-09)

- Over more than a thousand commits, `guillotine-mini` establishes **Python `execution-specs` as the single source of truth**, building the 7-checkpoint EIP-3155 trace divergence workflow (`scripts/isolate-test.ts`, `scripts/fix-specs.ts`) and covering Frontier through Prague.
- **`edafd394` (2026-09-05)** — `fix(wasm): build and execute the WASI reactor with linked crypto`. Guillotine Mini compiles to a WASI Preview 1 WebAssembly reactor with Voltaire's Rust cryptography linked directly in, enabling portable browser and Node execution.

## Era III: Observability, Osaka, Examples & Smithers Genesis (November 22 - 23, 2026)

- **`3e9e8580` (2026-11-22)** — Complete rewrite of the Vocs documentation site (`mini.tevm.sh`) with visual architecture diagrams, Head First tutorials, K&R-style references, and an interactive browser Opcode & Gas Explorer.
- **`14288287` & `69603e3d` (2026-11-23, PR #42)** — Massive leap in production readiness: EIP-7939 `CLZ`, EIP-7951 `P256VERIFY` precompile wiring, EIP-3155 tracing fixes, the 15-hook `Inspector` API with 256-bit `OpcodeMask`, 6 native tracers, `StateOverlayHost` simulation RPC, time-travel `DebugSession`, gas flamegraphs, and EVMC ABI 12 bridge.
- **`618007ed` (2026-11-23)** — First `.smithers/` factory scaffold lands, introducing `WORKSPACE.ts`, fine-grained `PACKAGE.ts` filegroups, and remote caching on `build.smithers.sh`.
- **`54be5890` & `472cf3b6` (2026-11-23)** — Modular precompile WASM splitting with strict byte budgets and 10 runnable Zig examples verified against EIP-3155 reference traces.
- **`cbc49735` (2026-11-23)** — Osaka property & fuzz suite catches and eliminates a reverted-child storage-slot resurrection bug.

## Era IV: The Lean 4 Formal Oracle & Three-Round Audit (November 24 - 25, 2026)

- **`ae8ef2d7` (2026-11-24)** — Multi-model PEAK-1 panel synthesis lands Osaka `P256VERIFY`, untruncated async C ABI, and safe `Evm.init`.
- **`5c2ae70c` & `d04d4e31` (2026-11-24)** — **Executable Lean 4 EVM Reference Specification (`spec/lean/`)** lands alongside a **14,784-vector differential fuzz suite** comparing the Zig EVM directly against machine-checked Lean 4 semantics with zero `sorry`s.
- **`a3a7a9a3`, `41408f2f`, `fc8d7133`, `f7e5da02` (2026-11-24 - 2026-11-25)** — Three full rounds of multi-lane security and correctness audits close rollback, checkpoint memory reclamation, async `EXTCODE*`/`SELFDESTRUCT` miss-handling, C handle re-entrancy, EIP-7623/7702 runner edge cases, and Osaka blob cap bugs.

## Era V: `v0.1.0`, Uphill Backpressure & Public Smithers Cloud Switchover (November 25 - 27, 2026)

- **`2264d998` (`v0.1.0`, 2026-11-25)** — First tagged public release (`v0.1.0`) with green macOS + Linux + WASM + Lean 4 + Smithers CI.
- **`0a128cae` (2026-11-26)** — Uphill continuous metrics (`safety`, `style`, `footprint`, `verification`, `documentation`) establish baselines and automated quality hill-climbing.
- **`577c5fab` (2026-11-27)** — Public Smithers Cloud switchover completes (`https://smithers.sh/evmts/guillotine-mini`), launching the Lighthouse Backpressure Audit Report, Obsidian Wiki, Cloud MCP server, and automated CI-gated releases.

## Era VI: `v0.2.0` — The SQLite of EVMs (November 27, 2026)

- **`1323d10f`** — Pins `evmts/voltaire` by URL+hash in `build.zig.zon` for standalone `zig fetch --save` and carves out duplicated `client/` and `client-ts/` prototypes (archived at `577c5fab`) to restore core EVM minimalism.
- **`a7492320`** — Lands the compiled basic-block interpreter (`src/compiled_code.zig`, `src/u256_math.zig`, `ReusableEvm`) comptime-gated off on `wasm32`, while Lean 4 differential fuzzing catches and closes a real Yellow Paper 1024-slot stack overflow bug.
- **`d6abb0d9`** — Achieves zero production `@panic`/`unreachable`/`catch {}` violations, 100% companion `*.zig.md` doc coverage, exports 7 new flamegraph & revert decoder C/WASM symbols (`44 -> 51`), and ships the live WASM Browser Playground (`mini.tevm.sh/play`).
- **`ac99b45a`** — Replaces broken regex spec filters with a zero-alloc Thompson NFA and adds `zig build eest-runner`, verifying **66,652 / 66,652 (100.00%)** official Frontier → Osaka `tests@v21.0.3` state tests in 18.5 s.
- **`b37f4e37`** — Expands Lean 4 formal verification from 60 to **210 machine-checked theorems** (`MultiFrame.lean` + `AmsterdamGas.lean`) with 0 `sorry` and 0 custom axioms.
- **`1a0f62c6`** — Ships the zero-dep universal `@tevm/guillotine-mini` TS/WASM SDK (`ts/`, ~1 KB browser/Worker WASI shim), C99 header (`include/guillotine_mini.h`), EVMC ABI 12 shared library (`src/evmc_exports.zig`), Cloudflare Edge EVM Worker, and reproducible WASM benchmark (`92.8 KiB` gzipped modular core).
- **`d74a1dea` & `31f2f439`** — Implements all 8 Glamsterdam (Amsterdam) EIPs (7708, 7843, 7928, 7954, 8024, 8037, 8038, 8246), closes an EIP-6780/8246 cross-fork guard leak caught by the 66,652-case EEST gate, and cuts **`v0.2.0`**.

## Related Pages

- [[Overview]]
- [[Architecture]]
- [[Decisions]]
- [[Factory-and-Operations]]
- [[Backpressure-and-Quality]]
