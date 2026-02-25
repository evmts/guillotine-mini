/// JournalOps — Thin adapter over Voltaire StateManager checkpointing
///
/// Provides a minimal, testable surface for world-state journaling that
/// mirrors Nethermind's begin/rollback/commit semantics while delegating the
/// actual implementation to Voltaire's `StateManager`.
///
/// Design rules:
/// - Uses Voltaire primitives and state-manager exclusively; no custom types.
/// - Does not own the `StateManager`; caller manages its lifetime.
/// - Error handling is explicit; no silent catches.
const std = @import("std");
const state_manager_mod = @import("state-manager");
const StateManager = state_manager_mod.StateManager;
const primitives = @import("voltaire");
const Address = primitives.Address.Address;

/// Thin adapter that exposes begin/rollback/commit on top of `StateManager`.
pub const JournalOps = struct {
    state: *StateManager,

    const Self = @This();

    /// Create a new adapter over an existing `StateManager`.
    pub fn init(state: *StateManager) Self {
        return .{ .state = state };
    }

    /// Begin a checkpoint (push journal marker).
    pub fn begin(self: *Self) !void {
        try self.state.checkpoint();
    }

    /// Roll back to the previous checkpoint.
    pub fn rollback(self: *Self) void {
        self.state.revert();
    }

    /// Commit changes made since the previous checkpoint.
    pub fn commit(self: *Self) void {
        self.state.commit();
    }
};

fn make_address(byte: u8) Address {
    return .{ .bytes = [_]u8{byte} ++ [_]u8{0} ** 19 };
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

test "JournalOps.begin creates a checkpoint; rollback restores state" {
    const allocator = std.testing.allocator;
    var state = try StateManager.init(allocator, null);
    defer state.deinit();

    var ops = JournalOps.init(&state);
    const addr = make_address(0xA1);

    try state.setBalance(addr, 1000);
    try ops.begin();
    try state.setBalance(addr, 2000);

    // Verify mutated
    var bal = try state.getBalance(addr);
    try std.testing.expectEqual(@as(u256, 2000), bal);

    // Roll back and verify original value
    ops.rollback();
    bal = try state.getBalance(addr);
    try std.testing.expectEqual(@as(u256, 1000), bal);
}

test "JournalOps.commit persists post-checkpoint changes" {
    const allocator = std.testing.allocator;
    var state = try StateManager.init(allocator, null);
    defer state.deinit();

    var ops = JournalOps.init(&state);
    const addr = make_address(0xB2);

    try state.setBalance(addr, 1);
    try ops.begin();
    try state.setBalance(addr, 2);

    ops.commit();

    // Value 2 must persist after commit
    const bal = try state.getBalance(addr);
    try std.testing.expectEqual(@as(u256, 2), bal);
}

test "JournalOps supports nested checkpoints via StateManager" {
    const allocator = std.testing.allocator;
    var state = try StateManager.init(allocator, null);
    defer state.deinit();

    var ops = JournalOps.init(&state);
    const addr = make_address(0xC3);

    try state.setBalance(addr, 10);
    try ops.begin(); // L1
    try state.setBalance(addr, 20);
    try ops.begin(); // L2
    try state.setBalance(addr, 30);

    // Revert L2 → 20
    ops.rollback();
    var bal = try state.getBalance(addr);
    try std.testing.expectEqual(@as(u256, 20), bal);

    // Revert L1 → 10
    ops.rollback();
    bal = try state.getBalance(addr);
    try std.testing.expectEqual(@as(u256, 10), bal);
}
