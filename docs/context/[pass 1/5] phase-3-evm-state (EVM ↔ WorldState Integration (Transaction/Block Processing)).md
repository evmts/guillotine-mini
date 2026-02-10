# [pass 1/5] phase-3-evm-state (EVM ↔ WorldState Integration (Transaction/Block Processing))

## Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Connect the guillotine-mini EVM to WorldState for transaction and block processing.
- Key components: `client/evm/host_adapter.zig`, `client/evm/processor.zig`.
- Reference architecture: `nethermind/src/Nethermind/Nethermind.Evm/` and guillotine-mini `src/evm.zig`, `src/host.zig`.
- Tests (plan): `ethereum-tests/GeneralStateTests/`, `execution-spec-tests/`.

## Spec References (from prd/ETHEREUM_SPECS_REFERENCE.md)
- `execution-specs/src/ethereum/forks/*/vm/__init__.py` (EVM data model).
- `execution-specs/src/ethereum/forks/*/fork.py` (transaction processing).
- Tests: `ethereum-tests/GeneralStateTests/`, `execution-spec-tests/fixtures/state_tests/`.

## Nethermind.Db Inventory (nethermind/src/Nethermind/Nethermind.Db/)
- Interfaces: `IDb.cs`, `IColumnsDb.cs`, `IReadOnlyDb.cs`, `IReadOnlyDbProvider.cs`, `IDbProvider.cs`, `IFullDb.cs`, `ITunableDb.cs`, `IDbFactory.cs`, `IMergeOperator.cs`, `IPruningConfig.cs`.
- Providers/extensions: `DbProvider.cs`, `DbProviderExtensions.cs`, `DbExtensions.cs`, `DbNames.cs`.
- In-memory/read-only: `MemDb.cs`, `MemColumnsDb.cs`, `MemDbFactory.cs`, `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `ReadOnlyDbProvider.cs`, `InMemoryColumnBatch.cs`, `InMemoryWriteBatch.cs`.
- RocksDB + null implementations: `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`, `NullDb.cs`, `NullRocksDbFactory.cs`.
- Pruning/metrics: `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/*`, `FullPruningTrigger.cs`, `FullPruningCompletionBehavior.cs`, `Metrics.cs`.
- Column schemas/metadata: `BlobTxsColumns.cs`, `ReceiptsColumns.cs`, `MetadataDbKeys.cs`.

## Voltaire (requested path)
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/` is not present in this workspace.
- Fallback inventory observed at `/Users/williamcory/voltaire/src/`.
- Relevant modules in `/Users/williamcory/voltaire/src/`: `evm/`, `state-manager/`, `primitives/`, `transaction/`, `block/`, `blockchain/`, `precompiles/`, `contract/`.
- Zig entrypoints visible in `/Users/williamcory/voltaire/src/`: `c_api.zig`, `log.zig`, `root.zig`.

## Guillotine-mini Host Interface (src/host.zig)
- `HostInterface` vtable provides balance/code/storage/nonce access:
  - `getBalance`, `setBalance`, `getCode`, `setCode`, `getStorage`, `setStorage`, `getNonce`, `setNonce`.
- Intended for external state access; nested calls are handled internally by the EVM.

## Test Fixtures (ethereum-tests/)
Top-level directories:
- `ABITests/`, `BasicTests/`, `BlockchainTests/`, `DifficultyTests/`, `EOFTests/`, `GenesisTests/`, `KeyStoreTests/`, `LegacyTests/`, `PoWTests/`, `RLPTests/`, `TransactionTests/`, `TrieTests/`.
- Fixtures tarballs: `fixtures_general_state_tests.tgz`, `fixtures_blockchain_tests.tgz`.
- NOTE: `GeneralStateTests/` directory is not present in this checkout (only the tarball).

## Test Fixtures (execution-spec-tests/)
- `execution-spec-tests/` is present but empty in this checkout; no `fixtures/state_tests/` directory found.
