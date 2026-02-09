const std = @import("std");
const crypto = @import("crypto");
const primitives = @import("primitives");
const trie = @import("client_trie");

const Allocator = std.mem.Allocator;
const Hash32 = trie.Hash32;

const FixtureFile = struct {
    file: []const u8,
    secure: bool,
};

const fixture_files = [_]FixtureFile{
    .{ .file = "trietest.json", .secure = false },
    .{ .file = "trieanyorder.json", .secure = false },
    .{ .file = "trietest_secureTrie.json", .secure = true },
    .{ .file = "trieanyorder_secureTrie.json", .secure = true },
    .{ .file = "hex_encoded_securetrie_test.json", .secure = true },
};

test "trie fixtures (ethereum-tests)" {
    const allocator = std.testing.allocator;

    for (fixture_files) |fixture| {
        try runFixtureFile(allocator, fixture.file, fixture.secure);
    }
}

fn runFixtureFile(allocator: Allocator, file: []const u8, secure: bool) !void {
    const path = try std.fmt.allocPrint(allocator, "ethereum-tests/TrieTests/{s}", .{file});
    defer allocator.free(path);

    const json_bytes = try std.fs.cwd().readFileAlloc(allocator, path, std.math.maxInt(usize));
    defer allocator.free(json_bytes);

    var parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_bytes, .{});
    defer parsed.deinit();

    if (parsed.value != .object) return error.InvalidFixtureFormat;
    var it = parsed.value.object.iterator();
    while (it.next()) |entry| {
        const test_name = entry.key_ptr.*;
        const test_value = entry.value_ptr.*;
        if (test_value != .object) return error.InvalidFixtureFormat;

        const test_obj = test_value.object;
        const input = test_obj.get("in") orelse return error.InvalidFixtureFormat;
        const root_value = test_obj.get("root") orelse return error.InvalidFixtureFormat;
        if (root_value != .string) return error.InvalidFixtureFormat;
        const root_hex = root_value.string;

        const hex_encoded = if (test_obj.get("hexEncoded")) |flag| blk: {
            if (flag != .bool) return error.InvalidFixtureFormat;
            break :blk flag.bool;
        } else false;

        var map = std.StringHashMap([]u8).init(allocator);
        defer deinitMap(allocator, &map);

        try ingestInput(allocator, &map, input, secure, hex_encoded);

        const actual = try computeRoot(allocator, &map);
        const expected = try primitives.Hex.hexToBytesFixed(32, root_hex);

        if (!std.mem.eql(u8, actual[0..], expected[0..])) {
            const expected_hex = try primitives.Hex.bytesToHex(allocator, expected[0..]);
            defer allocator.free(expected_hex);
            const actual_hex = try primitives.Hex.bytesToHex(allocator, actual[0..]);
            defer allocator.free(actual_hex);

            std.debug.print("Trie fixture mismatch {s}:{s}\n", .{ file, test_name });
            std.debug.print("  expected={s}\n", .{expected_hex});
            std.debug.print("       got={s}\n", .{actual_hex});
            return error.TestFailure;
        }
    }
}

fn ingestInput(
    allocator: Allocator,
    map: *std.StringHashMap([]u8),
    input: std.json.Value,
    secure: bool,
    hex_encoded: bool,
) !void {
    switch (input) {
        .array => |items| {
            for (items.items) |pair| {
                if (pair != .array or pair.array.items.len != 2) {
                    return error.InvalidFixtureFormat;
                }
                const key_value = pair.array.items[0];
                const value_value = pair.array.items[1];
                if (key_value != .string) return error.InvalidFixtureFormat;

                const key_bytes = try parseKeyBytes(allocator, key_value.string, secure, hex_encoded);
                const value_bytes = try parseValueBytes(allocator, value_value, hex_encoded);
                try applyEntry(allocator, map, key_bytes, value_bytes);
            }
        },
        .object => |obj| {
            var iter = obj.iterator();
            while (iter.next()) |pair| {
                const key_bytes = try parseKeyBytes(allocator, pair.key_ptr.*, secure, hex_encoded);
                const value_bytes = try parseValueBytes(allocator, pair.value_ptr.*, hex_encoded);
                try applyEntry(allocator, map, key_bytes, value_bytes);
            }
        },
        else => return error.InvalidFixtureFormat,
    }
}

fn parseKeyBytes(
    allocator: Allocator,
    key: []const u8,
    secure: bool,
    hex_encoded: bool,
) ![]u8 {
    var key_bytes = if (hex_encoded or std.mem.startsWith(u8, key, "0x"))
        try primitives.Hex.hexToBytes(allocator, key)
    else
        try allocator.dupe(u8, key);

    if (!secure) return key_bytes;

    const hashed = crypto.Hash.keccak256(key_bytes);
    allocator.free(key_bytes);

    key_bytes = try allocator.alloc(u8, hashed.len);
    @memcpy(key_bytes, &hashed);
    return key_bytes;
}

fn parseValueBytes(allocator: Allocator, value: std.json.Value, hex_encoded: bool) ![]u8 {
    switch (value) {
        .null => return allocator.alloc(u8, 0),
        .string => |str| {
            if (hex_encoded or std.mem.startsWith(u8, str, "0x")) {
                return primitives.Hex.hexToBytes(allocator, str);
            }
            return allocator.dupe(u8, str);
        },
        else => return error.InvalidFixtureFormat,
    }
}

fn applyEntry(
    allocator: Allocator,
    map: *std.StringHashMap([]u8),
    key: []u8,
    value: []u8,
) !void {
    if (value.len == 0) {
        if (map.fetchRemove(key)) |removed| {
            allocator.free(removed.key);
            allocator.free(removed.value);
        }
        allocator.free(key);
        allocator.free(value);
        return;
    }

    if (map.getEntry(key)) |entry| {
        allocator.free(entry.value_ptr.*);
        entry.value_ptr.* = value;
        allocator.free(key);
        return;
    }

    try map.put(key, value);
}

fn computeRoot(allocator: Allocator, map: *const std.StringHashMap([]u8)) !Hash32 {
    const count = map.count();
    if (count == 0) return trie.EMPTY_TRIE_ROOT;

    const keys = try allocator.alloc([]const u8, count);
    defer allocator.free(keys);
    const values = try allocator.alloc([]const u8, count);
    defer allocator.free(values);

    var i: usize = 0;
    var it = map.iterator();
    while (it.next()) |entry| : (i += 1) {
        keys[i] = entry.key_ptr.*;
        values[i] = entry.value_ptr.*;
    }

    return trie.trie_root(allocator, keys, values);
}

fn deinitMap(allocator: Allocator, map: *std.StringHashMap([]u8)) void {
    var it = map.iterator();
    while (it.next()) |entry| {
        allocator.free(entry.key_ptr.*);
        allocator.free(entry.value_ptr.*);
    }
    map.deinit();
}
