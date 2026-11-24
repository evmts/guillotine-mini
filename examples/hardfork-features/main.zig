const std = @import("std");
const ex = @import("../common.zig");

pub fn run(allocator: std.mem.Allocator, out: *std.Io.Writer) !void {
    for ([_]ex.mini.Hardfork{ .ISTANBUL, .BERLIN, .LONDON, .SHANGHAI, .CANCUN }) |fork| {
        var evm: ex.Evm = undefined;
        try evm.init(allocator, null, fork, null, ex.alice, 0, null);
        defer evm.deinit();
        const params = ex.message(ex.contract);
        // Clear the same non-zero slot on every fork. Refund is the raw counter.
        try evm.setStoragePrestate(.{ .address = ex.contract.bytes, .slot = 0 }, 1);
        const clear = evm.callWithBytecodeOverride(params, &.{ 0x60, 0, 0x60, 0, 0x55, 0x00 });
        try ex.requireSuccess(clear);
        const load = evm.callWithBytecodeOverride(params, &.{ 0x60, 0, 0x54, 0x00 });
        try ex.requireSuccess(load);
        try out.print("{s} SLOAD={d} clear_refund={d}", .{ @tagName(fork), load.gasConsumed(ex.gas), clear.refund_counter });

        const Feature = struct { name: []const u8, code: []const u8, since: ex.mini.Hardfork };
        for ([_]Feature{
            .{ .name = "PUSH0", .code = &.{ 0x5f, 0x00 }, .since = .SHANGHAI },
            .{ .name = "MCOPY", .code = &.{ 0x60, 0, 0x60, 0, 0x60, 0, 0x5e, 0x00 }, .since = .CANCUN },
            .{ .name = "TSTORE", .code = &.{ 0x60, 1, 0x60, 0, 0x5d, 0x00 }, .since = .CANCUN },
        }) |feature| {
            const result = evm.callWithBytecodeOverride(params, feature.code);
            try std.testing.expectEqual(fork.isAtLeast(feature.since), result.success);
            if (!result.success) try std.testing.expectEqualStrings("InvalidOpcode", result.error_info orelse return error.MissingFault);
            try out.print(" {s}={s}", .{ feature.name, if (result.success) "on" else "off" });
        }
        try out.writeByte('\n');
    }
}
