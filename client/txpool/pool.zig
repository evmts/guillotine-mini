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
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        pendingCount: *const fn (ptr: *anyopaque) u64,
        pendingBlobCount: *const fn (ptr: *anyopaque) u64,
    };

    /// Total number of pending transactions in the pool.
    pub fn pendingCount(self: TxPool) u64 {
        return self.vtable.pendingCount(self.ptr);
    }

    /// Total number of pending blob transactions in the pool.
    pub fn pendingBlobCount(self: TxPool) u64 {
        return self.vtable.pendingBlobCount(self.ptr);
    }
};

// ============================================================================
// Tests
// ============================================================================

test "txpool interface dispatches pending counts" {
    const DummyPool = struct {
        pending: u64,
        pending_blobs: u64,

        fn pendingCount(ptr: *anyopaque) u64 {
            const self: *DummyPool = @ptrCast(@alignCast(ptr));
            return self.pending;
        }

        fn pendingBlobCount(ptr: *anyopaque) u64 {
            const self: *DummyPool = @ptrCast(@alignCast(ptr));
            return self.pending_blobs;
        }
    };

    var dummy = DummyPool{ .pending = 42, .pending_blobs = 7 };
    const vtable = TxPool.VTable{
        .pendingCount = DummyPool.pendingCount,
        .pendingBlobCount = DummyPool.pendingBlobCount,
    };

    const pool = TxPool{ .ptr = &dummy, .vtable = &vtable };
    try std.testing.expectEqual(@as(u64, 42), pool.pendingCount());
    try std.testing.expectEqual(@as(u64, 7), pool.pendingBlobCount());
}
