# `src/hardfork_hooks.zig`

Self-contained hardfork readiness hooks for Osaka capabilities and Glamsterdam (Amsterdam) extension points.

## Responsibilities
- **Comptime Capability Helpers**: `hasFork`, `isAtLeast`, `supportsClz` (EIP-7939), `supportsP256Verify` (EIP-7951), `supportsEip7825TxGasCap` (EIP-7825), `supportsAmsterdam`, `supportsEthTransferLogs` (EIP-7708), `supportsBlockAccessList` (EIP-7928), `supportsStateGas` (EIP-8037), `txGasLimitCap`, and `isTxGasLimitAllowed`.
- **EIP-7708 ETH Transfer System Logs (`eth_transfer_log`)**: Allocation-free `SystemLog` builders and precomputed `Transfer(address,address,uint256)` topic0 constants emitted from `SYSTEM_ADDRESS` (`0xff..fe`).
- **EIP-7928 Block-Level Access Lists (`block_access_list`)**: Generic recorder interface with zero-cost `NoopRecorder` and list-backed recorders.
- **EIP-8037 / EIP-8038 State Gas (`GasSplit`, `GasSchedule`, `StateGasReservoir`)**: Fork-parameterized regular vs. state gas schedule and reservoir accounting.

## Design Invariants
- Imports only `std`, compiling cleanly against any Voltaire `Hardfork` enum pin via `@hasField` comptime checks so unactivated future fork hooks fold away with zero runtime overhead.
