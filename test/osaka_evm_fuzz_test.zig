//! Deep EVM interpreter property and fuzz suite (Osaka focus).
//!
//! Part A: deterministic PRNG property tests (fixed seeds, 300+ iterations each)
//!   - EIP-7939 CLZ (0x1e) algebraic laws, exact gas, pre-Osaka InvalidOpcode
//!   - arithmetic / bitwise / shift / stack / memory / MCOPY / transient storage laws
//!   - EIP-7951 P256VERIFY (0x0100) dispatch and EIP-2929 warm-access invariants
//!   - arbitrary random bytecode stability across six forks
//! Part B: native `std.testing.fuzz` target for arbitrary bytecode on Osaka and Prague.
//!
//! Wiring: the test module needs the `evm` (src/root.zig) and `voltaire` imports,
//! the same pair `test/specs/runner.zig` uses.
//!
//! Tests named `KNOWN-BUG` assert the specification behavior and fail (or abort the
//! process, for the `panic` one) until the interpreter defect they name is patched.
//! See fuzz-logs/fable-4-guillotine-evm.md for the file:line of each defect.
//! Defects are cited by function and expression, not line: src/ was being edited while
//! this suite was written (2026-11-22) and line numbers kept moving.

const std = @import("std");
const evm_mod = @import("evm");
const primitives = @import("voltaire");

const Evm = evm_mod.Evm(.{});

const max_words = 10;
const default_gas: u64 = 1_000_000;
const return_top_gas: u64 = 15; // PUSH1 MSTORE(+1 word) PUSH1 PUSH1 RETURN
const p256_gas: u64 = 6900;
const p256_input_length: usize = 160;
const max_u256: u256 = std.math.maxInt(u256);
const sign_bit: u256 = @as(u256, 1) << 255;

const Op = struct {
    const STOP: u8 = 0x00;
    const ADD: u8 = 0x01;
    const MUL: u8 = 0x02;
    const SUB: u8 = 0x03;
    const DIV: u8 = 0x04;
    const SDIV: u8 = 0x05;
    const MOD: u8 = 0x06;
    const SMOD: u8 = 0x07;
    const ADDMOD: u8 = 0x08;
    const MULMOD: u8 = 0x09;
    const EXP: u8 = 0x0a;
    const SIGNEXTEND: u8 = 0x0b;
    const LT: u8 = 0x10;
    const GT: u8 = 0x11;
    const SLT: u8 = 0x12;
    const SGT: u8 = 0x13;
    const EQ: u8 = 0x14;
    const ISZERO: u8 = 0x15;
    const AND: u8 = 0x16;
    const OR: u8 = 0x17;
    const XOR: u8 = 0x18;
    const NOT: u8 = 0x19;
    const BYTE: u8 = 0x1a;
    const SHL: u8 = 0x1b;
    const SHR: u8 = 0x1c;
    const SAR: u8 = 0x1d;
    const CLZ: u8 = 0x1e;
    const KECCAK256: u8 = 0x20;
    const ADDRESS: u8 = 0x30;
    const CALLDATALOAD: u8 = 0x35;
    const CALLDATASIZE: u8 = 0x36;
    const CALLDATACOPY: u8 = 0x37;
    const CODECOPY: u8 = 0x39;
    const EXTCODECOPY: u8 = 0x3c;
    const RETURNDATASIZE: u8 = 0x3d;
    const RETURNDATACOPY: u8 = 0x3e;
    const POP: u8 = 0x50;
    const MLOAD: u8 = 0x51;
    const MSTORE: u8 = 0x52;
    const MSTORE8: u8 = 0x53;
    const SLOAD: u8 = 0x54;
    const SSTORE: u8 = 0x55;
    const JUMP: u8 = 0x56;
    const JUMPI: u8 = 0x57;
    const PC: u8 = 0x58;
    const MSIZE: u8 = 0x59;
    const GAS: u8 = 0x5a;
    const JUMPDEST: u8 = 0x5b;
    const TLOAD: u8 = 0x5c;
    const TSTORE: u8 = 0x5d;
    const MCOPY: u8 = 0x5e;
    const PUSH0: u8 = 0x5f;
    const PUSH1: u8 = 0x60;
    const PUSH2: u8 = 0x61;
    const PUSH3: u8 = 0x62;
    const PUSH4: u8 = 0x63;
    const PUSH32: u8 = 0x7f;
    const DUP1: u8 = 0x80;
    const SWAP1: u8 = 0x90;
    const LOG0: u8 = 0xa0;
    const CALL: u8 = 0xf1;
    const CALLCODE: u8 = 0xf2;
    const RETURN: u8 = 0xf3;
    const DELEGATECALL: u8 = 0xf4;
    const STATICCALL: u8 = 0xfa;
    const REVERT: u8 = 0xfd;
    const INVALID: u8 = 0xfe;
};

const stability_forks = [_]primitives.Hardfork{ .FRONTIER, .BERLIN, .SHANGHAI, .CANCUN, .PRAGUE, .OSAKA };

// ============================================================================
// Harness
// ============================================================================

fn originAddress() primitives.Address {
    return primitives.Address.fromU256(0xa11ce);
}

fn contractAddress() primitives.Address {
    return primitives.Address.fromU256(0xc0de);
}

fn helperAddress() primitives.Address {
    return primitives.Address.fromU256(0xbbbb);
}

fn p256Address() primitives.Address {
    return primitives.Address.fromU256(0x0100);
}

/// Tiny bytecode assembler over a fixed buffer.
const Asm = struct {
    buf: [2048]u8 = undefined,
    len: usize = 0,

    fn op(self: *Asm, opcode: u8) void {
        self.buf[self.len] = opcode;
        self.len += 1;
    }

    /// PUSH32 value
    fn push(self: *Asm, value: u256) void {
        self.op(Op.PUSH32);
        std.mem.writeInt(u256, self.buf[self.len..][0..32], value, .big);
        self.len += 32;
    }

    fn push1(self: *Asm, value: u8) void {
        self.op(Op.PUSH1);
        self.op(value);
    }

    fn push2(self: *Asm, value: u16) void {
        self.op(Op.PUSH2);
        std.mem.writeInt(u16, self.buf[self.len..][0..2], value, .big);
        self.len += 2;
    }

    fn push3(self: *Asm, value: u24) void {
        self.op(Op.PUSH3);
        std.mem.writeInt(u24, self.buf[self.len..][0..3], value, .big);
        self.len += 3;
    }

    fn push4(self: *Asm, value: u32) void {
        self.op(Op.PUSH4);
        std.mem.writeInt(u32, self.buf[self.len..][0..4], value, .big);
        self.len += 4;
    }

    /// MSTORE the top of the stack at offset 0 and RETURN that word. Costs `return_top_gas`.
    fn returnTop(self: *Asm) void {
        self.push1(0);
        self.op(Op.MSTORE);
        self.push1(32);
        self.push1(0);
        self.op(Op.RETURN);
    }

    fn code(self: *const Asm) []const u8 {
        return self.buf[0..self.len];
    }
};

const RunMode = enum {
    /// `Evm.call` with a `.call` to a contract holding the code (top-level transaction path).
    transaction,
    /// `Evm.inner_call` after manual transaction setup. Code stays installed, so the
    /// program can CALL itself and exercise real nested frames.
    nested,
    /// `Evm.call` with a `.create` that runs the bytes as init code.
    create,
};

const Summary = struct {
    success: bool,
    gas_left: u64,
    output_len: usize,
    output_hash: u64,
    errored: bool,
    invalid_opcode: bool,
    words: [max_words]u256,
};

fn summarize(result: Evm.CallResult) Summary {
    var words = [_]u256{0} ** max_words;
    var index: usize = 0;
    while (index < max_words and (index + 1) * 32 <= result.output.len) : (index += 1) {
        words[index] = std.mem.readInt(u256, result.output[index * 32 ..][0..32], .big);
    }
    return .{
        .success = result.success,
        .gas_left = result.gas_left,
        .output_len = result.output.len,
        .output_hash = std.hash.Wyhash.hash(0, result.output),
        .errored = result.error_info != null,
        .invalid_opcode = if (result.error_info) |info| std.mem.eql(u8, info, "InvalidOpcode") else false,
        .words = words,
    };
}

fn run(fork: primitives.Hardfork, mode: RunMode, code: []const u8, calldata: []const u8, gas: u64) !Summary {
    var vm: Evm = undefined;
    try vm.init(std.testing.allocator, null, fork, null, originAddress(), 0, null);
    defer vm.deinit();

    switch (mode) {
        .transaction => {
            try vm.code.put(contractAddress(), code);
            return summarize(vm.call(.{ .call = .{
                .caller = originAddress(),
                .to = contractAddress(),
                .value = 0,
                .input = calldata,
                .gas = gas,
            } }));
        },
        .nested => {
            try vm.initTransactionState(null);
            try vm.preWarmTransaction(contractAddress());
            try vm.code.put(contractAddress(), code);
            return summarize(vm.inner_call(.{ .call = .{
                .caller = originAddress(),
                .to = contractAddress(),
                .value = 0,
                .input = calldata,
                .gas = gas,
            } }));
        },
        .create => {
            return summarize(vm.call(.{ .create = .{
                .caller = originAddress(),
                .value = 0,
                .init_code = code,
                .gas = gas,
            } }));
        },
    }
}

/// Top-level transaction straight to the P256VERIFY address (no contract code involved).
fn callP256Directly(fork: primitives.Hardfork, input: []const u8, gas: u64) !Summary {
    var vm: Evm = undefined;
    try vm.init(std.testing.allocator, null, fork, null, originAddress(), 0, null);
    defer vm.deinit();
    return summarize(vm.call(.{ .call = .{
        .caller = originAddress(),
        .to = p256Address(),
        .value = 0,
        .input = input,
        .gas = gas,
    } }));
}

/// Append "return top of stack", execute, and return that word.
fn evalTop(fork: primitives.Hardfork, a: *Asm) !u256 {
    a.returnTop();
    const result = try run(fork, .transaction, a.code(), &[_]u8{}, default_gas);
    try std.testing.expect(result.success);
    try std.testing.expectEqual(@as(usize, 32), result.output_len);
    return result.words[0];
}

/// Execute one opcode. `args[0]` ends on top of the stack (the first operand popped).
fn evalOp(fork: primitives.Hardfork, opcode: u8, args: []const u256) !u256 {
    var a = Asm{};
    var index = args.len;
    while (index > 0) {
        index -= 1;
        a.push(args[index]);
    }
    a.op(opcode);
    return evalTop(fork, &a);
}

fn gasUsed(fork: primitives.Hardfork, code: []const u8, gas: u64) !u64 {
    const result = try run(fork, .transaction, code, &[_]u8{}, gas);
    try std.testing.expect(result.success);
    try std.testing.expect(result.gas_left <= gas);
    return gas - result.gas_left;
}

fn memoryCost(words: u64) u64 {
    return 3 * words + words * words / 512;
}

fn ceil32(bytes: usize) usize {
    return (bytes + 31) / 32 * 32;
}

fn refClz(x: u256) u256 {
    return @as(u256, @clz(x));
}

/// Random word biased toward boundary shapes: 0, 1, max, sign bit, short values, powers of two.
fn randomWord(random: std.Random) u256 {
    const raw = random.int(u256);
    return switch (random.uintLessThan(u8, 16)) {
        0 => 0,
        1 => 1,
        2 => max_u256,
        3 => sign_bit,
        4, 5, 6, 7 => raw >> random.int(u8),
        8, 9 => @as(u256, 1) << random.int(u8),
        10 => (@as(u256, 1) << random.int(u8)) -% 1,
        11 => raw | sign_bit,
        else => raw,
    };
}

/// Random shift amount covering 0..255, exactly 256, just above, and huge values.
fn randomShift(random: std.Random) u256 {
    return switch (random.uintLessThan(u8, 8)) {
        0, 1, 2, 3, 4 => random.uintAtMost(u16, 255),
        5 => 256,
        6 => 257 + @as(u256, random.int(u16)),
        else => randomWord(random),
    };
}

fn randomFork(random: std.Random) primitives.Hardfork {
    return stability_forks[random.uintLessThan(usize, stability_forks.len)];
}

// ============================================================================
// Part A.1: EIP-7939 CLZ
// ============================================================================

test "property: CLZ is 256 iff zero, bounded by 255 otherwise, and locates the top set bit" {
    var prng = std.Random.DefaultPrng.init(0x7939_0001);
    const random = prng.random();

    var i: usize = 0;
    while (i < 400) : (i += 1) {
        const x = randomWord(random);
        errdefer std.debug.print("CLZ top-bit law failed: i={d} x=0x{x}\n", .{ i, x });

        const count = try evalOp(.OSAKA, Op.CLZ, &[_]u256{x});
        try std.testing.expectEqual(refClz(x), count);
        try std.testing.expectEqual(x == 0, count == 256);

        if (x != 0) {
            try std.testing.expect(count <= 255);
            const shift: u8 = @intCast(255 - count);
            try std.testing.expectEqual(@as(u256, 1), x >> shift);

            // Same law evaluated entirely inside the EVM: x >> (255 - CLZ(x)) == 1.
            var a = Asm{};
            a.push(x);
            a.op(Op.DUP1);
            a.op(Op.CLZ);
            a.push1(255);
            a.op(Op.SUB);
            a.op(Op.SHR);
            try std.testing.expectEqual(@as(u256, 1), try evalTop(.OSAKA, &a));
        }
    }
}

test "property: CLZ(x >> k) == min(256, CLZ(x) + k) and CLZ(1 << n) == 255 - n" {
    var prng = std.Random.DefaultPrng.init(0x7939_0002);
    const random = prng.random();

    var i: usize = 0;
    while (i < 400) : (i += 1) {
        const x = randomWord(random);
        const k = random.uintAtMost(u16, 256);
        errdefer std.debug.print("CLZ shift law failed: i={d} x=0x{x} k={d}\n", .{ i, x, k });

        var a = Asm{};
        a.push(x);
        a.push2(k);
        a.op(Op.SHR);
        a.op(Op.CLZ);
        const shifted_count = try evalTop(.OSAKA, &a);

        const expected = @min(@as(u256, 256), refClz(x) + k);
        try std.testing.expectEqual(expected, shifted_count);

        const n = random.int(u8);
        var b = Asm{};
        b.push1(1);
        b.push1(n);
        b.op(Op.SHL);
        b.op(Op.CLZ);
        try std.testing.expectEqual(@as(u256, 255) - n, try evalTop(.OSAKA, &b));
    }
}

test "property: CLZ(x | y) == min(CLZ(x), CLZ(y)) and CLZ is antitone" {
    var prng = std.Random.DefaultPrng.init(0x7939_0003);
    const random = prng.random();

    var i: usize = 0;
    while (i < 400) : (i += 1) {
        const x = randomWord(random);
        const y = randomWord(random);
        errdefer std.debug.print("CLZ lattice law failed: i={d} x=0x{x} y=0x{x}\n", .{ i, x, y });

        const count_x = try evalOp(.OSAKA, Op.CLZ, &[_]u256{x});
        const count_y = try evalOp(.OSAKA, Op.CLZ, &[_]u256{y});

        var a = Asm{};
        a.push(x);
        a.push(y);
        a.op(Op.OR);
        a.op(Op.CLZ);
        try std.testing.expectEqual(@min(count_x, count_y), try evalTop(.OSAKA, &a));

        var b = Asm{};
        b.push(x);
        b.push(y);
        b.op(Op.AND);
        b.op(Op.CLZ);
        try std.testing.expect(try evalTop(.OSAKA, &b) >= @max(count_x, count_y));

        // x <= y implies CLZ(x) >= CLZ(y).
        if (x <= y) try std.testing.expect(count_x >= count_y);
        if (y <= x) try std.testing.expect(count_y >= count_x);
    }
}

test "property: CLZ costs exactly 5 gas and leaves the rest of the stack intact" {
    var prng = std.Random.DefaultPrng.init(0x7939_0004);
    const random = prng.random();

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        const x = randomWord(random);
        const below = randomWord(random);
        errdefer std.debug.print("CLZ gas law failed: i={d} x=0x{x}\n", .{ i, x });

        // PUSH32 x, CLZ, return-top: 3 + 5 + 15.
        var with_clz = Asm{};
        with_clz.push(x);
        with_clz.op(Op.CLZ);
        with_clz.returnTop();
        try std.testing.expectEqual(@as(u64, 23), try gasUsed(.OSAKA, with_clz.code(), default_gas));

        // Same program without CLZ: 3 + 15. The difference is the CLZ price.
        var without_clz = Asm{};
        without_clz.push(x);
        without_clz.returnTop();
        try std.testing.expectEqual(@as(u64, 18), try gasUsed(.OSAKA, without_clz.code(), default_gas));

        // Exact-gas boundary: 23 succeeds with nothing left, 22 fails.
        const exact = try run(.OSAKA, .transaction, with_clz.code(), &[_]u8{}, 23);
        try std.testing.expect(exact.success);
        try std.testing.expectEqual(@as(u64, 0), exact.gas_left);
        try std.testing.expectEqual(refClz(x), exact.words[0]);
        const short = try run(.OSAKA, .transaction, with_clz.code(), &[_]u8{}, 22);
        try std.testing.expect(!short.success);

        // PUSH32 x, CLZ, STOP needs exactly 8 gas; 7 runs out inside CLZ.
        var bare = Asm{};
        bare.push(x);
        bare.op(Op.CLZ);
        bare.op(Op.STOP);
        const bare_exact = try run(.OSAKA, .transaction, bare.code(), &[_]u8{}, 8);
        try std.testing.expect(bare_exact.success);
        try std.testing.expectEqual(@as(u64, 0), bare_exact.gas_left);
        const bare_short = try run(.OSAKA, .transaction, bare.code(), &[_]u8{}, 7);
        try std.testing.expect(!bare_short.success);
        try std.testing.expectEqual(@as(u64, 0), bare_short.gas_left);

        // CLZ replaces only the top word.
        var keep = Asm{};
        keep.push(below);
        keep.push(x);
        keep.op(Op.CLZ);
        keep.op(Op.POP);
        try std.testing.expectEqual(below, try evalTop(.OSAKA, &keep));
    }

    // Empty stack: fails, and not as an invalid opcode.
    const underflow = try run(.OSAKA, .transaction, &[_]u8{Op.CLZ}, &[_]u8{}, default_gas);
    try std.testing.expect(!underflow.success);
    try std.testing.expect(!underflow.invalid_opcode);
}

test "property: CLZ is InvalidOpcode before Osaka and consumes all gas" {
    var prng = std.Random.DefaultPrng.init(0x7939_0005);
    const random = prng.random();
    const pre_osaka = [_]primitives.Hardfork{ .PRAGUE, .CANCUN, .SHANGHAI, .LONDON, .BERLIN, .FRONTIER };

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        const x = randomWord(random);
        const fork = pre_osaka[i % pre_osaka.len];
        const gas = 100 + random.uintLessThan(u64, 100_000);
        errdefer std.debug.print("CLZ pre-Osaka law failed: i={d} fork={s} x=0x{x}\n", .{ i, @tagName(fork), x });

        var a = Asm{};
        a.push(x);
        a.op(Op.CLZ);
        a.returnTop();

        const result = try run(fork, .transaction, a.code(), &[_]u8{}, gas);
        try std.testing.expect(!result.success);
        try std.testing.expect(result.invalid_opcode);
        try std.testing.expectEqual(@as(u64, 0), result.gas_left);
        try std.testing.expectEqual(@as(usize, 0), result.output_len);

        // The nested path fails too and hands no gas back.
        const nested = try run(fork, .nested, a.code(), &[_]u8{}, gas);
        try std.testing.expect(!nested.success);
        try std.testing.expectEqual(@as(u64, 0), nested.gas_left);
    }

    // Control: the same program succeeds on Osaka.
    var control = Asm{};
    control.push(1);
    control.op(Op.CLZ);
    try std.testing.expectEqual(@as(u256, 255), try evalTop(.OSAKA, &control));
}

// ============================================================================
// Part A.2: arithmetic, bitwise, shifts, stack
// ============================================================================

test "property: ADD/SUB form a commutative group mod 2^256" {
    var prng = std.Random.DefaultPrng.init(0xa11_0001);
    const random = prng.random();

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        const a = randomWord(random);
        const b = randomWord(random);
        const c = randomWord(random);
        const fork = randomFork(random);
        errdefer std.debug.print("ADD/SUB law failed: i={d} fork={s} a=0x{x} b=0x{x} c=0x{x}\n", .{ i, @tagName(fork), a, b, c });

        const sum = try evalOp(fork, Op.ADD, &[_]u256{ a, b });
        try std.testing.expectEqual(a +% b, sum);
        try std.testing.expectEqual(sum, try evalOp(fork, Op.ADD, &[_]u256{ b, a }));
        try std.testing.expectEqual(a, try evalOp(fork, Op.SUB, &[_]u256{ sum, b }));
        try std.testing.expectEqual(a -% b, try evalOp(fork, Op.SUB, &[_]u256{ a, b }));
        try std.testing.expectEqual(@as(u256, 0), try evalOp(fork, Op.SUB, &[_]u256{ a, a }));
        try std.testing.expectEqual(a, try evalOp(fork, Op.ADD, &[_]u256{ a, 0 }));

        // a + (0 - a) == 0, evaluated in one program.
        var inverse = Asm{};
        inverse.push(a);
        inverse.push(a);
        inverse.push1(0);
        inverse.op(Op.SUB);
        inverse.op(Op.ADD);
        try std.testing.expectEqual(@as(u256, 0), try evalTop(fork, &inverse));

        // (a + b) + c == a + (b + c).
        var left = Asm{};
        left.push(c);
        left.push(b);
        left.push(a);
        left.op(Op.ADD);
        left.op(Op.ADD);
        var right = Asm{};
        right.push(a);
        right.push(c);
        right.push(b);
        right.op(Op.ADD);
        right.op(Op.ADD);
        try std.testing.expectEqual(try evalTop(fork, &left), try evalTop(fork, &right));
    }
}

test "property: MUL is commutative, distributes over ADD, and has identity 1" {
    var prng = std.Random.DefaultPrng.init(0xa11_0002);
    const random = prng.random();

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        const a = randomWord(random);
        const b = randomWord(random);
        const c = randomWord(random);
        const fork = randomFork(random);
        errdefer std.debug.print("MUL law failed: i={d} fork={s} a=0x{x} b=0x{x} c=0x{x}\n", .{ i, @tagName(fork), a, b, c });

        const product = try evalOp(fork, Op.MUL, &[_]u256{ a, b });
        try std.testing.expectEqual(a *% b, product);
        try std.testing.expectEqual(product, try evalOp(fork, Op.MUL, &[_]u256{ b, a }));
        try std.testing.expectEqual(a, try evalOp(fork, Op.MUL, &[_]u256{ a, 1 }));
        try std.testing.expectEqual(@as(u256, 0), try evalOp(fork, Op.MUL, &[_]u256{ a, 0 }));

        // a * (b + c) == a*b + a*c.
        var left = Asm{};
        left.push(c);
        left.push(b);
        left.op(Op.ADD);
        left.push(a);
        left.op(Op.MUL);
        var right = Asm{};
        right.push(c);
        right.push(a);
        right.op(Op.MUL);
        right.push(b);
        right.push(a);
        right.op(Op.MUL);
        right.op(Op.ADD);
        try std.testing.expectEqual(try evalTop(fork, &left), try evalTop(fork, &right));
    }
}

fn magnitude(x: u256) u256 {
    return if (x & sign_bit != 0) 0 -% x else x;
}

/// Sign-magnitude SDIV, independent of the interpreter's i256 formulation.
fn refSdiv(a: u256, b: u256) u256 {
    if (b == 0) return 0;
    const quotient = magnitude(a) / magnitude(b);
    const negative = (a & sign_bit != 0) != (b & sign_bit != 0);
    return if (negative) 0 -% quotient else quotient;
}

/// Sign-magnitude SMOD: the result takes the sign of the dividend.
fn refSmod(a: u256, b: u256) u256 {
    if (b == 0) return 0;
    const remainder = magnitude(a) % magnitude(b);
    return if (a & sign_bit != 0) 0 -% remainder else remainder;
}

test "property: DIV/MOD and SDIV/SMOD satisfy the division identity" {
    var prng = std.Random.DefaultPrng.init(0xa11_0003);
    const random = prng.random();

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        const a = randomWord(random);
        const b = if (i % 16 == 0) @as(u256, 0) else randomWord(random);
        const fork = randomFork(random);
        errdefer std.debug.print("DIV/MOD law failed: i={d} fork={s} a=0x{x} b=0x{x}\n", .{ i, @tagName(fork), a, b });

        const quotient = try evalOp(fork, Op.DIV, &[_]u256{ a, b });
        const remainder = try evalOp(fork, Op.MOD, &[_]u256{ a, b });
        const signed_quotient = try evalOp(fork, Op.SDIV, &[_]u256{ a, b });
        const signed_remainder = try evalOp(fork, Op.SMOD, &[_]u256{ a, b });

        try std.testing.expectEqual(refSdiv(a, b), signed_quotient);
        try std.testing.expectEqual(refSmod(a, b), signed_remainder);

        if (b == 0) {
            try std.testing.expectEqual(@as(u256, 0), quotient);
            try std.testing.expectEqual(@as(u256, 0), remainder);
        } else {
            try std.testing.expect(remainder < b);
            try std.testing.expectEqual(a, quotient *% b +% remainder);
            try std.testing.expectEqual(a, signed_quotient *% b +% signed_remainder);
            try std.testing.expect(magnitude(signed_remainder) < magnitude(b));
        }
    }

    // The one overflowing signed division: MIN / -1 == MIN, MIN % -1 == 0.
    try std.testing.expectEqual(sign_bit, try evalOp(.OSAKA, Op.SDIV, &[_]u256{ sign_bit, max_u256 }));
    try std.testing.expectEqual(@as(u256, 0), try evalOp(.OSAKA, Op.SMOD, &[_]u256{ sign_bit, max_u256 }));
}

test "property: ADDMOD/MULMOD use the full 512-bit intermediate" {
    var prng = std.Random.DefaultPrng.init(0xa11_0004);
    const random = prng.random();

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        const a = randomWord(random);
        const b = randomWord(random);
        const n = if (i % 16 == 0) @as(u256, 0) else randomWord(random);
        const fork = randomFork(random);
        errdefer std.debug.print("ADDMOD/MULMOD law failed: i={d} fork={s} a=0x{x} b=0x{x} n=0x{x}\n", .{ i, @tagName(fork), a, b, n });

        const add_mod = try evalOp(fork, Op.ADDMOD, &[_]u256{ a, b, n });
        const mul_mod = try evalOp(fork, Op.MULMOD, &[_]u256{ a, b, n });

        if (n == 0) {
            try std.testing.expectEqual(@as(u256, 0), add_mod);
            try std.testing.expectEqual(@as(u256, 0), mul_mod);
            continue;
        }

        const wide_n: u512 = n;
        const expected_add: u256 = @intCast((@as(u512, a) + @as(u512, b)) % wide_n);
        const expected_mul: u256 = @intCast((@as(u512, a) * @as(u512, b)) % wide_n);
        try std.testing.expectEqual(expected_add, add_mod);
        try std.testing.expectEqual(expected_mul, mul_mod);
        try std.testing.expect(add_mod < n);
        try std.testing.expect(mul_mod < n);

        // Commutativity and reduction of operands.
        try std.testing.expectEqual(add_mod, try evalOp(fork, Op.ADDMOD, &[_]u256{ b, a, n }));
        try std.testing.expectEqual(mul_mod, try evalOp(fork, Op.MULMOD, &[_]u256{ b, a, n }));
        try std.testing.expectEqual(add_mod, try evalOp(fork, Op.ADDMOD, &[_]u256{ a % n, b % n, n }));
        try std.testing.expectEqual(mul_mod, try evalOp(fork, Op.MULMOD, &[_]u256{ a % n, b % n, n }));

        // a * 2 mod n == a + a mod n, and a * 1 mod n == a mod n (the EVM's own MOD).
        try std.testing.expectEqual(
            try evalOp(fork, Op.ADDMOD, &[_]u256{ a, a, n }),
            try evalOp(fork, Op.MULMOD, &[_]u256{ a, 2, n }),
        );
        try std.testing.expectEqual(
            try evalOp(fork, Op.MOD, &[_]u256{ a, n }),
            try evalOp(fork, Op.MULMOD, &[_]u256{ a, 1, n }),
        );
    }
}

test "property: SHL/SHR/SAR agree with MUL/DIV by 2^k and with each other" {
    var prng = std.Random.DefaultPrng.init(0xa11_0005);
    const random = prng.random();

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        const x = randomWord(random);
        const k = randomShift(random);
        const fork: primitives.Hardfork = if (i % 2 == 0) .OSAKA else .BERLIN;
        errdefer std.debug.print("shift law failed: i={d} fork={s} x=0x{x} k=0x{x}\n", .{ i, @tagName(fork), x, k });

        const shl = try evalOp(fork, Op.SHL, &[_]u256{ k, x });
        const shr = try evalOp(fork, Op.SHR, &[_]u256{ k, x });
        const sar = try evalOp(fork, Op.SAR, &[_]u256{ k, x });

        // 2^k mod 2^256 is 0 for k >= 256, and DIV by 0 is 0, so both laws hold for every k.
        const power = try evalOp(fork, Op.EXP, &[_]u256{ 2, k });
        try std.testing.expectEqual(try evalOp(fork, Op.MUL, &[_]u256{ x, power }), shl);
        try std.testing.expectEqual(try evalOp(fork, Op.DIV, &[_]u256{ x, power }), shr);

        if (k >= 256) {
            try std.testing.expectEqual(@as(u256, 0), shl);
            try std.testing.expectEqual(@as(u256, 0), shr);
            try std.testing.expectEqual(if (x & sign_bit != 0) max_u256 else @as(u256, 0), sar);
        } else {
            const small: u8 = @intCast(k);
            // SHR undoes SHL on the bits that survive.
            try std.testing.expectEqual(x & (max_u256 >> small), try evalOp(fork, Op.SHR, &[_]u256{ k, shl }));
            // SHL undoes SHR on the bits that survive.
            try std.testing.expectEqual(x & (max_u256 << small), try evalOp(fork, Op.SHL, &[_]u256{ k, shr }));
        }

        // SAR is SHR for non-negative values and NOT(SHR(NOT x)) for negative ones.
        if (x & sign_bit == 0) {
            try std.testing.expectEqual(shr, sar);
        } else {
            var a = Asm{};
            a.push(x);
            a.op(Op.NOT);
            a.push(k);
            a.op(Op.SHR);
            a.op(Op.NOT);
            try std.testing.expectEqual(try evalTop(fork, &a), sar);
        }
    }

    // Shifts do not exist before Constantinople.
    var early = Asm{};
    early.push1(1);
    early.push1(1);
    early.op(Op.SHL);
    early.returnTop();
    const frontier = try run(.FRONTIER, .transaction, early.code(), &[_]u8{}, default_gas);
    try std.testing.expect(!frontier.success);
    try std.testing.expect(frontier.invalid_opcode);
}

test "property: comparison and bitwise opcodes obey boolean-algebra laws" {
    var prng = std.Random.DefaultPrng.init(0xa11_0006);
    const random = prng.random();

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        const a = randomWord(random);
        const b = if (i % 8 == 0) a else randomWord(random);
        const fork = randomFork(random);
        errdefer std.debug.print("bitwise law failed: i={d} fork={s} a=0x{x} b=0x{x}\n", .{ i, @tagName(fork), a, b });

        // Trichotomy: exactly one of a < b, a > b, a == b.
        const lt = try evalOp(fork, Op.LT, &[_]u256{ a, b });
        const gt = try evalOp(fork, Op.GT, &[_]u256{ a, b });
        const eq = try evalOp(fork, Op.EQ, &[_]u256{ a, b });
        try std.testing.expectEqual(@as(u256, 1), lt + gt + eq);
        try std.testing.expectEqual(@as(u256, @intFromBool(a < b)), lt);
        try std.testing.expectEqual(lt, try evalOp(fork, Op.GT, &[_]u256{ b, a }));

        const signed_a: i256 = @bitCast(a);
        const signed_b: i256 = @bitCast(b);
        const slt = try evalOp(fork, Op.SLT, &[_]u256{ a, b });
        const sgt = try evalOp(fork, Op.SGT, &[_]u256{ a, b });
        try std.testing.expectEqual(@as(u256, @intFromBool(signed_a < signed_b)), slt);
        try std.testing.expectEqual(@as(u256, @intFromBool(signed_a > signed_b)), sgt);
        try std.testing.expectEqual(@as(u256, 1), slt + sgt + eq);

        try std.testing.expectEqual(@as(u256, @intFromBool(a == 0)), try evalOp(fork, Op.ISZERO, &[_]u256{a}));

        // De Morgan: NOT(a AND b) == NOT a OR NOT b.
        var left = Asm{};
        left.push(a);
        left.push(b);
        left.op(Op.AND);
        left.op(Op.NOT);
        var right = Asm{};
        right.push(a);
        right.op(Op.NOT);
        right.push(b);
        right.op(Op.NOT);
        right.op(Op.OR);
        try std.testing.expectEqual(try evalTop(fork, &left), try evalTop(fork, &right));

        try std.testing.expectEqual(@as(u256, 0), try evalOp(fork, Op.XOR, &[_]u256{ a, a }));
        try std.testing.expectEqual(a ^ b, try evalOp(fork, Op.XOR, &[_]u256{ a, b }));
        try std.testing.expectEqual(@as(u256, 0), try evalOp(fork, Op.AND, &[_]u256{ a, ~a }));
        try std.testing.expectEqual(max_u256, try evalOp(fork, Op.OR, &[_]u256{ a, ~a }));
        try std.testing.expectEqual(a, try evalOp(fork, Op.NOT, &[_]u256{~a}));

        // (a XOR b) XOR b == a.
        var involution = Asm{};
        involution.push(b);
        involution.push(b);
        involution.push(a);
        involution.op(Op.XOR);
        involution.op(Op.XOR);
        try std.testing.expectEqual(a, try evalTop(fork, &involution));

        // BYTE(i, x) picks big-endian byte i, 0 past the word.
        const index = random.uintLessThan(u8, 40);
        var be: [32]u8 = undefined;
        std.mem.writeInt(u256, &be, a, .big);
        const expected_byte: u256 = if (index < 32) be[index] else 0;
        try std.testing.expectEqual(expected_byte, try evalOp(fork, Op.BYTE, &[_]u256{ index, a }));

        // SIGNEXTEND(k, x): low bytes kept, high bits all equal the sign bit, idempotent.
        const k = random.uintLessThan(u8, 36);
        const extended = try evalOp(fork, Op.SIGNEXTEND, &[_]u256{ k, a });
        try std.testing.expectEqual(extended, try evalOp(fork, Op.SIGNEXTEND, &[_]u256{ k, extended }));
        if (k >= 31) {
            try std.testing.expectEqual(a, extended);
        } else {
            const bits: u8 = (k + 1) * 8;
            const low_mask = (@as(u256, 1) << bits) - 1;
            try std.testing.expectEqual(a & low_mask, extended & low_mask);
            const negative = (a >> (bits - 1)) & 1 == 1;
            try std.testing.expectEqual(if (negative) ~low_mask else @as(u256, 0), extended & ~low_mask);
        }
    }
}

test "property: EXP follows exponent laws and charges per exponent byte" {
    var prng = std.Random.DefaultPrng.init(0xa11_0007);
    const random = prng.random();

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        const base = randomWord(random);
        const m: u256 = random.int(u16);
        const n: u256 = random.int(u16);
        errdefer std.debug.print("EXP law failed: i={d} base=0x{x} m={d} n={d}\n", .{ i, base, m, n });

        try std.testing.expectEqual(@as(u256, 1), try evalOp(.OSAKA, Op.EXP, &[_]u256{ base, 0 }));
        try std.testing.expectEqual(base, try evalOp(.OSAKA, Op.EXP, &[_]u256{ base, 1 }));

        // base^(m+n) == base^m * base^n.
        const combined = try evalOp(.OSAKA, Op.EXP, &[_]u256{ base, m + n });
        const split = try evalOp(.OSAKA, Op.MUL, &[_]u256{
            try evalOp(.OSAKA, Op.EXP, &[_]u256{ base, m }),
            try evalOp(.OSAKA, Op.EXP, &[_]u256{ base, n }),
        });
        try std.testing.expectEqual(combined, split);

        // Gas: PUSH32 PUSH32 EXP STOP == 3 + 3 + 10 + per_byte * byte_length(exponent).
        const exponent = randomWord(random);
        const byte_length: u64 = (256 - @as(u64, @clz(exponent)) + 7) / 8;
        var a = Asm{};
        a.push(exponent);
        a.push(base);
        a.op(Op.EXP);
        a.op(Op.STOP);
        try std.testing.expectEqual(16 + 50 * byte_length, try gasUsed(.OSAKA, a.code(), default_gas));
        try std.testing.expectEqual(16 + 10 * byte_length, try gasUsed(.FRONTIER, a.code(), default_gas));
    }
}

test "property: DUPn and SWAPn address the right stack slots" {
    var prng = std.Random.DefaultPrng.init(0xa11_0008);
    const random = prng.random();

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        var values: [17]u256 = undefined;
        for (&values) |*value| value.* = random.int(u256);
        const n = 1 + random.uintLessThan(u8, 16); // 1..16
        const fork = randomFork(random);
        errdefer std.debug.print("DUP/SWAP law failed: i={d} fork={s} n={d}\n", .{ i, @tagName(fork), n });

        // values[16] is the top of the stack.
        var dup = Asm{};
        for (values) |value| dup.push(value);
        dup.op(Op.DUP1 + n - 1);
        try std.testing.expectEqual(values[17 - @as(usize, n)], try evalTop(fork, &dup));

        // After SWAPn the top holds the old slot n+1 ...
        var swap_top = Asm{};
        for (values) |value| swap_top.push(value);
        swap_top.op(Op.SWAP1 + n - 1);
        try std.testing.expectEqual(values[16 - @as(usize, n)], try evalTop(fork, &swap_top));

        // ... and slot n+1 holds the old top.
        var swap_deep = Asm{};
        for (values) |value| swap_deep.push(value);
        swap_deep.op(Op.SWAP1 + n - 1);
        var pops: u8 = 0;
        while (pops < n) : (pops += 1) swap_deep.op(Op.POP);
        try std.testing.expectEqual(values[16], try evalTop(fork, &swap_deep));

        // PUSHn zero-extends its immediate.
        const width = 1 + random.uintLessThan(u8, 32); // 1..32
        var immediate = [_]u8{0} ** 32;
        random.bytes(immediate[32 - @as(usize, width) ..]);
        var push = Asm{};
        push.op(Op.PUSH0 + width);
        for (immediate[32 - @as(usize, width) ..]) |byte| push.op(byte);
        try std.testing.expectEqual(std.mem.readInt(u256, &immediate, .big), try evalTop(fork, &push));
    }
}

test "property: the stack holds exactly 1024 words and PUSH0 starts at Shanghai" {
    var code = [_]u8{Op.PC} ** 1026;

    for (stability_forks) |fork| {
        // 1024 pushes then STOP succeeds.
        code[1024] = Op.STOP;
        const full = try run(fork, .transaction, code[0..1025], &[_]u8{}, default_gas);
        try std.testing.expect(full.success);
        try std.testing.expectEqual(default_gas - 2 * 1024, full.gas_left);

        // The 1025th push overflows.
        code[1024] = Op.PC;
        const overflow = try run(fork, .transaction, code[0..1025], &[_]u8{}, default_gas);
        try std.testing.expect(!overflow.success);
        try std.testing.expectEqual(@as(u64, 0), overflow.gas_left);
    }

    var push0 = Asm{};
    push0.op(Op.PUSH0);
    push0.returnTop();
    for ([_]primitives.Hardfork{ .SHANGHAI, .CANCUN, .PRAGUE, .OSAKA }) |fork| {
        const result = try run(fork, .transaction, push0.code(), &[_]u8{}, default_gas);
        try std.testing.expect(result.success);
        try std.testing.expectEqual(@as(u256, 0), result.words[0]);
        try std.testing.expectEqual(default_gas - 2 - return_top_gas, result.gas_left);
    }
    for ([_]primitives.Hardfork{ .FRONTIER, .BERLIN, .LONDON }) |fork| {
        const result = try run(fork, .transaction, push0.code(), &[_]u8{}, default_gas);
        try std.testing.expect(!result.success);
        try std.testing.expect(result.invalid_opcode);
    }
}

test "property: every opcode fails with fewer stack words than it needs" {
    const Requirement = struct { opcode: u8, needs: u8 };
    const fixed = [_]Requirement{
        .{ .opcode = Op.ADD, .needs = 2 },          .{ .opcode = Op.MUL, .needs = 2 },
        .{ .opcode = Op.SUB, .needs = 2 },          .{ .opcode = Op.DIV, .needs = 2 },
        .{ .opcode = Op.SDIV, .needs = 2 },         .{ .opcode = Op.MOD, .needs = 2 },
        .{ .opcode = Op.SMOD, .needs = 2 },         .{ .opcode = Op.ADDMOD, .needs = 3 },
        .{ .opcode = Op.MULMOD, .needs = 3 },       .{ .opcode = Op.EXP, .needs = 2 },
        .{ .opcode = Op.SIGNEXTEND, .needs = 2 },   .{ .opcode = Op.LT, .needs = 2 },
        .{ .opcode = Op.GT, .needs = 2 },           .{ .opcode = Op.SLT, .needs = 2 },
        .{ .opcode = Op.SGT, .needs = 2 },          .{ .opcode = Op.EQ, .needs = 2 },
        .{ .opcode = Op.ISZERO, .needs = 1 },       .{ .opcode = Op.AND, .needs = 2 },
        .{ .opcode = Op.OR, .needs = 2 },           .{ .opcode = Op.XOR, .needs = 2 },
        .{ .opcode = Op.NOT, .needs = 1 },          .{ .opcode = Op.BYTE, .needs = 2 },
        .{ .opcode = Op.SHL, .needs = 2 },          .{ .opcode = Op.SHR, .needs = 2 },
        .{ .opcode = Op.SAR, .needs = 2 },          .{ .opcode = Op.CLZ, .needs = 1 },
        .{ .opcode = Op.KECCAK256, .needs = 2 },    .{ .opcode = Op.POP, .needs = 1 },
        .{ .opcode = Op.MLOAD, .needs = 1 },        .{ .opcode = Op.MSTORE, .needs = 2 },
        .{ .opcode = Op.MSTORE8, .needs = 2 },      .{ .opcode = Op.SLOAD, .needs = 1 },
        .{ .opcode = Op.SSTORE, .needs = 2 },       .{ .opcode = Op.JUMP, .needs = 1 },
        .{ .opcode = Op.JUMPI, .needs = 2 },        .{ .opcode = Op.TLOAD, .needs = 1 },
        .{ .opcode = Op.TSTORE, .needs = 2 },       .{ .opcode = Op.MCOPY, .needs = 3 },
        .{ .opcode = Op.RETURN, .needs = 2 },       .{ .opcode = Op.REVERT, .needs = 2 },
        .{ .opcode = Op.CALL, .needs = 7 },         .{ .opcode = Op.CALLCODE, .needs = 7 },
        .{ .opcode = Op.DELEGATECALL, .needs = 6 }, .{ .opcode = Op.STATICCALL, .needs = 6 },
    };

    var requirements: [fixed.len + 37]Requirement = undefined;
    var count: usize = 0;
    for (fixed) |requirement| {
        requirements[count] = requirement;
        count += 1;
    }
    var n: u8 = 1;
    while (n <= 16) : (n += 1) {
        requirements[count] = .{ .opcode = Op.DUP1 + n - 1, .needs = n };
        requirements[count + 1] = .{ .opcode = Op.SWAP1 + n - 1, .needs = n + 1 };
        count += 2;
    }
    var topics: u8 = 0;
    while (topics <= 4) : (topics += 1) {
        requirements[count] = .{ .opcode = Op.LOG0 + topics, .needs = 2 + topics };
        count += 1;
    }
    try std.testing.expectEqual(requirements.len, count);

    for (requirements) |requirement| {
        var available: u8 = 0;
        while (available < requirement.needs) : (available += 1) {
            errdefer std.debug.print("underflow law failed: opcode=0x{x} available={d}\n", .{ requirement.opcode, available });
            var a = Asm{};
            var pushed: u8 = 0;
            while (pushed < available) : (pushed += 1) a.push1(0);
            a.op(requirement.opcode);
            a.push1(1);
            a.returnTop();
            const result = try run(.OSAKA, .transaction, a.code(), &[_]u8{}, default_gas);
            try std.testing.expect(!result.success);
            try std.testing.expectEqual(@as(u64, 0), result.gas_left);
        }
    }
}

// ============================================================================
// Part A.3: memory, MCOPY, transient storage
// ============================================================================

test "property: MSTORE/MSTORE8/MLOAD/MSIZE match a byte-array reference model" {
    var prng = std.Random.DefaultPrng.init(0x3e3_0001);
    const random = prng.random();

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        var model = [_]u8{0} ** 1024;
        var model_size: usize = 0;
        var a = Asm{};
        const fork = randomFork(random);
        errdefer std.debug.print("memory model failed: i={d} fork={s}\n", .{ i, @tagName(fork) });

        const op_count = 1 + random.uintLessThan(usize, 8);
        var step: usize = 0;
        while (step < op_count) : (step += 1) {
            const offset = random.uintLessThan(u16, 640);
            const value = randomWord(random);
            a.push(value);
            a.push2(offset);
            if (random.boolean()) {
                a.op(Op.MSTORE);
                std.mem.writeInt(u256, model[offset..][0..32], value, .big);
                model_size = @max(model_size, ceil32(@as(usize, offset) + 32));
            } else {
                a.op(Op.MSTORE8);
                model[offset] = @truncate(value);
                model_size = @max(model_size, ceil32(@as(usize, offset) + 1));
            }
        }

        const read_offset = random.uintLessThan(u16, 640);
        a.push2(read_offset);
        a.op(Op.MLOAD);
        model_size = @max(model_size, ceil32(@as(usize, read_offset) + 32));
        a.op(Op.MSIZE);
        a.push2(0x400);
        a.op(Op.MSTORE); // MSIZE at 0x400
        a.push2(0x420);
        a.op(Op.MSTORE); // loaded word at 0x420
        a.push1(0x40);
        a.push2(0x400);
        a.op(Op.RETURN);

        const result = try run(fork, .transaction, a.code(), &[_]u8{}, default_gas);
        try std.testing.expect(result.success);
        try std.testing.expectEqual(@as(usize, 64), result.output_len);
        try std.testing.expectEqual(@as(u256, model_size), result.words[0]);
        try std.testing.expectEqual(std.mem.readInt(u256, model[read_offset..][0..32], .big), result.words[1]);

        // 9 gas per store triple, 6 MLOAD, 2 MSIZE, 12 for the two result stores, 6 RETURN,
        // plus one expansion to the final 34 words (path independent).
        const expected_gas = 9 * @as(u64, op_count) + 26 + memoryCost(34);
        try std.testing.expectEqual(expected_gas, default_gas - result.gas_left);
    }
}

test "property: memory expansion gas is 3w + w^2/512, monotone, and charged once" {
    var prng = std.Random.DefaultPrng.init(0x3e3_0002);
    const random = prng.random();
    const gas: u64 = 10_000_000;

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        const first = random.uintLessThan(u32, 200_000) >> random.uintLessThan(u5, 12);
        const second = random.uintLessThan(u32, 200_000) >> random.uintLessThan(u5, 12);
        const low = @min(first, second);
        const high = @max(first, second);
        const fork = randomFork(random);
        errdefer std.debug.print("expansion gas law failed: i={d} fork={s} low={d} high={d}\n", .{ i, @tagName(fork), low, high });

        var used: [2]u64 = undefined;
        for ([_]u32{ low, high }, 0..) |offset, slot| {
            const words: u64 = (@as(u64, offset) + 32 + 31) / 32;

            // PUSH1 PUSH4 MSTORE STOP.
            var store = Asm{};
            store.push1(1);
            store.push4(offset);
            store.op(Op.MSTORE);
            store.op(Op.STOP);
            used[slot] = try gasUsed(fork, store.code(), gas);
            try std.testing.expectEqual(9 + memoryCost(words), used[slot]);

            // PUSH4 MLOAD STOP expands identically.
            var load = Asm{};
            load.push4(offset);
            load.op(Op.MLOAD);
            load.op(Op.STOP);
            try std.testing.expectEqual(6 + memoryCost(words), try gasUsed(fork, load.code(), gas));

            // Touching the same word again costs no further expansion.
            var twice = Asm{};
            twice.push1(1);
            twice.push4(offset);
            twice.op(Op.MSTORE);
            twice.push1(2);
            twice.push4(offset);
            twice.op(Op.MSTORE);
            twice.op(Op.STOP);
            try std.testing.expectEqual(18 + memoryCost(words), try gasUsed(fork, twice.code(), gas));

            // MSTORE8 expands to the word containing the byte.
            var byte_store = Asm{};
            byte_store.push1(1);
            byte_store.push4(offset);
            byte_store.op(Op.MSTORE8);
            byte_store.op(Op.STOP);
            const byte_words: u64 = (@as(u64, offset) + 1 + 31) / 32;
            try std.testing.expectEqual(9 + memoryCost(byte_words), try gasUsed(fork, byte_store.code(), gas));
        }
        try std.testing.expect(used[0] <= used[1]);
    }
}

test "property: MCOPY has memmove semantics on overlap with exact gas (Cancun, Osaka)" {
    var prng = std.Random.DefaultPrng.init(0x3e3_0003);
    const random = prng.random();

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        const fork: primitives.Hardfork = if (i % 2 == 0) .CANCUN else .OSAKA;
        var model = [_]u8{0} ** 288;
        var a = Asm{};

        var word: usize = 0;
        while (word < 3) : (word += 1) {
            const value = random.int(u256);
            std.mem.writeInt(u256, model[word * 32 ..][0..32], value, .big);
            a.push(value);
            a.push1(@intCast(word * 32));
            a.op(Op.MSTORE);
        }

        const length: usize = random.uintAtMost(u8, 64);
        const source: usize = random.uintAtMost(u8, 120);
        const dest: usize = random.uintAtMost(u8, 120);
        errdefer std.debug.print("MCOPY law failed: i={d} fork={s} dest={d} source={d} length={d}\n", .{ i, @tagName(fork), dest, source, length });

        a.push1(@intCast(length));
        a.push1(@intCast(source));
        a.push1(@intCast(dest));
        a.op(Op.MCOPY);
        a.op(Op.MSIZE);
        a.push2(0x100);
        a.op(Op.MSTORE); // MSIZE at word 8
        a.push2(0x120);
        a.push1(0);
        a.op(Op.RETURN);

        var scratch: [64]u8 = undefined;
        @memcpy(scratch[0..length], model[source..][0..length]);
        @memcpy(model[dest..][0..length], scratch[0..length]);
        const expected_size: usize = if (length == 0) 96 else @max(96, ceil32(@max(source, dest) + length));

        const result = try run(fork, .transaction, a.code(), &[_]u8{}, default_gas);
        try std.testing.expect(result.success);
        try std.testing.expectEqual(@as(usize, 288), result.output_len);
        try std.testing.expectEqual(@as(u256, expected_size), result.words[8]);
        var check: usize = 0;
        while (check < 8) : (check += 1) {
            try std.testing.expectEqual(std.mem.readInt(u256, model[check * 32 ..][0..32], .big), result.words[check]);
        }

        // 27 setup + 9 pushes + 3 base + 3/word copied + 2 MSIZE + 6 + 6, plus 9 words of memory.
        const copy_words: u64 = (@as(u64, length) + 31) / 32;
        try std.testing.expectEqual(53 + 3 * copy_words + memoryCost(9), default_gas - result.gas_left);

        // Before Cancun the opcode does not exist.
        if (i % 50 == 0) {
            const shanghai = try run(.SHANGHAI, .transaction, a.code(), &[_]u8{}, default_gas);
            try std.testing.expect(!shanghai.success);
            try std.testing.expect(shanghai.invalid_opcode);
        }

        // A zero-length MCOPY never expands memory, whatever the offsets: 3 pushes + 3 + MSIZE.
        var empty = Asm{};
        empty.push1(0);
        empty.push(randomWord(random));
        empty.push(randomWord(random));
        empty.op(Op.MCOPY);
        empty.op(Op.MSIZE);
        empty.returnTop();
        const empty_result = try run(fork, .transaction, empty.code(), &[_]u8{}, default_gas);
        try std.testing.expect(empty_result.success);
        try std.testing.expectEqual(@as(u256, 0), empty_result.words[0]);
        try std.testing.expectEqual(@as(u64, 14) + return_top_gas, default_gas - empty_result.gas_left);
    }
}

test "property: TSTORE/TLOAD round-trip at a flat 100 gas and reset between transactions" {
    var prng = std.Random.DefaultPrng.init(0x1153_0001);
    const random = prng.random();
    const forks = [_]primitives.Hardfork{ .CANCUN, .PRAGUE, .OSAKA };

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        const fork = forks[i % forks.len];
        const slot = randomWord(random);
        const value = randomWord(random);
        const other_slot = slot +% 1 +% random.int(u64);
        errdefer std.debug.print("transient law failed: i={d} fork={s} slot=0x{x} value=0x{x}\n", .{ i, @tagName(fork), slot, value });

        var store_load = Asm{};
        store_load.push(value);
        store_load.push(slot);
        store_load.op(Op.TSTORE);
        store_load.push(slot);
        store_load.op(Op.TLOAD);
        store_load.returnTop();
        const round_trip = try run(fork, .transaction, store_load.code(), &[_]u8{}, default_gas);
        try std.testing.expect(round_trip.success);
        try std.testing.expectEqual(value, round_trip.words[0]);
        // 3 pushes + TSTORE 100 + TLOAD 100, never a cold surcharge.
        try std.testing.expectEqual(@as(u64, 209) + return_top_gas, default_gas - round_trip.gas_left);

        // A different slot stays zero.
        var store_other = Asm{};
        store_other.push(value);
        store_other.push(slot);
        store_other.op(Op.TSTORE);
        store_other.push(other_slot);
        store_other.op(Op.TLOAD);
        try std.testing.expectEqual(@as(u256, 0), try evalTop(fork, &store_other));

        // Transaction 1 stores, transaction 2 on the same Evm reads zero.
        var store_only = Asm{};
        store_only.push(value);
        store_only.push(slot);
        store_only.op(Op.TSTORE);
        store_only.op(Op.STOP);
        var load_only = Asm{};
        load_only.push(slot);
        load_only.op(Op.TLOAD);
        load_only.returnTop();

        var vm: Evm = undefined;
        try vm.init(std.testing.allocator, null, fork, null, originAddress(), 0, null);
        defer vm.deinit();
        try vm.code.put(contractAddress(), store_only.code());
        const first = vm.call(.{ .call = .{ .caller = originAddress(), .to = contractAddress(), .value = 0, .input = &[_]u8{}, .gas = default_gas } });
        try std.testing.expect(first.success);
        try vm.code.put(contractAddress(), load_only.code());
        const second = summarize(vm.call(.{ .call = .{ .caller = originAddress(), .to = contractAddress(), .value = 0, .input = &[_]u8{}, .gas = default_gas } }));
        try std.testing.expect(second.success);
        try std.testing.expectEqual(@as(u256, 0), second.words[0]);
    }

    // Before Cancun both opcodes are invalid.
    var early = Asm{};
    early.push1(1);
    early.op(Op.TLOAD);
    early.returnTop();
    const shanghai = try run(.SHANGHAI, .transaction, early.code(), &[_]u8{}, default_gas);
    try std.testing.expect(!shanghai.success);
    try std.testing.expect(shanghai.invalid_opcode);
}

const CalleeEnding = enum { stop, revert, invalid };

/// Run caller code at `contractAddress()` and helper code at `helperAddress()` in one
/// transaction through `inner_call`, so nested frames see both contracts.
fn runTwoContracts(fork: primitives.Hardfork, caller_code: []const u8, helper_code: []const u8) !Summary {
    var vm: Evm = undefined;
    try vm.init(std.testing.allocator, null, fork, null, originAddress(), 0, null);
    defer vm.deinit();
    try vm.initTransactionState(null);
    try vm.preWarmTransaction(contractAddress());
    try vm.code.put(contractAddress(), caller_code);
    try vm.code.put(helperAddress(), helper_code);
    return summarize(vm.inner_call(.{ .call = .{
        .caller = originAddress(),
        .to = contractAddress(),
        .value = 0,
        .input = &[_]u8{},
        .gas = default_gas,
    } }));
}

test "property: a reverted or failed DELEGATECALL frame rolls back its TSTOREs" {
    var prng = std.Random.DefaultPrng.init(0x1153_0002);
    const random = prng.random();
    const forks = [_]primitives.Hardfork{ .CANCUN, .PRAGUE, .OSAKA };

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        const fork = forks[i % forks.len];
        const slot = randomWord(random);
        const outer_value = randomWord(random);
        const inner_value = randomWord(random);
        const ending: CalleeEnding = @enumFromInt(random.uintLessThan(u2, 3));
        errdefer std.debug.print("TSTORE rollback (delegatecall) failed: i={d} fork={s} ending={s}\n", .{ i, @tagName(fork), @tagName(ending) });

        // Helper: TSTORE(slot, inner_value) in the caller's context, then end.
        var helper = Asm{};
        helper.push(inner_value);
        helper.push(slot);
        helper.op(Op.TSTORE);
        switch (ending) {
            .stop => helper.op(Op.STOP),
            .revert => {
                helper.push1(0);
                helper.push1(0);
                helper.op(Op.REVERT);
            },
            .invalid => helper.op(Op.INVALID),
        }

        // Caller: TSTORE(slot, outer_value); DELEGATECALL helper; return (success, TLOAD(slot)).
        var caller = Asm{};
        caller.push(outer_value);
        caller.push(slot);
        caller.op(Op.TSTORE);
        caller.push1(0); // out length
        caller.push1(0); // out offset
        caller.push1(0); // in length
        caller.push1(0); // in offset
        caller.push2(0xbbbb);
        caller.op(Op.GAS);
        caller.op(Op.DELEGATECALL);
        caller.push(slot);
        caller.op(Op.TLOAD);
        caller.push1(0x20);
        caller.op(Op.MSTORE); // TLOAD result at word 1
        caller.push1(0);
        caller.op(Op.MSTORE); // success flag at word 0
        caller.push1(0x40);
        caller.push1(0);
        caller.op(Op.RETURN);

        const result = try runTwoContracts(fork, caller.code(), helper.code());
        try std.testing.expect(result.success);
        try std.testing.expectEqual(@as(usize, 64), result.output_len);
        if (ending == .stop) {
            try std.testing.expectEqual(@as(u256, 1), result.words[0]);
            try std.testing.expectEqual(inner_value, result.words[1]);
        } else {
            try std.testing.expectEqual(@as(u256, 0), result.words[0]);
            try std.testing.expectEqual(outer_value, result.words[1]);
        }
    }
}

test "property: a reverted CALL frame leaves no transient storage behind in the callee" {
    var prng = std.Random.DefaultPrng.init(0x1153_0003);
    const random = prng.random();
    const forks = [_]primitives.Hardfork{ .CANCUN, .PRAGUE, .OSAKA };

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        const fork = forks[i % forks.len];
        const slot = randomWord(random);
        const value = randomWord(random) | 1; // non-zero so a surviving write is visible
        const ending: CalleeEnding = @enumFromInt(random.uintLessThan(u2, 3));
        errdefer std.debug.print("TSTORE rollback (call) failed: i={d} fork={s} ending={s}\n", .{ i, @tagName(fork), @tagName(ending) });

        // Helper: with calldata, return TLOAD(slot); without, TSTORE(slot, value) then end.
        var helper = Asm{};
        helper.op(Op.CALLDATASIZE);
        helper.op(Op.PUSH1);
        const jump_operand = helper.len;
        helper.op(0); // patched below
        helper.op(Op.JUMPI);
        helper.push(value);
        helper.push(slot);
        helper.op(Op.TSTORE);
        switch (ending) {
            .stop => helper.op(Op.STOP),
            .revert => {
                helper.push1(0);
                helper.push1(0);
                helper.op(Op.REVERT);
            },
            .invalid => helper.op(Op.INVALID),
        }
        helper.buf[jump_operand] = @intCast(helper.len);
        helper.op(Op.JUMPDEST);
        helper.push(slot);
        helper.op(Op.TLOAD);
        helper.returnTop();

        // Caller: CALL helper with no calldata (the write), then with 1 byte (the read).
        var caller = Asm{};
        caller.push1(0); // out length
        caller.push1(0); // out offset
        caller.push1(0); // in length
        caller.push1(0); // in offset
        caller.push1(0); // value
        caller.push2(0xbbbb);
        caller.op(Op.GAS);
        caller.op(Op.CALL);
        caller.push1(0x40);
        caller.op(Op.MSTORE); // first success flag at word 2
        caller.push1(0x20); // out length
        caller.push1(0); // out offset
        caller.push1(1); // in length
        caller.push1(0); // in offset
        caller.push1(0); // value
        caller.push2(0xbbbb);
        caller.op(Op.GAS);
        caller.op(Op.CALL);
        caller.push1(0x20);
        caller.op(Op.MSTORE); // second success flag at word 1
        caller.push1(0x60);
        caller.push1(0);
        caller.op(Op.RETURN);

        const result = try runTwoContracts(fork, caller.code(), helper.code());
        try std.testing.expect(result.success);
        try std.testing.expectEqual(@as(usize, 96), result.output_len);
        try std.testing.expectEqual(@as(u256, 1), result.words[1]);
        if (ending == .stop) {
            try std.testing.expectEqual(@as(u256, 1), result.words[2]);
            try std.testing.expectEqual(value, result.words[0]);
        } else {
            try std.testing.expectEqual(@as(u256, 0), result.words[2]);
            try std.testing.expectEqual(@as(u256, 0), result.words[0]);
        }
    }
}

// ============================================================================
// Part A.4: EIP-7951 P256VERIFY (0x0100)
// ============================================================================

// RIP-7212 / EIP-7951 reference vector (first entry of go-ethereum's p256Verify.json).
const p256_reference_vector_hex = "4cee90eb86eaa050036147a12d49004b6b9c72bd725d39d4785011fe190f0b4d" ++
    "a73bd4903f0ce3b639bbbf6e8e80d16931ff4bcf5993d58468e8fb19086e8cac" ++
    "36dbcd03009df8c59286b162af3bd7fcc0450c9aa81be5d10d312af6c66b1d60" ++
    "4aebd3099c618202fcfe16ae7770b0c49ab5eadf74b754204a3bb6060e44eff3" ++
    "7618b065f9832de4ca6ca971a7a1adc826d0f7c00181a5fb2ddf79ae00b4e10e";

fn p256ReferenceVector() ![p256_input_length]u8 {
    var out: [p256_input_length]u8 = undefined;
    const decoded = try std.fmt.hexToBytes(&out, p256_reference_vector_hex);
    try std.testing.expectEqual(p256_input_length, decoded.len);
    return out;
}

test "property: P256VERIFY top-level dispatch charges 6900 on Osaka and is a plain account before" {
    var prng = std.Random.DefaultPrng.init(0x7951_0001);
    const random = prng.random();
    const pre_osaka = [_]primitives.Hardfork{ .PRAGUE, .CANCUN, .BERLIN, .FRONTIER };

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        var buffer: [320]u8 = undefined;
        const length: usize = if (i % 3 == 0) p256_input_length else random.uintLessThan(usize, buffer.len + 1);
        random.bytes(buffer[0..length]);
        const input = buffer[0..length];
        const gas = p256_gas + random.uintLessThan(u64, 200_000);
        errdefer std.debug.print("P256 dispatch law failed: i={d} length={d} gas={d}\n", .{ i, length, gas });

        // Osaka: every malformed or unverifiable input succeeds with empty output for 6900 gas.
        const osaka = try callP256Directly(.OSAKA, input, gas);
        try std.testing.expect(osaka.success);
        try std.testing.expectEqual(gas - p256_gas, osaka.gas_left);
        try std.testing.expectEqual(@as(usize, 0), osaka.output_len);

        // Osaka with less than 6900 gas fails and burns everything.
        const short_gas = random.uintLessThan(u64, p256_gas);
        const starved = try callP256Directly(.OSAKA, input, short_gas);
        try std.testing.expect(!starved.success);
        try std.testing.expectEqual(@as(u64, 0), starved.gas_left);
        try std.testing.expectEqual(@as(usize, 0), starved.output_len);

        // Before Osaka 0x0100 is an empty account: success, no output, no gas charged.
        const fork = pre_osaka[i % pre_osaka.len];
        const before = try callP256Directly(fork, input, gas);
        try std.testing.expect(before.success);
        try std.testing.expectEqual(gas, before.gas_left);
        try std.testing.expectEqual(@as(usize, 0), before.output_len);
        const before_starved = try callP256Directly(fork, input, short_gas);
        try std.testing.expect(before_starved.success);
        try std.testing.expectEqual(short_gas, before_starved.gas_left);
    }

    // The valid vector returns the 32-byte word 1 on Osaka only.
    const vector = try p256ReferenceVector();
    const valid = try callP256Directly(.OSAKA, &vector, 100_000);
    try std.testing.expect(valid.success);
    try std.testing.expectEqual(@as(u64, 100_000 - p256_gas), valid.gas_left);
    try std.testing.expectEqual(@as(usize, 32), valid.output_len);
    try std.testing.expectEqual(@as(u256, 1), valid.words[0]);

    const exact = try callP256Directly(.OSAKA, &vector, p256_gas);
    try std.testing.expect(exact.success);
    try std.testing.expectEqual(@as(u64, 0), exact.gas_left);
    try std.testing.expectEqual(@as(usize, 32), exact.output_len);

    const prague = try callP256Directly(.PRAGUE, &vector, 100_000);
    try std.testing.expect(prague.success);
    try std.testing.expectEqual(@as(u64, 100_000), prague.gas_left);
    try std.testing.expectEqual(@as(usize, 0), prague.output_len);

    // Any single flipped bit, truncation, or extension turns the output empty.
    var mutation: usize = 0;
    while (mutation < 8) : (mutation += 1) {
        var mutated = vector;
        mutated[random.uintLessThan(usize, 32)] ^= @as(u8, 1) << random.int(u3);
        const flipped = try callP256Directly(.OSAKA, &mutated, 100_000);
        try std.testing.expect(flipped.success);
        try std.testing.expectEqual(@as(u64, 100_000 - p256_gas), flipped.gas_left);
        try std.testing.expectEqual(@as(usize, 0), flipped.output_len);
    }
    const truncated = try callP256Directly(.OSAKA, vector[0 .. p256_input_length - 1], 100_000);
    try std.testing.expect(truncated.success);
    try std.testing.expectEqual(@as(usize, 0), truncated.output_len);
    var extended_input = [_]u8{0} ** (p256_input_length + 1);
    @memcpy(extended_input[0..p256_input_length], &vector);
    const extended = try callP256Directly(.OSAKA, &extended_input, 100_000);
    try std.testing.expect(extended.success);
    try std.testing.expectEqual(@as(usize, 0), extended.output_len);
}

/// Emit: PUSH1 0, PUSH1 0, PUSH1 in_length, PUSH1 0, PUSH2 0x0100, GAS, STATICCALL, POP.
/// Costs 19 gas plus the STATICCALL itself.
fn emitP256Probe(a: *Asm, in_length: u8) void {
    a.push1(0); // out length
    a.push1(0); // out offset
    a.push1(in_length);
    a.push1(0); // in offset
    a.push2(0x0100);
    a.op(Op.GAS);
    a.op(Op.STATICCALL);
    a.op(Op.POP);
}

test "property: P256VERIFY is warm from the first access on Osaka and cold-then-warm before" {
    var prng = std.Random.DefaultPrng.init(0x7951_0002);
    const random = prng.random();
    const pre_osaka = [_]primitives.Hardfork{ .PRAGUE, .CANCUN, .SHANGHAI, .BERLIN };

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        const in_length = random.int(u8);
        errdefer std.debug.print("P256 warm-access law failed: i={d} in_length={d}\n", .{ i, in_length });

        // Pre-expand memory to 512 bytes so neither probe pays expansion, then sample GAS
        // before, between, and after two identical STATICCALLs to 0x0100.
        var a = Asm{};
        a.push1(0);
        a.push2(0x1ff);
        a.op(Op.MSTORE8);
        a.op(Op.GAS);
        emitP256Probe(&a, in_length);
        a.op(Op.GAS);
        emitP256Probe(&a, in_length);
        a.op(Op.GAS);
        a.push2(0x240);
        a.op(Op.MSTORE); // third sample
        a.push2(0x220);
        a.op(Op.MSTORE); // second sample
        a.push2(0x200);
        a.op(Op.MSTORE); // first sample
        a.push1(0x60);
        a.push2(0x200);
        a.op(Op.RETURN);

        // Each interval is 19 (probe) + 2 (closing GAS) + the STATICCALL cost.
        const osaka = try run(.OSAKA, .transaction, a.code(), &[_]u8{}, 100_000);
        try std.testing.expect(osaka.success);
        const osaka_first = osaka.words[0] - osaka.words[1];
        const osaka_second = osaka.words[1] - osaka.words[2];
        try std.testing.expectEqual(@as(u256, 21 + 100 + p256_gas), osaka_first);
        try std.testing.expectEqual(osaka_first, osaka_second);

        const fork = pre_osaka[i % pre_osaka.len];
        const before = try run(fork, .transaction, a.code(), &[_]u8{}, 100_000);
        try std.testing.expect(before.success);
        const before_first = before.words[0] - before.words[1];
        const before_second = before.words[1] - before.words[2];
        try std.testing.expectEqual(@as(u256, 21 + 2600), before_first);
        try std.testing.expectEqual(@as(u256, 21 + 100), before_second);

        // Cold-versus-warm gap before Osaka, and the precompile price on a warm access.
        try std.testing.expectEqual(@as(u256, 2500), before_first - before_second);
        try std.testing.expectEqual(@as(u256, p256_gas), osaka_second - before_second);
    }
}

const ForwardedGas = enum { all, exact, insufficient };

test "property: P256VERIFY via STATICCALL returns 32 bytes when valid and nothing otherwise" {
    var prng = std.Random.DefaultPrng.init(0x7951_0003);
    const random = prng.random();
    const vector = try p256ReferenceVector();
    const sentinel: u256 = 0x5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e;

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        var buffer: [320]u8 = undefined;
        var length: usize = p256_input_length;
        const valid = i % 30 == 0;
        if (valid) {
            @memcpy(buffer[0..p256_input_length], &vector);
        } else {
            if (i % 2 == 0) length = random.uintLessThan(usize, buffer.len + 1);
            random.bytes(buffer[0..length]);
        }
        const forwarded: ForwardedGas = @enumFromInt(random.uintLessThan(u2, 3));
        errdefer std.debug.print("P256 output law failed: i={d} valid={} length={d} forwarded={s}\n", .{ i, valid, length, @tagName(forwarded) });

        // Copy calldata to memory, plant a sentinel in the output word, STATICCALL 0x0100,
        // return (output word, success flag, RETURNDATASIZE).
        var a = Asm{};
        a.op(Op.CALLDATASIZE);
        a.push1(0);
        a.push1(0);
        a.op(Op.CALLDATACOPY);
        a.push(sentinel);
        a.push2(0x200);
        a.op(Op.MSTORE);
        a.push1(0x20); // out length
        a.push2(0x200); // out offset
        a.op(Op.CALLDATASIZE); // in length
        a.push1(0); // in offset
        a.push2(0x0100);
        switch (forwarded) {
            .all => a.op(Op.GAS),
            .exact => a.push2(6900),
            .insufficient => a.push2(6899),
        }
        a.op(Op.STATICCALL);
        a.push2(0x220);
        a.op(Op.MSTORE);
        a.op(Op.RETURNDATASIZE);
        a.push2(0x240);
        a.op(Op.MSTORE);
        a.push1(0x60);
        a.push2(0x200);
        a.op(Op.RETURN);

        const osaka = try run(.OSAKA, .transaction, a.code(), buffer[0..length], 100_000);
        try std.testing.expect(osaka.success);
        try std.testing.expectEqual(@as(usize, 96), osaka.output_len);
        if (forwarded == .insufficient) {
            try std.testing.expectEqual(sentinel, osaka.words[0]);
            try std.testing.expectEqual(@as(u256, 0), osaka.words[1]);
            try std.testing.expectEqual(@as(u256, 0), osaka.words[2]);
        } else if (valid) {
            try std.testing.expectEqual(@as(u256, 1), osaka.words[0]);
            try std.testing.expectEqual(@as(u256, 1), osaka.words[1]);
            try std.testing.expectEqual(@as(u256, 32), osaka.words[2]);
        } else {
            try std.testing.expectEqual(sentinel, osaka.words[0]);
            try std.testing.expectEqual(@as(u256, 1), osaka.words[1]);
            try std.testing.expectEqual(@as(u256, 0), osaka.words[2]);
        }

        // Prague: no precompile, so the call always succeeds with no return data.
        const prague = try run(.PRAGUE, .transaction, a.code(), buffer[0..length], 100_000);
        try std.testing.expect(prague.success);
        try std.testing.expectEqual(sentinel, prague.words[0]);
        try std.testing.expectEqual(@as(u256, 1), prague.words[1]);
        try std.testing.expectEqual(@as(u256, 0), prague.words[2]);

        // Osaka pays exactly the precompile price more than Prague, minus the cold surcharge
        // Prague pays for the unwarmed address, when the precompile runs.
        if (forwarded != .insufficient) {
            const osaka_used = 100_000 - osaka.gas_left;
            const prague_used = 100_000 - prague.gas_left;
            try std.testing.expectEqual(prague_used + p256_gas + 100, osaka_used + 2600);
        }
    }
}

// ============================================================================
// Part A.5: specification mismatches found by reading the interpreter
// ============================================================================

test "KNOWN-BUG: zero-length CALLDATACOPY/CODECOPY/RETURNDATACOPY/EXTCODECOPY charge no memory expansion" {
    // Spec: a zero-size copy never extends memory (calculate_gas_extend_memory skips size 0).
    // src/instructions/handlers_context.zig calldatacopy, codecopy, extcodecopy and
    // returndatacopy call `frame.memoryExpansionCost(dest + len)` and charge it even when
    // the length is 0.
    var prng = std.Random.DefaultPrng.init(0xb06_0001);
    const random = prng.random();
    const copy_opcodes = [_]u8{ Op.CALLDATACOPY, Op.CODECOPY, Op.RETURNDATACOPY, Op.EXTCODECOPY };

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        const opcode = copy_opcodes[i % copy_opcodes.len];
        // Below 2^24 so the interpreter's saturated expansion cost cannot overflow.
        const dest: u24 = 33 + random.uintLessThan(u24, 0xff_0000);
        errdefer std.debug.print("zero-length copy gas failed: i={d} opcode=0x{x} dest={d}\n", .{ i, opcode, dest });

        var a = Asm{};
        a.push1(0); // length
        a.push1(0); // source offset
        a.push3(dest);
        if (opcode == Op.EXTCODECOPY) a.op(Op.ADDRESS); // warm: the transaction target
        a.op(opcode);
        a.op(Op.MSIZE);
        a.returnTop();

        const result = try run(.OSAKA, .transaction, a.code(), &[_]u8{ 1, 2, 3 }, default_gas);
        try std.testing.expect(result.success);
        try std.testing.expectEqual(@as(u256, 0), result.words[0]);
        // 3 pushes (9) + copy base + MSIZE (2) + return-top.
        const copy_gas: u64 = if (opcode == Op.EXTCODECOPY) 2 + 100 else 3;
        try std.testing.expectEqual(9 + copy_gas + 2 + return_top_gas, default_gas - result.gas_left);
    }
}

test "KNOWN-BUG: zero-length copies and logs succeed at any 256-bit memory offset" {
    // Spec: with size 0 the memory offset is never used. The interpreter rejects offsets
    // above u32 with OutOfBounds before looking at the length:
    // `std.math.cast(u32, dest_offset) orelse return error.OutOfBounds` in calldatacopy and
    // codecopy (src/instructions/handlers_context.zig) and the same cast of `offset` in
    // log (src/instructions/handlers_log.zig).
    var prng = std.Random.DefaultPrng.init(0xb06_0002);
    const random = prng.random();
    const opcodes = [_]u8{ Op.CALLDATACOPY, Op.CODECOPY, Op.LOG0 };

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        const opcode = opcodes[i % opcodes.len];
        const offset = (randomWord(random) | (@as(u256, 1) << 32));
        errdefer std.debug.print("zero-length huge-offset op failed: i={d} opcode=0x{x} offset=0x{x}\n", .{ i, opcode, offset });

        var a = Asm{};
        a.push1(0); // length
        if (opcode != Op.LOG0) a.push1(0); // source offset
        a.push(offset);
        a.op(opcode);
        a.op(Op.MSIZE);
        a.returnTop();

        const result = try run(.OSAKA, .transaction, a.code(), &[_]u8{ 1, 2, 3 }, default_gas);
        try std.testing.expect(result.success);
        try std.testing.expectEqual(@as(u256, 0), result.words[0]);
    }
}

test "KNOWN-BUG: CALLDATACOPY/CODECOPY/CALLDATALOAD read zeros from source offsets near or above 2^32" {
    // Spec: reads past the end of calldata or code yield zero bytes for any 256-bit source
    // offset. The interpreter fails with OutOfBounds when the source offset exceeds u32
    // (`std.math.cast(u32, offset)` in calldatacopy and codecopy) or when offset + i wraps
    // u32 (`add_u32(off, i)` in calldataload, `add_u32(src_off, i)` in the copies). All in
    // src/instructions/handlers_context.zig.
    var prng = std.Random.DefaultPrng.init(0xb06_0003);
    const random = prng.random();
    const sentinel: u256 = max_u256;

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        const source: u256 = switch (i % 3) {
            0 => randomWord(random) | (@as(u256, 1) << 32),
            1 => 0xffff_ffff - @as(u256, random.uintLessThan(u8, 31)),
            else => (@as(u256, 1) << 32) + random.int(u32),
        };
        errdefer std.debug.print("far-source read failed: i={d} source=0x{x}\n", .{ i, source });

        for ([_]u8{ Op.CALLDATACOPY, Op.CODECOPY }) |opcode| {
            var a = Asm{};
            a.push(sentinel);
            a.push1(0);
            a.op(Op.MSTORE);
            a.push1(32); // length
            a.push(source);
            a.push1(0); // dest
            a.op(opcode);
            a.push1(0);
            a.op(Op.MLOAD);
            a.returnTop();
            const result = try run(.OSAKA, .transaction, a.code(), &[_]u8{ 0xaa, 0xbb, 0xcc }, default_gas);
            try std.testing.expect(result.success);
            try std.testing.expectEqual(@as(u256, 0), result.words[0]);
        }

        var load = Asm{};
        load.push(source);
        load.op(Op.CALLDATALOAD);
        load.returnTop();
        const loaded = try run(.OSAKA, .transaction, load.code(), &[_]u8{ 0xaa, 0xbb, 0xcc }, default_gas);
        try std.testing.expect(loaded.success);
        try std.testing.expectEqual(@as(u256, 0), loaded.words[0]);
    }
}

// ============================================================================
// Part A.6: arbitrary bytecode stability
// ============================================================================

fn isDefinedOpcode(opcode: u8) bool {
    return switch (opcode) {
        0x00...0x0b, 0x10...0x1e, 0x20, 0x30...0x4a, 0x50...0x5e, 0x5f...0x7f, 0x80...0x9f, 0xa0...0xa4, 0xf0...0xf5, 0xfa, 0xfd, 0xfe, 0xff => true,
        else => false,
    };
}

fn randomDefinedOpcode(random: std.Random) u8 {
    while (true) {
        const opcode = random.int(u8);
        if (isDefinedOpcode(opcode)) return opcode;
    }
}

const small_operands = [_]u8{ 0, 0, 0, 1, 2, 3, 4, 8, 16, 31, 32, 33, 64, 96, 128, 255 };

fn randomSmallOperand(random: std.Random) u8 {
    return small_operands[random.uintLessThan(usize, small_operands.len)];
}

/// Uniformly random bytes.
fn generateRandomBytes(random: std.Random, buffer: []u8) usize {
    const length = 1 + random.uintLessThan(usize, 192);
    random.bytes(buffer[0..length]);
    return length;
}

/// Mostly small pushes mixed with defined opcodes and a few wide random pushes, so
/// execution gets past the first few instructions.
fn generateOpcodeSoup(random: std.Random, buffer: []u8) usize {
    var length: usize = 0;
    const target = 8 + random.uintLessThan(usize, 150);
    while (length < target and length + 34 <= buffer.len) {
        switch (random.uintLessThan(u8, 10)) {
            0, 1, 2, 3, 4 => {
                buffer[length] = Op.PUSH1;
                buffer[length + 1] = randomSmallOperand(random);
                length += 2;
            },
            5 => {
                const width = 1 + random.uintLessThan(u8, 32);
                buffer[length] = Op.PUSH0 + width;
                random.bytes(buffer[length + 1 ..][0..width]);
                length += 1 + @as(usize, width);
            },
            else => {
                buffer[length] = randomDefinedOpcode(random);
                length += 1;
            },
        }
    }
    return length;
}

fn emitSmallPushes(random: std.Random, buffer: []u8, start: usize, count: usize) usize {
    var length = start;
    var pushed: usize = 0;
    while (pushed < count) : (pushed += 1) {
        buffer[length] = Op.PUSH1;
        buffer[length + 1] = randomSmallOperand(random);
        length += 2;
    }
    return length;
}

/// Stack-primed programs with backward jumps, self-calls, precompile calls, memory and
/// storage traffic. Needs a buffer of at least 512 bytes.
fn generateStructured(random: std.Random, buffer: []u8) usize {
    var jump_dests: [16]u8 = undefined;
    var jump_dest_count: usize = 0;

    var length = emitSmallPushes(random, buffer, 0, 12);
    const steps = 12 + random.uintLessThan(usize, 40);
    var step: usize = 0;
    while (step < steps and length + 24 <= buffer.len) : (step += 1) {
        switch (random.uintLessThan(u8, 12)) {
            0 => {
                if (length < 256 and jump_dest_count < jump_dests.len) {
                    jump_dests[jump_dest_count] = @intCast(length);
                    jump_dest_count += 1;
                }
                buffer[length] = Op.JUMPDEST;
                length += 1;
            },
            1 => {
                const conditional = random.boolean();
                if (conditional) length = emitSmallPushes(random, buffer, length, 1);
                buffer[length] = Op.PUSH1;
                buffer[length + 1] = if (jump_dest_count > 0)
                    jump_dests[random.uintLessThan(usize, jump_dest_count)]
                else
                    randomSmallOperand(random);
                buffer[length + 2] = if (conditional) Op.JUMPI else Op.JUMP;
                length += 3;
            },
            2 => {
                // Call this contract again: CALL/CALLCODE take 7 words, the others 6.
                const call_opcodes = [_]u8{ Op.CALL, Op.CALLCODE, Op.DELEGATECALL, Op.STATICCALL };
                const opcode = call_opcodes[random.uintLessThan(usize, call_opcodes.len)];
                const argument_count: usize = if (opcode == Op.CALL or opcode == Op.CALLCODE) 5 else 4;
                length = emitSmallPushes(random, buffer, length, argument_count);
                buffer[length] = Op.ADDRESS;
                buffer[length + 1] = Op.GAS;
                buffer[length + 2] = opcode;
                length += 3;
            },
            3 => {
                // STATICCALL a precompile address (0x01..0x13) or P256VERIFY (0x0100).
                length = emitSmallPushes(random, buffer, length, 4);
                const target: u16 = if (random.boolean()) 0x0100 else 1 + random.uintLessThan(u16, 0x13);
                buffer[length] = Op.PUSH2;
                std.mem.writeInt(u16, buffer[length + 1 ..][0..2], target, .big);
                buffer[length + 3] = Op.GAS;
                buffer[length + 4] = Op.STATICCALL;
                length += 5;
            },
            4 => {
                const memory_opcodes = [_]u8{ Op.MSTORE, Op.MSTORE8, Op.MLOAD, Op.MCOPY, Op.KECCAK256, Op.CALLDATACOPY, Op.CODECOPY, Op.RETURNDATACOPY, Op.LOG0 };
                length = emitSmallPushes(random, buffer, length, 3);
                buffer[length] = memory_opcodes[random.uintLessThan(usize, memory_opcodes.len)];
                length += 1;
            },
            5 => {
                const storage_opcodes = [_]u8{ Op.SSTORE, Op.SLOAD, Op.TSTORE, Op.TLOAD };
                length = emitSmallPushes(random, buffer, length, 2);
                buffer[length] = storage_opcodes[random.uintLessThan(usize, storage_opcodes.len)];
                length += 1;
            },
            6 => {
                // Unary and binary Osaka-relevant arithmetic on whatever is on the stack.
                const arithmetic_opcodes = [_]u8{ Op.CLZ, Op.SHL, Op.SHR, Op.SAR, Op.EXP, Op.MULMOD, Op.ADDMOD, Op.SIGNEXTEND, Op.NOT, Op.SDIV, Op.SMOD };
                buffer[length] = arithmetic_opcodes[random.uintLessThan(usize, arithmetic_opcodes.len)];
                length += 1;
            },
            else => {
                length = emitSmallPushes(random, buffer, length, random.uintLessThan(usize, 4));
                buffer[length] = randomDefinedOpcode(random);
                length += 1;
            },
        }
    }
    return length;
}

fn expectSameSummary(expected: Summary, actual: Summary) !void {
    try std.testing.expectEqual(expected.success, actual.success);
    try std.testing.expectEqual(expected.gas_left, actual.gas_left);
    try std.testing.expectEqual(expected.output_len, actual.output_len);
    try std.testing.expectEqual(expected.output_hash, actual.output_hash);
    try std.testing.expectEqual(expected.errored, actual.errored);
}

/// The invariants every execution must satisfy, whatever the bytes.
fn expectExecutionInvariants(summary: Summary, mode: RunMode, gas_limit: u64) !void {
    // gas_used <= gas_limit
    try std.testing.expect(summary.gas_left <= gas_limit);
    // A zero-value top-level call that halts exceptionally consumes all gas and produces
    // no output. (Nested and create results may carry an error name with gas returned.)
    if (mode == .transaction and summary.errored) {
        try std.testing.expect(!summary.success);
        try std.testing.expectEqual(@as(u64, 0), summary.gas_left);
        try std.testing.expectEqual(@as(usize, 0), summary.output_len);
    }
}

/// Run one program on one fork through both entry paths and check the invariants.
fn checkProgram(fork: primitives.Hardfork, code: []const u8, calldata: []const u8, gas_limit: u64) !Summary {
    const first = try run(fork, .transaction, code, calldata, gas_limit);
    try expectExecutionInvariants(first, .transaction, gas_limit);

    // Execution is a pure function of (fork, code, calldata, gas).
    const second = try run(fork, .transaction, code, calldata, gas_limit);
    try expectSameSummary(first, second);

    const nested = try run(fork, .nested, code, calldata, gas_limit);
    try expectExecutionInvariants(nested, .nested, gas_limit);

    return first;
}

test "property: random bytecode never panics, overspends gas, or leaks on six forks" {
    var prng = std.Random.DefaultPrng.init(0xf022_0001);
    const random = prng.random();
    const gas_limit: u64 = 100_000;

    var program: usize = 0;
    while (program < 240) : (program += 1) {
        var buffer: [512]u8 = undefined;
        const length = switch (program % 3) {
            0 => generateRandomBytes(random, &buffer),
            1 => generateOpcodeSoup(random, &buffer),
            else => generateStructured(random, &buffer),
        };
        const code = buffer[0..length];

        var calldata: [64]u8 = undefined;
        const calldata_length = random.uintLessThan(usize, calldata.len + 1);
        random.bytes(calldata[0..calldata_length]);

        for (stability_forks) |fork| {
            errdefer std.debug.print("stability failed: program={d} fork={s} code={x}\n", .{ program, @tagName(fork), code });
            _ = try checkProgram(fork, code, calldata[0..calldata_length], gas_limit);
        }
    }
}

test "property: unbounded self-recursion terminates within its gas limit on every fork" {
    // PUSH1 0 x5, ADDRESS, GAS, CALL, STOP: recurse with all available gas until gas or the
    // 1024-frame depth limit stops it (pre-Tangerine forks forward everything).
    const code = [_]u8{ 0x60, 0x00, 0x60, 0x00, 0x60, 0x00, 0x60, 0x00, 0x60, 0x00, Op.ADDRESS, Op.GAS, Op.CALL, Op.STOP };

    for (stability_forks) |fork| {
        errdefer std.debug.print("self-recursion failed: fork={s}\n", .{@tagName(fork)});
        const result = try run(fork, .nested, &code, &[_]u8{}, 100_000);
        try std.testing.expect(result.success);
        try std.testing.expect(result.gas_left <= 100_000);
    }
}

// ============================================================================
// Part B: native coverage-guided fuzz target
// ============================================================================

const fuzz_gas_limit: u64 = 100_000;
const fuzz_max_code_length: usize = 4096;

/// True when no byte of the code could make Osaka and Prague diverge: no CLZ, no
/// address-touching opcode (0x0100 is pre-warmed on Osaka only), no call or create
/// (precompile set and MODEXP pricing differ). Push data counts as a match, which only
/// makes the check more conservative.
fn isForkAgnostic(code: []const u8) bool {
    for (code) |byte| {
        switch (byte) {
            0x1e, 0x31, 0x3b, 0x3c, 0x3f, 0xf0, 0xf1, 0xf2, 0xf4, 0xf5, 0xfa, 0xff => return false,
            else => {},
        }
    }
    return true;
}

fn fuzzArbitraryBytecode(_: void, input: []const u8) anyerror!void {
    const code = input[0..@min(input.len, fuzz_max_code_length)];

    // The same bytes serve as calldata so CALLDATA* opcodes see fuzzer-controlled data.
    const osaka = try checkProgram(.OSAKA, code, code, fuzz_gas_limit);
    const prague = try checkProgram(.PRAGUE, code, code, fuzz_gas_limit);

    // Differential oracle: without Osaka-specific opcodes the two forks agree exactly.
    if (isForkAgnostic(code)) try expectSameSummary(prague, osaka);

    // The same bytes as init code.
    const created = try run(.OSAKA, .create, code, &[_]u8{}, fuzz_gas_limit);
    try std.testing.expect(created.gas_left <= fuzz_gas_limit);
}

test "fuzz: arbitrary bytecode on Osaka and Prague with bounded gas" {
    try std.testing.fuzz({}, fuzzArbitraryBytecode, .{
        .corpus = &.{
            // PUSH1 1, CLZ, return top
            "\x60\x01\x1e\x60\x00\x52\x60\x20\x60\x00\xf3",
            // TSTORE then TLOAD the same slot, return it
            "\x60\x2a\x60\x01\x5d\x60\x01\x5c\x60\x00\x52\x60\x20\x60\x00\xf3",
            // MSTORE, overlapping MCOPY, MSIZE
            "\x60\xff\x60\x00\x52\x60\x20\x60\x10\x60\x00\x5e\x59\x00",
            // STATICCALL P256VERIFY with 160 zero bytes, RETURNDATASIZE
            "\x60\x20\x60\xa0\x60\xa0\x60\x00\x61\x01\x00\x5a\xfa\x3d\x00",
            // JUMPDEST, PUSH1 0, JUMP: burn all gas in a loop
            "\x5b\x60\x00\x56",
            // JUMPDEST, PC, PUSH1 0, JUMP: overflow the stack
            "\x5b\x58\x60\x00\x56",
            // PUSH32 truncated by the end of code
            "\x7f\x01\x02",
            // CALL self with all gas (recursion in the nested path)
            "\x60\x00\x60\x00\x60\x00\x60\x00\x60\x00\x30\x5a\xf1\x00",
            // KECCAK256 of 32 bytes, MSTORE, LOG0
            "\x60\x20\x60\x00\x20\x60\x00\x52\x60\x20\x60\x00\xa0\x00",
            // RETURNDATACOPY past the (empty) return data
            "\x60\x01\x60\x00\x60\x00\x3e",
            // CREATE with empty init code, then SELFDESTRUCT to self
            "\x60\x00\x60\x00\x60\x00\xf0\x30\xff",
            // REVERT with 32 bytes of data
            "\x60\x2a\x60\x00\x52\x60\x20\x60\x00\xfd",
            // SSTORE then SLOAD, INVALID
            "\x60\x01\x60\x00\x55\x60\x00\x54\xfe",
            // Undefined opcode 0x0c
            "\x0c",
        },
    });
}

// ============================================================================
// Part C: memory arguments beyond what gas can pay for
//
// These run last. Each asserts the specification outcome: an ordinary out-of-gas failure,
// never an integer-overflow or @intCast panic. The first two guard overflows that were
// patched in the working copy while this suite was written (`+` became `+|`); the third
// still aborts the test process in Debug and ReleaseSafe.
// ============================================================================

test "regression: MLOAD/MSTORE/MSTORE8 at offsets in [2^24, 2^32) run out of gas" {
    // src/instructions/handlers_memory.zig mload, mstore and mstore8 add the base cost to
    // memoryExpansionCost, which returns maxInt(u64) past 16 MiB. The add must saturate.
    var prng = std.Random.DefaultPrng.init(0xb06_0101);
    const random = prng.random();
    const opcodes = [_]u8{ Op.MLOAD, Op.MSTORE, Op.MSTORE8 };

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        const opcode = opcodes[i % opcodes.len];
        const offset: u32 = 0x0100_0000 + random.uintLessThan(u32, 0xff00_0000);

        var a = Asm{};
        a.push1(1);
        a.push4(offset);
        a.op(opcode);
        a.op(Op.STOP);

        for (stability_forks) |fork| {
            const result = try run(fork, .transaction, a.code(), &[_]u8{}, default_gas);
            try std.testing.expect(!result.success);
            try std.testing.expectEqual(@as(u64, 0), result.gas_left);
        }
    }
}

test "regression: copy opcodes with a destination past 16 MiB run out of gas" {
    // src/instructions/handlers_context.zig calldatacopy, codecopy, extcodecopy and
    // returndatacopy add the maxInt(u64) expansion cost to the base and copy costs. The
    // add must saturate.
    var prng = std.Random.DefaultPrng.init(0xb06_0102);
    const random = prng.random();
    const opcodes = [_]u8{ Op.CALLDATACOPY, Op.CODECOPY, Op.EXTCODECOPY };

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        const opcode = opcodes[i % opcodes.len];
        const dest: u32 = 0x0100_0000 + random.uintLessThan(u32, 0xff00_0000);

        var a = Asm{};
        a.push1(1 + random.uintLessThan(u8, 64)); // length
        a.push1(0); // source offset
        a.push4(dest);
        if (opcode == Op.EXTCODECOPY) a.op(Op.ADDRESS);
        a.op(opcode);
        a.op(Op.STOP);

        const result = try run(.OSAKA, .transaction, a.code(), &[_]u8{ 1, 2, 3 }, default_gas);
        try std.testing.expect(!result.success);
        try std.testing.expectEqual(@as(u64, 0), result.gas_left);
    }
}

test "KNOWN-BUG(panic): CALL-family opcodes with out-of-range memory arguments run out of gas" {
    // src/instructions/handlers_system.zig call, callcode, delegatecall and staticcall
    // compute `in_end` and `out_end` as `@as(u64, @intCast(offset)) + @as(u64, @intCast(length))`
    // from u256 stack words before any gas is charged. Cases 0-2 below hit the casts and the
    // add; cases 3-4 cover the saturating expansion cost and the aligned-size cast.
    var prng = std.Random.DefaultPrng.init(0xb06_0103);
    const random = prng.random();
    const opcodes = [_]u8{ Op.CALL, Op.CALLCODE, Op.DELEGATECALL, Op.STATICCALL };

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        const opcode = opcodes[i % opcodes.len];
        const takes_value = opcode == Op.CALL or opcode == Op.CALLCODE;

        // A non-empty region whose end is beyond anything gas could pay for.
        var offset: u256 = 0;
        var length: u256 = 1;
        switch (i % 5) {
            0 => offset = randomWord(random) | (@as(u256, 1) << 64), // offset does not fit u64
            1 => length = randomWord(random) | (@as(u256, 1) << 64), // length does not fit u64
            2 => { // both fit u64, the sum does not
                offset = std.math.maxInt(u64);
                length = 1 + @as(u256, random.int(u32));
            },
            3 => offset = 0x0100_0000 + @as(u256, random.int(u32)), // past the 16 MiB cap
            else => offset = (@as(u256, 1) << 32) + random.int(u48), // aligned size exceeds u32
        }
        const use_output_region = random.boolean();

        var a = Asm{};
        if (use_output_region) {
            a.push(length); // out length
            a.push(offset); // out offset
            a.push1(0); // in length
            a.push1(0); // in offset
        } else {
            a.push1(0); // out length
            a.push1(0); // out offset
            a.push(length); // in length
            a.push(offset); // in offset
        }
        if (takes_value) a.push1(0);
        a.op(Op.ADDRESS);
        a.op(Op.GAS);
        a.op(opcode);
        a.op(Op.STOP);

        const result = try run(.OSAKA, .transaction, a.code(), &[_]u8{}, default_gas);
        try std.testing.expect(!result.success);
        try std.testing.expectEqual(@as(u64, 0), result.gas_left);
    }
}
