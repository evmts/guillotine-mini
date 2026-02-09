//! Voltaire trie primitives re-exports used by the client trie module.
//!
//! This module intentionally avoids defining custom trie node types.
//! The Voltaire Zig root module currently exposes the `Trie` type but
//! not individual node structs; we re-export what is available.

const primitives = @import("primitives");

/// 32-byte hash type used for node references and root hashes.
pub const Hash32 = primitives.Hash.Hash;

/// Voltaire's Merkle Patricia Trie implementation.
pub const Trie = primitives.Trie;

test {
    @import("std").testing.refAllDecls(@This());
}
