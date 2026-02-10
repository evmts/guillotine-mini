# [Pass 2/5] Phase 0: DB Abstraction Layer — Context

## Phase Goal (from plan)

Create a database abstraction layer for persistent storage with interchangeable backends (in-memory for tests, RocksDB for production). This phase is an internal abstraction layer with no external spec requirements.

**Key components (planned paths):**
- `client/db/adapter.zig` — generic DB interface (ptr + vtable)
- `client/db/rocksdb.zig` — RocksDB backend (stub initially)
- `client/db/memory.zig` — in-memory backend for testing

## Specs & References (from prd/ETHEREUM_SPECS_REFERENCE.md)

- **Specs:** N/A for phase-0-db (internal abstraction)
- **Reference implementation:** `nethermind/src/Nethermind/Nethermind.Db/`
- **Tests:** Unit tests only (no ethereum-tests fixtures required for this phase)

## Nethermind DB module (nethermind/src/Nethermind/Nethermind.Db/)

Key files and likely roles (from directory listing):

- `IDb.cs` — primary DB interface surface
- `IReadOnlyDb.cs` — read-only DB wrapper interface
- `IDbFactory.cs` — DB instance factory
- `IDbProvider.cs`, `IReadOnlyDbProvider.cs` — named DB registry/provider
- `IFullDb.cs` — DB with enumeration/count access
- `IColumnsDb.cs` — column-family DB interface
- `ITunableDb.cs` — tuning hooks for backends
- `IMergeOperator.cs` — merge operator abstraction
- `DbNames.cs` — standard DB name constants
- `DbProvider.cs`, `DbProviderExtensions.cs` — provider implementation and helpers
- `DbExtensions.cs` — extension helpers
- `MemDb.cs`, `MemColumnsDb.cs` — in-memory DB implementations
- `MemDbFactory.cs` — in-memory DB factory
- `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `ReadOnlyDbProvider.cs` — read-only wrappers
- `NullDb.cs`, `NullRocksDbFactory.cs` — null-object DBs/factories
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs` — RocksDB settings/merge helpers
- `Metrics.cs` — DB metrics surface
- `MetadataDbKeys.cs`, `ReceiptsColumns.cs`, `BlobTxsColumns.cs` — key/column definitions
- `PruningConfig.cs`, `PruningMode.cs`, `FullPruning*` — pruning configuration and flows
- `SimpleFilePublicKeyDb.cs`, `InMemoryWriteBatch.cs`, `InMemoryColumnBatch.cs`, `CompressingDb.cs` — ancillary DB helpers

## Voltaire Zig primitives (voltaire/packages/voltaire-zig/src/)

Top-level modules (directory listing):
- `blockchain/`, `crypto/`, `evm/`, `jsonrpc/`, `precompiles/`, `primitives/`, `state-manager/`

Likely DB-facing primitives to reuse (no custom types):
- `primitives/Bytes`, `primitives/Bytes32` — key/value payloads
- `primitives/Hash`, `primitives/BlockHash`, `primitives/TransactionHash` — canonical key types
- `primitives/Address`, `primitives/Slot`, `primitives/StorageValue` — state DB keys/values
- `primitives/StateRoot`, `primitives/AccountState` — state indexing
- `primitives/Rlp`, `primitives/Hex` — encoding/decoding utilities

## Host interface (src/host.zig)

- `HostInterface` is a ptr + vtable pattern for external state access.
- vtable functions: `getBalance`, `setBalance`, `getCode`, `setCode`, `getStorage`, `setStorage`, `getNonce`, `setNonce`.
- Uses `primitives.Address` and `u256` for balances/storage.
- Note: EVM `inner_call` does not go through this host; it handles nested calls internally.

## ethereum-tests inventory (ethereum-tests/)

Directories:
- `ABITests/`, `BasicTests/`, `BlockchainTests/`, `DifficultyTests/`, `EOFTests/`,
  `GenesisTests/`, `JSONSchema/`, `KeyStoreTests/`, `LegacyTests/`, `PoWTests/`,
  `RLPTests/`, `TransactionTests/`, `TrieTests/`

Fixture archives:
- `ethereum-tests/fixtures_blockchain_tests.tgz`
- `ethereum-tests/fixtures_general_state_tests.tgz`

Phase-0-db tests remain local unit tests (no fixture dependency yet).
