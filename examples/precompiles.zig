//! Call SHA-256 and identity with the same input.
const std = @import("std");
const mini = @import("guillotine_mini");
const primitives = @import("voltaire");

const Evm = mini.Evm(.{});
const caller = primitives.Address.fromU256(0x1000);
const gas_limit = 100_000;

fn callPrecompile(evm: *Evm, address: u256, input: []const u8) !Evm.CallResult {
    // A regular CALL to a precompile address invokes the built-in implementation.
    const result = evm.call(.{ .call = .{
        .caller = caller,
        .to = primitives.Address.fromU256(address),
        .value = 0,
        .input = input,
        .gas = gas_limit,
    } });
    if (!result.isSuccess()) return error.PrecompileFailed;
    return result;
}

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer std.debug.assert(gpa.deinit() == .ok);

    var evm: Evm = undefined;
    try evm.init(gpa.allocator(), null, .CANCUN, null, caller, 0, null);
    defer evm.deinit();

    const input = "abc";
    const sha256 = try callPrecompile(&evm, 0x02, input);
    var expected_digest: [32]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(input, &expected_digest, .{});
    if (!std.mem.eql(u8, sha256.output, &expected_digest)) return error.UnexpectedDigest;
    const digest = std.fmt.bytesToHex(sha256.output[0..32], .lower);
    std.debug.print("SHA-256: 0x{s} ({d} gas)\n", .{ &digest, sha256.gasConsumed(gas_limit) });

    const identity = try callPrecompile(&evm, 0x04, input);
    if (!std.mem.eql(u8, identity.output, input)) return error.UnexpectedIdentityOutput;
    std.debug.print("Identity: {s} ({d} gas)\n", .{ identity.output, identity.gasConsumed(gas_limit) });
}
