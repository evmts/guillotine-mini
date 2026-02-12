//! RLPx MAC State Initialization
const std = @import("std");
const primitives = @import("primitives");
const crypto = @import("crypto");
const Bytes32 = primitives.Bytes32.Bytes32;

/// Generic pair of MAC/hash states for authenticated framing.
pub fn MacStatesFor(comptime Hasher: type) type {
    return struct { ingress: Hasher, egress: Hasher };
}

/// Default MAC states use Keccak256 as per RLPx.
pub const MacStates = MacStatesFor(crypto.Keccak256);
pub const MacSeedError = error{ InvalidAuthPrefix, InvalidAckPrefix, InvalidAuthSize, InvalidAckSize };

/// Generic initializer with DI for MAC/hash selection.
pub fn initMacStatesFor(
    comptime Hasher: type,
    mac_secret: Bytes32,
    initiator_nonce: Bytes32,
    recipient_nonce: Bytes32,
    auth: []const u8,
    ack: []const u8,
    is_initiator: bool,
) MacSeedError!MacStatesFor(Hasher) {
    if (auth.len < 2) return error.InvalidAuthPrefix;
    if (ack.len < 2) return error.InvalidAckPrefix;
    const auth_size: u16 = (@as(u16, auth[0]) << 8) | auth[1];
    const ack_size: u16 = (@as(u16, ack[0]) << 8) | ack[1];
    if (auth.len != 2 + auth_size) return error.InvalidAuthSize;
    if (ack.len != 2 + ack_size) return error.InvalidAckSize;
    var ingress = Hasher.init(.{});
    // Precompute XOR(mac-secret, initiator-nonce) and XOR(mac-secret, recipient-nonce)
    var mac_xor_initiator: Bytes32 = undefined;
    var mac_xor_recipient: Bytes32 = undefined;
    inline for (0..32) |i| {
        mac_xor_initiator[i] = mac_secret[i] ^ initiator_nonce[i];
        mac_xor_recipient[i] = mac_secret[i] ^ recipient_nonce[i];
    }
    var egress = Hasher.init(.{});
    if (is_initiator) {
        // egress: (mac ^ recipient_nonce) || auth
        egress.update(&mac_xor_recipient);
        egress.update(auth);
        // ingress: (mac ^ initiator_nonce) || ack
        ingress.update(&mac_xor_initiator);
        ingress.update(ack);
    } else {
        // egress: (mac ^ initiator_nonce) || ack
        egress.update(&mac_xor_initiator);
        egress.update(ack);
        // ingress: (mac ^ recipient_nonce) || auth
        ingress.update(&mac_xor_recipient);
        ingress.update(auth);
    }

    return .{ .ingress = ingress, .egress = egress };
}

/// Default initializer using Keccak256 per RLPx spec.
pub fn initMacStates(
    mac_secret: Bytes32,
    initiator_nonce: Bytes32,
    recipient_nonce: Bytes32,
    auth: []const u8,
    ack: []const u8,
    is_initiator: bool,
) MacSeedError!MacStates {
    return initMacStatesFor(crypto.Keccak256, mac_secret, initiator_nonce, recipient_nonce, auth, ack, is_initiator);
}

test "initMacStates: initiator vs recipient seeding per spec" {
    const zero: Bytes32 = [_]u8{0} ** 32;

    // Deterministic, easy-to-verify test vectors
    var mac: Bytes32 = zero;
    @memset(&mac, 0xaa);
    var n_i: Bytes32 = zero;
    @memset(&n_i, 0x11);
    var n_r: Bytes32 = zero;
    @memset(&n_r, 0x22);
    const auth_body = [_]u8{'A'};
    const ack_body = [_]u8{'B'};
    const auth = [_]u8{ 0x00, auth_body.len } ++ auth_body;
    const ack = [_]u8{ 0x00, ack_body.len } ++ ack_body;

    // Expected digests for initiator role
    var x_i: Bytes32 = undefined; // mac ^ initiator
    var x_r: Bytes32 = undefined; // mac ^ recipient
    inline for (0..32) |i| {
        x_i[i] = mac[i] ^ n_i[i];
        x_r[i] = mac[i] ^ n_r[i];
    }

    // Compute reference digests using fresh Keccak contexts
    var ref_egress_init = crypto.Keccak256.init(.{});
    ref_egress_init.update(&x_r);
    ref_egress_init.update(&auth);
    var ref_egress_init_digest: [32]u8 = undefined;
    ref_egress_init.final(&ref_egress_init_digest);

    var ref_ingress_init = crypto.Keccak256.init(.{});
    ref_ingress_init.update(&x_i);
    ref_ingress_init.update(&ack);
    var ref_ingress_init_digest: [32]u8 = undefined;
    ref_ingress_init.final(&ref_ingress_init_digest);
    const states_init = try initMacStates(mac, n_i, n_r, &auth, &ack, true);
    // Finalize copies to avoid consuming returned states
    var egress_copy_i = states_init.egress;
    var ingress_copy_i = states_init.ingress;
    var got_egress_i: [32]u8 = undefined;
    var got_ingress_i: [32]u8 = undefined;
    egress_copy_i.final(&got_egress_i);
    ingress_copy_i.final(&got_ingress_i);
    try std.testing.expectEqualSlices(u8, &ref_egress_init_digest, &got_egress_i);
    try std.testing.expectEqualSlices(u8, &ref_ingress_init_digest, &got_ingress_i);

    // Expected digests for recipient role (swap which goes to ingress/egress)
    var ref_egress_rec = crypto.Keccak256.init(.{});
    ref_egress_rec.update(&x_i);
    ref_egress_rec.update(&ack);
    var ref_egress_rec_digest: [32]u8 = undefined;
    ref_egress_rec.final(&ref_egress_rec_digest);
    var ref_ingress_rec = crypto.Keccak256.init(.{});
    ref_ingress_rec.update(&x_r);
    ref_ingress_rec.update(&auth);
    var ref_ingress_rec_digest: [32]u8 = undefined;
    ref_ingress_rec.final(&ref_ingress_rec_digest);

    const states_rec = try initMacStates(mac, n_i, n_r, &auth, &ack, false);
    var egress_copy_r = states_rec.egress;
    var ingress_copy_r = states_rec.ingress;
    var got_egress_r: [32]u8 = undefined;
    var got_ingress_r: [32]u8 = undefined;
    egress_copy_r.final(&got_egress_r);
    ingress_copy_r.final(&got_ingress_r);
    try std.testing.expectEqualSlices(u8, &ref_egress_rec_digest, &got_egress_r);
    try std.testing.expectEqualSlices(u8, &ref_ingress_rec_digest, &got_ingress_r);
}

test "initMacStatesFor(Keccak256) equals default" {
    const zero: Bytes32 = [_]u8{0} ** 32;
    var mac: Bytes32 = zero;
    @memset(&mac, 0x33);
    var n_i: Bytes32 = zero;
    @memset(&n_i, 0x44);
    var n_r: Bytes32 = zero;
    @memset(&n_r, 0x55);
    const auth_body = [_]u8{'X'};
    const ack_body = [_]u8{'Y'};
    const auth = [_]u8{ 0x00, auth_body.len } ++ auth_body;
    const ack = [_]u8{ 0x00, ack_body.len } ++ ack_body;
    const a = try initMacStates(mac, n_i, n_r, &auth, &ack, true);
    const b = try initMacStatesFor(crypto.Keccak256, mac, n_i, n_r, &auth, &ack, true);
    var a_e = a.egress;
    var a_i = a.ingress;
    var b_e = b.egress;
    var b_i = b.ingress;
    var a_ed: [32]u8 = undefined;
    var a_id: [32]u8 = undefined;
    var b_ed: [32]u8 = undefined;
    var b_id: [32]u8 = undefined;
    a_e.final(&a_ed);
    a_i.final(&a_id);
    b_e.final(&b_ed);
    b_i.final(&b_id);
    try std.testing.expectEqualSlices(u8, &a_ed, &b_ed);
    try std.testing.expectEqualSlices(u8, &a_id, &b_id);
}
