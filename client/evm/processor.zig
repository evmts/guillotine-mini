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
const calculate_intrinsic_gas = intrinsic_gas.calculate_intrinsic_gas;
const MAX_INIT_CODE_SIZE = intrinsic_gas.MAX_INIT_CODE_SIZE;

fn assert_supported_tx_type(comptime Tx: type, comptime context: []const u8) void {
    if (Tx != tx_mod.LegacyTransaction and
        Tx != tx_mod.Eip2930Transaction and
        Tx != tx_mod.Eip1559Transaction and
        Tx != tx_mod.Eip4844Transaction and
        Tx != tx_mod.Eip7702Transaction)
    {
        @compileError("Unsupported transaction type for " ++ context);
    }
}

/// Validate a transaction per execution-specs and return its intrinsic gas.
///
/// This performs the static checks that do not require state access:
/// - gas limit >= max(intrinsic gas, calldata floor) (Prague+ EIP-7623)
/// - nonce < 2**64 - 1
/// - init code size <= MAX_INIT_CODE_SIZE (Shanghai+ contract creation)
pub fn validate_transaction(
    tx: anytype,
    hardfork: Hardfork,
) error{ InsufficientGas, NonceOverflow, InitCodeTooLarge, UnsupportedTransactionType }!u64 {
    const Tx = @TypeOf(tx);
    comptime assert_supported_tx_type(Tx, "validate_transaction");

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
    const intrinsic = calculate_intrinsic_gas(tx, hardfork);

    const calldata_floor = intrinsic_gas.calculate_calldata_floor_gas(tx.data, hardfork);
    const required_gas = if (calldata_floor > intrinsic) calldata_floor else intrinsic;
    if (required_gas > tx.gas_limit) return error.InsufficientGas;
    if (tx.nonce >= std.math.maxInt(u64)) return error.NonceOverflow;
    if (is_create and hardfork.isAtLeast(.SHANGHAI)) {
        const max_init_code_size: usize = @intCast(MAX_INIT_CODE_SIZE);
        if (tx.data.len > max_init_code_size) return error.InitCodeTooLarge;
    }

    return intrinsic;
}

/// Calculate the effective gas price for a transaction, enforcing base fee rules.
///
/// For EIP-1559 style transactions, this applies:
/// `effective = base_fee + min(max_priority_fee, max_fee - base_fee)`.
/// For legacy/EIP-2930 transactions, `effective = gas_price` and must be
/// >= the base fee (post-London).
pub fn calculate_effective_gas_price(
    tx: anytype,
    base_fee_per_gas: u256,
) error{ PriorityFeeGreaterThanMaxFee, InsufficientMaxFeePerGas, GasPriceBelowBaseFee, UnsupportedTransactionType }!u256 {
    const Tx = @TypeOf(tx);
    comptime assert_supported_tx_type(Tx, "calculate_effective_gas_price");

    if (comptime Tx == tx_mod.LegacyTransaction or Tx == tx_mod.Eip2930Transaction) {
        if (tx.gas_price < base_fee_per_gas) return error.GasPriceBelowBaseFee;
        return tx.gas_price;
    }

    if (tx.max_fee_per_gas < tx.max_priority_fee_per_gas) return error.PriorityFeeGreaterThanMaxFee;
    if (tx.max_fee_per_gas < base_fee_per_gas) return error.InsufficientMaxFeePerGas;

    const max_priority_allowed = tx.max_fee_per_gas - base_fee_per_gas;
    const priority_fee = if (tx.max_priority_fee_per_gas < max_priority_allowed)
        tx.max_priority_fee_per_gas
    else
        max_priority_allowed;

    return base_fee_per_gas + priority_fee;
}

// =============================================================================
// Tests
// =============================================================================

test "validate_transaction — legacy ok" {
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

    const intrinsic = try validate_transaction(tx, .LONDON);
    try std.testing.expectEqual(@as(u64, intrinsic_gas.TX_BASE_COST), intrinsic);
}

test "validate_transaction — legacy insufficient gas" {
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

    try std.testing.expectError(error.InsufficientGas, validate_transaction(tx, .LONDON));
}

test "validate_transaction — nonce overflow" {
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

    try std.testing.expectError(error.NonceOverflow, validate_transaction(tx, .LONDON));
}

test "validate_transaction — init code size limit (Shanghai+)" {
    const allocator = std.testing.allocator;

    const size: usize = @intCast(MAX_INIT_CODE_SIZE + 1);
    const init_code = try allocator.alloc(u8, size);
    defer allocator.free(init_code);

    var tx = tx_mod.LegacyTransaction{
        .nonce = 0,
        .gas_price = 0,
        .gas_limit = 0,
        .to = null,
        .value = 0,
        .data = init_code,
        .v = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };
    const intrinsic = intrinsic_gas.calculate_intrinsic_gas(tx, .SHANGHAI);
    tx.gas_limit = intrinsic;

    try std.testing.expectError(error.InitCodeTooLarge, validate_transaction(tx, .SHANGHAI));
}

test "validate_transaction — eip1559 access list intrinsic gas" {
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

    const intrinsic = try validate_transaction(tx, .CANCUN);
    try std.testing.expectEqual(@as(u64, expected_gas), intrinsic);
}

test "validate_transaction — eip2930 access list intrinsic gas" {
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

    const intrinsic = try validate_transaction(tx, .BERLIN);
    try std.testing.expectEqual(@as(u64, expected_gas), intrinsic);
}

test "validate_transaction — eip1559 rejected before London" {
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

    try std.testing.expectError(error.UnsupportedTransactionType, validate_transaction(tx, .BERLIN));
}

test "validate_transaction — eip2930 rejected before Berlin" {
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

    try std.testing.expectError(error.UnsupportedTransactionType, validate_transaction(tx, .ISTANBUL));
}

test "validate_transaction — eip4844 rejected before Cancun" {
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

    try std.testing.expectError(error.UnsupportedTransactionType, validate_transaction(tx, .SHANGHAI));
}

test "validate_transaction — eip7702 rejected before Prague" {
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

    try std.testing.expectError(error.UnsupportedTransactionType, validate_transaction(tx, .CANCUN));
}

test "validate_transaction — eip4844 intrinsic gas" {
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

    const intrinsic = try validate_transaction(tx, .CANCUN);
    try std.testing.expectEqual(@as(u64, intrinsic_gas.TX_BASE_COST), intrinsic);
}

test "validate_transaction — prague calldata floor enforced" {
    const Address = primitives.Address;

    const data = [_]u8{0x01}; // one non-zero byte => floor > intrinsic
    var tx = tx_mod.LegacyTransaction{
        .nonce = 0,
        .gas_price = 0,
        .gas_limit = 0,
        .to = Address{ .bytes = [_]u8{0xAA} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &data,
        .v = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };
    const intrinsic = intrinsic_gas.calculate_intrinsic_gas(tx, .PRAGUE);
    tx.gas_limit = intrinsic;

    try std.testing.expectError(error.InsufficientGas, validate_transaction(tx, .PRAGUE));
}

test "validate_transaction — eip7702 authorization intrinsic gas" {
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

    const intrinsic = try validate_transaction(tx, .PRAGUE);
    try std.testing.expectEqual(@as(u64, expected), intrinsic);
}

test "calculate_effective_gas_price — legacy ok" {
    const Address = primitives.Address;

    const tx = tx_mod.LegacyTransaction{
        .nonce = 0,
        .gas_price = 100,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = Address{ .bytes = [_]u8{0x10} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .v = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    const effective = try calculate_effective_gas_price(tx, 10);
    try std.testing.expectEqual(@as(u256, 100), effective);
}

test "calculate_effective_gas_price — legacy rejects below base fee" {
    const Address = primitives.Address;

    const tx = tx_mod.LegacyTransaction{
        .nonce = 0,
        .gas_price = 5,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = Address{ .bytes = [_]u8{0x11} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .v = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    try std.testing.expectError(error.GasPriceBelowBaseFee, calculate_effective_gas_price(tx, 10));
}

test "calculate_effective_gas_price — eip1559 caps priority fee" {
    const Address = primitives.Address;

    const tx = tx_mod.Eip1559Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 20,
        .max_fee_per_gas = 25,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = Address{ .bytes = [_]u8{0x12} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    const effective = try calculate_effective_gas_price(tx, 10);
    try std.testing.expectEqual(@as(u256, 25), effective);
}

test "calculate_effective_gas_price — eip1559 priority fee above max fee" {
    const Address = primitives.Address;

    const tx = tx_mod.Eip1559Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 12,
        .max_fee_per_gas = 10,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = Address{ .bytes = [_]u8{0x13} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    try std.testing.expectError(error.PriorityFeeGreaterThanMaxFee, calculate_effective_gas_price(tx, 1));
}

test "calculate_effective_gas_price — eip1559 max fee below base fee" {
    const Address = primitives.Address;

    const tx = tx_mod.Eip1559Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 1,
        .max_fee_per_gas = 9,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = Address{ .bytes = [_]u8{0x14} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    try std.testing.expectError(error.InsufficientMaxFeePerGas, calculate_effective_gas_price(tx, 10));
}

/// Pre-price a transaction: validate statically and compute effective gas price.
///
/// Returns both the intrinsic gas and the effective gas price according to the
/// active hardfork and base fee. This combines validate_transaction (static
/// checks + intrinsic gas) and calculate_effective_gas_price (London+ rules).
///
/// Errors are the union of validation and pricing failures. Fork-gating is
/// enforced via validate_transaction.
pub fn preprice_transaction(
    tx: anytype,
    hardfork: Hardfork,
    base_fee_per_gas: u256,
) error{
    InsufficientGas,
    NonceOverflow,
    InitCodeTooLarge,
    UnsupportedTransactionType,
    PriorityFeeGreaterThanMaxFee,
    InsufficientMaxFeePerGas,
    GasPriceBelowBaseFee,
}!struct { intrinsic: u64, effective_gas_price: u256 } {
    const intrinsic = try validate_transaction(tx, hardfork);
    const effective = try calculate_effective_gas_price(tx, base_fee_per_gas);
    return .{ .intrinsic = intrinsic, .effective_gas_price = effective };
}

// -----------------------------------------------------------------------------
// preprice_transaction Tests
// -----------------------------------------------------------------------------

test "preprice_transaction — legacy ok" {
    const Address = primitives.Address;

    const tx = tx_mod.LegacyTransaction{
        .nonce = 0,
        .gas_price = 100,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = Address{ .bytes = [_]u8{0x20} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .v = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    const priced = try preprice_transaction(tx, .LONDON, 10);
    try std.testing.expectEqual(@as(u64, intrinsic_gas.TX_BASE_COST), priced.intrinsic);
    try std.testing.expectEqual(@as(u256, 100), priced.effective_gas_price);
}

test "preprice_transaction — eip2930 ok" {
    const Address = primitives.Address;

    const tx = tx_mod.Eip2930Transaction{
        .chain_id = 1,
        .nonce = 0,
        .gas_price = 50,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = Address{ .bytes = [_]u8{0x21} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    const priced = try preprice_transaction(tx, .LONDON, 10);
    try std.testing.expectEqual(@as(u64, intrinsic_gas.TX_BASE_COST), priced.intrinsic);
    try std.testing.expectEqual(@as(u256, 50), priced.effective_gas_price);
}

test "preprice_transaction — eip1559 ok (cap priority)" {
    const Address = primitives.Address;

    const tx = tx_mod.Eip1559Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 20,
        .max_fee_per_gas = 25,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = Address{ .bytes = [_]u8{0x22} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    const priced = try preprice_transaction(tx, .LONDON, 10);
    // intrinsic base cost only
    try std.testing.expectEqual(@as(u64, intrinsic_gas.TX_BASE_COST), priced.intrinsic);
    // effective = base_fee(10) + min(20, 25-10=15) = 25
    try std.testing.expectEqual(@as(u256, 25), priced.effective_gas_price);
}

test "preprice_transaction — eip4844 ok" {
    const Address = primitives.Address;
    const VersionedHash = primitives.Blob.VersionedHash;

    const hashes = [_]VersionedHash{.{ .bytes = [_]u8{0x01} ++ [_]u8{0} ** 31 }};

    const tx = tx_mod.Eip4844Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 1,
        .max_fee_per_gas = 100,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = Address{ .bytes = [_]u8{0x23} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .max_fee_per_blob_gas = 1,
        .blob_versioned_hashes = &hashes,
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    const priced = try preprice_transaction(tx, .CANCUN, 10);
    try std.testing.expectEqual(@as(u64, intrinsic_gas.TX_BASE_COST), priced.intrinsic);
    try std.testing.expectEqual(@as(u256, 11), priced.effective_gas_price); // 10 + min(1, 90)
}

test "preprice_transaction — eip7702 ok with authorization intrinsic" {
    const Address = primitives.Address;
    const Authorization = primitives.Authorization.Authorization;

    const auths = [_]Authorization{.{
        .chain_id = 1,
        .address = Address{ .bytes = [_]u8{0x24} ++ [_]u8{0} ** 19 },
        .nonce = 0,
        .v = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    }};

    const expected_intrinsic = intrinsic_gas.TX_BASE_COST + intrinsic_gas.TX_AUTHORIZATION_COST_PER_ITEM;

    const tx = tx_mod.Eip7702Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 2,
        .max_fee_per_gas = 20,
        .gas_limit = expected_intrinsic,
        .to = Address{ .bytes = [_]u8{0x25} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .authorization_list = &auths,
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    const priced = try preprice_transaction(tx, .PRAGUE, 10);
    try std.testing.expectEqual(@as(u64, expected_intrinsic), priced.intrinsic);
    try std.testing.expectEqual(@as(u256, 12), priced.effective_gas_price); // 10 + min(2, 10)
}

test "preprice_transaction — fork gating enforced" {
    const Address = primitives.Address;
    const VersionedHash = primitives.Blob.VersionedHash;
    const Authorization = primitives.Authorization.Authorization;

    // 2930 before Berlin
    const tx2930 = tx_mod.Eip2930Transaction{
        .chain_id = 1,
        .nonce = 0,
        .gas_price = 10,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = Address{ .bytes = [_]u8{0x26} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };
    try std.testing.expectError(error.UnsupportedTransactionType, preprice_transaction(tx2930, .ISTANBUL, 0));

    // 1559 before London
    const tx1559 = tx_mod.Eip1559Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 0,
        .max_fee_per_gas = 0,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = Address{ .bytes = [_]u8{0x27} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };
    try std.testing.expectError(error.UnsupportedTransactionType, preprice_transaction(tx1559, .BERLIN, 0));

    // 4844 before Cancun
    const hashes = [_]VersionedHash{.{ .bytes = [_]u8{0x01} ++ [_]u8{0} ** 31 }};
    const tx4844 = tx_mod.Eip4844Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 0,
        .max_fee_per_gas = 0,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = Address{ .bytes = [_]u8{0x28} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .max_fee_per_blob_gas = 1,
        .blob_versioned_hashes = &hashes,
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };
    try std.testing.expectError(error.UnsupportedTransactionType, preprice_transaction(tx4844, .SHANGHAI, 0));

    // 7702 before Prague
    const auths = [_]Authorization{.{
        .chain_id = 1,
        .address = Address{ .bytes = [_]u8{0x29} ++ [_]u8{0} ** 19 },
        .nonce = 0,
        .v = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    }};
    const tx7702 = tx_mod.Eip7702Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 0,
        .max_fee_per_gas = 0,
        .gas_limit = intrinsic_gas.TX_BASE_COST + intrinsic_gas.TX_AUTHORIZATION_COST_PER_ITEM,
        .to = Address{ .bytes = [_]u8{0x2A} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .authorization_list = &auths,
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };
    try std.testing.expectError(error.UnsupportedTransactionType, preprice_transaction(tx7702, .CANCUN, 0));
}
