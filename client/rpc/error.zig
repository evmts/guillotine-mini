const std = @import("std");
const primitives = @import("primitives");

/// JSON-RPC error codes per EIP-1474 (Voltaire primitive).
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

test "jsonrpc error codes include nethermind extensions" {
    try std.testing.expectEqual(@as(i32, 3), @intFromEnum(JsonRpcErrorCode.execution_reverted));
    try std.testing.expectEqual(@as(i32, 4), @intFromEnum(JsonRpcErrorCode.tx_sync_timeout));
    try std.testing.expectEqual(@as(i32, -32010), @intFromEnum(JsonRpcErrorCode.transaction_rejected_nethermind));
    try std.testing.expectEqual(@as(i32, -32015), @intFromEnum(JsonRpcErrorCode.execution_error));
    try std.testing.expectEqual(@as(i32, -32016), @intFromEnum(JsonRpcErrorCode.timeout));
    try std.testing.expectEqual(@as(i32, -32017), @intFromEnum(JsonRpcErrorCode.module_timeout));
    try std.testing.expectEqual(@as(i32, -32020), @intFromEnum(JsonRpcErrorCode.account_locked));
    try std.testing.expectEqual(@as(i32, -39001), @intFromEnum(JsonRpcErrorCode.unknown_block));
    try std.testing.expectEqual(@as(i32, -38010), @intFromEnum(JsonRpcErrorCode.nonce_too_low));
    try std.testing.expectEqual(@as(i32, -38011), @intFromEnum(JsonRpcErrorCode.nonce_too_high));
    try std.testing.expectEqual(@as(i32, -38013), @intFromEnum(JsonRpcErrorCode.insufficient_intrinsic_gas));
    try std.testing.expectEqual(@as(i32, -38014), @intFromEnum(JsonRpcErrorCode.invalid_transaction));
    try std.testing.expectEqual(@as(i32, -38015), @intFromEnum(JsonRpcErrorCode.block_gas_limit_reached));
    try std.testing.expectEqual(@as(i32, -38020), @intFromEnum(JsonRpcErrorCode.invalid_input_blocks_out_of_order));
    try std.testing.expectEqual(@as(i32, -38021), @intFromEnum(JsonRpcErrorCode.block_timestamp_not_increased));
    try std.testing.expectEqual(@as(i32, -38024), @intFromEnum(JsonRpcErrorCode.sender_is_not_eoa));
    try std.testing.expectEqual(@as(i32, -38025), @intFromEnum(JsonRpcErrorCode.max_init_code_size_exceeded));
    try std.testing.expectEqual(@as(i32, -38026), @intFromEnum(JsonRpcErrorCode.invalid_input_too_many_blocks));
    try std.testing.expectEqual(@as(i32, 4444), @intFromEnum(JsonRpcErrorCode.pruned_history_unavailable));

    try std.testing.expectEqual(@as(i32, -32000), @intFromEnum(JsonRpcErrorCode.resource_not_found_legacy));
    try std.testing.expectEqual(@as(i32, -32000), @intFromEnum(JsonRpcErrorCode.default));
    try std.testing.expectEqual(@as(i32, -32000), @intFromEnum(JsonRpcErrorCode.reverted_simulate));
    try std.testing.expectEqual(@as(i32, -32015), @intFromEnum(JsonRpcErrorCode.vm_error));
    try std.testing.expectEqual(@as(i32, -38013), @intFromEnum(JsonRpcErrorCode.intrinsic_gas));
    try std.testing.expectEqual(@as(i32, -38014), @intFromEnum(JsonRpcErrorCode.insufficient_funds));
    try std.testing.expectEqual(@as(i32, -38020), @intFromEnum(JsonRpcErrorCode.block_number_invalid));
    try std.testing.expectEqual(@as(i32, -38021), @intFromEnum(JsonRpcErrorCode.block_timestamp_invalid));
    try std.testing.expectEqual(@as(i32, -38026), @intFromEnum(JsonRpcErrorCode.client_limit_exceeded_error));
    try std.testing.expectEqual(@as(i32, -38026), @intFromEnum(JsonRpcErrorCode.client_limit_exceeded));
}

test "jsonrpc error default messages include nethermind extensions" {
    try std.testing.expectEqualStrings("Execution reverted", JsonRpcErrorCode.execution_reverted.defaultMessage());
    try std.testing.expectEqualStrings("Timeout", JsonRpcErrorCode.timeout.defaultMessage());
    try std.testing.expectEqualStrings("Account locked", JsonRpcErrorCode.account_locked.defaultMessage());
}
