const std = @import("std");
const ex = @import("../common.zig");

pub fn run(allocator: std.mem.Allocator, out: *std.Io.Writer) !void {
    var state = ex.mini.StateOverlayHost.init(allocator, null);
    defer state.deinit();
    const library = ex.Address.fromU256(0x300);
    state.setBalance(ex.alice, 10);
    // Return CALLER as a word so the parent can observe the child context.
    state.setCode(library, &.{ 0x33, 0x5f, 0x52, 0x60, 32, 0x5f, 0xf3 });
    var evm: ex.Evm = undefined;
    try evm.init(allocator, state.host(), .CANCUN, null, ex.alice, 0, null);
    defer evm.deinit();

    var payment = ex.message(library);
    payment.call.value = 1;
    try std.testing.expectEqual(0x100, try ex.outputWord(evm.call(payment)));
    try std.testing.expectEqual(1, state.getBalance(library));
    const read: ex.Evm.CallParams = .{ .staticcall = .{ .caller = ex.alice, .to = library, .input = &.{}, .gas = ex.gas } };
    try std.testing.expectEqual(0x100, try ex.outputWord(evm.call(read)));
    const denied = evm.callWithBytecodeOverride(read, &.{ 0x5f, 0x5f, 0x55 });
    try std.testing.expectEqualStrings("StaticCallViolation", denied.error_info orelse return error.ExpectedStaticViolation);
    try out.print("CALL transferred={d}; STATICCALL rejected SSTORE\n", .{state.getBalance(library)});

    // These two message types run inside a parent frame. Both use its address
    // and storage. DELEGATECALL preserves its caller; CALLCODE supplies its address as caller.
    const buffers = [_]u8{ 0x60, 32, 0x5f, 0x5f, 0x5f }; // out size/offset, in size/offset
    const target = [_]u8{ 0x61, 0x03, 0x00, 0x5a }; // PUSH2 library, GAS
    const ret = [_]u8{ 0x50, 0x60, 32, 0x5f, 0xf3 }; // discard success flag, return child output
    const delegate = buffers ++ target ++ [_]u8{0xf4} ++ ret;
    const callcode = buffers ++ [_]u8{0x5f} ++ target ++ [_]u8{0xf2} ++ ret; // extra value argument
    const preserved = try ex.outputWord(evm.callWithBytecodeOverride(ex.message(ex.contract), &delegate));
    const parent = try ex.outputWord(evm.callWithBytecodeOverride(ex.message(ex.contract), &callcode));
    try std.testing.expectEqual(0x100, preserved);
    try std.testing.expectEqual(0x200, parent);
    try out.print("DELEGATECALL caller=0x{x}; CALLCODE caller=0x{x}\n", .{ preserved, parent });

    // Initcode returns one zero-initialized memory byte as runtime code (STOP).
    const init_code = &[_]u8{ 0x60, 1, 0x5f, 0xf3 };
    const created = evm.call(.{ .create = .{ .caller = ex.alice, .value = 0, .init_code = init_code, .gas = ex.gas } });
    try ex.requireSuccess(created);
    const address = created.created_address orelse return error.MissingAddress;
    try std.testing.expectEqualSlices(u8, &.{0}, state.getCode(address));
    const predicted = try evm.computeCreate2Address(ex.alice, 42, init_code);
    const salted = evm.call(.{ .create2 = .{ .caller = ex.alice, .value = 0, .init_code = init_code, .salt = 42, .gas = ex.gas } });
    try ex.requireSuccess(salted);
    try std.testing.expectEqual(predicted, salted.created_address orelse return error.MissingAddress);
    try std.testing.expectEqualSlices(u8, &.{0}, state.getCode(predicted));
    try out.print("CREATE runtime=0x{x}; CREATE2 predicted=0x{x}\n", .{ state.getCode(address), predicted.bytes });
}
