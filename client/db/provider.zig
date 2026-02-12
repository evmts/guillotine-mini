/// Simple database provider that maps `DbName` → `Database` handles.
///
/// Mirrors Nethermind's `IDbProvider` at a minimal level without DI
/// containers: callers explicitly register databases by logical name and
/// retrieve them when needed. Lifetime of the underlying backends remains
/// the caller's responsibility — this provider does not own nor deinit
/// registered databases.
const std = @import("std");
const adapter = @import("adapter.zig");

const Database = adapter.Database;
const DbName = adapter.DbName;

/// Minimal provider error set.
pub const ProviderError = error{
    NotRegistered,
};

/// Registry mapping `DbName` to `Database`. Avoids heap allocations by using
/// a dense enum array storing optional entries.
pub const DbProvider = struct {
    entries: std.EnumArray(DbName, ?Database) = std.EnumArray(DbName, ?Database).initFill(null),

    /// Create an empty provider.
    pub fn init() DbProvider {
        return .{};
    }

    /// Register or replace the database for a given logical name.
    pub fn register(self: *DbProvider, name: DbName, db: Database) void {
        self.entries.set(name, db);
    }

    /// Returns the database registered for `name`, or `null` if missing.
    pub fn getOpt(self: *const DbProvider, name: DbName) ?Database {
        return self.entries.get(name) orelse null;
    }

    /// Returns the database registered for `name` or `error.NotRegistered`.
    pub fn get(self: *const DbProvider, name: DbName) ProviderError!Database {
        return self.getOpt(name) orelse ProviderError.NotRegistered;
    }

    /// Returns whether a database is registered for `name`.
    pub fn contains(self: *const DbProvider, name: DbName) bool {
        return self.entries.get(name) != null;
    }
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

const memory = @import("memory.zig");

test "DbProvider: register and retrieve databases by name" {
    var prov = DbProvider.init();

    var state_db = memory.MemoryDatabase.init(std.testing.allocator, .state);
    defer state_db.deinit();
    prov.register(.state, state_db.database());

    var headers_db = memory.MemoryDatabase.init(std.testing.allocator, .headers);
    defer headers_db.deinit();
    prov.register(.headers, headers_db.database());

    // Retrieve and check names
    const s = try prov.get(.state);
    try std.testing.expectEqual(DbName.state, s.name());
    const h = try prov.get(.headers);
    try std.testing.expectEqual(DbName.headers, h.name());
}

test "DbProvider: getOpt returns null when missing" {
    var prov = DbProvider.init();
    try std.testing.expect(prov.getOpt(.metadata) == null);
}

test "DbProvider: contains tracks registration state" {
    var prov = DbProvider.init();
    try std.testing.expect(!prov.contains(.receipts));

    var rec_db = memory.MemoryDatabase.init(std.testing.allocator, .receipts);
    defer rec_db.deinit();
    prov.register(.receipts, rec_db.database());

    try std.testing.expect(prov.contains(.receipts));
}

test "DbProvider: get returns error.NotRegistered when missing" {
    var prov = DbProvider.init();
    try std.testing.expectError(ProviderError.NotRegistered, prov.get(.bloom));
}
