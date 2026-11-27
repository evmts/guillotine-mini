# `src/compiled_code.zig`

Single-pass basic-block bytecode compiler and superinstruction cache for `guillotine-mini`.

## Responsibilities
- Compiles raw EVM bytecode into a compact 16-byte instruction stream (`Inst`) with basic-block static gas and stack-bounds fusion (`begin_block`).
- Pre-decodes `PUSH1..8` inline immediates, pools `PUSH9..32` constants, and pre-validates static jump targets (`push_jump`, `push_jumpi`, `iszero_push_jumpi`).
- Fuses hot immediate arithmetic/comparison/bitwise idioms (`push_add`, `push_sub`, `push_mul`, `push_lt`, `push_eq`, `push_and`, `push_shl`, `push_shr`, `swap1_pop`).
- Direct-mapped `CodeCache` reused across calls via `ReusableEvm`.

## Consensus Safety & Gating
- Gated at comptime by `EvmConfig.enable_compiled_interpreter` (enabled on native builds; disabled on `wasm32` in `src/root_c.zig` to preserve the `guillotine_mini_core.wasm` byte budget).
- Whenever a `begin_block` gas/stack pre-check fails, execution falls back to the un-fused step interpreter at the block's exact `raw_pc`, preserving exact EVM error semantics.
- Bypassed automatically when any `Inspector`, `Tracer`, `opcode_overrides`, `loop_quota`, JS opcode callback, or `AsyncExecutor` is active.
