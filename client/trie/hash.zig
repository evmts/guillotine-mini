//! MPT Root Hash Computation
//!
//! Implements the `patricialize()` algorithm from the Ethereum execution-specs
//! (`execution-specs/src/ethereum/forks/frontier/trie.py`). This computes a
//! Merkle Patricia Trie root hash from a flat key-value mapping, exactly
//! matching the spec behavior including node inlining (nodes whose RLP is
//! < 32 bytes are returned as raw RLP structures, not hashed).
//!
//! Uses Voltaire primitives for RLP encoding and keccak256 hashing.
//!
//! ## RLP List Encoding Design Note
//!
//! We maintain a custom `rlp_encode_tagged_list()` rather than using Voltaire's
//! `Rlp.encodeList()` because the MPT requires mixed-mode encoding: some list
//! items are byte strings needing RLP string encoding, while others are inline
//! node substructures that must be embedded verbatim (already RLP-encoded).
//! Voltaire's `encodeList` would re-encode verbatim items as byte strings,
//! producing incorrect results. We still use Voltaire's `Rlp.encodeBytes()`
//! for individual string items and `Rlp.encodeLength()` for list headers.

const std = @import("std");
const Allocator = std.mem.Allocator;

/// RLP encoding from Voltaire primitives
const Rlp = @import("primitives").Rlp;
/// Keccak256 hash function from Voltaire crypto
const Hash = @import("crypto").Hash;

/// 32-byte hash type, imported from node.zig to avoid duplication.
pub const Hash32 = @import("node.zig").Hash32;

/// EMPTY_TRIE_ROOT = keccak256(RLP(b"")) = keccak256(0x80)
/// = 0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421
/// Used when the trie has no entries.
pub const EMPTY_TRIE_ROOT: Hash32 = .{
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
const EncodedNode = union(enum) {
    /// Complete RLP encoding of an inline node (< 32 bytes)
    raw: []const u8,
    /// Keccak256 hash of the RLP encoding (>= 32 bytes)
    hash: Hash32,
    /// Empty node (encodes to b"")
    empty: void,
};

/// An item in an RLP list with explicit encoding tag.
///
/// This tagged union is necessary because the MPT spec requires mixed-mode
/// list encoding: some items are byte strings (needing RLP string encoding)
/// while others are already-encoded substructures (to embed verbatim).
/// Voltaire's `Rlp.encodeList()` cannot distinguish these cases, so we use
/// this type with our custom `rlp_encode_tagged_list()`.
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
pub fn trie_root(
    allocator: Allocator,
    keys: []const []const u8,
    values: []const []const u8,
) !Hash32 {
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
        nibble_keys[i] = try key_to_nibbles(allocator, key);
    }

    // Build the trie and get the root node encoding
    const root_node = try patricialize(allocator, nibble_keys, values, 0);
    defer free_encoded_node(allocator, root_node);

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

/// Free memory owned by an `EncodedNode`.
///
/// Only the `.raw` variant owns allocated memory (the RLP-encoded bytes).
/// `.hash` is a value type (32-byte array) and `.empty` holds no data.
fn free_encoded_node(allocator: Allocator, node: EncodedNode) void {
    switch (node) {
        .raw => |r| allocator.free(r),
        .hash, .empty => {},
    }
}

/// Convert a byte sequence to nibble-list form (each byte → two 4-bit nibbles).
///
/// Matches Python's `bytes_to_nibble_list()` from `execution-specs`.
/// For example, `[0x12, 0xAB]` becomes `[0x1, 0x2, 0xA, 0xB]`.
/// The caller owns the returned slice and must free it with `allocator`.
fn key_to_nibbles(allocator: Allocator, key: []const u8) ![]u8 {
    const nibbles = try allocator.alloc(u8, key.len * 2);
    for (key, 0..) |byte, i| {
        nibbles[i * 2] = byte >> 4;
        nibbles[i * 2 + 1] = byte & 0x0F;
    }
    return nibbles;
}

/// Hex-prefix (compact) encoding for nibble paths.
///
/// Matches Python's `nibble_list_to_compact()` from `execution-specs`.
/// Encodes a nibble path with a flag byte indicating leaf vs extension and
/// even vs odd length. The caller owns the returned slice.
///
/// Encoding rules:
/// - Even extension: `[0x00, packed_nibbles...]`
/// - Odd extension:  `[0x1N, packed_nibbles...]` where N is the first nibble
/// - Even leaf:      `[0x20, packed_nibbles...]`
/// - Odd leaf:       `[0x3N, packed_nibbles...]` where N is the first nibble
fn nibble_list_to_compact(allocator: Allocator, nibbles: []const u8, is_leaf: bool) ![]u8 {
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

/// Find the length of the longest common prefix between two byte slices.
///
/// Returns the number of leading bytes that are identical in both slices.
/// Used to find shared prefixes among nibble-encoded trie keys.
fn common_prefix_length(a: []const u8, b: []const u8) usize {
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
/// Returns an `EncodedNode` -- the result of `encode_internal_node()` on
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

    // Single entry -> leaf node
    if (nibble_keys.len == 1) {
        const rest_of_key = nibble_keys[0][level..];
        return encode_internal_leaf(allocator, rest_of_key, values[0]);
    }

    // Find common prefix among all keys at current level
    const first_key = nibble_keys[0][level..];
    var prefix_length: usize = first_key.len;

    for (nibble_keys[1..]) |key| {
        const key_suffix = key[level..];
        prefix_length = @min(prefix_length, common_prefix_length(first_key, key_suffix));
        if (prefix_length == 0) break;
    }

    // Extension node: shared prefix exists
    if (prefix_length > 0) {
        const prefix = nibble_keys[0][level .. level + prefix_length];
        const child = try patricialize(allocator, nibble_keys, values, level + prefix_length);
        defer free_encoded_node(allocator, child);
        return encode_internal_extension(allocator, prefix, child);
    }

    // Branch node: split into 16 buckets by nibble at current level.
    // Uses a two-pass approach with preallocated contiguous arrays to
    // minimize per-bucket allocation overhead.
    var bucket_counts: [16]usize = [_]usize{0} ** 16;
    // Python spec uses b"" (empty bytes) as the "no value" sentinel for
    // branch nodes, not None/null. This matches the spec's BranchNode
    // constructor default: `value: Extended = b""`.
    var branch_value: []const u8 = &[_]u8{};

    // Count entries per bucket and find branch value.
    // NOTE: If multiple keys have the same nibble path (duplicate keys),
    // the last value wins, matching Python dict semantics where later
    // insertions overwrite earlier ones.
    for (nibble_keys, 0..) |key, idx| {
        if (key.len == level) {
            branch_value = values[idx];
        } else {
            const nibble = key[level];
            bucket_counts[nibble] += 1;
        }
    }

    // Calculate total non-branch entries for contiguous allocation
    var total_entries: usize = 0;
    var bucket_offsets: [16]usize = undefined;
    for (0..16) |bi| {
        bucket_offsets[bi] = total_entries;
        total_entries += bucket_counts[bi];
    }

    // Allocate contiguous arrays for all bucket entries
    const all_keys = try allocator.alloc([]const u8, total_entries);
    defer allocator.free(all_keys);
    const all_vals = try allocator.alloc([]const u8, total_entries);
    defer allocator.free(all_vals);

    // Fill bucket arrays using offsets into contiguous storage
    var fill_counts: [16]usize = [_]usize{0} ** 16;
    for (nibble_keys, 0..) |key, idx| {
        if (key.len == level) continue;
        const nibble = key[level];
        const pos = bucket_offsets[nibble] + fill_counts[nibble];
        all_keys[pos] = key;
        all_vals[pos] = values[idx];
        fill_counts[nibble] += 1;
    }

    // Recursively patricialize each bucket
    var subnode_encodings: [16]EncodedNode = undefined;
    var subnode_count: usize = 0;
    errdefer {
        for (0..subnode_count) |si| {
            free_encoded_node(allocator, subnode_encodings[si]);
        }
    }

    for (0..16) |bi| {
        const start = bucket_offsets[bi];
        const count = bucket_counts[bi];
        const bkeys = all_keys[start .. start + count];
        const bvals = all_vals[start .. start + count];
        subnode_encodings[bi] = try patricialize(allocator, bkeys, bvals, level + 1);
        subnode_count = bi + 1;
    }
    // All 16 done, transfer to defer
    subnode_count = 0;
    defer {
        for (0..16) |si| {
            free_encoded_node(allocator, subnode_encodings[si]);
        }
    }

    return encode_internal_branch(allocator, &subnode_encodings, branch_value);
}

/// Encode a leaf node: `encode_internal_node(LeafNode(rest_of_key, value))`
///
/// The unencoded form is: `(nibble_list_to_compact(rest, True), value)`
/// RLP-encoded as a 2-element list.
fn encode_internal_leaf(allocator: Allocator, rest_of_key: []const u8, value: []const u8) !EncodedNode {
    const compact_path = try nibble_list_to_compact(allocator, rest_of_key, true);
    defer allocator.free(compact_path);

    // RLP encode the list [compact_path, value]
    const items = [2]RlpItem{
        .{ .string = compact_path },
        .{ .string = value },
    };
    return encode_internal_from_items(allocator, &items);
}

/// Encode an extension node: `encode_internal_node(ExtensionNode(prefix, subnode))`
///
/// The unencoded form is: `(nibble_list_to_compact(segment, False), subnode)`
/// where `subnode` is the result of `encode_internal_node()` on the child.
fn encode_internal_extension(allocator: Allocator, prefix: []const u8, child: EncodedNode) !EncodedNode {
    const compact_path = try nibble_list_to_compact(allocator, prefix, false);
    defer allocator.free(compact_path);

    const child_item = encoded_node_to_rlp_item(&child);

    const items = [2]RlpItem{
        .{ .string = compact_path },
        child_item,
    };
    return encode_internal_from_items(allocator, &items);
}

/// Encode a branch node: `encode_internal_node(BranchNode(subnodes, value))`
///
/// The unencoded form is: `list(subnodes) + [value]` (17 elements).
/// `value` is `b""` (empty bytes) when no value terminates at this branch,
/// matching the Python spec's sentinel convention.
fn encode_internal_branch(allocator: Allocator, subnodes: *const [16]EncodedNode, value: []const u8) !EncodedNode {
    var items: [17]RlpItem = undefined;

    for (0..16) |i| {
        items[i] = encoded_node_to_rlp_item(&subnodes[i]);
    }

    // Branch value: empty bytes means "no value" per spec
    items[16] = .{ .string = value };

    return encode_internal_from_items(allocator, &items);
}

/// Convert an EncodedNode to an RlpItem for embedding in a parent list.
///
/// In Python, `encode_internal_node` returns:
/// - `b""` for None -> string item
/// - `keccak256(encoded)` for large nodes -> 32-byte string item
/// - `unencoded` (tuple/list) for small nodes -> already-encoded substructure
///
/// When embedded in a parent node, strings get RLP-encoded as strings,
/// and nested structures get embedded directly (as their RLP form).
///
/// IMPORTANT: Takes a pointer to avoid dangling references to stack copies.
/// The `.hash` variant returns a slice pointing into the EncodedNode's storage,
/// so the node must remain alive while the returned RlpItem is used.
fn encoded_node_to_rlp_item(node: *const EncodedNode) RlpItem {
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
fn encode_internal_from_items(allocator: Allocator, items: []const RlpItem) !EncodedNode {
    const encoded = try rlp_encode_tagged_list(allocator, items);

    if (encoded.len < 32) {
        return .{ .raw = encoded };
    } else {
        defer allocator.free(encoded);
        return .{ .hash = Hash.keccak256(encoded) };
    }
}

/// RLP-encode a list of tagged items.
///
/// Each `.string` item is individually RLP-encoded via Voltaire's
/// `Rlp.encodeBytes()`. Each `.verbatim` item is included as-is
/// (already RLP-encoded). All are concatenated and wrapped with an
/// RLP list header (using Voltaire's `Rlp.encodeLength()` for long lists).
///
/// NOTE: We cannot use Voltaire's `Rlp.encodeList()` here because it would
/// re-encode verbatim items as byte strings. See module-level doc comment.
///
/// Allocation strategy: Two-pass approach. First pass computes total payload
/// size by encoding string items into a fixed-size buffer of pre-encoded
/// slices. Second pass writes directly into a single output allocation.
fn rlp_encode_tagged_list(allocator: Allocator, items: []const RlpItem) ![]u8 {
    // First pass: encode string items, keep verbatim as-is, compute total size.
    // Use a stack buffer for small lists (branch nodes have 17 items).
    const rlp_empty_string = [_]u8{0x80};
    var encoded_buf: [17][]const u8 = undefined;
    var owned_mask: [17]bool = [_]bool{false} ** 17;
    std.debug.assert(items.len <= 17);

    var total_len: usize = 0;
    for (items, 0..) |item, i| {
        switch (item) {
            .string => |s| {
                if (s.len == 0) {
                    encoded_buf[i] = &rlp_empty_string;
                    owned_mask[i] = false;
                } else {
                    encoded_buf[i] = try Rlp.encodeBytes(allocator, s);
                    owned_mask[i] = true;
                }
            },
            .verbatim => |v| {
                encoded_buf[i] = v;
                owned_mask[i] = false;
            },
        }
        total_len += encoded_buf[i].len;
    }
    // Ensure we free owned encoded items on all paths.
    // @constCast is needed because Rlp.encodeBytes returns []const u8 but
    // allocator.free requires []u8. The cast is safe since we own the memory.
    defer {
        for (0..items.len) |i| {
            if (owned_mask[i]) allocator.free(@constCast(encoded_buf[i]));
        }
    }

    // Second pass: compute header size and allocate result in one shot.
    // Max RLP list header: 1 prefix byte + up to 8 length bytes.
    var header_buf: [9]u8 = undefined;
    const header_len: usize = if (total_len < 56) blk: {
        header_buf[0] = 0xc0 + @as(u8, @intCast(total_len));
        break :blk 1;
    } else blk: {
        const len_bytes = try Rlp.encodeLength(allocator, total_len);
        defer allocator.free(len_bytes);
        header_buf[0] = 0xf7 + @as(u8, @intCast(len_bytes.len));
        @memcpy(header_buf[1 .. 1 + len_bytes.len], len_bytes);
        break :blk 1 + len_bytes.len;
    };

    // Single allocation for the complete result
    const result = try allocator.alloc(u8, header_len + total_len);
    errdefer allocator.free(result);

    // Write header
    @memcpy(result[0..header_len], header_buf[0..header_len]);

    // Write payload items contiguously
    var offset: usize = header_len;
    for (0..items.len) |i| {
        const item_data = encoded_buf[i];
        @memcpy(result[offset .. offset + item_data.len], item_data);
        offset += item_data.len;
    }

    return result;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

const testing = std.testing;

/// Helper: parse a comptime hex string literal into a fixed-size byte array.
/// Returns the parsed array directly — evaluated at comptime via inline.
inline fn hex_to_bytes(comptime hex: anytype) [@as(usize, hex.len) / 2]u8 {
    const n = @as(usize, hex.len) / 2;
    var result: [n]u8 = undefined;
    for (&result, 0..) |*byte, i| {
        byte.* = (hex_val(hex[i * 2]) << 4) | hex_val(hex[i * 2 + 1]);
    }
    return result;
}

inline fn hex_val(c: u8) u8 {
    return switch (c) {
        '0'...'9' => c - '0',
        'a'...'f' => c - 'a' + 10,
        'A'...'F' => c - 'A' + 10,
        else => unreachable,
    };
}

test "EMPTY_TRIE_ROOT matches spec constant" {
    // keccak256(rlp(b'')) = keccak256(0x80) =
    // 56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421
    const expected = hex_to_bytes("56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421");
    try testing.expectEqualSlices(u8, &expected, &EMPTY_TRIE_ROOT);
}

test "trie_root - empty trie returns EMPTY_TRIE_ROOT" {
    const allocator = testing.allocator;
    const root = try trie_root(allocator, &[_][]const u8{}, &[_][]const u8{});
    try testing.expectEqualSlices(u8, &EMPTY_TRIE_ROOT, &root);
}

test "trie_root - single entry" {
    const allocator = testing.allocator;

    const keys = [_][]const u8{"do"};
    const values = [_][]const u8{"verb"};
    const root = try trie_root(allocator, &keys, &values);

    // The root should NOT be the empty root
    try testing.expect(!std.mem.eql(u8, &root, &EMPTY_TRIE_ROOT));
}

test "nibble_list_to_compact - even extension" {
    const allocator = testing.allocator;
    const nibbles = [_]u8{ 0x1, 0x2, 0x3, 0x4 };
    const result = try nibble_list_to_compact(allocator, &nibbles, false);
    defer allocator.free(result);
    try testing.expectEqualSlices(u8, &[_]u8{ 0x00, 0x12, 0x34 }, result);
}

test "nibble_list_to_compact - odd leaf" {
    const allocator = testing.allocator;
    const nibbles = [_]u8{ 0x1, 0x2, 0x3 };
    const result = try nibble_list_to_compact(allocator, &nibbles, true);
    defer allocator.free(result);
    try testing.expectEqualSlices(u8, &[_]u8{ 0x31, 0x23 }, result);
}

test "nibble_list_to_compact - even leaf" {
    const allocator = testing.allocator;
    const nibbles = [_]u8{ 0x1, 0x2, 0x3, 0x4 };
    const result = try nibble_list_to_compact(allocator, &nibbles, true);
    defer allocator.free(result);
    try testing.expectEqualSlices(u8, &[_]u8{ 0x20, 0x12, 0x34 }, result);
}

test "nibble_list_to_compact - odd extension" {
    const allocator = testing.allocator;
    const nibbles = [_]u8{0x1};
    const result = try nibble_list_to_compact(allocator, &nibbles, false);
    defer allocator.free(result);
    try testing.expectEqualSlices(u8, &[_]u8{0x11}, result);
}

test "nibble_list_to_compact - empty leaf" {
    const allocator = testing.allocator;
    const nibbles = [_]u8{};
    const result = try nibble_list_to_compact(allocator, &nibbles, true);
    defer allocator.free(result);
    try testing.expectEqualSlices(u8, &[_]u8{0x20}, result);
}

test "key_to_nibbles - basic" {
    const allocator = testing.allocator;
    const key = [_]u8{ 0x12, 0xAB };
    const nibbles = try key_to_nibbles(allocator, &key);
    defer allocator.free(nibbles);
    try testing.expectEqualSlices(u8, &[_]u8{ 0x1, 0x2, 0xA, 0xB }, nibbles);
}

test "common_prefix_length - basic" {
    const a = [_]u8{ 1, 2, 3, 4 };
    const b = [_]u8{ 1, 2, 5, 6 };
    try testing.expectEqual(@as(usize, 2), common_prefix_length(&a, &b));
}

test "common_prefix_length - no common prefix" {
    const a = [_]u8{ 1, 2, 3 };
    const b = [_]u8{ 4, 5, 6 };
    try testing.expectEqual(@as(usize, 0), common_prefix_length(&a, &b));
}

test "common_prefix_length - full match" {
    const a = [_]u8{ 1, 2, 3 };
    const b = [_]u8{ 1, 2, 3 };
    try testing.expectEqual(@as(usize, 3), common_prefix_length(&a, &b));
}

// ---------------------------------------------------------------------------
// trieanyorder.json spec tests (all 7 vectors)
// ---------------------------------------------------------------------------

test "trieanyorder - singleItem" {
    // A -> aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    const allocator = testing.allocator;
    const keys = [_][]const u8{"A"};
    const values = [_][]const u8{"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"};
    const root = try trie_root(allocator, &keys, &values);
    const expected = hex_to_bytes("d23786fb4a010da3ce639d66d5e904a11dbc02746d1ce25029e53290cabf28ab");
    try testing.expectEqualSlices(u8, &expected, &root);
}

test "trieanyorder - dogs" {
    // doe -> reindeer, dog -> puppy, dogglesworth -> cat
    const allocator = testing.allocator;
    const keys = [_][]const u8{ "doe", "dog", "dogglesworth" };
    const values = [_][]const u8{ "reindeer", "puppy", "cat" };
    const root = try trie_root(allocator, &keys, &values);
    const expected = hex_to_bytes("8aad789dff2f538bca5d8ea56e8abe10f4c7ba3a5dea95fea4cd6e7c3a1168d3");
    try testing.expectEqualSlices(u8, &expected, &root);
}

test "trieanyorder - puppy" {
    // do -> verb, horse -> stallion, doge -> coin, dog -> puppy
    const allocator = testing.allocator;
    const keys = [_][]const u8{ "do", "horse", "doge", "dog" };
    const values = [_][]const u8{ "verb", "stallion", "coin", "puppy" };
    const root = try trie_root(allocator, &keys, &values);
    const expected = hex_to_bytes("5991bb8c6514148a29db676a14ac506cd2cd5775ace63c30a4fe457715e9ac84");
    try testing.expectEqualSlices(u8, &expected, &root);
}

test "trieanyorder - foo" {
    // foo -> bar, food -> bass
    const allocator = testing.allocator;
    const keys = [_][]const u8{ "foo", "food" };
    const values = [_][]const u8{ "bar", "bass" };
    const root = try trie_root(allocator, &keys, &values);
    const expected = hex_to_bytes("17beaa1648bafa633cda809c90c04af50fc8aed3cb40d16efbddee6fdf63c4c3");
    try testing.expectEqualSlices(u8, &expected, &root);
}

test "trieanyorder - smallValues" {
    // be -> e, dog -> puppy, bed -> d
    const allocator = testing.allocator;
    const keys = [_][]const u8{ "be", "dog", "bed" };
    const values = [_][]const u8{ "e", "puppy", "d" };
    const root = try trie_root(allocator, &keys, &values);
    const expected = hex_to_bytes("3f67c7a47520f79faa29255d2d3c084a7a6df0453116ed7232ff10277a8be68b");
    try testing.expectEqualSlices(u8, &expected, &root);
}

test "trieanyorder - testy" {
    // test -> test, te -> testy
    const allocator = testing.allocator;
    const keys = [_][]const u8{ "test", "te" };
    const values = [_][]const u8{ "test", "testy" };
    const root = try trie_root(allocator, &keys, &values);
    const expected = hex_to_bytes("8452568af70d8d140f58d941338542f645fcca50094b20f3c3d8c3df49337928");
    try testing.expectEqualSlices(u8, &expected, &root);
}

test "trieanyorder - hex" {
    // 0x0045 -> 0x0123456789, 0x4500 -> 0x9876543210
    // Keys/values are hex-encoded byte strings
    const allocator = testing.allocator;
    const keys = [_][]const u8{
        &hex_to_bytes("0045"),
        &hex_to_bytes("4500"),
    };
    const values = [_][]const u8{
        &hex_to_bytes("0123456789"),
        &hex_to_bytes("9876543210"),
    };
    const root = try trie_root(allocator, &keys, &values);
    const expected = hex_to_bytes("285505fcabe84badc8aa310e2aae17eddc7d120aabec8a476902c8184b3a3503");
    try testing.expectEqualSlices(u8, &expected, &root);
}

// ---------------------------------------------------------------------------
// trietest.json spec tests (ordered insertion with updates/deletes)
// ---------------------------------------------------------------------------

test "trietest - insert-middle-leaf" {
    // Ordered insertions:
    //   key1aa -> 0123456789012345678901234567890123456789xxx
    //   key1   -> 0123456789012345678901234567890123456789Very_Long
    //   key2bb -> aval3
    //   key2   -> short
    //   key3cc -> aval3
    //   key3   -> 1234567890123456789012345678901
    const allocator = testing.allocator;
    const keys = [_][]const u8{ "key1aa", "key1", "key2bb", "key2", "key3cc", "key3" };
    const values = [_][]const u8{
        "0123456789012345678901234567890123456789xxx",
        "0123456789012345678901234567890123456789Very_Long",
        "aval3",
        "short",
        "aval3",
        "1234567890123456789012345678901",
    };
    const root = try trie_root(allocator, &keys, &values);
    const expected = hex_to_bytes("cb65032e2f76c48b82b5c24b3db8f670ce73982869d38cd39a624f23d62a9e89");
    try testing.expectEqualSlices(u8, &expected, &root);
}

test "trietest - branch-value-update" {
    // Ordered insertions where "abc" is set twice (last value wins):
    //   abc  -> 123
    //   abcd -> abcd
    //   abc  -> abc  (overwrites "123")
    // Our trie_root takes final state, so pass the final mapping:
    const allocator = testing.allocator;
    const keys = [_][]const u8{ "abc", "abcd" };
    const values = [_][]const u8{ "abc", "abcd" };
    const root = try trie_root(allocator, &keys, &values);
    const expected = hex_to_bytes("7a320748f780ad9ad5b0837302075ce0eeba6c26e3d8562c67ccc0f1b273298a");
    try testing.expectEqualSlices(u8, &expected, &root);
}

// ---------------------------------------------------------------------------
// Internal structure tests
// ---------------------------------------------------------------------------

test "rlp_encode_tagged_list - simple leaf" {
    // Verify RLP encoding of a leaf node: [0x20, "reindeer"]
    const allocator = testing.allocator;

    const items = [2]RlpItem{
        .{ .string = &[_]u8{0x20} },
        .{ .string = "reindeer" },
    };
    const result = try rlp_encode_tagged_list(allocator, &items);
    defer allocator.free(result);

    const expected = hex_to_bytes("ca20887265696e64656572");
    try testing.expectEqualSlices(u8, &expected, result);
}

test "rlp_encode_tagged_list - branch with inline and hash" {
    // Verify RLP encoding of the branch at level 6 in the dogs test
    const allocator = testing.allocator;

    const inline_bytes = hex_to_bytes("ce89376c6573776f72746883636174");

    var items: [17]RlpItem = undefined;
    for (0..6) |i| items[i] = .{ .string = &[_]u8{} };
    items[6] = .{ .verbatim = &inline_bytes };
    for (7..16) |i| items[i] = .{ .string = &[_]u8{} };
    items[16] = .{ .string = "puppy" };

    const result = try rlp_encode_tagged_list(allocator, &items);
    defer allocator.free(result);

    const expected = hex_to_bytes("e4808080808080ce89376c6573776f72746883636174808080808080808080857075707079");
    try testing.expectEqualSlices(u8, &expected, result);
}

test "rlp_encode_tagged_list - level 5 branch (dogs test)" {
    const allocator = testing.allocator;

    const inline_doe = hex_to_bytes("ca20887265696e64656572");
    const hash_bytes = hex_to_bytes("37efd11993cb04a54048c25320e9f29c50a432d28afdf01598b2978ce1ca3068");

    var items: [17]RlpItem = undefined;
    for (0..5) |i| items[i] = .{ .string = &[_]u8{} };
    items[5] = .{ .verbatim = &inline_doe };
    items[6] = .{ .string = &[_]u8{} };
    items[7] = .{ .string = &hash_bytes };
    for (8..16) |i| items[i] = .{ .string = &[_]u8{} };
    items[16] = .{ .string = &[_]u8{} };

    const result = try rlp_encode_tagged_list(allocator, &items);
    defer allocator.free(result);

    const expected = hex_to_bytes("f83b8080808080ca20887265696e6465657280a037efd11993cb04a54048c25320e9f29c50a432d28afdf01598b2978ce1ca3068808080808080808080");
    try testing.expectEqualSlices(u8, &expected, result);

    // Also verify the hash
    const expected_hash = hex_to_bytes("db6ae1fda66890f6693f36560d36b4dca68b4d838f17016b151efe1d4c95c453");
    const actual_hash = Hash.keccak256(result);
    try testing.expectEqualSlices(u8, &expected_hash, &actual_hash);
}

/// Assert that an `EncodedNode` is a `.hash` variant matching `expected`.
/// On mismatch, prints debug info for `.raw` nodes to aid diagnosis.
fn expect_node_hash(node: EncodedNode, expected: []const u8) !void {
    switch (node) {
        .hash => |h| try testing.expectEqualSlices(u8, expected, &h),
        .raw => |raw| {
            std.debug.print("Got raw node (len {d}): ", .{raw.len});
            for (raw) |b| std.debug.print("{x:0>2}", .{b});
            std.debug.print("\n", .{});
            return error.TestExpectedEqual;
        },
        .empty => return error.TestExpectedEqual,
    }
}

test "patricialize - dogs subtree at level 6 (dog + dogglesworth)" {
    const allocator = testing.allocator;

    const dog_nibbles = [_]u8{ 6, 4, 6, 0xf, 6, 7 };
    const dogglesworth_nibbles = [_]u8{ 6, 4, 6, 0xf, 6, 7, 6, 7, 6, 0xc, 6, 5, 7, 3, 7, 7, 6, 0xf, 7, 2, 7, 4, 6, 8 };

    const nibble_keys = [_][]const u8{ &dog_nibbles, &dogglesworth_nibbles };
    const values = [_][]const u8{ "puppy", "cat" };

    const node = try patricialize(allocator, &nibble_keys, &values, 6);
    defer free_encoded_node(allocator, node);

    const expected_hash = hex_to_bytes("37efd11993cb04a54048c25320e9f29c50a432d28afdf01598b2978ce1ca3068");
    try expect_node_hash(node, &expected_hash);
}

test "patricialize - dogs at level 5 (full branch)" {
    const allocator = testing.allocator;

    const doe_nibbles = [_]u8{ 6, 4, 6, 0xf, 6, 5 };
    const dog_nibbles = [_]u8{ 6, 4, 6, 0xf, 6, 7 };
    const dogglesworth_nibbles = [_]u8{ 6, 4, 6, 0xf, 6, 7, 6, 7, 6, 0xc, 6, 5, 7, 3, 7, 7, 6, 0xf, 7, 2, 7, 4, 6, 8 };

    const nibble_keys = [_][]const u8{ &doe_nibbles, &dog_nibbles, &dogglesworth_nibbles };
    const values = [_][]const u8{ "reindeer", "puppy", "cat" };

    const node = try patricialize(allocator, &nibble_keys, &values, 5);
    defer free_encoded_node(allocator, node);

    const expected_hash = hex_to_bytes("db6ae1fda66890f6693f36560d36b4dca68b4d838f17016b151efe1d4c95c453");
    try expect_node_hash(node, &expected_hash);
}
