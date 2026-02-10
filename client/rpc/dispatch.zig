//! Lightweight JSON-RPC method resolver using Voltaire enums.
//!
//! Purpose: map a JSON-RPC `method` string to its namespace (engine/eth/debug)
//! without allocating or constructing full request payloads. Mirrors the
//! initial routing step in Nethermind's JsonRpcProcessor.

const std = @import("std");
const jsonrpc = @import("jsonrpc");
const primitives = @import("primitives");

/// Returns the root namespace tag of a JSON-RPC method name.
/// - `.engine` for Engine API
/// - `.eth` for Ethereum API
/// - `.debug` for Debug API
/// - `null` if the method is unknown to all namespaces
pub fn resolveNamespace(method_name: []const u8) ?std.meta.Tag(jsonrpc.JsonRpcMethod) {
    // Fast prefix short-circuit: only probe the relevant namespace
    if (std.mem.startsWith(u8, method_name, "eth_")) {
        if (jsonrpc.eth.fromMethodName(method_name)) |tag| {
            _ = tag;
            return .eth;
        } else |err| switch (err) {
            error.UnknownMethod => return null,
            else => return null,
        }
    }
    if (std.mem.startsWith(u8, method_name, "engine_")) {
        if (jsonrpc.engine.fromMethodName(method_name)) |tag| {
            _ = tag;
            return .engine;
        } else |err| switch (err) {
            error.UnknownMethod => return null,
            else => return null,
        }
    }
    if (std.mem.startsWith(u8, method_name, "debug_")) {
        if (jsonrpc.debug.fromMethodName(method_name)) |tag| {
            _ = tag;
            return .debug;
        } else |err| switch (err) {
            error.UnknownMethod => return null,
            else => return null,
        }
    }

    // Try Engine namespace
    if (jsonrpc.engine.fromMethodName(method_name)) |tag| {
        _ = tag; // tag not used beyond confirming success
        return .engine;
    } else |err| switch (err) {
        error.UnknownMethod => {}, // continue probing other namespaces
        else => return null, // defensive: unexpected error -> no match
    }

    // Try Eth namespace
    if (jsonrpc.eth.fromMethodName(method_name)) |tag| {
        _ = tag;
        return .eth;
    } else |err| switch (err) {
        error.UnknownMethod => {},
        else => return null,
    }

    // Try Debug namespace
    if (jsonrpc.debug.fromMethodName(method_name)) |tag| {
        _ = tag;
        return .debug;
    } else |err| switch (err) {
        error.UnknownMethod => {},
        else => return null,
    }

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

/// Minimal JSON-RPC request parser that extracts the `method` string and
/// resolves it to a root namespace tag. Returns an EIP-1474 error code for
/// unknown methods without allocating or fully parsing the JSON.
pub const ParseNamespaceResult = union(enum) {
    namespace: std.meta.Tag(jsonrpc.JsonRpcMethod),
    err: primitives.JsonRpcErrorCode,
};

/// Extracts the `method` field from a JSON-RPC request and returns its
/// resolved namespace tag. If the method is unknown, returns
/// `.error(.method_not_found)`. If the field is missing or malformed,
/// returns `.error(.invalid_request)` per EIP-1474.
pub fn parseRequestNamespace(request: []const u8) ParseNamespaceResult {
    const key = "\"method\"";
    const idx_opt = std.mem.indexOf(u8, request, key);
    if (idx_opt == null) return .{ .err = .invalid_request };

    var i: usize = idx_opt.? + key.len;
    // Skip whitespace to the ':'
    while (i < request.len and std.ascii.isWhitespace(request[i])) : (i += 1) {}
    if (i >= request.len or request[i] != ':') return .{ .err = .invalid_request };
    i += 1; // past ':'

    // Skip whitespace to the opening quote of the method string
    while (i < request.len and std.ascii.isWhitespace(request[i])) : (i += 1) {}
    if (i >= request.len or request[i] != '"') return .{ .err = .invalid_request };

    const start = i + 1;
    var end = start;
    while (end < request.len) : (end += 1) {
        if (request[end] == '"' and end > start and request[end - 1] != '\\') break;
    }
    if (end >= request.len or request[end] != '"') return .{ .err = .invalid_request };

    const method_name = request[start..end];
    if (resolveNamespace(method_name)) |tag| {
        return .{ .namespace = tag };
    } else {
        return .{ .err = .method_not_found };
    }
}

test "parseRequestNamespace returns namespace tag for known eth method" {
    const req =
        "{\n" ++
        "  \"jsonrpc\": \"2.0\",\n" ++
        "  \"id\": 1,\n" ++
        "  \"method\": \"eth_blockNumber\",\n" ++
        "  \"params\": []\n" ++
        "}";

    const res = parseRequestNamespace(req);
    switch (res) {
        .namespace => |tag| {
            try std.testing.expectEqual(std.meta.Tag(jsonrpc.JsonRpcMethod).eth, tag);
        },
        .err => |_| return error.UnexpectedError,
    }
}

test "parseRequestNamespace returns method_not_found for unknown method" {
    const req =
        "{\n" ++
        "  \"jsonrpc\": \"2.0\",\n" ++
        "  \"id\": 1,\n" ++
        "  \"method\": \"foo_bar\",\n" ++
        "  \"params\": []\n" ++
        "}";

    const res = parseRequestNamespace(req);
    switch (res) {
        .namespace => |_| return error.UnexpectedSuccess,
        .err => |code| try std.testing.expectEqual(primitives.JsonRpcErrorCode.method_not_found, code),
    }
}

test "parseRequestNamespace returns invalid_request when method missing" {
    const req =
        "{\n" ++
        "  \"jsonrpc\": \"2.0\",\n" ++
        "  \"id\": 1,\n" ++
        "  \"params\": []\n" ++
        "}";

    const res = parseRequestNamespace(req);
    switch (res) {
        .namespace => |_| return error.UnexpectedSuccess,
        .err => |code| try std.testing.expectEqual(primitives.JsonRpcErrorCode.invalid_request, code),
    }
}
