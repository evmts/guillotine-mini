# [Pass 1/5] Phase 0: DB Abstraction Layer — Context

## Phase Goal (from `prd/GUILLOTINE_CLIENT_PLAN.md`)

Create a database abstraction layer for persistent storage.

**Key Components (planned):**

- `client/db/adapter.zig` — generic DB interface
- `client/db/rocksdb.zig` — RocksDB backend implementation
- `client/db/memory.zig` — in-memory backend for testing

## Specs (from `prd/ETHEREUM_SPECS_REFERENCE.md`)

- Phase 0 has **no external protocol specs**.
- Tests: **unit tests only** (no fixtures required for this phase).

## Nethermind DB Reference (from `nethermind/src/Nethermind/Nethermind.Db/`)

Directory listing (key files to mirror architecturally):

**Core interfaces**

- `nethermind/src/Nethermind/Nethermind.Db/IDb.cs` — main DB interface (K/V + batching + metadata)
- `nethermind/src/Nethermind/Nethermind.Db/IReadOnlyDb.cs` — read-only interface
- `nethermind/src/Nethermind/Nethermind.Db/IColumnsDb.cs` — column-family DB abstraction
- `nethermind/src/Nethermind/Nethermind.Db/IDbFactory.cs` — DB factory
- `nethermind/src/Nethermind/Nethermind.Db/IDbProvider.cs` — named DB provider
- `nethermind/src/Nethermind/Nethermind.Db/IReadOnlyDbProvider.cs` — read-only provider
- `nethermind/src/Nethermind/Nethermind.Db/IFullDb.cs` — extended DB interface
- `nethermind/src/Nethermind/Nethermind.Db/IMergeOperator.cs` — merge operator
- `nethermind/src/Nethermind/Nethermind.Db/IPruningConfig.cs` — pruning config interface
- `nethermind/src/Nethermind/Nethermind.Db/ITunableDb.cs` — tunable DB interface

**Implementations / wrappers**

- `nethermind/src/Nethermind/Nethermind.Db/MemDb.cs` — in-memory DB
- `nethermind/src/Nethermind/Nethermind.Db/MemColumnsDb.cs` — in-memory column DB
- `nethermind/src/Nethermind/Nethermind.Db/MemDbFactory.cs` — in-memory DB factory
- `nethermind/src/Nethermind/Nethermind.Db/InMemoryWriteBatch.cs` — write batch impl
- `nethermind/src/Nethermind/Nethermind.Db/InMemoryColumnBatch.cs` — column batch impl
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDb.cs` — read-only wrapper
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyColumnsDb.cs` — read-only column wrapper
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDbProvider.cs` — read-only provider
- `nethermind/src/Nethermind/Nethermind.Db/DbProvider.cs` — provider implementation
- `nethermind/src/Nethermind/Nethermind.Db/DbProviderExtensions.cs` — provider helpers
- `nethermind/src/Nethermind/Nethermind.Db/DbExtensions.cs` — DB helpers
- `nethermind/src/Nethermind/Nethermind.Db/NullDb.cs` — null object DB
- `nethermind/src/Nethermind/Nethermind.Db/NullRocksDbFactory.cs` — null RocksDB factory
- `nethermind/src/Nethermind/Nethermind.Db/CompressingDb.cs` — compression wrapper
- `nethermind/src/Nethermind/Nethermind.Db/RocksDbMergeEnumerator.cs` — merge enumerator
- `nethermind/src/Nethermind/Nethermind.Db/RocksDbSettings.cs` — RocksDB settings

**Configuration / constants / metrics**

- `nethermind/src/Nethermind/Nethermind.Db/DbNames.cs` — canonical DB name constants
- `nethermind/src/Nethermind/Nethermind.Db/MetadataDbKeys.cs` — metadata key constants
- `nethermind/src/Nethermind/Nethermind.Db/Metrics.cs` — DB metrics
- `nethermind/src/Nethermind/Nethermind.Db/ReceiptsColumns.cs` — receipt column defs
- `nethermind/src/Nethermind/Nethermind.Db/BlobTxsColumns.cs` — blob tx column defs
- `nethermind/src/Nethermind/Nethermind.Db/SimpleFilePublicKeyDb.cs` — key store helper

**Pruning / maintenance**

- `nethermind/src/Nethermind/Nethermind.Db/FullPruning/` — pruning implementation
- `nethermind/src/Nethermind/Nethermind.Db/FullPruningTrigger.cs` — trigger config
- `nethermind/src/Nethermind/Nethermind.Db/FullPruningCompletionBehavior.cs` — completion policy
- `nethermind/src/Nethermind/Nethermind.Db/PruningConfig.cs` — pruning config
- `nethermind/src/Nethermind/Nethermind.Db/PruningMode.cs` — pruning modes

## Voltaire Zig APIs (required primitives)

**Requested path**: `/Users/williamcory/voltaire/packages/voltaire-zig/src/` **does not exist** in this workspace.

**Actual dependency root (from `build.zig.zon`)**: `/Users/williamcory/voltaire/src/`

Relevant modules under `/Users/williamcory/voltaire/src/`:

- `primitives/` — core Ethereum types (Address, Hash, Bytes, Bytes32, BlockHash, StateRoot, StorageValue, Nonce, etc.)
- `crypto/` — hashing + crypto helpers
- `state-manager/` — journaled state patterns (useful for later phases)
- `blockchain/` — block storage helpers (later phases)
- `jsonrpc/` — JSON-RPC types (later phases)
- `evm/`, `precompiles/` — EVM-related types

**Phase-0 takeaway**: no DB-specific primitives found; DB keys/values should use Voltaire primitives (e.g., `Hash`, `Bytes32`, `Address`, `StateRoot`) instead of custom types.

## Existing Zig Host Interface (from `src/host.zig`)

- `HostInterface` is a vtable-based adapter for external state access:
  - `getBalance` / `setBalance` (Address → u256)
  - `getCode` / `setCode` (Address → bytecode)
  - `getStorage` / `setStorage` (Address + slot → value)
  - `getNonce` / `setNonce` (Address → u64)
- This minimal interface is used for EVM external state access (not nested calls).

## Ethereum Test Fixtures (from `ethereum-tests/`)

Phase 0 uses unit tests only, but these fixture directories exist for later phases:

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

Phase 0 needs a thin, idiomatic Zig DB abstraction modeled after Nethermind’s `Nethermind.Db` interfaces, using Voltaire primitives for all Ethereum types. There are no external execution specs for DB, and no fixture-driven tests required for this phase.
