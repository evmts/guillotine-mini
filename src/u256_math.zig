//! High-performance 256-bit and 512-by-256 unsigned arithmetic (intx/ruint style).
//! Replaces LLVM's slow bit-by-bit restoring u256/u512 division with hardware-assisted
//! 64-bit limb Knuth Algorithm D and exact 256x256->512 modular reduction.
const std = @import("std");

pub const DivRem = struct {
    q: u256,
    r: u256,
};

inline fn toLimbs(x: u256) [4]u64 {
    return .{
        @truncate(x),
        @truncate(x >> 64),
        @truncate(x >> 128),
        @truncate(x >> 192),
    };
}

inline fn fromLimbs(l: [4]u64) u256 {
    return @as(u256, l[0]) |
        (@as(u256, l[1]) << 64) |
        (@as(u256, l[2]) << 128) |
        (@as(u256, l[3]) << 192);
}

inline fn limbLen(comptime N: usize, a: [N]u64) usize {
    var i: usize = N;
    while (i > 0) {
        i -= 1;
        if (a[i] != 0) return i + 1;
    }
    return 0;
}

/// Fast 256-bit unsigned division and remainder. Caller ensures b != 0.
pub fn divRem(a: u256, b: u256) DivRem {
    if (a < b) return .{ .q = 0, .r = a };
    if (a == b) return .{ .q = 1, .r = 0 };

    // Fast path: both fit in u64 (1 hardware udiv)
    if ((a >> 64) == 0) {
        const a64: u64 = @truncate(a);
        const b64: u64 = @truncate(b);
        const q = a64 / b64;
        return .{ .q = q, .r = a64 - q * b64 };
    }

    // Fast path: both fit in u128
    if ((a >> 128) == 0) {
        const a128: u128 = @truncate(a);
        const b128: u128 = @truncate(b);
        const q = a128 / b128;
        return .{ .q = q, .r = a128 - q * b128 };
    }

    const u = toLimbs(a);
    const v = toLimbs(b);

    // Fast path: single-limb divisor (b < 2^64)
    if ((b >> 64) == 0) {
        const d: u128 = v[0];
        var rem: u128 = 0;
        var q: [4]u64 = .{ 0, 0, 0, 0 };
        var i: usize = 4;
        while (i > 0) {
            i -= 1;
            const cur: u128 = (rem << 64) | u[i];
            const qi = cur / d;
            q[i] = @truncate(qi);
            rem = cur - qi * d;
        }
        return .{ .q = fromLimbs(q), .r = @as(u256, rem) };
    }

    // General Knuth Algorithm D for n = 2..4 limbs
    const n = limbLen(4, v);
    const m_plus_n = limbLen(4, u);
    const m = m_plus_n - n;

    // Normalize so v[n-1] has MSB set
    const shift: u6 = @intCast(@clz(v[n - 1]));
    var vn: [4]u64 = .{ 0, 0, 0, 0 };
    var un: [5]u64 = .{ 0, 0, 0, 0, 0 };

    if (shift > 0) {
        const rshift: u6 = @intCast(@as(u7, 64) - shift);
        var i: usize = n - 1;
        while (i > 0) : (i -= 1) {
            vn[i] = (v[i] << shift) | (v[i - 1] >> rshift);
        }
        vn[0] = v[0] << shift;

        un[m_plus_n] = u[m_plus_n - 1] >> rshift;
        i = m_plus_n - 1;
        while (i > 0) : (i -= 1) {
            un[i] = (u[i] << shift) | (u[i - 1] >> rshift);
        }
        un[0] = u[0] << shift;
    } else {
        vn = v;
        for (0..m_plus_n) |i| un[i] = u[i];
    }

    var q: [4]u64 = .{ 0, 0, 0, 0 };
    const vn1: u128 = vn[n - 1];
    const vn2: u128 = vn[n - 2];

    var j_plus_1: usize = m + 1;
    while (j_plus_1 > 0) {
        j_plus_1 -= 1;
        const j = j_plus_1;

        const dividend: u128 = (@as(u128, un[j + n]) << 64) | un[j + n - 1];
        var qhat: u128 = dividend / vn1;
        var rhat: u128 = dividend - qhat * vn1;

        while (qhat >= (@as(u128, 1) << 64) or qhat * vn2 > ((rhat << 64) | un[j + n - 2])) {
            qhat -= 1;
            rhat += vn1;
            if (rhat >= (@as(u128, 1) << 64)) break;
        }

        // Multiply and subtract: un[j..j+n] -= qhat * vn[0..n]
        var borrow: u128 = 0;
        for (0..n) |i| {
            const p: u128 = qhat * vn[i];
            const sub_lo: u64 = @truncate(p);
            const sub_hi: u64 = @truncate(p >> 64);

            const s1 = @subWithOverflow(un[j + i], sub_lo);
            const s2 = @subWithOverflow(s1[0], @as(u64, @truncate(borrow)));
            un[j + i] = s2[0];
            borrow = @as(u128, sub_hi) + s1[1] + s2[1];
        }
        const final_sub = @subWithOverflow(un[j + n], @as(u64, @truncate(borrow)));
        un[j + n] = final_sub[0];

        q[j] = @truncate(qhat);
        if (final_sub[1] != 0) {
            // Very rare add-back step (probability < 2/2^64)
            q[j] -= 1;
            var carry: u128 = 0;
            for (0..n) |i| {
                const sum = @as(u128, un[j + i]) + vn[i] + carry;
                un[j + i] = @truncate(sum);
                carry = sum >> 64;
            }
            un[j + n] +%= @truncate(carry);
        }
    }

    // Unnormalize remainder
    var r: [4]u64 = .{ 0, 0, 0, 0 };
    if (shift > 0) {
        const lshift: u6 = @intCast(@as(u7, 64) - shift);
        for (0..n - 1) |i| {
            r[i] = (un[i] >> shift) | (un[i + 1] << lshift);
        }
        r[n - 1] = un[n - 1] >> shift;
    } else {
        for (0..n) |i| r[i] = un[i];
    }

    return .{ .q = fromLimbs(q), .r = fromLimbs(r) };
}

pub inline fn div(a: u256, b: u256) u256 {
    if (b == 0) return 0;
    return divRem(a, b).q;
}

pub inline fn mod(a: u256, b: u256) u256 {
    if (b == 0) return 0;
    return divRem(a, b).r;
}

/// Fast overflow-free (a + b) % m. Returns 0 when m == 0.
pub inline fn addmod(a: u256, b: u256, m: u256) u256 {
    if (m == 0) return 0;
    const am = if (a >= m) divRem(a, m).r else a;
    const bm = if (b >= m) divRem(b, m).r else b;
    const space = m - am;
    return if (bm >= space) bm - space else am + bm;
}

/// Exact 256x256 -> 512-bit product in 8 little-endian u64 limbs.
inline fn mulFull256(a_in: u256, b_in: u256) [8]u64 {
    const a = toLimbs(a_in);
    const b = toLimbs(b_in);
    var p: [8]u64 = .{ 0, 0, 0, 0, 0, 0, 0, 0 };
    inline for (0..4) |i| {
        if (a[i] != 0) {
            var carry: u128 = 0;
            const ai: u128 = a[i];
            inline for (0..4) |j| {
                const prod = ai * @as(u128, b[j]) + p[i + j] + carry;
                p[i + j] = @truncate(prod);
                carry = prod >> 64;
            }
            p[i + 4] = @truncate(carry);
        }
    }
    return p;
}

/// Fast (a * b) % m for full 256-bit operands without invoking u512 restoring division.
pub fn mulmod(a: u256, b: u256, m: u256) u256 {
    if (m == 0 or a == 0 or b == 0) return 0;

    // Fast path: product fits in u128 and m fits in u128
    if ((a >> 64) == 0 and (b >> 64) == 0) {
        const prod: u128 = @as(u128, @truncate(a)) * @as(u128, @truncate(b));
        if ((m >> 128) != 0) return @as(u256, prod);
        return @as(u256, prod % @as(u128, @truncate(m)));
    }

    const prod = mulFull256(a, b);
    const u_len = limbLen(8, prod);
    if (u_len == 0) return 0;

    const v = toLimbs(m);
    const n = limbLen(4, v);

    // If product fits in 256 bits, use fast 256-bit divRem
    if (u_len <= 4) {
        const p256 = fromLimbs(.{ prod[0], prod[1], prod[2], prod[3] });
        return divRem(p256, m).r;
    }

    // Fast path: 1-limb modulus
    if (n == 1) {
        const d: u128 = v[0];
        var rem: u128 = 0;
        var i: usize = u_len;
        while (i > 0) {
            i -= 1;
            rem = ((rem << 64) | prod[i]) % d;
        }
        return @as(u256, rem);
    }

    // Knuth Algorithm D for 512-by-256 remainder (n = 2..4, u_len = 5..8)
    const m_steps = u_len - n;
    const shift: u6 = @intCast(@clz(v[n - 1]));
    var vn: [4]u64 = .{ 0, 0, 0, 0 };
    var un: [9]u64 = .{ 0, 0, 0, 0, 0, 0, 0, 0, 0 };

    if (shift > 0) {
        const rshift: u6 = @intCast(@as(u7, 64) - shift);
        var i: usize = n - 1;
        while (i > 0) : (i -= 1) {
            vn[i] = (v[i] << shift) | (v[i - 1] >> rshift);
        }
        vn[0] = v[0] << shift;

        un[u_len] = prod[u_len - 1] >> rshift;
        i = u_len - 1;
        while (i > 0) : (i -= 1) {
            un[i] = (prod[i] << shift) | (prod[i - 1] >> rshift);
        }
        un[0] = prod[0] << shift;
    } else {
        vn = v;
        for (0..u_len) |i| un[i] = prod[i];
    }

    const vn1: u128 = vn[n - 1];
    const vn2: u128 = vn[n - 2];

    var j_plus_1: usize = m_steps + 1;
    while (j_plus_1 > 0) {
        j_plus_1 -= 1;
        const j = j_plus_1;

        const dividend: u128 = (@as(u128, un[j + n]) << 64) | un[j + n - 1];
        var qhat: u128 = dividend / vn1;
        var rhat: u128 = dividend - qhat * vn1;

        while (qhat >= (@as(u128, 1) << 64) or qhat * vn2 > ((rhat << 64) | un[j + n - 2])) {
            qhat -= 1;
            rhat += vn1;
            if (rhat >= (@as(u128, 1) << 64)) break;
        }

        var borrow: u128 = 0;
        for (0..n) |i| {
            const p: u128 = qhat * vn[i];
            const sub_lo: u64 = @truncate(p);
            const sub_hi: u64 = @truncate(p >> 64);

            const s1 = @subWithOverflow(un[j + i], sub_lo);
            const s2 = @subWithOverflow(s1[0], @as(u64, @truncate(borrow)));
            un[j + i] = s2[0];
            borrow = @as(u128, sub_hi) + s1[1] + s2[1];
        }
        const final_sub = @subWithOverflow(un[j + n], @as(u64, @truncate(borrow)));
        un[j + n] = final_sub[0];

        if (final_sub[1] != 0) {
            var carry: u128 = 0;
            for (0..n) |i| {
                const sum = @as(u128, un[j + i]) + vn[i] + carry;
                un[j + i] = @truncate(sum);
                carry = sum >> 64;
            }
            un[j + n] +%= @truncate(carry);
        }
    }

    var r: [4]u64 = .{ 0, 0, 0, 0 };
    if (shift > 0) {
        const lshift: u6 = @intCast(@as(u7, 64) - shift);
        for (0..n - 1) |i| {
            r[i] = (un[i] >> shift) | (un[i + 1] << lshift);
        }
        r[n - 1] = un[n - 1] >> shift;
    } else {
        for (0..n) |i| r[i] = un[i];
    }
    return fromLimbs(r);
}

test "u256_math matches native Zig division, mod, addmod, mulmod across edge cases and PRNG" {
    const testing = std.testing;
    const max_u256 = std.math.maxInt(u256);

    const edge_vals = [_]u256{
        0,
        1,
        2,
        7,
        (@as(u256, 1) << 64) - 1,
        @as(u256, 1) << 64,
        (@as(u256, 1) << 64) + 1,
        (@as(u256, 1) << 128) - 1,
        @as(u256, 1) << 128,
        (@as(u256, 1) << 192) - 1,
        @as(u256, 1) << 192,
        (@as(u256, 1) << 255),
        max_u256 - 1,
        max_u256,
        // Knuth Algorithm D add-back torture vectors (divisor MSB=1, next limb=max, dividend close)
        0x8000000000000000_ffffffffffffffff_0000000000000000_0000000000000001,
        0x7fffffffffffffff_ffffffffffffffff_ffffffffffffffff_ffffffffffffffff,
        0x8000000000000000_0000000000000000_0000000000000000_0000000000000001,
    };

    for (edge_vals) |a| {
        for (edge_vals) |b| {
            const expected_div = if (b == 0) 0 else a / b;
            const expected_mod = if (b == 0) 0 else a % b;
            try testing.expectEqual(expected_div, div(a, b));
            try testing.expectEqual(expected_mod, mod(a, b));
        }
    }

    var prng = std.Random.DefaultPrng.init(0xdeadbeef_cafebabe);
    const rand = prng.random();
    for (0..5000) |_| {
        const a = rand.int(u256);
        const b_shift: u8 = @intCast(rand.uintLessThan(u16, 256));
        const b = rand.int(u256) >> b_shift;
        const m_shift: u8 = @intCast(rand.uintLessThan(u16, 256));
        const m = rand.int(u256) >> m_shift;

        const exp_div = if (b == 0) 0 else a / b;
        const exp_mod = if (b == 0) 0 else a % b;
        try testing.expectEqual(exp_div, div(a, b));
        try testing.expectEqual(exp_mod, mod(a, b));

        const exp_addmod: u256 = if (m == 0) 0 else @truncate((@as(u512, a) + @as(u512, b)) % @as(u512, m));
        try testing.expectEqual(exp_addmod, addmod(a, b, m));

        const exp_mulmod: u256 = if (m == 0) 0 else @truncate((@as(u512, a) * @as(u512, b)) % @as(u512, m));
        try testing.expectEqual(exp_mulmod, mulmod(a, b, m));
    }
}
