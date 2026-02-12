//! Lightweight JSON scanner utilities for top-level key detection.
//!
//! Shared by envelope and dispatch to avoid code duplication. These
//! functions are allocation-free and operate on raw bytes.
const std = @import("std");

/// Return the index at which the given JSON object key (including quotes)
/// appears as a direct child of the top-level object. Returns null if the
/// key is not found at the top level. The index points to the opening '"'.
pub inline fn find_top_level_key(input: []const u8, key: []const u8) ?usize {
    var depth: u32 = 0;
    var in_string = false;
    var escaped = false;
    var expecting_key = false;
    var i: usize = 0;
    while (i < input.len) : (i += 1) {
        const c = input[i];
        if (in_string) {
            if (escaped) {
                escaped = false;
                continue;
            }
            if (c == '\\') {
                escaped = true;
                continue;
            }
            if (c == '"') in_string = false;
            continue;
        }
        switch (c) {
            '"' => {
                if (depth == 1 and expecting_key) {
                    const rem = input[i..];
                    if (rem.len >= key.len and std.mem.eql(u8, rem[0..key.len], key)) {
                        return i;
                    }
                }
                in_string = true;
            },
            '{' => {
                depth += 1;
                if (depth == 1) expecting_key = true;
            },
            '}' => {
                if (depth == 0) return null;
                depth -= 1;
                if (depth == 1) expecting_key = false;
            },
            '[' => depth += 1,
            ']' => {
                if (depth == 0) return null;
                depth -= 1;
            },
            ':' => {
                if (depth == 1) expecting_key = false;
            },
            ',' => {
                if (depth == 1) expecting_key = true;
            },
            else => {},
        }
    }
    return null;
}

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------

test "find_top_level_key finds method at top-level only" {
    const json =
        "{\n" ++
        "  \"jsonrpc\": \"2.0\",\n" ++
        "  \"params\": { \"method\": \"nested\" },\n" ++
        "  \"method\": \"eth_blockNumber\"\n" ++
        "}";
    try std.testing.expect(find_top_level_key(json, "\"method\"") != null);
}

test "find_top_level_key ignores nested keys" {
    const json =
        "{\n" ++
        "  \"jsonrpc\": \"2.0\",\n" ++
        "  \"obj\": { \"id\": 1 }\n" ++
        "}";
    try std.testing.expect(find_top_level_key(json, "\"id\"") == null);
}
