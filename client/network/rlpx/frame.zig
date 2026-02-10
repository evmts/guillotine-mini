const std = @import("std");

/// Size of the RLPx MAC (16 bytes).
pub const MacSize: usize = 16;
/// Size of the encrypted RLPx header (16 bytes).
pub const HeaderSize: usize = 16;
/// AES-CTR block size used for header/data padding (16 bytes).
pub const BlockSize: usize = 16;
/// Maximum frame-size representable by the 24-bit RLPx header.
pub const ProtocolMaxFrameSize: usize = (@as(usize, 1) << 24) - 1;
/// Default fragmentation target for outbound frames; not a hard inbound limit.
pub const DefaultMaxFrameSize: usize = BlockSize * 64;

/// Returns the zero-fill padding required to align to the AES block size.
pub inline fn calculate_padding(size: usize) usize {
    const remainder = size % BlockSize;
    return if (remainder == 0) 0 else BlockSize - remainder;
}

/// Encodes a frame size as a 24-bit big-endian integer for the RLPx header.
/// Errors when `size` exceeds the protocol's 24-bit representable limit.
pub inline fn encodeFrameSize24(size: usize) ![3]u8 {
    if (size > ProtocolMaxFrameSize) return error.InvalidFrameSize;
    return .{
        @as(u8, @intCast((size >> 16) & 0xFF)),
        @as(u8, @intCast((size >> 8) & 0xFF)),
        @as(u8, @intCast(size & 0xFF)),
    };
}

test "calculate padding returns zero for aligned sizes" {
    try std.testing.expectEqual(@as(usize, 0), calculate_padding(0));
    try std.testing.expectEqual(@as(usize, 0), calculate_padding(BlockSize));
    try std.testing.expectEqual(@as(usize, 0), calculate_padding(BlockSize * 4));
}

test "calculate padding returns remainder to block size" {
    try std.testing.expectEqual(@as(usize, 15), calculate_padding(1));
    try std.testing.expectEqual(@as(usize, 1), calculate_padding(BlockSize - 1));
    try std.testing.expectEqual(@as(usize, 8), calculate_padding(BlockSize * 2 + 8));
}

test "frame constants mirror Nethermind defaults and protocol limits" {
    try std.testing.expectEqual(@as(usize, 16), MacSize);
    try std.testing.expectEqual(@as(usize, 16), HeaderSize);
    try std.testing.expectEqual(@as(usize, 16), BlockSize);
    try std.testing.expectEqual(@as(usize, 1024), DefaultMaxFrameSize);
    try std.testing.expectEqual(@as(usize, 0xFFFFFF), ProtocolMaxFrameSize);
}

test "encodeFrameSize24: encodes boundaries" {
    const zero = try encodeFrameSize24(0);
    try std.testing.expectEqualSlices(u8, &[_]u8{ 0x00, 0x00, 0x00 }, &zero);

    const one = try encodeFrameSize24(1);
    try std.testing.expectEqualSlices(u8, &[_]u8{ 0x00, 0x00, 0x01 }, &one);

    const max = try encodeFrameSize24(ProtocolMaxFrameSize);
    try std.testing.expectEqualSlices(u8, &[_]u8{ 0xFF, 0xFF, 0xFF }, &max);
}

test "encodeFrameSize24: rejects values > 24-bit" {
    try std.testing.expectError(error.InvalidFrameSize, encodeFrameSize24(ProtocolMaxFrameSize + 1));
}
