//! Engine API module for consensus-layer interaction.
const api = @import("api.zig");

/// Engine API error codes (execution-apis common definitions).
pub const EngineApiErrorCode = api.EngineApiErrorCode;

test {
    @import("std").testing.refAllDecls(@This());
}
