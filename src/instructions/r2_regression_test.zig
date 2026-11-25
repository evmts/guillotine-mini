//! Round 2 review regressions for opcode halts and frame tracing
//! (R2-04, R2-11, R2-12, R2-16, R2-043, R2-054, F-38), and Round 3 miss-aware
//! account reads in async opcodes (R3-007, A-1, R3-03).
const std = @import("std");
const testing = std.testing;
const primitives = @import("voltaire");
const GasConstants = primitives.GasConstants;
const Hardfork = primitives.Hardfork;
const Address = primitives.Address.Address;
const evm_mod = @import("../evm.zig");
const trace = @import("../trace.zig");
const Evm = evm_mod.Evm(.{});
const Frame = @import("../frame.zig").Frame(.{});
const System = @import("handlers_system.zig").Handlers(Frame);
const Storage = @import("handlers_storage.zig").Handlers(Frame);
const Memory = @import("handlers_memory.zig").Handlers(Frame);
const Log = @import("handlers_log.zig").Handlers(Frame);
const Context = @import("handlers_context.zig").Handlers(Frame);
const StorageInjector = @import("../storage_injector.zig").StorageInjector;

const Harness = struct {
    evm: *Evm,
    allocator: std.mem.Allocator,

    fn init(allocator: std.mem.Allocator, hardfork: Hardfork) !Harness {
        const evm = try allocator.create(Evm);
        errdefer allocator.destroy(evm);
        try evm.init(allocator, null, hardfork, null, primitives.ZERO_ADDRESS, 0, null);
        errdefer evm.deinit();
        try evm.initTransactionState(null);
        return .{ .evm = evm, .allocator = allocator };
    }

    /// Register a frame on the EVM frame stack (as `Evm.call` does) and return it.
    fn frame(self: *Harness, code: []const u8, gas: i64) !*Frame {
        try self.evm.frames.append(self.evm.tx_arena.allocator(), try Frame.init(
            self.allocator,
            code,
            gas,
            try Address.fromHex("0x1111111111111111111111111111111111111111"),
            try Address.fromHex("0x2222222222222222222222222222222222222222"),
            0,
            &.{},
            @ptrCast(self.evm),
            self.evm.hardfork,
            false,
        ));
        return self.evm.getCurrentFrame().?;
    }

    fn deinit(self: *Harness) void {
        for (self.evm.frames.items) |*f| f.deinit();
        self.evm.deinit();
        self.allocator.destroy(self.evm);
    }
};

/// Push operands so the handler pops them in the listed order.
fn pushOperands(f: *Frame, operands: []const u256) !void {
    var i = operands.len;
    while (i > 0) {
        i -= 1;
        try f.pushStack(operands[i]);
    }
}

test "R2-04 SELFDESTRUCT touches an existing empty beneficiary on a 0-wei transfer" {
    var h = try Harness.init(testing.allocator, .SPURIOUS_DRAGON);
    defer h.deinit();
    const beneficiary = try Address.fromHex("0x0000000000000000000000000000000000009999");
    try h.evm.balances.put(beneficiary, 0);
    const f = try h.frame(&.{}, 100_000);
    try f.pushStack(0x9999);
    try System.selfdestruct(f);
    try testing.expect(h.evm.touched_accounts.contains(beneficiary));
    try testing.expectEqual(beneficiary, h.evm.touched_journal.items[h.evm.touched_journal.items.len - 1]);
}

test "R2-11 SSTORE sentry halt burns all gas" {
    var h = try Harness.init(testing.allocator, .ISTANBUL);
    defer h.deinit();
    const f = try h.frame(&.{}, GasConstants.SstoreSentryGas);
    try pushOperands(f, &.{ 1, 1 });
    try testing.expectError(error.OutOfGas, Storage.sstore(f));
    try testing.expectEqual(@as(i64, 0), f.gas_remaining);
}

test "R2-043 SSTORE with a short stack is StackUnderflow even below the sentry" {
    var h = try Harness.init(testing.allocator, .CANCUN);
    defer h.deinit();
    const f = try h.frame(&.{}, 100);
    try f.pushStack(1);
    try testing.expectError(error.StackUnderflow, Storage.sstore(f));
}

test "R2-11 CREATE and CREATE2 reject oversize initcode before expanding memory" {
    inline for (.{ false, true }) |is_create2| {
        var h = try Harness.init(testing.allocator, .SHANGHAI);
        defer h.deinit();
        const f = try h.frame(&.{}, 30_000_000);
        if (is_create2) try f.pushStack(0); // salt
        try pushOperands(f, &.{ 0, 0, GasConstants.MaxInitcodeSize + 1 });
        const result = if (is_create2) System.create2(f) else System.create(f);
        try testing.expectError(error.OutOfGas, result);
        try testing.expectEqual(@as(i64, 0), f.gas_remaining);
        try testing.expectEqual(@as(u32, 0), f.memory_size);
    }
}

test "R2-11 LOG4 with two stack items is StackUnderflow, not OutOfGas" {
    var h = try Harness.init(testing.allocator, .CANCUN);
    defer h.deinit();
    const f = try h.frame(&.{}, 1_000);
    try pushOperands(f, &.{ 0, 1 << 32 });
    try testing.expectError(error.StackUnderflow, Log.log(f, 0xa4));
}

test "R2-11 LOG data and topics live in the transaction arena" {
    var h = try Harness.init(testing.allocator, .CANCUN);
    defer h.deinit();
    const f = try h.frame(&.{}, 10_000);
    try pushOperands(f, &.{ 0, 32, 0xaa, 0xbb });
    try Log.log(f, 0xa2);
    try testing.expectEqual(@as(usize, 1), h.evm.logs.items.len);
    const lg = h.evm.logs.items[0];
    try testing.expectEqualSlices(u256, &.{ 0xaa, 0xbb }, lg.topics);
    try testing.expectEqual(@as(usize, 32), lg.data.len);
}

test "R2-12 MLOAD, MSTORE and MSTORE8 past the u32 memory model halt with OutOfGas" {
    const offsets = [_]u256{ std.math.maxInt(u32), std.math.maxInt(u32) - 16, 1 << 40 };
    for (offsets) |offset| {
        var h = try Harness.init(testing.allocator, .CANCUN);
        defer h.deinit();
        const f = try h.frame(&.{}, 1_000_000);
        try f.pushStack(offset);
        try testing.expectError(error.OutOfGas, Memory.mload(f));
        try testing.expectEqual(@as(i64, 0), f.gas_remaining);

        f.gas_remaining = 1_000_000;
        try pushOperands(f, &.{ offset, 0x42 });
        try testing.expectError(error.OutOfGas, Memory.mstore(f));
        try testing.expectEqual(@as(i64, 0), f.gas_remaining);

        f.gas_remaining = 1_000_000;
        try pushOperands(f, &.{ offset, 0x42 });
        try testing.expectError(error.OutOfGas, Memory.mstore8(f));
        try testing.expectEqual(@as(i64, 0), f.gas_remaining);
    }
}

test "R2-12 MSTORE then MLOAD round-trips a word and expands memory by one word" {
    var h = try Harness.init(testing.allocator, .CANCUN);
    defer h.deinit();
    const f = try h.frame(&.{}, 1_000);
    const word: u256 = 0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20;
    try pushOperands(f, &.{ 1, word });
    try Memory.mstore(f);
    try testing.expectEqual(@as(u32, 64), f.memory_size);
    try testing.expectEqual(@as(i64, 1_000 - 3 - 6), f.gas_remaining);
    try f.pushStack(1);
    try Memory.mload(f);
    try testing.expectEqual(word, try f.popStack());
    try pushOperands(f, &.{ 70, 0x1ff });
    try Memory.mstore8(f);
    try testing.expectEqual(@as(u8, 0xff), f.readMemory(70));
    try testing.expectEqual(@as(u32, 96), f.memory_size);
}

test "R2-054 trace memSize reports logical memory when memory capture is off" {
    var h = try Harness.init(testing.allocator, .CANCUN);
    defer h.deinit();
    var tracer = trace.Tracer.init(testing.allocator);
    defer tracer.deinit();
    tracer.enabled = true;
    tracer.config.disable_memory = true;
    tracer.config.enable_memory = false;
    h.evm.setTracer(&tracer);

    // PUSH1 0, MLOAD, STOP
    const f = try h.frame(&.{ 0x60, 0x00, 0x51, 0x00 }, 1_000);
    try f.execute();
    try testing.expectEqual(@as(usize, 3), tracer.entries.items.len);
    try testing.expect(tracer.entries.items[2].memory == null);
    try testing.expectEqual(@as(usize, 32), tracer.entries.items[2].memSize);
    try testing.expect(tracer.entries.items[2].error_msg == null);
}

// ---------------------------------------------------------------------------
// R3-007 / A-1 / R3-03: async opcodes must request unloaded account fields
// ---------------------------------------------------------------------------

const r3_contract = Address{ .bytes = [_]u8{0xc0} ** 20 };
const r3_caller = Address{ .bytes = [_]u8{0xca} ** 20 };
const r3_remote = Address{ .bytes = [_]u8{0xb0} ** 20 };
const keccak_empty: u256 = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

/// Put the harness EVM into the state an async transaction with a StorageInjector runs in.
fn enableAsync(h: *Harness, injector: *StorageInjector) void {
    h.evm.storage.storage_injector = injector;
    h.evm.async_active = true;
}

fn expectRequest(h: *Harness, comptime field: std.meta.Tag(evm_mod.AsyncDataRequest), address: Address) !void {
    try testing.expect(h.evm.async_restart_pending);
    const request = h.evm.async_restart_request;
    try testing.expect(request == field);
    try testing.expect(@field(request, @tagName(field)).address.equals(address));
}

test "R3-007 EXTCODESIZE, EXTCODECOPY and EXTCODEHASH request unloaded code instead of reading empty" {
    inline for (.{ "size", "copy", "hash" }) |op| {
        var h = try Harness.init(testing.allocator, .CANCUN);
        defer h.deinit();
        var injector = try StorageInjector.init(testing.allocator);
        defer injector.deinit();
        enableAsync(&h, &injector);
        const f = try h.frame(&.{}, 100_000);
        const remote_word = primitives.Address.toU256(r3_remote);
        if (comptime std.mem.eql(u8, op, "copy")) {
            try pushOperands(f, &.{ remote_word, 0, 0, 32 });
            try testing.expectError(error.NeedAsyncData, Context.extcodecopy(f));
            // Nothing was copied or expanded on the placeholder empty code.
            try testing.expectEqual(@as(u32, 0), f.memory_size);
        } else {
            try f.pushStack(remote_word);
            const result = if (comptime std.mem.eql(u8, op, "size")) Context.extcodesize(f) else Context.extcodehash(f);
            try testing.expectError(error.NeedAsyncData, result);
            // No guessed result was pushed.
            try testing.expectEqual(@as(usize, 0), f.stack.items.len);
        }
        try expectRequest(&h, .code, r3_remote);
    }
}

test "R3-007 EXTCODEHASH of code-less account requests balance after fetched empty code" {
    var h = try Harness.init(testing.allocator, .CANCUN);
    defer h.deinit();
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    enableAsync(&h, &injector);
    try h.evm.supplyAsyncCode(r3_remote, &.{});
    const f = try h.frame(&.{}, 100_000);
    try f.pushStack(primitives.Address.toU256(r3_remote));
    try testing.expectError(error.NeedAsyncData, Context.extcodehash(f));
    try expectRequest(&h, .balance, r3_remote);
}

test "R3-007 CALL with value requests the target's liveness fields instead of charging 25000" {
    var h = try Harness.init(testing.allocator, .CANCUN);
    defer h.deinit();
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    enableAsync(&h, &injector);
    const f = try h.frame(&.{}, 100_000);
    try h.evm.balances.put(f.address, 10);
    const gas_before = f.gas_remaining;
    // CALL(gas, remote, value=1, 0, 0, 0, 0)
    try pushOperands(f, &.{ 0xffff, primitives.Address.toU256(r3_remote), 1, 0, 0, 0, 0 });
    try testing.expectError(error.NeedAsyncData, System.call(f));
    try expectRequest(&h, .balance, r3_remote);
    try testing.expectEqual(gas_before, f.gas_remaining);

    // A known zero balance is not an unknown code: the probe asks for code next.
    h.evm.clearAsyncRestart();
    try h.evm.supplyAsyncBalance(r3_remote, 0);
    try pushOperands(f, &.{ 0xffff, primitives.Address.toU256(r3_remote), 1, 0, 0, 0, 0 });
    try testing.expectError(error.NeedAsyncData, System.call(f));
    try expectRequest(&h, .code, r3_remote);

    h.evm.clearAsyncRestart();
    try h.evm.supplyAsyncCode(r3_remote, &.{});
    try pushOperands(f, &.{ 0xffff, primitives.Address.toU256(r3_remote), 1, 0, 0, 0, 0 });
    try testing.expectError(error.NeedAsyncData, System.call(f));
    try expectRequest(&h, .nonce, r3_remote);
}

test "R3-007 SELFDESTRUCT requests the beneficiary balance before moving value" {
    var h = try Harness.init(testing.allocator, .CANCUN);
    defer h.deinit();
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    enableAsync(&h, &injector);
    const f = try h.frame(&.{}, 100_000);
    try h.evm.balances.put(f.address, 5);
    try f.pushStack(primitives.Address.toU256(r3_remote));
    try testing.expectError(error.NeedAsyncData, System.selfdestruct(f));
    try expectRequest(&h, .balance, r3_remote);
    // The beneficiary was not written as 0 + 5 and the originator kept its balance.
    try testing.expect(!h.evm.balances.contains(r3_remote));
    try testing.expectEqual(@as(u256, 5), h.evm.balances.get(f.address).?);
    try testing.expect(!h.evm.selfdestructed_accounts.contains(f.address));
}

test "R3-007 SELFDESTRUCT with a zero balance still requests the beneficiary balance" {
    var h = try Harness.init(testing.allocator, .CANCUN);
    defer h.deinit();
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    enableAsync(&h, &injector);
    const f = try h.frame(&.{}, 100_000);
    try h.evm.balances.put(f.address, 0);
    try f.pushStack(primitives.Address.toU256(r3_remote));
    try testing.expectError(error.NeedAsyncData, System.selfdestruct(f));
    try expectRequest(&h, .balance, r3_remote);
    try testing.expect(!h.evm.balances.contains(r3_remote));
}

test "R3-007 synchronous hostless EXTCODESIZE and SELFDESTRUCT keep reading local state" {
    var h = try Harness.init(testing.allocator, .CANCUN);
    defer h.deinit();
    const f = try h.frame(&.{}, 100_000);
    try f.pushStack(primitives.Address.toU256(r3_remote));
    try Context.extcodesize(f);
    try testing.expectEqual(@as(u256, 0), try f.popStack());
    try h.evm.balances.put(f.address, 5);
    try f.pushStack(primitives.Address.toU256(r3_remote));
    try System.selfdestruct(f);
    try testing.expectEqual(@as(u256, 5), h.evm.balances.get(r3_remote).?);
    try testing.expect(!h.evm.async_restart_pending);
}

/// Answers every account and storage request from fixed tables until the transaction
/// reaches a terminal output, counting requests per kind.
const R3Host = struct {
    const Balance = struct { address: Address, balance: u256 };
    const Nonce = struct { address: Address, nonce: u64 };
    const Code = struct { address: Address, code: []const u8 };

    balances: []const Balance = &.{},
    nonces: []const Nonce = &.{},
    codes: []const Code = &.{},
    balance_requests: usize = 0,
    nonce_requests: usize = 0,
    code_requests: usize = 0,

    fn drive(self: *R3Host, vm: *Evm, first: Evm.CallOrContinueOutput) !Evm.CallOrContinueOutput {
        var output = first;
        var rounds: usize = 0;
        while (rounds < 64) : (rounds += 1) {
            switch (output) {
                .need_storage => |r| output = try vm.callOrContinue(.{ .continue_with_storage = .{ .address = r.address, .slot = r.slot, .value = 0 } }),
                .need_balance => |r| {
                    self.balance_requests += 1;
                    var value: u256 = 0;
                    for (self.balances) |e| {
                        if (e.address.equals(r.address)) value = e.balance;
                    }
                    output = try vm.callOrContinue(.{ .continue_with_balance = .{ .address = r.address, .balance = value } });
                },
                .need_nonce => |r| {
                    self.nonce_requests += 1;
                    var value: u64 = 0;
                    for (self.nonces) |e| {
                        if (e.address.equals(r.address)) value = e.nonce;
                    }
                    output = try vm.callOrContinue(.{ .continue_with_nonce = .{ .address = r.address, .nonce = value } });
                },
                .need_code => |r| {
                    self.code_requests += 1;
                    var value: []const u8 = &.{};
                    for (self.codes) |e| {
                        if (e.address.equals(r.address)) value = e.code;
                    }
                    output = try vm.callOrContinue(.{ .continue_with_code = .{ .address = r.address, .code = value } });
                },
                else => return output,
            }
        }
        return error.TooManyRequests;
    }
};

const R3Run = struct {
    output: []u8,
    gas_left: u64,
    beneficiary_balance: ?[]u8,
};

/// Run `code` at `r3_contract` as an async transaction from `r3_caller` against `host`,
/// commit it, and return the output, gas left and the committed balance of `r3_remote`.
fn runAsync(code: []const u8, value: u256, host: *R3Host) !R3Run {
    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .CANCUN, null, r3_caller, 0, null);
    defer vm.deinit();
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    vm.pending_storage_injector = &injector;
    vm.setBytecode(code);

    const params: Evm.CallParams = .{ .call = .{ .caller = r3_caller, .to = r3_contract, .value = value, .input = &.{}, .gas = 200_000 } };
    const committed = try host.drive(&vm, try vm.callOrContinue(.{ .call = params }));
    try testing.expect(committed == .ready_to_commit);

    var beneficiary_balance: ?[]u8 = null;
    errdefer if (beneficiary_balance) |b| testing.allocator.free(b);
    {
        var parsed = try std.json.parseFromSlice(std.json.Value, testing.allocator, committed.ready_to_commit.changes_json, .{});
        defer parsed.deinit();
        const remote_hex = "0x" ++ std.fmt.bytesToHex(r3_remote.bytes, .lower);
        for (parsed.value.object.get("balances").?.array.items) |entry| {
            if (std.ascii.eqlIgnoreCase(entry.object.get("address").?.string, remote_hex)) {
                beneficiary_balance = try testing.allocator.dupe(u8, entry.object.get("balance").?.string);
            }
        }
    }
    const done = try vm.callOrContinue(.{ .continue_after_commit = {} });
    try testing.expect(done == .result);
    try testing.expect(done.result.success);
    return .{
        .output = try testing.allocator.dupe(u8, done.result.output),
        .gas_left = done.result.gas_left,
        .beneficiary_balance = beneficiary_balance,
    };
}

fn freeRun(run: R3Run) void {
    testing.allocator.free(run.output);
    if (run.beneficiary_balance) |b| testing.allocator.free(b);
}

fn returnTop(comptime op: u8) [30]u8 {
    // PUSH20 remote; <op>; PUSH1 0; MSTORE; PUSH1 32; PUSH1 0; RETURN
    return [_]u8{0x73} ++ r3_remote.bytes ++ [_]u8{ op, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
}

fn outputWord(output: []const u8) !u256 {
    try testing.expectEqual(@as(usize, 32), output.len);
    return std.mem.readInt(u256, output[0..32], .big);
}

test "R3-007 async EXTCODESIZE and EXTCODEHASH see host-only code" {
    const remote_code = [_]u8{ 0x60, 0x01, 0x60, 0x02, 0x01, 0x60, 0x00, 0x52, 0x00, 0x00 };
    var expected_hash: [32]u8 = undefined;
    std.crypto.hash.sha3.Keccak256.hash(&remote_code, &expected_hash, .{});

    var size_host = R3Host{ .codes = &.{.{ .address = r3_remote, .code = &remote_code }} };
    const size_run = try runAsync(&returnTop(0x3b), 0, &size_host);
    defer freeRun(size_run);
    try testing.expectEqual(@as(u256, remote_code.len), try outputWord(size_run.output));
    try testing.expectEqual(@as(usize, 1), size_host.code_requests);

    var hash_host = R3Host{ .codes = &.{.{ .address = r3_remote, .code = &remote_code }} };
    const hash_run = try runAsync(&returnTop(0x3f), 0, &hash_host);
    defer freeRun(hash_run);
    try testing.expectEqual(std.mem.readInt(u256, &expected_hash, .big), try outputWord(hash_run.output));
}

test "R3-007 async EXTCODEHASH follows EIP-161: existing code-less account vs absent account" {
    // Nonce 5, no code, no balance: exists, so the hash of empty code.
    var alive_host = R3Host{ .nonces = &.{.{ .address = r3_remote, .nonce = 5 }} };
    const alive = try runAsync(&returnTop(0x3f), 0, &alive_host);
    defer freeRun(alive);
    try testing.expectEqual(keccak_empty, try outputWord(alive.output));
    try testing.expectEqual(@as(usize, 1), alive_host.nonce_requests);

    // Balance only: exists.
    var funded_host = R3Host{ .balances = &.{.{ .address = r3_remote, .balance = 1 }} };
    const funded = try runAsync(&returnTop(0x3f), 0, &funded_host);
    defer freeRun(funded);
    try testing.expectEqual(keccak_empty, try outputWord(funded.output));

    // Unknown to the host: empty, so zero.
    var absent_host = R3Host{};
    const absent = try runAsync(&returnTop(0x3f), 0, &absent_host);
    defer freeRun(absent);
    try testing.expectEqual(@as(u256, 0), try outputWord(absent.output));
}

test "R3-007 async CALL with value charges the new-account gas only for a dead target" {
    // CALL(0xffff, remote, 1, 0, 0, 0, 0); STOP
    const code = [_]u8{ 0x60, 0x00, 0x60, 0x00, 0x60, 0x00, 0x60, 0x00, 0x60, 0x01, 0x73 } ++ r3_remote.bytes ++ [_]u8{ 0x61, 0xff, 0xff, 0xf1, 0x00 };
    const caller_funds = [_]R3Host.Balance{.{ .address = r3_caller, .balance = 1_000 }};

    // Host EOA with nonce 5 and zero balance is alive (EIP-161).
    var alive_host = R3Host{ .balances = &caller_funds, .nonces = &.{.{ .address = r3_remote, .nonce = 5 }} };
    const alive = try runAsync(&code, 1, &alive_host);
    defer freeRun(alive);
    try testing.expect(alive_host.nonce_requests >= 1);

    var dead_host = R3Host{ .balances = &caller_funds };
    const dead = try runAsync(&code, 1, &dead_host);
    defer freeRun(dead);

    try testing.expectEqual(GasConstants.CallNewAccountGas, alive.gas_left - dead.gas_left);
}

test "R3-007 async SELFDESTRUCT credits the host balance of an unfetched beneficiary" {
    // PUSH20 remote; SELFDESTRUCT
    const code = [_]u8{0x73} ++ r3_remote.bytes ++ [_]u8{0xff};
    var host = R3Host{ .balances = &.{
        .{ .address = r3_caller, .balance = 1_000 },
        .{ .address = r3_remote, .balance = 1_000 },
    } };
    const run = try runAsync(&code, 10, &host);
    defer freeRun(run);
    // 1000 already held + 10 forwarded by the call, not 0 + 10.
    try testing.expectEqualStrings("0x3f2", run.beneficiary_balance.?);
}
