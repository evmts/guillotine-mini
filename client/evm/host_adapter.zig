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
///   this gap with a sticky error latch:
///   - The first backend error is stored in `HostAdapter.err` and logged. Later
///     errors are logged but do not overwrite it.
///   - **Getters** (getBalance, getCode, etc.) return a safe default (0 or an
///     empty slice) after a backend error. Missing accounts are not errors:
///     `StateManager` returns 0/empty for them without failing.
///   - **Setters** (setBalance, setCode, etc.) drop the write after a backend error.
///   - Execution results produced after a latched error are invalid. Callers
///     must call `checkError()` or `takeError()` after every execution and
///     discard or roll back the state on error. A latched error is a backend
///     (infrastructure) failure, not an EVM revert.
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
const primitives = @import("voltaire");
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
/// // Pass `host` to EVM configuration and execute.
/// try adapter.checkError(); // Backend failure invalidates the result.
/// ```
pub const HostAdapter = struct {
    state: *StateManager,
    /// First backend error seen since construction or the last `takeError()`.
    /// Non-null means a vtable call returned a default value or dropped a write.
    err: ?anyerror = null,

    const Self = @This();

    /// Create a new HostAdapter wrapping the given StateManager.
    pub fn init(state: *StateManager) Self {
        return .{ .state = state };
    }

    /// Return the latched backend error and clear the latch.
    pub fn takeError(self: *Self) ?anyerror {
        const err = self.err;
        self.err = null;
        return err;
    }

    /// Return the latched backend error, if any, without clearing it.
    pub fn checkError(self: *const Self) anyerror!void {
        if (self.err) |err| return err;
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
        .accountHasStorage = account_has_storage,
        .deleteAccount = delete_account,
    };

    const log = std.log.scoped(.host_adapter);

    /// Record a backend error. The first error wins; every error is logged.
    /// Logs at warn level: the caller decides whether the error is fatal.
    fn latch(self: *Self, err: anyerror, comptime fmt: []const u8, args: anytype) void {
        log.warn(fmt ++ ": {s}", args ++ .{@errorName(err)});
        if (self.err == null) self.err = err;
    }

    // -- vtable implementations ------------------------------------------------
    //
    // Error policy: latch the error, then return a safe default (getters) or
    // drop the write (setters). Callers must check the latch after execution.

    fn get_balance(ptr: *anyopaque, address: Address) u256 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        return self.state.getBalance(address) catch |err| {
            self.latch(err, "getBalance failed for {any}", .{address});
            return 0;
        };
    }

    fn set_balance(ptr: *anyopaque, address: Address, balance: u256) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        self.state.setBalance(address, balance) catch |err|
            self.latch(err, "setBalance failed for {any}", .{address});
    }

    fn get_code(ptr: *anyopaque, address: Address) []const u8 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        return self.state.getCode(address) catch |err| {
            self.latch(err, "getCode failed for {any}", .{address});
            return &[_]u8{};
        };
    }

    fn set_code(ptr: *anyopaque, address: Address, code: []const u8) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        self.state.setCode(address, code) catch |err|
            self.latch(err, "setCode failed for {any}", .{address});
    }

    fn get_storage(ptr: *anyopaque, address: Address, slot: u256) u256 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        return self.get_storage_checked(address, slot) catch |err| {
            self.latch(err, "getStorage failed for {any} slot {}", .{ address, slot });
            return 0;
        };
    }

    fn get_storage_checked(self: *Self, address: Address, slot: u256) !u256 {
        return self.state.getStorage(address, slot);
    }

    fn set_storage(ptr: *anyopaque, address: Address, slot: u256, value: u256) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        self.state.setStorage(address, slot, value) catch |err|
            self.latch(err, "setStorage failed for {any} slot {}", .{ address, slot });
    }

    fn get_nonce(ptr: *anyopaque, address: Address) u64 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        return self.state.getNonce(address) catch |err| {
            self.latch(err, "getNonce failed for {any}", .{address});
            return 0;
        };
    }

    /// Storage slots of `address` held in the journaled (local) storage cache.
    fn cached_slots(self: *Self, address: Address) ?*std.AutoHashMap(u256, u256) {
        return self.state.journaled_state.storage_cache.cache.getPtr(address);
    }

    fn account_has_storage(ptr: *anyopaque, address: Address) bool {
        const self: *Self = @ptrCast(@alignCast(ptr));
        const slots = self.cached_slots(address) orelse return false;
        var it = slots.valueIterator();
        while (it.next()) |value| {
            if (value.* != 0) return true;
        }
        return false;
    }

    /// Delete an account: zero every cached storage slot, then reset balance,
    /// nonce, and code.
    ///
    /// Slots are zeroed in place instead of removed so a fork backend cannot
    /// refill them from the remote chain. Checkpoints deep-copy the storage
    /// map, so `StateManager.revert` restores the slots. Limitation: with a
    /// fork backend, a remote slot that was never read into the cache can still
    /// be fetched after deletion; closing that needs a storage-wipe marker in
    /// Voltaire's `JournaledState`.
    fn delete_account(ptr: *anyopaque, address: Address) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        if (self.cached_slots(address)) |slots| {
            var it = slots.valueIterator();
            while (it.next()) |value| value.* = 0;
        }
        self.state.journaled_state.putAccount(address, state_manager_mod.AccountState.init()) catch |err| {
            self.latch(err, "deleteAccount failed for {any}", .{address});
            return;
        };
        set_code(ptr, address, &[_]u8{});
    }

    fn set_nonce(ptr: *anyopaque, address: Address, nonce: u64) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        self.state.setNonce(address, nonce) catch |err|
            self.latch(err, "setNonce failed for {any} nonce {}", .{ address, nonce });
    }
};

// =============================================================================
// Tests
// =============================================================================

fn make_address(byte: u8) Address {
    return .{ .bytes = [_]u8{byte} ++ [_]u8{0} ** 19 };
}

test "HostAdapter — getBalance/setBalance round-trip" {
    const allocator = std.testing.allocator;
    var state = try StateManager.init(allocator, null);
    defer state.deinit();

    var adapter = HostAdapter.init(&state);
    const host = adapter.host_interface();

    const addr = make_address(0xAA);

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

    const addr = make_address(0xBB);

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

    const addr = make_address(0xCC);
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

    const addr = make_address(0xDD);

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

    const addr = make_address(0xEE);

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

    const alice = make_address(0x01);
    const bob = make_address(0x02);

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
    const unknown = make_address(0xFF);

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
    const addr = make_address(0xAB);

    const result = adapter.get_storage_checked(addr, 1);
    try std.testing.expectError(error.RpcPending, result);
}

test "HostAdapter — backend error is latched, not panicked" {
    const allocator = std.testing.allocator;
    var fork = try ForkBackend.init(allocator, "latest", .{});
    defer fork.deinit();

    var state = try StateManager.init(allocator, &fork);
    defer state.deinit();

    var adapter = HostAdapter.init(&state);
    const host = adapter.host_interface();
    const addr = make_address(0xAC);

    try adapter.checkError();

    // The unfetched remote slot fails with RpcPending; the getter returns 0.
    try std.testing.expectEqual(@as(u256, 0), host.getStorage(addr, 1));
    try std.testing.expectError(error.RpcPending, adapter.checkError());

    // checkError does not clear; later errors do not overwrite the first.
    _ = host.getStorage(addr, 2);
    try std.testing.expectEqual(@as(?anyerror, error.RpcPending), adapter.takeError());

    // takeError clears the latch.
    try std.testing.expectEqual(@as(?anyerror, null), adapter.takeError());
    try adapter.checkError();
}

test "HostAdapter — successful writes leave the latch empty" {
    const allocator = std.testing.allocator;
    var state = try StateManager.init(allocator, null);
    defer state.deinit();

    var adapter = HostAdapter.init(&state);
    const host = adapter.host_interface();

    const addr = make_address(0x42);

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
    try adapter.checkError();
}

test "HostAdapter — deleteAccount removes storage, balance, nonce, and code" {
    const allocator = std.testing.allocator;
    var state = try StateManager.init(allocator, null);
    defer state.deinit();

    var adapter = HostAdapter.init(&state);
    const host = adapter.host_interface();

    const victim = make_address(0x51);
    const bystander = make_address(0x52);

    host.setBalance(victim, 500);
    host.setNonce(victim, 4);
    host.setCode(victim, &[_]u8{ 0x60, 0x01 });
    host.setStorage(victim, 1, 11);
    host.setStorage(victim, 2, 22);
    host.setStorage(victim, std.math.maxInt(u256), 33);
    host.setStorage(bystander, 1, 99);

    try std.testing.expect(host.accountHasStorage(victim));
    host.deleteAccount(victim);

    try std.testing.expectEqual(@as(u256, 0), host.getStorage(victim, 1));
    try std.testing.expectEqual(@as(u256, 0), host.getStorage(victim, 2));
    try std.testing.expectEqual(@as(u256, 0), host.getStorage(victim, std.math.maxInt(u256)));
    try std.testing.expectEqual(@as(u256, 0), host.getBalance(victim));
    try std.testing.expectEqual(@as(u64, 0), host.getNonce(victim));
    try std.testing.expectEqual(@as(usize, 0), host.getCode(victim).len);
    try std.testing.expect(!host.accountHasStorage(victim));
    try std.testing.expect(!host.accountExists(victim));

    try std.testing.expectEqual(@as(u256, 99), host.getStorage(bystander, 1));
    try std.testing.expect(host.accountHasStorage(bystander));
}

test "HostAdapter — recreated account does not see previous incarnation's storage" {
    const allocator = std.testing.allocator;
    var state = try StateManager.init(allocator, null);
    defer state.deinit();

    var adapter = HostAdapter.init(&state);
    const host = adapter.host_interface();
    const addr = make_address(0x53);

    host.setStorage(addr, 7, 0xdead);
    host.deleteAccount(addr);
    host.setNonce(addr, 1);
    host.setCode(addr, &[_]u8{0x00});

    try std.testing.expectEqual(@as(u256, 0), host.getStorage(addr, 7));
}

test "HostAdapter — revert restores storage removed by deleteAccount" {
    const allocator = std.testing.allocator;
    var state = try StateManager.init(allocator, null);
    defer state.deinit();

    var adapter = HostAdapter.init(&state);
    const host = adapter.host_interface();
    const addr = make_address(0x54);

    host.setBalance(addr, 10);
    host.setStorage(addr, 3, 33);

    try state.checkpoint();
    host.deleteAccount(addr);
    try std.testing.expectEqual(@as(u256, 0), host.getStorage(addr, 3));
    state.revert();

    try std.testing.expectEqual(@as(u256, 33), host.getStorage(addr, 3));
    try std.testing.expectEqual(@as(u256, 10), host.getBalance(addr));
}
