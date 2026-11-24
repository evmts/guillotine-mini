const std = @import("std");
const primitives = @import("voltaire");
const evm_mod = @import("evm.zig");
const insp = @import("inspector.zig");
const tracers = @import("tracers.zig");
const live = @import("live_tracer.zig");
const store_mod = @import("trace_store.zig");

const testing = std.testing;
const Address = primitives.Address;
const Evm = evm_mod.Evm(.{});
const CallResult = Evm.CallResult;
const HostInterface = @import("host.zig").HostInterface;

const CallTracer = tracers.CallTracer;
const BlockHooks = live.BlockHooks;
const MuxBlockHooks = live.MuxBlockHooks;
const SupplyTracer = live.SupplyTracer;
const SignedU256 = live.SignedU256;
const TraceStore = store_mod.TraceStore;
const TraceFilter = store_mod.TraceFilter;
const StoredTraceEntry = store_mod.StoredTraceEntry;

// ---------------------------------------------------------------------------
// Test helpers (mini assembler, in-memory host, JSON helpers)
// ---------------------------------------------------------------------------

const Asm = struct {
    list: std.ArrayList(u8) = .{},

    fn deinit(self: *Asm) void {
        self.list.deinit(testing.allocator);
    }

    fn bytes(self: *const Asm) []const u8 {
        return self.list.items;
    }

    fn op(self: *Asm, code: []const u8) !void {
        try self.list.appendSlice(testing.allocator, code);
    }

    fn push(self: *Asm, value: u256) !void {
        if (value == 0) return self.op(&.{0x5f});
        const bits: usize = 256 - @as(usize, @clz(value));
        const n = (bits + 7) / 8;
        try self.list.append(testing.allocator, @intCast(0x5f + n));
        var buf: [32]u8 = undefined;
        std.mem.writeInt(u256, &buf, value, .big);
        try self.op(buf[32 - n ..]);
    }

    fn mstoreLeft(self: *Asm, offset: u256, value: u256, len: u8) !void {
        const shift: u8 = @intCast((32 - @as(u16, len)) * 8);
        try self.push(value << shift);
        try self.push(offset);
        try self.op(&.{0x52});
    }

    fn call(self: *Asm, to: u256, value: u256, in_off: u256, in_len: u256, out_off: u256, out_len: u256) !void {
        for ([_]u256{ out_len, out_off, in_len, in_off, value, to }) |v| try self.push(v);
        try self.op(&.{ 0x5a, 0xf1, 0x50 });
    }

    fn sstore(self: *Asm, slot: u256, value: u256) !void {
        try self.push(value);
        try self.push(slot);
        try self.op(&.{0x55});
    }

    fn returnWord(self: *Asm, value: u256) !void {
        try self.push(value);
        try self.push(0);
        try self.op(&.{0x52});
        try self.push(32);
        try self.push(0);
        try self.op(&.{0xf3});
    }

    fn revertError(self: *Asm, comptime reason: []const u8) !void {
        comptime std.debug.assert(reason.len <= 32);
        try self.mstoreLeft(0, 0x08c379a0, 4);
        try self.push(32);
        try self.push(4);
        try self.op(&.{0x52});
        try self.push(reason.len);
        try self.push(36);
        try self.op(&.{0x52});
        var word: [32]u8 = @splat(0);
        @memcpy(word[0..reason.len], reason);
        try self.push(std.mem.readInt(u256, &word, .big));
        try self.push(68);
        try self.op(&.{0x52});
        try self.push(100);
        try self.push(0);
        try self.op(&.{0xfd});
    }
};

const TestHost = struct {
    const SlotKey = struct { address: [20]u8, slot: u256 };

    balances: std.AutoHashMapUnmanaged(Address, u256) = .{},
    nonces: std.AutoHashMapUnmanaged(Address, u64) = .{},
    code: std.AutoHashMapUnmanaged(Address, []const u8) = .{},
    storage: std.AutoHashMapUnmanaged(SlotKey, u256) = .{},

    fn deinit(self: *TestHost) void {
        var it = self.code.valueIterator();
        while (it.next()) |code| testing.allocator.free(code.*);
        self.code.deinit(testing.allocator);
        self.balances.deinit(testing.allocator);
        self.nonces.deinit(testing.allocator);
        self.storage.deinit(testing.allocator);
    }

    fn outOfMemory() noreturn {
        @panic("test host out of memory");
    }

    fn from(ptr: *anyopaque) *TestHost {
        return @ptrCast(@alignCast(ptr));
    }

    fn getBalance(ptr: *anyopaque, address: Address) u256 {
        return from(ptr).balances.get(address) orelse 0;
    }
    fn setBalance(ptr: *anyopaque, address: Address, balance: u256) void {
        from(ptr).balances.put(testing.allocator, address, balance) catch outOfMemory();
    }
    fn getCode(ptr: *anyopaque, address: Address) []const u8 {
        return from(ptr).code.get(address) orelse &.{};
    }
    fn setCode(ptr: *anyopaque, address: Address, code: []const u8) void {
        const copy = testing.allocator.dupe(u8, code) catch outOfMemory();
        const old = from(ptr).code.fetchPut(testing.allocator, address, copy) catch outOfMemory();
        if (old) |entry| testing.allocator.free(entry.value);
    }
    fn getStorage(ptr: *anyopaque, address: Address, slot: u256) u256 {
        return from(ptr).storage.get(.{ .address = address.bytes, .slot = slot }) orelse 0;
    }
    fn setStorage(ptr: *anyopaque, address: Address, slot: u256, value: u256) void {
        from(ptr).storage.put(testing.allocator, .{ .address = address.bytes, .slot = slot }, value) catch outOfMemory();
    }
    fn getNonce(ptr: *anyopaque, address: Address) u64 {
        return from(ptr).nonces.get(address) orelse 0;
    }
    fn setNonce(ptr: *anyopaque, address: Address, nonce: u64) void {
        from(ptr).nonces.put(testing.allocator, address, nonce) catch outOfMemory();
    }

    const vtable: HostInterface.VTable = .{
        .getBalance = getBalance,
        .setBalance = setBalance,
        .getCode = getCode,
        .setCode = setCode,
        .getStorage = getStorage,
        .setStorage = setStorage,
        .getNonce = getNonce,
        .setNonce = setNonce,
    };

    fn interface(self: *TestHost) HostInterface {
        return .{ .ptr = self, .vtable = &vtable };
    }
};

const Chain = struct {
    host: TestHost,
    evm: Evm,

    fn init(self: *Chain, origin: Address) !void {
        self.host = .{};
        errdefer self.host.deinit();
        try self.evm.init(testing.allocator, self.host.interface(), .CANCUN, null, origin, 0, null);
    }

    fn deinit(self: *Chain) void {
        self.evm.deinit();
        self.host.deinit();
    }

    fn setCode(self: *Chain, address: Address, code: []const u8) void {
        TestHost.setCode(&self.host, address, code);
    }

    fn setBalance(self: *Chain, address: Address, amount: u256) void {
        TestHost.setBalance(&self.host, address, amount);
    }

    fn call(self: *Chain, caller: Address, to: Address, value: u256, input: []const u8, gas: u64, sink: ?insp.Inspector) CallResult {
        if (sink) |s| self.evm.setInspector(s) else self.evm.clearInspector();
        return self.evm.call(.{ .call = .{ .caller = caller, .to = to, .value = value, .input = input, .gas = gas } });
    }
};

fn addr(n: u256) Address {
    return Address.fromU256(n);
}

fn hashFill(tag: u8) [32]u8 {
    return @splat(tag);
}

fn parseJson(text: []const u8) !std.json.Parsed(std.json.Value) {
    return std.json.parseFromSlice(std.json.Value, testing.allocator, text, .{});
}

// ---------------------------------------------------------------------------
// BlockHooks + MuxBlockHooks lifecycle + EVM integration
// ---------------------------------------------------------------------------

test "BlockHooks and MuxBlockHooks dispatch full chain/block/syscall/tx/state lifecycle" {
    const EventTag = enum {
        chain_init,
        genesis,
        block_start,
        sys_start,
        sys_end,
        balance_change,
        state_update,
        block_end,
        skipped,
        close,
    };

    const Recorder = struct {
        events: std.ArrayList(EventTag) = .{},
        tx_enters: usize = 0,
        last_state_accounts: usize = 0,
        last_sys_output_len: usize = 0,
        last_skipped_reason: []const u8 = "",

        fn deinit(self: *@This()) void {
            self.events.deinit(testing.allocator);
        }

        fn push(ptr: *anyopaque, tag: EventTag) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            self.events.append(testing.allocator, tag) catch @panic("oom");
        }

        fn onChainInit(ptr: *anyopaque, _: live.ChainInitEvent) void {
            push(ptr, .chain_init);
        }
        fn onGenesis(ptr: *anyopaque, _: live.GenesisBlockEvent) void {
            push(ptr, .genesis);
        }
        fn onBlockStart(ptr: *anyopaque, _: live.BlockStartEvent) void {
            push(ptr, .block_start);
        }
        fn onBlockEnd(ptr: *anyopaque, _: live.BlockEndEvent) void {
            push(ptr, .block_end);
        }
        fn onSkipped(ptr: *anyopaque, ev: live.SkippedBlockEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            self.last_skipped_reason = ev.reason;
            push(ptr, .skipped);
        }
        fn onSysStart(ptr: *anyopaque, _: live.SystemCallStartEvent) void {
            push(ptr, .sys_start);
        }
        fn onSysEnd(ptr: *anyopaque, ev: live.SystemCallEndEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            self.last_sys_output_len = ev.output.len;
            push(ptr, .sys_end);
        }
        fn onBalChange(ptr: *anyopaque, _: live.BlockBalanceChangeEvent) void {
            push(ptr, .balance_change);
        }
        fn onStateUpdate(ptr: *anyopaque, ev: live.StateUpdateEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            self.last_state_accounts = ev.accounts.len;
            push(ptr, .state_update);
        }
        fn onClose(ptr: *anyopaque) void {
            push(ptr, .close);
        }
        fn onEnter(ptr: *anyopaque, _: insp.FrameEnterEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            self.tx_enters += 1;
        }

        const vtable: BlockHooks.VTable = .{
            .onBlockchainInit = onChainInit,
            .onGenesisBlock = onGenesis,
            .onBlockStart = onBlockStart,
            .onBlockEnd = onBlockEnd,
            .onSkippedBlock = onSkipped,
            .onSystemCallStart = onSysStart,
            .onSystemCallEnd = onSysEnd,
            .onBlockBalanceChange = onBalChange,
            .onStateUpdate = onStateUpdate,
            .onClose = onClose,
        };

        const tx_vtable: insp.Inspector.VTable = .{
            .onEnter = onEnter,
        };

        fn blockHooks(self: *@This()) BlockHooks {
            return .{
                .ptr = self,
                .vtable = &vtable,
                .tx_inspector = .{
                    .ptr = self,
                    .vtable = &tx_vtable,
                    .opcode_mask = insp.OpcodeMask.NONE,
                },
            };
        }
    };

    var rec = Recorder{};
    defer rec.deinit();

    var supply = SupplyTracer.init(testing.allocator, .{});
    defer supply.deinit();

    var call_tracer = CallTracer.init(testing.allocator, .{});
    defer call_tracer.deinit();

    const call_only_vtable: BlockHooks.VTable = .{};
    var dummy_ctx: u8 = 0;
    const call_hook: BlockHooks = .{
        .ptr = &dummy_ctx,
        .vtable = &call_only_vtable,
        .tx_inspector = call_tracer.inspector(),
    };

    const children = [_]BlockHooks{ rec.blockHooks(), supply.blockHooks(), call_hook };
    var mux = MuxBlockHooks.init(&children);
    const hooks = mux.blockHooks();
    try testing.expect(hooks.tx_inspector != null);

    // 1. Chain init & genesis
    hooks.onBlockchainInit(.{
        .chain_id = 1,
        .hardfork = .CANCUN,
        .genesis_hash = hashFill(0x01),
    });
    const genesis_allocs = [_]live.GenesisAllocEntry{
        .{ .address = addr(0x1000), .balance = 1_000_000, .nonce = 0, .code = &.{} },
    };
    hooks.onGenesisBlock(.{
        .block_hash = hashFill(0x01),
        .allocs = &genesis_allocs,
    });

    // 2. Block 1 start + EIP-4788 beacon root system call
    hooks.onBlockStart(.{
        .number = 1,
        .hash = hashFill(0x11),
        .parent_hash = hashFill(0x01),
        .timestamp = 1_700_000_012,
        .coinbase = addr(0xc01b),
        .gas_limit = 30_000_000,
        .base_fee = 10,
        .blob_base_fee = 1,
        .hardfork = .CANCUN,
        .tx_count = 1,
    });
    hooks.onSystemCallStart(.{
        .block_number = 1,
        .caller = addr(0xfffffffffffffffffffffffffffffffffffffffe),
        .target = addr(0x000f3df6d732807ef1319fb7b8bb8522d0beac02),
        .input = &hashFill(0xab),
    });
    hooks.onSystemCallEnd(.{
        .block_number = 1,
        .target = addr(0x000f3df6d732807ef1319fb7b8bb8522d0beac02),
        .output = &.{ 0x01, 0x02 },
        .error_name = null,
    });

    // 3. Real EVM transaction execution observed via `hooks.tx_inspector`
    var target_code: Asm = .{};
    defer target_code.deinit();
    try target_code.sstore(1, 0x42);
    try target_code.returnWord(0x99);

    var chain: Chain = undefined;
    try chain.init(addr(0x1000));
    defer chain.deinit();
    chain.setCode(addr(0x2000), target_code.bytes());
    const tx_res = chain.call(addr(0x1000), addr(0x2000), 0, &.{ 0xde, 0xad }, 200_000, hooks.tx_inspector);
    try testing.expect(tx_res.success);
    try testing.expectEqual(@as(usize, 1), rec.tx_enters);
    try testing.expect(call_tracer.root() != null);
    try testing.expect(call_tracer.root().?.to.equals(addr(0x2000)));
    try testing.expectEqual(@as(usize, 32), call_tracer.root().?.output.len);
    try testing.expectEqual(@as(u8, 0x99), call_tracer.root().?.output[31]);

    // 4. Block balance changes + state update + block end
    hooks.onBlockBalanceChange(.{
        .address = addr(0x1000),
        .prev = 1_000_000,
        .new = 999_500,
        .reason = .fee_burn,
    });
    const updates = [_]live.AccountStateUpdate{
        .{ .address = addr(0x1000), .balance = 999_500, .nonce = 1, .code_hash = null, .deleted = false },
        .{ .address = addr(0x2000), .balance = 0, .nonce = 0, .code_hash = hashFill(0xcc), .deleted = false },
    };
    hooks.onStateUpdate(.{
        .block_number = 1,
        .block_hash = hashFill(0x11),
        .parent_hash = hashFill(0x01),
        .accounts = &updates,
    });
    hooks.onBlockEnd(.{
        .number = 1,
        .hash = hashFill(0x11),
        .gas_used = 50_000,
        .tx_count = 1,
        .error_name = null,
    });

    // 5. Skipped block + close
    hooks.onSkippedBlock(.{
        .number = 2,
        .hash = hashFill(0x22),
        .reason = "known ancestor",
    });
    hooks.onClose();

    const expected = [_]EventTag{
        .chain_init,
        .genesis,
        .block_start,
        .sys_start,
        .sys_end,
        .balance_change,
        .state_update,
        .block_end,
        .skipped,
        .close,
    };
    try testing.expectEqualSlices(EventTag, &expected, rec.events.items);
    try testing.expectEqual(@as(usize, 2), rec.last_state_accounts);
    try testing.expectEqual(@as(usize, 2), rec.last_sys_output_len);
    try testing.expectEqualStrings("known ancestor", rec.last_skipped_reason);

    // SupplyTracer saw genesis + block 1 + skipped block + close
    try testing.expectEqual(@as(u256, 1_000_000), supply.total_issuance);
    try testing.expectEqual(@as(u256, 500), supply.total_burn);
    try testing.expectEqual(@as(u256, 999_500), supply.netSupply());
    try testing.expectEqual(@as(u64, 1), supply.skipped_blocks);
    try testing.expect(supply.closed);
}

test "MuxBlockHooks returns null tx_inspector when no child attaches one" {
    const empty_vtable: BlockHooks.VTable = .{};
    var ctx: u8 = 0;
    const children = [_]BlockHooks{
        .{ .ptr = &ctx, .vtable = &empty_vtable, .tx_inspector = null },
    };
    var mux = MuxBlockHooks.init(&children);
    try testing.expect(mux.blockHooks().tx_inspector == null);
}

// ---------------------------------------------------------------------------
// SupplyTracer
// ---------------------------------------------------------------------------

test "SupplyTracer tracks genesis, rewards, withdrawals, EIP-1559/blob burns, signed deltas and valid NDJSON/summary JSON" {
    var supply = SupplyTracer.init(testing.allocator, .{});
    defer supply.deinit();
    const hooks = supply.blockHooks();

    hooks.onBlockchainInit(.{
        .chain_id = 1,
        .hardfork = .CANCUN,
        .genesis_hash = hashFill(0xaa),
    });

    // Genesis: 2 accounts totaling 10_000 wei
    const allocs = [_]live.GenesisAllocEntry{
        .{ .address = addr(0x01), .balance = 6_000, .nonce = 0, .code = &.{} },
        .{ .address = addr(0x02), .balance = 4_000, .nonce = 1, .code = &.{0x00} },
    };
    hooks.onGenesisBlock(.{
        .block_hash = hashFill(0xaa),
        .allocs = &allocs,
    });
    try testing.expectEqual(@as(u256, 10_000), supply.netSupply());
    try testing.expectEqual(@as(usize, 1), supply.records.items.len);

    // Block 1 (net inflationary): +500 withdrawal, +200 block reward, +50 uncle reward, -100 base fee burn => +650 delta
    hooks.onBlockStart(.{
        .number = 1,
        .hash = hashFill(0x01),
        .parent_hash = hashFill(0xaa),
        .timestamp = 100,
        .coinbase = addr(0xc0),
        .gas_limit = 30_000_000,
        .base_fee = 10,
        .blob_base_fee = 0,
        .hardfork = .CANCUN,
        .tx_count = 2,
    });
    hooks.onBlockBalanceChange(.{ .address = addr(0x10), .prev = 0, .new = 500, .reason = .withdrawal });
    hooks.onBlockBalanceChange(.{ .address = addr(0xc0), .prev = 0, .new = 200, .reason = .block_reward });
    hooks.onBlockBalanceChange(.{ .address = addr(0xc1), .prev = 0, .new = 50, .reason = .uncle_reward });
    hooks.onBlockBalanceChange(.{ .address = addr(0x01), .prev = 6_000, .new = 5_900, .reason = .fee_burn });
    // Transfers and tx_fee are neutral to total supply
    hooks.onBlockBalanceChange(.{ .address = addr(0x01), .prev = 5_900, .new = 5_800, .reason = .transfer });
    hooks.onBlockBalanceChange(.{ .address = addr(0x02), .prev = 4_000, .new = 4_100, .reason = .transfer });
    hooks.onBlockEnd(.{
        .number = 1,
        .hash = hashFill(0x01),
        .gas_used = 21_000,
        .tx_count = 2,
        .error_name = null,
    });

    const b1 = supply.latestRecord().?;
    try testing.expectEqual(@as(u256, 750), b1.issuance.total());
    try testing.expectEqual(@as(u256, 100), b1.burn.total());
    try testing.expect(!b1.delta.negative);
    try testing.expectEqual(@as(u256, 650), b1.delta.magnitude);
    try testing.expectEqual(@as(u256, 10_650), supply.netSupply());

    // Block 2 (net deflationary): +100 withdrawal, -300 eip1559 burn, -262_144 blob burn (2 blobs @ blob_base_fee=1), -50 misc burn
    // Net block delta = 100 - (300 + 262_144 + 50) = -262_394
    hooks.onBlockStart(.{
        .number = 2,
        .hash = hashFill(0x02),
        .parent_hash = hashFill(0x01),
        .timestamp = 112,
        .coinbase = addr(0xc0),
        .gas_limit = 30_000_000,
        .base_fee = 15,
        .blob_base_fee = 1,
        .hardfork = .CANCUN,
        .tx_count = 1,
    });
    hooks.onBlockBalanceChange(.{ .address = addr(0x10), .prev = 500, .new = 600, .reason = .withdrawal });
    hooks.onBlockBalanceChange(.{ .address = addr(0x01), .prev = 5_800, .new = 5_500, .reason = .fee_burn });
    hooks.tx_inspector.?.onTxStart(.{
        .hardfork = .CANCUN,
        .origin = addr(0x01),
        .target = addr(0x02),
        .coinbase = addr(0xc0),
        .is_create = false,
        .value = 0,
        .gas_limit = 50_000,
        .gas_price = 20,
        .input = &.{},
        .block_number = 2,
        .block_timestamp = 112,
        .chain_id = 1,
        .blob_base_fee = 1,
        .blob_hash_count = 2,
    });
    supply.recordMiscBurn(50);
    hooks.onBlockEnd(.{
        .number = 2,
        .hash = hashFill(0x02),
        .gas_used = 21_000,
        .tx_count = 1,
        .error_name = null,
    });

    const b2 = supply.latestRecord().?;
    try testing.expectEqual(@as(u256, 100), b2.issuance.withdrawal);
    try testing.expectEqual(@as(u256, 300), b2.burn.eip1559);
    try testing.expectEqual(@as(u256, 262_144), b2.burn.blob);
    try testing.expectEqual(@as(u256, 50), b2.burn.misc);
    try testing.expect(b2.delta.negative);
    try testing.expectEqual(@as(u256, 262_394), b2.delta.magnitude);

    // Cumulative: issued = 10_000 + 750 + 100 = 10_850, burned = 100 + 262_494 = 262_594 => signed delta = -251_744
    try testing.expectEqual(@as(u256, 10_850), supply.total_issuance);
    try testing.expectEqual(@as(u256, 262_594), supply.total_burn);
    try testing.expect(supply.netSupplySigned().negative);
    try testing.expectEqual(@as(u256, 251_744), supply.netSupplySigned().magnitude);
    try testing.expectEqual(@as(u256, 0), supply.netSupply());

    // Failed block must NOT alter cumulative totals
    hooks.onBlockStart(.{
        .number = 3,
        .hash = hashFill(0x03),
        .parent_hash = hashFill(0x02),
        .timestamp = 124,
        .coinbase = addr(0xc0),
        .gas_limit = 30_000_000,
        .base_fee = 15,
        .blob_base_fee = 1,
        .hardfork = .CANCUN,
        .tx_count = 1,
    });
    hooks.onBlockBalanceChange(.{ .address = addr(0x10), .prev = 0, .new = 999_999, .reason = .withdrawal });
    hooks.onBlockEnd(.{
        .number = 3,
        .hash = hashFill(0x03),
        .gas_used = 0,
        .tx_count = 0,
        .error_name = "invalid block",
    });
    try testing.expectEqual(@as(u64, 1), supply.failed_blocks);
    try testing.expectEqual(@as(usize, 3), supply.records.items.len);
    try testing.expectEqual(@as(u256, 10_850), supply.total_issuance);

    hooks.onClose();

    // Verify NDJSON output (3 lines: genesis + block 1 + block 2)
    var ndjson_aw: std.Io.Writer.Allocating = .init(testing.allocator);
    defer ndjson_aw.deinit();
    try supply.writeJsonlRecord(&ndjson_aw.writer);
    const ndjson = try ndjson_aw.toOwnedSlice();
    defer testing.allocator.free(ndjson);

    var line_it = std.mem.splitScalar(u8, ndjson, '\n');
    var line_count: usize = 0;
    while (line_it.next()) |line| {
        if (line.len == 0) continue;
        const parsed = try parseJson(line);
        defer parsed.deinit();
        const obj = parsed.value.object;
        switch (line_count) {
            0 => {
                try testing.expectEqual(@as(i64, 0), obj.get("blockNumber").?.integer);
                try testing.expectEqualStrings("0x2710", obj.get("issuance").?.object.get("genesis").?.string);
                try testing.expectEqualStrings("0x2710", obj.get("delta").?.string);
                try testing.expectEqualStrings("0x2710", obj.get("cumulativeSupply").?.string);
            },
            1 => {
                try testing.expectEqual(@as(i64, 1), obj.get("blockNumber").?.integer);
                try testing.expectEqualStrings("0x28a", obj.get("delta").?.string); // +650
                try testing.expectEqualStrings("0x299a", obj.get("cumulativeSupply").?.string); // 10_650
            },
            2 => {
                try testing.expectEqual(@as(i64, 2), obj.get("blockNumber").?.integer);
                try testing.expectEqualStrings("-0x400fa", obj.get("delta").?.string); // -262_394
                try testing.expectEqualStrings("-0x3d760", obj.get("cumulativeSupply").?.string); // -251_744
                try testing.expectEqualStrings("0x40000", obj.get("burn").?.object.get("blob").?.string);
            },
            else => unreachable,
        }
        line_count += 1;
    }
    try testing.expectEqual(@as(usize, 3), line_count);

    // Verify summary JSON
    var summary_aw: std.Io.Writer.Allocating = .init(testing.allocator);
    defer summary_aw.deinit();
    try supply.writeSummaryJson(&summary_aw.writer);
    const summary = try summary_aw.toOwnedSlice();
    defer testing.allocator.free(summary);

    const parsed_summary = try parseJson(summary);
    defer parsed_summary.deinit();
    const s = parsed_summary.value.object;
    try testing.expectEqualStrings("0x1", s.get("chainId").?.string);
    try testing.expectEqual(@as(i64, 3), s.get("blocksProcessed").?.integer);
    try testing.expectEqual(@as(i64, 0), s.get("skippedBlocks").?.integer);
    try testing.expectEqual(@as(i64, 1), s.get("failedBlocks").?.integer);
    try testing.expect(s.get("closed").?.bool);
    try testing.expectEqualStrings("0x2a62", s.get("totalIssuance").?.string); // 10_850
    try testing.expectEqualStrings("0x401c2", s.get("totalBurn").?.string); // 262_594
    try testing.expectEqualStrings("0x0", s.get("netSupply").?.string);
    try testing.expectEqualStrings("-0x3d760", s.get("netDelta").?.string);
}

test "SupplyTracer infer_eip1559_burn calculates base_fee * gas_used without double counting" {
    var supply = SupplyTracer.init(testing.allocator, .{ .infer_eip1559_burn = true });
    defer supply.deinit();
    const hooks = supply.blockHooks();

    // Block 1: no explicit fee_burn -> inferred 21_000 * 10 = 210_000
    hooks.onBlockStart(.{
        .number = 1,
        .hash = hashFill(0x11),
        .parent_hash = hashFill(0x00),
        .timestamp = 1,
        .coinbase = addr(0xc0),
        .gas_limit = 30_000_000,
        .base_fee = 10,
        .blob_base_fee = 0,
        .hardfork = .CANCUN,
        .tx_count = 1,
    });
    hooks.onBlockEnd(.{
        .number = 1,
        .hash = hashFill(0x11),
        .gas_used = 21_000,
        .tx_count = 1,
        .error_name = null,
    });
    try testing.expectEqual(@as(u256, 210_000), supply.total_burn_breakdown.eip1559);

    // Block 2: explicit fee_burn = 500 -> does NOT also add gas_used * base_fee
    hooks.onBlockStart(.{
        .number = 2,
        .hash = hashFill(0x22),
        .parent_hash = hashFill(0x11),
        .timestamp = 13,
        .coinbase = addr(0xc0),
        .gas_limit = 30_000_000,
        .base_fee = 10,
        .blob_base_fee = 0,
        .hardfork = .CANCUN,
        .tx_count = 1,
    });
    hooks.onBlockBalanceChange(.{ .address = addr(0x01), .prev = 1_000, .new = 500, .reason = .fee_burn });
    hooks.onBlockEnd(.{
        .number = 2,
        .hash = hashFill(0x22),
        .gas_used = 21_000,
        .tx_count = 1,
        .error_name = null,
    });
    try testing.expectEqual(@as(u256, 210_500), supply.total_burn_breakdown.eip1559);
}

// ---------------------------------------------------------------------------
// TraceStore & Indexed trace_filter
// ---------------------------------------------------------------------------

const ORIGIN_A: u256 = 0x1001;
const ORIGIN_B: u256 = 0x1002;
const ROUTER: u256 = 0x2001;
const WORKER: u256 = 0x3001;
const REVERTER: u256 = 0x4001;
const DESTRUCT_CONTRACT: u256 = 0x5001;
const BENEFICIARY: u256 = 0x5002;
const IDENTITY_PRECOMPILE: u256 = 0x04;

/// Runs a rich EVM transaction that calls WORKER, REVERTER (with Error("denied")),
/// IDENTITY precompile (omitted from flat trace), and CREATEs a 1-byte contract.
fn runComplexTx(
    origin: u256,
    router_nonce: u64,
    store: *TraceStore,
    block_number: u64,
    block_hash: [32]u8,
    tx_hash: [32]u8,
    tx_index: u32,
) !Address {
    var router_code: Asm = .{};
    defer router_code.deinit();
    try router_code.mstoreLeft(0, 0x11223344, 4);
    try router_code.call(WORKER, 7, 0, 4, 0, 32);
    try router_code.mstoreLeft(0, 0xdeadbeef, 4);
    try router_code.call(REVERTER, 0, 0, 4, 0, 0);
    // Call precompile 0x04 (should be omitted in flat trace)
    try router_code.call(IDENTITY_PRECOMPILE, 0, 0, 4, 64, 4);
    // CREATE a 1-byte contract (0x00)
    const init_code: u256 = 0x60005f5360015ff3;
    try router_code.mstoreLeft(0, init_code, 8);
    try router_code.push(8);
    try router_code.push(0);
    try router_code.push(0);
    try router_code.op(&.{ 0xf0, 0x50, 0x00 });

    var worker_code: Asm = .{};
    defer worker_code.deinit();
    try worker_code.returnWord(0xabcd);

    var reverter_code: Asm = .{};
    defer reverter_code.deinit();
    try reverter_code.revertError("denied");

    var tracer = CallTracer.init(testing.allocator, .{});
    defer tracer.deinit();

    var chain: Chain = undefined;
    try chain.init(addr(origin));
    defer chain.deinit();
    chain.setCode(addr(ROUTER), router_code.bytes());
    chain.setCode(addr(WORKER), worker_code.bytes());
    chain.setCode(addr(REVERTER), reverter_code.bytes());
    chain.setBalance(addr(ROUTER), 1_000);
    TestHost.setNonce(&chain.host, addr(ROUTER), router_nonce);

    const res = chain.call(addr(origin), addr(ROUTER), 0, &.{ 0xca, 0xfe }, 1_000_000, tracer.inspector());
    try testing.expect(res.success);
    const created_addr = tracer.root().?.calls.items[3].created_address.?;

    try store.recordCallTrace(block_number, block_hash, tx_hash, tx_index, &tracer);
    return created_addr;
}

fn runSelfDestructTx(
    store: *TraceStore,
    block_number: u64,
    block_hash: [32]u8,
    tx_hash: [32]u8,
    tx_index: u32,
) !void {
    var tracer = CallTracer.init(testing.allocator, .{});
    defer tracer.deinit();

    var chain: Chain = undefined;
    try chain.init(addr(ORIGIN_B));
    defer chain.deinit();
    chain.setBalance(addr(DESTRUCT_CONTRACT), 42);
    chain.setCode(addr(DESTRUCT_CONTRACT), &.{ 0x61, 0x50, 0x02, 0xff }); // PUSH2 0x5002 SELFDESTRUCT

    const res = chain.call(addr(ORIGIN_B), addr(DESTRUCT_CONTRACT), 0, &.{}, 100_000, tracer.inspector());
    try testing.expect(res.success);

    try store.recordCallTrace(block_number, block_hash, tx_hash, tx_index, &tracer);
}

test "TraceStore indexes real CallTracer executions and serves trace_filter with Parity JSON" {
    var store = TraceStore.init(testing.allocator, .{});
    defer store.deinit();

    // Insert block 10 (tx 0 = complex, tx 1 = selfdestruct) and block 11 (tx 0 = complex from ORIGIN_B)
    const created_b10 = try runComplexTx(ORIGIN_A, 1, &store, 10, hashFill(0x10), hashFill(0xa0), 0);
    try runSelfDestructTx(&store, 10, hashFill(0x10), hashFill(0xa1), 1);
    const created_b11 = try runComplexTx(ORIGIN_B, 2, &store, 11, hashFill(0x11), hashFill(0xb0), 0);
    try testing.expect(!created_b10.equals(created_b11));

    // Complex tx has 4 flat entries (root, worker, reverter, create; identity precompile omitted).
    // Selfdestruct tx has 2 flat entries (root call + suicide child).
    // Total = 4 + 2 + 4 = 10 entries across 2 blocks.
    try testing.expectEqual(@as(usize, 10), store.entryCount());
    try testing.expectEqual(@as(usize, 2), store.blockCount());

    // 1. Unfiltered query: deterministic (block_number, tx_index, trace_address) ordering
    const all = try store.filter(testing.allocator, .{});
    defer testing.allocator.free(all);
    try testing.expectEqual(@as(usize, 10), all.len);
    try testing.expectEqual(@as(u64, 10), all[0].block_number);
    try testing.expectEqual(@as(u32, 0), all[0].tx_index);
    try testing.expectEqual(@as(usize, 0), all[0].trace_address.len);
    try testing.expectEqual(@as(usize, 3), all[0].subtraces);
    // Child 0: WORKER
    try testing.expectEqualSlices(usize, &.{0}, all[1].trace_address);
    try testing.expect(all[1].to.?.equals(addr(WORKER)));
    // Child 1: REVERTER
    try testing.expectEqualSlices(usize, &.{1}, all[2].trace_address);
    try testing.expect(all[2].reverted);
    try testing.expectEqualStrings("denied", all[2].revert_reason.?);
    // Child 2: CREATE (index 2 because precompile was skipped)
    try testing.expectEqualSlices(usize, &.{2}, all[3].trace_address);
    try testing.expectEqual(insp.CallType.create, all[3].call_type);
    try testing.expect(all[3].to.?.equals(created_b10));
    // Block 10 tx 1: selfdestruct root + suicide child
    try testing.expectEqual(@as(u32, 1), all[4].tx_index);
    try testing.expectEqual(insp.CallType.selfdestruct, all[5].call_type);
    try testing.expect(all[5].from.equals(addr(DESTRUCT_CONTRACT)));
    try testing.expect(all[5].to.?.equals(addr(BENEFICIARY)));
    // Block 11 tx 0
    try testing.expectEqual(@as(u64, 11), all[6].block_number);
    try testing.expect(all[9].to.?.equals(created_b11));

    // 2. Block range filter
    const only_b11 = try store.filter(testing.allocator, .{ .from_block = 11, .to_block = 11 });
    defer testing.allocator.free(only_b11);
    try testing.expectEqual(@as(usize, 4), only_b11.len);
    for (only_b11) |e| try testing.expectEqual(@as(u64, 11), e.block_number);

    // Inverted range returns empty
    const empty_range = try store.filter(testing.allocator, .{ .from_block = 12, .to_block = 10 });
    defer testing.allocator.free(empty_range);
    try testing.expectEqual(@as(usize, 0), empty_range.len);

    // 3. from_address filter (including duplicate address in query slice)
    const from_origin_a = try store.filter(testing.allocator, .{
        .from_address = &.{ addr(ORIGIN_A), addr(ORIGIN_A) },
    });
    defer testing.allocator.free(from_origin_a);
    try testing.expectEqual(@as(usize, 1), from_origin_a.len);
    try testing.expect(from_origin_a[0].from.equals(addr(ORIGIN_A)));

    // 4. to_address filter (created contract + selfdestruct beneficiary)
    const to_created_or_beneficiary = try store.filter(testing.allocator, .{
        .to_address = &.{ created_b10, addr(BENEFICIARY) },
    });
    defer testing.allocator.free(to_created_or_beneficiary);
    try testing.expectEqual(@as(usize, 2), to_created_or_beneficiary.len);
    try testing.expectEqual(insp.CallType.create, to_created_or_beneficiary[0].call_type);
    try testing.expectEqual(insp.CallType.selfdestruct, to_created_or_beneficiary[1].call_type);

    // 5. Combined from_address + to_address + block range intersection
    const router_to_worker_b10 = try store.filter(testing.allocator, .{
        .from_block = 10,
        .to_block = 10,
        .from_address = &.{addr(ROUTER)},
        .to_address = &.{addr(WORKER)},
    });
    defer testing.allocator.free(router_to_worker_b10);
    try testing.expectEqual(@as(usize, 1), router_to_worker_b10.len);
    try testing.expectEqual(@as(u64, 10), router_to_worker_b10[0].block_number);
    try testing.expectEqual(@as(u256, 7), router_to_worker_b10[0].value);

    // 6. Pagination with `after` and `count`
    const page1 = try store.filter(testing.allocator, .{ .after = 2, .count = 3 });
    defer testing.allocator.free(page1);
    try testing.expectEqual(@as(usize, 3), page1.len);
    try testing.expectEqual(all[2], page1[0]);
    try testing.expectEqual(all[3], page1[1]);
    try testing.expectEqual(all[4], page1[2]);

    const past_end = try store.filter(testing.allocator, .{ .after = 100, .count = 5 });
    defer testing.allocator.free(past_end);
    try testing.expectEqual(@as(usize, 0), past_end.len);

    // 7. Parity `trace_filter` JSON validation
    var json_aw: std.Io.Writer.Allocating = .init(testing.allocator);
    defer json_aw.deinit();
    try TraceStore.writeFilterJson(&json_aw.writer, all);
    const json_text = try json_aw.toOwnedSlice();
    defer testing.allocator.free(json_text);

    const parsed = try parseJson(json_text);
    defer parsed.deinit();
    const arr = parsed.value.array.items;
    try testing.expectEqual(@as(usize, 10), arr.len);

    // Entry 0: CALL
    const j0 = arr[0].object;
    try testing.expectEqualStrings("call", j0.get("type").?.string);
    try testing.expectEqual(@as(i64, 10), j0.get("blockNumber").?.integer);
    try testing.expectEqual(@as(i64, 0), j0.get("transactionPosition").?.integer);
    try testing.expectEqual(@as(i64, 3), j0.get("subtraces").?.integer);
    try testing.expectEqualStrings("call", j0.get("action").?.object.get("callType").?.string);
    try testing.expect(j0.get("result") != null);

    // Entry 2: REVERTER -> Parity error "Reverted", no result
    const j2 = arr[2].object;
    try testing.expectEqualStrings("Reverted", j2.get("error").?.string);
    try testing.expect(j2.get("result") == null);

    // Entry 3: CREATE -> type "create", result.code "0x00"
    const j3 = arr[3].object;
    try testing.expectEqualStrings("create", j3.get("type").?.string);
    try testing.expectEqualStrings("create", j3.get("action").?.object.get("creationMethod").?.string);
    try testing.expectEqualStrings("0x00", j3.get("result").?.object.get("code").?.string);

    // Entry 5: SELFDESTRUCT -> type "suicide", result null
    const j5 = arr[5].object;
    try testing.expectEqualStrings("suicide", j5.get("type").?.string);
    try testing.expect(j5.get("result").? == .null);
    try testing.expectEqualStrings("0x2a", j5.get("action").?.object.get("balance").?.string);
}

test "TraceStore enforces max_blocks and max_entries eviction cleanly with zero index leaks" {
    // Part A: max_blocks = 2
    {
        var store = TraceStore.init(testing.allocator, .{ .max_blocks = 2, .max_entries = 1024 });
        defer store.deinit();

        _ = try runComplexTx(ORIGIN_A, 1, &store, 1, hashFill(0x01), hashFill(0x11), 0);
        _ = try runComplexTx(ORIGIN_B, 2, &store, 2, hashFill(0x02), hashFill(0x22), 0);
        _ = try runComplexTx(ORIGIN_B, 3, &store, 3, hashFill(0x03), hashFill(0x33), 0);

        try testing.expectEqual(@as(usize, 2), store.blockCount());
        try testing.expect(!store.hasBlock(1));
        try testing.expect(store.hasBlock(2));
        try testing.expect(store.hasBlock(3));

        // ORIGIN_A only existed in evicted block 1: must return 0 matches and no stale index bucket
        const evicted_matches = try store.filter(testing.allocator, .{ .from_address = &.{addr(ORIGIN_A)} });
        defer testing.allocator.free(evicted_matches);
        try testing.expectEqual(@as(usize, 0), evicted_matches.len);
        try testing.expect(!store.from_index.contains(addr(ORIGIN_A)));
    }

    // Part B: max_entries = 5 (each complex tx produces 4 entries, so adding block 2 evicts block 1)
    {
        var store = TraceStore.init(testing.allocator, .{ .max_blocks = 16, .max_entries = 5 });
        defer store.deinit();

        _ = try runComplexTx(ORIGIN_A, 1, &store, 1, hashFill(0x01), hashFill(0x11), 0);
        try testing.expectEqual(@as(usize, 4), store.entryCount());

        _ = try runComplexTx(ORIGIN_B, 2, &store, 2, hashFill(0x02), hashFill(0x22), 0);
        try testing.expect(store.entryCount() <= 5);
        try testing.expect(!store.hasBlock(1));
        try testing.expect(store.hasBlock(2));
    }

    // Part C: single block exceeding max_entries evicts oldest entries within that block
    {
        var store = TraceStore.init(testing.allocator, .{ .max_blocks = 16, .max_entries = 2 });
        defer store.deinit();

        _ = try runComplexTx(ORIGIN_A, 1, &store, 1, hashFill(0x01), hashFill(0x11), 0);
        try testing.expectEqual(@as(usize, 2), store.entryCount());
        try testing.expectEqual(@as(usize, 1), store.blockCount());
    }
}

test "TraceStore rollbackReorg prunes blocks above new head and updates all secondary indexes" {
    var store = TraceStore.init(testing.allocator, .{});
    defer store.deinit();

    _ = try runComplexTx(ORIGIN_A, 1, &store, 100, hashFill(0x01), hashFill(0x10), 0);
    _ = try runComplexTx(ORIGIN_A, 2, &store, 101, hashFill(0x02), hashFill(0x11), 0);
    try runSelfDestructTx(&store, 102, hashFill(0x03), hashFill(0x12), 0);
    _ = try runComplexTx(ORIGIN_B, 3, &store, 103, hashFill(0x04), hashFill(0x13), 0);

    try testing.expectEqual(@as(usize, 4), store.blockCount());
    try testing.expectEqual(@as(usize, 14), store.entryCount());

    // Reorg back to block 101: blocks 102 and 103 must be pruned completely
    store.rollbackReorg(101);
    try testing.expectEqual(@as(usize, 2), store.blockCount());
    try testing.expectEqual(@as(usize, 8), store.entryCount());
    try testing.expect(store.hasBlock(100));
    try testing.expect(store.hasBlock(101));
    try testing.expect(!store.hasBlock(102));
    try testing.expect(!store.hasBlock(103));

    // Pruned addresses from blocks 102/103 must no longer appear in secondary indexes
    const pruned_beneficiary = try store.filter(testing.allocator, .{ .to_address = &.{addr(BENEFICIARY)} });
    defer testing.allocator.free(pruned_beneficiary);
    try testing.expectEqual(@as(usize, 0), pruned_beneficiary.len);

    const pruned_origin_b = try store.filter(testing.allocator, .{ .from_address = &.{addr(ORIGIN_B)} });
    defer testing.allocator.free(pruned_origin_b);
    try testing.expectEqual(@as(usize, 0), pruned_origin_b.len);

    // Record new canonical block 102 after reorg
    try runSelfDestructTx(&store, 102, hashFill(0x99), hashFill(0x88), 0);
    try testing.expectEqual(@as(usize, 3), store.blockCount());
    const canonical = try store.filter(testing.allocator, .{
        .from_block = 102,
        .to_block = 102,
        .to_address = &.{addr(BENEFICIARY)},
    });
    defer testing.allocator.free(canonical);
    try testing.expectEqual(@as(usize, 1), canonical.len);
    try testing.expectEqualSlices(u8, &hashFill(0x99), &canonical[0].block_hash);
}

test "TraceStore keep_reverted=false omits reverted frames" {
    var store = TraceStore.init(testing.allocator, .{ .keep_reverted = false });
    defer store.deinit();

    _ = try runComplexTx(ORIGIN_A, 1, &store, 5, hashFill(0x05), hashFill(0x55), 0);
    // Complex tx has 4 flat frames, 1 of which (REVERTER) reverted => 3 kept.
    try testing.expectEqual(@as(usize, 3), store.entryCount());

    const to_reverter = try store.filter(testing.allocator, .{ .to_address = &.{addr(REVERTER)} });
    defer testing.allocator.free(to_reverter);
    try testing.expectEqual(@as(usize, 0), to_reverter.len);
}

test "TraceStore handles failed CREATE (to == null) and out-of-order block insertion" {
    var store = TraceStore.init(testing.allocator, .{});
    defer store.deinit();

    // Record block 20 BEFORE block 10 to verify deterministic sorting
    try runSelfDestructTx(&store, 20, hashFill(0x20), hashFill(0xf0), 1);

    // Contract that attempts a reverting CREATE (initcode executes PUSH0 PUSH0 REVERT)
    var factory: Asm = .{};
    defer factory.deinit();
    try factory.mstoreLeft(0, 0x5f5ffd, 3); // PUSH0 PUSH0 REVERT
    try factory.push(3);
    try factory.push(0);
    try factory.push(0);
    try factory.op(&.{ 0xf0, 0x50, 0x00 });

    var tracer = CallTracer.init(testing.allocator, .{});
    defer tracer.deinit();

    var chain: Chain = undefined;
    try chain.init(addr(ORIGIN_A));
    defer chain.deinit();
    chain.setCode(addr(ROUTER), factory.bytes());
    const res = chain.call(addr(ORIGIN_A), addr(ROUTER), 0, &.{}, 200_000, tracer.inspector());
    try testing.expect(res.success);

    try store.recordCallTrace(10, hashFill(0x10), hashFill(0xe0), 0, &tracer);

    const all = try store.filter(testing.allocator, .{});
    defer testing.allocator.free(all);
    try testing.expectEqual(@as(usize, 4), all.len);
    // Block 10 entries come before block 20 entries despite reverse insertion order
    try testing.expectEqual(@as(u64, 10), all[0].block_number);
    try testing.expectEqual(@as(u64, 10), all[1].block_number);
    try testing.expectEqual(insp.CallType.create, all[1].call_type);
    try testing.expect(all[1].reverted);
    try testing.expect(all[1].to == null);
    try testing.expectEqual(@as(u64, 20), all[2].block_number);

    // Failed CREATE must serialize with Parity error and valid JSON
    var aw: std.Io.Writer.Allocating = .init(testing.allocator);
    defer aw.deinit();
    try store_mod.writeFilterJson(&aw.writer, all[1..2]);
    const text = try aw.toOwnedSlice();
    defer testing.allocator.free(text);
    const parsed = try parseJson(text);
    defer parsed.deinit();
    const create_obj = parsed.value.array.items[0].object;
    try testing.expectEqualStrings("create", create_obj.get("type").?.string);
    try testing.expectEqualStrings("Reverted", create_obj.get("error").?.string);
    try testing.expect(create_obj.get("result") == null);
}

test "refAllDecls compiles all live_tracer and trace_store declarations" {
    testing.refAllDecls(live);
    testing.refAllDecls(store_mod);
    const zero_pos: SignedU256 = .{ .negative = false, .magnitude = 0 };
    const zero_neg: SignedU256 = .{ .negative = true, .magnitude = 0 };
    try testing.expect(zero_pos.isZero());
    try testing.expect(zero_pos.eql(zero_neg));
}
