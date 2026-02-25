const std = @import("std");
const testing = std.testing;
const trie = @import("root.zig");
const Hex = @import("voltaire").Hex;

test "TrieTests fixtures - trieanyorder" {
    try run_fixture_file("ethereum-tests/TrieTests/trieanyorder.json", false);
}

test "TrieTests fixtures - trieanyorder_secureTrie" {
    try run_fixture_file("ethereum-tests/TrieTests/trieanyorder_secureTrie.json", true);
}

test "TrieTests fixtures - trietest" {
    try run_fixture_file("ethereum-tests/TrieTests/trietest.json", false);
}

test "TrieTests fixtures - trietest_secureTrie" {
    try run_fixture_file("ethereum-tests/TrieTests/trietest_secureTrie.json", true);
}

test "TrieTests fixtures - hex_encoded_securetrie_test" {
    try run_fixture_file("ethereum-tests/TrieTests/hex_encoded_securetrie_test.json", true);
}

fn run_fixture_file(path: []const u8, secure: bool) !void {
    const allocator = testing.allocator;
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const contents = try file.readToEndAlloc(allocator, 16 * 1024 * 1024);
    defer allocator.free(contents);

    var parsed = try std.json.parseFromSlice(std.json.Value, allocator, contents, .{});
    defer parsed.deinit();

    const root_value = parsed.value;
    const root_obj = switch (root_value) {
        .object => |obj| obj,
        else => return error.InvalidFixture,
    };

    var it = root_obj.iterator();
    while (it.next()) |entry| {
        try run_fixture_case(parsed.arena.allocator(), entry.key_ptr.*, entry.value_ptr.*, secure);
    }
}

fn run_fixture_case(
    allocator: std.mem.Allocator,
    name: []const u8,
    value: std.json.Value,
    secure: bool,
) !void {
    const case_obj = switch (value) {
        .object => |obj| obj,
        else => return error.InvalidFixture,
    };

    const in_value = case_obj.get("in") orelse return error.InvalidFixture;
    const root_value = case_obj.get("root") orelse return error.InvalidFixture;
    const root_str = switch (root_value) {
        .string => |s| s,
        else => return error.InvalidFixture,
    };

    var hex_encoded = false;
    if (case_obj.get("hexEncoded")) |flag| {
        hex_encoded = switch (flag) {
            .bool => |b| b,
            else => return error.InvalidFixture,
        };
    }

    var map = std.StringArrayHashMap([]const u8).init(allocator);
    defer map.deinit();

    try apply_input(allocator, &map, in_value, hex_encoded);

    const keys = map.keys();
    const values = map.values();
    const computed = if (secure)
        try trie.secure_trie_root(testing.allocator, keys, values)
    else
        try trie.trie_root(testing.allocator, keys, values);

    const expected = try Hex.hexToBytesFixed(32, root_str);
    if (!std.mem.eql(u8, &expected, &computed)) {
        std.debug.print("Trie fixture mismatch: {s}\n", .{name});
        return error.TestExpectedEqual;
    }
}

fn apply_input(
    allocator: std.mem.Allocator,
    map: *std.StringArrayHashMap([]const u8),
    value: std.json.Value,
    force_hex: bool,
) !void {
    switch (value) {
        .object => |obj| {
            var it = obj.iterator();
            while (it.next()) |entry| {
                const key_value = std.json.Value{ .string = entry.key_ptr.* };
                try apply_entry(allocator, map, key_value, entry.value_ptr.*, force_hex);
            }
        },
        .array => |arr| {
            for (arr.items) |item| {
                const pair = switch (item) {
                    .array => |pair_value| pair_value,
                    else => return error.InvalidFixture,
                };
                if (pair.items.len != 2) {
                    return error.InvalidFixture;
                }
                try apply_entry(allocator, map, pair.items[0], pair.items[1], force_hex);
            }
        },
        else => return error.InvalidFixture,
    }
}

fn apply_entry(
    allocator: std.mem.Allocator,
    map: *std.StringArrayHashMap([]const u8),
    key_value: std.json.Value,
    value_value: std.json.Value,
    force_hex: bool,
) !void {
    const key_bytes = switch (key_value) {
        .string => |s| try decode_string(allocator, s, force_hex),
        else => return error.InvalidFixture,
    };

    switch (value_value) {
        .null => {
            _ = map.swapRemove(key_bytes);
        },
        .string => |s| {
            const value_bytes = try decode_string(allocator, s, force_hex);
            try map.put(key_bytes, value_bytes);
        },
        else => return error.InvalidFixture,
    }
}

fn decode_string(
    allocator: std.mem.Allocator,
    value: []const u8,
    force_hex: bool,
) ![]const u8 {
    if (force_hex or Hex.isHex(value)) {
        return Hex.hexToBytes(allocator, value);
    }
    return value;
}
