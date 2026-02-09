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
/// Returns an error when fee constraints are invalid per execution-specs.
pub fn effective_priority_fee_per_gas(tx: anytype, base_fee: BaseFeePerGas) !U256 {
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
        if (gas_price.cmp(base_fee_wei) == .lt) {
            return error.GasPriceBelowBaseFee;
        }
        max_fee = gas_price;
        max_priority = gas_price;
    } else {
        max_fee = U256.from_u256(tx.max_fee_per_gas);
        max_priority = U256.from_u256(tx.max_priority_fee_per_gas);
        if (max_fee.cmp(max_priority) == .lt) {
            return error.PriorityFeeGreaterThanMaxFee;
        }
        if (max_fee.cmp(base_fee_wei) == .lt) {
            return error.MaxFeePerGasBelowBaseFee;
        }
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
    const priority = try effective_priority_fee_per_gas(tx, base_fee);
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
    const priority = try effective_priority_fee_per_gas(tx, base_fee);
    try std.testing.expectEqual(U256.from_u64(50), priority);
}

test "effective_priority_fee_per_gas - 1559 rejects when base fee exceeds max fee" {
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
    try std.testing.expectError(
        error.MaxFeePerGasBelowBaseFee,
        effective_priority_fee_per_gas(tx, base_fee),
    );
}

test "effective_priority_fee_per_gas - 1559 rejects when priority exceeds max fee" {
    const Address = primitives.Address;

    const tx = tx_mod.Eip1559Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = @as(u256, 200),
        .max_fee_per_gas = @as(u256, 100),
        .gas_limit = 21_000,
        .to = Address{ .bytes = [_]u8{0x34} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    const base_fee = BaseFeePerGas.from(1);
    try std.testing.expectError(
        error.PriorityFeeGreaterThanMaxFee,
        effective_priority_fee_per_gas(tx, base_fee),
    );
}

test "effective_priority_fee_per_gas - legacy rejects when gas price below base fee" {
    const Address = primitives.Address;

    const tx = tx_mod.LegacyTransaction{
        .nonce = 0,
        .gas_price = @as(u256, 10),
        .gas_limit = 21_000,
        .to = Address{ .bytes = [_]u8{0x35} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .v = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    const base_fee = BaseFeePerGas.from(11);
    try std.testing.expectError(
        error.GasPriceBelowBaseFee,
        effective_priority_fee_per_gas(tx, base_fee),
    );
}

test "effective_priority_fee_per_gas - 4844 uses fee market fields" {
    const Address = primitives.Address;
    const VersionedHash = primitives.Blob.VersionedHash;

    const hashes = [_]VersionedHash{
        VersionedHash{ .bytes = [_]u8{0x01} ++ [_]u8{0} ** 31 },
    };

    const tx = tx_mod.Eip4844Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = @as(u256, 50),
        .max_fee_per_gas = @as(u256, 120),
        .gas_limit = 21_000,
        .to = Address{ .bytes = [_]u8{0x36} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .max_fee_per_blob_gas = @as(u256, 500),
        .blob_versioned_hashes = &hashes,
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    const base_fee = BaseFeePerGas.from(100);
    const priority = try effective_priority_fee_per_gas(tx, base_fee);
    try std.testing.expectEqual(U256.from_u64(20), priority);
}

test "effective_priority_fee_per_gas - 7702 uses fee market fields" {
    const Address = primitives.Address;
    const Authorization = primitives.Authorization.Authorization;

    const tx = tx_mod.Eip7702Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = @as(u256, 60),
        .max_fee_per_gas = @as(u256, 140),
        .gas_limit = 21_000,
        .to = Address{ .bytes = [_]u8{0x37} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .authorization_list = &[_]Authorization{},
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    const base_fee = BaseFeePerGas.from(100);
    const priority = try effective_priority_fee_per_gas(tx, base_fee);
    try std.testing.expectEqual(U256.from_u64(40), priority);
}
