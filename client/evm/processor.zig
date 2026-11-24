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
const primitives = @import("voltaire");
const EffectiveGasPrice = primitives.EffectiveGasPrice;
const Hardfork = primitives.Hardfork;
const tx_mod = primitives.Transaction;
const intrinsic_gas = @import("intrinsic_gas.zig");
const calculate_intrinsic_gas = intrinsic_gas.calculate_intrinsic_gas;
const MAX_INIT_CODE_SIZE = intrinsic_gas.MAX_INIT_CODE_SIZE;

/// EIP-7825 (Osaka+): maximum gas limit a single transaction may declare (2^24).
/// Mirrors `TX_MAX_GAS_LIMIT` in execution-specs `forks/osaka/transactions.py`.
pub const MAX_TX_GAS_LIMIT_OSAKA: u64 = 1 << 24;

inline fn to_bytes_be(x: u256) [32]u8 {
    var out: [32]u8 = undefined;
    std.mem.writeInt(u256, &out, x, .big);
    return out;
}

/// Convert base/max/tip to EffectiveGasPrice.U256 and compute the 1559-style
/// effective gas price. Shared by both pricing functions to avoid duplication.
inline fn calc_1559_effective(base_fee_per_gas: u256, max_fee_per_gas: u256, max_priority_fee_per_gas: u256) EffectiveGasPrice {
    var base_bytes = to_bytes_be(base_fee_per_gas);
    var max_bytes = to_bytes_be(max_fee_per_gas);
    var tip_bytes = to_bytes_be(max_priority_fee_per_gas);
    const U = EffectiveGasPrice.U256;
    const base_u = U.from_be_bytes(base_bytes[0..]);
    const max_u = U.from_be_bytes(max_bytes[0..]);
    const tip_u = U.from_be_bytes(tip_bytes[0..]);

    const allowed_opt = max_u.checked_sub(base_u);
    const allowed = allowed_opt orelse U.ZERO;
    const eff_tip = if (tip_u.lt(allowed)) tip_u else allowed;
    var final = base_u.wrapping_add(eff_tip);
    if (final.gt(max_u)) final = max_u;
    return EffectiveGasPrice.fromU256(final);
}

// Reuse the single source of truth defined in intrinsic_gas.zig
const assert_supported_tx_type = intrinsic_gas.assert_supported_tx_type;

/// Version byte every EIP-4844 blob versioned hash must start with.
/// Mirrors `VERSIONED_HASH_VERSION_KZG` in execution-specs `forks/cancun/fork.py`.
pub const VERSIONED_HASH_VERSION_KZG: u8 = primitives.Blob.BLOB_COMMITMENT_VERSION_KZG;

/// Maximum blobs one transaction may carry under `hardfork`.
///
/// Cancun and Prague bound a transaction only by the block blob-gas cap
/// (`MAX_BLOB_GAS_PER_BLOCK / GAS_PER_BLOB` = 6 and 9). Osaka adds a fixed
/// per-transaction `BLOB_COUNT_LIMIT` of 6 (EIP-7594).
pub fn max_blobs_per_transaction(hardfork: Hardfork) u64 {
    if (hardfork.isAtLeast(.OSAKA)) return 6;
    if (hardfork.isAtLeast(.PRAGUE)) return 9;
    return 6;
}

/// Static validation errors returned by `validate_transaction`.
pub const ValidationError = error{
    InsufficientGas,
    NonceOverflow,
    InitCodeTooLarge,
    UnsupportedTransactionType,
    TransactionGasLimitExceeded,
    /// EIP-4844: a blob transaction must carry at least one blob (`NoBlobDataError`).
    EmptyBlobVersionedHashes,
    /// EIP-4844: a versioned hash does not start with `VERSIONED_HASH_VERSION_KZG`.
    InvalidBlobVersionedHash,
    /// EIP-4844/EIP-7594: more blobs than `max_blobs_per_transaction(hardfork)`.
    TooManyBlobs,
    /// EIP-7702: a set-code transaction must carry at least one authorization.
    EmptyAuthorizationList,
    /// EIP-7702: a set-code transaction cannot create a contract (`to == null`).
    SetCodeTransactionCreate,
};

/// Validate a transaction per execution-specs and return its intrinsic gas.
///
/// This performs the static checks that do not require state access:
/// - gas limit >= max(intrinsic gas, calldata floor) (Prague+ EIP-7623)
/// - nonce < 2**64 - 1
/// - init code size <= MAX_INIT_CODE_SIZE (Shanghai+ contract creation)
/// - gas limit <= MAX_TX_GAS_LIMIT_OSAKA (Osaka+ EIP-7825)
/// - EIP-4844: 1..=max_blobs_per_transaction blobs, each with the KZG version byte
/// - EIP-7702: non-empty authorization list and a non-null `to`
pub fn validate_transaction(
    tx: anytype,
    hardfork: Hardfork,
) ValidationError!u64 {
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

    if (comptime Tx == tx_mod.Eip4844Transaction) {
        if (tx.blob_versioned_hashes.len == 0) return error.EmptyBlobVersionedHashes;
        if (tx.blob_versioned_hashes.len > max_blobs_per_transaction(hardfork)) return error.TooManyBlobs;
        for (tx.blob_versioned_hashes) |hash| {
            if (hash.bytes[0] != VERSIONED_HASH_VERSION_KZG) return error.InvalidBlobVersionedHash;
        }
    }
    if (comptime Tx == tx_mod.Eip7702Transaction) {
        if (tx.to == null) return error.SetCodeTransactionCreate;
        if (tx.authorization_list.len == 0) return error.EmptyAuthorizationList;
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
    if (hardfork.isAtLeast(.OSAKA) and tx.gas_limit > MAX_TX_GAS_LIMIT_OSAKA) {
        return error.TransactionGasLimitExceeded;
    }

    return intrinsic;
}

/// Legacy and EIP-2930 transactions carry a single `gas_price`.
inline fn uses_gas_price(comptime Tx: type) bool {
    return Tx == tx_mod.LegacyTransaction or Tx == tx_mod.Eip2930Transaction;
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
) error{ PriorityFeeGreaterThanMaxFee, InsufficientMaxFeePerGas, GasPriceBelowBaseFee, UnsupportedTransactionType }!EffectiveGasPrice {
    const Tx = @TypeOf(tx);
    comptime assert_supported_tx_type(Tx, "calculate_effective_gas_price");

    if (comptime uses_gas_price(Tx)) {
        if (tx.gas_price < base_fee_per_gas) return error.GasPriceBelowBaseFee;
        return EffectiveGasPrice.fromU256(EffectiveGasPrice.U256.from_be_bytes(to_bytes_be(tx.gas_price)[0..]));
    }

    if (tx.max_fee_per_gas < tx.max_priority_fee_per_gas) return error.PriorityFeeGreaterThanMaxFee;
    if (tx.max_fee_per_gas < base_fee_per_gas) return error.InsufficientMaxFeePerGas;

    return calc_1559_effective(base_fee_per_gas, tx.max_fee_per_gas, tx.max_priority_fee_per_gas);
}

/// Hardfork-aware variant: applies pre-/post-London rules explicitly.
/// - Pre-London: legacy/2930 → effective = gas_price (no base fee gating;
///   validate_transaction still rejects 2930 before Berlin)
///               1559/4844/7702 → UnsupportedTransactionType
/// - London and later: same rules as .
pub fn calculate_effective_gas_price_hardfork(
    tx: anytype,
    hardfork: Hardfork,
    base_fee_per_gas: u256,
) error{ PriorityFeeGreaterThanMaxFee, InsufficientMaxFeePerGas, GasPriceBelowBaseFee, UnsupportedTransactionType }!EffectiveGasPrice {
    const Tx = @TypeOf(tx);
    comptime assert_supported_tx_type(Tx, "calculate_effective_gas_price_hardfork");

    if (hardfork.isBefore(.LONDON)) {
        if (comptime uses_gas_price(Tx)) {
            return EffectiveGasPrice.fromU256(EffectiveGasPrice.U256.from_be_bytes(to_bytes_be(tx.gas_price)[0..]));
        }
        return error.UnsupportedTransactionType;
    }

    // London+
    if (comptime uses_gas_price(Tx)) {
        if (tx.gas_price < base_fee_per_gas) return error.GasPriceBelowBaseFee;
        return EffectiveGasPrice.fromU256(EffectiveGasPrice.U256.from_be_bytes(to_bytes_be(tx.gas_price)[0..]));
    }

    if (tx.max_fee_per_gas < tx.max_priority_fee_per_gas) return error.PriorityFeeGreaterThanMaxFee;
    if (tx.max_fee_per_gas < base_fee_per_gas) return error.InsufficientMaxFeePerGas;

    return calc_1559_effective(base_fee_per_gas, tx.max_fee_per_gas, tx.max_priority_fee_per_gas);
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

fn eip7825_test_tx(gas_limit: u64) tx_mod.LegacyTransaction {
    return .{
        .nonce = 0,
        .gas_price = 0,
        .gas_limit = gas_limit,
        .to = primitives.Address{ .bytes = [_]u8{0x78} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .v = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };
}

test "validate_transaction — EIP-7825 cap not enforced before Osaka" {
    const intrinsic = try validate_transaction(eip7825_test_tx(MAX_TX_GAS_LIMIT_OSAKA + 1), .PRAGUE);
    try std.testing.expectEqual(@as(u64, intrinsic_gas.TX_BASE_COST), intrinsic);
    _ = try validate_transaction(eip7825_test_tx(30_000_000), .PRAGUE);
}

test "validate_transaction — EIP-7825 cap allows exactly 2^24 on Osaka" {
    try std.testing.expectEqual(@as(u64, 16_777_216), MAX_TX_GAS_LIMIT_OSAKA);
    const intrinsic = try validate_transaction(eip7825_test_tx(16_777_216), .OSAKA);
    try std.testing.expectEqual(@as(u64, intrinsic_gas.TX_BASE_COST), intrinsic);
}

test "validate_transaction — EIP-7825 cap rejects 2^24 + 1 on Osaka" {
    try std.testing.expectError(
        error.TransactionGasLimitExceeded,
        validate_transaction(eip7825_test_tx(16_777_217), .OSAKA),
    );
    try std.testing.expectError(
        error.TransactionGasLimitExceeded,
        preprice_transaction(eip7825_test_tx(16_777_217), .OSAKA, 0),
    );
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

// EIP-2930 removed from primitives — access lists covered by 1559/4844/7702.
// Keep an equivalent 1559 case.
test "validate_transaction — 1559 access list intrinsic gas" {
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

    const tx = tx_mod.Eip1559Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 0,
        .max_fee_per_gas = 0,
        .gas_limit = expected_gas,
        .to = Address{ .bytes = [_]u8{0x5B} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &access_list,
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    // EIP-1559 activates at London; Berlin must reject 1559 type.
    const intrinsic = try validate_transaction(tx, .LONDON);
    try std.testing.expectEqual(@as(u64, expected_gas), intrinsic);
}

test "validate_transaction — eip1559 rejected before London (duplicate removed)" {
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

// 2930 variant removed; 1559 is gated at London
test "validate_transaction — eip1559 rejected before London" {
    const Address = primitives.Address;

    const tx = tx_mod.Eip1559Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 0,
        .max_fee_per_gas = 0,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = Address{ .bytes = [_]u8{0x6A} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    try std.testing.expectError(error.UnsupportedTransactionType, validate_transaction(tx, .BERLIN));
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
    try std.testing.expectEqual(@as(u64, 100), try effective.toU64());
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
    try std.testing.expectEqual(@as(u64, 25), try effective.toU64());
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

test "calculate_effective_gas_price_hardfork — legacy pre-London ignores base fee" {
    const Address = primitives.Address;
    const tx = tx_mod.LegacyTransaction{
        .nonce = 0,
        .gas_price = 5,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = Address{ .bytes = [_]u8{0xFE} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .v = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };
    const eff = try calculate_effective_gas_price_hardfork(tx, .BERLIN, 10);
    try std.testing.expectEqual(@as(u64, 5), try eff.toU64());
}

test "calculate_effective_gas_price_hardfork — eip1559 rejected before London" {
    const Address = primitives.Address;
    const tx = tx_mod.Eip1559Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 1,
        .max_fee_per_gas = 10,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = Address{ .bytes = [_]u8{0xEF} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };
    try std.testing.expectError(error.UnsupportedTransactionType, calculate_effective_gas_price_hardfork(tx, .BERLIN, 0));
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
) (ValidationError || error{
    PriorityFeeGreaterThanMaxFee,
    InsufficientMaxFeePerGas,
    GasPriceBelowBaseFee,
})!struct { intrinsic: u64, effective_gas_price: EffectiveGasPrice } {
    const intrinsic = try validate_transaction(tx, hardfork);
    const effective = try calculate_effective_gas_price_hardfork(tx, hardfork, base_fee_per_gas);
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
    try std.testing.expectEqual(@as(u64, 100), try priced.effective_gas_price.toU64());
}

test "preprice_transaction — eip1559 (with gas_price) treated per fork" {
    const Address = primitives.Address;

    const tx = tx_mod.Eip1559Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 0,
        .max_fee_per_gas = 50,
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
    try std.testing.expectEqual(@as(u64, 10), try priced.effective_gas_price.toU64());
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
    try std.testing.expectEqual(@as(u64, 25), try priced.effective_gas_price.toU64());
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
    try std.testing.expectEqual(@as(u64, 11), try priced.effective_gas_price.toU64()); // 10 + min(1, 90)
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
    try std.testing.expectEqual(@as(u64, 12), try priced.effective_gas_price.toU64()); // 10 + min(2, 10)
}

test "preprice_transaction — fork gating enforced" {
    const Address = primitives.Address;
    const VersionedHash = primitives.Blob.VersionedHash;
    const Authorization = primitives.Authorization.Authorization;

    // 2930 before Berlin
    // 2930 removed — test 1559 gating instead handled elsewhere

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

// -----------------------------------------------------------------------------
// Round 1 fixes: EIP-2930 type-1, EIP-4844 blob list, EIP-7702 authorization list
// -----------------------------------------------------------------------------

fn r1_address(byte: u8) primitives.Address {
    return .{ .bytes = [_]u8{byte} ++ [_]u8{0} ** 19 };
}

fn r1_eip2930_tx(gas_price: u256, gas_limit: u64, access_list_items: []const tx_mod.AccessListItem) tx_mod.Eip2930Transaction {
    return .{
        .chain_id = 1,
        .nonce = 0,
        .gas_price = gas_price,
        .gas_limit = gas_limit,
        .to = r1_address(0x50),
        .value = 0,
        .data = &[_]u8{},
        .access_list = access_list_items,
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };
}

fn r1_blob_tx(hashes: []const primitives.Blob.VersionedHash) tx_mod.Eip4844Transaction {
    return .{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 0,
        .max_fee_per_gas = 0,
        .gas_limit = intrinsic_gas.TX_BASE_COST,
        .to = r1_address(0x51),
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .max_fee_per_blob_gas = 1,
        .blob_versioned_hashes = hashes,
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };
}

fn r1_set_code_tx(to: ?primitives.Address, auths: []const primitives.Authorization.Authorization) tx_mod.Eip7702Transaction {
    return .{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 0,
        .max_fee_per_gas = 0,
        .gas_limit = 100_000,
        .to = to,
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .authorization_list = auths,
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };
}

const r1_kzg_hash = primitives.Blob.VersionedHash{ .bytes = [_]u8{VERSIONED_HASH_VERSION_KZG} ++ [_]u8{0} ** 31 };

const r1_auth = primitives.Authorization.Authorization{
    .chain_id = 1,
    .address = primitives.Address{ .bytes = [_]u8{0x52} ++ [_]u8{0} ** 19 },
    .nonce = 0,
    .v = 0,
    .r = [_]u8{0} ** 32,
    .s = [_]u8{0} ** 32,
};

test "validate_transaction — eip2930 accepted on Berlin with access list intrinsic gas" {
    const keys = [_][32]u8{[_]u8{0x01} ** 32};
    const list = [_]tx_mod.AccessListItem{.{ .address = r1_address(0x53), .storage_keys = &keys }};
    const expected: u64 = intrinsic_gas.TX_BASE_COST + intrinsic_gas.TX_ACCESS_LIST_ADDRESS_COST +
        intrinsic_gas.TX_ACCESS_LIST_STORAGE_KEY_COST;
    try std.testing.expectEqual(expected, try validate_transaction(r1_eip2930_tx(0, expected, &list), .BERLIN));
    try std.testing.expectError(error.InsufficientGas, validate_transaction(r1_eip2930_tx(0, expected - 1, &list), .BERLIN));
}

test "validate_transaction — eip2930 rejected before Berlin" {
    try std.testing.expectError(
        error.UnsupportedTransactionType,
        validate_transaction(r1_eip2930_tx(0, intrinsic_gas.TX_BASE_COST, &.{}), .MUIR_GLACIER),
    );
}

test "preprice_transaction — eip2930 uses gas_price before and after London" {
    const berlin = try preprice_transaction(r1_eip2930_tx(7, intrinsic_gas.TX_BASE_COST, &.{}), .BERLIN, 0);
    try std.testing.expectEqual(@as(u64, 7), try berlin.effective_gas_price.toU64());

    const london = try preprice_transaction(r1_eip2930_tx(7, intrinsic_gas.TX_BASE_COST, &.{}), .LONDON, 5);
    try std.testing.expectEqual(@as(u64, 7), try london.effective_gas_price.toU64());

    try std.testing.expectError(
        error.GasPriceBelowBaseFee,
        preprice_transaction(r1_eip2930_tx(4, intrinsic_gas.TX_BASE_COST, &.{}), .LONDON, 5),
    );
}

test "validate_transaction — eip4844 rejects empty blob_versioned_hashes" {
    try std.testing.expectError(error.EmptyBlobVersionedHashes, validate_transaction(r1_blob_tx(&.{}), .CANCUN));
    try std.testing.expectError(error.EmptyBlobVersionedHashes, validate_transaction(r1_blob_tx(&.{}), .OSAKA));
}

test "validate_transaction — eip4844 rejects non-KZG versioned hash" {
    const bad = [_]primitives.Blob.VersionedHash{ r1_kzg_hash, .{ .bytes = [_]u8{0x02} ++ [_]u8{0} ** 31 } };
    try std.testing.expectError(error.InvalidBlobVersionedHash, validate_transaction(r1_blob_tx(&bad), .CANCUN));
}

test "validate_transaction — eip4844 blob count limit per fork" {
    const six = [_]primitives.Blob.VersionedHash{r1_kzg_hash} ** 6;
    const seven = [_]primitives.Blob.VersionedHash{r1_kzg_hash} ** 7;
    const nine = [_]primitives.Blob.VersionedHash{r1_kzg_hash} ** 9;
    const ten = [_]primitives.Blob.VersionedHash{r1_kzg_hash} ** 10;

    _ = try validate_transaction(r1_blob_tx(&six), .CANCUN);
    try std.testing.expectError(error.TooManyBlobs, validate_transaction(r1_blob_tx(&seven), .CANCUN));
    _ = try validate_transaction(r1_blob_tx(&nine), .PRAGUE);
    try std.testing.expectError(error.TooManyBlobs, validate_transaction(r1_blob_tx(&ten), .PRAGUE));
    _ = try validate_transaction(r1_blob_tx(&six), .OSAKA);
    try std.testing.expectError(error.TooManyBlobs, validate_transaction(r1_blob_tx(&seven), .OSAKA));
}

test "validate_transaction — eip7702 rejects empty authorization_list" {
    try std.testing.expectError(
        error.EmptyAuthorizationList,
        validate_transaction(r1_set_code_tx(r1_address(0x54), &.{}), .PRAGUE),
    );
    const auths = [_]primitives.Authorization.Authorization{r1_auth};
    _ = try validate_transaction(r1_set_code_tx(r1_address(0x54), &auths), .PRAGUE);
}

test "validate_transaction — eip7702 rejects contract creation" {
    const auths = [_]primitives.Authorization.Authorization{r1_auth};
    try std.testing.expectError(
        error.SetCodeTransactionCreate,
        validate_transaction(r1_set_code_tx(null, &auths), .PRAGUE),
    );
}

test "validate_transaction — pre-Istanbul legacy uses 68 gas per non-zero byte" {
    const data = [_]u8{0xFF};
    var tx = tx_mod.LegacyTransaction{
        .nonce = 0,
        .gas_price = 0,
        .gas_limit = 21_067,
        .to = r1_address(0x55),
        .value = 0,
        .data = &data,
        .v = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };
    try std.testing.expectError(error.InsufficientGas, validate_transaction(tx, .BYZANTIUM));
    tx.gas_limit = 21_068;
    try std.testing.expectEqual(@as(u64, 21_068), try validate_transaction(tx, .BYZANTIUM));
    try std.testing.expectEqual(@as(u64, 21_016), try validate_transaction(tx, .ISTANBUL));
}
