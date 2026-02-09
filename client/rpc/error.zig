/// JSON-RPC error codes per EIP-1474 (Voltaire primitive).
const std = @import("std");
const primitives = @import("primitives");

pub const JsonRpcErrorCode = primitives.JsonRpcErrorCode;

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
