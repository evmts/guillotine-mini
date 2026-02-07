//! Merkle Patricia Trie module for the Guillotine execution client.
//!
//! Implements the Modified Merkle Patricia Trie (MPT) for Ethereum state
//! storage, matching the authoritative Python execution-specs behavior.
//!
//! ## Modules
//!
//! - `hash` — Root hash computation via `patricialize()` algorithm
//! - `node` — Trie node types (Leaf, Extension, Branch, Node union)
//!
//! ## Architecture
//!
//! The trie module implements the spec's `patricialize()` approach: given a
//! flat key-value mapping, it recursively builds the MPT and computes the
//! root hash. This matches `execution-specs/src/ethereum/forks/frontier/trie.py`
//! exactly, including the < 32-byte node inlining rule.
//!
//! Voltaire primitives are used for:
//! - RLP encoding (`primitives.Rlp`)
//! - Keccak256 hashing (`crypto.keccak256`)
//!
//! ## Usage
//!
//! ```zig
//! const trie = @import("client/trie/root.zig");
//!
//! // Compute root hash from key-value pairs
//! const root = try trie.trieRoot(allocator, &keys, &values);
//! ```

pub const hash = @import("hash.zig");
pub const node = @import("node.zig");

// Re-export primary API
pub const trieRoot = hash.trieRoot;
pub const EMPTY_TRIE_ROOT = hash.EMPTY_TRIE_ROOT;

// Re-export node types
pub const Node = node.Node;
pub const NodeType = node.NodeType;
pub const LeafNode = node.LeafNode;
pub const ExtensionNode = node.ExtensionNode;
pub const BranchNode = node.BranchNode;
pub const ChildRef = node.ChildRef;

test {
    // Ensure all sub-modules compile and their tests run.
    @import("std").testing.refAllDecls(@This());
}
