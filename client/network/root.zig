/// devp2p networking surface for the Guillotine execution client.
const std = @import("std");

const rlpx = @import("rlpx/root.zig");

/// RLPx handshake role (initiator/recipient).
pub const HandshakeRole = rlpx.HandshakeRole;

test {
    std.testing.refAllDecls(@This());
}
