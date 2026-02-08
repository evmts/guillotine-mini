# Context: Phase 10 Runner (Entry Point + CLI)

## Goals (Phase 10: Runner)
Source: `repo_link/prd/GUILLOTINE_CLIENT_PLAN.md`
- Create the CLI entry point and configuration.
- Key components:
  - `client/main.zig` (main entry point)
  - `client/config.zig` (configuration management)
  - `client/cli.zig` (CLI argument parsing)
- Nethermind reference: `repo_link/nethermind/src/Nethermind/Nethermind.Runner/`

## Relevant Specs
Source: `repo_link/prd/ETHEREUM_SPECS_REFERENCE.md`
- Phase 10 Runner specs: N/A (CLI/configuration)
- Tests: Integration tests and `hive/` full node tests

## Nethermind Db Files (for architectural patterns)
Directory: `repo_link/nethermind/src/Nethermind/Nethermind.Db/`
- `BlobTxsColumns.cs`
- `CompressingDb.cs`
- `DbProvider.cs`
- `DbProviderExtensions.cs`
- `IColumnsDb.cs`, `IDb.cs`, `IDbFactory.cs`, `IDbProvider.cs`
- `IReadOnlyDb.cs`, `IReadOnlyDbProvider.cs`, `ITunableDb.cs`
- `MemDb.cs`, `MemDbFactory.cs`, `MemColumnsDb.cs`
- `NullDb.cs`, `NullRocksDbFactory.cs`
- `ReadOnlyColumnsDb.cs`, `ReadOnlyDb.cs`, `ReadOnlyDbProvider.cs`
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`
- `ReceiptsColumns.cs`
- `PruningConfig.cs`, `PruningMode.cs`, `IPruningConfig.cs`
- `DbNames.cs`, `DbExtensions.cs`, `MetadataDbKeys.cs`, `Metrics.cs`

## Voltaire Zig APIs (available primitives/modules)
Directory: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- `blockchain/`
- `crypto/`
- `evm/`
- `jsonrpc/`
- `precompiles/`
- `primitives/`
- `state-manager/`
- `log.zig`
- `root.zig`

## Existing Zig Host Interface
File: `repo_link/src/host.zig`
- `HostInterface` provides a vtable-based interface with:
  - `getBalance`, `setBalance`
  - `getCode`, `setCode`
  - `getStorage`, `setStorage`
  - `getNonce`, `setNonce`
- Minimal host interface used for external state access; nested calls are handled internally in EVM.

## Ethereum Tests Fixtures
Directory: `repo_link/ethereum-tests/`
- `ABITests/`
- `BasicTests/`
- `BlockchainTests/`
- `DifficultyTests/`
- `EOFTests/`
- `GenesisTests/`
- `KeyStoreTests/`
- `LegacyTests/`
- `PoWTests/`
- `RLPTests/`
- `TransactionTests/`
- `TrieTests/`
- `fixtures_blockchain_tests.tgz`
- `fixtures_general_state_tests.tgz`

## Summary
Phase 10 focuses on a CLI runner with configuration and argument parsing. Specs are N/A for this phase, with integration and hive full-node tests as references. Nethermind’s Runner module is the structural reference; the Db module contains patterns that may inform configuration/IO boundaries. Voltaire provides primitives and modules (blockchain, evm, jsonrpc, primitives, state-manager). The existing `HostInterface` in `src/host.zig` is a vtable-based external state access interface.
