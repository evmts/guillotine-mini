const std = @import("std");

/// Size of the RLPx MAC (16 bytes).
pub const MacSize: u16 = 16;
/// Size of the encrypted RLPx header (16 bytes).
pub const HeaderSize: u16 = 16;
/// AES-CTR block size used for header/data padding (16 bytes).
pub const BlockSize: u16 = 16;
/// Maximum frame-size representable by the 24-bit RLPx header.
pub const ProtocolMaxFrameSize: u24 = 0xFF_FF_FF;
/// Default fragmentation target for outbound frames; not a hard inbound limit.
pub const DefaultMaxFrameSize: u16 = BlockSize * 64;

/// Returns the zero-fill padding required to align to the AES block size.
pub inline fn calculate_padding(size: usize) usize {
    const remainder = size % BlockSize;
    return if (remainder == 0) 0 else BlockSize - remainder;
}

/// Encodes a frame size as a 24-bit big-endian integer for the RLPx header.
/// Errors when `size` exceeds the protocol's 24-bit representable limit.
pub inline fn encode_frame_size_24(size: usize) FrameError![3]u8 {
    if (size > ProtocolMaxFrameSize) return FrameError.InvalidFrameSize;
    var out: [3]u8 = undefined;
    // Use std.mem primitives for well-defined u24 big-endian encoding.
    std.mem.writeInt(u24, &out, @as(u24, @intCast(size)), .big);
    return out;
}

/// Decodes a 24-bit big-endian frame size from the RLPx header bytes.
/// The input must be exactly three bytes as per RLPx framing.
pub inline fn decode_frame_size_24(bytes: [3]u8) usize {
    const v: u24 = std.mem.readInt(u24, &bytes, .big);
    return @as(usize, @intCast(v));
}

// NOTE(rlpx): Integration test plan — Add a header/decoder-level test ensuring
// nodes reject any incoming frame with size > u24::max prior to decryption or
// allocation. This hardens invariants and prevents resource waste. (Future work.)

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
    try std.testing.expectEqual(@as(u16, 16), MacSize);
    try std.testing.expectEqual(@as(u16, 16), HeaderSize);
    try std.testing.expectEqual(@as(u16, 16), BlockSize);
    try std.testing.expectEqual(@as(u16, 1024), DefaultMaxFrameSize);
    try std.testing.expectEqual(@as(u24, 0xFF_FF_FF), ProtocolMaxFrameSize);
}

test "encode_frame_size_24: encodes boundaries" {
    const zero = try encode_frame_size_24(0);
    try std.testing.expectEqualSlices(u8, &[_]u8{ 0x00, 0x00, 0x00 }, &zero);

    const one = try encode_frame_size_24(1);
    try std.testing.expectEqualSlices(u8, &[_]u8{ 0x00, 0x00, 0x01 }, &one);

    const max = try encode_frame_size_24(ProtocolMaxFrameSize);
    try std.testing.expectEqualSlices(u8, &[_]u8{ 0xFF, 0xFF, 0xFF }, &max);
}

test "encode_frame_size_24: rejects values > 24-bit" {
    const too_big: usize = @as(usize, @intCast(ProtocolMaxFrameSize)) + 1;
    try std.testing.expectError(FrameError.InvalidFrameSize, encode_frame_size_24(too_big));
}

test "decode_frame_size_24: decodes boundaries" {
    try std.testing.expectEqual(@as(usize, 0), decode_frame_size_24(.{ 0x00, 0x00, 0x00 }));
    try std.testing.expectEqual(@as(usize, 1), decode_frame_size_24(.{ 0x00, 0x00, 0x01 }));
    try std.testing.expectEqual(ProtocolMaxFrameSize, decode_frame_size_24(.{ 0xFF, 0xFF, 0xFF }));
}

test "decode_frame_size_24: roundtrips representative values" {
    const values = [_]usize{ 0, 1, 15, 16, 255, 256, 1024, 4096, 65535, 70000, 1_000_000, ProtocolMaxFrameSize };
    inline for (values) |v| {
        const enc = try encode_frame_size_24(v);
        const dec = decode_frame_size_24(enc);
        try std.testing.expectEqual(v, dec);
    }
}
/// Public, stable error set for frame helpers to avoid error-set widening.
pub const FrameError = error{
    InvalidFrameSize,
};
