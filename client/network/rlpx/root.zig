const frame = @import("frame.zig");
const handshake_role = @import("handshake_role.zig");
const snappy_parameters = @import("snappy_parameters.zig");
const secrets_mod = @import("secrets.zig");
const mac_mod = @import("mac.zig");

/// RLPx handshake role (initiator/recipient).
pub const HandshakeRole = handshake_role.HandshakeRole;
/// Snappy framing limits for RLPx compressed payloads.
pub const SnappyParameters = snappy_parameters.SnappyParameters;
/// RLPx frame constants and padding helper.
pub const Frame = frame;
/// RLPx secrets derivation (shared/aes/mac) per spec.
pub const Secrets = secrets_mod.Secrets;
pub const deriveSecrets = secrets_mod.deriveSecrets;

/// RLPx MAC state initialization (ingress/egress Keccak256 contexts).
pub const MacStates = mac_mod.MacStates;
pub const initMacStates = mac_mod.initMacStates;
test {
    @import("std").testing.refAllDecls(@This());
}
