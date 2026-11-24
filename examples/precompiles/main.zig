const std = @import("std");
const ex = @import("../common.zig");

pub fn run(allocator: std.mem.Allocator, out: *std.Io.Writer) !void {
    var evm: ex.Evm = undefined;
    try evm.init(allocator, null, .CANCUN, null, ex.alice, 0, null);
    defer evm.deinit();

    // MODEXP expects three 32-byte lengths, then base, exponent and modulus.
    var modexp = [_]u8{0} ** 99;
    for ([_]usize{ 31, 63, 95 }) |i| modexp[i] = 1;
    modexp[96..99].* = .{ 2, 5, 13 }; // 2^5 mod 13 = 6
    var blake = [_]u8{0} ** 213;
    blake[3] = 1; // one compression round, zero state, block and counters
    const cases = [_]struct { name: []const u8, input: []const u8, size: usize }{
        .{ .name = "ECRECOVER", .input = &.{}, .size = 0 }, // invalid signature yields empty output
        .{ .name = "SHA256", .input = "abc", .size = 32 },
        .{ .name = "RIPEMD160", .input = "abc", .size = 32 }, // left-padded digest
        .{ .name = "IDENTITY", .input = "abc", .size = 3 },
        .{ .name = "MODEXP", .input = &modexp, .size = 1 },
        .{ .name = "BN254ADD", .input = &.{}, .size = 64 }, // zero-padded point at infinity
        .{ .name = "BN254MUL", .input = &.{}, .size = 64 },
        .{ .name = "BN254PAIRING", .input = &.{}, .size = 32 }, // empty pairing product is one
        .{ .name = "BLAKE2F", .input = &blake, .size = 64 },
    };
    for (cases, 1..) |case, address| {
        // Precompiles accept the same message API as bytecode contracts.
        var params = ex.message(ex.Address.fromU256(address));
        params.call.input = case.input;
        const result = evm.call(params);
        try ex.requireSuccess(result);
        try std.testing.expectEqual(case.size, result.output.len);
        switch (address) {
            2 => {
                var digest: [32]u8 = undefined;
                std.crypto.hash.sha2.Sha256.hash(case.input, &digest, .{});
                try std.testing.expectEqualSlices(u8, &digest, result.output);
            },
            4 => try std.testing.expectEqualSlices(u8, case.input, result.output),
            5 => try std.testing.expectEqualSlices(u8, &.{6}, result.output),
            8 => try std.testing.expectEqual(1, try ex.outputWord(result)),
            else => {},
        }
        try out.print("0x{x:0>2} {s} gas={d} output_bytes={d}\n", .{ address, case.name, result.gasConsumed(ex.gas), result.output.len });
    }
}
