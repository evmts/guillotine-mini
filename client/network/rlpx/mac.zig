//! RLPx MAC State Initialization
const std = @import("std");
const primitives = @import("primitives");
const crypto = @import("crypto");
const Bytes32 = primitives.Bytes32.Bytes32;

/// Pair of Keccak256 states for authenticated framing.
pub const MacStates = struct {
    ingress: crypto.Keccak256,
    egress: crypto.Keccak256,
};
pub const MacSeedError = error{ InvalidAuthPrefix, InvalidAckPrefix, InvalidAuthSize, InvalidAckSize };

pub fn initMacStates(
    mac_secret: Bytes32,
    initiator_nonce: Bytes32,
    recipient_nonce: Bytes32,
    auth: []const u8,
    ack: []const u8,
    is_initiator: bool,
) MacSeedError!MacStates {
    if (auth.len < 2) return error.InvalidAuthPrefix;
    if (ack.len < 2) return error.InvalidAckPrefix;
    const auth_size: u16 = (@as(u16, auth[0]) << 8) | auth[1];
    const ack_size: u16 = (@as(u16, ack[0]) << 8) | ack[1];
    if (auth.len != 2 + auth_size) return error.InvalidAuthSize;
    if (ack.len != 2 + ack_size) return error.InvalidAckSize;
    var ingress = crypto.Keccak256.init(.{});
    // Precompute XOR(mac-secret, initiator-nonce) and XOR(mac-secret, recipient-nonce)
    var mac_xor_initiator: Bytes32 = undefined;
    var mac_xor_recipient: Bytes32 = undefined;
    inline for (0..32) |i| {
        mac_xor_initiator[i] = mac_secret[i] ^ initiator_nonce[i];
        mac_xor_recipient[i] = mac_secret[i] ^ recipient_nonce[i];
    }
    var egress = crypto.Keccak256.init(.{});
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
    ref_egress_rec.update(ack);
    var ref_egress_rec_digest: [32]u8 = undefined;
    ref_egress_rec.final(&ref_egress_rec_digest);
    var ref_ingress_rec = crypto.Keccak256.init(.{});
    ref_ingress_rec.update(&x_r);
    ref_ingress_rec.update(auth);
    var ref_ingress_rec_digest: [32]u8 = undefined;
    ref_ingress_rec.final(&ref_ingress_rec_digest);

    const states_rec = initMacStates(mac, n_i, n_r, auth, ack, false);
    var egress_copy_r = states_rec.egress;
    var ingress_copy_r = states_rec.ingress;
    var got_egress_r: [32]u8 = undefined;
    var got_ingress_r: [32]u8 = undefined;
    egress_copy_r.final(&got_egress_r);
    ingress_copy_r.final(&got_ingress_r);
    try std.testing.expectEqualSlices(u8, &ref_egress_rec_digest, &got_egress_r);
    try std.testing.expectEqualSlices(u8, &ref_ingress_rec_digest, &got_ingress_r);
}

test "initMacStates: zero-length auth/ack handled" {
    const zero: Bytes32 = [_]u8{0} ** 32;
    const states = initMacStates(zero, zero, zero, &[_]u8{}, &[_]u8{}, true);
    // Finalizing should succeed and match keccak256(mac^nonce) for each direction
    var x_i: Bytes32 = zero; // mac ^ initiator == zero
    var x_r: Bytes32 = zero; // mac ^ recipient == zero
    var e = states.egress;
    var i = states.ingress;
    var e_d: [32]u8 = undefined;
    var i_d: [32]u8 = undefined;
    e.final(&e_d);
    i.final(&i_d);
    var expect_e = crypto.Keccak256.init(.{});
    expect_e.update(&x_r);
    var expect_e_d: [32]u8 = undefined;
    expect_e.final(&expect_e_d);

    var expect_i = crypto.Keccak256.init(.{});
    expect_i.update(&x_i);
    var expect_i_d: [32]u8 = undefined;
    expect_i.final(&expect_i_d);
    try std.testing.expectEqualSlices(u8, &expect_e_d, &e_d);
    try std.testing.expectEqualSlices(u8, &expect_i_d, &i_d);
}
