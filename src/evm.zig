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
const trace = @import("trace.zig");
const blake2 = @import("blake2.zig");

const Address = primitives.Address.Address;

// Re-export host types for compatibility
pub const HostInterface = host.HostInterface;
pub const CallResult = host.CallResult;
pub const Host = host.Host;

/// Access list storage key slot type
pub const AccessListStorageKey = struct {
    address: Address,
    slot: u256,
};

/// Access list parameter type for EIP-2930
pub const AccessListParam = struct {
    addresses: []const Address,
    storage_keys: []const AccessListStorageKey,
};

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
    transient_storage: std.AutoHashMap(StorageSlotKey, u256),
    created_accounts: std.AutoHashMap(Address, void),
    balances: std.AutoHashMap(Address, u256),
    nonces: std.AutoHashMap(Address, u64),
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
    tracer: ?*trace.Tracer = null,
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
    blob_versioned_hashes: []const [32]u8 = &[_][32]u8{},

    pub fn init(allocator: std.mem.Allocator, h: ?HostInterface, hardfork: ?Hardfork, block_context: ?BlockContext) !Self {
        return Self{
            .frames = undefined,
            .storage = undefined,
            .original_storage = undefined,
            .transient_storage = undefined,
            .created_accounts = undefined,
            .balances = undefined,
            .nonces = undefined,
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
            .tracer = null,
        };
    }

    /// Clean up resources
    pub fn deinit(self: *Self) void {
        self.arena.deinit();
    }

    /// Set tracer for EIP-3155 trace capture
    pub fn setTracer(self: *Self, tracer: *trace.Tracer) void {
        self.tracer = tracer;
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
        access_list: ?AccessListParam,
        blob_versioned_hashes: ?[]const [32]u8,
    ) errors.CallError!CallResult {
        const arena_allocator = self.arena.allocator();
        self.storage = std.AutoHashMap(StorageSlotKey, u256).init(arena_allocator);
        self.balances = std.AutoHashMap(Address, u256).init(arena_allocator);
        self.nonces = std.AutoHashMap(Address, u64).init(arena_allocator);
        self.code = std.AutoHashMap(Address, []const u8).init(arena_allocator);
        self.warm_addresses = std.array_hash_map.ArrayHashMap(Address, void, AddressContext, false).init(arena_allocator);
        self.warm_storage_slots = std.array_hash_map.ArrayHashMap(StorageSlotKey, void, StorageSlotKeyContext, false).init(arena_allocator);
        self.frames = std.ArrayList(Frame){};
        try self.frames.ensureTotalCapacity(arena_allocator, 16);
        self.original_storage = std.AutoHashMap(StorageSlotKey, u256).init(arena_allocator);
        self.transient_storage = std.AutoHashMap(StorageSlotKey, u256).init(arena_allocator);
        self.created_accounts = std.AutoHashMap(Address, void).init(arena_allocator);

        // Set blob versioned hashes for EIP-4844
        if (blob_versioned_hashes) |hashes| {
            self.blob_versioned_hashes = hashes;
        } else {
            self.blob_versioned_hashes = &[_][32]u8{};
        }

        try self.preWarmTransaction(address);

        // Pre-warm access list (EIP-2930)
        if (access_list) |list| {
            // Pre-warm all addresses in access list
            for (list.addresses) |addr| {
                _ = try self.warm_addresses.getOrPut(addr);
            }

            // Pre-warm all storage keys in access list
            for (list.storage_keys) |entry| {
                const key = StorageSlotKey{
                    .address = entry.address,
                    .slot = entry.slot,
                };
                _ = try self.warm_storage_slots.getOrPut(key);
            }
        }

        // Transfer value from caller to recipient (if value > 0)
        if (value > 0 and self.host != null) {
            const sender_balance = if (self.host) |h| h.getBalance(caller) else 0;
            if (sender_balance < value) {
                return CallResult{
                    .success = false,
                    .gas_left = 0,
                    .output = &[_]u8{},
                };
            }
            if (self.host) |h| {
                h.setBalance(caller, sender_balance - value);
                const recipient_balance = h.getBalance(address);
                h.setBalance(address, recipient_balance + value);
            }
        }

        // Note: intrinsic gas should be deducted by the caller (e.g., test runner)
        // before calling this function. This function receives gas that's already
        // net of intrinsic costs, similar to inner_call().
        const execution_gas_limit: u64 = @as(u64, @intCast(gas));

        // Create and push frame onto stack
        try self.frames.append(self.arena.allocator(), try Frame.init(
            self.arena.allocator(),
            bytecode,
            gas,
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
            // Error case - reverse value transfer if needed
            if (value > 0 and self.host != null) {
                if (self.host) |h| {
                    const sender_balance = h.getBalance(caller);
                    const recipient_balance = h.getBalance(address);
                    h.setBalance(caller, sender_balance + value);
                    h.setBalance(address, recipient_balance - value);
                }
            }
            // Return failure (arena will clean up)
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
            // Calculate gas used (note: intrinsic gas is handled by the caller)
            const execution_gas_used = if (execution_gas_limit > gas_left) execution_gas_limit - gas_left else 0;

            // Pre-London: refund up to half of gas used; post-London: refund up to one fifth of gas used
            const capped_refund = if (self.hardfork.isBefore(.LONDON)) blk: {
                @branchHint(.cold);
                break :blk @min(self.gas_refund, execution_gas_used / 2);
            } else blk: {
                @branchHint(.likely);
                break :blk @min(self.gas_refund, execution_gas_used / 5);
            };

            // Apply the refund
            gas_left = gas_left + capped_refund;
            self.gas_refund = 0;
        }

        // Reverse value transfer if transaction reverted
        if (frame.reverted and value > 0 and self.host != null) {
            if (self.host) |h| {
                const sender_balance = h.getBalance(caller);
                const recipient_balance = h.getBalance(address);
                h.setBalance(caller, sender_balance + value);
                h.setBalance(address, recipient_balance - value);
            }
        }

        // Return result (execution gas left; intrinsic gas handled by caller)
        const result = CallResult{
            .success = !frame.reverted,
            .gas_left = gas_left,
            .output = output,
        };

        // Reset transaction-scoped caches
        self.warm_addresses.clearRetainingCapacity();
        self.warm_storage_slots.clearRetainingCapacity();

        // Clear transient storage at end of transaction (EIP-1153)
        self.transient_storage.clearRetainingCapacity();

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
        call_type: HostInterface.CallType,
    ) errors.CallError!CallResult {
        if (self.frames.items.len >= 1024) {
            return CallResult{
                .success = false,
                .gas_left = 0,
                .output = &[_]u8{},
            };
        }

        // Snapshot transient storage before the call (EIP-1153)
        // Transient storage must be reverted on call failure
        var transient_snapshot = std.AutoHashMap(StorageSlotKey, u256).init(self.arena.allocator());
        var it = self.transient_storage.iterator();
        while (it.next()) |entry| {
            try transient_snapshot.put(entry.key_ptr.*, entry.value_ptr.*);
        }

        // Get caller from current frame
        const caller = if (self.getCurrentFrame()) |frame| frame.address else self.origin;

        // Handle balance transfer if value > 0 (only for regular CALL)
        if (value > 0 and call_type == .Call) {
            const caller_balance = if (self.host) |h| h.getBalance(caller) else self.balances.get(caller) orelse 0;
            if (caller_balance < value) {
                // Insufficient balance - call fails
                // std.debug.print("CALL FAILED: insufficient balance (caller={any} needs {} has {})\n", .{caller.bytes, value, caller_balance});
                return CallResult{
                    .success = false,
                    .gas_left = gas,
                    .output = &[_]u8{},
                };
            }

            // Transfer balance
            if (self.host) |h| {
                // std.debug.print("TRANSFER: from={any} to={any} value={} (caller_bal={} callee_bal={})\n", .{caller.bytes, address.bytes, value, caller_balance, h.getBalance(address)});
                h.setBalance(caller, caller_balance - value);
                const callee_balance = h.getBalance(address);
                h.setBalance(address, callee_balance + value);
            } else {
                try self.balances.put(caller, caller_balance - value);
                const callee_balance = self.balances.get(address) orelse 0;
                try self.balances.put(address, callee_balance + value);
            }
        }

        // Get code for the target address
        const code = self.get_code(address);
        // std.debug.print("DEBUG inner_call: address={any} code.len={} frames={}\n", .{address.bytes, code.len, self.frames.items.len});
        if (code.len == 0) {
            // Check if this is a precompile address
            const addr_num = blk: {
                var val: u256 = 0;
                for (address.bytes) |b| {
                    val = (val << 8) | b;
                }
                break :blk val;
            };

            // Precompile 0x01: ECRECOVER - signature recovery (all forks)
            if (addr_num == 1) {
                const precompile_gas: u64 = 3000;

                if (gas < precompile_gas) {
                    return CallResult{
                        .success = false,
                        .gas_left = 0,
                        .output = &[_]u8{},
                    };
                }

                // Pad input to 128 bytes if needed
                var padded_input: [128]u8 = [_]u8{0} ** 128;
                const copy_len = @min(input.len, 128);
                @memcpy(padded_input[0..copy_len], input[0..copy_len]);

                // For now, return empty output (20 zero bytes + 12 padding)
                // TODO: Implement actual ECRECOVER using crypto library
                const output = try self.arena.allocator().alloc(u8, 32);
                @memset(output, 0);

                return CallResult{
                    .success = true,
                    .gas_left = gas - precompile_gas,
                    .output = output,
                };
            }

            // Precompile 0x02: SHA256 - available in all forks
            if (addr_num == 2) {
                const Sha256 = std.crypto.hash.sha2.Sha256;
                // Gas cost: 60 + 12 * (len(input) / 32) rounded up
                const input_len = input.len;
                const word_count = (input_len + 31) / 32;
                const precompile_gas = 60 + (12 * word_count);

                if (gas < precompile_gas) {
                    // Out of gas
                    return CallResult{
                        .success = false,
                        .gas_left = 0,
                        .output = &[_]u8{},
                    };
                }

                // Compute SHA256 hash
                var hash: [32]u8 = undefined;
                Sha256.hash(input, &hash, .{});

                const output = try self.arena.allocator().alloc(u8, 32);
                @memcpy(output, &hash);

                return CallResult{
                    .success = true,
                    .gas_left = gas - precompile_gas,
                    .output = output,
                };
            }

            // Precompile 0x04: Identity (datacopy) - available in all forks
            if (addr_num == 4) {
                // Identity: copy input to output
                // Gas cost: 15 + 3 * (len(input) / 32) rounded up
                const input_len = input.len;
                const word_count = (input_len + 31) / 32;
                const precompile_gas = 15 + (3 * word_count);

                if (gas < precompile_gas) {
                    // Out of gas
                    return CallResult{
                        .success = false,
                        .gas_left = 0,
                        .output = &[_]u8{},
                    };
                }

                // Copy input to output
                const output = try self.arena.allocator().alloc(u8, input_len);
                @memcpy(output, input);

                return CallResult{
                    .success = true,
                    .gas_left = gas - precompile_gas,
                    .output = output,
                };
            }

            // Precompile 0x05: MODEXP - modular exponentiation (Byzantium+, EIP-198)
            if (addr_num == 5 and self.hardfork.isAtLeast(.BYZANTIUM)) {
                // Parse lengths from input (first 96 bytes)
                var base_len: u256 = 0;
                var exp_len: u256 = 0;
                var mod_len: u256 = 0;

                if (input.len >= 32) {
                    for (input[0..32]) |b| base_len = (base_len << 8) | b;
                }
                if (input.len >= 64) {
                    for (input[32..64]) |b| exp_len = (exp_len << 8) | b;
                }
                if (input.len >= 96) {
                    for (input[64..96]) |b| mod_len = (mod_len << 8) | b;
                }

                // Parse exponent head (first 32 bytes of exponent, for gas calculation)
                const exp_start = 96 + @as(usize, @intCast(@min(base_len, std.math.maxInt(usize))));
                var exp_head: u256 = 0;
                const exp_head_len = @min(@as(usize, @intCast(@min(exp_len, 32))), input.len -| exp_start);
                if (exp_start < input.len and exp_head_len > 0) {
                    for (input[exp_start..][0..exp_head_len]) |b| exp_head = (exp_head << 8) | b;
                }

                // Calculate complexity (mult_complexity)
                const max_len = @max(base_len, mod_len);
                const mult_complexity = if (max_len <= 64) blk: {
                    break :blk (max_len * max_len);
                } else if (max_len <= 1024) blk: {
                    break :blk ((max_len * max_len) / 4) + (96 * max_len) - 3072;
                } else blk: {
                    break :blk ((max_len * max_len) / 16) + (480 * max_len) - 199680;
                };

                // Calculate iterations (iteration_count)
                const adjusted_exp_len = if (exp_len < 32) blk: {
                    // bit_length - 1 of exp_head, or 0
                    if (exp_head == 0) break :blk 0;
                    var bit_len: u256 = 0;
                    var temp = exp_head;
                    var safety: u256 = 0;
                    while (temp > 0 and safety < 256) : ({temp >>= 1; safety += 1;}) bit_len += 1;
                    break :blk if (bit_len > 0) bit_len - 1 else 0;
                } else blk: {
                    if (exp_head == 0) {
                        // If exp_head is 0 but exp_len >= 32, the effective bit length is still based on exp_len
                        break :blk 8 * (exp_len - 32);
                    }
                    var bit_len: u256 = 0;
                    var temp = exp_head;
                    var safety: u256 = 0;
                    while (temp > 0 and safety < 256) : ({temp >>= 1; safety += 1;}) bit_len += 1;
                    const exp_bit_len = if (bit_len > 0) bit_len - 1 else 0;
                    break :blk 8 * (exp_len - 32) + exp_bit_len;
                };
                const iteration_count = @max(adjusted_exp_len, 1);

                // Gas cost = (mult_complexity * iteration_count) / 20
                const cost = (mult_complexity * iteration_count) / 20;
                const precompile_gas = @as(u64, @intCast(@min(cost, std.math.maxInt(u64))));

                if (gas < precompile_gas) {
                    return CallResult{
                        .success = true,  // MODEXP returns success with empty output on OOG (EIP-198)
                        .gas_left = 0,
                        .output = &[_]u8{},
                    };
                }

                // For now, return zero result (proper implementation would do modular exponentiation)
                // Output should be mod_len bytes
                const output_len = @min(@as(usize, @intCast(mod_len)), 8192); // Cap at reasonable size
                const output = try self.arena.allocator().alloc(u8, output_len);
                @memset(output, 0);

                return CallResult{
                    .success = true,
                    .gas_left = gas - precompile_gas,
                    .output = output,
                };
            }

            // Precompile 0x09: BLAKE2F - available from Istanbul (EIP-152)
            if (addr_num == 9 and self.hardfork.isAtLeast(.ISTANBUL)) {
                // BLAKE2F compression function
                // Input must be exactly 213 bytes
                if (input.len != 213) {
                    // Invalid input - precompile fails
                    return CallResult{
                        .success = false,
                        .gas_left = 0,
                        .output = &[_]u8{},
                    };
                }

                // Parse rounds from first 4 bytes (big-endian)
                const rounds = std.mem.readInt(u32, input[0..4], .big);

                // Gas cost: 1 per round
                const precompile_gas = @as(u64, rounds);

                if (gas < precompile_gas) {
                    // Out of gas
                    return CallResult{
                        .success = false,
                        .gas_left = 0,
                        .output = &[_]u8{},
                    };
                }

                // Validate final block flag (last byte must be 0 or 1)
                const f = input[212];
                if (f != 0 and f != 1) {
                    // Invalid final block flag - precompile fails
                    return CallResult{
                        .success = false,
                        .gas_left = 0,
                        .output = &[_]u8{},
                    };
                }

                // Perform BLAKE2F compression
                var output_buf: [64]u8 = undefined;
                blake2.compress(input, &output_buf) catch {
                    // Compression failed - precompile fails
                    return CallResult{
                        .success = false,
                        .gas_left = 0,
                        .output = &[_]u8{},
                    };
                };

                // Copy output to arena
                const output = try self.arena.allocator().alloc(u8, 64);
                @memcpy(output, &output_buf);

                return CallResult{
                    .success = true,
                    .gas_left = gas - precompile_gas,
                    .output = output,
                };
            }

            // For other precompiles or empty accounts, return success with no output
            // TODO: Implement other precompiles
            // std.debug.print("DEBUG: Returning success for empty code (addr_num={})\n", .{addr_num});
            return CallResult{
                .success = true,
                .gas_left = gas,
                .output = &[_]u8{},
            };
        }

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
            // std.debug.print("CALL FAILED: execution error {} (addr={any})\n", .{err, address.bytes});
            _ = self.frames.pop();

            // Reverse value transfer on failure
            if (value > 0 and call_type == .Call) {
                if (self.host) |h| {
                    const caller_balance = h.getBalance(caller);
                    const callee_balance = h.getBalance(address);
                    h.setBalance(caller, caller_balance + value);
                    h.setBalance(address, callee_balance - value);
                } else {
                    const caller_balance = self.balances.get(caller) orelse 0;
                    const callee_balance = self.balances.get(address) orelse 0;
                    try self.balances.put(caller, caller_balance + value);
                    try self.balances.put(address, callee_balance - value);
                }
            }

            // Restore transient storage on failure (EIP-1153)
            self.transient_storage.clearRetainingCapacity();
            var restore_it = transient_snapshot.iterator();
            while (restore_it.next()) |entry| {
                try self.transient_storage.put(entry.key_ptr.*, entry.value_ptr.*);
            }

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
        // std.debug.print("DEBUG inner_call result: address={any} success={} reverted={} frames={}\n", .{address.bytes, result.success, frame.reverted, self.frames.items.len});

        // Restore transient storage on revert (EIP-1153)
        if (frame.reverted) {
            self.transient_storage.clearRetainingCapacity();
            var restore_it = transient_snapshot.iterator();
            while (restore_it.next()) |entry| {
                try self.transient_storage.put(entry.key_ptr.*, entry.value_ptr.*);
            }
        }

        // Reverse value transfer if call reverted
        if (frame.reverted and value > 0 and call_type == .Call) {
            // std.debug.print("REVERT: reversing transfer from={any} to={any} value={}\n", .{caller.bytes, address.bytes, value});
            if (self.host) |h| {
                const caller_balance = h.getBalance(caller);
                const callee_balance = h.getBalance(address);
                h.setBalance(caller, caller_balance + value);
                h.setBalance(address, callee_balance - value);
            } else {
                const caller_balance = self.balances.get(caller) orelse 0;
                const callee_balance = self.balances.get(address) orelse 0;
                try self.balances.put(caller, caller_balance + value);
                try self.balances.put(address, callee_balance - value);
            }
        }

        // if (frame.reverted) {
        //     std.debug.print("CALL FAILED: reverted (addr={any})\n", .{address.bytes});
        // }

        // Pop frame from stack
        _ = self.frames.pop();

        // std.debug.print("RETURN: addr={any} success={} gas_left={}\n", .{address.bytes, result.success, result.gas_left});
        // No cleanup needed - arena handles it
        return result;
    }

    /// Handle CREATE operation (contract creation)
    pub fn inner_create(
        self: *Self,
        value: u256,
        init_code: []const u8,
        gas: u64,
        salt: ?u256,
    ) errors.CallError!struct { address: Address, success: bool, gas_left: u64 } {
        // Check call depth
        if (self.frames.items.len >= 1024) {
            return .{
                .address = primitives.ZERO_ADDRESS,
                .success = false,
                .gas_left = 0,
            };
        }

        // EIP-3860: Check init code size limit (Shanghai and later)
        if (self.hardfork.isAtLeast(.SHANGHAI)) {
            if (init_code.len > GasConstants.MaxInitcodeSize) {
                return .{
                    .address = primitives.ZERO_ADDRESS,
                    .success = false,
                    .gas_left = gas,
                };
            }
        }

        // Get caller from current frame
        const caller = if (self.getCurrentFrame()) |frame| frame.address else self.origin;

        // Handle balance transfer if value > 0
        if (value > 0) {
            const caller_balance = if (self.host) |h| h.getBalance(caller) else self.balances.get(caller) orelse 0;
            if (caller_balance < value) {
                // Insufficient balance - CREATE fails
                return .{
                    .address = primitives.ZERO_ADDRESS,
                    .success = false,
                    .gas_left = gas,
                };
            }
            // Note: balance transfer happens after we know the new address
        }

        // Calculate new contract address
        const new_address = if (salt) |s| blk: {
            // CREATE2: keccak256(0xff ++ caller ++ salt ++ keccak256(init_code))[12:]
            var hash_input = std.ArrayList(u8){};
            defer hash_input.deinit(self.allocator);

            try hash_input.append(self.allocator, 0xff);
            try hash_input.appendSlice(self.allocator, &caller.bytes);

            // Add salt (32 bytes, big-endian)
            var salt_bytes: [32]u8 = undefined;
            var i: usize = 0;
            while (i < 32) : (i += 1) {
                salt_bytes[31 - i] = @as(u8, @truncate(s >> @intCast(i * 8)));
            }
            try hash_input.appendSlice(self.allocator, &salt_bytes);

            // Add keccak256(init_code)
            var code_hash: [32]u8 = undefined;
            std.crypto.hash.sha3.Keccak256.hash(init_code, &code_hash, .{});
            try hash_input.appendSlice(self.allocator, &code_hash);

            // Hash and take last 20 bytes
            var addr_hash: [32]u8 = undefined;
            std.crypto.hash.sha3.Keccak256.hash(hash_input.items, &addr_hash, .{});

            var addr_bytes: [20]u8 = undefined;
            @memcpy(&addr_bytes, addr_hash[12..32]);
            break :blk Address{ .bytes = addr_bytes };
        } else blk: {
            // CREATE: keccak256(rlp([sender, nonce]))[12:]
            // Get caller's nonce and increment it
            const nonce = if (self.host) |h|
                h.getNonce(caller)
            else
                self.nonces.get(caller) orelse 0;

            if (self.host) |h| {
                h.setNonce(caller, nonce + 1);
            } else {
                try self.nonces.put(caller, nonce + 1);
            }

            // Manually construct RLP encoding of [address_bytes, nonce]
            // Address is 20 bytes, nonce is variable length
            var rlp_data = std.ArrayList(u8){};
            defer rlp_data.deinit(self.allocator);

            // Encode address (20 bytes, 0x80 + 20 = 0x94)
            try rlp_data.append(self.allocator, 0x94);
            try rlp_data.appendSlice(self.allocator, &caller.bytes);

            // Encode nonce (RLP encoding for integers)
            if (nonce == 0) {
                try rlp_data.append(self.allocator, 0x80); // Empty byte string
            } else if (nonce < 0x80) {
                try rlp_data.append(self.allocator, @as(u8, @intCast(nonce)));
            } else {
                // Multi-byte nonce - encode as big-endian bytes with length prefix
                // First, determine the minimum number of bytes needed
                var nonce_bytes: [8]u8 = undefined;
                var nonce_len: usize = 0;
                var temp_nonce = nonce;

                // Convert to big-endian bytes, skipping leading zeros
                var i: usize = 8;
                while (i > 0) : (i -= 1) {
                    const byte = @as(u8, @truncate(temp_nonce & 0xFF));
                    nonce_bytes[i - 1] = byte;
                    temp_nonce >>= 8;
                    if (temp_nonce == 0 and nonce_len == 0) {
                        nonce_len = i;
                    }
                }

                const start_idx = nonce_len;
                const byte_count = 8 - start_idx;

                // RLP: 0x80 + length, then the bytes
                try rlp_data.append(self.allocator, @as(u8, @intCast(0x80 + byte_count)));
                try rlp_data.appendSlice(self.allocator, nonce_bytes[start_idx..]);
            }

            // Wrap in list prefix
            const total_len = rlp_data.items.len;
            var final_rlp = std.ArrayList(u8){};
            defer final_rlp.deinit(self.allocator);
            try final_rlp.append(self.allocator, @as(u8, @intCast(0xc0 + total_len))); // List with length
            try final_rlp.appendSlice(self.allocator, rlp_data.items);

            // Hash and take last 20 bytes
            var addr_hash: [32]u8 = undefined;
            std.crypto.hash.sha3.Keccak256.hash(final_rlp.items, &addr_hash, .{});

            var addr_bytes: [20]u8 = undefined;
            @memcpy(&addr_bytes, addr_hash[12..32]);
            break :blk Address{ .bytes = addr_bytes };
        };

        // Set nonce of new contract to 1 (EVM spec: contracts start with nonce 1)
        if (self.host) |h| {
            h.setNonce(new_address, 1);
        } else {
            try self.nonces.put(new_address, 1);
        }

        // Transfer balance if value > 0
        if (value > 0) {
            if (self.host) |h| {
                const caller_balance = h.getBalance(caller);
                h.setBalance(caller, caller_balance - value);
                const new_addr_balance = h.getBalance(new_address);
                h.setBalance(new_address, new_addr_balance + value);
            } else {
                const caller_balance = self.balances.get(caller) orelse 0;
                try self.balances.put(caller, caller_balance - value);
                const new_addr_balance = self.balances.get(new_address) orelse 0;
                try self.balances.put(new_address, new_addr_balance + value);
            }
        }

        // Execute initialization code
        try self.frames.append(self.arena.allocator(), try Frame.init(
            self.arena.allocator(),
            init_code,
            @intCast(gas),
            caller,
            new_address,
            value,
            &[_]u8{}, // no calldata for CREATE
            @as(*anyopaque, @ptrCast(self)),
            self.hardfork,
        ));
        errdefer _ = self.frames.pop();

        // Execute frame
        self.frames.items[self.frames.items.len - 1].execute() catch {
            _ = self.frames.pop();

            // Revert nonce on execution error
            if (self.host) |h| {
                h.setNonce(new_address, 0);
            } else {
                _ = self.nonces.remove(new_address);
            }

            // Reverse value transfer on error
            if (value > 0) {
                if (self.host) |h| {
                    const caller_balance = h.getBalance(caller);
                    const new_addr_balance = h.getBalance(new_address);
                    h.setBalance(caller, caller_balance + value);
                    h.setBalance(new_address, new_addr_balance - value);
                } else {
                    const caller_balance = self.balances.get(caller) orelse 0;
                    const new_addr_balance = self.balances.get(new_address) orelse 0;
                    try self.balances.put(caller, caller_balance + value);
                    try self.balances.put(new_address, new_addr_balance - value);
                }
            }

            return .{
                .address = primitives.ZERO_ADDRESS,
                .success = false,
                .gas_left = 0,
            };
        };

        // Get frame results
        const frame = &self.frames.items[self.frames.items.len - 1];
        var gas_left = @as(u64, @intCast(@max(frame.gas_remaining, 0)));
        var success = !frame.reverted;

        // If successful, check deposit cost and code size, then deploy
        if (success) {
            // Charge code deposit cost (200 gas per byte) if there's output
            if (frame.output.len > 0) {
                const deposit_cost = @as(u64, @intCast(frame.output.len)) * GasConstants.CreateDataGas;
                if (gas_left < deposit_cost) {
                    // Out of gas during code deposit -> creation fails
                    success = false;
                    gas_left = 0;
                }
            }

            if (success and frame.output.len > 0) {
                // Check code size limit (EIP-170: 24576 bytes)
                const max_code_size = 24576;
                if (frame.output.len > max_code_size) {
                    _ = self.frames.pop();

                    // Revert nonce on failure
                    if (self.host) |h| {
                        h.setNonce(new_address, 0);
                    } else {
                        _ = self.nonces.remove(new_address);
                    }

                    // Reverse value transfer on code size failure
                    if (value > 0) {
                        if (self.host) |h| {
                            const caller_balance = h.getBalance(caller);
                            const new_addr_balance = h.getBalance(new_address);
                            h.setBalance(caller, caller_balance + value);
                            h.setBalance(new_address, new_addr_balance - value);
                        } else {
                            const caller_balance = self.balances.get(caller) orelse 0;
                            const new_addr_balance = self.balances.get(new_address) orelse 0;
                            try self.balances.put(caller, caller_balance + value);
                            try self.balances.put(new_address, new_addr_balance - value);
                        }
                    }

                    return .{
                        .address = primitives.ZERO_ADDRESS,
                        .success = false,
                        .gas_left = gas_left,
                    };
                }

                // Deploy code and deduct deposit gas
                const code_copy = try self.arena.allocator().alloc(u8, frame.output.len);
                @memcpy(code_copy, frame.output);
                try self.code.put(new_address, code_copy);
                const deposit_cost = @as(u64, @intCast(frame.output.len)) * GasConstants.CreateDataGas;
                gas_left -= deposit_cost;
            } else if (success) {
                // Deploy empty code (output.len == 0)
                try self.code.put(new_address, &[_]u8{});
            }

            // Mark account as created in this transaction (EIP-6780) if successful
            if (success) {
                try self.created_accounts.put(new_address, {});
            }
        } else {
            // Reverse state changes on revert
            // Revert nonce to 0
            if (self.host) |h| {
                h.setNonce(new_address, 0);
            } else {
                _ = self.nonces.remove(new_address);
            }

            // Reverse value transfer
            if (value > 0) {
                if (self.host) |h| {
                    const caller_balance = h.getBalance(caller);
                    const new_addr_balance = h.getBalance(new_address);
                    h.setBalance(caller, caller_balance + value);
                    h.setBalance(new_address, new_addr_balance - value);
                } else {
                    const caller_balance = self.balances.get(caller) orelse 0;
                    const new_addr_balance = self.balances.get(new_address) orelse 0;
                    try self.balances.put(caller, caller_balance + value);
                    try self.balances.put(new_address, new_addr_balance - value);
                }
            }
        }

        // Pop frame
        _ = self.frames.pop();

        return .{
            .address = if (success) new_address else primitives.ZERO_ADDRESS,
            .success = success,
            .gas_left = gas_left,
        };
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
    /// EIP-7702: Handle delegation designation (0xef0100 + address)
    pub fn get_code(self: *Self, address: Address) []const u8 {
        const raw_code = if (self.host) |h|
            h.getCode(address)
        else
            self.code.get(address) orelse &[_]u8{};

        // EIP-7702: Check for delegation designation (Prague+)
        if (self.hardfork.isAtLeast(.PRAGUE) and raw_code.len == 23 and
            raw_code[0] == 0xef and raw_code[1] == 0x01 and raw_code[2] == 0x00)
        {
            // Extract delegated address (bytes 3-22, 20 bytes)
            var delegated_addr: Address = undefined;
            @memcpy(&delegated_addr.bytes, raw_code[3..23]);

            // Recursively get code from delegated address
            // Note: We don't recurse infinitely - if delegated address also has
            // delegation designation, we return its delegation code as-is
            const delegated_code = if (self.host) |h|
                h.getCode(delegated_addr)
            else
                self.code.get(delegated_addr) orelse &[_]u8{};

            return delegated_code;
        }

        return raw_code;
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
        const key = StorageSlotKey{ .address = address, .slot = slot };

        // Track original value on first write in transaction
        if (!self.original_storage.contains(key)) {
            const current = if (self.host) |h|
                h.getStorage(address, slot)
            else
                self.storage.get(key) orelse 0;
            try self.original_storage.put(key, current);
        }

        if (self.host) |h| {
            h.setStorage(address, slot, value);
            return;
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
        // Use host if available
        if (self.host) |h| {
            return h.getStorage(address, slot);
        }
        return self.storage.get(key) orelse 0;
    }

    /// Get transient storage value (EIP-1153)
    pub fn get_transient_storage(self: *Self, address: Address, slot: u256) u256 {
        const key = StorageSlotKey{ .address = address, .slot = slot };
        return self.transient_storage.get(key) orelse 0;
    }

    /// Set transient storage value (EIP-1153)
    pub fn set_transient_storage(self: *Self, address: Address, slot: u256, value: u256) !void {
        const key = StorageSlotKey{ .address = address, .slot = slot };
        if (value == 0) {
            _ = self.transient_storage.remove(key);
        } else {
            try self.transient_storage.put(key, value);
        }
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
