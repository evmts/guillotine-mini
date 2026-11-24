//! The modular reactor keeps Voltaire's fork activation rules in the EVM.
//! Its synchronous host executes the selected module in a separate memory.
const std = @import("std");
const builtins = @import("builtins");
const primitives = @import("voltaire");
const abi = @import("wasm_errors.zig");

pub const isPrecompile = builtins.isPrecompile;

extern "precompiles" fn run(address: u32, fork: u32, input: [*]const u8, len: usize, gas: u64, gas_used: *u64) i32;
extern "precompiles" fn copy_output(address: u32, dest: [*]u8, len: usize) void;

pub fn execute(allocator: std.mem.Allocator, address: primitives.Address, input: []const u8, gas: u64, fork: primitives.Hardfork) builtins.PrecompileError!builtins.PrecompileResult {
    var used: u64 = 0;
    const id: u32 = @intCast(address.toU256()); // EVM checked isPrecompile first.
    const len = run(id, @intFromEnum(fork), input.ptr, input.len, gas, &used);
    if (len < 0) return abi.decode(len);
    if (used > gas) return error.OutOfGas;
    const output = try allocator.alloc(u8, @intCast(len));
    if (len > 0) copy_output(id, output.ptr, output.len);
    return .{ .output = output, .gas_used = used };
}
