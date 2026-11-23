//! Configurable retention trace store (`TraceStore`) and indexed Parity
//! `trace_filter` engine modeled after Nethermind and Erigon trace indexing.
//!
//! Flattens `tracers.CallTracer` trees into owned `StoredTraceEntry` records,
//! maintains secondary `block_index`, `from_index`, and `to_index` hash sets
//! for fast intersection queries, evicts oldest blocks when retention limits
//! are exceeded, and supports zero-allocation reorg rollbacks.
const std = @import("std");
const primitives = @import("voltaire");
const inspector = @import("inspector.zig");
const tracers = @import("tracers.zig");

const Address = primitives.Address;
const Allocator = std.mem.Allocator;
const CallType = inspector.CallType;
const CallFrame = tracers.CallFrame;
const CallTracer = tracers.CallTracer;

pub const RetentionConfig = struct {
    max_blocks: usize = 256,
    max_entries: usize = 65536,
    keep_reverted: bool = true,
};

pub const StoredTraceEntry = struct {
    block_number: u64,
    block_hash: [32]u8,
    tx_hash: [32]u8,
    tx_index: u32,
    call_type: CallType,
    from: Address,
    to: ?Address,
    value: u256,
    gas: u64,
    gas_used: u64,
    input: []const u8,
    output: []const u8,
    error_msg: ?[]const u8,
    revert_reason: ?[]const u8,
    subtraces: usize,
    trace_address: []const usize,
    reverted: bool,

    fn destroy(self: *StoredTraceEntry, allocator: Allocator) void {
        allocator.free(self.input);
        allocator.free(self.output);
        if (self.error_msg) |msg| allocator.free(msg);
        if (self.revert_reason) |reason| allocator.free(reason);
        allocator.free(self.trace_address);
        allocator.destroy(self);
    }
};

pub const TraceFilter = struct {
    from_block: ?u64 = null,
    to_block: ?u64 = null,
    from_address: ?[]const Address = null,
    to_address: ?[]const Address = null,
    after: usize = 0,
    count: ?usize = null,
};

pub const TraceStore = struct {
    const IdSet = std.AutoArrayHashMapUnmanaged(u64, void);
    const BlockIndex = std.AutoArrayHashMapUnmanaged(u64, IdSet);
    const AddrIndex = std.AutoHashMapUnmanaged(Address, IdSet);

    allocator: Allocator,
    config: RetentionConfig,
    next_id: u64 = 1,
    entries: std.AutoHashMapUnmanaged(u64, *StoredTraceEntry) = .{},
    block_index: BlockIndex = .{},
    from_index: AddrIndex = .{},
    to_index: AddrIndex = .{},

    pub fn init(allocator: Allocator, config: RetentionConfig) TraceStore {
        return .{
            .allocator = allocator,
            .config = config,
        };
    }

    pub fn deinit(self: *TraceStore) void {
        self.clear();
        self.entries.deinit(self.allocator);
        self.block_index.deinit(self.allocator);
        self.from_index.deinit(self.allocator);
        self.to_index.deinit(self.allocator);
        self.* = undefined;
    }

    pub fn clear(self: *TraceStore) void {
        var entry_it = self.entries.valueIterator();
        while (entry_it.next()) |entry_ptr| {
            entry_ptr.*.destroy(self.allocator);
        }
        self.entries.clearRetainingCapacity();

        for (self.block_index.values()) |*set| set.deinit(self.allocator);
        self.block_index.clearRetainingCapacity();

        var from_it = self.from_index.valueIterator();
        while (from_it.next()) |set| set.deinit(self.allocator);
        self.from_index.clearRetainingCapacity();

        var to_it = self.to_index.valueIterator();
        while (to_it.next()) |set| set.deinit(self.allocator);
        self.to_index.clearRetainingCapacity();
    }

    pub fn entryCount(self: *const TraceStore) usize {
        return self.entries.count();
    }

    pub fn blockCount(self: *const TraceStore) usize {
        return self.block_index.count();
    }

    pub fn hasBlock(self: *const TraceStore, block_number: u64) bool {
        return self.block_index.contains(block_number);
    }

    /// Flattens a `CallTracer` tree into indexed `StoredTraceEntry` rows,
    /// updating `block_index`, `from_index`, and `to_index`, and evicting
    /// oldest blocks when `max_blocks` or `max_entries` is exceeded.
    pub fn recordCallTrace(
        self: *TraceStore,
        block_number: u64,
        block_hash: [32]u8,
        tx_hash: [32]u8,
        tx_index: u32,
        call_tracer: *const CallTracer,
    ) !void {
        if (call_tracer.err) |e| return e;
        if (self.config.max_blocks == 0 or self.config.max_entries == 0) return;
        const root = call_tracer.root() orelse return;

        var staged: std.ArrayList(*StoredTraceEntry) = .{};
        var committed: usize = 0;
        // A failed insert must not leave half a transaction indexed.
        const first_id = self.next_id;
        errdefer {
            self.removeEntriesFrom(first_id);
            for (staged.items[committed..]) |entry| entry.destroy(self.allocator);
            staged.deinit(self.allocator);
        }

        var path: std.ArrayList(usize) = .{};
        defer path.deinit(self.allocator);

        try self.flattenFrame(
            block_number,
            block_hash,
            tx_hash,
            tx_index,
            root,
            false,
            &path,
            &staged,
        );

        for (staged.items) |entry| {
            try self.insertEntry(entry);
            committed += 1;
        }
        staged.deinit(self.allocator);

        self.enforceRetention();
    }

    fn visibleInFlat(frame: *const CallFrame) bool {
        return !frame.is_precompile;
    }

    fn isCreate(call_type: CallType) bool {
        return call_type == .create or call_type == .create2;
    }

    fn flattenFrame(
        self: *TraceStore,
        block_number: u64,
        block_hash: [32]u8,
        tx_hash: [32]u8,
        tx_index: u32,
        frame: *const CallFrame,
        ancestor_reverted: bool,
        path: *std.ArrayList(usize),
        out: *std.ArrayList(*StoredTraceEntry),
    ) !void {
        const rolled_back = ancestor_reverted or frame.reverted;

        var subtraces: usize = 0;
        for (frame.calls.items) |child| {
            if (visibleInFlat(child)) subtraces += 1;
        }

        if (self.config.keep_reverted or !rolled_back) {
            const entry = try self.cloneFrameEntry(
                block_number,
                block_hash,
                tx_hash,
                tx_index,
                frame,
                subtraces,
                path.items,
            );
            errdefer entry.destroy(self.allocator);
            try out.append(self.allocator, entry);
        }

        var child_index: usize = 0;
        for (frame.calls.items) |child| {
            if (!visibleInFlat(child)) continue;
            try path.append(self.allocator, child_index);
            defer _ = path.pop();
            try self.flattenFrame(
                block_number,
                block_hash,
                tx_hash,
                tx_index,
                child,
                rolled_back,
                path,
                out,
            );
            child_index += 1;
        }
    }

    fn cloneFrameEntry(
        self: *TraceStore,
        block_number: u64,
        block_hash: [32]u8,
        tx_hash: [32]u8,
        tx_index: u32,
        frame: *const CallFrame,
        subtraces: usize,
        trace_address: []const usize,
    ) !*StoredTraceEntry {
        const entry = try self.allocator.create(StoredTraceEntry);
        errdefer self.allocator.destroy(entry);

        const input_copy = try self.allocator.dupe(u8, frame.input);
        errdefer self.allocator.free(input_copy);

        const output_copy = try self.allocator.dupe(u8, frame.output);
        errdefer self.allocator.free(output_copy);

        const err_copy: ?[]const u8 = if (frame.error_msg) |msg|
            try self.allocator.dupe(u8, msg)
        else
            null;
        errdefer if (err_copy) |msg| self.allocator.free(msg);

        const reason_copy: ?[]const u8 = if (frame.revert_reason) |reason|
            try self.allocator.dupe(u8, reason)
        else
            null;
        errdefer if (reason_copy) |reason| self.allocator.free(reason);

        const addr_path_copy = try self.allocator.dupe(usize, trace_address);
        errdefer self.allocator.free(addr_path_copy);

        const failed_create = isCreate(frame.call_type) and frame.reverted and frame.created_address == null;
        const to_addr: ?Address = if (failed_create) null else frame.effectiveTo();

        entry.* = .{
            .block_number = block_number,
            .block_hash = block_hash,
            .tx_hash = tx_hash,
            .tx_index = tx_index,
            .call_type = frame.call_type,
            .from = frame.from,
            .to = to_addr,
            .value = frame.value,
            .gas = frame.gas,
            .gas_used = frame.gas_used,
            .input = input_copy,
            .output = output_copy,
            .error_msg = err_copy,
            .revert_reason = reason_copy,
            .subtraces = subtraces,
            .trace_address = addr_path_copy,
            .reverted = frame.reverted,
        };
        return entry;
    }

    fn insertEntry(self: *TraceStore, entry: *StoredTraceEntry) !void {
        const id = self.next_id;
        try self.entries.ensureUnusedCapacity(self.allocator, 1);

        const blk_gop = try self.block_index.getOrPut(self.allocator, entry.block_number);
        if (!blk_gop.found_existing) blk_gop.value_ptr.* = .{};
        errdefer if (!blk_gop.found_existing and blk_gop.value_ptr.count() == 0) {
            blk_gop.value_ptr.deinit(self.allocator);
            _ = self.block_index.swapRemove(entry.block_number);
        };
        try blk_gop.value_ptr.ensureUnusedCapacity(self.allocator, 1);

        const from_gop = try self.from_index.getOrPut(self.allocator, entry.from);
        if (!from_gop.found_existing) from_gop.value_ptr.* = .{};
        errdefer if (!from_gop.found_existing and from_gop.value_ptr.count() == 0) {
            from_gop.value_ptr.deinit(self.allocator);
            _ = self.from_index.remove(entry.from);
        };
        try from_gop.value_ptr.ensureUnusedCapacity(self.allocator, 1);

        if (entry.to) |to_addr| {
            const to_gop = try self.to_index.getOrPut(self.allocator, to_addr);
            if (!to_gop.found_existing) to_gop.value_ptr.* = .{};
            errdefer if (!to_gop.found_existing and to_gop.value_ptr.count() == 0) {
                to_gop.value_ptr.deinit(self.allocator);
                _ = self.to_index.remove(to_addr);
            };
            try to_gop.value_ptr.ensureUnusedCapacity(self.allocator, 1);

            self.next_id += 1;
            self.entries.putAssumeCapacityNoClobber(id, entry);
            blk_gop.value_ptr.putAssumeCapacity(id, {});
            from_gop.value_ptr.putAssumeCapacity(id, {});
            to_gop.value_ptr.putAssumeCapacity(id, {});
        } else {
            self.next_id += 1;
            self.entries.putAssumeCapacityNoClobber(id, entry);
            blk_gop.value_ptr.putAssumeCapacity(id, {});
            from_gop.value_ptr.putAssumeCapacity(id, {});
        }
    }

    fn removeFromAddrIndex(self: *TraceStore, map: *AddrIndex, addr: Address, id: u64) void {
        if (map.getPtr(addr)) |set| {
            _ = set.swapRemove(id);
            if (set.count() == 0) {
                set.deinit(self.allocator);
                _ = map.remove(addr);
            }
        }
    }

    /// Removes one entry from `entries` and every index, then frees it.
    fn removeEntry(self: *TraceStore, id: u64) void {
        const removed = self.entries.fetchRemove(id) orelse return;
        const entry = removed.value;
        if (self.block_index.getPtr(entry.block_number)) |set| {
            _ = set.swapRemove(id);
            if (set.count() == 0) {
                set.deinit(self.allocator);
                _ = self.block_index.swapRemove(entry.block_number);
            }
        }
        self.removeFromAddrIndex(&self.from_index, entry.from, id);
        if (entry.to) |to_addr| self.removeFromAddrIndex(&self.to_index, to_addr, id);
        entry.destroy(self.allocator);
    }

    /// Undoes every insert with an id at or above `first_id`. Never allocates.
    fn removeEntriesFrom(self: *TraceStore, first_id: u64) void {
        var id = first_id;
        while (id < self.next_id) : (id += 1) self.removeEntry(id);
        self.next_id = first_id;
    }

    fn oldestBlockNumber(self: *const TraceStore) ?u64 {
        const keys = self.block_index.keys();
        if (keys.len == 0) return null;
        var oldest = keys[0];
        for (keys[1..]) |bn| {
            if (bn < oldest) oldest = bn;
        }
        return oldest;
    }

    fn evictBlock(self: *TraceStore, block_number: u64) void {
        const kv = self.block_index.fetchSwapRemove(block_number) orelse return;
        var ids = kv.value;
        defer ids.deinit(self.allocator);

        for (ids.keys()) |id| {
            if (self.entries.fetchRemove(id)) |removed| {
                const entry = removed.value;
                self.removeFromAddrIndex(&self.from_index, entry.from, id);
                if (entry.to) |to_addr| {
                    self.removeFromAddrIndex(&self.to_index, to_addr, id);
                }
                entry.destroy(self.allocator);
            }
        }
    }

    fn evictOldestEntryInBlock(self: *TraceStore, block_number: u64) void {
        const set = self.block_index.getPtr(block_number) orelse return;
        if (set.count() == 0) {
            set.deinit(self.allocator);
            _ = self.block_index.swapRemove(block_number);
            return;
        }
        var min_id = set.keys()[0];
        for (set.keys()[1..]) |id| {
            if (id < min_id) min_id = id;
        }
        self.removeEntry(min_id);
    }

    fn enforceRetention(self: *TraceStore) void {
        while (self.block_index.count() > self.config.max_blocks) {
            const oldest = self.oldestBlockNumber() orelse break;
            self.evictBlock(oldest);
        }
        while (self.entries.count() > self.config.max_entries) {
            if (self.block_index.count() > 1) {
                const oldest = self.oldestBlockNumber() orelse break;
                self.evictBlock(oldest);
            } else {
                const remaining = self.oldestBlockNumber() orelse break;
                self.evictOldestEntryInBlock(remaining);
            }
        }
    }

    /// Reorg-aware pruning: removes every block strictly greater than
    /// `new_head_block` along with all of its secondary index entries.
    pub fn rollbackReorg(self: *TraceStore, new_head_block: u64) void {
        var i = self.block_index.count();
        while (i > 0) {
            i -= 1;
            const bn = self.block_index.keys()[i];
            if (bn > new_head_block) {
                self.evictBlock(bn);
            }
        }
    }

    // -----------------------------------------------------------------------
    // Indexed trace_filter query
    // -----------------------------------------------------------------------

    fn addressInSlice(slice: []const Address, target: Address) bool {
        for (slice) |addr| {
            if (addr.equals(target)) return true;
        }
        return false;
    }

    fn seenAddressEarlier(slice: []const Address, index: usize) bool {
        const target = slice[index];
        for (slice[0..index]) |prev| {
            if (prev.equals(target)) return true;
        }
        return false;
    }

    fn matchesBlockRange(block_number: u64, from_block: ?u64, to_block: ?u64) bool {
        if (from_block) |lo| if (block_number < lo) return false;
        if (to_block) |hi| if (block_number > hi) return false;
        return true;
    }

    fn matchesQuery(entry: *const StoredTraceEntry, query: TraceFilter) bool {
        if (!matchesBlockRange(entry.block_number, query.from_block, query.to_block)) return false;
        if (query.from_address) |from_addrs| {
            if (from_addrs.len > 0 and !addressInSlice(from_addrs, entry.from)) return false;
        }
        if (query.to_address) |to_addrs| {
            if (to_addrs.len > 0) {
                const to_addr = entry.to orelse return false;
                if (!addressInSlice(to_addrs, to_addr)) return false;
            }
        }
        return true;
    }

    fn entryLessThan(_: void, a: *const StoredTraceEntry, b: *const StoredTraceEntry) bool {
        if (a.block_number != b.block_number) return a.block_number < b.block_number;
        if (a.tx_index != b.tx_index) return a.tx_index < b.tx_index;
        const min_len = @min(a.trace_address.len, b.trace_address.len);
        for (0..min_len) |i| {
            if (a.trace_address[i] != b.trace_address[i]) {
                return a.trace_address[i] < b.trace_address[i];
            }
        }
        return a.trace_address.len < b.trace_address.len;
    }

    const IndexChoice = enum { block, from, to };

    /// Executes an indexed `trace_filter` query, choosing the smallest index
    /// candidate set for intersection, sorting deterministically by
    /// `(block_number, tx_index, trace_address)`, and applying `after`/`count`
    /// pagination. Caller owns the returned slice and frees it with `allocator`.
    pub fn filter(
        self: *const TraceStore,
        allocator: Allocator,
        query: TraceFilter,
    ) ![]const *const StoredTraceEntry {
        if (query.from_block) |lo| {
            if (query.to_block) |hi| {
                if (lo > hi) return allocator.alloc(*const StoredTraceEntry, 0);
            }
        }
        if (query.count) |c| {
            if (c == 0) return allocator.alloc(*const StoredTraceEntry, 0);
        }

        const has_from = if (query.from_address) |s| s.len > 0 else false;
        const has_to = if (query.to_address) |s| s.len > 0 else false;

        var block_est: usize = 0;
        for (self.block_index.keys(), self.block_index.values()) |bn, set| {
            if (matchesBlockRange(bn, query.from_block, query.to_block)) {
                block_est += set.count();
            }
        }
        if (block_est == 0) return allocator.alloc(*const StoredTraceEntry, 0);

        var best_choice: IndexChoice = .block;
        var best_est: usize = block_est;

        if (has_from) {
            const from_addrs = query.from_address.?;
            var from_est: usize = 0;
            for (from_addrs, 0..) |addr, idx| {
                if (seenAddressEarlier(from_addrs, idx)) continue;
                if (self.from_index.getPtr(addr)) |set| from_est += set.count();
            }
            if (from_est == 0) return allocator.alloc(*const StoredTraceEntry, 0);
            if (from_est < best_est) {
                best_est = from_est;
                best_choice = .from;
            }
        }

        if (has_to) {
            const to_addrs = query.to_address.?;
            var to_est: usize = 0;
            for (to_addrs, 0..) |addr, idx| {
                if (seenAddressEarlier(to_addrs, idx)) continue;
                if (self.to_index.getPtr(addr)) |set| to_est += set.count();
            }
            if (to_est == 0) return allocator.alloc(*const StoredTraceEntry, 0);
            if (to_est < best_est) {
                best_est = to_est;
                best_choice = .to;
            }
        }

        var matches: std.ArrayList(*const StoredTraceEntry) = .{};
        defer matches.deinit(allocator);

        switch (best_choice) {
            .from => {
                const from_addrs = query.from_address.?;
                for (from_addrs, 0..) |addr, idx| {
                    if (seenAddressEarlier(from_addrs, idx)) continue;
                    const set = self.from_index.getPtr(addr) orelse continue;
                    for (set.keys()) |id| {
                        const entry = self.entries.get(id) orelse continue;
                        if (matchesQuery(entry, query)) {
                            try matches.append(allocator, entry);
                        }
                    }
                }
            },
            .to => {
                const to_addrs = query.to_address.?;
                for (to_addrs, 0..) |addr, idx| {
                    if (seenAddressEarlier(to_addrs, idx)) continue;
                    const set = self.to_index.getPtr(addr) orelse continue;
                    for (set.keys()) |id| {
                        const entry = self.entries.get(id) orelse continue;
                        if (matchesQuery(entry, query)) {
                            try matches.append(allocator, entry);
                        }
                    }
                }
            },
            .block => {
                for (self.block_index.keys(), self.block_index.values()) |bn, set| {
                    if (!matchesBlockRange(bn, query.from_block, query.to_block)) continue;
                    for (set.keys()) |id| {
                        const entry = self.entries.get(id) orelse continue;
                        if (matchesQuery(entry, query)) {
                            try matches.append(allocator, entry);
                        }
                    }
                }
            },
        }

        std.mem.sort(*const StoredTraceEntry, matches.items, {}, entryLessThan);

        if (query.after >= matches.items.len) {
            return allocator.alloc(*const StoredTraceEntry, 0);
        }
        const start = query.after;
        const available = matches.items.len - start;
        const take = if (query.count) |c| @min(c, available) else available;

        const out = try allocator.alloc(*const StoredTraceEntry, take);
        @memcpy(out, matches.items[start .. start + take]);
        return out;
    }

    // -----------------------------------------------------------------------
    // Parity `trace_filter` JSON formatting
    // -----------------------------------------------------------------------

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
            try tracers.writeJsonString(self.writer, name);
            try self.writer.writeByte(':');
        }

        fn string(self: *JsonObject, name: []const u8, value: []const u8) !void {
            try self.key(name);
            try tracers.writeJsonString(self.writer, value);
        }

        fn hex(self: *JsonObject, name: []const u8, bytes: []const u8) !void {
            try self.key(name);
            try self.writer.print("\"0x{x}\"", .{bytes});
        }

        fn quantity(self: *JsonObject, name: []const u8, value: anytype) !void {
            try self.key(name);
            try self.writer.print("\"0x{x}\"", .{value});
        }
    };

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

    /// Writes `matches` as a Parity / Erigon `trace_filter` JSON array.
    pub fn writeFilterJson(writer: *std.Io.Writer, matches: []const *const StoredTraceEntry) !void {
        try writer.writeByte('[');
        for (matches, 0..) |entry, idx| {
            if (idx > 0) try writer.writeByte(',');
            var obj = try JsonObject.begin(writer);
            try obj.key("action");
            var action = try JsonObject.begin(writer);
            switch (entry.call_type) {
                .create, .create2 => {
                    try action.string("creationMethod", if (entry.call_type == .create) "create" else "create2");
                    try action.hex("from", &entry.from.bytes);
                    try action.quantity("gas", entry.gas);
                    try action.hex("init", entry.input);
                    try action.quantity("value", entry.value);
                },
                .selfdestruct => {
                    const refund_addr = entry.to orelse primitives.ZERO_ADDRESS;
                    try action.hex("address", &entry.from.bytes);
                    try action.quantity("balance", entry.value);
                    try action.hex("refundAddress", &refund_addr.bytes);
                },
                else => {
                    const to_addr = entry.to orelse primitives.ZERO_ADDRESS;
                    try action.string("callType", switch (entry.call_type) {
                        .callcode => "callcode",
                        .delegatecall => "delegatecall",
                        .staticcall => "staticcall",
                        else => "call",
                    });
                    try action.hex("from", &entry.from.bytes);
                    try action.quantity("gas", entry.gas);
                    try action.hex("input", entry.input);
                    try action.hex("to", &to_addr.bytes);
                    try action.quantity("value", entry.value);
                },
            }
            try action.end();

            try obj.hex("blockHash", &entry.block_hash);
            try obj.key("blockNumber");
            try writer.print("{d}", .{entry.block_number});

            if (entry.call_type == .selfdestruct) {
                try obj.key("result");
                try writer.writeAll("null");
            } else if (entry.error_msg) |msg| {
                try obj.string("error", parityError(msg));
            } else {
                try obj.key("result");
                var result = try JsonObject.begin(writer);
                if (isCreate(entry.call_type)) {
                    const created_addr = entry.to orelse primitives.ZERO_ADDRESS;
                    try result.hex("address", &created_addr.bytes);
                    try result.hex("code", entry.output);
                    try result.quantity("gasUsed", entry.gas_used);
                } else {
                    try result.quantity("gasUsed", entry.gas_used);
                    try result.hex("output", entry.output);
                }
                try result.end();
            }

            try obj.key("subtraces");
            try writer.print("{d}", .{entry.subtraces});

            try obj.key("traceAddress");
            try writer.writeByte('[');
            for (entry.trace_address, 0..) |step, i| {
                if (i > 0) try writer.writeByte(',');
                try writer.print("{d}", .{step});
            }
            try writer.writeByte(']');

            try obj.hex("transactionHash", &entry.tx_hash);
            try obj.key("transactionPosition");
            try writer.print("{d}", .{entry.tx_index});
            try obj.string("type", switch (entry.call_type) {
                .create, .create2 => "create",
                .selfdestruct => "suicide",
                else => "call",
            });
            try obj.end();
        }
        try writer.writeByte(']');
    }
};

pub const writeFilterJson = TraceStore.writeFilterJson;
