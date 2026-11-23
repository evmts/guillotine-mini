/// EVM implementation for tracing and validation
/// This is a simplified, unoptimized EVM that orchestrates execution.
/// Architecture mirrors evm.zig - Evm orchestrates, Frame executes
const std = @import("std");
const log = @import("logger.zig");
const primitives = @import("voltaire");
const GasConstants = primitives.GasConstants;
const Address = primitives.Address;
const Frame = @import("frame.zig").Frame;
const Hardfork = primitives.Hardfork;
const host = @import("host.zig");
const errors = @import("errors.zig");
const trace = @import("trace.zig");
const inspector_mod = @import("inspector.zig");
const precompiles = @import("precompiles");
const evm_config = @import("evm_config.zig");
const EvmConfig = evm_config.EvmConfig;
const storage_injector = @import("storage_injector.zig");
const StorageInjector = storage_injector.StorageInjector;
const storage_mod = @import("storage.zig");
const async_executor_mod = @import("async_executor.zig");
const access_list_manager_mod = @import("access_list_manager.zig");
const AccessListManager = access_list_manager_mod.AccessListManager;
const AccessListSnapshot = access_list_manager_mod.AccessListSnapshot;

const p256verify_address = Address.fromU256(0x0100);

fn isPrecompile(address: Address, hardfork: Hardfork) bool {
    if (address.equals(p256verify_address)) return hardfork.isAtLeast(.OSAKA);
    return precompiles.isPrecompile(address, hardfork);
}

// Re-export StorageKey from Voltaire primitives (canonical path)
pub const StorageKey = primitives.State.StorageKey;
pub const StorageSlotKey = StorageKey; // Backwards compatibility alias

// Re-export from storage module
pub const Storage = storage_mod.Storage;
pub const AsyncDataRequest = storage_mod.AsyncDataRequest;

// For creating snapshots we need access to the snapshot API
// The manager provides snapshot() and restore() methods

pub const BlockContext = struct {
    chain_id: u256,
    block_number: u64,
    block_timestamp: u64,
    block_difficulty: u256,
    block_prevrandao: u256,
    block_coinbase: primitives.Address,
    block_gas_limit: u64,
    block_base_fee: u256,
    blob_base_fee: u256,
    /// Array of recent block hashes (last 256 blocks)
    /// Per Python reference (cancun/vm/__init__.py:42): block_hashes: List[Hash32]
    /// Python access pattern: block_hashes[-(current_block - target_block)]
    /// Empty slice if no block hashes available
    block_hashes: []const [32]u8 = &[_][32]u8{},
};

/// EIP-7702 delegation designation prefix.
pub const DELEGATION_PREFIX = [_]u8{ 0xef, 0x01, 0x00 };
/// `0xef0100 || address`.
pub const DELEGATION_CODE_LENGTH = DELEGATION_PREFIX.len + 20;

/// The delegate of an EIP-7702 designation, or null. Only the exact 23-byte
/// form counts (execution-specs prague `is_valid_delegation`).
pub fn parseDelegation(code: []const u8) ?primitives.Address {
    if (code.len != DELEGATION_CODE_LENGTH or !std.mem.eql(u8, code[0..3], &DELEGATION_PREFIX)) return null;
    return .{ .bytes = code[3..23].* };
}

/// Creates a configured EVM instance type.
pub fn Evm(comptime config: EvmConfig) type {
    // Import Frame with matching config
    const frame_mod = @import("frame.zig");
    const FrameType = frame_mod.Frame(config);

    // Import new API types with config
    const call_params = @import("call_params.zig");
    const call_result = @import("call_result.zig");

    return struct {
        const Self = @This();

        pub const CallParams = call_params.CallParams(config);
        pub const CallResult = call_result.CallResult(config);

        // Create AsyncExecutor type for this EVM
        pub const AsyncExecutorType = async_executor_mod.AsyncExecutor(Self, CallParams, CallResult);

        // Re-export async types from executor
        pub const CallOrContinueInput = AsyncExecutorType.CallOrContinueInput;
        pub const CallOrContinueOutput = AsyncExecutorType.CallOrContinueOutput;

        frames: std.ArrayList(FrameType),
        storage: Storage,
        // Explicitly seeded slots are also the baseline for injector-backed transactions.
        storage_prestate: std.AutoHashMap(StorageKey, u256),
        created_accounts: std.AutoHashMap(primitives.Address, void),
        selfdestructed_accounts: std.AutoHashMap(primitives.Address, void), // EIP-6780: Track accounts marked for deletion
        touched_accounts: std.AutoHashMap(primitives.Address, void), // Pre-Paris: Track touched accounts for deletion if empty
        balances: std.AutoHashMap(primitives.Address, u256),
        nonces: std.AutoHashMap(primitives.Address, u64),
        code: std.AutoHashMap(primitives.Address, []const u8),
        access_list_manager: AccessListManager,
        gas_refund: u64,
        // Stack of balance snapshots for nested calls (for SELFDESTRUCT revert handling)
        // Each call pushes a snapshot, and on revert we restore from that snapshot
        balance_snapshot_stack: std.ArrayList(*std.AutoHashMap(primitives.Address, u256)),
        nonce_snapshot_stack: std.ArrayList(*std.AutoHashMap(primitives.Address, u64)),
        code_snapshot_stack: std.ArrayList(*std.AutoHashMap(primitives.Address, []const u8)),
        hardfork: Hardfork = Hardfork.DEFAULT,
        fork_transition: ?primitives.ForkTransition = null,
        origin: primitives.Address,
        gas_price: u256,
        host: ?host.HostInterface,
        arena: std.heap.ArenaAllocator,
        allocator: std.mem.Allocator,
        tracer: ?*trace.Tracer = null,
        inspector: ?inspector_mod.Inspector = null,
        next_frame_id: u64 = 0,
        inspector_frame_id: ?u64 = null,
        block_context: BlockContext,
        blob_versioned_hashes: []const [32]u8 = &[_][32]u8{},
        // Stored state for call() - set via setter methods
        pending_bytecode: []const u8 = &[_]u8{},
        pending_access_list: ?primitives.AccessList.AccessList = null,
        pending_storage_injector: ?*storage_injector.StorageInjector = null,

        // Config-provided overrides (comptime known)
        opcode_overrides: []const evm_config.OpcodeOverride,
        precompile_overrides: []const evm_config.PrecompileOverride,

        // State changes JSON (arena-allocated, sized to fit — persists across yields within
        // a transaction). Previously a fixed 16 KiB array that silently truncated large dumps.
        pending_state_changes: []const u8 = &.{},
        pending_state_changes_len: usize = 0,

        // Async executor (initialized after Self is fully constructed)
        async_executor: ?AsyncExecutorType = null,
        async_observation: ?ObservedFrame = null,

        // Accumulated logs for current transaction
        logs: std.ArrayList(call_result.Log),

        /// Initialize a new EVM instance
        /// Config provides defaults, but hardfork can be overridden at runtime
        pub fn init(self: *Self, allocator: std.mem.Allocator, h: ?host.HostInterface, hardfork: ?Hardfork, block_context: ?BlockContext, origin: primitives.Address, gas_price: u256, log_level: ?log.LogLevel) !void {
            // Set log level if provided
            if (log_level) |level| {
                log.setLogLevel(level);
            }

            self.* = Self{
                .frames = .{},
                .storage = undefined,
                .storage_prestate = undefined,
                .created_accounts = undefined,
                .selfdestructed_accounts = undefined,
                .touched_accounts = undefined,
                .balances = undefined,
                .nonces = undefined,
                .code = undefined,
                .access_list_manager = undefined,
                .gas_refund = 0,
                .balance_snapshot_stack = undefined,
                .nonce_snapshot_stack = undefined,
                .code_snapshot_stack = undefined,
                .hardfork = hardfork orelse config.hardfork,
                .fork_transition = null,
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
                .origin = origin,
                .gas_price = gas_price,
                .host = h,
                .arena = std.heap.ArenaAllocator.init(allocator),
                .allocator = allocator,
                .tracer = null,
                .blob_versioned_hashes = &[_][32]u8{},
                .pending_bytecode = &[_]u8{},
                .pending_access_list = null,
                .pending_storage_injector = null,
                .opcode_overrides = config.opcode_overrides,
                .precompile_overrides = config.precompile_overrides,
                .pending_state_changes = &.{},
                .pending_state_changes_len = 0,
                .async_executor = null, // Initialized when needed
                .logs = undefined,
            };
            errdefer self.arena.deinit();

            const arena_alloc = self.arena.allocator();
            self.storage = Storage.init(arena_alloc, h, null);
            self.storage_prestate = .init(arena_alloc);
            self.balances = std.AutoHashMap(primitives.Address, u256).init(arena_alloc);
            self.nonces = std.AutoHashMap(primitives.Address, u64).init(arena_alloc);
            self.code = std.AutoHashMap(primitives.Address, []const u8).init(arena_alloc);
        }

        /// Seed a storage slot without counting it as a transaction write.
        pub fn setStoragePrestate(self: *Self, key: StorageKey, value: u256) !void {
            try self.storage_prestate.ensureUnusedCapacity(1);
            try self.storage.storage.put(key, value);
            self.storage_prestate.putAssumeCapacity(key, value);
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
        pub fn getPrecompileOverride(self: *const Self, address: primitives.Address) ?*const evm_config.PrecompileOverride {
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
            if (self.storage.storage_injector != null or self.pending_storage_injector != null) {
                // A remote backing state owns the committed slots. Clear its transaction overlay.
                try self.storage.storage.ensureTotalCapacity(self.storage_prestate.count());
                self.storage.storage.clearRetainingCapacity();
                var prestate = self.storage_prestate.iterator();
                while (prestate.next()) |entry| {
                    self.storage.storage.putAssumeCapacity(entry.key_ptr.*, entry.value_ptr.*);
                }
            }
            self.storage.host = self.host;
            self.storage.storage_injector = self.pending_storage_injector;
            self.storage.original_storage.clearRetainingCapacity();
            self.storage.clear_transient();
            self.storage.trace_slots.clearRetainingCapacity();
            self.storage.async_data_request = .none;
            self.gas_refund = 0;
            self.pending_state_changes = &.{};
            self.pending_state_changes_len = 0;
            self.access_list_manager = AccessListManager.init(arena_allocator);
            self.frames = std.ArrayList(FrameType){};
            // Keep frame pointers stable through the message-call limit, including the root frame.
            try self.frames.ensureTotalCapacity(arena_allocator, @as(usize, config.max_call_depth) + 1);
            self.logs = std.ArrayList(call_result.Log){};
            self.created_accounts = std.AutoHashMap(primitives.Address, void).init(arena_allocator);
            self.selfdestructed_accounts = std.AutoHashMap(primitives.Address, void).init(arena_allocator);
            self.touched_accounts = std.AutoHashMap(primitives.Address, void).init(arena_allocator);
            self.balance_snapshot_stack = std.ArrayList(*std.AutoHashMap(primitives.Address, u256)){};
            self.nonce_snapshot_stack = std.ArrayList(*std.AutoHashMap(primitives.Address, u64)){};
            self.code_snapshot_stack = std.ArrayList(*std.AutoHashMap(primitives.Address, []const u8)){};

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

        pub fn setInspector(self: *Self, inspector: inspector_mod.Inspector) void {
            self.inspector = inspector;
        }

        pub fn clearInspector(self: *Self) void {
            self.inspector = null;
            self.async_observation = null;
            self.inspector_frame_id = null;
        }

        fn activeFrameId(self: *const Self) u64 {
            return self.inspector_frame_id orelse 0;
        }

        const ObservedFrame = struct {
            sink: inspector_mod.Inspector,
            frame_id: u64,
            parent_id: ?u64,
            depth: usize,
            gas: u64,
        };

        fn enterFrame(self: *Self, event: inspector_mod.FrameEnterEvent) ?ObservedFrame {
            @branchHint(.unlikely);
            const sink = self.inspector orelse return null;
            var view = event;
            view.frame_id = self.next_frame_id;
            self.next_frame_id += 1;
            view.parent_id = self.inspector_frame_id;
            view.depth = self.frames.items.len + 1;
            self.inspector_frame_id = view.frame_id;
            sink.onEnter(view);
            return .{ .sink = sink, .frame_id = view.frame_id, .parent_id = view.parent_id, .depth = view.depth, .gas = view.gas };
        }

        fn exitFrame(self: *Self, frame: ObservedFrame, result: CallResult, error_name: ?[]const u8) void {
            frame.sink.onExit(.{
                .frame_id = frame.frame_id,
                .parent_id = frame.parent_id,
                .depth = frame.depth,
                .output = result.output,
                .gas_used = frame.gas -| result.gas_left,
                .gas_left = result.gas_left,
                .reverted = !result.success,
                .error_name = error_name,
                .created_address = result.created_address,
            });
            self.inspector_frame_id = frame.parent_id;
        }

        fn enterCall(self: *Self, params: CallParams, from: Address, resolved: ResolvedCode, value: u256, is_static: bool) ?ObservedFrame {
            @branchHint(.unlikely);
            if (self.inspector == null) return null;
            const target = params.get_to() orelse resolved.address;
            return self.enterFrame(.{
                .frame_id = 0,
                .parent_id = null,
                .depth = 0,
                .call_type = callType(params),
                .from = from,
                .to = target,
                .code_address = resolved.address,
                .value = value,
                .gas = params.getGas(),
                .input = params.getInput(),
                .is_static = is_static,
                .is_precompile = self.canExecutePrecompile(target, resolved),
                .is_delegated = resolved.is_delegated,
                .code = resolved.code,
            });
        }

        fn callType(params: CallParams) inspector_mod.CallType {
            return switch (params) {
                .call => .call,
                .callcode => .callcode,
                .delegatecall => .delegatecall,
                .staticcall => .staticcall,
                .create => .create,
                .create2 => .create2,
            };
        }

        fn attachFrame(self: *Self, observation: ?ObservedFrame, code_address: Address) void {
            const frame = &self.frames.items[self.frames.items.len - 1];
            frame.code_address = code_address;
            if (observation) |observed| {
                frame.frame_id = observed.frame_id;
                frame.parent_frame_id = observed.parent_id;
            }
        }

        pub fn resultErrorName(result: CallResult) ?[]const u8 {
            if (result.success) return null;
            const name = result.error_info orelse return inspector_mod.formatErrorName(error.RevertExecution);
            inline for (@typeInfo(errors.CallError).error_set.?) |entry| {
                if (std.mem.eql(u8, name, entry.name)) return inspector_mod.formatErrorName(@field(anyerror, entry.name));
            }
            return name;
        }

        fn failed(self: *Self, gas_left: u64, err: anyerror) CallResult {
            return CallResult.failure_with_error(self.arena.allocator(), gas_left, @errorName(err)) catch
                .{ .success = false, .gas_left = gas_left, .output = &.{} };
        }

        pub fn accessAddress(self: *Self, address: Address) !u64 {
            const berlin = self.hardfork.isAtLeast(.BERLIN);
            const cost = if (berlin) try self.access_list_manager.access_address(address) else 0;
            self.observeAccess(address, null, berlin and cost == GasConstants.WarmStorageReadCost);
            return cost;
        }

        /// Access a storage slot and return the gas cost (EIP-2929 warm/cold).
        pub fn accessStorageSlot(self: *Self, address: Address, slot: u256) !u64 {
            const berlin = self.hardfork.isAtLeast(.BERLIN);
            const cost: u64 = if (berlin)
                try self.access_list_manager.access_storage_slot(address, slot)
            else if (self.hardfork.isAtLeast(.ISTANBUL))
                800
            else if (self.hardfork.isAtLeast(.TANGERINE_WHISTLE))
                200
            else
                50;
            self.observeAccess(address, slot, berlin and cost == GasConstants.WarmStorageReadCost);
            return cost;
        }

        fn observeAccess(self: *Self, address: Address, slot: ?u256, was_warm: bool) void {
            if (self.inspector) |sink| {
                @branchHint(.unlikely);
                sink.onAccess(.{ .frame_id = self.activeFrameId(), .address = address, .slot = slot, .was_warm = was_warm });
            }
        }

        pub fn observeStorage(self: *Self, frame: *FrameType, slot: u256, previous: u256, value: u256, is_read: bool) !void {
            if (self.inspector) |sink| {
                @branchHint(.unlikely);
                sink.onStorageChange(.{
                    .frame_id = frame.frame_id,
                    .address = frame.address,
                    .slot = slot,
                    .prev_value = previous,
                    .new_value = value,
                    .is_read = is_read,
                });
            }
            if (self.tracer) |tracer| {
                if (tracer.willCapture() and tracer.config.tracksStorage()) {
                    try self.storage.trace_slots.put(.{ .address = frame.address.bytes, .slot = slot }, {});
                }
            }
        }

        /// Set balance with copy-on-write snapshot for revert handling
        ///
        /// This should be called instead of direct host.setBalance() when inside a frame.
        /// Uses copy-on-write semantics to track balance changes for proper revert handling.
        ///
        /// IMPORTANT: Snapshots the balance in ALL active snapshots on the stack, not just the current one.
        /// This ensures that parent frames can restore state when they revert, even if the balance
        /// was modified in a nested call.
        ///
        /// Parameters:
        ///   - addr: The address whose balance to modify
        ///   - new_balance: The new balance value to set
        ///
        /// Returns: void
        ///
        /// Errors:
        ///   - OutOfMemory: If snapshot allocation fails
        pub fn setBalanceWithSnapshot(self: *Self, addr: primitives.Address, new_balance: u256) !void {
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

            const observer = self.inspector;
            const before = if (observer != null) self.get_balance(addr) else 0;
            if (self.pending_storage_injector) |injector| try injector.markBalanceDirty(addr);
            if (self.host) |h| {
                h.setBalance(addr, new_balance);
            } else {
                try self.balances.put(addr, new_balance);
            }
            if (observer) |sink| {
                @branchHint(.unlikely);
                if (before != new_balance) sink.onBalanceChange(.{
                    .frame_id = self.activeFrameId(),
                    .address = addr,
                    .prev_balance = before,
                    .new_balance = new_balance,
                });
            }
        }

        pub fn setNonceWithSnapshot(self: *Self, addr: primitives.Address, new_nonce: u64) !void {
            for (self.nonce_snapshot_stack.items) |snapshot| {
                if (!snapshot.contains(addr)) {
                    const current_nonce = if (self.host) |h|
                        h.getNonce(addr)
                    else
                        self.nonces.get(addr) orelse 0;
                    try snapshot.put(addr, current_nonce);
                }
            }

            const observer = self.inspector;
            const before = if (observer != null) self.getNonce(addr) else 0;
            if (self.pending_storage_injector) |injector| try injector.markNonceDirty(addr);
            if (self.host) |h| {
                h.setNonce(addr, new_nonce);
            } else if (new_nonce == 0) {
                _ = self.nonces.remove(addr);
            } else {
                try self.nonces.put(addr, new_nonce);
            }
            if (observer) |sink| {
                @branchHint(.unlikely);
                if (before != new_nonce) sink.onNonceChange(.{
                    .frame_id = self.activeFrameId(),
                    .address = addr,
                    .prev_nonce = before,
                    .new_nonce = new_nonce,
                });
            }
        }

        pub fn setCodeWithSnapshot(self: *Self, addr: primitives.Address, new_code: []const u8) !void {
            for (self.code_snapshot_stack.items) |snapshot| {
                if (!snapshot.contains(addr)) {
                    const current_code = self.getRawCode(addr);
                    const current_copy = if (current_code.len > 0)
                        try self.arena.allocator().dupe(u8, current_code)
                    else
                        &[_]u8{};
                    try snapshot.put(addr, current_copy);
                }
            }

            const observer = self.inspector;
            const previous = if (observer != null and observer.?.vtable.onCodeChange != null) blk: {
                const existing = self.getRawCode(addr);
                if (std.mem.eql(u8, existing, new_code)) break :blk null;
                break :blk try self.allocator.dupe(u8, existing);
            } else null;
            defer if (previous) |bytes| self.allocator.free(bytes);
            if (self.pending_storage_injector) |injector| try injector.markCodeDirty(addr);
            if (self.host) |h| {
                h.setCode(addr, new_code);
            } else if (new_code.len == 0) {
                _ = self.code.remove(addr);
            } else {
                const code_copy = try self.arena.allocator().dupe(u8, new_code);
                try self.code.put(addr, code_copy);
            }
            if (previous) |bytes| {
                @branchHint(.unlikely);
                observer.?.onCodeChange(.{
                    .frame_id = self.activeFrameId(),
                    .address = addr,
                    .prev_code = bytes,
                    .new_code = self.getRawCode(addr),
                });
            }
        }

        fn touchCallTarget(self: *Self, addr: primitives.Address) void {
            self.touched_accounts.put(addr, {}) catch {};

            // Before EIP-161, a successful zero-value CALL to an otherwise empty
            // account leaves that empty account in the state trie.
            if (self.hardfork.isBefore(.SPURIOUS_DRAGON)) {
                if (self.host) |h| {
                    h.setBalance(addr, h.getBalance(addr));
                } else if (!self.balances.contains(addr)) {
                    self.balances.put(addr, 0) catch {};
                }
            }
        }

        pub fn accountIsEmpty(self: *Self, addr: primitives.Address) bool {
            const balance = if (self.host) |h| h.getBalance(addr) else self.balances.get(addr) orelse 0;
            const nonce = if (self.host) |h| h.getNonce(addr) else self.nonces.get(addr) orelse 0;
            return balance == 0 and nonce == 0 and self.get_code(addr).len == 0;
        }

        pub fn accountExists(self: *Self, addr: primitives.Address) bool {
            if (self.host) |h| return h.accountExists(addr);
            if (self.get_balance(addr) != 0 or (self.nonces.get(addr) orelse 0) != 0 or self.get_code(addr).len != 0) return true;
            var storage_it = self.storage.storage.iterator();
            while (storage_it.next()) |entry| {
                if (std.mem.eql(u8, &entry.key_ptr.*.address, &addr.bytes)) return true;
            }
            var original_storage_it = self.storage.original_storage.iterator();
            while (original_storage_it.next()) |entry| {
                if (std.mem.eql(u8, &entry.key_ptr.*.address, &addr.bytes)) return true;
            }
            return false;
        }

        fn deleteAccountState(self: *Self, addr: Address) !void {
            const observed = self.inspector;
            const injector = self.pending_storage_injector;
            const tracked = observed != null or injector != null;
            const balance = if (tracked) self.get_balance(addr) else 0;
            const nonce = if (tracked) self.getNonce(addr) else 0;
            const code = if (tracked) self.getRawCode(addr) else &.{};
            const previous_code = if (observed != null and observed.?.vtable.onCodeChange != null and code.len != 0)
                try self.allocator.dupe(u8, code)
            else
                &.{};
            defer self.allocator.free(previous_code);

            if (injector) |active| {
                if (balance != 0) try active.markBalanceDirty(addr);
                if (nonce != 0) try active.markNonceDirty(addr);
                if (code.len != 0) try active.markCodeDirty(addr);
            }
            if (self.host) |h| {
                h.deleteAccount(addr);
            } else {
                var storage_it = self.storage.storage.iterator();
                while (storage_it.next()) |storage_entry| {
                    const key = storage_entry.key_ptr.*;
                    if (std.mem.eql(u8, &key.address, &addr.bytes)) {
                        _ = self.storage.storage.fetchRemove(key);
                    }
                }
                var original_storage_it = self.storage.original_storage.iterator();
                while (original_storage_it.next()) |storage_entry| {
                    const key = storage_entry.key_ptr.*;
                    if (std.mem.eql(u8, &key.address, &addr.bytes)) {
                        _ = self.storage.original_storage.fetchRemove(key);
                    }
                }
                _ = self.balances.fetchRemove(addr);
                _ = self.code.fetchRemove(addr);
                _ = self.nonces.fetchRemove(addr);
            }
            if (observed) |sink| {
                @branchHint(.unlikely);
                const id = self.activeFrameId();
                if (balance != 0) sink.onBalanceChange(.{ .frame_id = id, .address = addr, .prev_balance = balance, .new_balance = 0 });
                if (nonce != 0) sink.onNonceChange(.{ .frame_id = id, .address = addr, .prev_nonce = nonce, .new_nonce = 0 });
                if (previous_code.len != 0) sink.onCodeChange(.{ .frame_id = id, .address = addr, .prev_code = previous_code, .new_code = &.{} });
            }
        }

        fn clearExistingEmptyAccountForCreate(self: *Self, addr: primitives.Address) !void {
            if (!self.accountIsEmpty(addr) or !self.accountExists(addr)) return;
            try self.deleteAccountState(addr);
        }

        fn cleanup_touched_empty_accounts_end_of_tx(self: *Self) !void {
            if (self.hardfork.isBefore(.SPURIOUS_DRAGON)) return;

            var it = self.touched_accounts.iterator();
            while (it.next()) |entry| {
                const addr = entry.key_ptr.*;
                if (isPrecompile(addr, self.hardfork)) continue;
                if (self.accountIsEmpty(addr)) {
                    try self.deleteAccountState(addr);
                }
            }
        }

        fn restore_created_accounts_after_create_failure(
            self: *Self,
            created_snapshot: *const std.AutoHashMap(primitives.Address, void),
        ) !void {
            var created_it = self.created_accounts.iterator();
            while (created_it.next()) |entry| {
                const addr = entry.key_ptr.*;
                if (!created_snapshot.contains(addr)) {
                    try self.deleteAccountState(addr);
                }
            }

            self.created_accounts.clearRetainingCapacity();
            var restore_it = created_snapshot.iterator();
            while (restore_it.next()) |entry| {
                try self.created_accounts.put(entry.key_ptr.*, {});
            }
        }

        /// Pre-warm addresses for transaction initialization
        fn pre_warm_addresses(self: *Self, addresses: []const primitives.Address) !void {
            self.access_list_manager.pre_warm_addresses(addresses) catch {
                return errors.CallError.StorageError;
            };
        }

        /// Get nonce for an address
        pub fn getNonce(self: *Self, address: primitives.Address) u64 {
            if (self.host) |h| {
                return h.getNonce(address);
            }
            return self.nonces.get(address) orelse 0;
        }

        /// Compute CREATE address: keccak256(rlp([sender, nonce]))[12:]
        ///
        /// Calculates the address for a new contract created via CREATE opcode or
        /// contract creation transaction. Uses RLP encoding of [sender_address, nonce]
        /// and takes the last 20 bytes of the keccak256 hash.
        ///
        /// Parameters:
        ///   - sender: Address of the account creating the contract
        ///   - nonce: Nonce value of the sender at creation time
        ///
        /// Returns: The computed contract address
        ///
        /// Errors:
        ///   - OutOfMemory: If RLP buffer allocation fails
        pub fn computeCreateAddress(self: *Self, sender: primitives.Address, nonce: u64) !primitives.Address {
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
            var addr: primitives.Address = undefined;
            @memcpy(&addr.bytes, hash[12..32]);
            return addr;
        }

        /// Compute CREATE2 address: keccak256(0xff ++ sender ++ salt ++ keccak256(init_code))[12:]
        pub fn computeCreate2Address(self: *Self, sender: primitives.Address, salt: u256, init_code: []const u8) !primitives.Address {
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
            var addr: primitives.Address = undefined;
            @memcpy(&addr.bytes, hash[12..32]);
            return addr;
        }

        /// Pre-warm addresses at transaction start (EIP-2929, EIP-3651)
        ///
        /// Marks specific addresses as "warm" before transaction execution begins.
        /// This affects gas costs for subsequent accesses to these addresses.
        ///
        /// Pre-warmed addresses (Berlin+):
        ///   - Transaction origin (sender)
        ///   - Transaction target (if not zero address)
        ///   - Coinbase address (Shanghai+, EIP-3651)
        ///   - All precompile addresses active in the current fork
        ///
        /// Pre-Berlin: No-op (no warm/cold distinction)
        ///
        /// Parameters:
        ///   - target: The transaction target address
        ///
        /// Returns: void
        ///
        /// Errors:
        ///   - StorageError: If warming addresses fails
        pub fn preWarmTransaction(self: *Self, target: primitives.Address) errors.CallError!void {
            // EIP-2929 (Berlin+): Pre-warm addresses at transaction start
            // Pre-Berlin: no warm/cold distinction, so skip this entirely
            if (!self.hardfork.isAtLeast(.BERLIN)) return;

            var warm: [3]primitives.Address = undefined;
            var count: usize = 0;

            warm[count] = self.origin;
            count += 1;

            if (!target.equals(primitives.ZERO_ADDRESS)) {
                warm[count] = target;
                count += 1;
            }

            // EIP-3651 (Shanghai+): Coinbase address is pre-warmed at transaction start
            if (self.hardfork.isAtLeast(.SHANGHAI)) {
                @branchHint(.likely);
                warm[count] = self.block_context.block_coinbase;
                count += 1;
            }

            // Pre-warm origin, target, and coinbase
            try self.pre_warm_addresses(warm[0..count]);

            // Pre-warm precompiles
            // EIP-2929: Precompiles are always warm at transaction start
            // Determine number of precompiles based on hardfork
            // Berlin: 0x01-0x09 (ECRECOVER through BLAKE2F)
            // Cancun+: 0x01-0x0A (10 precompiles, added KZG point evaluation at 0x0A via EIP-4844)
            // Prague+: 0x01-0x13 (standard BLS12-381 precompile table in Voltaire)
            const precompile_count: usize = if (self.hardfork.isAtLeast(.PRAGUE))
                0x13 // Prague: All precompiles including BLS12-381
            else if (self.hardfork.isAtLeast(.CANCUN))
                0x0A // Cancun: Includes KZG point evaluation
            else
                0x09; // Berlin: Up to BLAKE2F

            var precompile_addrs: [0x13]primitives.Address = undefined;
            var i: usize = 0;
            while (i < precompile_count) : (i += 1) {
                precompile_addrs[i] = primitives.Address.fromU256(i + 1);
            }
            try self.pre_warm_addresses(precompile_addrs[0..precompile_count]);
            if (isPrecompile(p256verify_address, self.hardfork)) {
                try self.pre_warm_addresses(&.{p256verify_address});
            }
        }

        /// Set bytecode for the next call() invocation
        pub fn setBytecode(self: *Self, bytecode: []const u8) void {
            self.pending_bytecode = bytecode;
        }

        /// Set access list for the next call() invocation
        pub fn setAccessList(self: *Self, access_list: ?primitives.AccessList.AccessList) void {
            self.pending_access_list = access_list;
        }

        /// Set blob versioned hashes for the next call() invocation
        pub fn setBlobVersionedHashes(self: *Self, hashes: []const [32]u8) void {
            self.blob_versioned_hashes = hashes;
        }

        /// Execute a transaction's message. Intrinsic gas and fee settlement are caller-owned.
        pub fn call(self: *Self, params: CallParams) CallResult {
            return self.callWithBytecodeOverride(params, null);
        }

        /// Override the root message's code for this execution only.
        pub fn callWithBytecodeOverride(self: *Self, params: CallParams, bytecode: ?[]const u8) CallResult {
            const target: anyerror!Address = blk: {
                params.validateForHardfork(self.hardfork) catch |err| break :blk err;
                if (params.get_to()) |address| break :blk address;
                break :blk self.createAddress(self.origin, self.getNonce(self.origin), params.getInput(), createSalt(params), true);
            };
            const observer = self.inspector;
            const value = callValue(params);
            if (observer) |sink| self.notifyTxStart(sink, params, target catch primitives.ZERO_ADDRESS, value);
            const result = self.callTransaction(params, value, target, bytecode);
            if (observer) |sink| notifyTxEnd(sink, params.getGas(), result);
            return result;
        }

        fn notifyTxStart(self: *Self, sink: inspector_mod.Inspector, params: CallParams, target: Address, value: u256) void {
            sink.onTxStart(.{
                .hardfork = self.hardfork,
                .origin = self.origin,
                .target = target,
                .coinbase = self.block_context.block_coinbase,
                .is_create = params.isCreate(),
                .value = value,
                .gas_limit = params.getGas(),
                .gas_price = self.gas_price,
                .input = params.getInput(),
                .block_number = self.block_context.block_number,
                .block_timestamp = self.block_context.block_timestamp,
                .chain_id = self.block_context.chain_id,
                .blob_base_fee = self.block_context.blob_base_fee,
                .blob_hash_count = self.blob_versioned_hashes.len,
            });
        }

        fn notifyTxEnd(sink: inspector_mod.Inspector, gas_limit: u64, result: CallResult) void {
            sink.onTxEnd(.{
                .success = result.success,
                .gas_used = gas_limit -| result.gas_left,
                .gas_left = result.gas_left,
                .gas_refund = result.refund_counter,
                .output = result.output,
                .error_name = resultErrorName(result),
                .created_address = result.created_address,
            });
        }

        fn callValue(params: CallParams) u256 {
            return switch (params) {
                .call => |p| p.value,
                .callcode => |p| p.value,
                .create => |p| p.value,
                .create2 => |p| p.value,
                .delegatecall, .staticcall => 0,
            };
        }

        fn createSalt(params: CallParams) ?u256 {
            return if (params == .create2) params.create2.salt else null;
        }

        fn callTransaction(self: *Self, params: CallParams, value: u256, target: anyerror!Address, bytecode: ?[]const u8) CallResult {
            const address = target catch |err| return self.failed(0, err);
            const gas = params.getGas();
            const calldata = params.getInput();
            const access_list = self.pending_access_list;
            const blob_versioned_hashes = if (self.blob_versioned_hashes.len > 0) self.blob_versioned_hashes else null;

            self.initTransactionState(blob_versioned_hashes) catch |err| return self.failed(0, err);
            self.preWarmTransaction(address) catch |err| return self.failed(0, err);
            if (access_list) |list| {
                self.access_list_manager.pre_warm_from_access_list(list) catch |err| return self.failed(0, err);
            }

            if (params.isCreate()) {
                const created = self.createAtAddress(value, calldata, gas, createSalt(params), address) catch |err| return self.failed(0, err);
                var result = if (created.success)
                    CallResult.success_with_logs(self.arena.allocator(), created.gas_left, created.output, self.logs.items) catch |err| return self.failed(0, err)
                else
                    CallResult.revert_with_data(self.arena.allocator(), created.gas_left, created.output) catch |err| return self.failed(created.gas_left, err);
                if (created.err) |err| result.error_info = self.arena.allocator().dupe(u8, @errorName(err)) catch null;
                result.refund_counter = self.gas_refund;
                if (created.success) result.created_address = created.address;
                self.finishTransaction() catch |err| return self.failed(0, err);
                return result;
            }

            const resolved = self.resolveCodeBytes(address, bytecode orelse self.getRawCode(address));
            // EIP-7702: the destination's delegate is warm for the whole
            // transaction (prague `process_message_call`).
            if (resolved.is_delegated) self.pre_warm_addresses(&.{resolved.address}) catch |err| return self.failed(0, err);
            const is_static = params == .staticcall;
            const observed = self.enterCall(params, params.getCaller(), resolved, value, is_static);
            const result = self.executeTopCall(params, address, resolved, value, is_static, observed);
            if (observed) |observation| self.exitFrame(observation, result, resultErrorName(result));
            return result;
        }

        fn finishTransaction(self: *Self) !void {
            self.access_list_manager.clear();
            self.storage.clear_transient();
            self.logs.clearRetainingCapacity();
            try self.cleanup_selfdestructed_accounts_end_of_tx();
            try self.cleanup_touched_empty_accounts_end_of_tx();
            self.created_accounts.clearRetainingCapacity();
            self.selfdestructed_accounts.clearRetainingCapacity();
            self.touched_accounts.clearRetainingCapacity();
        }

        fn executeTopCall(self: *Self, params: CallParams, address: Address, resolved: ResolvedCode, value: u256, is_static: bool, observed: ?ObservedFrame) CallResult {
            const caller = params.getCaller();
            const calldata = params.getInput();
            const gas = params.getGas();
            const frame_gas = std.math.cast(i64, gas) orelse return self.failed(0, error.OutOfGas);
            const transfer = self.host != null and value != 0;
            const sender_balance = if (transfer) self.get_balance(caller) else 0;
            if (transfer and sender_balance < value) return self.failed(0, error.InsufficientBalance);
            const recipient_balance = if (transfer) self.get_balance(address) else 0;
            const moved = transfer and !caller.equals(address);
            if (moved) {
                self.setBalanceWithSnapshot(caller, sender_balance - value) catch |err| return self.failed(0, err);
                self.setBalanceWithSnapshot(address, recipient_balance + value) catch |err| {
                    self.host.?.setBalance(caller, sender_balance);
                    return self.failed(0, err);
                };
            }

            const checkpoint = self.captureTopCheckpoint() catch |err| {
                if (moved) {
                    self.host.?.setBalance(caller, sender_balance);
                    self.host.?.setBalance(address, recipient_balance);
                }
                return self.failed(0, err);
            };
            defer checkpoint.release(self);

            var result = self.executeTopMessage(params, address, resolved, frame_gas, calldata, value, is_static, observed);
            if (!result.success) {
                // Undo every write the root frame and its successful children made
                // directly to the host, as a nested revert does.
                checkpoint.restore(self) catch |err| {
                    result = self.failed(0, err);
                };
            }
            if (!result.success and moved) {
                self.host.?.setBalance(caller, sender_balance);
                self.host.?.setBalance(address, recipient_balance);
            }
            if (result.success or result.error_info == null) {
                self.finishTransaction() catch |err| return self.failed(0, err);
            }
            return result;
        }

        fn executeTopMessage(self: *Self, params: CallParams, address: Address, resolved: ResolvedCode, gas: i64, calldata: []const u8, value: u256, is_static: bool, observed: ?ObservedFrame) CallResult {
            if (resolved.code.len == 0) {
                var result = self.executePrecompile(address, resolved, calldata, @intCast(gas)) orelse CallResult{
                    .success = true,
                    .gas_left = @intCast(gas),
                    .output = &.{},
                };
                if (result.success) self.touchCallTarget(address);
                result.refund_counter = self.gas_refund;
                return result;
            }

            const frame = FrameType.init(self.arena.allocator(), resolved.code, gas, params.getCaller(), address, value, calldata, self, self.hardfork, is_static) catch |err| return self.failed(0, err);
            self.frames.append(self.arena.allocator(), frame) catch |err| return self.failed(0, err);
            defer _ = self.frames.pop();
            self.attachFrame(observed, resolved.address);

            self.frames.items[self.frames.items.len - 1].execute() catch |err| return self.failed(0, err);
            const finished = &self.frames.items[self.frames.items.len - 1];
            const gas_left: u64 = @intCast(@max(finished.gas_remaining, 0));
            if (finished.reverted) {
                return CallResult.revert_with_data(self.arena.allocator(), gas_left, finished.output) catch |err| return self.failed(0, err);
            }
            var result = CallResult.success_with_logs(self.arena.allocator(), gas_left, finished.output, self.logs.items) catch |err| return self.failed(0, err);
            result.refund_counter = self.gas_refund;
            return result;
        }

        /// Main async execution method - supports yielding for async requests
        /// CRITICAL: NO defer statements that clean up state!
        /// This wraps call() but supports yielding for async data requests
        pub fn callOrContinue(
            self: *Self,
            input: CallOrContinueInput,
        ) !CallOrContinueOutput {
            // Initialize async executor on first use
            if (self.async_executor == null) {
                self.async_executor = AsyncExecutorType.init(self);
            }

            return self.async_executor.?.callOrContinue(input) catch |err| {
                self.finishAsyncObservation(.{ .success = false, .gas_left = 0, .output = &.{}, .error_info = @errorName(err) });
                return err;
            };
        }

        pub fn startAsyncObservation(self: *Self, params: CallParams, address: Address, bytecode: []const u8) void {
            const sink = self.inspector orelse return;
            const value = callValue(params);
            self.notifyTxStart(sink, params, address, value);
            self.async_observation = self.enterCall(params, params.getCaller(), .{ .code = bytecode, .address = address }, value, params == .staticcall);
        }

        pub fn attachAsyncFrame(self: *Self, address: Address) void {
            self.attachFrame(self.async_observation, address);
        }

        fn finishAsyncObservation(self: *Self, result: CallResult) void {
            const observed = self.async_observation orelse return;
            self.async_observation = null;
            self.exitFrame(observed, result, resultErrorName(result));
            notifyTxEnd(observed.sink, observed.gas, result);
        }

        /// Execute until we hit a yield point or complete
        /// NO defer statements!
        pub fn executeUntilYieldOrComplete(self: *Self) !CallOrContinueOutput {
            while (self.frames.items.len > 0) {
                const frame = &self.frames.items[self.frames.items.len - 1];

                // Execute frame - may return error.NeedAsyncData
                frame.execute() catch |err| {
                    if (err == error.NeedAsyncData) {
                        // Read the request from evm.async_data_request
                        return switch (self.storage.async_data_request) {
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
                if (self.frames.items.len == 1 and self.storage.storage_injector != null) {
                    log.debug("executeUntilYieldOrComplete: Last frame, dumping changes", .{});
                    // Don't pop yet - need to dump changes first
                    const changes_json = try self.dumpStateChanges();
                    log.debug("executeUntilYieldOrComplete: changes_json.len = {}", .{changes_json.len});
                    return .{ .ready_to_commit = .{ .changes_json = changes_json } };
                }

                // Keep the root frame alive until its output and gas have been read.
                if (self.frames.items.len == 1) break;
                _ = self.frames.pop();
            }

            // All frames complete, no storage injector
            return try self.finalizeAndReturnResult();
        }

        /// Finalize execution and return result
        /// Called only when we're truly done (after commit if needed)
        pub fn finalizeAndReturnResult(self: *Self) !CallOrContinueOutput {
            // At this point frames should be empty OR we have one frame to finalize
            if (self.frames.items.len > 0) {
                const frame = self.frames.items[self.frames.items.len - 1];
                const output = try self.arena.allocator().dupe(u8, frame.output);
                const gas_left = @as(u64, @intCast(@max(frame.gas_remaining, 0)));
                const success = !frame.reverted;

                // NOW we can pop (we're returning the final result)
                _ = self.frames.pop();

                // Clean up transaction state (safe now)
                self.access_list_manager.clear();
                self.storage.clear_transient();

                const result: CallResult = .{
                    .success = success,
                    .gas_left = gas_left,
                    .output = output,
                    .refund_counter = self.gas_refund,
                };
                self.finishAsyncObservation(result);
                self.pending_state_changes = &.{};
                self.pending_state_changes_len = 0;
                return .{ .result = result };
            }

            return .{ .result = CallResult{
                .success = true,
                .gas_left = 0,
                .output = &.{},
                .refund_counter = self.gas_refund,
            } };
        }

        /// Dump state changes to JSON
        pub fn dumpStateChanges(self: *Self) ![]const u8 {
            if (self.storage.storage_injector) |injector| {
                const result = try injector.dumpChanges(self);
                log.debug("dumpStateChanges: Got {} bytes from injector", .{result.len});
                // Copy into an arena-allocated buffer sized to fit (persists for the tx; no
                // truncation). Falls back to the raw result if allocation fails.
                const buf = self.arena.allocator().alloc(u8, result.len) catch {
                    self.pending_state_changes = result;
                    self.pending_state_changes_len = result.len;
                    return result;
                };
                @memcpy(buf, result);
                self.pending_state_changes = buf;
                self.pending_state_changes_len = buf.len;
                return self.pending_state_changes;
            }
            log.debug("dumpStateChanges: No injector, returning empty", .{});
            self.pending_state_changes = &.{};
            self.pending_state_changes_len = 0;
            return &.{};
        }

        /// Delete accounts marked via SELFDESTRUCT at end of transaction (EIP-6780).
        /// Handles both host-backed and in-memory modes. Must be called only after
        /// transient storage is cleared and logs are finalized.
        fn cleanup_selfdestructed_accounts_end_of_tx(self: *Self) !void {
            var it = self.selfdestructed_accounts.iterator();
            while (it.next()) |entry| {
                const addr = entry.key_ptr.*;
                try self.deleteAccountState(addr);
            }
            self.selfdestructed_accounts.clearRetainingCapacity();
        }

        /// Revert state for the root message frame. Nested frames build the same
        /// snapshots inline in `executeInnerCall`.
        const TopCheckpoint = struct {
            refund: u64,
            access_list: AccessListSnapshot,
            original_storage: std.AutoHashMap(StorageKey, u256),
            storage: std.AutoHashMap(StorageKey, u256),
            balances: std.AutoHashMap(primitives.Address, u256),
            nonces: std.AutoHashMap(primitives.Address, u64),
            code: std.AutoHashMap(primitives.Address, []const u8),
            transient: std.AutoHashMap(StorageKey, u256),
            selfdestructed: std.AutoHashMap(primitives.Address, void),
            created: std.AutoHashMap(primitives.Address, void),

            fn restore(cp: *TopCheckpoint, evm: *Self) !void {
                try evm.restore_call_revert_state(
                    cp.refund,
                    &cp.access_list,
                    &cp.original_storage,
                    &cp.storage,
                    &cp.balances,
                    &cp.nonces,
                    &cp.code,
                    &cp.transient,
                    &cp.selfdestructed,
                    &cp.created,
                );
            }

            /// Pops the copy-on-write snapshot stacks. Map memory lives in the arena.
            fn release(cp: *TopCheckpoint, evm: *Self) void {
                cp.access_list.deinit();
                _ = evm.balance_snapshot_stack.pop();
                _ = evm.nonce_snapshot_stack.pop();
                _ = evm.code_snapshot_stack.pop();
            }
        };

        /// Allocated in the arena because the snapshot stacks hold pointers into it.
        fn captureTopCheckpoint(self: *Self) !*TopCheckpoint {
            const arena = self.arena.allocator();
            const cp = try arena.create(TopCheckpoint);
            cp.* = .{
                .refund = self.gas_refund,
                .access_list = try self.access_list_manager.snapshot(),
                .original_storage = try self.storage.original_storage.cloneWithAllocator(arena),
                .storage = std.AutoHashMap(StorageKey, u256).init(arena),
                .balances = std.AutoHashMap(primitives.Address, u256).init(arena),
                .nonces = std.AutoHashMap(primitives.Address, u64).init(arena),
                .code = std.AutoHashMap(primitives.Address, []const u8).init(arena),
                .transient = try self.storage.transient.cloneWithAllocator(arena),
                .selfdestructed = try self.selfdestructed_accounts.cloneWithAllocator(arena),
                .created = try self.created_accounts.cloneWithAllocator(arena),
            };
            errdefer cp.access_list.deinit();
            if (self.host) |h| {
                var it = self.storage.original_storage.keyIterator();
                while (it.next()) |key| {
                    try cp.storage.put(key.*, h.getStorage(.{ .bytes = key.address }, key.slot));
                }
            }
            if (self.host == null or self.storage.storage_injector != null) {
                var it = self.storage.storage.iterator();
                while (it.next()) |entry| try cp.storage.put(entry.key_ptr.*, entry.value_ptr.*);
            }
            try self.balance_snapshot_stack.ensureUnusedCapacity(arena, 1);
            try self.nonce_snapshot_stack.ensureUnusedCapacity(arena, 1);
            try self.code_snapshot_stack.ensureUnusedCapacity(arena, 1);
            self.balance_snapshot_stack.appendAssumeCapacity(&cp.balances);
            self.nonce_snapshot_stack.appendAssumeCapacity(&cp.nonces);
            self.code_snapshot_stack.appendAssumeCapacity(&cp.code);
            return cp;
        }

        fn restore_call_revert_state(
            self: *Self,
            refund_snapshot: u64,
            access_list_snapshot: *const AccessListSnapshot,
            original_storage_snapshot: *const std.AutoHashMap(StorageKey, u256),
            storage_snapshot: *const std.AutoHashMap(StorageKey, u256),
            balance_snapshot: *const std.AutoHashMap(primitives.Address, u256),
            nonce_snapshot: *const std.AutoHashMap(primitives.Address, u64),
            code_snapshot: *const std.AutoHashMap(primitives.Address, []const u8),
            transient_snapshot: *const std.AutoHashMap(StorageKey, u256),
            selfdestruct_snapshot: *const std.AutoHashMap(primitives.Address, void),
            created_accounts_snapshot: *const std.AutoHashMap(primitives.Address, void),
        ) !void {
            // Restore gas refunds on failure
            // Per Python: incorporate_child_on_error does NOT add child's refund_counter
            self.gas_refund = refund_snapshot;

            // Restore warm addresses and storage slots on failure (EIP-2929)
            try self.access_list_manager.restore(access_list_snapshot.*);

            // Restore storage on failure
            // IMPORTANT: Identify slots to delete BEFORE restoring original_storage
            // First, identify slots that were added during the call (exist in original_storage but not in snapshot)
            const AddedStorageSlot = struct {
                key: StorageKey,
                original_value: u256,
            };
            var added_slots = std.ArrayList(AddedStorageSlot){};
            try added_slots.ensureTotalCapacity(self.arena.allocator(), 10);
            var orig_check_it = self.storage.original_storage.iterator();
            while (orig_check_it.next()) |entry| {
                if (!original_storage_snapshot.contains(entry.key_ptr.*)) {
                    try added_slots.append(self.arena.allocator(), .{
                        .key = entry.key_ptr.*,
                        .original_value = entry.value_ptr.*,
                    });
                }
            }

            // Second, restore original_storage to remove entries added during the call
            self.storage.original_storage.clearRetainingCapacity();
            var original_storage_restore_it = original_storage_snapshot.iterator();
            while (original_storage_restore_it.next()) |entry| {
                try self.storage.original_storage.put(entry.key_ptr.*, entry.value_ptr.*);
            }

            // Third, restore storage values from snapshot
            var storage_restore_it = storage_snapshot.iterator();
            while (storage_restore_it.next()) |entry| {
                if (self.host) |h| {
                    const addr = primitives.Address{ .bytes = entry.key_ptr.*.address };
                    h.setStorage(addr, entry.key_ptr.*.slot, entry.value_ptr.*);
                }
                if (self.host == null or self.storage.storage_injector != null) {
                    try self.storage.storage.put(entry.key_ptr.*, entry.value_ptr.*);
                }
            }

            // Fourth, delete slots that were added during the call
            for (added_slots.items) |slot| {
                const slot_key = slot.key;
                if (self.host) |h| {
                    h.setStorage(Address{ .bytes = slot_key.address }, slot_key.slot, slot.original_value);
                }
                if (self.host == null or self.storage.storage_injector != null) {
                    if (slot.original_value == 0 and self.storage.storage_injector == null) {
                        _ = self.storage.storage.remove(slot_key);
                    } else {
                        try self.storage.storage.put(slot_key, slot.original_value);
                    }
                }
            }

            // Restore transient storage on failure (EIP-1153)
            self.storage.clear_transient();
            var restore_it = transient_snapshot.iterator();
            while (restore_it.next()) |entry| {
                try self.storage.transient.put(entry.key_ptr.*, entry.value_ptr.*);
            }

            // Restore selfdestructed_accounts on failure (EIP-6780)
            // This ensures that SELFDESTRUCT operations in reverted calls don't affect the final state
            self.selfdestructed_accounts.clearRetainingCapacity();
            var restore_selfdestruct_it = selfdestruct_snapshot.iterator();
            while (restore_selfdestruct_it.next()) |entry| {
                try self.selfdestructed_accounts.put(entry.key_ptr.*, {});
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

            var nonce_restore_it = nonce_snapshot.iterator();
            while (nonce_restore_it.next()) |entry| {
                if (self.host) |h| {
                    h.setNonce(entry.key_ptr.*, entry.value_ptr.*);
                } else if (entry.value_ptr.* == 0) {
                    _ = self.nonces.remove(entry.key_ptr.*);
                } else {
                    try self.nonces.put(entry.key_ptr.*, entry.value_ptr.*);
                }
            }

            var code_restore_it = code_snapshot.iterator();
            while (code_restore_it.next()) |entry| {
                if (self.host) |h| {
                    h.setCode(entry.key_ptr.*, entry.value_ptr.*);
                } else if (entry.value_ptr.*.len == 0) {
                    _ = self.code.remove(entry.key_ptr.*);
                } else {
                    try self.code.put(entry.key_ptr.*, entry.value_ptr.*);
                }
            }

            self.created_accounts.clearRetainingCapacity();
            var restore_created_it = created_accounts_snapshot.iterator();
            while (restore_created_it.next()) |entry| {
                try self.created_accounts.put(entry.key_ptr.*, {});
            }
        }

        /// Handle inner call from frame (like evm.inner_call)
        /// Execute a nested EVM call - used for calls from within the EVM (e.g., CALL, DELEGATECALL opcodes).
        /// This handles nested calls and manages depth tracking.
        /// Follows the same API pattern as guillotine performance EVM.
        pub fn inner_call(self: *Self, params: CallParams) CallResult {
            const address = params.get_to().?;
            const resolved = self.resolveCode(address);
            const parent = self.getCurrentFrame();
            const caller = if (parent) |frame| frame.address else self.origin;
            const is_static = params == .staticcall or (parent != null and parent.?.is_static);
            const value = if (params == .delegatecall and parent != null) parent.?.value else callValue(params);
            const observed = self.enterCall(params, caller, resolved, value, is_static);
            const result = self.executeInnerCall(params, resolved, value, is_static, observed);
            if (observed) |observation| self.exitFrame(observation, result, resultErrorName(result));
            return result;
        }

        fn executeInnerCall(self: *Self, params: CallParams, resolved: ResolvedCode, value: u256, is_static: bool, observed: ?ObservedFrame) CallResult {
            const address = params.get_to().?;
            const input: []const u8 = params.getInput();
            const gas: u64 = params.getGas();

            const call_type = callType(params);
            // The top-level transaction frame is not counted toward the message-call depth limit.
            if (self.frames.items.len > config.max_call_depth) {
                return self.failed(gas, error.callDepthExceeded);
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
            const logs_len_snapshot = self.logs.items.len;

            // Snapshot transient storage before the call (EIP-1153)
            // Transient storage must be reverted on call failure
            var transient_snapshot = std.AutoHashMap(StorageKey, u256).init(self.arena.allocator());
            var it = self.storage.transient.iterator();
            while (it.next()) |entry| {
                transient_snapshot.put(entry.key_ptr.*, entry.value_ptr.*) catch |err| {
                    // Memory allocation failed during snapshot - fail the call
                    return self.failed(gas, err);
                };
            }

            // Snapshot selfdestructed_accounts before the call (EIP-6780 revert handling)
            // On revert, accounts marked for deletion during the reverted call must be removed
            var selfdestruct_snapshot = std.AutoHashMap(primitives.Address, void).init(self.arena.allocator());
            var selfdestruct_it = self.selfdestructed_accounts.iterator();
            while (selfdestruct_it.next()) |entry| {
                selfdestruct_snapshot.put(entry.key_ptr.*, {}) catch |err| {
                    // Memory allocation failed during snapshot - fail the call
                    return self.failed(gas, err);
                };
            }

            var created_accounts_snapshot = std.AutoHashMap(primitives.Address, void).init(self.arena.allocator());
            var created_accounts_it = self.created_accounts.iterator();
            while (created_accounts_it.next()) |entry| {
                created_accounts_snapshot.put(entry.key_ptr.*, {}) catch |err| {
                    return self.failed(gas, err);
                };
            }

            // Snapshot warm addresses and storage slots before the call (EIP-2929)
            // Per Python reference (incorporate_child_on_error), accessed_addresses
            // and accessed_storage_keys are only propagated on success, not on failure
            var access_list_snapshot = self.access_list_manager.snapshot() catch |err| {
                return self.failed(gas, err);
            };
            defer access_list_snapshot.deinit();

            // Snapshot original_storage before the call
            // This is critical for correct SSTORE gas calculation after reverts
            // When a call reverts, any entries added to original_storage during that call
            // must be removed, otherwise subsequent SSTOREs will use stale original values
            // and incorrectly calculate gas costs and refunds
            var original_storage_snapshot = std.AutoHashMap(StorageKey, u256).init(self.arena.allocator());
            var original_storage_it = self.storage.original_storage.iterator();
            while (original_storage_it.next()) |entry| {
                original_storage_snapshot.put(entry.key_ptr.*, entry.value_ptr.*) catch |err| {
                    return self.failed(gas, err);
                };
            }

            // Snapshot storage before the call
            // We need to track which slots existed and their values
            // On revert, we restore to this exact state (remove new slots, restore modified slots)
            var storage_snapshot = std.AutoHashMap(StorageKey, u256).init(self.arena.allocator());
            if (self.host) |h| {
                // In host mode, we need to ask the host for current storage values
                // But we don't have a way to enumerate all slots, so we track what we've seen
                // For now, we'll snapshot original_storage keys since those are the accessed slots
                var orig_it = self.storage.original_storage.iterator();
                while (orig_it.next()) |entry| {
                    const addr = primitives.Address.Address{ .bytes = entry.key_ptr.*.address };
                    const current_val = h.getStorage(addr, entry.key_ptr.*.slot);
                    storage_snapshot.put(entry.key_ptr.*, current_val) catch |err| {
                        return self.failed(gas, err);
                    };
                }
            }
            if (self.host == null or self.storage.storage_injector != null) {
                var storage_it = self.storage.storage.iterator();
                while (storage_it.next()) |entry| {
                    storage_snapshot.put(entry.key_ptr.*, entry.value_ptr.*) catch |err| {
                        return self.failed(gas, err);
                    };
                }
            }

            // Snapshot balances before the call (for SELFDESTRUCT revert handling)
            // We use copy-on-write: addresses are snapshotted when first modified via setBalanceWithSnapshot
            var balance_snapshot = std.AutoHashMap(primitives.Address, u256).init(self.arena.allocator());
            var nonce_snapshot = std.AutoHashMap(primitives.Address, u64).init(self.arena.allocator());
            var code_snapshot = std.AutoHashMap(primitives.Address, []const u8).init(self.arena.allocator());

            // Push the snapshot onto the stack so nested calls can snapshot in parent snapshots
            self.balance_snapshot_stack.append(self.arena.allocator(), &balance_snapshot) catch |err| {
                return self.failed(gas, err);
            };
            defer _ = self.balance_snapshot_stack.pop();
            self.nonce_snapshot_stack.append(self.arena.allocator(), &nonce_snapshot) catch |err| {
                return self.failed(gas, err);
            };
            defer _ = self.nonce_snapshot_stack.pop();
            self.code_snapshot_stack.append(self.arena.allocator(), &code_snapshot) catch |err| {
                return self.failed(gas, err);
            };
            defer _ = self.code_snapshot_stack.pop();

            const execution_caller: primitives.Address = switch (call_type) {
                .call, .staticcall => frame_caller,
                .delegatecall => frame_caller_caller,
                .callcode => frame_caller,
                else => unreachable,
            };

            const execution_address: primitives.Address = switch (call_type) {
                .call, .staticcall => address,
                .delegatecall, .callcode => frame_caller,
                else => unreachable,
            };

            // Handle balance transfer if value > 0 (only for regular CALL)
            if (value > 0 and call_type == .call) {
                const caller_balance = if (self.host) |h| h.getBalance(frame_caller) else self.balances.get(frame_caller) orelse 0;
                if (caller_balance < value) {
                    // Insufficient balance - call fails
                    return self.failed(gas, error.InsufficientBalance);
                }

                // Transfer balance using snapshot mechanism for proper revert handling
                self.setBalanceWithSnapshot(frame_caller, caller_balance - value) catch |err| {
                    return self.failed(gas, err);
                };
                const callee_balance = if (self.host) |h| h.getBalance(address) else self.balances.get(address) orelse 0;
                self.setBalanceWithSnapshot(address, callee_balance + value) catch |err| {
                    return self.failed(gas, err);
                };
            }

            if (value > 0 and call_type == .callcode) {
                const current_balance = if (self.host) |h| h.getBalance(frame_caller) else self.balances.get(frame_caller) orelse 0;
                if (current_balance < value) return self.failed(gas, error.InsufficientBalance);
            }

            const code = resolved.code;
            if (code.len == 0) {
                const result = self.executePrecompile(address, resolved, input, gas) orelse CallResult{
                    .success = true,
                    .gas_left = gas,
                    .output = &.{},
                };
                if (result.success) {
                    if (call_type == .call) self.touchCallTarget(address);
                } else {
                    self.restore_call_revert_state(
                        refund_snapshot,
                        &access_list_snapshot,
                        &original_storage_snapshot,
                        &storage_snapshot,
                        &balance_snapshot,
                        &nonce_snapshot,
                        &code_snapshot,
                        &transient_snapshot,
                        &selfdestruct_snapshot,
                        &created_accounts_snapshot,
                    ) catch |err| return self.failed(0, err);
                }
                return result;
            }

            // Safely cast gas to i64 - if it exceeds i64::MAX, cap it (shouldn't happen in practice)
            const frame_gas = std.math.cast(i64, gas) orelse std.math.maxInt(i64);
            self.frames.append(self.arena.allocator(), FrameType.init(
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
            ) catch |err| {
                return self.failed(0, err);
            }) catch |err| {
                return self.failed(0, err);
            };
            defer _ = self.frames.pop();
            self.attachFrame(observed, resolved.address);

            // Execute frame (don't cache pointer - it may become invalid during nested calls)
            self.frames.items[self.frames.items.len - 1].execute() catch |err| {
                self.logs.shrinkRetainingCapacity(logs_len_snapshot);

                self.restore_call_revert_state(
                    refund_snapshot,
                    &access_list_snapshot,
                    &original_storage_snapshot,
                    &storage_snapshot,
                    &balance_snapshot,
                    &nonce_snapshot,
                    &code_snapshot,
                    &transient_snapshot,
                    &selfdestruct_snapshot,
                    &created_accounts_snapshot,
                ) catch |restore_err| {
                    return self.failed(0, restore_err);
                };

                return self.failed(0, err);
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
            if (result.success and call_type == .call) self.touchCallTarget(address);
            // Restore revert-only state
            if (frame.reverted) {
                self.logs.shrinkRetainingCapacity(logs_len_snapshot);
                self.restore_call_revert_state(
                    refund_snapshot,
                    &access_list_snapshot,
                    &original_storage_snapshot,
                    &storage_snapshot,
                    &balance_snapshot,
                    &nonce_snapshot,
                    &code_snapshot,
                    &transient_snapshot,
                    &selfdestruct_snapshot,
                    &created_accounts_snapshot,
                ) catch |err| {
                    return self.failed(0, err);
                };
            }

            // No cleanup needed - arena handles it
            return result;
        }

        pub const CreateResult = struct {
            address: Address = primitives.ZERO_ADDRESS,
            success: bool = false,
            gas_left: u64 = 0,
            output: []const u8 = &.{},
            err: ?errors.CallError = null,
        };

        fn createAddress(self: *Self, caller: Address, nonce: u64, init_code: []const u8, salt: ?u256, top_level: bool) !Address {
            if (salt) |value| return self.computeCreate2Address(caller, value, init_code);
            return self.computeCreateAddress(caller, if (top_level) nonce -| 1 else nonce);
        }

        /// Handle CREATE and CREATE2 from an active frame or a transaction runner.
        pub fn inner_create(self: *Self, value: u256, init_code: []const u8, gas: u64, salt: ?u256) errors.CallError!CreateResult {
            const caller = if (self.getCurrentFrame()) |frame| frame.address else self.origin;
            const address = try self.createAddress(caller, self.getNonce(caller), init_code, salt, self.frames.items.len == 0);
            return self.createAtAddress(value, init_code, gas, salt, address);
        }

        fn createAtAddress(self: *Self, value: u256, init_code: []const u8, gas: u64, salt: ?u256, address: Address) errors.CallError!CreateResult {
            const caller = if (self.getCurrentFrame()) |frame| frame.address else self.origin;
            const early = self.beginCreate(caller, address, value, init_code, gas);
            const observed = if (self.inspector != null) self.enterFrame(.{
                .frame_id = 0,
                .parent_id = null,
                .depth = 0,
                .call_type = if (salt != null) .create2 else .create,
                .from = caller,
                .to = address,
                .code_address = address,
                .value = value,
                .gas = gas,
                .input = init_code,
                .is_static = false,
                .is_precompile = false,
                .is_delegated = false,
                .code = init_code,
            }) else null;
            const outcome: errors.CallError!CreateResult = if (early) |maybe_result|
                maybe_result orelse self.executeCreate(caller, address, value, init_code, gas, observed)
            else |err|
                err;
            if (observed) |observation| {
                @branchHint(.unlikely);
                const created = outcome catch |err| CreateResult{ .err = err };
                const failure = if (created.success) null else inspector_mod.formatErrorName(created.err orelse error.RevertExecution);
                self.exitFrame(observation, .{
                    .success = created.success,
                    .gas_left = created.gas_left,
                    .output = if (created.success) self.getRawCode(address) else created.output,
                    .created_address = if (created.success) address else null,
                }, failure);
            }
            return outcome;
        }

        /// Checks that run, and the creator nonce bump that persists, before the
        /// CREATE frame is entered. A non-null result ends the CREATE early.
        /// Inspectors see the creator nonce change in the parent frame, so a
        /// failed initcode does not roll it back.
        fn beginCreate(self: *Self, caller: Address, new_address: Address, value: u256, init_code: []const u8, gas: u64) errors.CallError!?CreateResult {
            const is_top_level_create = self.frames.items.len == 0;
            // The root transaction frame is excluded from the message-call depth limit.
            if (self.frames.items.len > config.max_call_depth) return .{ .gas_left = gas, .err = error.CallDepthExceeded };
            const sender_nonce = self.getNonce(caller);
            if (sender_nonce == std.math.maxInt(u64)) return .{ .gas_left = gas, .err = error.NonceOverflow };
            if (value > 0 and self.get_balance(caller) < value) return .{ .gas_left = gas, .err = error.InsufficientBalance };

            // EIP-3860: Check init code size limit (Shanghai and later)
            // Per Python reference (system.py:81-82): This check happens IMMEDIATELY after reading call_data
            // and BEFORE any nonce increments or child call gas calculation
            // When this check fails, it raises OutOfGasError in the PARENT frame (the frame executing CREATE)
            // This halts the entire parent frame, not just the CREATE operation
            if (self.hardfork.isAtLeast(.SHANGHAI)) {
                if (init_code.len > config.max_initcode_size) {
                    // Per Python reference: OutOfGasError is raised, halting the parent frame
                    // The initcode gas was already charged in frame.zig
                    return error.OutOfGas;
                }
            }

            // EIP-3860 initcode cost is charged in two different places depending on context:
            // 1. For top-level creates (contract creation transactions): charged in transaction intrinsic gas
            // 2. For CREATE/CREATE2 opcodes: charged in frame.zig before calling inner_create
            // Therefore, DO NOT charge it again here for top-level creates
            if (std.math.cast(i64, gas) == null) return error.OutOfGas;

            // EIP-2929 (Berlin): Mark created address as warm
            // Per Python reference: accessed_addresses.add(contract_address) happens
            // BEFORE collision check and nonce increment
            _ = try self.accessAddress(new_address);

            // Check for address collision (code or nonce already exists)
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

                    try self.setNonceWithSnapshot(caller, caller_nonce + 1);
                }

                // Per Python reference (system.py:105-112): On collision, the gas is NOT refunded.
                // Line 86 deducts create_message_gas, and line 111-112 returns without refunding.
                // Therefore, we return gas_left = 0 to indicate all gas was consumed.
                return .{
                    .address = primitives.ZERO_ADDRESS,
                    .success = false,
                    .gas_left = 0,
                    .output = &[_]u8{},
                    .err = error.ContractCollision,
                };
            }

            try self.clearExistingEmptyAccountForCreate(new_address);

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

                try self.setNonceWithSnapshot(caller, caller_nonce + 1);
            }

            return null;
        }

        fn executeCreate(self: *Self, caller: Address, new_address: Address, value: u256, init_code: []const u8, gas: u64, observed: ?ObservedFrame) errors.CallError!CreateResult {
            const child_gas = std.math.cast(i64, gas) orelse return error.OutOfGas;
            // Set nonce of new contract to 1 (EVM spec: contracts start with nonce 1)
            try self.setNonceWithSnapshot(new_address, 1);

            var created_accounts_snapshot = std.AutoHashMap(primitives.Address, void).init(self.arena.allocator());
            var created_snapshot_it = self.created_accounts.iterator();
            while (created_snapshot_it.next()) |entry| {
                try created_accounts_snapshot.put(entry.key_ptr.*, {});
            }
            defer created_accounts_snapshot.deinit();

            // EIP-6780 (Cancun): Mark account as created BEFORE execution
            // Per Python reference (interpreter.py:174): mark_account_created happens BEFORE process_message
            // "The marker is not removed even if the account creation reverts"
            // This is required for SELFDESTRUCT to correctly identify same-tx creations
            try self.created_accounts.put(new_address, {});

            // Snapshot gas refunds before executing init code
            // Per Python reference (vm/__init__.py:incorporate_child_on_error), failed creates do not
            // propagate refunds to parent. Only incorporate_child_on_success adds child refunds.
            const refund_snapshot = self.gas_refund;

            // Snapshot warm addresses and storage slots before executing init code (EIP-2929)
            // Per Python reference (incorporate_child_on_error), accessed_addresses
            // and accessed_storage_keys are only propagated on success, not on failure
            var access_list_snapshot = try self.access_list_manager.snapshot();
            defer access_list_snapshot.deinit();

            // Snapshot balances before execution (for SELFDESTRUCT revert handling)
            // We use copy-on-write: addresses are snapshotted when first modified via setBalanceWithSnapshot
            var balance_snapshot = std.AutoHashMap(primitives.Address, u256).init(self.arena.allocator());

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
            var create_selfdestruct_snapshot = std.AutoHashMap(primitives.Address, void).init(self.arena.allocator());
            var create_selfdestruct_it = self.selfdestructed_accounts.iterator();
            while (create_selfdestruct_it.next()) |entry| {
                try create_selfdestruct_snapshot.put(entry.key_ptr.*, {});
            }

            // Execute initialization code
            try self.frames.append(self.arena.allocator(), try FrameType.init(
                self.arena.allocator(),
                init_code,
                child_gas,
                caller,
                new_address,
                value,
                &[_]u8{}, // no calldata for CREATE
                @as(*anyopaque, @ptrCast(self)),
                self.hardfork,
                false, // CREATE/CREATE2 are never static (can't create contracts in static context)
            ));
            defer _ = self.frames.pop();
            self.attachFrame(observed, new_address);

            // Execute frame
            self.frames.items[self.frames.items.len - 1].execute() catch |err| {
                const failed_frame = &self.frames.items[self.frames.items.len - 1];
                const error_output = failed_frame.output; // Capture output before popping

                // Revert nonce on execution error
                try self.setNonceWithSnapshot(new_address, 0);

                // Restore gas refunds on failure
                // Per Python: incorporate_child_on_error does NOT add child's refund_counter
                self.gas_refund = refund_snapshot;

                // Restore warm addresses and storage slots on failure (EIP-2929)
                try self.access_list_manager.restore(access_list_snapshot);

                // Restore balances on error (handles SELFDESTRUCT balance transfers and value transfers)
                var balance_restore_it = balance_snapshot.iterator();
                while (balance_restore_it.next()) |entry| {
                    if (self.host) |h| {
                        h.setBalance(entry.key_ptr.*, entry.value_ptr.*);
                    } else {
                        try self.balances.put(entry.key_ptr.*, entry.value_ptr.*);
                    }
                }
                try self.restore_created_accounts_after_create_failure(&created_accounts_snapshot);

                return .{
                    .address = primitives.ZERO_ADDRESS,
                    .success = false,
                    .gas_left = 0,
                    .output = error_output,
                    .err = err,
                };
            };

            // Get frame results
            const frame = &self.frames.items[self.frames.items.len - 1];
            var gas_left = @as(u64, @intCast(@max(frame.gas_remaining, 0)));
            var success = !frame.reverted;
            const frame_output = frame.output;
            var failure: ?errors.CallError = null;

            // If successful, check deposit cost and code size, then deploy
            if (success) {
                // Charge code deposit cost (200 gas per byte) if there's output
                if (frame_output.len > 0) {
                    const deposit_cost = @as(u64, @intCast(frame_output.len)) * GasConstants.CreateDataGas;
                    if (gas_left < deposit_cost) {
                        // Out of gas during code deposit -> creation fails
                        success = false;
                        gas_left = 0;
                        failure = error.CodeStoreOutOfGas;
                    }
                }

                if (success and frame_output.len > 0) {
                    // EIP-170 (Spurious Dragon+): deployed code is size limited.
                    // EIP-3541 (London+): deployed code may not start with the 0xEF byte.
                    const exceeds_size = self.hardfork.isAtLeast(.SPURIOUS_DRAGON) and frame_output.len > config.max_bytecode_size;
                    const ef_prefix = self.hardfork.isAtLeast(.LONDON) and frame_output[0] == 0xEF;
                    if (exceeds_size or ef_prefix) {
                        // Revert nonce on failure
                        try self.setNonceWithSnapshot(new_address, 0);

                        // Restore gas refunds on failure
                        // Per Python: incorporate_child_on_error does NOT add child's refund_counter
                        self.gas_refund = refund_snapshot;

                        // Restore warm addresses and storage slots on failure (EIP-2929)
                        try self.access_list_manager.restore(access_list_snapshot);

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
                        try self.restore_created_accounts_after_create_failure(&created_accounts_snapshot);

                        // Per Python reference: code size violation raises OutOfGasError, consuming all gas
                        // execution-specs/src/ethereum/forks/constantinople/vm/interpreter.py
                        return .{
                            .address = primitives.ZERO_ADDRESS,
                            .success = false,
                            .gas_left = 0, // Consume all remaining gas on code size violation
                            .output = frame_output,
                            .err = if (exceeds_size) error.CreateContractSizeLimit else error.InvalidBytecode,
                        };
                    }

                    // Deploy code and deduct deposit gas
                    try self.setCodeWithSnapshot(new_address, frame_output);
                    const deposit_cost = @as(u64, @intCast(frame_output.len)) * GasConstants.CreateDataGas;
                    gas_left -= deposit_cost;
                } else if (success) {
                    // Deploy empty code (output.len == 0)
                    try self.setCodeWithSnapshot(new_address, &[_]u8{});
                }
            } else {
                // Reverse state changes on revert
                // Revert nonce to 0
                try self.setNonceWithSnapshot(new_address, 0);

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
                try self.restore_created_accounts_after_create_failure(&created_accounts_snapshot);
            }

            // According to EIP-1014 and CREATE semantics:
            // - On success: return_data should be empty
            // - On failure/revert: return_data should contain the child's output
            return .{
                .address = if (success) new_address else primitives.ZERO_ADDRESS,
                .success = success,
                .gas_left = gas_left,
                .output = if (success) &[_]u8{} else frame_output,
                .err = failure,
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
        pub fn get_balance(self: *Self, address: primitives.Address) u256 {
            if (self.host) |h| return h.getBalance(address);
            return self.balances.get(address) orelse 0;
        }

        const ResolvedCode = struct {
            code: []const u8,
            address: Address,
            is_delegated: bool = false,
        };

        pub fn getRawCode(self: *Self, address: Address) []const u8 {
            if (self.host) |h| return h.getCode(address);
            return self.code.get(address) orelse &.{};
        }

        fn resolveCode(self: *Self, address: Address) ResolvedCode {
            return self.resolveCodeBytes(address, self.getRawCode(address));
        }

        fn resolveCodeBytes(self: *Self, address: Address, code: []const u8) ResolvedCode {
            // EIP-7702 resolves one delegation designation.
            if (self.hardfork.isAtLeast(.PRAGUE)) {
                if (parseDelegation(code)) |delegated| {
                    return .{ .code = self.getRawCode(delegated), .address = delegated, .is_delegated = true };
                }
            }
            return .{ .code = code, .address = address };
        }

        pub fn get_code(self: *Self, address: Address) []const u8 {
            return self.resolveCode(address).code;
        }

        fn canExecutePrecompile(self: *Self, address: Address, resolved: ResolvedCode) bool {
            return resolved.code.len == 0 and !resolved.is_delegated and
                (self.getPrecompileOverride(address) != null or isPrecompile(address, self.hardfork));
        }

        fn executePrecompile(self: *Self, address: Address, resolved: ResolvedCode, input: []const u8, gas: u64) ?CallResult {
            if (resolved.is_delegated) return null;
            const root_c = @import("root_c.zig");
            var output_len: usize = 0;
            var output_ptr: [*]u8 = undefined;
            var gas_used: u64 = 0;
            if (root_c.tryCallJsPrecompileHandler(&address.bytes, input.ptr, input.len, gas, &output_len, &output_ptr, &gas_used)) {
                if (gas_used > gas) return self.failed(0, error.OutOfGas);
                return .{
                    .success = true,
                    .gas_left = gas - gas_used,
                    .output = if (output_len == 0) &.{} else output_ptr[0..output_len],
                };
            }

            const allocator = self.arena.allocator();
            if (self.getPrecompileOverride(address)) |override| {
                const result = override.execute(override.context, allocator, input, gas) catch |err| return self.failed(0, err);
                if (result.gas_used > gas) return self.failed(0, error.OutOfGas);
                if (!result.success) return self.failed(0, error.PrecompileError);
                return .{ .success = true, .gas_left = gas - result.gas_used, .output = result.output };
            }
            if (isPrecompile(address, self.hardfork)) {
                const result = precompiles.execute(allocator, address, input, gas, self.hardfork) catch |err| return self.failed(0, err);
                return .{ .success = true, .gas_left = gas - result.gas_used, .output = result.output };
            }
            return null;
        }

        /// Get current frame (top of the frame stack)
        pub fn getCurrentFrame(self: *Self) ?*FrameType {
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
                return self.frames.items[self.frames.items.len - 1].bytecode.code;
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

test "parseDelegation accepts only the exact 23-byte designation" {
    const target = primitives.Address{ .bytes = @splat(0xab) };
    const designation = DELEGATION_PREFIX ++ target.bytes;
    try std.testing.expectEqual(target, parseDelegation(&designation).?);
    try std.testing.expect(parseDelegation(&(designation ++ [_]u8{0x00})) == null);
    try std.testing.expect(parseDelegation(designation[0..22]) == null);
    try std.testing.expect(parseDelegation(&([_]u8{ 0xef, 0x01, 0x01 } ++ target.bytes)) == null);
    try std.testing.expect(parseDelegation(&.{}) == null);
}
