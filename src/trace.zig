const std = @import("std");
const primitives = @import("voltaire");
const TraceConfig = primitives.TraceConfig;

pub const StorageEntry = struct { slot: u256, value: u256 };

pub const TraceSummary = struct {
    output: []const u8,
    gas_used: u64,
    pass: bool = true,
    error_msg: ?[]const u8 = null,
    state_root: ?[32]u8 = null,
};

/// EIP-3155 compatible trace entry
pub const TraceEntry = struct {
    pc: u64,
    op: u8,
    gas: u64,
    gasCost: u64,
    memory: ?[]const u8,
    memSize: usize,
    stack: []const u256,
    returnData: ?[]const u8,
    depth: usize,
    refund: i64,
    opName: []const u8,
    error_msg: ?[]const u8 = null,
    storage: ?[]const StorageEntry = null,
    op_name_owned: bool = false,
    error_msg_owned: bool = false,

    pub fn deinit(self: TraceEntry, allocator: std.mem.Allocator) void {
        if (self.memory) |memory| allocator.free(memory);
        allocator.free(self.stack);
        if (self.returnData) |data| allocator.free(data);
        if (self.storage) |storage| allocator.free(storage);
        if (self.op_name_owned) allocator.free(self.opName);
        if (self.error_msg_owned) allocator.free(self.error_msg.?);
    }

    pub fn toJson(self: *const TraceEntry, allocator: std.mem.Allocator) !std.json.Value {
        var obj = std.StringArrayHashMap(std.json.Value).init(allocator);

        try obj.put("pc", .{ .integer = @intCast(self.pc) });
        try obj.put("op", .{ .integer = @intCast(self.op) });

        // Format gas as hex string
        var gas_buf: [32]u8 = undefined;
        const gas_str = try std.fmt.bufPrint(&gas_buf, "0x{x}", .{self.gas});
        try obj.put("gas", .{ .string = try allocator.dupe(u8, gas_str) });

        var gas_cost_buf: [32]u8 = undefined;
        const gas_cost_str = try std.fmt.bufPrint(&gas_cost_buf, "0x{x}", .{self.gasCost});
        try obj.put("gasCost", .{ .string = try allocator.dupe(u8, gas_cost_str) });

        // Memory as hex string if present
        if (self.memory) |mem| {
            const hex_mem = try allocator.alloc(u8, mem.len * 2 + 2);
            hex_mem[0] = '0';
            hex_mem[1] = 'x';
            for (mem, 0..) |byte, i| {
                _ = try std.fmt.bufPrint(hex_mem[2 + i * 2 ..][0..2], "{x:0>2}", .{byte});
            }
            try obj.put("memory", .{ .string = hex_mem });
        } else {
            try obj.put("memory", .null);
        }

        try obj.put("memSize", .{ .integer = @intCast(self.memSize) });

        // Stack as array of hex strings
        var stack_arr = std.json.Array.init(allocator);
        for (self.stack) |val| {
            var val_buf: [66]u8 = undefined;
            const val_str = try std.fmt.bufPrint(&val_buf, "0x{x}", .{val});
            try stack_arr.append(.{ .string = try allocator.dupe(u8, val_str) });
        }
        try obj.put("stack", .{ .array = stack_arr });

        // Return data as hex string if present
        if (self.returnData) |data| {
            const hex_data = try allocator.alloc(u8, data.len * 2 + 2);
            hex_data[0] = '0';
            hex_data[1] = 'x';
            for (data, 0..) |byte, i| {
                _ = try std.fmt.bufPrint(hex_data[2 + i * 2 ..][0..2], "{x:0>2}", .{byte});
            }
            try obj.put("returnData", .{ .string = hex_data });
        } else {
            try obj.put("returnData", .null);
        }

        try obj.put("depth", .{ .integer = @intCast(self.depth) });
        try obj.put("refund", .{ .integer = @intCast(self.refund) });
        try obj.put("opName", .{ .string = try allocator.dupe(u8, self.opName) });

        if (self.storage) |slots| {
            var storage = std.json.ObjectMap.init(allocator);
            for (slots) |slot| {
                const key = try std.fmt.allocPrint(allocator, "0x{x}", .{slot.slot});
                const value = try std.fmt.allocPrint(allocator, "0x{x}", .{slot.value});
                try storage.put(key, .{ .string = value });
            }
            try obj.put("storage", .{ .object = storage });
        }

        if (self.error_msg) |err| {
            try obj.put("error", .{ .string = try allocator.dupe(u8, err) });
        }

        return .{ .object = obj };
    }

    fn writeJson(self: TraceEntry, json: *std.json.Stringify, jsonl: bool) !void {
        try json.beginObject();
        try json.objectField("pc");
        try json.write(self.pc);
        try json.objectField("op");
        try json.write(self.op);
        try writeQuantity(json, "gas", self.gas);
        try writeQuantity(json, "gasCost", self.gasCost);
        try json.objectField("memSize");
        try json.write(self.memSize);
        try json.objectField("stack");
        try json.beginArray();
        for (self.stack) |value| {
            var buf: [66]u8 = undefined;
            try json.write(std.fmt.bufPrint(&buf, "0x{x}", .{value}) catch unreachable);
        }
        try json.endArray();
        try json.objectField("depth");
        try json.write(self.depth);
        if (self.returnData) |data| {
            try writeBytes(json, "returnData", data);
        } else if (jsonl) {
            try writeBytes(json, "returnData", &.{});
        } else {
            try json.objectField("returnData");
            try json.write(null);
        }
        try json.objectField("refund");
        try json.write(self.refund);
        try json.objectField("opName");
        try json.write(self.opName);
        if (self.error_msg) |msg| {
            try json.objectField("error");
            try json.write(msg);
        }
        if (self.memory) |memory| {
            try writeBytes(json, "memory", memory);
        } else if (!jsonl) {
            try json.objectField("memory");
            try json.write(null);
        }
        if (self.storage) |slots| {
            try json.objectField("storage");
            try json.beginObject();
            for (slots) |slot| {
                var key: [66]u8 = undefined;
                try writeQuantity(json, std.fmt.bufPrint(&key, "0x{x}", .{slot.slot}) catch unreachable, slot.value);
            }
            try json.endObject();
        }
        try json.endObject();
    }
};

fn writeQuantity(json: *std.json.Stringify, field: []const u8, value: anytype) !void {
    var buf: [66]u8 = undefined;
    try json.objectField(field);
    try json.write(std.fmt.bufPrint(&buf, "0x{x}", .{value}) catch unreachable);
}

fn writeBytes(json: *std.json.Stringify, field: []const u8, bytes: []const u8) !void {
    try json.objectField(field);
    try json.beginWriteRaw();
    try json.writer.print("\"0x{x}\"", .{bytes});
    json.endWriteRaw();
}

/// Tracer that captures EIP-3155 compatible traces
pub const Tracer = struct {
    entries: std.ArrayList(TraceEntry),
    allocator: std.mem.Allocator,
    enabled: bool = false,
    /// Maximum retained steps; execution continues after this limit.
    max_entries: usize = std.math.maxInt(usize),
    config: TraceConfig = TraceConfig.from(),
    truncated: bool = false,
    dropped_entries: usize = 0,
    ring_buffer: bool = false,
    first_retained_step: usize = 0,

    pub fn init(allocator: std.mem.Allocator) Tracer {
        return .{
            .entries = std.ArrayList(TraceEntry){},
            .allocator = allocator,
            .config = TraceConfig.from(),
        };
    }

    pub fn deinit(self: *Tracer) void {
        for (self.entries.items) |entry| entry.deinit(self.allocator);
        self.entries.deinit(self.allocator);
    }

    pub fn enable(self: *Tracer) void {
        self.enabled = true;
    }

    pub fn disable(self: *Tracer) void {
        self.enabled = false;
    }

    pub fn captureState(
        self: *Tracer,
        pc: u64,
        op: u8,
        gas: u64,
        gas_cost: u64,
        memory: ?[]const u8,
        stack: []const u256,
        return_data: ?[]const u8,
        depth: usize,
        refund: i64,
        op_name: []const u8,
    ) !void {
        _ = try self.capture(.{
            .pc = pc,
            .op = op,
            .gas = gas,
            .gasCost = gas_cost,
            .memory = memory,
            .memSize = if (memory) |m| m.len else 0,
            .stack = stack,
            .returnData = return_data,
            .depth = depth,
            .refund = refund,
            .opName = op_name,
        }, true);
    }

    pub fn willCapture(self: *const Tracer) bool {
        return self.enabled and self.max_entries != 0 and
            (self.ring_buffer or self.entries.items.len < self.max_entries);
    }

    /// Capture a pre-op snapshot. With copy_op_name=false the name must be static.
    /// The token lets the caller finish this step even after nested calls evict entries.
    pub fn capture(self: *Tracer, entry: TraceEntry, copy_op_name: bool) !?usize {
        if (!self.enabled) return null;
        if (!self.willCapture()) {
            self.truncated = true;
            self.dropped_entries +|= 1;
            return null;
        }

        var owned = entry;
        owned.memory = null;
        owned.stack = &.{};
        owned.returnData = null;
        owned.storage = null;
        owned.op_name_owned = false;
        owned.error_msg_owned = false;
        errdefer owned.deinit(self.allocator);

        if (self.config.tracksMemory()) {
            if (entry.memory) |memory| owned.memory = try self.allocator.dupe(u8, memory);
        }
        if (self.config.tracksStack()) owned.stack = try self.allocator.dupe(u256, entry.stack);
        if (self.config.enable_return_data) {
            if (entry.returnData) |data| owned.returnData = try self.allocator.dupe(u8, data);
        }
        if (self.config.tracksStorage()) {
            if (entry.storage) |storage| owned.storage = try self.allocator.dupe(StorageEntry, storage);
        }
        if (copy_op_name) {
            owned.opName = try self.allocator.dupe(u8, entry.opName);
            owned.op_name_owned = true;
        }
        if (entry.error_msg) |msg| {
            owned.error_msg = try self.allocator.dupe(u8, msg);
            owned.error_msg_owned = true;
        }

        while (self.entries.items.len >= self.max_entries) {
            self.entries.orderedRemove(0).deinit(self.allocator);
            self.truncated = true;
            self.dropped_entries +|= 1;
            self.first_retained_step += 1;
        }
        const token = self.first_retained_step + self.entries.items.len;
        try self.entries.append(self.allocator, owned);
        return token;
    }

    /// Complete a captured step with a static error name, if any.
    pub fn finishStep(self: *Tracer, token: usize, gas_cost: u64, error_msg: ?[]const u8) void {
        if (token < self.first_retained_step) return;
        const entry = &self.entries.items[token - self.first_retained_step];
        entry.gasCost = gas_cost;
        if (entry.error_msg_owned) self.allocator.free(entry.error_msg.?);
        entry.error_msg_owned = false;
        entry.error_msg = error_msg;
    }

    pub fn toJson(self: *const Tracer) !std.json.Value {
        var arr = std.json.Array.init(self.allocator);

        for (self.entries.items) |*entry| {
            const entry_json = try entry.toJson(self.allocator);
            try arr.append(entry_json);
        }

        return .{ .array = arr };
    }

    pub fn writeToFile(self: *const Tracer, path: []const u8) !void {
        const file = try std.fs.cwd().createFile(path, .{});
        defer file.close();

        var buffer: [4096]u8 = undefined;
        var file_writer = file.writer(&buffer);
        const writer = &file_writer.interface;
        var json: std.json.Stringify = .{ .writer = writer, .options = .{ .whitespace = .indent_2 } };
        try json.beginArray();
        for (self.entries.items) |entry| try entry.writeJson(&json, false);
        try json.endArray();
        try writer.writeByte('\n');
        try writer.flush();
    }

    /// Writes one JSON object per line. Memory uses the EIP example's hex string.
    pub fn writeEip3155Jsonl(self: *const Tracer, writer: *std.Io.Writer, summary: ?TraceSummary) !void {
        for (self.entries.items) |entry| {
            var json: std.json.Stringify = .{ .writer = writer };
            try entry.writeJson(&json, true);
            try writer.writeByte('\n');
        }
        if (summary) |value| {
            var json: std.json.Stringify = .{ .writer = writer };
            try json.beginObject();
            if (value.state_root) |root| try writeBytes(&json, "stateRoot", &root);
            try writeBytes(&json, "output", value.output);
            try writeQuantity(&json, "gasUsed", value.gas_used);
            try json.objectField("pass");
            try json.write(value.pass);
            if (value.error_msg) |msg| {
                try json.objectField("error");
                try json.write(msg);
            }
            try json.endObject();
            try writer.writeByte('\n');
        }
    }
};

/// Compare two traces and find the first divergence
pub const TraceDiff = struct {
    divergence_index: ?usize,
    our_entry: ?TraceEntry,
    ref_entry: ?TraceEntry,
    diff_field: ?[]const u8,

    pub fn compare(allocator: std.mem.Allocator, our_trace: *const Tracer, ref_trace: *const Tracer) !TraceDiff {
        const min_len = @min(our_trace.entries.items.len, ref_trace.entries.items.len);

        for (0..min_len) |i| {
            const our = &our_trace.entries.items[i];
            const ref = &ref_trace.entries.items[i];

            const field =
                if (our.pc != ref.pc) "pc" else if (our.op != ref.op) "op" else if (our.gas != ref.gas) "gas" else if (our.gasCost != ref.gasCost) "gasCost" else if (our.depth != ref.depth) "depth" else if (our.memSize != ref.memSize) "memSize" else if (our.refund != ref.refund) "refund" else if (our.stack.len != ref.stack.len) "stack_length" else if (!std.mem.eql(u256, our.stack, ref.stack)) "stack_value" else if (!optionalBytesEqual(our.returnData, ref.returnData)) "returnData" else if (!optionalBytesEqual(our.error_msg, ref.error_msg)) "error_msg" else continue;

            return .{
                .divergence_index = i,
                .our_entry = our.*,
                .ref_entry = ref.*,
                .diff_field = try allocator.dupe(u8, field),
            };
        }

        // Check if one trace is longer
        if (our_trace.entries.items.len != ref_trace.entries.items.len) {
            return TraceDiff{
                .divergence_index = min_len,
                .our_entry = if (our_trace.entries.items.len > min_len) our_trace.entries.items[min_len] else null,
                .ref_entry = if (ref_trace.entries.items.len > min_len) ref_trace.entries.items[min_len] else null,
                .diff_field = try allocator.dupe(u8, "trace_length"),
            };
        }

        return TraceDiff{
            .divergence_index = null,
            .our_entry = null,
            .ref_entry = null,
            .diff_field = null,
        };
    }

    fn optionalBytesEqual(left: ?[]const u8, right: ?[]const u8) bool {
        if (left) |bytes| return if (right) |other| std.mem.eql(u8, bytes, other) else false;
        return right == null;
    }

    /// The entries borrow the original traces. Only the field name is owned.
    pub fn deinit(self: *TraceDiff, allocator: std.mem.Allocator) void {
        if (self.diff_field) |field| allocator.free(field);
        self.* = .{ .divergence_index = null, .our_entry = null, .ref_entry = null, .diff_field = null };
    }

    pub fn printDiff(self: *const TraceDiff, writer: anytype) !void {
        if (self.divergence_index == null) {
            try writer.print("✓ Traces match perfectly!\n", .{});
            return;
        }

        try writer.print("\n{s}⚠ Trace Divergence at step {d}{s}\n", .{
            "\x1b[33m", // Yellow
            self.divergence_index.?,
            "\x1b[0m", // Reset
        });

        if (self.diff_field) |field| {
            try writer.print("{s}Difference in: {s}{s}\n\n", .{
                "\x1b[1m", // Bold
                field,
                "\x1b[0m", // Reset
            });
        }

        if (self.our_entry) |our| {
            try writer.print("{s}Our EVM:{s}\n", .{ "\x1b[36m", "\x1b[0m" }); // Cyan
            try writer.print("  PC: 0x{x}  Op: 0x{x:0>2} ({s})  Gas: {d}\n", .{
                our.pc,
                our.op,
                our.opName,
                our.gas,
            });
            try writer.print("  Stack depth: {d}\n", .{our.stack.len});
        }

        if (self.ref_entry) |ref| {
            try writer.print("\n{s}Reference:{s}\n", .{ "\x1b[35m", "\x1b[0m" }); // Magenta
            try writer.print("  PC: 0x{x}  Op: 0x{x:0>2} ({s})  Gas: {d}\n", .{
                ref.pc,
                ref.op,
                ref.opName,
                ref.gas,
            });
            try writer.print("  Stack depth: {d}\n", .{ref.stack.len});
        }
    }
};

fn sampleStep(pc: u64) TraceEntry {
    return .{
        .pc = pc,
        .op = 0x52,
        .gas = 4,
        .gasCost = 6,
        .memory = null,
        .memSize = 32,
        .stack = &.{ 42, 0 },
        .returnData = &.{0x05},
        .depth = 1,
        .refund = 0,
        .opName = "MSTORE",
    };
}

test "trace limits retain ordered entries and protect parent step tokens" {
    var tracer = Tracer.init(std.testing.allocator);
    defer tracer.deinit();
    tracer.enable();
    tracer.max_entries = 2;

    const old = (try tracer.capture(sampleStep(0), false)).?;
    _ = try tracer.capture(sampleStep(1), false);
    try std.testing.expect(try tracer.capture(sampleStep(2), false) == null);
    try std.testing.expect(tracer.truncated);
    try std.testing.expectEqual(@as(usize, 1), tracer.dropped_entries);
    try std.testing.expectEqual(@as(u64, 0), tracer.entries.items[0].pc);

    tracer.ring_buffer = true;
    const newest = (try tracer.capture(sampleStep(3), false)).?;
    tracer.finishStep(old, 100, "evicted");
    tracer.finishStep(newest, 5, "out of gas");
    try std.testing.expectEqual(@as(usize, 2), tracer.dropped_entries);
    try std.testing.expectEqual(@as(u64, 1), tracer.entries.items[0].pc);
    try std.testing.expectEqual(@as(u64, 3), tracer.entries.items[1].pc);
    try std.testing.expectEqual(@as(u64, 5), tracer.entries.items[1].gasCost);
    try std.testing.expectEqualStrings("out of gas", tracer.entries.items[1].error_msg.?);
}

test "trace JSONL and array writers include faults, storage and optional summary" {
    const allocator = std.testing.allocator;
    var tracer = Tracer.init(allocator);
    defer tracer.deinit();
    tracer.enable();
    tracer.config.disable_memory = true;
    tracer.config.enable_return_data = true;

    var step = sampleStep(7);
    step.error_msg = "out of gas \"during write\"";
    step.storage = &.{.{ .slot = 42, .value = 2 }};
    _ = try tracer.capture(step, false);
    tracer.config.disable_storage = true;
    _ = try tracer.capture(sampleStep(8), false);

    var output: std.Io.Writer.Allocating = .init(allocator);
    defer output.deinit();
    try tracer.writeEip3155Jsonl(&output.writer, .{
        .output = &.{ 0, 42 },
        .gas_used = 10,
        .pass = false,
        .state_root = @splat(0xaa),
        .error_msg = "out of gas",
    });
    var lines = std.mem.splitScalar(u8, output.written(), '\n');
    const first = try std.json.parseFromSlice(std.json.Value, allocator, lines.next().?, .{});
    defer first.deinit();
    const second = try std.json.parseFromSlice(std.json.Value, allocator, lines.next().?, .{});
    defer second.deinit();
    const summary = try std.json.parseFromSlice(std.json.Value, allocator, lines.next().?, .{});
    defer summary.deinit();
    try std.testing.expectEqualStrings("", lines.next().?);
    try std.testing.expectEqual(@as(i64, 32), first.value.object.get("memSize").?.integer);
    try std.testing.expect(!first.value.object.contains("memory"));
    try std.testing.expectEqualStrings(step.error_msg.?, first.value.object.get("error").?.string);
    try std.testing.expectEqualStrings("0x05", first.value.object.get("returnData").?.string);
    try std.testing.expectEqualStrings("0x2", first.value.object.get("storage").?.object.get("0x2a").?.string);
    try std.testing.expect(!second.value.object.contains("storage"));
    try std.testing.expectEqualStrings("0x002a", summary.value.object.get("output").?.string);
    try std.testing.expectEqualStrings("0xa", summary.value.object.get("gasUsed").?.string);
    try std.testing.expectEqual(@as(usize, 66), summary.value.object.get("stateRoot").?.string.len);
    try std.testing.expect(!summary.value.object.get("pass").?.bool);

    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const value = try tracer.entries.items[0].toJson(arena.allocator());
    try std.testing.expectEqualStrings("0x2", value.object.get("storage").?.object.get("0x2a").?.string);

    var cwd = std.testing.tmpDir(.{});
    defer cwd.cleanup();
    const root = try cwd.dir.realpathAlloc(allocator, ".");
    defer allocator.free(root);
    const filename = try std.fs.path.join(allocator, &.{ root, "trace.json" });
    defer allocator.free(filename);
    try tracer.writeToFile(filename);
    const bytes = try cwd.dir.readFileAlloc(allocator, "trace.json", 4096);
    defer allocator.free(bytes);
    const array = try std.json.parseFromSlice(std.json.Value, allocator, bytes, .{});
    defer array.deinit();
    try std.testing.expectEqualStrings(step.error_msg.?, array.value.array.items[0].object.get("error").?.string);
}

test "TraceDiff diagnoses all required step fields" {
    const allocator = std.testing.allocator;
    var left = Tracer.init(allocator);
    defer left.deinit();
    var right = Tracer.init(allocator);
    defer right.deinit();
    left.enable();
    right.enable();
    left.config.enable_return_data = true;
    right.config.enable_return_data = true;
    _ = try left.capture(sampleStep(0), false);

    inline for (.{
        .{ "pc", 1, "pc" },
        .{ "op", 0, "op" },
        .{ "gas", 0, "gas" },
        .{ "gasCost", 0, "gasCost" },
        .{ "depth", 2, "depth" },
        .{ "memSize", 0, "memSize" },
        .{ "refund", 1, "refund" },
        .{ "stack", &[_]u256{ 42, 1 }, "stack_value" },
        .{ "returnData", &[_]u8{6}, "returnData" },
        .{ "error_msg", "out of gas", "error_msg" },
    }) |case| {
        var step = sampleStep(0);
        @field(step, case[0]) = case[1];
        _ = try right.capture(step, false);
        defer right.entries.pop().?.deinit(allocator);
        var diff = try TraceDiff.compare(allocator, &left, &right);
        defer diff.deinit(allocator);
        try std.testing.expectEqual(@as(?usize, 0), diff.divergence_index);
        try std.testing.expectEqualStrings(case[2], diff.diff_field.?);
    }
}
