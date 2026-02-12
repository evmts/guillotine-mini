/// devp2p networking surface for the Guillotine execution client.
const std = @import("std");

const rlpx = @import("rlpx/root.zig");

/// Snappy framing limits for RLPx compressed payloads.
pub const SnappyParameters = rlpx.SnappyParameters;
/// RLPx frame constants and padding helper.
pub const Frame = rlpx.Frame;

test {
    std.testing.refAllDecls(@This());
}
