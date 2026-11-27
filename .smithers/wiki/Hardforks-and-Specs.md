---
title: Hardforks, Specs, and Lean 4 Oracle
tags: [hardforks, specs, osaka, glamsterdam, lean4, testing]
---

# Hardforks, Specs, and Lean 4 Oracle

In Guillotine Mini, **Python `execution-specs` is authoritative** and **`spec/lean/` provides a machine-checked executable oracle**. Every gas schedule, hardfork guard, and error mapping must match consensus exactly. See [[Architecture]] and [[Backpressure-and-Quality]].

## Supported Hardforks

| Era | Hardforks | Key Semantics |
| --- | --- | --- |
| Classic | Frontier, Homestead, Tangerine Whistle, Spurious Dragon | Base opcodes, EIP-150 63/64 gas forwarding, EIP-161 empty account clearing |
| Byzantium - Istanbul | Byzantium, Constantinople, Petersburg, Istanbul | `STATICCALL`, `REVERT`, `CREATE2`, `EXTCODEHASH`, `CHAINID`, `SELFBALANCE`, BLAKE2f |
| Berlin - London | Berlin, London | EIP-2929 cold/warm access lists, EIP-3529 1/5 refund cap, EIP-1559 `BASEFEE` |
| Merge - Shanghai | Merge, Shanghai | `PREVRANDAO`, EIP-3855 `PUSH0`, EIP-3860 initcode size & word cost, EIP-3651 warm coinbase |
| Cancun - Prague | Cancun, Prague | EIP-1153 `TLOAD`/`TSTORE`, EIP-5656 `MCOPY`, EIP-6780 `SELFDESTRUCT`, EIP-4844 blobs, EIP-7702 |
| Osaka & Next | **Osaka (DEFAULT)**, Amsterdam / Glamsterdam hooks | EIP-7939 `CLZ`, EIP-7951 `P256VERIFY`, EIP-7825 tx gas cap, `src/hardfork_hooks.zig` |

## Consensus Invariants Enforced on Every Review

1. **Gas before effect**: Gas is always charged before mutating stack, memory, or storage, matching Python's exact validation order (e.g., `SSTORE` checks the 2300 stipend before computing dynamic gas).
2. **Fork guard monotonicity**: Always gate fork behavior with `hardfork.isAtLeast(.FORK)` or `hardfork.isBefore(.FORK)` so earlier forks never drift.
3. **Transaction-scoped warm sets**: Warm/cold access sets are cumulative across a transaction, roll back on revert, and reset between transactions.
4. **Transient storage**: `TLOAD`/`TSTORE` slots are always warm, cleared at transaction end, rolled back on revert, and forbidden in static context.
5. **Signed gas refunds**: Refunds may go negative mid-transaction and are capped only at transaction finalization (1/2 pre-London, 1/5 London+).

## The 7-Checkpoint Spec-Fix Method

The `.smithers/flows/spec-fix/flow.mdx` flow enforces seven evidence-backed checkpoints with zero placeholders:
1. Run `TEST_FILTER="<name>" zig build specs` and record the failure.
2. Run `bun scripts/isolate-test.ts "<name>"` to capture the EIP-3155 trace divergence.
3. Quote the authoritative Python reference in `execution-specs/src/ethereum/forks/<fork>/vm/`.
4. Quote the corresponding Zig code in `src/frame.zig`, `src/evm.zig`, or `src/instructions/`.
5. Diagnose root cause and gas/fork invariant.
6. Apply minimal fix preserving hardfork guards (never modifying test fixtures or submodules).
7. Re-run isolated test, `zig build unit`, `zig build test-trace`, and affected spec subset.

## Lean 4 Formal Verification Oracle (`spec/lean/`)

- Located in `spec/lean/EvmSpec/` (`Word.lean`, `Bytecode.lean`, `Gas.lean`, `Machine.lean`, `Theorems.lean`, `Main.lean`).
- Differential fuzzer (`LEAN_DIFF_REQUIRE=1 zig build lean-diff -Doptimize=ReleaseFast`) compares 14,784+ execution vectors between Zig and Lean 4 in CI.
- Hard Uphill invariant (`verification/lean-no-sorry`): **zero `sorry` and zero unproved `axiom` declarations** anywhere in `spec/lean/`.

## Related Pages

- [[Overview]]
- [[Architecture]]
- [[Backpressure-and-Quality]]
- [[Decisions]]
