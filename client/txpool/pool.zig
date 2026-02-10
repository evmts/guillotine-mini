const std = @import("std");
const primitives = @import("primitives");
const GasLimit = primitives.Gas.GasLimit;
const Address = primitives.Address;

/// Transaction pool configuration defaults, modeled after Nethermind's
/// `ITxPoolConfig` / `TxPoolConfig`.
pub const TxPoolConfig = struct {
    /// Blob transaction storage policy.
    pub const BlobsSupportMode = enum(u8) {
        /// Do not accept or store blob transactions.
        disabled,
        /// Keep blob transactions only in memory.
        in_memory,
        /// Persist blob transactions without reorg handling.
        storage,
        /// Persist blob transactions and retain reorg metadata.
        storage_with_reorgs,

        fn is_persistent_storage(self: BlobsSupportMode) bool {
            return self == .storage or self == .storage_with_reorgs;
        }

        fn is_enabled(self: BlobsSupportMode) bool {
            return self != .disabled;
        }

        fn is_disabled(self: BlobsSupportMode) bool {
            return self == .disabled;
        }

        fn supports_reorgs(self: BlobsSupportMode) bool {
            return self == .storage_with_reorgs;
        }
    };

    /// Percent of persistent transactions announced per block (0 disables).
    peer_notification_threshold: u32 = 5,
    /// Base fee multiplier threshold (percent) used for broadcast filtering.
    min_base_fee_threshold: u32 = 70,
    /// Maximum number of pending non-blob transactions in the pool.
    size: u32 = 2048,
    /// Blob transaction storage mode.
    blobs_support: BlobsSupportMode = .storage_with_reorgs,
    /// Persistent blob storage capacity (transaction count).
    persistent_blob_storage_size: u32 = 16 * 1024,
    /// LRU cache size for full blob transactions.
    blob_cache_size: u32 = 256,
    /// In-memory blob pool capacity when persistence is disabled.
    in_memory_blob_pool_size: u32 = 512,
    /// Max pending non-blob txs per sender (0 disables limit).
    max_pending_txs_per_sender: u32 = 0,
    /// Max pending blob txs per sender (0 disables limit).
    max_pending_blob_txs_per_sender: u32 = 16,
    /// Hash cache size for duplicate transaction suppression.
    hash_cache_size: u32 = 512 * 1024,
    /// Optional gas limit cap for incoming transactions.
    gas_limit: ?GasLimit = null,
    /// Maximum non-blob transaction size in bytes (null disables limit).
    max_tx_size: ?u64 = 128 * 1024,
    /// Maximum blob transaction size in bytes (null disables limit).
    max_blob_tx_size: ?u64 = 1024 * 1024,
    /// Enable translation of blob proof versions on intake.
    proofs_translation_enabled: bool = false,
    /// Optional reporting interval in minutes (null disables reporting).
    report_minutes: ?u32 = null,
    /// Accept transactions while the node is syncing.
    accept_tx_when_not_synced: bool = false,
    /// Enable persistent broadcast for locally submitted transactions.
    persistent_broadcast_enabled: bool = true,
    /// Require max fee per blob gas to meet current blob base fee.
    current_blob_base_fee_required: bool = true,
    /// Minimum priority fee required for blob transactions (semantic type).
    min_blob_tx_priority_fee: primitives.MaxPriorityFeePerGas = primitives.MaxPriorityFeePerGas.from(0),
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
        /// Number of pending transactions for a specific sender address.
        get_pending_count_for_sender: *const fn (ptr: *anyopaque, sender: Address) usize,
    };

    /// Total number of pending transactions in the pool.
    pub fn pending_count(self: TxPool) usize {
        return self.vtable.pending_count(self.ptr);
    }

    /// Total number of pending blob transactions in the pool.
    pub fn pending_blob_count(self: TxPool) usize {
        return self.vtable.pending_blob_count(self.ptr);
    }

    /// Number of pending transactions currently tracked for `sender`.
    ///
    /// This mirrors Nethermind's per-sender pending count surface and is used
    /// by admission logic to enforce nonce gap constraints.
    pub fn get_pending_count_for_sender(self: TxPool, sender: Address) usize {
        return self.vtable.get_pending_count_for_sender(self.ptr, sender);
    }
};

// ============================================================================
// Tests
// ============================================================================

test "txpool interface dispatches pending counts" {
    const DummyPool = struct {
        pending: usize,
        pending_blobs: usize,
        match_sender: Address,
        pending_for_sender: usize,

        fn pending_count(ptr: *anyopaque) usize {
            const Self = @This();
            const self: *Self = @ptrCast(@alignCast(ptr));
            return self.pending;
        }

        fn pending_blob_count(ptr: *anyopaque) usize {
            const Self = @This();
            const self: *Self = @ptrCast(@alignCast(ptr));
            return self.pending_blobs;
        }

        fn get_pending_count_for_sender(ptr: *anyopaque, sender: Address) usize {
            const Self = @This();
            const self: *Self = @ptrCast(@alignCast(ptr));
            return if (std.mem.eql(u8, &self.match_sender.bytes, &sender.bytes))
                self.pending_for_sender
            else
                0;
        }
    };

    const target = Address{ .bytes = [_]u8{0xAB} ++ [_]u8{0} ** 19 };
    var dummy = DummyPool{
        .pending = 42,
        .pending_blobs = 7,
        .match_sender = target,
        .pending_for_sender = 3,
    };
    const vtable = TxPool.VTable{
        .pending_count = DummyPool.pending_count,
        .pending_blob_count = DummyPool.pending_blob_count,
        .get_pending_count_for_sender = DummyPool.get_pending_count_for_sender,
    };

    const pool = TxPool{ .ptr = &dummy, .vtable = &vtable };
    try std.testing.expectEqual(@as(usize, 42), pool.pending_count());
    try std.testing.expectEqual(@as(usize, 7), pool.pending_blob_count());
    try std.testing.expectEqual(@as(usize, 3), pool.get_pending_count_for_sender(target));
    const other = Address{ .bytes = [_]u8{0xBA} ++ [_]u8{0} ** 19 };
    try std.testing.expectEqual(@as(usize, 0), pool.get_pending_count_for_sender(other));
}

test "blobs support mode helpers mirror nethermind semantics" {
    const Mode = TxPoolConfig.BlobsSupportMode;

    try std.testing.expect(Mode.disabled.is_disabled());
    try std.testing.expect(!Mode.disabled.is_enabled());
    try std.testing.expect(!Mode.disabled.is_persistent_storage());
    try std.testing.expect(!Mode.disabled.supports_reorgs());

    try std.testing.expect(Mode.in_memory.is_enabled());
    try std.testing.expect(!Mode.in_memory.is_disabled());
    try std.testing.expect(!Mode.in_memory.is_persistent_storage());
    try std.testing.expect(!Mode.in_memory.supports_reorgs());

    try std.testing.expect(Mode.storage.is_enabled());
    try std.testing.expect(!Mode.storage.is_disabled());
    try std.testing.expect(Mode.storage.is_persistent_storage());
    try std.testing.expect(!Mode.storage.supports_reorgs());

    try std.testing.expect(Mode.storage_with_reorgs.is_enabled());
    try std.testing.expect(!Mode.storage_with_reorgs.is_disabled());
    try std.testing.expect(Mode.storage_with_reorgs.is_persistent_storage());
    try std.testing.expect(Mode.storage_with_reorgs.supports_reorgs());
}

test "txpool config defaults match nethermind" {
    const config = TxPoolConfig{};

    try std.testing.expectEqual(@as(u32, 5), config.peer_notification_threshold);
    try std.testing.expectEqual(@as(u32, 70), config.min_base_fee_threshold);
    try std.testing.expectEqual(@as(u32, 2048), config.size);
    try std.testing.expectEqual(TxPoolConfig.BlobsSupportMode.storage_with_reorgs, config.blobs_support);
    try std.testing.expectEqual(@as(u32, 16 * 1024), config.persistent_blob_storage_size);
    try std.testing.expectEqual(@as(u32, 256), config.blob_cache_size);
    try std.testing.expectEqual(@as(u32, 512), config.in_memory_blob_pool_size);
    try std.testing.expectEqual(@as(u32, 0), config.max_pending_txs_per_sender);
    try std.testing.expectEqual(@as(u32, 16), config.max_pending_blob_txs_per_sender);
    try std.testing.expectEqual(@as(u32, 512 * 1024), config.hash_cache_size);
    try std.testing.expectEqual(@as(?GasLimit, null), config.gas_limit);
    try std.testing.expectEqual(@as(?u64, 128 * 1024), config.max_tx_size);
    try std.testing.expectEqual(@as(?u64, 1024 * 1024), config.max_blob_tx_size);
    try std.testing.expect(!config.proofs_translation_enabled);
    try std.testing.expectEqual(@as(?u32, null), config.report_minutes);
    try std.testing.expect(!config.accept_tx_when_not_synced);
    try std.testing.expect(config.persistent_broadcast_enabled);
    try std.testing.expect(config.current_blob_base_fee_required);
    try std.testing.expect(config.min_blob_tx_priority_fee.isZero());
}
