//! EVMC ABI 12 shared-library entry point (`evmc_create_guillotine_mini`).
const std = @import("std");
const primitives = @import("voltaire");
const evm_mod = @import("evm.zig");
const host_mod = @import("host.zig");
const logger = @import("logger.zig");
const evmc = @import("evmc_adapter.zig");

const Address = primitives.Address;
const Evm = evm_mod.Evm(.{});
const CallParams = Evm.CallParams;
const CallResult = Evm.CallResult;
const HostInterface = host_mod.HostInterface;
const Addr = evmc.EvmcAddress;
const B32 = evmc.EvmcBytes32;
const Msg = evmc.EvmcMessage;
const Res = evmc.EvmcResult;
const SC = evmc.EvmcStatusCode;
const HostIf = evmc.EvmcHostInterface;
const HostCtx = evmc.EvmcHostContext;

pub const EVMC_CAPABILITY_EVM1: u32 = 1 << 0;
pub const EVMC_CAPABILITY_PRECOMPILES: u32 = 1 << 2;

pub const EvmcSetOptionResult = enum(c_int) { success = 0, invalid_name = 1, invalid_value = 2 };

pub const EvmcVm = extern struct {
    abi_version: c_int,
    name: [*:0]const u8,
    version: [*:0]const u8,
    destroy: *const fn (?*EvmcVm) callconv(.c) void,
    execute: *const fn (
        ?*EvmcVm,
        ?*const HostIf,
        ?*HostCtx,
        evmc.EvmcRevision,
        ?*const Msg,
        ?[*]const u8,
        usize,
    ) callconv(.c) Res,
    get_capabilities: *const fn (?*EvmcVm) callconv(.c) u32,
    set_option: ?*const fn (?*EvmcVm, ?[*:0]const u8, ?[*:0]const u8) callconv(.c) EvmcSetOptionResult,
};

const GuillotineVm = struct { vm: EvmcVm, log_level: logger.LogLevel = .none };

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var alloc: std.mem.Allocator = gpa.allocator();

const HostProxy = struct {
    arena: std.mem.Allocator,
    host: *const HostIf,
    ctx: ?*HostCtx,
    balances: std.AutoHashMapUnmanaged(Address, u256) = .{},
    nonces: std.AutoHashMapUnmanaged(Address, u64) = .{},
    codes: std.AutoHashMapUnmanaged(Address, []const u8) = .{},

    const vt: HostInterface.VTable = .{
        .getBalance = getBalance,
        .setBalance = setBalance,
        .getCode = getCode,
        .setCode = setCode,
        .getStorage = getStorage,
        .setStorage = setStorage,
        .getNonce = getNonce,
        .setNonce = setNonce,
        .accountExists = accountExists,
    };

    fn asInterface(self: *HostProxy) HostInterface {
        return .{ .ptr = self, .vtable = &vt };
    }
    fn cast(ptr: *anyopaque) *HostProxy {
        return @ptrCast(@alignCast(ptr));
    }
    fn getBalance(ptr: *anyopaque, addr: Address) u256 {
        const s = cast(ptr);
        if (s.balances.get(addr)) |bal| return bal;
        const a = Addr.fromAddress(addr);
        return s.host.get_balance(s.ctx, &a).toU256();
    }
    fn setBalance(p: *anyopaque, a: Address, v: u256) void {
        cast(p).balances.put(cast(p).arena, a, v) catch |e| logger.err("evmc bal: {s}", .{@errorName(e)});
    }
    fn getCode(p: *anyopaque, addr: Address) []const u8 {
        const s = cast(p);
        if (s.codes.get(addr)) |c| return c;
        const a = Addr.fromAddress(addr);
        const sz = s.host.get_code_size(s.ctx, &a);
        if (sz == 0) return &.{};
        const buf = s.arena.alloc(u8, sz) catch return &.{};
        const sl = buf[0..@min(s.host.copy_code(s.ctx, &a, 0, buf.ptr, sz), sz)];
        s.codes.put(s.arena, addr, sl) catch |e| logger.err("evmc code: {s}", .{@errorName(e)});
        return sl;
    }
    fn setCode(p: *anyopaque, a: Address, code: []const u8) void {
        const s = cast(p);
        const cp = s.arena.dupe(u8, code) catch return;
        s.codes.put(s.arena, a, cp) catch |e| logger.err("evmc code: {s}", .{@errorName(e)});
    }
    fn getStorage(p: *anyopaque, addr: Address, slot: u256) u256 {
        const s = cast(p);
        const a = Addr.fromAddress(addr);
        const k = B32.fromU256(slot);
        return s.host.get_storage(s.ctx, &a, &k).toU256();
    }
    fn setStorage(p: *anyopaque, addr: Address, slot: u256, val: u256) void {
        const s = cast(p);
        const a = Addr.fromAddress(addr);
        const k = B32.fromU256(slot);
        const v = B32.fromU256(val);
        _ = s.host.set_storage(s.ctx, &a, &k, &v);
    }
    fn getNonce(p: *anyopaque, a: Address) u64 {
        return cast(p).nonces.get(a) orelse 0;
    }
    fn setNonce(p: *anyopaque, a: Address, n: u64) void {
        cast(p).nonces.put(cast(p).arena, a, n) catch |e| logger.err("evmc nonce: {s}", .{@errorName(e)});
    }
    fn accountExists(p: *anyopaque, addr: Address) bool {
        const s = cast(p);
        const a = Addr.fromAddress(addr);
        return s.balances.contains(addr) or s.codes.contains(addr) or s.host.account_exists(s.ctx, &a);
    }
};

/// Create a Guillotine Mini EVMC ABI 12 VM instance.
pub export fn evmc_create_guillotine_mini() callconv(.c) ?*EvmcVm {
    const inst = alloc.create(GuillotineVm) catch return null;
    inst.* = .{ .vm = .{
        .abi_version = evmc.EVMC_ABI_VERSION,
        .name = "guillotine-mini",
        .version = "0.2.0",
        .destroy = destroyCb,
        .execute = executeCb,
        .get_capabilities = getCapabilitiesCb,
        .set_option = setOptionCb,
    } };
    std.debug.assert(inst.vm.abi_version == 12);
    return &inst.vm;
}

fn destroyCb(vm: ?*EvmcVm) callconv(.c) void {
    const ptr = vm orelse return;
    alloc.destroy(@as(*GuillotineVm, @fieldParentPtr("vm", ptr)));
}

fn getCapabilitiesCb(_: ?*EvmcVm) callconv(.c) u32 {
    return EVMC_CAPABILITY_EVM1 | EVMC_CAPABILITY_PRECOMPILES;
}

fn setOptionCb(vm: ?*EvmcVm, name_p: ?[*:0]const u8, val_p: ?[*:0]const u8) callconv(.c) EvmcSetOptionResult {
    const inst: *GuillotineVm = @fieldParentPtr("vm", vm orelse return .invalid_name);
    const name = std.mem.span(name_p orelse return .invalid_name);
    const val = std.mem.span(val_p orelse return .invalid_value);
    if (!std.mem.eql(u8, name, "log_level")) return .invalid_name;
    inst.log_level = std.meta.stringToEnum(logger.LogLevel, val) orelse return .invalid_value;
    return .success;
}

fn releaseResultCb(res: *const Res) callconv(.c) void {
    const ptr = res.output_data orelse return;
    if (res.output_size == 0) return;
    alloc.free(@as([*]u8, @constCast(ptr))[0..res.output_size]);
}

fn errRes(code: SC) Res {
    return .{
        .status_code = code,
        .gas_left = 0,
        .gas_refund = 0,
        .output_data = null,
        .output_size = 0,
        .release = null,
        .create_address = .{},
    };
}

fn mapStatus(res: CallResult) SC {
    if (res.success) return .success;
    const name = res.error_info orelse return .revert;
    const eql = std.mem.eql;
    if (eql(u8, name, "RevertExecution")) return .revert;
    if (eql(u8, name, "OutOfGas") or eql(u8, name, "CodeStoreOutOfGas")) return .out_of_gas;
    if (eql(u8, name, "StackOverflow")) return .stack_overflow;
    if (eql(u8, name, "StackUnderflow")) return .stack_underflow;
    if (eql(u8, name, "InvalidJump") or eql(u8, name, "InvalidJumpDestination")) return .bad_jump_destination;
    if (eql(u8, name, "InvalidOpcode")) return .invalid_instruction;
    if (eql(u8, name, "StaticCallViolation") or eql(u8, name, "WriteProtection")) return .static_mode_violation;
    if (eql(u8, name, "CallDepthExceeded")) return .call_depth_exceeded;
    if (eql(u8, name, "InsufficientBalance")) return .insufficient_balance;
    if (eql(u8, name, "PrecompileError")) return .precompile_failure;
    if (eql(u8, name, "OutOfMemory")) return .out_of_memory;
    return .failure;
}

fn buildBlockCtx(tx: evmc.EvmcTxContext) evm_mod.BlockContext {
    return .{
        .chain_id = tx.chain_id.toU256(),
        .block_number = @intCast(@max(tx.block_number, 0)),
        .block_timestamp = @intCast(@max(tx.block_timestamp, 0)),
        .block_difficulty = tx.block_prev_randao.toU256(),
        .block_prevrandao = tx.block_prev_randao.toU256(),
        .block_coinbase = tx.block_coinbase.toAddress(),
        .block_gas_limit = @intCast(@max(tx.block_gas_limit, 0)),
        .block_base_fee = tx.block_base_fee.toU256(),
        .blob_base_fee = tx.blob_base_fee.toU256(),
    };
}

fn buildParams(msg: *const Msg, input: []const u8) ?CallParams {
    const gas: u64 = @intCast(msg.gas);
    const s = msg.sender.toAddress();
    const r = msg.recipient.toAddress();
    const ca = msg.code_address.toAddress();
    const v = msg.value.toU256();
    return switch (msg.kind) {
        .call => if ((msg.flags & evmc.EVMC_STATIC) != 0)
            .{ .staticcall = .{ .caller = s, .to = r, .input = input, .gas = gas } }
        else
            .{ .call = .{ .caller = s, .to = r, .value = v, .input = input, .gas = gas } },
        .delegatecall => .{ .delegatecall = .{ .caller = s, .to = ca, .input = input, .gas = gas, .value = v } },
        .callcode => .{ .callcode = .{ .caller = s, .to = ca, .value = v, .input = input, .gas = gas } },
        .create => .{ .create = .{ .caller = s, .value = v, .init_code = input, .gas = gas } },
        .create2 => .{
            .create2 = .{ .caller = s, .value = v, .init_code = input, .salt = msg.create2_salt.toU256(), .gas = gas },
        },
        .eofcreate => null,
    };
}

fn forwardLogs(h: *const HostIf, ctx: ?*HostCtx, logs: []const primitives.logs.Log) void {
    for (logs) |lg| {
        const a = Addr.fromAddress(lg.address);
        var topics: [4]B32 = undefined;
        const n = @min(lg.topics.len, 4);
        for (lg.topics[0..n], 0..) |t, i| topics[i] = B32.fromU256(t);
        const dp: ?[*]const u8 = if (lg.data.len > 0) lg.data.ptr else null;
        h.emit_log(ctx, &a, dp, lg.data.len, &topics, n);
    }
}

fn toEvmcResult(res: CallResult) Res {
    var out_p: ?[*]const u8 = null;
    var rel: ?evmc.EvmcReleaseResultFn = null;
    if (res.output.len > 0) {
        const copy = alloc.dupe(u8, res.output) catch return errRes(.out_of_memory);
        out_p = copy.ptr;
        rel = releaseResultCb;
    }
    return .{
        .status_code = mapStatus(res),
        .gas_left = std.math.cast(i64, res.gas_left) orelse std.math.maxInt(i64),
        .gas_refund = std.math.cast(i64, res.refund_counter) orelse std.math.maxInt(i64),
        .output_data = out_p,
        .output_size = res.output.len,
        .release = rel,
        .create_address = if (res.created_address) |a| Addr.fromAddress(a) else .{},
    };
}

fn executeCb(
    vm: ?*EvmcVm,
    host_p: ?*const HostIf,
    ctx: ?*HostCtx,
    rev: evmc.EvmcRevision,
    msg_p: ?*const Msg,
    code_p: ?[*]const u8,
    code_sz: usize,
) callconv(.c) Res {
    const bad = errRes(.argument_out_of_range);
    const inst: *GuillotineVm = @fieldParentPtr("vm", vm orelse return bad);
    const msg = msg_p orelse return bad;
    if (msg.gas < 0 or (msg.input_size > 0 and msg.input_data == null)) return bad;
    if (code_sz > 0 and code_p == null) return bad;
    const input = if (msg.input_size > 0) msg.input_data.?[0..msg.input_size] else &[_]u8{};
    const params = buildParams(msg, input) orelse return errRes(.rejected);

    var tx_arena = std.heap.ArenaAllocator.init(alloc);
    defer tx_arena.deinit();
    var proxy: HostProxy = undefined;
    var host_if: ?HostInterface = null;
    var blk: ?evm_mod.BlockContext = null;
    var origin = msg.sender.toAddress();
    var gas_price: u256 = 0;
    if (host_p) |h| {
        proxy = .{ .arena = tx_arena.allocator(), .host = h, .ctx = ctx };
        host_if = proxy.asInterface();
        const tx = h.get_tx_context(ctx);
        blk = buildBlockCtx(tx);
        origin = tx.tx_origin.toAddress();
        gas_price = tx.tx_gas_price.toU256();
    }

    var evm_inst: Evm = undefined;
    Evm.init(&evm_inst, alloc, host_if, evmc.toHardfork(rev), blk, origin, gas_price, inst.log_level) catch
        return errRes(.out_of_memory);
    defer evm_inst.deinit();

    const code: ?[]const u8 = if (code_sz > 0) code_p.?[0..code_sz] else if (msg.code_size > 0 and msg.code != null)
        msg.code.?[0..msg.code_size]
    else
        null;
    const res = if (params.isCreate()) evm_inst.call(params) else evm_inst.callWithBytecodeOverride(params, code);
    if (host_p) |h| if (res.success and res.logs.len > 0) forwardLogs(h, ctx, res.logs);
    return toEvmcResult(res);
}

test "evmc vtable lifecycle, execution, osaka CLZ, revert, and host callbacks" {
    const t = std.testing;
    const prev = alloc;
    alloc = t.allocator;
    defer alloc = prev;

    const vm = evmc_create_guillotine_mini() orelse return error.OutOfMemory;
    defer vm.destroy(vm);
    try t.expectEqual(@as(c_int, 12), vm.abi_version);
    try t.expectEqualStrings("guillotine-mini", std.mem.span(vm.name));
    try t.expectEqual(EVMC_CAPABILITY_EVM1 | EVMC_CAPABILITY_PRECOMPILES, vm.get_capabilities(vm));
    const opt = vm.set_option orelse return error.MissingSetOption;
    try t.expectEqual(EvmcSetOptionResult.success, opt(vm, "log_level", "none"));
    try t.expectEqual(EvmcSetOptionResult.invalid_value, opt(vm, "log_level", "bad"));
    try t.expectEqual(EvmcSetOptionResult.invalid_name, opt(vm, "nope", "1"));

    const tgt = Addr.fromAddress(Address.fromU256(0x200));
    const msg: Msg = .{
        .kind = .call,
        .flags = 0,
        .depth = 0,
        .gas = 100_000,
        .recipient = tgt,
        .sender = Addr.fromAddress(Address.fromU256(0x100)),
        .input_data = null,
        .input_size = 0,
        .value = .{},
        .create2_salt = .{},
        .code_address = tgt,
    };

    const e = struct {
        fn ok(c: []const u8, exp: u8, v: *EvmcVm, m: *const Msg) !void {
            const r = v.execute(v, null, null, .osaka, m, c.ptr, c.len);
            defer if (r.release) |rel| rel(&r);
            try t.expectEqual(SC.success, r.status_code);
            try t.expectEqual(exp, r.output_data.?[31]);
        }
    };
    try e.ok(&.{ 0x60, 0x2a, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 }, 42, vm, &msg);
    try e.ok(&.{ 0x60, 0x01, 0x1e, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 }, 255, vm, &msg);
    const rev = [_]u8{ 0x63, 0xde, 0xad, 0xbe, 0xef, 0x60, 0x00, 0x52, 0x60, 0x04, 0x60, 0x1c, 0xfd };
    const r3 = vm.execute(vm, null, null, .osaka, &msg, &rev, rev.len);
    defer if (r3.release) |rel| rel(&r3);
    try t.expectEqual(SC.revert, r3.status_code);
    try t.expectEqualSlices(u8, &[_]u8{ 0xde, 0xad, 0xbe, 0xef }, r3.output_data.?[0..4]);

    const MH = struct {
        slot0: u256 = 0,
        fn zB(_: *anyopaque, _: Address) u256 {
            return 0;
        }
        fn nB(_: *anyopaque, _: Address, _: u256) void {}
        fn zC(_: *anyopaque, _: Address) []const u8 {
            return &.{};
        }
        fn nC(_: *anyopaque, _: Address, _: []const u8) void {}
        fn gS(p: *anyopaque, _: Address, _: u256) u256 {
            return @as(*@This(), @ptrCast(@alignCast(p))).slot0;
        }
        fn sS(p: *anyopaque, _: Address, _: u256, v: u256) void {
            @as(*@This(), @ptrCast(@alignCast(p))).slot0 = v;
        }
        fn zN(_: *anyopaque, _: Address) u64 {
            return 0;
        }
        fn nN(_: *anyopaque, _: Address, _: u64) void {}
    };
    var mh = MH{};
    const vt: HostInterface.VTable = .{
        .getBalance = MH.zB,
        .setBalance = MH.nB,
        .getCode = MH.zC,
        .setCode = MH.nC,
        .getStorage = MH.gS,
        .setStorage = MH.sS,
        .getNonce = MH.zN,
        .setNonce = MH.nN,
    };
    var br = evmc.EvmcHostBridge.init(t.allocator, .{ .ptr = &mh, .vtable = &vt }, .{});
    defer br.deinit();
    const hc = [_]u8{ 0x60, 0x07, 0x5f, 0x55, 0x5f, 0x54, 0x5f, 0x52, 0x60, 0x20, 0x5f, 0xa0, 0x60, 0x20, 0x5f, 0xf3 };
    const r4 = vm.execute(vm, evmc.EvmcHostBridge.hostInterface(), br.hostContext(), .osaka, &msg, &hc, hc.len);
    defer if (r4.release) |rel| rel(&r4);
    try t.expectEqual(SC.success, r4.status_code);
    try t.expectEqual(@as(u256, 7), mh.slot0);
    try t.expectEqual(@as(usize, 1), br.logs.items.len);
}
