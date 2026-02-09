const std = @import("std");

/// Role for the RLPx handshake (initiator vs recipient).
/// Mirrors Nethermind's `HandshakeRole`.
pub const HandshakeRole = enum {
    initiator,
    recipient,
};

test {
    std.testing.refAllDecls(@This());
}
