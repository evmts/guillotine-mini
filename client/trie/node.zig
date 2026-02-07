//! Trie Node Types for the Merkle Patricia Trie.
//!
//! Defines the three internal node types used by the Modified Merkle Patricia
//! Trie (MPT): `LeafNode`, `ExtensionNode`, and `BranchNode`, plus a `Node`
//! tagged union that represents any node.
//!
//! These types match the Python execution-specs definitions from
//! `execution-specs/src/ethereum/forks/frontier/trie.py`:
//!
//! ```python
//! class LeafNode:
//!     rest_of_key: Bytes
//!     value: Extended
//!
//! class ExtensionNode:
//!     key_segment: Bytes
//!     subnode: Extended
//!
//! class BranchNode:
//!     subnodes: Tuple[Extended, ...]  # 16 children
//!     value: Extended
//! ```
//!
//! The Nethermind equivalent is `NodeType.cs` + `NodeData.cs` in
//! `Nethermind.Trie/`, which uses a single sealed `TrieNode` container with
//! a `NodeType` enum and polymorphic `INodeData`. Here we use a Zig tagged
//! union instead, which is idiomatic and provides comptime type safety.
//!
//! ## Child References
//!
//! Branch and extension nodes reference children via `ChildRef`, which
//! mirrors the Python spec's `Extended` type: a child can be either an
//! inline node (RLP < 32 bytes, stored directly) or a hash reference
//! (keccak256 of the RLP encoding, 32 bytes). This matches the
//! `encode_internal_node` rule: if `len(rlp.encode(node)) < 32`, the
//! unencoded form is inlined; otherwise the keccak256 hash is stored.
//!
//! ## Memory Ownership
//!
//! All byte slices (`[]const u8`) within node types are borrowed references.
//! The caller (typically the `Trie` struct in `trie.zig`) is responsible for
//! lifetime management, usually via an arena allocator that owns all trie
//! data for a given transaction or block.

const std = @import("std");

/// Voltaire Hash type for 32-byte cryptographic hashes.
const VHash = @import("primitives").Hash;

/// 32-byte hash type used for node references and root hashes.
pub const Hash32 = VHash.Hash;

/// Number of children in a branch node (one per hex nibble 0x0-0xF).
pub const BRANCH_NODE_LENGTH: usize = 16;

/// A reference to a child node.
///
/// In the Python spec, `encode_internal_node` returns:
/// - `b""` for `None` (empty/absent child)
/// - `keccak256(encoded)` for nodes whose RLP encoding >= 32 bytes
/// - The unencoded form (tuple/list) for nodes whose RLP < 32 bytes
///
/// We represent this as:
/// - `.empty` — absent child (corresponds to `b""` / `None`)
/// - `.hash` — 32-byte keccak256 reference to a persisted node
/// - `.inline_node` — raw RLP bytes of a small inline node (< 32 bytes)
///
/// This mirrors the `EncodedNode` type in `hash.zig` but is designed for
/// use as a stored child reference within trie node structures, whereas
/// `EncodedNode` is used during root hash computation.
pub const ChildRef = union(enum) {
    /// Absent child — no node at this position.
    empty: void,
    /// Hash reference to a child node (keccak256 of its RLP encoding).
    /// Used when the child's RLP encoding is >= 32 bytes.
    hash: Hash32,
    /// Inline RLP encoding of a small child node (< 32 bytes).
    /// The child is embedded directly rather than referenced by hash.
    inline_node: []const u8,

    /// Returns `true` if this reference points to a child (not empty).
    pub fn isPresent(self: ChildRef) bool {
        return self != .empty;
    }

    /// Returns `true` if this is an empty (absent) child reference.
    pub fn isEmpty(self: ChildRef) bool {
        return self == .empty;
    }
};

/// Node type discriminator.
///
/// Matches Nethermind's `NodeType` enum from `NodeType.cs`:
/// ```csharp
/// public enum NodeType : byte { Unknown, Branch, Extension, Leaf }
/// ```
///
/// And the Python spec's `InternalNode = LeafNode | ExtensionNode | BranchNode`.
///
/// `unknown` is included for Nethermind compatibility: persisted nodes whose
/// type hasn't been determined yet (lazy RLP decoding pattern).
pub const NodeType = enum(u8) {
    /// Persisted node, not yet decoded (Nethermind lazy resolution pattern).
    unknown = 0,
    /// Branch node: 16 children (one per nibble) + optional value.
    branch = 1,
    /// Extension node: shared key prefix + single child reference.
    extension = 2,
    /// Leaf node: remaining key path + value.
    leaf = 3,
};

/// Leaf node in the Merkle Patricia Trie.
///
/// Represents a terminal node that stores a value at a specific key path.
/// The `rest_of_key` field contains the remaining nibbles of the key after
/// the path from the root to this node.
///
/// Python spec: `LeafNode(rest_of_key: Bytes, value: Extended)`
/// Nethermind: `LeafData` with `Key` and `Value` properties.
pub const LeafNode = struct {
    /// Remaining nibbles of the key (hex-prefix encoded for RLP).
    /// Each byte is a nibble value 0x0-0xF.
    rest_of_key: []const u8,
    /// The stored value (RLP-encoded account, storage value, etc.).
    value: []const u8,

    /// Returns the node type discriminator.
    pub fn nodeType(_: LeafNode) NodeType {
        return .leaf;
    }
};

/// Extension node in the Merkle Patricia Trie.
///
/// Represents a shared key prefix that leads to a single child node.
/// Used to compress paths where multiple keys share a common prefix,
/// avoiding unnecessary branch nodes.
///
/// Python spec: `ExtensionNode(key_segment: Bytes, subnode: Extended)`
/// Nethermind: `ExtensionData` with `Key` and `Value` (child) properties.
pub const ExtensionNode = struct {
    /// Shared key segment (nibble values 0x0-0xF).
    key_segment: []const u8,
    /// Reference to the single child node.
    child: ChildRef,

    /// Returns the node type discriminator.
    pub fn nodeType(_: ExtensionNode) NodeType {
        return .extension;
    }
};

/// Branch node in the Merkle Patricia Trie.
///
/// Represents a 16-way fork in the trie, with one child slot per hex nibble
/// (0x0 through 0xF) plus an optional value for keys that terminate at this
/// branch point.
///
/// Python spec: `BranchNode(subnodes: Tuple[Extended, ...], value: Extended)`
///   where `subnodes` has exactly 16 elements.
/// Nethermind: `BranchData` with `[InlineArray(16)]` children + value.
pub const BranchNode = struct {
    /// 16 child references, indexed by nibble value (0x0-0xF).
    children: [BRANCH_NODE_LENGTH]ChildRef,
    /// Optional value stored at this branch point.
    /// `null` means no value terminates here (only pass-through).
    value: ?[]const u8,

    /// Create a new empty branch node with no children and no value.
    pub fn empty() BranchNode {
        return .{
            .children = [_]ChildRef{.empty} ** BRANCH_NODE_LENGTH,
            .value = null,
        };
    }

    /// Returns the node type discriminator.
    pub fn nodeType(_: BranchNode) NodeType {
        return .branch;
    }

    /// Returns the number of non-empty children.
    pub fn childCount(self: *const BranchNode) usize {
        var count: usize = 0;
        for (self.children) |child| {
            if (child != .empty) count += 1;
        }
        return count;
    }

    /// Returns the child reference at the given nibble index (0-15).
    pub fn getChild(self: *const BranchNode, nibble: u4) ChildRef {
        return self.children[@as(usize, nibble)];
    }

    /// Sets the child reference at the given nibble index (0-15).
    pub fn setChild(self: *BranchNode, nibble: u4, ref_: ChildRef) void {
        self.children[@as(usize, nibble)] = ref_;
    }
};

/// A trie node — tagged union of all node types.
///
/// Corresponds to Python's `InternalNode = LeafNode | ExtensionNode | BranchNode`
/// and Nethermind's `TrieNode` (which wraps `INodeData`).
///
/// The `.empty` variant represents the absence of a node (Python's `None`),
/// used as the initial state of an empty trie.
pub const Node = union(enum) {
    /// No node (empty trie or absent subtree).
    empty: void,
    /// Leaf node: terminal key-value storage.
    leaf: LeafNode,
    /// Extension node: shared key prefix compression.
    extension: ExtensionNode,
    /// Branch node: 16-way nibble fork.
    branch: BranchNode,

    /// Returns the `NodeType` discriminator for this node.
    pub fn nodeType(self: Node) NodeType {
        return switch (self) {
            .empty => .unknown,
            .leaf => .leaf,
            .extension => .extension,
            .branch => .branch,
        };
    }

    /// Returns `true` if this is an empty (absent) node.
    pub fn isEmpty(self: Node) bool {
        return self == .empty;
    }

    /// Returns `true` if this is a leaf node.
    pub fn isLeaf(self: Node) bool {
        return self == .leaf;
    }

    /// Returns `true` if this is an extension node.
    pub fn isExtension(self: Node) bool {
        return self == .extension;
    }

    /// Returns `true` if this is a branch node.
    pub fn isBranch(self: Node) bool {
        return self == .branch;
    }
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

const testing = std.testing;

test "NodeType enum values match Nethermind ordering" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(NodeType.unknown));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(NodeType.branch));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(NodeType.extension));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(NodeType.leaf));
}

test "LeafNode stores key and value" {
    const leaf = LeafNode{
        .rest_of_key = &[_]u8{ 0x1, 0x2, 0x3 },
        .value = "hello",
    };
    try testing.expectEqualSlices(u8, &[_]u8{ 0x1, 0x2, 0x3 }, leaf.rest_of_key);
    try testing.expectEqualStrings("hello", leaf.value);
    try testing.expectEqual(NodeType.leaf, leaf.nodeType());
}

test "ExtensionNode stores key segment and child ref" {
    const ext = ExtensionNode{
        .key_segment = &[_]u8{ 0xA, 0xB },
        .child = .{ .hash = [_]u8{0x42} ** 32 },
    };
    try testing.expectEqualSlices(u8, &[_]u8{ 0xA, 0xB }, ext.key_segment);
    try testing.expect(ext.child == .hash);
    try testing.expectEqual(NodeType.extension, ext.nodeType());
}

test "ExtensionNode with inline child" {
    const ext = ExtensionNode{
        .key_segment = &[_]u8{0x5},
        .child = .{ .inline_node = &[_]u8{ 0xc0, 0x80 } },
    };
    try testing.expect(ext.child == .inline_node);
    try testing.expectEqualSlices(u8, &[_]u8{ 0xc0, 0x80 }, ext.child.inline_node);
}

test "BranchNode.empty creates node with 16 empty children" {
    const branch = BranchNode.empty();
    try testing.expectEqual(NodeType.branch, branch.nodeType());
    try testing.expectEqual(@as(?[]const u8, null), branch.value);
    try testing.expectEqual(@as(usize, 0), branch.childCount());

    for (branch.children) |child| {
        try testing.expect(child == .empty);
    }
}

test "BranchNode.setChild and getChild" {
    var branch = BranchNode.empty();

    const hash_ref = ChildRef{ .hash = [_]u8{0xFF} ** 32 };
    branch.setChild(0x3, hash_ref);
    branch.setChild(0xA, .{ .inline_node = "test" });

    try testing.expect(branch.getChild(0x3) == .hash);
    try testing.expect(branch.getChild(0xA) == .inline_node);
    try testing.expect(branch.getChild(0x0) == .empty);
    try testing.expectEqual(@as(usize, 2), branch.childCount());
}

test "BranchNode with value" {
    var branch = BranchNode.empty();
    branch.value = "leaf_value";

    try testing.expectEqualStrings("leaf_value", branch.value.?);
}

test "Node tagged union - empty" {
    const node = Node{ .empty = {} };
    try testing.expect(node.isEmpty());
    try testing.expect(!node.isLeaf());
    try testing.expect(!node.isExtension());
    try testing.expect(!node.isBranch());
    try testing.expectEqual(NodeType.unknown, node.nodeType());
}

test "Node tagged union - leaf" {
    const node = Node{ .leaf = .{
        .rest_of_key = &[_]u8{ 0x1, 0x2 },
        .value = "val",
    } };
    try testing.expect(node.isLeaf());
    try testing.expect(!node.isEmpty());
    try testing.expectEqual(NodeType.leaf, node.nodeType());
}

test "Node tagged union - extension" {
    const node = Node{ .extension = .{
        .key_segment = &[_]u8{0x5},
        .child = .empty,
    } };
    try testing.expect(node.isExtension());
    try testing.expectEqual(NodeType.extension, node.nodeType());
}

test "Node tagged union - branch" {
    const node = Node{ .branch = BranchNode.empty() };
    try testing.expect(node.isBranch());
    try testing.expectEqual(NodeType.branch, node.nodeType());
}

test "ChildRef.isPresent and isEmpty" {
    const empty_ref = ChildRef{ .empty = {} };
    try testing.expect(empty_ref.isEmpty());
    try testing.expect(!empty_ref.isPresent());

    const hash_ref = ChildRef{ .hash = [_]u8{0x00} ** 32 };
    try testing.expect(hash_ref.isPresent());
    try testing.expect(!hash_ref.isEmpty());

    const inline_ref = ChildRef{ .inline_node = "data" };
    try testing.expect(inline_ref.isPresent());
    try testing.expect(!inline_ref.isEmpty());
}

test "BRANCH_NODE_LENGTH is 16" {
    try testing.expectEqual(@as(usize, 16), BRANCH_NODE_LENGTH);
}

test "BranchNode children array has correct length" {
    const branch = BranchNode.empty();
    try testing.expectEqual(@as(usize, 16), branch.children.len);
}

test "LeafNode with empty key (branch-value leaf)" {
    // A leaf at a branch point has an empty rest_of_key
    const leaf = LeafNode{
        .rest_of_key = &[_]u8{},
        .value = "branch_value",
    };
    try testing.expectEqual(@as(usize, 0), leaf.rest_of_key.len);
    try testing.expectEqualStrings("branch_value", leaf.value);
}
