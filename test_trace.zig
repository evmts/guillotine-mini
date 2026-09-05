//! Deterministic native trace regression; no fixture generation is needed.
const std = @import("std");
const mini = @import("guillotine");
const primitives = @import("voltaire");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();
    const address = primitives.Address.fromU256(0x123);
    var tracer = mini.trace.Tracer.init(allocator);
    defer tracer.deinit();
    tracer.config.enable_memory = true;
    tracer.enable();
    var evm: mini.Evm(.{}) = undefined;
    try evm.init(allocator, null, .CANCUN, .{
        .chain_id = 31337,
        .block_number = 1,
        .block_timestamp = 1,
        .block_difficulty = 0,
        .block_prevrandao = 0,
        .block_coinbase = address,
        .block_gas_limit = 30_000_000,
        .block_base_fee = 0,
        .blob_base_fee = 0,
    }, address, 0, null);
    defer evm.deinit();
    evm.setTracer(&tracer);
    try evm.code.put(address, &.{ 0x60, 0x2a, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 });
    const result = evm.call(.{ .call = .{ .caller = address, .to = address, .value = 0, .input = &.{}, .gas = 100_000 } });
    try std.testing.expect(result.success);
    try std.testing.expectEqual(@as(usize, 32), result.output.len);
    try std.testing.expectEqual(@as(u8, 42), result.output[31]);
    try std.testing.expectEqual(@as(usize, 0), tracer.entries.items[0].stack.len);
    try std.testing.expectEqualSlices(u256, &.{42}, tracer.entries.items[1].stack);
    try std.testing.expectEqual(@as(u64, 3), tracer.entries.items[0].gasCost);
    try std.testing.expectEqual(@as(usize, 32), tracer.entries.items[3].memory.?.len);
    try std.testing.expectEqualStrings("RETURN", tracer.entries.items[tracer.entries.items.len - 1].opName);
}
