//! JSON-RPC envelope helpers (ID extraction, zero-copy).
//!
//! Small, allocation-free utilities for working with the JSON-RPC 2.0
//! envelope. Mirrors Nethermind's lightweight handling of request `Id`,
//! but implemented as a fast top-level scanner to avoid materializing
//! full `std.json.Value` trees.
const std = @import("std");
const errors = @import("error.zig");
const scan = @import("scan.zig");

/// Zero-copy representation of a JSON-RPC request id.
/// - `.string` returns the raw, unescaped string contents (between quotes).
/// - `.number` returns the raw decimal token (no quotes, may include leading `-`).
/// - `.null` when the request carries `id: null` or the id field is absent.
pub const Id = union(enum) {
    string: []const u8,
    number: []const u8,
    null,
};

/// Result of ID extraction: either an `Id` or an EIP-1474 error code.
pub const ExtractIdResult = union(enum) {
    id: Id,
    err: errors.JsonRpcErrorCode,
};

/// Extract the top-level `id` field from a JSON-RPC request without allocations.
///
/// Rules (JSON-RPC 2.0 + EIP-1474):
/// - Batch (top-level array) is not handled here → `.err = .invalid_request`.
/// - Missing `id` yields `.id = .null` (error responses must carry `null`).
/// - `id` must be string, number (integer), or null → otherwise `.err = .invalid_request`.
/// Extract the JSON-RPC request id as a zero-copy token.
pub fn extract_request_id(input: []const u8) ExtractIdResult {
    // Skip UTF-8 BOM
    var i: usize = 0;
    if (input.len >= 3 and input[0] == 0xEF and input[1] == 0xBB and input[2] == 0xBF) i = 3;
    // Skip leading whitespace
    while (i < input.len and std.ascii.isWhitespace(input[i])) : (i += 1) {}
    if (i >= input.len) return .{ .err = .parse_error };

    const first = input[i];
    if (first == '[') return .{ .err = .invalid_request }; // batch not handled here
    if (first != '{') return .{ .err = .invalid_request };

    const key = "\"id\"";
    const key_idx = scan.find_top_level_key(input[i..], key);
    if (key_idx == null) return .{ .id = .null }; // id not present → treat as null

    // Move to ':' after the key
    var j: usize = i + key_idx.? + key.len;
    while (j < input.len and std.ascii.isWhitespace(input[j])) : (j += 1) {}
    if (j >= input.len or input[j] != ':') return .{ .err = .invalid_request };
    j += 1; // past ':'

    // Skip whitespace to the value
    while (j < input.len and std.ascii.isWhitespace(input[j])) : (j += 1) {}
    if (j >= input.len) return .{ .err = .parse_error };

    const v0 = input[j];
    // String id
    if (v0 == '"') {
        var end = j + 1;
        var esc = false;
        while (end < input.len) : (end += 1) {
            const ch = input[end];
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
        if (end >= input.len or input[end] != '"') return .{ .err = .parse_error };
        // Return string contents without quotes (raw, possibly with escapes)
        return .{ .id = .{ .string = input[(j + 1)..end] } };
    }

    // Null id
    if (v0 == 'n') {
        const rem = input[j..];
        if (rem.len >= 4 and std.mem.eql(u8, rem[0..4], "null")) {
            return .{ .id = .null };
        } else {
            return .{ .err = .invalid_request };
        }
    }

    // Numeric id (integer token). Accept optional leading '-'.
    if (v0 == '-' or std.ascii.isDigit(v0)) {
        var k = j;
        if (input[k] == '-') k += 1;
        const start = k;
        while (k < input.len and std.ascii.isDigit(input[k])) : (k += 1) {}
        if (k == start) return .{ .err = .invalid_request }; // '-' not followed by digits
        // Ensure the token ends at a valid delimiter for JSON (ws, ',', '}')
        if (k < input.len) {
            const term = input[k];
            if (!(std.ascii.isWhitespace(term) or term == ',' or term == '}')) {
                return .{ .err = .invalid_request };
            }
        }
        return .{ .id = .{ .number = input[j..k] } };
    }

    // Any other type (true/false/object/array/float) is invalid for id.
    return .{ .err = .invalid_request };
}

// ============================================================================
// Tests
// ============================================================================

test "extractRequestId: numeric id" {
    const req =
        "{\n" ++
        "  \"jsonrpc\": \"2.0\",\n" ++
        "  \"id\": 42,\n" ++
        "  \"method\": \"eth_blockNumber\",\n" ++
        "  \"params\": []\n" ++
        "}";
    const r = extract_request_id(req);
    switch (r) {
        .id => |id| switch (id) {
            .number => |tok| try std.testing.expectEqualStrings("42", tok),
            else => return error.UnexpectedVariant,
        },
        .err => |_| return error.UnexpectedError,
    }
}

test "extractRequestId: string id" {
    const req =
        "{\n" ++
        "  \"jsonrpc\": \"2.0\",\n" ++
        "  \"id\": \"abc-123\",\n" ++
        "  \"method\": \"eth_blockNumber\",\n" ++
        "  \"params\": []\n" ++
        "}";
    const r = extract_request_id(req);
    switch (r) {
        .id => |id| switch (id) {
            .string => |s| try std.testing.expectEqualStrings("abc-123", s),
            else => return error.UnexpectedVariant,
        },
        .err => |_| return error.UnexpectedError,
    }
}

test "extractRequestId: null id" {
    const req =
        "{\n" ++
        "  \"jsonrpc\": \"2.0\",\n" ++
        "  \"id\": null,\n" ++
        "  \"method\": \"eth_blockNumber\",\n" ++
        "  \"params\": []\n" ++
        "}";
    const r = extract_request_id(req);
    switch (r) {
        .id => |id| try std.testing.expect(id == .null),
        .err => |_| return error.UnexpectedError,
    }
}

test "extractRequestId: missing id -> null" {
    const req =
        "{\n" ++
        "  \"jsonrpc\": \"2.0\",\n" ++
        "  \"method\": \"eth_blockNumber\",\n" ++
        "  \"params\": []\n" ++
        "}";
    const r = extract_request_id(req);
    switch (r) {
        .id => |id| try std.testing.expect(id == .null),
        .err => |_| return error.UnexpectedError,
    }
}

test "extractRequestId: batch input invalid_request" {
    const req = "[ { \"jsonrpc\": \"2.0\", \"id\": 1, \"method\": \"eth_blockNumber\", \"params\": [] } ]";
    const r = extract_request_id(req);
    switch (r) {
        .id => |_| return error.UnexpectedSuccess,
        .err => |code| try std.testing.expectEqual(errors.JsonRpcErrorCode.invalid_request, code),
    }
}

test "extractRequestId: invalid id type (object) -> invalid_request" {
    const req =
        "{\n" ++
        "  \"jsonrpc\": \"2.0\",\n" ++
        "  \"id\": {\"x\":1},\n" ++
        "  \"method\": \"eth_blockNumber\",\n" ++
        "  \"params\": []\n" ++
        "}";
    const r = extract_request_id(req);
    switch (r) {
        .id => |_| return error.UnexpectedSuccess,
        .err => |code| try std.testing.expectEqual(errors.JsonRpcErrorCode.invalid_request, code),
    }
}
