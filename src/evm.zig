/// EVM implementation for tracing and validation
/// This is a simplified, unoptimized EVM that orchestrates execution.
/// Architecture mirrors evm.zig - Evm orchestrates, Frame executes
const std = @import("std");
const primitives = @import("primitives");
const GasConstants = primitives.GasConstants;
const Frame = @import("frame.zig").Frame;
const Hardfork = @import("hardfork.zig").Hardfork;
const host = @import("host.zig");
const errors = @import("errors.zig");

const Address = primitives.Address.Address;

// Re-export host types for compatibility
pub const HostInterface = host.HostInterface;
pub const CallResult = host.CallResult;
pub const Host = host.Host;

/// Storage slot key for tracking
pub const StorageSlotKey = struct {
    address: Address,
    slot: u256,

    pub fn hash(key: StorageSlotKey) u32 {
        var hasher = std.hash.Wyhash.init(0);
        hasher.update(&key.address.bytes);
        hasher.update(std.mem.asBytes(&key.slot));
        return @truncate(hasher.final());
    }

    pub fn eql(a: StorageSlotKey, b: StorageSlotKey) bool {
        return a.address.equals(b.address) and a.slot == b.slot;
    }
};

// Context for Address ArrayHashMap
const AddressContext = std.array_hash_map.AutoContext(Address);

// Context for hashing/equality of StorageSlotKey for ArrayHashMap
const StorageSlotKeyContext = struct {
    pub fn hash(self: @This(), key: StorageSlotKey) u32 {
        _ = self;
        return StorageSlotKey.hash(key);
    }

    pub fn eql(self: @This(), a: StorageSlotKey, b: StorageSlotKey, b_index: usize) bool {
        _ = self;
        _ = b_index;
        return StorageSlotKey.eql(a, b);
    }
};

const BlockContext = struct {
    chain_id: u64,
    block_number: u64,
    block_timestamp: u64,
    block_difficulty: u256,
    block_prevrandao: u256,
    block_coinbase: Address,
    block_gas_limit: u64,
    block_base_fee: u256,
    blob_base_fee: u256,
};

/// EVM - Orchestrates execution like evm.zig
pub const Evm = struct {
    const Self = @This();

    frames: std.ArrayList(Frame),
    storage: std.AutoHashMap(StorageSlotKey, u256),
    original_storage: std.AutoHashMap(StorageSlotKey, u256),
    balances: std.AutoHashMap(Address, u256),
    code: std.AutoHashMap(Address, []const u8),
    warm_addresses: std.array_hash_map.ArrayHashMap(Address, void, AddressContext, false),
    warm_storage_slots: std.array_hash_map.ArrayHashMap(StorageSlotKey, void, StorageSlotKeyContext, false),
    gas_refund: u64,
    hardfork: Hardfork = Hardfork.DEFAULT,
    origin: Address,
    gas_price: u256,
    host: ?HostInterface,
    arena: std.heap.ArenaAllocator,
    allocator: std.mem.Allocator,
    block_context: BlockContext = .{
        .chain_id = 1,
        .block_number = 0,
        .block_timestamp = 0,
        .block_difficulty = 0,
        .block_prevrandao = 0,
        .block_coinbase = primitives.ZERO_ADDRESS,
        .block_gas_limit = 30_000_000,
        .block_base_fee = 0,
        .blob_base_fee = 0,
    },

    pub fn init(allocator: std.mem.Allocator, h: ?HostInterface, hardfork: ?Hardfork, block_context: ?BlockContext) !Self {
        return Self{
            .frames = undefined,
            .storage = undefined,
            .original_storage = undefined,
            .balances = undefined,
            .code = undefined,
            .warm_addresses = undefined,
            .warm_storage_slots = undefined,
            .gas_refund = 0,
            .hardfork = hardfork orelse Hardfork.DEFAULT,
            .block_context = block_context orelse .{
                .chain_id = 1,
                .block_number = 0,
                .block_timestamp = 0,
                .block_difficulty = 0,
                .block_prevrandao = 0,
                .block_coinbase = primitives.ZERO_ADDRESS,
                .block_gas_limit = 30_000_000,
                .block_base_fee = 0,
                .blob_base_fee = 0,
            },
            .origin = primitives.ZERO_ADDRESS,
            .gas_price = 0,
            .host = h,
            .arena = std.heap.ArenaAllocator.init(allocator),
            .allocator = allocator,
        };
    }

    /// Clean up resources
    pub fn deinit(self: *Self) void {
        self.arena.deinit();
    }

    pub fn accessAddress(self: *Self, address: Address) !u64 {
        if (self.hardfork.isBefore(.BERLIN)) {
            @branchHint(.cold);
            return GasConstants.CallCodeCost;
        }

        const entry = try self.warm_addresses.getOrPut(address);
        return if (entry.found_existing)
            GasConstants.WarmStorageReadCost
        else
            GasConstants.ColdAccountAccessCost;
    }

    /// Access a storage slot and return the gas cost (EIP-2929 warm/cold)
    pub fn accessStorageSlot(self: *Self, contract_address: Address, slot: u256) !u64 {
        if (self.hardfork.isBefore(.BERLIN)) {
            @branchHint(.cold);
            return GasConstants.SloadGas;
        }

        const key = StorageSlotKey{ .address = contract_address, .slot = slot };
        const entry = try self.warm_storage_slots.getOrPut(key);
        return if (entry.found_existing)
            GasConstants.WarmStorageReadCost
        else
            GasConstants.ColdSloadCost;
    }

    /// Pre-warm addresses for transaction initialization
    fn preWarmAddresses(self: *Self, addresses: []const Address) !void {
        for (addresses) |addr| {
            _ = self.warm_addresses.getOrPut(addr) catch {
                return errors.CallError.StorageError;
            };
        }
    }

    fn preWarmTransaction(self: *Self, target: Address) errors.CallError!void {
        var warm: [3]Address = undefined;
        var count: usize = 0;

        warm[count] = self.origin;
        count += 1;

        if (!target.equals(primitives.ZERO_ADDRESS)) {
            warm[count] = target;
            count += 1;
        }

        if (self.hardfork.isAtLeast(.SHANGHAI)) {
            @branchHint(.likely);
            warm[count] = self.block_context.block_coinbase;
            count += 1;
        }

        // Pre-warm origin, target, and coinbase
        try self.preWarmAddresses(warm[0..count]);

        // Pre-warm precompiles if Berlin+
        if (!self.hardfork.isAtLeast(.BERLIN)) return;
        // TODO: Pre-warm precompiles
    }

    /// Execute bytecode (main entry point like evm.execute)
    pub fn call(
        self: *Self,
        bytecode: []const u8,
        gas: i64,
        caller: Address,
        address: Address,
        value: u256,
        calldata: []const u8,
    ) errors.CallError!CallResult {
        const arena_allocator = self.arena.allocator();
        self.storage = std.AutoHashMap(StorageSlotKey, u256).init(arena_allocator);
        self.balances = std.AutoHashMap(Address, u256).init(arena_allocator);
        self.code = std.AutoHashMap(Address, []const u8).init(arena_allocator);
        self.warm_addresses = std.array_hash_map.ArrayHashMap(Address, void, AddressContext, false).init(arena_allocator);
        self.warm_storage_slots = std.array_hash_map.ArrayHashMap(StorageSlotKey, void, StorageSlotKeyContext, false).init(arena_allocator);
        self.frames = std.ArrayList(Frame){};
        try self.frames.ensureTotalCapacity(arena_allocator, 16);
        self.original_storage = std.AutoHashMap(StorageSlotKey, u256).init(arena_allocator);

        try self.preWarmTransaction(address);

        const intrinsic_gas: i64 = @intCast(GasConstants.TxGas);
        if (gas < intrinsic_gas) {
            @branchHint(.cold);
            return CallResult{
                .success = false,
                .gas_left = 0,
                .output = &[_]u8{},
            };
        }
        const execution_gas = gas - intrinsic_gas;
        const execution_gas_limit: u64 = @as(u64, @intCast(execution_gas));

        // Create and push frame onto stack
        try self.frames.append(self.arena.allocator(), try Frame.init(
            self.arena.allocator(),
            bytecode,
            execution_gas,
            caller,
            address,
            value,
            calldata,
            @as(*anyopaque, @ptrCast(self)),
            self.hardfork,
        ));
        defer _ = self.frames.pop();

        // Execute the frame (don't cache pointer - it may become invalid during nested calls)
        self.frames.items[self.frames.items.len - 1].execute() catch {
            // Error case - return failure (arena will clean up)
            return CallResult{
                .success = false,
                .gas_left = 0,
                .output = &[_]u8{},
            };
        };

        // Get frame results (refetch pointer after execution)
        const frame = &self.frames.items[self.frames.items.len - 1];
        const output = try self.arena.allocator().alloc(u8, frame.output.len);
        @memcpy(output, frame.output);

        var gas_left = @as(u64, @intCast(@max(frame.gas_remaining, 0)));
        // Apply gas refund if the call was successful
        if (!frame.reverted) {
            // Calculate total gas used including intrinsic gas (TxGas)
            // The refund cap should be based on total gas used, not just execution gas
            const execution_gas_used = if (execution_gas_limit > gas_left) execution_gas_limit - gas_left else 0;
            const total_gas_used = GasConstants.TxGas + execution_gas_used;

            // Pre-London: refund up to half of gas used; post-London: refund up to one fifth of gas used
            const capped_refund = if (self.hardfork.isBefore(.LONDON)) blk: {
                @branchHint(.cold);
                break :blk @min(self.gas_refund, total_gas_used / 2);
            } else blk: {
                @branchHint(.likely);
                break :blk @min(self.gas_refund, total_gas_used / 5);
            };

            // Apply the refund
            gas_left = gas_left + capped_refund;
            self.gas_refund = 0;
        }

        // Return result
        const result = CallResult{
            .success = !frame.reverted,
            .gas_left = gas_left,
            .output = output,
        };

        // Reset transaction-scoped caches
        self.warm_addresses.clearRetainingCapacity();
        self.warm_storage_slots.clearRetainingCapacity();

        // No cleanup needed - arena handles it
        return result;
    }

    /// Handle inner call from frame (like evm.inner_call)
    pub fn inner_call(
        self: *Self,
        address: Address,
        value: u256,
        input: []const u8,
        gas: u64,
    ) errors.CallError!CallResult {
        if (self.frames.items.len >= 1024) {
            return CallResult{
                .success = false,
                .gas_left = 0,
                .output = &[_]u8{},
            };
        }

        // Get code for the target address
        const code = self.get_code(address);
        if (code.len == 0) {
            // TODO: Implement precompiles

            // Empty account - just return success
            return CallResult{
                .success = true,
                .gas_left = gas,
                .output = &[_]u8{},
            };
        }

        // Get caller from current frame
        const caller = if (self.getCurrentFrame()) |frame| frame.address else self.origin;

        // Create and push frame onto stack
        try self.frames.append(self.arena.allocator(), try Frame.init(
            self.arena.allocator(),
            code,
            @intCast(gas),
            caller,
            address,
            value,
            input,
            @as(*anyopaque, @ptrCast(self)),
            self.hardfork,
        ));
        errdefer _ = self.frames.pop();

        // Execute frame (don't cache pointer - it may become invalid during nested calls)
        self.frames.items[self.frames.items.len - 1].execute() catch {
            _ = self.frames.pop();
            return CallResult{
                .success = false,
                .gas_left = 0,
                .output = &[_]u8{},
            };
        };

        // Get frame results (refetch pointer after execution)
        const frame = &self.frames.items[self.frames.items.len - 1];

        // Store return data
        const output = if (frame.output.len > 0) blk: {
            const output_copy = try self.arena.allocator().alloc(u8, frame.output.len);
            @memcpy(output_copy, frame.output);
            break :blk output_copy;
        } else &[_]u8{};

        // Return result
        const result = CallResult{
            .success = !frame.reverted,
            .gas_left = @as(u64, @intCast(@max(frame.gas_remaining, 0))),
            .output = output,
        };

        // Pop frame from stack
        _ = self.frames.pop();

        // No cleanup needed - arena handles it
        return result;
    }

    /// Add gas refund (called by frame)
    pub fn add_refund(self: *Self, amount: u64) void {
        self.gas_refund += amount;
    }

    /// Get balance of an address (called by frame)
    pub fn get_balance(self: *Self, address: Address) u256 {
        if (self.host) |h| return h.getBalance(address);
        return self.balances.get(address) orelse 0;
    }

    /// Get code for an address
    pub fn get_code(self: *Self, address: Address) []const u8 {
        if (self.host) |h| {
            return h.getCode(address);
        }
        return self.code.get(address) orelse &[_]u8{};
    }

    /// Get storage value (called by frame)
    pub fn get_storage(self: *Self, address: Address, slot: u256) u256 {
        if (self.host) |h| {
            return h.getStorage(address, slot);
        }
        const key = StorageSlotKey{ .address = address, .slot = slot };
        return self.storage.get(key) orelse 0;
    }

    /// Set storage value (called by frame)
    pub fn set_storage(self: *Self, address: Address, slot: u256, value: u256) !void {
        if (self.host) |h| {
            h.setStorage(address, slot, value);
            return;
        }
        const key = StorageSlotKey{ .address = address, .slot = slot };

        // Track original value on first write in transaction
        if (!self.original_storage.contains(key)) {
            const current = self.storage.get(key) orelse 0;
            try self.original_storage.put(key, current);
        }

        try self.storage.put(key, value);
    }

    /// Get original storage value (before transaction modifications)
    pub fn get_original_storage(self: *Self, address: Address, slot: u256) u256 {
        const key = StorageSlotKey{ .address = address, .slot = slot };
        // If we have tracked the original, return it
        if (self.original_storage.get(key)) |original| {
            return original;
        }
        // Otherwise return current value (unchanged in this transaction)
        return self.storage.get(key) orelse 0;
    }

    /// Get current frame (top of the frame stack)
    pub fn getCurrentFrame(self: *Self) ?*Frame {
        if (self.frames.items.len > 0) return &self.frames.items[self.frames.items.len - 1];
        return null;
    }

    /// Get current frame's PC (for tracer)
    pub fn getPC(self: *const Self) u32 {
        if (self.frames.items.len > 0) {
            return self.frames.items[self.frames.items.len - 1].pc;
        }
        return 0;
    }

    /// Get current frame's bytecode (for tracer)
    pub fn getBytecode(self: *const Self) []const u8 {
        if (self.frames.items.len > 0) {
            return self.frames.items[self.frames.items.len - 1].bytecode;
        }
        return &[_]u8{};
    }

    /// Execute a single step (for tracer)
    pub fn step(self: *Self) !void {
        if (self.getCurrentFrame()) |frame| {
            try frame.step();
        }
    }
};
