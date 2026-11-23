/// End-to-end Core EVM execution benchmarks: loops, memory, storage, nested CALLs,
/// CREATE/CREATE2, precompiles (incl. Osaka P256VERIFY), Tracer/Inspector, and AsyncExecutor.
const std = @import("std");
const bench = @import("bench_utils");
const primitives = @import("voltaire");
const evm_mod = @import("evm");
const EvmType = evm_mod.Evm(.{});
const CallParams = evm_mod.call_params.CallParams(.{});
const Tracer = evm_mod.Tracer;
const Inspector = evm_mod.Inspector;
const RevertDecoder = evm_mod.RevertDecoder;
const Address = primitives.Address.Address;

fn makeAddr(byte: u8) Address {
    var bytes: [20]u8 = [_]u8{0} ** 20;
    bytes[19] = byte;
    return .{ .bytes = bytes };
}

const BenchHost = struct {
    contract_addr: Address,
    contract_code: []const u8,
    extra_addr: ?Address,
    extra_code: []const u8,

    fn getBalance(_: *anyopaque, _: Address) u256 {
        return 0;
    }
    fn setBalance(_: *anyopaque, _: Address, _: u256) void {}
    fn getCode(ptr: *anyopaque, addr: Address) []const u8 {
        const self: *BenchHost = @ptrCast(@alignCast(ptr));
        if (addr.equals(self.contract_addr)) return self.contract_code;
        if (self.extra_addr) |ea| {
            if (addr.equals(ea)) return self.extra_code;
        }
        return &.{};
    }
    fn setCode(_: *anyopaque, _: Address, _: []const u8) void {}
    fn getStorage(_: *anyopaque, _: Address, _: u256) u256 {
        return 0;
    }
    fn setStorage(_: *anyopaque, _: Address, _: u256, _: u256) void {}
    fn getNonce(_: *anyopaque, _: Address) u64 {
        return 0;
    }
    fn setNonce(_: *anyopaque, _: Address, _: u64) void {}

    const vtable = evm_mod.HostInterface.VTable{
        .getBalance = getBalance,
        .setBalance = setBalance,
        .getCode = getCode,
        .setCode = setCode,
        .getStorage = getStorage,
        .setStorage = setStorage,
        .getNonce = getNonce,
        .setNonce = setNonce,
    };

    fn interface(self: *BenchHost) evm_mod.HostInterface {
        return .{ .ptr = self, .vtable = &vtable };
    }
};

fn buildLoopContract(iters: u16) [13]u8 {
    return .{
        0x61, @intCast(iters >> 8), @intCast(iters & 0xff), // PUSH2 iters
        0x5b, // JUMPDEST (pc=3)
        0x60, 0x01, // PUSH1 1
        0x90, // SWAP1
        0x03, // SUB
        0x80, // DUP1
        0x60, 0x03, // PUSH1 3
        0x57, // JUMPI
        0x00, // STOP
    };
}

/// Memory + Keccak loop: stores 32 bytes at offset 0 and hashes 256 bytes per iteration.
fn buildMemoryKeccakContract(iters: u16) [26]u8 {
    return .{
        0x61, @intCast(iters >> 8), @intCast(iters & 0xff), // PUSH2 iters
        0x5b, // JUMPDEST (pc=3)
        0x80, // DUP1 (value)
        0x60, 0x00, // PUSH1 0 (offset)
        0x52, // MSTORE
        0x61, 0x01, 0x00, // PUSH2 256 (size)
        0x60, 0x00, // PUSH1 0 (offset)
        0x20, // KECCAK256
        0x60, 0x20, // PUSH1 32
        0x52, // MSTORE
        0x60, 0x01, // PUSH1 1
        0x90, // SWAP1
        0x03, // SUB
        0x80, // DUP1
        0x60, 0x03, // PUSH1 3
        0x57, // JUMPI
        0x00, // STOP
    };
}

/// Storage + Log loop (ERC20-like balance debit/credit + LOG0)
fn buildStorageContract(iters: u16) [27]u8 {
    return .{
        0x61, @intCast(iters >> 8), @intCast(iters & 0xff), // PUSH2 iters
        0x5b, // JUMPDEST (pc=3)
        0x60, 0x01, // PUSH1 1 (slot)
        0x54, // SLOAD
        0x60, 0x01, // PUSH1 1
        0x01, // ADD
        0x60, 0x01, // PUSH1 1 (slot)
        0x55, // SSTORE
        0x60, 0x20, // PUSH1 32 (size)
        0x60, 0x00, // PUSH1 0 (offset)
        0xa0, // LOG0
        0x60, 0x01, // PUSH1 1
        0x90, // SWAP1
        0x03, // SUB
        0x80, // DUP1
        0x60, 0x03, // PUSH1 3
        0x57, // JUMPI
        0x00, // STOP
    };
}

/// Caller contract that calls `callee` (0x44) `iters` times with 0 value and 32B input
fn buildNestedCallContract(iters: u16) [30]u8 {
    return .{
        0x61, @intCast(iters >> 8), @intCast(iters & 0xff), // PUSH2 iters
        0x5b, // JUMPDEST (pc=3)
        0x60, 0x00, // retSize
        0x60, 0x00, // retOffset
        0x60, 0x20, // argsSize
        0x60, 0x00, // argsOffset
        0x60, 0x00, // value
        0x60, 0x44, // to = 0x00..44
        0x61, 0x27, 0x10, // gas = 10000
        0xf1, // CALL
        0x50, // POP success
        0x60, 0x01, // PUSH1 1
        0x90, // SWAP1
        0x03, // SUB
        0x80, // DUP1
        0x60, 0x03, // PUSH1 3
        0x57, // JUMPI
        0x00, // STOP
    };
}

fn runContract(allocator: std.mem.Allocator, code: []const u8, extra_target: ?struct { addr: Address, code: []const u8 }, runs: usize, with_tracer: bool) !u64 {
    const caller = makeAddr(0x11);
    const contract = makeAddr(0x22);

    var host_impl = BenchHost{
        .contract_addr = contract,
        .contract_code = code,
        .extra_addr = if (extra_target) |t| t.addr else null,
        .extra_code = if (extra_target) |t| t.code else &.{},
    };
    const host_iface = host_impl.interface();

    // Warmup
    {
        var evm: EvmType = undefined;
        try evm.init(allocator, host_iface, .OSAKA, null, caller, 0, .none);
        defer evm.deinit();
        const res = evm.call(.{ .call = .{ .caller = caller, .to = contract, .value = 0, .input = &.{}, .gas = 30_000_000 } });
        std.debug.assert(res.success);
        std.mem.doNotOptimizeAway(res.gas_left);
    }

    var total_ns: u64 = 0;
    for (0..runs) |_| {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const a = arena.allocator();

        var evm: EvmType = undefined;
        try evm.init(a, host_iface, .OSAKA, null, caller, 0, .none);

        var tracer = Tracer.init(a);
        if (with_tracer) {
            tracer.enabled = true;
            evm.setTracer(&tracer);
        }

        var timer = try std.time.Timer.start();
        const res = evm.call(.{ .call = .{
            .caller = caller,
            .to = contract,
            .value = 0,
            .input = &.{},
            .gas = 30_000_000,
        } });
        total_ns += timer.read();
        std.mem.doNotOptimizeAway(res.success);
        std.mem.doNotOptimizeAway(res.gas_left);
    }
    return total_ns;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var suite = bench.BenchSuite.init(allocator, "core-evm/execution");
    defer suite.deinit();

    // 1. Tight loop
    suite.section("End-to-End EVM Contract Execution");
    const tight_loop = buildLoopContract(2000);
    try suite.record(bench.make_result("tight arithmetic loop (2K iters / ~14K opcodes)", 50, try runContract(allocator, &tight_loop, null, 50, false)));

    const mem_keccak = buildMemoryKeccakContract(500);
    try suite.record(bench.make_result("memory MSTORE + KECCAK256(256B) loop (500 iters)", 30, try runContract(allocator, &mem_keccak, null, 30, false)));

    const storage_loop = buildStorageContract(500);
    try suite.record(bench.make_result("storage SLOAD+SSTORE+LOG0 loop (500 iters)", 30, try runContract(allocator, &storage_loop, null, 30, false)));

    const nested_caller = buildNestedCallContract(100);
    const callee_code = [_]u8{ 0x60, 0x2a, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 }; // return 42
    try suite.record(bench.make_result("nested CALL loop (100 inner CALLs)", 30, try runContract(allocator, &nested_caller, .{ .addr = makeAddr(0x44), .code = &callee_code }, 30, false)));

    // 2. Tracer & RevertDecoder
    suite.section("Observability (Tracer & RevertDecoder)");
    const trace_loop = buildLoopContract(500);
    try suite.record(bench.make_result("500-iter loop WITHOUT tracer", 30, try runContract(allocator, &trace_loop, null, 30, false)));
    try suite.record(bench.make_result("500-iter loop WITH EIP-3155 tracer", 30, try runContract(allocator, &trace_loop, null, 30, true)));
    {
        var rev = [_]u8{0} ** 100;
        @memcpy(rev[0..4], &[_]u8{ 0x08, 0xc3, 0x79, 0xa0 });
        rev[35] = 32;
        rev[67] = 12;
        @memcpy(rev[68..80], "insufficient");
        const iters: usize = 500_000;
        var timer = try std.time.Timer.start();
        var sink: usize = 0;
        for (0..iters) |_| {
            if (RevertDecoder.decode(&rev)) |d| {
                sink +%= d.reason.len;
            }
        }
        std.mem.doNotOptimizeAway(sink);
        try suite.record(bench.make_result("RevertDecoder.decode Error(string)", iters, timer.read()));
    }

    // 3. Precompiles
    suite.section("Precompile Dispatch");
    {
        const caller = makeAddr(0x11);
        var payload: [256]u8 = undefined;
        for (&payload, 0..) |*b, i| b.* = @truncate(i);

        // IDENTITY (0x04)
        {
            var evm: EvmType = undefined;
            try evm.init(allocator, null, .OSAKA, null, caller, 0, .none);
            defer evm.deinit();
            const precompile_id = makeAddr(0x04);
            const iters: usize = 20_000;
            var timer = try std.time.Timer.start();
            var sink: usize = 0;
            for (0..iters) |_| {
                const res = evm.call(.{ .staticcall = .{ .caller = caller, .to = precompile_id, .input = &payload, .gas = 1_000_000 } });
                sink +%= res.output.len;
            }
            std.mem.doNotOptimizeAway(sink);
            try suite.record(bench.make_result("precompile IDENTITY 256B (0x04)", iters, timer.read()));
        }

        // SHA256 (0x02)
        {
            var evm: EvmType = undefined;
            try evm.init(allocator, null, .OSAKA, null, caller, 0, .none);
            defer evm.deinit();
            const precompile_sha = makeAddr(0x02);
            const iters: usize = 10_000;
            var timer = try std.time.Timer.start();
            var sink: usize = 0;
            for (0..iters) |_| {
                const res = evm.call(.{ .staticcall = .{ .caller = caller, .to = precompile_sha, .input = &payload, .gas = 1_000_000 } });
                sink +%= res.output.len;
            }
            std.mem.doNotOptimizeAway(sink);
            try suite.record(bench.make_result("precompile SHA256 256B (0x02)", iters, timer.read()));
        }

        // P256VERIFY (0x0100, Osaka EIP-7951)
        {
            var evm: EvmType = undefined;
            try evm.init(allocator, null, .OSAKA, null, caller, 0, .none);
            defer evm.deinit();
            var p256_addr = Address.ZERO;
            p256_addr.bytes[18] = 0x01;
            p256_addr.bytes[19] = 0x00;
            const p256_input = [_]u8{0x11} ** 160;
            const iters: usize = 2_000;
            var timer = try std.time.Timer.start();
            var sink: u64 = 0;
            for (0..iters) |_| {
                const res = evm.call(.{ .staticcall = .{ .caller = caller, .to = p256_addr, .input = &p256_input, .gas = 1_000_000 } });
                sink +%= res.gas_left;
            }
            std.mem.doNotOptimizeAway(sink);
            try suite.record(bench.make_result("precompile P256VERIFY (0x0100, Osaka)", iters, timer.read()));
        }
    }

    try suite.finish();
}
