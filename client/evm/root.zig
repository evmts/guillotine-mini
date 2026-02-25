/// EVM integration layer for the Guillotine execution client.
///
/// Bridges Voltaire's `StateManager` to the guillotine-mini EVM engine via
/// a `HostInterface` adapter and provides transaction/block processing.
///
/// ## Modules
///
/// - `HostAdapter` — Adapts Voltaire `StateManager` to guillotine-mini `HostInterface` vtable.
/// - `IntrinsicGas` — Intrinsic gas calculation for transactions (pre-execution gas charging).
/// - `TransactionValidation` — Static transaction validation (intrinsic gas + limits).
///
/// ## Architecture (Nethermind parity)
///
/// | Module          | Nethermind equivalent                      | Purpose                                |
/// |-----------------|--------------------------------------------|----------------------------------------|
/// | `HostAdapter`   | `IWorldState` passed to `VirtualMachine`   | State read/write bridge for EVM        |
/// | `IntrinsicGas`  | `IntrinsicGasCalculator`                   | Pre-execution gas cost calculation     |
///
/// ## Usage
///
/// ```zig
/// const client_evm = @import("client_evm");
/// const primitives = @import("voltaire");
///
/// var state = try StateManager.init(allocator, null);
/// defer state.deinit();
///
/// var adapter = client_evm.HostAdapter.init(&state);
/// const host = adapter.host_interface();
///
/// // Calculate intrinsic gas for a transaction
/// const tx = primitives.Transaction.LegacyTransaction{
///     .nonce = 0,
///     .gas_price = 0,
///     .gas_limit = 0,
///     .to = null,
///     .value = 0,
///     .data = tx_data,
///     .v = 0,
///     .r = [_]u8{0} ** 32,
///     .s = [_]u8{0} ** 32,
/// };
/// const gas = client_evm.calculate_intrinsic_gas(tx, .CANCUN);
/// ```
const host_adapter = @import("host_adapter.zig");
const intrinsic_gas = @import("intrinsic_gas.zig");
const processor = @import("processor.zig");

// -- Public API: flat re-exports -------------------------------------------

/// Adapts Voltaire `StateManager` to guillotine-mini `HostInterface` vtable.
pub const HostAdapter = host_adapter.HostAdapter;

/// Calculate the intrinsic gas cost of a transaction.
pub const calculate_intrinsic_gas = intrinsic_gas.calculate_intrinsic_gas;

/// Calculate the gas cost for init code words (EIP-3860).
pub const init_code_cost = intrinsic_gas.init_code_cost;

/// Validate a transaction and return its intrinsic gas.
pub const validate_transaction = processor.validate_transaction;

/// Calculate the effective gas price for a transaction (London+ EIP-1559 rules).
/// Re-exported for a stable public API surface under `client_evm`.
pub const calculate_effective_gas_price = processor.calculate_effective_gas_price;

// -- Gas constants re-exports ----------------------------------------------

/// Base cost of any transaction.
pub const TX_BASE_COST = intrinsic_gas.TX_BASE_COST;

/// Gas cost per zero byte in transaction data.
pub const TX_DATA_COST_PER_ZERO = intrinsic_gas.TX_DATA_COST_PER_ZERO;

/// Gas cost per non-zero byte in transaction data.
pub const TX_DATA_COST_PER_NON_ZERO = intrinsic_gas.TX_DATA_COST_PER_NON_ZERO;

/// Additional gas cost for contract creation transactions.
pub const TX_CREATE_COST = intrinsic_gas.TX_CREATE_COST;

/// Gas cost per address in an EIP-2930 access list.
pub const TX_ACCESS_LIST_ADDRESS_COST = intrinsic_gas.TX_ACCESS_LIST_ADDRESS_COST;

/// Gas cost per storage key in an EIP-2930 access list.
pub const TX_ACCESS_LIST_STORAGE_KEY_COST = intrinsic_gas.TX_ACCESS_LIST_STORAGE_KEY_COST;

/// Gas cost per 32-byte word of init code (EIP-3860).
pub const INIT_CODE_WORD_COST = intrinsic_gas.INIT_CODE_WORD_COST;

/// Maximum allowed init code size in bytes (EIP-3860).
pub const MAX_INIT_CODE_SIZE = intrinsic_gas.MAX_INIT_CODE_SIZE;

test {
    // Ensure all sub-modules compile and their tests run.
    @import("std").testing.refAllDecls(@This());
}
