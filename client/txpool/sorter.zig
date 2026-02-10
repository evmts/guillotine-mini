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

/// Compare two fee tuples by priority (descending).
///
/// Returns:
/// - `-1` when `x` has higher priority (should sort before `y`)
/// - `0` when equal
/// - `1` when `y` has higher priority
///
/// When EIP-1559 is enabled, this compares the effective gas price:
/// `min(max_fee, base_fee + max_priority)` with a max fee tie-breaker.
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
        const base_fee_wei = base_fee.toWei();
        const x_effective = EffectiveGasPrice.calculate(
            base_fee_wei,
            x_max_fee_per_gas.toWei(),
            x_max_priority_fee_per_gas.toWei(),
        ).effective;
        const y_effective = EffectiveGasPrice.calculate(
            base_fee_wei,
            y_max_fee_per_gas.toWei(),
            y_max_priority_fee_per_gas.toWei(),
        ).effective;

        switch (x_effective.compare(y_effective)) {
            .lt => return 1,
            .gt => return -1,
            .eq => {},
        }

        switch (x_max_fee_per_gas.compare(y_max_fee_per_gas)) {
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
