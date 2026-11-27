/// Bytecode utilities and validation
/// This module provides abstractions for working with EVM bytecode,
/// including jump destination analysis and bytecode traversal.
const std = @import("std");

/// Represents analyzed bytecode with pre-validated jump destinations stored in a packed bitset.
/// Contracts up to 512 bytes use inline storage with zero heap allocations.
pub const Bytecode = struct {
    const INLINE_WORDS = 2; // 2 * 64 = 128 bytes inline (shrinks Frame by 48 bytes)

    /// Raw bytecode bytes
    code: []const u8,

    /// Allocator used when `heap_bits != null`
    allocator: std.mem.Allocator,

    /// Inline bitset for contracts <= 128 bytes (zero heap allocations)
    inline_bits: [INLINE_WORDS]u64 = .{0} ** INLINE_WORDS,

    /// Heap-allocated bitset for contracts > 128 bytes (1 bit per code byte)
    heap_bits: ?[]u64 = null,

    /// Whether the JUMPDEST bitset has been populated yet.
    analyzed: bool = false,

    /// Initialize bytecode lazily without scanning JUMPDESTs until needed.
    /// Used by frames whose compiled code path uses pre-resolved jump targets.
    pub fn initLazy(allocator: std.mem.Allocator, code: []const u8) Bytecode {
        return .{
            .code = code,
            .allocator = allocator,
            .analyzed = false,
        };
    }

    /// Populate the JUMPDEST bitset on demand if not already analyzed.
    pub fn ensureAnalyzed(self: *Bytecode) !void {
        if (self.analyzed) return;
        const word_count = (self.code.len + 63) >> 6;
        if (word_count > INLINE_WORDS) {
            const bits = try self.allocator.alloc(u64, word_count);
            @memset(bits, 0);
            self.heap_bits = bits;
            analyzeJumpDestsBitset(self.code, bits);
        } else if (word_count > 0) {
            analyzeJumpDestsBitset(self.code, self.inline_bits[0..word_count]);
        }
        self.analyzed = true;
    }

    /// Initialize bytecode with jump destination analysis
    pub fn init(allocator: std.mem.Allocator, code: []const u8) !Bytecode {
        var self = initLazy(allocator, code);
        try self.ensureAnalyzed();
        return self;
    }

    /// Clean up resources
    pub fn deinit(self: *Bytecode) void {
        if (self.heap_bits) |bits| {
            self.allocator.free(bits);
            self.heap_bits = null;
        }
    }

    /// Check if a position is a valid JUMPDEST in O(1) with zero hashing
    pub inline fn isValidJumpDest(self: *const Bytecode, pc: u32) bool {
        if (pc >= self.code.len) return false;
        const words: []const u64 = self.heap_bits orelse &self.inline_bits;
        const word_idx: usize = @intCast(pc >> 6);
        const bit_idx: u6 = @truncate(pc);
        return ((words[word_idx] >> bit_idx) & 1) != 0;
    }

    /// Get bytecode length
    pub inline fn len(self: *const Bytecode) usize {
        return self.code.len;
    }

    /// Get opcode at position
    pub inline fn getOpcode(self: *const Bytecode, pc: u32) ?u8 {
        if (pc >= self.code.len) {
            return null;
        }
        return self.code[pc];
    }

    /// Read immediate data for PUSH operations
    /// Returns the N bytes following the current PC (for PUSHN instructions)
    pub inline fn readImmediate(self: *const Bytecode, pc: u32, size: u8) ?u256 {
        const pc_usize: usize = @intCast(pc);

        // A PUSHn whose immediate runs past the end of code is valid: the missing trailing
        // bytes are treated as zero (available bytes are the high-order bytes). Only the
        // opcode byte itself being out of bounds is degenerate.
        if (pc_usize >= self.code.len) {
            return null;
        }

        const start: usize = pc_usize + 1;
        const n: usize = @intCast(size);
        if (start + n <= self.code.len) {
            // Fast path: full immediate lies within bytecode bounds
            return switch (size) {
                0 => 0,
                1 => self.code[start],
                2 => std.mem.readInt(u16, self.code[start..][0..2], .big),
                3 => std.mem.readInt(u24, self.code[start..][0..3], .big),
                4 => std.mem.readInt(u32, self.code[start..][0..4], .big),
                8 => std.mem.readInt(u64, self.code[start..][0..8], .big),
                16 => std.mem.readInt(u128, self.code[start..][0..16], .big),
                20 => std.mem.readInt(u160, self.code[start..][0..20], .big),
                32 => std.mem.readInt(u256, self.code[start..][0..32], .big),
                else => blk: {
                    var buf: [32]u8 = [_]u8{0} ** 32;
                    @memcpy(buf[32 - n .. 32], self.code[start .. start + n]);
                    break :blk std.mem.readInt(u256, &buf, .big);
                },
            };
        }

        // Truncated PUSH at end of bytecode: right-pad missing trailing bytes with zeros
        var buf: [32]u8 = [_]u8{0} ** 32;
        const avail = self.code.len - start;
        if (avail > 0) {
            const copy_len = @min(avail, n);
            @memcpy(buf[32 - n .. 32 - n + copy_len], self.code[start .. start + copy_len]);
        }
        return std.mem.readInt(u256, &buf, .big);
    }
};

/// Analyze bytecode into a packed bitset of valid JUMPDEST positions.
///
/// EIP-8024 (`DUPN` 0xe6, `SWAPN` 0xe7, `EXCHANGE` 0xe8) deliberately forbids
/// `0x5b..0x7f` as valid immediates so JUMPDEST scanning stays unchanged:
/// a `0x5b` byte after `0xe6`/`0xe7`/`0xe8` remains a valid JUMPDEST, and a
/// `0x60..0x7f` byte after them still masks the following PUSH data bytes.
fn analyzeJumpDestsBitset(code: []const u8, bits: []u64) void {
    var pc: usize = 0;
    const code_len = code.len;

    while (pc < code_len) {
        const opcode = code[pc];
        if (opcode == 0x5b) {
            bits[pc >> 6] |= (@as(u64, 1) << @as(u6, @truncate(pc)));
            pc += 1;
        } else if (opcode >= 0x60 and opcode <= 0x7f) {
            pc += 1 + @as(usize, opcode - 0x5f);
        } else {
            pc += 1;
        }
    }
}

test "analyzeJumpDests: simple JUMPDEST" {
    const code = [_]u8{ 0x5b, 0x00, 0x5b }; // JUMPDEST, STOP, JUMPDEST
    var bc = try Bytecode.init(std.testing.allocator, &code);
    defer bc.deinit();

    try std.testing.expect(bc.isValidJumpDest(0));
    try std.testing.expect(bc.isValidJumpDest(2));
    try std.testing.expect(!bc.isValidJumpDest(1));
}

test "analyzeJumpDests: PUSH data containing JUMPDEST opcode" {
    const code = [_]u8{
        0x60, 0x5b, // PUSH1 0x5b (pushes JUMPDEST opcode as data)
        0x5b, // JUMPDEST (actual valid jump destination)
    };
    var bc = try Bytecode.init(std.testing.allocator, &code);
    defer bc.deinit();

    // Only position 2 should be valid (the actual JUMPDEST)
    // Position 1 (the 0x5b in PUSH data) should NOT be valid
    try std.testing.expect(!bc.isValidJumpDest(0));
    try std.testing.expect(!bc.isValidJumpDest(1));
    try std.testing.expect(bc.isValidJumpDest(2));
}

test "analyzeJumpDests: PUSH32 with embedded JUMPDEST bytes" {
    var code: [34]u8 = undefined;
    code[0] = 0x7f; // PUSH32
    // Fill with 32 bytes of data, including some 0x5b (JUMPDEST) bytes
    for (1..33) |i| {
        code[i] = if (i % 2 == 0) 0x5b else 0x00;
    }
    code[33] = 0x5b; // Actual JUMPDEST after PUSH32

    var bc = try Bytecode.init(std.testing.allocator, &code);
    defer bc.deinit();

    // Only position 33 should be valid
    try std.testing.expect(!bc.isValidJumpDest(0));
    for (1..33) |i| {
        try std.testing.expect(!bc.isValidJumpDest(@intCast(i)));
    }
    try std.testing.expect(bc.isValidJumpDest(33));
}

test "Bytecode: initialization and queries" {
    const code = [_]u8{ 0x60, 0x01, 0x5b, 0x00 }; // PUSH1 1, JUMPDEST, STOP

    var bytecode = try Bytecode.init(std.testing.allocator, &code);
    defer bytecode.deinit();

    try std.testing.expectEqual(@as(usize, 4), bytecode.len());
    try std.testing.expect(!bytecode.isValidJumpDest(0));
    try std.testing.expect(!bytecode.isValidJumpDest(1));
    try std.testing.expect(bytecode.isValidJumpDest(2));
    try std.testing.expect(!bytecode.isValidJumpDest(3));
}

test "Bytecode: readImmediate" {
    const code = [_]u8{ 0x60, 0xff, 0x61, 0x12, 0x34 }; // PUSH1 0xff, PUSH2 0x1234

    var bytecode = try Bytecode.init(std.testing.allocator, &code);
    defer bytecode.deinit();

    // Read PUSH1 immediate (1 byte)
    if (bytecode.readImmediate(0, 1)) |value| {
        try std.testing.expectEqual(@as(u256, 0xff), value);
    } else {
        try std.testing.expect(false); // Should not be null
    }

    // Read PUSH2 immediate (2 bytes)
    if (bytecode.readImmediate(2, 2)) |value| {
        try std.testing.expectEqual(@as(u256, 0x1234), value);
    } else {
        try std.testing.expect(false); // Should not be null
    }

    // Missing PUSH immediate bytes are zero-padded; a missing opcode is null.
    try std.testing.expectEqual(@as(?u256, 0x3400), bytecode.readImmediate(3, 2));
    try std.testing.expectEqual(@as(?u256, 0), bytecode.readImmediate(4, 32));
    try std.testing.expect(bytecode.readImmediate(5, 2) == null);
}

test "analyzeJumpDests: EIP-8024 does not mask JUMPDEST or PUSH immediates" {
    // 0xe6 0x5b: 0x5b is an invalid DUPN immediate and remains a valid JUMPDEST.
    const dupn_jd = [_]u8{ 0xe6, 0x5b, 0x00 };
    var bc1 = try Bytecode.init(std.testing.allocator, &dupn_jd);
    defer bc1.deinit();
    try std.testing.expect(bc1.isValidJumpDest(1));

    // 0xe6 0x60 0x5b: 0x60 (PUSH1) after DUPN masks the trailing 0x5b.
    const dupn_push_jd = [_]u8{ 0xe6, 0x60, 0x5b, 0x5b };
    var bc2 = try Bytecode.init(std.testing.allocator, &dupn_push_jd);
    defer bc2.deinit();
    try std.testing.expect(!bc2.isValidJumpDest(2));
    try std.testing.expect(bc2.isValidJumpDest(3));
}
