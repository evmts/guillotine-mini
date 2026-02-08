# [Pass 1/5] Phase 0: DB Abstraction Layer — Context

## Phase Goal (from `prd/GUILLOTINE_CLIENT_PLAN.md`)
Create a database abstraction layer for persistent storage. This is an internal interface that underpins later phases.

**Key Components**:
- `client/db/adapter.zig` — generic database interface (vtable-style)
- `client/db/rocksdb.zig` — RocksDB backend implementation
- `client/db/memory.zig` — in-memory backend for tests

## Specs (from `prd/ETHEREUM_SPECS_REFERENCE.md`)
- Phase 0 has **no external protocol specs**.
- Tests: **unit tests only**.

## Nethermind DB Reference (from `nethermind/src/Nethermind/Nethermind.Db/`)
Use these as architectural guidance for interfaces, providers, and backends:

**Core interfaces / providers**
- `nethermind/src/Nethermind/Nethermind.Db/IDb.cs` — main DB interface
- `nethermind/src/Nethermind/Nethermind.Db/IReadOnlyDb.cs` — read-only DB interface
- `nethermind/src/Nethermind/Nethermind.Db/IColumnsDb.cs` — column-family DB abstraction
- `nethermind/src/Nethermind/Nethermind.Db/IDbFactory.cs` — factory for DB creation
- `nethermind/src/Nethermind/Nethermind.Db/IDbProvider.cs` — named DB registry/provider
- `nethermind/src/Nethermind/Nethermind.Db/IReadOnlyDbProvider.cs` — read-only provider
- `nethermind/src/Nethermind/Nethermind.Db/IFullDb.cs` — extended DB interface
- `nethermind/src/Nethermind/Nethermind.Db/IMergeOperator.cs` — merge operator abstraction
- `nethermind/src/Nethermind/Nethermind.Db/ITunableDb.cs` — tunable DB interface

**In-memory implementations / batches**
- `nethermind/src/Nethermind/Nethermind.Db/MemDb.cs` — in-memory DB reference impl
- `nethermind/src/Nethermind/Nethermind.Db/MemColumnsDb.cs` — in-memory column DB
- `nethermind/src/Nethermind/Nethermind.Db/MemDbFactory.cs` — in-memory DB factory
- `nethermind/src/Nethermind/Nethermind.Db/InMemoryWriteBatch.cs` — write batch impl
- `nethermind/src/Nethermind/Nethermind.Db/InMemoryColumnBatch.cs` — column batch impl

**Wrappers / utilities**
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDb.cs` — read-only wrapper
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyColumnsDb.cs` — read-only column wrapper
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDbProvider.cs` — read-only provider
- `nethermind/src/Nethermind/Nethermind.Db/DbProvider.cs` — provider implementation
- `nethermind/src/Nethermind/Nethermind.Db/DbProviderExtensions.cs` — provider helpers
- `nethermind/src/Nethermind/Nethermind.Db/DbExtensions.cs` — DB helpers

**Configuration / metadata / metrics**
- `nethermind/src/Nethermind/Nethermind.Db/DbNames.cs` — canonical DB name constants
- `nethermind/src/Nethermind/Nethermind.Db/MetadataDbKeys.cs` — metadata key constants
- `nethermind/src/Nethermind/Nethermind.Db/RocksDbSettings.cs` — RocksDB settings
- `nethermind/src/Nethermind/Nethermind.Db/Metrics.cs` — DB metrics

**Pruning / maintenance (for later phases)**
- `nethermind/src/Nethermind/Nethermind.Db/FullPruning/` — pruning implementation
- `nethermind/src/Nethermind/Nethermind.Db/PruningConfig.cs` — pruning config
- `nethermind/src/Nethermind/Nethermind.Db/PruningMode.cs` — pruning modes
- `nethermind/src/Nethermind/Nethermind.Db/FullPruningTrigger.cs` — trigger config
- `nethermind/src/Nethermind/Nethermind.Db/FullPruningCompletionBehavior.cs` — completion policy

**Other DB helpers**
- `nethermind/src/Nethermind/Nethermind.Db/NullDb.cs` — null object DB
- `nethermind/src/Nethermind/Nethermind.Db/NullRocksDbFactory.cs` — null RocksDB factory
- `nethermind/src/Nethermind/Nethermind.Db/CompressingDb.cs` — compression wrapper
- `nethermind/src/Nethermind/Nethermind.Db/BlobTxsColumns.cs` — blob tx column defs
- `nethermind/src/Nethermind/Nethermind.Db/ReceiptsColumns.cs` — receipt column defs
- `nethermind/src/Nethermind/Nethermind.Db/SimpleFilePublicKeyDb.cs` — key store helper

## Voltaire APIs (from `/Users/williamcory/voltaire/packages/voltaire-zig/src/`)
Top-level modules available to the client:
- `blockchain/`
- `crypto/`
- `evm/`
- `jsonrpc/`
- `log.zig`
- `precompiles/`
- `primitives/`
- `state-manager/`
- `c_api.zig`
- `root.zig`

Relevant primitives for DB-facing types (from `primitives/root.zig`):
- `primitives.Bytes`
- `primitives.Hash`
- `primitives.Address`
- `primitives.BlockHash`, `primitives.StateRoot`, `primitives.TransactionHash`
- `primitives.Rlp`, `primitives.Hex`
- `primitives.Uint` / fixed-width wrappers (use Voltaire primitives, not custom types)

## Existing Zig Reference (from `src/host.zig`)
The DB interface should mirror the HostInterface vtable pattern:
- `HostInterface` stores `ptr: *anyopaque` + `vtable: *const VTable`
- Each method forwards to `vtable.fn(ptr, ...)`
- This is the canonical comptime DI/vtable pattern used by guillotine-mini

## Ethereum Test Fixtures (from `ethereum-tests/`)
Phase 0 does not consume external fixtures, but these are available for later phases:
- `ethereum-tests/TrieTests/`
- `ethereum-tests/BlockchainTests/`
- `ethereum-tests/TransactionTests/`
- `ethereum-tests/BasicTests/`
- `ethereum-tests/GenesisTests/`
- `ethereum-tests/RLPTests/`
- `ethereum-tests/EOFTests/`
- `ethereum-tests/LegacyTests/`
- `ethereum-tests/fixtures_blockchain_tests.tgz`
- `ethereum-tests/fixtures_general_state_tests.tgz`

