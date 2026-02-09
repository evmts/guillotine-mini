const std = @import("std");
const primitives = @import("primitives");

/// Snappy compressed payload size limit for RLPx (Snappy framing is not used).
/// Mirrors Nethermind's SnappyParameters.MaxSnappyLength.
pub const SnappyParameters = primitives.SnappyParameters;

test "snappy max length is 16 MiB" {
    try std.testing.expectEqual(@as(usize, 16 * 1024 * 1024), SnappyParameters.MaxSnappyLength);
}
