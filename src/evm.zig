/// EVM implementation for tracing and validation
/// This is a simplified, unoptimized EVM that orchestrates execution.
/// Architecture mirrors evm.zig - Evm orchestrates, Frame executes
const std = @import("std");
const log = @import("logger.zig");
const primitives = @import("primitives");
const GasConstants = primitives.GasConstants;
const Frame = @import("frame.zig").Frame;
const Hardfork = @import("hardfork.zig").Hardfork;
const host = @import("host.zig");
const errors = @import("errors.zig");
const trace = @import("trace.zig");
const blake2 = @import("blake2.zig");
const precompiles = @import("precompiles/precompiles.zig");
const evm_config = @import("evm_config.zig");
const EvmConfig = evm_config.EvmConfig;
const storage_injector = @import("storage_injector.zig");
const StorageInjector = storage_injector.StorageInjector;

const Address = primitives.Address.Address;

// Re-export host types for compatibility
pub const HostInterface = host.HostInterface;
pub const Host = host.Host;

// Re-export config
pub const Config = EvmConfig;

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

/// Async data request - written by get_storage/get_balance/etc when cache miss
/// Read by executeUntilYieldOrComplete to build the return value
pub const AsyncDataRequest = union(enum) {
    none: void,
    storage: struct {
        address: Address,
        slot: u256,
    },
    balance: struct {
        address: Address,
    },
    code: struct {
        address: Address,
    },
    nonce: struct {
        address: Address,
    },
};

pub const BlockContext = struct {
    chain_id: u256,
    block_number: u64,
    block_timestamp: u64,
    block_difficulty: u256,
    block_prevrandao: u256,
    block_coinbase: Address,
    block_gas_limit: u64,
    block_base_fee: u256,
    blob_base_fee: u256,
};

/// Creates a configured EVM instance type.
pub fn Evm(config: EvmConfig) type {
    // Import new API types with config
    const call_params = @import("call_params.zig");
    const call_result = @import("call_result.zig");

    return struct {
        const Self = @This();

        pub const CallParams = call_params.CallParams(config);
        pub const CallResult = call_result.CallResult(config);

        /// Input to callOrContinue - tagged union for starting or continuing execution
        pub const CallOrContinueInput = union(enum) {
            call: CallParams,
            continue_with_storage: struct {
                address: Address,
                slot: u256,
                value: u256,
            },
            continue_with_balance: struct {
                address: Address,
                balance: u256,
            },
            continue_with_code: struct {
                address: Address,
                code: []const u8,
            },
            continue_with_nonce: struct {
                address: Address,
                nonce: u64,
            },
            continue_after_commit: void,
        };

        /// Output from callOrContinue - tagged union for result or async request
        pub const CallOrContinueOutput = union(enum) {
            result: CallResult,
            need_storage: struct {
                address: Address,
                slot: u256,
            },
            need_balance: struct {
                address: Address,
            },
            need_code: struct {
                address: Address,
            },
            need_nonce: struct {
                address: Address,
            },
            ready_to_commit: struct {
                changes_json: []const u8,
            },
        };

    frames: std.ArrayList(Frame),
    storage: std.AutoHashMap(StorageSlotKey, u256),
    original_storage: std.AutoHashMap(StorageSlotKey, u256),
    transient_storage: std.AutoHashMap(StorageSlotKey, u256),
    created_accounts: std.AutoHashMap(Address, void),
    selfdestructed_accounts: std.AutoHashMap(Address, void),  // EIP-6780: Track accounts marked for deletion
    touched_accounts: std.AutoHashMap(Address, void),  // Pre-Paris: Track touched accounts for deletion if empty
    balances: std.AutoHashMap(Address, u256),
    nonces: std.AutoHashMap(Address, u64),
    code: std.AutoHashMap(Address, []const u8),
    warm_addresses: std.array_hash_map.ArrayHashMap(Address, void, AddressContext, false),
    warm_storage_slots: std.array_hash_map.ArrayHashMap(StorageSlotKey, void, StorageSlotKeyContext, false),
    gas_refund: u64,
    // Stack of balance snapshots for nested calls (for SELFDESTRUCT revert handling)
    // Each call pushes a snapshot, and on revert we restore from that snapshot
    balance_snapshot_stack: std.ArrayList(*std.AutoHashMap(Address, u256)),
    hardfork: Hardfork = Hardfork.DEFAULT,
    fork_transition: ?@import("hardfork.zig").ForkTransition = null,
    origin: Address,
    gas_price: u256,
    host: ?HostInterface,
    arena: std.heap.ArenaAllocator,
    allocator: std.mem.Allocator,
    tracer: ?*trace.Tracer = null,
    block_context: BlockContext,
    blob_versioned_hashes: []const [32]u8 = &[_][32]u8{},
    // Stored state for call() - set via setter methods
    pending_bytecode: []const u8 = &[_]u8{},
    pending_access_list: ?AccessListParam = null,

    // Config-provided overrides (comptime known)
    opcode_overrides: []const evm_config.OpcodeOverride,
    precompile_overrides: []const evm_config.PrecompileOverride,

    // Async storage injection
    async_data_request: AsyncDataRequest = .none,
    storage_injector: ?*StorageInjector = null,
    // Buffer for state changes JSON (persists across yields)
    pending_state_changes_buffer: [16384]u8 = undefined,
    pending_state_changes_len: usize = 0,

    /// Initialize a new EVM instance
    /// Config provides defaults, but hardfork can be overridden at runtime
    pub fn init(allocator: std.mem.Allocator, h: ?HostInterface, hardfork: ?Hardfork, block_context: ?BlockContext, log_level: ?log.LogLevel) !Self {
        // Set log level if provided
        if (log_level) |level| {
            log.setLogLevel(level);
        }

        return Self{
            .frames = undefined,
            .storage = undefined,
            .original_storage = undefined,
            .transient_storage = undefined,
            .created_accounts = undefined,
            .selfdestructed_accounts = undefined,
            .touched_accounts = undefined,
            .balances = undefined,
            .nonces = undefined,
            .code = undefined,
            .warm_addresses = undefined,
            .warm_storage_slots = undefined,
            .gas_refund = 0,
            .balance_snapshot_stack = undefined,
            .hardfork = hardfork orelse Hardfork.DEFAULT,
            .block_context = block_context orelse .{
                .chain_id = 1,
                .block_number = 0,
                .block_timestamp = 0,
                .block_difficulty = 0,
                .block_prevrandao = 0,
                .block_coinbase = primitives.ZERO_ADDRESS,
                .block_gas_limit = config.block_gas_limit,
                .block_base_fee = 0,
                .blob_base_fee = 0,
            },
            .origin = primitives.ZERO_ADDRESS,
            .gas_price = 0,
            .host = h,
            .arena = std.heap.ArenaAllocator.init(allocator),
            .allocator = allocator,
            .tracer = null,
            .opcode_overrides = config.opcode_overrides,
            .precompile_overrides = config.precompile_overrides,
        };
    }

    /// Look up custom opcode handler override
    /// Returns null if no override exists for this opcode
    pub fn getOpcodeOverride(self: *const Self, opcode: u8) ?*const anyopaque {
        for (self.opcode_overrides) |override| {
            if (override.opcode == opcode) {
                return override.handler;
            }
        }
        return null;
    }

    /// Look up custom precompile override
    /// Returns null if no override exists for this address
    pub fn getPrecompileOverride(self: *const Self, address: Address) ?*const evm_config.PrecompileOverride {
        for (self.precompile_overrides) |*override| {
            if (override.address.equals(address)) {
                return override;
            }
        }
        return null;
    }

    /// Clean up resources
    pub fn deinit(self: *Self) void {
        self.arena.deinit();
    }

    /// Get the active fork based on block context (handles fork transitions)
    pub fn getActiveFork(self: *const Self) Hardfork {
        if (self.fork_transition) |transition| {
            return transition.getActiveFork(self.block_context.block_number, self.block_context.block_timestamp);
        }
        return self.hardfork;
    }

    /// Initialize internal state (hash maps, lists, etc.) for transaction execution
    /// Must be called before any transaction execution (call or inner_create)
    pub fn initTransactionState(self: *Self, blob_versioned_hashes: ?[]const [32]u8) !void {
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
        self.selfdestructed_accounts = std.AutoHashMap(Address, void).init(arena_allocator);
        self.touched_accounts = std.AutoHashMap(Address, void).init(arena_allocator);
        self.balance_snapshot_stack = std.ArrayList(*std.AutoHashMap(Address, u256)){};

        // Set blob versioned hashes for EIP-4844
        // CRITICAL: Must copy blob hashes into arena to ensure correct lifetime
        // The caller may free the hashes after passing them to us, so we need our own copy
        if (blob_versioned_hashes) |hashes| {
            // Allocate space in arena for blob hashes
            const hashes_copy = try arena_allocator.alloc([32]u8, hashes.len);
            // Copy each hash
            for (hashes, 0..) |hash, i| {
                hashes_copy[i] = hash;
            }
            self.blob_versioned_hashes = hashes_copy;
        } else {
            self.blob_versioned_hashes = &[_][32]u8{};
        }
    }

    /// Set tracer for EIP-3155 trace capture
    pub fn setTracer(self: *Self, tracer: *trace.Tracer) void {
        self.tracer = tracer;
    }

    pub fn accessAddress(self: *Self, address: Address) !u64 {
        if (self.hardfork.isBefore(.BERLIN)) {
            @branchHint(.cold);
            // Pre-Berlin: No warm/cold access costs (EIP-2929 introduced in Berlin)
            // The base call cost is already charged in the CALL opcode
            return 0;
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
            // EIP-1884 (Istanbul): SLOAD increased from 200 to 800 gas
            if (self.hardfork.isAtLeast(.ISTANBUL)) {
                return 800;
            } else {
                return 200;
            }
        }

        const key = StorageSlotKey{ .address = contract_address, .slot = slot };
        const entry = try self.warm_storage_slots.getOrPut(key);
        return if (entry.found_existing)
            GasConstants.WarmStorageReadCost
        else
            GasConstants.ColdSloadCost;
    }

    /// Set balance with copy-on-write snapshot for revert handling
    /// This should be called instead of direct host.setBalance() when inside a frame
    /// IMPORTANT: Snapshots the balance in ALL active snapshots on the stack, not just the current one.
    /// This ensures that parent frames can restore state when they revert, even if the balance
    /// was modified in a nested call.
    pub fn setBalanceWithSnapshot(self: *Self, addr: Address, new_balance: u256) !void {
        // Snapshot in ALL active snapshots (from outermost to innermost)
        // This ensures parent frames can restore state even if modified in nested calls
        for (self.balance_snapshot_stack.items) |snapshot| {
            if (!snapshot.contains(addr)) {
                // Snapshot the current balance before modifying
                const current_balance = if (self.host) |h|
                    h.getBalance(addr)
                else
                    self.balances.get(addr) orelse 0;
                try snapshot.put(addr, current_balance);
            }
        }

        // Now set the new balance
        if (self.host) |h| {
            h.setBalance(addr, new_balance);
        } else {
            try self.balances.put(addr, new_balance);
        }
    }

    /// Pre-warm addresses for transaction initialization
    fn preWarmAddresses(self: *Self, addresses: []const Address) !void {
        for (addresses) |addr| {
            _ = self.warm_addresses.getOrPut(addr) catch {
                return errors.CallError.StorageError;
            };
        }
    }

    /// Get nonce for an address
    fn getNonce(self: *Self, address: Address) u64 {
        if (self.host) |h| {
            return h.getNonce(address);
        }
        return self.nonces.get(address) orelse 0;
    }

    /// Compute CREATE address: keccak256(rlp([sender, nonce]))[12:]
    fn computeCreateAddress(self: *Self, sender: Address, nonce: u64) !Address {
        _ = self;
        // RLP encoding of [sender (20 bytes), nonce]
        // For simplicity, use a fixed buffer (max size for nonce encoding is small)
        var buffer: [64]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buffer);
        const writer = fbs.writer();

        // Calculate nonce encoding length
        const nonce_len: usize = blk: {
            if (nonce == 0) break :blk 1;
            if (nonce < 128) break :blk 1;
            var n = nonce;
            var len: usize = 0;
            while (n > 0) : (n >>= 8) {
                len += 1;
            }
            break :blk len + 1; // +1 for length prefix
        };

        // RLP list prefix
        const list_len = 21 + nonce_len;
        try writer.writeByte(0xc0 + @as(u8, @intCast(list_len)));

        // RLP encode sender address (20 bytes, so 0x80 + 20 = 0x94)
        try writer.writeByte(0x94);
        try writer.writeAll(&sender.bytes);

        // RLP encode nonce
        if (nonce == 0) {
            try writer.writeByte(0x80);
        } else if (nonce < 128) {
            try writer.writeByte(@intCast(nonce));
        } else {
            var nonce_bytes: [8]u8 = undefined;
            std.mem.writeInt(u64, &nonce_bytes, nonce, .big);
            var start: usize = 0;
            while (start < 8 and nonce_bytes[start] == 0) : (start += 1) {}
            const nonce_byte_len = 8 - start;
            try writer.writeByte(0x80 + @as(u8, @intCast(nonce_byte_len)));
            try writer.writeAll(nonce_bytes[start..]);
        }

        const rlp_data = fbs.getWritten();

        // Compute keccak256 hash
        var hash: [32]u8 = undefined;
        std.crypto.hash.sha3.Keccak256.hash(rlp_data, &hash, .{});

        // Take last 20 bytes as address
        var addr: Address = undefined;
        @memcpy(&addr.bytes, hash[12..32]);
        return addr;
    }

    /// Compute CREATE2 address: keccak256(0xff ++ sender ++ salt ++ keccak256(init_code))[12:]
    fn computeCreate2Address(self: *Self, sender: Address, salt: u256, init_code: []const u8) !Address {
        _ = self;
        // Compute keccak256(init_code)
        var init_code_hash: [32]u8 = undefined;
        std.crypto.hash.sha3.Keccak256.hash(init_code, &init_code_hash, .{});

        // Compute keccak256(0xff ++ sender ++ salt ++ init_code_hash)
        var buffer: [85]u8 = undefined; // 1 + 20 + 32 + 32
        buffer[0] = 0xff;
        @memcpy(buffer[1..21], &sender.bytes);

        // Convert salt to bytes (big-endian)
        var salt_bytes: [32]u8 = undefined;
        std.mem.writeInt(u256, &salt_bytes, salt, .big);
        @memcpy(buffer[21..53], &salt_bytes);

        @memcpy(buffer[53..85], &init_code_hash);

        var hash: [32]u8 = undefined;
        std.crypto.hash.sha3.Keccak256.hash(&buffer, &hash, .{});

        // Take last 20 bytes as address
        var addr: Address = undefined;
        @memcpy(&addr.bytes, hash[12..32]);
        return addr;
    }

    pub fn preWarmTransaction(self: *Self, target: Address) errors.CallError!void {
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
        // EIP-2929: Precompiles are always warm at transaction start
        if (!self.hardfork.isAtLeast(.BERLIN)) return;

        // Determine number of precompiles based on hardfork
        // Berlin-Istanbul: 0x01-0x09 (9 precompiles: ECRECOVER through BLAKE2F)
        // Cancun+: 0x01-0x0A (10 precompiles, added KZG point evaluation at 0x0A via EIP-4844)
        // Prague+: 0x01-0x12 (19 precompiles, added BLS12-381 operations at 0x0B-0x12 via EIP-2537)
        const precompile_count: usize = if (self.hardfork.isAtLeast(.PRAGUE))
            0x12 // Prague: All precompiles including BLS12-381
        else if (self.hardfork.isAtLeast(.CANCUN))
            0x0A // Cancun: Includes KZG point evaluation
        else
            0x09; // Berlin-Istanbul: Up to BLAKE2F

        var precompile_addrs: [0x12]Address = undefined;
        var i: usize = 0;
        while (i < precompile_count) : (i += 1) {
            precompile_addrs[i] = Address.from_u256(i + 1);
        }
        try self.preWarmAddresses(precompile_addrs[0..precompile_count]);
    }

    /// Set bytecode for the next call() invocation
    pub fn setBytecode(self: *Self, bytecode: []const u8) void {
        self.pending_bytecode = bytecode;
    }

    /// Set access list for the next call() invocation
    pub fn setAccessList(self: *Self, access_list: ?AccessListParam) void {
        self.pending_access_list = access_list;
    }

    /// Set blob versioned hashes for the next call() invocation
    pub fn setBlobVersionedHashes(self: *Self, hashes: []const [32]u8) void {
        self.blob_versioned_hashes = hashes;
    }

    /// Execute bytecode (main entry point like evm.execute)
    pub fn call(
        self: *Self,
        params: CallParams,
    ) CallResult {
        // Helper to return failure - if allocation fails, return static failure
        const makeFailure = struct {
            fn call(allocator: std.mem.Allocator, gas_left: u64) CallResult {
                return CallResult.failure(allocator, gas_left) catch CallResult{
                    .success = false,
                    .gas_left = gas_left,
                    .output = &.{},
                };
            }
        }.call;

        // Validate parameters
        params.validate() catch {
            return makeFailure(self.arena.allocator(), 0);
        };

        // Extract common parameters
        const caller = params.getCaller();
        const gas = @as(i64, @intCast(params.getGas()));
        const is_create = params.isCreate();

        // Determine target address and value
        const address: Address = if (is_create) blk: {
            // For CREATE operations, compute the new contract address
            if (params == .create2) {
                // CREATE2: address = keccak256(0xff ++ caller ++ salt ++ keccak256(init_code))[12:]
                const init_code = params.getInput();
                const salt = params.create2.salt;
                break :blk self.computeCreate2Address(caller, salt, init_code) catch {
                    return makeFailure(self.arena.allocator(), 0);
                };
            } else {
                // CREATE: address = keccak256(rlp([caller, nonce]))[12:]
                const nonce = self.getNonce(caller);
                break :blk self.computeCreateAddress(caller, nonce) catch {
                    return makeFailure(self.arena.allocator(), 0);
                };
            }
        } else params.get_to().?;

        const value = switch (params) {
            .call => |p| p.value,
            .callcode => |p| p.value,
            .create => |p| p.value,
            .create2 => |p| p.value,
            .delegatecall, .staticcall => 0,
        };

        const calldata = params.getInput();
        const bytecode = self.pending_bytecode;
        const blob_versioned_hashes = if (self.blob_versioned_hashes.len > 0) self.blob_versioned_hashes else null;
        const access_list = self.pending_access_list;

        // Initialize transaction state
        self.initTransactionState(blob_versioned_hashes) catch {
            return makeFailure(self.arena.allocator(), 0);
        };

        self.preWarmTransaction(address) catch {
            return makeFailure(self.arena.allocator(), 0);
        };

        // Pre-warm access list (EIP-2929)
        if (access_list) |list| {
            // Pre-warm all addresses in access list
            for (list.addresses) |addr| {
                _ = self.warm_addresses.getOrPut(addr) catch {
                    return makeFailure(self.arena.allocator(), 0);
                };
            }

            // Pre-warm all storage keys in access list
            for (list.storage_keys) |entry| {
                const key = StorageSlotKey{
                    .address = entry.address,
                    .slot = entry.slot,
                };
                _ = self.warm_storage_slots.getOrPut(key) catch {
                    return makeFailure(self.arena.allocator(), 0);
                };

                // If using storage injector, mark slot as warm but we still need to fetch value
                // The slot is marked warm for gas accounting, but value fetching happens lazily
                // when get_storage() is first called on this slot
            }
        }

        // Transfer value from caller to recipient (if value > 0)
        if (value > 0 and self.host != null) {
            const sender_balance = if (self.host) |h| h.getBalance(caller) else 0;
            if (sender_balance < value) {
                return makeFailure(self.arena.allocator(), 0);
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

        // Create and push frame onto stack
        self.frames.append(self.arena.allocator(), Frame.init(
            self.arena.allocator(),
            bytecode,
            gas,
            caller,
            address,
            value,
            calldata,
            @as(*anyopaque, @ptrCast(self)),
            self.hardfork,
            false, // Top-level transaction is never static
        ) catch {
            return makeFailure(self.arena.allocator(), 0);
        }) catch {
            return makeFailure(self.arena.allocator(), 0);
        };
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
            return makeFailure(self.arena.allocator(), 0);
        };

        // Get frame results (refetch pointer after execution)
        const frame = &self.frames.items[self.frames.items.len - 1];
        const output = self.arena.allocator().alloc(u8, frame.output.len) catch {
            return makeFailure(self.arena.allocator(), 0);
        };
        @memcpy(output, frame.output);

        const gas_left = @as(u64, @intCast(@max(frame.gas_remaining, 0)));
        // Note: Gas refunds are NOT applied here. They should be applied by the caller
        // (test runner) after calculating coinbase payment based on gas actually consumed.
        // The refund counter is NOT reset here - caller needs access to it.

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
        var result = if (frame.reverted)
            CallResult.revert_with_data(self.arena.allocator(), gas_left, output) catch unreachable
        else
            CallResult.success_with_output(self.arena.allocator(), gas_left, output) catch unreachable;

        // Set created address for CREATE operations
        if (is_create and !frame.reverted) {
            result.created_address = address;
        }

        // Reset transaction-scoped caches
        self.warm_addresses.clearRetainingCapacity();
        self.warm_storage_slots.clearRetainingCapacity();

        // Clear transient storage at end of transaction (EIP-1153)
        self.transient_storage.clearRetainingCapacity();

        // Delete selfdestructed accounts at end of transaction (EIP-6780)
        // This must happen AFTER transient storage is cleared since transient storage
        // should be accessible during the transaction even after SELFDESTRUCT
        var selfdestruct_it = self.selfdestructed_accounts.iterator();
        while (selfdestruct_it.next()) |entry| {
            const addr = entry.key_ptr.*;
            if (self.host) |h| {
                // Clear all account state: balance (should already be 0), code, nonce, and storage
                h.setBalance(addr, 0);
                h.setCode(addr, &[_]u8{});
                h.setNonce(addr, 0);

                // Clear permanent storage for self-destructed account
                // Per Python reference: destroy_account calls destroy_storage
                // We need to iterate and clear all storage slots for this address
                var storage_it = self.storage.iterator();
                while (storage_it.next()) |storage_entry| {
                    const key = storage_entry.key_ptr.*;
                    if (std.mem.eql(u8, &key.address.bytes, &addr.bytes)) {
                        h.setStorage(addr, key.slot, 0);
                    }
                }
            } else {
                // Clear all account state in EVM storage
                // Note: In non-host mode, we use arena allocation so memory will be reclaimed
                // when the arena is freed. We simply remove storage entries rather than trying to update them.
                // Clear permanent storage for self-destructed account
                // Per Python reference: destroy_account calls destroy_storage
                var storage_it = self.storage.iterator();
                while (storage_it.next()) |storage_entry| {
                    const key = storage_entry.key_ptr.*;
                    if (std.mem.eql(u8, &key.address.bytes, &addr.bytes)) {
                        _ = self.storage.fetchRemove(key);
                    }
                }
                // Also clear from original_storage
                var original_storage_it = self.original_storage.iterator();
                while (original_storage_it.next()) |storage_entry| {
                    const key = storage_entry.key_ptr.*;
                    if (std.mem.eql(u8, &key.address.bytes, &addr.bytes)) {
                        _ = self.original_storage.fetchRemove(key);
                    }
                }
                // Clear account state by removing from maps
                _ = self.balances.fetchRemove(addr);
                _ = self.code.fetchRemove(addr);
                _ = self.nonces.fetchRemove(addr);
            }
        }

        // Clear transaction-scoped sets at end of transaction
        // These must be cleared to avoid incorrectly treating accounts as created/selfdestructed
        // in subsequent transactions within the same block
        self.created_accounts.clearRetainingCapacity();
        self.selfdestructed_accounts.clearRetainingCapacity();

        // No cleanup needed - arena handles it
        return result;
    }

    /// Main async execution method - supports yielding for async requests
    /// CRITICAL: NO defer statements that clean up state!
    /// This wraps call() but supports yielding for async data requests
    pub fn callOrContinue(
        self: *Self,
        input: CallOrContinueInput,
    ) !CallOrContinueOutput {
        switch (input) {
            .call => |params| {
                // Start new call - set up state
                try self.initTransactionState(null);

                if (self.storage_injector) |injector| {
                    log.debug("callOrContinue: Storage injector enabled, clearing cache", .{});
                    injector.clearCache();
                } else {
                    log.debug("callOrContinue: No storage injector", .{});
                }

                // Extract common parameters (same as call() method)
                const caller = params.getCaller();
                const gas = @as(i64, @intCast(params.getGas()));
                const is_create = params.isCreate();

                // Determine target address and value
                const address: Address = if (is_create) blk: {
                    if (params == .create2) {
                        const init_code = params.getInput();
                        const salt = params.create2.salt;
                        break :blk try self.computeCreate2Address(caller, salt, init_code);
                    } else {
                        const nonce = self.getNonce(caller);
                        break :blk try self.computeCreateAddress(caller, nonce);
                    }
                } else params.get_to().?;

                const value = switch (params) {
                    .call => |p| p.value,
                    .callcode => |p| p.value,
                    .create => |p| p.value,
                    .create2 => |p| p.value,
                    .delegatecall, .staticcall => 0,
                };

                const calldata = params.getInput();
                const bytecode = self.pending_bytecode;

                try self.preWarmTransaction(address);

                // Pre-warm access list if present
                if (self.pending_access_list) |list| {
                    for (list.addresses) |addr| {
                        _ = try self.warm_addresses.getOrPut(addr);
                    }
                    for (list.storage_keys) |entry| {
                        const key = StorageSlotKey{
                            .address = entry.address,
                            .slot = entry.slot,
                        };
                        _ = try self.warm_storage_slots.getOrPut(key);
                    }
                }

                // Transfer value if needed
                if (value > 0 and self.host != null) {
                    const sender_balance = if (self.host) |h| h.getBalance(caller) else 0;
                    if (sender_balance < value) {
                        return error.InsufficientBalance;
                    }
                    if (self.host) |h| {
                        h.setBalance(caller, sender_balance - value);
                        const recipient_balance = h.getBalance(address);
                        h.setBalance(address, recipient_balance + value);
                    }
                }

                // Create frame WITHOUT defer (critical!)
                log.debug("callOrContinue: Creating frame with address={any}", .{address.bytes});
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
                    false, // Top-level is never static
                ));

                // Execute (may yield)
                return try self.executeUntilYieldOrComplete();
            },

            .continue_with_storage => |data| {
                const key = StorageSlotKey{
                    .address = data.address,
                    .slot = data.slot,
                };

                // Store value in both cache and storage
                if (self.storage_injector) |injector| {
                    _ = try injector.storage_cache.put(key, data.value);
                }

                // Also put in self.storage so get_storage can find it
                try self.storage.put(key, data.value);

                // Clear the request
                self.async_data_request = .none;

                // Continue execution
                return try self.executeUntilYieldOrComplete();
            },

            .continue_with_balance => |data| {
                if (self.storage_injector) |injector| {
                    try injector.balance_cache.put(data.address, data.balance);
                }

                // Clear the request
                self.async_data_request = .none;

                return try self.executeUntilYieldOrComplete();
            },

            .continue_after_commit => {
                // Commit done - finalize and return result
                return try self.finalizeAndReturnResult();
            },

            else => return error.UnsupportedContinueType,
        }
    }

    /// Execute until we hit a yield point or complete
    /// NO defer statements!
    fn executeUntilYieldOrComplete(self: *Self) !CallOrContinueOutput {
        while (self.frames.items.len > 0) {
            const frame = &self.frames.items[self.frames.items.len - 1];

            // Execute frame - may return error.NeedAsyncData
            frame.execute() catch |err| {
                if (err == error.NeedAsyncData) {
                    // Read the request from evm.async_data_request
                    return switch (self.async_data_request) {
                        .storage => |req| .{ .need_storage = .{
                            .address = req.address,
                            .slot = req.slot,
                        } },
                        .balance => |req| .{ .need_balance = .{ .address = req.address } },
                        .code => |req| .{ .need_code = .{ .address = req.address } },
                        .nonce => |req| .{ .need_nonce = .{ .address = req.address } },
                        .none => error.InvalidAsyncState,
                    };
                }

                // Real error - return it (state preserved for debugging)
                return err;
            };

            // Frame completed successfully
            // Check if this is the last frame AND we have storage injector
            if (self.frames.items.len == 1 and self.storage_injector != null) {
                log.debug("executeUntilYieldOrComplete: Last frame, dumping changes", .{});
                // Don't pop yet - need to dump changes first
                const changes_json = try self.dumpStateChanges();
                log.debug("executeUntilYieldOrComplete: changes_json.len = {}", .{changes_json.len});
                return .{ .ready_to_commit = .{ .changes_json = changes_json } };
            }

            // Pop frame (safe - not returning early)
            _ = self.frames.pop();
        }

        // All frames complete, no storage injector
        return try self.finalizeAndReturnResult();
    }

    /// Finalize execution and return result
    /// Called only when we're truly done (after commit if needed)
    fn finalizeAndReturnResult(self: *Self) !CallOrContinueOutput {
        // At this point frames should be empty OR we have one frame to finalize
        if (self.frames.items.len > 0) {
            const frame = self.frames.items[self.frames.items.len - 1];
            const output = try self.arena.allocator().dupe(u8, frame.output);
            const gas_left = @as(u64, @intCast(@max(frame.gas_remaining, 0)));
            const success = !frame.reverted;

            // NOW we can pop (we're returning the final result)
            _ = self.frames.pop();

            // Clean up transaction state (safe now)
            self.warm_addresses.clearRetainingCapacity();
            self.warm_storage_slots.clearRetainingCapacity();
            self.transient_storage.clearRetainingCapacity();

            return .{ .result = CallResult{
                .success = success,
                .gas_left = gas_left,
                .output = output,
            } };
        }

        return .{ .result = CallResult{
            .success = true,
            .gas_left = 0,
            .output = &.{},
        } };
    }

    /// Dump state changes to JSON
    fn dumpStateChanges(self: *Self) ![]const u8 {
        if (self.storage_injector) |injector| {
            const result = try injector.dumpChanges(self);
            log.debug("dumpStateChanges: Got {} bytes from injector", .{result.len});
            // Copy to persistent buffer in Evm struct
            const copy_len = @min(result.len, self.pending_state_changes_buffer.len);
            if (copy_len > 0) {
                @memcpy(self.pending_state_changes_buffer[0..copy_len], result[0..copy_len]);
            }
            self.pending_state_changes_len = copy_len;
            return self.pending_state_changes_buffer[0..copy_len];
        }
        log.debug("dumpStateChanges: No injector, returning empty", .{});
        self.pending_state_changes_len = 0;
        return &.{};
    }

    /// Handle inner call from frame (like evm.inner_call)
    /// Execute a nested EVM call - used for calls from within the EVM (e.g., CALL, DELEGATECALL opcodes).
    /// This handles nested calls and manages depth tracking.
    /// Follows the same API pattern as guillotine performance EVM.
    pub fn inner_call(
        self: *Self,
        params: CallParams,
    ) CallResult {
        // Helper to return failure - if allocation fails, return static failure
        const makeFailure = struct {
            fn call(allocator: std.mem.Allocator, gas_left: u64) CallResult {
                return CallResult.failure(allocator, gas_left) catch CallResult{
                    .success = false,
                    .gas_left = gas_left,
                    .output = &.{},
                };
            }
        }.call;
        // Extract parameters from CallParams union
        const address: Address = switch (params) {
            .call => |p| p.to,
            .callcode => |p| p.to,
            .delegatecall => |p| p.to,
            .staticcall => |p| p.to,
            .create => unreachable, // CREATE should use inner_create
            .create2 => unreachable, // CREATE2 should use inner_create
        };

        const value: u256 = if (params.hasValue()) switch (params) {
            .call => |p| p.value,
            .callcode => |p| p.value,
            else => 0,
        } else 0;

        const input: []const u8 = params.getInput();
        const gas: u64 = params.getGas();

        // Determine call type
        const call_type: enum { Call, CallCode, DelegateCall, StaticCall } = switch (params) {
            .call => .Call,
            .callcode => .CallCode,
            .delegatecall => .DelegateCall,
            .staticcall => .StaticCall,
            else => unreachable,
        };
        // Check call depth (STACK_DEPTH_LIMIT = 1024)
        // Per Python reference (system.py:297-300), depth exceeded refunds gas
        if (self.frames.items.len >= 1024) {
            return makeFailure(self.arena.allocator(), gas);
        }

        // Get caller and execution context address based on call type
        // For CALL: caller = current frame's address, execution address = target address
        // For DELEGATECALL: caller = current frame's caller, execution address = current frame's address (code from target)
        // For CALLCODE: caller = current frame's address, execution address = current frame's address (code from target)
        // For STATICCALL: same as CALL but with static mode
        const current_frame = self.getCurrentFrame();
        const frame_caller = if (current_frame) |frame| frame.address else self.origin;
        const frame_caller_caller = if (current_frame) |frame| frame.caller else self.origin;

        // Snapshot gas refunds before the call
        // Per Python reference (vm/__init__.py:incorporate_child_on_error), failed calls do not
        // propagate refunds to parent. Only incorporate_child_on_success adds child refunds.
        const refund_snapshot = self.gas_refund;

        // Snapshot transient storage before the call (EIP-1153)
        // Transient storage must be reverted on call failure
        var transient_snapshot = std.AutoHashMap(StorageSlotKey, u256).init(self.arena.allocator());
        var it = self.transient_storage.iterator();
        while (it.next()) |entry| {
            transient_snapshot.put(entry.key_ptr.*, entry.value_ptr.*) catch {
                // Memory allocation failed during snapshot - fail the call
                return makeFailure(self.arena.allocator(), gas);
            };
        }

        // Snapshot selfdestructed_accounts before the call (EIP-6780 revert handling)
        // On revert, accounts marked for deletion during the reverted call must be removed
        var selfdestruct_snapshot = std.AutoHashMap(Address, void).init(self.arena.allocator());
        var selfdestruct_it = self.selfdestructed_accounts.iterator();
        while (selfdestruct_it.next()) |entry| {
            selfdestruct_snapshot.put(entry.key_ptr.*, {}) catch {
                // Memory allocation failed during snapshot - fail the call
                return makeFailure(self.arena.allocator(), gas);
            };
        }

        // Snapshot warm addresses before the call (EIP-2929)
        // Per Python reference (incorporate_child_on_error), accessed_addresses
        // are only propagated on success, not on failure
        var warm_addresses_snapshot = std.AutoHashMap(Address, void).init(self.arena.allocator());
        var warm_addr_it = self.warm_addresses.iterator();
        while (warm_addr_it.next()) |entry| {
            try warm_addresses_snapshot.put(entry.key_ptr.*, {});
        }

        // Snapshot warm storage slots before the call (EIP-2929)
        // Per Python reference (incorporate_child_on_error), accessed_storage_keys
        // are only propagated on success, not on failure
        var warm_storage_snapshot = std.array_hash_map.ArrayHashMap(StorageSlotKey, void, StorageSlotKeyContext, false).init(self.arena.allocator());
        var warm_storage_it = self.warm_storage_slots.iterator();
        while (warm_storage_it.next()) |entry| {
            _ = try warm_storage_snapshot.put(entry.key_ptr.*, {});
        }

        // Snapshot original_storage before the call
        // This is critical for correct SSTORE gas calculation after reverts
        // When a call reverts, any entries added to original_storage during that call
        // must be removed, otherwise subsequent SSTOREs will use stale original values
        // and incorrectly calculate gas costs and refunds
        var original_storage_snapshot = std.AutoHashMap(StorageSlotKey, u256).init(self.arena.allocator());
        var original_storage_it = self.original_storage.iterator();
        while (original_storage_it.next()) |entry| {
            try original_storage_snapshot.put(entry.key_ptr.*, entry.value_ptr.*);
        }

        // Snapshot storage before the call
        // We need to track which slots existed and their values
        // On revert, we restore to this exact state (remove new slots, restore modified slots)
        var storage_snapshot = std.AutoHashMap(StorageSlotKey, u256).init(self.arena.allocator());
        if (self.host) |h| {
            // In host mode, we need to ask the host for current storage values
            // But we don't have a way to enumerate all slots, so we track what we've seen
            // For now, we'll snapshot original_storage keys since those are the accessed slots
            var orig_it = self.original_storage.iterator();
            while (orig_it.next()) |entry| {
                const current_val = h.getStorage(entry.key_ptr.*.address, entry.key_ptr.*.slot);
                try storage_snapshot.put(entry.key_ptr.*, current_val);
            }
        } else {
            var storage_it = self.storage.iterator();
            while (storage_it.next()) |entry| {
                try storage_snapshot.put(entry.key_ptr.*, entry.value_ptr.*);
            }
        }

        // Snapshot balances before the call (for SELFDESTRUCT revert handling)
        // We use copy-on-write: addresses are snapshotted when first modified via setBalanceWithSnapshot
        var balance_snapshot = std.AutoHashMap(Address, u256).init(self.arena.allocator());

        // Push the snapshot onto the stack so nested calls can snapshot in parent snapshots
        try self.balance_snapshot_stack.append(self.arena.allocator(), &balance_snapshot);
        defer _ = self.balance_snapshot_stack.pop();

        const execution_caller: Address = switch (call_type) {
            .Call, .StaticCall => frame_caller,
            .DelegateCall => frame_caller_caller,
            .CallCode => frame_caller,
        };

        const execution_address: Address = switch (call_type) {
            .Call, .StaticCall => address,
            .DelegateCall, .CallCode => frame_caller,
        };

        // Handle balance transfer if value > 0 (only for regular CALL)
        if (value > 0 and call_type == .Call) {
            const caller_balance = if (self.host) |h| h.getBalance(frame_caller) else self.balances.get(frame_caller) orelse 0;
            if (caller_balance < value) {
                // Insufficient balance - call fails
                // std.debug.print("CALL FAILED: insufficient balance (caller={any} needs {} has {})\n", .{frame_caller.bytes, value, caller_balance});
                return makeFailure(self.arena.allocator(), gas);
            }

            // Transfer balance using snapshot mechanism for proper revert handling
            try self.setBalanceWithSnapshot(frame_caller, caller_balance - value);
            const callee_balance = if (self.host) |h| h.getBalance(address) else self.balances.get(address) orelse 0;
            try self.setBalanceWithSnapshot(address, callee_balance + value);
        }

        // Get code for the target address
        const code = self.get_code(address);
        // std.debug.print("DEBUG inner_call: address={any} code.len={} frames={}\n", .{address.bytes, code.len, self.frames.items.len});
        if (code.len == 0) {
            // Check for JavaScript custom precompile handler first
            const root_c = @import("root_c.zig");
            var output_len: usize = 0;
            var output_ptr: [*]u8 = undefined;
            var gas_used: u64 = 0;

            if (root_c.tryCallJsPrecompileHandler(
                &address.bytes,
                input.ptr,
                input.len,
                gas,
                &output_len,
                &output_ptr,
                &gas_used,
            )) {
                // JavaScript precompile handler executed successfully
                const output = if (output_len > 0) output_ptr[0..output_len] else &[_]u8{};
                return CallResult{
                    .success = true,
                    .gas_left = gas - gas_used,
                    .output = output,
                };
            }

            // Check for config-based precompile override (native Zig handlers)
            if (self.getPrecompileOverride(address)) |override| {
                const result = override.execute(
                    override.context,
                    self.arena.allocator(),
                    input,
                    gas,
                ) catch |err| {
                    std.debug.print("Custom precompile execution error: {}\n", .{err});
                    return makeFailure(self.arena.allocator(), 0);
                };

                return CallResult{
                    .success = result.success,
                    .gas_left = if (result.success) gas - result.gas_used else 0,
                    .output = result.output,
                };
            }

            // Check if this is a standard precompile address (hardfork-aware)
            if (precompiles.is_precompile(address, self.hardfork)) {
                // Use the precompiles module to handle all precompile execution
                const result = precompiles.execute_precompile(
                    self.arena.allocator(),
                    address,
                    input,
                    gas,
                    self.hardfork,
                ) catch |err| {
                    // On error, return failure
                    std.debug.print("Precompile execution error: {}\n", .{err});
                    return makeFailure(self.arena.allocator(), 0);
                };

                return CallResult{
                    .success = result.success,
                    .gas_left = if (result.success) gas - result.gas_used else 0,
                    .output = result.output,
                };
            }

            // For non-precompile empty accounts, return success with no output
            return CallResult.success_empty(self.arena.allocator(), gas) catch CallResult{
                .success = true,
                .gas_left = gas,
                .output = &.{},
            };
        }

        // Create and push frame onto stack
        // Use execution_caller and execution_address which are determined by call_type

        // Determine if this call should be static
        // STATICCALL creates a static context, and static context propagates to all nested calls
        const parent_is_static = if (self.getCurrentFrame()) |frame| frame.is_static else false;
        const is_static = parent_is_static or call_type == .StaticCall;

        // Safely cast gas to i64 - if it exceeds i64::MAX, cap it (shouldn't happen in practice)
        const frame_gas = std.math.cast(i64, gas) orelse std.math.maxInt(i64);
        self.frames.append(self.arena.allocator(), Frame.init(
            self.arena.allocator(),
            code,
            frame_gas,
            execution_caller,
            execution_address,
            value,
            input,
            @as(*anyopaque, @ptrCast(self)),
            self.hardfork,
            is_static,
        ) catch {
            return makeFailure(self.arena.allocator(), 0);
        }) catch {
            return makeFailure(self.arena.allocator(), 0);
        };
        errdefer _ = self.frames.pop();

        // Execute frame (don't cache pointer - it may become invalid during nested calls)
        self.frames.items[self.frames.items.len - 1].execute() catch {
            // std.debug.print("CALL FAILED: execution error {} (addr={any})\n", .{err, address.bytes});
            _ = self.frames.pop();

            // Restore gas refunds on failure
            // Per Python: incorporate_child_on_error does NOT add child's refund_counter
            self.gas_refund = refund_snapshot;

            // Restore warm addresses on failure (EIP-2929)
            self.warm_addresses.clearRetainingCapacity();
            var warm_addr_restore_it = warm_addresses_snapshot.iterator();
            while (warm_addr_restore_it.next()) |entry| {
                try self.warm_addresses.put(entry.key_ptr.*, {});
            }

            // Restore warm storage slots on failure (EIP-2929)
            self.warm_storage_slots.clearRetainingCapacity();
            var warm_storage_restore_it = warm_storage_snapshot.iterator();
            while (warm_storage_restore_it.next()) |entry| {
                _ = try self.warm_storage_slots.put(entry.key_ptr.*, {});
            }

            // Restore storage on failure
            // IMPORTANT: Identify slots to delete BEFORE restoring original_storage
            // First, identify slots that were added during the call (exist in original_storage but not in snapshot)
            var added_slots = std.ArrayList(StorageSlotKey){};
            try added_slots.ensureTotalCapacity(self.arena.allocator(), 10);
            var orig_check_it = self.original_storage.iterator();
            while (orig_check_it.next()) |entry| {
                if (!original_storage_snapshot.contains(entry.key_ptr.*)) {
                    try added_slots.append(self.arena.allocator(), entry.key_ptr.*);
                }
            }

            // Second, restore original_storage to remove entries added during the call
            self.original_storage.clearRetainingCapacity();
            var original_storage_restore_it = original_storage_snapshot.iterator();
            while (original_storage_restore_it.next()) |entry| {
                try self.original_storage.put(entry.key_ptr.*, entry.value_ptr.*);
            }

            // Third, restore storage values from snapshot
            var storage_restore_it = storage_snapshot.iterator();
            while (storage_restore_it.next()) |entry| {
                if (self.host) |h| {
                    h.setStorage(entry.key_ptr.*.address, entry.key_ptr.*.slot, entry.value_ptr.*);
                } else {
                    try self.storage.put(entry.key_ptr.*, entry.value_ptr.*);
                }
            }

            // Fourth, delete slots that were added during the call
            for (added_slots.items) |slot_key| {
                if (self.host) |h| {
                    h.setStorage(slot_key.address, slot_key.slot, 0);
                } else {
                    _ = self.storage.remove(slot_key);
                }
            }

            // Restore balances on failure (handles SELFDESTRUCT balance transfers)
            var balance_restore_it = balance_snapshot.iterator();
            while (balance_restore_it.next()) |entry| {
                if (self.host) |h| {
                    h.setBalance(entry.key_ptr.*, entry.value_ptr.*);
                } else {
                    try self.balances.put(entry.key_ptr.*, entry.value_ptr.*);
                }
            }

            // Restore transient storage on failure (EIP-1153)
            self.transient_storage.clearRetainingCapacity();
            var restore_it = transient_snapshot.iterator();
            while (restore_it.next()) |entry| {
                self.transient_storage.put(entry.key_ptr.*, entry.value_ptr.*) catch {
                    // Critical: cannot restore transient storage - return failure with remaining gas
                    return makeFailure(self.arena.allocator(), 0);
                };
            }

            return makeFailure(self.arena.allocator(), 0);
        };

        // Get frame results (refetch pointer after execution)
        const frame = &self.frames.items[self.frames.items.len - 1];

        // Store return data
        const output = if (frame.output.len > 0) blk: {
            const output_copy = self.arena.allocator().alloc(u8, frame.output.len) catch {
                // Allocation failed - return empty output
                break :blk &[_]u8{};
            };
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

        // Restore gas refunds on revert
        // Per Python: incorporate_child_on_error does NOT add child's refund_counter
        // This applies to both reverts and exceptional halts
        if (frame.reverted) {
            self.gas_refund = refund_snapshot;
        }

        // Restore warm addresses on revert (EIP-2929)
        if (frame.reverted) {
            self.warm_addresses.clearRetainingCapacity();
            var warm_addr_restore_it = warm_addresses_snapshot.iterator();
            while (warm_addr_restore_it.next()) |entry| {
                try self.warm_addresses.put(entry.key_ptr.*, {});
            }
        }

        // Restore warm storage slots on revert (EIP-2929)
        if (frame.reverted) {
            self.warm_storage_slots.clearRetainingCapacity();
            var warm_storage_restore_it = warm_storage_snapshot.iterator();
            while (warm_storage_restore_it.next()) |entry| {
                _ = try self.warm_storage_slots.put(entry.key_ptr.*, {});
            }
        }

        // Restore storage on revert
        if (frame.reverted) {
            // IMPORTANT: Identify slots to delete BEFORE restoring original_storage
            // First, identify slots that were added during the call (exist in original_storage but not in snapshot)
            var added_slots = std.ArrayList(StorageSlotKey){};
            try added_slots.ensureTotalCapacity(self.arena.allocator(), 10);
            var orig_check_it = self.original_storage.iterator();
            while (orig_check_it.next()) |entry| {
                if (!original_storage_snapshot.contains(entry.key_ptr.*)) {
                    try added_slots.append(self.arena.allocator(), entry.key_ptr.*);
                }
            }

            // Second, restore original_storage to remove entries added during the call
            self.original_storage.clearRetainingCapacity();
            var original_storage_restore_it = original_storage_snapshot.iterator();
            while (original_storage_restore_it.next()) |entry| {
                try self.original_storage.put(entry.key_ptr.*, entry.value_ptr.*);
            }

            // Third, restore storage values from snapshot
            var storage_restore_it = storage_snapshot.iterator();
            while (storage_restore_it.next()) |entry| {
                if (self.host) |h| {
                    h.setStorage(entry.key_ptr.*.address, entry.key_ptr.*.slot, entry.value_ptr.*);
                } else {
                    try self.storage.put(entry.key_ptr.*, entry.value_ptr.*);
                }
            }

            // Fourth, delete slots that were added during the call
            for (added_slots.items) |slot_key| {
                if (self.host) |h| {
                    h.setStorage(slot_key.address, slot_key.slot, 0);
                } else {
                    _ = self.storage.remove(slot_key);
                }
            }
        }

        // Restore transient storage on revert (EIP-1153)
        if (frame.reverted) {
            self.transient_storage.clearRetainingCapacity();
            var restore_it = transient_snapshot.iterator();
            while (restore_it.next()) |entry| {
                self.transient_storage.put(entry.key_ptr.*, entry.value_ptr.*) catch {};
            }
        }

        // Restore selfdestructed_accounts on revert (EIP-6780)
        // This ensures that SELFDESTRUCT operations in reverted calls don't affect the final state
        if (frame.reverted) {
            self.selfdestructed_accounts.clearRetainingCapacity();
            var restore_selfdestruct_it = selfdestruct_snapshot.iterator();
            while (restore_selfdestruct_it.next()) |entry| {
                self.selfdestructed_accounts.put(entry.key_ptr.*, {}) catch {};
            }
        }

        // Restore balances on revert (handles SELFDESTRUCT balance transfers and value transfers)
        if (frame.reverted) {
            var balance_restore_it = balance_snapshot.iterator();
            while (balance_restore_it.next()) |entry| {
                if (self.host) |h| {
                    h.setBalance(entry.key_ptr.*, entry.value_ptr.*);
<<<<<<< HEAD
                }
            } else {
                // Restore all balances for non-host mode
                self.balances.clearRetainingCapacity();
                var balance_restore_it = balance_snapshot.iterator();
                while (balance_restore_it.next()) |entry| {
                    self.balances.put(entry.key_ptr.*, entry.value_ptr.*) catch {};
=======
                } else {
                    try self.balances.put(entry.key_ptr.*, entry.value_ptr.*);
>>>>>>> 0942fa7 (fix: Pass Cancun EIP-6780 revert tests (12 tests))
                }
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
    ) errors.CallError!struct { address: Address, success: bool, gas_left: u64, output: []const u8 } {
        // Track if this is a top-level create (contract-creation transaction)
        // We detect this when there is no active frame yet.
        // Used to avoid double-incrementing the sender's nonce (runner already increments it)
        const is_top_level_create = self.frames.items.len == 0;
        // Check call depth (STACK_DEPTH_LIMIT = 1024)
        // Per Python reference (system.py:97-99), depth exceeded refunds gas
        if (self.frames.items.len >= 1024) {
            return .{
                .address = primitives.ZERO_ADDRESS,
                .success = false,
                .gas_left = gas,
                .output = &[_]u8{},
            };
        }

        // Get caller from current frame
        const caller = if (self.getCurrentFrame()) |frame| frame.address else self.origin;

        // Check sender's nonce for overflow (max nonce is 2^64 - 1)
        const sender_nonce = if (self.host) |h|
            h.getNonce(caller)
        else
            self.nonces.get(caller) orelse 0;

        if (sender_nonce == std.math.maxInt(u64)) {
            // Nonce overflow - CREATE fails, return gas
            return .{
                .address = primitives.ZERO_ADDRESS,
                .success = false,
                .gas_left = gas,
                .output = &[_]u8{},
            };
        }

        // Handle balance transfer if value > 0
        if (value > 0) {
            const caller_balance = if (self.host) |h| h.getBalance(caller) else self.balances.get(caller) orelse 0;
            if (caller_balance < value) {
                // Insufficient balance - CREATE fails
                return .{
                    .address = primitives.ZERO_ADDRESS,
                    .success = false,
                    .gas_left = gas,
                    .output = &[_]u8{},
                };
            }
            // Note: balance transfer happens after we know the new address
        }

        // Calculate new contract address
        const new_address = if (salt) |s| blk: {
            // CREATE2: keccak256(0xff ++ caller ++ salt ++ keccak256(init_code))[12:]
            var hash_input = std.ArrayList(u8){};
            defer hash_input.deinit(self.arena.allocator());

            try hash_input.append(self.arena.allocator(), 0xff);
            try hash_input.appendSlice(self.arena.allocator(), &caller.bytes);

            // Add salt (32 bytes, big-endian)
            var salt_bytes: [32]u8 = undefined;
            var i: usize = 0;
            while (i < 32) : (i += 1) {
                salt_bytes[31 - i] = @as(u8, @truncate(s >> @intCast(i * 8)));
            }
            try hash_input.appendSlice(self.arena.allocator(), &salt_bytes);

            // Add keccak256(init_code)
            var code_hash: [32]u8 = undefined;
            std.crypto.hash.sha3.Keccak256.hash(init_code, &code_hash, .{});
            try hash_input.appendSlice(self.arena.allocator(), &code_hash);

            // Hash and take last 20 bytes
            var addr_hash: [32]u8 = undefined;
            std.crypto.hash.sha3.Keccak256.hash(hash_input.items, &addr_hash, .{});

            var addr_bytes: [20]u8 = undefined;
            @memcpy(&addr_bytes, addr_hash[12..32]);
            break :blk Address{ .bytes = addr_bytes };
        } else blk: {
            // CREATE: keccak256(rlp([sender, nonce]))[12:]
            // For top-level creates: nonce was already incremented by runner, so subtract 1
            // For opcode creates: use current nonce (will be incremented after collision check)
            // Per Python reference (message.py:57): uses "nonce - 1" for transactions
            var nonce = if (self.host) |h|
                h.getNonce(caller)
            else
                self.nonces.get(caller) orelse 0;

            if (is_top_level_create) {
                nonce -= 1; // Undo the increment that runner already did
            }

            // Manually construct RLP encoding of [address_bytes, nonce]
            // Address is 20 bytes, nonce is variable length
            var rlp_data = std.ArrayList(u8){};
            defer rlp_data.deinit(self.arena.allocator());

            // Encode address (20 bytes, 0x80 + 20 = 0x94)
            try rlp_data.append(self.arena.allocator(), 0x94);
            try rlp_data.appendSlice(self.arena.allocator(), &caller.bytes);

            // Encode nonce (RLP encoding for integers)
            if (nonce == 0) {
                try rlp_data.append(self.arena.allocator(), 0x80); // Empty byte string
            } else if (nonce < 0x80) {
                try rlp_data.append(self.arena.allocator(), @as(u8, @intCast(nonce)));
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
                try rlp_data.append(self.arena.allocator(), @as(u8, @intCast(0x80 + byte_count)));
                try rlp_data.appendSlice(self.arena.allocator(), nonce_bytes[start_idx..]);
            }

            // Wrap in list prefix
            const total_len = rlp_data.items.len;
            var final_rlp = std.ArrayList(u8){};
            defer final_rlp.deinit(self.arena.allocator());
            try final_rlp.append(self.arena.allocator(), @as(u8, @intCast(0xc0 + total_len))); // List with length
            try final_rlp.appendSlice(self.arena.allocator(), rlp_data.items);

            // Hash and take last 20 bytes
            var addr_hash: [32]u8 = undefined;
            std.crypto.hash.sha3.Keccak256.hash(final_rlp.items, &addr_hash, .{});

            var addr_bytes: [20]u8 = undefined;
            @memcpy(&addr_bytes, addr_hash[12..32]);
            break :blk Address{ .bytes = addr_bytes };
        };

        // EIP-3860: Check init code size limit (Shanghai and later)
        // Per Python reference (system.py:81-82): This check happens IMMEDIATELY after reading call_data
        // and BEFORE any nonce increments or child call gas calculation
        // When this check fails, it raises OutOfGasError in the PARENT frame (the frame executing CREATE)
        // This halts the entire parent frame, not just the CREATE operation
        if (self.hardfork.isAtLeast(.SHANGHAI)) {
            // Check must use >= to match reference implementation exactly
            // MAX_INITCODE_SIZE is the maximum ALLOWED, so > is correct
            if (init_code.len > primitives.GasConstants.MaxInitcodeSize) {
                // Per Python reference: OutOfGasError is raised, halting the parent frame
                // The initcode gas was already charged in frame.zig
                return error.OutOfGas;
            }
        }

        // EIP-3860 initcode cost is charged in two different places depending on context:
        // 1. For top-level creates (contract creation transactions): charged in transaction intrinsic gas
        // 2. For CREATE/CREATE2 opcodes: charged in frame.zig before calling inner_create
        // Therefore, DO NOT charge it again here for top-level creates
        const child_gas: u64 = gas;

        // EIP-2929 (Berlin): Mark created address as warm
        // Per Python reference: accessed_addresses.add(contract_address) happens
        // BEFORE collision check and nonce increment
        if (self.hardfork.isAtLeast(.BERLIN)) {
            _ = try self.warm_addresses.getOrPut(new_address);
        }

        // Check for address collision (code, nonce, or storage already exists)
        // Per EIP-684: If account has code or nonce, CREATE fails
        const has_collision = blk: {
            if (self.host) |h| {
                const has_code = h.getCode(new_address).len > 0;
                const has_nonce = h.getNonce(new_address) > 0;
                break :blk has_code or has_nonce;
            } else {
                const has_code = (self.code.get(new_address) orelse &[_]u8{}).len > 0;
                const has_nonce = (self.nonces.get(new_address) orelse 0) > 0;
                break :blk has_code or has_nonce;
            }
        };

        if (has_collision) {
            // Collision detected - increment caller's nonce and return failure
            // Per Python reference (system.py:107-110): nonce is incremented even on collision
            // But only for CREATE/CREATE2 opcodes, not for top-level creates (already incremented by runner)
            if (!is_top_level_create) {
                const caller_nonce = if (self.host) |h|
                    h.getNonce(caller)
                else
                    self.nonces.get(caller) orelse 0;

                if (self.host) |h| {
                    h.setNonce(caller, caller_nonce + 1);
                } else {
                    try self.nonces.put(caller, caller_nonce + 1);
                }
            }

            // Per Python reference (system.py:105-112): On collision, the gas is NOT refunded.
            // Line 86 deducts create_message_gas, and line 111-112 returns without refunding.
            // Therefore, we return gas_left = 0 to indicate all gas was consumed.
            return .{
                .address = primitives.ZERO_ADDRESS,
                .success = false,
                .gas_left = 0,
                .output = &[_]u8{},
            };
        }

        // Increment caller's nonce for CREATE/CREATE2 opcodes (but not top-level creates)
        // Per Python reference:
        // - fork.py:546 increments sender nonce for transactions (done by runner before calling this)
        // - system.py:113 increments caller nonce for CREATE/CREATE2 opcodes
        // For top-level creates: nonce already incremented in transaction processing (runner.zig:988-990)
        // For opcode creates: nonce must be incremented here
        if (!is_top_level_create) {
            const caller_nonce = if (self.host) |h|
                h.getNonce(caller)
            else
                self.nonces.get(caller) orelse 0;

            if (self.host) |h| {
                h.setNonce(caller, caller_nonce + 1);
            } else {
                try self.nonces.put(caller, caller_nonce + 1);
            }
        }

        // Set nonce of new contract to 1 (EVM spec: contracts start with nonce 1)
        if (self.host) |h| {
            h.setNonce(new_address, 1);
        } else {
            try self.nonces.put(new_address, 1);
        }

        // EIP-6780 (Cancun): Mark account as created BEFORE execution
        // Per Python reference (interpreter.py:174): mark_account_created happens BEFORE process_message
        // "The marker is not removed even if the account creation reverts"
        // This is required for SELFDESTRUCT to correctly identify same-tx creations
        try self.created_accounts.put(new_address, {});

        // Snapshot balances before execution (for SELFDESTRUCT revert handling)
        // We use copy-on-write: addresses are snapshotted when first modified via setBalanceWithSnapshot
        var balance_snapshot = std.AutoHashMap(Address, u256).init(self.arena.allocator());

        // Push the snapshot onto the stack so nested calls can snapshot in parent snapshots
        try self.balance_snapshot_stack.append(self.arena.allocator(), &balance_snapshot);
        defer _ = self.balance_snapshot_stack.pop();

        // Transfer balance if value > 0 using snapshot mechanism for proper revert handling
        if (value > 0) {
            const caller_balance = if (self.host) |h| h.getBalance(caller) else self.balances.get(caller) orelse 0;
            try self.setBalanceWithSnapshot(caller, caller_balance - value);
            const new_addr_balance = if (self.host) |h| h.getBalance(new_address) else self.balances.get(new_address) orelse 0;
            try self.setBalanceWithSnapshot(new_address, new_addr_balance + value);
        }

        // Snapshot selfdestructed_accounts before executing init code (EIP-6780 revert handling)
        // If CREATE fails, any SELFDESTRUCTs in the init code must be reverted
        var create_selfdestruct_snapshot = std.AutoHashMap(Address, void).init(self.arena.allocator());
        var create_selfdestruct_it = self.selfdestructed_accounts.iterator();
        while (create_selfdestruct_it.next()) |entry| {
            try create_selfdestruct_snapshot.put(entry.key_ptr.*, {});
        }

        // Execute initialization code
        try self.frames.append(self.arena.allocator(), try Frame.init(
            self.arena.allocator(),
            init_code,
            @intCast(child_gas),
            caller,
            new_address,
            value,
            &[_]u8{}, // no calldata for CREATE
            @as(*anyopaque, @ptrCast(self)),
            self.hardfork,
            false, // CREATE/CREATE2 are never static (can't create contracts in static context)
        ));
        errdefer _ = self.frames.pop();

        // Execute frame
        self.frames.items[self.frames.items.len - 1].execute() catch {
            const failed_frame = &self.frames.items[self.frames.items.len - 1];
            const error_output = failed_frame.output; // Capture output before popping
            _ = self.frames.pop();

            // Revert nonce on execution error
            if (self.host) |h| {
                h.setNonce(new_address, 0);
            } else {
                _ = self.nonces.remove(new_address);
            }

            // Restore balances on error (handles SELFDESTRUCT balance transfers and value transfers)
            var balance_restore_it = balance_snapshot.iterator();
            while (balance_restore_it.next()) |entry| {
                if (self.host) |h| {
                    h.setBalance(entry.key_ptr.*, entry.value_ptr.*);
                } else {
                    try self.balances.put(entry.key_ptr.*, entry.value_ptr.*);
                }
            }

            return .{
                .address = primitives.ZERO_ADDRESS,
                .success = false,
                .gas_left = 0,
                .output = error_output,
            };
        };

        // Get frame results
        const frame = &self.frames.items[self.frames.items.len - 1];
        var gas_left = @as(u64, @intCast(@max(frame.gas_remaining, 0)));
        var success = !frame.reverted;
        const frame_output = frame.output; // Capture output

        // If successful, check deposit cost and code size, then deploy
        if (success) {
            // Charge code deposit cost (200 gas per byte) if there's output
            if (frame_output.len > 0) {
                const deposit_cost = @as(u64, @intCast(frame_output.len)) * GasConstants.CreateDataGas;
                if (gas_left < deposit_cost) {
                    // Out of gas during code deposit -> creation fails
                    success = false;
                    gas_left = 0;
                }
            }

            if (success and frame_output.len > 0) {
                // Check code size limit (EIP-170: 24576 bytes)
                const max_code_size = 24576;
                if (frame_output.len > max_code_size) {
                    _ = self.frames.pop();

                    // Revert nonce on failure
                    if (self.host) |h| {
                        h.setNonce(new_address, 0);
                    } else {
                        _ = self.nonces.remove(new_address);
                    }

                    // Restore balances on failure (handles SELFDESTRUCT balance transfers and value transfers)
                    var balance_restore_it = balance_snapshot.iterator();
                    while (balance_restore_it.next()) |entry| {
                        if (self.host) |h| {
                            h.setBalance(entry.key_ptr.*, entry.value_ptr.*);
                        } else {
                            try self.balances.put(entry.key_ptr.*, entry.value_ptr.*);
                        }
                    }

                    // Restore selfdestructed_accounts on failure (EIP-6780)
                    self.selfdestructed_accounts.clearRetainingCapacity();
                    var restore_create_selfdestruct_it = create_selfdestruct_snapshot.iterator();
                    while (restore_create_selfdestruct_it.next()) |entry| {
                        try self.selfdestructed_accounts.put(entry.key_ptr.*, {});
                    }

                    // Per Python reference: code size violation raises OutOfGasError, consuming all gas
                    // execution-specs/src/ethereum/forks/constantinople/vm/interpreter.py
                    return .{
                        .address = primitives.ZERO_ADDRESS,
                        .success = false,
                        .gas_left = 0,  // Consume all remaining gas on code size violation
                        .output = frame_output,
                    };
                }

                // Deploy code and deduct deposit gas
                if (self.host) |h| {
                    // When using a host, update host's code directly
                    h.setCode(new_address, frame_output);
                } else {
                    // When not using a host, store in EVM's code map
                    const code_copy = try self.arena.allocator().alloc(u8, frame_output.len);
                    @memcpy(code_copy, frame_output);
                    try self.code.put(new_address, code_copy);
                }
                const deposit_cost = @as(u64, @intCast(frame_output.len)) * GasConstants.CreateDataGas;
                gas_left -= deposit_cost;
            } else if (success) {
                // Deploy empty code (output.len == 0)
                if (self.host) |h| {
                    h.setCode(new_address, &[_]u8{});
                } else {
                    try self.code.put(new_address, &[_]u8{});
                }
            }
        } else {
            // Reverse state changes on revert
            // Revert nonce to 0
            if (self.host) |h| {
                h.setNonce(new_address, 0);
            } else {
                _ = self.nonces.remove(new_address);
            }

            // Restore balances on revert (handles SELFDESTRUCT balance transfers and value transfers)
            var balance_restore_it = balance_snapshot.iterator();
            while (balance_restore_it.next()) |entry| {
                if (self.host) |h| {
                    h.setBalance(entry.key_ptr.*, entry.value_ptr.*);
                } else {
                    try self.balances.put(entry.key_ptr.*, entry.value_ptr.*);
                }
            }

            // Restore selfdestructed_accounts on failure (EIP-6780)
            self.selfdestructed_accounts.clearRetainingCapacity();
            var restore_create_selfdestruct_it = create_selfdestruct_snapshot.iterator();
            while (restore_create_selfdestruct_it.next()) |entry| {
                try self.selfdestructed_accounts.put(entry.key_ptr.*, {});
            }
        }

        // Pop frame
        _ = self.frames.pop();

        // According to EIP-1014 and CREATE semantics:
        // - On success: return_data should be empty
        // - On failure/revert: return_data should contain the child's output
        return .{
            .address = if (success) new_address else primitives.ZERO_ADDRESS,
            .success = success,
            .gas_left = gas_left,
            .output = if (success) &[_]u8{} else frame_output,
        };
    }

    /// Add gas refund (called by frame)
    pub fn add_refund(self: *Self, amount: u64) void {
        self.gas_refund += amount;
    }

    pub fn sub_refund(self: *Self, amount: u64) void {
        self.gas_refund -= amount;
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
    pub fn get_storage(self: *Self, address: Address, slot: u256) !u256 {
        const key = StorageSlotKey{ .address = address, .slot = slot };

        // If using storage injector, check cache first
        if (self.storage_injector) |injector| {
            log.debug("get_storage: Using storage injector for slot {}", .{slot});
            // Check cache first
            if (injector.storage_cache.get(key)) |value| {
                log.debug("get_storage: Cache HIT for slot {}, value={}", .{ slot, value });
                return value; // Cache hit
            }

            // Cache miss - yield to fetch from async source
            log.debug("get_storage: Cache MISS for slot {}, yielding", .{slot});
            self.async_data_request = .{ .storage = .{
                .address = address,
                .slot = slot,
            } };
            return errors.CallError.NeedAsyncData;
        }

        // No injector - use host or internal HashMap
        if (self.host) |h| {
            return h.getStorage(address, slot);
        }
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

        // Mark dirty if using injector
        if (self.storage_injector) |injector| {
            try injector.markStorageDirty(address, slot);
        }

        if (self.host) |h| {
            h.setStorage(address, slot, value);
            return;
        }

        // EVM spec: storage slots with value 0 should be deleted, not stored
        if (value == 0) {
            _ = self.storage.remove(key);
        } else {
            try self.storage.put(key, value);
        }
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
}

// Default EVM instance for backward compatibility
pub const DefaultEvm = Evm(.{});

// ============================================================================
// Tests for Async Storage Injection (Phase 1: Core Types and Error Handling)
// ============================================================================

test "AsyncDataRequest - union size and field access" {
    const testing = std.testing;

    // Test none variant
    const req_none = AsyncDataRequest{ .none = {} };
    try testing.expect(req_none == .none);

    // Test storage variant
    const addr = primitives.Address.from_hex("0x1234567890123456789012345678901234567890") catch unreachable;
    const req_storage = AsyncDataRequest{ .storage = .{
        .address = addr,
        .slot = 42,
    } };
    try testing.expect(req_storage == .storage);
    try testing.expect(req_storage.storage.address.equals(addr));
    try testing.expectEqual(42, req_storage.storage.slot);

    // Test balance variant
    const req_balance = AsyncDataRequest{ .balance = .{
        .address = addr,
    } };
    try testing.expect(req_balance == .balance);
    try testing.expect(req_balance.balance.address.equals(addr));

    // Test code variant
    const req_code = AsyncDataRequest{ .code = .{
        .address = addr,
    } };
    try testing.expect(req_code == .code);
    try testing.expect(req_code.code.address.equals(addr));

    // Test nonce variant
    const req_nonce = AsyncDataRequest{ .nonce = .{
        .address = addr,
    } };
    try testing.expect(req_nonce == .nonce);
    try testing.expect(req_nonce.nonce.address.equals(addr));
}

test "AsyncDataRequest - can write and read each variant" {
    const testing = std.testing;

    var request: AsyncDataRequest = .none;

    // Write storage request
    const addr = primitives.Address.from_hex("0xabcdef0123456789abcdef0123456789abcdef01") catch unreachable;
    request = .{ .storage = .{ .address = addr, .slot = 100 } };
    try testing.expect(request == .storage);
    try testing.expectEqual(100, request.storage.slot);

    // Write balance request
    request = .{ .balance = .{ .address = addr } };
    try testing.expect(request == .balance);

    // Write back to none
    request = .none;
    try testing.expect(request == .none);
}

test "error.NeedAsyncData can be caught and identified" {
    const testing = std.testing;

    const TestFn = struct {
        fn needsData() !void {
            return errors.CallError.NeedAsyncData;
        }
    };

    const result = TestFn.needsData();
    try testing.expectError(errors.CallError.NeedAsyncData, result);
}

test "error.NeedAsyncData propagates through call stack" {
    const testing = std.testing;

    const TestFn = struct {
        fn level3() !void {
            return errors.CallError.NeedAsyncData;
        }

        fn level2() !void {
            try level3();
        }

        fn level1() !void {
            try level2();
        }
    };

    const result = TestFn.level1();
    try testing.expectError(errors.CallError.NeedAsyncData, result);
}

test "Evm.async_data_request field initialized to .none" {
    const testing = std.testing;

    var evm = try DefaultEvm.init(testing.allocator, null, null, null, null);
    defer evm.deinit();

    try testing.expect(evm.async_data_request == .none);
}

test "Evm.async_data_request can write/read different request types" {
    const testing = std.testing;

    var evm = try DefaultEvm.init(testing.allocator, null, null, null, null);
    defer evm.deinit();

    const addr = primitives.Address.from_hex("0x1111111111111111111111111111111111111111") catch unreachable;

    // Write storage request
    evm.async_data_request = .{ .storage = .{ .address = addr, .slot = 99 } };
    try testing.expect(evm.async_data_request == .storage);
    try testing.expectEqual(99, evm.async_data_request.storage.slot);

    // Write balance request
    evm.async_data_request = .{ .balance = .{ .address = addr } };
    try testing.expect(evm.async_data_request == .balance);

    // Clear request
    evm.async_data_request = .none;
    try testing.expect(evm.async_data_request == .none);
}

// ============================================================================
// Tests for Phase 4: callOrContinue() and Async Execution
// ============================================================================

test "CallOrContinueInput/Output - can construct each variant" {
    const testing = std.testing;

    const addr = primitives.Address.from_hex("0x1111111111111111111111111111111111111111") catch unreachable;

    // Test Input variants
    const call_input: DefaultEvm.CallOrContinueInput = .{ .call = .{
        .call = .{
            .caller = addr,
            .to = addr,
            .gas = 1000,
            .value = 0,
            .input = &[_]u8{},
        },
    } };
    try testing.expect(call_input == .call);

    const storage_input: DefaultEvm.CallOrContinueInput = .{ .continue_with_storage = .{
        .address = addr,
        .slot = 42,
        .value = 100,
    } };
    try testing.expect(storage_input == .continue_with_storage);

    // Test Output variants
    const result_output: DefaultEvm.CallOrContinueOutput = .{ .result = .{
        .success = true,
        .gas_left = 500,
        .output = &[_]u8{},
    } };
    try testing.expect(result_output == .result);

    const storage_output: DefaultEvm.CallOrContinueOutput = .{ .need_storage = .{
        .address = addr,
        .slot = 99,
    } };
    try testing.expect(storage_output == .need_storage);
}

test "callOrContinue - returns .need_storage on cache miss" {
    const testing = std.testing;

    // Create EVM with storage injector
    var evm = try DefaultEvm.init(testing.allocator, null, null, null, null);
    defer evm.deinit();

    var injector = try StorageInjector.init(evm.arena.allocator());
    evm.storage_injector = &injector;

    const addr = primitives.Address.from_hex("0x1234567890123456789012345678901234567890") catch unreachable;

    // Bytecode: PUSH1 0x00, SLOAD - will trigger async request
    const bytecode = [_]u8{ 0x60, 0x00, 0x54 }; // PUSH1 0, SLOAD
    evm.pending_bytecode = &bytecode;

    const params: DefaultEvm.CallParams = .{ .call = .{
        .caller = addr,
        .to = addr,
        .gas = 100000,
        .value = 0,
        .input = &[_]u8{},
    } };

    const output = try evm.callOrContinue(.{ .call = params });

    // Should yield with storage request
    try testing.expect(output == .need_storage);
    try testing.expectEqual(0, output.need_storage.slot);
}

test "callOrContinue - continue_with_storage resumes execution" {
    const testing = std.testing;

    var evm = try DefaultEvm.init(testing.allocator, null, null, null, null);
    defer evm.deinit();

    var injector = try StorageInjector.init(evm.arena.allocator());
    evm.storage_injector = &injector;

    const addr = primitives.Address.from_hex("0x1234567890123456789012345678901234567890") catch unreachable;

    // Bytecode: PUSH1 0x00, SLOAD, STOP
    const bytecode = [_]u8{ 0x60, 0x00, 0x54, 0x00 };
    evm.pending_bytecode = &bytecode;

    const params: DefaultEvm.CallParams = .{ .call = .{
        .caller = addr,
        .to = addr,
        .gas = 100000,
        .value = 0,
        .input = &[_]u8{},
    } };

    // First call - should yield
    const output1 = try evm.callOrContinue(.{ .call = params });
    try testing.expect(output1 == .need_storage);

    // Continue with storage value
    const output2 = try evm.callOrContinue(.{ .continue_with_storage = .{
        .address = addr,
        .slot = 0,
        .value = 42,
    } });

    // Should complete with ready_to_commit (if storage injector) or result
    try testing.expect(output2 == .ready_to_commit or output2 == .result);
}
