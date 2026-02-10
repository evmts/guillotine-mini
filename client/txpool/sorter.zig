/// Transaction pool sorting helpers (fee market priority).
///
/// Spec references:
/// - EIP-1559 effective gas price calculation
/// - execution-specs/src/ethereum/forks/london/fork.py (effective gas price)
///
/// Nethermind reference:
/// - Nethermind.Consensus/Comparers/GasPriceTxComparerHelper.cs
const std = @import("std");
const primitives = @import("primitives");

const BaseFeePerGas = primitives.BaseFeePerGas;
const EffectiveGasPrice = primitives.EffectiveGasPrice;
const GasPrice = primitives.GasPrice;
const MaxFeePerGas = primitives.MaxFeePerGas;
const MaxPriorityFeePerGas = primitives.MaxPriorityFeePerGas;

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
        const x_effective = EffectiveGasPrice.calculate(
            base_fee_wei,
            x_max_fee.toWei(),
            x_max_priority.toWei(),
        ).effective;
        const y_effective = EffectiveGasPrice.calculate(
            base_fee_wei,
            y_max_fee.toWei(),
            y_max_priority.toWei(),
        ).effective;

        switch (x_effective.compare(y_effective)) {
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
    const base_fee = BaseFeePerGas.fromGwei(10);

    const x_max_fee = MaxFeePerGas.fromGwei(30);
    const x_max_priority = MaxPriorityFeePerGas.fromGwei(2);

    const y_max_fee = MaxFeePerGas.fromGwei(20);
    const y_max_priority = MaxPriorityFeePerGas.fromGwei(8);

    const x_gas_price = GasPrice.fromGwei(0);
    const y_gas_price = GasPrice.fromGwei(0);

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
    const base_fee = BaseFeePerGas.fromGwei(10);

    const x_gas_price = GasPrice.fromGwei(50);
    const x_max_fee = MaxFeePerGas.fromGwei(0);
    const x_max_priority = MaxPriorityFeePerGas.fromGwei(0);

    const y_gas_price = GasPrice.fromGwei(0);
    const y_max_fee = MaxFeePerGas.fromGwei(40);
    const y_max_priority = MaxPriorityFeePerGas.fromGwei(2);

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
    const base_fee = BaseFeePerGas.fromGwei(10);

    const x_max_fee = MaxFeePerGas.fromGwei(20);
    const x_max_priority = MaxPriorityFeePerGas.fromGwei(5);

    const y_max_fee = MaxFeePerGas.fromGwei(25);
    const y_max_priority = MaxPriorityFeePerGas.fromGwei(5);

    const x_gas_price = GasPrice.fromGwei(0);
    const y_gas_price = GasPrice.fromGwei(0);

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
    const base_fee = BaseFeePerGas.fromGwei(25);

    const x_max_fee = MaxFeePerGas.fromGwei(27);
    const x_max_priority = MaxPriorityFeePerGas.fromGwei(5);

    const y_max_fee = MaxFeePerGas.fromGwei(28);
    const y_max_priority = MaxPriorityFeePerGas.fromGwei(1);

    const x_gas_price = GasPrice.fromGwei(0);
    const y_gas_price = GasPrice.fromGwei(0);

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
    const base_fee = BaseFeePerGas.fromGwei(30);

    const x_max_fee = MaxFeePerGas.fromGwei(25);
    const x_max_priority = MaxPriorityFeePerGas.fromGwei(2);

    const y_max_fee = MaxFeePerGas.fromGwei(28);
    const y_max_priority = MaxPriorityFeePerGas.fromGwei(1);

    const x_gas_price = GasPrice.fromGwei(0);
    const y_gas_price = GasPrice.fromGwei(0);

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
    const base_fee = BaseFeePerGas.fromGwei(0);

    const x_gas_price = GasPrice.fromGwei(30);
    const y_gas_price = GasPrice.fromGwei(20);

    const x_max_fee = MaxFeePerGas.fromGwei(0);
    const x_max_priority = MaxPriorityFeePerGas.fromGwei(0);
    const y_max_fee = MaxFeePerGas.fromGwei(0);
    const y_max_priority = MaxPriorityFeePerGas.fromGwei(0);

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
    const base_fee = BaseFeePerGas.fromGwei(10);

    const gas_price = GasPrice.fromGwei(20);
    const max_fee = MaxFeePerGas.fromGwei(20);
    const max_priority = MaxPriorityFeePerGas.fromGwei(5);

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
