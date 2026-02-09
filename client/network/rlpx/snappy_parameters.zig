const std = @import("std");

/// Snappy framing limits for RLPx compressed payloads.
/// Mirrors Nethermind's SnappyParameters.MaxSnappyLength.
pub const SnappyParameters = struct {
    /// Maximum uncompressed payload size (16 MiB).
    pub const max_snappy_length: usize = 16 * 1024 * 1024;
};

test "snappy max length is 16 MiB" {
    try std.testing.expectEqual(@as(usize, 16 * 1024 * 1024), SnappyParameters.max_snappy_length);
}
