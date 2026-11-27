# `src/u256_math.zig`

High-performance 256-bit and 512-by-256 unsigned arithmetic (`intx`/`ruint` style) replacing LLVM's bit-by-bit restoring `u256`/`u512` division.

## Responsibilities
- Fast paths for 64-bit, 128-bit, and single-limb (`< 2^64`) divisors.
- Knuth Algorithm D over 4×64-bit limbs for general 256-bit division (`div`, `mod`, `divRem`).
- Exact 256×256 → 512-bit product reduction for EVM `MULMOD` (`mulmod`) and `ADDMOD`.

## Safety & Invariants
- Zero panics, zero heap allocations, deterministic across native and `wasm32-wasi` targets.
- Division or modulo by zero returns `0` matching EVM yellow-paper / EELS semantics.
