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
/// - `.inline_node` — **verbatim** RLP bytes of a small inline node (< 32 bytes)
///
/// This mirrors the `EncodedNode` type in `hash.zig` but is designed for
/// use as a stored child reference within trie node structures, whereas
/// `EncodedNode` is used during root hash computation.
///
/// ## Verbatim Embedding Invariant
///
/// The `.inline_node` variant stores **already-RLP-encoded** bytes that MUST
/// be embedded verbatim (without further encoding) when this child reference
/// is serialized into a parent node's RLP list. The bytes must be a valid
/// RLP list (starting with 0xc0..0xf7 for short lists, or 0xf8..0xff for
/// long lists). This matches the Python spec's behavior where
/// `encode_internal_node` returns the *unencoded* form (a tuple/list), and
/// the parent's `rlp.encode()` embeds it as a nested structure — NOT as a
/// byte string. In our Zig representation, we pre-encode to RLP and tag as
/// `.verbatim` / `.inline_node` so encoders embed without re-wrapping.
///
/// Use `createInlineNode()` to construct inline nodes with validation.
/// Direct construction is allowed but callers MUST ensure the bytes are
/// valid verbatim RLP (a complete RLP list encoding, not a bare byte string).
pub const ChildRef = union(enum) {
    /// Absent child — no node at this position.
    empty: void,
    /// Hash reference to a child node (keccak256 of its RLP encoding).
    /// Used when the child's RLP encoding is >= 32 bytes.
    hash: Hash32,
    /// Verbatim RLP encoding of a small child node (< 32 bytes).
    /// The child is embedded directly rather than referenced by hash.
    ///
    /// INVARIANT: These bytes are already a complete RLP encoding and
    /// MUST be embedded verbatim (not re-encoded as a string) when
    /// serialized into a parent node. The first byte must indicate an
    /// RLP list (>= 0xc0) since trie nodes are always RLP lists.
    inline_node: []const u8,

    /// Create an inline node reference with validation.
    ///
    /// Verifies the verbatim embedding invariant: the bytes must be a
    /// valid RLP list (first byte >= 0xc0) and less than 32 bytes.
    /// Returns `error.InvalidInlineNode` if the bytes don't look like
    /// a valid RLP list encoding for a trie node.
    pub fn createInlineNode(rlp_bytes: []const u8) error{InvalidInlineNode}!ChildRef {
        if (rlp_bytes.len == 0 or rlp_bytes.len >= 32) {
            return error.InvalidInlineNode;
        }
        // Trie nodes are always RLP lists; first byte must be >= 0xc0
        if (rlp_bytes[0] < 0xc0) {
            return error.InvalidInlineNode;
        }
        return .{ .inline_node = rlp_bytes };
    }

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
/// `unknown` is reserved for Nethermind compatibility: persisted nodes whose
/// type hasn't been determined yet (lazy RLP decoding pattern). It is NOT
/// used for empty/absent nodes — those are represented by `Node.empty` and
/// report `NodeType.empty`.
pub const NodeType = enum(u8) {
    /// Persisted node, not yet decoded (Nethermind lazy resolution pattern).
    /// This value is ONLY for lazy-decoded DB nodes. For absent/empty nodes
    /// use `.empty` instead.
    unknown = 0,
    /// Branch node: 16 children (one per nibble) + value.
    branch = 1,
    /// Extension node: shared key prefix + single child reference.
    extension = 2,
    /// Leaf node: remaining key path + value.
    leaf = 3,
    /// Empty/absent node — no node at this position (Python spec's `None`).
    /// Distinct from `unknown` which represents a persisted but not-yet-decoded node.
    empty = 4,
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
    /// Remaining nibbles of the key path, stored as a **nibble list** (NOT
    /// hex-prefix encoded). Each byte is a single nibble value in 0x0-0xF.
    ///
    /// Hex-prefix (compact) encoding is applied only at RLP serialization
    /// time by `nibbleListToCompact()` in `hash.zig`, matching the Python
    /// spec's `nibble_list_to_compact(node.rest_of_key, True)` call inside
    /// `encode_internal_node()`. Storing nibbles here (not compact form)
    /// avoids double-encoding when the node is serialized.
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
    /// Shared key segment stored as a **nibble list** (NOT hex-prefix
    /// encoded). Each byte is a single nibble value in 0x0-0xF.
    ///
    /// Hex-prefix (compact) encoding is applied only at RLP serialization
    /// time by `nibbleListToCompact()` in `hash.zig`, matching the Python
    /// spec's `nibble_list_to_compact(node.key_segment, False)` call inside
    /// `encode_internal_node()`.
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
/// (0x0 through 0xF) plus a value for keys that terminate at this branch
/// point.
///
/// Python spec: `BranchNode(subnodes: Tuple[Extended, ...], value: Extended)`
///   where `subnodes` has exactly 16 elements and `value` defaults to `b""`.
/// Nethermind: `BranchData` with `[InlineArray(16)]` children + value.
pub const BranchNode = struct {
    /// 16 child references, indexed by nibble value (0x0-0xF).
    children: [BRANCH_NODE_LENGTH]ChildRef,
    /// Value stored at this branch point.
    /// Empty slice (`""`) means no value terminates here (only pass-through),
    /// matching the Python spec's `value = b""` sentinel. The spec uses
    /// empty bytes — not None/null — as the "no value" indicator, ensuring
    /// consistent RLP encoding (empty string encodes as 0x80).
    value: []const u8,

    /// Create a new empty branch node with no children and no value.
    pub fn empty() BranchNode {
        return .{
            .children = [_]ChildRef{.empty} ** BRANCH_NODE_LENGTH,
            .value = &[_]u8{},
        };
    }

    /// Returns `true` if this branch has a value (non-empty).
    pub fn hasValue(self: *const BranchNode) bool {
        return self.value.len > 0;
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
    ///
    /// Empty nodes return `.empty`, NOT `.unknown`. The `.unknown` variant
    /// is reserved for lazily-decoded persisted nodes (Nethermind pattern),
    /// which are a different concept from absent/empty subtrees.
    pub fn nodeType(self: Node) NodeType {
        return switch (self) {
            .empty => .empty,
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
    // .empty is distinct from .unknown (absent vs lazy-decoded)
    try testing.expectEqual(@as(u8, 4), @intFromEnum(NodeType.empty));
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
    // Use createInlineNode to enforce verbatim embedding invariant
    const inline_rlp = &[_]u8{ 0xc2, 0x80, 0x80 }; // valid RLP list
    const ext = ExtensionNode{
        .key_segment = &[_]u8{0x5},
        .child = try ChildRef.createInlineNode(inline_rlp),
    };
    try testing.expect(ext.child == .inline_node);
    try testing.expectEqualSlices(u8, inline_rlp, ext.child.inline_node);
}

test "BranchNode.empty creates node with 16 empty children" {
    const branch = BranchNode.empty();
    try testing.expectEqual(NodeType.branch, branch.nodeType());
    // Spec uses empty bytes b"" as the "no value" sentinel, not null
    try testing.expectEqual(@as(usize, 0), branch.value.len);
    try testing.expect(!branch.hasValue());
    try testing.expectEqual(@as(usize, 0), branch.childCount());

    for (branch.children) |child| {
        try testing.expect(child == .empty);
    }
}

test "BranchNode.setChild and getChild" {
    var branch = BranchNode.empty();

    const hash_ref = ChildRef{ .hash = [_]u8{0xFF} ** 32 };
    branch.setChild(0x3, hash_ref);
    // Use createInlineNode with valid RLP list bytes
    branch.setChild(0xA, try ChildRef.createInlineNode(&[_]u8{ 0xc4, 0x83, 0x01, 0x02, 0x03 }));

    try testing.expect(branch.getChild(0x3) == .hash);
    try testing.expect(branch.getChild(0xA) == .inline_node);
    try testing.expect(branch.getChild(0x0) == .empty);
    try testing.expectEqual(@as(usize, 2), branch.childCount());
}

test "BranchNode with value" {
    var branch = BranchNode.empty();
    branch.value = "leaf_value";

    try testing.expectEqualStrings("leaf_value", branch.value);
    try testing.expect(branch.hasValue());
}

test "Node tagged union - empty" {
    const node = Node{ .empty = {} };
    try testing.expect(node.isEmpty());
    try testing.expect(!node.isLeaf());
    try testing.expect(!node.isExtension());
    try testing.expect(!node.isBranch());
    // Empty nodes return .empty, NOT .unknown (which is for lazy-decoded DB nodes)
    try testing.expectEqual(NodeType.empty, node.nodeType());
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

    // Use createInlineNode with valid RLP list bytes
    const inline_ref = try ChildRef.createInlineNode(&[_]u8{ 0xc1, 0x80 });
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

test "ChildRef.createInlineNode rejects non-RLP-list bytes" {
    // String-encoded bytes (first byte < 0xc0) must be rejected
    try testing.expectError(error.InvalidInlineNode, ChildRef.createInlineNode(&[_]u8{ 0x80, 0x01 }));
    // Empty bytes must be rejected
    try testing.expectError(error.InvalidInlineNode, ChildRef.createInlineNode(&[_]u8{}));
    // Bytes >= 32 must be rejected (too large to inline)
    const large = &[_]u8{0xc0} ++ &[_]u8{0x80} ** 31;
    try testing.expectError(error.InvalidInlineNode, ChildRef.createInlineNode(large));
}

test "ChildRef.createInlineNode accepts valid RLP list" {
    // Minimal valid RLP list: 0xc0 = empty list
    const ref1 = try ChildRef.createInlineNode(&[_]u8{0xc0});
    try testing.expect(ref1 == .inline_node);
    // Short list with payload
    const ref2 = try ChildRef.createInlineNode(&[_]u8{ 0xc2, 0x80, 0x80 });
    try testing.expect(ref2 == .inline_node);
}
