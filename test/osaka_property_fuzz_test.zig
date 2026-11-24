//! Deterministic campaigns run in the unit build. Each native fuzz target decodes
//! bytes directly so mutations and minimized inputs retain their EVM meaning.
const std = @import("std");
const evm = @import("evm");
const Address = @import("voltaire").Address;
const Evm = evm.Evm(.{});
const Frame = evm.Frame(.{});
const t = std.testing;
const forks = [_]evm.Hardfork{ .PRAGUE, .OSAKA };
const origin = Address.fromU256(0xcafe);
const contract = Address.fromU256(0xc0de);
const p256 = Address.fromU256(0x100);
const modexp = Address.fromU256(5);

fn initTransaction(vm: *Evm, fork: evm.Hardfork) !void {
    try vm.init(t.allocator, null, fork, null, origin, 0, null);
    errdefer vm.deinit();
    try vm.initTransactionState(null);
    try vm.preWarmTransaction(contract);
}

fn call(to: Address, input: []const u8, gas: u64) Evm.CallParams {
    return .{ .call = .{ .caller = origin, .to = to, .input = input, .value = 0, .gas = gas } };
}

fn checkClz(word: u256) !void {
    var code: [34]u8 = undefined;
    code[0] = 0x7f;
    std.mem.writeInt(u256, code[1..33], word, .big);
    code[33] = 0x1e;
    for (forks) |fork| {
        var vm: Evm = undefined;
        try vm.init(t.allocator, null, fork, null, origin, 0, null);
        defer vm.deinit();
        var frame = try Frame.init(t.allocator, &code, 8, origin, contract, 0, &.{}, &vm, fork, false);
        defer frame.deinit();
        try frame.step(); // PUSH32 costs 3, leaving precisely enough for CLZ.
        try t.expectEqual(5, frame.gas_remaining);
        if (fork == .OSAKA) {
            try frame.step();
            try t.expectEqualSlices(u256, &.{@clz(word)}, frame.stack.items);
            try t.expectEqual(0, frame.gas_remaining);
            try t.expectEqual(code.len, frame.pc);
        } else {
            try t.expectError(error.InvalidOpcode, frame.step());
        }
    }
}

test "CLZ differential at every power boundary and on sparse, dense and uniform words" {
    for (0..256) |bit| {
        const power = @as(u256, 1) << @intCast(bit);
        for ([_]u256{ power - 1, power, power + 1 }) |word| try checkClz(word);
    }
    var prng = std.Random.DefaultPrng.init(0xa57a_7939);
    const r = prng.random();
    for (0..4096) |i| {
        const sparse = (@as(u256, 1) << r.int(u8)) | (@as(u256, 1) << r.int(u8)) | (@as(u256, 1) << r.int(u8));
        const word = switch (i % 4) {
            0 => sparse,
            1 => ~sparse,
            2 => r.int(u256) >> r.int(u8),
            else => r.int(u256),
        };
        errdefer std.debug.print("CLZ case {d}, word {x}\n", .{ i, word });
        try checkClz(word);
    }
}

fn fuzzClz(_: void, bytes: []const u8) !void {
    var buf = [_]u8{0} ** 32;
    const n = @min(buf.len, bytes.len);
    @memcpy(buf[32 - n ..], bytes[0..n]);
    try checkClz(std.mem.readInt(u256, &buf, .big));
}

test "fuzz CLZ immediate" {
    try t.fuzz({}, fuzzClz, .{ .corpus = &.{ "\xff", "\x01" ++ "\x00" ** 31, "\xff" ** 32 } });
}

const Lengths = struct {
    base: u16,
    exp: u16,
    mod: u16,

    fn write(self: Lengths, buf: []u8) void {
        for ([_]u16{ self.base, self.exp, self.mod }, 0..) |len, i| {
            std.mem.writeInt(u256, buf[32 * i ..][0..32], len, .big);
        }
    }
};

// Compute with wider intermediates, using the first min(32, exp_len) bytes
// as a big-endian integer. The rest of the exponent contributes by length.
fn price(fork: evm.Hardfork, lens: Lengths, exponent: []const u8) u64 {
    var head: u256 = 0;
    for (exponent[0..@min(32, lens.exp)]) |byte| head = (head << 8) | byte;
    const top_bit: u128 = if (head == 0) 0 else 255 - @as(u128, @clz(head));
    const width: u128 = @max(lens.base, lens.mod);
    const words = (width + 7) / 8;
    const osaka = fork == .OSAKA;
    const tail: u128 = lens.exp -| 32;
    const iterations = @max(1, top_bit + tail * @as(u128, if (osaka) 16 else 8));
    if (osaka) {
        const complexity = if (width <= 32) 16 else 2 * words * words;
        return @intCast(@max(500, complexity * iterations));
    }
    return @intCast(@max(200, words * words * iterations / 3));
}

fn failedWith(result: Evm.CallResult, reason: []const u8) !void {
    try t.expect(!result.success);
    try t.expectEqual(0, result.gas_left);
    try t.expectEqual(0, result.output.len);
    try t.expectEqualStrings(reason, result.error_info orelse return error.MissingErrorInfo);
}

// Large declarations use a zero modulus implicit in the right padding. This
// exercises pricing and the length gate without timing big integer arithmetic.
fn checkPrice(vm: *Evm, lens: Lengths, head: [32]u8) !?u64 {
    var buf = [_]u8{0} ** (96 + 1100 + 32);
    lens.write(&buf);
    const offset = 96 + @as(usize, lens.base);
    const n = @min(32, lens.exp);
    @memcpy(buf[offset..][0..n], head[0..n]);
    const input = buf[0 .. offset + n];
    const budget: u64 = 1 << 32;
    const quoted = vm.inner_call(call(modexp, input, budget));
    if (vm.hardfork == .OSAKA and @max(lens.base, lens.exp, lens.mod) > 1024) {
        try failedWith(quoted, "InvalidInput");
        return null;
    }
    const expected = price(vm.hardfork, lens, &head);
    try t.expect(quoted.success);
    try t.expectEqual(budget - expected, quoted.gas_left);
    try t.expectEqual(lens.mod, quoted.output.len);
    try t.expect(std.mem.allEqual(u8, quoted.output, 0));
    const exact = vm.inner_call(call(modexp, input, expected));
    try t.expect(exact.success);
    try t.expectEqual(0, exact.gas_left);
    try failedWith(vm.inner_call(call(modexp, input, expected - 1)), "OutOfGas");
    return budget - quoted.gas_left;
}

fn checkLengths(lens: Lengths, head: [32]u8, axis: u8) !void {
    var grown = lens;
    const length = switch (axis % 3) {
        0 => &grown.base,
        1 => &grown.exp,
        else => &grown.mod,
    };
    length.* = @min(1100, length.* + 1);
    var prague: u64 = 0;
    for (forks) |fork| {
        var vm: Evm = undefined;
        try initTransaction(&vm, fork);
        defer vm.deinit();
        const cost = try checkPrice(&vm, lens, head);
        const next = try checkPrice(&vm, grown, head);
        if (cost) |before| {
            if (next) |after| try t.expect(after >= before);
            if (fork == .PRAGUE) prague = before else try t.expect(before >= prague);
        }
    }
}

fn randomLength(r: std.Random) u16 {
    const edges = [_]u16{ 0, 1, 7, 8, 9, 31, 32, 33, 1023, 1024, 1025, 1100 };
    return if (r.boolean()) r.uintAtMost(u16, 1100) else edges[r.uintLessThan(usize, edges.len)];
}

test "ModExp fork pricing, monotonic operand growth and exact funding" {
    var prng = std.Random.DefaultPrng.init(0xa57a_7883);
    const r = prng.random();
    for (0..1536) |i| {
        const lens = Lengths{ .base = randomLength(r), .exp = randomLength(r), .mod = randomLength(r) };
        var head: [32]u8 = undefined;
        r.bytes(&head);
        @memset(head[0..r.uintAtMost(usize, 32)], 0);
        errdefer std.debug.print("price case {d}, lengths {any}, head {x}\n", .{ i, lens, head });
        try checkLengths(lens, head, @intCast(i % 3));
    }

    // High bits of *each* 256-bit header must be checked before narrowing.
    var vm: Evm = undefined;
    try initTransaction(&vm, .OSAKA);
    defer vm.deinit();
    for (0..3) |axis| {
        for ([_]u256{ 1025, @as(u256, 1) << 64, std.math.maxInt(u256) }) |len| {
            var buf = [_]u8{0} ** 96;
            std.mem.writeInt(u256, buf[32 * axis ..][0..32], len, .big);
            try failedWith(vm.inner_call(call(modexp, &buf, std.math.maxInt(u64))), "InvalidInput");
        }
    }
}

fn checkSmall(base: u32, exp: u8, modulus: u32) !void {
    const lens = Lengths{ .base = 4, .exp = 1, .mod = 4 };
    var buf: [105]u8 = undefined;
    lens.write(&buf);
    std.mem.writeInt(u32, buf[96..100], base, .big);
    buf[100] = exp;
    std.mem.writeInt(u32, buf[101..105], modulus, .big);
    var answer: u64 = 0;
    if (modulus != 0) {
        answer = 1 % @as(u64, modulus);
        for (0..exp) |_| answer = (answer * base) % modulus;
    }
    for (forks) |fork| {
        var vm: Evm = undefined;
        try initTransaction(&vm, fork);
        defer vm.deinit();
        const gas: u64 = if (fork == .OSAKA) 500 else 200;
        const result = vm.inner_call(call(modexp, &buf, gas));
        try t.expect(result.success);
        try t.expectEqual(0, result.gas_left);
        try t.expectEqual(4, result.output.len);
        try t.expectEqual(answer, std.mem.readInt(u32, result.output[0..4], .big));
    }
}

test "ModExp small results agree with repeated modular multiplication" {
    var prng = std.Random.DefaultPrng.init(0xa57a_7823);
    const r = prng.random();
    for (0..1024) |i| {
        const base = r.int(u32);
        const exp = if (i % 16 == 0) 0 else r.int(u8);
        const modulus = switch (i % 17) {
            0 => 0,
            1 => 1,
            else => r.int(u32),
        };
        errdefer std.debug.print("ModExp case {d}: {d}^{d} mod {d}\n", .{ i, base, exp, modulus });
        try checkSmall(base, exp, modulus);
    }
}

fn fuzzModexp(_: void, bytes: []const u8) !void {
    var buf = [_]u8{0} ** 40;
    const n = @min(bytes.len, buf.len);
    @memcpy(buf[0..n], bytes[0..n]);
    try checkLengths(.{
        .base = std.mem.readInt(u16, buf[0..2], .big) % 1101,
        .exp = std.mem.readInt(u16, buf[2..4], .big) % 1101,
        .mod = std.mem.readInt(u16, buf[4..6], .big) % 1101,
    }, buf[8..40].*, buf[6]);
    try checkSmall(std.mem.readInt(u32, buf[8..12], .big), buf[7], std.mem.readInt(u32, buf[12..16], .big));
}

test "fuzz ModExp lengths, exponent head and small operands" {
    try t.fuzz({}, fuzzModexp, .{ .corpus = &.{ "\x04\x00\x04\x00\x04\x00", "\x04\x01", "\x00\x21\x00\x21\x00\x20\x01\xff\x80" } });
}

const one_word = ([_]u8{0} ** 31) ++ [_]u8{1};

// Algebraic test fixture with private scalar and nonce both 1: Q = G,
// r = G.x, s = (digest + r) mod n. Includes a zero digest.
fn signedInput(digest: u256) [160]u8 {
    const x = 0x6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296;
    const y = 0x4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5;
    const order = 0xffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551;
    const s = (@as(u257, digest) + x) % order;
    // ECDSA requires a nonzero s. Use digest 0 for this one residue.
    const words = [_]u256{ if (s == 0) 0 else digest, x, if (s == 0) x else @intCast(s), x, y };
    var input: [160]u8 = undefined;
    for (words, 0..) |word, i| std.mem.writeInt(u256, input[32 * i ..][0..32], word, .big);
    return input;
}

fn checkP256(code: []const u8, input: []const u8, gas: u16, is_static: bool, known_valid: bool) !void {
    for (forks) |fork| {
        var vm: Evm = undefined;
        try initTransaction(&vm, fork);
        defer vm.deinit();
        try vm.code.put(p256, code);
        _ = try vm.accessAddress(p256); // The call opcode warms its target before dispatch.
        var tracer = evm.Tracer.init(t.allocator);
        defer tracer.deinit();
        tracer.max_entries = 1;
        tracer.enable();
        vm.setTracer(&tracer);

        const params = if (is_static) Evm.CallParams{ .staticcall = .{
            .caller = origin,
            .to = p256,
            .input = input,
            .gas = gas,
        } } else call(p256, input, gas);
        const deployed = vm.get_code(p256);
        const result = vm.inner_call(params);
        try t.expect(result.gas_left <= gas);
        if (fork == .OSAKA) {
            try t.expectEqual(0, tracer.entries.items.len);
            if (gas < 6900) {
                try failedWith(result, "OutOfGas");
            } else {
                try t.expect(result.success);
                try t.expectEqual(gas - 6900, result.gas_left);
                if (known_valid) {
                    try t.expectEqualSlices(u8, &one_word, result.output);
                } else if (input.len != 160) {
                    try t.expectEqual(0, result.output.len);
                } else {
                    try t.expect(result.output.len == 0 or std.mem.eql(u8, result.output, &one_word));
                }
            }
        } else if (deployed.len != 0) {
            try t.expectEqual(1, tracer.entries.items.len);
            try t.expectEqual(deployed[0], tracer.entries.items[0].op);
            try t.expectEqual(0, tracer.entries.items[0].pc);
        } else {
            try t.expectEqual(0, tracer.entries.items.len);
            try t.expect(result.success);
            try t.expectEqual(gas, result.gas_left);
            try t.expectEqual(0, result.output.len);
        }

        // Execute the actual CALL/STATICCALL instruction in a fresh transaction.
        // Pre-expand memory so the instruction's only costs are access and child gas.
        var nested: Evm = undefined;
        try initTransaction(&nested, fork);
        defer nested.deinit();
        try nested.code.put(p256, code);
        const opcode = [_]u8{if (is_static) 0xfa else 0xf1};
        const parent_gas = 32_000; // EIP-150 cap exceeds every requested child budget.
        const arena = nested.arena.allocator();
        try nested.frames.append(arena, try Frame.init(arena, &opcode, parent_gas, origin, origin, 0, &.{}, &nested, fork, false));
        const frame = &nested.frames.items[0];
        for (input, 0..) |byte, i| try frame.writeMemory(@intCast(i), byte);
        frame.memory_size = @intCast(std.mem.alignForward(usize, input.len, 32));
        for ([_]u256{ 0, 0, input.len, 0 }) |arg| try frame.pushStack(arg);
        if (!is_static) try frame.pushStack(0);
        try frame.pushStack(0x100);
        try frame.pushStack(gas);
        try frame.step();
        const parent = &nested.frames.items[0];
        try t.expectEqualSlices(u256, &.{@intFromBool(result.success)}, parent.stack.items);
        try t.expectEqualSlices(u8, result.output, parent.return_data);
        const access: u64 = if (fork == .OSAKA) 100 else 2600;
        try t.expectEqual(@as(i64, @intCast(parent_gas - access - (gas - result.gas_left))), parent.gas_remaining);
    }
}

test "P256VERIFY code precedence and caller-visible status, data and gas" {
    var prng = std.Random.DefaultPrng.init(0xa57a_7951);
    const r = prng.random();
    for (0..1024) |i| {
        var code_buf: [128]u8 = undefined;
        const code = code_buf[0..if (i % 8 == 0) 0 else r.uintAtMost(usize, 128)];
        r.bytes(code);
        var input_buf: [256]u8 = undefined;
        const n = r.uintAtMost(usize, 256);
        r.bytes(input_buf[0..n]);
        const valid = i % 31 == 0;
        const signed = signedInput(r.int(u256));
        const input = if (valid) &signed else input_buf[0..n];
        const gas: u16 = switch (i % 11) {
            0 => 0,
            1 => 6899,
            2 => 6900,
            3 => 6901,
            4 => 10000,
            else => r.uintAtMost(u16, 10000),
        };
        errdefer std.debug.print("P256 case {d}, gas {d}, code {x}\n", .{ i, gas, code });
        try checkP256(code, input, gas, i % 2 == 0, valid);
    }
}

fn fuzzP256(_: void, bytes: []const u8) !void {
    // Gas, mode, code length, deployed code, calldata. Every remaining byte
    // feeds the actual program or precompile without PRNG seed indirection.
    var hdr = [_]u8{0} ** 4;
    const n = @min(4, bytes.len);
    @memcpy(hdr[0..n], bytes[0..n]);
    const body = bytes[n..];
    const code_len = @min(hdr[3] % 129, body.len);
    const input = body[code_len..][0..@min(256, body.len - code_len)];
    try checkP256(body[0..code_len], input, std.mem.readInt(u16, hdr[0..2], .big) % 10001, hdr[2] & 1 != 0, false);
}

test "fuzz P256VERIFY CALL and STATICCALL with deployed bytecode" {
    const valid = signedInput(0);
    try t.fuzz({}, fuzzP256, .{ .corpus = &.{
        "\x1a\xf3\x00\x01\xfe",                             "\x1a\xf4\x01\x01\xfe" ++ valid,
        "\x27\x10\x00\x08\x60\x42\x5f\x53\x60\x01\x5f\xf3",
    } });
}

test "nested native precompile failures preserve the reason at zero gas" {
    var vm: Evm = undefined;
    try initTransaction(&vm, .OSAKA);
    defer vm.deinit();
    try failedWith(vm.inner_call(.{ .staticcall = .{ .caller = origin, .to = p256, .gas = 0, .input = &.{} } }), "OutOfGas");
    try failedWith(vm.call(call(p256, &.{}, 0)), "OutOfGas");
}

const End = enum { stop, revert, invalid };

const Model = struct {
    key: u8,
    before: u8,
    after: u8,
    transfer: u8,

    fn program(m: Model, end: End) [22]u8 {
        // Write a previously dirty slot, a new slot and transient storage.
        // Emit a log before either committing or unwinding the frame.
        return .{
            0x60, m.after, 0x60, m.key,      0x55,
            0x60, m.after, 0x60, m.key +% 1, 0x55,
            0x60, m.after, 0x60, m.key,      0x5d,
            0x5f, 0x5f,    0xa0, 0x5f,       0x5f,
            switch (end) {
                .stop => 0,
                .revert => 0xfd,
                .invalid => 0xfe,
            },
            0,
        };
    }
};

fn checkProgram(code: []const u8, gas: u64, model: Model, end: ?End) !void {
    for (forks) |fork| {
        var vm: Evm = undefined;
        try initTransaction(&vm, fork);
        defer vm.deinit();

        const key = evm.StorageKey{ .address = contract.bytes, .slot = model.key };
        try vm.storage.storage.put(key, 43); // Transaction-start value.
        try vm.storage.set(contract, model.key, model.before);
        try vm.storage.set_transient(contract, model.key, 19);
        try vm.balances.put(origin, 256);
        try vm.balances.put(contract, 13);
        try vm.nonces.put(contract, 7);
        try vm.code.put(contract, code);
        try vm.logs.append(vm.arena.allocator(), .{ .address = origin, .topics = &.{}, .data = "before" });
        vm.gas_refund = 4800;
        _ = try vm.accessStorageSlot(contract, 256); // Warm unrelated state must survive.
        const warm_addresses = vm.access_list_manager.warm_addresses.count();

        var params = call(contract, &.{model.after}, gas);
        params.call.value = model.transfer;
        const result = vm.inner_call(params);
        try t.expect(result.gas_left <= gas);
        try t.expectEqual(0, vm.frames.items.len);
        if (end) |halt| {
            try t.expectEqual(halt == .stop, result.success);
            if (halt == .invalid) try t.expectEqual(0, result.gas_left) else try t.expect(result.gas_left > 0);
        }
        if (!result.success) {
            try t.expectEqual(model.before, try vm.storage.get(contract, model.key));
            try t.expectEqual(@intFromBool(model.before != 0), vm.storage.storage.count());
            try t.expectEqual(43, vm.storage.get_original(contract, model.key));
            try t.expectEqual(1, vm.storage.original_storage.count());
            try t.expectEqual(19, vm.storage.get_transient(contract, model.key));
            try t.expectEqual(1, vm.storage.transient.count());
            try t.expectEqual(256, vm.get_balance(origin));
            try t.expectEqual(13, vm.get_balance(contract));
            try t.expectEqual(7, vm.getNonce(contract));
            try t.expectEqualSlices(u8, code, vm.code.get(contract) orelse return error.MissingCode);
            try t.expectEqual(4800, vm.gas_refund);
            try t.expectEqual(1, vm.logs.items.len);
            try t.expectEqualSlices(u8, "before", vm.logs.items[0].data);
            try t.expectEqual(0, vm.created_accounts.count());
            try t.expectEqual(0, vm.selfdestructed_accounts.count());
            try t.expectEqual(warm_addresses, vm.access_list_manager.warm_addresses.count());
            try t.expectEqual(1, vm.access_list_manager.warm_storage_slots.count());
            try t.expect(vm.access_list_manager.is_storage_slot_warm(contract, 256));
        } else if (end == .stop) {
            try t.expectEqual(model.after, try vm.storage.get(contract, model.key));
            try t.expectEqual(model.after, try vm.storage.get(contract, model.key +% 1));
            try t.expectEqual(model.after, vm.storage.get_transient(contract, model.key));
            try t.expectEqual(256 - @as(u256, model.transfer), vm.get_balance(origin));
            try t.expectEqual(13 + @as(u256, model.transfer), vm.get_balance(contract));
            try t.expectEqual(2, vm.logs.items.len);
            try t.expect(vm.access_list_manager.is_storage_slot_warm(contract, model.key));
        }
    }
}

test "arbitrary bytecode and stateful programs conserve gas and restore the enclosing state" {
    var prng = std.Random.DefaultPrng.init(0xa57a_beef);
    const r = prng.random();
    for (0..1536) |i| {
        const model = Model{
            .key = r.int(u8),
            .before = if (i % 5 == 0) 0 else r.int(u8),
            .after = r.int(u8),
            .transfer = r.int(u8),
        };
        var buf: [128]u8 = undefined;
        const code = buf[0..r.uintAtMost(usize, buf.len)];
        r.bytes(code);
        const gas = r.uintAtMost(u32, 100_000);
        errdefer std.debug.print("snapshot case {d}, model {any}, gas {d}, code {x}\n", .{ i, model, gas, code });
        try checkProgram(code, gas, model, null);
        const halt: End = @enumFromInt(i % 3);
        try checkProgram(&model.program(halt), 100_000, model, halt);
    }
}

fn fuzzProgram(_: void, bytes: []const u8) !void {
    var hdr = [_]u8{0} ** 6;
    const n = @min(bytes.len, hdr.len);
    @memcpy(hdr[0..n], bytes[0..n]);
    const code = bytes[n..][0..@min(128, bytes.len - n)];
    const model = Model{ .key = hdr[2], .before = hdr[3], .after = hdr[4], .transfer = hdr[5] };
    const gas = std.mem.readInt(u16, hdr[0..2], .big);
    try checkProgram(code, gas, model, null);
    const halt: End = @enumFromInt(hdr[5] % 3);
    try checkProgram(&model.program(halt), 100_000, model, halt);
}

test "fuzz raw child bytecode and snapshot rollback" {
    try t.fuzz({}, fuzzProgram, .{ .corpus = &.{
        "\xff\xff\x01\x02\x03\x04\x60\x03\x5f\x55\x5f\x5f\xfd",
        "\x00\x15\x00\x00\x01\x02\x7f",
        "\x00\x08\x00\x00\x01\x00\x60\x80\x1e",
    } });
}

test "a reverting child cannot resurrect a slot cleared by its parent" {
    var vm: Evm = undefined;
    try initTransaction(&vm, .OSAKA);
    defer vm.deinit();
    const key = evm.StorageKey{ .address = contract.bytes, .slot = 0 };
    try vm.storage.storage.put(key, 1);
    try vm.storage.set(contract, 0, 0);
    // SSTORE(0, 1), REVERT(0, 0).
    try vm.code.put(contract, &.{ 0x60, 1, 0x5f, 0x55, 0x5f, 0x5f, 0xfd });
    const result = vm.inner_call(call(contract, &.{}, 30_000));
    try t.expect(!result.success);
    try t.expect(result.gas_left > 0);
    try t.expect(!vm.storage.storage.contains(key));
    try t.expectEqual(1, vm.storage.get_original(contract, 0));
}
