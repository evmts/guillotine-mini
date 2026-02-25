/// Sync status resolver: maps SyncMode + head/highest to Voltaire SyncStatus.
///
/// Mirrors Nethermind's EthSyncingInfo high-level semantics:
/// - If node is far from head (by a small distance threshold), report syncing
/// - Otherwise, if any fast/snap phases are still active, report syncing
/// - Else, report not syncing
const std = @import("std");
const SyncStatusMod = @import("voltaire").SyncStatus;
const SyncStatus = SyncStatusMod.SyncStatus;
const mode = @import("mode.zig");

/// Default block distance threshold considered "synced" to head.
/// Chosen to mirror Nethermind-style small tolerance while avoiding flapping.
pub const DEFAULT_MAX_DISTANCE_FOR_SYNCED: u64 = 8;

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
    // Unknown best-known head (e.g. no peer estimates yet) must be treated as syncing.
    // Mirrors Nethermind BlockTreeExtensions.IsSyncing semantics for highest == 0.
    if (highest_block == 0) {
        return SyncStatusMod.syncing(0, current_block, highest_block);
    }
    // Primary criterion: distance to best suggested head.
    if (!is_synced_by_distance(current_block, highest_block, max_distance_for_synced)) {
        return SyncStatusMod.syncing(0, current_block, highest_block);
    }

    // Secondary criteria: gate only on fast-blocks bodies/receipts near head.
    const fast_bodies_flag: u32 = mode.SyncMode.fast_bodies & ~mode.SyncMode.fast_blocks;
    const fast_receipts_flag: u32 = mode.SyncMode.fast_receipts & ~mode.SyncMode.fast_blocks;
    const gate_fast_bodies = (sync_mode & fast_bodies_flag) != 0;
    const gate_fast_receipts = (sync_mode & fast_receipts_flag) != 0;
    if (gate_fast_bodies or gate_fast_receipts) {
        return SyncStatusMod.syncing(0, current_block, highest_block);
    }
    // Once chain progress wiring is available, plumb the actual starting block into to_sync_status.
    return SyncStatusMod.notSyncing();
}

/// Convenience wrapper that applies the default distance threshold.
/// This is the preferred entry point for external callers unless they
/// explicitly want a custom tolerance.
pub fn default_to_sync_status(sync_mode: u32, current_block: u64, highest_block: u64) SyncStatus {
    return to_sync_status(sync_mode, current_block, highest_block, DEFAULT_MAX_DISTANCE_FOR_SYNCED);
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

test "default_to_sync_status: equals explicit threshold" {
    const s1 = default_to_sync_status(mode.SyncMode.waiting_for_block, 100, 108);
    const s2 = to_sync_status(mode.SyncMode.waiting_for_block, 100, 108, DEFAULT_MAX_DISTANCE_FOR_SYNCED);
    try std.testing.expectEqual(s1.isSyncing(), s2.isSyncing());
}

test "default_to_sync_status: far from head => syncing" {
    const s = default_to_sync_status(mode.SyncMode.waiting_for_block, 100, 109);
    try std.testing.expect(s.isSyncing());
}

test "default_to_sync_status: near head + waiting => not syncing" {
    const s = default_to_sync_status(mode.SyncMode.waiting_for_block, 1000, 1005);
    try std.testing.expect(!s.isSyncing());
}

test "default_to_sync_status: near head but fast phases => syncing" {
    const s = default_to_sync_status(mode.SyncMode.fast_bodies, 1000, 1005);
    try std.testing.expect(s.isSyncing());
}

test "to_sync_status: unknown highest (0) reports syncing even at head" {
    const s0 = to_sync_status(mode.SyncMode.waiting_for_block, 0, 0, 8);
    try std.testing.expect(s0.isSyncing());
    const s1 = to_sync_status(mode.SyncMode.waiting_for_block, 1000, 0, 8);
    try std.testing.expect(s1.isSyncing());
}
test "to_sync_status: near head with only headers/state does NOT gate syncing" {
    const near: u64 = 1000;
    const highest: u64 = 1005;
    const s_headers = to_sync_status(mode.SyncMode.fast_headers, near, highest, 8);
    try std.testing.expect(!s_headers.isSyncing());
    const s_state = to_sync_status(mode.SyncMode.state_nodes, near, highest, 8);
    try std.testing.expect(!s_state.isSyncing());
}
test "to_sync_status: current > highest is treated as synced (not syncing)" {
    const s = to_sync_status(mode.SyncMode.waiting_for_block, 1010, 1005, 8);
    try std.testing.expect(!s.isSyncing());
}
