/// Intrinsic gas calculation for Ethereum transactions.
///
/// Computes the gas charged before EVM execution begins. Every transaction
/// must provide at least this much gas or it is invalid.
///
/// ## Spec References
///
/// - **Python (authoritative):** `execution-specs/src/ethereum/forks/cancun/transactions.py`
///   → `calculate_intrinsic_cost(tx)`
/// - **Nethermind:** `Nethermind.Evm/IntrinsicGasCalculator.cs`
///
/// ## Components
///
/// ```
/// intrinsic_gas = TX_BASE_COST (21000)
///               + data_cost (4 per zero byte, 16 per non-zero byte)
///               + create_cost (32000 + init_code_word_cost if contract creation)
///               + access_list_cost (2400 per address + 1900 per storage key)
/// ```
///
/// The init code word cost (EIP-3860, Shanghai+) adds 2 gas per 32-byte word
/// of init code for contract creation transactions.
const std = @import("std");
const primitives = @import("primitives");
const Hardfork = primitives.Hardfork;
const tx_mod = primitives.Transaction;
const access_list = primitives.AccessList;
const authorization = primitives.Authorization;
const GasConstants = primitives.GasConstants;

// ============================================================================
// Gas Constants (matching Python spec exactly)
// ============================================================================

/// Base cost of any transaction.
pub const TX_BASE_COST: u64 = GasConstants.TxGas;

/// Gas cost per zero byte in transaction data.
pub const TX_DATA_COST_PER_ZERO: u64 = GasConstants.TxDataZeroGas;

/// Gas cost per non-zero byte in transaction data (EIP-2028).
pub const TX_DATA_COST_PER_NON_ZERO: u64 = GasConstants.TxDataNonZeroGas;

/// Additional gas cost for contract creation transactions (EIP-2).
pub const TX_CREATE_COST: u64 = GasConstants.TxGasContractCreation - GasConstants.TxGas;

/// Gas cost per address in an EIP-2930 access list.
pub const TX_ACCESS_LIST_ADDRESS_COST: u64 = access_list.ACCESS_LIST_ADDRESS_COST;

/// Gas cost per storage key in an EIP-2930 access list.
pub const TX_ACCESS_LIST_STORAGE_KEY_COST: u64 = access_list.ACCESS_LIST_STORAGE_KEY_COST;

/// Gas cost per authorization tuple in an EIP-7702 transaction.
pub const TX_AUTHORIZATION_COST_PER_ITEM: u64 = authorization.PER_EMPTY_ACCOUNT_COST;

/// Calldata floor cost per token (EIP-7623, Prague+).
pub const TX_CALLDATA_FLOOR_COST_PER_TOKEN: u64 = 10;

/// Token multiplier for non-zero calldata bytes (EIP-7623).
pub const TX_CALLDATA_NONZERO_TOKEN_MULTIPLIER: u64 = 4;

/// Gas cost per 32-byte word of init code (EIP-3860, Shanghai+).
pub const INIT_CODE_WORD_COST: u64 = GasConstants.InitcodeWordGas;

/// Maximum allowed init code size in bytes (EIP-3860, Shanghai+).
pub const MAX_INIT_CODE_SIZE: u64 = GasConstants.MaxInitcodeSize;

/// Compile-time assertion for supported transaction types used across modules.
pub fn assert_supported_tx_type(comptime Tx: type, comptime context: []const u8) void {
    comptime {
        if (Tx != tx_mod.LegacyTransaction and
            Tx != tx_mod.Eip1559Transaction and
            Tx != tx_mod.Eip4844Transaction and
            Tx != tx_mod.Eip7702Transaction)
        {
            @compileError("Unsupported transaction type for " ++ context);
        }
    }
}

// ============================================================================
// Intrinsic Gas Calculation
// ============================================================================

/// Calculate the intrinsic gas cost of a transaction.
///
/// This is the gas that is charged before execution begins. If a transaction
/// provides less gas than this amount, it is invalid.
///
/// Follows the Python spec: `calculate_intrinsic_cost(tx)` from
/// `execution-specs/src/ethereum/forks/cancun/transactions.py`.
pub fn calculate_intrinsic_gas(tx: anytype, hardfork: Hardfork) u64 {
    const Tx = @TypeOf(tx);
    comptime assert_supported_tx_type(Tx, "calculate_intrinsic_gas");

    const is_create = if (comptime Tx == tx_mod.Eip4844Transaction) false else tx.to == null;

    var access_list_address_count: u64 = 0;
    var access_list_storage_key_count: u64 = 0;
    if (comptime (Tx == tx_mod.Eip1559Transaction or Tx == tx_mod.Eip4844Transaction or Tx == tx_mod.Eip7702Transaction)) {
        access_list_address_count = @intCast(tx.access_list.len);
        for (tx.access_list) |entry| {
            access_list_storage_key_count += @intCast(entry.storage_keys.len);
        }
    }

    var authorization_count: u64 = 0;
    if (comptime Tx == tx_mod.Eip7702Transaction) {
        authorization_count = @intCast(tx.authorization_list.len);
    }

    return calculate_intrinsic_gas_parts(
        tx.data,
        is_create,
        access_list_address_count,
        access_list_storage_key_count,
        authorization_count,
        hardfork,
    );
}

fn calculate_intrinsic_gas_parts(
    data: []const u8,
    is_create: bool,
    access_list_address_count: u64,
    access_list_storage_key_count: u64,
    authorization_count: u64,
    hardfork: Hardfork,
) u64 {
    // 1. Data cost: 4 gas per zero byte, 16 gas per non-zero byte
    var data_cost: u64 = 0;
    for (data) |byte| {
        if (byte == 0) {
            data_cost += TX_DATA_COST_PER_ZERO;
        } else {
            data_cost += TX_DATA_COST_PER_NON_ZERO;
        }
    }

    // 2. Create cost: 32000 for contract creation + init code word cost (EIP-3860)
    var create_cost: u64 = 0;
    if (is_create) {
        create_cost = TX_CREATE_COST;
        // EIP-3860 (Shanghai+): charge 2 gas per 32-byte word of init code
        if (hardfork.isAtLeast(.SHANGHAI)) {
            create_cost += init_code_cost(data.len);
        }
    }

    // 3. Access list cost (EIP-2930, Berlin+)
    const access_list_cost =
        access_list_address_count * TX_ACCESS_LIST_ADDRESS_COST +
        access_list_storage_key_count * TX_ACCESS_LIST_STORAGE_KEY_COST;

    // 4. Authorization cost (EIP-7702, Prague+)
    var authorization_cost: u64 = 0;
    if (authorization_count > 0 and hardfork.isAtLeast(.PRAGUE)) {
        authorization_cost = authorization_count * TX_AUTHORIZATION_COST_PER_ITEM;
    }

    // 5. Total = base + data + create + access list + authorization
    return TX_BASE_COST + data_cost + create_cost + access_list_cost + authorization_cost;
}

/// Calculate the calldata floor gas cost (EIP-7623, Prague+).
///
/// Returns zero for pre-Prague hardforks.
pub fn calculate_calldata_floor_gas(data: []const u8, hardfork: Hardfork) u64 {
    if (!hardfork.isAtLeast(.PRAGUE)) return 0;

    var zero_bytes: u64 = 0;
    var nonzero_bytes: u64 = 0;
    for (data) |byte| {
        if (byte == 0) {
            zero_bytes += 1;
        } else {
            nonzero_bytes += 1;
        }
    }

    const tokens_in_calldata = zero_bytes + nonzero_bytes * TX_CALLDATA_NONZERO_TOKEN_MULTIPLIER;
    return TX_BASE_COST + (tokens_in_calldata * TX_CALLDATA_FLOOR_COST_PER_TOKEN);
}

/// Calculate the gas cost for init code words (EIP-3860).
///
/// Python spec: `GAS_INIT_CODE_WORD_COST * ceil32(init_code_length) // 32`
/// from `execution-specs/src/ethereum/forks/cancun/vm/gas.py`.
pub fn init_code_cost(init_code_length: usize) u64 {
    const len: u64 = @intCast(init_code_length);
    // ceil32(len) = ((len + 31) / 32) * 32, then divide by 32
    // Simplifies to: (len + 31) / 32
    const words = (len + 31) / 32;
    return INIT_CODE_WORD_COST * words;
}

// =============================================================================
// Tests
// =============================================================================

const Address = primitives.Address;
const AccessListItem = tx_mod.AccessListItem;
const Authorization = authorization.Authorization;

fn make_address(byte: u8) Address {
    return .{ .bytes = [_]u8{byte} ++ [_]u8{0} ** 19 };
}

fn legacy_tx(data: []const u8, to: ?Address) tx_mod.LegacyTransaction {
    return .{
        .nonce = 0,
        .gas_price = 0,
        .gas_limit = 0,
        .to = to,
        .value = 0,
        .data = data,
        .v = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };
}

fn eip1559_al_tx(data: []const u8, to: ?Address, access_list_items: []const AccessListItem) tx_mod.Eip1559Transaction {
    return .{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 0,
        .max_fee_per_gas = 0,
        .gas_limit = 0,
        .to = to,
        .value = 0,
        .data = data,
        .access_list = access_list_items,
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };
}

test "intrinsic gas — simple transfer (no data, no create)" {
    const tx = legacy_tx(&.{}, make_address(0x01));
    const gas = calculate_intrinsic_gas(tx, .LONDON);
    try std.testing.expectEqual(@as(u64, 21_000), gas);
}

test "intrinsic gas — transfer with zero-byte data" {
    const data = [_]u8{ 0, 0, 0, 0 };
    const tx = legacy_tx(&data, make_address(0x02));
    const gas = calculate_intrinsic_gas(tx, .LONDON);
    // 21000 + 4 * 4 = 21016
    try std.testing.expectEqual(@as(u64, 21_016), gas);
}

test "intrinsic gas — transfer with non-zero-byte data" {
    const data = [_]u8{ 0xFF, 0xAB, 0x01 };
    const tx = legacy_tx(&data, make_address(0x03));
    const gas = calculate_intrinsic_gas(tx, .LONDON);
    // 21000 + 3 * 16 = 21048
    try std.testing.expectEqual(@as(u64, 21_048), gas);
}

test "intrinsic gas — transfer with mixed data" {
    const data = [_]u8{ 0x00, 0xFF, 0x00, 0xAB };
    const tx = legacy_tx(&data, make_address(0x04));
    const gas = calculate_intrinsic_gas(tx, .LONDON);
    // 21000 + 2*4 + 2*16 = 21000 + 8 + 32 = 21040
    try std.testing.expectEqual(@as(u64, 21_040), gas);
}

test "intrinsic gas — contract creation (pre-Shanghai, no EIP-3860)" {
    const init_code = [_]u8{0x60} ** 64; // 64 bytes of PUSH1
    const tx = legacy_tx(&init_code, null);
    const gas = calculate_intrinsic_gas(tx, .LONDON);
    // 21000 + 64*16 + 32000 = 21000 + 1024 + 32000 = 54024
    // No init code word cost pre-Shanghai
    try std.testing.expectEqual(@as(u64, 54_024), gas);
}

test "intrinsic gas — contract creation (Shanghai+, EIP-3860)" {
    const init_code = [_]u8{0x60} ** 64; // 64 bytes = 2 words
    const tx = legacy_tx(&init_code, null);
    const gas = calculate_intrinsic_gas(tx, .SHANGHAI);
    // 21000 + 64*16 + 32000 + 2*2 = 21000 + 1024 + 32000 + 4 = 54028
    try std.testing.expectEqual(@as(u64, 54_028), gas);
}

test "intrinsic gas — contract creation with non-word-aligned init code" {
    const init_code = [_]u8{0x60} ** 33; // 33 bytes = ceil(33/32) = 2 words
    const tx = legacy_tx(&init_code, null);
    const gas = calculate_intrinsic_gas(tx, .CANCUN);
    // 21000 + 33*16 + 32000 + 2*2 = 21000 + 528 + 32000 + 4 = 53532
    try std.testing.expectEqual(@as(u64, 53_532), gas);
}

test "intrinsic gas — with access list (1559)" {
    const key1 = [_]u8{0x01} ** 32;
    const key2 = [_]u8{0x02} ** 32;
    const key3 = [_]u8{0x03} ** 32;
    const keys12 = [_][32]u8{ key1, key2 };
    const keys3 = [_][32]u8{key3};
    const list = [_]AccessListItem{
        .{ .address = make_address(0x10), .storage_keys = &keys12 },
        .{ .address = make_address(0x11), .storage_keys = &keys3 },
    };
    const tx = eip1559_al_tx(&.{}, make_address(0x12), &list);
    const gas = calculate_intrinsic_gas(tx, .LONDON);
    // 21000 + 2*2400 + 3*1900 = 21000 + 4800 + 5700 = 31500
    try std.testing.expectEqual(@as(u64, 31_500), gas);
}

test "intrinsic gas — full tx (create + data + access list, Cancun)" {
    const init_code = [_]u8{0x60} ** 32; // 32 bytes = 1 word
    const key1 = [_]u8{0xAA} ** 32;
    const key2 = [_]u8{0xBB} ** 32;
    const keys = [_][32]u8{ key1, key2 };
    const list = [_]AccessListItem{
        .{ .address = make_address(0x13), .storage_keys = &keys },
    };
    const tx = eip1559_al_tx(&init_code, null, &list);
    const gas = calculate_intrinsic_gas(tx, .CANCUN);
    // 21000 + 32*16 + 32000 + 1*2 + 1*2400 + 2*1900
    // = 21000 + 512 + 32000 + 2 + 2400 + 3800 = 59714
    try std.testing.expectEqual(@as(u64, 59_714), gas);
}

test "intrinsic gas — empty data contract creation (Cancun)" {
    const tx = legacy_tx(&.{}, null);
    const gas = calculate_intrinsic_gas(tx, .CANCUN);
    // 21000 + 0 + 32000 + 0 (no words) = 53000
    try std.testing.expectEqual(@as(u64, 53_000), gas);
}

test "init_code_cost — exact word boundary" {
    // 32 bytes = 1 word → 2 gas
    try std.testing.expectEqual(@as(u64, 2), init_code_cost(32));
    // 64 bytes = 2 words → 4 gas
    try std.testing.expectEqual(@as(u64, 4), init_code_cost(64));
}

test "init_code_cost — non-word-aligned" {
    // 1 byte → ceil(1/32) = 1 word → 2 gas
    try std.testing.expectEqual(@as(u64, 2), init_code_cost(1));
    // 33 bytes → ceil(33/32) = 2 words → 4 gas
    try std.testing.expectEqual(@as(u64, 4), init_code_cost(33));
    // 31 bytes → ceil(31/32) = 1 word → 2 gas
    try std.testing.expectEqual(@as(u64, 2), init_code_cost(31));
}

test "intrinsic gas — eip7702 authorization cost (Prague+)" {
    const auths = [_]Authorization{
        .{
            .chain_id = 1,
            .address = make_address(0x20),
            .nonce = 0,
            .v = 0,
            .r = [_]u8{0} ** 32,
            .s = [_]u8{0} ** 32,
        },
        .{
            .chain_id = 1,
            .address = make_address(0x21),
            .nonce = 1,
            .v = 0,
            .r = [_]u8{0} ** 32,
            .s = [_]u8{0} ** 32,
        },
    };
    const tx = tx_mod.Eip7702Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 0,
        .max_fee_per_gas = 0,
        .gas_limit = 0,
        .to = make_address(0x22),
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]AccessListItem{},
        .authorization_list = &auths,
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };
    const gas = calculate_intrinsic_gas(tx, .PRAGUE);
    // 21000 + 2*25000 = 71000
    try std.testing.expectEqual(@as(u64, 71_000), gas);
}

test "calldata floor gas — prague applies floor" {
    const data = [_]u8{0x01}; // one non-zero byte => 4 tokens
    const floor = calculate_calldata_floor_gas(&data, .PRAGUE);
    // 21000 + 4*10 = 21040
    try std.testing.expectEqual(@as(u64, 21_040), floor);
}

test "calldata floor gas — pre-prague returns zero" {
    const data = [_]u8{0x01};
    try std.testing.expectEqual(@as(u64, 0), calculate_calldata_floor_gas(&data, .CANCUN));
}

test "init_code_cost — zero length" {
    try std.testing.expectEqual(@as(u64, 0), init_code_cost(0));
}

test "init_code_cost — max init code size" {
    // 49152 bytes = 1536 words → 3072 gas
    const max_size: usize = @intCast(MAX_INIT_CODE_SIZE);
    try std.testing.expectEqual(@as(u64, 3_072), init_code_cost(max_size));
}
