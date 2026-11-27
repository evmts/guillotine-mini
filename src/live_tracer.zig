//! Live block-level and chain-level tracing hooks (`BlockHooks`) modeled after
//! Geth's `core/tracing.Hooks`, plus `MuxBlockHooks` fan-out and the reference
//! `SupplyTracer` (`--vmtrace supply`).
//!
//! All event slices are borrowed for the duration of the callback. Like
//! `inspector.Inspector`, hook callbacks return `void`, so stateful live
//! tracers record their first internal error in `err`, stop collecting, and
//! surface that error from their writers.
const std = @import("std");
const primitives = @import("voltaire");
const inspector = @import("inspector.zig");

const Address = primitives.Address;
const Hardfork = primitives.Hardfork;
const Allocator = std.mem.Allocator;
const Stringify = std.json.Stringify;
const Inspector = inspector.Inspector;

/// EIP-4844 gas per blob (`DATA_GAS_PER_BLOB = 2^17`).
pub const GAS_PER_BLOB: u256 = 131_072;

// ---------------------------------------------------------------------------
// Block-level and chain-level event types
// ---------------------------------------------------------------------------

pub const ChainInitEvent = struct {
    chain_id: u256,
    hardfork: Hardfork,
    genesis_hash: [32]u8,
};

pub const GenesisAllocEntry = struct {
    address: Address,
    balance: u256,
    nonce: u64 = 0,
    code: []const u8 = &.{},
};

pub const GenesisBlockEvent = struct {
    block_hash: [32]u8,
    allocs: []const GenesisAllocEntry,
};

pub const BlockStartEvent = struct {
    number: u64,
    hash: [32]u8,
    parent_hash: [32]u8,
    timestamp: u64,
    coinbase: Address,
    gas_limit: u64,
    base_fee: u256,
    blob_base_fee: u256,
    hardfork: Hardfork,
    tx_count: usize,
};

pub const BlockEndEvent = struct {
    number: u64,
    hash: [32]u8,
    gas_used: u64,
    tx_count: usize,
    error_name: ?[]const u8 = null,
};

pub const SkippedBlockEvent = struct {
    number: u64,
    hash: [32]u8,
    reason: []const u8,
};

pub const SystemCallStartEvent = struct {
    block_number: u64,
    caller: Address,
    target: Address,
    input: []const u8,
};

pub const SystemCallEndEvent = struct {
    block_number: u64,
    target: Address,
    output: []const u8,
    error_name: ?[]const u8 = null,
};

pub const BalanceChangeReason = enum {
    block_reward,
    uncle_reward,
    withdrawal,
    genesis,
    tx_fee,
    fee_burn,
    selfdestruct,
    transfer,
    unspecified,
};

pub const BlockBalanceChangeEvent = struct {
    address: Address,
    prev: u256,
    new: u256,
    reason: BalanceChangeReason,
};

pub const AccountStateUpdate = struct {
    address: Address,
    balance: ?u256 = null,
    nonce: ?u64 = null,
    code_hash: ?[32]u8 = null,
    deleted: bool = false,
};

pub const StateUpdateEvent = struct {
    block_number: u64,
    block_hash: [32]u8,
    parent_hash: [32]u8,
    accounts: []const AccountStateUpdate,
};

// ---------------------------------------------------------------------------
// BlockHooks vtable
// ---------------------------------------------------------------------------

/// Read-only block-level and chain-level live tracing interface.
/// The context and vtable must outlive registration on the block executor.
pub const BlockHooks = struct {
    ptr: *anyopaque,
    vtable: *const VTable,
    /// Optional per-transaction VM inspector so a live tracer can observe
    /// both block-level events and per-transaction EVM execution events.
    tx_inspector: ?Inspector = null,

    pub const VTable = struct {
        onBlockchainInit: ?*const fn (*anyopaque, ChainInitEvent) void = null,
        onGenesisBlock: ?*const fn (*anyopaque, GenesisBlockEvent) void = null,
        onBlockStart: ?*const fn (*anyopaque, BlockStartEvent) void = null,
        onBlockEnd: ?*const fn (*anyopaque, BlockEndEvent) void = null,
        onSkippedBlock: ?*const fn (*anyopaque, SkippedBlockEvent) void = null,
        onSystemCallStart: ?*const fn (*anyopaque, SystemCallStartEvent) void = null,
        onSystemCallEnd: ?*const fn (*anyopaque, SystemCallEndEvent) void = null,
        onBlockBalanceChange: ?*const fn (*anyopaque, BlockBalanceChangeEvent) void = null,
        onStateUpdate: ?*const fn (*anyopaque, StateUpdateEvent) void = null,
        onClose: ?*const fn (*anyopaque) void = null,
    };

    pub fn onBlockchainInit(self: BlockHooks, event: ChainInitEvent) void {
        if (self.vtable.onBlockchainInit) |callback| callback(self.ptr, event);
    }

    pub fn onGenesisBlock(self: BlockHooks, event: GenesisBlockEvent) void {
        if (self.vtable.onGenesisBlock) |callback| callback(self.ptr, event);
    }

    pub fn onBlockStart(self: BlockHooks, event: BlockStartEvent) void {
        if (self.vtable.onBlockStart) |callback| callback(self.ptr, event);
    }

    pub fn onBlockEnd(self: BlockHooks, event: BlockEndEvent) void {
        if (self.vtable.onBlockEnd) |callback| callback(self.ptr, event);
    }

    pub fn onSkippedBlock(self: BlockHooks, event: SkippedBlockEvent) void {
        if (self.vtable.onSkippedBlock) |callback| callback(self.ptr, event);
    }

    pub fn onSystemCallStart(self: BlockHooks, event: SystemCallStartEvent) void {
        if (self.vtable.onSystemCallStart) |callback| callback(self.ptr, event);
    }

    pub fn onSystemCallEnd(self: BlockHooks, event: SystemCallEndEvent) void {
        if (self.vtable.onSystemCallEnd) |callback| callback(self.ptr, event);
    }

    pub fn onBlockBalanceChange(self: BlockHooks, event: BlockBalanceChangeEvent) void {
        if (self.vtable.onBlockBalanceChange) |callback| callback(self.ptr, event);
    }

    pub fn onStateUpdate(self: BlockHooks, event: StateUpdateEvent) void {
        if (self.vtable.onStateUpdate) |callback| callback(self.ptr, event);
    }

    pub fn onClose(self: BlockHooks) void {
        if (self.vtable.onClose) |callback| callback(self.ptr);
    }
};

// ---------------------------------------------------------------------------
// MuxBlockHooks
// ---------------------------------------------------------------------------

/// Fan out block-level and per-tx live tracing events to multiple `BlockHooks`
/// in a single pass, preserving child order.
pub const MuxBlockHooks = struct {
    children: []const BlockHooks,

    pub fn init(children: []const BlockHooks) MuxBlockHooks {
        return .{ .children = children };
    }

    pub fn blockHooks(self: *MuxBlockHooks) BlockHooks {
        return .{
            .ptr = self,
            .vtable = &vtable,
            .tx_inspector = self.txInspector(),
        };
    }

    /// Returns a composed `Inspector` forwarding to every child's `tx_inspector`,
    /// or `null` when no child provides one.
    pub fn txInspector(self: *MuxBlockHooks) ?Inspector {
        var has_any = false;
        var mask = inspector.OpcodeMask.NONE;
        var capture_memory = false;
        for (self.children) |child| {
            if (child.tx_inspector) |ins| {
                has_any = true;
                mask = mask.unionWith(ins.opcode_mask);
                capture_memory = capture_memory or ins.capture_memory;
            }
        }
        if (!has_any) return null;
        return .{
            .ptr = self,
            .vtable = &tx_vtable,
            .opcode_mask = mask,
            .capture_memory = capture_memory,
        };
    }

    fn forwardBlock(comptime name: []const u8, comptime Event: type) *const fn (*anyopaque, Event) void {
        return &struct {
            fn dispatch(ptr: *anyopaque, event: Event) void {
                const mux: *MuxBlockHooks = @ptrCast(@alignCast(ptr));
                for (mux.children) |child| @field(BlockHooks, name)(child, event);
            }
        }.dispatch;
    }

    fn forwardClose(ptr: *anyopaque) void {
        const mux: *MuxBlockHooks = @ptrCast(@alignCast(ptr));
        for (mux.children) |child| child.onClose();
    }

    fn forwardTx(comptime name: []const u8, comptime Event: type) *const fn (*anyopaque, Event) void {
        return &struct {
            fn dispatch(ptr: *anyopaque, event: Event) void {
                const mux: *MuxBlockHooks = @ptrCast(@alignCast(ptr));
                for (mux.children) |child| {
                    if (child.tx_inspector) |ins| @field(Inspector, name)(ins, event);
                }
            }
        }.dispatch;
    }

    const vtable: BlockHooks.VTable = .{
        .onBlockchainInit = forwardBlock("onBlockchainInit", ChainInitEvent),
        .onGenesisBlock = forwardBlock("onGenesisBlock", GenesisBlockEvent),
        .onBlockStart = forwardBlock("onBlockStart", BlockStartEvent),
        .onBlockEnd = forwardBlock("onBlockEnd", BlockEndEvent),
        .onSkippedBlock = forwardBlock("onSkippedBlock", SkippedBlockEvent),
        .onSystemCallStart = forwardBlock("onSystemCallStart", SystemCallStartEvent),
        .onSystemCallEnd = forwardBlock("onSystemCallEnd", SystemCallEndEvent),
        .onBlockBalanceChange = forwardBlock("onBlockBalanceChange", BlockBalanceChangeEvent),
        .onStateUpdate = forwardBlock("onStateUpdate", StateUpdateEvent),
        .onClose = forwardClose,
    };

    const tx_vtable: Inspector.VTable = .{
        .onTxStart = forwardTx("onTxStart", inspector.TxStartEvent),
        .onTxEnd = forwardTx("onTxEnd", inspector.TxEndEvent),
        .onEnter = forwardTx("onEnter", inspector.FrameEnterEvent),
        .onExit = forwardTx("onExit", inspector.FrameExitEvent),
        .onOpcode = forwardTx("onOpcode", inspector.OpcodeEvent),
        .onOpcodeEnd = forwardTx("onOpcodeEnd", inspector.OpcodeEndEvent),
        .onFault = forwardTx("onFault", inspector.OpcodeEndEvent),
        .onLog = forwardTx("onLog", inspector.LogEvent),
        .onStorageChange = forwardTx("onStorageChange", inspector.StorageChangeEvent),
        .onTransientStorageChange = forwardTx("onTransientStorageChange", inspector.TransientStorageEvent),
        .onBalanceChange = forwardTx("onBalanceChange", inspector.BalanceChangeEvent),
        .onNonceChange = forwardTx("onNonceChange", inspector.NonceChangeEvent),
        .onCodeChange = forwardTx("onCodeChange", inspector.CodeChangeEvent),
        .onSelfDestruct = forwardTx("onSelfDestruct", inspector.SelfDestructEvent),
        .onAccess = forwardTx("onAccess", inspector.AccessEvent),
    };
};

// ---------------------------------------------------------------------------
// Signed 256-bit quantity helper for supply deltas
// ---------------------------------------------------------------------------

/// Signed 256-bit magnitude for per-block and cumulative ETH supply deltas.
pub const SignedU256 = struct {
    negative: bool = false,
    magnitude: u256 = 0,

    pub fn fromDiff(issued: u256, burned: u256) SignedU256 {
        if (issued >= burned) {
            return .{ .negative = false, .magnitude = issued - burned };
        }
        return .{ .negative = true, .magnitude = burned - issued };
    }

    pub fn isZero(self: SignedU256) bool {
        return self.magnitude == 0;
    }

    pub fn eql(self: SignedU256, other: SignedU256) bool {
        if (self.magnitude == 0 and other.magnitude == 0) return true;
        return self.negative == other.negative and self.magnitude == other.magnitude;
    }

    pub fn formatHexBuf(self: SignedU256, buf: *[80]u8) []const u8 {
        const hex = "0123456789abcdef";
        var idx: usize = 0;
        if (self.negative and self.magnitude != 0) {
            buf[idx] = '-';
            idx += 1;
        }
        buf[idx] = '0';
        buf[idx + 1] = 'x';
        idx += 2;
        if (self.magnitude == 0) {
            buf[idx] = '0';
            return buf[0 .. idx + 1];
        }
        var digits: [64]u8 = undefined;
        var count: usize = 0;
        var value = self.magnitude;
        while (value != 0) : (value >>= 4) {
            digits[count] = hex[@as(usize, @intCast(value & 0xf))];
            count += 1;
        }
        var i = count;
        while (i > 0) {
            i -= 1;
            buf[idx] = digits[i];
            idx += 1;
        }
        return buf[0..idx];
    }
};

// ---------------------------------------------------------------------------
// SupplyTracer (Geth `--vmtrace supply` reference live tracer)
// ---------------------------------------------------------------------------

pub const IssuanceBreakdown = struct {
    genesis: u256 = 0,
    block_reward: u256 = 0,
    uncle_reward: u256 = 0,
    withdrawal: u256 = 0,

    pub fn total(self: IssuanceBreakdown) u256 {
        return self.genesis +| self.block_reward +| self.uncle_reward +| self.withdrawal;
    }

    pub fn add(self: *IssuanceBreakdown, other: IssuanceBreakdown) void {
        self.genesis +|= other.genesis;
        self.block_reward +|= other.block_reward;
        self.uncle_reward +|= other.uncle_reward;
        self.withdrawal +|= other.withdrawal;
    }
};

pub const BurnBreakdown = struct {
    eip1559: u256 = 0,
    blob: u256 = 0,
    misc: u256 = 0,

    pub fn total(self: BurnBreakdown) u256 {
        return self.eip1559 +| self.blob +| self.misc;
    }

    pub fn add(self: *BurnBreakdown, other: BurnBreakdown) void {
        self.eip1559 +|= other.eip1559;
        self.blob +|= other.blob;
        self.misc +|= other.misc;
    }
};

pub const BlockSupplyRecord = struct {
    block_number: u64 = 0,
    block_hash: [32]u8 = @splat(0),
    parent_hash: [32]u8 = @splat(0),
    tx_count: usize = 0,
    gas_used: u64 = 0,
    base_fee: u256 = 0,
    blob_base_fee: u256 = 0,
    issuance: IssuanceBreakdown = .{},
    burn: BurnBreakdown = .{},
    delta: SignedU256 = .{},
    cumulative_issuance: u256 = 0,
    cumulative_burn: u256 = 0,
    cumulative_supply: SignedU256 = .{},
};

/// Adapts a fallible `method(self, event)` to an infallible vtable callback.
fn hook(comptime T: type, comptime Event: type, comptime method: anytype) *const fn (*anyopaque, Event) void {
    return &struct {
        fn call(ptr: *anyopaque, event: Event) void {
            const self: *T = @ptrCast(@alignCast(ptr));
            if (self.err != null) return;
            method(self, event) catch |e| {
                self.err = e;
            };
        }
    }.call;
}

/// Geth `--vmtrace supply` reference live tracer.
///
/// Tracks ETH issuance (genesis allocations, block/uncle rewards, beacon
/// withdrawals), burn (EIP-1559 base fee burns, EIP-4844 blob fee burns, and
/// miscellaneous burns), per-block net delta, and cumulative net supply.
pub const SupplyTracer = struct {
    pub const Options = struct {
        /// When true and no explicit `.fee_burn` balance change was recorded
        /// during a block, `onBlockEnd` computes EIP-1559 burn as
        /// `gas_used * base_fee`.
        infer_eip1559_burn: bool = false,
        /// When true, `tx_inspector` automatically accounts for EIP-4844 blob
        /// fee burns observed via `TxStartEvent`.
        track_tx_blob_burn: bool = true,
    };

    allocator: Allocator,
    options: Options,
    chain_id: ?u256 = null,
    hardfork: ?Hardfork = null,
    genesis_hash: ?[32]u8 = null,
    total_issuance_breakdown: IssuanceBreakdown = .{},
    total_burn_breakdown: BurnBreakdown = .{},
    total_issuance: u256 = 0,
    total_burn: u256 = 0,
    skipped_blocks: u64 = 0,
    failed_blocks: u64 = 0,
    closed: bool = false,
    current_block: ?BlockSupplyRecord = null,
    explicit_fee_burn_in_block: bool = false,
    records: std.ArrayList(BlockSupplyRecord) = .{},
    err: ?anyerror = null,

    pub fn init(allocator: Allocator, options: Options) SupplyTracer {
        return .{ .allocator = allocator, .options = options };
    }

    pub fn deinit(self: *SupplyTracer) void {
        self.records.deinit(self.allocator);
        self.* = undefined;
    }

    pub fn blockHooks(self: *SupplyTracer) BlockHooks {
        return .{
            .ptr = self,
            .vtable = &block_vtable,
            .tx_inspector = if (self.options.track_tx_blob_burn) self.txInspector() else null,
        };
    }

    pub fn txInspector(self: *SupplyTracer) Inspector {
        return .{
            .ptr = self,
            .vtable = &tx_vtable,
            .opcode_mask = inspector.OpcodeMask.NONE,
            .capture_memory = false,
        };
    }

    /// Cumulative net ETH supply as a signed 256-bit quantity (`total_issuance - total_burn`).
    pub fn netSupplySigned(self: *const SupplyTracer) SignedU256 {
        return SignedU256.fromDiff(self.total_issuance, self.total_burn);
    }

    /// Cumulative net ETH supply saturating at zero when observed burns exceed observed issuance.
    pub fn netSupply(self: *const SupplyTracer) u256 {
        return self.total_issuance -| self.total_burn;
    }

    /// Returns the most recently finalized block supply record, if any.
    pub fn latestRecord(self: *const SupplyTracer) ?BlockSupplyRecord {
        if (self.records.items.len == 0) return null;
        return self.records.items[self.records.items.len - 1];
    }

    /// Manually record an EIP-4844 blob fee burn in the active block (or
    /// directly against totals when outside a block).
    pub fn recordBlobBurn(self: *SupplyTracer, amount: u256) void {
        if (self.err != null or amount == 0) return;
        if (self.current_block) |*blk| {
            blk.burn.blob +|= amount;
        } else {
            self.total_burn_breakdown.blob +|= amount;
            self.total_burn +|= amount;
        }
    }

    /// Manually record a miscellaneous burn in the active block (or directly
    /// against totals when outside a block).
    pub fn recordMiscBurn(self: *SupplyTracer, amount: u256) void {
        if (self.err != null or amount == 0) return;
        if (self.current_block) |*blk| {
            blk.burn.misc +|= amount;
        } else {
            self.total_burn_breakdown.misc +|= amount;
            self.total_burn +|= amount;
        }
    }

    const block_vtable: BlockHooks.VTable = .{
        .onBlockchainInit = hook(SupplyTracer, ChainInitEvent, onBlockchainInit),
        .onGenesisBlock = hook(SupplyTracer, GenesisBlockEvent, onGenesisBlock),
        .onBlockStart = hook(SupplyTracer, BlockStartEvent, onBlockStart),
        .onBlockEnd = hook(SupplyTracer, BlockEndEvent, onBlockEnd),
        .onSkippedBlock = hook(SupplyTracer, SkippedBlockEvent, onSkippedBlock),
        .onBlockBalanceChange = hook(SupplyTracer, BlockBalanceChangeEvent, onBlockBalanceChange),
        .onClose = onCloseCallback,
    };

    const tx_vtable: Inspector.VTable = .{
        .onTxStart = hook(SupplyTracer, inspector.TxStartEvent, onTxStart),
    };

    fn onBlockchainInit(self: *SupplyTracer, event: ChainInitEvent) !void {
        self.chain_id = event.chain_id;
        self.hardfork = event.hardfork;
        self.genesis_hash = event.genesis_hash;
    }

    fn onGenesisBlock(self: *SupplyTracer, event: GenesisBlockEvent) !void {
        // Reserve first so totals never count a block whose record is lost.
        try self.records.ensureUnusedCapacity(self.allocator, 1);
        var genesis_total: u256 = 0;
        for (event.allocs) |entry| {
            genesis_total +|= entry.balance;
        }
        self.total_issuance_breakdown.genesis +|= genesis_total;
        self.total_issuance +|= genesis_total;

        const record: BlockSupplyRecord = .{
            .block_number = 0,
            .block_hash = event.block_hash,
            .parent_hash = @splat(0),
            .tx_count = 0,
            .gas_used = 0,
            .base_fee = 0,
            .blob_base_fee = 0,
            .issuance = .{ .genesis = genesis_total },
            .burn = .{},
            .delta = SignedU256.fromDiff(genesis_total, 0),
            .cumulative_issuance = self.total_issuance,
            .cumulative_burn = self.total_burn,
            .cumulative_supply = self.netSupplySigned(),
        };
        self.records.appendAssumeCapacity(record);
    }

    fn onBlockStart(self: *SupplyTracer, event: BlockStartEvent) !void {
        self.current_block = .{
            .block_number = event.number,
            .block_hash = event.hash,
            .parent_hash = event.parent_hash,
            .tx_count = event.tx_count,
            .base_fee = event.base_fee,
            .blob_base_fee = event.blob_base_fee,
        };
        self.explicit_fee_burn_in_block = false;
    }

    fn onTxStart(self: *SupplyTracer, event: inspector.TxStartEvent) !void {
        if (!self.options.track_tx_blob_burn) return;
        if (event.blob_hash_count == 0 or event.blob_base_fee == 0) return;
        const blob_gas = std.math.mul(u256, @as(u256, event.blob_hash_count), GAS_PER_BLOB) catch std.math.maxInt(u256);
        const blob_burn = std.math.mul(u256, blob_gas, event.blob_base_fee) catch std.math.maxInt(u256);
        self.recordBlobBurn(blob_burn);
    }

    fn onBlockBalanceChange(self: *SupplyTracer, event: BlockBalanceChangeEvent) !void {
        if (event.prev == event.new) return;
        switch (event.reason) {
            .genesis => {
                if (event.new > event.prev) {
                    const delta = event.new - event.prev;
                    if (self.current_block) |*blk| {
                        blk.issuance.genesis +|= delta;
                    } else {
                        self.total_issuance_breakdown.genesis +|= delta;
                        self.total_issuance +|= delta;
                    }
                }
            },
            .block_reward => {
                if (event.new > event.prev) {
                    const delta = event.new - event.prev;
                    if (self.current_block) |*blk| {
                        blk.issuance.block_reward +|= delta;
                    } else {
                        self.total_issuance_breakdown.block_reward +|= delta;
                        self.total_issuance +|= delta;
                    }
                }
            },
            .uncle_reward => {
                if (event.new > event.prev) {
                    const delta = event.new - event.prev;
                    if (self.current_block) |*blk| {
                        blk.issuance.uncle_reward +|= delta;
                    } else {
                        self.total_issuance_breakdown.uncle_reward +|= delta;
                        self.total_issuance +|= delta;
                    }
                }
            },
            .withdrawal => {
                if (event.new > event.prev) {
                    const delta = event.new - event.prev;
                    if (self.current_block) |*blk| {
                        blk.issuance.withdrawal +|= delta;
                    } else {
                        self.total_issuance_breakdown.withdrawal +|= delta;
                        self.total_issuance +|= delta;
                    }
                }
            },
            .fee_burn => {
                const delta = if (event.prev > event.new) event.prev - event.new else event.new - event.prev;
                if (self.current_block) |*blk| {
                    blk.burn.eip1559 +|= delta;
                    self.explicit_fee_burn_in_block = true;
                } else {
                    self.total_burn_breakdown.eip1559 +|= delta;
                    self.total_burn +|= delta;
                }
            },
            .tx_fee, .selfdestruct, .transfer, .unspecified => {},
        }
    }

    fn onBlockEnd(self: *SupplyTracer, event: BlockEndEvent) !void {
        var blk = self.current_block orelse BlockSupplyRecord{
            .block_number = event.number,
            .block_hash = event.hash,
        };
        self.current_block = null;
        const had_explicit_burn = self.explicit_fee_burn_in_block;
        self.explicit_fee_burn_in_block = false;

        if (event.error_name != null) {
            self.failed_blocks += 1;
            return;
        }

        try self.records.ensureUnusedCapacity(self.allocator, 1);
        blk.block_number = event.number;
        blk.block_hash = event.hash;
        blk.gas_used = event.gas_used;
        blk.tx_count = event.tx_count;

        if (self.options.infer_eip1559_burn and !had_explicit_burn and blk.base_fee > 0 and event.gas_used > 0) {
            const inferred = std.math.mul(u256, @as(u256, event.gas_used), blk.base_fee) catch std.math.maxInt(u256);
            blk.burn.eip1559 +|= inferred;
        }

        const block_issued = blk.issuance.total();
        const block_burned = blk.burn.total();
        blk.delta = SignedU256.fromDiff(block_issued, block_burned);

        self.total_issuance_breakdown.add(blk.issuance);
        self.total_burn_breakdown.add(blk.burn);
        self.total_issuance +|= block_issued;
        self.total_burn +|= block_burned;

        blk.cumulative_issuance = self.total_issuance;
        blk.cumulative_burn = self.total_burn;
        blk.cumulative_supply = self.netSupplySigned();

        self.records.appendAssumeCapacity(blk);
    }

    fn onSkippedBlock(self: *SupplyTracer, _: SkippedBlockEvent) !void {
        self.current_block = null;
        self.explicit_fee_burn_in_block = false;
        self.skipped_blocks += 1;
    }

    fn onCloseCallback(ptr: *anyopaque) void {
        const self: *SupplyTracer = @ptrCast(@alignCast(ptr));
        self.closed = true;
    }

    // -----------------------------------------------------------------------
    // JSON / NDJSON serialization
    // -----------------------------------------------------------------------

    fn writeHexBytes(json: *Stringify, bytes: []const u8) !void {
        try json.beginWriteRaw();
        try json.writer.print("\"0x{x}\"", .{bytes});
        json.endWriteRaw();
    }

    fn writeQuantity(json: *Stringify, value: u256) !void {
        var buf: [80]u8 = undefined;
        try json.write(try std.fmt.bufPrint(&buf, "0x{x}", .{value}));
    }

    fn writeSignedQuantity(json: *Stringify, value: SignedU256) !void {
        var buf: [80]u8 = undefined;
        try json.write(value.formatHexBuf(&buf));
    }

    fn writeIssuanceObject(json: *Stringify, issuance: IssuanceBreakdown) !void {
        try json.beginObject();
        try json.objectField("genesis");
        try writeQuantity(json, issuance.genesis);
        try json.objectField("blockReward");
        try writeQuantity(json, issuance.block_reward);
        try json.objectField("uncleReward");
        try writeQuantity(json, issuance.uncle_reward);
        try json.objectField("withdrawals");
        try writeQuantity(json, issuance.withdrawal);
        try json.objectField("total");
        try writeQuantity(json, issuance.total());
        try json.endObject();
    }

    fn writeBurnObject(json: *Stringify, burn: BurnBreakdown) !void {
        try json.beginObject();
        try json.objectField("eip1559");
        try writeQuantity(json, burn.eip1559);
        try json.objectField("blob");
        try writeQuantity(json, burn.blob);
        try json.objectField("misc");
        try writeQuantity(json, burn.misc);
        try json.objectField("total");
        try writeQuantity(json, burn.total());
        try json.endObject();
    }

    /// Writes a single `BlockSupplyRecord` as compact JSON (no trailing newline).
    pub fn writeRecordJson(record: BlockSupplyRecord, writer: *std.Io.Writer) !void {
        var json: Stringify = .{ .writer = writer };
        try json.beginObject();
        try json.objectField("blockNumber");
        try json.write(record.block_number);
        try json.objectField("hash");
        try writeHexBytes(&json, &record.block_hash);
        try json.objectField("parentHash");
        try writeHexBytes(&json, &record.parent_hash);
        try json.objectField("txCount");
        try json.write(record.tx_count);
        try json.objectField("gasUsed");
        try json.write(record.gas_used);
        try json.objectField("baseFee");
        try writeQuantity(&json, record.base_fee);
        try json.objectField("blobBaseFee");
        try writeQuantity(&json, record.blob_base_fee);
        try json.objectField("issuance");
        try writeIssuanceObject(&json, record.issuance);
        try json.objectField("burn");
        try writeBurnObject(&json, record.burn);
        try json.objectField("delta");
        try writeSignedQuantity(&json, record.delta);
        try json.objectField("cumulativeIssuance");
        try writeQuantity(&json, record.cumulative_issuance);
        try json.objectField("cumulativeBurn");
        try writeQuantity(&json, record.cumulative_burn);
        try json.objectField("cumulativeSupply");
        try writeSignedQuantity(&json, record.cumulative_supply);
        try json.endObject();
    }

    /// Writes all finalized block supply records as NDJSON (one JSON object per
    /// line, each terminated by `\n`).
    pub fn writeJsonlRecord(self: *const SupplyTracer, writer: *std.Io.Writer) !void {
        if (self.err) |e| return e;
        for (self.records.items) |record| {
            try writeRecordJson(record, writer);
            try writer.writeByte('\n');
        }
    }

    /// Writes the cumulative session supply summary as a JSON object.
    pub fn writeSummaryJson(self: *const SupplyTracer, writer: *std.Io.Writer) !void {
        if (self.err) |e| return e;
        var json: Stringify = .{ .writer = writer };
        try json.beginObject();
        if (self.chain_id) |cid| {
            try json.objectField("chainId");
            try writeQuantity(&json, cid);
        }
        if (self.genesis_hash) |gh| {
            try json.objectField("genesisHash");
            try writeHexBytes(&json, &gh);
        }
        try json.objectField("blocksProcessed");
        try json.write(self.records.items.len);
        try json.objectField("skippedBlocks");
        try json.write(self.skipped_blocks);
        try json.objectField("failedBlocks");
        try json.write(self.failed_blocks);
        try json.objectField("closed");
        try json.write(self.closed);
        try json.objectField("issuance");
        try writeIssuanceObject(&json, self.total_issuance_breakdown);
        try json.objectField("burn");
        try writeBurnObject(&json, self.total_burn_breakdown);
        try json.objectField("totalIssuance");
        try writeQuantity(&json, self.total_issuance);
        try json.objectField("totalBurn");
        try writeQuantity(&json, self.total_burn);
        try json.objectField("netSupply");
        try writeQuantity(&json, self.netSupply());
        try json.objectField("netDelta");
        try writeSignedQuantity(&json, self.netSupplySigned());
        try json.endObject();
    }
};
