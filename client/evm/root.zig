/// EVM integration layer for the Guillotine execution client.
///
/// Bridges the guillotine-mini EVM engine with Voltaire's state management,
/// providing transaction and block processing capabilities.
///
/// ## Modules
///
/// - `HostAdapter` — Adapts Voltaire `StateManager` to guillotine-mini `HostInterface` vtable.
///
/// ## Architecture (Nethermind parity)
///
/// | Module          | Nethermind equivalent                      | Purpose                                |
/// |-----------------|--------------------------------------------|----------------------------------------|
/// | `HostAdapter`   | `IWorldState` passed to `VirtualMachine`   | State read/write bridge for EVM        |
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
/// const host = adapter.hostInterface();
/// ```
const host_adapter = @import("host_adapter.zig");

// -- Public API: flat re-exports -------------------------------------------

/// Adapts Voltaire `StateManager` to guillotine-mini `HostInterface` vtable.
pub const HostAdapter = host_adapter.HostAdapter;

test {
    // Ensure all sub-modules compile and their tests run.
    @import("std").testing.refAllDecls(@This());
}
