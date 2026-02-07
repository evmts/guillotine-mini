/// Database abstraction layer for the Guillotine execution client.
///
/// Provides a backend-agnostic key-value storage interface modeled after
/// Nethermind's `IDb` / `IKeyValueStore` hierarchy. All persistent storage
/// (trie nodes, block data, receipts, etc.) goes through this interface.
///
/// ## Modules
///
/// - `Database` — Type-erased vtable interface for any KV backend.
/// - `WriteBatch` — Batched write operations with optional atomicity.
/// - `MemoryDatabase` — In-memory backend (for tests and ephemeral state).
/// - `RocksDatabase` — RocksDB backend stub (null object pattern, no FFI yet).
/// - `DbSettings` — Configuration for RocksDB instances.
/// - `DbName` — Standard database partition names (matches Nethermind).
///
/// ## Usage
///
/// ```zig
/// const db = @import("client/db/root.zig");
///
/// var mem = db.MemoryDatabase.init(allocator);
/// defer mem.deinit();
///
/// const iface = mem.database();
/// try iface.put("key", "value");
/// ```
pub const adapter = @import("adapter.zig");
pub const memory = @import("memory.zig");
pub const rocksdb = @import("rocksdb.zig");

pub const Database = adapter.Database;
pub const WriteBatch = adapter.WriteBatch;
pub const WriteBatchOp = adapter.WriteBatchOp;
pub const DbName = adapter.DbName;
pub const Error = adapter.Error;
pub const MemoryDatabase = memory.MemoryDatabase;
pub const RocksDatabase = rocksdb.RocksDatabase;
pub const DbSettings = rocksdb.DbSettings;

test {
    @import("std").testing.refAllDecls(@This());
}
