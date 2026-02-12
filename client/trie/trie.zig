//! Trie implementation and adapters over Voltaire primitives.
//!
//! This module intentionally avoids custom trie/node types. It re-exports the
//! canonical Voltaire trie and provides minimal glue that is universally
//! useful for Ethereum MPT usage in the client.

const primitives = @import("primitives");

/// Merkle Patricia Trie implementation (Voltaire primitive).
pub const Trie = primitives.Trie;

/// Default hash module for secure trie operations (comptime-injected policy).
pub const DefaultHashMod = primitives.crypto.Hash;

/// Errors for secure trie strict helpers.
pub const SecureTrieError = error{KeyLooksHashed};

/// Hash a raw key for use in a secure trie (keccak256(key)).
///
/// - Uses Voltaire primitives hashing (`primitives.Hash.keccak256`).
/// - Returns `primitives.Hash.Hash` (32-byte Keccak-256 digest).
pub fn secureKey(raw_key: []const u8) primitives.Hash.Hash {
    return DefaultHashMod.keccak256(raw_key);
}

/// Same as `secureKey` but with comptime-injected hash policy.
pub fn secureKeyWith(comptime HashMod: type, raw_key: []const u8) primitives.Hash.Hash {
    return HashMod.keccak256(raw_key);
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

/// Insert into secure trie with injected hash policy.
pub fn putSecureWith(comptime HashMod: type, trie: *Trie, key: []const u8, value: []const u8) !void {
    const hashed = secureKeyWith(HashMod, key);
    return trie.put(&hashed, value);
}

/// Strict insert: rejects 32-byte inputs that likely are already hashed.
pub fn putSecureStrict(trie: *Trie, key: []const u8, value: []const u8) SecureTrieError!void {
    if (key.len == @sizeOf(primitives.Hash.Hash)) return SecureTrieError.KeyLooksHashed;
    return putSecure(trie, key, value);
}

/// Fetch a value from a secure trie using raw (unhashed) key.
pub fn getSecure(trie: *Trie, key: []const u8) !?[]const u8 {
    const hashed = secureKey(key);
    return trie.get(&hashed);
}

/// Fetch with injected hash policy.
pub fn getSecureWith(comptime HashMod: type, trie: *Trie, key: []const u8) !?[]const u8 {
    const hashed = secureKeyWith(HashMod, key);
    return trie.get(&hashed);
}

/// Strict fetch: rejects 32-byte inputs that likely are already hashed.
pub fn getSecureStrict(trie: *Trie, key: []const u8) SecureTrieError!?[]const u8 {
    if (key.len == @sizeOf(primitives.Hash.Hash)) return SecureTrieError.KeyLooksHashed;
    return getSecure(trie, key);
}

/// Delete a value from a secure trie using raw (unhashed) key.
pub fn deleteSecure(trie: *Trie, key: []const u8) !void {
    const hashed = secureKey(key);
    return trie.delete(&hashed);
}

/// Delete with injected hash policy.
pub fn deleteSecureWith(comptime HashMod: type, trie: *Trie, key: []const u8) !void {
    const hashed = secureKeyWith(HashMod, key);
    return trie.delete(&hashed);
}

/// Strict delete: rejects 32-byte inputs that likely are already hashed.
pub fn deleteSecureStrict(trie: *Trie, key: []const u8) SecureTrieError!void {
    if (key.len == @sizeOf(primitives.Hash.Hash)) return SecureTrieError.KeyLooksHashed;
    return deleteSecure(trie, key);
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

test "getSecure/deleteSecure - round trip and removal" {
    const std = @import("std");
    const testing = std.testing;

    var t = Trie.init(testing.allocator);
    defer t.deinit();

    const key = "bird";
    try putSecure(&t, key, "tweet");
    const got1 = try getSecure(&t, key);
    try testing.expect(got1 != null);
    try testing.expectEqualStrings("tweet", got1.?);
    try deleteSecure(&t, key);
    const got2 = try getSecure(&t, key);
    try testing.expect(got2 == null);
}

test "secure trie - empty key insertion and fetch" {
    const std = @import("std");
    const testing = std.testing;

    var t = Trie.init(testing.allocator);
    defer t.deinit();

    const empty: [0]u8 = .{};
    try putSecure(&t, &empty, "v");
    const got = try getSecure(&t, &empty);
    try testing.expect(got != null);
    try testing.expectEqualStrings("v", got.?);
}

test "secure trie - missing key returns null" {
    const std = @import("std");
    const testing = std.testing;

    var t = Trie.init(testing.allocator);
    defer t.deinit();

    const got = try getSecure(&t, "does-not-exist");
    try testing.expect(got == null);
}

test "secure trie strict - 32-byte inputs rejected" {
    const std = @import("std");
    const testing = std.testing;

    var t = Trie.init(testing.allocator);
    defer t.deinit();

    var raw32: [32]u8 = [_]u8{0xaa} ** 32;
    try testing.expectError(SecureTrieError.KeyLooksHashed, putSecureStrict(&t, &raw32, "x"));
    try testing.expectError(SecureTrieError.KeyLooksHashed, getSecureStrict(&t, &raw32));
    try testing.expectError(SecureTrieError.KeyLooksHashed, deleteSecureStrict(&t, &raw32));
}
