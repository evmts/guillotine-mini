/// Transaction pool sorting helpers (priority fee calculation).
///
/// Spec references:
/// - `execution-specs/src/ethereum/forks/cancun/fork.py` -> check_transaction
/// - `execution-specs/src/ethereum/forks/london/transactions.py` -> fee market fields
const std = @import("std");
const primitives = @import("primitives");

const tx_mod = primitives.Transaction;
const BaseFeePerGas = primitives.BaseFeePerGas;
const EffectiveGasPrice = primitives.EffectiveGasPrice;
const U256 = EffectiveGasPrice.U256;

/// Compute the effective priority fee per gas (miner tip) at the given base fee.
///
/// For EIP-1559 style transactions this is:
///   min(max_priority_fee_per_gas, max_fee_per_gas - base_fee)
/// Legacy transactions treat gas_price as both max fee and max priority fee.
pub fn effective_priority_fee_per_gas(tx: anytype, base_fee: BaseFeePerGas) U256 {
    const Tx = @TypeOf(tx);
    comptime {
        // NOTE: Voltaire Zig primitives do not yet expose EIP-2930 transactions.
        if (Tx != tx_mod.LegacyTransaction and
            Tx != tx_mod.Eip1559Transaction and
            Tx != tx_mod.Eip4844Transaction and
            Tx != tx_mod.Eip7702Transaction)
        {
            @compileError("Unsupported transaction type for effective_priority_fee_per_gas");
        }
    }

    const base_fee_wei = base_fee.toWei();

    var max_fee: U256 = undefined;
    var max_priority: U256 = undefined;

    if (comptime Tx == tx_mod.LegacyTransaction) {
        const gas_price = U256.from_u256(tx.gas_price);
        max_fee = gas_price;
        max_priority = gas_price;
    } else {
        max_fee = U256.from_u256(tx.max_fee_per_gas);
        max_priority = U256.from_u256(tx.max_priority_fee_per_gas);
    }

    const result = EffectiveGasPrice.calculate(base_fee_wei, max_fee, max_priority);
    return result.miner_fee;
}

// =============================================================================
// Tests
// =============================================================================

test "effective_priority_fee_per_gas - legacy uses gas_price minus base_fee" {
    const Address = primitives.Address;

    const tx = tx_mod.LegacyTransaction{
        .nonce = 0,
        .gas_price = @as(u256, 50),
        .gas_limit = 21_000,
        .to = Address{ .bytes = [_]u8{0x11} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .v = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    const base_fee = BaseFeePerGas.from(10);
    const priority = effective_priority_fee_per_gas(tx, base_fee);
    try std.testing.expectEqual(U256.from_u64(40), priority);
}

test "effective_priority_fee_per_gas - 1559 caps at max fee" {
    const Address = primitives.Address;

    const tx = tx_mod.Eip1559Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = @as(u256, 80),
        .max_fee_per_gas = @as(u256, 150),
        .gas_limit = 21_000,
        .to = Address{ .bytes = [_]u8{0x22} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    const base_fee = BaseFeePerGas.from(100);
    const priority = effective_priority_fee_per_gas(tx, base_fee);
    try std.testing.expectEqual(U256.from_u64(50), priority);
}

test "effective_priority_fee_per_gas - 1559 returns zero when base fee exceeds max fee" {
    const Address = primitives.Address;

    const tx = tx_mod.Eip1559Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = @as(u256, 10),
        .max_fee_per_gas = @as(u256, 100),
        .gas_limit = 21_000,
        .to = Address{ .bytes = [_]u8{0x33} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    const base_fee = BaseFeePerGas.from(200);
    const priority = effective_priority_fee_per_gas(tx, base_fee);
    try std.testing.expectEqual(U256.from_u64(0), priority);
}
