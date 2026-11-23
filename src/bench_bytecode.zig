/// Benchmarks for EVM bytecode analysis, JUMPDEST lookup, and PUSH immediate decoding.
const std = @import("std");
const bench = @import("bench_utils");
const Bytecode = @import("bytecode.zig").Bytecode;

fn buildMixedBytecode(allocator: std.mem.Allocator, size: usize) ![]u8 {
    const code = try allocator.alloc(u8, size);
    var i: usize = 0;
    var seed: u64 = 0x9e3779b97f4a7c15;
    while (i < size) {
        seed = seed *% 6364136223846793005 +% 1442695040888963407;
        const r: u8 = @truncate(seed >> 56);
        if (r < 24) {
            code[i] = 0x5b; // JUMPDEST (~10%)
            i += 1;
        } else if (r < 72 and i + 2 <= size) {
            const push_len: usize = 1 + (r % 4);
            const actual = @min(push_len, size - i - 1);
            code[i] = @intCast(0x5f + actual);
            i += 1;
            for (0..actual) |k| {
                // Embed occasional 0x5b inside PUSH data to stress skipping
                code[i + k] = if (k == 0) 0x5b else @truncate(seed >> @intCast((k % 7) * 8));
            }
            i += actual;
        } else if (r < 84 and i + 33 <= size) {
            code[i] = 0x7f; // PUSH32
            i += 1;
            @memset(code[i .. i + 32], 0x5b);
            i += 32;
        } else {
            code[i] = 0x01; // ADD
            i += 1;
        }
    }
    return code;
}

fn buildAllJumpdestBytecode(allocator: std.mem.Allocator, size: usize) ![]u8 {
    const code = try allocator.alloc(u8, size);
    @memset(code, 0x5b);
    return code;
}

fn benchAnalyze(code: []const u8, iters: usize) !u64 {
    // Warmup
    for (0..3) |_| {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        var bc = try Bytecode.init(arena.allocator(), code);
        std.mem.doNotOptimizeAway(bc.isValidJumpDest(0));
        bc.deinit();
        arena.deinit();
    }

    var timer = try std.time.Timer.start();
    var sink: usize = 0;
    for (0..iters) |_| {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        var bc = try Bytecode.init(arena.allocator(), code);
        sink +%= @intFromBool(bc.isValidJumpDest(0));
        bc.deinit();
        arena.deinit();
    }
    std.mem.doNotOptimizeAway(sink);
    return timer.read();
}

fn benchJumpdestLookups(bc: *const Bytecode, iters: usize) !u64 {
    const len_u32: u32 = @intCast(bc.len());
    var timer = try std.time.Timer.start();
    var hits: usize = 0;
    var pc: u32 = 0;
    for (0..iters) |_| {
        hits +%= @intFromBool(bc.isValidJumpDest(pc));
        pc +%= 13;
        if (pc >= len_u32) pc -= len_u32;
    }
    std.mem.doNotOptimizeAway(hits);
    return timer.read();
}

fn benchReadImmediate(bc: *const Bytecode, size: u8, iters: usize) !u64 {
    const max_pc: u32 = @intCast(bc.len() -| 33);
    var timer = try std.time.Timer.start();
    var acc: u256 = 0;
    var pc: u32 = 0;
    for (0..iters) |_| {
        acc +%= bc.readImmediate(pc, size) orelse 0;
        pc +%= 7;
        if (pc >= max_pc) pc = 0;
    }
    std.mem.doNotOptimizeAway(acc);
    return timer.read();
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var suite = bench.BenchSuite.init(allocator, "core-evm/bytecode");
    defer suite.deinit();

    const small = try buildMixedBytecode(allocator, 256);
    defer allocator.free(small);
    const medium = try buildMixedBytecode(allocator, 4096);
    defer allocator.free(medium);
    const large = try buildMixedBytecode(allocator, 24576);
    defer allocator.free(large);
    const worst = try buildAllJumpdestBytecode(allocator, 24576);
    defer allocator.free(worst);

    suite.section("Bytecode.init (JUMPDEST analysis)");
    try suite.record(bench.make_result("analyze mixed 256B", 5_000, try benchAnalyze(small, 5_000)));
    try suite.record(bench.make_result("analyze mixed 4KB", 1_000, try benchAnalyze(medium, 1_000)));
    try suite.record(bench.make_result("analyze mixed 24KB (max contract)", 200, try benchAnalyze(large, 200)));
    try suite.record(bench.make_result("analyze all-JUMPDEST 24KB (adversarial)", 200, try benchAnalyze(worst, 200)));

    suite.section("Bytecode.isValidJumpDest");
    var bc_large = try Bytecode.init(allocator, large);
    defer bc_large.deinit();
    var bc_worst = try Bytecode.init(allocator, worst);
    defer bc_worst.deinit();
    try suite.record(bench.make_result("isValidJumpDest mixed 24KB", 2_000_000, try benchJumpdestLookups(&bc_large, 2_000_000)));
    try suite.record(bench.make_result("isValidJumpDest all-JUMPDEST 24KB", 2_000_000, try benchJumpdestLookups(&bc_worst, 2_000_000)));

    suite.section("Bytecode.readImmediate");
    try suite.record(bench.make_result("readImmediate PUSH1", 2_000_000, try benchReadImmediate(&bc_large, 1, 2_000_000)));
    try suite.record(bench.make_result("readImmediate PUSH4", 2_000_000, try benchReadImmediate(&bc_large, 4, 2_000_000)));
    try suite.record(bench.make_result("readImmediate PUSH20", 2_000_000, try benchReadImmediate(&bc_large, 20, 2_000_000)));
    try suite.record(bench.make_result("readImmediate PUSH32", 2_000_000, try benchReadImmediate(&bc_large, 32, 2_000_000)));

    try suite.finish();
}
