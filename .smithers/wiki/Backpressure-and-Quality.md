---
title: Backpressure and Lighthouse Audit Quality
tags: [backpressure, lighthouse, uphill, quality, wasm, tigerstyle]
---

# Backpressure and Lighthouse Audit Quality

Backpressure in `evmts/guillotine-mini` is continuous, stratified by speed, and presented as a **Lighthouse-style Audit Report** published live at **[https://mini.tevm.sh/audit/](https://mini.tevm.sh/audit/)** and summarized inline on **[https://smithers.sh/evmts/guillotine-mini](https://smithers.sh/evmts/guillotine-mini)**. See [[Overview]] and [[Trust-and-Security]].

## Six Lighthouse Audit Categories

Measured continuously by Uphill (`.agents/uphill/uphill.yaml`) and rendered by `.smithers/scripts/generate-audit-report.ts`:

| Category | Metric Script | What It Audits |
| --- | --- | --- |
| **Safety & TigerStyle** | `.agents/uphill/metrics/safety.ts` | Zero `@panic`/`unreachable`, zero `std.debug.print`, zero swallowed `catch {}`, assertion density, zero TypeScript `any` or `@ts-ignore` |
| **Style & Limits** | `.agents/uphill/metrics/style.ts` | `zig fmt --check`, TigerStyle 70-line function limit, 120-column line limit, zero `TODO`/`FIXME`/`HACK` markers |
| **Footprint & Minimalism** | `.agents/uphill/metrics/footprint.ts` | Concise Zig modules (`<= 400` lines), compact WASM surface protecting the `240,000 B` core / `605,000 B` full budgets, concise TypeScript modules (`<= 300` lines) |
| **Verification & Tests** | `.agents/uphill/metrics/verification.ts` | Lean 4 zero-`sorry` invariant, **210** Lean 4 theorems, Zig inline test coverage, TypeScript SDK test ratio |
| **Documentation** | `.agents/uphill/metrics/documentation.ts` | Zero broken local links across root & `docs/`, **100%** companion `*.zig.md` design doc coverage |
| **Factory & Trust** | `.agents/uphill/metrics/factory.ts` | `.smithers/factory.json` & `home.json` projection parity, cache-write isolation & person-only merge guard, zero broken Obsidian `[[wikilinks]]`, MCP & one-time auth readiness |

## Tiered Backpressure Cadence

| Tier | Latency | Commands | When It Runs |
| --- | --- | --- | --- |
| **Fast Check** | Seconds | `bun test ./.smithers/scripts/`, `bun test ./ts/`, `bun .smithers/scripts/sync-wiki-feed.ts --check`, `bun .smithers/scripts/project-home.ts --check`, `uphill --compact` | Every edit and inner agent loop |
| **Medium Check** | 1-5 min | `zig build unit test-trace test-evmc`, `zig build wasm wasm-modular test-wasm-size test-wasm`, `bun .smithers/scripts/generate-audit-report.ts --verify` | Every PR and Change update |
| **Full Check** | 5-20 min | **66,652-case official EEST (`zig build eest-runner`)**, `LEAN_DIFF_REQUIRE=1 zig build lean-diff -Doptimize=ReleaseFast` (**14,784 vectors**), clean-room `zig fetch --save` consumer build, C99 header + EVMC 12 verification, live WASM docs build | Main pushes, merge queue, and release candidates |

## Running Locally

```sh
# Refresh Uphill metrics + Lighthouse HTML/JSON/Markdown audit report
bun .smithers/scripts/generate-audit-report.ts --untrusted

# Also stage into docs/public/audit/ for Vocs preview
bun .smithers/scripts/generate-audit-report.ts --publish-docs
```

## Related Pages

- [[Overview]]
- [[Architecture]]
- [[Hardforks-and-Specs]]
- [[Trust-and-Security]]
- [[Factory-and-Operations]]
