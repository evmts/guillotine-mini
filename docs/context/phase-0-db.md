# Phase 0: DB Abstraction Layer — Context (Pass 1/5, updated)

## Goal

Create a database abstraction layer for persistent key-value storage that will underpin the trie, state, blockchain, and all other storage needs of the Guillotine execution client.

**Deliverables:**
- `client/db/adapter.zig` — Generic database interface (vtable-based, comptime DI) **[DONE]**
- `client/db/memory.zig` — In-memory backend for testing **[DONE]**
- `client/db/null.zig` — Null object backend **[DONE]**
- `client/db/rocksdb.zig` — RocksDB backend stub (all ops error) **[DONE]**
- `client/db/bench.zig` — Benchmarks **[DONE]**
- `client/db/root.zig` — Module root with re-exports **[DONE]**

**Specs**: N/A (internal abstraction — no Ethereum spec governs DB layout)
**Tests**: Unit tests only (inline `test` blocks) — 41 tests total

---

## Current State

All core Phase 0 files are **implemented and tested**:

| File | Status | Contents |
|------|--------|----------|
| `client/db/adapter.zig` | **DONE** | `Database` vtable (get/put/delete/contains/writeBatch), `WriteBatch` with arena + atomic/sequential commit, `WriteBatchOp` tagged union, `DbName` enum (15 variants), `Error` type. 14 tests. |
| `client/db/memory.zig` | **DONE** | `MemoryDatabase` (HashMap + arena, read/write counters, vtable impl). 14 tests. |
| `client/db/null.zig` | **DONE** | `NullDb` (null object: reads→null, writes→StorageError). 6 tests. |
| `client/db/rocksdb.zig` | **DONE** | `RocksDatabase` stub (name-based, all ops→StorageError). 7 tests. |
| `client/db/bench.zig` | **DONE** | Sequential writes, random reads, mixed workloads, WriteBatch, vtable overhead benchmarks. |
| `client/db/root.zig` | **DONE** | Module root, re-exports all public types, `refAllDecls` test. |

**Not yet implemented (future work):**
1. RocksDB FFI (C API bindings) — `rocksdb.zig` is a stub
2. Column family support (`IColumnsDb<T>` equivalent)
3. `ReadFlags`/`WriteFlags` hint enums (for RocksDB tuning)
4. `DbMetric` for monitoring (size, cache, reads, writes)
5. Iterator/range scan support
6. `DbProvider` (registry of named databases)
7. `ReadOnlyDb` wrapper (decorator pattern)
8. Integration with `build.zig` (no `client/db` build targets yet)

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
| `nethermind/src/Nethermind/Nethermind.Db/InMemoryWriteBatch.cs` | Single-column batch: accumulates in ConcurrentDictionary, flushes to underlying store on Dispose() |
| `nethermind/src/Nethermind/Nethermind.Db/InMemoryColumnBatch.cs` | Multi-column batch: manages InMemoryWriteBatch per column, disposes all on Dispose() |
| `nethermind/src/Nethermind/Nethermind.Db.Rocks/DbOnTheRocks.cs` | 74KB main RocksDB wrapper: `IDb, ITunableDb, IReadOnlyNativeKeyValueStore, ISortedKeyValueStore, IMergeableKeyValueStore, IKeyValueStoreWithSnapshot`. Uses `ConcurrentDictionary<string, RocksDb>` for path-based caching. Manages WriteOptions (normal, noWal, lowPriority), ReadOptions (default, hintCacheMiss, readAhead), DbOptions, row cache, iterator management, and file warming. |
| `nethermind/src/Nethermind/Nethermind.Db.Rocks/RocksDbFactory.cs` | Creates `DbOnTheRocks` with shared `HyperClockCacheWrapper`, `IDbConfig`, `IRocksDbConfigFactory`, `ILogManager` |
| `nethermind/src/Nethermind/Nethermind.Db.Rocks/ColumnsDb.cs` | Multi-column-family wrapper: enum-keyed columns, per-column compaction/metrics |
| `nethermind/src/Nethermind/Nethermind.Db.Rocks/ColumnDb.cs` | Single column wrapper delegating I/O to parent `DbOnTheRocks` |

### Core API Surface (from Nethermind)

| Operation | Method | Return | Notes |
|-----------|--------|--------|-------|
| Single Get | `Get(key)` | `byte[]?` | null if missing |
| Single Set | `Set(key, value)` | `void` | null value = delete |
| Multi Get | `this[byte[][] keys]` | `KeyValuePair[]` | Batch read |
| Key Exists | `KeyExists(key)` | `bool` | |
| Remove | `Remove(key)` | `void` | Same as Set(key, null) |
| Batch Write | `StartWriteBatch()` | `IWriteBatch` | Atomic multi-write |
| Enumerate | `GetAll()` | `IEnumerable<>` | Optional ordering |
| Metadata | `GatherMetric()` | `DbMetric` | Size, cache stats |
| Maintenance | `Flush()`, `Clear()`, `Compact()` | `void` | Housekeeping |

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
| `StorageKey` | Composite key `{ address: [20]u8, slot: u256 }` |

### AccountState Structure (from Voltaire)

```zig
pub const AccountState = struct {
    nonce: u64,
    balance: u256,
    storage_root: Hash,
    code_hash: Hash,
};
// Methods: isEOA(), isContract(), rlpEncode(), rlpDecode()
// Constants: EMPTY_CODE_HASH, EMPTY_TRIE_ROOT
```

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
| `client/db/adapter.zig` | **DONE**: Database vtable, DbName enum, Error type, MockDb, tests |
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
- `ethereum-tests/TrieTests/trietest.json` — Phase 1
- `ethereum-tests/TrieTests/trieanyorder.json` — Phase 1
- `ethereum-tests/TrieTests/hex_encoded_securetrie_test.json` — Phase 1
- `ethereum-tests/TrieTests/trietest_secureTrie.json` — Phase 1
- `ethereum-tests/TrieTests/trieanyorder_secureTrie.json` — Phase 1
- `ethereum-tests/TrieTests/trietestnextprev.json` — Phase 1
- `ethereum-tests/GeneralStateTests/` — Phase 3+
- `ethereum-tests/BlockchainTests/ValidBlocks/` — Phase 4+
- `ethereum-tests/BlockchainTests/InvalidBlocks/` — Phase 4+

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

## Implementation Order (remaining — future work only)

1. **RocksDB FFI** — Replace stub with C API bindings in `rocksdb.zig`
2. **Column families** — Add `IColumnsDb<T>` equivalent for RocksDB column families
3. **`DbProvider`** — Registry of named databases (mirrors Nethermind's `IDbProvider`)
4. **`ReadOnlyDb`** — Decorator wrapping base DB + optional MemDb write overlay
5. **`ReadFlags`/`WriteFlags`** — Hint enums for RocksDB tuning
6. **`DbMetric`** — Monitoring struct (size, cache stats, read/write counts)
7. **Iterator support** — Range scans for state enumeration
8. **`build.zig` integration** — Build targets for client/db module and bench

---

## File Paths Summary

### Nethermind Reference Files
- `nethermind/src/Nethermind/Nethermind.Core/IKeyValueStore.cs`
- `nethermind/src/Nethermind/Nethermind.Core/IKeyValueStoreWithBatching.cs`
- `nethermind/src/Nethermind/Nethermind.Core/IWriteBatch.cs`
- `nethermind/src/Nethermind/Nethermind.Core/FakeWriteBatch.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IFullDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/MemDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/NullDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/DbNames.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IDbFactory.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IDbProvider.cs`
- `nethermind/src/Nethermind/Nethermind.Db/DbProvider.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IColumnsDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IReadOnlyDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/ITunableDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/RocksDbSettings.cs`
- `nethermind/src/Nethermind/Nethermind.Db/MetadataDbKeys.cs`
- `nethermind/src/Nethermind/Nethermind.Db/DbExtensions.cs`
- `nethermind/src/Nethermind/Nethermind.Db/CompressingDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/MemDbFactory.cs`
- `nethermind/src/Nethermind/Nethermind.Db/InMemoryWriteBatch.cs`
- `nethermind/src/Nethermind/Nethermind.Db/InMemoryColumnBatch.cs`
- `nethermind/src/Nethermind/Nethermind.Db.Rocks/DbOnTheRocks.cs`
- `nethermind/src/Nethermind/Nethermind.Db.Rocks/RocksDbFactory.cs`
- `nethermind/src/Nethermind/Nethermind.Db.Rocks/ColumnsDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db.Rocks/ColumnDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db.Rocks/RocksDbReader.cs`
- `nethermind/src/Nethermind/Nethermind.Db.Rocks/RocksdbSortedView.cs`

### Voltaire Modules
- `voltaire/packages/voltaire-zig/src/primitives/` — Address, Hash, u256, RLP, AccountState, Block, Tx, Storage, State, Trie
- `voltaire/packages/voltaire-zig/src/state-manager/StateCache.zig` — Checkpoint/revert pattern model
- `voltaire/packages/voltaire-zig/src/state-manager/JournaledState.zig` — Dual-cache orchestrator model
- `voltaire/packages/voltaire-zig/src/state-manager/ForkBackend.zig` — vtable pattern model (RpcClient)
- `voltaire/packages/voltaire-zig/src/state-manager/StateManager.zig` — Public API combining all above
- `voltaire/packages/voltaire-zig/src/blockchain/BlockStore.zig` — In-memory block storage model
- `voltaire/packages/voltaire-zig/src/blockchain/Blockchain.zig` — Block chain orchestrator

### Existing Zig Files (Phase 0 — all DONE)
- `client/db/adapter.zig` — Database vtable, WriteBatch, WriteBatchOp, DbName, Error. 14 tests.
- `client/db/memory.zig` — MemoryDatabase (HashMap + arena, read/write counters). 14 tests.
- `client/db/null.zig` — NullDb (null object pattern). 6 tests.
- `client/db/rocksdb.zig` — RocksDatabase stub (name-based). 7 tests.
- `client/db/bench.zig` — Benchmarks for all backends.
- `client/db/root.zig` — Module root with re-exports.

### Reference Zig Files
- `src/host.zig` — vtable pattern reference (ptr + vtable DI)
- `src/evm.zig` — consumer of vtable-based DI
- `build.zig` — build system (needs client/ module integration)

### Test Fixtures (downstream phases)
- `ethereum-tests/TrieTests/` — Phase 1
- `ethereum-tests/GeneralStateTests/` — Phase 3
- `ethereum-tests/BlockchainTests/` — Phase 4

### Implemented MemDb Test Patterns (all passing in memory.zig)

- Basic `put(key, value)` then `get(key)` round-trip
- `get()` missing key returns `null`
- `delete()` existing key, then `get()` returns `null`
- `delete()` non-existing key is a no-op
- `contains(key)` returns true/false correctly
- `put(key, null)` behaves as delete (Nethermind pattern)
- Read/write count tracking (reads_count, writes_count)
- Overwrite existing key
- Empty keys and values
- Binary (non-UTF8) keys and values
- Many entries (100+)
- Vtable interface dispatch
- `deinit()` frees all memory cleanly (no leaks under test allocator)

### Implemented WriteBatch Test Patterns (all passing in adapter.zig)

- Commit applies put operations
- Commit applies delete operations
- Mixed operations in order
- Clear discards pending operations
- Empty batch commit is no-op
- Deinit frees all memory (leak check)
- Sequential fallback retains ops on error for retry
- Atomic writeBatch vtable for all-or-nothing semantics
- Atomic commit retains ops on failure (no partial apply)
- Clear resets arena memory (reusable after clear)
- Put/delete propagate OutOfMemory (not StorageError)
