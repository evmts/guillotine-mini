const frame = @import("frame.zig");
const handshake_role = @import("handshake_role.zig");
const snappy_parameters = @import("snappy_parameters.zig");

/// RLPx handshake role (initiator/recipient).
pub const HandshakeRole = handshake_role.HandshakeRole;
/// Snappy framing limits for RLPx compressed payloads.
pub const SnappyParameters = snappy_parameters.SnappyParameters;
/// RLPx frame constants and padding helper.
pub const Frame = frame;

test {
    @import("std").testing.refAllDecls(@This());
}
