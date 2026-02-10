/// Synchronization module entry point (phase-9-sync).
const full = @import("full.zig");

// -- Public API --------------------------------------------------------------

/// Full sync block/receipt request container.
pub const BlocksRequest = full.BlocksRequest;
/// Full sync per-peer body request limit.
pub const maxBodiesPerRequest = full.maxBodiesPerRequest;
/// Full sync per-peer receipt request limit.
pub const maxReceiptsPerRequest = full.maxReceiptsPerRequest;

test {
    @import("std").testing.refAllDecls(@This());
}
