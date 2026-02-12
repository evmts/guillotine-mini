/// AccountJournal — thin facade over Journal(Address, AccountState)
///
/// Purpose: record account-level changes (create/update/delete/just_cache)
/// using the generic change-list Journal while enforcing Voltaire primitives.
///
/// Design constraints:
/// - Uses Voltaire `primitives.Address.Address` and
///   `primitives.AccountState.AccountState` exclusively.
/// - Delegates snapshot/restore/commit to the underlying Journal.
/// - No hidden allocations beyond the Journal's append/truncate.
const std = @import("std");
const primitives = @import("primitives");

const Address = primitives.Address.Address;
const AccountState = primitives.AccountState.AccountState;

const journal_mod = @import("journal.zig");
const JournalType = journal_mod.Journal(Address, AccountState);
const EntryType = journal_mod.Entry(Address, AccountState);
const ChangeTag = journal_mod.ChangeTag;
const JournalError = journal_mod.JournalError;

pub const AccountJournal = struct {
    const Self = @This();

    journal: JournalType,

    /// Initialize an empty account journal.
    pub fn init(allocator: std.mem.Allocator) Self {
        return .{ .journal = JournalType.init(allocator) };
    }

    /// Release all memory.
    pub fn deinit(self: *Self) void {
        self.journal.deinit();
    }

    // ---------------------------------------------------------------------
    // Recording helpers
    // ---------------------------------------------------------------------

    /// Record a cache-only read of an account (survives restore).
    pub fn cache(self: *Self, addr: Address, acct: AccountState) JournalError!usize {
        return self.journal.append(.{ .key = addr, .value = acct, .tag = .just_cache });
    }

    /// Record a new account creation.
    pub fn create(self: *Self, addr: Address, acct: AccountState) JournalError!usize {
        return self.journal.append(.{ .key = addr, .value = acct, .tag = .create });
    }

    /// Record an account update.
    pub fn update(self: *Self, addr: Address, acct: AccountState) JournalError!usize {
        return self.journal.append(.{ .key = addr, .value = acct, .tag = .update });
    }

    /// Record an account deletion.
    pub fn delete(self: *Self, addr: Address) JournalError!usize {
        return self.journal.append(.{ .key = addr, .value = null, .tag = .delete });
    }

    // ---------------------------------------------------------------------
    // Snapshot / Restore / Commit
    // ---------------------------------------------------------------------

    /// Capture the current tail position (or empty sentinel).
    pub fn take_snapshot(self: *const Self) usize {
        return self.journal.take_snapshot();
    }

    /// Restore to a previous snapshot; preserves just_cache entries.
    pub fn restore(self: *Self, snapshot: usize) JournalError!void {
        try self.journal.restore(snapshot, null);
    }

    /// Commit entries after a snapshot.
    pub fn commit(self: *Self, snapshot: usize) JournalError!void {
        try self.journal.commit(snapshot, null);
    }

    // ---------------------------------------------------------------------
    // Read-only accessors (for tests / diagnostics)
    // ---------------------------------------------------------------------

    /// Number of entries currently recorded.
    pub fn len(self: *const Self) usize {
        // Use underlying private method through field to avoid copying.
        return self.journal.entries.items.len;
    }

    /// Expose a read-only view of the entries (testing aid).
    pub fn items(self: *const Self) []const EntryType {
        return self.journal.items();
    }
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

fn addr(byte: u8) Address {
    return .{ .bytes = [_]u8{byte} ++ [_]u8{0} ** 19 };
}

test "AccountJournal: create/update/delete/cache tagging and restore preserves just_cache" {
    var aj = AccountJournal.init(std.testing.allocator);
    defer aj.deinit();

    const a1 = addr(0xA1);
    const a2 = addr(0xA2);
    const a3 = addr(0xA3);
    const a4 = addr(0xA4);

    const empty = AccountState.createEmpty();
    const with_nonce = AccountState.from(.{ .nonce = 1 });
    const with_balance = AccountState.from(.{ .balance = 2 });

    // Initial create, then snapshot.
    _ = try aj.create(a1, empty);
    const snap = aj.take_snapshot();

    // Mix of cache/update/cache/delete after the snapshot.
    _ = try aj.cache(a2, empty);
    _ = try aj.update(a1, with_nonce);
    _ = try aj.cache(a3, with_balance);
    _ = try aj.delete(a4);

    // Verify tagging pre-restore.
    const pre = aj.items();
    try std.testing.expectEqual(@as(usize, 5), pre.len);
    try std.testing.expectEqual(ChangeTag.create, pre[0].tag);
    try std.testing.expectEqual(ChangeTag.just_cache, pre[1].tag);
    try std.testing.expectEqual(ChangeTag.update, pre[2].tag);
    try std.testing.expectEqual(ChangeTag.just_cache, pre[3].tag);
    try std.testing.expectEqual(ChangeTag.delete, pre[4].tag);
    try std.testing.expect(pre[4].value == null);

    // Restore — only the just_cache entries after the snapshot should survive,
    // re-appended in original order after the preserved prefix.
    try aj.restore(snap);

    try std.testing.expectEqual(@as(usize, 3), aj.len());
    const post = aj.items();
    try std.testing.expectEqual(ChangeTag.create, post[0].tag);
    try std.testing.expectEqual(ChangeTag.just_cache, post[1].tag);
    try std.testing.expectEqual(ChangeTag.just_cache, post[2].tag);
    // Order preserved for just_cache entries
    try std.testing.expect(std.mem.eql(u8, &post[1].key.bytes, &a2.bytes));
    try std.testing.expect(std.mem.eql(u8, &post[2].key.bytes, &a3.bytes));
}

test "AccountJournal: commit after snapshot clears tail" {
    var aj = AccountJournal.init(std.testing.allocator);
    defer aj.deinit();

    const a1 = addr(0xB1);
    const a2 = addr(0xB2);
    const empty = AccountState.createEmpty();

    _ = try aj.create(a1, empty);
    const snap = aj.take_snapshot();
    _ = try aj.update(a1, AccountState.from(.{ .nonce = 7 }));
    _ = try aj.cache(a2, empty);

    // Commit tail beyond snapshot, then ensure only prefix remains.
    try aj.commit(snap);
    try std.testing.expectEqual(@as(usize, 1), aj.len());
    const post = aj.items();
    try std.testing.expectEqual(ChangeTag.create, post[0].tag);
}
