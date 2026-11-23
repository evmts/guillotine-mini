/// Benchmarks for the C FFI / WASM bridge (src/root_c.zig).
const std = @import("std");
const bench = @import("bench_utils");
const root_c = @import("root_c.zig");

comptime {
    _ = root_c;
}

const EvmHandle = anyopaque;
extern fn evm_create(hardfork_name: [*]const u8, hardfork_len: usize, log_level: u8) ?*EvmHandle;
extern fn evm_destroy(handle: ?*EvmHandle) void;
extern fn evm_set_bytecode(handle: ?*EvmHandle, bytecode: [*]const u8, bytecode_len: usize) bool;
extern fn evm_set_execution_context(
    handle: ?*EvmHandle,
    gas: i64,
    caller: *const [20]u8,
    address: *const [20]u8,
    value: *const [32]u8,
    calldata: [*]const u8,
    calldata_len: usize,
) bool;
extern fn evm_execute(handle: ?*EvmHandle) bool;
extern fn evm_get_gas_used(handle: ?*EvmHandle) i64;
extern fn evm_get_output(handle: ?*EvmHandle, buffer: [*]u8, buffer_len: usize) usize;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var suite = bench.BenchSuite.init(allocator, "core-evm/c-ffi");
    defer suite.deinit();

    const hardfork = "OSAKA";
    // Simple arithmetic contract: PUSH1 20; PUSH1 22; ADD; PUSH1 0; MSTORE; PUSH1 32; PUSH1 0; RETURN
    const code = [_]u8{ 0x60, 0x14, 0x60, 0x16, 0x01, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
    const caller = [_]u8{0x11} ** 20;
    const address = [_]u8{0x22} ** 20;
    const value = [_]u8{0} ** 32;
    const empty = [_]u8{};

    suite.section("C-FFI Lifecycle & Execution");
    {
        const iters: usize = 5_000;
        var timer = try std.time.Timer.start();
        var sink: i64 = 0;
        for (0..iters) |_| {
            const handle = evm_create(hardfork.ptr, hardfork.len, 0) orelse unreachable;
            _ = evm_set_bytecode(handle, &code, code.len);
            _ = evm_set_execution_context(handle, 1_000_000, &caller, &address, &value, &empty, 0);
            _ = evm_execute(handle);
            sink +%= evm_get_gas_used(handle);
            evm_destroy(handle);
        }
        std.mem.doNotOptimizeAway(sink);
        try suite.record(bench.make_result("FFI evm_create + set_bytecode + execute + destroy", iters, timer.read()));
    }

    {
        const handle = evm_create(hardfork.ptr, hardfork.len, 0) orelse unreachable;
        defer evm_destroy(handle);
        _ = evm_set_bytecode(handle, &code, code.len);
        _ = evm_set_execution_context(handle, 1_000_000, &caller, &address, &value, &empty, 0);

        const iters: usize = 10_000;
        var out_buf: [64]u8 = undefined;
        var timer = try std.time.Timer.start();
        var sink: usize = 0;
        for (0..iters) |_| {
            _ = evm_execute(handle);
            const len = evm_get_output(handle, &out_buf, out_buf.len);
            sink +%= len;
        }
        std.mem.doNotOptimizeAway(sink);
        try suite.record(bench.make_result("FFI reused-handle evm_execute + evm_get_output", iters, timer.read()));
    }

    try suite.finish();
}
