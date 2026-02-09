# [Pass 2/5] Phase 0: DB Abstraction Layer — Context

## Goal (from `prd/GUILLOTINE_CLIENT_PLAN.md`)

Create a database abstraction layer for persistent key-value storage.

**Key components:**
- `client/db/adapter.zig` — generic DB interface
- `client/db/rocksdb.zig` — RocksDB backend
- `client/db/memory.zig` — in-memory backend for tests

## Specs (from `prd/ETHEREUM_SPECS_REFERENCE.md`)

Phase 0 is an internal abstraction.
- **Specs:** N/A
- **Tests:** unit tests only

## Nethermind DB Architecture (directory listing)

Directory: `nethermind/src/Nethermind/Nethermind.Db/`

**Files present:**
- `BlobTxsColumns.cs`
- `Blooms/`
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
- `Nethermind.Db.csproj`
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

**Key takeaways for Zig design:**
- Interfaces: `IDb`, `IReadOnlyDb`, `IColumnsDb`, `IDbProvider`, `IDbFactory`
- Implementations: `MemDb`, `NullDb`, `ReadOnlyDb`, `MemColumnsDb`
- Metadata: `DbNames`, `Metrics`, `MetadataDbKeys`
- RocksDB config: `RocksDbSettings`, `IMergeOperator`

## Voltaire primitives and modules (directory listing)

Root: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- `primitives/` (Ethereum types)
- `state-manager/` (journaled caches)
- `blockchain/`
- `crypto/`
- `evm/`
- `jsonrpc/`
- `log.zig`, `root.zig`

**Relevant primitives to reference (DB key/value shapes):**
- `primitives/Address/`
- `primitives/Hash/`
- `primitives/Bytes/`
- `primitives/Bytes32/`
- `primitives/Uint/`
- `primitives/Rlp/`
- `primitives/AccountState/`
- `primitives/StateRoot/`
- `primitives/Storage/`, `StorageValue/`, `StorageDiff/`
- `primitives/Transaction/`, `Receipt/`, `BlockHeader/`
- `primitives/trie.zig`

**State-manager modules (possible DB consumers):**
- `state-manager/StateManager.zig`
- `state-manager/JournaledState.zig`
- `state-manager/StateCache.zig`
- `state-manager/ForkBackend.zig`

## Existing Zig Host Interface (for vtable pattern)

File: `src/host.zig`
- Uses `ptr: *anyopaque` + `vtable: *const VTable`
- VTable exposes `getBalance`, `setBalance`, `getCode`, `setCode`, `getStorage`, `setStorage`, `getNonce`, `setNonce`
- Forwarding methods are thin wrappers around `vtable` calls

**Takeaway:** DB adapter should mirror this pattern for comptime DI.

## Ethereum tests directory listing (fixtures)

Directory: `ethereum-tests/`
- `ABITests/`
- `BasicTests/`
- `BlockchainTests/`
- `DifficultyTests/`
- `EOFTests/`
- `GenesisTests/`
- `JSONSchema/`
- `KeyStoreTests/`
- `LegacyTests/`
- `PoWTests/`
- `RLPTests/`
- `TransactionTests/`
- `TrieTests/`
- `fixtures_blockchain_tests.tgz`
- `fixtures_general_state_tests.tgz`
- `src/`

**Phase 0 note:** no external fixtures are required; use unit tests only.

## Summary

This pass collected the Phase 0 plan goals, confirmed that no Ethereum spec governs DB abstraction, recorded Nethermind DB module files to mirror architecture, listed Voltaire primitives/modules to use for key/value types, captured the existing HostInterface vtable pattern, and enumerated `ethereum-tests/` fixture directories for later phases.
