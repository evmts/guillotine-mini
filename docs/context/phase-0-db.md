# Phase 0: DB Abstraction Layer — Context Document

## Goal

Create a database abstraction layer for persistent storage. This is the foundational layer that all upper layers (trie, state, blockchain) will build upon.

**Target files to create:**
- `client/db/adapter.zig` — Generic database interface (vtable-based, like HostInterface)
- `client/db/memory.zig` — In-memory backend for testing
- `client/db/rocksdb.zig` — RocksDB backend (future, stubbed initially)

## Specs

Phase 0 is an **internal abstraction** — no Ethereum specification governs the DB layer directly. However, the design must support the access patterns required by the Merkle Patricia Trie (Phase 1) and World State (Phase 2).

## Nethermind Architecture Reference

### Core Interface Hierarchy (most important)

| File | Purpose | Notes |
|------|---------|-------|
| `nethermind/src/Nethermind/Nethermind.Core/IKeyValueStore.cs` | Base KV interface: `IReadOnlyKeyValueStore` (Get/KeyExists), `IWriteOnlyKeyValueStore` (Set/Remove), `IKeyValueStore` (both) | **Primary reference** — our `DbAdapter` maps to this |
| `nethermind/src/Nethermind/Nethermind.Core/IKeyValueStoreWithBatching.cs` | Adds `StartWriteBatch()` to IKeyValueStore | Write batching for atomic commits |
| `nethermind/src/Nethermind/Nethermind.Db/IDb.cs` | Full DB interface = IKeyValueStoreWithBatching + IDbMeta + Name + GetAll/GetAllKeys | Extended DB with iteration, metrics, flush |
| `nethermind/src/Nethermind/Nethermind.Db/IDbProvider.cs` | Registry of named DBs (StateDb, CodeDb, HeadersDb, etc.) | Manages multiple DBs by name |
| `nethermind/src/Nethermind/Nethermind.Db/IDbFactory.cs` | Factory to create IDb instances from settings | Construction pattern |

### Implementations

| File | Purpose | Notes |
|------|---------|-------|
| `nethermind/src/Nethermind/Nethermind.Db/MemDb.cs` | In-memory ConcurrentDictionary-backed DB | **Primary reference for memory.zig** |
| `nethermind/src/Nethermind/Nethermind.Db/NullDb.cs` | No-op DB (singleton, returns null for all reads) | Useful for testing |
| `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDb.cs` | Read-only wrapper with in-memory overlay | Reads from overlay first, then underlying |
| `nethermind/src/Nethermind/Nethermind.Db/InMemoryWriteBatch.cs` | Batch that buffers writes, flushes on Dispose | Simple batch pattern |
| `nethermind/src/Nethermind/Nethermind.Db/InMemoryColumnBatch.cs` | Column-aware batch | For column family support |
| `nethermind/src/Nethermind/Nethermind.Db/DbNames.cs` | Constants for DB names (state, code, blocks, headers, etc.) | Our `DbName` enum |
| `nethermind/src/Nethermind/Nethermind.Db/DbProvider.cs` | DI-based DbProvider using Autofac | We'll use simpler pattern |
| `nethermind/src/Nethermind/Nethermind.Db/RocksDbSettings.cs` | DB configuration (name, path, deleteOnStart, etc.) | Settings struct |

### RocksDB Backend

| File | Purpose | Notes |
|------|---------|-------|
| `nethermind/src/Nethermind/Nethermind.Db.Rocks/DbOnTheRocks.cs` | Full RocksDB implementation (~700 lines) | **Reference for rocksdb.zig** — complex, defer to later |
| `nethermind/src/Nethermind/Nethermind.Db.Rocks/RocksDbFactory.cs` | Factory creating RocksDB instances | |
| `nethermind/src/Nethermind/Nethermind.Db.Rocks/ColumnDb.cs` | Column family support | |
| `nethermind/src/Nethermind/Nethermind.Db.Rocks/ColumnsDb.cs` | Multi-column DB | |

### Column Support

| File | Purpose | Notes |
|------|---------|-------|
| `nethermind/src/Nethermind/Nethermind.Db/IColumnsDb.cs` | Column family interface | Not needed in Phase 0 |
| `nethermind/src/Nethermind/Nethermind.Db/ReceiptsColumns.cs` | Column enum for receipts | Later phase |
| `nethermind/src/Nethermind/Nethermind.Db/BlobTxsColumns.cs` | Column enum for blob txs | Later phase |

### Other

| File | Purpose | Notes |
|------|---------|-------|
| `nethermind/src/Nethermind/Nethermind.Db/CompressingDb.cs` | Compression wrapper | Optimization, later |
| `nethermind/src/Nethermind/Nethermind.Db/FullPruning/` | Full pruning support | Much later |
| `nethermind/src/Nethermind/Nethermind.Db/Metrics.cs` | DB metrics tracking | Nice to have |
| `nethermind/src/Nethermind/Nethermind.Db/ITunableDb.cs` | Tunable performance settings | RocksDB-specific |

## Voltaire APIs Available

### Primitives (from `voltaire/packages/voltaire-zig/src/primitives/`)

Relevant types that the DB layer might interact with (via keys/values):
- `Address/` — Ethereum address (20 bytes)
- `Hash/` — Keccak256 hash (32 bytes) — used as trie node keys
- `Bytes/` — Generic byte handling
- `Bytes32/` — 32-byte fixed arrays
- `Rlp/` — RLP encoding (used for serializing trie values)
- `State/` — Account state definitions (StorageKey with address+slot)
- `AccountState/` — Account state structure
- `BlockHash/` — Block hash type
- `BlockNumber/` — Block number type

### State Manager (from `voltaire/packages/voltaire-zig/src/state-manager/`)

The state-manager already exists in Voltaire with:
- `StateCache.zig` — Per-type caching with journaling
- `JournaledState.zig` — Dual-cache orchestrator
- `StateManager.zig` — Main public API
- `ForkBackend.zig` — Remote state fetcher

**Important**: The state-manager uses its own in-memory structures. Our DB layer needs to be compatible but independent — it provides the persistent storage that the state-manager (Phase 2) will eventually back onto.

### Crypto (from `voltaire/packages/voltaire-zig/src/crypto/`)

- `hash.zig` / `keccak256_accel.zig` — For key hashing if needed

## Existing Zig Files (guillotine-mini)

| File | Relevance | Notes |
|------|-----------|-------|
| `src/host.zig` | **Key pattern reference** — vtable-based interface with `*anyopaque` pointer | Our `Db` interface should follow this exact pattern |
| `src/storage.zig` | Current EVM storage using HashMap | Will eventually be backed by our DB layer |
| `src/root.zig` | Module exports | We'll add client modules here or in a separate root |
| `src/evm.zig` | EVM implementation | Consumer of host/storage |
| `build.zig` | Build configuration | Will need updating to include client/ modules |
| `build.zig.zon` | Dependencies | Already has `primitives` dependency |

### HostInterface Pattern (from `src/host.zig`)

```zig
pub const HostInterface = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        getBalance: *const fn (ptr: *anyopaque, address: Address) u256,
        // ... more functions
    };

    pub fn getBalance(self: HostInterface, address: Address) u256 {
        return self.vtable.getBalance(self.ptr, address);
    }
    // ... convenience methods
};
```

**This is the pattern we MUST follow for the DB interface.**

## Test Fixtures

Phase 0 has **no Ethereum test fixtures** — it's an internal abstraction. Testing is entirely via inline unit tests:

- `test "MemoryDb: get returns null for missing key"`
- `test "MemoryDb: put and get round-trip"`
- `test "MemoryDb: delete removes key"`
- `test "MemoryDb: contains checks existence"`
- `test "WriteBatch: atomic commit"`
- `test "WriteBatch: delete in batch"`
- `test "DbAdapter: vtable dispatch works"`

### Relevant test fixture directories (for later phases that depend on DB):
- `ethereum-tests/TrieTests/` — Phase 1 will use DB for trie storage
- `ethereum-tests/BlockchainTests/` — Phase 4 will use DB for chain storage
- `ethereum-tests/GeneralStateTests/` — Phase 3 will use DB for state

## Design Decisions

### 1. Interface Design (vtable pattern, matching host.zig)

```zig
pub const Db = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        get: *const fn (ptr: *anyopaque, key: []const u8) ?[]const u8,
        put: *const fn (ptr: *anyopaque, key: []const u8, value: []const u8) void,
        delete: *const fn (ptr: *anyopaque, key: []const u8) void,
        contains: *const fn (ptr: *anyopaque, key: []const u8) bool,
    };
};
```

### 2. Key Design Simplification

Nethermind uses `ReadOnlySpan<byte>` for keys — arbitrary byte slices. We should do the same: `[]const u8`. The trie layer (Phase 1) will handle key hashing/encoding.

### 3. Memory Management

- MemoryDb: Arena allocator owns all stored data
- RocksDB: Caller-owned keys, DB-owned values (returned as slices with lifetime tied to DB)
- WriteBatch: Buffers operations, applies atomically

### 4. DbName Constants (from Nethermind DbNames.cs)

```zig
pub const DbName = enum {
    state,
    code,
    blocks,
    headers,
    block_numbers,
    receipts,
    block_infos,
    bad_blocks,
    bloom,
    metadata,
    blob_transactions,
};
```

### 5. Implementation Order

1. `client/db/adapter.zig` — The Db interface (vtable struct)
2. `client/db/memory.zig` — MemoryDb (HashMap-backed, for testing)
3. `client/db/rocksdb.zig` — RocksDb (stub initially, real impl later)

## Key Architectural Notes

1. **No allocation in the interface** — get() returns optional slice pointing to DB-owned memory
2. **Errors as error unions** — `!void` for puts, `error{OutOfMemory}` etc.
3. **Thread safety** — MemoryDb doesn't need it (single-threaded Zig), RocksDB handles it internally
4. **No column families initially** — simplify to plain KV store first, add columns when needed (Phase 4+)
5. **WriteBatch** — Buffer writes and commit atomically; critical for trie commits
