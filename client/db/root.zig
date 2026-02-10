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
/// - `ReadOnlyDb` — Read-only wrapper with optional in-memory overlay.
/// - `RocksDatabase` — RocksDB backend stub (not yet implemented).
/// - `DbSettings` — RocksDB configuration settings (name/path + flags + merge operators).
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
/// var mem = db.MemoryDatabase.init(allocator, .state);
/// defer mem.deinit();
///
/// const iface = mem.database();
/// try iface.put("key", "value");
/// ```
// Internal module imports — not part of the public API.
// Kept for `refAllDecls` in tests to ensure all sub-modules compile.
const adapter = @import("adapter.zig");
const memory = @import("memory.zig");
const null_db = @import("null.zig");
const rocksdb = @import("rocksdb.zig");
const read_only = @import("read_only.zig");

// -- Public API: flat re-exports of all user-facing types -----------------

/// Type-erased vtable interface for any KV backend.
pub const Database = adapter.Database;
/// Batched write operations with optional atomicity.
pub const WriteBatch = adapter.WriteBatch;
/// Single write operation used in batched commits.
pub const WriteBatchOp = adapter.WriteBatchOp;
/// Standard database partition names (matches Nethermind).
pub const DbName = adapter.DbName;
/// Database error set for backend operations.
pub const Error = adapter.Error;
/// Read flags (Nethermind ReadFlags).
pub const ReadFlags = adapter.ReadFlags;
/// Write flags (Nethermind WriteFlags).
pub const WriteFlags = adapter.WriteFlags;
/// Database metrics (Nethermind DbMetric).
pub const DbMetric = adapter.DbMetric;
/// Borrowed DB value with release semantics.
pub const DbValue = adapter.DbValue;
/// Key/value entry used by iterators.
pub const DbEntry = adapter.DbEntry;
/// Type-erased DB iterator.
pub const DbIterator = adapter.DbIterator;
/// Type-erased DB snapshot.
pub const DbSnapshot = adapter.DbSnapshot;
/// In-memory backend (for tests and ephemeral state).
pub const MemoryDatabase = memory.MemoryDatabase;
/// Null object backend (reads return null, writes error).
pub const NullDb = null_db.NullDb;
/// RocksDB backend stub (not yet implemented).
pub const RocksDatabase = rocksdb.RocksDatabase;
/// RocksDB configuration settings (name/path + flags + merge operators).
pub const DbSettings = rocksdb.DbSettings;
/// Read-only wrapper with optional in-memory overlay.
pub const ReadOnlyDb = read_only.ReadOnlyDb;

test {
    // Ensure all sub-modules compile and their tests run.
    @import("std").testing.refAllDecls(@This());
}
