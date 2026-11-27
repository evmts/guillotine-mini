# `src/simulation.zig`

Isolated state-overlay simulation engine backing standard Ethereum JSON-RPC call, estimation, and multi-block simulation methods.

## Responsibilities
- **`StateOverlayHost`**: Copy-on-write [`HostInterface`](host.zig) over an optional base host with undo-journal `checkpoint`/`revertTo`, code arena storage, and `AccountOverride` (`balance`, `nonce`, `code`, full `state`, sparse `state_diff`) plus `BlockOverride` support. Base host state is never mutated.
- **Transaction Gas & Validation**: `intrinsicGas`, `floorDataGas` (EIP-7623), and `minimumGas` matching Prague/Osaka `process_transaction` semantics, including EIP-7702 `AuthorizationTuple` handling.
- **RPC Operations**:
  - `executeOnOverlay` / `simulateCall`: Executes `eth_call`, `debug_traceCall`, and `trace_call` with optional `Inspector` and `Tracer`.
  - `estimateGas` / `estimateGasDetailed`: Binary-searches the minimal passing gas limit within Geth's 1.5% error ratio.
  - `createAccessList`: Iteratively converges an EIP-2930 access list via `AccessListInspector` (capped at 10 iterations).
  - `simulateV1`: Multi-block `eth_simulateV1` simulation (up to `MAX_SIMULATED_BLOCKS = 256`) with per-block overrides, sequential state propagation, and log/call result reporting.
- **Error Formatting**: `revertMessage` (via [`RevertDecoder`](inspector.zig)) and `invalidMessage`.
