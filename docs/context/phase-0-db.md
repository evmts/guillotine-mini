# Phase 0: DB Abstraction Layer — Context (Pass 1/5)

## Goal

Create a database abstraction layer for persistent key-value storage that will underpin the trie, state, blockchain, and all other storage needs of the Guillotine execution client.

**Deliverables:**
- `client/db/adapter.zig` — Generic database interface (vtable-based, comptime DI) **[DONE]**
- `client/db/memory.zig` — In-memory backend for testing
- `client/db/rocksdb.zig` — RocksDB backend (future; interface only for now)

**Specs**: N/A (internal abstraction — no Ethereum spec governs DB layout)
**Tests**: Unit tests only (inline `test` blocks)

---

## Current State

- `client/db/adapter.zig` already exists with:
  - `Database` vtable struct (ptr + vtable pattern from `src/host.zig`)
  - `VTable` with `get`, `put`, `delete`, `contains` operations
  - `Error` enum: `StorageError`, `KeyTooLarge`, `ValueTooLarge`, `DatabaseClosed`
  - `DbName` enum with 12 variants matching Nethermind's `DbNames`
  - `MockDb` for testing vtable dispatch
  - All inline tests passing

**Remaining work:**
1. `client/db/memory.zig` — Full in-memory `MemoryDatabase` implementing `Database` interface
2. `client/db/rocksdb.zig` — RocksDB stub (interface only, no FFI)
3. `WriteBatch` interface for atomic multi-key writes
4. Build integration into `build.zig`

---

## Nethermind Architecture Reference

### Interface Hierarchy (Nethermind.Core + Nethermind.Db)

```
IReadOnlyKeyValueStore          <- Get, GetSpan, KeyExists
IWriteOnlyKeyValueStore         <- Set, Remove, PutSpan
    +-- IKeyValueStore          <- Combines read + write
        +-- IKeyValueStoreWithBatching  <- StartWriteBatch()
            +-- IDb             <- Name, multi-get, GetAll, CreateReadOnly
                +-- IFullDb     <- Keys, Values, Count (for in-memory)
```

### Key Files

| File | Purpose |
|------|---------|
| `nethermind/src/Nethermind/Nethermind.Core/IKeyValueStore.cs` | Core read/write interface: `Get(key, ReadFlags)`, `Set(key, value, WriteFlags)`, `KeyExists`, `Remove`. Also defines `ReadFlags` and `WriteFlags` enums, `IKeyValueStoreWithSnapshot`, `ISortedKeyValueStore`, `IMergeableKeyValueStore` |
| `nethermind/src/Nethermind/Nethermind.Core/IKeyValueStoreWithBatching.cs` | Adds `StartWriteBatch() -> IWriteBatch` for atomic writes |
| `nethermind/src/Nethermind/Nethermind.Core/IWriteBatch.cs` | Batch context: `IDisposable + IWriteOnlyKeyValueStore + Clear()` |
| `nethermind/src/Nethermind/Nethermind.Db/IDb.cs` | Main DB interface: `Name`, multi-get `this[byte[][] keys]`, `GetAll(ordered)`, `CreateReadOnly` |
| `nethermind/src/Nethermind/Nethermind.Db/IDbMeta.cs` | Metrics in IDb.cs: `GatherMetric() -> DbMetric { Size, CacheSize, TotalReads, TotalWrites }`, `Flush`, `Clear`, `Compact` |
| `nethermind/src/Nethermind/Nethermind.Db/IDbFactory.cs` | Factory: `CreateDb(DbSettings)`, `CreateColumnsDb<T>(DbSettings)` |
| `nethermind/src/Nethermind/Nethermind.Db/IDbProvider.cs` | Registry: named DB access (`StateDb`, `CodeDb`, `BlocksDb`, `HeadersDb`, etc.) |
| `nethermind/src/Nethermind/Nethermind.Db/MemDb.cs` | In-memory impl using `ConcurrentDictionary<byte[], byte[]?>` with `Bytes.EqualityComparer`. Tracks `ReadsCount`/`WritesCount`. `Set(key, null)` calls `Remove(key)`. |
| `nethermind/src/Nethermind/Nethermind.Db/NullDb.cs` | Null object pattern (reads return null, writes throw) |
| `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDb.cs` | Decorator: base DB + optional MemDb write overlay. Reads cascade: memdb first, then wrapped. |
| `nethermind/src/Nethermind/Nethermind.Db/DbNames.cs` | Constants: `State`, `Code`, `Blocks`, `Headers`, `BlockNumbers`, `Receipts`, `BlockInfos`, `BadBlocks`, `Bloom`, `Metadata`, `BlobTransactions` |
| `nethermind/src/Nethermind/Nethermind.Db/IColumnsDb.cs` | Multi-column DB: enum-keyed column families (`ReceiptsColumns`, `BlobTxsColumns`). `GetColumnDb(TKey)`, `StartWriteBatch()`, `CreateSnapshot()` |
| `nethermind/src/Nethermind/Nethermind.Db/ITunableDb.cs` | Performance hints: `Tune(TuneType)` for `WriteBias`, `HeavyWrite`, `DisableCompaction`, etc. |
| `nethermind/src/Nethermind/Nethermind.Db/IFullDb.cs` | Extended in-memory: `Keys`, `Values`, `Count` |
| `nethermind/src/Nethermind/Nethermind.Db/IReadOnlyDb.cs` | Read-only view with `ClearTempChanges()` |
| `nethermind/src/Nethermind/Nethermind.Db/DbExtensions.cs` | Helpers: `AsReadOnly()`, `MultiGet()` |
| `nethermind/src/Nethermind/Nethermind.Db/DbProvider.cs` | IoC-based provider via Autofac: resolves `IDb` by name string |
| `nethermind/src/Nethermind/Nethermind.Db/MemDbFactory.cs` | Factory that creates `MemDb` instances |
| `nethermind/src/Nethermind/Nethermind.Db/RocksDbSettings.cs` | Settings: `DbName`, `DbPath`, `DeleteOnStart`, `CanDeleteFolder`, `MergeOperator` |
| `nethermind/src/Nethermind/Nethermind.Db/CompressingDb.cs` | EOA compression decorator: strips/adds empty code hash + storage root suffix |
| `nethermind/src/Nethermind/Nethermind.Db/MetadataDbKeys.cs` | Constants for metadata DB: `TerminalPoWHash`, `FinalizedBlockHash`, `SafeBlockHash`, etc. |
| `nethermind/src/Nethermind/Nethermind.Db.Rocks/DbOnTheRocks.cs` | RocksDB concrete impl: uses `RocksDbSharp` library, implements `IDb, ITunableDb, IReadOnlyNativeKeyValueStore, ISortedKeyValueStore, IMergeableKeyValueStore, IKeyValueStoreWithSnapshot` |
| `nethermind/src/Nethermind/Nethermind.Db.Rocks/RocksDbFactory.cs` | Factory: `CreateDb(DbSettings)` creates `DbOnTheRocks` with shared cache, config, logging |

### Key Design Patterns

1. **Span-based API** — `Get(ReadOnlySpan<byte>)` / `Set(ReadOnlySpan<byte>, byte[]?)` for zero-alloc reads
2. **Null = delete** — `Set(key, null)` removes entry (no separate delete in write path)
3. **Batch = transaction** — `StartWriteBatch() -> IWriteBatch`; dispose to commit, `Clear()` to abort
4. **ReadFlags / WriteFlags** — Optimization hints (`HintCacheMiss`, `LowPriority`, `DisableWAL`)
5. **Column families** — Enum-keyed columns for typed sub-databases
6. **Decorator pattern** — `ReadOnlyDb` wraps base + optional MemDb overlay
7. **Null object** — `NullDb` for safe defaults
8. **Factory + Provider** — `IDbFactory` creates, `IDbProvider` resolves by name

---

## Voltaire APIs Available

### Relevant Primitives (from `voltaire/packages/voltaire-zig/src/primitives/`)

| Type | Usage for DB |
|------|-------------|
| `Address` | 20-byte key for account lookups |
| `Hash` / `Bytes32` | 32-byte key for trie nodes, block hashes, tx hashes |
| `Uint` (u256) | Storage slot keys/values |
| `Rlp` | Encoding values for DB storage |
| `AccountState` | `{ nonce, balance, code_hash, storage_root }` |
| `Block`, `BlockHeader`, `BlockBody` | Block storage values |
| `Transaction`, `Receipt` | Transaction/receipt storage |
| `trie.zig` | Merkle Patricia Trie (Phase 1, DB must support its storage patterns) |
| `Storage`, `StorageValue`, `StorageDiff` | Storage types |
| `State`, `StateDiff`, `StateRoot` | State types |

### Relevant State Manager (from `voltaire/packages/voltaire-zig/src/state-manager/`)

| Module | Relevance |
|--------|-----------|
| `StateCache.zig` | In-memory cache with checkpoint/revert/commit. Model for MemDb journaling. Uses `AccountCache`, `StorageCache`, `ContractCache` types with `AccountState`, `StorageKey`. |
| `JournaledState.zig` | Dual-cache orchestrator (normal cache + fork backend). Read cascade: normal -> fork -> default. All writes to normal cache. Phase 2 consumer. |
| `ForkBackend.zig` | Async RPC bridge with vtable pattern (`RpcClient`). Architectural model for DB vtable. `CacheConfig`, `Transport` types. |
| `StateManager.zig` | Public API: `getBalance/setBalance`, `getStorage/setStorage`, `checkpoint/revert/commit`, `snapshot/revertToSnapshot`. Phase 2+ consumer. |

### Relevant Blockchain (from `voltaire/packages/voltaire-zig/src/blockchain/`)

| Module | Relevance |
|--------|-----------|
| `BlockStore.zig` | In-memory block storage with canonical chain tracking |
| `Blockchain.zig` | Orchestrator with local + fork cache |
| `ForkBlockCache.zig` | Block caching for fork scenarios |

### Key Insight

Voltaire does **NOT** provide a generic persistent DB abstraction. All storage is in-memory (HashMap-based). The DB abstraction layer is the missing piece that connects Voltaire's in-memory types to persistent storage.

---

## Existing Zig Files

| File | Relevance |
|------|-----------|
| `src/host.zig` | Existing vtable pattern for EVM <-> state communication. DB adapter follows this same `ptr + vtable` pattern. |
| `src/evm.zig` | Consumer of HostInterface — shows how vtable-based DI works |
| `client/db/adapter.zig` | **Already implemented**: `Database` vtable, `DbName` enum, `Error` type, `MockDb`, tests |
| `build.zig` | Build system — new `client/` module will need build integration |

### HostInterface Pattern (already followed in adapter.zig)

```zig
pub const HostInterface = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        getBalance: *const fn (ptr: *anyopaque, address: Address) u256,
        setBalance: *const fn (ptr: *anyopaque, address: Address, balance: u256) void,
        // ...
    };

    pub fn getBalance(self: HostInterface, address: Address) u256 {
        return self.vtable.getBalance(self.ptr, address);
    }
    // ...
};
```

---

## Test Fixtures

No external test fixtures for this phase. Phase 0 is an internal abstraction tested with inline unit tests.

**Downstream test fixtures** (consumers of DB layer in later phases):
- `ethereum-tests/TrieTests/trietest.json` — Phase 1 (trie needs DB backend)
- `ethereum-tests/TrieTests/trieanyorder.json` — Phase 1
- `ethereum-tests/TrieTests/hex_encoded_securetrie_test.json` — Phase 1
- `ethereum-tests/GeneralStateTests/` — Phase 3+
- `ethereum-tests/BlockchainTests/` — Phase 4+

---

## Design Decisions for Zig Implementation

### 1. Interface Shape (DONE in adapter.zig)

Following the `ptr + vtable` pattern from `host.zig`:

```zig
pub const Database = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        get: *const fn (ptr: *anyopaque, key: []const u8) Error!?[]const u8,
        put: *const fn (ptr: *anyopaque, key: []const u8, value: ?[]const u8) Error!void,
        delete: *const fn (ptr: *anyopaque, key: []const u8) Error!void,
        contains: *const fn (ptr: *anyopaque, key: []const u8) Error!bool,
    };
};
```

### 2. Simplifications vs Nethermind

| Nethermind | Zig Equivalent | Notes |
|-----------|----------------|-------|
| `ReadFlags` / `WriteFlags` | Omit for now | Add when RocksDB backend needs them |
| `IColumnsDb<T>` | Separate `Database` instances per column | Simpler; column families are a RocksDB optimization |
| `IDbProvider` | `DbProvider` struct with named fields | No IoC container in Zig |
| `IWriteBatch` | `WriteBatch` struct with arraylist of ops | Explicit commit/abort |
| `IDbMeta` | Omit for now | Add metrics when needed |
| `ITunableDb` | Omit for now | RocksDB-specific |
| `ReadOnlyDb` | `ReadOnlyDatabase` wrapper | Decorator pattern works in Zig |
| `ConcurrentDictionary` | `std.HashMap` | No concurrency needed initially (single-threaded Zig) |

### 3. Allocation Strategy

- **MemDb**: Arena allocator for all stored keys/values (freed at DB destruction)
- **RocksDB**: Backend manages its own memory; Zig copies into arena on read
- **WriteBatch**: Arena allocator for pending operations, freed on commit/abort

### 4. Error Handling

All DB operations return error unions (`Error!?[]const u8` for get, `Error!void` for put/delete). Never use `catch {}`.

---

## Implementation Order (remaining)

1. **`client/db/memory.zig`** — `MemoryDatabase` implementing `Database` (HashMap-backed, tracks reads/writes)
2. **`WriteBatch` in adapter.zig** — Batch interface for atomic multi-key writes
3. **`client/db/rocksdb.zig`** — `RocksDatabase` stub (interface only, no FFI yet)
4. **Integration**: Wire into `build.zig` as a new module

---

## File Paths Summary

### Nethermind Reference Files
- `nethermind/src/Nethermind/Nethermind.Core/IKeyValueStore.cs`
- `nethermind/src/Nethermind/Nethermind.Core/IKeyValueStoreWithBatching.cs`
- `nethermind/src/Nethermind/Nethermind.Core/IWriteBatch.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/MemDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/NullDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/DbNames.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IDbFactory.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IDbProvider.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IColumnsDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IFullDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IReadOnlyDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/ITunableDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/DbExtensions.cs`
- `nethermind/src/Nethermind/Nethermind.Db/CompressingDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/MemDbFactory.cs`
- `nethermind/src/Nethermind/Nethermind.Db/RocksDbSettings.cs`
- `nethermind/src/Nethermind/Nethermind.Db/MetadataDbKeys.cs`
- `nethermind/src/Nethermind/Nethermind.Db.Rocks/DbOnTheRocks.cs`
- `nethermind/src/Nethermind/Nethermind.Db.Rocks/RocksDbFactory.cs`

### Voltaire Modules
- `voltaire/packages/voltaire-zig/src/primitives/` — Address, Hash, u256, RLP, AccountState, Block, Tx, Storage, State, Trie
- `voltaire/packages/voltaire-zig/src/state-manager/StateCache.zig` — Checkpoint/revert pattern model
- `voltaire/packages/voltaire-zig/src/state-manager/JournaledState.zig` — Dual-cache orchestrator model
- `voltaire/packages/voltaire-zig/src/state-manager/ForkBackend.zig` — vtable pattern model (RpcClient)
- `voltaire/packages/voltaire-zig/src/state-manager/StateManager.zig` — Public API combining all above
- `voltaire/packages/voltaire-zig/src/blockchain/BlockStore.zig` — In-memory block storage model
- `voltaire/packages/voltaire-zig/src/blockchain/Blockchain.zig` — Block chain orchestrator

### Existing Zig Files
- `src/host.zig` — vtable pattern to follow
- `src/evm.zig` — consumer of vtable-based DI
- `client/db/adapter.zig` — **DONE**: Database vtable, DbName enum, Error, MockDb, tests
- `build.zig` — build system (needs new client/ module)

### Test Fixtures (downstream phases)
- `ethereum-tests/TrieTests/trietest.json` — Phase 1
- `ethereum-tests/TrieTests/trieanyorder.json` — Phase 1
- `ethereum-tests/TrieTests/hex_encoded_securetrie_test.json` — Phase 1
- `ethereum-tests/GeneralStateTests/` — Phase 3
- `ethereum-tests/BlockchainTests/ValidBlocks/` — Phase 4
- `ethereum-tests/BlockchainTests/InvalidBlocks/` — Phase 4

### MemDb Unit Test Patterns (from Nethermind MemDb.cs)

The following test patterns should be implemented for the in-memory backend:
- Basic `put(key, value)` then `get(key)` round-trip
- `get()` missing key returns `null`
- `delete()` existing key, then `get()` returns `null`
- `delete()` non-existing key is a no-op
- `contains(key)` returns true/false correctly
- `put(key, null_or_empty)` behaves as delete (Nethermind pattern: `Set(key, null)` calls `Remove`)
- Read/write count tracking
- `getAll()` returns all stored pairs
- Batch operations: accumulate, commit atomically
- `deinit()` frees all memory cleanly (no leaks under test allocator)
