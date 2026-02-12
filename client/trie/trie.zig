//! Trie implementation and adapters over Voltaire primitives.
//!
//! This module intentionally avoids custom trie/node types. It re-exports the
//! canonical Voltaire trie and provides minimal glue that is universally
//! useful for Ethereum MPT usage in the client.

const primitives = @import("primitives");
const Crypto = @import("crypto");
const Hash32 = @import("node.zig").Hash32;

/// Merkle Patricia Trie implementation (Voltaire primitive).
pub const Trie = primitives.Trie;

/// Hash a raw key for use in a secure trie (keccak256(key)).
///
/// - Uses Voltaire crypto Keccak-256 implementation.
/// - Returns Voltaire `Hash32` (primitives.Hash.Hash) — no custom types.
pub inline fn secureKey(raw_key: []const u8) Hash32 {
    return Crypto.Hash.keccak256(raw_key);
}

test {
    @import("std").testing.refAllDecls(@This());
}

test "secureKey - keccak256(empty) matches spec digest" {
    const std = @import("std");
    const testing = std.testing;
    const Hex = primitives.Hex;

    const got = secureKey(&[_]u8{});
    const expected = try Hex.hexToBytesFixed(32, "0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470");
    try testing.expectEqualSlices(u8, &expected, &got);
}
