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
/// - gas limit >= max(intrinsic gas, calldata floor) (Prague+ EIP-7623)
/// - nonce < 2**64 - 1
/// - init code size <= MAX_INIT_CODE_SIZE (Shanghai+ contract creation)
pub fn validateTransaction(
    tx: anytype,
    hardfork: Hardfork,
) error{ InsufficientGas, NonceOverflow, InitCodeTooLarge, UnsupportedTransactionType }!u64 {
    const Tx = @TypeOf(tx);
    comptime {
        if (Tx != tx_mod.LegacyTransaction and
            Tx != tx_mod.Eip2930Transaction and
            Tx != tx_mod.Eip1559Transaction and
            Tx != tx_mod.Eip4844Transaction and
            Tx != tx_mod.Eip7702Transaction)
        {
            @compileError("Unsupported transaction type for validateTransaction");
        }
    }

    const required_fork: ?Hardfork = comptime blk: {
        if (Tx == tx_mod.Eip2930Transaction) break :blk .BERLIN;
        if (Tx == tx_mod.Eip1559Transaction) break :blk .LONDON;
        if (Tx == tx_mod.Eip4844Transaction) break :blk .CANCUN;
        if (Tx == tx_mod.Eip7702Transaction) break :blk .PRAGUE;
        break :blk null;
    };
    if (required_fork) |fork| {
        if (hardfork.isBefore(fork)) return error.UnsupportedTransactionType;
    }

    const is_create = if (comptime Tx == tx_mod.Eip4844Transaction) false else tx.to == null;

    var access_list_address_count: u64 = 0;
    var access_list_storage_key_count: u64 = 0;
    if (comptime Tx == tx_mod.Eip2930Transaction or
        Tx == tx_mod.Eip1559Transaction or
        Tx == tx_mod.Eip4844Transaction or
        Tx == tx_mod.Eip7702Transaction)
    {
        access_list_address_count = @intCast(tx.access_list.len);
        for (tx.access_list) |entry| {
            access_list_storage_key_count += @intCast(entry.storage_keys.len);
        }
    }

    var authorization_count: u64 = 0;
    if (comptime Tx == tx_mod.Eip7702Transaction) {
        authorization_count = @intCast(tx.authorization_list.len);
    }

    const intrinsic = calculateIntrinsicGas(.{
        .data = tx.data,
        .is_create = is_create,
        .access_list_address_count = access_list_address_count,
        .access_list_storage_key_count = access_list_storage_key_count,
        .authorization_count = authorization_count,
        .hardfork = hardfork,
    });

    const calldata_floor = intrinsic_gas.calculateCalldataFloorGas(tx.data, hardfork);
    const required_gas = if (calldata_floor > intrinsic) calldata_floor else intrinsic;
    if (required_gas > tx.gas_limit) return error.InsufficientGas;
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

    const intrinsic = intrinsic_gas.calculateIntrinsicGas(.{
        .data = init_code,
        .is_create = true,
        .hardfork = .SHANGHAI,
    });

    const tx = tx_mod.LegacyTransaction{
        .nonce = 0,
        .gas_price = 0,
        .gas_limit = intrinsic,
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

test "validateTransaction — eip2930 access list intrinsic gas" {
    const Address = primitives.Address;

    const key1 = [_]u8{0x0A} ** 32;
    const key2 = [_]u8{0x0B} ** 32;
    const keys = [_][32]u8{ key1, key2 };

    const access_list = [_]tx_mod.AccessListItem{
        .{ .address = Address{ .bytes = [_]u8{0x5A} ++ [_]u8{0} ** 19 }, .storage_keys = &keys },
    };

    const expected_gas = intrinsic_gas.TX_BASE_COST +
        intrinsic_gas.TX_ACCESS_LIST_ADDRESS_COST +
        (2 * intrinsic_gas.TX_ACCESS_LIST_STORAGE_KEY_COST);

    const tx = tx_mod.Eip2930Transaction{
        .chain_id = 1,
        .nonce = 0,
        .gas_price = 0,
        .gas_limit = expected_gas,
        .to = Address{ .bytes = [_]u8{0x5B} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &access_list,
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    const intrinsic = try validateTransaction(tx, .BERLIN);
    try std.testing.expectEqual(@as(u64, expected_gas), intrinsic);
}

test "validateTransaction — eip1559 rejected before London" {
    const Address = primitives.Address;

    const tx = tx_mod.Eip1559Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 0,
        .max_fee_per_gas = 0,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = Address{ .bytes = [_]u8{0x66} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    try std.testing.expectError(error.UnsupportedTransactionType, validateTransaction(tx, .BERLIN));
}

test "validateTransaction — eip2930 rejected before Berlin" {
    const Address = primitives.Address;

    const tx = tx_mod.Eip2930Transaction{
        .chain_id = 1,
        .nonce = 0,
        .gas_price = 0,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = Address{ .bytes = [_]u8{0x6A} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    try std.testing.expectError(error.UnsupportedTransactionType, validateTransaction(tx, .ISTANBUL));
}

test "validateTransaction — eip4844 rejected before Cancun" {
    const Address = primitives.Address;
    const VersionedHash = primitives.Blob.VersionedHash;

    const hashes = [_]VersionedHash{.{ .bytes = [_]u8{0x01} ++ [_]u8{0} ** 31 }};

    const tx = tx_mod.Eip4844Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 0,
        .max_fee_per_gas = 0,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = Address{ .bytes = [_]u8{0x77} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .max_fee_per_blob_gas = 1,
        .blob_versioned_hashes = &hashes,
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    try std.testing.expectError(error.UnsupportedTransactionType, validateTransaction(tx, .SHANGHAI));
}

test "validateTransaction — eip7702 rejected before Prague" {
    const Address = primitives.Address;
    const Authorization = primitives.Authorization.Authorization;

    const auths = [_]Authorization{.{
        .chain_id = 1,
        .address = Address{ .bytes = [_]u8{0x88} ++ [_]u8{0} ** 19 },
        .nonce = 0,
        .v = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    }};

    const tx = tx_mod.Eip7702Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 0,
        .max_fee_per_gas = 0,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = Address{ .bytes = [_]u8{0x99} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .authorization_list = &auths,
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    try std.testing.expectError(error.UnsupportedTransactionType, validateTransaction(tx, .CANCUN));
}

test "validateTransaction — eip4844 intrinsic gas" {
    const Address = primitives.Address;
    const VersionedHash = primitives.Blob.VersionedHash;

    const hashes = [_]VersionedHash{.{ .bytes = [_]u8{0x01} ++ [_]u8{0} ** 31 }};

    const tx = tx_mod.Eip4844Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 0,
        .max_fee_per_gas = 0,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = Address{ .bytes = [_]u8{0xAB} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .max_fee_per_blob_gas = 1,
        .blob_versioned_hashes = &hashes,
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    const intrinsic = try validateTransaction(tx, .CANCUN);
    try std.testing.expectEqual(@as(u64, intrinsic_gas.TX_BASE_COST), intrinsic);
}

test "validateTransaction — prague calldata floor enforced" {
    const Address = primitives.Address;

    const data = [_]u8{0x01}; // one non-zero byte => floor > intrinsic
    const intrinsic = intrinsic_gas.calculateIntrinsicGas(.{
        .data = &data,
        .hardfork = .PRAGUE,
    });

    const tx = tx_mod.LegacyTransaction{
        .nonce = 0,
        .gas_price = 0,
        .gas_limit = intrinsic,
        .to = Address{ .bytes = [_]u8{0xAA} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &data,
        .v = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    try std.testing.expectError(error.InsufficientGas, validateTransaction(tx, .PRAGUE));
}

test "validateTransaction — eip7702 authorization intrinsic gas" {
    const Address = primitives.Address;
    const Authorization = primitives.Authorization.Authorization;

    const auths = [_]Authorization{
        .{
            .chain_id = 1,
            .address = Address{ .bytes = [_]u8{0xBB} ++ [_]u8{0} ** 19 },
            .nonce = 0,
            .v = 0,
            .r = [_]u8{0} ** 32,
            .s = [_]u8{0} ** 32,
        },
        .{
            .chain_id = 1,
            .address = Address{ .bytes = [_]u8{0xCC} ++ [_]u8{0} ** 19 },
            .nonce = 1,
            .v = 0,
            .r = [_]u8{0} ** 32,
            .s = [_]u8{0} ** 32,
        },
    };

    const expected = intrinsic_gas.TX_BASE_COST + (2 * intrinsic_gas.TX_AUTHORIZATION_COST_PER_ITEM);

    const tx = tx_mod.Eip7702Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 0,
        .max_fee_per_gas = 0,
        .gas_limit = expected,
        .to = Address{ .bytes = [_]u8{0xDD} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .authorization_list = &auths,
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    const intrinsic = try validateTransaction(tx, .PRAGUE);
    try std.testing.expectEqual(@as(u64, expected), intrinsic);
}
