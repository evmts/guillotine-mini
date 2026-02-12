/// Synchronization module entry point (phase-9-sync).
const full = @import("full.zig");
const manager = @import("mode.zig");
const headers = @import("headers.zig");

// -- Public API --------------------------------------------------------------

/// Full sync block/receipt request container.
pub const BlocksRequest = full.BlocksRequest;
/// Full sync per-peer body request limit.
pub const max_bodies_per_request = full.max_bodies_per_request;
/// Full sync per-peer receipt request limit.
pub const max_receipts_per_request = full.max_receipts_per_request;
/// Full sync per-peer header request limit.
pub const max_headers_per_request = full.max_headers_per_request;

/// Sync mode bit flags (Nethermind-compatible shape).
pub const SyncMode = manager.SyncMode;

/// GetBlockHeaders request helper.
pub const HeadersRequest = headers.HeadersRequest;
/// GetBlockHeaders origin discriminator.
pub const HeadersOrigin = headers.Origin;

test {
    @import("std").testing.refAllDecls(@This());
}
