//! Trie node types re-exported from Voltaire primitives.
//!
//! This module intentionally does not define custom trie node types.
//! Use Voltaire's implementation directly to ensure consistency across
//! the client.

const primitives = @import("primitives");
const trie = @import("primitives/trie.zig");

/// 32-byte hash type used for node references and root hashes.
pub const Hash32 = primitives.Hash.Hash;

/// 16-bit child mask for branch nodes.
pub const TrieMask = trie.TrieMask;

/// Node type discriminator.
pub const NodeType = trie.NodeType;

/// Trie node union.
pub const Node = trie.Node;

/// Leaf node type.
pub const LeafNode = trie.LeafNode;

/// Extension node type.
pub const ExtensionNode = trie.ExtensionNode;

/// Branch node type.
pub const BranchNode = trie.BranchNode;

test {
    @import("std").testing.refAllDecls(@This());
}
