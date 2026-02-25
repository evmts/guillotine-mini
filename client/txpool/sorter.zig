/// Transaction pool sorting helpers (fee market priority).
///
/// Spec references:
/// - EIP-1559 effective gas price calculation
/// - execution-specs/src/ethereum/forks/london/fork.py (effective gas price)
///
/// Nethermind reference:
/// - Nethermind.Consensus/Comparers/GasPriceTxComparerHelper.cs
const std = @import("std");
const primitives = @import("voltaire");

const BaseFeePerGas = primitives.BaseFeePerGas;
const GasPrice = primitives.GasPrice;
const MaxFeePerGas = primitives.MaxFeePerGas;
const MaxPriorityFeePerGas = primitives.MaxPriorityFeePerGas;
const U256 = primitives.Denomination.U256;

fn is_legacy_fee_fields(max_fee: MaxFeePerGas, max_priority: MaxPriorityFeePerGas) bool {
    return max_fee.isZero() and max_priority.isZero();
}

fn resolve_max_fee(
    gas_price: GasPrice,
    max_fee: MaxFeePerGas,
    is_legacy: bool,
) MaxFeePerGas {
    if (is_legacy) {
        return MaxFeePerGas.fromU256(gas_price.toWei());
    }

    return max_fee;
}

fn resolve_max_priority(
    gas_price: GasPrice,
    max_priority: MaxPriorityFeePerGas,
    is_legacy: bool,
) MaxPriorityFeePerGas {
    if (is_legacy) {
        return MaxPriorityFeePerGas.fromU256(gas_price.toWei());
    }

    return max_priority;
}

/// Compare two fee tuples by priority (descending).
///
/// Returns:
/// - `-1` when `x` has higher priority (should sort before `y`)
/// - `0` when equal
/// - `1` when `y` has higher priority
///
/// When EIP-1559 is enabled, this compares the effective gas price:
/// `min(max_fee, base_fee + max_priority)` with a max fee tie-breaker.
/// Legacy txs with zeroed EIP-1559 fields are treated as
/// `max_fee = max_priority = gas_price`.
/// Otherwise it compares legacy `gas_price` (descending).
pub fn compare_fee_market_priority(
    x_gas_price: GasPrice,
    x_max_fee_per_gas: MaxFeePerGas,
    x_max_priority_fee_per_gas: MaxPriorityFeePerGas,
    y_gas_price: GasPrice,
    y_max_fee_per_gas: MaxFeePerGas,
    y_max_priority_fee_per_gas: MaxPriorityFeePerGas,
    base_fee: BaseFeePerGas,
    is_eip1559_enabled: bool,
) i32 {
    if (is_eip1559_enabled) {
        const x_is_legacy = is_legacy_fee_fields(x_max_fee_per_gas, x_max_priority_fee_per_gas);
        const y_is_legacy = is_legacy_fee_fields(y_max_fee_per_gas, y_max_priority_fee_per_gas);

        const x_max_fee = resolve_max_fee(x_gas_price, x_max_fee_per_gas, x_is_legacy);
        const y_max_fee = resolve_max_fee(y_gas_price, y_max_fee_per_gas, y_is_legacy);

        const x_max_priority = resolve_max_priority(x_gas_price, x_max_priority_fee_per_gas, x_is_legacy);
        const y_max_priority = resolve_max_priority(y_gas_price, y_max_priority_fee_per_gas, y_is_legacy);

        const base_fee_wei = base_fee.toWei();

        const x_allowed: U256 = blk: {
            if (x_max_fee.toWei().cmp(base_fee_wei) == .lt) break :blk x_max_fee.toWei();
            break :blk x_max_fee.toWei().wrapping_sub(base_fee_wei);
        };
        const y_allowed: U256 = blk: {
            if (y_max_fee.toWei().cmp(base_fee_wei) == .lt) break :blk y_max_fee.toWei();
            break :blk y_max_fee.toWei().wrapping_sub(base_fee_wei);
        };

        const x_eff_prio: U256 = if (x_max_priority.toWei().cmp(x_allowed) == .lt) x_max_priority.toWei() else x_allowed;
        const y_eff_prio: U256 = if (y_max_priority.toWei().cmp(y_allowed) == .lt) y_max_priority.toWei() else y_allowed;

        const x_effective: U256 = blk: {
            const candidate = base_fee_wei.wrapping_add(x_eff_prio);
            break :blk if (candidate.cmp(x_max_fee.toWei()) == .gt) x_max_fee.toWei() else candidate;
        };
        const y_effective: U256 = blk: {
            const candidate = base_fee_wei.wrapping_add(y_eff_prio);
            break :blk if (candidate.cmp(y_max_fee.toWei()) == .gt) y_max_fee.toWei() else candidate;
        };

        switch (x_effective.cmp(y_effective)) {
            .lt => return 1,
            .gt => return -1,
            .eq => {},
        }

        switch (x_max_fee.compare(y_max_fee)) {
            .lt => return 1,
            .gt => return -1,
            .eq => return 0,
        }
    }

    switch (x_gas_price.compare(y_gas_price)) {
        .lt => return 1,
        .gt => return -1,
        .eq => return 0,
    }
}

// =============================================================================
// Tests
// =============================================================================

test "compare_fee_market_priority — EIP-1559 compares effective gas price" {
    const base_fee = BaseFeePerGas.from(10_000_000_000);

    const x_max_fee = MaxFeePerGas.from(30_000_000_000);
    const x_max_priority = MaxPriorityFeePerGas.from(2_000_000_000);

    const y_max_fee = MaxFeePerGas.from(20_000_000_000);
    const y_max_priority = MaxPriorityFeePerGas.from(8_000_000_000);

    const x_gas_price = GasPrice.from(0);
    const y_gas_price = GasPrice.from(0);

    try std.testing.expectEqual(
        @as(i32, 1),
        compare_fee_market_priority(
            x_gas_price,
            x_max_fee,
            x_max_priority,
            y_gas_price,
            y_max_fee,
            y_max_priority,
            base_fee,
            true,
        ),
    );
}

test "compare_fee_market_priority — EIP-1559 legacy fallback uses gas price" {
    const base_fee = BaseFeePerGas.from(10_000_000_000);

    const x_gas_price = GasPrice.from(50_000_000_000);
    const x_max_fee = MaxFeePerGas.from(0);
    const x_max_priority = MaxPriorityFeePerGas.from(0);

    const y_gas_price = GasPrice.from(0);
    const y_max_fee = MaxFeePerGas.from(40_000_000_000);
    const y_max_priority = MaxPriorityFeePerGas.from(2_000_000_000);

    try std.testing.expectEqual(
        @as(i32, -1),
        compare_fee_market_priority(
            x_gas_price,
            x_max_fee,
            x_max_priority,
            y_gas_price,
            y_max_fee,
            y_max_priority,
            base_fee,
            true,
        ),
    );
}

test "compare_fee_market_priority — EIP-1559 ties on effective gas price use max fee" {
    const base_fee = BaseFeePerGas.from(10_000_000_000);

    const x_max_fee = MaxFeePerGas.from(20_000_000_000);
    const x_max_priority = MaxPriorityFeePerGas.from(5_000_000_000);

    const y_max_fee = MaxFeePerGas.from(25_000_000_000);
    const y_max_priority = MaxPriorityFeePerGas.from(5_000_000_000);

    const x_gas_price = GasPrice.from(0);
    const y_gas_price = GasPrice.from(0);

    try std.testing.expectEqual(
        @as(i32, 1),
        compare_fee_market_priority(
            x_gas_price,
            x_max_fee,
            x_max_priority,
            y_gas_price,
            y_max_fee,
            y_max_priority,
            base_fee,
            true,
        ),
    );
}

test "compare_fee_market_priority — EIP-1559 caps priority by max fee minus base fee" {
    const base_fee = BaseFeePerGas.from(25_000_000_000);

    const x_max_fee = MaxFeePerGas.from(27_000_000_000);
    const x_max_priority = MaxPriorityFeePerGas.from(5_000_000_000);

    const y_max_fee = MaxFeePerGas.from(28_000_000_000);
    const y_max_priority = MaxPriorityFeePerGas.from(1_000_000_000);

    const x_gas_price = GasPrice.from(0);
    const y_gas_price = GasPrice.from(0);

    try std.testing.expectEqual(
        @as(i32, -1),
        compare_fee_market_priority(
            x_gas_price,
            x_max_fee,
            x_max_priority,
            y_gas_price,
            y_max_fee,
            y_max_priority,
            base_fee,
            true,
        ),
    );
}

test "compare_fee_market_priority — EIP-1559 max fee below base fee uses max fee" {
    const base_fee = BaseFeePerGas.from(30_000_000_000);

    const x_max_fee = MaxFeePerGas.from(25_000_000_000);
    const x_max_priority = MaxPriorityFeePerGas.from(2_000_000_000);

    const y_max_fee = MaxFeePerGas.from(28_000_000_000);
    const y_max_priority = MaxPriorityFeePerGas.from(1_000_000_000);

    const x_gas_price = GasPrice.from(0);
    const y_gas_price = GasPrice.from(0);

    try std.testing.expectEqual(
        @as(i32, 1),
        compare_fee_market_priority(
            x_gas_price,
            x_max_fee,
            x_max_priority,
            y_gas_price,
            y_max_fee,
            y_max_priority,
            base_fee,
            true,
        ),
    );
}

test "compare_fee_market_priority — legacy compares gas price descending" {
    const base_fee = BaseFeePerGas.from(0);

    const x_gas_price = GasPrice.from(30_000_000_000);
    const y_gas_price = GasPrice.from(20_000_000_000);

    const x_max_fee = MaxFeePerGas.from(0);
    const x_max_priority = MaxPriorityFeePerGas.from(0);
    const y_max_fee = MaxFeePerGas.from(0);
    const y_max_priority = MaxPriorityFeePerGas.from(0);

    try std.testing.expectEqual(
        @as(i32, -1),
        compare_fee_market_priority(
            x_gas_price,
            x_max_fee,
            x_max_priority,
            y_gas_price,
            y_max_fee,
            y_max_priority,
            base_fee,
            false,
        ),
    );
}

test "compare_fee_market_priority — equality returns zero" {
    const base_fee = BaseFeePerGas.from(10_000_000_000);

    const gas_price = GasPrice.from(20_000_000_000);
    const max_fee = MaxFeePerGas.from(20_000_000_000);
    const max_priority = MaxPriorityFeePerGas.from(5_000_000_000);

    try std.testing.expectEqual(
        @as(i32, 0),
        compare_fee_market_priority(
            gas_price,
            max_fee,
            max_priority,
            gas_price,
            max_fee,
            max_priority,
            base_fee,
            true,
        ),
    );
}
