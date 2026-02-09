//! Voltaire trie primitives re-exports used by the client trie module.
//!
//! This module intentionally avoids defining custom trie node types and
//! re-exports the canonical Voltaire primitives instead.

const primitives = @import("primitives");

/// 32-byte hash type used for node references and root hashes.
pub const Hash32 = primitives.Hash.Hash;

/// Voltaire's Merkle Patricia Trie implementation.
pub const Trie = primitives.Trie;

/// Trie node types (Voltaire primitives).
pub const TrieMask = primitives.TrieMask;
pub const NodeType = primitives.NodeType;
pub const Node = primitives.Node;
pub const LeafNode = primitives.LeafNode;
pub const ExtensionNode = primitives.ExtensionNode;
pub const BranchNode = primitives.BranchNode;

test {
    @import("std").testing.refAllDecls(@This());
}
