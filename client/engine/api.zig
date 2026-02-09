const std = @import("std");

/// Engine API error codes per execution-apis `common.md`.
/// Mirrors Nethermind's MergeErrorCodes values.
pub const EngineApiErrorCode = enum(i32) {
    unknown_payload = -38001,
    invalid_forkchoice_state = -38002,
    invalid_payload_attributes = -38003,
    too_large_request = -38004,
    unsupported_fork = -38005,

    pub fn defaultMessage(self: EngineApiErrorCode) []const u8 {
        return switch (self) {
            .unknown_payload => "Unknown payload",
            .invalid_forkchoice_state => "Invalid forkchoice state",
            .invalid_payload_attributes => "Invalid payload attributes",
            .too_large_request => "Too large request",
            .unsupported_fork => "Unsupported fork",
        };
    }
};

// ============================================================================
// Tests
// ============================================================================

test "engine api error codes match execution-apis common definitions" {
    try std.testing.expectEqual(@as(i32, -38001), @intFromEnum(EngineApiErrorCode.unknown_payload));
    try std.testing.expectEqual(@as(i32, -38002), @intFromEnum(EngineApiErrorCode.invalid_forkchoice_state));
    try std.testing.expectEqual(@as(i32, -38003), @intFromEnum(EngineApiErrorCode.invalid_payload_attributes));
    try std.testing.expectEqual(@as(i32, -38004), @intFromEnum(EngineApiErrorCode.too_large_request));
    try std.testing.expectEqual(@as(i32, -38005), @intFromEnum(EngineApiErrorCode.unsupported_fork));
}

test "engine api error code default messages follow execution-apis" {
    try std.testing.expectEqualStrings("Unknown payload", EngineApiErrorCode.unknown_payload.defaultMessage());
    try std.testing.expectEqualStrings("Invalid forkchoice state", EngineApiErrorCode.invalid_forkchoice_state.defaultMessage());
    try std.testing.expectEqualStrings("Invalid payload attributes", EngineApiErrorCode.invalid_payload_attributes.defaultMessage());
    try std.testing.expectEqualStrings("Too large request", EngineApiErrorCode.too_large_request.defaultMessage());
    try std.testing.expectEqualStrings("Unsupported fork", EngineApiErrorCode.unsupported_fork.defaultMessage());
}
