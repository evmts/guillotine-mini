/// JSON-RPC request/response builders for Ethereum RPC methods
/// This module provides functions to build JSON params arrays and parse responses
/// Users provide their own RPC transport (HTTP, WebSocket, etc.)
const std = @import("std");
const primitives = @import("primitives");
const Address = primitives.Address.Address;

/// Block tag for RPC requests
pub const BlockTag = union(enum) {
    latest,
    earliest,
    pending,
    number: u64,
    hash: [32]u8,

    /// Convert block tag to JSON string
    pub fn toJson(self: BlockTag, allocator: std.mem.Allocator) ![]const u8 {
        return switch (self) {
            .latest => try allocator.dupe(u8, "\"latest\""),
            .earliest => try allocator.dupe(u8, "\"earliest\""),
            .pending => try allocator.dupe(u8, "\"pending\""),
            .number => |n| try std.fmt.allocPrint(allocator, "\"0x{x}\"", .{n}),
            .hash => |h| blk: {
                var buf: [66]u8 = undefined; // "0x" + 64 hex chars
                buf[0] = '0';
                buf[1] = 'x';
                const hex_digits = "0123456789abcdef";
                for (h, 0..) |byte, i| {
                    buf[2 + i * 2] = hex_digits[byte >> 4];
                    buf[2 + i * 2 + 1] = hex_digits[byte & 0x0F];
                }
                break :blk try std.fmt.allocPrint(allocator, "\"{s}\"", .{buf});
            },
        };
    }
};

/// Build params JSON array for eth_getStorageAt
/// Returns: ["0x1234...", "0x0000...", "latest"]
pub fn buildGetStorageAtParams(
    allocator: std.mem.Allocator,
    address: Address,
    slot: u256,
    block: BlockTag,
) ![]const u8 {
    // Convert address to hex string
    var addr_buf: [42]u8 = undefined; // "0x" + 40 hex chars
    addr_buf[0] = '0';
    addr_buf[1] = 'x';
    const hex_digits = "0123456789abcdef";
    for (address.bytes, 0..) |byte, i| {
        addr_buf[2 + i * 2] = hex_digits[byte >> 4];
        addr_buf[2 + i * 2 + 1] = hex_digits[byte & 0x0F];
    }

    // Convert slot to 32-byte hex string
    var slot_bytes: [32]u8 = undefined;
    std.mem.writeInt(u256, &slot_bytes, slot, .big);
    var slot_buf: [66]u8 = undefined; // "0x" + 64 hex chars
    slot_buf[0] = '0';
    slot_buf[1] = 'x';
    for (slot_bytes, 0..) |byte, i| {
        slot_buf[2 + i * 2] = hex_digits[byte >> 4];
        slot_buf[2 + i * 2 + 1] = hex_digits[byte & 0x0F];
    }

    const block_str = try block.toJson(allocator);
    defer allocator.free(block_str);

    return try std.fmt.allocPrint(
        allocator,
        "[\"{s}\", \"{s}\", {s}]",
        .{ addr_buf, slot_buf, block_str },
    );
}

/// Build params JSON array for eth_getBalance
/// Returns: ["0x1234...", "latest"]
pub fn buildGetBalanceParams(
    allocator: std.mem.Allocator,
    address: Address,
    block: BlockTag,
) ![]const u8 {
    const hex_digits = "0123456789abcdef";
    var addr_buf: [42]u8 = undefined;
    addr_buf[0] = '0';
    addr_buf[1] = 'x';
    for (address.bytes, 0..) |byte, i| {
        addr_buf[2 + i * 2] = hex_digits[byte >> 4];
        addr_buf[2 + i * 2 + 1] = hex_digits[byte & 0x0F];
    }

    const block_str = try block.toJson(allocator);
    defer allocator.free(block_str);

    return try std.fmt.allocPrint(
        allocator,
        "[\"{s}\", {s}]",
        .{ addr_buf, block_str },
    );
}

/// Build params JSON array for eth_getCode
/// Returns: ["0x1234...", "latest"]
pub fn buildGetCodeParams(
    allocator: std.mem.Allocator,
    address: Address,
    block: BlockTag,
) ![]const u8 {
    const hex_digits = "0123456789abcdef";
    var addr_buf: [42]u8 = undefined;
    addr_buf[0] = '0';
    addr_buf[1] = 'x';
    for (address.bytes, 0..) |byte, i| {
        addr_buf[2 + i * 2] = hex_digits[byte >> 4];
        addr_buf[2 + i * 2 + 1] = hex_digits[byte & 0x0F];
    }

    const block_str = try block.toJson(allocator);
    defer allocator.free(block_str);

    return try std.fmt.allocPrint(
        allocator,
        "[\"{s}\", {s}]",
        .{ addr_buf, block_str },
    );
}

/// Build params JSON array for eth_getTransactionCount (nonce)
/// Returns: ["0x1234...", "latest"]
pub fn buildGetTransactionCountParams(
    allocator: std.mem.Allocator,
    address: Address,
    block: BlockTag,
) ![]const u8 {
    const hex_digits = "0123456789abcdef";
    var addr_buf: [42]u8 = undefined;
    addr_buf[0] = '0';
    addr_buf[1] = 'x';
    for (address.bytes, 0..) |byte, i| {
        addr_buf[2 + i * 2] = hex_digits[byte >> 4];
        addr_buf[2 + i * 2 + 1] = hex_digits[byte & 0x0F];
    }

    const block_str = try block.toJson(allocator);
    defer allocator.free(block_str);

    return try std.fmt.allocPrint(
        allocator,
        "[\"{s}\", {s}]",
        .{ addr_buf, block_str },
    );
}

/// Build params JSON array for eth_getProof
/// Returns: ["0x1234...", [], "latest"]
pub fn buildGetProofParams(
    allocator: std.mem.Allocator,
    address: Address,
    storage_keys: []const u256,
    block: BlockTag,
) ![]const u8 {
    const hex_digits = "0123456789abcdef";
    var addr_buf: [42]u8 = undefined;
    addr_buf[0] = '0';
    addr_buf[1] = 'x';
    for (address.bytes, 0..) |byte, i| {
        addr_buf[2 + i * 2] = hex_digits[byte >> 4];
        addr_buf[2 + i * 2 + 1] = hex_digits[byte & 0x0F];
    }

    // Build storage keys array
    var keys_list = std.ArrayList(u8).init(allocator);
    defer keys_list.deinit();
    const keys_writer = keys_list.writer();

    try keys_writer.writeByte('[');
    for (storage_keys, 0..) |key, i| {
        if (i > 0) try keys_writer.writeByte(',');

        var key_bytes: [32]u8 = undefined;
        std.mem.writeInt(u256, &key_bytes, key, .big);
        var key_buf: [66]u8 = undefined;
        key_buf[0] = '0';
        key_buf[1] = 'x';
        for (key_bytes, 0..) |byte, j| {
            key_buf[2 + j * 2] = hex_digits[byte >> 4];
            key_buf[2 + j * 2 + 1] = hex_digits[byte & 0x0F];
        }
        try keys_writer.print("\"{s}\"", .{key_buf});
    }
    try keys_writer.writeByte(']');

    const block_str = try block.toJson(allocator);
    defer allocator.free(block_str);

    return try std.fmt.allocPrint(
        allocator,
        "[\"{s}\", {s}, {s}]",
        .{ addr_buf, keys_list.items, block_str },
    );
}

/// Parse hex string to u256
fn parseHexU256(hex_str: []const u8) !u256 {
    // Remove "0x" prefix if present
    const hex = if (hex_str.len >= 2 and hex_str[0] == '0' and (hex_str[1] == 'x' or hex_str[1] == 'X'))
        hex_str[2..]
    else
        hex_str;

    if (hex.len == 0) return 0;
    if (hex.len > 64) return error.HexTooLong;

    var result: u256 = 0;
    for (hex) |c| {
        const digit = switch (c) {
            '0'...'9' => c - '0',
            'a'...'f' => c - 'a' + 10,
            'A'...'F' => c - 'A' + 10,
            else => return error.InvalidHexCharacter,
        };
        result = (result << 4) | digit;
    }
    return result;
}

/// Parse hex string to u64
fn parseHexU64(hex_str: []const u8) !u64 {
    const hex = if (hex_str.len >= 2 and hex_str[0] == '0' and (hex_str[1] == 'x' or hex_str[1] == 'X'))
        hex_str[2..]
    else
        hex_str;

    if (hex.len == 0) return 0;
    if (hex.len > 16) return error.HexTooLong;

    var result: u64 = 0;
    for (hex) |c| {
        const digit = switch (c) {
            '0'...'9' => c - '0',
            'a'...'f' => c - 'a' + 10,
            'A'...'F' => c - 'A' + 10,
            else => return error.InvalidHexCharacter,
        };
        result = (result << 4) | digit;
    }
    return result;
}

/// Parse hex string to bytes (allocates)
fn parseHexBytes(allocator: std.mem.Allocator, hex_str: []const u8) ![]u8 {
    const hex = if (hex_str.len >= 2 and hex_str[0] == '0' and (hex_str[1] == 'x' or hex_str[1] == 'X'))
        hex_str[2..]
    else
        hex_str;

    if (hex.len == 0) return try allocator.alloc(u8, 0);
    if (hex.len % 2 != 0) return error.OddHexLength;

    const result = try allocator.alloc(u8, hex.len / 2);
    errdefer allocator.free(result);

    var i: usize = 0;
    while (i < hex.len) : (i += 2) {
        const high = switch (hex[i]) {
            '0'...'9' => hex[i] - '0',
            'a'...'f' => hex[i] - 'a' + 10,
            'A'...'F' => hex[i] - 'A' + 10,
            else => return error.InvalidHexCharacter,
        };
        const low = switch (hex[i + 1]) {
            '0'...'9' => hex[i + 1] - '0',
            'a'...'f' => hex[i + 1] - 'a' + 10,
            'A'...'F' => hex[i + 1] - 'A' + 10,
            else => return error.InvalidHexCharacter,
        };
        result[i / 2] = (high << 4) | low;
    }

    return result;
}

/// Parse eth_getStorageAt response
/// Expects: "0x0000..." (hex string)
pub fn parseStorageResponse(response: []const u8) !u256 {
    // Trim whitespace and quotes
    var start: usize = 0;
    var end: usize = response.len;

    while (start < end and (response[start] == ' ' or response[start] == '\n' or response[start] == '\r' or response[start] == '\t' or response[start] == '"')) : (start += 1) {}
    while (end > start and (response[end - 1] == ' ' or response[end - 1] == '\n' or response[end - 1] == '\r' or response[end - 1] == '\t' or response[end - 1] == '"')) : (end -= 1) {}

    const trimmed = response[start..end];
    return try parseHexU256(trimmed);
}

/// Parse eth_getBalance response
/// Expects: "0x1234..." (hex string)
pub fn parseBalanceResponse(response: []const u8) !u256 {
    return try parseStorageResponse(response); // Same format
}

/// Parse eth_getTransactionCount response
/// Expects: "0x12" (hex string)
pub fn parseTransactionCountResponse(response: []const u8) !u64 {
    var start: usize = 0;
    var end: usize = response.len;

    while (start < end and (response[start] == ' ' or response[start] == '\n' or response[start] == '\r' or response[start] == '\t' or response[start] == '"')) : (start += 1) {}
    while (end > start and (response[end - 1] == ' ' or response[end - 1] == '\n' or response[end - 1] == '\r' or response[end - 1] == '\t' or response[end - 1] == '"')) : (end -= 1) {}

    const trimmed = response[start..end];
    return try parseHexU64(trimmed);
}

/// Parse eth_getCode response (allocates)
/// Expects: "0x6060..." (hex string)
pub fn parseCodeResponse(allocator: std.mem.Allocator, response: []const u8) ![]u8 {
    var start: usize = 0;
    var end: usize = response.len;

    while (start < end and (response[start] == ' ' or response[start] == '\n' or response[start] == '\r' or response[start] == '\t' or response[start] == '"')) : (start += 1) {}
    while (end > start and (response[end - 1] == ' ' or response[end - 1] == '\n' or response[end - 1] == '\r' or response[end - 1] == '\t' or response[end - 1] == '"')) : (end -= 1) {}

    const trimmed = response[start..end];
    return try parseHexBytes(allocator, trimmed);
}

/// Account proof data from eth_getProof
pub const AccountProof = struct {
    balance: u256,
    nonce: u64,
    code_hash: [32]u8,
    storage_hash: [32]u8,
};

/// Parse eth_getProof response
/// This is a simplified parser that extracts just the account data we need
/// Full format: { balance, nonce, codeHash, storageHash, accountProof, storageProof }
pub fn parseProofResponse(response: []const u8) !AccountProof {
    const parsed = try std.json.parseFromSlice(std.json.Value, std.heap.page_allocator, response, .{});
    defer parsed.deinit();

    const root = parsed.value;
    if (root != .object) return error.InvalidProofResponse;

    const balance_str = root.object.get("balance") orelse return error.MissingBalance;
    const nonce_str = root.object.get("nonce") orelse return error.MissingNonce;
    const code_hash_str = root.object.get("codeHash") orelse return error.MissingCodeHash;
    const storage_hash_str = root.object.get("storageHash") orelse return error.MissingStorageHash;

    const balance = try parseHexU256(balance_str.string);
    const nonce = try parseHexU64(nonce_str.string);

    const code_hash_bytes = try parseHexBytes(std.heap.page_allocator, code_hash_str.string);
    defer std.heap.page_allocator.free(code_hash_bytes);
    if (code_hash_bytes.len != 32) return error.InvalidCodeHash;

    const storage_hash_bytes = try parseHexBytes(std.heap.page_allocator, storage_hash_str.string);
    defer std.heap.page_allocator.free(storage_hash_bytes);
    if (storage_hash_bytes.len != 32) return error.InvalidStorageHash;

    var result = AccountProof{
        .balance = balance,
        .nonce = nonce,
        .code_hash = undefined,
        .storage_hash = undefined,
    };
    @memcpy(&result.code_hash, code_hash_bytes);
    @memcpy(&result.storage_hash, storage_hash_bytes);

    return result;
}

// Unit tests
test "buildGetStorageAtParams" {
    const allocator = std.testing.allocator;
    const address = Address{ .bytes = [_]u8{0x12} ++ [_]u8{0} ** 19 };
    const slot: u256 = 5;
    const block = BlockTag.latest;

    const params = try buildGetStorageAtParams(allocator, address, slot, block);
    defer allocator.free(params);

    try std.testing.expect(std.mem.indexOf(u8, params, "0x1200000000000000000000000000000000000000") != null);
    try std.testing.expect(std.mem.indexOf(u8, params, "latest") != null);
}

test "parseStorageResponse" {
    const response = "\"0x0000000000000000000000000000000000000000000000000000000000000005\"";
    const result = try parseStorageResponse(response);
    try std.testing.expectEqual(@as(u256, 5), result);
}

test "parseHexU256" {
    try std.testing.expectEqual(@as(u256, 0), try parseHexU256("0x0"));
    try std.testing.expectEqual(@as(u256, 255), try parseHexU256("0xff"));
    try std.testing.expectEqual(@as(u256, 255), try parseHexU256("0xFF"));
    try std.testing.expectEqual(@as(u256, 4096), try parseHexU256("0x1000"));
}

test "parseCodeResponse" {
    const allocator = std.testing.allocator;
    const response = "\"0x6060604052\"";
    const code = try parseCodeResponse(allocator, response);
    defer allocator.free(code);

    try std.testing.expectEqual(@as(usize, 5), code.len);
    try std.testing.expectEqual(@as(u8, 0x60), code[0]);
    try std.testing.expectEqual(@as(u8, 0x52), code[4]);
}
