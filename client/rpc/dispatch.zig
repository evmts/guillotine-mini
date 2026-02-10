//! Lightweight JSON-RPC method resolver using Voltaire enums.
//!
//! Purpose: map a JSON-RPC `method` string to its namespace (engine/eth/debug)
//! without allocating or constructing full request payloads. Mirrors the
//! initial routing step in Nethermind's JsonRpcProcessor.

const std = @import("std");
const jsonrpc = @import("jsonrpc");

/// Returns the root namespace tag of a JSON-RPC method name.
/// - `.engine` for Engine API
/// - `.eth` for Ethereum API
/// - `.debug` for Debug API
/// - `null` if the method is unknown to all namespaces
pub fn resolveNamespace(method_name: []const u8) ?std.meta.Tag(jsonrpc.JsonRpcMethod) {
    // Try Engine namespace
    if (jsonrpc.engine.fromMethodName(method_name)) |_| {
        return .engine;
    } else |_| {}

    // Try Eth namespace
    if (jsonrpc.eth.fromMethodName(method_name)) |_| {
        return .eth;
    } else |_| {}

    // Try Debug namespace
    if (jsonrpc.debug.fromMethodName(method_name)) |_| {
        return .debug;
    } else |_| {}

    return null;
}

test "resolveNamespace returns .eth for eth_*" {
    const tag = resolveNamespace("eth_blockNumber");
    try std.testing.expect(tag != null);
    try std.testing.expectEqual(std.meta.Tag(jsonrpc.JsonRpcMethod).eth, tag.?);
}

test "resolveNamespace returns .engine for engine_*" {
    const tag = resolveNamespace("engine_getPayloadV3");
    try std.testing.expect(tag != null);
    try std.testing.expectEqual(std.meta.Tag(jsonrpc.JsonRpcMethod).engine, tag.?);
}

test "resolveNamespace returns null for unknown" {
    try std.testing.expect(resolveNamespace("unknown_method") == null);
}
