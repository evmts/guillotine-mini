/// Chain management entry point for the client.
const chain = @import("chain.zig");
const validator = @import("validator.zig");

// -- Public API --------------------------------------------------------------

/// Chain management API rooted in Voltaire's `Blockchain` primitive.
pub const Chain = chain.Chain;
/// Header validation interface for block chain management.
pub const HeaderValidator = validator.HeaderValidator;

test {
    @import("std").testing.refAllDecls(@This());
}
