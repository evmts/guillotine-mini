//! Trie implementation and adapters over Voltaire primitives.
//!
//! This module intentionally avoids custom trie/node types. It re-exports the
//! canonical Voltaire trie and provides minimal glue that is universally
//! useful for Ethereum MPT usage in the client.

const primitives = @import("primitives");

/// Merkle Patricia Trie implementation (Voltaire primitive).
pub const Trie = primitives.Trie;

/// Hash a raw key for use in a secure trie (keccak256(key)).
///
/// - Uses Voltaire primitives hashing (`primitives.Hash.keccak256`).
/// - Returns `primitives.Hash.Hash` (32-byte Keccak-256 digest).
pub fn secureKey(raw_key: []const u8) primitives.Hash.Hash {
    return primitives.Hash.keccak256(raw_key);
}

/// Insert a value into a secure trie using a raw (unhashed) key.
///
/// - Matches execution-specs `secured=True` semantics: keys are first
///   hashed with Keccak-256 (preimage resistant) before insertion.
/// - Uses Voltaire primitives exclusively; no custom hash/key types.
/// - Delegates to `Trie.put()` with the 32-byte hashed key.
pub fn putSecure(trie: *Trie, key: []const u8, value: []const u8) !void {
    const hashed = secureKey(key);
    return trie.put(&hashed, value);
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

test "putSecure - basic put/get via hashed lookup" {
    const std = @import("std");
    const testing = std.testing;

    var t = Trie.init(testing.allocator);
    defer t.deinit();

    const key = "dog";
    const val = "puppy";
    try putSecure(&t, key, val);

    const hashed = secureKey(key);
    const got = try t.get(&hashed);
    try testing.expect(got != null);
    try testing.expectEqualStrings(val, got.?);
}

test "putSecure - overwrite updates stored value" {
    const std = @import("std");
    const testing = std.testing;

    var t = Trie.init(testing.allocator);
    defer t.deinit();

    const key = "cat";
    try putSecure(&t, key, "meow");
    try putSecure(&t, key, "purr");

    const hashed = secureKey(key);
    const got = try t.get(&hashed);
    try testing.expect(got != null);
    try testing.expectEqualStrings("purr", got.?);
}
