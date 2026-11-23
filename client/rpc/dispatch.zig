//! Lightweight JSON-RPC method resolver using Voltaire enums.
//!
//! Purpose: map a JSON-RPC `method` string to its namespace
//! (engine/eth/debug/trace) without allocating or constructing full request
//! payloads. Mirrors the initial routing step in Nethermind's JsonRpcProcessor.

const std = @import("std");
const jsonrpc = @import("jsonrpc");
const errors = @import("error.zig");
const scan = @import("scan.zig");

/// Root namespace of a JSON-RPC method.
pub const RpcNamespace = enum {
    engine,
    eth,
    debug,
    /// Parity/OpenEthereum `trace_*`; Voltaire has no enum for it.
    trace,

    /// The matching Voltaire `JsonRpcMethod` tag; null for `.trace`.
    pub fn toJsonRpcTag(self: RpcNamespace) ?std.meta.Tag(jsonrpc.JsonRpcMethod) {
        return switch (self) {
            .engine => .engine,
            .eth => .eth,
            .debug => .debug,
            .trace => null,
        };
    }
};

/// Methods served locally that Voltaire's method unions do not (yet) list.
/// Upstream `EngineMethod` omits engine_getClientVersionV1 and `DebugMethod`
/// has no tracing methods.
const local_methods = std.StaticStringMap(RpcNamespace).initComptime(.{
    .{ "engine_getClientVersionV1", .engine },
    .{ "eth_call", .eth },
    .{ "eth_estimateGas", .eth },
    .{ "eth_createAccessList", .eth },
    .{ "eth_simulateV1", .eth },
    .{ "debug_traceCall", .debug },
    .{ "debug_traceTransaction", .debug },
    .{ "debug_traceBlockByNumber", .debug },
    .{ "debug_traceBlockByHash", .debug },
    .{ "trace_call", .trace },
    .{ "trace_callMany", .trace },
    .{ "trace_rawTransaction", .trace },
    .{ "trace_replayTransaction", .trace },
    .{ "trace_replayBlockTransactions", .trace },
    .{ "trace_transaction", .trace },
    .{ "trace_get", .trace },
    .{ "trace_block", .trace },
    .{ "trace_filter", .trace },
});

/// Returns the root namespace of a JSON-RPC method name, or null if no
/// namespace knows it.
///
/// Every Voltaire method name carries its namespace prefix, so the prefix
/// alone picks the one enum worth probing. (The resolver used to probe all
/// three enums again after a prefix miss; that fallback could never match.)
pub fn resolve_namespace(method_name: []const u8) ?RpcNamespace {
    if (local_methods.get(method_name)) |ns| return ns;
    if (std.mem.startsWith(u8, method_name, "eth_")) {
        _ = jsonrpc.eth.EthMethod.fromMethodName(method_name) catch return null;
        return .eth;
    }
    if (std.mem.startsWith(u8, method_name, "engine_")) {
        _ = jsonrpc.engine.EngineMethod.fromMethodName(method_name) catch return null;
        return .engine;
    }
    if (std.mem.startsWith(u8, method_name, "debug_")) {
        _ = jsonrpc.debug.DebugMethod.fromMethodName(method_name) catch return null;
        return .debug;
    }
    return null;
}

test "resolveNamespace returns .eth for eth_*" {
    const tag = resolve_namespace("eth_blockNumber");
    try std.testing.expect(tag != null);
    try std.testing.expectEqual(RpcNamespace.eth, tag.?);
}

test "resolveNamespace returns .engine for engine_*" {
    const tag = resolve_namespace("engine_getPayloadV3");
    try std.testing.expect(tag != null);
    try std.testing.expectEqual(RpcNamespace.engine, tag.?);
}

test "resolveNamespace treats engine_getClientVersionV1 as engine" {
    const tag = resolve_namespace("engine_getClientVersionV1");
    try std.testing.expect(tag != null);
    try std.testing.expectEqual(RpcNamespace.engine, tag.?);
}

test "resolveNamespace returns null for unknown" {
    try std.testing.expect(resolve_namespace("unknown_method") == null);
}

/// Minimal JSON-RPC request parser that extracts the `method` string and
/// resolves it to a root namespace tag. Returns an EIP-1474 error code for
/// unknown methods without allocating or fully parsing the JSON.
pub const ParseNamespaceResult = union(enum) {
    namespace: RpcNamespace,
    err: errors.JsonRpcErrorCode,
};

/// Extracts the `method` field from a JSON-RPC request and returns its
/// resolved namespace tag. If the method is unknown, returns
/// `.error(.method_not_found)`. If the field is missing or malformed,
/// returns `.error(.invalid_request)` per EIP-1474.
pub fn parse_request_namespace(request: []const u8) ParseNamespaceResult {
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
    const idx_opt = scan.find_top_level_key(request[i_top..], key);
    if (idx_opt == null) return .{ .err = .invalid_request };

    var i: usize = i_top + idx_opt.? + key.len;
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
    if (resolve_namespace(method_name)) |tag| {
        return .{ .namespace = tag };
    } else {
        return .{ .err = .method_not_found };
    }
}

// ============================================================================
// Additional tests for debug_* mapping and batch input handling
// ============================================================================

test "resolveNamespace returns .debug for debug_*" {
    const tag = resolve_namespace("debug_getRawBlock");
    try std.testing.expect(tag != null);
    try std.testing.expectEqual(RpcNamespace.debug, tag.?);
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

    const res = parse_request_namespace(req);
    switch (res) {
        .namespace => |_| return error.UnexpectedSuccess,
        .err => |code| try std.testing.expectEqual(errors.JsonRpcErrorCode.invalid_request, code),
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

    const res = parse_request_namespace(req);
    switch (res) {
        .namespace => |tag| {
            try std.testing.expectEqual(RpcNamespace.eth, tag);
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

    const res = parse_request_namespace(req);
    switch (res) {
        .namespace => |_| return error.UnexpectedSuccess,
        .err => |code| try std.testing.expectEqual(errors.JsonRpcErrorCode.method_not_found, code),
    }
}

test "parseRequestNamespace returns invalid_request when method missing" {
    const req =
        "{\n" ++
        "  \"jsonrpc\": \"2.0\",\n" ++
        "  \"id\": 1,\n" ++
        "  \"params\": []\n" ++
        "}";

    const res = parse_request_namespace(req);
    switch (res) {
        .namespace => |_| return error.UnexpectedSuccess,
        .err => |code| try std.testing.expectEqual(errors.JsonRpcErrorCode.invalid_request, code),
    }
}

// ============================================================================
// Simulation and tracing methods
// ============================================================================

test "resolveNamespace routes simulation methods to eth" {
    for ([_][]const u8{ "eth_call", "eth_estimateGas", "eth_createAccessList", "eth_simulateV1" }) |m| {
        try std.testing.expectEqual(@as(?RpcNamespace, .eth), resolve_namespace(m));
    }
}

test "resolveNamespace routes debug tracing methods to debug" {
    // Voltaire's DebugMethod has neither; these used to resolve to null.
    try std.testing.expectEqual(@as(?RpcNamespace, .debug), resolve_namespace("debug_traceCall"));
    try std.testing.expectEqual(@as(?RpcNamespace, .debug), resolve_namespace("debug_traceTransaction"));
}

test "resolveNamespace routes Parity trace methods to trace" {
    for ([_][]const u8{ "trace_call", "trace_transaction", "trace_block", "trace_filter" }) |m| {
        try std.testing.expectEqual(@as(?RpcNamespace, .trace), resolve_namespace(m));
    }
    try std.testing.expect(resolve_namespace("trace_bogus") == null);
    try std.testing.expect(RpcNamespace.trace.toJsonRpcTag() == null);
    try std.testing.expectEqual(std.meta.Tag(jsonrpc.JsonRpcMethod).eth, RpcNamespace.eth.toJsonRpcTag().?);
}

test "resolveNamespace: unknown name under a known prefix is null" {
    try std.testing.expect(resolve_namespace("eth_bogus") == null);
    try std.testing.expect(resolve_namespace("debug_bogus") == null);
    try std.testing.expect(resolve_namespace("engine_bogus") == null);
    try std.testing.expect(resolve_namespace("") == null);
}

test "parseRequestNamespace routes debug_traceCall, trace_call, eth_simulateV1, eth_createAccessList" {
    const cases = .{
        .{ "debug_traceCall", RpcNamespace.debug },
        .{ "trace_call", RpcNamespace.trace },
        .{ "eth_simulateV1", RpcNamespace.eth },
        .{ "eth_createAccessList", RpcNamespace.eth },
    };
    inline for (cases) |case| {
        const req = "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"" ++ case[0] ++ "\",\"params\":[]}";
        switch (parse_request_namespace(req)) {
            .namespace => |ns| try std.testing.expectEqual(case[1], ns),
            .err => return error.UnexpectedError,
        }
    }
}
