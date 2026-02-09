/// Transaction pool interface (minimal vtable surface).
///
/// Mirrors the first two members of Nethermind's `ITxPool`:
/// - `GetPendingTransactionsCount()`
/// - `GetPendingBlobTransactionsCount()`
const std = @import("std");

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
