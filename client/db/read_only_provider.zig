/// Read-only provider wrapper around `DbProvider` that returns `ReadOnlyDb`
/// views for each logical database name.
///
/// Mirrors Nethermind's `ReadOnlyDb` usage at the provider layer: callers can
/// obtain a strictly read-only view (writes return StorageError) or a view
/// with a per-database in-memory write overlay. Overlays are isolated to the
/// wrapper and never mutate the underlying provider's databases.
const std = @import("std");
const adapter = @import("adapter.zig");
const provider_mod = @import("provider.zig");
const read_only = @import("read_only.zig");

const Database = adapter.Database;
const DbName = adapter.DbName;
const Error = adapter.Error;
const ReadOnlyDb = read_only.ReadOnlyDb;
const DbProvider = provider_mod.DbProvider;
const ProviderError = provider_mod.ProviderError;

/// Error set for ReadOnlyDbProvider operations.
///
/// Combines `ProviderError` (missing registration) with database-level
/// allocation errors that can occur when creating write overlays lazily.
pub const ReadOnlyProviderError = ProviderError || Error;

/// Fixed slot for storing an inline `ReadOnlyDb` instance.
const Slot = struct {
    present: bool = false,
    value: ReadOnlyDb = undefined,
};

/// Read-only wrapper provider.
///
/// - `base` is the underlying registry of concrete databases.
/// - If `overlay_allocator` is set, returned read-only DBs buffer writes in
///   a per-DB `MemoryDatabase` overlay; otherwise all writes error.
/// - `slots` caches per-DbName `ReadOnlyDb` wrappers so vtable pointers remain
///   stable without heap allocations for the wrapper object itself.
pub const ReadOnlyDbProvider = struct {
    base: *const DbProvider,
    overlay_allocator: ?std.mem.Allocator,
    // Initialize fixed slots with default `Slot{ .present = false }` repeated N times.
    // Avoids zeroing non-null pointers inside nested structs.
    slots: [std.meta.fields(DbName).len]Slot = [_]Slot{Slot{ .present = false }} ** std.meta.fields(DbName).len,

    /// Create a strict read-only provider (no write overlay). No allocations.
    pub fn init_strict(base: *const DbProvider) ReadOnlyDbProvider {
        return .{ .base = base, .overlay_allocator = null };
    }

    /// Create a provider whose returned DBs have an in-memory write overlay.
    /// Overlays are created lazily per database on first access.
    pub fn init_with_write_store(base: *const DbProvider, allocator: std.mem.Allocator) ReadOnlyDbProvider {
        return .{ .base = base, .overlay_allocator = allocator };
    }

    /// Free any overlay memory held by cached wrappers.
    pub fn deinit(self: *ReadOnlyDbProvider) void {
        var i: usize = 0;
        while (i < self.slots.len) : (i += 1) {
            if (self.slots[i].present) {
                self.slots[i].value.deinit();
                self.slots[i].present = false;
            }
        }
    }

    /// Returns whether an overlay is enabled for newly created wrappers.
    pub fn has_write_overlay(self: *const ReadOnlyDbProvider) bool {
        return self.overlay_allocator != null;
    }

    /// Returns whether the underlying provider has a database for `name`.
    pub fn contains(self: *const ReadOnlyDbProvider, name: DbName) bool {
        return self.base.contains(name);
    }

    /// Returns the read-only database for `name`, creating and caching the
    /// wrapper on first access. When overlays are enabled, a per-DB overlay
    /// is created lazily at this point.
    pub fn get(self: *ReadOnlyDbProvider, name: DbName) ReadOnlyProviderError!Database {
        const idx: usize = @intFromEnum(name);
        if (self.slots[idx].present) {
            return self.slots[idx].value.database();
        }

        // Obtain the underlying concrete database from the base provider.
        const wrapped = self.base.get(name) catch |e| switch (e) {
            ProviderError.NotRegistered => return ReadOnlyProviderError.NotRegistered,
        };

        // Construct the read-only wrapper inline in the slot, with or without overlay.
        if (self.overlay_allocator) |alloc| {
            self.slots[idx].value = try ReadOnlyDb.init_with_write_store(wrapped, alloc);
        } else {
            self.slots[idx].value = ReadOnlyDb.init(wrapped);
        }
        self.slots[idx].present = true;
        return self.slots[idx].value.database();
    }

    /// Return a previously-created wrapper interface if present, else null.
    /// Does not allocate or create new wrappers.
    pub fn getOpt(self: *ReadOnlyDbProvider, name: DbName) ?Database {
        const idx: usize = @intFromEnum(name);
        if (!self.slots[idx].present) return null;
        return self.slots[idx].value.database();
    }

    /// Clear all temporary overlay changes across all cached wrappers. No-op
    /// for wrappers created in strict read-only mode.
    pub fn clear_all_temp_changes(self: *ReadOnlyDbProvider) void {
        var i: usize = 0;
        while (i < self.slots.len) : (i += 1) {
            if (self.slots[i].present) self.slots[i].value.clear_temp_changes();
        }
    }
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

const memory = @import("memory.zig");

test "ReadOnlyDbProvider(strict): get returns read-only wrapper and forbids writes" {
    var prov = DbProvider.init();

    var state_db = memory.MemoryDatabase.init(std.testing.allocator, .state);
    defer state_db.deinit();
    try state_db.put("k", "v");
    prov.register(.state, state_db.database());

    var rop = ReadOnlyDbProvider.init_strict(&prov);
    defer rop.deinit();

    // get() creates/caches wrapper
    const db = try rop.get(.state);
    const val = try db.get("k");
    try std.testing.expect(val != null);
    defer val.?.release();
    try std.testing.expectEqualStrings("v", val.?.bytes);

    // writes are forbidden in strict mode
    try std.testing.expectError(error.StorageError, db.put("k", "x"));
    try std.testing.expectError(error.StorageError, db.delete("k"));

    // underlying database remains unchanged
    const base = state_db.get("k").?;
    defer base.release();
    try std.testing.expectEqualStrings("v", base.bytes);

    // getOpt returns cached wrapper only (no allocation)
    const db2 = rop.getOpt(.state).?;
    const v2 = try db2.get("k");
    try std.testing.expect(v2 != null);
    defer v2.?.release();
    try std.testing.expectEqualStrings("v", v2.?.bytes);
}

test "ReadOnlyDbProvider(strict): get missing db returns NotRegistered" {
    var prov = DbProvider.init();
    var rop = ReadOnlyDbProvider.init_strict(&prov);
    defer rop.deinit();
    try std.testing.expectError(ReadOnlyProviderError.NotRegistered, rop.get(.headers));
}

test "ReadOnlyDbProvider(overlay): overlay writes are isolated and clearable" {
    var prov = DbProvider.init();
    var mem = memory.MemoryDatabase.init(std.testing.allocator, .state);
    defer mem.deinit();
    try mem.put("base", "old");
    prov.register(.state, mem.database());

    var rop = ReadOnlyDbProvider.init_with_write_store(&prov, std.testing.allocator);
    defer rop.deinit();

    const rodb = try rop.get(.state);
    // overlay write
    try rodb.put("base", "ov");
    try rodb.put("temp", "t");

    // overlay wins for reads
    const ov = (try rodb.get("base")).?;
    defer ov.release();
    try std.testing.expectEqualStrings("ov", ov.bytes);
    const t = (try rodb.get("temp")).?;
    defer t.release();
    try std.testing.expectEqualStrings("t", t.bytes);

    // underlying database remains unchanged
    const base = mem.get("base").?;
    defer base.release();
    try std.testing.expectEqualStrings("old", base.bytes);
    try std.testing.expect(mem.get("temp") == null);

    // clear all overlays
    rop.clear_all_temp_changes();
    try std.testing.expect((try rodb.get("temp")) == null);
    const after = (try rodb.get("base")).?;
    defer after.release();
    try std.testing.expectEqualStrings("old", after.bytes);
}

test "ReadOnlyDbProvider(overlay): second db lazily initializes its own overlay" {
    var prov = DbProvider.init();
    var s = memory.MemoryDatabase.init(std.testing.allocator, .state);
    defer s.deinit();
    var h = memory.MemoryDatabase.init(std.testing.allocator, .headers);
    defer h.deinit();
    prov.register(.state, s.database());
    prov.register(.headers, h.database());

    var rop = ReadOnlyDbProvider.init_with_write_store(&prov, std.testing.allocator);
    defer rop.deinit();

    const sdb = try rop.get(.state);
    try sdb.put("x", "1");
    const s_val = (try sdb.get("x")).?;
    defer s_val.release();
    try std.testing.expectEqualStrings("1", s_val.bytes);

    const hdb = try rop.get(.headers);
    try hdb.put("y", "2");
    const h_val = (try hdb.get("y")).?;
    defer h_val.release();
    try std.testing.expectEqualStrings("2", h_val.bytes);
}
