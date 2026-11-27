---
title: Hardforks, Specs, and Lean 4 Oracle
tags: [hardforks, specs, osaka, glamsterdam, lean4, testing]
---

# Hardforks, Specs, and Lean 4 Oracle

In Guillotine Mini, **Python `execution-specs` and official EEST `tests@v21.0.3` fixtures are authoritative**, and **`spec/lean/` provides a machine-checked executable oracle with 210 theorems**. Every gas schedule, hardfork guard, and error mapping must match consensus exactly. See [[Architecture]] and [[Backpressure-and-Quality]].

## Supported Hardforks & EEST Conformance

Verified on every push in CI (`zig build eest-runner -Doptimize=ReleaseFast`) against official `ethereum/execution-spec-tests` `tests@v21.0.3`: **66,652 / 66,652 (100.00%, 0 failed, 0 skipped)** across all 14 mainnet hardforks from Frontier through Osaka in ~18.5 s.

| Era | Hardforks | Key Semantics | EEST `tests@v21.0.3` |
| --- | --- | --- | ---: |
| Classic | Frontier, Homestead, Tangerine Whistle, Spurious Dragon | Base opcodes, EIP-150 63/64 gas forwarding, EIP-161 empty account clearing | 3,538 / 3,538 |
| Byzantium - Istanbul | Byzantium, Constantinople Fix, Istanbul | `STATICCALL`, `REVERT`, `CREATE2`, `EXTCODEHASH`, `CHAINID`, `SELFBALANCE`, BLAKE2f | 7,509 / 7,509 |
| Berlin - London | Berlin, London | EIP-2929 cold/warm access lists, EIP-3529 1/5 refund cap, EIP-1559 `BASEFEE` | 7,467 / 7,467 |
| Merge - Shanghai | Paris (Merge), Shanghai | `PREVRANDAO`, EIP-3855 `PUSH0`, EIP-3860 initcode size & word cost, EIP-3651 warm coinbase | 7,977 / 7,977 |
| Cancun - Prague | Cancun, Prague | EIP-1153 `TLOAD`/`TSTORE`, EIP-5656 `MCOPY`, EIP-6780 `SELFDESTRUCT`, EIP-4844 blobs, EIP-7702 | 25,497 / 25,497 |
| Osaka | **Osaka (DEFAULT)** | EIP-7939 `CLZ`, EIP-7951 `P256VERIFY`, EIP-7825 tx gas cap, EIP-7623 floor gas | 14,664 / 14,664 |
| Glamsterdam | **Amsterdam** | EIP-7708 (ETH transfer logs), EIP-7843 (`SLOTNUM`), EIP-7928 (BAL), EIP-7954 (64/128 KiB), EIP-8024 (`DUPN`/`SWAPN`/`EXCHANGE`), EIP-8037 (2D state gas), EIP-8038 (repricing), EIP-8246 (no-burn self-destruct) | EVM unit-verified |

## Consensus Invariants Enforced on Every Review

1. **Gas before effect**: Gas is always charged before mutating stack, memory, or storage, matching Python's exact validation order (e.g., `SSTORE` checks the 2300 stipend before computing dynamic gas).
2. **Fork guard monotonicity**: Always gate fork behavior with `hardfork.isAtLeast(.FORK)` or `hardfork_hooks.supportsAmsterdam(hardfork)` so earlier forks never drift.
3. **Transaction-scoped warm sets**: Warm/cold access sets are cumulative across a transaction, roll back on revert, and reset between transactions.
4. **Transient storage**: `TLOAD`/`TSTORE` slots are always warm, cleared at transaction end, rolled back on revert, and forbidden in static context.
5. **Signed gas refunds**: Refunds may go negative mid-transaction and are capped only at transaction finalization (1/2 pre-London, 1/5 London+).
6. **Exact 1024-slot stack limit**: `Frame.effectiveStackCap()` enforces Yellow Paper's 1024-item stack cap regardless of allocator over-capacity.

## The 7-Checkpoint Spec-Fix Method

The `.smithers/flows/spec-fix/flow.mdx` flow enforces seven evidence-backed checkpoints with zero placeholders:
1. Run `TEST_FILTER="<regex>" zig build specs` (supports full Thompson NFA `.*`, `(a|b)`, `[^...]`) and record the failure.
2. Run `bun scripts/isolate-test.ts "<name>"` to capture the EIP-3155 trace divergence.
3. Quote the authoritative Python reference in `execution-specs/src/ethereum/forks/<fork>/vm/`.
4. Quote the corresponding Zig code in `src/frame.zig`, `src/evm.zig`, or `src/instructions/`.
5. Diagnose root cause and gas/fork invariant.
6. Apply minimal fix preserving hardfork guards (never modifying test fixtures or submodules).
7. Re-run isolated test, `zig build unit`, `zig build test-trace`, and `zig build eest-runner`.

## Lean 4 Formal Verification Oracle (`spec/lean/`)

- Located in `spec/lean/EvmSpec/` (`Word.lean`, `Bytecode.lean`, `Gas.lean`, `Machine.lean`, `Theorems.lean`, `MultiFrame.lean`, `AmsterdamGas.lean`, `Main.lean`).
- **210 machine-checked theorems** (66 core + 68 multi-frame rollback/isolation + 76 Glamsterdam EIP-8037 2D gas & EIP-8024 proofs) with **0 `sorry`** and **0 custom axioms**.
- Differential fuzzer (`LEAN_DIFF_REQUIRE=1 zig build lean-diff -Doptimize=ReleaseFast`) compares **14,784 execution vectors** between Zig and Lean 4 in CI with **0 mismatches**.

## Related Pages

- [[Overview]]
- [[Architecture]]
- [[Backpressure-and-Quality]]
- [[Decisions]]
