/// Transaction processing helpers for the EVM ↔ WorldState integration layer.
///
/// This module starts the TransactionProcessor surface by providing
/// spec-accurate transaction validation helpers used before execution.
///
/// ## Spec References
/// - `execution-specs/src/ethereum/forks/cancun/transactions.py` → validate_transaction
/// - `execution-specs/src/ethereum/forks/cancun/transactions.py` → calculate_intrinsic_cost
///
/// ## Nethermind Parallel
/// - `Nethermind.Evm/TransactionProcessing/TransactionProcessor.cs` → ValidateStatic
const std = @import("std");
const primitives = @import("primitives");
const Hardfork = primitives.Hardfork;
const tx_mod = primitives.Transaction;
const intrinsic_gas = @import("intrinsic_gas.zig");
const calculateIntrinsicGas = intrinsic_gas.calculateIntrinsicGas;
const MAX_INIT_CODE_SIZE = intrinsic_gas.MAX_INIT_CODE_SIZE;

/// Validate a transaction per execution-specs and return its intrinsic gas.
///
/// This performs the static checks that do not require state access:
/// - gas limit >= intrinsic gas
/// - nonce < 2**64 - 1
/// - init code size <= MAX_INIT_CODE_SIZE (Shanghai+ contract creation)
pub fn validateTransaction(
    tx: anytype,
    hardfork: Hardfork,
) error{ InsufficientGas, NonceOverflow, InitCodeTooLarge }!u64 {
    const Tx = @TypeOf(tx);
    comptime {
        if (Tx != tx_mod.LegacyTransaction and
            Tx != tx_mod.Eip1559Transaction and
            Tx != tx_mod.Eip4844Transaction and
            Tx != tx_mod.Eip7702Transaction)
        {
            @compileError("Unsupported transaction type for validateTransaction");
        }
    }

    const is_create = if (comptime Tx == tx_mod.Eip4844Transaction) false else tx.to == null;

    var access_list_address_count: u64 = 0;
    var access_list_storage_key_count: u64 = 0;
    if (comptime Tx == tx_mod.Eip1559Transaction or
        Tx == tx_mod.Eip4844Transaction or
        Tx == tx_mod.Eip7702Transaction)
    {
        access_list_address_count = @intCast(tx.access_list.len);
        for (tx.access_list) |entry| {
            access_list_storage_key_count += @intCast(entry.storage_keys.len);
        }
    }

    const intrinsic = calculateIntrinsicGas(.{
        .data = tx.data,
        .is_create = is_create,
        .access_list_address_count = access_list_address_count,
        .access_list_storage_key_count = access_list_storage_key_count,
        .hardfork = hardfork,
    });

    if (intrinsic > tx.gas_limit) return error.InsufficientGas;
    if (tx.nonce >= std.math.maxInt(u64)) return error.NonceOverflow;
    if (is_create and hardfork.isAtLeast(.SHANGHAI)) {
        const max_init_code_size: usize = @intCast(MAX_INIT_CODE_SIZE);
        if (tx.data.len > max_init_code_size) return error.InitCodeTooLarge;
    }

    return intrinsic;
}

// =============================================================================
// Tests
// =============================================================================

test "validateTransaction — legacy ok" {
    const Address = primitives.Address;

    const tx = tx_mod.LegacyTransaction{
        .nonce = 0,
        .gas_price = 0,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = Address{ .bytes = [_]u8{0x11} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .v = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    const intrinsic = try validateTransaction(tx, .LONDON);
    try std.testing.expectEqual(@as(u64, intrinsic_gas.TX_BASE_COST), intrinsic);
}

test "validateTransaction — legacy insufficient gas" {
    const Address = primitives.Address;

    const tx = tx_mod.LegacyTransaction{
        .nonce = 0,
        .gas_price = 0,
        .gas_limit = intrinsic_gas.TX_BASE_COST - 1,
        .to = Address{ .bytes = [_]u8{0x22} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .v = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    try std.testing.expectError(error.InsufficientGas, validateTransaction(tx, .LONDON));
}

test "validateTransaction — nonce overflow" {
    const Address = primitives.Address;

    const tx = tx_mod.LegacyTransaction{
        .nonce = std.math.maxInt(u64),
        .gas_price = 0,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = Address{ .bytes = [_]u8{0x33} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .v = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    try std.testing.expectError(error.NonceOverflow, validateTransaction(tx, .LONDON));
}

test "validateTransaction — init code size limit (Shanghai+)" {
    const allocator = std.testing.allocator;

    const size: usize = @intCast(MAX_INIT_CODE_SIZE + 1);
    const init_code = try allocator.alloc(u8, size);
    defer allocator.free(init_code);

    const tx = tx_mod.LegacyTransaction{
        .nonce = 0,
        .gas_price = 0,
        .gas_limit = intrinsic_gas.TX_BASE_COST + @as(u64, @intCast(size)) * intrinsic_gas.TX_DATA_COST_PER_NON_ZERO,
        .to = null,
        .value = 0,
        .data = init_code,
        .v = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    try std.testing.expectError(error.InitCodeTooLarge, validateTransaction(tx, .SHANGHAI));
}

test "validateTransaction — eip1559 access list intrinsic gas" {
    const Address = primitives.Address;

    const key1 = [_]u8{0x01} ** 32;
    const key2 = [_]u8{0x02} ** 32;
    const keys = [_][32]u8{ key1, key2 };

    const access_list = [_]tx_mod.AccessListItem{
        .{ .address = Address{ .bytes = [_]u8{0x44} ++ [_]u8{0} ** 19 }, .storage_keys = &keys },
    };

    const expected_gas = intrinsic_gas.TX_BASE_COST +
        intrinsic_gas.TX_ACCESS_LIST_ADDRESS_COST +
        (2 * intrinsic_gas.TX_ACCESS_LIST_STORAGE_KEY_COST);

    const tx = tx_mod.Eip1559Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 0,
        .max_fee_per_gas = 0,
        .gas_limit = expected_gas,
        .to = Address{ .bytes = [_]u8{0x55} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &access_list,
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    const intrinsic = try validateTransaction(tx, .CANCUN);
    try std.testing.expectEqual(@as(u64, expected_gas), intrinsic);
}
