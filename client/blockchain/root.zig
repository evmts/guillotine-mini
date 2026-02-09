/// Chain management entry point for the client.
const chain = @import("chain.zig");
const validator = @import("validator.zig");

// -- Public API --------------------------------------------------------------

/// Chain management API rooted in Voltaire's `Blockchain` primitive.
pub const Chain = chain.Chain;
/// Validate PoS header constants (difficulty/nonce/ommers hash).
pub const validatePosHeaderConstants = validator.validatePosHeaderConstants;
/// Shared header validation errors.
pub const ValidationError = validator.ValidationError;
/// Merge-aware header validator.
pub const MergeHeaderValidator = validator.MergeHeaderValidator;

test {
    @import("std").testing.refAllDecls(@This());
}
