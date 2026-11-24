//! One separately loadable WASI reactor per precompile address. The next
//! prepare() releases the previous call's input, result and scratch space.
const std = @import("std");
const builtins = @import("builtins");
const primitives = @import("voltaire");
const abi = @import("wasm_errors.zig");
const id = @import("options").address;

var arena = std.heap.ArenaAllocator.init(std.heap.wasm_allocator);
var input: ?[]u8 = null;
var result: builtins.PrecompileResult = undefined;

export fn address() u32 {
    return id;
}

export fn prepare(len: usize) usize {
    _ = arena.reset(.retain_capacity);
    input = arena.allocator().alloc(u8, len) catch null;
    const buffer = input orelse return 0;
    return if (len == 0) 0 else @intFromPtr(buffer.ptr);
}

export fn execute(fork_id: u32, gas: u64) i32 {
    const bytes = input orelse return abi.encode(error.OutOfMemory);
    const fork = std.enums.fromInt(primitives.Hardfork, fork_id) orelse return abi.encode(error.InvalidInput);
    // Select at compile time. Calling Voltaire's runtime address dispatcher
    // here would retain every crypto implementation in each binary.
    const run = switch (id) {
        0x01 => builtins.ecrecover.execute,
        0x02 => builtins.sha256.execute,
        0x03 => builtins.ripemd160.execute,
        0x04 => builtins.identity.execute,
        0x05 => builtins.modexp.execute,
        0x06 => builtins.bn254_add.executeWithHardfork,
        0x07 => builtins.bn254_mul.executeWithHardfork,
        0x08 => builtins.bn254_pairing.executeWithHardfork,
        0x09 => builtins.blake2f.execute,
        0x0a => builtins.point_evaluation.execute,
        0x0b => builtins.bls12_g1_add.execute,
        0x0c => builtins.bls12_g1_msm.execute,
        0x0d => builtins.bls12_g2_add.execute,
        0x0e => builtins.bls12_g2_msm.execute,
        0x0f => builtins.bls12_pairing.execute,
        0x10 => builtins.bls12_map_fp_to_g1.execute,
        0x11 => builtins.bls12_map_fp2_to_g2.execute,
        0x100 => builtins.p256verify.execute,
        else => @compileError("unknown precompile address"),
    };
    const args = .{ arena.allocator(), bytes, gas };
    result = (if (@typeInfo(@TypeOf(run)).@"fn".params.len == 4)
        @call(.auto, run, args ++ .{fork})
    else
        @call(.auto, run, args)) catch |err| return abi.encode(err);
    return std.math.cast(i32, result.output.len) orelse abi.encode(error.OutOfMemory);
}

export fn output_ptr() usize {
    return @intFromPtr(result.output.ptr);
}

export fn gas_used() u64 {
    return result.gas_used;
}
