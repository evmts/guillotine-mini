# `src/evmc_exports.zig` — EVMC ABI 12 Shared Library Entry Point

Exports `evmc_create_guillotine_mini()` so any EVMC v11/v12 host (`evmc run`,
Reth, Erigon, Silkworm, Besu) can load Guillotine Mini as a shared library
(`libguillotine_mini_evmc.so` / `.dylib`).

## Architecture

- **`EvmcVm`**: Exact C-ABI layout matching `struct evmc_vm` in `evmc.h`
  (`abi_version = 12`, `name`, `version`, `destroy`, `execute`,
  `get_capabilities`, `set_option`).
- **`HostProxy`**: Bridges an inbound C-ABI `EvmcHostInterface` into
  Guillotine Mini's `HostInterface`, forwarding storage reads/writes, balances,
  code lookups, block/transaction context, and emitted logs.
- **Capabilities**: Declares `EVMC_CAPABILITY_EVM1 | EVMC_CAPABILITY_PRECOMPILES`.
- **Options**: Supports `set_option("log_level", "none|err|warn|info|debug")`.
- **Memory safety**: Output buffers are duplicated and released via
  `EvmcResult.release`; all per-call host proxy allocations live in a
  transaction-scoped `ArenaAllocator`.
