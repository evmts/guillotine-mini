const std = @import("std");
const primitives = @import("primitives");

/// Role for the RLPx handshake (initiator vs recipient).
/// Mirrors Nethermind's `HandshakeRole`.
pub const HandshakeRole = primitives.HandshakeRole;

test {
    std.testing.refAllDecls(@This());
}
