/// HostAdapter — bridges Voltaire StateManager to guillotine-mini HostInterface
///
/// Implements the guillotine-mini `HostInterface` vtable backed by Voltaire's
/// `StateManager`. When the EVM calls `getBalance(addr)`, the adapter reads
/// from `StateManager`. When the EVM calls `setBalance(addr, val)`, the
/// adapter writes to `StateManager`.
///
/// ## Design Notes
///
/// - `HostInterface` vtable functions are non-failable (return `u256`, not `!u256`),
///   but `StateManager` methods return error unions (`!u256`). The adapter catches
///   errors and returns defaults (0 for balance/nonce/storage, empty slice for code).
/// - The adapter holds a pointer to a `StateManager`, not an owned copy. The caller
///   is responsible for the `StateManager` lifetime.
/// - This follows the same vtable pattern used in `test/specs/test_host.zig`.
///
/// ## Nethermind Parallel
///
/// This corresponds to Nethermind's `IWorldState` interface being passed to the
/// `VirtualMachine`, providing state read/write access.
const std = @import("std");
const evm_mod = @import("evm");
const HostInterface = evm_mod.HostInterface;
const state_manager_mod = @import("state-manager");
const StateManager = state_manager_mod.StateManager;
const primitives = @import("primitives");
const Address = primitives.Address;

/// Adapts a Voltaire `StateManager` to the guillotine-mini `HostInterface` vtable.
///
/// Usage:
/// ```zig
/// var state = try StateManager.init(allocator, null);
/// defer state.deinit();
///
/// var adapter = HostAdapter.init(&state);
/// const host = adapter.hostInterface();
/// // Pass `host` to EVM configuration
/// ```
pub const HostAdapter = struct {
    state: *StateManager,

    const Self = @This();

    /// Create a new HostAdapter wrapping the given StateManager.
    pub fn init(state: *StateManager) Self {
        return .{ .state = state };
    }

    /// Return a `HostInterface` vtable that delegates to the wrapped StateManager.
    pub fn hostInterface(self: *Self) HostInterface {
        return .{
            .ptr = @ptrCast(self),
            .vtable = &vtable,
        };
    }

    const vtable = HostInterface.VTable{
        .getBalance = getBalance,
        .setBalance = setBalance,
        .getCode = getCode,
        .setCode = setCode,
        .getStorage = getStorage,
        .setStorage = setStorage,
        .getNonce = getNonce,
        .setNonce = setNonce,
    };

    // -- vtable implementations ------------------------------------------------

    fn getBalance(ptr: *anyopaque, address: Address) u256 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        return self.state.getBalance(address) catch 0;
    }

    fn setBalance(ptr: *anyopaque, address: Address, balance: u256) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        self.state.setBalance(address, balance) catch return;
    }

    fn getCode(ptr: *anyopaque, address: Address) []const u8 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        return self.state.getCode(address) catch &[_]u8{};
    }

    fn setCode(ptr: *anyopaque, address: Address, code: []const u8) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        self.state.setCode(address, code) catch return;
    }

    fn getStorage(ptr: *anyopaque, address: Address, slot: u256) u256 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        return self.state.getStorage(address, slot) catch 0;
    }

    fn setStorage(ptr: *anyopaque, address: Address, slot: u256, value: u256) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        self.state.setStorage(address, slot, value) catch return;
    }

    fn getNonce(ptr: *anyopaque, address: Address) u64 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        return self.state.getNonce(address) catch 0;
    }

    fn setNonce(ptr: *anyopaque, address: Address, nonce: u64) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        self.state.setNonce(address, nonce) catch return;
    }
};

// =============================================================================
// Tests
// =============================================================================

test "HostAdapter — getBalance/setBalance round-trip" {
    const allocator = std.testing.allocator;
    var state = try StateManager.init(allocator, null);
    defer state.deinit();

    var adapter = HostAdapter.init(&state);
    const host = adapter.hostInterface();

    const addr = Address{ .bytes = [_]u8{0xAA} ++ [_]u8{0} ** 19 };

    // Default balance is 0
    try std.testing.expectEqual(@as(u256, 0), host.getBalance(addr));

    // Set and read back
    host.setBalance(addr, 42_000);
    try std.testing.expectEqual(@as(u256, 42_000), host.getBalance(addr));

    // Overwrite
    host.setBalance(addr, 1);
    try std.testing.expectEqual(@as(u256, 1), host.getBalance(addr));
}

test "HostAdapter — getNonce/setNonce round-trip" {
    const allocator = std.testing.allocator;
    var state = try StateManager.init(allocator, null);
    defer state.deinit();

    var adapter = HostAdapter.init(&state);
    const host = adapter.hostInterface();

    const addr = Address{ .bytes = [_]u8{0xBB} ++ [_]u8{0} ** 19 };

    try std.testing.expectEqual(@as(u64, 0), host.getNonce(addr));

    host.setNonce(addr, 7);
    try std.testing.expectEqual(@as(u64, 7), host.getNonce(addr));
}

test "HostAdapter — getStorage/setStorage round-trip" {
    const allocator = std.testing.allocator;
    var state = try StateManager.init(allocator, null);
    defer state.deinit();

    var adapter = HostAdapter.init(&state);
    const host = adapter.hostInterface();

    const addr = Address{ .bytes = [_]u8{0xCC} ++ [_]u8{0} ** 19 };
    const slot: u256 = 5;

    try std.testing.expectEqual(@as(u256, 0), host.getStorage(addr, slot));

    host.setStorage(addr, slot, 999);
    try std.testing.expectEqual(@as(u256, 999), host.getStorage(addr, slot));
}

test "HostAdapter — getCode/setCode round-trip" {
    const allocator = std.testing.allocator;
    var state = try StateManager.init(allocator, null);
    defer state.deinit();

    var adapter = HostAdapter.init(&state);
    const host = adapter.hostInterface();

    const addr = Address{ .bytes = [_]u8{0xDD} ++ [_]u8{0} ** 19 };

    // Default code is empty
    try std.testing.expectEqual(@as(usize, 0), host.getCode(addr).len);

    // Set bytecode and read back
    const bytecode = [_]u8{ 0x60, 0x00, 0x60, 0x00, 0xFD };
    host.setCode(addr, &bytecode);
    try std.testing.expectEqualSlices(u8, &bytecode, host.getCode(addr));
}

test "HostAdapter — StateManager checkpoint/revert propagates through adapter" {
    const allocator = std.testing.allocator;
    var state = try StateManager.init(allocator, null);
    defer state.deinit();

    var adapter = HostAdapter.init(&state);
    const host = adapter.hostInterface();

    const addr = Address{ .bytes = [_]u8{0xEE} ++ [_]u8{0} ** 19 };

    // Set initial balance
    host.setBalance(addr, 1000);
    try std.testing.expectEqual(@as(u256, 1000), host.getBalance(addr));

    // Checkpoint, modify, then revert
    try state.checkpoint();
    host.setBalance(addr, 2000);
    try std.testing.expectEqual(@as(u256, 2000), host.getBalance(addr));

    state.revert();
    try std.testing.expectEqual(@as(u256, 1000), host.getBalance(addr));
}

test "HostAdapter — multiple accounts isolated" {
    const allocator = std.testing.allocator;
    var state = try StateManager.init(allocator, null);
    defer state.deinit();

    var adapter = HostAdapter.init(&state);
    const host = adapter.hostInterface();

    const alice = Address{ .bytes = [_]u8{0x01} ++ [_]u8{0} ** 19 };
    const bob = Address{ .bytes = [_]u8{0x02} ++ [_]u8{0} ** 19 };

    host.setBalance(alice, 100);
    host.setBalance(bob, 200);

    try std.testing.expectEqual(@as(u256, 100), host.getBalance(alice));
    try std.testing.expectEqual(@as(u256, 200), host.getBalance(bob));
}
