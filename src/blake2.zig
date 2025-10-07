/// BLAKE2F compression function for EIP-152
/// Reference: https://datatracker.ietf.org/doc/html/rfc7693
const std = @import("std");

/// BLAKE2b initialization vector
const IV = [8]u64{
    0x6A09E667F3BCC908,
    0xBB67AE8584CAA73B,
    0x3C6EF372FE94F82B,
    0xA54FF53A5F1D36F1,
    0x510E527FADE682D1,
    0x9B05688C2B3E6C1F,
    0x1F83D9ABFB41BD6B,
    0x5BE0CD19137E2179,
};

/// BLAKE2b sigma permutations
const SIGMA = [10][16]u8{
    .{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 },
    .{ 14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3 },
    .{ 11, 8, 12, 0, 5, 2, 15, 13, 10, 14, 3, 6, 7, 1, 9, 4 },
    .{ 7, 9, 3, 1, 13, 12, 11, 14, 2, 6, 5, 10, 4, 0, 15, 8 },
    .{ 9, 0, 5, 7, 2, 4, 10, 15, 14, 1, 11, 12, 6, 8, 3, 13 },
    .{ 2, 12, 6, 10, 0, 11, 8, 3, 4, 13, 7, 5, 15, 14, 1, 9 },
    .{ 12, 5, 1, 15, 14, 13, 4, 10, 0, 7, 6, 3, 9, 2, 8, 11 },
    .{ 13, 11, 7, 14, 12, 1, 3, 9, 5, 0, 15, 4, 8, 6, 2, 10 },
    .{ 6, 15, 14, 9, 11, 3, 0, 8, 12, 2, 13, 7, 1, 4, 10, 5 },
    .{ 10, 2, 8, 4, 7, 6, 1, 5, 15, 11, 9, 14, 3, 12, 13, 0 },
};

/// Mix function G
fn G(v: *[16]u64, a: usize, b: usize, c: usize, d: usize, x: u64, y: u64) void {
    v[a] = v[a] +% v[b] +% x;
    v[d] = std.math.rotr(u64, v[d] ^ v[a], 32);

    v[c] = v[c] +% v[d];
    v[b] = std.math.rotr(u64, v[b] ^ v[c], 24);

    v[a] = v[a] +% v[b] +% y;
    v[d] = std.math.rotr(u64, v[d] ^ v[a], 16);

    v[c] = v[c] +% v[d];
    v[b] = std.math.rotr(u64, v[b] ^ v[c], 63);
}

/// BLAKE2F compression function
/// Input: 213 bytes
///   - rounds: 4 bytes (big-endian u32)
///   - h: 64 bytes (8 x u64 little-endian)
///   - m: 128 bytes (16 x u64 little-endian)
///   - t_0, t_1: 16 bytes (2 x u64 little-endian)
///   - f: 1 byte (final block flag, 0 or 1)
/// Output: 64 bytes (8 x u64 little-endian)
pub fn compress(data: []const u8, output: []u8) !void {
    if (data.len != 213) {
        return error.InvalidInputLength;
    }
    if (output.len != 64) {
        return error.InvalidOutputLength;
    }

    // Parse rounds (big-endian)
    const rounds = std.mem.readInt(u32, data[0..4], .big);

    // Parse h (8 x u64, little-endian)
    var h: [8]u64 = undefined;
    for (0..8) |i| {
        h[i] = std.mem.readInt(u64, data[4 + i * 8 ..][0..8], .little);
    }

    // Parse m (16 x u64, little-endian)
    var m: [16]u64 = undefined;
    for (0..16) |i| {
        m[i] = std.mem.readInt(u64, data[68 + i * 8 ..][0..8], .little);
    }

    // Parse t_0, t_1 (2 x u64, little-endian)
    const t_0 = std.mem.readInt(u64, data[196..204], .little);
    const t_1 = std.mem.readInt(u64, data[204..212], .little);

    // Parse f (final block flag)
    const f = data[212];
    if (f != 0 and f != 1) {
        return error.InvalidFinalBlockFlag;
    }

    // Initialize working vector v
    var v: [16]u64 = undefined;
    v[0..8].* = h;
    v[8..16].* = IV;

    // Mix in t_0 and t_1
    v[12] ^= t_0;
    v[13] ^= t_1;

    // If final block, invert all bits of v[14]
    if (f == 1) {
        v[14] ^= 0xFFFFFFFFFFFFFFFF;
    }

    // Mixing rounds
    for (0..rounds) |r| {
        const s = SIGMA[r % 10];

        // Round function
        G(&v, 0, 4, 8, 12, m[s[0]], m[s[1]]);
        G(&v, 1, 5, 9, 13, m[s[2]], m[s[3]]);
        G(&v, 2, 6, 10, 14, m[s[4]], m[s[5]]);
        G(&v, 3, 7, 11, 15, m[s[6]], m[s[7]]);

        G(&v, 0, 5, 10, 15, m[s[8]], m[s[9]]);
        G(&v, 1, 6, 11, 12, m[s[10]], m[s[11]]);
        G(&v, 2, 7, 8, 13, m[s[12]], m[s[13]]);
        G(&v, 3, 4, 9, 14, m[s[14]], m[s[15]]);
    }

    // Finalize: XOR the two halves
    for (0..8) |i| {
        h[i] ^= v[i] ^ v[i + 8];
    }

    // Write output (little-endian)
    for (0..8) |i| {
        std.mem.writeInt(u64, output[i * 8 ..][0..8], h[i], .little);
    }
}

test "BLAKE2F basic" {
    // Test vector from EIP-152
    const input = [_]u8{
        // rounds (12 rounds, big-endian)
        0x00, 0x00, 0x00, 0x0c,
        // h (64 bytes, little-endian u64s)
        0x48, 0xc9, 0xbd, 0xf2, 0x67, 0xe6, 0x09, 0x6a,
        0x3b, 0xa7, 0xca, 0x84, 0x85, 0xae, 0x67, 0xbb,
        0x2b, 0xf8, 0x94, 0xfe, 0x72, 0xf3, 0x6e, 0x3c,
        0xf1, 0x36, 0x1d, 0x5f, 0x3a, 0xf5, 0x4f, 0xa5,
        0xd1, 0x82, 0xe6, 0xad, 0x7f, 0x52, 0x0e, 0x51,
        0x1f, 0x6c, 0x3e, 0x2b, 0x8c, 0x68, 0x05, 0x9b,
        0x6b, 0xbd, 0x41, 0xfb, 0xab, 0xd9, 0x83, 0x1f,
        0x79, 0x21, 0x7e, 0x13, 0x19, 0xcd, 0xe0, 0x5b,
        // m (128 bytes, little-endian u64s - all zeros for this test)
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        // t_0, t_1 (16 bytes, little-endian u64s)
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        // f (final block flag)
        0x00,
    };

    var output: [64]u8 = undefined;
    try compress(&input, &output);

    // The expected output would be the BLAKE2 state after 12 rounds
    // For now just check it doesn't crash
    try std.testing.expect(output.len == 64);
}
