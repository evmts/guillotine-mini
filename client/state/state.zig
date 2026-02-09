/// World-state snapshot indexes (state + storage).
///
/// Mirrors Nethermind's `Nethermind.Evm.State.Snapshot` struct:
/// - Composite snapshot of account state and storage providers
/// - Empty sentinel equals the journal empty position
///
/// These snapshot indexes are used by the world state manager to
/// restore state after failed calls/transactions.
const std = @import("std");

/// Composite snapshot for state + persistent + transient storage.
pub const Snapshot = struct {
    /// Sentinel value representing an empty snapshot (no entries).
    /// Matches `Journal.empty_snapshot` (maxInt(usize)).
    pub const empty_position: usize = std.math.maxInt(usize);

    /// Snapshot positions for storage providers.
    pub const Storage = struct {
        /// Empty storage snapshot (no entries in either provider).
        pub const empty: Storage = .{
            .persistent = empty_position,
            .transient = empty_position,
        };

        /// Persistent storage snapshot index.
        persistent: usize,
        /// Transient storage snapshot index (EIP-1153).
        transient: usize,
    };

    /// Empty composite snapshot.
    pub const empty: Snapshot = .{
        .storage = Storage.empty,
        .state = empty_position,
    };

    /// Snapshot index for account state provider.
    state: usize,
    /// Snapshot indexes for storage providers.
    storage: Storage,
};

// =========================================================================
// Tests
// =========================================================================

test "Snapshot: empty uses sentinel positions" {
    try std.testing.expectEqual(Snapshot.empty_position, Snapshot.empty.state);
    try std.testing.expectEqual(Snapshot.empty_position, Snapshot.empty.storage.persistent);
    try std.testing.expectEqual(Snapshot.empty_position, Snapshot.empty.storage.transient);
}
