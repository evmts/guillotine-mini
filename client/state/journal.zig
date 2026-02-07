/// Change-list journal with index-based snapshot/restore.
///
/// Implements Nethermind's change-list journaling pattern
/// (`PartialStorageProviderBase.cs` / `StateProvider.cs`): changes are appended
/// to a flat list, snapshots record a position, and restore truncates back.
///
/// This is a generic building block — concrete journals for accounts, storage,
/// and transient storage will be built on top of this.
///
/// ## Design
///
/// - **Change list** — An `ArrayList` of `Entry` structs, append-only during
///   normal operation.  Entries are never modified in place.
/// - **Snapshot** — An index into the change list (`usize`).
///   `takeSnapshot()` returns the current tail position.
/// - **Restore** — Truncates the list back to a snapshot position and invokes
///   an optional callback so the caller can undo side-effects (cache cleanup).
/// - **Commit** — Discards all entries up to the snapshot (logical; the caller
///   decides what "commit" means for its caches).
///
/// ## Relationship to Nethermind
///
/// Nethermind's `PartialStorageProviderBase` uses `List<Change>` with
/// `CollectionsMarshal.SetCount()` for O(1) truncation.  This Zig
/// implementation mirrors that with `ArrayList` + `shrinkRetainingCapacity`.
///
/// Nethermind's `_intraBlockCache` (a `Dict<Key, StackList<int>>`) that maps
/// each key to a stack of change indices is *not* part of this generic journal;
/// it belongs to the concrete journal types that layer on top.
const std = @import("std");

/// A single entry in the change journal.
///
/// Mirrors Nethermind's `Change` readonly struct.
///
/// - `key`   — The entity that was changed (address, storage cell, …).
/// - `value` — The new state *after* the change (nullable for deletions).
/// - `tag`   — Classifies the change for commit/restore filtering.
pub fn Entry(comptime K: type, comptime V: type) type {
    return struct {
        key: K,
        value: ?V,
        tag: ChangeTag,
    };
}

/// Classification of a change entry.
///
/// Matches Nethermind's `ChangeType` enum, unified across account and storage
/// journals:
///
/// | Variant        | Nethermind equivalent     | Semantics                        |
/// |----------------|---------------------------|----------------------------------|
/// | `just_cache`   | `JustCache`               | Read-only; survives restore      |
/// | `update`       | `Update`                  | Value mutation                   |
/// | `create`       | `New`                     | New entity created               |
/// | `delete`       | `Delete`                  | Entity destroyed                 |
/// | `touch`        | `Touch`                   | EIP-158 empty-account touch      |
pub const ChangeTag = enum(u8) {
    /// Read-only cache population — not a mutation.
    /// Preserved across `restore()` so the cache stays warm.
    just_cache = 0,
    /// An existing value was modified.
    update = 1,
    /// A brand-new entity was created.
    create = 2,
    /// An entity was destroyed / deleted.
    delete = 3,
    /// An empty account was "touched" (EIP-158).
    touch = 4,
};

/// Generic change-list journal.
///
/// `K` is the key type (e.g. `Address` for accounts, `StorageCell` for slots).
/// `V` is the value type (e.g. `AccountState`, `u256`).
///
/// The journal itself is purely a change log.  Higher-level types add
/// per-key caches on top.
pub fn Journal(comptime K: type, comptime V: type) type {
    const E = Entry(K, V);

    return struct {
        const Self = @This();

        /// Ordered list of change entries.
        entries: std.ArrayListUnmanaged(E) = .{},

        /// Backing allocator for the entry list.
        allocator: std.mem.Allocator,

        // -----------------------------------------------------------------
        // Lifecycle
        // -----------------------------------------------------------------

        /// Create a new, empty journal.
        pub fn init(allocator: std.mem.Allocator) Self {
            return .{ .allocator = allocator };
        }

        /// Release all memory owned by the journal.
        pub fn deinit(self: *Self) void {
            self.entries.deinit(self.allocator);
        }

        // -----------------------------------------------------------------
        // Append
        // -----------------------------------------------------------------

        /// Append a change entry.  Returns the index of the new entry.
        pub fn append(self: *Self, entry: E) !usize {
            const idx = self.entries.items.len;
            try self.entries.append(self.allocator, entry);
            return idx;
        }

        // -----------------------------------------------------------------
        // Snapshot / Restore
        // -----------------------------------------------------------------

        /// Sentinel value representing "no entries" (empty journal).
        /// Mirrors Nethermind's `Resettable.EmptyPosition` (= -1 as int).
        pub const empty_snapshot: usize = std.math.maxInt(usize);

        /// Capture the current journal position.
        ///
        /// Returns `empty_snapshot` if the journal is empty, otherwise the
        /// index of the last entry.
        pub fn takeSnapshot(self: *const Self) usize {
            if (self.entries.items.len == 0) return empty_snapshot;
            return self.entries.items.len - 1;
        }

        /// Restore the journal to a previous snapshot.
        ///
        /// All entries *after* `snapshot` are removed.  For each removed
        /// entry, `on_revert` is called (if non-null) so the caller can
        /// update its caches.
        ///
        /// If `snapshot` is `empty_snapshot`, the journal is cleared
        /// entirely.
        pub fn restore(
            self: *Self,
            snapshot: usize,
            on_revert: ?*const fn (entry: *const E) void,
        ) void {
            const target_len = if (snapshot == empty_snapshot)
                0
            else
                snapshot + 1;

            if (target_len >= self.entries.items.len) return; // nothing to do

            // Walk backwards and notify caller of each reverted entry.
            if (on_revert) |cb| {
                var i = self.entries.items.len;
                while (i > target_len) {
                    i -= 1;
                    cb(&self.entries.items[i]);
                }
            }

            // Truncate — O(1), retains capacity.
            self.entries.shrinkRetainingCapacity(target_len);
        }

        /// Discard all entries (equivalent to restoring to `empty_snapshot`).
        pub fn clear(self: *Self) void {
            self.entries.shrinkRetainingCapacity(0);
        }

        // -----------------------------------------------------------------
        // Read-only accessors
        // -----------------------------------------------------------------

        /// Number of entries currently in the journal.
        pub fn len(self: *const Self) usize {
            return self.entries.items.len;
        }

        /// Get a reference to an entry by index.
        pub fn get(self: *const Self, index: usize) *const E {
            return &self.entries.items[index];
        }

        /// Get a mutable reference to an entry by index.
        pub fn getMut(self: *Self, index: usize) *E {
            return &self.entries.items[index];
        }

        /// Return a slice of all entries.
        pub fn items(self: *const Self) []const E {
            return self.entries.items;
        }
    };
}

// =========================================================================
// Tests
// =========================================================================

test "Journal: init and deinit (empty)" {
    var j = Journal(u32, u64).init(std.testing.allocator);
    defer j.deinit();

    try std.testing.expectEqual(@as(usize, 0), j.len());
}

test "Journal: append increases length" {
    var j = Journal(u32, u64).init(std.testing.allocator);
    defer j.deinit();

    const idx = try j.append(.{ .key = 1, .value = 100, .tag = .update });
    try std.testing.expectEqual(@as(usize, 0), idx);
    try std.testing.expectEqual(@as(usize, 1), j.len());
}

test "Journal: append returns sequential indices" {
    var j = Journal(u32, u64).init(std.testing.allocator);
    defer j.deinit();

    const a = try j.append(.{ .key = 1, .value = 10, .tag = .create });
    const b = try j.append(.{ .key = 2, .value = 20, .tag = .update });
    const c = try j.append(.{ .key = 3, .value = 30, .tag = .delete });

    try std.testing.expectEqual(@as(usize, 0), a);
    try std.testing.expectEqual(@as(usize, 1), b);
    try std.testing.expectEqual(@as(usize, 2), c);
    try std.testing.expectEqual(@as(usize, 3), j.len());
}

test "Journal: get returns correct entry" {
    var j = Journal(u32, u64).init(std.testing.allocator);
    defer j.deinit();

    _ = try j.append(.{ .key = 42, .value = 999, .tag = .update });

    const entry = j.get(0);
    try std.testing.expectEqual(@as(u32, 42), entry.key);
    try std.testing.expectEqual(@as(?u64, 999), entry.value);
    try std.testing.expectEqual(ChangeTag.update, entry.tag);
}

test "Journal: takeSnapshot on empty returns sentinel" {
    const j = Journal(u32, u64).init(std.testing.allocator);
    // no deinit needed — nothing allocated

    try std.testing.expectEqual(Journal(u32, u64).empty_snapshot, j.takeSnapshot());
}

test "Journal: takeSnapshot returns last index" {
    var j = Journal(u32, u64).init(std.testing.allocator);
    defer j.deinit();

    _ = try j.append(.{ .key = 1, .value = 10, .tag = .create });
    _ = try j.append(.{ .key = 2, .value = 20, .tag = .update });

    try std.testing.expectEqual(@as(usize, 1), j.takeSnapshot());
}

test "Journal: restore truncates entries" {
    var j = Journal(u32, u64).init(std.testing.allocator);
    defer j.deinit();

    _ = try j.append(.{ .key = 1, .value = 10, .tag = .create });
    const snap = j.takeSnapshot(); // position 0
    _ = try j.append(.{ .key = 2, .value = 20, .tag = .update });
    _ = try j.append(.{ .key = 3, .value = 30, .tag = .update });

    try std.testing.expectEqual(@as(usize, 3), j.len());

    j.restore(snap, null);

    try std.testing.expectEqual(@as(usize, 1), j.len());
    // Entry 0 is preserved.
    try std.testing.expectEqual(@as(u32, 1), j.get(0).key);
}

test "Journal: restore to empty_snapshot clears all" {
    var j = Journal(u32, u64).init(std.testing.allocator);
    defer j.deinit();

    _ = try j.append(.{ .key = 1, .value = 10, .tag = .create });
    _ = try j.append(.{ .key = 2, .value = 20, .tag = .update });

    j.restore(Journal(u32, u64).empty_snapshot, null);

    try std.testing.expectEqual(@as(usize, 0), j.len());
}

test "Journal: restore invokes callback for each reverted entry" {
    var j = Journal(u32, u64).init(std.testing.allocator);
    defer j.deinit();

    _ = try j.append(.{ .key = 1, .value = 10, .tag = .create });
    const snap = j.takeSnapshot();
    _ = try j.append(.{ .key = 2, .value = 20, .tag = .update });
    _ = try j.append(.{ .key = 3, .value = 30, .tag = .delete });

    // Use a static variable to count callbacks (Zig test workaround).
    const Counter = struct {
        var count: usize = 0;
        fn cb(_: *const Entry(u32, u64)) void {
            count += 1;
        }
    };
    Counter.count = 0;

    j.restore(snap, &Counter.cb);

    // Two entries reverted (indices 2 and 1).
    try std.testing.expectEqual(@as(usize, 2), Counter.count);
}

test "Journal: restore is no-op when snapshot is at current position" {
    var j = Journal(u32, u64).init(std.testing.allocator);
    defer j.deinit();

    _ = try j.append(.{ .key = 1, .value = 10, .tag = .create });
    const snap = j.takeSnapshot();

    j.restore(snap, null); // should be a no-op

    try std.testing.expectEqual(@as(usize, 1), j.len());
}

test "Journal: restore beyond current position is no-op" {
    var j = Journal(u32, u64).init(std.testing.allocator);
    defer j.deinit();

    _ = try j.append(.{ .key = 1, .value = 10, .tag = .create });

    // Snapshot index 5 is way past the single entry — should not crash.
    j.restore(5, null);

    try std.testing.expectEqual(@as(usize, 1), j.len());
}

test "Journal: clear removes all entries" {
    var j = Journal(u32, u64).init(std.testing.allocator);
    defer j.deinit();

    _ = try j.append(.{ .key = 1, .value = 10, .tag = .create });
    _ = try j.append(.{ .key = 2, .value = 20, .tag = .update });

    j.clear();

    try std.testing.expectEqual(@as(usize, 0), j.len());
    try std.testing.expectEqual(Journal(u32, u64).empty_snapshot, j.takeSnapshot());
}

test "Journal: items returns full slice" {
    var j = Journal(u32, u64).init(std.testing.allocator);
    defer j.deinit();

    _ = try j.append(.{ .key = 1, .value = 10, .tag = .create });
    _ = try j.append(.{ .key = 2, .value = 20, .tag = .update });

    const slice = j.items();
    try std.testing.expectEqual(@as(usize, 2), slice.len);
    try std.testing.expectEqual(@as(u32, 1), slice[0].key);
    try std.testing.expectEqual(@as(u32, 2), slice[1].key);
}

test "Journal: value can be null (deletion)" {
    var j = Journal(u32, u64).init(std.testing.allocator);
    defer j.deinit();

    _ = try j.append(.{ .key = 99, .value = null, .tag = .delete });

    try std.testing.expectEqual(@as(?u64, null), j.get(0).value);
    try std.testing.expectEqual(ChangeTag.delete, j.get(0).tag);
}

test "Journal: getMut allows modification" {
    var j = Journal(u32, u64).init(std.testing.allocator);
    defer j.deinit();

    _ = try j.append(.{ .key = 1, .value = 10, .tag = .update });

    j.getMut(0).value = 42;

    try std.testing.expectEqual(@as(?u64, 42), j.get(0).value);
}

test "Journal: multiple snapshot/restore cycles" {
    var j = Journal(u32, u64).init(std.testing.allocator);
    defer j.deinit();

    // Build up some state.
    _ = try j.append(.{ .key = 1, .value = 10, .tag = .create });
    const snap1 = j.takeSnapshot(); // 0

    _ = try j.append(.{ .key = 2, .value = 20, .tag = .update });
    const snap2 = j.takeSnapshot(); // 1

    _ = try j.append(.{ .key = 3, .value = 30, .tag = .update });
    try std.testing.expectEqual(@as(usize, 3), j.len());

    // Restore to snap2 — removes entry 2.
    j.restore(snap2, null);
    try std.testing.expectEqual(@as(usize, 2), j.len());

    // Add new entry after restore.
    _ = try j.append(.{ .key = 4, .value = 40, .tag = .update });
    try std.testing.expectEqual(@as(usize, 3), j.len());

    // Restore to snap1 — removes entries 1 and 2.
    j.restore(snap1, null);
    try std.testing.expectEqual(@as(usize, 1), j.len());
    try std.testing.expectEqual(@as(u32, 1), j.get(0).key);
}

test "ChangeTag: all variants accessible" {
    // Compile-time check that all tags are usable.
    const tags = [_]ChangeTag{
        .just_cache,
        .update,
        .create,
        .delete,
        .touch,
    };
    try std.testing.expectEqual(@as(usize, 5), tags.len);
}
