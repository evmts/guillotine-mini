# Context: Phase 0 DB Abstraction Layer (pass 2/5)

## Goals (from plan)
- Provide a database abstraction layer for persistent storage.
- Target components: `client/db/adapter.zig`, `client/db/rocksdb.zig`, `client/db/memory.zig`.
- Follow Nethermind DB architecture as reference.

Source: `repo_link/prd/GUILLOTINE_CLIENT_PLAN.md`.

## Spec References
- Phase 0 has no external spec requirements (internal abstraction only).

Source: `repo_link/prd/ETHEREUM_SPECS_REFERENCE.md`.

## Nethermind DB Reference Files
Located in `repo_link/nethermind/src/Nethermind/Nethermind.Db/`:
- `BlobTxsColumns.cs`
- `CompressingDb.cs`
- `DbExtensions.cs`
- `DbNames.cs`
- `DbProvider.cs`
- `DbProviderExtensions.cs`
- `FullPruning/`
- `FullPruningCompletionBehavior.cs`
- `FullPruningTrigger.cs`
- `IColumnsDb.cs`
- `IDb.cs`
- `IDbFactory.cs`
- `IDbProvider.cs`
- `IFullDb.cs`
- `IMergeOperator.cs`
- `IPruningConfig.cs`
- `IReadOnlyDb.cs`
- `IReadOnlyDbProvider.cs`
- `ITunableDb.cs`
- `InMemoryColumnBatch.cs`
- `InMemoryWriteBatch.cs`
- `MemColumnsDb.cs`
- `MemDb.cs`
- `MemDbFactory.cs`
- `MetadataDbKeys.cs`
- `Metrics.cs`
- `NullDb.cs`
- `NullRocksDbFactory.cs`
- `PruningConfig.cs`
- `PruningMode.cs`
- `ReadOnlyColumnsDb.cs`
- `ReadOnlyDb.cs`
- `ReadOnlyDbProvider.cs`
- `ReceiptsColumns.cs`
- `RocksDbMergeEnumerator.cs`
- `RocksDbSettings.cs`
- `SimpleFilePublicKeyDb.cs`

## Voltaire Primitives (candidate DB key/value types)
No DB-specific primitives are present under `voltaire/packages/voltaire-zig/src/`.
Useful building blocks for DB keys/values likely include:
- `primitives/Bytes`
- `primitives/Bytes32`
- `primitives/Hash`
- `primitives/Address`
- `primitives/StorageValue`

Root listing: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`.

## Existing Guillotine EVM Host Interface
File: `repo_link/src/host.zig`
- Defines `HostInterface` with a vtable for balance, code, storage, and nonce access.
- Interface uses `primitives.Address.Address` and `u256` for storage/balance values.
- Notes that nested calls are handled internally by the EVM and do not use this host interface.

## Test Fixtures
Ethereum test suite directories (for later phases, none required for phase 0):
- `repo_link/ethereum-tests/ABITests`
- `repo_link/ethereum-tests/BasicTests`
- `repo_link/ethereum-tests/BlockchainTests`
- `repo_link/ethereum-tests/DifficultyTests`
- `repo_link/ethereum-tests/EOFTests`
- `repo_link/ethereum-tests/GenesisTests`
- `repo_link/ethereum-tests/JSONSchema`
- `repo_link/ethereum-tests/KeyStoreTests`
- `repo_link/ethereum-tests/LegacyTests`
- `repo_link/ethereum-tests/PoWTests`
- `repo_link/ethereum-tests/RLPTests`
- `repo_link/ethereum-tests/TransactionTests`
- `repo_link/ethereum-tests/TrieTests`

## Summary
Phase 0 requires a DB abstraction with in-memory and RocksDB backends, aligned to Nethermind's `Nethermind.Db` structure. There are no execution-spec or EIP requirements for this phase. Voltaire provides general primitives (Bytes/Hash/Address/etc.) but no DB-specific types; DB interfaces should be built using these primitives. The existing `HostInterface` provides state access primitives to align DB storage expectations (balances, code, storage, nonces).
