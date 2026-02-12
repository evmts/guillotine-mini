//! Voltaire trie-related primitives used by the client trie module.
//!
//! Keep this surface minimal for phase-1 (root hash only) to avoid pulling in
//! upstream trie internals during compilation.

const primitives = @import("primitives");

/// 32-byte hash type used for node references and root hashes.
pub const Hash32 = primitives.Hash.Hash;

// Intentionally do not re-export the full Trie or node types here to avoid
// compiling upstream internals in this phase. Root-hash functions live in
// `client/trie/hash.zig` and rely only on hashing and RLP primitives.

test {
    @import("std").testing.refAllDecls(@This());
}
