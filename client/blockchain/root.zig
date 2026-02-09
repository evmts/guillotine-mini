/// Chain management entry point for the client.
const chain = @import("chain.zig");

// -- Public API --------------------------------------------------------------

/// Chain management API rooted in Voltaire's `Blockchain` primitive.
pub const Chain = chain.Chain;

test {
    @import("std").testing.refAllDecls(@This());
}
