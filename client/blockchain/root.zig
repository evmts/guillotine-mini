/// Chain management entry point for the client.
const chain = @import("chain.zig");

// -- Public API --------------------------------------------------------------

pub const Chain = chain.Chain;

test {
    @import("std").testing.refAllDecls(@This());
}
