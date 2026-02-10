const std = @import("std");

/// RLPx frame constants and padding helper.
pub const MacSize: usize = 16;
pub const HeaderSize: usize = 16;
pub const BlockSize: usize = 16;
pub const DefaultMaxFrameSize: usize = BlockSize * 64;

/// Returns the zero-fill padding required to align to the AES block size.
pub fn calculatePadding(size: usize) usize {
    const remainder = size % BlockSize;
    return if (remainder == 0) 0 else BlockSize - remainder;
}

test "calculate padding returns zero for aligned sizes" {
    try std.testing.expectEqual(@as(usize, 0), calculatePadding(0));
    try std.testing.expectEqual(@as(usize, 0), calculatePadding(BlockSize));
    try std.testing.expectEqual(@as(usize, 0), calculatePadding(BlockSize * 4));
}

test "calculate padding returns remainder to block size" {
    try std.testing.expectEqual(@as(usize, 15), calculatePadding(1));
    try std.testing.expectEqual(@as(usize, 1), calculatePadding(BlockSize - 1));
    try std.testing.expectEqual(@as(usize, 8), calculatePadding(BlockSize * 2 + 8));
}

test "frame constants mirror Nethermind defaults" {
    try std.testing.expectEqual(@as(usize, 16), MacSize);
    try std.testing.expectEqual(@as(usize, 16), HeaderSize);
    try std.testing.expectEqual(@as(usize, 16), BlockSize);
    try std.testing.expectEqual(@as(usize, 1024), DefaultMaxFrameSize);
}
