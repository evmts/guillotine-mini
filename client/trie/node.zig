//! Trie node types re-exported from Voltaire primitives.
//!
//! This module intentionally does not define custom trie node types.
//! Use Voltaire's implementation directly to ensure consistency across
//! the client.

const primitives = @import("primitives");

/// 32-byte hash type used for node references and root hashes.
pub const Hash32 = primitives.Hash.Hash;

/// 16-bit child mask for branch nodes.
pub const TrieMask = primitives.TrieMask;

/// Node type discriminator.
pub const NodeType = primitives.TrieNodeType;

/// Trie node union.
pub const Node = primitives.TrieNode;

/// Leaf node type.
pub const LeafNode = primitives.TrieLeafNode;

/// Extension node type.
pub const ExtensionNode = primitives.TrieExtensionNode;

/// Branch node type.
pub const BranchNode = primitives.TrieBranchNode;

test {
    @import("std").testing.refAllDecls(@This());
}
