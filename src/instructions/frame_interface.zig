/// Frame interface shared by guillotine-mini and guillotine-performance opcode handlers.
///
/// Handlers are generic over a `FrameType` and use static dispatch: no vtables.
/// `checkFrameInterface` verifies at comptime that a frame type exposes every
/// declaration the core handlers call, so a frame with a different data layout
/// (custom stack, custom memory) can reuse the same handler algorithms.
///
/// Core contract (used by arithmetic, comparison, bitwise and the dispatcher):
///
/// | Member                                         | Kind   | Notes                                       |
/// |------------------------------------------------|--------|---------------------------------------------|
/// | `EvmError`                                     | decl   | Error set returned by every handler         |
/// | `pc`                                           | field  | Integer program counter, advanced by 1      |
/// | `popStack(*Self) EvmError!u256`                | method | Remove and return the top word              |
/// | `pushStack(*Self, u256) EvmError!void`         | method | Push a word                                 |
/// | `peekStack(*const Self, usize) EvmError!u256`  | method | Read the word `index` slots below the top   |
/// | `setStackTop(*Self, u256) void`                | method | Overwrite the top word; caller has already  |
/// |                                                |        | proven the stack is non-empty via a peek    |
/// | `consumeGas(*Self, u64) EvmError!void`         | method | Required only when `config.charge_gas`      |
///
/// Opcode families that touch memory, storage, calls or block context need the
/// additional members listed in each handler module's doc comment.
const std = @import("std");

/// Comptime options for handler instantiation.
pub const HandlerConfig = struct {
    /// When false, handlers skip every `consumeGas` call. Callers that account
    /// for gas themselves (e.g. per-basic-block in guillotine-performance) use this.
    /// Gas-dependent semantics that read `gas_remaining` directly (SSTORE sentry,
    /// CALL forwarding, GAS opcode) are unchanged.
    charge_gas: bool = true,
};

/// Required method names, excluding `consumeGas` which depends on `HandlerConfig`.
const required_methods = [_][]const u8{ "popStack", "pushStack", "peekStack", "setStackTop" };

/// Returns the name of the first missing interface member, or null if `FrameType`
/// satisfies the core frame interface for `config`.
pub fn missingFrameMember(comptime FrameType: type, comptime config: HandlerConfig) ?[]const u8 {
    if (!@hasDecl(FrameType, "EvmError")) return "EvmError";
    if (@typeInfo(FrameType.EvmError) != .error_set) return "EvmError";
    if (!@hasField(FrameType, "pc")) return "pc";
    inline for (required_methods) |name| {
        if (!@hasDecl(FrameType, name)) return name;
        if (@typeInfo(@TypeOf(@field(FrameType, name))) != .@"fn") return name;
    }
    if (config.charge_gas) {
        if (!@hasDecl(FrameType, "consumeGas")) return "consumeGas";
        if (@typeInfo(@TypeOf(FrameType.consumeGas)) != .@"fn") return "consumeGas";
    }
    return null;
}

/// Comptime check that `FrameType` implements the core frame interface.
/// Emits a compile error naming the first missing member.
pub fn checkFrameInterface(comptime FrameType: type, comptime config: HandlerConfig) void {
    if (comptime missingFrameMember(FrameType, config)) |name| {
        @compileError("Frame type '" ++ @typeName(FrameType) ++ "' does not implement frame interface member '" ++ name ++ "'");
    }
}

// ================================ Tests ================================

const handlers_arithmetic = @import("handlers_arithmetic.zig");
const handlers_comparison = @import("handlers_comparison.zig");
const handlers_bitwise = @import("handlers_bitwise.zig");

/// Minimal frame with a fixed-size array stack and no gas tracking, mirroring
/// the shape of a performance-oriented frame.
const PerfFrame = struct {
    pub const EvmError = error{ StackUnderflow, StackOverflow, OutOfGas, InvalidOpcode };

    stack: [16]u256 = undefined,
    len: usize = 0,
    pc: u32 = 0,

    pub fn popStack(self: *PerfFrame) EvmError!u256 {
        if (self.len == 0) return error.StackUnderflow;
        self.len -= 1;
        return self.stack[self.len];
    }
    pub fn pushStack(self: *PerfFrame, value: u256) EvmError!void {
        if (self.len == self.stack.len) return error.StackOverflow;
        self.stack[self.len] = value;
        self.len += 1;
    }
    pub fn peekStack(self: *const PerfFrame, index: usize) EvmError!u256 {
        if (index >= self.len) return error.StackUnderflow;
        return self.stack[self.len - 1 - index];
    }
    pub fn setStackTop(self: *PerfFrame, value: u256) void {
        std.debug.assert(self.len > 0);
        self.stack[self.len - 1] = value;
    }
};

const GasFrame = struct {
    pub const EvmError = PerfFrame.EvmError;
    inner: PerfFrame = .{},
    pc: u32 = 0,
    gas_used: u64 = 0,

    pub fn popStack(self: *GasFrame) EvmError!u256 {
        return self.inner.popStack();
    }
    pub fn pushStack(self: *GasFrame, value: u256) EvmError!void {
        return self.inner.pushStack(value);
    }
    pub fn peekStack(self: *const GasFrame, index: usize) EvmError!u256 {
        return self.inner.peekStack(index);
    }
    pub fn setStackTop(self: *GasFrame, value: u256) void {
        self.inner.setStackTop(value);
    }
    pub fn consumeGas(self: *GasFrame, amount: u64) EvmError!void {
        self.gas_used += amount;
    }
};

test "checkFrameInterface accepts the guillotine-mini Frame" {
    const Frame = @import("../frame.zig").Frame(.{});
    comptime checkFrameInterface(Frame, .{});
    try std.testing.expect(missingFrameMember(Frame, .{}) == null);
}

test "missingFrameMember reports the first missing member" {
    try std.testing.expect(missingFrameMember(PerfFrame, .{ .charge_gas = false }) == null);
    try std.testing.expectEqualStrings("consumeGas", missingFrameMember(PerfFrame, .{}).?);

    const NoPeek = struct {
        pub const EvmError = error{StackUnderflow};
        pc: u32 = 0,
        pub fn popStack(_: *@This()) EvmError!u256 {
            return 0;
        }
        pub fn pushStack(_: *@This(), _: u256) EvmError!void {}
    };
    try std.testing.expectEqualStrings("peekStack", missingFrameMember(NoPeek, .{}).?);

    const NoPc = struct {
        pub const EvmError = error{StackUnderflow};
    };
    try std.testing.expectEqualStrings("pc", missingFrameMember(NoPc, .{}).?);
    try std.testing.expectEqualStrings("EvmError", missingFrameMember(struct {}, .{}).?);
}

test "core handlers run on a custom frame without consumeGas when charge_gas is false" {
    const config: HandlerConfig = .{ .charge_gas = false };
    const Arith = handlers_arithmetic.HandlersWithConfig(PerfFrame, config);
    const Cmp = handlers_comparison.HandlersWithConfig(PerfFrame, config);
    const Bit = handlers_bitwise.HandlersWithConfig(PerfFrame, config);

    var frame = PerfFrame{};
    try frame.pushStack(7); // second
    try frame.pushStack(5); // top
    try Arith.add(&frame);
    try std.testing.expectEqual(@as(usize, 1), frame.len);
    try std.testing.expectEqual(@as(u256, 12), try frame.peekStack(0));

    try frame.pushStack(20);
    try Arith.sub(&frame); // 20 - 12
    try std.testing.expectEqual(@as(u256, 8), try frame.peekStack(0));

    try Cmp.iszero(&frame);
    try std.testing.expectEqual(@as(u256, 0), try frame.peekStack(0));

    try Bit.op_not(&frame);
    try std.testing.expectEqual(std.math.maxInt(u256), try frame.peekStack(0));

    try std.testing.expectEqual(@as(u32, 4), frame.pc);

    var empty = PerfFrame{};
    try empty.pushStack(1);
    try std.testing.expectError(error.StackUnderflow, Arith.mul(&empty));
}

test "charge_gas toggles consumeGas calls" {
    var charged = GasFrame{};
    try charged.pushStack(2);
    try charged.pushStack(3);
    try handlers_arithmetic.HandlersWithConfig(GasFrame, .{}).mul(&charged);
    try std.testing.expectEqual(@as(u64, 5), charged.gas_used);
    try std.testing.expectEqual(@as(u256, 6), try charged.peekStack(0));

    var uncharged = GasFrame{};
    try uncharged.pushStack(2);
    try uncharged.pushStack(3);
    try handlers_arithmetic.HandlersWithConfig(GasFrame, .{ .charge_gas = false }).mul(&uncharged);
    try std.testing.expectEqual(@as(u64, 0), uncharged.gas_used);
    try std.testing.expectEqual(@as(u256, 6), try uncharged.peekStack(0));
}

test "DispatcherWithConfig runs the real Frame with and without gas charging" {
    const test_helpers = @import("test_helpers.zig");
    const dispatcher = @import("dispatcher.zig");
    const GasConstants = @import("voltaire").GasConstants;

    var charged = try test_helpers.TestHelper.init(std.testing.allocator);
    defer charged.deinit();
    try charged.pushStack(10);
    try charged.pushStack(20);
    try dispatcher.Dispatcher(test_helpers.TestFrameType).execute(charged.frame, 0x01);
    try charged.assertStackTop(30);
    try charged.assertStackSize(1);
    try charged.assertGasConsumed(GasConstants.GasFastestStep);

    var uncharged = try test_helpers.TestHelper.init(std.testing.allocator);
    defer uncharged.deinit();
    try uncharged.pushStack(10);
    try uncharged.pushStack(20);
    try dispatcher.DispatcherWithConfig(test_helpers.TestFrameType, .{ .charge_gas = false }).execute(uncharged.frame, 0x01);
    try uncharged.assertStackTop(30);
    try uncharged.assertStackSize(1);
    try uncharged.assertGasConsumed(0);
    try uncharged.assertPC(1);
}
