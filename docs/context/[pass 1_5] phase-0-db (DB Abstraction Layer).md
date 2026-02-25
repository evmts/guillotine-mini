# [Pass 1/5] Phase 0: DB Abstraction Layer — Implementation Context

## Phase Goal

Create a database abstraction layer for persistent storage that will underpin the entire Guillotine client. This is a pure internal abstraction — no external specs or test fixtures apply. The DB layer provides a generic key-value interface that can be backed by in-memory storage (for testing) or RocksDB (for production).

**Key Components** (from plan):
- `client/db/adapter.zig` - Generic database interface
- `client/db/rocksdb.zig` - RocksDB backend implementation (stub initially)
- `client/db/memory.zig` - In-memory backend for testing

**5 Implementation Passes**:
1. `types.zig` — DbNames, ReadFlags, WriteFlags, DbMetric
2. `adapter.zig` — Db vtable interface
3. `memory.zig` — In-memory HashMap backend
4. `provider.zig` — Named DB registry
5. Integration — build.zig wiring, final tests

---

## 1. Architecture Reference: Nethermind DB Module

### Key Nethermind Files

| File | Purpose |
|------|---------|
| `nethermind/src/Nethermind/Nethermind.Core/IKeyValueStore.cs` | Base interfaces: IReadOnlyKeyValueStore, IWriteOnlyKeyValueStore, IKeyValueStore, ReadFlags, WriteFlags |
| `nethermind/src/Nethermind/Nethermind.Core/IKeyValueStoreWithBatching.cs` | Adds `StartWriteBatch()` |
| `nethermind/src/Nethermind/Nethermind.Core/IWriteBatch.cs` | Write batch: IDisposable + IWriteOnlyKeyValueStore + Clear() |
| `nethermind/src/Nethermind/Nethermind.Db/IDb.cs` | Main DB interface + IDbMeta (Flush, Clear, Compact, GatherMetric) |
| `nethermind/src/Nethermind/Nethermind.Db/IFullDb.cs` | DB with Keys, Values, Count collection access |
| `nethermind/src/Nethermind/Nethermind.Db/IDbProvider.cs` | Named DB registry (StateDb, CodeDb, HeadersDb, etc.) |
| `nethermind/src/Nethermind/Nethermind.Db/IDbFactory.cs` | Factory for creating DB instances |
| `nethermind/src/Nethermind/Nethermind.Db/IReadOnlyDb.cs` | Read-only wrapper interface |
| `nethermind/src/Nethermind/Nethermind.Db/MemDb.cs` | Reference in-memory implementation (ConcurrentDictionary-backed) |
| `nethermind/src/Nethermind/Nethermind.Db/DbNames.cs` | Standard DB name constants |
| `nethermind/src/Nethermind/Nethermind.Db/NullDb.cs` | Null object pattern (no-op DB) |
| `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDb.cs` | Read-only wrapper with MemDb overlay |
| `nethermind/src/Nethermind/Nethermind.Db/RocksDbSettings.cs` | DbSettings struct (DbName, DbPath, DeleteOnStart, etc.) |
| `nethermind/src/Nethermind/Nethermind.Db/IColumnsDb.cs` | Column-family DB interface |
| `nethermind/src/Nethermind/Nethermind.Db/ITunableDb.cs` | Tuning interface (TuneType: WriteBias, HeavyWrite, etc.) |
| `nethermind/src/Nethermind/Nethermind.Db/DbProvider.cs` | DI-based named DB resolver |
| `nethermind/src/Nethermind/Nethermind.Db/MemDbFactory.cs` | Factory that creates MemDb instances |
| `nethermind/src/Nethermind/Nethermind.Db/Metrics.cs` | Prometheus-style DB metrics |
| `nethermind/src/Nethermind/Nethermind.Db.Rocks/DbOnTheRocks.cs` | RocksDB backend impl (1900+ lines) |
| `nethermind/src/Nethermind/Nethermind.Db.Rocks/RocksDbFactory.cs` | RocksDB factory |

### Core Interface Hierarchy

```
IReadOnlyKeyValueStore           (Get, KeyExists, GetSpan)
  └── IWriteOnlyKeyValueStore    (Set, Remove, PutSpan)
      └── IKeyValueStore         (combined read+write)
          └── IKeyValueStoreWithBatching  (StartWriteBatch)
              └── IDb            (Name, GetAll, multi-get, + IDbMeta)

IWriteBatch : IDisposable, IWriteOnlyKeyValueStore  (Clear, on-Dispose writes)
IDbMeta     (GatherMetric, Flush, Clear, Compact)
```

### Key API Summary (from IKeyValueStore.cs)

**IReadOnlyKeyValueStore:**
```csharp
byte[]? Get(ReadOnlySpan<byte> key, ReadFlags flags = ReadFlags.None);
bool KeyExists(ReadOnlySpan<byte> key);
```

**IWriteOnlyKeyValueStore:**
```csharp
void Set(ReadOnlySpan<byte> key, byte[]? value, WriteFlags flags = WriteFlags.None);
void Remove(ReadOnlySpan<byte> key);
```

**IDb (extends IKeyValueStoreWithBatching + IDbMeta):**
```csharp
string Name { get; }
KeyValuePair<byte[], byte[]?>[] this[byte[][] keys] { get; }  // multi-get
IEnumerable<KeyValuePair<byte[], byte[]?>> GetAll(bool ordered = false);
IWriteBatch StartWriteBatch();
```

**IDbMeta:**
```csharp
DbMetric GatherMetric();  // { Size, CacheSize, IndexSize, MemtableSize, TotalReads, TotalWrites }
void Flush(bool onlyWal = false);
void Clear();
void Compact();
```

**ReadFlags** (from IKeyValueStore.cs):
```csharp
[Flags] public enum ReadFlags {
    None = 0,
    HintCacheMiss = 1,
    HintReadAhead = 2,
    HintReadAhead2 = 4,
    HintReadAhead3 = 8,
    SkipDuplicateRead = 16,
}
```

**WriteFlags** (from IKeyValueStore.cs):
```csharp
[Flags] public enum WriteFlags {
    None = 0,
    LowPriority = 1,
    DisableWAL = 2,
    LowPriorityAndNoWAL = LowPriority | DisableWAL,
}
```

### Key Patterns

1. **Vtable pattern**: Interface-based polymorphism (we use Zig ptr+vtable)
2. **Write Batch**: Accumulate writes, flush atomically on dispose/deinit
3. **ReadOnly Overlay**: ReadOnlyDb wraps a DB; reads fall through, writes go to memory
4. **Provider Pattern**: Named DB registry — `GetDb("state")` returns state DB
5. **Null Object**: NullDb returns null for all gets (useful for testing)
6. **ReadFlags/WriteFlags**: Caching hints for backend optimization

### Standard DB Names (from DbNames.cs)

```
storage, state, code, blocks, headers, blockNumbers, receipts,
blockInfos, badBlocks, bloom, metadata, blobTransactions,
discoveryNodes, discoveryV5Nodes, peers
```

---

## 2. Zig Implementation Design

### Files to Create

```
client/
├── db/
│   ├── types.zig        # Shared types (DbNames, ReadFlags, WriteFlags, DbMetric)
│   ├── adapter.zig      # Generic DB interface (vtable-based, like HostInterface)
│   ├── memory.zig       # In-memory backend (HashMap-based)
│   ├── rocksdb.zig      # RocksDB backend (stub for now)
│   └── provider.zig     # Named DB registry (DbProvider)
```

### VTable Pattern to Follow (from src/host.zig)

```zig
pub const HostInterface = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        getBalance: *const fn (ptr: *anyopaque, address: Address) u256,
        setBalance: *const fn (ptr: *anyopaque, address: Address, balance: u256) void,
        getCode: *const fn (ptr: *anyopaque, address: Address) []const u8,
        setCode: *const fn (ptr: *anyopaque, address: Address, code: []const u8) void,
        getStorage: *const fn (ptr: *anyopaque, address: Address, slot: u256) u256,
        setStorage: *const fn (ptr: *anyopaque, address: Address, slot: u256, value: u256) void,
        getNonce: *const fn (ptr: *anyopaque, address: Address) u64,
        setNonce: *const fn (ptr: *anyopaque, address: Address, nonce: u64) void,
    };

    pub fn getBalance(self: HostInterface, address: Address) u256 {
        return self.vtable.getBalance(self.ptr, address);
    }
    // ... forwarding methods
};
```

### Proposed Db Interface (adapter.zig)

```zig
pub const Db = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        get: *const fn (ptr: *anyopaque, key: []const u8) ?[]const u8,
        put: *const fn (ptr: *anyopaque, key: []const u8, value: []const u8) void,
        delete: *const fn (ptr: *anyopaque, key: []const u8) void,
        contains: *const fn (ptr: *anyopaque, key: []const u8) bool,
        flush: *const fn (ptr: *anyopaque) void,
        close: *const fn (ptr: *anyopaque) void,
    };

    // Forwarding methods...
};
```

---

## 3. Voltaire APIs

Phase 0 has **minimal Voltaire dependency** — DB works with raw `[]const u8` byte slices.

### Available Voltaire Primitives (for context)

Voltaire is at `../voltaire/packages/voltaire-zig/src/` and imports via:
```zig
const primitives = @import("voltaire");
```

**Primitives module** (`../voltaire/packages/voltaire-zig/src/primitives/`):
- `Address/address.zig` — 20-byte Ethereum address type
- `Hash/Hash.zig` — 32-byte hash type
- `Rlp/Rlp.zig` — RLP encoding/decoding
- `State/state.zig` — StorageKey, EMPTY_CODE_HASH, EMPTY_TRIE_ROOT
- `AccountState/AccountState.zig` — Account state struct
- `trie.zig` — MPT implementation
- `Bytes/Bytes.zig` — Byte utilities
- `Bytes32/Bytes32.zig` — 32-byte fixed-size type
- `BlockHash/BlockHash.zig`, `BlockNumber/BlockNumber.zig`, `BlockHeader/BlockHeader.zig`

**State Manager module** (`../voltaire/packages/voltaire-zig/src/state-manager/`):
- `StateManager.zig` — getBalance/setBalance/getStorage/setStorage + snapshot/revert
- `JournaledState.zig` — checkpoint/revert/commit with overlay caches
- `StateCache.zig` — per-type caching
- `ForkBackend.zig` — remote state fetching

**Crypto module** (`../voltaire/packages/voltaire-zig/src/crypto/`):
- `hash.zig` — keccak256, sha256

---

## 4. Existing Guillotine-Mini Code

| File | Relevance |
|------|-----------|
| `src/host.zig` | **Pattern to follow** — vtable ptr+vtable struct for DB interface |
| `src/storage.zig` | Uses HostInterface for storage — DB will back this in Phase 3 |
| `src/storage_injector.zig` | Async data fetch pattern, LRU cache implementation |
| `src/evm.zig` | Main EVM — uses HostInterface |
| `src/root.zig` | Module exports — client module will be separate |
| `src/frame.zig` | Call frame stack |
| `src/access_list_manager.zig` | EIP-2929/2930 warm/cold tracking |
| `build.zig` | Must add `client/` module; defines primitives, crypto, precompiles imports |
| `build.zig.zon` | Dependencies: `primitives` -> `../voltaire` |

### Build System Notes

- Modules defined via `b.addModule()` with `.imports` for Voltaire deps
- Tests use `b.addTest(.{ .root_module = mod })` pattern
- `client/` directory does NOT yet exist — must be created
- To add client module: create `client/root.zig`, add module in `build.zig`

---

## 5. Test Fixtures

**Phase 0 has NO external test fixtures.** Pure unit tests only.

Future phases that depend on DB:
- Phase 1 (Trie): `ethereum-tests/TrieTests/trietest.json`, `trieanyorder.json`, `hex_encoded_securetrie_test.json`
- Phase 3 (EVM State): `ethereum-tests/GeneralStateTests/`, `execution-spec-tests/fixtures/state_tests/`
- Phase 4 (Blockchain): `ethereum-tests/BlockchainTests/`, `execution-spec-tests/fixtures/blockchain_tests/`

### Unit Test Patterns (from Nethermind MemDb)
- Basic set/get round-trip
- Get missing key returns null
- Delete existing key
- Delete non-existing key (no-op)
- Key existence check
- Clear all entries
- Read/write count metrics
- Deinit frees all memory cleanly

---

## 6. Key Design Decisions

1. **Byte slice keys/values**: `[]const u8` for both. Type-safe wrappers added in Phase 2.
2. **Owned values**: MemoryDb stores owned copies via allocator. Returned slices valid until next mutation.
3. **Error handling**: `get()` returns `?[]const u8` (null = not found). `put()` returns `!void` for OOM.
4. **No columns initially**: Column families deferred until RocksDB is needed.
5. **No compression**: Optimization deferred.
6. **Single-threaded**: Mutexes added only when needed (Phase 8).
7. **Memory management**: MemoryDb owns all stored keys/values. `deinit()` frees everything.
8. **WriteBatch**: Implemented as a simple arraylist of operations for atomicity.

---

## 7. Implementation Order for This Pass (Pass 1/5)

**This pass creates `types.zig`** — the foundation types needed by all other DB files.

Create: `client/db/types.zig`
- `DbName` — string enum/constants for standard DB names
- `ReadFlags` — packed struct flags for read hints
- `WriteFlags` — packed struct flags for write hints
- `DbMetric` — stats struct (size, total_reads, total_writes, cache_size)
- Unit tests for all types
