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
//! const trie = @import("client_trie");
//!
//! // Compute root hash from key-value pairs
//! const root = try trie.trie_root(allocator, &keys, &values);
//! ```

/// Hashing and patricialize implementation details.
pub const hash = @import("hash.zig");
/// Voltaire trie node types re-export module.
pub const node = @import("node.zig");

// Re-export primary API
/// Compute the Merkle Patricia Trie root hash for key-value pairs.
pub const trie_root = hash.trie_root;
/// Root hash for an empty trie (keccak256(RLP(""))).
pub const EMPTY_TRIE_ROOT = hash.EMPTY_TRIE_ROOT;
/// 32-byte hash type used for root hashes.
pub const Hash32 = node.Hash32;

test {
    // Ensure all sub-modules compile and their tests run.
    @import("std").testing.refAllDecls(@This());
}
