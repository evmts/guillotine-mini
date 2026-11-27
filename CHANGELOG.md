# Changelog

All notable changes to `evmts/guillotine-mini` are documented in this file.

## 0.2.0 - 2026-11-27

### Added
- **Universal `@tevm/guillotine-mini` TypeScript/WASM SDK (`ts/`)**: Zero-dependency runtime supporting browsers, Cloudflare Workers, Deno, Bun, and Node 22+ via a ~1 KB pure-JS WASI Preview 1 shim (`ts/wasi-shim.ts`), `GuillotineEvm` with `Symbol.dispose`, modular precompile loader (`ts/precompiles.ts`), async JSON-RPC state forking (`ts/fork.ts`), and `cloudflare/evm-worker.ts` edge RPC Worker.
- **Official EEST `tests@v21.0.3` Parallel Runner & CI Gate**: Added `scripts/fetch-eest-fixtures.sh` (SHA-256 verified) and `zig build eest-runner` (`test/specs/eest_cli.zig`), achieving **66,652 / 66,652 (100.00%, 0 failed, 0 skipped)** across Frontier through Osaka in ~18.5 s and gating every push in CI.
- **Full Glamsterdam (Amsterdam) EIPs**: Implemented EIP-7708 (ETH transfer system logs), EIP-7843 (`SLOTNUM`), EIP-7928 (revert-aware `BalRecorder`), EIP-7954 (64 KiB code / 128 KiB initcode), EIP-8024 (`DUPN`/`SWAPN`/`EXCHANGE`), EIP-8037 (3-register LIFO 2D state gas reservoir), EIP-8038 (state-access repricing), and EIP-8246 (no-burn self-destruct).
- **Lean 4 Formal Verification Expansion (`spec/lean/`)**: Expanded from 60 to **210 machine-checked theorems** (0 `sorry`, 0 custom axioms) with new `EvmSpec/MultiFrame.lean` (multi-frame checkpoint/rollback isolation) and `EvmSpec/AmsterdamGas.lean` (EIP-8037 2D gas conservation).
- **C99 Single-Header API & EVMC ABI 12 Shared Library**: Added `include/guillotine_mini.h` covering all 51 `evm_*` symbols plus `evmc_create_guillotine_mini()`, and `zig build evmc` (`src/evmc_exports.zig`) producing `libguillotine_mini_evmc.{so,dylib}`.
- **51-Symbol C/WASM ABI**: Exported 7 new flamegraph and ABI revert decoder symbols (`evm_enable_flamegraph`, `evm_get_flamegraph_svg{_len}`, `evm_get_flamegraph_folded{_len}`, `evm_decode_revert_json{_len}`) in `src/root_c.zig`.
- **Live Browser WASM Debugger & Playground**: Added `docs/src/pages/play.mdx` and `WasmPlayground.tsx` (time-travel EIP-3155 scrubber, Stack/Memory/Storage/CallTree/SVG Flamegraph/RevertDecoder, and RPC transaction replay) backed by the real `guillotine_mini.wasm` staged in `docs.yml`.
- **Compiled Basic-Block Interpreter & Reusable EVM**: Landed `src/u256_math.zig`, `src/compiled_code.zig`, `ReusableEvm`, and lazy JUMPDEST bitmap construction (comptime-gated off on `wasm32` to keep `guillotine_mini_core.wasm` at 235,150 B / 92.8 KiB gzipped).
- **Reproducible WASM Benchmark**: Added `bench/wasm-compare.mjs` measuring bundle sizes and cold/warm latencies.

### Changed
- **Standalone `zig fetch --save` Support**: Replaced the sibling `../voltaire` path dependency in `build.zig.zon` with a URL+hash pinned Voltaire archive (`93c4e67ddaff`) so Zig consumers can fetch `guillotine-mini` standalone without external checkouts.
- **Minimalist Scope Restoration**: Carved out the duplicated `client/` and `client-ts/` client prototypes (preserved in history at commit `577c5fab`) while retaining `test/specs/header_validator.zig` and `src/bench_utils.zig`; active full-client development lives in `evmts/zevm` and `evmts/guillotine`.
- **100% Companion Module Docs & Zero-Panic Safety**: Added missing companion `*.zig.md` design docs (100% coverage) and eliminated all production `@panic`, `unreachable`, and empty `catch {}` blocks.

### Fixed
- **1024-Slot Stack Overflow Guard**: Caught via the Lean 4 differential fuzzer and fixed `Frame.effectiveStackCap()` (`ensureTotalCapacityPrecise`) so `PUSH` beyond 1024 items always faults at depth 1024.
- **Regex Spec Filter Engine**: Replaced broken substring matching in `test/utils.zig` with a zero-allocation Thompson NFA supporting `.*`, `(a|b)`, and `[^...]`.
- **Lazy Native KZG Trusted Setup**: Lazily initialize Voltaire's embedded KZG trusted setup on native EIP-4844 `0x0a` calls (gated off on `wasm32` to avoid inflating WASM bundles).
- **EIP-6780 / EIP-8246 Cross-Fork Guard**: Gated balance-preserving self-destruct cleanup strictly on `supportsAmsterdam(hardfork)` so Cancun/Prague/Osaka match all 66,652 EEST cases.

## 0.1.0 - 2026-11-25

- First tagged public release with Frontier through Osaka support (`CLZ` EIP-7939, `P256VERIFY` EIP-7951), WASI Preview 1 WASM reactor with linked Rust cryptography, modular precompile bundles, 15-hook `Inspector`, 6 tracers, `StateOverlayHost` simulation, time-travel `DebugSession`, gas flamegraphs, 10 runnable Zig examples, and the initial Lean 4 differential oracle (`14,784` vectors).
