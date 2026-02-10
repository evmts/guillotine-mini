/// TxPool module root: re-exports public surface for tests and consumers.
const std = @import("std");

const pool = @import("pool.zig");
const sorter = @import("sorter.zig");
const limits = @import("limits.zig");

pub const TxPool = pool.TxPool;
pub const TxPoolConfig = pool.TxPoolConfig;

// Fee market comparator (EIP-1559-aware)
pub const compare_fee_market_priority = sorter.compare_fee_market_priority;

// Admission helpers
pub fn fits_size_limits(allocator: std.mem.Allocator, tx: anytype, cfg: TxPoolConfig) (error{ MaxTxSizeExceeded, MaxBlobTxSizeExceeded } || std.mem.Allocator.Error)!void {
    return limits.fits_size_limits(allocator, tx, cfg);
}

test {
    std.testing.refAllDecls(@This());
}
