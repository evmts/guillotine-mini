/// Engine API module for consensus layer communication.
const std = @import("std");

const api = @import("api.zig");

/// Re-exported Engine API interface.
pub const EngineApi = api.EngineApi;

test {
    std.testing.refAllDecls(@This());
}
