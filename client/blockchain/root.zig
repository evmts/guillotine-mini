/// Chain management entry point for the client.
const chain = @import("chain.zig");
const validator = @import("validator.zig");
const blockchain = @import("blockchain");

// -- Public API --------------------------------------------------------------

/// Chain management API rooted in Voltaire's `Blockchain` primitive.
///
/// All public aliases exposed here intentionally re-export Voltaire primitives
/// or thin helpers around them; no custom types are introduced at this layer.
pub const Chain = chain.Chain;
/// Direct re-exports for consumers needing raw Voltaire types.
pub const Blockchain = blockchain.Blockchain;
pub const ForkBlockCache = blockchain.ForkBlockCache;
/// Canonical head helpers.
pub const head_hash = chain.head_hash;
pub const head_block = chain.head_block;
pub const head_number = chain.head_number;
/// Canonicality checks.
pub const is_canonical = chain.is_canonical;
pub const is_canonical_or_fetch = chain.is_canonical_or_fetch;
/// Existence check (local or fork-cache).
pub const has_block = chain.has_block;
/// Local-only block lookup (no fork-cache fetch/allocations).
pub const get_block_local = chain.get_block_local;
/// Local-only canonical block lookup by number (no fork-cache fetch/allocations).
pub const get_block_by_number_local = chain.get_block_by_number_local;
/// Canonical hash lookup by number (local-only read).
pub const canonical_hash = chain.canonical_hash;
/// Generic comptime DI helpers for head reads.
pub const head_hash_of = chain.head_hash_of;
pub const head_block_of = chain.head_block_of;
pub const head_number_of = chain.head_number_of;
/// Safe/finalized head helpers (local-only).
pub const safe_head_hash_of = chain.safe_head_hash_of;
pub const finalized_head_hash_of = chain.finalized_head_hash_of;
pub const safe_head_block_of = chain.safe_head_block_of;
pub const finalized_head_block_of = chain.finalized_head_block_of;
/// Shared header validation errors.
pub const ValidationError = validator.ValidationError;
/// Header validation context.
pub const HeaderValidationContext = validator.HeaderValidationContext;
/// Merge-aware header validator.
pub const merge_header_validator = validator.merge_header_validator;

test {
    @import("std").testing.refAllDecls(@This());
}
