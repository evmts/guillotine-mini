const std = @import("std");
// Voltaire primitives currently don't export HandshakeRole. Define a minimal
// local enum aligned with Nethermind for now. Replace with primitives when available.

/// Role for the RLPx handshake (initiator vs recipient).
/// Mirrors Nethermind's `HandshakeRole`.
pub const HandshakeRole = enum(u8) { initiator = 0, recipient = 1 };

test {
    std.testing.refAllDecls(@This());
}
