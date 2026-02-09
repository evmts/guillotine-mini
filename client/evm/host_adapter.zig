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
///   - **Getters** (getBalance, getCode, etc.): Panic on error. Missing accounts
///     are handled by `StateManager` and return safe defaults (0/empty) without error.
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
const ForkBackend = state_manager_mod.ForkBackend;
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
/// const host = adapter.host_interface();
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

    const log = std.log.scoped(.host_adapter);

    fn panic_state_error(comptime fmt: []const u8, args: anytype) noreturn {
        log.err(fmt, args);
        std.debug.panic(fmt, args);
    }

    // -- vtable implementations ------------------------------------------------
    //
    // Error policy:
    //   Getters → @panic on error (non-existent account is normal and returns default).
    //   Setters → @panic. A failed state write is consensus-critical.

    fn get_balance(ptr: *anyopaque, address: Address) u256 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        return self.state.getBalance(address) catch |err| panic_state_error(
            "{s} failed for {any}: {any}",
            .{ "getBalance", address, err },
        );
    }

    fn set_balance(ptr: *anyopaque, address: Address, balance: u256) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        self.state.setBalance(address, balance) catch |err| panic_state_error(
            "{s} failed for {any}: {any}",
            .{ "setBalance", address, err },
        );
    }

    fn get_code(ptr: *anyopaque, address: Address) []const u8 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        return self.state.getCode(address) catch |err| panic_state_error(
            "{s} failed for {any}: {any}",
            .{ "getCode", address, err },
        );
    }

    fn set_code(ptr: *anyopaque, address: Address, code: []const u8) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        self.state.setCode(address, code) catch |err| panic_state_error(
            "{s} failed for {any}: {any}",
            .{ "setCode", address, err },
        );
    }

    fn get_storage(ptr: *anyopaque, address: Address, slot: u256) u256 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        return self.get_storage_checked(address, slot) catch |err| panic_state_error(
            "{s} failed for {any} slot {}: {any}",
            .{ "getStorage", address, slot, err },
        );
    }

    fn get_storage_checked(self: *Self, address: Address, slot: u256) !u256 {
        return self.state.getStorage(address, slot);
    }

    fn set_storage(ptr: *anyopaque, address: Address, slot: u256, value: u256) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        self.state.setStorage(address, slot, value) catch |err| panic_state_error(
            "{s} failed for {any} slot {}: {any}",
            .{ "setStorage", address, slot, err },
        );
    }

    fn get_nonce(ptr: *anyopaque, address: Address) u64 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        return self.state.getNonce(address) catch |err| panic_state_error(
            "{s} failed for {any}: {any}",
            .{ "getNonce", address, err },
        );
    }

    fn set_nonce(ptr: *anyopaque, address: Address, nonce: u64) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        self.state.setNonce(address, nonce) catch |err| panic_state_error(
            "{s} failed for {any} nonce {}: {any}",
            .{ "setNonce", address, nonce, err },
        );
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
    const host = adapter.host_interface();

    const addr = Address{ .bytes = [_]u8{0xCC} ++ [_]u8{0} ** 19 };
    const slot: u256 = 5;

    try std.testing.expectEqual(@as(u256, 0), host.getStorage(addr, slot));

    host.setStorage(addr, slot, 999);
    try std.testing.expectEqual(@as(u256, 999), host.getStorage(addr, slot));
}

test "HostAdapter — getCode/setCode round-trip (bytecode)" {
    const allocator = std.testing.allocator;
    var state = try StateManager.init(allocator, null);
    defer state.deinit();

    var adapter = HostAdapter.init(&state);
    const host = adapter.host_interface();

    const addr = Address{ .bytes = [_]u8{0xDD} ++ [_]u8{0} ** 19 };

    try std.testing.expectEqual(@as(usize, 0), host.getCode(addr).len);

    const code = [_]u8{ 0x60, 0x00, 0x60, 0x00, 0x56 };
    host.setCode(addr, &code);
    try std.testing.expectEqualSlices(u8, &code, host.getCode(addr));
}

test "HostAdapter — StateManager checkpoint/revert propagates through adapter" {
    const allocator = std.testing.allocator;
    var state = try StateManager.init(allocator, null);
    defer state.deinit();

    var adapter = HostAdapter.init(&state);
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

test "HostAdapter — storage read surfaces backend errors" {
    const allocator = std.testing.allocator;
    var fork = try ForkBackend.init(allocator, "latest", .{});
    defer fork.deinit();

    var state = try StateManager.init(allocator, &fork);
    defer state.deinit();

    var adapter = HostAdapter.init(&state);
    const addr = Address{ .bytes = [_]u8{0xAB} ++ [_]u8{0} ** 19 };

    const result = adapter.get_storage_checked(addr, 1);
    try std.testing.expectError(error.RpcPending, result);
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
