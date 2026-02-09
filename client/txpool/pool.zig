const std = @import("std");
const primitives = @import("primitives");
const GasLimit = primitives.Gas.GasLimit;
const MaxPriorityFeePerGas = primitives.MaxPriorityFeePerGas;

/// Transaction pool configuration defaults, modeled after Nethermind's
/// `ITxPoolConfig` / `TxPoolConfig`.
pub const TxPoolConfig = struct {
    /// Blob transaction storage policy.
    pub const BlobsSupportMode = enum(u8) {
        disabled,
        in_memory,
        storage,
        storage_with_reorgs,
    };

    peer_notification_threshold: u32 = 5,
    min_base_fee_threshold: u32 = 70,
    size: usize = 2048,
    blobs_support: BlobsSupportMode = .storage_with_reorgs,
    persistent_blob_storage_size: usize = 16 * 1024,
    blob_cache_size: usize = 256,
    in_memory_blob_pool_size: usize = 512,
    max_pending_txs_per_sender: usize = 0,
    max_pending_blob_txs_per_sender: usize = 16,
    hash_cache_size: usize = 512 * 1024,
    gas_limit: ?GasLimit = null,
    max_tx_size: ?u64 = 128 * 1024,
    max_blob_tx_size: ?u64 = 1024 * 1024,
    proofs_translation_enabled: bool = false,
    report_minutes: ?u32 = null,
    accept_tx_when_not_synced: bool = false,
    persistent_broadcast_enabled: bool = true,
    current_blob_base_fee_required: bool = true,
    min_blob_tx_priority_fee: MaxPriorityFeePerGas = MaxPriorityFeePerGas.from(0),
};

/// Transaction pool interface (minimal vtable surface).
///
/// Mirrors the first two members of Nethermind's `ITxPool`:
/// - `GetPendingTransactionsCount()`
/// - `GetPendingBlobTransactionsCount()`
/// Vtable-based txpool interface for dependency injection.
///
/// This mirrors the HostInterface pattern used by the EVM and allows
/// compile-time wiring of concrete pool implementations.
pub const TxPool = struct {
    /// Type-erased pointer to the concrete txpool implementation.
    ptr: *anyopaque,
    /// Pointer to the static vtable for the concrete txpool implementation.
    vtable: *const VTable,

    /// Virtual function table for txpool operations.
    pub const VTable = struct {
        /// Total number of pending transactions in the pool.
        pending_count: *const fn (ptr: *anyopaque) usize,
        /// Total number of pending blob transactions in the pool.
        pending_blob_count: *const fn (ptr: *anyopaque) usize,
    };

    /// Total number of pending transactions in the pool.
    pub fn pending_count(self: TxPool) usize {
        return self.vtable.pending_count(self.ptr);
    }

    /// Total number of pending blob transactions in the pool.
    pub fn pending_blob_count(self: TxPool) usize {
        return self.vtable.pending_blob_count(self.ptr);
    }
};

// ============================================================================
// Tests
// ============================================================================

test "txpool interface dispatches pending counts" {
    const DummyPool = struct {
        pending: usize,
        pending_blobs: usize,

        fn pending_count(ptr: *anyopaque) usize {
            const self: *DummyPool = @ptrCast(@alignCast(ptr));
            return self.pending;
        }

        fn pending_blob_count(ptr: *anyopaque) usize {
            const self: *DummyPool = @ptrCast(@alignCast(ptr));
            return self.pending_blobs;
        }
    };

    var dummy = DummyPool{ .pending = 42, .pending_blobs = 7 };
    const vtable = TxPool.VTable{
        .pending_count = DummyPool.pending_count,
        .pending_blob_count = DummyPool.pending_blob_count,
    };

    const pool = TxPool{ .ptr = &dummy, .vtable = &vtable };
    try std.testing.expectEqual(@as(usize, 42), pool.pending_count());
    try std.testing.expectEqual(@as(usize, 7), pool.pending_blob_count());
}
