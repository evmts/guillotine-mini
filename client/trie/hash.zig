//! MPT Root Hash Computation
//!
//! Implements the `patricialize()` algorithm from the Ethereum execution-specs
//! (`execution-specs/src/ethereum/forks/frontier/trie.py`). This computes a
//! Merkle Patricia Trie root hash from a flat key-value mapping, exactly
//! matching the spec behavior including node inlining (nodes whose RLP is
//! < 32 bytes are returned as raw RLP structures, not hashed).
//!
//! Uses Voltaire primitives for RLP encoding and keccak256 hashing.

const std = @import("std");
const Allocator = std.mem.Allocator;

/// RLP encoding from Voltaire primitives
const Rlp = @import("primitives").Rlp;
/// Keccak256 hash function from Voltaire crypto
const Hash = @import("crypto").Hash;

/// EMPTY_TRIE_ROOT = keccak256(RLP(b"")) = keccak256(0x80)
/// = 0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421
/// Used when the trie has no entries.
pub const EMPTY_TRIE_ROOT: [32]u8 = .{
    0x56, 0xe8, 0x1f, 0x17, 0x1b, 0xcc, 0x55, 0xa6,
    0xff, 0x83, 0x45, 0xe6, 0x92, 0xc0, 0xf8, 0x6e,
    0x5b, 0x48, 0xe0, 0x1b, 0x99, 0x6c, 0xad, 0xc0,
    0x01, 0x62, 0x2f, 0xb5, 0xe3, 0x63, 0xb4, 0x21,
};

/// Represents the result of `encode_internal_node()` from the spec.
///
/// In the Python spec, `encode_internal_node` returns either:
/// - `bytes` (a keccak256 hash, 32 bytes) for large nodes
/// - The "unencoded" form (a tuple/list) for small nodes (< 32 bytes RLP)
/// - `b""` for empty/None nodes
///
/// We represent this as:
/// - `.hash`: 32-byte keccak hash (for large nodes)
/// - `.raw`: the complete RLP encoding of the unencoded form (small nodes)
/// - `.empty`: represents `b""` (None/empty node)
pub const EncodedNode = union(enum) {
    /// Complete RLP encoding of an inline node (< 32 bytes)
    raw: []const u8,
    /// Keccak256 hash of the RLP encoding (>= 32 bytes)
    hash: [32]u8,
    /// Empty node (encodes to b"")
    empty: void,
};

/// An item in an RLP list with explicit encoding tag.
/// This allows us to distinguish between:
/// - byte strings that should be RLP-encoded as strings
/// - already-encoded substructures (inline nodes) to embed verbatim
const RlpItem = union(enum) {
    /// A byte string to be RLP-encoded as a string item
    string: []const u8,
    /// An already-RLP-encoded substructure to embed verbatim
    verbatim: []const u8,
};

/// Compute the MPT root hash of a set of key-value pairs.
///
/// This is the top-level entry point matching the Python spec's `root()`.
/// Keys should already be in their final form (i.e., keccak256'd for secure
/// tries). Values should already be RLP-encoded where needed.
///
/// Algorithm:
/// 1. Convert each key to nibble-list form
/// 2. Call `patricialize()` to build the tree recursively
/// 3. RLP-encode the root node; if < 32 bytes, hash it; otherwise use as-is
pub fn trieRoot(
    allocator: Allocator,
    keys: []const []const u8,
    values: []const []const u8,
) ![32]u8 {
    std.debug.assert(keys.len == values.len);

    if (keys.len == 0) {
        return EMPTY_TRIE_ROOT;
    }

    // Convert keys to nibble form
    var nibble_keys = try allocator.alloc([]u8, keys.len);
    defer {
        for (nibble_keys) |nk| allocator.free(nk);
        allocator.free(nibble_keys);
    }

    for (keys, 0..) |key, i| {
        nibble_keys[i] = try keyToNibbles(allocator, key);
    }

    // Build the trie and get the root node encoding
    const root_node = try patricialize(allocator, nibble_keys, values, 0);
    defer freeEncodedNode(allocator, root_node);

    // Python spec's root():
    //   root_node = encode_internal_node(patricialize(prepared, 0))
    //   if len(rlp.encode(root_node)) < 32:
    //       return keccak256(rlp.encode(root_node))
    //   else:
    //       return Root(root_node)  # already a 32-byte hash
    switch (root_node) {
        .empty => return EMPTY_TRIE_ROOT,
        .hash => |h| return h,
        .raw => |raw| {
            // Small root: RLP encoding < 32 bytes, but we still need to hash
            // it to produce the 32-byte root.
            return Hash.keccak256(raw);
        },
    }
}

/// Free memory owned by an EncodedNode.
fn freeEncodedNode(allocator: Allocator, node: EncodedNode) void {
    switch (node) {
        .raw => |r| allocator.free(r),
        .hash, .empty => {},
    }
}

/// Convert bytes to nibble-list (each byte → two 4-bit nibbles).
/// Matches Python's `bytes_to_nibble_list()`.
fn keyToNibbles(allocator: Allocator, key: []const u8) ![]u8 {
    const nibbles = try allocator.alloc(u8, key.len * 2);
    for (key, 0..) |byte, i| {
        nibbles[i * 2] = byte >> 4;
        nibbles[i * 2 + 1] = byte & 0x0F;
    }
    return nibbles;
}

/// Hex prefix encoding (compact encoding) for nibble paths.
/// Matches Python's `nibble_list_to_compact()`.
fn nibbleListToCompact(allocator: Allocator, nibbles: []const u8, is_leaf: bool) ![]u8 {
    if (nibbles.len % 2 == 0) {
        // Even length
        const result = try allocator.alloc(u8, 1 + nibbles.len / 2);
        result[0] = if (is_leaf) 0x20 else 0x00;
        var i: usize = 0;
        while (i < nibbles.len) : (i += 2) {
            result[1 + i / 2] = (nibbles[i] << 4) | nibbles[i + 1];
        }
        return result;
    } else {
        // Odd length
        const result = try allocator.alloc(u8, 1 + nibbles.len / 2);
        result[0] = (if (is_leaf) @as(u8, 0x30) else @as(u8, 0x10)) | nibbles[0];
        var i: usize = 1;
        while (i < nibbles.len) : (i += 2) {
            result[1 + i / 2] = (nibbles[i] << 4) | nibbles[i + 1];
        }
        return result;
    }
}

/// Find the length of the longest common prefix between two nibble slices.
fn commonPrefixLength(a: []const u8, b: []const u8) usize {
    const min_len = @min(a.len, b.len);
    for (0..min_len) |i| {
        if (a[i] != b[i]) return i;
    }
    return min_len;
}

/// Recursively build the MPT from key-value pairs.
///
/// Matches Python's `patricialize(obj, level)`. Instead of using a dict,
/// we pass parallel arrays of nibble-keys and values.
///
/// Returns an `EncodedNode` — the result of `encode_internal_node()` on
/// the node built at this level.
fn patricialize(
    allocator: Allocator,
    nibble_keys: []const []const u8,
    values: []const []const u8,
    level: usize,
) !EncodedNode {
    if (nibble_keys.len == 0) {
        return .empty;
    }

    // Single entry → leaf node
    if (nibble_keys.len == 1) {
        const rest_of_key = nibble_keys[0][level..];
        return encodeInternalLeaf(allocator, rest_of_key, values[0]);
    }

    // Find common prefix among all keys at current level
    const first_key = nibble_keys[0][level..];
    var prefix_length: usize = first_key.len;

    for (nibble_keys[1..]) |key| {
        const key_suffix = key[level..];
        prefix_length = @min(prefix_length, commonPrefixLength(first_key, key_suffix));
        if (prefix_length == 0) break;
    }

    // Extension node: shared prefix exists
    if (prefix_length > 0) {
        const prefix = nibble_keys[0][level .. level + prefix_length];
        const child = try patricialize(allocator, nibble_keys, values, level + prefix_length);
        defer freeEncodedNode(allocator, child);
        return encodeInternalExtension(allocator, prefix, child);
    }

    // Branch node: split into 16 buckets by nibble at current level
    var bucket_counts: [16]usize = [_]usize{0} ** 16;
    var branch_value: ?[]const u8 = null;

    // Count entries per bucket and find branch value
    for (nibble_keys, 0..) |key, idx| {
        if (key.len == level) {
            branch_value = values[idx];
        } else {
            const nibble = key[level];
            bucket_counts[nibble] += 1;
        }
    }

    // Allocate temporary arrays for each bucket
    var bucket_key_arrays: [16]?[][]const u8 = [_]?[][]const u8{null} ** 16;
    var bucket_val_arrays: [16]?[][]const u8 = [_]?[][]const u8{null} ** 16;
    defer {
        for (0..16) |bi| {
            if (bucket_key_arrays[bi]) |arr| allocator.free(arr);
            if (bucket_val_arrays[bi]) |arr| allocator.free(arr);
        }
    }

    for (0..16) |bi| {
        if (bucket_counts[bi] > 0) {
            bucket_key_arrays[bi] = try allocator.alloc([]const u8, bucket_counts[bi]);
            bucket_val_arrays[bi] = try allocator.alloc([]const u8, bucket_counts[bi]);
        }
    }

    // Fill bucket arrays
    var fill_counts: [16]usize = [_]usize{0} ** 16;
    for (nibble_keys, 0..) |key, idx| {
        if (key.len == level) continue;
        const nibble = key[level];
        const fc = fill_counts[nibble];
        bucket_key_arrays[nibble].?[fc] = key;
        bucket_val_arrays[nibble].?[fc] = values[idx];
        fill_counts[nibble] += 1;
    }

    // Recursively patricialize each bucket
    var subnode_encodings: [16]EncodedNode = undefined;
    var subnode_count: usize = 0;
    errdefer {
        for (0..subnode_count) |si| {
            freeEncodedNode(allocator, subnode_encodings[si]);
        }
    }

    for (0..16) |bi| {
        const bkeys = bucket_key_arrays[bi] orelse &[_][]const u8{};
        const bvals = bucket_val_arrays[bi] orelse &[_][]const u8{};
        subnode_encodings[bi] = try patricialize(allocator, bkeys, bvals, level + 1);
        subnode_count = bi + 1;
    }
    // All 16 done, transfer to defer
    subnode_count = 0;
    defer {
        for (0..16) |si| {
            freeEncodedNode(allocator, subnode_encodings[si]);
        }
    }

    return encodeInternalBranch(allocator, &subnode_encodings, branch_value);
}

/// Encode a leaf node: `encode_internal_node(LeafNode(rest_of_key, value))`
///
/// The unencoded form is: `(nibble_list_to_compact(rest, True), value)`
/// RLP-encoded as a 2-element list.
fn encodeInternalLeaf(allocator: Allocator, rest_of_key: []const u8, value: []const u8) !EncodedNode {
    const compact_path = try nibbleListToCompact(allocator, rest_of_key, true);
    defer allocator.free(compact_path);

    // RLP encode the list [compact_path, value]
    const items = [2]RlpItem{
        .{ .string = compact_path },
        .{ .string = value },
    };
    return encodeInternalFromItems(allocator, &items);
}

/// Encode an extension node: `encode_internal_node(ExtensionNode(prefix, subnode))`
///
/// The unencoded form is: `(nibble_list_to_compact(segment, False), subnode)`
/// where `subnode` is the result of `encode_internal_node()` on the child.
fn encodeInternalExtension(allocator: Allocator, prefix: []const u8, child: EncodedNode) !EncodedNode {
    const compact_path = try nibbleListToCompact(allocator, prefix, false);
    defer allocator.free(compact_path);

    const child_item = encodedNodeToRlpItem(&child);

    const items = [2]RlpItem{
        .{ .string = compact_path },
        child_item,
    };
    return encodeInternalFromItems(allocator, &items);
}

/// Encode a branch node: `encode_internal_node(BranchNode(subnodes, value))`
///
/// The unencoded form is: `list(subnodes) + [value]` (17 elements)
fn encodeInternalBranch(allocator: Allocator, subnodes: *const [16]EncodedNode, value: ?[]const u8) !EncodedNode {
    var items: [17]RlpItem = undefined;

    for (0..16) |i| {
        items[i] = encodedNodeToRlpItem(&subnodes[i]);
    }

    // Branch value: empty bytes if no value
    items[16] = .{ .string = value orelse &[_]u8{} };

    return encodeInternalFromItems(allocator, &items);
}

/// Convert an EncodedNode to an RlpItem for embedding in a parent list.
///
/// In Python, `encode_internal_node` returns:
/// - `b""` for None → string item
/// - `keccak256(encoded)` for large nodes → 32-byte string item
/// - `unencoded` (tuple/list) for small nodes → already-encoded substructure
///
/// When embedded in a parent node, strings get RLP-encoded as strings,
/// and nested structures get embedded directly (as their RLP form).
///
/// IMPORTANT: Takes a pointer to avoid dangling references to stack copies.
/// The `.hash` variant returns a slice pointing into the EncodedNode's storage,
/// so the node must remain alive while the returned RlpItem is used.
fn encodedNodeToRlpItem(node: *const EncodedNode) RlpItem {
    switch (node.*) {
        .empty => return .{ .string = &[_]u8{} },
        .hash => |*h| return .{ .string = h },
        .raw => |raw| return .{ .verbatim = raw },
    }
}

/// Encode items as an RLP list and apply the < 32 byte inlining rule.
///
/// This is the core of `encode_internal_node()`:
/// 1. RLP-encode the list of items
/// 2. If len < 32: return the raw RLP (inline)
/// 3. If len >= 32: return keccak256(RLP)
fn encodeInternalFromItems(allocator: Allocator, items: []const RlpItem) !EncodedNode {
    const encoded = try rlpEncodeTaggedList(allocator, items);

    if (encoded.len < 32) {
        return .{ .raw = encoded };
    } else {
        defer allocator.free(encoded);
        return .{ .hash = Hash.keccak256(encoded) };
    }
}

/// RLP-encode a list of tagged items.
///
/// Each `.string` item is individually RLP-encoded as a byte string.
/// Each `.verbatim` item is included as-is (already RLP-encoded).
/// All are concatenated and wrapped with an RLP list header.
fn rlpEncodeTaggedList(allocator: Allocator, items: []const RlpItem) ![]u8 {
    // Encode each item
    var encoded_items = std.ArrayList([]u8){};
    defer {
        for (encoded_items.items) |item| allocator.free(item);
        encoded_items.deinit(allocator);
    }

    var total_len: usize = 0;
    for (items) |item| {
        const encoded_item = switch (item) {
            .string => |s| try Rlp.encodeBytes(allocator, s),
            .verbatim => |v| try allocator.dupe(u8, v),
        };

        try encoded_items.append(allocator, encoded_item);
        total_len += encoded_item.len;
    }

    // Build list with header
    var result = std.ArrayList(u8){};
    errdefer result.deinit(allocator);

    if (total_len < 56) {
        try result.append(allocator, 0xc0 + @as(u8, @intCast(total_len)));
    } else {
        const len_bytes = try Rlp.encodeLength(allocator, total_len);
        defer allocator.free(len_bytes);
        try result.append(allocator, 0xf7 + @as(u8, @intCast(len_bytes.len)));
        try result.appendSlice(allocator, len_bytes);
    }

    for (encoded_items.items) |item| {
        try result.appendSlice(allocator, item);
    }

    return try result.toOwnedSlice(allocator);
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

const testing = std.testing;

test "EMPTY_TRIE_ROOT matches spec constant" {
    // keccak256(rlp(b'')) = keccak256(0x80) =
    // 56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421
    const expected = [_]u8{
        0x56, 0xe8, 0x1f, 0x17, 0x1b, 0xcc, 0x55, 0xa6,
        0xff, 0x83, 0x45, 0xe6, 0x92, 0xc0, 0xf8, 0x6e,
        0x5b, 0x48, 0xe0, 0x1b, 0x99, 0x6c, 0xad, 0xc0,
        0x01, 0x62, 0x2f, 0xb5, 0xe3, 0x63, 0xb4, 0x21,
    };
    try testing.expectEqualSlices(u8, &expected, &EMPTY_TRIE_ROOT);
}

test "trieRoot - empty trie returns EMPTY_TRIE_ROOT" {
    const allocator = testing.allocator;
    const root = try trieRoot(allocator, &[_][]const u8{}, &[_][]const u8{});
    try testing.expectEqualSlices(u8, &EMPTY_TRIE_ROOT, &root);
}

test "trieRoot - single entry" {
    const allocator = testing.allocator;

    const keys = [_][]const u8{"do"};
    const values = [_][]const u8{"verb"};
    const root = try trieRoot(allocator, &keys, &values);

    // The root should NOT be the empty root
    try testing.expect(!std.mem.eql(u8, &root, &EMPTY_TRIE_ROOT));
}

test "nibbleListToCompact - even extension" {
    const allocator = testing.allocator;
    const nibbles = [_]u8{ 0x1, 0x2, 0x3, 0x4 };
    const result = try nibbleListToCompact(allocator, &nibbles, false);
    defer allocator.free(result);
    try testing.expectEqualSlices(u8, &[_]u8{ 0x00, 0x12, 0x34 }, result);
}

test "nibbleListToCompact - odd leaf" {
    const allocator = testing.allocator;
    const nibbles = [_]u8{ 0x1, 0x2, 0x3 };
    const result = try nibbleListToCompact(allocator, &nibbles, true);
    defer allocator.free(result);
    try testing.expectEqualSlices(u8, &[_]u8{ 0x31, 0x23 }, result);
}

test "nibbleListToCompact - even leaf" {
    const allocator = testing.allocator;
    const nibbles = [_]u8{ 0x1, 0x2, 0x3, 0x4 };
    const result = try nibbleListToCompact(allocator, &nibbles, true);
    defer allocator.free(result);
    try testing.expectEqualSlices(u8, &[_]u8{ 0x20, 0x12, 0x34 }, result);
}

test "nibbleListToCompact - odd extension" {
    const allocator = testing.allocator;
    const nibbles = [_]u8{0x1};
    const result = try nibbleListToCompact(allocator, &nibbles, false);
    defer allocator.free(result);
    try testing.expectEqualSlices(u8, &[_]u8{0x11}, result);
}

test "nibbleListToCompact - empty leaf" {
    const allocator = testing.allocator;
    const nibbles = [_]u8{};
    const result = try nibbleListToCompact(allocator, &nibbles, true);
    defer allocator.free(result);
    try testing.expectEqualSlices(u8, &[_]u8{0x20}, result);
}

test "keyToNibbles - basic" {
    const allocator = testing.allocator;
    const key = [_]u8{ 0x12, 0xAB };
    const nibbles = try keyToNibbles(allocator, &key);
    defer allocator.free(nibbles);
    try testing.expectEqualSlices(u8, &[_]u8{ 0x1, 0x2, 0xA, 0xB }, nibbles);
}

test "commonPrefixLength - basic" {
    const a = [_]u8{ 1, 2, 3, 4 };
    const b = [_]u8{ 1, 2, 5, 6 };
    try testing.expectEqual(@as(usize, 2), commonPrefixLength(&a, &b));
}

test "commonPrefixLength - no common prefix" {
    const a = [_]u8{ 1, 2, 3 };
    const b = [_]u8{ 4, 5, 6 };
    try testing.expectEqual(@as(usize, 0), commonPrefixLength(&a, &b));
}

test "commonPrefixLength - full match" {
    const a = [_]u8{ 1, 2, 3 };
    const b = [_]u8{ 1, 2, 3 };
    try testing.expectEqual(@as(usize, 3), commonPrefixLength(&a, &b));
}

test "trieRoot - dogs test (trieanyorder.json)" {
    // From ethereum-tests/TrieTests/trieanyorder.json "dogs" test:
    //   doe → reindeer, dog → puppy, dogglesworth → cat
    //   expected root: 0x8aad789dff2f538bca5d8ea56e8abe10f4c7ba3a5dea95fea4cd6e7c3a1168d3
    const allocator = testing.allocator;

    const keys = [_][]const u8{ "doe", "dog", "dogglesworth" };
    const values = [_][]const u8{ "reindeer", "puppy", "cat" };
    const root = try trieRoot(allocator, &keys, &values);

    const expected = [_]u8{
        0x8a, 0xad, 0x78, 0x9d, 0xff, 0x2f, 0x53, 0x8b,
        0xca, 0x5d, 0x8e, 0xa5, 0x6e, 0x8a, 0xbe, 0x10,
        0xf4, 0xc7, 0xba, 0x3a, 0x5d, 0xea, 0x95, 0xfe,
        0xa4, 0xcd, 0x6e, 0x7c, 0x3a, 0x11, 0x68, 0xd3,
    };
    try testing.expectEqualSlices(u8, &expected, &root);
}

test "rlpEncodeTaggedList - simple leaf" {
    // Verify RLP encoding of a leaf node: [0x20, "reindeer"]
    // Expected: ca 20 88 72656966e64656572
    const allocator = testing.allocator;

    const items = [2]RlpItem{
        .{ .string = &[_]u8{0x20} },
        .{ .string = "reindeer" },
    };
    const result = try rlpEncodeTaggedList(allocator, &items);
    defer allocator.free(result);

    // 0x20 is a single byte < 0x80, so RLP encodes as itself: 0x20 (1 byte)
    // "reindeer" is 8 bytes → RLP: 0x88 + 8 bytes (9 bytes)
    // Total payload: 1 + 9 = 10
    // List header: 0xc0 + 10 = 0xca
    const expected_hex = "ca20887265696e64656572";
    var expected: [expected_hex.len / 2]u8 = undefined;
    for (0..expected.len) |i| {
        expected[i] = std.fmt.parseInt(u8, expected_hex[i * 2 .. i * 2 + 2], 16) catch unreachable;
    }
    try testing.expectEqualSlices(u8, &expected, result);
}

test "rlpEncodeTaggedList - branch with inline and hash" {
    // Verify RLP encoding of the branch at level 6 in the dogs test
    // 15 empty subnodes + 1 inline leaf + 1 value
    const allocator = testing.allocator;

    // The inline leaf: ce89376c6573776f72746883636174
    const inline_hex = "ce89376c6573776f72746883636174";
    var inline_bytes: [inline_hex.len / 2]u8 = undefined;
    for (0..inline_bytes.len) |i| {
        inline_bytes[i] = std.fmt.parseInt(u8, inline_hex[i * 2 .. i * 2 + 2], 16) catch unreachable;
    }

    var items: [17]RlpItem = undefined;
    // subnodes 0-5: empty
    for (0..6) |i| items[i] = .{ .string = &[_]u8{} };
    // subnode 6: inline leaf
    items[6] = .{ .verbatim = &inline_bytes };
    // subnodes 7-15: empty
    for (7..16) |i| items[i] = .{ .string = &[_]u8{} };
    // value: "puppy"
    items[16] = .{ .string = "puppy" };

    const result = try rlpEncodeTaggedList(allocator, &items);
    defer allocator.free(result);

    const expected_hex = "e4808080808080ce89376c6573776f72746883636174808080808080808080857075707079";
    var expected: [expected_hex.len / 2]u8 = undefined;
    for (0..expected.len) |i| {
        expected[i] = std.fmt.parseInt(u8, expected_hex[i * 2 .. i * 2 + 2], 16) catch unreachable;
    }
    try testing.expectEqualSlices(u8, &expected, result);
}

test "rlpEncodeTaggedList - level 5 branch (dogs test)" {
    // Full branch at level 5: 14 empty + inline doe leaf + empty + hash for dog subtree + empty*8 + value empty
    // Expected: f83b 80*5 ca20887265696e64656572 80 a037efd1... 80*8 80
    const allocator = testing.allocator;

    // Inline leaf for doe: ca20887265696e64656572
    const inline_doe_hex = "ca20887265696e64656572";
    var inline_doe: [inline_doe_hex.len / 2]u8 = undefined;
    for (0..inline_doe.len) |i| {
        inline_doe[i] = std.fmt.parseInt(u8, inline_doe_hex[i * 2 .. i * 2 + 2], 16) catch unreachable;
    }

    // Hash for dog/dogglesworth subtree
    const hash_hex = "37efd11993cb04a54048c25320e9f29c50a432d28afdf01598b2978ce1ca3068";
    var hash_bytes: [32]u8 = undefined;
    for (0..32) |i| {
        hash_bytes[i] = std.fmt.parseInt(u8, hash_hex[i * 2 .. i * 2 + 2], 16) catch unreachable;
    }

    var items: [17]RlpItem = undefined;
    // subnodes 0-4: empty
    for (0..5) |i| items[i] = .{ .string = &[_]u8{} };
    // subnode 5: inline doe leaf
    items[5] = .{ .verbatim = &inline_doe };
    // subnode 6: empty
    items[6] = .{ .string = &[_]u8{} };
    // subnode 7: hash
    items[7] = .{ .string = &hash_bytes };
    // subnodes 8-15: empty
    for (8..16) |i| items[i] = .{ .string = &[_]u8{} };
    // value: empty
    items[16] = .{ .string = &[_]u8{} };

    const result = try rlpEncodeTaggedList(allocator, &items);
    defer allocator.free(result);

    const expected_hex = "f83b8080808080ca20887265696e6465657280a037efd11993cb04a54048c25320e9f29c50a432d28afdf01598b2978ce1ca3068808080808080808080";
    var expected: [expected_hex.len / 2]u8 = undefined;
    for (0..expected.len) |i| {
        expected[i] = std.fmt.parseInt(u8, expected_hex[i * 2 .. i * 2 + 2], 16) catch unreachable;
    }
    try testing.expectEqualSlices(u8, &expected, result);

    // Also verify the hash
    const expected_hash_hex = "db6ae1fda66890f6693f36560d36b4dca68b4d838f17016b151efe1d4c95c453";
    var expected_hash: [32]u8 = undefined;
    for (0..32) |i| {
        expected_hash[i] = std.fmt.parseInt(u8, expected_hash_hex[i * 2 .. i * 2 + 2], 16) catch unreachable;
    }
    const actual_hash = Hash.keccak256(result);
    try testing.expectEqualSlices(u8, &expected_hash, &actual_hash);
}

test "patricialize - dogs subtree at level 6 (dog + dogglesworth)" {
    // Test the subtree containing "dog" and "dogglesworth" at level 6
    // dog nibbles: [6,4,6,f,6,7] (len 6)
    // dogglesworth nibbles: [6,4,6,f,6,7,6,7,6,c,6,5,7,3,7,7,6,f,7,2,7,4,6,8] (len 24)
    // At level 6: dog ends → branch value="puppy", dogglesworth → bucket 6
    const allocator = testing.allocator;

    const dog_nibbles = [_]u8{ 6, 4, 6, 0xf, 6, 7 };
    const dogglesworth_nibbles = [_]u8{ 6, 4, 6, 0xf, 6, 7, 6, 7, 6, 0xc, 6, 5, 7, 3, 7, 7, 6, 0xf, 7, 2, 7, 4, 6, 8 };

    const nibble_keys = [_][]const u8{ &dog_nibbles, &dogglesworth_nibbles };
    const values = [_][]const u8{ "puppy", "cat" };

    const node = try patricialize(allocator, &nibble_keys, &values, 6);
    defer freeEncodedNode(allocator, node);

    // Expected: hash 37efd11993cb04a54048c25320e9f29c50a432d28afdf01598b2978ce1ca3068
    const expected_hex = "37efd11993cb04a54048c25320e9f29c50a432d28afdf01598b2978ce1ca3068";
    var expected_hash: [32]u8 = undefined;
    for (0..32) |i| {
        expected_hash[i] = std.fmt.parseInt(u8, expected_hex[i * 2 .. i * 2 + 2], 16) catch unreachable;
    }

    switch (node) {
        .hash => |h| try testing.expectEqualSlices(u8, &expected_hash, &h),
        .raw => |raw| {
            std.debug.print("Got raw node (len {d}): ", .{raw.len});
            for (raw) |b| std.debug.print("{x:0>2}", .{b});
            std.debug.print("\n", .{});
            return error.TestExpectedEqual;
        },
        .empty => return error.TestExpectedEqual,
    }
}

test "patricialize - dogs at level 5 (full branch)" {
    // Test the branch at level 5 with all three keys
    const allocator = testing.allocator;

    const doe_nibbles = [_]u8{ 6, 4, 6, 0xf, 6, 5 };
    const dog_nibbles = [_]u8{ 6, 4, 6, 0xf, 6, 7 };
    const dogglesworth_nibbles = [_]u8{ 6, 4, 6, 0xf, 6, 7, 6, 7, 6, 0xc, 6, 5, 7, 3, 7, 7, 6, 0xf, 7, 2, 7, 4, 6, 8 };

    const nibble_keys = [_][]const u8{ &doe_nibbles, &dog_nibbles, &dogglesworth_nibbles };
    const values = [_][]const u8{ "reindeer", "puppy", "cat" };

    const node = try patricialize(allocator, &nibble_keys, &values, 5);
    defer freeEncodedNode(allocator, node);

    // Expected: hash db6ae1fda66890f6693f36560d36b4dca68b4d838f17016b151efe1d4c95c453
    const expected_hex = "db6ae1fda66890f6693f36560d36b4dca68b4d838f17016b151efe1d4c95c453";
    var expected_hash: [32]u8 = undefined;
    for (0..32) |i| {
        expected_hash[i] = std.fmt.parseInt(u8, expected_hex[i * 2 .. i * 2 + 2], 16) catch unreachable;
    }

    switch (node) {
        .hash => |h| try testing.expectEqualSlices(u8, &expected_hash, &h),
        .raw => |raw| {
            std.debug.print("Got raw node (len {d}): ", .{raw.len});
            for (raw) |b| std.debug.print("{x:0>2}", .{b});
            std.debug.print("\n", .{});
            return error.TestExpectedEqual;
        },
        .empty => return error.TestExpectedEqual,
    }
}

test "trieRoot - singleItem test (trieanyorder.json)" {
    // From ethereum-tests/TrieTests/trieanyorder.json "singleItem":
    //   A → aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    //   expected root: 0xd23786fb4a010da3ce639d66d5e904a11dbc02746d1ce25029e53290cabf28ab
    const allocator = testing.allocator;

    const keys = [_][]const u8{"A"};
    const values = [_][]const u8{"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"};
    const root = try trieRoot(allocator, &keys, &values);

    const expected = [_]u8{
        0xd2, 0x37, 0x86, 0xfb, 0x4a, 0x01, 0x0d, 0xa3,
        0xce, 0x63, 0x9d, 0x66, 0xd5, 0xe9, 0x04, 0xa1,
        0x1d, 0xbc, 0x02, 0x74, 0x6d, 0x1c, 0xe2, 0x50,
        0x29, 0xe5, 0x32, 0x90, 0xca, 0xbf, 0x28, 0xab,
    };
    try testing.expectEqualSlices(u8, &expected, &root);
}
