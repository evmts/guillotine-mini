const std = @import("std");
const primitives = @import("voltaire");
const TraceConfig = primitives.TraceConfig;

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

        if (self.error_msg) |err| {
            try obj.put("error", .{ .string = try allocator.dupe(u8, err) });
        }

        return .{ .object = obj };
    }
};

/// Tracer that captures EIP-3155 compatible traces
pub const Tracer = struct {
    entries: std.ArrayList(TraceEntry),
    allocator: std.mem.Allocator,
    enabled: bool = false,
    /// Maximum retained steps; execution continues after this limit.
    /// `captureStep` drops every step past it.
    max_entries: usize = std.math.maxInt(usize),
    config: TraceConfig = TraceConfig.from(),

    pub fn init(allocator: std.mem.Allocator) Tracer {
        return .{
            .entries = std.ArrayList(TraceEntry){},
            .allocator = allocator,
            .config = TraceConfig.from(),
        };
    }

    pub fn deinit(self: *Tracer) void {
        // Free allocated memory in entries
        for (self.entries.items) |entry| {
            if (entry.memory) |mem| {
                if (mem.len > 0) {
                    self.allocator.free(mem);
                }
            }
            if (entry.returnData) |data| {
                if (data.len > 0) {
                    self.allocator.free(data);
                }
            }
            if (entry.stack.len > 0) {
                self.allocator.free(entry.stack);
            }
            self.allocator.free(entry.opName);
            if (entry.error_msg) |msg| {
                self.allocator.free(msg);
            }
        }
        self.entries.deinit(self.allocator);
    }

    pub fn enable(self: *Tracer) void {
        self.enabled = true;
    }

    pub fn disable(self: *Tracer) void {
        self.enabled = false;
    }

    /// Record one step. `memSize` is the length of `memory`; a caller that
    /// skips the byte snapshot should use `captureStep` with the logical size.
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
        const mem_size = if (memory) |m| m.len else 0;
        return self.captureStep(pc, op, gas, gas_cost, memory, mem_size, stack, return_data, depth, refund, op_name);
    }

    /// Record one step. `mem_size` is the frame's logical memory size in bytes
    /// and is recorded even when `memory` is null because memory-byte capture
    /// is disabled.
    pub fn captureStep(
        self: *Tracer,
        pc: u64,
        op: u8,
        gas: u64,
        gas_cost: u64,
        memory: ?[]const u8,
        mem_size: usize,
        stack: []const u256,
        return_data: ?[]const u8,
        depth: usize,
        refund: i64,
        op_name: []const u8,
    ) !void {
        if (!self.enabled) return;
        // The retention cap holds for every caller, not only the interpreter,
        // which also checks it to skip preparing a step that would be dropped.
        if (self.entries.items.len >= self.max_entries) return;

        const track_memory = self.config.tracksMemory();
        const track_stack = self.config.tracksStack();
        const track_return = self.config.enable_return_data;

        // Each copy below is owned by the entry only once the append succeeds.
        // Until then an errdefer releases it, so a failed later allocation
        // cannot leak the earlier ones. Empty slices are static, never freed.
        const mem_copy: ?[]const u8 = if (track_memory) blk: {
            if (memory) |m| {
                if (m.len == 0) break :blk &[_]u8{};
                break :blk try self.allocator.dupe(u8, m);
            }
            break :blk null;
        } else null;
        errdefer if (mem_copy) |m| {
            if (m.len > 0) self.allocator.free(m);
        };

        const stack_copy: []const u256 = if (track_stack) blk: {
            if (stack.len == 0) break :blk &[_]u256{};
            break :blk try self.allocator.dupe(u256, stack);
        } else &[_]u256{};
        errdefer if (stack_copy.len > 0) self.allocator.free(stack_copy);

        const return_copy: ?[]const u8 = if (track_return) blk: {
            if (return_data) |r| {
                if (r.len == 0) break :blk &[_]u8{};
                break :blk try self.allocator.dupe(u8, r);
            }
            break :blk null;
        } else null;
        errdefer if (return_copy) |r| {
            if (r.len > 0) self.allocator.free(r);
        };

        const op_name_copy = try self.allocator.dupe(u8, op_name);
        errdefer self.allocator.free(op_name_copy);

        const entry = TraceEntry{
            .pc = pc,
            .op = op,
            .gas = gas,
            .gasCost = gas_cost,
            .memory = mem_copy,
            .memSize = mem_size,
            .stack = stack_copy,
            .returnData = return_copy,
            .depth = depth,
            .refund = refund,
            .opName = op_name_copy,
        };

        try self.entries.append(self.allocator, entry);
    }

    /// Build a JSON array of every entry. The value's strings, arrays and
    /// objects are allocated with `self.allocator` and are not freed
    /// individually; use an arena-backed tracer or copy the value out.
    pub fn toJson(self: *const Tracer) !std.json.Value {
        var arr = std.json.Array.init(self.allocator);

        for (self.entries.items) |*entry| {
            try arr.append(try entry.toJson(self.allocator));
        }

        return .{ .array = arr };
    }

    pub fn writeToFile(self: *const Tracer, path: []const u8) !void {
        const file = try std.fs.cwd().createFile(path, .{});
        defer file.close();

        var json = std.ArrayList(u8){};
        defer json.deinit(self.allocator);

        const writer = json.writer(self.allocator);

        try writer.writeAll("[\n");

        for (self.entries.items, 0..) |entry, i| {
            if (i > 0) try writer.writeAll(",\n");
            try writer.writeAll("  {\n");
            try writer.print("    \"pc\": {d},\n", .{entry.pc});
            try writer.print("    \"op\": {d},\n", .{entry.op});
            try writer.print("    \"gas\": \"0x{x}\",\n", .{entry.gas});
            try writer.print("    \"gasCost\": \"0x{x}\",\n", .{entry.gasCost});

            if (entry.memory) |mem| {
                try writer.writeAll("    \"memory\": \"0x");
                for (mem) |b| {
                    try writer.print("{x:0>2}", .{b});
                }
                try writer.writeAll("\",\n");
            } else {
                try writer.writeAll("    \"memory\": null,\n");
            }

            try writer.print("    \"memSize\": {d},\n", .{entry.memSize});
            try writer.writeAll("    \"stack\": [");
            for (entry.stack, 0..) |val, j| {
                if (j > 0) try writer.writeAll(", ");
                try writer.print("\"0x{x}\"", .{val});
            }
            try writer.writeAll("],\n");

            if (entry.returnData) |data| {
                try writer.writeAll("    \"returnData\": \"0x");
                for (data) |b| {
                    try writer.print("{x:0>2}", .{b});
                }
                try writer.writeAll("\",\n");
            } else {
                try writer.writeAll("    \"returnData\": null,\n");
            }

            try writer.print("    \"depth\": {d},\n", .{entry.depth});
            try writer.print("    \"refund\": {d},\n", .{entry.refund});
            // Callers of `captureStep` choose the name, so it is escaped like any string.
            try writer.writeAll("    \"opName\": ");
            try writeJsonString(writer, entry.opName);
            // Same key as `TraceEntry.toJson` and EIP-3155.
            if (entry.error_msg) |err| {
                try writer.writeAll(",\n    \"error\": ");
                try writeJsonString(writer, err);
            }
            try writer.writeAll("\n");
            try writer.writeAll("  }");
        }

        try writer.writeAll("\n]\n");
        try file.writeAll(json.items);
    }
};

/// Write `text` as a quoted JSON string.
fn writeJsonString(writer: anytype, text: []const u8) !void {
    try writer.writeByte('"');
    for (text) |c| switch (c) {
        '"' => try writer.writeAll("\\\""),
        '\\' => try writer.writeAll("\\\\"),
        0...0x1f => try writer.print("\\u{x:0>4}", .{c}),
        else => try writer.writeByte(c),
    };
    try writer.writeByte('"');
}

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

            if (our.pc != ref.pc) {
                return TraceDiff{
                    .divergence_index = i,
                    .our_entry = our.*,
                    .ref_entry = ref.*,
                    .diff_field = try allocator.dupe(u8, "pc"),
                };
            }

            if (our.op != ref.op) {
                return TraceDiff{
                    .divergence_index = i,
                    .our_entry = our.*,
                    .ref_entry = ref.*,
                    .diff_field = try allocator.dupe(u8, "op"),
                };
            }

            if (our.gas != ref.gas) {
                return TraceDiff{
                    .divergence_index = i,
                    .our_entry = our.*,
                    .ref_entry = ref.*,
                    .diff_field = try allocator.dupe(u8, "gas"),
                };
            }

            // Check stack
            if (our.stack.len != ref.stack.len) {
                return TraceDiff{
                    .divergence_index = i,
                    .our_entry = our.*,
                    .ref_entry = ref.*,
                    .diff_field = try allocator.dupe(u8, "stack_length"),
                };
            }

            for (our.stack, ref.stack) |our_val, ref_val| {
                if (our_val != ref_val) {
                    return TraceDiff{
                        .divergence_index = i,
                        .our_entry = our.*,
                        .ref_entry = ref.*,
                        .diff_field = try allocator.dupe(u8, "stack_value"),
                    };
                }
            }
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

test "Tracer.captureState frees partial copies when any allocation fails" {
    const testing = std.testing;

    const capture = struct {
        fn run(allocator: std.mem.Allocator) !void {
            var tracer = Tracer.init(allocator);
            defer tracer.deinit();
            tracer.enable();
            tracer.config.enable_return_data = true;

            const memory = [_]u8{0xaa} ** 64;
            const stack = [_]u256{ 1, 2, 3 };
            const return_data = [_]u8{0xbb} ** 8;
            // Two steps: the second append must grow the entry list.
            try tracer.captureState(0, 0x60, 100, 3, &memory, &stack, &return_data, 1, 0, "PUSH1");
            try tracer.captureState(2, 0x01, 97, 3, &memory, &stack, &return_data, 1, 0, "ADD");
            try testing.expectEqual(@as(usize, 2), tracer.entries.items.len);
        }
    }.run;

    // Fails every allocation in turn; the testing allocator reports any leak.
    try testing.checkAllAllocationFailures(testing.allocator, capture, .{});
}

test "Tracer.toJson serializes captured steps" {
    const testing = std.testing;
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var tracer = Tracer.init(allocator);
    defer tracer.deinit();
    tracer.enable();
    tracer.config.enable_return_data = true;

    const memory = [_]u8{ 0x00, 0x2a };
    const stack = [_]u256{ 1, 0xff };
    try tracer.captureState(0, 0x60, 100, 3, &memory, &stack, &[_]u8{0xbb}, 1, 0, "PUSH1");
    try tracer.captureState(2, 0xfe, 97, 97, null, &.{}, null, 1, 0, "INVALID");
    tracer.entries.items[1].error_msg = try allocator.dupe(u8, "InvalidOpcode");

    const value = try tracer.toJson();
    const json = try std.json.Stringify.valueAlloc(allocator, value, .{});

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json, .{});
    const steps = parsed.value.array.items;
    try testing.expectEqual(@as(usize, 2), steps.len);
    const first = steps[0].object;
    try testing.expectEqual(@as(i64, 0), first.get("pc").?.integer);
    try testing.expectEqual(@as(i64, 0x60), first.get("op").?.integer);
    try testing.expectEqualStrings("0x64", first.get("gas").?.string);
    try testing.expectEqualStrings("0x3", first.get("gasCost").?.string);
    try testing.expectEqualStrings("0x002a", first.get("memory").?.string);
    try testing.expectEqual(@as(i64, 2), first.get("memSize").?.integer);
    const stack_json = first.get("stack").?.array.items;
    try testing.expectEqual(@as(usize, 2), stack_json.len);
    try testing.expectEqualStrings("0x1", stack_json[0].string);
    try testing.expectEqualStrings("0xff", stack_json[1].string);
    try testing.expectEqualStrings("0xbb", first.get("returnData").?.string);
    try testing.expectEqualStrings("PUSH1", first.get("opName").?.string);
    try testing.expect(first.get("error") == null);

    const second = steps[1].object;
    try testing.expect(second.get("memory").? == .null);
    try testing.expectEqual(@as(usize, 0), second.get("stack").?.array.items.len);
    try testing.expectEqualStrings("InvalidOpcode", second.get("error").?.string);
}

test "Tracer keeps logical memSize without memory bytes and writes the step error" {
    const testing = std.testing;
    var tracer = Tracer.init(testing.allocator);
    defer tracer.deinit();
    tracer.enable();
    tracer.config.disable_memory = true;
    tracer.config.enable_memory = false;
    try testing.expect(!tracer.config.tracksMemory());

    // MSTORE expanded memory to 64 bytes, then INVALID faulted. Byte capture is
    // off, so no snapshot is passed, but the logical size must survive.
    const stack = [_]u256{};
    try tracer.captureStep(0, 0x52, 100, 9, null, 0, &stack, null, 1, 0, "MSTORE");
    try tracer.captureStep(3, 0xfe, 91, 91, null, 64, &stack, null, 1, 0, "INVALID");
    tracer.entries.items[1].error_msg = try testing.allocator.dupe(u8, "InvalidOpcode");
    try testing.expect(tracer.entries.items[1].memory == null);
    try testing.expectEqual(@as(usize, 64), tracer.entries.items[1].memSize);

    // A snapshot that capture drops still reports its length through captureState.
    try tracer.captureState(4, 0x00, 0, 0, &([_]u8{0} ** 32), &stack, null, 1, 0, "STOP");
    try testing.expect(tracer.entries.items[2].memory == null);
    try testing.expectEqual(@as(usize, 32), tracer.entries.items[2].memSize);

    var tmp = testing.tmpDir(.{});
    defer tmp.cleanup();
    const dir_path = try tmp.dir.realpathAlloc(testing.allocator, ".");
    defer testing.allocator.free(dir_path);
    const path = try std.fs.path.join(testing.allocator, &.{ dir_path, "trace.json" });
    defer testing.allocator.free(path);
    try tracer.writeToFile(path);

    const contents = try tmp.dir.readFileAlloc(testing.allocator, "trace.json", 1 << 20);
    defer testing.allocator.free(contents);
    const parsed = try std.json.parseFromSlice(std.json.Value, testing.allocator, contents, .{});
    defer parsed.deinit();
    const steps = parsed.value.array.items;
    try testing.expectEqual(@as(usize, 3), steps.len);
    try testing.expect(steps[0].object.get("error") == null);
    const fault = steps[1].object;
    try testing.expect(fault.get("memory").? == .null);
    try testing.expectEqual(@as(i64, 64), fault.get("memSize").?.integer);
    try testing.expectEqualStrings("InvalidOpcode", fault.get("error").?.string);
    try testing.expectEqual(@as(i64, 32), steps[2].object.get("memSize").?.integer);
}

test "Tracer.writeToFile escapes a quoted opcode name like toJson does" {
    const testing = std.testing;
    // `toJson` leaves its value tree to the tracer's allocator, so use an arena.
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    var tracer = Tracer.init(arena.allocator());
    tracer.enable();

    // R3-047: `captureStep` is public and takes any name.
    const name = "CUSTOM \"quoted\" \\ op\n";
    const stack = [_]u256{};
    try tracer.captureStep(0, 0x0c, 100, 1, null, 0, &stack, null, 1, 0, name);

    var tmp = testing.tmpDir(.{});
    defer tmp.cleanup();
    const dir_path = try tmp.dir.realpathAlloc(testing.allocator, ".");
    defer testing.allocator.free(dir_path);
    const path = try std.fs.path.join(testing.allocator, &.{ dir_path, "trace.json" });
    defer testing.allocator.free(path);
    try tracer.writeToFile(path);

    const contents = try tmp.dir.readFileAlloc(testing.allocator, "trace.json", 1 << 20);
    defer testing.allocator.free(contents);
    const parsed = try std.json.parseFromSlice(std.json.Value, testing.allocator, contents, .{});
    defer parsed.deinit();
    try testing.expectEqual(@as(usize, 1), parsed.value.array.items.len);
    try testing.expectEqualStrings(name, parsed.value.array.items[0].object.get("opName").?.string);

    // The object serializer agrees.
    const value = try tracer.toJson();
    try testing.expectEqualStrings(name, value.array.items[0].object.get("opName").?.string);
}

test "Tracer.captureStep enforces max_entries for direct callers" {
    const testing = std.testing;
    var tracer = Tracer.init(testing.allocator);
    defer tracer.deinit();
    tracer.enable();
    tracer.max_entries = 1;

    // R3-048: no interpreter in front of the tracer to apply the cap.
    const stack = [_]u256{7};
    try tracer.captureStep(0, 0x60, 100, 3, null, 0, &stack, null, 1, 0, "PUSH1");
    try tracer.captureStep(2, 0x01, 97, 3, null, 0, &stack, null, 1, 0, "ADD");
    try tracer.captureState(3, 0x00, 94, 0, null, &stack, null, 1, 0, "STOP");
    try testing.expectEqual(@as(usize, 1), tracer.entries.items.len);
    try testing.expectEqualStrings("PUSH1", tracer.entries.items[0].opName);

    // Raising the cap resumes capture; zero retains nothing.
    tracer.max_entries = 2;
    try tracer.captureStep(3, 0x00, 94, 0, null, 0, &stack, null, 1, 0, "STOP");
    try testing.expectEqual(@as(usize, 2), tracer.entries.items.len);
    tracer.max_entries = 0;
    try tracer.captureStep(4, 0x00, 94, 0, null, 0, &stack, null, 1, 0, "STOP");
    try testing.expectEqual(@as(usize, 2), tracer.entries.items.len);
}
