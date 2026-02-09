/// JSON-RPC error codes per EIP-1474.
const std = @import("std");

pub const JsonRpcErrorCode = enum(i32) {
    parse_error = -32700,
    invalid_request = -32600,
    method_not_found = -32601,
    invalid_params = -32602,
    internal_error = -32603,
    invalid_input = -32000,
    resource_not_found = -32001,
    resource_unavailable = -32002,
    transaction_rejected = -32003,
    method_not_supported = -32004,
    limit_exceeded = -32005,
    jsonrpc_version_not_supported = -32006,

    pub fn defaultMessage(self: JsonRpcErrorCode) []const u8 {
        return switch (self) {
            .parse_error => "Parse error",
            .invalid_request => "Invalid request",
            .method_not_found => "Method not found",
            .invalid_params => "Invalid params",
            .internal_error => "Internal error",
            .invalid_input => "Invalid input",
            .resource_not_found => "Resource not found",
            .resource_unavailable => "Resource unavailable",
            .transaction_rejected => "Transaction rejected",
            .method_not_supported => "Method not supported",
            .limit_exceeded => "Limit exceeded",
            .jsonrpc_version_not_supported => "JSON-RPC version not supported",
        };
    }
};

// ============================================================================
// Tests
// ============================================================================

test "jsonrpc error codes match eip-1474" {
    try std.testing.expectEqual(@as(i32, -32700), @intFromEnum(JsonRpcErrorCode.parse_error));
    try std.testing.expectEqual(@as(i32, -32600), @intFromEnum(JsonRpcErrorCode.invalid_request));
    try std.testing.expectEqual(@as(i32, -32601), @intFromEnum(JsonRpcErrorCode.method_not_found));
    try std.testing.expectEqual(@as(i32, -32602), @intFromEnum(JsonRpcErrorCode.invalid_params));
    try std.testing.expectEqual(@as(i32, -32603), @intFromEnum(JsonRpcErrorCode.internal_error));
    try std.testing.expectEqual(@as(i32, -32000), @intFromEnum(JsonRpcErrorCode.invalid_input));
    try std.testing.expectEqual(@as(i32, -32001), @intFromEnum(JsonRpcErrorCode.resource_not_found));
    try std.testing.expectEqual(@as(i32, -32002), @intFromEnum(JsonRpcErrorCode.resource_unavailable));
    try std.testing.expectEqual(@as(i32, -32003), @intFromEnum(JsonRpcErrorCode.transaction_rejected));
    try std.testing.expectEqual(@as(i32, -32004), @intFromEnum(JsonRpcErrorCode.method_not_supported));
    try std.testing.expectEqual(@as(i32, -32005), @intFromEnum(JsonRpcErrorCode.limit_exceeded));
    try std.testing.expectEqual(@as(i32, -32006), @intFromEnum(JsonRpcErrorCode.jsonrpc_version_not_supported));
}

test "jsonrpc error default messages follow eip-1474" {
    try std.testing.expectEqualStrings("Parse error", JsonRpcErrorCode.parse_error.defaultMessage());
    try std.testing.expectEqualStrings("Invalid request", JsonRpcErrorCode.invalid_request.defaultMessage());
    try std.testing.expectEqualStrings("Method not found", JsonRpcErrorCode.method_not_found.defaultMessage());
    try std.testing.expectEqualStrings("Invalid params", JsonRpcErrorCode.invalid_params.defaultMessage());
    try std.testing.expectEqualStrings("Internal error", JsonRpcErrorCode.internal_error.defaultMessage());
    try std.testing.expectEqualStrings("Invalid input", JsonRpcErrorCode.invalid_input.defaultMessage());
    try std.testing.expectEqualStrings("Resource not found", JsonRpcErrorCode.resource_not_found.defaultMessage());
    try std.testing.expectEqualStrings("Resource unavailable", JsonRpcErrorCode.resource_unavailable.defaultMessage());
    try std.testing.expectEqualStrings("Transaction rejected", JsonRpcErrorCode.transaction_rejected.defaultMessage());
    try std.testing.expectEqualStrings("Method not supported", JsonRpcErrorCode.method_not_supported.defaultMessage());
    try std.testing.expectEqualStrings("Limit exceeded", JsonRpcErrorCode.limit_exceeded.defaultMessage());
    try std.testing.expectEqualStrings("JSON-RPC version not supported", JsonRpcErrorCode.jsonrpc_version_not_supported.defaultMessage());
}
