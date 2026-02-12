//! JSON-RPC response builder (allocation-free serializers).
//!
//! Minimal helpers to serialize JSON-RPC 2.0 success/error envelopes without
//! allocating, using the zero-copy `Envelope.Id` extracted from requests.
//! The functions write directly to an `anytype` writer.
const std = @import("std");
const envelope = @import("envelope.zig");
const errors = @import("error.zig");

/// Response helpers namespace.
pub const Response = struct {
    /// Serialize a success response with a pre-encoded `result`.
    ///
    /// The `result_raw` must be a valid JSON fragment (already encoded).
    pub fn writeSuccessRaw(writer: anytype, id: envelope.Id, result_raw: []const u8) !void {
        try writer.writeAll("{\"jsonrpc\":\"2.0\",\"id\":");
        try writeId(writer, id);
        try writer.writeAll(",\"result\":");
        try writer.writeAll(result_raw);
        try writer.writeAll("}");
    }

    /// Serialize an error response following JSON-RPC 2.0 and EIP-1474.
    ///
    /// - `code` must be a `JsonRpcErrorCode`.
    /// - `message` is a human-readable string; it is JSON-escaped here.
    /// - `data_raw`, when provided, must be a valid JSON fragment.
    pub fn writeError(writer: anytype, id: envelope.Id, code: errors.JsonRpcErrorCode, message: []const u8, data_raw: ?[]const u8) !void {
        try writer.writeAll("{\"jsonrpc\":\"2.0\",\"id\":");
        try writeId(writer, id);
        try writer.writeAll(",\"error\":{\"code\":");
        try std.fmt.format(writer, "{}", .{@as(i32, @intFromEnum(code))});
        try writer.writeAll(",\"message\":");
        try writeJsonString(writer, message);
        if (data_raw) |d| {
            try writer.writeAll(",\"data\":");
            try writer.writeAll(d);
        }
        try writer.writeAll("}}");
    }

    // ---------------------------------------------------------------------
    // Internals
    // ---------------------------------------------------------------------

    fn writeId(writer: anytype, id: envelope.Id) !void {
        switch (id) {
            .null => try writer.writeAll("null"),
            .number => |tok| try writer.writeAll(tok),
            .string => |raw_between_quotes| {
                // The extracted string is the raw contents between quotes (with any
                // backslash escapes preserved). Re-wrap with quotes to reproduce the
                // original value without decoding/allocating.
                try writer.writeAll("\"");
                try writer.writeAll(raw_between_quotes);
                try writer.writeAll("\"");
            },
        }
    }

    fn writeJsonString(writer: anytype, s: []const u8) !void {
        try writer.writeAll("\"");
        var i: usize = 0;
        while (i < s.len) : (i += 1) {
            const c = s[i];
            switch (c) {
                '"' => try writer.writeAll("\\\""),
                '\\' => try writer.writeAll("\\\\"),
                '\n' => try writer.writeAll("\\n"),
                '\r' => try writer.writeAll("\\r"),
                '\t' => try writer.writeAll("\\t"),
                0x08 => try writer.writeAll("\\b"),
                0x0C => try writer.writeAll("\\f"),
                else => if (c < 0x20) {
                    // Control chars -> \u00XX
                    var buf: [6]u8 = .{ '\\', 'u', '0', '0', 0, 0 };
                    const hex = "0123456789abcdef";
                    buf[4] = hex[(c >> 4) & 0xF];
                    buf[5] = hex[c & 0xF];
                    try writer.writeAll(&buf);
                } else {
                    try writer.writeByte(c);
                },
            }
        }
        try writer.writeAll("\"");
    }
};

// ============================================================================
// Tests
// ============================================================================

test "Response.writeSuccessRaw: id string" {
    var buf = std.ArrayList(u8){};
    defer buf.deinit(std.testing.allocator);
    try Response.writeSuccessRaw(buf.writer(std.testing.allocator), .{ .string = "abc-123" }, "1");
    try std.testing.expectEqualStrings(
        "{\"jsonrpc\":\"2.0\",\"id\":\"abc-123\",\"result\":1}",
        buf.items,
    );
}

test "Response.writeSuccessRaw: id number" {
    var buf = std.ArrayList(u8){};
    defer buf.deinit(std.testing.allocator);
    try Response.writeSuccessRaw(buf.writer(std.testing.allocator), .{ .number = "42" }, "\"0x1\"");
    try std.testing.expectEqualStrings(
        "{\"jsonrpc\":\"2.0\",\"id\":42,\"result\":\"0x1\"}",
        buf.items,
    );
}

test "Response.writeSuccessRaw: id null" {
    var buf = std.ArrayList(u8){};
    defer buf.deinit(std.testing.allocator);
    try Response.writeSuccessRaw(buf.writer(std.testing.allocator), .null, "null");
    try std.testing.expectEqualStrings(
        "{\"jsonrpc\":\"2.0\",\"id\":null,\"result\":null}",
        buf.items,
    );
}

test "Response.writeError: basic (string id)" {
    var buf = std.ArrayList(u8){};
    defer buf.deinit(std.testing.allocator);
    const code = errors.JsonRpcErrorCode.invalid_request;
    try Response.writeError(buf.writer(std.testing.allocator), .{ .string = "x" }, code, code.defaultMessage(), null);
    try std.testing.expectEqualStrings(
        "{\"jsonrpc\":\"2.0\",\"id\":\"x\",\"error\":{\"code\":-32600,\"message\":\"Invalid request\"}}",
        buf.items,
    );
}

test "Response.writeError: with data (number id)" {
    var buf = std.ArrayList(u8){};
    defer buf.deinit(std.testing.allocator);
    const code = errors.JsonRpcErrorCode.method_not_found;
    try Response.writeError(buf.writer(std.testing.allocator), .{ .number = "7" }, code, code.defaultMessage(), "{\"foo\":1}");
    try std.testing.expectEqualStrings(
        "{\"jsonrpc\":\"2.0\",\"id\":7,\"error\":{\"code\":-32601,\"message\":\"Method not found\",\"data\":{\"foo\":1}}}",
        buf.items,
    );
}
