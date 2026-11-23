/// Benchmarks for EVM Storage and EIP-2929 AccessListManager (including snapshot/restore).
const std = @import("std");
const bench = @import("bench_utils");
const primitives = @import("voltaire");
const Storage = @import("storage.zig").Storage;
const AccessListManager = @import("access_list_manager.zig").AccessListManager;
const Address = primitives.Address.Address;

fn makeAddr(i: usize) Address {
    var bytes: [20]u8 = [_]u8{0} ** 20;
    const idx_bytes = std.mem.asBytes(&i);
    @memcpy(bytes[0..@min(idx_bytes.len, 20)], idx_bytes[0..@min(idx_bytes.len, 20)]);
    return .{ .bytes = bytes };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var suite = bench.BenchSuite.init(allocator, "core-evm/storage-and-access-list");
    defer suite.deinit();

    const addr = makeAddr(0x1234);

    // 1. Storage persistent get/set
    suite.section("Storage (persistent & transient)");
    {
        var storage = Storage.init(allocator, null, null);
        defer storage.deinit();

        const n: usize = 100_000;
        var timer = try std.time.Timer.start();
        for (0..n) |i| {
            try storage.set(addr, @intCast(i & 4095), @intCast(i + 1));
        }
        try suite.record(bench.make_result("Storage.set (4K working set)", n, timer.read()));

        timer.reset();
        var acc: u256 = 0;
        for (0..n) |i| {
            acc +%= try storage.get(addr, @intCast(i & 4095));
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("Storage.get (4K working set)", n, timer.read()));

        timer.reset();
        for (0..n) |i| {
            acc +%= storage.get_original(addr, @intCast(i & 4095));
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("Storage.get_original (4K working set)", n, timer.read()));

        timer.reset();
        for (0..n) |i| {
            try storage.set_transient(addr, @intCast(i & 1023), @intCast(i + 1));
            acc +%= storage.get_transient(addr, @intCast(i & 1023));
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("Storage transient set+get (1K slots)", n, timer.read()));
    }

    // 2. AccessListManager warm/cold lookups
    suite.section("AccessListManager (EIP-2929)");
    {
        var alm = AccessListManager.init(allocator);
        defer alm.deinit();

        const cold_n: usize = 50_000;
        var timer = try std.time.Timer.start();
        var gas_acc: u64 = 0;
        for (0..cold_n) |i| {
            gas_acc +%= try alm.access_storage_slot(addr, @intCast(i));
        }
        std.mem.doNotOptimizeAway(gas_acc);
        try suite.record(bench.make_result("access_storage_slot cold (50K slots)", cold_n, timer.read()));

        const warm_n: usize = 500_000;
        timer.reset();
        for (0..warm_n) |i| {
            gas_acc +%= try alm.access_storage_slot(addr, @intCast(i % cold_n));
        }
        std.mem.doNotOptimizeAway(gas_acc);
        try suite.record(bench.make_result("access_storage_slot warm (500K lookups)", warm_n, timer.read()));
    }

    // 3. AccessListManager snapshot/restore (hot path for nested CALLs!)
    suite.section("AccessListManager Snapshot & Restore (nested CALLs)");
    inline for (.{ 16, 128, 1024 }) |warm_count| {
        var alm = AccessListManager.init(allocator);
        defer alm.deinit();

        for (0..warm_count) |i| {
            _ = try alm.access_address(makeAddr(i));
            _ = try alm.access_storage_slot(addr, @intCast(i));
        }

        const iters: usize = if (warm_count <= 128) 2_000 else 200;
        var timer = try std.time.Timer.start();
        for (0..iters) |iter| {
            var snap = try alm.snapshot();
            // Simulate child call touching 4 slots then reverting
            for (0..4) |k| {
                _ = try alm.access_storage_slot(addr, @intCast(warm_count + iter * 4 + k));
            }
            try alm.restore(snap);
            snap.deinit();
        }
        const label = std.fmt.comptimePrint("snapshot+touch(4)+restore ({d} warm entries)", .{warm_count});
        try suite.record(bench.make_result(label, iters, timer.read()));
    }

    try suite.finish();
}
