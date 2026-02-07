/// EVM integration layer for the Guillotine execution client.
///
/// Bridges Voltaire's `StateManager` to the guillotine-mini EVM engine via
/// a `HostInterface` adapter. Currently provides the state read/write bridge
/// needed for EVM execution; transaction and block processing will be added
/// in later phases.
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
