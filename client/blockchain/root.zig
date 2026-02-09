/// Chain management entry point for the client.
const chain = @import("chain.zig");
const validator = @import("validator.zig");

// -- Public API --------------------------------------------------------------

/// Chain management API rooted in Voltaire's `Blockchain` primitive.
pub const Chain = chain.Chain;
/// Shared header validation errors.
pub const ValidationError = validator.ValidationError;
/// Merge-aware header validator.
pub const merge_header_validator = validator.merge_header_validator;

test {
    @import("std").testing.refAllDecls(@This());
}
