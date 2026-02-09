/// World-state snapshot indexes (state + storage).
///
/// Mirrors Nethermind's `Nethermind.Evm.State.Snapshot` struct:
/// - Composite snapshot of account state and storage providers
/// - Empty sentinel equals the journal empty position
///
/// These snapshot indexes are used by the world state manager to
/// restore state after failed calls/transactions.
const std = @import("std");
const journal = @import("journal.zig");

/// Composite snapshot for state + persistent + transient storage.
pub const Snapshot = struct {
    /// Sentinel value representing an empty snapshot (no entries).
    /// Matches `Journal.empty_snapshot` (maxInt(usize)).
    pub const empty_position: usize = journal.empty_snapshot_sentinel;

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

comptime {
    if (Snapshot.empty_position != journal.empty_snapshot_sentinel) {
        @compileError("Snapshot.empty_position must match Journal.empty_snapshot sentinel.");
    }
}

// =========================================================================
// Tests
// =========================================================================

test "Snapshot: empty uses sentinel positions" {
    try std.testing.expectEqual(journal.empty_snapshot_sentinel, Snapshot.empty_position);
    try std.testing.expectEqual(Snapshot.empty_position, Snapshot.empty.state);
    try std.testing.expectEqual(Snapshot.empty_position, Snapshot.empty.storage.persistent);
    try std.testing.expectEqual(Snapshot.empty_position, Snapshot.empty.storage.transient);
}
