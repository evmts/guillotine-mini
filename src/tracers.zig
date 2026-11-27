//! Built-in native tracers on top of `inspector.zig`.
//!
//! Inspector callbacks return void, so every tracer records its first
//! internal failure (usually OutOfMemory) in `err`, stops collecting, and
//! returns that error from its JSON writers.
const std = @import("std");
const primitives = @import("voltaire");
const precompiles = @import("precompiles");
const insp = @import("inspector.zig");
const opcode_mod = @import("opcode.zig");

const Address = primitives.Address;
const Hardfork = primitives.Hardfork;
const Allocator = std.mem.Allocator;
const Stringify = std.json.Stringify;
const Inspector = insp.Inspector;
const OpcodeMask = insp.OpcodeMask;
const CallType = insp.CallType;

const p256verify_address = Address.fromU256(0x0100);

/// Mirrors the EVM's precompile table, including Osaka's P256VERIFY.
pub fn isPrecompile(address: Address, hardfork: Hardfork) bool {
    if (address.equals(p256verify_address)) return hardfork.isAtLeast(.OSAKA);
    return precompiles.isPrecompile(address, hardfork);
}

/// Adapts a fallible `method(self, event)` to an infallible vtable callback.
/// The first error is kept in `self.err`; later events are ignored.
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

// ---------------------------------------------------------------------------
// JSON helpers
// ---------------------------------------------------------------------------

fn writeHex(json: *Stringify, bytes: []const u8) !void {
    try json.beginWriteRaw();
    try json.writer.print("\"0x{x}\"", .{bytes});
    json.endWriteRaw();
}

fn writeHexField(json: *Stringify, field: []const u8, bytes: []const u8) !void {
    try json.objectField(field);
    try writeHex(json, bytes);
}

fn writeAddress(json: *Stringify, address: Address) !void {
    try writeHex(json, &address.bytes);
}

fn writeAddressField(json: *Stringify, field: []const u8, address: Address) !void {
    try json.objectField(field);
    try writeAddress(json, address);
}

fn writeQuantity(json: *Stringify, value: anytype) !void {
    var buf: [80]u8 = undefined;
    try json.write(try std.fmt.bufPrint(&buf, "0x{x}", .{value}));
}

fn writeQuantityField(json: *Stringify, field: []const u8, value: anytype) !void {
    try json.objectField(field);
    try writeQuantity(json, value);
}

/// Writes `text` as a JSON string. Escapes quotes, backslashes and control
/// characters; replaces invalid UTF-8 with U+FFFD so output is always valid.
pub fn writeJsonString(writer: *std.Io.Writer, text: []const u8) !void {
    try writer.writeByte('"');
    var i: usize = 0;
    while (i < text.len) {
        const byte = text[i];
        if (byte < 0x80) {
            switch (byte) {
                '"' => try writer.writeAll("\\\""),
                '\\' => try writer.writeAll("\\\\"),
                '\n' => try writer.writeAll("\\n"),
                '\r' => try writer.writeAll("\\r"),
                '\t' => try writer.writeAll("\\t"),
                0x08 => try writer.writeAll("\\b"),
                0x0c => try writer.writeAll("\\f"),
                0x00...0x07, 0x0b, 0x0e...0x1f => try writer.print("\\u{x:0>4}", .{byte}),
                else => try writer.writeByte(byte),
            }
            i += 1;
            continue;
        }
        const len = std.unicode.utf8ByteSequenceLength(byte) catch 0;
        if (len == 0 or i + len > text.len or !std.unicode.utf8ValidateSlice(text[i .. i + len])) {
            try writer.writeAll("\\ufffd");
            i += 1;
            continue;
        }
        try writer.writeAll(text[i .. i + len]);
        i += len;
    }
    try writer.writeByte('"');
}

fn writeJsonHex(writer: *std.Io.Writer, bytes: []const u8) !void {
    try writer.print("\"0x{x}\"", .{bytes});
}

/// Streaming JSON object writer with no nesting limit. Callers write nested
/// values directly to `writer` after `key`.
const JsonObject = struct {
    writer: *std.Io.Writer,
    first: bool = true,

    fn begin(writer: *std.Io.Writer) !JsonObject {
        try writer.writeByte('{');
        return .{ .writer = writer };
    }

    fn end(self: *JsonObject) !void {
        try self.writer.writeByte('}');
    }

    fn key(self: *JsonObject, name: []const u8) !void {
        if (!self.first) try self.writer.writeByte(',');
        self.first = false;
        try writeJsonString(self.writer, name);
        try self.writer.writeByte(':');
    }

    fn string(self: *JsonObject, name: []const u8, value: []const u8) !void {
        try self.key(name);
        try writeJsonString(self.writer, value);
    }

    fn hex(self: *JsonObject, name: []const u8, bytes: []const u8) !void {
        try self.key(name);
        try writeJsonHex(self.writer, bytes);
    }

    fn quantity(self: *JsonObject, name: []const u8, value: anytype) !void {
        try self.key(name);
        try self.writer.print("\"0x{x}\"", .{value});
    }
};

fn wordBytes(value: u256) [32]u8 {
    var out: [32]u8 = undefined;
    std.mem.writeInt(u256, &out, value, .big);
    return out;
}

fn formatHexLower(dst: []u8, bytes: []const u8) []const u8 {
    const hex = "0123456789abcdef";
    dst[0] = '0';
    dst[1] = 'x';
    for (bytes, 0..) |b, i| {
        dst[2 + i * 2] = hex[b >> 4];
        dst[3 + i * 2] = hex[b & 0x0f];
    }
    return dst[0 .. 2 + bytes.len * 2];
}

fn addressKey(buf: *[42]u8, address: Address) []const u8 {
    return formatHexLower(buf, &address.bytes);
}

fn wordKey(buf: *[66]u8, value: u256) []const u8 {
    const bytes = wordBytes(value);
    return formatHexLower(buf, &bytes);
}

fn addressLessThan(_: void, a: Address, b: Address) bool {
    return std.mem.order(u8, &a.bytes, &b.bytes) == .lt;
}

fn u256LessThan(_: void, a: u256, b: u256) bool {
    return a < b;
}

fn callTypeUpper(call_type: CallType) []const u8 {
    return switch (call_type) {
        .call => "CALL",
        .callcode => "CALLCODE",
        .delegatecall => "DELEGATECALL",
        .staticcall => "STATICCALL",
        .create => "CREATE",
        .create2 => "CREATE2",
        .selfdestruct => "SELFDESTRUCT",
    };
}

fn isCreate(call_type: CallType) bool {
    return call_type == .create or call_type == .create2;
}

// ---------------------------------------------------------------------------
// CallTracer
// ---------------------------------------------------------------------------

pub const CallLog = struct {
    address: Address,
    topics: []const [32]u8,
    data: []const u8,
    /// Number of child calls that preceded this log in its frame.
    position: usize,
};

pub const CallFrame = struct {
    frame_id: u64,
    call_type: CallType,
    from: Address,
    to: Address,
    code_address: Address,
    is_delegated: bool,
    is_precompile: bool,
    value: u256,
    gas: u64,
    gas_used: u64 = 0,
    input: []const u8 = &.{},
    output: []const u8 = &.{},
    error_msg: ?[]const u8 = null,
    revert_reason: ?[]const u8 = null,
    created_address: ?Address = null,
    reverted: bool = false,
    calls: std.ArrayList(*CallFrame) = .{},
    logs: std.ArrayList(CallLog) = .{},

    fn destroy(self: *CallFrame, allocator: Allocator) void {
        for (self.calls.items) |child| child.destroy(allocator);
        self.calls.deinit(allocator);
        for (self.logs.items) |entry| {
            allocator.free(entry.topics);
            allocator.free(entry.data);
        }
        self.logs.deinit(allocator);
        allocator.free(self.input);
        allocator.free(self.output);
        if (self.error_msg) |msg| allocator.free(msg);
        if (self.revert_reason) |msg| allocator.free(msg);
        allocator.destroy(self);
    }

    /// Geth reports the created address as `to` for CREATE frames.
    pub fn effectiveTo(self: *const CallFrame) Address {
        return self.created_address orelse self.to;
    }
};

/// Geth `callTracer` and `flatCallTracer` (Parity `trace_*`) output.
/// The tracer keeps the most recent top-level call.
pub const CallTracer = struct {
    pub const Options = struct {
        only_top_call: bool = false,
        with_log: bool = false,
    };

    allocator: Allocator,
    options: Options,
    root_frame: ?*CallFrame = null,
    stack: std.ArrayList(*CallFrame) = .{},
    skipped_depth: usize = 0,
    err: ?anyerror = null,

    pub fn init(allocator: Allocator, options: Options) CallTracer {
        return .{ .allocator = allocator, .options = options };
    }

    pub fn deinit(self: *CallTracer) void {
        if (self.root_frame) |frame| frame.destroy(self.allocator);
        self.stack.deinit(self.allocator);
        self.* = undefined;
    }

    pub fn inspector(self: *CallTracer) Inspector {
        return .{ .ptr = self, .vtable = &vtable, .opcode_mask = OpcodeMask.NONE };
    }

    pub fn root(self: *const CallTracer) ?*const CallFrame {
        return self.root_frame;
    }

    const vtable: Inspector.VTable = .{
        .onEnter = hook(CallTracer, insp.FrameEnterEvent, enter),
        .onExit = hook(CallTracer, insp.FrameExitEvent, exit),
        .onLog = hook(CallTracer, insp.LogEvent, log),
        .onSelfDestruct = hook(CallTracer, insp.SelfDestructEvent, selfDestruct),
    };

    fn addFrame(self: *CallTracer, init_frame: CallFrame, input: []const u8, push: bool) !void {
        const parent: ?*CallFrame = if (self.stack.items.len > 0) self.stack.items[self.stack.items.len - 1] else null;
        if (parent) |p| try p.calls.ensureUnusedCapacity(self.allocator, 1);
        if (push) try self.stack.ensureUnusedCapacity(self.allocator, 1);
        const frame = try self.allocator.create(CallFrame);
        errdefer self.allocator.destroy(frame);
        frame.* = init_frame;
        frame.input = try self.allocator.dupe(u8, input);
        if (parent) |p| {
            p.calls.appendAssumeCapacity(frame);
        } else {
            if (self.root_frame) |old| old.destroy(self.allocator);
            self.root_frame = frame;
        }
        if (push) self.stack.appendAssumeCapacity(frame);
    }

    fn enter(self: *CallTracer, event: insp.FrameEnterEvent) !void {
        if (self.skipped_depth > 0 or (self.options.only_top_call and self.stack.items.len > 0)) {
            self.skipped_depth += 1;
            return;
        }
        try self.addFrame(.{
            .frame_id = event.frame_id,
            .call_type = event.call_type,
            .from = event.from,
            .to = event.to,
            .code_address = event.code_address,
            .is_delegated = event.is_delegated,
            .is_precompile = event.is_precompile,
            .value = event.value,
            .gas = event.gas,
        }, event.input, true);
    }

    fn exit(self: *CallTracer, event: insp.FrameExitEvent) !void {
        if (self.skipped_depth > 0) {
            self.skipped_depth -= 1;
            return;
        }
        const frame = self.stack.pop() orelse return error.UnbalancedFrameExit;
        frame.gas_used = event.gas_used;
        frame.reverted = event.reverted;
        frame.created_address = event.created_address;
        frame.output = try self.allocator.dupe(u8, event.output);
        if (event.error_name) |name| frame.error_msg = try self.allocator.dupe(u8, name);
        if (event.reverted) frame.revert_reason = try insp.RevertDecoder.formatAlloc(self.allocator, event.output);
    }

    fn log(self: *CallTracer, event: insp.LogEvent) !void {
        if (!self.options.with_log or self.skipped_depth > 0) return;
        const frame = if (self.stack.items.len > 0) self.stack.items[self.stack.items.len - 1] else return;
        try frame.logs.ensureUnusedCapacity(self.allocator, 1);
        const topics = try self.allocator.dupe([32]u8, event.topics);
        errdefer self.allocator.free(topics);
        const data = try self.allocator.dupe(u8, event.data);
        frame.logs.appendAssumeCapacity(.{
            .address = event.address,
            .topics = topics,
            .data = data,
            .position = frame.calls.items.len,
        });
    }

    fn selfDestruct(self: *CallTracer, event: insp.SelfDestructEvent) !void {
        if (self.skipped_depth > 0 or self.options.only_top_call or self.stack.items.len == 0) return;
        try self.addFrame(.{
            .frame_id = std.math.maxInt(u64),
            .call_type = .selfdestruct,
            .from = event.address,
            .to = event.beneficiary,
            .code_address = event.address,
            .is_delegated = false,
            .is_precompile = false,
            .value = event.value,
            .gas = 0,
        }, &.{}, false);
    }

    /// Geth `callTracer` JSON. Logs from reverted frames and their
    /// descendants are omitted, matching Geth's `clearFailedLogs`.
    /// Written directly rather than with `std.json.Stringify`, whose nesting
    /// limit (256) is below the EVM's 1024-frame call depth.
    pub fn writeGethJson(self: *const CallTracer, writer: *std.Io.Writer) !void {
        if (self.err) |e| return e;
        if (self.root_frame) |frame| {
            try self.writeGethFrame(writer, frame, false);
        } else {
            try writer.writeAll("null");
        }
    }

    fn writeGethFrame(
        self: *const CallTracer,
        writer: *std.Io.Writer,
        frame: *const CallFrame,
        ancestor_reverted: bool,
    ) !void {
        const rolled_back = ancestor_reverted or frame.reverted;
        var obj = try JsonObject.begin(writer);
        try obj.string("type", callTypeUpper(frame.call_type));
        try obj.hex("from", &frame.from.bytes);
        try obj.quantity("gas", frame.gas);
        try obj.quantity("gasUsed", frame.gas_used);
        // Geth clears `to` on a failed CREATE: no contract exists at the predicted address.
        const failed_create = isCreate(frame.call_type) and frame.reverted and frame.created_address == null;
        if (!failed_create) try obj.hex("to", &frame.effectiveTo().bytes);
        try obj.hex("input", frame.input);
        if (frame.output.len > 0) try obj.hex("output", frame.output);
        if (frame.error_msg) |msg| try obj.string("error", msg);
        if (frame.revert_reason) |reason| try obj.string("revertReason", reason);
        if (frame.call_type != .staticcall) try obj.quantity("value", frame.value);
        if (self.options.with_log and !rolled_back and frame.logs.items.len > 0) {
            try obj.key("logs");
            try writer.writeByte('[');
            for (frame.logs.items, 0..) |entry, i| {
                if (i > 0) try writer.writeByte(',');
                var log_obj = try JsonObject.begin(writer);
                try log_obj.hex("address", &entry.address.bytes);
                try log_obj.key("topics");
                try writer.writeByte('[');
                for (entry.topics, 0..) |topic, j| {
                    if (j > 0) try writer.writeByte(',');
                    try writeJsonHex(writer, &topic);
                }
                try writer.writeByte(']');
                try log_obj.hex("data", entry.data);
                try log_obj.quantity("position", entry.position);
                try log_obj.end();
            }
            try writer.writeByte(']');
        }
        if (frame.calls.items.len > 0) {
            try obj.key("calls");
            try writer.writeByte('[');
            for (frame.calls.items, 0..) |child, i| {
                if (i > 0) try writer.writeByte(',');
                try self.writeGethFrame(writer, child, rolled_back);
            }
            try writer.writeByte(']');
        }
        try obj.end();
    }

    /// Geth `flatCallTracer` / Parity `trace_*` JSON array. Precompile
    /// frames are omitted, as with Geth's default `includePrecompiles=false`.
    pub fn writeFlatJson(self: *const CallTracer, writer: *std.Io.Writer) !void {
        if (self.err) |e| return e;
        var trace_address: std.ArrayList(usize) = .{};
        defer trace_address.deinit(self.allocator);
        var first = true;
        try writer.writeByte('[');
        if (self.root_frame) |frame| try self.writeFlatFrame(writer, frame, &trace_address, &first);
        try writer.writeByte(']');
    }

    fn visibleInFlat(frame: *const CallFrame) bool {
        return !frame.is_precompile;
    }

    fn writeFlatAction(writer: *std.Io.Writer, frame: *const CallFrame) !void {
        var action = try JsonObject.begin(writer);
        switch (frame.call_type) {
            .create, .create2 => {
                try action.string("creationMethod", if (frame.call_type == .create) "create" else "create2");
                try action.hex("from", &frame.from.bytes);
                try action.quantity("gas", frame.gas);
                try action.hex("init", frame.input);
                try action.quantity("value", frame.value);
            },
            .selfdestruct => {
                try action.hex("address", &frame.from.bytes);
                try action.quantity("balance", frame.value);
                try action.hex("refundAddress", &frame.to.bytes);
            },
            else => {
                try action.string("callType", switch (frame.call_type) {
                    .callcode => "callcode",
                    .delegatecall => "delegatecall",
                    .staticcall => "staticcall",
                    else => "call",
                });
                try action.hex("from", &frame.from.bytes);
                try action.quantity("gas", frame.gas);
                try action.hex("input", frame.input);
                try action.hex("to", &frame.to.bytes);
                try action.quantity("value", frame.value);
            },
        }
        try action.end();
    }

    fn writeFlatResult(obj: *JsonObject, writer: *std.Io.Writer, frame: *const CallFrame) !void {
        if (frame.call_type == .selfdestruct) {
            try obj.key("result");
            try writer.writeAll("null");
        } else if (frame.error_msg) |msg| {
            try obj.string("error", parityError(msg));
        } else {
            try obj.key("result");
            var result = try JsonObject.begin(writer);
            if (isCreate(frame.call_type)) {
                try result.hex("address", &frame.effectiveTo().bytes);
                try result.hex("code", frame.output);
                try result.quantity("gasUsed", frame.gas_used);
            } else {
                try result.quantity("gasUsed", frame.gas_used);
                try result.hex("output", frame.output);
            }
            try result.end();
        }
    }

    fn writeFlatFrame(
        self: *const CallTracer,
        writer: *std.Io.Writer,
        frame: *const CallFrame,
        trace_address: *std.ArrayList(usize),
        first: *bool,
    ) !void {
        var subtraces: usize = 0;
        for (frame.calls.items) |child| {
            if (visibleInFlat(child)) subtraces += 1;
        }
        if (!first.*) try writer.writeByte(',');
        first.* = false;
        var obj = try JsonObject.begin(writer);
        try obj.key("action");
        try writeFlatAction(writer, frame);
        try writeFlatResult(&obj, writer, frame);
        try obj.key("subtraces");
        try writer.print("{d}", .{subtraces});
        try obj.key("traceAddress");
        try writer.writeByte('[');
        for (trace_address.items, 0..) |index, i| {
            if (i > 0) try writer.writeByte(',');
            try writer.print("{d}", .{index});
        }
        try writer.writeByte(']');
        try obj.string("type", switch (frame.call_type) {
            .create, .create2 => "create",
            .selfdestruct => "suicide",
            else => "call",
        });
        try obj.end();

        var index: usize = 0;
        for (frame.calls.items) |child| {
            if (!visibleInFlat(child)) continue;
            try trace_address.append(self.allocator, index);
            defer _ = trace_address.pop();
            try self.writeFlatFrame(writer, child, trace_address, first);
            index += 1;
        }
    }

    fn parityError(msg: []const u8) []const u8 {
        const table = [_][2][]const u8{
            .{ "execution reverted", "Reverted" },
            .{ "out of gas", "Out of gas" },
            .{ "invalid jump destination", "Bad jump destination" },
            .{ "invalid opcode", "Bad instruction" },
            .{ "stack underflow", "Stack underflow" },
            .{ "stack limit reached 1024", "Out of stack" },
            .{ "write protection", "Mutable Call In Static Context" },
            .{ "contract creation code storage out of gas", "Contract code size limit exceeded" },
        };
        for (table) |row| {
            if (std.mem.eql(u8, msg, row[0])) return row[1];
        }
        return msg;
    }
};

// ---------------------------------------------------------------------------
// FourByteTracer
// ---------------------------------------------------------------------------

/// Geth `4byteTracer`: counts `selector-argsize` pairs for call-family frames.
pub const FourByteTracer = struct {
    pub const Key = struct { selector: [4]u8, arg_size: usize };

    allocator: Allocator,
    counts: std.AutoHashMapUnmanaged(Key, u64) = .{},
    err: ?anyerror = null,

    pub fn init(allocator: Allocator) FourByteTracer {
        return .{ .allocator = allocator };
    }

    pub fn deinit(self: *FourByteTracer) void {
        self.counts.deinit(self.allocator);
        self.* = undefined;
    }

    pub fn inspector(self: *FourByteTracer) Inspector {
        return .{ .ptr = self, .vtable = &vtable, .opcode_mask = OpcodeMask.NONE };
    }

    const vtable: Inspector.VTable = .{ .onEnter = hook(FourByteTracer, insp.FrameEnterEvent, enter) };

    fn enter(self: *FourByteTracer, event: insp.FrameEnterEvent) !void {
        switch (event.call_type) {
            .call, .callcode, .delegatecall, .staticcall => {},
            else => return,
        }
        if (event.is_precompile or event.input.len < 4) return;
        const key: Key = .{ .selector = event.input[0..4].*, .arg_size = event.input.len - 4 };
        const entry = try self.counts.getOrPut(self.allocator, key);
        if (!entry.found_existing) entry.value_ptr.* = 0;
        entry.value_ptr.* += 1;
    }

    pub fn getCount(self: *const FourByteTracer, selector: [4]u8, arg_size: usize) u64 {
        return self.counts.get(.{ .selector = selector, .arg_size = arg_size }) orelse 0;
    }

    fn keyLessThan(_: void, a: Key, b: Key) bool {
        return switch (std.mem.order(u8, &a.selector, &b.selector)) {
            .lt => true,
            .gt => false,
            .eq => a.arg_size < b.arg_size,
        };
    }

    pub fn writeJson(self: *const FourByteTracer, writer: *std.Io.Writer) !void {
        if (self.err) |e| return e;
        const keys = try self.allocator.alloc(Key, self.counts.count());
        defer self.allocator.free(keys);
        var it = self.counts.keyIterator();
        var i: usize = 0;
        while (it.next()) |key| : (i += 1) keys[i] = key.*;
        std.mem.sortUnstable(Key, keys, {}, keyLessThan);
        var json: Stringify = .{ .writer = writer };
        try json.beginObject();
        for (keys) |key| {
            var buf: [48]u8 = undefined;
            const sel: []const u8 = &key.selector;
            try json.objectField(try std.fmt.bufPrint(&buf, "0x{x}-{d}", .{ sel, key.arg_size }));
            try json.write(self.counts.get(key).?);
        }
        try json.endObject();
    }
};

// ---------------------------------------------------------------------------
// PrestateTracer
// ---------------------------------------------------------------------------

/// Geth `prestateTracer`, including `diffMode`. State is learned from
/// inspector events only: a field appears once a frame, read, or write
/// reveals it. Post-state is rolled back with each reverted frame.
pub const PrestateTracer = struct {
    pub const Options = struct {
        diff_mode: bool = false,
        disable_code: bool = false,
        disable_storage: bool = false,
    };

    pub const AccountState = struct {
        balance: ?u256 = null,
        nonce: ?u64 = null,
        code: ?[]const u8 = null,
        storage: std.AutoArrayHashMapUnmanaged(u256, u256) = .{},

        fn deinit(self: *AccountState, allocator: Allocator) void {
            if (self.code) |code| allocator.free(code);
            self.storage.deinit(allocator);
        }
    };

    pub const Account = struct {
        pre: AccountState = .{},
        post: AccountState = .{},
        created: bool = false,
        selfdestructed: bool = false,
    };

    const Undo = union(enum) {
        balance: struct { address: Address, prev: ?u256 },
        nonce: struct { address: Address, prev: ?u64 },
        code: struct { address: Address, prev: ?[]const u8 },
        storage: struct { address: Address, slot: u256, prev: ?u256 },
        created: struct { address: Address, prev: bool },
        selfdestructed: struct { address: Address, prev: bool },
    };

    allocator: Allocator,
    options: Options,
    accounts: std.AutoArrayHashMapUnmanaged(Address, Account) = .{},
    undo_log: std.ArrayList(Undo) = .{},
    frame_marks: std.ArrayList(usize) = .{},
    err: ?anyerror = null,

    pub fn init(allocator: Allocator, options: Options) PrestateTracer {
        return .{ .allocator = allocator, .options = options };
    }

    pub fn deinit(self: *PrestateTracer) void {
        for (self.accounts.values()) |*acct| {
            acct.pre.deinit(self.allocator);
            acct.post.deinit(self.allocator);
        }
        self.accounts.deinit(self.allocator);
        self.commitAll();
        self.undo_log.deinit(self.allocator);
        self.frame_marks.deinit(self.allocator);
        self.* = undefined;
    }

    pub fn inspector(self: *PrestateTracer) Inspector {
        return .{ .ptr = self, .vtable = &vtable, .opcode_mask = OpcodeMask.NONE };
    }

    /// Account state observed for `address`, or null if never touched.
    pub fn account(self: *const PrestateTracer, address: Address) ?*const Account {
        return self.accounts.getPtr(address);
    }

    const vtable: Inspector.VTable = .{
        .onEnter = hook(PrestateTracer, insp.FrameEnterEvent, enter),
        .onExit = hook(PrestateTracer, insp.FrameExitEvent, exit),
        .onStorageChange = hook(PrestateTracer, insp.StorageChangeEvent, storageChange),
        .onBalanceChange = hook(PrestateTracer, insp.BalanceChangeEvent, balanceChange),
        .onNonceChange = hook(PrestateTracer, insp.NonceChangeEvent, nonceChange),
        .onCodeChange = hook(PrestateTracer, insp.CodeChangeEvent, codeChange),
        .onSelfDestruct = hook(PrestateTracer, insp.SelfDestructEvent, selfDestruct),
    };

    fn touch(self: *PrestateTracer, address: Address) !*Account {
        const entry = try self.accounts.getOrPut(self.allocator, address);
        if (!entry.found_existing) entry.value_ptr.* = .{};
        return entry.value_ptr;
    }

    fn inFrame(self: *const PrestateTracer) bool {
        return self.frame_marks.items.len > 0;
    }

    /// Reserve undo space before mutating so a failed append cannot desync.
    fn reserveUndo(self: *PrestateTracer) !void {
        if (self.inFrame()) try self.undo_log.ensureUnusedCapacity(self.allocator, 1);
    }

    fn recordPreCode(self: *PrestateTracer, address: Address, code: []const u8) !void {
        if (self.options.disable_code) return;
        const acct = try self.touch(address);
        if (acct.pre.code == null and acct.post.code == null) acct.pre.code = try self.allocator.dupe(u8, code);
    }

    fn enter(self: *PrestateTracer, event: insp.FrameEnterEvent) !void {
        try self.frame_marks.append(self.allocator, self.undo_log.items.len);
        _ = try self.touch(event.from);
        if (isCreate(event.call_type)) {
            try self.reserveUndo();
            const acct = try self.touch(event.to);
            if (self.inFrame()) {
                self.undo_log.appendAssumeCapacity(.{
                    .created = .{ .address = event.to, .prev = acct.created },
                });
            }
            acct.created = true;
            return;
        }
        if (event.is_precompile) return;
        _ = try self.touch(event.to);
        try self.recordPreCode(event.code_address, event.code);
        if (event.is_delegated) {
            // EIP-7702: the called account holds the designation, not the code.
            var designation: [23]u8 = undefined;
            designation[0..3].* = .{ 0xef, 0x01, 0x00 };
            designation[3..].* = event.code_address.bytes;
            try self.recordPreCode(event.to, &designation);
        }
    }

    fn exit(self: *PrestateTracer, event: insp.FrameExitEvent) !void {
        const mark = self.frame_marks.pop() orelse return error.UnbalancedFrameExit;
        if (event.reverted) self.rollbackTo(mark);
        if (!self.inFrame()) self.commitAll();
    }

    fn rollbackTo(self: *PrestateTracer, mark: usize) void {
        while (self.undo_log.items.len > mark) {
            const undo = self.undo_log.pop().?;
            switch (undo) {
                .balance => |u| self.accounts.getPtr(u.address).?.post.balance = u.prev,
                .nonce => |u| self.accounts.getPtr(u.address).?.post.nonce = u.prev,
                .code => |u| {
                    const acct = self.accounts.getPtr(u.address).?;
                    if (acct.post.code) |current| self.allocator.free(current);
                    acct.post.code = u.prev;
                },
                .storage => |u| {
                    const storage = &self.accounts.getPtr(u.address).?.post.storage;
                    if (u.prev) |prev| {
                        storage.getPtr(u.slot).?.* = prev;
                    } else {
                        _ = storage.orderedRemove(u.slot);
                    }
                },
                .created => |u| self.accounts.getPtr(u.address).?.created = u.prev,
                .selfdestructed => |u| self.accounts.getPtr(u.address).?.selfdestructed = u.prev,
            }
        }
    }

    fn commitAll(self: *PrestateTracer) void {
        for (self.undo_log.items) |undo| switch (undo) {
            .code => |u| if (u.prev) |prev| self.allocator.free(prev),
            else => {},
        };
        self.undo_log.clearRetainingCapacity();
    }

    fn balanceChange(self: *PrestateTracer, event: insp.BalanceChangeEvent) !void {
        try self.reserveUndo();
        const acct = try self.touch(event.address);
        if (acct.pre.balance == null) acct.pre.balance = event.prev_balance;
        if (self.inFrame()) {
            self.undo_log.appendAssumeCapacity(.{
                .balance = .{ .address = event.address, .prev = acct.post.balance },
            });
        }
        acct.post.balance = event.new_balance;
    }

    fn nonceChange(self: *PrestateTracer, event: insp.NonceChangeEvent) !void {
        try self.reserveUndo();
        const acct = try self.touch(event.address);
        if (acct.pre.nonce == null) acct.pre.nonce = event.prev_nonce;
        if (self.inFrame()) {
            self.undo_log.appendAssumeCapacity(.{
                .nonce = .{ .address = event.address, .prev = acct.post.nonce },
            });
        }
        acct.post.nonce = event.new_nonce;
    }

    fn codeChange(self: *PrestateTracer, event: insp.CodeChangeEvent) !void {
        if (self.options.disable_code) {
            _ = try self.touch(event.address);
            return;
        }
        try self.reserveUndo();
        const acct = try self.touch(event.address);
        if (acct.pre.code == null and acct.post.code == null) {
            acct.pre.code = try self.allocator.dupe(u8, event.prev_code);
        }
        const copy = try self.allocator.dupe(u8, event.new_code);
        if (self.inFrame()) {
            self.undo_log.appendAssumeCapacity(.{ .code = .{ .address = event.address, .prev = acct.post.code } });
        } else if (acct.post.code) |old| {
            self.allocator.free(old);
        }
        acct.post.code = copy;
    }

    fn storageChange(self: *PrestateTracer, event: insp.StorageChangeEvent) !void {
        const acct = try self.touch(event.address);
        if (self.options.disable_storage) return;
        const pre = try acct.pre.storage.getOrPut(self.allocator, event.slot);
        if (!pre.found_existing) pre.value_ptr.* = event.prev_value;
        if (event.is_read) return;
        try self.reserveUndo();
        const post = try acct.post.storage.getOrPut(self.allocator, event.slot);
        const prev: ?u256 = if (post.found_existing) post.value_ptr.* else null;
        if (self.inFrame()) {
            self.undo_log.appendAssumeCapacity(.{
                .storage = .{ .address = event.address, .slot = event.slot, .prev = prev },
            });
        }
        post.value_ptr.* = event.new_value;
    }

    fn selfDestruct(self: *PrestateTracer, event: insp.SelfDestructEvent) !void {
        _ = try self.touch(event.beneficiary);
        try self.reserveUndo();
        const acct = try self.touch(event.address);
        if (self.inFrame()) {
            self.undo_log.appendAssumeCapacity(.{
                .selfdestructed = .{ .address = event.address, .prev = acct.selfdestructed },
            });
        }
        acct.selfdestructed = true;
    }

    const empty_code: []const u8 = &.{};

    fn finalBalance(acct: *const Account) u256 {
        return acct.post.balance orelse acct.pre.balance orelse 0;
    }
    fn finalNonce(acct: *const Account) u64 {
        return acct.post.nonce orelse acct.pre.nonce orelse 0;
    }
    fn finalCode(acct: *const Account) []const u8 {
        return acct.post.code orelse acct.pre.code orelse empty_code;
    }

    fn balanceChanged(acct: *const Account) bool {
        const post = acct.post.balance orelse return false;
        return post != (acct.pre.balance orelse 0);
    }
    fn nonceChanged(acct: *const Account) bool {
        const post = acct.post.nonce orelse return false;
        return post != (acct.pre.nonce orelse 0);
    }
    fn codeChanged(self: *const PrestateTracer, acct: *const Account) bool {
        if (self.options.disable_code) return false;
        const post = acct.post.code orelse return false;
        return !std.mem.eql(u8, post, acct.pre.code orelse empty_code);
    }
    fn slotChanged(acct: *const Account, slot: u256, value: u256) bool {
        return value != (acct.pre.storage.get(slot) orelse 0);
    }
    fn storageChanged(self: *const PrestateTracer, acct: *const Account) bool {
        if (self.options.disable_storage) return false;
        var it = acct.post.storage.iterator();
        while (it.next()) |entry| if (slotChanged(acct, entry.key_ptr.*, entry.value_ptr.*)) return true;
        return false;
    }
    /// True when nothing was observed for `acct` before this transaction touched it.
    fn preEmpty(acct: *const Account) bool {
        if ((acct.pre.balance orelse 0) != 0 or (acct.pre.nonce orelse 0) != 0) return false;
        if ((acct.pre.code orelse empty_code).len != 0) return false;
        for (acct.pre.storage.values()) |value| if (value != 0) return false;
        return true;
    }
    fn isDeleted(acct: *const Account) bool {
        return acct.selfdestructed and finalBalance(acct) == 0 and finalNonce(acct) == 0 and finalCode(acct).len == 0;
    }

    const Section = enum { prestate, diff_pre, diff_post };

    pub fn writeJson(self: *const PrestateTracer, writer: *std.Io.Writer) !void {
        if (self.err) |e| return e;
        const addresses = try self.allocator.dupe(Address, self.accounts.keys());
        defer self.allocator.free(addresses);
        std.mem.sortUnstable(Address, addresses, {}, addressLessThan);
        var json: Stringify = .{ .writer = writer };
        if (!self.options.diff_mode) return self.writeSection(&json, addresses, .prestate);
        try json.beginObject();
        try json.objectField("post");
        try self.writeSection(&json, addresses, .diff_post);
        try json.objectField("pre");
        try self.writeSection(&json, addresses, .diff_pre);
        try json.endObject();
    }

    fn writeSection(self: *const PrestateTracer, json: *Stringify, addresses: []const Address, section: Section) !void {
        try json.beginObject();
        for (addresses) |address| {
            const acct = self.accounts.getPtr(address).?;
            const fields = self.sectionFields(acct, section) orelse continue;
            var key: [42]u8 = undefined;
            try json.objectField(addressKey(&key, address));
            try self.writeAccount(json, acct, section, fields);
        }
        try json.endObject();
    }

    const Fields = struct { balance: bool, nonce: bool, code: bool, storage: bool };

    /// Which fields a section emits for `acct`; null skips the account.
    fn sectionFields(self: *const PrestateTracer, acct: *const Account, section: Section) ?Fields {
        const deleted = isDeleted(acct);
        switch (section) {
            .prestate => return .{
                .balance = acct.pre.balance != null,
                .nonce = (acct.pre.nonce orelse 0) != 0,
                .code = !self.options.disable_code and (acct.pre.code orelse empty_code).len != 0,
                .storage = !self.options.disable_storage and acct.pre.storage.count() != 0,
            },
            .diff_pre => {
                if (acct.created) {
                    // Geth drops a created account's pre entry only when it was
                    // empty; a prefunded CREATE target keeps its observed balance.
                    if (preEmpty(acct)) return null;
                    return .{
                        .balance = (acct.pre.balance orelse 0) != 0,
                        .nonce = false,
                        .code = false,
                        .storage = self.storageChanged(acct),
                    };
                }
                if (deleted) {
                    const full = self.sectionFields(acct, .prestate).?;
                    if (!(full.balance or full.nonce or full.code or full.storage)) return null;
                    return full;
                }
                const fields: Fields = .{
                    .balance = balanceChanged(acct),
                    .nonce = nonceChanged(acct),
                    .code = self.codeChanged(acct),
                    .storage = self.storageChanged(acct),
                };
                if (!(fields.balance or fields.nonce or fields.code or fields.storage)) return null;
                return fields;
            },
            .diff_post => {
                if (deleted) return null;
                var fields: Fields = .{
                    .balance = balanceChanged(acct),
                    .nonce = nonceChanged(acct),
                    .code = self.codeChanged(acct),
                    .storage = false,
                };
                if (self.storageChanged(acct)) {
                    var it = acct.post.storage.iterator();
                    while (it.next()) |entry| {
                        const val = entry.value_ptr.*;
                        if (val != 0 and slotChanged(acct, entry.key_ptr.*, val)) fields.storage = true;
                    }
                }
                if (!(fields.balance or fields.nonce or fields.code or fields.storage)) return null;
                return fields;
            },
        }
    }

    fn writeAccount(
        self: *const PrestateTracer,
        json: *Stringify,
        acct: *const Account,
        section: Section,
        fields: Fields,
    ) !void {
        const state = if (section == .diff_post) &acct.post else &acct.pre;
        try json.beginObject();
        if (fields.balance) try writeQuantityField(json, "balance", state.balance orelse 0);
        if (fields.code) try writeHexField(json, "code", state.code orelse empty_code);
        // Geth's `nonce,omitempty`: an absent nonce means zero.
        if (fields.nonce and (state.nonce orelse 0) != 0) {
            try json.objectField("nonce");
            try json.write(state.nonce orelse 0);
        }
        if (fields.storage) {
            const slots = try self.allocator.dupe(u256, state.storage.keys());
            defer self.allocator.free(slots);
            std.mem.sortUnstable(u256, slots, {}, u256LessThan);
            try json.objectField("storage");
            try json.beginObject();
            for (slots) |slot| {
                const value = state.storage.get(slot).?;
                const include = switch (section) {
                    .prestate => true,
                    .diff_pre => blk: {
                        if (isDeleted(acct)) break :blk true;
                        const post_val = acct.post.storage.get(slot) orelse break :blk false;
                        break :blk slotChanged(acct, slot, post_val);
                    },
                    .diff_post => value != 0 and slotChanged(acct, slot, value),
                };
                if (!include) continue;
                var key: [66]u8 = undefined;
                try json.objectField(wordKey(&key, slot));
                try writeHex(json, &wordBytes(value));
            }
            try json.endObject();
        }
        try json.endObject();
    }
};

// ---------------------------------------------------------------------------
// AccessListInspector
// ---------------------------------------------------------------------------

pub const AccessListEntry = struct {
    address: Address,
    storage_keys: []const [32]u8,
};

pub fn freeAccessListEntries(allocator: Allocator, entries: []const AccessListEntry) void {
    for (entries) |entry| allocator.free(entry.storage_keys);
    allocator.free(entries);
}

/// Geth `eth_createAccessList` / Revm `AccessListInspector`. Accesses in
/// reverted frames are kept: EIP-2929 warmth is not rolled back for the list.
pub const AccessListInspector = struct {
    pub const Options = struct {
        exclude_origin: bool = true,
        exclude_target: bool = true,
        exclude_precompiles: bool = true,
        exclude_coinbase: bool = false,
    };

    const SlotKey = struct { address: [20]u8, slot: [32]u8 };

    allocator: Allocator,
    options: Options,
    origin: ?Address = null,
    target: ?Address = null,
    coinbase: ?Address = null,
    hardfork: ?Hardfork = null,
    addresses: std.AutoArrayHashMapUnmanaged(Address, void) = .{},
    slots: std.AutoArrayHashMapUnmanaged(SlotKey, void) = .{},
    /// Contracts created in this transaction; Geth never lists them.
    created: std.AutoArrayHashMapUnmanaged(Address, void) = .{},
    err: ?anyerror = null,

    pub fn init(allocator: Allocator, options: Options) AccessListInspector {
        return .{ .allocator = allocator, .options = options };
    }

    pub fn deinit(self: *AccessListInspector) void {
        self.addresses.deinit(self.allocator);
        self.slots.deinit(self.allocator);
        self.created.deinit(self.allocator);
        self.* = undefined;
    }

    pub fn inspector(self: *AccessListInspector) Inspector {
        return .{ .ptr = self, .vtable = &vtable, .opcode_mask = OpcodeMask.NONE };
    }

    const vtable: Inspector.VTable = .{
        .onTxStart = txStart,
        .onExit = hook(AccessListInspector, insp.FrameExitEvent, exit),
        .onAccess = hook(AccessListInspector, insp.AccessEvent, access),
    };

    /// Exclude a CREATE target only once it exists. A colliding or reverted
    /// CREATE leaves earlier accesses to that address in the list.
    fn exit(self: *AccessListInspector, event: insp.FrameExitEvent) !void {
        if (event.reverted) return;
        if (event.created_address) |address| try self.created.put(self.allocator, address, {});
    }

    /// Each transaction starts a fresh list, including after a failed one.
    fn txStart(ptr: *anyopaque, event: insp.TxStartEvent) void {
        const self: *AccessListInspector = @ptrCast(@alignCast(ptr));
        self.addresses.clearRetainingCapacity();
        self.slots.clearRetainingCapacity();
        self.created.clearRetainingCapacity();
        self.err = null;
        self.origin = event.origin;
        self.target = event.target;
        self.coinbase = event.coinbase;
        self.hardfork = event.hardfork;
    }

    fn access(self: *AccessListInspector, event: insp.AccessEvent) !void {
        if (event.slot) |slot| {
            try self.slots.put(self.allocator, .{ .address = event.address.bytes, .slot = wordBytes(slot) }, {});
        } else {
            try self.addresses.put(self.allocator, event.address, {});
        }
    }

    pub fn isExcluded(self: *const AccessListInspector, address: Address) bool {
        if (self.options.exclude_origin) if (self.origin) |a| if (a.equals(address)) return true;
        if (self.options.exclude_target) if (self.target) |a| if (a.equals(address)) return true;
        if (self.options.exclude_coinbase) if (self.coinbase) |a| if (a.equals(address)) return true;
        if (self.options.exclude_precompiles) if (self.hardfork) |fork| if (isPrecompile(address, fork)) return true;
        return self.created.contains(address);
    }

    fn slotLessThan(_: void, a: SlotKey, b: SlotKey) bool {
        return switch (std.mem.order(u8, &a.address, &b.address)) {
            .lt => true,
            .gt => false,
            .eq => std.mem.order(u8, &a.slot, &b.slot) == .lt,
        };
    }

    /// Sorted entries. Excluded accounts appear only when they have storage keys.
    /// Free with `freeAccessListEntries`.
    pub fn toOwnedEntries(self: *const AccessListInspector, allocator: Allocator) ![]AccessListEntry {
        if (self.err) |e| return e;
        const slots = try allocator.dupe(SlotKey, self.slots.keys());
        defer allocator.free(slots);
        std.mem.sortUnstable(SlotKey, slots, {}, slotLessThan);

        var addresses: std.AutoArrayHashMapUnmanaged(Address, void) = .{};
        defer addresses.deinit(allocator);
        for (self.addresses.keys()) |address| {
            if (!self.isExcluded(address)) try addresses.put(allocator, address, {});
        }
        for (slots) |slot| try addresses.put(allocator, .{ .bytes = slot.address }, {});
        const sorted = try allocator.dupe(Address, addresses.keys());
        defer allocator.free(sorted);
        std.mem.sortUnstable(Address, sorted, {}, addressLessThan);

        var entries: std.ArrayList(AccessListEntry) = .{};
        errdefer {
            for (entries.items) |entry| allocator.free(entry.storage_keys);
            entries.deinit(allocator);
        }
        try entries.ensureTotalCapacity(allocator, sorted.len);
        var cursor: usize = 0;
        for (sorted) |address| {
            const start = cursor;
            while (cursor < slots.len and std.mem.eql(u8, &slots[cursor].address, &address.bytes)) cursor += 1;
            const keys = try allocator.alloc([32]u8, cursor - start);
            for (slots[start..cursor], keys) |slot, *key| key.* = slot.slot;
            entries.appendAssumeCapacity(.{ .address = address, .storage_keys = keys });
        }
        return entries.toOwnedSlice(allocator);
    }

    /// EIP-2930 JSON: `[{"address": ..., "storageKeys": [...]}]`.
    pub fn writeJson(self: *const AccessListInspector, writer: *std.Io.Writer) !void {
        const entries = try self.toOwnedEntries(self.allocator);
        defer freeAccessListEntries(self.allocator, entries);
        var json: Stringify = .{ .writer = writer };
        try json.beginArray();
        for (entries) |entry| {
            try json.beginObject();
            try writeAddressField(&json, "address", entry.address);
            try json.objectField("storageKeys");
            try json.beginArray();
            for (entry.storage_keys) |key| try writeHex(&json, &key);
            try json.endArray();
            try json.endObject();
        }
        try json.endArray();
    }
};

// ---------------------------------------------------------------------------
// GasProfiler
// ---------------------------------------------------------------------------

pub const OpcodeStats = struct {
    count: u64 = 0,
    /// Includes gas forwarded to child frames by CALL-family opcodes.
    total_gas: u64 = 0,
    memory_expansion_gas: u64 = 0,
    /// Executions that ended with an error, including REVERT.
    fault_count: u64 = 0,
};

pub const OpcodeRank = struct {
    op: u8,
    name: []const u8,
    stats: OpcodeStats,
};

pub const FrameGasProfile = struct {
    frame_id: u64,
    parent_id: ?u64,
    depth: usize,
    call_type: CallType,
    to: Address,
    gas_supplied: u64,
    inclusive_gas: u64 = 0,
    exclusive_gas: u64 = 0,
    opcode_count: u64 = 0,
    reverted: bool = false,
    children_gas: u64 = 0,
};

/// Opcode histogram plus inclusive/exclusive gas per frame.
pub const GasProfiler = struct {
    allocator: Allocator,
    opcodes: [256]OpcodeStats = @splat(.{}),
    frames: std.ArrayList(FrameGasProfile) = .{},
    open: std.ArrayList(usize) = .{},
    err: ?anyerror = null,

    pub fn init(allocator: Allocator) GasProfiler {
        return .{ .allocator = allocator };
    }

    pub fn deinit(self: *GasProfiler) void {
        self.frames.deinit(self.allocator);
        self.open.deinit(self.allocator);
        self.* = undefined;
    }

    pub fn inspector(self: *GasProfiler) Inspector {
        return .{ .ptr = self, .vtable = &vtable, .opcode_mask = OpcodeMask.ALL, .capture_memory = false };
    }

    const vtable: Inspector.VTable = .{
        .onEnter = hook(GasProfiler, insp.FrameEnterEvent, enter),
        .onExit = hook(GasProfiler, insp.FrameExitEvent, exit),
        .onOpcodeEnd = hook(GasProfiler, insp.OpcodeEndEvent, opcodeEnd),
        .onFault = hook(GasProfiler, insp.OpcodeEndEvent, fault),
    };

    fn enter(self: *GasProfiler, event: insp.FrameEnterEvent) !void {
        try self.open.ensureUnusedCapacity(self.allocator, 1);
        try self.frames.append(self.allocator, .{
            .frame_id = event.frame_id,
            .parent_id = event.parent_id,
            .depth = event.depth,
            .call_type = event.call_type,
            .to = event.to,
            .gas_supplied = event.gas,
        });
        self.open.appendAssumeCapacity(self.frames.items.len - 1);
    }

    fn exit(self: *GasProfiler, event: insp.FrameExitEvent) !void {
        const index = self.open.pop() orelse return error.UnbalancedFrameExit;
        const frame = &self.frames.items[index];
        frame.inclusive_gas = event.gas_used;
        frame.exclusive_gas = event.gas_used -| frame.children_gas;
        frame.reverted = event.reverted;
        if (self.open.getLastOrNull()) |parent| self.frames.items[parent].children_gas += event.gas_used;
    }

    fn opcodeEnd(self: *GasProfiler, event: insp.OpcodeEndEvent) !void {
        const stats = &self.opcodes[event.op];
        stats.count += 1;
        stats.total_gas +|= event.gas_cost;
        stats.memory_expansion_gas +|= event.memory_expansion_gas;
        if (self.open.getLastOrNull()) |index| {
            const frame = &self.frames.items[index];
            if (frame.frame_id == event.frame_id) frame.opcode_count += 1;
        }
    }

    fn fault(self: *GasProfiler, event: insp.OpcodeEndEvent) !void {
        self.opcodes[event.op].fault_count += 1;
    }

    fn rankLessThan(_: void, a: OpcodeRank, b: OpcodeRank) bool {
        if (a.stats.total_gas != b.stats.total_gas) return a.stats.total_gas > b.stats.total_gas;
        if (a.stats.count != b.stats.count) return a.stats.count > b.stats.count;
        return a.op < b.op;
    }

    /// Executed opcodes ordered by total gas, then count, then opcode byte.
    pub fn topOpcodes(self: *const GasProfiler, allocator: Allocator, limit: usize) ![]OpcodeRank {
        if (self.err) |e| return e;
        var ranks: std.ArrayList(OpcodeRank) = .{};
        defer ranks.deinit(allocator);
        for (self.opcodes, 0..) |stats, i| {
            if (stats.count == 0) continue;
            const op: u8 = @intCast(i);
            try ranks.append(allocator, .{ .op = op, .name = opcode_mod.getOpName(op), .stats = stats });
        }
        std.mem.sortUnstable(OpcodeRank, ranks.items, {}, rankLessThan);
        ranks.shrinkRetainingCapacity(@min(limit, ranks.items.len));
        return ranks.toOwnedSlice(allocator);
    }

    pub fn writeJson(self: *const GasProfiler, writer: *std.Io.Writer) !void {
        if (self.err) |e| return e;
        var json: Stringify = .{ .writer = writer };
        try json.beginObject();
        try json.objectField("opcodes");
        try json.beginArray();
        for (self.opcodes, 0..) |stats, i| {
            if (stats.count == 0) continue;
            const op: u8 = @intCast(i);
            try json.beginObject();
            try writeQuantityField(&json, "op", op);
            try json.objectField("name");
            try json.write(opcode_mod.getOpName(op));
            try json.objectField("count");
            try json.write(stats.count);
            try json.objectField("gas");
            try json.write(stats.total_gas);
            try json.objectField("memoryExpansionGas");
            try json.write(stats.memory_expansion_gas);
            try json.objectField("faults");
            try json.write(stats.fault_count);
            try json.endObject();
        }
        try json.endArray();
        try json.objectField("frames");
        try json.beginArray();
        for (self.frames.items) |frame| {
            try json.beginObject();
            try json.objectField("frameId");
            try json.write(frame.frame_id);
            try json.objectField("parentId");
            try json.write(frame.parent_id);
            try json.objectField("depth");
            try json.write(frame.depth);
            try json.objectField("type");
            try json.write(callTypeUpper(frame.call_type));
            try writeAddressField(&json, "to", frame.to);
            try json.objectField("gasSupplied");
            try json.write(frame.gas_supplied);
            try json.objectField("inclusiveGas");
            try json.write(frame.inclusive_gas);
            try json.objectField("exclusiveGas");
            try json.write(frame.exclusive_gas);
            try json.objectField("opcodeCount");
            try json.write(frame.opcode_count);
            try json.objectField("reverted");
            try json.write(frame.reverted);
            try json.endObject();
        }
        try json.endArray();
        try json.endObject();
    }
};

// ---------------------------------------------------------------------------
// CoverageInspector
// ---------------------------------------------------------------------------

pub const JumpiBranch = struct { taken: u64 = 0, not_taken: u64 = 0 };

/// PC, edge, and JUMPI branch coverage keyed by keccak256(code).
/// Edges only connect consecutive opcodes in the same frame.
pub const CoverageInspector = struct {
    const op_jumpi: u8 = 0x57;

    pub const PcKey = struct { code_hash: [32]u8, pc: u64 };
    pub const EdgeKey = struct { code_hash: [32]u8, from_pc: u64, to_pc: u64 };

    const FrameState = struct {
        frame_id: u64,
        code_hash: [32]u8,
        last_pc: ?u64 = null,
        last_op: ?u8 = null,
        /// Condition of the JUMPI in flight, read from the stack before it
        /// executes; recorded once the opcode completes without a fault.
        pending_jumpi: ?struct { pc: u64, taken: bool } = null,
    };

    allocator: Allocator,
    frames: std.ArrayList(FrameState) = .{},
    code_hashes: std.AutoArrayHashMapUnmanaged([32]u8, void) = .{},
    pc_hits: std.AutoHashMapUnmanaged(PcKey, u64) = .{},
    edges: std.AutoHashMapUnmanaged(EdgeKey, u64) = .{},
    jumpis: std.AutoHashMapUnmanaged(PcKey, JumpiBranch) = .{},
    err: ?anyerror = null,

    pub fn init(allocator: Allocator) CoverageInspector {
        return .{ .allocator = allocator };
    }

    pub fn deinit(self: *CoverageInspector) void {
        self.frames.deinit(self.allocator);
        self.code_hashes.deinit(self.allocator);
        self.pc_hits.deinit(self.allocator);
        self.edges.deinit(self.allocator);
        self.jumpis.deinit(self.allocator);
        self.* = undefined;
    }

    pub fn inspector(self: *CoverageInspector) Inspector {
        return .{ .ptr = self, .vtable = &vtable, .opcode_mask = OpcodeMask.ALL, .capture_memory = false };
    }

    pub fn codeHash(code: []const u8) [32]u8 {
        var out: [32]u8 = undefined;
        std.crypto.hash.sha3.Keccak256.hash(code, &out, .{});
        return out;
    }

    const vtable: Inspector.VTable = .{
        .onEnter = hook(CoverageInspector, insp.FrameEnterEvent, enter),
        .onExit = hook(CoverageInspector, insp.FrameExitEvent, exit),
        .onOpcode = hook(CoverageInspector, insp.OpcodeEvent, opcode),
        .onOpcodeEnd = hook(CoverageInspector, insp.OpcodeEndEvent, opcodeEnd),
    };

    fn enter(self: *CoverageInspector, event: insp.FrameEnterEvent) !void {
        const hash = codeHash(event.code);
        if (event.code.len > 0) try self.code_hashes.put(self.allocator, hash, {});
        try self.frames.append(self.allocator, .{ .frame_id = event.frame_id, .code_hash = hash });
    }

    fn exit(self: *CoverageInspector, _: insp.FrameExitEvent) !void {
        _ = self.frames.pop() orelse return error.UnbalancedFrameExit;
    }

    fn current(self: *CoverageInspector, frame_id: u64) ?*FrameState {
        var i = self.frames.items.len;
        while (i > 0) {
            i -= 1;
            if (self.frames.items[i].frame_id == frame_id) return &self.frames.items[i];
        }
        return null;
    }

    fn recordBranch(self: *CoverageInspector, code_hash: [32]u8, pc: u64, taken: bool) !void {
        const entry = try self.jumpis.getOrPut(self.allocator, .{ .code_hash = code_hash, .pc = pc });
        if (!entry.found_existing) entry.value_ptr.* = .{};
        if (taken) entry.value_ptr.taken += 1 else entry.value_ptr.not_taken += 1;
    }

    fn opcode(self: *CoverageInspector, event: insp.OpcodeEvent) !void {
        const frame = self.current(event.frame_id) orelse return error.UnknownFrame;
        const hash = frame.code_hash;
        if (frame.last_pc) |from| {
            const edge_key: EdgeKey = .{ .code_hash = hash, .from_pc = from, .to_pc = event.pc };
            const edge = try self.edges.getOrPut(self.allocator, edge_key);
            if (!edge.found_existing) edge.value_ptr.* = 0;
            edge.value_ptr.* += 1;
        }
        const hit = try self.pc_hits.getOrPut(self.allocator, .{ .code_hash = hash, .pc = event.pc });
        if (!hit.found_existing) hit.value_ptr.* = 0;
        hit.value_ptr.* += 1;
        frame.last_pc = event.pc;
        frame.last_op = event.op;
        // The PC after a JUMPI cannot tell a taken jump to `pc + 1` from a
        // fallthrough, so read the condition (second from the top) instead.
        frame.pending_jumpi = if (event.op == op_jumpi and event.stack.len >= 2)
            .{ .pc = event.pc, .taken = event.stack[event.stack.len - 2] != 0 }
        else
            null;
    }

    fn opcodeEnd(self: *CoverageInspector, event: insp.OpcodeEndEvent) !void {
        if (event.op != op_jumpi) return;
        const frame = self.current(event.frame_id) orelse return;
        const pending = frame.pending_jumpi orelse return;
        frame.pending_jumpi = null;
        // A faulting JUMPI neither jumps nor falls through.
        if (event.error_name != null or pending.pc != event.pc) return;
        try self.recordBranch(frame.code_hash, pending.pc, pending.taken);
    }

    pub fn pcHits(self: *const CoverageInspector, code_hash: [32]u8, pc: u64) u64 {
        return self.pc_hits.get(.{ .code_hash = code_hash, .pc = pc }) orelse 0;
    }

    pub fn edgeHits(self: *const CoverageInspector, code_hash: [32]u8, from_pc: u64, to_pc: u64) u64 {
        return self.edges.get(.{ .code_hash = code_hash, .from_pc = from_pc, .to_pc = to_pc }) orelse 0;
    }

    pub fn jumpiStats(self: *const CoverageInspector, code_hash: [32]u8, pc: u64) ?JumpiBranch {
        return self.jumpis.get(.{ .code_hash = code_hash, .pc = pc });
    }

    fn hashLessThan(_: void, a: [32]u8, b: [32]u8) bool {
        return std.mem.order(u8, &a, &b) == .lt;
    }
    fn u64LessThan(_: void, a: u64, b: u64) bool {
        return a < b;
    }
    fn edgeLessThan(_: void, a: EdgeKey, b: EdgeKey) bool {
        if (a.from_pc != b.from_pc) return a.from_pc < b.from_pc;
        return a.to_pc < b.to_pc;
    }

    fn writeCodeCoverage(
        self: *const CoverageInspector,
        json: *Stringify,
        hash: [32]u8,
        pcs: []const u64,
        edges: []const EdgeKey,
        jumpi_pcs: []const u64,
    ) !void {
        var hash_key: [66]u8 = undefined;
        try json.objectField(formatHexLower(&hash_key, &hash));
        try json.beginObject();
        try json.objectField("pcs");
        try json.beginObject();
        for (pcs) |pc| {
            var buf: [24]u8 = undefined;
            try json.objectField(try std.fmt.bufPrint(&buf, "{d}", .{pc}));
            try json.write(self.pcHits(hash, pc));
        }
        try json.endObject();
        try json.objectField("edges");
        try json.beginArray();
        for (edges) |edge| {
            try json.beginObject();
            try json.objectField("from");
            try json.write(edge.from_pc);
            try json.objectField("to");
            try json.write(edge.to_pc);
            try json.objectField("count");
            try json.write(self.edges.get(edge).?);
            try json.endObject();
        }
        try json.endArray();
        try json.objectField("jumpis");
        try json.beginObject();
        for (jumpi_pcs) |pc| {
            const branch = self.jumpiStats(hash, pc).?;
            var buf: [24]u8 = undefined;
            try json.objectField(try std.fmt.bufPrint(&buf, "{d}", .{pc}));
            try json.beginObject();
            try json.objectField("taken");
            try json.write(branch.taken);
            try json.objectField("notTaken");
            try json.write(branch.not_taken);
            try json.endObject();
        }
        try json.endObject();
        try json.endObject();
    }

    /// `{codeHash: {"pcs": {pc: hits}, "edges": [{from,to,count}], "jumpis": {pc: {taken, notTaken}}}}`.
    pub fn writeJson(self: *const CoverageInspector, writer: *std.Io.Writer) !void {
        if (self.err) |e| return e;
        const hashes = try self.allocator.dupe([32]u8, self.code_hashes.keys());
        defer self.allocator.free(hashes);
        std.mem.sortUnstable([32]u8, hashes, {}, hashLessThan);

        var pcs: std.ArrayList(u64) = .{};
        defer pcs.deinit(self.allocator);
        var jumpi_pcs: std.ArrayList(u64) = .{};
        defer jumpi_pcs.deinit(self.allocator);
        var edges: std.ArrayList(EdgeKey) = .{};
        defer edges.deinit(self.allocator);

        var json: Stringify = .{ .writer = writer };
        try json.beginObject();
        for (hashes) |hash| {
            pcs.clearRetainingCapacity();
            jumpi_pcs.clearRetainingCapacity();
            edges.clearRetainingCapacity();
            var pc_it = self.pc_hits.keyIterator();
            while (pc_it.next()) |key| {
                if (std.mem.eql(u8, &key.code_hash, &hash)) try pcs.append(self.allocator, key.pc);
            }
            var jumpi_it = self.jumpis.keyIterator();
            while (jumpi_it.next()) |key| {
                if (std.mem.eql(u8, &key.code_hash, &hash)) try jumpi_pcs.append(self.allocator, key.pc);
            }
            var edge_it = self.edges.keyIterator();
            while (edge_it.next()) |key| {
                if (std.mem.eql(u8, &key.code_hash, &hash)) try edges.append(self.allocator, key.*);
            }
            std.mem.sortUnstable(u64, pcs.items, {}, u64LessThan);
            std.mem.sortUnstable(u64, jumpi_pcs.items, {}, u64LessThan);
            std.mem.sortUnstable(EdgeKey, edges.items, {}, edgeLessThan);
            try self.writeCodeCoverage(&json, hash, pcs.items, edges.items, jumpi_pcs.items);
        }
        try json.endObject();
    }
};
