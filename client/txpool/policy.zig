const std = @import("std");
const primitives = @import("primitives");

const BaseFeePerGas = primitives.BaseFeePerGas;
const MaxFeePerGas = primitives.MaxFeePerGas;
const U256 = primitives.Denomination.U256;

/// Calculate the base-fee threshold used for immediate local tx broadcast.
///
/// Returned value is a `MaxFeePerGas`.
/// Callers must broadcast only when `tx.max_fee_per_gas >= calculate_base_fee_threshold(...)`.
/// Explicit: compare `tx.max_fee_per_gas` against this threshold.
///
/// Mirrors Nethermind's TxBroadcaster.CalculateBaseFeeThreshold semantics:
/// - Compute floor(base_fee * threshold_percent / 100)
/// - If base_fee * threshold_percent overflows, fall back to
///   floor((base_fee / 100) * threshold_percent)
/// - If even the fallback overflows (only possible when threshold_percent > 100),
///   return MaxFeePerGas(U256.MAX) to indicate "unattainable threshold".
///
/// All arithmetic is performed on Voltaire U256 primitives with explicit
/// overflow handling. No allocations.
pub fn calculate_base_fee_threshold(base_fee: BaseFeePerGas, threshold_percent: u32) MaxFeePerGas {
    const hundred = U256.from_u64(100);
    const percent = U256.from_u64(threshold_percent);

    const fee_wei: U256 = base_fee.toWei();

    // Try precise path first: (base_fee * percent) / 100
    var mul = fee_wei.overflowing_mul(percent);
    var overflow = mul.overflow;
    var threshold: U256 = undefined;
    if (!overflow) {
        threshold = mul.result.div_rem(hundred).quotient;
    } else {
        // Fallback: (base_fee / 100) * percent (less accurate but avoids early overflow)
        const one_percent = fee_wei.div_rem(hundred).quotient;
        mul = one_percent.overflowing_mul(percent);
        threshold = mul.result;
        overflow = mul.overflow;
    }

    return if (overflow)
        MaxFeePerGas.fromU256(U256.MAX)
    else
        MaxFeePerGas.fromU256(threshold);
}

/// Compute how many persistent transactions to broadcast per block.
///
/// Mirrors Nethermind's TxBroadcaster persistent quota logic:
/// `min(PeerNotificationThreshold * persistent_count / 100 + 1, persistent_count)`.
///
/// Notes:
/// - Returns 0 when either `pool_size` or `threshold_percent` is 0.
/// - Uses widened 64-bit arithmetic to avoid intermediate overflow.
/// - Constant +1 matches Nethermind (not a true ceil); clamp enforces the max.
pub fn calculate_persistent_broadcast_quota(pool_size: u32, threshold_percent: u32) u32 {
    if (pool_size == 0 or threshold_percent == 0) return 0;

    const product: u64 = @as(u64, threshold_percent) * @as(u64, pool_size);
    const quota64: u64 = product / 100 + 1;
    // Mixed-width compare: cast pool_size to u64 for clarity and safety.
    return if (quota64 > @as(u64, pool_size)) pool_size else @as(u32, @intCast(quota64));
}

// =============================================================================
// Tests
// =============================================================================

test "calculate_base_fee_threshold — exact small values (70%)" {
    const fee = BaseFeePerGas.from(0);
    try std.testing.expect(calculate_base_fee_threshold(fee, 70).toWei().eq(U256.from_u64(0)));

    try std.testing.expect(calculate_base_fee_threshold(BaseFeePerGas.from(2), 70).toWei().eq(U256.from_u64(1)));
    try std.testing.expect(calculate_base_fee_threshold(BaseFeePerGas.from(3), 70).toWei().eq(U256.from_u64(2)));
    try std.testing.expect(calculate_base_fee_threshold(BaseFeePerGas.from(7), 70).toWei().eq(U256.from_u64(4)));
    try std.testing.expect(calculate_base_fee_threshold(BaseFeePerGas.from(8), 70).toWei().eq(U256.from_u64(5)));
    try std.testing.expect(calculate_base_fee_threshold(BaseFeePerGas.from(100), 70).toWei().eq(U256.from_u64(70)));
    try std.testing.expect(calculate_base_fee_threshold(BaseFeePerGas.from(9999), 70).toWei().eq(U256.from_u64(6999)));
    try std.testing.expect(calculate_base_fee_threshold(BaseFeePerGas.from(10_000), 70).toWei().eq(U256.from_u64(7000)));
}

test "calculate_base_fee_threshold — overflow fallback and saturation" {
    // Construct a large base fee close to U256::MAX so that multiplying by a small
    // divisor then by percent tests both paths. We mirror Nethermind's logic:
    // - Attempt: base * percent (overflow?); divide by 100
    // - Fallback: (base/100) * percent (overflow?); otherwise result
    const max = U256.MAX;

    // Derive base_fee = MAX / divisor to make first multiply often overflow,
    // then verify fallback behavior across different percents.
    inline for (.{ 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 }) |divisor| {
        const base_div = max.div_rem(U256.from_u64(divisor)).quotient;
        const base = BaseFeePerGas.fromU256(base_div);

        inline for (.{ 0, 70, 100, 101, 500 }) |threshold_percent| {
            const res = calculate_base_fee_threshold(base, threshold_percent).toWei();

            // Build expected according to Nethermind reference logic
            var overflow1 = base_div.overflowing_mul(U256.from_u64(threshold_percent));
            var expected = overflow1.result.div_rem(U256.from_u64(100)).quotient;
            var of = overflow1.overflow;
            if (of) {
                const one_percent = base_div.div_rem(U256.from_u64(100)).quotient;
                const overflow2 = one_percent.overflowing_mul(U256.from_u64(threshold_percent));
                expected = overflow2.result;
                of = overflow2.overflow;
            }

            const final_expected = if (of) U256.MAX else expected;
            try std.testing.expect(res.eq(final_expected));
        }
    }
}

test "calculate_persistent_broadcast_quota — zeros and basic cases" {
    try std.testing.expectEqual(@as(u32, 0), calculate_persistent_broadcast_quota(0, 0));
    try std.testing.expectEqual(@as(u32, 0), calculate_persistent_broadcast_quota(10, 0));
    try std.testing.expectEqual(@as(u32, 0), calculate_persistent_broadcast_quota(0, 5));

    // At least one when threshold > 0
    try std.testing.expectEqual(@as(u32, 1), calculate_persistent_broadcast_quota(1, 1));
    try std.testing.expectEqual(@as(u32, 1), calculate_persistent_broadcast_quota(1, 99));
}

test "calculate_persistent_broadcast_quota — matches Nethermind rounding and clamp" {
    // Formula: min(threshold*count/100 + 1, count)
    try std.testing.expectEqual(@as(u32, 6), calculate_persistent_broadcast_quota(100, 5));
    try std.testing.expectEqual(@as(u32, 50), calculate_persistent_broadcast_quota(50, 99));
    try std.testing.expectEqual(@as(u32, 50), calculate_persistent_broadcast_quota(50, 100));

    // Not a true ceil: 1% of 200 -> floor(2)+1 = 3
    try std.testing.expectEqual(@as(u32, 3), calculate_persistent_broadcast_quota(200, 1));

    // Clamp at pool size for very large thresholds
    try std.testing.expectEqual(@as(u32, 20), calculate_persistent_broadcast_quota(20, 500));
    try std.testing.expectEqual(@as(u32, 2048), calculate_persistent_broadcast_quota(2048, 4_294_967_295));

    // Typical default: 5% of 2048 => 102 + 1 = 103
    try std.testing.expectEqual(@as(u32, 103), calculate_persistent_broadcast_quota(2048, 5));
}
