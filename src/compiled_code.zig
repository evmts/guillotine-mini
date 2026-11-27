//! Basic-block gas/stack fusion & superinstruction bytecode compiler for guillotine-mini.
//!
//! Compiles raw EVM bytecode into a compact 16-byte instruction stream (`Inst`) in a single
//! linear pass:
//! - Basic-block static gas & stack-bounds fusion (`begin_block`): validates total block gas,
//!   minimum stack depth, and peak stack growth once per basic block instead of per opcode.
//! - Pre-decoded immediates (`push_u64` for PUSH1..8, `const_pool` for PUSH9..32).
//! - Pre-validated static jump targets (`push_jump`, `push_jumpi`, `iszero_push_jumpi`).
//! - Immediate arithmetic/comparison/bitwise superinstructions (`push_add`, `push_sub`, `push_mul`,
//!   `push_lt`, `push_gt`, `push_eq`, `push_and`, `push_shl`, `push_shr`, `swap1_pop`).
//! - Trailing sentinel `.stop` so the dispatch loop never checks `ip >= ops.len`.
//!
//! Safety guarantee: whenever a `begin_block` entry check fails (OutOfGas / StackUnderflow /
//! StackOverflow), execution falls back to the exact un-fused opcode interpreter from the
//! block's original `raw_pc`, preserving exact EVM error semantics and error PCs.

const std = @import("std");
const primitives = @import("voltaire");
const GasConstants = primitives.GasConstants;
const Hardfork = primitives.Hardfork;
const hardfork_hooks = @import("hardfork_hooks.zig");

pub const INVALID_TARGET: u32 = std.math.maxInt(u32);

pub const HardforkFlags = packed struct(u8) {
    has_push0: bool = false,
    has_shift: bool = false,
    has_mcopy: bool = false,
    has_returndata: bool = false,
    is_amsterdam: bool = false,
    _pad: u3 = 0,

    pub fn fromHardfork(hf: Hardfork) HardforkFlags {
        return .{
            .has_push0 = hf.isAtLeast(.SHANGHAI),
            .has_shift = hf.isAtLeast(.CONSTANTINOPLE),
            .has_mcopy = hf.isAtLeast(.CANCUN),
            .has_returndata = hf.isAtLeast(.BYZANTIUM),
            .is_amsterdam = hardfork_hooks.supportsAmsterdam(hf),
        };
    }

    pub inline fn asU8(self: HardforkFlags) u8 {
        return @bitCast(self);
    }
};

pub const BlockMeta = packed struct(u64) {
    gas: u32,
    min_stack: u16,
    max_growth: u16,
};

pub const Op = enum(u8) {
    begin_block,
    // Fused superinstructions
    push_u64,
    push_const,
    push_jump,
    push_jumpi,
    iszero_push_jumpi,
    dup1_iszero_push_jumpi,
    push_add,
    push_sub,
    push_swap1_sub,
    push_mul,
    push_lt,
    push_swap1_lt,
    push_gt,
    push_swap1_gt,
    push_eq,
    push_and,
    push_shl,
    push_shr,
    swap1_pop,
    // Pure static-gas opcodes (executed with zero per-op gas/stack checks inside a block)
    stop,
    add,
    mul,
    sub,
    div,
    sdiv,
    mod,
    smod,
    addmod,
    mulmod,
    signextend,
    lt,
    gt,
    slt,
    sgt,
    eq,
    iszero,
    bit_and,
    bit_or,
    bit_xor,
    bit_not,
    byte_op,
    shl,
    shr,
    sar,
    address_op,
    caller,
    callvalue,
    calldatasize,
    returndatasize,
    pop,
    push0,
    dup1,
    dup2,
    dup3,
    dup4,
    dup5,
    dup6,
    dup7,
    dup8,
    dup9,
    dup10,
    dup11,
    dup12,
    dup13,
    dup14,
    dup15,
    dup16,
    swap1,
    swap2,
    swap3,
    swap4,
    swap5,
    swap6,
    swap7,
    swap8,
    swap9,
    swap10,
    swap11,
    swap12,
    swap13,
    swap14,
    swap15,
    swap16,
    jump,
    jumpi,
    pc_op,
    // Inlined dynamic/memory/calldata/keccak opcodes (executed outside static block gas)
    mload,
    mstore,
    mstore8,
    msize,
    mcopy,
    calldataload,
    keccak256,
    // Fallback to standard frame.step() at raw_pc (`aux`)
    fallback,
};

pub const Inst = struct {
    op: Op,
    aux: u32 = 0,
    imm: u64 = 0,
};

pub const JumpDestEntry = struct {
    pc: u32,
    ip: u32,
};

/// O(log J) lookup of valid JUMPDEST `pc` -> compiled instruction index `ip`.
pub inline fn resolveJumpDestSlice(jumpdests: []const JumpDestEntry, target_pc: u32) ?u32 {
    var lo: usize = 0;
    var hi: usize = jumpdests.len;
    while (lo < hi) {
        const mid = lo + ((hi - lo) >> 1);
        const mid_pc = jumpdests[mid].pc;
        if (mid_pc == target_pc) return jumpdests[mid].ip;
        if (mid_pc < target_pc) lo = mid + 1 else hi = mid;
    }
    return null;
}

pub const CompiledCode = struct {
    ops: []Inst,
    const_pool: []u256,
    jumpdests: []JumpDestEntry,
    /// Exact copy of raw code bytes for collision-free cache lookup (only owned if cached).
    code_copy: []u8 = &.{},
    hash: u64 = 0,
    flags: u8 = 0,

    pub fn deinit(self: *CompiledCode, allocator: std.mem.Allocator) void {
        if (self.ops.len > 0) allocator.free(self.ops);
        if (self.const_pool.len > 0) allocator.free(self.const_pool);
        if (self.jumpdests.len > 0) allocator.free(self.jumpdests);
        if (self.code_copy.len > 0) allocator.free(self.code_copy);
        self.* = .{ .ops = &.{}, .const_pool = &.{}, .jumpdests = &.{} };
    }

    /// O(log J) lookup of valid JUMPDEST `pc` -> compiled instruction index `ip`.
    pub inline fn resolveJumpDest(self: *const CompiledCode, target_pc: u32) ?u32 {
        return resolveJumpDestSlice(self.jumpdests, target_pc);
    }
};

const StaticOpInfo = struct {
    op: Op,
    gas: u32,
    inputs: u16,
    outputs: u16,
};

fn classifyStaticOp(byte: u8, flags: HardforkFlags) ?StaticOpInfo {
    return switch (byte) {
        0x01 => .{ .op = .add, .gas = GasConstants.GasFastestStep, .inputs = 2, .outputs = 1 },
        0x02 => .{ .op = .mul, .gas = GasConstants.GasFastStep, .inputs = 2, .outputs = 1 },
        0x03 => .{ .op = .sub, .gas = GasConstants.GasFastestStep, .inputs = 2, .outputs = 1 },
        0x04 => .{ .op = .div, .gas = GasConstants.GasFastStep, .inputs = 2, .outputs = 1 },
        0x05 => .{ .op = .sdiv, .gas = GasConstants.GasFastStep, .inputs = 2, .outputs = 1 },
        0x06 => .{ .op = .mod, .gas = GasConstants.GasFastStep, .inputs = 2, .outputs = 1 },
        0x07 => .{ .op = .smod, .gas = GasConstants.GasFastStep, .inputs = 2, .outputs = 1 },
        0x08 => .{ .op = .addmod, .gas = GasConstants.GasMidStep, .inputs = 3, .outputs = 1 },
        0x09 => .{ .op = .mulmod, .gas = GasConstants.GasMidStep, .inputs = 3, .outputs = 1 },
        0x0b => .{ .op = .signextend, .gas = GasConstants.GasFastStep, .inputs = 2, .outputs = 1 },
        0x10 => .{ .op = .lt, .gas = GasConstants.GasFastestStep, .inputs = 2, .outputs = 1 },
        0x11 => .{ .op = .gt, .gas = GasConstants.GasFastestStep, .inputs = 2, .outputs = 1 },
        0x12 => .{ .op = .slt, .gas = GasConstants.GasFastestStep, .inputs = 2, .outputs = 1 },
        0x13 => .{ .op = .sgt, .gas = GasConstants.GasFastestStep, .inputs = 2, .outputs = 1 },
        0x14 => .{ .op = .eq, .gas = GasConstants.GasFastestStep, .inputs = 2, .outputs = 1 },
        0x15 => .{ .op = .iszero, .gas = GasConstants.GasFastestStep, .inputs = 1, .outputs = 1 },
        0x16 => .{ .op = .bit_and, .gas = GasConstants.GasFastestStep, .inputs = 2, .outputs = 1 },
        0x17 => .{ .op = .bit_or, .gas = GasConstants.GasFastestStep, .inputs = 2, .outputs = 1 },
        0x18 => .{ .op = .bit_xor, .gas = GasConstants.GasFastestStep, .inputs = 2, .outputs = 1 },
        0x19 => .{ .op = .bit_not, .gas = GasConstants.GasFastestStep, .inputs = 1, .outputs = 1 },
        0x1a => .{ .op = .byte_op, .gas = GasConstants.GasFastestStep, .inputs = 2, .outputs = 1 },
        0x1b => if (flags.has_shift)
            .{ .op = .shl, .gas = GasConstants.GasFastestStep, .inputs = 2, .outputs = 1 }
        else
            null,
        0x1c => if (flags.has_shift)
            .{ .op = .shr, .gas = GasConstants.GasFastestStep, .inputs = 2, .outputs = 1 }
        else
            null,
        0x1d => if (flags.has_shift)
            .{ .op = .sar, .gas = GasConstants.GasFastestStep, .inputs = 2, .outputs = 1 }
        else
            null,
        0x30 => .{ .op = .address_op, .gas = GasConstants.GasQuickStep, .inputs = 0, .outputs = 1 },
        0x33 => .{ .op = .caller, .gas = GasConstants.GasQuickStep, .inputs = 0, .outputs = 1 },
        0x34 => .{ .op = .callvalue, .gas = GasConstants.GasQuickStep, .inputs = 0, .outputs = 1 },
        0x35 => .{ .op = .calldataload, .gas = GasConstants.GasFastestStep, .inputs = 1, .outputs = 1 },
        0x36 => .{ .op = .calldatasize, .gas = GasConstants.GasQuickStep, .inputs = 0, .outputs = 1 },
        0x3d => if (flags.has_returndata)
            .{ .op = .returndatasize, .gas = GasConstants.GasQuickStep, .inputs = 0, .outputs = 1 }
        else
            null,
        0x50 => .{ .op = .pop, .gas = GasConstants.GasQuickStep, .inputs = 1, .outputs = 0 },
        0x58 => .{ .op = .pc_op, .gas = GasConstants.GasQuickStep, .inputs = 0, .outputs = 1 },
        0x59 => .{ .op = .msize, .gas = GasConstants.GasQuickStep, .inputs = 0, .outputs = 1 },
        0x5f => if (flags.has_push0)
            .{ .op = .push0, .gas = GasConstants.GasQuickStep, .inputs = 0, .outputs = 1 }
        else
            null,
        0x80...0x8f => |op| .{
            .op = @enumFromInt(@intFromEnum(Op.dup1) + (op - 0x80)),
            .gas = GasConstants.GasFastestStep,
            .inputs = @as(u16, op - 0x80) + 1,
            .outputs = @as(u16, op - 0x80) + 2,
        },
        0x90...0x9f => |op| .{
            .op = @enumFromInt(@intFromEnum(Op.swap1) + (op - 0x90)),
            .gas = GasConstants.GasFastestStep,
            .inputs = @as(u16, op - 0x90) + 2,
            .outputs = @as(u16, op - 0x90) + 2,
        },
        else => null,
    };
}

inline fn readPushU64(code: []const u8, pc: usize, n: usize) u64 {
    var val: u64 = 0;
    const start = pc + 1;
    for (0..n) |i| {
        const b: u8 = if (start + i < code.len) code[start + i] else 0;
        val = (val << 8) | b;
    }
    return val;
}

inline fn readPushU256(code: []const u8, pc: usize, n: usize) u256 {
    var buf: [32]u8 = [_]u8{0} ** 32;
    const start = pc + 1;
    const avail = if (start < code.len) @min(code.len - start, n) else 0;
    if (avail > 0) {
        @memcpy(buf[32 - n .. 32 - n + avail], code[start .. start + avail]);
    }
    return std.mem.readInt(u256, &buf, .big);
}

const BlockAcc = struct {
    open: bool = false,
    header_ip: usize = 0,
    gas: u32 = 0,
    cur_delta: i32 = 0,
    min_stack: i32 = 0,
    max_growth: i32 = 0,

    fn ensureOpen(self: *BlockAcc, ops: *std.ArrayList(Inst), alloc: std.mem.Allocator, raw_pc: usize) !void {
        if (!self.open) {
            self.header_ip = ops.items.len;
            try ops.append(alloc, .{ .op = .begin_block, .aux = @intCast(raw_pc), .imm = 0 });
            self.open = true;
            self.gas = 0;
            self.cur_delta = 0;
            self.min_stack = 0;
            self.max_growth = 0;
        }
    }

    inline fn record(self: *BlockAcc, gas: u32, inputs: u16, outputs: u16) void {
        self.gas += gas;
        const need = @as(i32, inputs) - self.cur_delta;
        if (need > self.min_stack) self.min_stack = need;
        self.cur_delta += @as(i32, outputs) - @as(i32, inputs);
        if (self.cur_delta > self.max_growth) self.max_growth = self.cur_delta;
    }

    fn close(self: *BlockAcc, ops: *std.ArrayList(Inst)) void {
        if (!self.open) return;
        const meta = BlockMeta{
            .gas = self.gas,
            .min_stack = @intCast(@max(self.min_stack, 0)),
            .max_growth = @intCast(@max(self.max_growth, 0)),
        };
        ops.items[self.header_ip].imm = @bitCast(meta);
        self.open = false;
    }
};

const PendingJump = struct {
    inst_ip: usize,
    target_pc: u64,
};

pub fn compile(allocator: std.mem.Allocator, code: []const u8, hardfork: Hardfork) !CompiledCode {
    const flags = HardforkFlags.fromHardfork(hardfork);

    var ops = std.ArrayList(Inst){};
    errdefer ops.deinit(allocator);
    try ops.ensureTotalCapacity(allocator, code.len + 16);

    var const_pool = std.ArrayList(u256){};
    errdefer const_pool.deinit(allocator);

    var jumpdests = std.ArrayList(JumpDestEntry){};
    errdefer jumpdests.deinit(allocator);

    var pending_jumps = std.ArrayList(PendingJump){};
    defer pending_jumps.deinit(allocator);

    var blk = BlockAcc{};
    var pc: usize = 0;

    while (pc < code.len) {
        const b = code[pc];

        // JUMPDEST (0x5b): terminates previous block and starts a new block at this ip.
        if (b == 0x5b) {
            blk.close(&ops);
            const jd_ip: u32 = @intCast(ops.items.len);
            try jumpdests.append(allocator, .{ .pc = @intCast(pc), .ip = jd_ip });
            try blk.ensureOpen(&ops, allocator, pc);
            blk.record(GasConstants.JumpdestGas, 0, 0);
            pc += 1;
            continue;
        }

        // STOP (0x00)
        if (b == 0x00) {
            blk.close(&ops);
            try ops.append(allocator, .{ .op = .stop, .aux = @intCast(pc) });
            pc += 1;
            continue;
        }

        // DUP1 + ISZERO + PUSH1..4 + JUMPI fusion (universal loop / guard pattern)
        if (b == 0x80 and pc + 2 < code.len and code[pc + 1] == 0x15) {
            const b2 = code[pc + 2];
            if (b2 >= 0x60 and b2 <= 0x63) {
                const n: usize = @as(usize, b2 - 0x60) + 1;
                const next_pc = pc + 3 + n;
                if (next_pc < code.len and code[next_pc] == 0x57) {
                    const target_pc = readPushU64(code, pc + 2, n);
                    try blk.ensureOpen(&ops, allocator, pc);
                    // Record EXACT un-fused gas and peak stack for DUP1, ISZERO, PUSHn, JUMPI
                    blk.record(GasConstants.GasFastestStep, 1, 2); // DUP1
                    blk.record(GasConstants.GasFastestStep, 1, 1); // ISZERO
                    blk.record(GasConstants.GasFastestStep, 0, 1); // PUSHn (peak +2!)
                    blk.record(GasConstants.GasSlowStep, 2, 0); // JUMPI
                    const ip = ops.items.len;
                    try ops.append(allocator, .{ .op = .dup1_iszero_push_jumpi, .aux = INVALID_TARGET, .imm = pc });
                    try pending_jumps.append(allocator, .{ .inst_ip = ip, .target_pc = target_pc });
                    blk.close(&ops);
                    pc = next_pc + 1;
                    continue;
                }
            }
        }

        // ISZERO + PUSH1..4 + JUMPI fusion (Solidity if/require/loop pattern)
        if (b == 0x15 and pc + 1 < code.len) {
            const b1 = code[pc + 1];
            if (b1 >= 0x60 and b1 <= 0x63) {
                const n: usize = @as(usize, b1 - 0x60) + 1;
                const next_pc = pc + 2 + n;
                if (next_pc < code.len and code[next_pc] == 0x57) {
                    const target_pc = readPushU64(code, pc + 1, n);
                    try blk.ensureOpen(&ops, allocator, pc);
                    // Record EXACT un-fused gas and peak stack for ISZERO, PUSHn, JUMPI
                    blk.record(GasConstants.GasFastestStep, 1, 1); // ISZERO
                    blk.record(GasConstants.GasFastestStep, 0, 1); // PUSHn (peak +1!)
                    blk.record(GasConstants.GasSlowStep, 2, 0); // JUMPI
                    const ip = ops.items.len;
                    try ops.append(allocator, .{ .op = .iszero_push_jumpi, .aux = INVALID_TARGET, .imm = pc });
                    try pending_jumps.append(allocator, .{ .inst_ip = ip, .target_pc = target_pc });
                    blk.close(&ops);
                    pc = next_pc + 1;
                    continue;
                }
            }
        }

        // PUSH1..PUSH8 (0x60..0x67) with superinstruction fusion
        if (b >= 0x60 and b <= 0x67) {
            const n: usize = @as(usize, b - 0x60) + 1;
            const imm = readPushU64(code, pc, n);
            const next_pc = pc + 1 + n;

            if (next_pc < code.len) {
                const next_op = code[next_pc];

                // PUSH1..4 + JUMP / JUMPI
                if (n <= 4 and (next_op == 0x56 or next_op == 0x57)) {
                    try blk.ensureOpen(&ops, allocator, pc);
                    blk.record(GasConstants.GasFastestStep, 0, 1); // PUSH
                    if (next_op == 0x56) {
                        blk.record(GasConstants.GasMidStep, 1, 0); // JUMP
                        const ip = ops.items.len;
                        try ops.append(allocator, .{ .op = .push_jump, .aux = INVALID_TARGET, .imm = pc });
                        try pending_jumps.append(allocator, .{ .inst_ip = ip, .target_pc = imm });
                    } else {
                        blk.record(GasConstants.GasSlowStep, 2, 0); // JUMPI
                        const ip = ops.items.len;
                        try ops.append(allocator, .{ .op = .push_jumpi, .aux = INVALID_TARGET, .imm = pc });
                        try pending_jumps.append(allocator, .{ .inst_ip = ip, .target_pc = imm });
                    }
                    blk.close(&ops);
                    pc = next_pc + 1;
                    continue;
                }

                // PUSH1..8 + SWAP1 + SUB/LT/GT (universal loop decrement `x - imm`, `x < imm`, `x > imm`)
                if (next_op == 0x90 and next_pc + 1 < code.len) {
                    const op2 = code[next_pc + 1];
                    const fused_swap_op: ?Op = switch (op2) {
                        0x03 => .push_swap1_sub,
                        0x10 => .push_swap1_lt,
                        0x11 => .push_swap1_gt,
                        else => null,
                    };
                    if (fused_swap_op) |fop| {
                        try blk.ensureOpen(&ops, allocator, pc);
                        blk.record(GasConstants.GasFastestStep, 0, 1); // PUSH
                        blk.record(GasConstants.GasFastestStep, 2, 2); // SWAP1
                        blk.record(GasConstants.GasFastestStep, 2, 1); // SUB/LT/GT
                        try ops.append(allocator, .{ .op = fop, .aux = @intCast(pc), .imm = imm });
                        pc = next_pc + 2;
                        continue;
                    }
                }

                // PUSH1..8 + binary ALU op (ADD, SUB, MUL, LT, GT, EQ, AND, SHL, SHR)
                const fused_op: ?struct { op: Op, gas: u32 } = switch (next_op) {
                    0x01 => .{ .op = .push_add, .gas = GasConstants.GasFastestStep },
                    0x02 => .{ .op = .push_mul, .gas = GasConstants.GasFastStep },
                    0x03 => .{ .op = .push_sub, .gas = GasConstants.GasFastestStep },
                    0x10 => .{ .op = .push_lt, .gas = GasConstants.GasFastestStep },
                    0x11 => .{ .op = .push_gt, .gas = GasConstants.GasFastestStep },
                    0x14 => .{ .op = .push_eq, .gas = GasConstants.GasFastestStep },
                    0x16 => .{ .op = .push_and, .gas = GasConstants.GasFastestStep },
                    0x1b => if (flags.has_shift) .{ .op = .push_shl, .gas = GasConstants.GasFastestStep } else null,
                    0x1c => if (flags.has_shift) .{ .op = .push_shr, .gas = GasConstants.GasFastestStep } else null,
                    else => null,
                };
                if (fused_op) |f| {
                    try blk.ensureOpen(&ops, allocator, pc);
                    blk.record(GasConstants.GasFastestStep, 0, 1); // PUSH (preserves peak +1 overflow check!)
                    blk.record(f.gas, 2, 1); // ALU op
                    try ops.append(allocator, .{ .op = f.op, .aux = @intCast(pc), .imm = imm });
                    pc = next_pc + 1;
                    continue;
                }
            }

            try blk.ensureOpen(&ops, allocator, pc);
            blk.record(GasConstants.GasFastestStep, 0, 1);
            try ops.append(allocator, .{ .op = .push_u64, .aux = @intCast(pc), .imm = imm });
            pc = @min(next_pc, code.len);
            continue;
        }

        // PUSH9..PUSH32 (0x68..0x7f)
        if (b >= 0x68 and b <= 0x7f) {
            const n: usize = @as(usize, b - 0x60) + 1;
            const val = readPushU256(code, pc, n);
            const pool_idx = const_pool.items.len;
            try const_pool.append(allocator, val);
            try blk.ensureOpen(&ops, allocator, pc);
            blk.record(GasConstants.GasFastestStep, 0, 1);
            try ops.append(allocator, .{ .op = .push_const, .aux = @intCast(pc), .imm = pool_idx });
            pc = @min(pc + 1 + n, code.len);
            continue;
        }

        // SWAP1 + POP fusion (0x90 + 0x50)
        if (b == 0x90 and pc + 1 < code.len and code[pc + 1] == 0x50) {
            try blk.ensureOpen(&ops, allocator, pc);
            blk.record(GasConstants.GasFastestStep, 2, 2); // SWAP1
            blk.record(GasConstants.GasQuickStep, 1, 0); // POP
            try ops.append(allocator, .{ .op = .swap1_pop, .aux = @intCast(pc) });
            pc += 2;
            continue;
        }

        // Dynamic JUMP (0x56) / JUMPI (0x57): included at end of current basic block
        if (b == 0x56 or b == 0x57) {
            try blk.ensureOpen(&ops, allocator, pc);
            if (b == 0x56) {
                blk.record(GasConstants.GasMidStep, 1, 0);
                try ops.append(allocator, .{ .op = .jump, .aux = @intCast(pc) });
            } else {
                blk.record(GasConstants.GasSlowStep, 2, 0);
                try ops.append(allocator, .{ .op = .jumpi, .aux = @intCast(pc) });
            }
            blk.close(&ops);
            pc += 1;
            continue;
        }

        // Static pure stack/ALU/DUP/SWAP/POP/PC/PUSH0 opcodes
        if (classifyStaticOp(b, flags)) |info| {
            try blk.ensureOpen(&ops, allocator, pc);
            blk.record(info.gas, info.inputs, info.outputs);
            try ops.append(allocator, .{ .op = info.op, .aux = @intCast(pc) });
            pc += 1;
            continue;
        }

        // Dynamic/memory/calldata/keccak/state opcodes: close static block first so gas/stack are exact
        blk.close(&ops);
        const dyn_op: Op = switch (b) {
            0x20 => .keccak256,
            0x51 => .mload,
            0x52 => .mstore,
            0x53 => .mstore8,
            0x5e => if (flags.has_mcopy) .mcopy else .fallback,
            else => .fallback,
        };
        try ops.append(allocator, .{ .op = dyn_op, .aux = @intCast(pc) });
        pc += 1;
    }

    blk.close(&ops);
    // Sentinel STOP so dispatch loop never checks `ip >= ops.len`
    try ops.append(allocator, .{ .op = .stop, .aux = @intCast(code.len) });

    var compiled = CompiledCode{
        .ops = try ops.toOwnedSlice(allocator),
        .const_pool = try const_pool.toOwnedSlice(allocator),
        .jumpdests = try jumpdests.toOwnedSlice(allocator),
        .flags = flags.asU8(),
    };

    // Patch pre-validated static jump targets
    for (pending_jumps.items) |pj| {
        if (pj.target_pc <= std.math.maxInt(u32)) {
            if (compiled.resolveJumpDest(@intCast(pj.target_pc))) |target_ip| {
                compiled.ops[pj.inst_ip].aux = target_ip;
            }
        }
    }

    return compiled;
}

/// Fixed 32-slot direct-mapped compiled-bytecode cache owned by an `Evm`'s general allocator.
/// Eliminates bytecode re-analysis across repeated CALL/STATICCALL frames and reused-Evm txs.
///
/// Displaced entries are parked in `evicted` rather than freed immediately so any active
/// ancestor frame executing `executeCompiled` retains valid `ops`, `const_pool`, and
/// `jumpdests` slices across nested CALLs; `reclaimEvicted` frees them once no frames are live.
pub const CodeCache = struct {
    pub const SLOTS = 32;

    entries: [SLOTS]CompiledCode = [_]CompiledCode{.{ .ops = &.{}, .const_pool = &.{}, .jumpdests = &.{} }} ** SLOTS,
    occupied: [SLOTS]bool = [_]bool{false} ** SLOTS,
    evicted: std.ArrayListUnmanaged(CompiledCode) = .empty,

    pub fn getOrCompile(
        self: *CodeCache,
        allocator: std.mem.Allocator,
        code: []const u8,
        hardfork: Hardfork,
    ) !*const CompiledCode {
        const flags = HardforkFlags.fromHardfork(hardfork).asU8();
        const h = std.hash.Wyhash.hash(flags, code);
        const slot_idx: usize = @intCast(h & (SLOTS - 1));

        if (self.occupied[slot_idx]) {
            const entry = &self.entries[slot_idx];
            if (entry.hash == h and entry.flags == flags and std.mem.eql(u8, entry.code_copy, code)) {
                return entry;
            }
            // Reserve room in `evicted` before allocating the replacement so OOM never drops
            // either the old or the new CompiledCode.
            try self.evicted.ensureUnusedCapacity(allocator, 1);
        }

        var compiled = try compile(allocator, code, hardfork);
        errdefer compiled.deinit(allocator);
        compiled.code_copy = if (code.len > 0) try allocator.dupe(u8, code) else &.{};
        compiled.hash = h;

        if (self.occupied[slot_idx]) {
            self.evicted.appendAssumeCapacity(self.entries[slot_idx]);
        }
        self.entries[slot_idx] = compiled;
        self.occupied[slot_idx] = true;
        return &self.entries[slot_idx];
    }

    /// Free all entries displaced during the previous transaction (must only be called when
    /// no frames are executing).
    pub fn reclaimEvicted(self: *CodeCache, allocator: std.mem.Allocator) void {
        if (self.evicted.items.len == 0) return;
        for (self.evicted.items) |*entry| {
            entry.deinit(allocator);
        }
        if (self.evicted.capacity > 64) {
            self.evicted.clearAndFree(allocator);
        } else {
            self.evicted.clearRetainingCapacity();
        }
    }

    /// Free all occupied cache slots and any parked evicted entries.
    pub fn deinit(self: *CodeCache, allocator: std.mem.Allocator) void {
        for (0..SLOTS) |i| {
            if (self.occupied[i]) {
                self.entries[i].deinit(allocator);
                self.occupied[i] = false;
            }
        }
        for (self.evicted.items) |*entry| {
            entry.deinit(allocator);
        }
        self.evicted.deinit(allocator);
    }
};

test "compiled_code fuses basic block gas, peak stack, and static jump targets" {
    const alloc = std.testing.allocator;
    // JUMPDEST(1), PUSH1 1(3), ADD(3), PUSH1 0(3), JUMPI(10) => gas = 20, min_stack = 1, max_growth = 1
    const code = [_]u8{ 0x5b, 0x60, 0x01, 0x01, 0x60, 0x00, 0x57 };
    var cc = try compile(alloc, &code, .PRAGUE);
    defer cc.deinit(alloc);

    try std.testing.expectEqual(Op.begin_block, cc.ops[0].op);
    const meta: BlockMeta = @bitCast(cc.ops[0].imm);
    try std.testing.expectEqual(@as(u32, 20), meta.gas);
    try std.testing.expectEqual(@as(u16, 1), meta.min_stack);
    try std.testing.expectEqual(@as(u16, 1), meta.max_growth);
    try std.testing.expectEqual(Op.push_add, cc.ops[1].op);
    try std.testing.expectEqual(@as(u64, 1), cc.ops[1].imm);
    try std.testing.expectEqual(Op.push_jumpi, cc.ops[2].op);
    try std.testing.expectEqual(@as(u32, 0), cc.ops[2].aux); // points to JUMPDEST at ip=0
}

test "CodeCache parks evicted entries until reclaimEvicted and frees cleanly on deinit" {
    const alloc = std.testing.allocator;
    var cache = CodeCache{};
    defer cache.deinit(alloc);

    const flags = HardforkFlags.fromHardfork(.PRAGUE).asU8();
    const code_a = [_]u8{ 0x5b, 0x60, 0x01, 0x00 };
    const slot_a = std.hash.Wyhash.hash(flags, &code_a) & (CodeCache.SLOTS - 1);

    // Find a distinct bytecode `code_b` that maps to the exact same slot.
    var code_b_buf = [_]u8{ 0x60, 0x00, 0x5b, 0x00 };
    var found = false;
    for (0..256) |i| {
        code_b_buf[1] = @intCast(i);
        if ((std.hash.Wyhash.hash(flags, &code_b_buf) & (CodeCache.SLOTS - 1)) == slot_a) {
            found = true;
            break;
        }
    }
    try std.testing.expect(found);

    const entry_a = try cache.getOrCompile(alloc, &code_a, .PRAGUE);
    const a_ops = entry_a.ops;
    const a_jds = entry_a.jumpdests;
    try std.testing.expectEqual(@as(?u32, 0), resolveJumpDestSlice(a_jds, 0));

    // Evict slot_a with code_b: entry_a's slices must remain valid and unaliased.
    const entry_b = try cache.getOrCompile(alloc, &code_b_buf, .PRAGUE);
    try std.testing.expectEqual(@as(usize, 1), cache.evicted.items.len);
    try std.testing.expectEqual(@as(?u32, 0), resolveJumpDestSlice(a_jds, 0));
    try std.testing.expectEqual(@as(?u32, null), resolveJumpDestSlice(a_jds, 2));
    try std.testing.expectEqual(@as(?u32, null), entry_b.resolveJumpDest(0));
    try std.testing.expect(entry_b.resolveJumpDest(2) != null);
    try std.testing.expectEqual(Op.begin_block, a_ops[0].op);

    // Reclaim evicted entries after frame completion.
    cache.reclaimEvicted(alloc);
    try std.testing.expectEqual(@as(usize, 0), cache.evicted.items.len);
}
