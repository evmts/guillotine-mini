//! Merkle Patricia Trie module for the Guillotine execution client.
//!
//! Implements the Modified Merkle Patricia Trie (MPT) for Ethereum state
//! storage, matching the authoritative Python execution-specs behavior.
//!
//! ## Modules
//!
//! - `hash` — Root hash computation via `patricialize()` algorithm
//! - `node` — Trie node types (Leaf, Extension, Branch, Node union)
//! - `trie` — Trie API re-export (Voltaire primitive)
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
//! // Compute root hash from key-value pairs.
//! // NOTE: keys must already be keccak256-prehashed for secure tries,
//! // and values must be RLP-encoded (e.g. transactions, receipts, accounts).
//! const root = try trie.trie_root(allocator, &keys, &values);
//! ```

/// Hashing and patricialize implementation details.
pub const hash = @import("hash.zig");
/// Voltaire trie node types re-export module.
pub const node = @import("node.zig");
/// Voltaire trie implementation re-export module.
pub const trie = @import("trie.zig");

// Re-export primary API
/// Compute the Merkle Patricia Trie root hash for key-value pairs.
pub const trie_root = hash.trie_root;
/// Root hash for an empty trie (keccak256(RLP(""))).
pub const EMPTY_TRIE_ROOT = hash.EMPTY_TRIE_ROOT;
/// 32-byte hash type used for root hashes.
pub const Hash32 = node.Hash32;
/// Branch child mask helper.
pub const TrieMask = node.TrieMask;
/// Trie node type discriminator.
pub const NodeType = node.NodeType;
/// Trie node union.
pub const Node = node.Node;
/// Trie leaf node.
pub const LeafNode = node.LeafNode;
/// Trie extension node.
pub const ExtensionNode = node.ExtensionNode;
/// Trie branch node.
pub const BranchNode = node.BranchNode;
/// Trie implementation (Voltaire primitive).
pub const Trie = trie.Trie;

test {
    // Ensure all sub-modules compile and their tests run.
    @import("std").testing.refAllDecls(@This());
}

test "client_trie public API smoke" {
    const std = @import("std");
    const testing = std.testing;

    var trie_instance = Trie.init(testing.allocator);
    defer trie_instance.deinit();
    try testing.expect(trie_instance.root_hash() == null);

    const empty_keys: [0][]const u8 = .{};
    const empty_values: [0][]const u8 = .{};
    const root = try trie_root(testing.allocator, &empty_keys, &empty_values);
    try testing.expectEqual(EMPTY_TRIE_ROOT, root);
}
