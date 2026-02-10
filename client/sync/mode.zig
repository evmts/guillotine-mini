/// Sync manager primitives: sync mode bit flags (Nethermind-compatible shape).
///
/// Mirrors Nethermind's Synchronization.ParallelSync.SyncMode flags so that
/// higher-level coordination can be implemented idiomatically in Zig while
/// staying structurally aligned.
const std = @import("std");

/// Bitflag set representing current synchronization modes.
/// Multiple flags may be active at once.
pub const SyncMode = struct {
    pub const none: u32 = 0;

    /// We are connected and waiting for new blocks from peers (EL-driven).
    pub const waiting_for_block: u32 = 1 << 0; // WaitingForBlock
    /// We are not connected to usable peers.
    pub const disconnected: u32 = 1 << 1; // Disconnected

    /// Fast blocks umbrella flag.
    pub const fast_blocks: u32 = 1 << 2; // FastBlocks
    /// Standard fast sync (near head after fast blocks stage)
    pub const fast_sync: u32 = 1 << 3; // FastSync
    /// Downloading state trie nodes in fast sync.
    pub const state_nodes: u32 = 1 << 4; // StateNodes
    /// Full archive sync or full after state sync completes.
    pub const full: u32 = 1 << 5; // Full
    /// Loading blocks from local DB.
    pub const db_load: u32 = 1 << 7; // DbLoad (matches Nethermind gap at bit 6)

    /// Fast headers/body/receipts phases (piggybacking on fast_blocks).
    pub const fast_headers: u32 = fast_blocks | (1 << 8); // FastHeaders
    pub const fast_bodies: u32 = fast_blocks | (1 << 9); // FastBodies
    pub const fast_receipts: u32 = fast_blocks | (1 << 10); // FastReceipts

    /// Snap state sync (accounts/storage/code/proofs ranges).
    pub const snap_sync: u32 = 1 << 11; // SnapSync
    /// Reverse header download from beacon pivot to genesis.
    pub const beacon_headers: u32 = 1 << 12; // BeaconHeaders
    /// Waiting for forkchoice update to refresh pivot.
    pub const updating_pivot: u32 = 1 << 13; // UpdatingPivot

    pub const all: u32 = waiting_for_block | disconnected | fast_blocks | fast_sync | state_nodes |
        full | db_load | fast_headers | fast_bodies | fast_receipts | snap_sync | beacon_headers | updating_pivot;
};

test "SyncMode bit flags uniqueness and composition" {
    // Ensure no overlap among base flags (excluding composed fast_* variants).
    const bases = [_]u32{
        SyncMode.waiting_for_block,
        SyncMode.disconnected,
        SyncMode.fast_blocks,
        SyncMode.fast_sync,
        SyncMode.state_nodes,
        SyncMode.full,
        SyncMode.db_load,
        SyncMode.snap_sync,
        SyncMode.beacon_headers,
        SyncMode.updating_pivot,
    };

    var acc: u32 = 0;
    for (bases) |b| {
        // No double-set bits.
        try std.testing.expect((acc & b) == 0);
        acc |= b;
    }

    // Composed fast_* include fast_blocks bit.
    try std.testing.expect((SyncMode.fast_headers & SyncMode.fast_blocks) != 0);
    try std.testing.expect((SyncMode.fast_bodies & SyncMode.fast_blocks) != 0);
    try std.testing.expect((SyncMode.fast_receipts & SyncMode.fast_blocks) != 0);

    // 'all' should include every named flag.
    try std.testing.expect((SyncMode.all & SyncMode.waiting_for_block) != 0);
    try std.testing.expect((SyncMode.all & SyncMode.disconnected) != 0);
    try std.testing.expect((SyncMode.all & SyncMode.fast_blocks) != 0);
    try std.testing.expect((SyncMode.all & SyncMode.fast_sync) != 0);
    try std.testing.expect((SyncMode.all & SyncMode.state_nodes) != 0);
    try std.testing.expect((SyncMode.all & SyncMode.full) != 0);
    try std.testing.expect((SyncMode.all & SyncMode.db_load) != 0);
    try std.testing.expect((SyncMode.all & SyncMode.fast_headers) != 0);
    try std.testing.expect((SyncMode.all & SyncMode.fast_bodies) != 0);
    try std.testing.expect((SyncMode.all & SyncMode.fast_receipts) != 0);
    try std.testing.expect((SyncMode.all & SyncMode.snap_sync) != 0);
    try std.testing.expect((SyncMode.all & SyncMode.beacon_headers) != 0);
    try std.testing.expect((SyncMode.all & SyncMode.updating_pivot) != 0);
}

/// Helper predicates for sync mode classification (Nethermind-compatible).
pub fn not_syncing(mode: u32) bool {
    // Mirrors: SyncModeExtensions.NotSyncing (exact value match).
    return mode == SyncMode.waiting_for_block or mode == SyncMode.disconnected;
}

pub fn have_not_synced_bodies_yet(mode: u32) bool {
    // Mirrors: HaveNotSyncedBodiesYet (any of the listed flags present).
    const mask: u32 =
        SyncMode.fast_headers |
        SyncMode.fast_bodies |
        SyncMode.fast_sync |
        SyncMode.state_nodes |
        SyncMode.snap_sync |
        SyncMode.beacon_headers |
        SyncMode.updating_pivot;
    return (mode & mask) != 0;
}

pub fn have_not_synced_receipts_yet(mode: u32) bool {
    // Mirrors: HaveNotSyncedReceiptsYet.
    const mask: u32 =
        SyncMode.fast_blocks |
        SyncMode.fast_sync |
        SyncMode.state_nodes |
        SyncMode.snap_sync |
        SyncMode.beacon_headers |
        SyncMode.updating_pivot;
    return (mode & mask) != 0;
}

pub fn have_not_synced_headers_yet(mode: u32) bool {
    // Mirrors: HaveNotSyncedHeadersYet.
    const mask: u32 =
        SyncMode.fast_headers |
        SyncMode.beacon_headers |
        SyncMode.updating_pivot;
    return (mode & mask) != 0;
}

pub fn have_not_synced_state_yet(mode: u32) bool {
    // Mirrors: HaveNotSyncedStateYet.
    const mask: u32 =
        SyncMode.fast_sync |
        SyncMode.state_nodes |
        SyncMode.snap_sync |
        SyncMode.updating_pivot;
    return (mode & mask) != 0;
}

test "SyncMode helper predicates: not_syncing" {
    try std.testing.expect(not_syncing(SyncMode.waiting_for_block));
    try std.testing.expect(not_syncing(SyncMode.disconnected));
    try std.testing.expect(!not_syncing(SyncMode.fast_blocks));
    try std.testing.expect(!not_syncing(SyncMode.full));
}

test "SyncMode helper predicates: have_not_synced_bodies_yet" {
    try std.testing.expect(have_not_synced_bodies_yet(SyncMode.fast_headers));
    try std.testing.expect(have_not_synced_bodies_yet(SyncMode.fast_bodies));
    try std.testing.expect(have_not_synced_bodies_yet(SyncMode.fast_sync));
    try std.testing.expect(have_not_synced_bodies_yet(SyncMode.state_nodes));
    try std.testing.expect(have_not_synced_bodies_yet(SyncMode.snap_sync));
    try std.testing.expect(have_not_synced_bodies_yet(SyncMode.beacon_headers));
    try std.testing.expect(have_not_synced_bodies_yet(SyncMode.updating_pivot));
    try std.testing.expect(!have_not_synced_bodies_yet(SyncMode.full));
    try std.testing.expect(!have_not_synced_bodies_yet(SyncMode.db_load));
    try std.testing.expect(!have_not_synced_bodies_yet(SyncMode.none));
}

test "SyncMode helper predicates: have_not_synced_receipts_yet" {
    try std.testing.expect(have_not_synced_receipts_yet(SyncMode.fast_blocks));
    try std.testing.expect(have_not_synced_receipts_yet(SyncMode.fast_sync));
    try std.testing.expect(have_not_synced_receipts_yet(SyncMode.state_nodes));
    try std.testing.expect(have_not_synced_receipts_yet(SyncMode.snap_sync));
    try std.testing.expect(have_not_synced_receipts_yet(SyncMode.beacon_headers));
    try std.testing.expect(have_not_synced_receipts_yet(SyncMode.updating_pivot));
    try std.testing.expect(!have_not_synced_receipts_yet(SyncMode.full));
    try std.testing.expect(!have_not_synced_receipts_yet(SyncMode.none));
}

test "SyncMode helper predicates: have_not_synced_headers_yet" {
    try std.testing.expect(have_not_synced_headers_yet(SyncMode.fast_headers));
    try std.testing.expect(have_not_synced_headers_yet(SyncMode.beacon_headers));
    try std.testing.expect(have_not_synced_headers_yet(SyncMode.updating_pivot));
    try std.testing.expect(!have_not_synced_headers_yet(SyncMode.full));
    try std.testing.expect(!have_not_synced_headers_yet(SyncMode.none));
}

test "SyncMode helper predicates: have_not_synced_state_yet" {
    try std.testing.expect(have_not_synced_state_yet(SyncMode.fast_sync));
    try std.testing.expect(have_not_synced_state_yet(SyncMode.state_nodes));
    try std.testing.expect(have_not_synced_state_yet(SyncMode.snap_sync));
    try std.testing.expect(have_not_synced_state_yet(SyncMode.updating_pivot));
    try std.testing.expect(!have_not_synced_state_yet(SyncMode.full));
    try std.testing.expect(!have_not_synced_state_yet(SyncMode.none));
}
