/// Micro-benchmarks for every EVM opcode family executed via Frame.executeOpcode.
const std = @import("std");
const bench = @import("bench_utils");
const primitives = @import("voltaire");
const evm_mod = @import("evm");
const EvmType = evm_mod.Evm(.{});
const FrameType = evm_mod.Frame(.{});
const Address = primitives.Address.Address;

fn resetFrame(frame: *FrameType) void {
    frame.stack.items.len = 0;
    frame.pc = 0;
    frame.gas_remaining = 1_000_000_000_000;
    frame.stopped = false;
    frame.reverted = false;
}

fn benchBinaryOp(frame: *FrameType, opcode: u8, a: u256, b: u256, iters: usize) !u64 {
    var timer = try std.time.Timer.start();
    var acc: u256 = 0;
    for (0..iters) |i| {
        frame.stack.items.len = 0;
        frame.pc = 0;
        frame.gas_remaining = 1_000_000_000;
        try frame.pushStack(b +% @as(u256, i));
        try frame.pushStack(a +% @as(u256, i));
        try frame.executeOpcode(opcode);
        acc +%= try frame.popStack();
    }
    std.mem.doNotOptimizeAway(acc);
    return timer.read();
}

fn benchUnaryOp(frame: *FrameType, opcode: u8, a: u256, iters: usize) !u64 {
    var timer = try std.time.Timer.start();
    var acc: u256 = 0;
    for (0..iters) |i| {
        frame.stack.items.len = 0;
        frame.pc = 0;
        frame.gas_remaining = 1_000_000_000;
        try frame.pushStack(a +% @as(u256, i));
        try frame.executeOpcode(opcode);
        acc +%= try frame.popStack();
    }
    std.mem.doNotOptimizeAway(acc);
    return timer.read();
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var suite = bench.BenchSuite.init(allocator, "core-evm/opcodes");
    defer suite.deinit();

    var evm: EvmType = undefined;
    const origin = Address{ .bytes = [_]u8{0x11} ** 20 };
    const target = Address{ .bytes = [_]u8{0x22} ** 20 };
    try evm.init(allocator, null, .OSAKA, null, origin, 0, .none);
    defer evm.deinit();
    try evm.initTransactionState(null);

    // Bytecode supporting PUSH0/PUSH1/PUSH32 and JUMPDEST at pc=35
    var code: [64]u8 = [_]u8{0} ** 64;
    code[0] = 0x5f; // PUSH0
    code[1] = 0x60; // PUSH1
    code[2] = 0x42;
    code[3] = 0x7f; // PUSH32
    @memset(code[4..36], 0xab);
    code[36] = 0x5b; // JUMPDEST

    const calldata = [_]u8{0xde} ** 256;

    var frame = try FrameType.init(allocator, &code, 1_000_000_000_000, origin, target, 0, &calldata, @ptrCast(&evm), .OSAKA, false);
    defer frame.deinit();

    const N: usize = 500_000;
    const a: u256 = 0x123456789abcdef0_fedcba9876543210_1122334455667788_99aabbccddeeff01;
    const b: u256 = 0x0000000000000001_0000000000000007_000000000000000d_0000000000000013;

    suite.section("Arithmetic Opcodes");
    try suite.record(bench.make_result("ADD (0x01)", N, try benchBinaryOp(&frame, 0x01, a, b, N)));
    try suite.record(bench.make_result("MUL (0x02)", N, try benchBinaryOp(&frame, 0x02, a, b, N)));
    try suite.record(bench.make_result("SUB (0x03)", N, try benchBinaryOp(&frame, 0x03, a, b, N)));
    try suite.record(bench.make_result("DIV (0x04)", N, try benchBinaryOp(&frame, 0x04, a, b, N)));
    try suite.record(bench.make_result("SDIV (0x05)", N, try benchBinaryOp(&frame, 0x05, a, b, N)));
    try suite.record(bench.make_result("MOD (0x06)", N, try benchBinaryOp(&frame, 0x06, a, b, N)));
    try suite.record(bench.make_result("EXP (0x0a, base=3, exp=200)", 100_000, try benchBinaryOp(&frame, 0x0a, 3, 200, 100_000)));
    {
        const iters: usize = 200_000;
        var timer = try std.time.Timer.start();
        var acc: u256 = 0;
        for (0..iters) |i| {
            frame.stack.items.len = 0;
            frame.pc = 0;
            frame.gas_remaining = 1_000_000_000;
            try frame.pushStack(b);
            try frame.pushStack(a +% @as(u256, i));
            try frame.pushStack(a);
            try frame.executeOpcode(0x09); // MULMOD
            acc +%= try frame.popStack();
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("MULMOD (0x09)", iters, timer.read()));
    }

    suite.section("Comparison & Bitwise Opcodes (incl. Osaka CLZ)");
    try suite.record(bench.make_result("LT (0x10)", N, try benchBinaryOp(&frame, 0x10, a, b, N)));
    try suite.record(bench.make_result("EQ (0x14)", N, try benchBinaryOp(&frame, 0x14, a, b, N)));
    try suite.record(bench.make_result("AND (0x16)", N, try benchBinaryOp(&frame, 0x16, a, b, N)));
    try suite.record(bench.make_result("XOR (0x18)", N, try benchBinaryOp(&frame, 0x18, a, b, N)));
    try suite.record(bench.make_result("SHL (0x1b)", N, try benchBinaryOp(&frame, 0x1b, 17, a, N)));
    try suite.record(bench.make_result("SHR (0x1c)", N, try benchBinaryOp(&frame, 0x1c, 17, a, N)));
    try suite.record(bench.make_result("SAR (0x1d)", N, try benchBinaryOp(&frame, 0x1d, 17, a, N)));
    try suite.record(bench.make_result("CLZ (0x1e, Osaka EIP-7939)", N, try benchUnaryOp(&frame, 0x1e, a, N)));

    suite.section("Stack Opcodes");
    {
        var timer = try std.time.Timer.start();
        var acc: u256 = 0;
        for (0..N) |_| {
            frame.stack.items.len = 0;
            frame.pc = 3;
            frame.gas_remaining = 1_000_000_000;
            try frame.executeOpcode(0x7f); // PUSH32
            acc +%= try frame.popStack();
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("PUSH32 (0x7f)", N, timer.read()));

        timer.reset();
        for (0..N) |_| {
            frame.stack.items.len = 0;
            frame.pc = 0;
            frame.gas_remaining = 1_000_000_000;
            try frame.pushStack(a);
            try frame.executeOpcode(0x80); // DUP1
            try frame.executeOpcode(0x90); // SWAP1
            try frame.executeOpcode(0x50); // POP
            acc +%= try frame.popStack();
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("DUP1 + SWAP1 + POP sequence", N, timer.read()));
    }

    suite.section("Memory & Keccak Opcodes");
    {
        const mem_n: usize = 100_000;
        resetFrame(&frame);
        var timer = try std.time.Timer.start();
        for (0..mem_n) |i| {
            frame.stack.items.len = 0;
            frame.pc = 0;
            frame.gas_remaining = 1_000_000_000;
            try frame.pushStack(a +% @as(u256, i));
            try frame.pushStack((i & 31) * 32);
            try frame.executeOpcode(0x52); // MSTORE
        }
        try suite.record(bench.make_result("MSTORE (0x52, 32B word)", mem_n, timer.read()));

        timer.reset();
        var acc: u256 = 0;
        for (0..mem_n) |i| {
            frame.stack.items.len = 0;
            frame.pc = 0;
            frame.gas_remaining = 1_000_000_000;
            try frame.pushStack((i & 31) * 32);
            try frame.executeOpcode(0x51); // MLOAD
            acc +%= try frame.popStack();
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("MLOAD (0x51, 32B word)", mem_n, timer.read()));

        const mcopy_n: usize = 20_000;
        timer.reset();
        for (0..mcopy_n) |_| {
            frame.stack.items.len = 0;
            frame.pc = 0;
            frame.gas_remaining = 1_000_000_000;
            try frame.pushStack(1024); // len
            try frame.pushStack(0); // src
            try frame.pushStack(1024); // dest
            try frame.executeOpcode(0x5e); // MCOPY 1KB
        }
        try suite.record(bench.make_result("MCOPY (0x5e, 1KB copy)", mcopy_n, timer.read()));

        const k_n: usize = 20_000;
        timer.reset();
        for (0..k_n) |_| {
            frame.stack.items.len = 0;
            frame.pc = 0;
            frame.gas_remaining = 1_000_000_000;
            try frame.pushStack(256); // size
            try frame.pushStack(0); // offset
            try frame.executeOpcode(0x20); // KECCAK256 256B
            acc +%= try frame.popStack();
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("KECCAK256 (0x20, 256B)", k_n, timer.read()));
    }

    suite.section("Storage, Control Flow, Context & Log Opcodes");
    {
        const s_n: usize = 100_000;
        // Pre-warm slot 1
        _ = try evm.accessStorageSlot(target, 1);
        try evm.storage.set(target, 1, 123);

        var timer = try std.time.Timer.start();
        var acc: u256 = 0;
        for (0..s_n) |_| {
            frame.stack.items.len = 0;
            frame.pc = 0;
            frame.gas_remaining = 1_000_000_000;
            try frame.pushStack(1);
            try frame.executeOpcode(0x54); // SLOAD warm
            acc +%= try frame.popStack();
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("SLOAD warm (0x54)", s_n, timer.read()));

        timer.reset();
        for (0..s_n) |i| {
            frame.stack.items.len = 0;
            frame.pc = 0;
            frame.gas_remaining = 1_000_000_000;
            try frame.pushStack(@intCast(i + 1));
            try frame.pushStack(1);
            try frame.executeOpcode(0x55); // SSTORE warm update
        }
        try suite.record(bench.make_result("SSTORE warm update (0x55)", s_n, timer.read()));

        timer.reset();
        for (0..s_n) |i| {
            frame.stack.items.len = 0;
            frame.pc = 0;
            frame.gas_remaining = 1_000_000_000;
            try frame.pushStack(@intCast(i + 1));
            try frame.pushStack(7);
            try frame.executeOpcode(0x5d); // TSTORE
            try frame.pushStack(7);
            try frame.executeOpcode(0x5c); // TLOAD
            acc +%= try frame.popStack();
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("TSTORE + TLOAD (0x5d/0x5c)", s_n, timer.read()));

        timer.reset();
        for (0..N) |_| {
            frame.stack.items.len = 0;
            frame.pc = 0;
            frame.gas_remaining = 1_000_000_000;
            try frame.pushStack(36); // JUMPDEST at pc=36
            try frame.executeOpcode(0x56); // JUMP
        }
        std.mem.doNotOptimizeAway(frame.pc);
        try suite.record(bench.make_result("JUMP to JUMPDEST (0x56)", N, timer.read()));

        timer.reset();
        for (0..N) |_| {
            frame.stack.items.len = 0;
            frame.pc = 0;
            frame.gas_remaining = 1_000_000_000;
            try frame.pushStack(32);
            try frame.executeOpcode(0x35); // CALLDATALOAD
            acc +%= try frame.popStack();
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("CALLDATALOAD (0x35)", N, timer.read()));

        const log_n: usize = 50_000;
        timer.reset();
        for (0..log_n) |_| {
            frame.stack.items.len = 0;
            frame.pc = 0;
            frame.gas_remaining = 1_000_000_000;
            evm.logs.items.len = 0;
            try frame.pushStack(0x1111); // topic2
            try frame.pushStack(0x2222); // topic1
            try frame.pushStack(64); // size
            try frame.pushStack(0); // offset
            try frame.executeOpcode(0xa2); // LOG2 64B
        }
        try suite.record(bench.make_result("LOG2 64B data (0xa2)", log_n, timer.read()));
    }

    try suite.finish();
}
