/// World state utilities for tracking accounts created during a transaction.
///
/// Mirrors execution-specs `State.created_accounts` semantics:
/// - A set of addresses created during the *current* top-level transaction.
/// - Cleared when the outermost transaction scope ends (commit or rollback).
///
/// This tracker is intentionally minimal and allocation-aware. It does NOT
/// snapshot per nested call frame; callers should clear it when transaction
/// depth returns to zero (spec behavior).
const std = @import("std");
const primitives = @import("primitives");
const Address = primitives.Address;

/// Tracks addresses created during the current transaction.
pub const CreatedAccounts = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    set: std.AutoHashMapUnmanaged(Address, void) = .{},

    /// Initialize an empty tracker.
    pub fn init(allocator: std.mem.Allocator) Self {
        return .{ .allocator = allocator };
    }

    /// Release all memory owned by the tracker.
    pub fn deinit(self: *Self) void {
        self.set.deinit(self.allocator);
    }

    /// Remove all tracked accounts (retains capacity).
    pub fn clear(self: *Self) void {
        self.set.clearRetainingCapacity();
    }

    /// Remove all tracked accounts and release capacity.
    pub fn clearAndFree(self: *Self) void {
        self.set.clearAndFree(self.allocator);
    }

    /// Check whether an address is tracked as created.
    pub fn contains(self: *const Self, address: Address) bool {
        return self.set.contains(address);
    }

    /// Add an address to the created set.
    ///
    /// Returns true if the address was newly inserted, false if it already
    /// existed in the set.
    pub fn add(self: *Self, address: Address) error{OutOfMemory}!bool {
        const entry = try self.set.getOrPut(self.allocator, address);
        return !entry.found_existing;
    }

    /// Return the number of tracked addresses.
    pub fn len(self: *const Self) usize {
        return self.set.count();
    }
};

// =========================================================================
// Tests
// =========================================================================

test "CreatedAccounts: add/contains/len/clear" {
    const allocator = std.testing.allocator;
    var tracker = CreatedAccounts.init(allocator);
    defer tracker.deinit();

    const addr1 = Address{ .bytes = [_]u8{0x11} ++ [_]u8{0} ** 19 };
    const addr2 = Address{ .bytes = [_]u8{0x22} ++ [_]u8{0} ** 19 };

    try std.testing.expectEqual(@as(usize, 0), tracker.len());
    try std.testing.expect(!tracker.contains(addr1));

    const inserted1 = try tracker.add(addr1);
    try std.testing.expect(inserted1);
    try std.testing.expect(tracker.contains(addr1));
    try std.testing.expectEqual(@as(usize, 1), tracker.len());

    const inserted1_again = try tracker.add(addr1);
    try std.testing.expect(!inserted1_again);
    try std.testing.expectEqual(@as(usize, 1), tracker.len());

    const inserted2 = try tracker.add(addr2);
    try std.testing.expect(inserted2);
    try std.testing.expect(tracker.contains(addr2));
    try std.testing.expectEqual(@as(usize, 2), tracker.len());

    tracker.clear();
    try std.testing.expectEqual(@as(usize, 0), tracker.len());
    try std.testing.expect(!tracker.contains(addr1));
    try std.testing.expect(!tracker.contains(addr2));

    const inserted1_after_clear = try tracker.add(addr1);
    const inserted2_after_clear = try tracker.add(addr2);
    try std.testing.expect(inserted1_after_clear);
    try std.testing.expect(inserted2_after_clear);

    tracker.clearAndFree();
    try std.testing.expectEqual(@as(usize, 0), tracker.len());
    try std.testing.expect(!tracker.contains(addr1));
    try std.testing.expect(!tracker.contains(addr2));
}
