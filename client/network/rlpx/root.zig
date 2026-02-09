const handshake_role = @import("handshake_role.zig");

/// RLPx handshake role (initiator/recipient).
pub const HandshakeRole = handshake_role.HandshakeRole;

test {
    @import("std").testing.refAllDecls(@This());
}
