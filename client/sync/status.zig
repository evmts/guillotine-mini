/// Sync status resolver: maps SyncMode + head/highest to Voltaire SyncStatus.
///
/// Mirrors Nethermind's EthSyncingInfo high-level semantics:
/// - If node is far from head (by a small distance threshold), report syncing
/// - Otherwise, if any fast/snap phases are still active, report syncing
/// - Else, report not syncing
const std = @import("std");
const primitives = @import("primitives");
const SyncStatusMod = @import("primitives").SyncStatus;
const SyncStatus = SyncStatusMod.SyncStatus;
const mode = @import("mode.zig");

/// Return true when the current head is considered "synced" to the network head
/// within the provided distance threshold. Equivalent to Nethermind's
/// BlockTree.IsSyncing(maxDistanceForSynced: X) inverted.
pub fn is_synced_by_distance(current_block: u64, highest_block: u64, max_distance_for_synced: u64) bool {
    if (highest_block <= current_block) return true;
    const distance = highest_block - current_block;
    return distance <= max_distance_for_synced;
}

/// Convert sync mode and chain progress counters into a Voltaire SyncStatus.
/// - If far from head (distance > threshold), returns syncing(start=0, current=head, highest)
/// - Else if any body/receipt/header/state phases are incomplete per SyncMode, returns syncing
/// - Else returns not_syncing
pub fn to_sync_status(sync_mode: u32, current_block: u64, highest_block: u64, max_distance_for_synced: u64) SyncStatus {
    // Primary criterion: distance to best suggested head.
    if (!is_synced_by_distance(current_block, highest_block, max_distance_for_synced)) {
        return SyncStatusMod.syncing(0, current_block, highest_block);
    }

    // Secondary criteria: explicit phase masks (Nethermind-compatible helpers).
    if (mode.have_not_synced_bodies_yet(sync_mode)) {
        return SyncStatusMod.syncing(0, current_block, highest_block);
    }
    if (mode.have_not_synced_receipts_yet(sync_mode)) {
        return SyncStatusMod.syncing(0, current_block, highest_block);
    }
    if (mode.have_not_synced_headers_yet(sync_mode)) {
        return SyncStatusMod.syncing(0, current_block, highest_block);
    }
    if (mode.have_not_synced_state_yet(sync_mode)) {
        return SyncStatusMod.syncing(0, current_block, highest_block);
    }

    return SyncStatusMod.notSyncing();
}

// ============================================================================
// Tests
// ============================================================================

test "is_synced_by_distance: exact and within threshold are synced" {
    try std.testing.expect(is_synced_by_distance(100, 100, 8));
    try std.testing.expect(is_synced_by_distance(100, 108, 8));
}

test "is_synced_by_distance: beyond threshold is not synced" {
    try std.testing.expect(!is_synced_by_distance(100, 109, 8));
}

test "to_sync_status: far from head reports syncing" {
    const s = to_sync_status(mode.SyncMode.waiting_for_block, 100, 1000, 8);
    try std.testing.expect(s.isSyncing());
    try std.testing.expectEqual(@as(?u64, 100), s.getCurrentBlock());
    try std.testing.expectEqual(@as(?u64, 1000), s.getHighestBlock());
}

test "to_sync_status: near head but fast phases active reports syncing" {
    // Near head (within threshold), but have_not_synced_bodies_yet => syncing.
    const near_head: u64 = 1000;
    const highest: u64 = 1005;
    const sync_mode = mode.SyncMode.fast_bodies; // implies have_not_synced_bodies_yet
    const s = to_sync_status(sync_mode, near_head, highest, 8);
    try std.testing.expect(s.isSyncing());
}

test "to_sync_status: fully synced and no phases active reports not_syncing" {
    const s = to_sync_status(mode.SyncMode.waiting_for_block, 2000, 2000, 8);
    try std.testing.expect(!s.isSyncing());
}
