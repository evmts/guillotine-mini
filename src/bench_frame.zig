/// Benchmarks for EVM Frame lifecycle, stack ops, memory ops, and gas metering.
const std = @import("std");
const bench = @import("bench_utils");
const primitives = @import("voltaire");
const evm_mod = @import("evm");
const EvmType = evm_mod.Evm(.{});
const FrameType = evm_mod.Frame(.{});
const Address = primitives.Address.Address;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var suite = bench.BenchSuite.init(allocator, "core-evm/frame");
    defer suite.deinit();

    var evm: EvmType = undefined;
    const origin = Address.ZERO;
    try evm.init(allocator, null, .CANCUN, null, origin, 0, .none);
    defer evm.deinit();

    const sample_code = [_]u8{ 0x60, 0x01, 0x60, 0x02, 0x01, 0x5b, 0x00 } ** 64;

    // 1. Frame init/deinit
    suite.section("Frame Lifecycle");
    {
        const iters: usize = 20_000;
        var timer = try std.time.Timer.start();
        var sink: usize = 0;
        for (0..iters) |_| {
            var frame = try FrameType.init(allocator, &sample_code, 10_000_000, origin, origin, 0, &.{}, @ptrCast(&evm), .CANCUN, false);
            sink +%= frame.bytecode.len();
            frame.deinit();
        }
        std.mem.doNotOptimizeAway(sink);
        try suite.record(bench.make_result("Frame.init + deinit (448B bytecode)", iters, timer.read()));
    }

    var frame = try FrameType.init(allocator, &sample_code, 1_000_000_000_000, origin, origin, 0, &.{}, @ptrCast(&evm), .CANCUN, false);
    defer frame.deinit();

    // 2. Stack push/pop/peek
    suite.section("Stack Operations");
    {
        const iters: usize = 5_000_000;
        var timer = try std.time.Timer.start();
        var acc: u256 = 0;
        for (0..iters) |i| {
            try frame.pushStack(@intCast(i));
            const top = try frame.peekStack(0);
            const popped = try frame.popStack();
            acc +%= top ^ popped;
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("stack push + peek + pop", iters, timer.read()));
    }

    // 3. Gas consumption
    suite.section("Gas Metering");
    {
        const iters: usize = 10_000_000;
        frame.gas_remaining = 1_000_000_000_000;
        var timer = try std.time.Timer.start();
        for (0..iters) |_| {
            try frame.consumeGas(3);
        }
        std.mem.doNotOptimizeAway(frame.gas_remaining);
        try suite.record(bench.make_result("Frame.consumeGas(3)", iters, timer.read()));
    }

    // 4. Memory expansion cost
    suite.section("Memory Expansion Cost");
    {
        const iters: usize = 5_000_000;
        frame.memory_size = 4096;
        var timer = try std.time.Timer.start();
        var acc: u64 = 0;
        for (0..iters) |i| {
            const target: u64 = if ((i & 3) == 0) 8192 else 2048;
            acc +%= frame.memoryExpansionCost(target);
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("memoryExpansionCost (75% hit / 25% expand)", iters, timer.read()));
    }

    // 5. Memory read/write
    suite.section("Memory Read/Write");
    {
        // Write 4KB repeatedly
        const write_iters: usize = 2_000;
        const block_size: u32 = 4096;
        var timer = try std.time.Timer.start();
        for (0..write_iters) |iter| {
            const val: u8 = @truncate(iter);
            var off: u32 = 0;
            while (off < block_size) : (off += 1) {
                try frame.writeMemory(off, val);
            }
        }
        try suite.record(bench.make_result("writeMemory 4KB byte-by-byte", write_iters, timer.read()));

        const read_iters: usize = 2_000;
        timer.reset();
        var acc: u64 = 0;
        for (0..read_iters) |_| {
            var off: u32 = 0;
            while (off < block_size) : (off += 1) {
                acc +%= frame.readMemory(off);
            }
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("readMemory 4KB byte-by-byte", read_iters, timer.read()));
    }

    try suite.finish();
}
