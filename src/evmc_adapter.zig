//! EVMC v11/v12 C-ABI types and `HostInterface` + `Inspector` bridge.
//!
//! Provides exact C-layout `extern struct` and `enum(c_int)` definitions
//! matching the EVMC specification (`evmc.h`) along with `EvmcHostBridge`,
//! which adapts `guillotine-mini`'s `HostInterface` (and optional `Inspector`)
//! into a callable `EvmcHostInterface`.
const std = @import("std");
const primitives = @import("voltaire");
const host_mod = @import("host.zig");
const insp = @import("inspector.zig");

const Allocator = std.mem.Allocator;
const Address = primitives.Address;
const Hardfork = primitives.Hardfork;
const HostInterface = host_mod.HostInterface;
const Inspector = insp.Inspector;

/// EVMC ABI version targeted by this adapter (v12, backwards-compatible with v11).
pub const EVMC_ABI_VERSION: c_int = 12;

/// EVMC message flags (`enum evmc_flags`).
pub const EVMC_STATIC: u32 = 1;
pub const EVMC_DELEGATED: u32 = 2;

/// 20-byte Ethereum address with exact C ABI layout (`evmc_address`).
pub const EvmcAddress = extern struct {
    bytes: [20]u8 = @splat(0),

    pub fn fromAddress(address: Address) EvmcAddress {
        return .{ .bytes = address.bytes };
    }

    pub fn toAddress(self: EvmcAddress) Address {
        return .{ .bytes = self.bytes };
    }

    pub fn eql(self: EvmcAddress, other: EvmcAddress) bool {
        return std.mem.eql(u8, &self.bytes, &other.bytes);
    }
};

/// 32-byte big-endian word / hash with exact C ABI layout (`evmc_bytes32` / `evmc_uint256be`).
pub const EvmcBytes32 = extern struct {
    bytes: [32]u8 = @splat(0),

    pub fn fromU256(value: u256) EvmcBytes32 {
        var out: EvmcBytes32 = .{};
        std.mem.writeInt(u256, &out.bytes, value, .big);
        return out;
    }

    pub fn toU256(self: EvmcBytes32) u256 {
        return std.mem.readInt(u256, &self.bytes, .big);
    }

    pub fn fromBytes(bytes: [32]u8) EvmcBytes32 {
        return .{ .bytes = bytes };
    }

    pub fn isZero(self: EvmcBytes32) bool {
        return std.mem.allEqual(u8, &self.bytes, 0);
    }

    pub fn eql(self: EvmcBytes32, other: EvmcBytes32) bool {
        return std.mem.eql(u8, &self.bytes, &other.bytes);
    }
};

/// Alias matching EVMC's `evmc_uint256be`.
pub const EvmcUint256be = EvmcBytes32;

/// Call kind (`enum evmc_call_kind`).
pub const EvmcCallKind = enum(c_int) {
    call = 0,
    delegatecall = 1,
    callcode = 2,
    create = 3,
    create2 = 4,
    eofcreate = 5,
};

/// Execution status code (`enum evmc_status_code`).
pub const EvmcStatusCode = enum(c_int) {
    success = 0,
    failure = 1,
    revert = 2,
    out_of_gas = 3,
    invalid_instruction = 4,
    undefined_instruction = 5,
    stack_overflow = 6,
    stack_underflow = 7,
    bad_jump_destination = 8,
    invalid_memory_access = 9,
    call_depth_exceeded = 10,
    static_mode_violation = 11,
    precompile_failure = 12,
    contract_validation_failure = 13,
    argument_out_of_range = 14,
    wasm_unreachable_instruction = 15,
    wasm_trap = 16,
    insufficient_balance = 17,
    internal_error = -1,
    rejected = -2,
    out_of_memory = -3,
};

/// EVM hardfork revision (`enum evmc_revision`, EVMC v11/v12 Frontier..Osaka).
pub const EvmcRevision = enum(c_int) {
    frontier = 0,
    homestead = 1,
    tangerine_whistle = 2,
    spurious_dragon = 3,
    byzantium = 4,
    constantinople = 5,
    petersburg = 6,
    istanbul = 7,
    berlin = 8,
    london = 9,
    paris = 10,
    shanghai = 11,
    cancun = 12,
    prague = 13,
    osaka = 14,
    /// `EVMC_EXPERIMENTAL`: any fork newer than the latest named revision
    /// (for example Amsterdam).
    experimental = 15,
};

/// EIP-2929 access warmth status (`enum evmc_access_status`).
pub const EvmcAccessStatus = enum(c_int) {
    cold = 0,
    warm = 1,
};

/// EIP-2200 storage transition status (`enum evmc_storage_status`).
pub const EvmcStorageStatus = enum(c_int) {
    assigned = 0,
    added = 1,
    deleted = 2,
    modified = 3,
    deleted_added = 4,
    modified_deleted = 5,
    deleted_restored = 6,
    added_deleted = 7,
    modified_restored = 8,
};

/// EVMC call/create message (`struct evmc_message`).
pub const EvmcMessage = extern struct {
    kind: EvmcCallKind,
    flags: u32,
    depth: i32,
    gas: i64,
    recipient: EvmcAddress,
    sender: EvmcAddress,
    input_data: ?[*]const u8,
    input_size: usize,
    value: EvmcUint256be,
    create2_salt: EvmcBytes32,
    code_address: EvmcAddress,
    /// EVMC v12 optional code buffer (null/0 in v11 callers).
    code: ?[*]const u8 = null,
    code_size: usize = 0,
};

/// Release callback for heap-allocated `EvmcResult.output_data`.
pub const EvmcReleaseResultFn = *const fn (result: *const EvmcResult) callconv(.c) void;

/// EVMC execution result (`struct evmc_result`).
pub const EvmcResult = extern struct {
    status_code: EvmcStatusCode,
    gas_left: i64,
    gas_refund: i64,
    output_data: ?[*]const u8,
    output_size: usize,
    release: ?EvmcReleaseResultFn,
    create_address: EvmcAddress,
    padding: [4]u8 = @splat(0),
};

/// EVMC transaction & block context (`struct evmc_tx_context`).
pub const EvmcTxContext = extern struct {
    tx_gas_price: EvmcUint256be = .{},
    tx_origin: EvmcAddress = .{},
    block_coinbase: EvmcAddress = .{},
    block_number: i64 = 0,
    block_timestamp: i64 = 0,
    block_gas_limit: i64 = 0,
    block_prev_randao: EvmcBytes32 = .{},
    chain_id: EvmcUint256be = .{},
    block_base_fee: EvmcUint256be = .{},
    blob_base_fee: EvmcUint256be = .{},
    blob_hashes: ?[*]const EvmcBytes32 = null,
    blob_hashes_count: usize = 0,
    initcodes: ?*const anyopaque = null,
    initcodes_count: usize = 0,
};

/// Opaque host context pointer (`struct evmc_host_context`).
pub const EvmcHostContext = opaque {};

/// C-ABI EVMC v11/v12 host callback table (`struct evmc_host_interface`).
pub const EvmcHostInterface = extern struct {
    account_exists: *const fn (context: ?*EvmcHostContext, address: *const EvmcAddress) callconv(.c) bool,
    get_storage: *const fn (context: ?*EvmcHostContext, address: *const EvmcAddress, key: *const EvmcBytes32) callconv(.c) EvmcBytes32,
    set_storage: *const fn (context: ?*EvmcHostContext, address: *const EvmcAddress, key: *const EvmcBytes32, value: *const EvmcBytes32) callconv(.c) EvmcStorageStatus,
    get_balance: *const fn (context: ?*EvmcHostContext, address: *const EvmcAddress) callconv(.c) EvmcUint256be,
    get_code_size: *const fn (context: ?*EvmcHostContext, address: *const EvmcAddress) callconv(.c) usize,
    get_code_hash: *const fn (context: ?*EvmcHostContext, address: *const EvmcAddress) callconv(.c) EvmcBytes32,
    copy_code: *const fn (context: ?*EvmcHostContext, address: *const EvmcAddress, code_offset: usize, buffer_data: ?[*]u8, buffer_size: usize) callconv(.c) usize,
    selfdestruct: *const fn (context: ?*EvmcHostContext, address: *const EvmcAddress, beneficiary: *const EvmcAddress) callconv(.c) bool,
    call: *const fn (context: ?*EvmcHostContext, msg: *const EvmcMessage) callconv(.c) EvmcResult,
    get_tx_context: *const fn (context: ?*EvmcHostContext) callconv(.c) EvmcTxContext,
    get_block_hash: *const fn (context: ?*EvmcHostContext, number: i64) callconv(.c) EvmcBytes32,
    emit_log: *const fn (context: ?*EvmcHostContext, address: *const EvmcAddress, data: ?[*]const u8, data_size: usize, topics: ?[*]const EvmcBytes32, topics_count: usize) callconv(.c) void,
    access_account: *const fn (context: ?*EvmcHostContext, address: *const EvmcAddress) callconv(.c) EvmcAccessStatus,
    access_storage: *const fn (context: ?*EvmcHostContext, address: *const EvmcAddress, key: *const EvmcBytes32) callconv(.c) EvmcAccessStatus,
    get_transient_storage: *const fn (context: ?*EvmcHostContext, address: *const EvmcAddress, key: *const EvmcBytes32) callconv(.c) EvmcBytes32,
    set_transient_storage: *const fn (context: ?*EvmcHostContext, address: *const EvmcAddress, key: *const EvmcBytes32, value: *const EvmcBytes32) callconv(.c) void,
};

comptime {
    if (@sizeOf(EvmcAddress) != 20) @compileError("EvmcAddress must be 20 bytes");
    if (@sizeOf(EvmcBytes32) != 32) @compileError("EvmcBytes32 must be 32 bytes");
    if (@alignOf(EvmcAddress) != 1) @compileError("EvmcAddress must have alignment 1");
    if (@alignOf(EvmcBytes32) != 1) @compileError("EvmcBytes32 must have alignment 1");
}

/// Converts a `guillotine-mini` / `voltaire` `Hardfork` into an `EvmcRevision`.
/// Forks newer than Osaka (e.g. Amsterdam) map to `EVMC_EXPERIMENTAL`. The
/// mapping is written without an exhaustive switch so newer Voltaire
/// `Hardfork` variants compile without changes here.
pub fn fromHardfork(hardfork: Hardfork) EvmcRevision {
    if (@intFromEnum(hardfork) > @intFromEnum(Hardfork.OSAKA)) return .experimental;
    const mapping = .{
        .{ "FRONTIER", EvmcRevision.frontier },
        .{ "HOMESTEAD", EvmcRevision.homestead },
        .{ "DAO", EvmcRevision.homestead },
        .{ "TANGERINE_WHISTLE", EvmcRevision.tangerine_whistle },
        .{ "SPURIOUS_DRAGON", EvmcRevision.spurious_dragon },
        .{ "BYZANTIUM", EvmcRevision.byzantium },
        .{ "CONSTANTINOPLE", EvmcRevision.constantinople },
        .{ "PETERSBURG", EvmcRevision.petersburg },
        .{ "ISTANBUL", EvmcRevision.istanbul },
        .{ "MUIR_GLACIER", EvmcRevision.istanbul },
        .{ "BERLIN", EvmcRevision.berlin },
        .{ "LONDON", EvmcRevision.london },
        .{ "ARROW_GLACIER", EvmcRevision.london },
        .{ "GRAY_GLACIER", EvmcRevision.london },
        .{ "MERGE", EvmcRevision.paris },
        .{ "SHANGHAI", EvmcRevision.shanghai },
        .{ "CANCUN", EvmcRevision.cancun },
        .{ "PRAGUE", EvmcRevision.prague },
        .{ "OSAKA", EvmcRevision.osaka },
    };
    inline for (mapping) |entry| {
        if (@hasField(Hardfork, entry[0]) and hardfork == @field(Hardfork, entry[0])) return entry[1];
    }
    unreachable;
}

/// Converts an `EvmcRevision` into a `guillotine-mini` / `voltaire` `Hardfork`.
/// `experimental` maps to the newest fork Voltaire defines.
pub fn toHardfork(revision: EvmcRevision) Hardfork {
    return switch (revision) {
        .frontier => .FRONTIER,
        .homestead => .HOMESTEAD,
        .tangerine_whistle => .TANGERINE_WHISTLE,
        .spurious_dragon => .SPURIOUS_DRAGON,
        .byzantium => .BYZANTIUM,
        .constantinople => .CONSTANTINOPLE,
        .petersburg => .PETERSBURG,
        .istanbul => .ISTANBUL,
        .berlin => .BERLIN,
        .london => .LONDON,
        .paris => .MERGE,
        .shanghai => .SHANGHAI,
        .cancun => .CANCUN,
        .prague => .PRAGUE,
        .osaka => .OSAKA,
        .experimental => newestHardfork(),
    };
}

fn newestHardfork() Hardfork {
    const fields = @typeInfo(Hardfork).@"enum".fields;
    var newest: Hardfork = @enumFromInt(fields[0].value);
    inline for (fields) |field| {
        const fork: Hardfork = @enumFromInt(field.value);
        if (@intFromEnum(fork) > @intFromEnum(newest)) newest = fork;
    }
    return newest;
}

/// Recorded log entry emitted through `EvmcHostBridge.emit_log`.
pub const RecordedLog = struct {
    address: Address,
    topics: []const [32]u8,
    data: []const u8,
};

/// Bridges `guillotine-mini`'s `HostInterface` and optional `Inspector` to a
/// C-ABI `EvmcHostInterface`.
pub const EvmcHostBridge = struct {
    const SlotKey = struct { address: [20]u8, slot: u256 };

    pub const CallHandler = *const fn (ctx: ?*anyopaque, msg: *const EvmcMessage) EvmcResult;

    pub const Options = struct {
        inspector: ?Inspector = null,
        tx_context: EvmcTxContext = .{},
        frame_id: u64 = 0,
        call_handler: ?CallHandler = null,
        call_handler_ctx: ?*anyopaque = null,
    };

    allocator: Allocator,
    host: HostInterface,
    inspector: ?Inspector,
    tx_context: EvmcTxContext,
    frame_id: u64,
    call_handler: ?CallHandler,
    call_handler_ctx: ?*anyopaque,
    original_storage: std.AutoHashMapUnmanaged(SlotKey, u256) = .{},
    transient_storage: std.AutoHashMapUnmanaged(SlotKey, u256) = .{},
    warm_accounts: std.AutoHashMapUnmanaged(Address, void) = .{},
    warm_storage: std.AutoHashMapUnmanaged(SlotKey, void) = .{},
    selfdestructed: std.AutoHashMapUnmanaged(Address, void) = .{},
    block_hashes: std.AutoHashMapUnmanaged(i64, [32]u8) = .{},
    logs: std.ArrayList(RecordedLog) = .{},
    err: ?anyerror = null,

    pub fn init(allocator: Allocator, host: HostInterface, options: Options) EvmcHostBridge {
        return .{
            .allocator = allocator,
            .host = host,
            .inspector = options.inspector,
            .tx_context = options.tx_context,
            .frame_id = options.frame_id,
            .call_handler = options.call_handler,
            .call_handler_ctx = options.call_handler_ctx,
        };
    }

    pub fn deinit(self: *EvmcHostBridge) void {
        self.original_storage.deinit(self.allocator);
        self.transient_storage.deinit(self.allocator);
        self.warm_accounts.deinit(self.allocator);
        self.warm_storage.deinit(self.allocator);
        self.selfdestructed.deinit(self.allocator);
        self.block_hashes.deinit(self.allocator);
        for (self.logs.items) |entry| {
            self.allocator.free(entry.topics);
            self.allocator.free(entry.data);
        }
        self.logs.deinit(self.allocator);
        self.* = undefined;
    }

    /// Returns the static C-ABI `EvmcHostInterface` callback table.
    pub fn hostInterface() *const EvmcHostInterface {
        return &vtable;
    }

    /// Returns this bridge cast as an opaque EVMC host context pointer.
    pub fn hostContext(self: *EvmcHostBridge) *EvmcHostContext {
        return @ptrCast(self);
    }

    /// Registers a historical block hash for `get_block_hash`.
    pub fn setBlockHash(self: *EvmcHostBridge, number: i64, hash: [32]u8) !void {
        try self.block_hashes.put(self.allocator, number, hash);
    }

    /// Clears transaction-scoped transient storage (EIP-1153).
    pub fn clearTransientStorage(self: *EvmcHostBridge) void {
        self.transient_storage.clearRetainingCapacity();
    }

    fn fromContext(context: ?*EvmcHostContext) *EvmcHostBridge {
        return @ptrCast(@alignCast(context.?));
    }

    const vtable: EvmcHostInterface = .{
        .account_exists = accountExistsCb,
        .get_storage = getStorageCb,
        .set_storage = setStorageCb,
        .get_balance = getBalanceCb,
        .get_code_size = getCodeSizeCb,
        .get_code_hash = getCodeHashCb,
        .copy_code = copyCodeCb,
        .selfdestruct = selfdestructCb,
        .call = callCb,
        .get_tx_context = getTxContextCb,
        .get_block_hash = getBlockHashCb,
        .emit_log = emitLogCb,
        .access_account = accessAccountCb,
        .access_storage = accessStorageCb,
        .get_transient_storage = getTransientStorageCb,
        .set_transient_storage = setTransientStorageCb,
    };

    fn accountExistsCb(context: ?*EvmcHostContext, address: *const EvmcAddress) callconv(.c) bool {
        const self = fromContext(context);
        return self.host.accountExists(address.toAddress());
    }

    fn getStorageCb(context: ?*EvmcHostContext, address: *const EvmcAddress, key: *const EvmcBytes32) callconv(.c) EvmcBytes32 {
        const self = fromContext(context);
        const addr = address.toAddress();
        const slot = key.toU256();
        const value = self.host.getStorage(addr, slot);
        if (self.inspector) |sink| {
            sink.onStorageChange(.{
                .frame_id = self.frame_id,
                .address = addr,
                .slot = slot,
                .prev_value = value,
                .new_value = value,
                .is_read = true,
            });
        }
        return EvmcBytes32.fromU256(value);
    }

    fn classifyStorageStatus(original: u256, current: u256, new_val: u256) EvmcStorageStatus {
        if (current == new_val) return .assigned;
        if (original == current) {
            if (original == 0) return .added;
            if (new_val == 0) return .deleted;
            return .modified;
        }
        // Dirty slot (original != current).
        if (original == 0) {
            if (new_val == 0) return .added_deleted;
            return .assigned;
        }
        if (current == 0) {
            if (new_val == original) return .deleted_restored;
            return .deleted_added;
        }
        if (new_val == 0) return .modified_deleted;
        if (new_val == original) return .modified_restored;
        return .assigned;
    }

    fn setStorageCb(
        context: ?*EvmcHostContext,
        address: *const EvmcAddress,
        key: *const EvmcBytes32,
        value: *const EvmcBytes32,
    ) callconv(.c) EvmcStorageStatus {
        const self = fromContext(context);
        const addr = address.toAddress();
        const slot = key.toU256();
        const new_val = value.toU256();
        const current = self.host.getStorage(addr, slot);

        const slot_key: SlotKey = .{ .address = addr.bytes, .slot = slot };
        const original: u256 = blk: {
            if (self.original_storage.get(slot_key)) |orig| break :blk orig;
            self.original_storage.put(self.allocator, slot_key, current) catch |e| {
                if (self.err == null) self.err = e;
            };
            break :blk current;
        };

        const status = classifyStorageStatus(original, current, new_val);
        self.host.setStorage(addr, slot, new_val);

        if (self.inspector) |sink| {
            sink.onStorageChange(.{
                .frame_id = self.frame_id,
                .address = addr,
                .slot = slot,
                .prev_value = current,
                .new_value = new_val,
                .is_read = false,
            });
        }
        return status;
    }

    fn getBalanceCb(context: ?*EvmcHostContext, address: *const EvmcAddress) callconv(.c) EvmcUint256be {
        const self = fromContext(context);
        return EvmcBytes32.fromU256(self.host.getBalance(address.toAddress()));
    }

    fn getCodeSizeCb(context: ?*EvmcHostContext, address: *const EvmcAddress) callconv(.c) usize {
        const self = fromContext(context);
        return self.host.getCode(address.toAddress()).len;
    }

    fn getCodeHashCb(context: ?*EvmcHostContext, address: *const EvmcAddress) callconv(.c) EvmcBytes32 {
        const self = fromContext(context);
        const addr = address.toAddress();
        if (!self.host.accountExists(addr)) return .{};
        const code = self.host.getCode(addr);
        var hash: [32]u8 = undefined;
        std.crypto.hash.sha3.Keccak256.hash(code, &hash, .{});
        return EvmcBytes32.fromBytes(hash);
    }

    fn copyCodeCb(
        context: ?*EvmcHostContext,
        address: *const EvmcAddress,
        code_offset: usize,
        buffer_data: ?[*]u8,
        buffer_size: usize,
    ) callconv(.c) usize {
        const self = fromContext(context);
        const dst = buffer_data orelse return 0;
        if (buffer_size == 0) return 0;
        const code = self.host.getCode(address.toAddress());
        if (code_offset >= code.len) return 0;
        const n = @min(buffer_size, code.len - code_offset);
        @memcpy(dst[0..n], code[code_offset .. code_offset + n]);
        return n;
    }

    fn selfdestructCb(
        context: ?*EvmcHostContext,
        address: *const EvmcAddress,
        beneficiary: *const EvmcAddress,
    ) callconv(.c) bool {
        const self = fromContext(context);
        const addr = address.toAddress();
        const ben = beneficiary.toAddress();
        const balance = self.host.getBalance(addr);

        if (balance > 0) {
            if (!addr.equals(ben)) {
                const prev_ben = self.host.getBalance(ben);
                const new_ben = prev_ben +| balance;
                self.host.setBalance(ben, new_ben);
                if (self.inspector) |sink| {
                    sink.onBalanceChange(.{
                        .frame_id = self.frame_id,
                        .address = ben,
                        .prev_balance = prev_ben,
                        .new_balance = new_ben,
                    });
                }
            }
            self.host.setBalance(addr, 0);
            if (self.inspector) |sink| {
                sink.onBalanceChange(.{
                    .frame_id = self.frame_id,
                    .address = addr,
                    .prev_balance = balance,
                    .new_balance = 0,
                });
            }
        }

        const entry = self.selfdestructed.getOrPut(self.allocator, addr) catch |e| {
            if (self.err == null) self.err = e;
            return false;
        };
        const first_time = !entry.found_existing;

        if (self.inspector) |sink| {
            sink.onSelfDestruct(.{
                .frame_id = self.frame_id,
                .address = addr,
                .beneficiary = ben,
                .value = balance,
            });
        }
        return first_time;
    }

    fn callCb(context: ?*EvmcHostContext, msg: *const EvmcMessage) callconv(.c) EvmcResult {
        const self = fromContext(context);
        if (self.call_handler) |handler| {
            return handler(self.call_handler_ctx, msg);
        }
        return .{
            .status_code = .failure,
            .gas_left = 0,
            .gas_refund = 0,
            .output_data = null,
            .output_size = 0,
            .release = null,
            .create_address = .{},
        };
    }

    fn getTxContextCb(context: ?*EvmcHostContext) callconv(.c) EvmcTxContext {
        return fromContext(context).tx_context;
    }

    fn getBlockHashCb(context: ?*EvmcHostContext, number: i64) callconv(.c) EvmcBytes32 {
        const self = fromContext(context);
        const hash = self.block_hashes.get(number) orelse return .{};
        return EvmcBytes32.fromBytes(hash);
    }

    fn emitLogCb(
        context: ?*EvmcHostContext,
        address: *const EvmcAddress,
        data: ?[*]const u8,
        data_size: usize,
        topics: ?[*]const EvmcBytes32,
        topics_count: usize,
    ) callconv(.c) void {
        const self = fromContext(context);
        const addr = address.toAddress();
        const data_slice: []const u8 = if (data) |ptr| ptr[0..data_size] else &.{};

        const owned_topics = self.allocator.alloc([32]u8, topics_count) catch |e| {
            if (self.err == null) self.err = e;
            return;
        };
        if (topics) |t_ptr| {
            for (0..topics_count) |i| owned_topics[i] = t_ptr[i].bytes;
        } else {
            for (owned_topics) |*t| t.* = @splat(0);
        }

        const owned_data = self.allocator.dupe(u8, data_slice) catch |e| {
            self.allocator.free(owned_topics);
            if (self.err == null) self.err = e;
            return;
        };

        self.logs.append(self.allocator, .{
            .address = addr,
            .topics = owned_topics,
            .data = owned_data,
        }) catch |e| {
            self.allocator.free(owned_topics);
            self.allocator.free(owned_data);
            if (self.err == null) self.err = e;
            return;
        };

        if (self.inspector) |sink| {
            sink.onLog(.{
                .frame_id = self.frame_id,
                .address = addr,
                .topics = owned_topics,
                .data = owned_data,
            });
        }
    }

    fn accessAccountCb(context: ?*EvmcHostContext, address: *const EvmcAddress) callconv(.c) EvmcAccessStatus {
        const self = fromContext(context);
        const addr = address.toAddress();
        const entry = self.warm_accounts.getOrPut(self.allocator, addr) catch |e| {
            if (self.err == null) self.err = e;
            return .cold;
        };
        const was_warm = entry.found_existing;
        if (self.inspector) |sink| {
            sink.onAccess(.{
                .frame_id = self.frame_id,
                .address = addr,
                .slot = null,
                .was_warm = was_warm,
            });
        }
        return if (was_warm) .warm else .cold;
    }

    fn accessStorageCb(
        context: ?*EvmcHostContext,
        address: *const EvmcAddress,
        key: *const EvmcBytes32,
    ) callconv(.c) EvmcAccessStatus {
        const self = fromContext(context);
        const addr = address.toAddress();
        const slot = key.toU256();
        const slot_key: SlotKey = .{ .address = addr.bytes, .slot = slot };
        const entry = self.warm_storage.getOrPut(self.allocator, slot_key) catch |e| {
            if (self.err == null) self.err = e;
            return .cold;
        };
        const was_warm = entry.found_existing;
        if (self.inspector) |sink| {
            sink.onAccess(.{
                .frame_id = self.frame_id,
                .address = addr,
                .slot = slot,
                .was_warm = was_warm,
            });
        }
        return if (was_warm) .warm else .cold;
    }

    fn getTransientStorageCb(
        context: ?*EvmcHostContext,
        address: *const EvmcAddress,
        key: *const EvmcBytes32,
    ) callconv(.c) EvmcBytes32 {
        const self = fromContext(context);
        const addr = address.toAddress();
        const slot = key.toU256();
        const val = self.transient_storage.get(.{ .address = addr.bytes, .slot = slot }) orelse 0;
        if (self.inspector) |sink| {
            sink.onTransientStorageChange(.{
                .frame_id = self.frame_id,
                .address = addr,
                .slot = slot,
                .value = val,
                .is_write = false,
            });
        }
        return EvmcBytes32.fromU256(val);
    }

    fn setTransientStorageCb(
        context: ?*EvmcHostContext,
        address: *const EvmcAddress,
        key: *const EvmcBytes32,
        value: *const EvmcBytes32,
    ) callconv(.c) void {
        const self = fromContext(context);
        const addr = address.toAddress();
        const slot = key.toU256();
        const new_val = value.toU256();
        self.transient_storage.put(self.allocator, .{ .address = addr.bytes, .slot = slot }, new_val) catch |e| {
            if (self.err == null) self.err = e;
            return;
        };
        if (self.inspector) |sink| {
            sink.onTransientStorageChange(.{
                .frame_id = self.frame_id,
                .address = addr,
                .slot = slot,
                .value = new_val,
                .is_write = true,
            });
        }
    }
};
