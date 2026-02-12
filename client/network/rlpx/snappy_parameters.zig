const std = @import("std");
// Voltaire primitives currently don't export SnappyParameters. Provide a tiny
// local shim until upstream exposes it.

/// Snappy compressed payload size limit for RLPx payloads.
/// Mirrors Nethermind's SnappyParameters.MaxSnappyLength.
pub const SnappyParameters = struct {
    pub const MaxSnappyLength: usize = 16 * 1024 * 1024;
};

test "snappy max length is 16 MiB" {
    try std.testing.expectEqual(@as(usize, 16 * 1024 * 1024), SnappyParameters.MaxSnappyLength);
}
