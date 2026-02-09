//! Voltaire trie primitives re-exports used by the client trie module.
//!
//! This module intentionally avoids defining custom trie node types and
//! re-exports the canonical Voltaire primitives instead.

const primitives = @import("primitives");
const trie_primitives = @import("primitives_trie");

/// 32-byte hash type used for node references and root hashes.
pub const Hash32 = primitives.Hash.Hash;

/// Voltaire's Merkle Patricia Trie implementation.
pub const Trie = primitives.Trie;

/// Trie node types (Voltaire primitives).
pub const TrieMask = trie_primitives.TrieMask;
pub const NodeType = trie_primitives.NodeType;
pub const Node = trie_primitives.Node;
pub const LeafNode = trie_primitives.LeafNode;
pub const ExtensionNode = trie_primitives.ExtensionNode;
pub const BranchNode = trie_primitives.BranchNode;

test {
    @import("std").testing.refAllDecls(@This());
}
