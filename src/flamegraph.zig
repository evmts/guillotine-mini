//! Gas flamegraph collector and visualizer built on top of `inspector.zig`.
//!
//! `FlamegraphCollector` implements `Inspector`, tracks the live EVM call
//! stack with optional contract/function labels (`AddressLabeler`), and
//! aggregates exclusive gas per folded call path — both at frame granularity
//! and per-opcode granularity.
//!
//! Exports:
//! - `writeFoldedStacks`: Brendan Gregg `flamegraph.pl` / `inferno` /
//!   `speedscope` collapsed-stack format (`frameA;frameB;SLOAD 2100`).
//! - `writeSvg`: self-contained interactive SVG flamegraph with proportional
//!   bars, hover `<title>` tooltips (full path, gas, `%` of total), category
//!   color-coding, and XML-escaped labels.
const std = @import("std");
const primitives = @import("voltaire");
const insp = @import("inspector.zig");
const opcode_mod = @import("opcode.zig");

const Allocator = std.mem.Allocator;
const Address = primitives.Address;
const CallType = insp.CallType;
const Inspector = insp.Inspector;
const OpcodeMask = insp.OpcodeMask;

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

/// Optional callback for mapping a contract address (and optional 4-byte
/// calldata selector) to a human-readable frame label.
pub const AddressLabeler = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        /// Return a label slice (either static or formatted into `buf`), or
        /// `null` to fall back to the default hex address representation.
        label: *const fn (ctx: *anyopaque, address: Address, selector: ?[4]u8, buf: []u8) ?[]const u8,
    };

    pub fn label(self: AddressLabeler, address: Address, selector: ?[4]u8, buf: []u8) ?[]const u8 {
        return self.vtable.label(self.ptr, address, selector, buf);
    }
};

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

/// Collects call-stack + per-opcode gas samples and exports folded stacks or SVG.
pub const FlamegraphCollector = struct {
    pub const Options = struct {
        labeler: ?AddressLabeler = null,
        /// When true, unlabeled addresses are formatted as `0x1111..2222`;
        /// when false (default), full 40-hex-character addresses are emitted.
        compact_addresses: bool = false,
    };

    const ActiveFrame = struct {
        frame_id: u64,
        path: []u8,
        is_precompile: bool,
        children_gas: u64 = 0,
        opcode_gas: u64 = 0,
        pending_gas_before: ?u64 = null,
        pending_child_gas: u64 = 0,
    };

    const SampleEntry = struct {
        path: []const u8,
        gas: u64,
    };

    allocator: Allocator,
    options: Options,
    active_frames: std.ArrayList(ActiveFrame) = .{},
    /// Frame-only folded stack -> exclusive frame gas.
    frame_samples: std.StringHashMapUnmanaged(u64) = .{},
    /// Frame stack + opcode (or precompile frame) -> gas cost.
    opcode_samples: std.StringHashMapUnmanaged(u64) = .{},
    err: ?anyerror = null,

    pub fn init(allocator: Allocator, options: Options) FlamegraphCollector {
        return .{ .allocator = allocator, .options = options };
    }

    pub fn deinit(self: *FlamegraphCollector) void {
        for (self.active_frames.items) |frame| self.allocator.free(frame.path);
        self.active_frames.deinit(self.allocator);
        freeSampleMap(self.allocator, &self.frame_samples);
        freeSampleMap(self.allocator, &self.opcode_samples);
        self.* = undefined;
    }

    fn freeSampleMap(allocator: Allocator, map: *std.StringHashMapUnmanaged(u64)) void {
        var it = map.keyIterator();
        while (it.next()) |key| allocator.free(key.*);
        map.deinit(allocator);
    }

    pub fn inspector(self: *FlamegraphCollector) Inspector {
        return .{
            .ptr = self,
            .vtable = &vtable,
            .opcode_mask = OpcodeMask.ALL,
            .capture_memory = false,
        };
    }

    const vtable: Inspector.VTable = .{
        .onEnter = hook(FlamegraphCollector, insp.FrameEnterEvent, enter),
        .onExit = hook(FlamegraphCollector, insp.FrameExitEvent, exit),
        .onOpcode = hook(FlamegraphCollector, insp.OpcodeEvent, opcode),
        .onOpcodeEnd = hook(FlamegraphCollector, insp.OpcodeEndEvent, opcodeEnd),
    };

    fn addSample(self: *FlamegraphCollector, map: *std.StringHashMapUnmanaged(u64), key: []const u8, gas: u64) !void {
        if (gas == 0) return;
        if (map.getPtr(key)) |existing| {
            existing.* +|= gas;
            return;
        }
        const owned_key = try self.allocator.dupe(u8, key);
        errdefer self.allocator.free(owned_key);
        try map.put(self.allocator, owned_key, gas);
    }

    fn writeU64(writer: *std.Io.Writer, value: u64) !void {
        var buf: [20]u8 = undefined;
        var v = value;
        var i: usize = buf.len;
        if (v == 0) {
            try writer.writeByte('0');
            return;
        }
        while (v != 0) : (v /= 10) {
            i -= 1;
            buf[i] = @as(u8, @intCast(v % 10)) + '0';
        }
        try writer.writeAll(buf[i..]);
    }

    fn appendHexBytes(allocator: Allocator, out: *std.ArrayList(u8), bytes: []const u8) !void {
        const hex = "0123456789abcdef";
        try out.ensureUnusedCapacity(allocator, bytes.len * 2);
        for (bytes) |b| {
            out.appendAssumeCapacity(hex[b >> 4]);
            out.appendAssumeCapacity(hex[b & 0x0f]);
        }
    }

    fn formatFrameLabel(self: *const FlamegraphCollector, event: insp.FrameEnterEvent, out: *std.ArrayList(u8)) !void {
        const prefix = if (event.is_precompile) "PRECOMPILE" else callTypeUpper(event.call_type);
        try out.appendSlice(self.allocator, prefix);
        try out.append(self.allocator, ':');

        const selector: ?[4]u8 = if (!isCreate(event.call_type) and event.input.len >= 4)
            event.input[0..4].*
        else
            null;

        var label_buf: [256]u8 = undefined;
        const custom_label: ?[]const u8 = if (self.options.labeler) |labeler|
            labeler.label(event.to, selector, &label_buf)
        else
            null;

        if (custom_label) |lbl| {
            // Sanitize characters that would break folded-stack syntax (`path gas\n`).
            for (lbl) |ch| {
                const safe: u8 = switch (ch) {
                    ';' => ':',
                    '\n', '\r', '\t', ' ' => '_',
                    else => ch,
                };
                try out.append(self.allocator, safe);
            }
            return;
        }

        try out.appendSlice(self.allocator, "0x");
        if (self.options.compact_addresses) {
            try appendHexBytes(self.allocator, out, event.to.bytes[0..2]);
            try out.appendSlice(self.allocator, "..");
            try appendHexBytes(self.allocator, out, event.to.bytes[18..20]);
        } else {
            try appendHexBytes(self.allocator, out, &event.to.bytes);
        }
    }

    fn enter(self: *FlamegraphCollector, event: insp.FrameEnterEvent) !void {
        var path_buf: std.ArrayList(u8) = .{};
        errdefer path_buf.deinit(self.allocator);

        if (self.active_frames.getLastOrNull()) |parent| {
            try path_buf.appendSlice(self.allocator, parent.path);
            try path_buf.append(self.allocator, ';');
        }
        try self.formatFrameLabel(event, &path_buf);

        const owned_path = try path_buf.toOwnedSlice(self.allocator);
        errdefer self.allocator.free(owned_path);

        try self.active_frames.append(self.allocator, .{
            .frame_id = event.frame_id,
            .path = owned_path,
            .is_precompile = event.is_precompile,
        });
    }

    fn exit(self: *FlamegraphCollector, event: insp.FrameExitEvent) !void {
        const frame = self.active_frames.pop() orelse return error.UnbalancedFrameExit;
        defer self.allocator.free(frame.path);

        const exclusive_gas = event.gas_used -| frame.children_gas;
        if (self.active_frames.items.len > 0) {
            const parent = &self.active_frames.items[self.active_frames.items.len - 1];
            parent.children_gas +|= event.gas_used;
            if (parent.pending_gas_before != null) {
                parent.pending_child_gas +|= event.gas_used;
            }
        }

        try self.addSample(&self.frame_samples, frame.path, exclusive_gas);
        if (frame.is_precompile) {
            try self.addSample(&self.opcode_samples, frame.path, event.gas_used);
        } else if (frame.opcode_gas == 0 and exclusive_gas > 0) {
            try self.addSample(&self.opcode_samples, frame.path, exclusive_gas);
        }
    }

    fn findActiveFrame(self: *FlamegraphCollector, frame_id: u64) ?*ActiveFrame {
        var i = self.active_frames.items.len;
        while (i > 0) {
            i -= 1;
            if (self.active_frames.items[i].frame_id == frame_id) return &self.active_frames.items[i];
        }
        return null;
    }

    fn opcode(self: *FlamegraphCollector, event: insp.OpcodeEvent) !void {
        if (self.findActiveFrame(event.frame_id)) |frame| {
            frame.pending_gas_before = event.gas;
            frame.pending_child_gas = 0;
        }
    }

    fn opcodeEnd(self: *FlamegraphCollector, event: insp.OpcodeEndEvent) !void {
        const op_name = opcode_mod.getOpName(event.op);
        if (self.findActiveFrame(event.frame_id)) |frame| {
            const exclusive_cost: u64 = if (frame.pending_gas_before) |gas_before|
                gas_before -| (event.gas_after +| frame.pending_child_gas)
            else
                event.gas_cost;
            frame.pending_gas_before = null;
            frame.pending_child_gas = 0;
            if (exclusive_cost == 0) return;
            frame.opcode_gas +|= exclusive_cost;
            const full_len = frame.path.len + 1 + op_name.len;
            const key = try self.allocator.alloc(u8, full_len);
            defer self.allocator.free(key);
            @memcpy(key[0..frame.path.len], frame.path);
            key[frame.path.len] = ';';
            @memcpy(key[frame.path.len + 1 ..], op_name);
            try self.addSample(&self.opcode_samples, key, exclusive_cost);
        } else {
            if (event.gas_cost == 0) return;
            try self.addSample(&self.opcode_samples, op_name, event.gas_cost);
        }
    }

    /// Total aggregated gas across all recorded samples.
    pub fn totalGas(self: *const FlamegraphCollector, include_opcodes: bool) u64 {
        const map = if (include_opcodes) &self.opcode_samples else &self.frame_samples;
        var sum: u64 = 0;
        var it = map.valueIterator();
        while (it.next()) |gas| sum +|= gas.*;
        return sum;
    }

    /// Number of distinct folded stack paths collected.
    pub fn sampleCount(self: *const FlamegraphCollector, include_opcodes: bool) usize {
        const map = if (include_opcodes) &self.opcode_samples else &self.frame_samples;
        return map.count();
    }

    fn sampleLessThan(_: void, a: SampleEntry, b: SampleEntry) bool {
        return std.mem.order(u8, a.path, b.path) == .lt;
    }

    fn sortSamplesShell(items: []SampleEntry) void {
        var gap = items.len / 2;
        while (gap > 0) : (gap /= 2) {
            var i = gap;
            while (i < items.len) : (i += 1) {
                const cur = items[i];
                var j = i;
                while (j >= gap and sampleLessThan({}, cur, items[j - gap])) : (j -= gap) {
                    items[j] = items[j - gap];
                }
                items[j] = cur;
            }
        }
    }

    fn sortedSamples(self: *const FlamegraphCollector, allocator: Allocator, include_opcodes: bool) ![]SampleEntry {
        const map = if (include_opcodes) &self.opcode_samples else &self.frame_samples;
        var list: std.ArrayList(SampleEntry) = .{};
        errdefer list.deinit(allocator);
        try list.ensureTotalCapacity(allocator, map.count());
        var it = map.iterator();
        while (it.next()) |entry| {
            if (entry.value_ptr.* == 0) continue;
            list.appendAssumeCapacity(.{ .path = entry.key_ptr.*, .gas = entry.value_ptr.* });
        }
        sortSamplesShell(list.items);
        return list.toOwnedSlice(allocator);
    }

    /// Writes standard Brendan Gregg / `inferno` / `speedscope` collapsed-stack
    /// text format (`path1;path2;... <gas>\n`), deterministically sorted by path.
    pub fn writeFoldedStacks(self: *const FlamegraphCollector, writer: *std.Io.Writer, include_opcodes: bool) !void {
        if (self.err) |e| return e;
        const samples = try self.sortedSamples(self.allocator, include_opcodes);
        defer self.allocator.free(samples);
        for (samples) |entry| {
            try writer.writeAll(entry.path);
            try writer.writeByte(' ');
            try writeU64(writer, entry.gas);
            try writer.writeByte('\n');
        }
    }

    // -----------------------------------------------------------------------
    // SVG Flamegraph Renderer
    // -----------------------------------------------------------------------

    const TreeNode = struct {
        name: []const u8,
        full_path: []const u8,
        total_gas: u64 = 0,
        children: std.ArrayList(*TreeNode) = .{},

        fn getOrCreateChild(self: *TreeNode, allocator: Allocator, name: []const u8, full_path: []const u8) !*TreeNode {
            for (self.children.items) |child| {
                if (std.mem.eql(u8, child.name, name)) return child;
            }
            const node = try allocator.create(TreeNode);
            node.* = .{
                .name = name,
                .full_path = full_path,
            };
            try self.children.append(allocator, node);
            return node;
        }
    };

    fn buildSvgTree(
        alloc: Allocator,
        samples: []const SampleEntry,
        max_depth: *usize,
    ) !*TreeNode {
        const root = try alloc.create(TreeNode);
        root.* = .{ .name = "all", .full_path = "all" };
        for (samples) |entry| {
            root.total_gas +|= entry.gas;
            var cur = root;
            var depth: usize = 0;
            var start: usize = 0;
            while (start <= entry.path.len) {
                const sep = std.mem.indexOfScalarPos(u8, entry.path, start, ';') orelse entry.path.len;
                const seg = entry.path[start..sep];
                const full_prefix = entry.path[0..sep];
                if (seg.len > 0) {
                    depth += 1;
                    cur = try cur.getOrCreateChild(alloc, seg, full_prefix);
                    cur.total_gas +|= entry.gas;
                    if (depth > max_depth.*) max_depth.* = depth;
                }
                if (sep == entry.path.len) break;
                start = sep + 1;
            }
        }
        return root;
    }

    /// Writes a self-contained interactive SVG flamegraph with proportional
    /// frame bars, `<title>` hover tooltips, category coloring, and XML escaping.
    pub fn writeSvg(
        self: *const FlamegraphCollector,
        writer: *std.Io.Writer,
        title: []const u8,
        include_opcodes: bool,
    ) !void {
        if (self.err) |e| return e;

        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();
        const alloc = arena.allocator();

        const samples = try self.sortedSamples(alloc, include_opcodes);

        const svg_width: u64 = 1200;
        const pad_x: f64 = 12.0;
        const header_h: u64 = 52;
        const row_h: u64 = 20;
        const footer_h: u64 = 16;
        const chart_w: f64 = @as(f64, @floatFromInt(svg_width)) - (2.0 * pad_x);

        if (samples.len == 0) {
            const empty_h = header_h + row_h + footer_h;
            try writeSvgHeader(writer, svg_width, empty_h, title, 0);
            try writer.writeAll("<text x=\"");
            try writeU64(writer, svg_width / 2);
            try writer.writeAll(".0\" y=\"");
            try writeU64(writer, header_h + 14);
            try writer.writeAll(".0\" class=\"empty\">No gas samples recorded</text>\n</svg>\n");
            return;
        }

        var max_depth: usize = 0;
        const root = try buildSvgTree(alloc, samples, &max_depth);

        const svg_height = header_h + (@as(u64, @intCast(max_depth + 1)) * row_h) + footer_h;
        try writeSvgHeader(writer, svg_width, svg_height, title, root.total_gas);

        try writeSvgNode(
            writer,
            root,
            0,
            max_depth,
            pad_x,
            chart_w,
            root.total_gas,
            @floatFromInt(header_h),
            @floatFromInt(row_h),
        );
        try writer.writeAll("</svg>\n");
    }

    /// Formats a non-negative float with two decimal places using integer math
    /// so WASM builds avoid pulling in `std.fmt.float` formatting tables.
    fn writeFixed2(writer: *std.Io.Writer, value: f64) !void {
        const scaled: u64 = if (value <= 0.0) 0 else @intFromFloat(@round(value * 100.0));
        try writeU64(writer, scaled / 100);
        try writer.writeByte('.');
        const frac = scaled % 100;
        try writer.writeByte(@as(u8, @intCast(frac / 10)) + '0');
        try writer.writeByte(@as(u8, @intCast(frac % 10)) + '0');
    }

    fn writeSvgHeader(writer: *std.Io.Writer, width: u64, height: u64, title: []const u8, total_gas: u64) !void {
        try writer.writeAll("<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" width=\"");
        try writeU64(writer, width);
        try writer.writeAll("\" height=\"");
        try writeU64(writer, height);
        try writer.writeAll("\" viewBox=\"0 0 ");
        try writeU64(writer, width);
        try writer.writeByte(' ');
        try writeU64(writer, height);
        try writer.writeAll("\">\n");
        try writer.writeAll(
            "<style>\n" ++
                "  text { font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; " ++
                "font-size: 11px; fill: #1a1a1a; pointer-events: none; }\n" ++
                "  text.title { font-size: 16px; font-weight: 700; text-anchor: middle; fill: #111827; }\n" ++
                "  text.subtitle { font-size: 11px; text-anchor: middle; fill: #4b5563; }\n" ++
                "  text.empty { font-size: 12px; text-anchor: middle; fill: #6b7280; }\n" ++
                "  g.frame rect { stroke: #ffffff; stroke-width: 0.6; }\n" ++
                "  g.frame:hover rect { stroke: #111827; stroke-width: 1.2; opacity: 0.9; }\n" ++
                "</style>\n",
        );
        try writer.writeAll("<rect x=\"0\" y=\"0\" width=\"");
        try writeU64(writer, width);
        try writer.writeAll("\" height=\"");
        try writeU64(writer, height);
        try writer.writeAll("\" fill=\"#fafafa\"/>\n<text x=\"");
        try writeU64(writer, width / 2);
        try writer.writeAll(".0\" y=\"22\" class=\"title\">");
        try writeXmlEscaped(writer, title);
        try writer.writeAll("</text>\n<text x=\"");
        try writeU64(writer, width / 2);
        try writer.writeAll(".0\" y=\"40\" class=\"subtitle\">Total gas: ");
        try writeU64(writer, total_gas);
        try writer.writeAll("</text>\n");
    }

    fn writeSvgNode(
        writer: *std.Io.Writer,
        node: *const TreeNode,
        depth: usize,
        max_depth: usize,
        x: f64,
        width: f64,
        total_gas: u64,
        header_h: f64,
        row_h: f64,
    ) !void {
        if (node.total_gas == 0 or total_gas == 0 or width < 0.05) return;

        const y = header_h + (@as(f64, @floatFromInt(max_depth - depth)) * row_h);
        const pct = (@as(f64, @floatFromInt(node.total_gas)) * 100.0) / @as(f64, @floatFromInt(total_gas));
        const fill = colorForLabel(node.name, depth);

        try writer.writeAll("<g class=\"frame\"><title>");
        try writeXmlEscaped(writer, node.full_path);
        try writer.writeAll(" (");
        try writeU64(writer, node.total_gas);
        try writer.writeAll(" gas, ");
        try writeFixed2(writer, pct);
        try writer.writeAll("%)</title><rect x=\"");
        try writeFixed2(writer, x);
        try writer.writeAll("\" y=\"");
        try writeFixed2(writer, y);
        try writer.writeAll("\" width=\"");
        try writeFixed2(writer, width);
        try writer.writeAll("\" height=\"");
        try writeFixed2(writer, row_h - 1.0);
        try writer.writeAll("\" rx=\"2\" fill=\"");
        try writer.writeAll(fill);
        try writer.writeAll("\"/>");

        // Render text label if the bar is wide enough to hold at least ~3 characters.
        const max_chars: usize = if (width > 24.0) @intFromFloat((width - 8.0) / 6.6) else 0;
        if (max_chars >= 3) {
            try writer.writeAll("<text x=\"");
            try writeFixed2(writer, x + 4.0);
            try writer.writeAll("\" y=\"");
            try writeFixed2(writer, y + row_h - 6.0);
            try writer.writeAll("\">");
            if (node.name.len <= max_chars) {
                try writeXmlEscaped(writer, node.name);
            } else {
                const cut = max_chars - 2;
                try writeXmlEscaped(writer, node.name[0..cut]);
                try writer.writeAll("..");
            }
            try writer.writeAll("</text>");
        }
        try writer.writeAll("</g>\n");

        var child_x = x;
        const node_gas_f: f64 = @floatFromInt(node.total_gas);
        for (node.children.items) |child| {
            const child_w = width * (@as(f64, @floatFromInt(child.total_gas)) / node_gas_f);
            try writeSvgNode(writer, child, depth + 1, max_depth, child_x, child_w, total_gas, header_h, row_h);
            child_x += child_w;
        }
    }

    fn colorForLabel(name: []const u8, depth: usize) []const u8 {
        if (depth == 0) return "#d97706";
        if (std.mem.startsWith(u8, name, "CALL:") or std.mem.startsWith(u8, name, "CALLCODE:")) return "#60a5fa";
        if (std.mem.startsWith(u8, name, "STATICCALL:")) return "#38bdf8";
        if (std.mem.startsWith(u8, name, "DELEGATECALL:")) return "#818cf8";
        if (std.mem.startsWith(u8, name, "CREATE:") or std.mem.startsWith(u8, name, "CREATE2:")) return "#a78bfa";
        if (std.mem.startsWith(u8, name, "PRECOMPILE:")) return "#2dd4bf";

        if (std.mem.eql(u8, name, "SLOAD") or std.mem.eql(u8, name, "SSTORE") or
            std.mem.eql(u8, name, "TLOAD") or std.mem.eql(u8, name, "TSTORE"))
        {
            return "#f87171";
        }
        if (std.mem.eql(u8, name, "MLOAD") or std.mem.eql(u8, name, "MSTORE") or
            std.mem.eql(u8, name, "MSTORE8") or std.mem.eql(u8, name, "MCOPY") or
            std.mem.eql(u8, name, "CALLDATACOPY") or std.mem.eql(u8, name, "CODECOPY") or
            std.mem.eql(u8, name, "RETURNDATACOPY") or std.mem.eql(u8, name, "EXTCODECOPY"))
        {
            return "#fb923c";
        }
        if (std.mem.eql(u8, name, "KECCAK256") or std.mem.startsWith(u8, name, "LOG")) {
            return "#c084fc";
        }
        if (std.mem.eql(u8, name, "CALL") or std.mem.eql(u8, name, "STATICCALL") or
            std.mem.eql(u8, name, "DELEGATECALL") or std.mem.eql(u8, name, "CALLCODE") or
            std.mem.eql(u8, name, "CREATE") or std.mem.eql(u8, name, "CREATE2") or
            std.mem.eql(u8, name, "SELFDESTRUCT"))
        {
            return "#34d399";
        }
        if (std.mem.eql(u8, name, "REVERT") or std.mem.eql(u8, name, "INVALID")) {
            return "#ef4444";
        }
        if (std.mem.eql(u8, name, "JUMP") or std.mem.eql(u8, name, "JUMPI") or
            std.mem.eql(u8, name, "JUMPDEST") or std.mem.eql(u8, name, "RETURN") or
            std.mem.eql(u8, name, "STOP"))
        {
            return "#4ade80";
        }
        return "#fbbf24";
    }
};

/// Escapes XML special characters so arbitrary labels/titles produce valid SVG.
pub fn writeXmlEscaped(writer: *std.Io.Writer, text: []const u8) !void {
    for (text) |ch| {
        switch (ch) {
            '&' => try writer.writeAll("&amp;"),
            '<' => try writer.writeAll("&lt;"),
            '>' => try writer.writeAll("&gt;"),
            '"' => try writer.writeAll("&quot;"),
            '\'' => try writer.writeAll("&#39;"),
            else => try writer.writeByte(ch),
        }
    }
}
