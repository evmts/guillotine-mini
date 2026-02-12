const std = @import("std");
const primitives = @import("primitives");

const BaseFeePerGas = primitives.BaseFeePerGas;
const U256 = primitives.Denomination.U256;

/// Calculate the base-fee threshold used for immediate local tx broadcast.
///
/// Mirrors Nethermind's TxBroadcaster.CalculateBaseFeeThreshold semantics:
/// - Compute floor(base_fee * threshold_percent / 100)
/// - If base_fee * threshold_percent overflows, fall back to
///   floor((base_fee / 100) * threshold_percent)
/// - If even the fallback overflows (only possible when threshold_percent > 100),
///   return U256.MAX to indicate "unattainable threshold".
///
/// All arithmetic is performed on Voltaire U256 primitives with explicit
/// overflow handling. No allocations.
pub fn calculate_base_fee_threshold(base_fee: BaseFeePerGas, threshold_percent: u32) U256 {
    const hundred = U256.from_u64(100);
    const percent = U256.from_u64(threshold_percent);

    const fee_wei: U256 = base_fee.toWei();

    // Try precise path first: (base_fee * percent) / 100
    var mul = fee_wei.overflowing_mul(percent);
    var threshold = mul.result.div_rem(hundred).quotient;
    var overflow = mul.overflow;

    if (overflow) {
        // Fallback: (base_fee / 100) * percent (less accurate but avoids early overflow)
        const one_percent = fee_wei.div_rem(hundred).quotient;
        mul = one_percent.overflowing_mul(percent);
        threshold = mul.result;
        overflow = mul.overflow;
    }

    return if (overflow) U256.MAX else threshold;
}

// =============================================================================
// Tests
// =============================================================================

test "calculate_base_fee_threshold — exact small values (70%)" {
    const fee = BaseFeePerGas.from(0);
    try std.testing.expect(calculate_base_fee_threshold(fee, 70).eq(U256.from_u64(0)));

    try std.testing.expect(calculate_base_fee_threshold(BaseFeePerGas.from(2), 70).eq(U256.from_u64(1)));
    try std.testing.expect(calculate_base_fee_threshold(BaseFeePerGas.from(3), 70).eq(U256.from_u64(2)));
    try std.testing.expect(calculate_base_fee_threshold(BaseFeePerGas.from(7), 70).eq(U256.from_u64(4)));
    try std.testing.expect(calculate_base_fee_threshold(BaseFeePerGas.from(8), 70).eq(U256.from_u64(5)));
    try std.testing.expect(calculate_base_fee_threshold(BaseFeePerGas.from(100), 70).eq(U256.from_u64(70)));
    try std.testing.expect(calculate_base_fee_threshold(BaseFeePerGas.from(9999), 70).eq(U256.from_u64(6999)));
    try std.testing.expect(calculate_base_fee_threshold(BaseFeePerGas.from(10_000), 70).eq(U256.from_u64(7000)));
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
            const res = calculate_base_fee_threshold(base, threshold_percent);

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
