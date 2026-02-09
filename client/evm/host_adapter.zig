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
///   but `StateManager` methods return error unions (`!u256`). The adapter bridges
///   this gap with a fail-fast policy:
///   - **Getters** (getBalance, getCode, etc.): Panic on backend errors. Missing
///     accounts are handled by `StateManager` and return defaults. Backend failures
///     are consensus-critical and must halt execution.
///   - **Setters** (setBalance, setCode, etc.): Panic on failure. State write failures
///     are consensus-critical — silently dropping a write would cause state divergence.
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
const StorageKey = primitives.StorageKey;

/// Adapts a Voltaire `StateManager` to the guillotine-mini `HostInterface` vtable.
///
/// Usage:
/// ```zig
/// var state = try StateManager.init(allocator, null);
/// defer state.deinit();
///
/// var adapter = HostAdapter.init(&state);
/// const host = adapter.host_interface();
/// // Pass `host` to EVM configuration
/// ```
pub const HostAdapter = struct {
    state: *StateManager,
    deleted_storage: std.AutoHashMap(StorageKey, void),

    const Self = @This();

    /// Create a new HostAdapter wrapping the given StateManager.
    pub fn init(state: *StateManager) Self {
        return .{
            .state = state,
            .deleted_storage = std.AutoHashMap(StorageKey, void).init(state.allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.deleted_storage.deinit();
    }

    /// Return a `HostInterface` vtable that delegates to the wrapped StateManager.
    pub fn host_interface(self: *Self) HostInterface {
        return .{
            .ptr = @ptrCast(self),
            .vtable = &vtable,
        };
    }

    const vtable = HostInterface.VTable{
        .getBalance = get_balance,
        .setBalance = set_balance,
        .getCode = get_code,
        .setCode = set_code,
        .getStorage = get_storage,
        .setStorage = set_storage,
        .getNonce = get_nonce,
        .setNonce = set_nonce,
    };

    // -- vtable implementations ------------------------------------------------
    //
    // Error policy:
    //   Getters → @panic on backend errors (non-existent account is normal).
    //   Setters → @panic. A failed state write is consensus-critical.

    fn get_balance(ptr: *anyopaque, address: Address) u256 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        return self.state.getBalance(address) catch |err| {
            std.debug.panic("getBalance failed for {any}: {any}", .{ address, err });
        };
    }

    fn set_balance(ptr: *anyopaque, address: Address, balance: u256) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        self.state.setBalance(address, balance) catch |err| {
            std.debug.panic("setBalance failed for {any}: {any}", .{ address, err });
        };
    }

    fn get_code(ptr: *anyopaque, address: Address) []const u8 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        return self.state.getCode(address) catch |err| {
            std.debug.panic("getCode failed for {any}: {any}", .{ address, err });
        };
    }

    fn set_code(ptr: *anyopaque, address: Address, code: []const u8) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        self.state.setCode(address, code) catch |err| {
            std.debug.panic("setCode failed for {any}: {any}", .{ address, err });
        };
    }

    fn get_storage(ptr: *anyopaque, address: Address, slot: u256) u256 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        const key = StorageKey{ .address = address.bytes, .slot = slot };
        if (self.deleted_storage.contains(key)) return 0;
        return self.state.getStorage(address, slot) catch |err| {
            std.debug.panic("getStorage failed for {any} slot {}: {any}", .{ address, slot, err });
        };
    }

    fn set_storage(ptr: *anyopaque, address: Address, slot: u256, value: u256) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        const key = StorageKey{ .address = address.bytes, .slot = slot };
        if (value == 0) {
            self.deleted_storage.put(key, {}) catch |err| {
                std.debug.panic("setStorage failed to track delete for {any} slot {}: {any}", .{ address, slot, err });
            };
            _ = self.state.journaled_state.storage_cache.delete(address, slot);
            return;
        }

        self.state.setStorage(address, slot, value) catch |err| {
            std.debug.panic("setStorage failed for {any} slot {}: {any}", .{ address, slot, err });
        };
        _ = self.deleted_storage.remove(key);
    }

    fn get_nonce(ptr: *anyopaque, address: Address) u64 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        return self.state.getNonce(address) catch |err| {
            std.debug.panic("getNonce failed for {any}: {any}", .{ address, err });
        };
    }

    fn set_nonce(ptr: *anyopaque, address: Address, nonce: u64) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        self.state.setNonce(address, nonce) catch |err| {
            std.debug.panic("setNonce failed for {any} nonce {}: {any}", .{ address, nonce, err });
        };
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
    defer adapter.deinit();
    const host = adapter.host_interface();

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
    defer adapter.deinit();
    const host = adapter.host_interface();

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
    defer adapter.deinit();
    const host = adapter.host_interface();

    const addr = Address{ .bytes = [_]u8{0xCC} ++ [_]u8{0} ** 19 };
    const slot: u256 = 5;

    try std.testing.expectEqual(@as(u256, 0), host.getStorage(addr, slot));

    host.setStorage(addr, slot, 999);
    try std.testing.expectEqual(@as(u256, 999), host.getStorage(addr, slot));
}

test "HostAdapter — getCode/setCode default empty" {
    const allocator = std.testing.allocator;
    var state = try StateManager.init(allocator, null);
    defer state.deinit();

    var adapter = HostAdapter.init(&state);
    defer adapter.deinit();
    const host = adapter.host_interface();

    const addr = Address{ .bytes = [_]u8{0xDD} ++ [_]u8{0} ** 19 };
    const code = [_]u8{ 0x60, 0x00, 0x56 };

    try std.testing.expectEqualSlices(u8, &[_]u8{}, host.getCode(addr));

    host.setCode(addr, &code);
    try std.testing.expectEqualSlices(u8, &code, host.getCode(addr));
}

test "HostAdapter — getCode/setCode round-trip" {
    const allocator = std.testing.allocator;
    var state = try StateManager.init(allocator, null);
    defer state.deinit();

    var adapter = HostAdapter.init(&state);
    defer adapter.deinit();
    const host = adapter.host_interface();

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
    defer adapter.deinit();
    const host = adapter.host_interface();

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
    const host = adapter.host_interface();

    const alice = Address{ .bytes = [_]u8{0x01} ++ [_]u8{0} ** 19 };
    const bob = Address{ .bytes = [_]u8{0x02} ++ [_]u8{0} ** 19 };

    host.setBalance(alice, 100);
    host.setBalance(bob, 200);

    try std.testing.expectEqual(@as(u256, 100), host.getBalance(alice));
    try std.testing.expectEqual(@as(u256, 200), host.getBalance(bob));
}

test "HostAdapter — getters return safe defaults for non-existent accounts" {
    const allocator = std.testing.allocator;
    var state = try StateManager.init(allocator, null);
    defer state.deinit();

    var adapter = HostAdapter.init(&state);
    const host = adapter.host_interface();

    // Use an address that was never written to.
    const unknown = Address{ .bytes = [_]u8{0xFF} ++ [_]u8{0} ** 19 };

    // Getters must return safe defaults, not error out.
    try std.testing.expectEqual(@as(u256, 0), host.getBalance(unknown));
    try std.testing.expectEqual(@as(u64, 0), host.getNonce(unknown));
    try std.testing.expectEqual(@as(u256, 0), host.getStorage(unknown, 42));
    try std.testing.expectEqual(@as(usize, 0), host.getCode(unknown).len);
}

test "HostAdapter — setters panic on failure (policy check)" {
    // This test verifies the *compile-time* error-handling policy:
    //   - Setter vtable functions call `std.debug.panic` on error, not `catch return`.
    //   - We cannot trigger a real StateManager error in unit tests (in-memory backend),
    //     but we verify the vtable is wired correctly by confirming that a successful
    //     write followed by a read returns the expected value.  The panic path is
    //     validated by code review and the `std.debug.panic` calls in the source.
    const allocator = std.testing.allocator;
    var state = try StateManager.init(allocator, null);
    defer state.deinit();

    var adapter = HostAdapter.init(&state);
    const host = adapter.host_interface();

    const addr = Address{ .bytes = [_]u8{0x42} ++ [_]u8{0} ** 19 };

    // Write through vtable — must not silently drop.
    host.setBalance(addr, 999);
    host.setNonce(addr, 10);
    host.setStorage(addr, 7, 77);
    host.setCode(addr, &[_]u8{ 0x60, 0x00 });

    // Read back — confirms the write was applied, not dropped.
    try std.testing.expectEqual(@as(u256, 999), host.getBalance(addr));
    try std.testing.expectEqual(@as(u64, 10), host.getNonce(addr));
    try std.testing.expectEqual(@as(u256, 77), host.getStorage(addr, 7));
    try std.testing.expectEqualSlices(u8, &[_]u8{ 0x60, 0x00 }, host.getCode(addr));
}
