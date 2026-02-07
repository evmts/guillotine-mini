//! Merkle Patricia Trie module for the Guillotine execution client.
//!
//! Implements the Modified Merkle Patricia Trie (MPT) for Ethereum state
//! storage, matching the authoritative Python execution-specs behavior.
//!
//! ## Modules
//!
//! - `hash` — Root hash computation via `patricialize()` algorithm
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

// Re-export primary API
pub const trieRoot = hash.trieRoot;
pub const EMPTY_TRIE_ROOT = hash.EMPTY_TRIE_ROOT;

test {
    // Ensure all sub-modules compile and their tests run.
    @import("std").testing.refAllDecls(@This());
}
