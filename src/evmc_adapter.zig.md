# `src/evmc_adapter.zig`

EVMC v11/v12 C-ABI types and `HostInterface` + `Inspector` bridge.

## Responsibilities
- **Exact C-ABI Layouts**: Defines `extern struct` and `enum(c_int)` types matching `evmc.h` (`EVMC_ABI_VERSION = 12`, `EvmcAddress`, `EvmcBytes32`, `EvmcMessage`, `EvmcResult`, `EvmcTxContext`, `EvmcHostInterface`, `EvmcCallKind`, `EvmcStatusCode`, `EvmcRevision`, `EvmcAccessStatus`, `EvmcStorageStatus`), verified at comptime for size and alignment.
- **Hardfork Mapping**: `fromHardfork` and `toHardfork` convert between Voltaire `Hardfork` (`Frontier`..`Osaka` and newer experimental forks) and `EvmcRevision` without panicking.
- **`EvmcHostBridge`**: Adapts `guillotine-mini`'s [`HostInterface`](host.zig) and optional [`Inspector`](inspector.zig) into a callable `EvmcHostInterface` callback table, tracking EIP-2200 storage transitions, EIP-2929 warm/cold sets, EIP-1153 transient storage, historical block hashes, logs, and selfdestructs.

## Ownership & Safety
- `EvmcHostBridge.deinit` releases all hash maps and recorded log buffers.
- Allocation errors inside C callbacks are recorded in `EvmcHostBridge.err` rather than panicking across the C ABI boundary.
