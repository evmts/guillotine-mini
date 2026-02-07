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
/// - `NullDb` — Null object backend (reads return null, writes error).
/// - `RocksDatabase` — RocksDB backend stub (not yet implemented).
/// - `DbName` — Standard database partition names (matches Nethermind).
///
/// ## Architecture (Nethermind parity)
///
/// Nethermind separates `NullDb` (null object pattern, singleton) from
/// `DbOnTheRocks` (real RocksDB backend). This module follows the same
/// separation:
///   - `NullDb` — satisfies the Database interface without storing data.
///   - `RocksDatabase` — stub for future RocksDB FFI (all ops error).
///   - `MemoryDatabase` — in-memory storage for tests and ephemeral use.
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
pub const null_db = @import("null.zig");
pub const rocksdb = @import("rocksdb.zig");

pub const Database = adapter.Database;
pub const WriteBatch = adapter.WriteBatch;
pub const WriteBatchOp = adapter.WriteBatchOp;
pub const DbName = adapter.DbName;
pub const Error = adapter.Error;
pub const MemoryDatabase = memory.MemoryDatabase;
pub const NullDb = null_db.NullDb;
pub const RocksDatabase = rocksdb.RocksDatabase;

test {
    @import("std").testing.refAllDecls(@This());
}
