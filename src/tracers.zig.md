# `src/tracers.zig`

Built-in native EVM tracers, profilers, and coverage inspectors implemented on [`inspector.zig`](inspector.zig).

## Responsibilities
- **`CallTracer`**: Records nested `CallFrame` trees (including logs and `SELFDESTRUCT` pseudo-frames) and emits Geth `callTracer` JSON (`writeGethJson`, streaming without nesting limits up to EVM depth 1024) and Parity `flatCallTracer` / `trace_*` JSON (`writeFlatJson`), decoding revert reasons via `RevertDecoder`.
- **`FourByteTracer`**: Counts `(selector, calldata_arg_size)` invocations for non-precompile call frames and emits deterministic sorted JSON (`writeJson`).
- **`PrestateTracer`**: Tracks pre- and post-execution account balances, nonces, code (including EIP-7702 delegations), and storage with frame-scoped undo rollback on revert; supports Geth `prestateTracer` and `diffMode`.
- **`AccessListInspector`**: Collects EIP-2929 accessed addresses and storage slots (excluding origin, target, precompiles, and created contracts per Geth rules) for `eth_createAccessList` (`toOwnedEntries`, `writeJson`).
- **`GasProfiler`**: Aggregates per-opcode histograms (`OpcodeStats`, `topOpcodes`) and inclusive/exclusive per-frame gas profiles (`FrameGasProfile`).
- **`CoverageInspector`**: Records PC hit counts, control-flow edges, and `JUMPI` taken/not-taken branch counts keyed by `keccak256(code)`.

## Ownership & Safety
- Every tracer catches internal allocation failures in `self.err`, halts further recording, surfaces the error from writers, and frees all allocations in `deinit`.
- `CallTracer` and `AccessListInspector` are also exposed via the C/WASM ABI in [`root_c.zig`](root_c.zig).
