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

// ============================================================================
// Gas Constants (matching Python spec exactly)
// ============================================================================

/// Base cost of any transaction.
pub const TX_BASE_COST: u64 = 21_000;

/// Gas cost per zero byte in transaction data.
pub const TX_DATA_COST_PER_ZERO: u64 = 4;

/// Gas cost per non-zero byte in transaction data (EIP-2028).
pub const TX_DATA_COST_PER_NON_ZERO: u64 = 16;

/// Additional gas cost for contract creation transactions (EIP-2).
pub const TX_CREATE_COST: u64 = 32_000;

/// Gas cost per address in an EIP-2930 access list.
pub const TX_ACCESS_LIST_ADDRESS_COST: u64 = 2_400;

/// Gas cost per storage key in an EIP-2930 access list.
pub const TX_ACCESS_LIST_STORAGE_KEY_COST: u64 = 1_900;

/// Gas cost per authorization tuple in an EIP-7702 transaction.
pub const TX_AUTHORIZATION_COST_PER_ITEM: u64 = 25_000;

/// Calldata floor cost per token (EIP-7623, Prague+).
pub const TX_CALLDATA_FLOOR_COST_PER_TOKEN: u64 = 10;

/// Token multiplier for non-zero calldata bytes (EIP-7623).
pub const TX_CALLDATA_NONZERO_TOKEN_MULTIPLIER: u64 = 4;

/// Gas cost per 32-byte word of init code (EIP-3860, Shanghai+).
pub const INIT_CODE_WORD_COST: u64 = 2;

/// Maximum allowed init code size in bytes (EIP-3860, Shanghai+).
pub const MAX_INIT_CODE_SIZE: u64 = 49_152; // 2 * 24576

// ============================================================================
// Intrinsic Gas Calculation
// ============================================================================

/// Parameters for intrinsic gas calculation.
///
/// Mirrors the fields of a transaction that affect intrinsic gas cost,
/// without depending on any specific transaction type. The caller extracts
/// these from their transaction representation.
pub const IntrinsicGasParams = struct {
    /// Transaction calldata (or init code for contract creation).
    data: []const u8 = &.{},

    /// True if this is a contract creation transaction (to == null).
    is_create: bool = false,

    /// Number of addresses in the EIP-2930 access list.
    access_list_address_count: u64 = 0,

    /// Total number of storage keys across all access list entries.
    access_list_storage_key_count: u64 = 0,

    /// Number of authorization tuples (EIP-7702).
    authorization_count: u64 = 0,

    /// Active hardfork — controls whether EIP-3860 init code cost applies.
    hardfork: Hardfork = Hardfork.DEFAULT,
};

/// Calculate the intrinsic gas cost of a transaction.
///
/// This is the gas that is charged before execution begins. If a transaction
/// provides less gas than this amount, it is invalid.
///
/// Follows the Python spec: `calculate_intrinsic_cost(tx)` from
/// `execution-specs/src/ethereum/forks/cancun/transactions.py`.
pub fn calculateIntrinsicGas(params: IntrinsicGasParams) u64 {
    // 1. Data cost: 4 gas per zero byte, 16 gas per non-zero byte
    var data_cost: u64 = 0;
    for (params.data) |byte| {
        if (byte == 0) {
            data_cost += TX_DATA_COST_PER_ZERO;
        } else {
            data_cost += TX_DATA_COST_PER_NON_ZERO;
        }
    }

    // 2. Create cost: 32000 for contract creation + init code word cost (EIP-3860)
    var create_cost: u64 = 0;
    if (params.is_create) {
        create_cost = TX_CREATE_COST;
        // EIP-3860 (Shanghai+): charge 2 gas per 32-byte word of init code
        if (params.hardfork.isAtLeast(.SHANGHAI)) {
            create_cost += initCodeCost(params.data.len);
        }
    }

    // 3. Access list cost (EIP-2930, Berlin+)
    const access_list_cost =
        params.access_list_address_count * TX_ACCESS_LIST_ADDRESS_COST +
        params.access_list_storage_key_count * TX_ACCESS_LIST_STORAGE_KEY_COST;

    // 4. Authorization cost (EIP-7702, Prague+)
    var authorization_cost: u64 = 0;
    if (params.authorization_count > 0 and params.hardfork.isAtLeast(.PRAGUE)) {
        authorization_cost = params.authorization_count * TX_AUTHORIZATION_COST_PER_ITEM;
    }

    // 5. Total = base + data + create + access list + authorization
    return TX_BASE_COST + data_cost + create_cost + access_list_cost + authorization_cost;
}

/// Calculate the calldata floor gas cost (EIP-7623, Prague+).
///
/// Returns zero for pre-Prague hardforks.
pub fn calculateCalldataFloorGas(data: []const u8, hardfork: Hardfork) u64 {
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
pub fn initCodeCost(init_code_length: usize) u64 {
    const len: u64 = @intCast(init_code_length);
    // ceil32(len) = ((len + 31) / 32) * 32, then divide by 32
    // Simplifies to: (len + 31) / 32
    const words = (len + 31) / 32;
    return INIT_CODE_WORD_COST * words;
}

// =============================================================================
// Tests
// =============================================================================

test "intrinsic gas — simple transfer (no data, no create)" {
    const gas = calculateIntrinsicGas(.{});
    try std.testing.expectEqual(@as(u64, 21_000), gas);
}

test "intrinsic gas — transfer with zero-byte data" {
    const data = [_]u8{ 0, 0, 0, 0 };
    const gas = calculateIntrinsicGas(.{ .data = &data });
    // 21000 + 4 * 4 = 21016
    try std.testing.expectEqual(@as(u64, 21_016), gas);
}

test "intrinsic gas — transfer with non-zero-byte data" {
    const data = [_]u8{ 0xFF, 0xAB, 0x01 };
    const gas = calculateIntrinsicGas(.{ .data = &data });
    // 21000 + 3 * 16 = 21048
    try std.testing.expectEqual(@as(u64, 21_048), gas);
}

test "intrinsic gas — transfer with mixed data" {
    const data = [_]u8{ 0x00, 0xFF, 0x00, 0xAB };
    const gas = calculateIntrinsicGas(.{ .data = &data });
    // 21000 + 2*4 + 2*16 = 21000 + 8 + 32 = 21040
    try std.testing.expectEqual(@as(u64, 21_040), gas);
}

test "intrinsic gas — contract creation (pre-Shanghai, no EIP-3860)" {
    const init_code = [_]u8{0x60} ** 64; // 64 bytes of PUSH1
    const gas = calculateIntrinsicGas(.{
        .data = &init_code,
        .is_create = true,
        .hardfork = .LONDON,
    });
    // 21000 + 64*16 + 32000 = 21000 + 1024 + 32000 = 54024
    // No init code word cost pre-Shanghai
    try std.testing.expectEqual(@as(u64, 54_024), gas);
}

test "intrinsic gas — contract creation (Shanghai+, EIP-3860)" {
    const init_code = [_]u8{0x60} ** 64; // 64 bytes = 2 words
    const gas = calculateIntrinsicGas(.{
        .data = &init_code,
        .is_create = true,
        .hardfork = .SHANGHAI,
    });
    // 21000 + 64*16 + 32000 + 2*2 = 21000 + 1024 + 32000 + 4 = 54028
    try std.testing.expectEqual(@as(u64, 54_028), gas);
}

test "intrinsic gas — contract creation with non-word-aligned init code" {
    const init_code = [_]u8{0x60} ** 33; // 33 bytes = ceil(33/32) = 2 words
    const gas = calculateIntrinsicGas(.{
        .data = &init_code,
        .is_create = true,
        .hardfork = .CANCUN,
    });
    // 21000 + 33*16 + 32000 + 2*2 = 21000 + 528 + 32000 + 4 = 53532
    try std.testing.expectEqual(@as(u64, 53_532), gas);
}

test "intrinsic gas — with access list" {
    const gas = calculateIntrinsicGas(.{
        .access_list_address_count = 2,
        .access_list_storage_key_count = 3,
    });
    // 21000 + 2*2400 + 3*1900 = 21000 + 4800 + 5700 = 31500
    try std.testing.expectEqual(@as(u64, 31_500), gas);
}

test "intrinsic gas — full transaction (create + data + access list, Cancun)" {
    const init_code = [_]u8{0x60} ** 32; // 32 bytes = 1 word
    const gas = calculateIntrinsicGas(.{
        .data = &init_code,
        .is_create = true,
        .access_list_address_count = 1,
        .access_list_storage_key_count = 2,
        .hardfork = .CANCUN,
    });
    // 21000 + 32*16 + 32000 + 1*2 + 1*2400 + 2*1900
    // = 21000 + 512 + 32000 + 2 + 2400 + 3800 = 59714
    try std.testing.expectEqual(@as(u64, 59_714), gas);
}

test "intrinsic gas — empty data contract creation (Cancun)" {
    const gas = calculateIntrinsicGas(.{
        .data = &.{},
        .is_create = true,
        .hardfork = .CANCUN,
    });
    // 21000 + 0 + 32000 + 0 (no words) = 53000
    try std.testing.expectEqual(@as(u64, 53_000), gas);
}

test "initCodeCost — exact word boundary" {
    // 32 bytes = 1 word → 2 gas
    try std.testing.expectEqual(@as(u64, 2), initCodeCost(32));
    // 64 bytes = 2 words → 4 gas
    try std.testing.expectEqual(@as(u64, 4), initCodeCost(64));
}

test "initCodeCost — non-word-aligned" {
    // 1 byte → ceil(1/32) = 1 word → 2 gas
    try std.testing.expectEqual(@as(u64, 2), initCodeCost(1));
    // 33 bytes → ceil(33/32) = 2 words → 4 gas
    try std.testing.expectEqual(@as(u64, 4), initCodeCost(33));
    // 31 bytes → ceil(31/32) = 1 word → 2 gas
    try std.testing.expectEqual(@as(u64, 2), initCodeCost(31));
}

test "intrinsic gas — eip7702 authorization cost (Prague+)" {
    const gas = calculateIntrinsicGas(.{
        .authorization_count = 2,
        .hardfork = .PRAGUE,
    });
    // 21000 + 2*25000 = 71000
    try std.testing.expectEqual(@as(u64, 71_000), gas);
}

test "calldata floor gas — prague applies floor" {
    const data = [_]u8{0x01}; // one non-zero byte => 4 tokens
    const floor = calculateCalldataFloorGas(&data, .PRAGUE);
    // 21000 + 4*10 = 21040
    try std.testing.expectEqual(@as(u64, 21_040), floor);
}

test "calldata floor gas — pre-prague returns zero" {
    const data = [_]u8{0x01};
    try std.testing.expectEqual(@as(u64, 0), calculateCalldataFloorGas(&data, .CANCUN));
}

test "initCodeCost — zero length" {
    try std.testing.expectEqual(@as(u64, 0), initCodeCost(0));
}

test "initCodeCost — max init code size" {
    // 49152 bytes = 1536 words → 3072 gas
    try std.testing.expectEqual(@as(u64, 3_072), initCodeCost(MAX_INIT_CODE_SIZE));
}
