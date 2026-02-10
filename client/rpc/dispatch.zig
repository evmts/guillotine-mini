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
        if (jsonrpc.eth.EthMethod.fromMethodName(method_name)) |tag| {
            _ = tag;
            return .eth;
        } else |err| switch (err) {
            error.UnknownMethod => return null,
            else => return null,
        }
    }
    if (std.mem.startsWith(u8, method_name, "engine_")) {
        if (jsonrpc.engine.EngineMethod.fromMethodName(method_name)) |tag| {
            _ = tag;
            return .engine;
        } else |err| switch (err) {
            error.UnknownMethod => return null,
            else => return null,
        }
    }
    if (std.mem.startsWith(u8, method_name, "debug_")) {
        if (jsonrpc.debug.DebugMethod.fromMethodName(method_name)) |tag| {
            _ = tag;
            return .debug;
        } else |err| switch (err) {
            error.UnknownMethod => return null,
            else => return null,
        }
    }

    // Try Engine namespace
    if (jsonrpc.engine.EngineMethod.fromMethodName(method_name)) |tag| {
        _ = tag; // tag not used beyond confirming success
        return .engine;
    } else |err| switch (err) {
        error.UnknownMethod => {}, // continue probing other namespaces
        else => return null, // defensive: unexpected error -> no match
    }

    // Try Eth namespace
    if (jsonrpc.eth.EthMethod.fromMethodName(method_name)) |tag| {
        _ = tag;
        return .eth;
    } else |err| switch (err) {
        error.UnknownMethod => {},
        else => return null,
    }

    // Try Debug namespace
    if (jsonrpc.debug.DebugMethod.fromMethodName(method_name)) |tag| {
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
    // Top-level JSON type validation and batch guard
    var i_top: usize = 0;
    // Skip UTF-8 BOM if present
    if (request.len >= 3 and request[0] == 0xEF and request[1] == 0xBB and request[2] == 0xBF) {
        i_top = 3;
    }
    // Skip leading whitespace
    while (i_top < request.len and std.ascii.isWhitespace(request[i_top])) : (i_top += 1) {}
    if (i_top >= request.len) return .{ .err = .parse_error };
    const first = request[i_top];
    if (first == '[') {
        // Batch request arrays are handled by upper layers; treat as invalid_request here.
        return .{ .err = .invalid_request };
    }
    if (first != '{') {
        // Valid JSON but not a Request object -> invalid_request (EIP-1474)
        return .{ .err = .invalid_request };
    }

    const key = "\"method\"";
    // Depth-aware, key-context search for top-level key named "method".
    var depth: u32 = 0;
    var in_string = false;
    var escaped = false;
    var expecting_key = false; // only true inside the top-level object when next token is a key
    var idx_opt: ?usize = null;
    var i_scan: usize = i_top; // start from first non-ws char
    while (i_scan < request.len) : (i_scan += 1) {
        const c = request[i_scan];
        if (in_string) {
            if (escaped) {
                escaped = false;
                continue;
            }
            if (c == '\\') {
                escaped = true;
                continue;
            }
            if (c == '"') in_string = false; // end string
            continue;
        }
        switch (c) {
            '"' => {
                // Only treat as a potential key when at top-level object and expecting a key
                if (depth == 1 and expecting_key) {
                    const rem = request[i_scan..];
                    if (rem.len >= key.len and std.mem.eql(u8, rem[0..key.len], key)) {
                        idx_opt = i_scan;
                        break;
                    }
                }
                in_string = true;
            },
            '{' => {
                depth += 1;
                if (depth == 1) expecting_key = true; // entering top-level object
            },
            '}' => {
                if (depth == 0) break else depth -= 1;
                if (depth == 1) expecting_key = false; // leaving inner object
            },
            '[' => depth += 1,
            ']' => if (depth == 0) break else depth -= 1,
            58 => { if (depth == 1) expecting_key = false; },
            44 => { if (depth == 1) expecting_key = true; },
            else => {},
        }
    }
    if (idx_opt == null) return .{ .err = .invalid_request };

    var i: usize = idx_opt.? + key.len;
    // Skip whitespace to the ':'
    while (i < request.len and std.ascii.isWhitespace(request[i])) : (i += 1) {}
    if (i >= request.len or request[i] != ':') return .{ .err = .invalid_request };
    i += 1; // past ':'

    // Skip whitespace to the opening quote of the method string
    while (i < request.len and std.ascii.isWhitespace(request[i])) : (i += 1) {}
    if (i >= request.len or request[i] != '"') return .{ .err = .invalid_request };

    // Extract string value with proper escape handling
    var end = i + 1;
    var esc = false;
    while (end < request.len) : (end += 1) {
        const ch = request[end];
        if (esc) {
            esc = false;
            continue;
        }
        if (ch == '\\') {
            esc = true;
            continue;
        }
        if (ch == '"') break;
    }
    if (end >= request.len or request[end] != '"') return .{ .err = .parse_error };
    const start = i + 1;

    const method_name = request[start..end];
    if (resolveNamespace(method_name)) |tag| {
        return .{ .namespace = tag };
    } else {
        return .{ .err = .method_not_found };
    }
}

// ============================================================================
// Additional tests for debug_* mapping and batch input handling
// ============================================================================

test "resolveNamespace returns .debug for debug_*" {
    const tag = resolveNamespace("debug_getRawBlock");
    try std.testing.expect(tag != null);
    try std.testing.expectEqual(std.meta.Tag(jsonrpc.JsonRpcMethod).debug, tag.?);
}

test "parseRequestNamespace returns invalid_request for batch array input" {
    const req =
        "[\n" ++
        "  {\n" ++
        "    \"jsonrpc\": \"2.0\",\n" ++
        "    \"id\": 1,\n" ++
        "    \"method\": \"eth_blockNumber\",\n" ++
        "    \"params\": []\n" ++
        "  }\n" ++
        "]";

    const res = parseRequestNamespace(req);
    switch (res) {
        .namespace => |_| return error.UnexpectedSuccess,
        .err => |code| try std.testing.expectEqual(primitives.JsonRpcErrorCode.invalid_request, code),
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
