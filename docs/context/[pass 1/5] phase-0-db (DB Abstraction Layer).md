# [Pass 1/5] Phase 0: DB Abstraction Layer — Context

## Phase Goal (from `prd/GUILLOTINE_CLIENT_PLAN.md`)

Create a database abstraction layer for persistent storage.

Planned components:
- `client/db/adapter.zig` — generic DB interface
- `client/db/rocksdb.zig` — RocksDB backend
- `client/db/memory.zig` — in-memory backend for tests

## Specs (from `prd/ETHEREUM_SPECS_REFERENCE.md`)

- Phase 0 has **no external execution specs**.
- Tests: **unit tests only** (no fixture suites required for this phase).

## Nethermind DB Reference (from `nethermind/src/Nethermind/Nethermind.Db/`)

Full directory listing (use as architectural reference):
- `nethermind/src/Nethermind/Nethermind.Db/BlobTxsColumns.cs`
- `nethermind/src/Nethermind/Nethermind.Db/Blooms/`
- `nethermind/src/Nethermind/Nethermind.Db/CompressingDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/DbExtensions.cs`
- `nethermind/src/Nethermind/Nethermind.Db/DbNames.cs`
- `nethermind/src/Nethermind/Nethermind.Db/DbProvider.cs`
- `nethermind/src/Nethermind/Nethermind.Db/DbProviderExtensions.cs`
- `nethermind/src/Nethermind/Nethermind.Db/FullPruning/`
- `nethermind/src/Nethermind/Nethermind.Db/FullPruningCompletionBehavior.cs`
- `nethermind/src/Nethermind/Nethermind.Db/FullPruningTrigger.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IColumnsDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IDbFactory.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IDbProvider.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IFullDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IMergeOperator.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IPruningConfig.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IReadOnlyDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IReadOnlyDbProvider.cs`
- `nethermind/src/Nethermind/Nethermind.Db/ITunableDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/InMemoryColumnBatch.cs`
- `nethermind/src/Nethermind/Nethermind.Db/InMemoryWriteBatch.cs`
- `nethermind/src/Nethermind/Nethermind.Db/MemColumnsDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/MemDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/MemDbFactory.cs`
- `nethermind/src/Nethermind/Nethermind.Db/MetadataDbKeys.cs`
- `nethermind/src/Nethermind/Nethermind.Db/Metrics.cs`
- `nethermind/src/Nethermind/Nethermind.Db/Nethermind.Db.csproj`
- `nethermind/src/Nethermind/Nethermind.Db/NullDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/NullRocksDbFactory.cs`
- `nethermind/src/Nethermind/Nethermind.Db/PruningConfig.cs`
- `nethermind/src/Nethermind/Nethermind.Db/PruningMode.cs`
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyColumnsDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDbProvider.cs`
- `nethermind/src/Nethermind/Nethermind.Db/ReceiptsColumns.cs`
- `nethermind/src/Nethermind/Nethermind.Db/RocksDbMergeEnumerator.cs`
- `nethermind/src/Nethermind/Nethermind.Db/RocksDbSettings.cs`
- `nethermind/src/Nethermind/Nethermind.Db/SimpleFilePublicKeyDb.cs`

## Voltaire Zig APIs

Requested path: `/Users/williamcory/voltaire/packages/voltaire-zig/src/` — **not found** on disk.

Available Voltaire Zig sources live under `/Users/williamcory/voltaire/src/`.

DB-specific primitives found at:
- `/Users/williamcory/voltaire/src/primitives/Db/db.zig`

Key types in `db.zig` (modeled after Nethermind Db/KeyValueStore):
- `Error` (StorageError, KeyTooLarge, ValueTooLarge, DatabaseClosed, OutOfMemory, UnsupportedOperation)
- `DbName` enum (state, storage, code, blocks, headers, block_numbers, receipts, block_infos, bad_blocks, bloom, metadata, blob_transactions, discovery_nodes, discovery_v5_nodes, peers) + `to_string()` matching `DbNames`.
- `ReadFlags` and `WriteFlags` bitfields with merge/has helpers.
- `DbMetric` for size/read/write metrics.
- `DbValue` (borrowed values with optional release callback), `DbEntry`.
- `DbIterator` and `DbSnapshot` with comptime-bound dispatch + opaque init.

Other Voltaire primitives for typed keys/values (sample, not exhaustive):
- `/Users/williamcory/voltaire/src/primitives/Address/`
- `/Users/williamcory/voltaire/src/primitives/Hash/`
- `/Users/williamcory/voltaire/src/primitives/Hex/`
- `/Users/williamcory/voltaire/src/primitives/Bytes/`
- `/Users/williamcory/voltaire/src/primitives/Bytes32/`
- `/Users/williamcory/voltaire/src/primitives/BlockHash/`
- `/Users/williamcory/voltaire/src/primitives/TransactionHash/`
- `/Users/williamcory/voltaire/src/primitives/U256/`
- `/Users/williamcory/voltaire/src/primitives/Uint64/`

## Existing Zig Host Interface (from `src/host.zig`)

`HostInterface` is a vtable-based adapter for external state access:
- `getBalance` / `setBalance` (Address → u256)
- `getCode` / `setCode` (Address → bytecode)
- `getStorage` / `setStorage` (Address + slot → value)
- `getNonce` / `setNonce` (Address → u64)

## Ethereum Test Fixtures (from `ethereum-tests/`)

Phase 0 uses unit tests only, but fixture directories exist for later phases:
- `ethereum-tests/ABITests/`
- `ethereum-tests/BasicTests/`
- `ethereum-tests/BlockchainTests/`
- `ethereum-tests/DifficultyTests/`
- `ethereum-tests/EOFTests/`
- `ethereum-tests/GenesisTests/`
- `ethereum-tests/KeyStoreTests/`
- `ethereum-tests/LegacyTests/`
- `ethereum-tests/PoWTests/`
- `ethereum-tests/RLPTests/`
- `ethereum-tests/TransactionTests/`
- `ethereum-tests/TrieTests/`
- `ethereum-tests/fixtures_blockchain_tests.tgz`
- `ethereum-tests/fixtures_general_state_tests.tgz`

## Summary

Phase 0 is an internal DB abstraction with no external spec dependencies. Mirror Nethermind’s DB surface (IDb/IColumnsDb/etc.) and reuse Voltaire’s shared DB primitives in `primitives/Db/db.zig` for flags, names, iterator/snapshot semantics. The originally requested Voltaire Zig path does not exist; Voltaire’s Zig sources live under `/Users/williamcory/voltaire/src/`.
