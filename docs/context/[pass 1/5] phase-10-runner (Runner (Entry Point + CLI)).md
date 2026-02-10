# [pass 1/5] phase-10-runner (Runner (Entry Point + CLI)) - Context

## 1. Phase Goals and Scope

Source: `prd/GUILLOTINE_CLIENT_PLAN.md`

- Phase: `phase-10-runner`
- Goal: create the CLI entry point and configuration surface
- Planned components:
- `client/main.zig` - main entry point
- `client/config.zig` - configuration management
- `client/cli.zig` - CLI argument parsing
- Structural reference:
- `nethermind/src/Nethermind/Nethermind.Runner/`

## 2. Relevant Ethereum Specs

Source: `prd/ETHEREUM_SPECS_REFERENCE.md`

- For phase 10 runner: **Specs are explicitly N/A** (CLI/configuration phase).
- Test guidance still applies:
- integration tests
- `hive/` full node tests
- Adjacent protocol context that runner wiring must expose correctly:
- `devp2p/rlpx.md`
- `devp2p/caps/eth.md`
- `devp2p/caps/snap.md`
- `devp2p/discv4.md`
- `devp2p/discv5/discv5.md`
- `devp2p/enr.md`

## 3. Nethermind Structure Reference

### Runner module

Path: `nethermind/src/Nethermind/Nethermind.Runner/`

Key files and areas:
- `Program.cs` - primary process entry point and bootstrapping
- `Ethereum/` - Ethereum client startup wiring
- `JsonRpc/` - JSON-RPC hosting/wiring
- `Logging/` - logging setup
- `Monitoring/` - metrics/monitoring setup
- `configs/` - packaged config profiles
- `NethermindPlugins.cs` - plugin discovery/registration
- `ConsoleHelpers.cs` - terminal interaction helpers

### Requested DB listing

Path: `nethermind/src/Nethermind/Nethermind.Db/`

Notable files for architecture alignment:
- `IDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs` - core DB contracts
- `IColumnsDb.cs`, `ITunableDb.cs` - column/tuning contracts
- `IDbProvider.cs`, `DbProvider.cs`, `IDbFactory.cs`, `DbProviderExtensions.cs` - provider/factory access
- `MemDb.cs`, `MemColumnsDb.cs`, `MemDbFactory.cs`, `InMemoryWriteBatch.cs`, `InMemoryColumnBatch.cs` - in-memory implementations
- `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `ReadOnlyDbProvider.cs` - read-only wrappers
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`, `NullRocksDbFactory.cs` - RocksDB integration hooks
- `PruningConfig.cs`, `IPruningConfig.cs`, `PruningMode.cs`, `FullPruning/` - pruning strategy
- `DbNames.cs`, `MetadataDbKeys.cs`, `BlobTxsColumns.cs`, `ReceiptsColumns.cs` - DB naming/column metadata
- `Metrics.cs` - DB metrics instrumentation

## 4. Voltaire Zig APIs Relevant to Runner Wiring

Base path: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`

- `root.zig`:
- exports `Primitives` and `Crypto`
- `jsonrpc/root.zig`:
- exports `JsonRpc`, namespace modules `eth`, `debug`, `engine`
- exports `types` and convenience `JsonRpcMethod`
- `jsonrpc/JsonRpc.zig`:
- defines `JsonRpcMethod` root union (`engine | eth | debug`)
- exposes `methodName()` to recover full JSON-RPC method name
- `jsonrpc/types.zig`:
- shared JSON-RPC types (Address, Hash, Quantity, BlockTag, BlockSpec)
- `blockchain/root.zig`:
- exports `BlockStore`, `ForkBlockCache`, `Blockchain`
- `state-manager/root.zig`:
- exports `StateManager`, `JournaledState`, `ForkBackend`, `StateCache` types
- `c_api.zig`:
- FFI structs such as `PrimitivesAddress`, `PrimitivesHash`, `PrimitivesU256`
- FFI error constants (`PRIMITIVES_ERROR_*`) and KZG constants used by host integrations
- `log.zig`:
- centralized logging utilities used by runtime setup

## 5. Existing Host Interface Contract

Path: `src/host.zig`

`HostInterface` is a ptr + vtable abstraction for external state access, with methods:
- `getBalance` / `setBalance`
- `getCode` / `setCode`
- `getStorage` / `setStorage`
- `getNonce` / `setNonce`

Important note from file header:
- nested calls are handled directly by EVM internals; this host interface is for external state access.

## 6. Ethereum Test Fixture Paths

Top-level fixture suites under `ethereum-tests/`:
- `ABITests/`
- `BasicTests/`
- `BlockchainTests/` (`InvalidBlocks/`, `ValidBlocks/`)
- `DifficultyTests/`
- `EOFTests/`
- `GenesisTests/`
- `KeyStoreTests/`
- `LegacyTests/`
- `PoWTests/`
- `RLPTests/`
- `TransactionTests/`
- `TrieTests/`

Additional useful paths:
- `ethereum-tests/src/BlockchainTestsFiller/`
- `ethereum-tests/src/TransactionTestsFiller/`
- `ethereum-tests/src/EOFTestsFiller/`
- `ethereum-tests/docs/test_types/`
- `ethereum-tests/JSONSchema/`

## Summary

Phase-10 context confirms CLI/config goals and runner-centric architecture: follow `Nethermind.Runner` module boundaries for entrypoint and service bootstrapping, keep DB concerns aligned with `Nethermind.Db` contracts, rely on Voltaire Zig JSON-RPC/type exports for method/type modeling, preserve `src/host.zig` external state interface semantics, and target integration plus hive/full-node style validation with ethereum-tests fixture directories available for broader regression coverage.
