# [Pass 1/5] Phase 0: DB Abstraction Layer — Implementation Context

## Phase Goal

Create a database abstraction layer for persistent storage that underpins the entire Guillotine execution client. This is a pure internal abstraction — no external Ethereum specs or test fixtures apply. The DB layer provides a generic key-value interface backed by in-memory storage (for testing) or RocksDB (for production).

**Key Components** (from `prd/GUILLOTINE_CLIENT_PLAN.md`):
- `client/db/adapter.zig` — Generic database interface
- `client/db/rocksdb.zig` — RocksDB backend implementation (stub initially)
- `client/db/memory.zig` — In-memory backend for testing

**5 Implementation Passes**:
1. `types.zig` — DbNames, ReadFlags, WriteFlags, DbMetric
2. `adapter.zig` — Db vtable interface
3. `memory.zig` — In-memory HashMap backend
4. `provider.zig` — Named DB registry
5. Integration — build.zig wiring, final tests

---

## 1. Nethermind Architecture Reference

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

### Nethermind Files by Importance

| File | Purpose | Key APIs |
|------|---------|----------|
| `nethermind/src/Nethermind/Nethermind.Core/IKeyValueStore.cs` | Base interfaces | `Get(key, flags) -> ?[]byte`, `Set(key, value, flags)`, `KeyExists(key) -> bool`, `Remove(key)`, `ReadFlags`, `WriteFlags` |
| `nethermind/src/Nethermind/Nethermind.Core/IKeyValueStoreWithBatching.cs` | Batch support | `StartWriteBatch() -> IWriteBatch` |
| `nethermind/src/Nethermind/Nethermind.Core/IWriteBatch.cs` | Write batch | `IWriteOnlyKeyValueStore + IDisposable + Clear()` |
| `nethermind/src/Nethermind/Nethermind.Db/IDb.cs` | Main DB + IDbMeta | `Name`, `GetAll(ordered)`, `GetAllKeys()`, `GetAllValues()`, multi-get `this[byte[][]]`, `Flush()`, `Clear()`, `Compact()`, `GatherMetric()` |
| `nethermind/src/Nethermind/Nethermind.Db/IFullDb.cs` | Extended DB | `Keys`, `Values`, `Count` |
| `nethermind/src/Nethermind/Nethermind.Db/MemDb.cs` | **Reference impl** | `ConcurrentDictionary<byte[], byte[]?>` backed; tracks ReadsCount/WritesCount; supports write/read delays for testing |
| `nethermind/src/Nethermind/Nethermind.Db/NullDb.cs` | Null object | Singleton, returns null for all reads, throws on writes |
| `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDb.cs` | Overlay wrapper | Wraps IDb + MemDb overlay; reads check overlay first |
| `nethermind/src/Nethermind/Nethermind.Db/DbNames.cs` | Name constants | `"state"`, `"code"`, `"blocks"`, `"headers"`, `"blockNumbers"`, `"receipts"`, `"blockInfos"`, `"badBlocks"`, `"bloom"`, `"metadata"`, `"blobTransactions"`, `"discoveryNodes"`, `"discoveryV5Nodes"`, `"peers"` |
| `nethermind/src/Nethermind/Nethermind.Db/IDbProvider.cs` | Named registry | `StateDb`, `CodeDb`, `BlocksDb`, `HeadersDb`, `BlockNumbersDb`, `BlockInfosDb`, `ReceiptsDb`, `MetadataDb`, etc. via `GetDb<T>(name)` |
| `nethermind/src/Nethermind/Nethermind.Db/IDbFactory.cs` | Factory | `CreateDb(DbSettings) -> IDb` |
| `nethermind/src/Nethermind/Nethermind.Db/MemDbFactory.cs` | Factory impl | Creates MemDb instances for testing |
| `nethermind/src/Nethermind/Nethermind.Db/RocksDbSettings.cs` | Settings | `DbName`, `DbPath`, `DeleteOnStart`, `CanDeleteFolder`, `MergeOperator` |
| `nethermind/src/Nethermind/Nethermind.Db/InMemoryWriteBatch.cs` | Batch impl | Collects writes in ConcurrentDictionary; flushes to store on Dispose |
| `nethermind/src/Nethermind/Nethermind.Db/IColumnsDb.cs` | Column families | `GetColumnDb(key)`, `ColumnKeys`, `StartWriteBatch()` |
| `nethermind/src/Nethermind/Nethermind.Db/DbProvider.cs` | Provider impl | DI-based (Autofac); resolves DBs by keyed name |
| `nethermind/src/Nethermind/Nethermind.Db/IReadOnlyDb.cs` | Read-only iface | `ClearTempChanges()` |
| `nethermind/src/Nethermind/Nethermind.Db/Metrics.cs` | Prometheus metrics | Read/write counters |
| `nethermind/src/Nethermind/Nethermind.Db.Rocks/DbOnTheRocks.cs` | RocksDB impl | 1900+ lines; column families, snapshots, compaction, WAL |
| `nethermind/src/Nethermind/Nethermind.Db.Test/MemDbTests.cs` | **Test patterns** | `Simple_set_get_is_fine`, `Can_delete`, `Can_check_if_key_exists`, `Can_remove_key`, `Can_get_all`, `Dispose_does_not_cause_trouble`, `Can_get_all_ordered` |

### Key API Details

**ReadFlags** (caching hints):
```csharp
None = 0, HintCacheMiss = 1, HintReadAhead = 2, HintReadAhead2 = 4,
HintReadAhead3 = 8, SkipDuplicateRead = 16
```

**WriteFlags** (write behavior):
```csharp
None = 0, LowPriority = 1, DisableWAL = 2, LowPriorityAndNoWAL = 3
```

**DbMetric** (operational stats):
```csharp
struct DbMetric { Size, CacheSize, IndexSize, MemtableSize, TotalReads, TotalWrites }
```

### Key Patterns to Replicate

1. **VTable pattern**: Zig ptr+vtable (matches `src/host.zig`)
2. **Write Batch**: Accumulate writes, flush atomically on deinit
3. **ReadOnly Overlay**: ReadOnlyDb wraps a DB; reads check overlay first, writes go to memory
4. **Provider Pattern**: Named DB registry — `getDb("state")` returns state DB
5. **Null Object**: NullDb returns null for all gets
6. **Factory Pattern**: IDbFactory creates DB instances by settings

---

## 2. Voltaire APIs

Phase 0 has **minimal Voltaire dependency** — DB works with raw `[]const u8` byte slices.

### Build Dependency

From `build.zig.zon`:
```zig
.dependencies = .{
    .primitives = .{ .path = "../voltaire" },
    .guillotine_primitives = .{ .path = "../voltaire" },
},
```

### Available Voltaire Modules (via `build.zig`)
- `primitives` — `primitives_dep.module("primitives")`
- `crypto` — `primitives_dep.module("crypto")`
- `precompiles` — `primitives_dep.module("precompiles")`

### Key Voltaire Primitive Paths (for context, used in later phases)

| Path | Type | Phase Used |
|------|------|------------|
| `src/primitives/Address/address.zig` | 20-byte address | Phase 2+ |
| `src/primitives/Hash/Hash.zig` | 32-byte hash | Phase 1+ |
| `src/primitives/Rlp/Rlp.zig` | RLP encoding/decoding | Phase 1+ |
| `src/primitives/State/state.zig` | StorageKey, EMPTY_CODE_HASH | Phase 2+ |
| `src/primitives/AccountState/AccountState.zig` | Account state | Phase 2+ |
| `src/primitives/trie.zig` | MPT implementation | Phase 1+ |
| `src/primitives/Bytes32/Bytes32.zig` | 32-byte fixed type | Phase 1+ |
| `src/primitives/Block/Block.zig` | Block type | Phase 4+ |
| `src/primitives/BlockHeader/BlockHeader.zig` | Block header | Phase 4+ |
| `src/primitives/Receipt/Receipt.zig` | Transaction receipt | Phase 4+ |

### Voltaire State Manager (Phase 2+ bridge target)

Located at `../voltaire/packages/voltaire-zig/src/state-manager/`:
- `StateManager.zig` — getBalance/setBalance/getStorage/setStorage + snapshot/revert
- `JournaledState.zig` — checkpoint/revert/commit with overlay caches
- `StateCache.zig` — per-type caching
- `ForkBackend.zig` — remote state fetching

---

## 3. Existing Guillotine-Mini Zig Files

### Files Relevant to DB Layer

| File | Purpose | Relevance |
|------|---------|-----------|
| `src/host.zig` | **HostInterface vtable pattern** | The exact pattern to follow for DB vtable (ptr + VTable struct) |
| `src/storage.zig` | EVM storage manager | Uses HostInterface for storage; DB will back this in Phase 3. Defines `StorageSlotKey` = `{address: [20]u8, slot: u256}` |
| `src/root.zig` | Module exports | Shows module export pattern; client module will be separate |
| `src/evm.zig` | EVM implementation | Consumer of host.zig; Phase 3 creates host backed by WorldState+DB |
| `build.zig` | Build system | Must add `client/` module; shows `b.addModule()` with `.imports` pattern |
| `build.zig.zon` | Dependencies | Voltaire at `../voltaire` |

### VTable Pattern Reference (from `src/host.zig`)

```zig
pub const HostInterface = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        getBalance: *const fn (ptr: *anyopaque, address: Address) u256,
        setBalance: *const fn (ptr: *anyopaque, address: Address, balance: u256) void,
        // ... more functions
    };

    pub fn getBalance(self: HostInterface, address: Address) u256 {
        return self.vtable.getBalance(self.ptr, address);
    }
    // ... forwarding methods
};
```

### All Existing Zig Source Files

```
src/
├── evm_config.zig          — EVM configuration options
├── evm.zig                 — Main EVM implementation
├── evm_test.zig            — EVM tests
├── evm_c.zig               — C API for EVM
├── root.zig                — Module root exports
├── root_c.zig              — C/WASM entry point
├── host.zig                — HostInterface vtable ★
├── storage.zig             — Storage manager
├── storage_injector.zig    — Async storage injection
├── async_executor.zig      — Async execution support
├── frame.zig               — Call frame management
├── call_params.zig         — Call parameters
├── call_result.zig         — Call results + logs
├── errors.zig              — Error types
├── opcode.zig              — Opcode definitions
├── bytecode.zig            — Bytecode analysis
├── logger.zig              — Logging
├── trace.zig               — EIP-3155 tracing
├── access_list_manager.zig — EIP-2929 access lists
└── instructions/           — Opcode handlers (30+ files)
```

---

## 4. Test Fixtures

### Phase 0: Unit Tests Only

Phase 0 has **no external Ethereum test fixtures**. All tests are inline unit tests.

### Test Patterns to Implement (from Nethermind `MemDbTests.cs`)

| Test | Description |
|------|-------------|
| `Simple_set_get_is_fine` | Set bytes, get same bytes back |
| `Can_delete` | Clear all entries |
| `Can_check_if_key_exists` | KeyExists returns true/false correctly |
| `Can_remove_key` | Remove specific key |
| `Can_get_keys` | Count/enumerate keys |
| `Can_get_some_keys` | Multi-get returns null for missing |
| `Can_get_all` | Enumerate all values |
| `Can_get_all_ordered` | Ordered iteration |
| `Dispose_does_not_cause_trouble` | Clean shutdown |
| `Flush_does_not_cause_trouble` | Flush is no-op for memory |
| `Can_use_batches_without_issues` | WriteBatch set+commit |
| `Can_create_with_name` | Named DB |

### Future Phase Test Fixture Paths

| Phase | Fixtures |
|-------|----------|
| Phase 1 (Trie) | `ethereum-tests/TrieTests/trietest.json`, `ethereum-tests/TrieTests/trieanyorder.json`, `ethereum-tests/TrieTests/hex_encoded_securetrie_test.json` |
| Phase 3 (EVM State) | `ethereum-tests/GeneralStateTests/`, `execution-spec-tests/fixtures/state_tests/` |
| Phase 4 (Blockchain) | `ethereum-tests/BlockchainTests/`, `execution-spec-tests/fixtures/blockchain_tests/` |

---

## 5. Spec Files

No external specs for Phase 0. For reference:
- `prd/GUILLOTINE_CLIENT_PLAN.md` — Phase 0 definition
- `prd/ETHEREUM_SPECS_REFERENCE.md` — Maps Phase 0 → "N/A (internal abstraction)"

---

## 6. Design Decisions

1. **Byte slice keys**: `[]const u8` for keys and values. Higher-level typed wrappers in Phase 2.
2. **Owned values**: DB stores owned copies. Returned slices are borrowed from the DB.
3. **Error handling**: `get()` returns `?[]const u8` (null = not found). Mutations return `!void` for OOM.
4. **Allocator-aware**: All implementations take `std.mem.Allocator` — enables arena patterns.
5. **No columns initially**: Column families deferred until needed (Phase 4+).
6. **No compression/pruning initially**: Optimization deferred.
7. **Single-threaded initially**: Mutexes added later if needed.
8. **Memory management**: MemoryDb owns all stored key/value copies. `deinit()` frees everything.
9. **WriteBatch**: Collects mutations in ArrayList; applies atomically on `commit()`/`deinit()`.
10. **RocksDB stub**: Interface only in Phase 0; real implementation when persistence needed.

---

## 7. Implementation Order for All 5 Passes

| Pass | File | Content |
|------|------|---------|
| 1 | `client/db/types.zig` | `DbName` enum, `ReadFlags`, `WriteFlags`, `DbMetric` struct |
| 2 | `client/db/adapter.zig` | `Db` vtable interface (ptr + VTable), `WriteBatch` interface |
| 3 | `client/db/memory.zig` | `MemoryDb` — HashMap-backed implementation with all tests |
| 4 | `client/db/provider.zig` | `DbProvider` — named DB registry using StringHashMap |
| 5 | Integration | `client/db/root.zig` exports, `build.zig` wiring, end-to-end tests |
