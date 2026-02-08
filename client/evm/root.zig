/// EVM integration layer for the Guillotine execution client.
///
/// Bridges Voltaire's `StateManager` to the guillotine-mini EVM engine via
/// a `HostInterface` adapter and provides transaction/block processing.
///
/// ## Modules
///
/// - `HostAdapter` — Adapts Voltaire `StateManager` to guillotine-mini `HostInterface` vtable.
/// - `IntrinsicGas` — Intrinsic gas calculation for transactions (pre-execution gas charging).
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
///
/// var state = try StateManager.init(allocator, null);
/// defer state.deinit();
///
/// var adapter = client_evm.HostAdapter.init(&state);
/// const host = adapter.host_interface();
///
/// // Calculate intrinsic gas for a transaction
/// const gas = client_evm.calculateIntrinsicGas(.{
///     .data = tx_data,
///     .is_create = true,
///     .hardfork = .CANCUN,
/// });
/// ```
const host_adapter = @import("host_adapter.zig");
const intrinsic_gas = @import("intrinsic_gas.zig");

// -- Public API: flat re-exports -------------------------------------------

/// Adapts Voltaire `StateManager` to guillotine-mini `HostInterface` vtable.
pub const HostAdapter = host_adapter.HostAdapter;

/// Calculate the intrinsic gas cost of a transaction.
pub const calculateIntrinsicGas = intrinsic_gas.calculateIntrinsicGas;

/// Calculate the gas cost for init code words (EIP-3860).
pub const initCodeCost = intrinsic_gas.initCodeCost;

/// Parameters for intrinsic gas calculation.
pub const IntrinsicGasParams = intrinsic_gas.IntrinsicGasParams;

// -- Gas constants re-exports ----------------------------------------------

pub const TX_BASE_COST = intrinsic_gas.TX_BASE_COST;
pub const TX_DATA_COST_PER_ZERO = intrinsic_gas.TX_DATA_COST_PER_ZERO;
pub const TX_DATA_COST_PER_NON_ZERO = intrinsic_gas.TX_DATA_COST_PER_NON_ZERO;
pub const TX_CREATE_COST = intrinsic_gas.TX_CREATE_COST;
pub const TX_ACCESS_LIST_ADDRESS_COST = intrinsic_gas.TX_ACCESS_LIST_ADDRESS_COST;
pub const TX_ACCESS_LIST_STORAGE_KEY_COST = intrinsic_gas.TX_ACCESS_LIST_STORAGE_KEY_COST;
pub const INIT_CODE_WORD_COST = intrinsic_gas.INIT_CODE_WORD_COST;
pub const MAX_INIT_CODE_SIZE = intrinsic_gas.MAX_INIT_CODE_SIZE;

test {
    // Ensure all sub-modules compile and their tests run.
    @import("std").testing.refAllDecls(@This());
}
