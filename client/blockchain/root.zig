/// Chain management entry point for the client.
const chain = @import("chain.zig");
const validator = @import("validator.zig");

// -- Public API --------------------------------------------------------------

/// Chain management API rooted in Voltaire's `Blockchain` primitive.
///
/// All public aliases exposed here intentionally re-export Voltaire primitives
/// or thin helpers around them; no custom types are introduced at this layer.
pub const Chain = chain.Chain;
/// Canonical head helpers.
pub const head_hash = chain.head_hash;
pub const head_block = chain.head_block;
/// Canonicality checks.
pub const is_canonical = chain.is_canonical;
pub const is_canonical_or_fetch = chain.is_canonical_or_fetch;
/// Generic comptime DI helpers for head reads.
pub const head_hash_of = chain.head_hash_of;
pub const head_block_of = chain.head_block_of;
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
