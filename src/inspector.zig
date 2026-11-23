//! Read-only EVM execution hooks. All event slices are borrowed for the
//! duration of the callback. Mutation events include writes in reverted frames.
const std = @import("std");
const primitives = @import("voltaire");
const Address = primitives.Address;
const Hardfork = primitives.Hardfork;

pub const OpcodeMask = struct {
    words: [4]u64,

    pub const ALL: OpcodeMask = .{ .words = @splat(std.math.maxInt(u64)) };
    pub const NONE: OpcodeMask = .{ .words = @splat(0) };

    pub fn fromOpcodes(opcodes: []const u8) OpcodeMask {
        var mask = NONE;
        for (opcodes) |op| mask.words[op / 64] |= @as(u64, 1) << @as(u6, @truncate(op));
        return mask;
    }

    pub fn contains(self: OpcodeMask, op: u8) bool {
        return self.words[op / 64] & (@as(u64, 1) << @as(u6, @truncate(op))) != 0;
    }

    pub fn unionWith(self: OpcodeMask, other: OpcodeMask) OpcodeMask {
        var result: OpcodeMask = undefined;
        for (&result.words, self.words, other.words) |*word, left, right| word.* = left | right;
        return result;
    }
};

pub const CallType = enum { call, callcode, delegatecall, staticcall, create, create2, selfdestruct };

pub const TxStartEvent = struct {
    hardfork: Hardfork,
    origin: Address,
    target: Address,
    coinbase: Address,
    is_create: bool,
    value: u256,
    gas_limit: u64,
    gas_price: u256,
    input: []const u8,
    block_number: u64,
    block_timestamp: u64,
    chain_id: u256,
    blob_base_fee: u256,
    blob_hash_count: usize,
};

pub const TxEndEvent = struct {
    success: bool,
    gas_used: u64,
    gas_left: u64,
    gas_refund: u64,
    output: []const u8,
    error_name: ?[]const u8,
    created_address: ?Address,
};

pub const FrameEnterEvent = struct {
    frame_id: u64,
    parent_id: ?u64,
    depth: usize,
    call_type: CallType,
    from: Address,
    to: Address,
    code_address: Address,
    value: u256,
    gas: u64,
    input: []const u8,
    is_static: bool,
    is_precompile: bool,
    is_delegated: bool,
    code: []const u8,
};

pub const FrameExitEvent = struct {
    frame_id: u64,
    parent_id: ?u64,
    depth: usize,
    output: []const u8,
    gas_used: u64,
    gas_left: u64,
    reverted: bool,
    error_name: ?[]const u8,
    created_address: ?Address,
};

pub const OpcodeEvent = struct {
    frame_id: u64,
    pc: u64,
    op: u8,
    op_name: []const u8,
    gas: u64,
    memory_size: usize,
    memory: ?[]const u8,
    stack: []const u256,
    return_data: []const u8,
    depth: usize,
    refund: i64,
    address: Address,
    code_address: Address,
};

pub const OpcodeEndEvent = struct {
    frame_id: u64,
    pc: u64,
    op: u8,
    gas_cost: u64,
    gas_after: u64,
    memory_expansion_gas: u64,
    error_name: ?[]const u8,
};

pub const LogEvent = struct {
    frame_id: u64,
    address: Address,
    topics: []const [32]u8,
    data: []const u8,
};

pub const StorageChangeEvent = struct {
    frame_id: u64,
    address: Address,
    slot: u256,
    prev_value: u256,
    new_value: u256,
    is_read: bool,
};

pub const TransientStorageEvent = struct {
    frame_id: u64,
    address: Address,
    slot: u256,
    value: u256,
    is_write: bool,
};

pub const BalanceChangeEvent = struct {
    frame_id: u64,
    address: Address,
    prev_balance: u256,
    new_balance: u256,
};

pub const NonceChangeEvent = struct {
    frame_id: u64,
    address: Address,
    prev_nonce: u64,
    new_nonce: u64,
};

pub const CodeChangeEvent = struct {
    frame_id: u64,
    address: Address,
    prev_code: []const u8,
    new_code: []const u8,
};

pub const SelfDestructEvent = struct {
    frame_id: u64,
    address: Address,
    beneficiary: Address,
    value: u256,
};

pub const AccessEvent = struct {
    frame_id: u64,
    address: Address,
    slot: ?u256,
    was_warm: bool,
};

/// The context and vtable must outlive the registration on the EVM.
pub const Inspector = struct {
    ptr: *anyopaque,
    vtable: *const VTable,
    opcode_mask: OpcodeMask = OpcodeMask.ALL,
    capture_memory: bool = false,

    pub const VTable = struct {
        onTxStart: ?*const fn (*anyopaque, TxStartEvent) void = null,
        onTxEnd: ?*const fn (*anyopaque, TxEndEvent) void = null,
        onEnter: ?*const fn (*anyopaque, FrameEnterEvent) void = null,
        onExit: ?*const fn (*anyopaque, FrameExitEvent) void = null,
        onOpcode: ?*const fn (*anyopaque, OpcodeEvent) void = null,
        onOpcodeEnd: ?*const fn (*anyopaque, OpcodeEndEvent) void = null,
        onFault: ?*const fn (*anyopaque, OpcodeEndEvent) void = null,
        onLog: ?*const fn (*anyopaque, LogEvent) void = null,
        onStorageChange: ?*const fn (*anyopaque, StorageChangeEvent) void = null,
        onTransientStorageChange: ?*const fn (*anyopaque, TransientStorageEvent) void = null,
        onBalanceChange: ?*const fn (*anyopaque, BalanceChangeEvent) void = null,
        onNonceChange: ?*const fn (*anyopaque, NonceChangeEvent) void = null,
        onCodeChange: ?*const fn (*anyopaque, CodeChangeEvent) void = null,
        onSelfDestruct: ?*const fn (*anyopaque, SelfDestructEvent) void = null,
        onAccess: ?*const fn (*anyopaque, AccessEvent) void = null,
    };

    pub fn onTxStart(self: Inspector, event: TxStartEvent) void {
        if (self.vtable.onTxStart) |callback| callback(self.ptr, event);
    }

    pub fn onTxEnd(self: Inspector, event: TxEndEvent) void {
        if (self.vtable.onTxEnd) |callback| callback(self.ptr, event);
    }

    pub fn onEnter(self: Inspector, event: FrameEnterEvent) void {
        if (self.vtable.onEnter) |callback| callback(self.ptr, event);
    }

    pub fn onExit(self: Inspector, event: FrameExitEvent) void {
        if (self.vtable.onExit) |callback| callback(self.ptr, event);
    }

    pub fn onOpcode(self: Inspector, event: OpcodeEvent) void {
        if (!self.opcode_mask.contains(event.op)) return;
        var view = event;
        if (!self.capture_memory) view.memory = null;
        if (self.vtable.onOpcode) |callback| callback(self.ptr, view);
    }

    pub fn onOpcodeEnd(self: Inspector, event: OpcodeEndEvent) void {
        if (!self.opcode_mask.contains(event.op)) return;
        if (self.vtable.onOpcodeEnd) |callback| callback(self.ptr, event);
    }

    pub fn onFault(self: Inspector, event: OpcodeEndEvent) void {
        if (!self.opcode_mask.contains(event.op)) return;
        if (self.vtable.onFault) |callback| callback(self.ptr, event);
    }

    pub fn onLog(self: Inspector, event: LogEvent) void {
        if (self.vtable.onLog) |callback| callback(self.ptr, event);
    }

    pub fn onStorageChange(self: Inspector, event: StorageChangeEvent) void {
        if (self.vtable.onStorageChange) |callback| callback(self.ptr, event);
    }

    pub fn onTransientStorageChange(self: Inspector, event: TransientStorageEvent) void {
        if (self.vtable.onTransientStorageChange) |callback| callback(self.ptr, event);
    }

    pub fn onBalanceChange(self: Inspector, event: BalanceChangeEvent) void {
        if (self.vtable.onBalanceChange) |callback| callback(self.ptr, event);
    }

    pub fn onNonceChange(self: Inspector, event: NonceChangeEvent) void {
        if (self.vtable.onNonceChange) |callback| callback(self.ptr, event);
    }

    pub fn onCodeChange(self: Inspector, event: CodeChangeEvent) void {
        if (self.vtable.onCodeChange) |callback| callback(self.ptr, event);
    }

    pub fn onSelfDestruct(self: Inspector, event: SelfDestructEvent) void {
        if (self.vtable.onSelfDestruct) |callback| callback(self.ptr, event);
    }

    pub fn onAccess(self: Inspector, event: AccessEvent) void {
        if (self.vtable.onAccess) |callback| callback(self.ptr, event);
    }
};

/// Fan out one execution to multiple inspectors, preserving child order.
pub const MuxInspector = struct {
    children: []const Inspector,

    pub fn init(children: []const Inspector) MuxInspector {
        return .{ .children = children };
    }

    pub fn inspector(self: *MuxInspector) Inspector {
        var mask = OpcodeMask.NONE;
        var capture_memory = false;
        for (self.children) |child| {
            mask = mask.unionWith(child.opcode_mask);
            capture_memory = capture_memory or child.capture_memory;
        }
        return .{ .ptr = self, .vtable = &vtable, .opcode_mask = mask, .capture_memory = capture_memory };
    }

    fn forward(comptime name: []const u8, comptime Event: type) *const fn (*anyopaque, Event) void {
        return &struct {
            fn dispatch(ptr: *anyopaque, event: Event) void {
                const mux: *MuxInspector = @ptrCast(@alignCast(ptr));
                for (mux.children) |child| @field(Inspector, name)(child, event);
            }
        }.dispatch;
    }

    const vtable: Inspector.VTable = .{
        .onTxStart = forward("onTxStart", TxStartEvent),
        .onTxEnd = forward("onTxEnd", TxEndEvent),
        .onEnter = forward("onEnter", FrameEnterEvent),
        .onExit = forward("onExit", FrameExitEvent),
        .onOpcode = forward("onOpcode", OpcodeEvent),
        .onOpcodeEnd = forward("onOpcodeEnd", OpcodeEndEvent),
        .onFault = forward("onFault", OpcodeEndEvent),
        .onLog = forward("onLog", LogEvent),
        .onStorageChange = forward("onStorageChange", StorageChangeEvent),
        .onTransientStorageChange = forward("onTransientStorageChange", TransientStorageEvent),
        .onBalanceChange = forward("onBalanceChange", BalanceChangeEvent),
        .onNonceChange = forward("onNonceChange", NonceChangeEvent),
        .onCodeChange = forward("onCodeChange", CodeChangeEvent),
        .onSelfDestruct = forward("onSelfDestruct", SelfDestructEvent),
        .onAccess = forward("onAccess", AccessEvent),
    };
};

pub const DecodedRevert = union(enum) {
    reason: []const u8,
    panic: Panic,
};

pub const Panic = struct {
    code: u256,
    description: ?[]const u8,
};

pub const RevertDecoder = struct {
    pub fn decode(data: []const u8) ?DecodedRevert {
        if (data.len < 4) return null;
        const payload = data[4..];
        switch (std.mem.readInt(u32, data[0..4], .big)) {
            0x08c379a0 => {
                if (payload.len < 32) return null;
                const offset = std.math.cast(usize, std.mem.readInt(u256, payload[0..32], .big)) orelse return null;
                if (offset < 32 or offset % 32 != 0 or offset > payload.len - 32) return null;
                const len = std.math.cast(usize, std.mem.readInt(u256, payload[offset..][0..32], .big)) orelse return null;
                const contents = payload[offset + 32 ..];
                const padded_len = std.math.add(usize, len, (32 - len % 32) % 32) catch return null;
                if (padded_len > contents.len) return null;
                // Solidity strings are UTF-8; anything else is not a readable reason.
                if (!std.unicode.utf8ValidateSlice(contents[0..len])) return null;
                return .{ .reason = contents[0..len] };
            },
            0x4e487b71 => {
                if (payload.len < 32) return null;
                const code = std.mem.readInt(u256, payload[0..32], .big);
                return .{ .panic = .{ .code = code, .description = switch (code) {
                    0x00 => "generic compiler panic",
                    0x01 => "assertion failed",
                    0x11 => "arithmetic underflow or overflow",
                    0x12 => "division or modulo by zero",
                    0x21 => "invalid enum conversion",
                    0x22 => "incorrectly encoded storage byte array",
                    0x31 => "pop on an empty array",
                    0x32 => "array index out of bounds",
                    0x41 => "memory allocation overflow",
                    0x51 => "call to an uninitialized internal function",
                    else => null,
                } } };
            },
            else => return null,
        }
    }

    pub fn formatAlloc(allocator: std.mem.Allocator, data: []const u8) !?[]u8 {
        return switch (decode(data) orelse return null) {
            .reason => |reason| try allocator.dupe(u8, reason),
            .panic => |panic| if (panic.description) |description|
                try std.fmt.allocPrint(allocator, "panic 0x{x}: {s}", .{ panic.code, description })
            else
                try std.fmt.allocPrint(allocator, "panic 0x{x}", .{panic.code}),
        };
    }
};

pub fn formatErrorName(err: anyerror) []const u8 {
    return switch (err) {
        error.OutOfGas => "out of gas",
        error.StackUnderflow => "stack underflow",
        error.StackOverflow => "stack limit reached 1024",
        error.InvalidJump, error.InvalidJumpDestination => "invalid jump destination",
        error.InvalidOpcode => "invalid opcode",
        error.WriteProtection, error.StaticCallViolation => "write protection",
        error.ExecutionTimeout => "execution timeout",
        error.RevertExecution => "execution reverted",
        error.CallDepthExceeded => "max call depth exceeded",
        error.InsufficientBalance => "insufficient balance for transfer",
        error.ContractCollision => "contract address collision",
        error.NonceOverflow => "nonce uint64 overflow",
        error.CodeStoreOutOfGas => "contract creation code storage out of gas",
        error.CreateContractSizeLimit, error.BytecodeTooLarge => "max code size exceeded",
        error.InitcodeTooLarge, error.CreateInitCodeSizeLimit, error.InvalidInitCodeSize => "max initcode size exceeded",
        error.OutOfBounds => "return data out of bounds",
        error.InvalidBytecode => "invalid code",
        error.PrecompileError => "precompile error",
        error.OutOfMemory, error.AllocationError => "out of memory",
        error.NeedAsyncData => "execution suspended",
        else => @errorName(err),
    };
}

test "OpcodeMask covers all four words and unions without changing inputs" {
    const low = OpcodeMask.fromOpcodes(&.{ 0, 63, 64, 127 });
    const high = OpcodeMask.fromOpcodes(&.{ 128, 191, 192, 255 });
    const combined = low.unionWith(high);
    for (0..256) |i| {
        const op: u8 = @intCast(i);
        try std.testing.expect(OpcodeMask.ALL.contains(op));
        try std.testing.expect(!OpcodeMask.NONE.contains(op));
        try std.testing.expectEqual(low.contains(op) or high.contains(op), combined.contains(op));
    }
    for ([_]u8{ 0, 63, 64, 127, 128, 191, 192, 255 }) |op| try std.testing.expect(combined.contains(op));
    try std.testing.expect(!combined.contains(65));
}

test "RevertDecoder decodes ABI Error(string) and rejects invalid bounds" {
    var data = [_]u8{0} ** 100;
    @memcpy(data[0..4], &[_]u8{ 0x08, 0xc3, 0x79, 0xa0 });
    data[35] = 32;
    data[67] = 4;
    @memcpy(data[68..72], "oops");
    try std.testing.expectEqualStrings("oops", RevertDecoder.decode(&data).?.reason);
    const formatted = (try RevertDecoder.formatAlloc(std.testing.allocator, &data)).?;
    defer std.testing.allocator.free(formatted);
    try std.testing.expectEqualStrings("oops", formatted);
    for (0..100) |len| try std.testing.expect(RevertDecoder.decode(data[0..len]) == null);
    data[4] = 0xff;
    try std.testing.expect(RevertDecoder.decode(&data) == null);
    data[4] = 0;
    data[35] = 33;
    try std.testing.expect(RevertDecoder.decode(&data) == null);
    data[35] = 32;
    data[36] = 0xff;
    try std.testing.expect(RevertDecoder.decode(&data) == null);
    try std.testing.expect(try RevertDecoder.formatAlloc(std.testing.allocator, &.{ 1, 2, 3, 4 }) == null);
}

test "RevertDecoder rejects Error(string) payloads that are not UTF-8" {
    var data = [_]u8{0} ** 100;
    @memcpy(data[0..4], &[_]u8{ 0x08, 0xc3, 0x79, 0xa0 });
    data[35] = 32;
    data[67] = 4;
    @memcpy(data[68..72], &[_]u8{ 'o', 0xff, 0xfe, 'k' });
    try std.testing.expect(RevertDecoder.decode(&data) == null);
    try std.testing.expect(try RevertDecoder.formatAlloc(std.testing.allocator, &data) == null);
    // Multi-byte UTF-8 and control characters are valid reasons.
    @memcpy(data[68..72], "\xc3\xa9\"\n");
    try std.testing.expectEqualStrings("\xc3\xa9\"\n", RevertDecoder.decode(&data).?.reason);
}

test "RevertDecoder recognizes all standard panic codes and preserves unknown codes" {
    var data = [_]u8{0} ** 36;
    @memcpy(data[0..4], &[_]u8{ 0x4e, 0x48, 0x7b, 0x71 });
    for ([_]u8{ 0x00, 0x01, 0x11, 0x12, 0x21, 0x22, 0x31, 0x32, 0x41, 0x51 }) |code| {
        data[35] = code;
        const decoded = RevertDecoder.decode(&data).?.panic;
        try std.testing.expectEqual(@as(u256, code), decoded.code);
        try std.testing.expect(decoded.description != null);
    }
    data[35] = 0xff;
    try std.testing.expect(RevertDecoder.decode(&data).?.panic.description == null);
    const formatted = (try RevertDecoder.formatAlloc(std.testing.allocator, &data)).?;
    defer std.testing.allocator.free(formatted);
    try std.testing.expectEqualStrings("panic 0xff", formatted);
    try std.testing.expect(RevertDecoder.decode(data[0..35]) == null);
}

test "formatErrorName maps execution faults" {
    try std.testing.expectEqualStrings("out of gas", formatErrorName(error.OutOfGas));
    try std.testing.expectEqualStrings("stack underflow", formatErrorName(error.StackUnderflow));
    try std.testing.expectEqualStrings("stack limit reached 1024", formatErrorName(error.StackOverflow));
    try std.testing.expectEqualStrings("invalid jump destination", formatErrorName(error.InvalidJumpDestination));
    try std.testing.expectEqualStrings("invalid opcode", formatErrorName(error.InvalidOpcode));
    try std.testing.expectEqualStrings("write protection", formatErrorName(error.StaticCallViolation));
    try std.testing.expectEqualStrings("execution timeout", formatErrorName(error.ExecutionTimeout));
    try std.testing.expectEqualStrings("SomeCustomError", formatErrorName(error.SomeCustomError));
}

test "MuxInspector forwards masked opcodes and each child's memory preference" {
    const Observer = struct {
        seen: usize = 0,
        memory_seen: bool = false,

        fn onOpcode(ptr: *anyopaque, event: OpcodeEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            self.seen += 1;
            self.memory_seen = event.memory != null;
        }

        const vtable: Inspector.VTable = .{ .onOpcode = onOpcode };
    };
    var first: Observer = .{};
    var second: Observer = .{};
    const children = [_]Inspector{
        .{ .ptr = &first, .vtable = &Observer.vtable, .opcode_mask = OpcodeMask.fromOpcodes(&.{0x60}) },
        .{ .ptr = &second, .vtable = &Observer.vtable, .opcode_mask = OpcodeMask.fromOpcodes(&.{0x51}), .capture_memory = true },
    };
    var mux = MuxInspector.init(&children);
    const sink = mux.inspector();
    try std.testing.expect(sink.capture_memory);
    try std.testing.expect(sink.opcode_mask.contains(0x60));
    try std.testing.expect(sink.opcode_mask.contains(0x51));
    try std.testing.expect(!sink.opcode_mask.contains(0x01));
    var event: OpcodeEvent = .{
        .frame_id = 0,
        .pc = 1,
        .op = 0x60,
        .op_name = "PUSH1",
        .gas = 10,
        .memory_size = 1,
        .memory = &.{1},
        .stack = &.{},
        .return_data = &.{},
        .depth = 1,
        .refund = 0,
        .address = primitives.ZERO_ADDRESS,
        .code_address = primitives.ZERO_ADDRESS,
    };
    sink.onOpcode(event);
    try std.testing.expectEqual(@as(usize, 1), first.seen);
    try std.testing.expectEqual(@as(usize, 0), second.seen);
    try std.testing.expect(!first.memory_seen);
    event.op = 0x51;
    sink.onOpcode(event);
    try std.testing.expectEqual(@as(usize, 1), first.seen);
    try std.testing.expectEqual(@as(usize, 1), second.seen);
    try std.testing.expect(second.memory_seen);
}
