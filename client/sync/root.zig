/// Synchronization module entry point (phase-9-sync).
const full = @import("full.zig");

// -- Public API --------------------------------------------------------------

/// Full sync block/receipt request container.
pub const BlocksRequest = full.BlocksRequest;

test {
    @import("std").testing.refAllDecls(@This());
}
