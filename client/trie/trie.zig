//! Trie implementation re-exported from Voltaire primitives.
//!
//! This module intentionally does not define custom trie types. Use the
//! Voltaire implementation directly to stay aligned with shared primitives.

const primitives = @import("primitives");

/// Merkle Patricia Trie implementation (Voltaire primitive).
pub const Trie = primitives.Trie;

test {
    @import("std").testing.refAllDecls(@This());
}
