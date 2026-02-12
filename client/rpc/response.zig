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
    pub fn write_success_raw(writer: anytype, id: envelope.Id, result_raw: []const u8) !void {
        try writer.writeAll("{\"jsonrpc\":\"2.0\",\"id\":");
        try write_id(writer, id);
        try writer.writeAll(",\"result\":");
        try writer.writeAll(result_raw);
        try writer.writeAll("}");
    }

    /// Serialize an error response following JSON-RPC 2.0 and EIP-1474.
    ///
    /// - `code` must be a `JsonRpcErrorCode`.
    /// - `message` is a human-readable string; it is JSON-escaped here.
    /// - `data_raw`, when provided, must be a valid JSON fragment.
    pub fn write_error(writer: anytype, id: envelope.Id, code: errors.JsonRpcErrorCode, message: []const u8, data_raw: ?[]const u8) !void {
        try writer.writeAll("{\"jsonrpc\":\"2.0\",\"id\":");
        try write_id(writer, id);
        try writer.writeAll(",\"error\":{\"code\":");
        try std.fmt.format(writer, "{}", .{@as(i32, @intFromEnum(code))});
        try writer.writeAll(",\"message\":");
        try write_json_string(writer, message);
        if (data_raw) |d| {
            try writer.writeAll(",\"data\":");
            try writer.writeAll(d);
        }
        try writer.writeAll("}}");
    }

    /// Write a JSON QUANTITY (EIP-1474) from a u64 as a JSON string.
    /// Lowercase hex, 0x-prefixed, no leading zeros (zero => "0x0").
    pub fn write_quantity_u64(writer: anytype, value: u64) !void {
        try writer.writeByte('"');
        try writer.writeAll("0x");
        if (value == 0) {
            try writer.writeByte('0');
            try writer.writeByte('"');
            return;
        }

        var buf: [16]u8 = undefined; // max hex digits for u64
        var i: usize = buf.len;
        var v = value;
        const hex = "0123456789abcdef";
        while (v != 0) : (v >>= 4) {
            i -= 1;
            buf[i] = hex[@intCast(v & 0xF)];
        }
        try writer.writeAll(buf[i..]);
        try writer.writeByte('"');
    }

    /// Convenience: full success envelope with QUANTITY(u64) result.
    pub fn write_success_quantity_u64(writer: anytype, id: envelope.Id, value: u64) !void {
        try writer.writeAll("{\"jsonrpc\":\"2.0\",\"id\":");
        try write_id(writer, id);
        try writer.writeAll(",\"result\":");
        try write_quantity_u64(writer, value);
        try writer.writeAll("}");
    }

    // ---------------------------------------------------------------------
    // Internals
    // ---------------------------------------------------------------------

    fn write_id(writer: anytype, id: envelope.Id) !void {
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

    fn write_json_string(writer: anytype, s: []const u8) !void {
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
    var buf = std.array_list.Managed(u8).init(std.testing.allocator);
    defer buf.deinit();
    try Response.write_success_raw(buf.writer(), .{ .string = "abc-123" }, "1");
    try std.testing.expectEqualStrings(
        "{\"jsonrpc\":\"2.0\",\"id\":\"abc-123\",\"result\":1}",
        buf.items,
    );
}

test "Response.writeSuccessRaw: id number" {
    var buf = std.array_list.Managed(u8).init(std.testing.allocator);
    defer buf.deinit();
    try Response.write_success_raw(buf.writer(), .{ .number = "42" }, "\"0x1\"");
    try std.testing.expectEqualStrings(
        "{\"jsonrpc\":\"2.0\",\"id\":42,\"result\":\"0x1\"}",
        buf.items,
    );
}

test "Response.writeSuccessRaw: id null" {
    var buf = std.array_list.Managed(u8).init(std.testing.allocator);
    defer buf.deinit();
    try Response.write_success_raw(buf.writer(), .null, "null");
    try std.testing.expectEqualStrings(
        "{\"jsonrpc\":\"2.0\",\"id\":null,\"result\":null}",
        buf.items,
    );
}

test "Response.writeError: basic (string id)" {
    var buf = std.array_list.Managed(u8).init(std.testing.allocator);
    defer buf.deinit();
    const code = errors.JsonRpcErrorCode.invalid_request;
    try Response.write_error(buf.writer(), .{ .string = "x" }, code, code.default_message(), null);
    try std.testing.expectEqualStrings(
        "{\"jsonrpc\":\"2.0\",\"id\":\"x\",\"error\":{\"code\":-32600,\"message\":\"Invalid request\"}}",
        buf.items,
    );
}

test "Response.writeError: with data (number id)" {
    var buf = std.array_list.Managed(u8).init(std.testing.allocator);
    defer buf.deinit();
    const code = errors.JsonRpcErrorCode.method_not_found;
    try Response.write_error(buf.writer(), .{ .number = "7" }, code, code.default_message(), "{\"foo\":1}");
    try std.testing.expectEqualStrings(
        "{\"jsonrpc\":\"2.0\",\"id\":7,\"error\":{\"code\":-32601,\"message\":\"Method not found\",\"data\":{\"foo\":1}}}",
        buf.items,
    );
}

test "Response.writeQuantityU64: encodes per EIP-1474" {
    var buf = std.array_list.Managed(u8).init(std.testing.allocator);
    defer buf.deinit();
    try Response.write_quantity_u64(buf.writer(), 0);
    try std.testing.expectEqualStrings("\"0x0\"", buf.items);

    buf.clearRetainingCapacity();
    try Response.write_quantity_u64(buf.writer(), 1);
    try std.testing.expectEqualStrings("\"0x1\"", buf.items);

    buf.clearRetainingCapacity();
    try Response.write_quantity_u64(buf.writer(), std.math.maxInt(u64));
    try std.testing.expectEqualStrings("\"0xffffffffffffffff\"", buf.items);
}

test "Response.writeSuccessQuantityU64: full envelope" {
    var buf = std.array_list.Managed(u8).init(std.testing.allocator);
    defer buf.deinit();
    try Response.write_success_quantity_u64(buf.writer(), .{ .number = "7" }, 26);
    try std.testing.expectEqualStrings(
        "{\"jsonrpc\":\"2.0\",\"id\":7,\"result\":\"0x1a\"}",
        buf.items,
    );
}
