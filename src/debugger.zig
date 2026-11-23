//! Interactive step-and-rewind EVM debugger built on top of `inspector.zig`.
//!
//! `ExecutionRecorder` implements `Inspector` and captures an immutable
//! timeline of every executed opcode (`DebugStep`), storage access
//! (`StorageEventRecord`), and call frame (`CallFrameRecord`).
//!
//! `DebugSession` operates as a zero-cost time-travel cursor over a recorded
//! timeline, supporting forward stepping (`stepInto`, `stepOver`, `stepOut`),
//! backward rewind (`stepBack`), arbitrary seeks (`jumpToStep`), rich
//! breakpoints (`pc`, `opcode`, `call_target`, `storage_slot`, `on_revert`,
//! `on_fault`, `depth_at_most`), optional source-map resolution, and
//! human-readable state dumps.
const std = @import("std");
const primitives = @import("voltaire");
const insp = @import("inspector.zig");

const Allocator = std.mem.Allocator;
const Address = primitives.Address;
const CallType = insp.CallType;
const Inspector = insp.Inspector;
const OpcodeMask = insp.OpcodeMask;

/// Adapts a fallible `method(self, event)` to an infallible vtable callback.
/// The first error is preserved in `self.err` and subsequent events are ignored.
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

/// Source-map entry for Solidity/Vyper/Fe source-level debugging.
pub const SourceLocation = struct {
    pub const Jump = enum { in, out, regular };

    file_id: u32,
    offset: u32,
    length: u32,
    jump: Jump = .regular,
};

/// Optional vtable for resolving `(code_address, pc)` to a `SourceLocation`.
pub const SourceMapResolver = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        resolve: *const fn (ctx: *anyopaque, code_address: Address, pc: u64) ?SourceLocation,
    };

    pub fn resolve(self: SourceMapResolver, code_address: Address, pc: u64) ?SourceLocation {
        return self.vtable.resolve(self.ptr, code_address, pc);
    }
};

/// Condition that halts `DebugSession.continueUntilBreakpoint`.
pub const Breakpoint = union(enum) {
    pc: struct { address: ?Address = null, pc: u64 },
    opcode: u8,
    call_target: Address,
    storage_slot: struct { address: ?Address = null, slot: u256 },
    on_revert: void,
    on_fault: void,
    depth_at_most: usize,
};

/// Immutable snapshot recorded for a single executed EVM opcode.
pub const DebugStep = struct {
    step_index: usize,
    frame_id: u64,
    depth: usize,
    pc: u64,
    op: u8,
    op_name: []const u8,
    gas: u64,
    gas_cost: u64 = 0,
    memory_size: usize,
    memory: ?[]const u8 = null,
    stack: []const u256,
    return_data: []const u8,
    refund: i64,
    address: Address,
    code_address: Address,
    error_name: ?[]const u8 = null,
    source_loc: ?SourceLocation = null,

    fn deinit(self: *DebugStep, allocator: Allocator) void {
        if (self.memory) |mem| allocator.free(mem);
        allocator.free(self.stack);
        allocator.free(self.return_data);
        if (self.error_name) |name| allocator.free(name);
    }
};

/// Storage read/write recorded during execution, linked to its triggering step.
pub const StorageEventRecord = struct {
    step_index: ?usize,
    frame_id: u64,
    address: Address,
    slot: u256,
    prev_value: u256,
    new_value: u256,
    is_read: bool,
};

/// Call-frame lifecycle metadata recorded during execution.
pub const CallFrameRecord = struct {
    frame_id: u64,
    parent_id: ?u64,
    depth: usize,
    call_type: CallType,
    from: Address,
    to: Address,
    code_address: Address,
    value: u256,
    gas: u64,
    gas_used: u64 = 0,
    gas_left: u64 = 0,
    input: []const u8 = &.{},
    output: []const u8 = &.{},
    reverted: bool = false,
    error_name: ?[]const u8 = null,
    created_address: ?Address = null,
    is_precompile: bool = false,
    /// Step index of the CALL/CREATE instruction in the parent frame (if any).
    caller_step_index: ?usize = null,
    /// Step index of the first opcode executed in this frame (when `has_steps` is true).
    enter_step_index: usize = 0,
    /// Step index of the last opcode executed before this frame exited.
    exit_step_index: ?usize = null,
    has_steps: bool = false,

    fn deinit(self: *CallFrameRecord, allocator: Allocator) void {
        allocator.free(self.input);
        allocator.free(self.output);
        if (self.error_name) |name| allocator.free(name);
    }
};

/// Records a complete EVM execution timeline via `Inspector` hooks.
pub const ExecutionRecorder = struct {
    pub const Options = struct {
        max_steps: ?usize = null,
        capture_memory: bool = true,
        source_map: ?SourceMapResolver = null,
    };

    const OpenFrame = struct {
        frame_id: u64,
        record_index: usize,
        pending_step: ?usize = null,
        last_step: ?usize = null,
    };

    allocator: Allocator,
    options: Options,
    steps: std.ArrayList(DebugStep) = .{},
    storage_events: std.ArrayList(StorageEventRecord) = .{},
    call_frames: std.ArrayList(CallFrameRecord) = .{},
    open_frames: std.ArrayList(OpenFrame) = .{},
    orphan_pending_step: ?usize = null,
    orphan_last_step: ?usize = null,
    truncated: bool = false,
    err: ?anyerror = null,

    pub fn init(allocator: Allocator, options: Options) ExecutionRecorder {
        return .{ .allocator = allocator, .options = options };
    }

    pub fn deinit(self: *ExecutionRecorder) void {
        for (self.steps.items) |*step| step.deinit(self.allocator);
        self.steps.deinit(self.allocator);
        self.storage_events.deinit(self.allocator);
        for (self.call_frames.items) |*frame| frame.deinit(self.allocator);
        self.call_frames.deinit(self.allocator);
        self.open_frames.deinit(self.allocator);
        self.* = undefined;
    }

    pub fn inspector(self: *ExecutionRecorder) Inspector {
        return .{
            .ptr = self,
            .vtable = &vtable,
            .opcode_mask = OpcodeMask.ALL,
            .capture_memory = self.options.capture_memory,
        };
    }

    /// Create an interactive time-travel debugging session over this recording.
    pub fn session(self: *const ExecutionRecorder, allocator: Allocator) DebugSession {
        return DebugSession.init(allocator, self);
    }

    const vtable: Inspector.VTable = .{
        .onEnter = hook(ExecutionRecorder, insp.FrameEnterEvent, enter),
        .onExit = hook(ExecutionRecorder, insp.FrameExitEvent, exit),
        .onOpcode = hook(ExecutionRecorder, insp.OpcodeEvent, opcode),
        .onOpcodeEnd = hook(ExecutionRecorder, insp.OpcodeEndEvent, opcodeEnd),
        .onFault = hook(ExecutionRecorder, insp.OpcodeEndEvent, fault),
        .onStorageChange = hook(ExecutionRecorder, insp.StorageChangeEvent, storageChange),
    };

    fn findOpenFrame(self: *ExecutionRecorder, frame_id: u64) ?*OpenFrame {
        var i = self.open_frames.items.len;
        while (i > 0) {
            i -= 1;
            if (self.open_frames.items[i].frame_id == frame_id) return &self.open_frames.items[i];
        }
        return null;
    }

    fn enter(self: *ExecutionRecorder, event: insp.FrameEnterEvent) !void {
        try self.open_frames.ensureUnusedCapacity(self.allocator, 1);
        try self.call_frames.ensureUnusedCapacity(self.allocator, 1);

        const caller_step_index: ?usize = if (self.open_frames.getLastOrNull()) |parent|
            parent.pending_step
        else
            null;

        const input_copy = try self.allocator.dupe(u8, event.input);
        const record_index = self.call_frames.items.len;
        self.call_frames.appendAssumeCapacity(.{
            .frame_id = event.frame_id,
            .parent_id = event.parent_id,
            .depth = event.depth,
            .call_type = event.call_type,
            .from = event.from,
            .to = event.to,
            .code_address = event.code_address,
            .value = event.value,
            .gas = event.gas,
            .input = input_copy,
            .is_precompile = event.is_precompile,
            .caller_step_index = caller_step_index,
            .enter_step_index = self.steps.items.len,
        });
        self.open_frames.appendAssumeCapacity(.{
            .frame_id = event.frame_id,
            .record_index = record_index,
        });
    }

    fn exit(self: *ExecutionRecorder, event: insp.FrameExitEvent) !void {
        const open = self.open_frames.pop() orelse return error.UnbalancedFrameExit;
        const frame = &self.call_frames.items[open.record_index];
        frame.gas_used = event.gas_used;
        frame.gas_left = event.gas_left;
        frame.reverted = event.reverted;
        frame.created_address = event.created_address;
        frame.exit_step_index = if (self.steps.items.len > 0) self.steps.items.len - 1 else null;

        const output_copy = try self.allocator.dupe(u8, event.output);
        errdefer self.allocator.free(output_copy);
        const err_copy: ?[]const u8 = if (event.error_name) |name|
            try self.allocator.dupe(u8, name)
        else
            null;

        self.allocator.free(frame.output);
        frame.output = output_copy;
        if (frame.error_name) |old_err| self.allocator.free(old_err);
        frame.error_name = err_copy;
    }

    fn opcode(self: *ExecutionRecorder, event: insp.OpcodeEvent) !void {
        if (self.options.max_steps) |limit| {
            if (self.steps.items.len >= limit) {
                self.truncated = true;
                if (self.findOpenFrame(event.frame_id)) |open| {
                    open.pending_step = null;
                    open.last_step = null;
                } else {
                    self.orphan_pending_step = null;
                    self.orphan_last_step = null;
                }
                return;
            }
        }

        try self.steps.ensureUnusedCapacity(self.allocator, 1);

        const stack_copy = try self.allocator.dupe(u256, event.stack);
        errdefer self.allocator.free(stack_copy);

        const return_data_copy = try self.allocator.dupe(u8, event.return_data);
        errdefer self.allocator.free(return_data_copy);

        const memory_copy: ?[]const u8 = if (self.options.capture_memory)
            if (event.memory) |mem| try self.allocator.dupe(u8, mem) else null
        else
            null;
        errdefer if (memory_copy) |mem| self.allocator.free(mem);

        const source_loc: ?SourceLocation = if (self.options.source_map) |resolver|
            resolver.resolve(event.code_address, event.pc)
        else
            null;

        const step_index = self.steps.items.len;
        self.steps.appendAssumeCapacity(.{
            .step_index = step_index,
            .frame_id = event.frame_id,
            .depth = event.depth,
            .pc = event.pc,
            .op = event.op,
            .op_name = event.op_name,
            .gas = event.gas,
            .gas_cost = 0,
            .memory_size = event.memory_size,
            .memory = memory_copy,
            .stack = stack_copy,
            .return_data = return_data_copy,
            .refund = event.refund,
            .address = event.address,
            .code_address = event.code_address,
            .error_name = null,
            .source_loc = source_loc,
        });

        if (self.findOpenFrame(event.frame_id)) |open| {
            const frame = &self.call_frames.items[open.record_index];
            if (!frame.has_steps) {
                frame.enter_step_index = step_index;
                frame.has_steps = true;
            }
            open.pending_step = step_index;
            open.last_step = step_index;
        } else {
            self.orphan_pending_step = step_index;
            self.orphan_last_step = step_index;
        }
    }

    fn opcodeEnd(self: *ExecutionRecorder, event: insp.OpcodeEndEvent) !void {
        const step_index = blk: {
            if (self.findOpenFrame(event.frame_id)) |open| {
                const idx = open.pending_step orelse return;
                open.pending_step = null;
                break :blk idx;
            }
            const idx = self.orphan_pending_step orelse return;
            self.orphan_pending_step = null;
            break :blk idx;
        };

        const step = &self.steps.items[step_index];
        step.gas_cost = event.gas_cost;
        if (event.error_name) |name| {
            if (step.error_name == null) {
                step.error_name = try self.allocator.dupe(u8, name);
            }
        }
    }

    fn fault(self: *ExecutionRecorder, event: insp.OpcodeEndEvent) !void {
        const step_index = blk: {
            if (self.findOpenFrame(event.frame_id)) |open| {
                break :blk open.last_step orelse return;
            }
            break :blk self.orphan_last_step orelse return;
        };

        const step = &self.steps.items[step_index];
        if (step.frame_id != event.frame_id or step.pc != event.pc or step.op != event.op) return;
        if (step.gas_cost == 0) step.gas_cost = event.gas_cost;
        if (step.error_name == null) {
            step.error_name = try self.allocator.dupe(u8, event.error_name orelse "fault");
        }
    }

    fn storageChange(self: *ExecutionRecorder, event: insp.StorageChangeEvent) !void {
        const step_index: ?usize = if (self.findOpenFrame(event.frame_id)) |open|
            open.pending_step
        else
            self.orphan_pending_step;

        try self.storage_events.append(self.allocator, .{
            .step_index = step_index,
            .frame_id = event.frame_id,
            .address = event.address,
            .slot = event.slot,
            .prev_value = event.prev_value,
            .new_value = event.new_value,
            .is_read = event.is_read,
        });
    }
};

/// Interactive forward/backward time-travel cursor over an `ExecutionRecorder`.
pub const DebugSession = struct {
    const BreakpointEntry = struct {
        id: usize,
        bp: Breakpoint,
    };

    const op_revert: u8 = 0xfd;

    allocator: Allocator,
    recorder: *const ExecutionRecorder,
    cursor: ?usize,
    breakpoints: std.ArrayList(BreakpointEntry) = .{},
    next_breakpoint_id: usize = 0,

    pub fn init(allocator: Allocator, recorder: *const ExecutionRecorder) DebugSession {
        return .{
            .allocator = allocator,
            .recorder = recorder,
            .cursor = if (recorder.steps.items.len > 0) 0 else null,
        };
    }

    pub fn deinit(self: *DebugSession) void {
        self.breakpoints.deinit(self.allocator);
        self.* = undefined;
    }

    /// Total number of recorded steps in the underlying timeline.
    pub fn stepCount(self: *const DebugSession) usize {
        return self.recorder.steps.items.len;
    }

    /// Current zero-based step index, or null if the recording is empty.
    pub fn currentIndex(self: *const DebugSession) ?usize {
        return self.cursor;
    }

    /// Returns the step at the current cursor, or null if no steps exist.
    pub fn current(self: *const DebugSession) ?*const DebugStep {
        const idx = self.cursor orelse return null;
        if (idx >= self.recorder.steps.items.len) return null;
        return &self.recorder.steps.items[idx];
    }

    /// Advances forward by one opcode (entering child call frames).
    /// Returns null without moving past the end if already at the final step.
    pub fn stepInto(self: *DebugSession) ?*const DebugStep {
        const idx = self.cursor orelse return null;
        if (idx + 1 >= self.recorder.steps.items.len) return null;
        self.cursor = idx + 1;
        return &self.recorder.steps.items[idx + 1];
    }

    /// Time-travel rewind by one opcode.
    /// Returns null without moving if already at step 0 or empty.
    pub fn stepBack(self: *DebugSession) ?*const DebugStep {
        const idx = self.cursor orelse return null;
        if (idx == 0) return null;
        self.cursor = idx - 1;
        return &self.recorder.steps.items[idx - 1];
    }

    /// Advances to the next step whose call depth is `<= current.depth`,
    /// skipping over nested child frames invoked by CALL/CREATE opcodes.
    pub fn stepOver(self: *DebugSession) ?*const DebugStep {
        const idx = self.cursor orelse return null;
        const steps = self.recorder.steps.items;
        if (idx >= steps.len) return null;
        const target_depth = steps[idx].depth;
        var next = idx + 1;
        while (next < steps.len) : (next += 1) {
            if (steps[next].depth <= target_depth) {
                self.cursor = next;
                return &steps[next];
            }
        }
        return null;
    }

    /// Advances until execution leaves the current frame (`depth < current.depth`).
    pub fn stepOut(self: *DebugSession) ?*const DebugStep {
        const idx = self.cursor orelse return null;
        const steps = self.recorder.steps.items;
        if (idx >= steps.len) return null;
        const target_depth = steps[idx].depth;
        var next = idx + 1;
        while (next < steps.len) : (next += 1) {
            if (steps[next].depth < target_depth) {
                self.cursor = next;
                return &steps[next];
            }
        }
        return null;
    }

    /// Scans forward from `cursor + 1` until any active breakpoint matches.
    pub fn continueUntilBreakpoint(self: *DebugSession) ?*const DebugStep {
        const idx = self.cursor orelse return null;
        const steps = self.recorder.steps.items;
        var next = idx + 1;
        while (next < steps.len) : (next += 1) {
            if (self.matchesAnyBreakpoint(&steps[next])) {
                self.cursor = next;
                return &steps[next];
            }
        }
        return null;
    }

    /// Scans backward from `cursor - 1` until any active breakpoint matches.
    pub fn continueBackUntilBreakpoint(self: *DebugSession) ?*const DebugStep {
        const idx = self.cursor orelse return null;
        if (idx == 0) return null;
        const steps = self.recorder.steps.items;
        var prev = idx;
        while (prev > 0) {
            prev -= 1;
            if (self.matchesAnyBreakpoint(&steps[prev])) {
                self.cursor = prev;
                return &steps[prev];
            }
        }
        return null;
    }

    /// Instant O(1) time-travel jump to an arbitrary step index.
    pub fn jumpToStep(self: *DebugSession, index: usize) ?*const DebugStep {
        const steps = self.recorder.steps.items;
        if (index >= steps.len) return null;
        self.cursor = index;
        return &steps[index];
    }

    /// Registers a breakpoint and returns its unique identifier.
    pub fn addBreakpoint(self: *DebugSession, bp: Breakpoint) !usize {
        const id = self.next_breakpoint_id;
        try self.breakpoints.append(self.allocator, .{ .id = id, .bp = bp });
        self.next_breakpoint_id += 1;
        return id;
    }

    /// Removes the breakpoint with `id` (no-op if not present).
    pub fn removeBreakpoint(self: *DebugSession, id: usize) void {
        for (self.breakpoints.items, 0..) |entry, i| {
            if (entry.id == id) {
                _ = self.breakpoints.orderedRemove(i);
                return;
            }
        }
    }

    /// Removes all active breakpoints.
    pub fn clearBreakpoints(self: *DebugSession) void {
        self.breakpoints.clearRetainingCapacity();
    }

    /// Number of currently active breakpoints.
    pub fn breakpointCount(self: *const DebugSession) usize {
        return self.breakpoints.items.len;
    }

    fn matchesAnyBreakpoint(self: *const DebugSession, step: *const DebugStep) bool {
        for (self.breakpoints.items) |entry| {
            if (self.matchesBreakpoint(entry.bp, step)) return true;
        }
        return false;
    }

    fn matchesBreakpoint(self: *const DebugSession, bp: Breakpoint, step: *const DebugStep) bool {
        return switch (bp) {
            .pc => |target| step.pc == target.pc and
                (target.address == null or target.address.?.equals(step.code_address) or target.address.?.equals(step.address)),
            .opcode => |op| step.op == op,
            .call_target => |target| self.matchesCallTarget(target, step),
            .storage_slot => |target| self.matchesStorageSlot(target.address, target.slot, step),
            .on_revert => step.op == op_revert or
                (step.error_name != null and std.mem.eql(u8, step.error_name.?, "execution reverted")),
            .on_fault => step.error_name != null,
            .depth_at_most => |max_depth| step.depth <= max_depth,
        };
    }

    fn matchesCallTarget(self: *const DebugSession, target: Address, step: *const DebugStep) bool {
        for (self.recorder.call_frames.items) |frame| {
            if (!frame.to.equals(target) and !frame.code_address.equals(target)) continue;
            if (frame.has_steps) {
                if (frame.frame_id == step.frame_id and frame.enter_step_index == step.step_index) {
                    return true;
                }
            } else if (frame.caller_step_index) |caller_idx| {
                if (caller_idx == step.step_index) return true;
            }
        }
        return false;
    }

    fn matchesStorageSlot(self: *const DebugSession, address: ?Address, slot: u256, step: *const DebugStep) bool {
        for (self.recorder.storage_events.items) |ev| {
            const ev_step = ev.step_index orelse continue;
            if (ev_step != step.step_index) continue;
            if (ev.slot != slot) continue;
            if (address == null or address.?.equals(ev.address)) return true;
        }
        return false;
    }

    /// Writes a human-readable dump of the current step's PC, opcode, gas,
    /// call depth, stack, memory, return data, error, and source location.
    pub fn writeCurrentStateSummary(self: *const DebugSession, writer: *std.Io.Writer) !void {
        const step = self.current() orelse {
            try writer.writeAll("<no active step>\n");
            return;
        };

        try writer.print(
            "Step {d}/{d} | Frame #{d} (depth {d}) | PC=0x{x:0>4} ({d}) | {s} (0x{x:0>2})\n",
            .{
                step.step_index + 1,
                self.recorder.steps.items.len,
                step.frame_id,
                step.depth,
                step.pc,
                step.pc,
                step.op_name,
                step.op,
            },
        );
        try writer.print(
            "Address: 0x{x} | Code: 0x{x}\n",
            .{ @as([]const u8, &step.address.bytes), @as([]const u8, &step.code_address.bytes) },
        );
        try writer.print(
            "Gas: {d} (cost {d}) | Refund: {d} | MemorySize: {d}\n",
            .{ step.gas, step.gas_cost, step.refund, step.memory_size },
        );

        if (step.source_loc) |loc| {
            try writer.print(
                "Source: file={d} offset={d} length={d} jump={s}\n",
                .{ loc.file_id, loc.offset, loc.length, @tagName(loc.jump) },
            );
        }

        if (step.error_name) |err_name| {
            try writer.print("Error: {s}\n", .{err_name});
        }

        try writer.print("Stack ({d}):", .{step.stack.len});
        if (step.stack.len == 0) {
            try writer.writeAll(" []\n");
        } else {
            try writer.writeByte('\n');
            // Display top-of-stack first ([0] = top).
            var i: usize = 0;
            while (i < step.stack.len) : (i += 1) {
                const value = step.stack[step.stack.len - 1 - i];
                try writer.print("  [{d}] 0x{x}\n", .{ i, value });
            }
        }

        if (step.memory) |mem| {
            try writer.print("Memory ({d} bytes):", .{mem.len});
            if (mem.len == 0) {
                try writer.writeAll(" 0x\n");
            } else {
                const preview_len = @min(mem.len, 64);
                try writer.print(" 0x{x}", .{mem[0..preview_len]});
                if (mem.len > preview_len) {
                    try writer.print("... (+{d} bytes)", .{mem.len - preview_len});
                }
                try writer.writeByte('\n');
            }
        } else if (step.memory_size > 0) {
            try writer.print("Memory ({d} bytes): <not captured>\n", .{step.memory_size});
        } else {
            try writer.writeAll("Memory (0 bytes): 0x\n");
        }

        if (step.return_data.len > 0) {
            const preview_len = @min(step.return_data.len, 64);
            try writer.print("ReturnData ({d} bytes): 0x{x}", .{ step.return_data.len, step.return_data[0..preview_len] });
            if (step.return_data.len > preview_len) {
                try writer.print("... (+{d} bytes)", .{step.return_data.len - preview_len});
            }
            try writer.writeByte('\n');
        }
    }
};
