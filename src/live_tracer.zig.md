# `src/live_tracer.zig`

Block-level and chain-level live tracing hooks modeled after Geth's `core/tracing.Hooks`.

## Responsibilities
- **`BlockHooks`**: Read-only vtable for chain/block lifecycle events (`onBlockchainInit`, `onGenesisBlock`, `onBlockStart`, `onBlockEnd`, `onSkippedBlock`, `onSystemCallStart`, `onSystemCallEnd`, `onBlockBalanceChange`, `onStateUpdate`, `onClose`) plus an optional `tx_inspector` (`Inspector`) for per-transaction hooks.
- **`MuxBlockHooks`**: Composes multiple `BlockHooks` instances and merges their optional `tx_inspector` hooks into a single fan-out pass.
- **`SignedU256`**: Allocation-free signed 256-bit magnitude helper with panic-free hex formatting (`formatHexBuf`).
- **`SupplyTracer`**: Reference Geth `--vmtrace supply` live tracer tracking ETH issuance (genesis, block/uncle rewards, withdrawals), burn (EIP-1559 base fees, EIP-4844 blob fees via `GAS_PER_BLOB`, miscellaneous), per-block deltas, cumulative totals, and JSON/NDJSON serialization (`writeRecordJson`, `writeJsonlRecord`, `writeSummaryJson`).

## Ownership & Safety
- Hook callbacks return `void` and record their first allocation error in `SupplyTracer.err`, surfacing it from JSON writers without panicking.
