/// TxPool module root: re-exports public surface for tests and consumers.
const std = @import("std");

const pool = @import("pool.zig");
const sorter = @import("sorter.zig");
const limits = @import("limits.zig");
const policy = @import("policy.zig");

/// Transaction pool interface (vtable-based). Mirrors Nethermind's ITxPool minimal surface (parity note: names & behavior audited against Nethermind).
pub const TxPool = pool.TxPool;
/// Transaction pool configuration (defaults align with Nethermind).
pub const TxPoolConfig = pool.TxPoolConfig;
/// Fee market comparator (EIP-1559-aware).
pub const compare_fee_market_priority = sorter.compare_fee_market_priority;
/// Broadcast policy helper: base-fee threshold calculator (parity with Nethermind's TxBroadcaster.CalculateBaseFeeThreshold).
pub const calculate_base_fee_threshold = policy.calculate_base_fee_threshold;
/// Broadcast policy helper: persistent broadcast quota per block.
pub const calculate_persistent_broadcast_quota = policy.calculate_persistent_broadcast_quota;

/// Admission helper: re-export to avoid wrapper signature drift.
pub const fits_size_limits = limits.fits_size_limits;
pub const fits_gas_limit = limits.fits_gas_limit;
pub const enforce_min_priority_fee_for_blobs = limits.enforce_min_priority_fee_for_blobs;
pub const enforce_nonce_gap = limits.enforce_nonce_gap;

test {
    std.testing.refAllDecls(@This());
}
