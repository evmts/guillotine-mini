const std = @import("std");
const testing = std.testing;
const evm_mod = @import("evm");
const primitives = @import("primitives");
const Address = primitives.Address.Address;
const test_host_mod = @import("test_host.zig");
const TestHost = test_host_mod.TestHost;
const StorageSlotKey = test_host_mod.StorageSlotKey;
const assembler = @import("assembler.zig");

// Error type for tests that are not yet implemented
pub const TestTodo = error.TestTodo;

// Run a single test case from JSON
pub fn runJsonTest(allocator: std.mem.Allocator, test_case: std.json.Value) !void {
    // Handle non-object test cases
    if (test_case != .object) {
        return;
    }

    // std.debug.print("DEBUG: Starting test\n", .{});

    // Create test host
    var test_host = try TestHost.init(allocator);
    defer test_host.deinit();

    // Setup pre-state
    if (test_case.object.get("pre")) |pre| {
        if (pre == .object) {
            var it = pre.object.iterator();
            while (it.next()) |kv| {
                const address = try parseAddress(kv.key_ptr.*);
                const account = kv.value_ptr.*;

                // Set balance
                if (account.object.get("balance")) |balance| {
                    const bal_str = balance.string;
                    const bal = if (bal_str.len == 0) 0 else try std.fmt.parseInt(u256, bal_str, 0);
                    try test_host.setBalance(address, bal);
                }

                // Set nonce
                if (account.object.get("nonce")) |nonce| {
                    const nonce_val = try parseIntFromJson(nonce);
                    try test_host.setNonce(address, nonce_val);
                }

                // Set code
                if (account.object.get("code")) |code| {
                    if (code == .string) {
                        const code_str = code.string;
                        if (!std.mem.eql(u8, code_str, "") and !std.mem.eql(u8, code_str, "0x")) {
                            // Check if this is assembly code that needs compilation
                            if (std.mem.startsWith(u8, code_str, ":yul ") or
                                std.mem.startsWith(u8, code_str, "(asm ") or
                                std.mem.startsWith(u8, code_str, ":asm ") or
                                std.mem.startsWith(u8, code_str, "{"))
                            {
                                // Compile assembly to bytecode
                                const compiled_bytes = try assembler.compileAssembly(allocator, code_str);
                                defer allocator.free(compiled_bytes);
                                try test_host.setCode(address, compiled_bytes);
                            } else {
                                // Handle :raw format or direct hex
                                var hex_str = code_str;
                                if (std.mem.startsWith(u8, code_str, ":raw ")) {
                                    hex_str = std.mem.trim(u8, code_str[5..], " \t\n\r");
                                }

                                // Parse hex and handle placeholders
                                const hex_data = try parseHexData(allocator, hex_str);
                                defer allocator.free(hex_data);

                                if (hex_data.len > 2) {
                                    const code_bytes = try primitives.Hex.hex_to_bytes(allocator, hex_data);
                                    defer allocator.free(code_bytes);
                                    try test_host.setCode(address, code_bytes);
                                }
                            }
                        }
                    }
                }

                // Set storage
                if (account.object.get("storage")) |storage| {
                    if (storage == .object) {
                        var storage_it = storage.object.iterator();
                        while (storage_it.next()) |storage_kv| {
                            const key = try std.fmt.parseInt(u256, storage_kv.key_ptr.*, 0);
                            const value_str = storage_kv.value_ptr.*.string;
                            const value: u256 = if (std.mem.startsWith(u8, value_str, "<") and std.mem.endsWith(u8, value_str, ">")) blk: {
                                const addr = try parseAddress(value_str);
                                const addr_bytes = addr.bytes;
                                var addr_int: u256 = 0;
                                for (addr_bytes) |b| {
                                    addr_int = (addr_int << 8) | b;
                                }
                                break :blk addr_int;
                            } else blk: {
                                break :blk try std.fmt.parseInt(u256, value_str, 0);
                            };
                            try test_host.setStorageSlot(address, key, value);
                        }
                    }
                }
            }
        }
    }

    // Block context is optional - pass null to use EVM's defaults
    // TODO: Parse from JSON env when needed for specific tests
    _ = test_case.object.get("env");
    const block_ctx = null;

    // Create EVM with test host
    const host_interface = test_host.hostInterface();
    var evm_instance = try evm_mod.Evm.init(allocator, host_interface, null, block_ctx);
    defer evm_instance.deinit();

    // Execute transaction(s)
    const has_transactions = test_case.object.get("transactions") != null;
    const has_transaction = test_case.object.get("transaction") != null;

    if (has_transactions or has_transaction) {
        const transactions = if (has_transactions)
            test_case.object.get("transactions").?.array.items
        else
            &[_]std.json.Value{test_case.object.get("transaction").?};

        for (transactions) |tx| {
            // Parse transaction data
            const tx_data = if (tx.object.get("data")) |data| blk: {
                const data_str = if (data == .array) data.array.items[0].string else data.string;
                const hex = try parseHexData(allocator, data_str);
                defer allocator.free(hex);
                if (hex.len > 2) {
                    break :blk try primitives.Hex.hex_to_bytes(allocator, hex);
                } else {
                    break :blk try allocator.alloc(u8, 0);
                }
            } else try allocator.alloc(u8, 0);
            defer allocator.free(tx_data);

            // Determine sender
            const sender = if (tx.object.get("sender")) |s|
                try parseAddress(s.string)
            else if (tx.object.get("secretKey") != null)
                try Address.fromHex("0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b")
            else
                primitives.ZERO_ADDRESS;

            // Set origin
            evm_instance.origin = sender;

            // Parse and set gas price
            if (tx.object.get("gasPrice")) |gp| {
                const gas_price_str = gp.string;
                const gas_price = if (gas_price_str.len == 0) 0 else try std.fmt.parseInt(u256, gas_price_str, 0);
                evm_instance.gas_price = gas_price;
            }

            // Parse gas limit
            const gas_limit = if (tx.object.get("gasLimit")) |g| blk: {
                if (g == .array) {
                    break :blk try parseIntFromJson(g.array.items[0]);
                } else {
                    break :blk try parseIntFromJson(g);
                }
            } else 1000000;

            // Parse value
            const value = if (tx.object.get("value")) |v| blk: {
                const val_str = if (v == .array) v.array.items[0].string else v.string;
                break :blk if (val_str.len == 0) 0 else try std.fmt.parseInt(u256, val_str, 0);
            } else 0;

            // Parse to address
            const to = if (tx.object.get("to")) |to_val| blk: {
                const to_str = to_val.string;
                if (to_str.len == 0) break :blk null;
                break :blk try parseAddress(to_str);
            } else null;

            // Increment sender's nonce before transaction (as per Ethereum spec)
            const current_nonce = test_host.getNonce(sender);
            try test_host.setNonce(sender, current_nonce + 1);

            // Get contract code
            const target_addr = to orelse primitives.ZERO_ADDRESS;
            const bytecode = test_host.code.get(target_addr) orelse &[_]u8{};

            // Execute
            const result = try evm_instance.call(
                bytecode,
                @intCast(gas_limit),
                sender,
                target_addr,
                value,
                tx_data,
            );

            // Result is automatically cleaned up by arena
            _ = result;
        }
    }

    // Validate post-state
    if (test_case.object.get("post")) |post| {
        // Debug: print all storage for debugging
        // var storage_debug_it = test_host.storage.iterator();
        // while (storage_debug_it.next()) |entry| {
        //     std.debug.print("DEBUG: Storage addr={any} slot={} value={}\n", .{entry.key_ptr.address.bytes, entry.key_ptr.slot, entry.value_ptr.*});
        // }
        if (post == .object) {
            var it = post.object.iterator();
            while (it.next()) |kv| {
                const address = try parseAddress(kv.key_ptr.*);
                const expected = kv.value_ptr.*;

                // Check if account should not exist
                if (expected.object.get("shouldnotexist")) |sne| {
                    const should_not_exist = try parseIntFromJson(sne);
                    if (should_not_exist == 1) {
                        // Verify account doesn't exist (no balance, no code, no nonce, no storage)
                        const balance = test_host.balances.get(address) orelse 0;
                        const nonce = test_host.getNonce(address);
                        const code = test_host.code.get(address) orelse &[_]u8{};

                        try testing.expectEqual(@as(u256, 0), balance);
                        try testing.expectEqual(@as(u64, 0), nonce);
                        try testing.expectEqual(@as(usize, 0), code.len);
                        continue;
                    }
                }

                // Check balance
                if (expected.object.get("balance")) |expected_bal| {
                    const exp = if (expected_bal.string.len == 0) 0 else try std.fmt.parseInt(u256, expected_bal.string, 0);
                    const actual = test_host.balances.get(address) orelse 0;
                    try testing.expectEqual(exp, actual);
                }

                // Check nonce
                if (expected.object.get("nonce")) |expected_nonce| {
                    const exp = try parseIntFromJson(expected_nonce);
                    const actual = test_host.getNonce(address);
                    try testing.expectEqual(exp, actual);
                }

                // Check storage
                if (expected.object.get("storage")) |storage| {
                    if (storage == .object) {
                        var storage_it = storage.object.iterator();
                        while (storage_it.next()) |storage_kv| {
                            const key = try std.fmt.parseInt(u256, storage_kv.key_ptr.*, 0);
                            const exp_value: u256 = if (std.mem.startsWith(u8, storage_kv.value_ptr.*.string, "<") and std.mem.endsWith(u8, storage_kv.value_ptr.*.string, ">")) blk: {
                                const addr = try parseAddress(storage_kv.value_ptr.*.string);
                                const addr_bytes = addr.bytes;
                                var addr_int: u256 = 0;
                                for (addr_bytes) |b| {
                                    addr_int = (addr_int << 8) | b;
                                }
                                break :blk addr_int;
                            } else blk: {
                                break :blk try std.fmt.parseInt(u256, storage_kv.value_ptr.*.string, 0);
                            };

                            const slot_key = StorageSlotKey{ .address = address, .slot = key };
                            const actual_value = test_host.storage.get(slot_key) orelse 0;
                            // if (exp_value != actual_value) {
                            //     std.debug.print("Storage mismatch: addr={any} slot={} expected {}, found {}\n", .{address.bytes, key, exp_value, actual_value});
                            // }
                            try testing.expectEqual(exp_value, actual_value);
                        }
                    }
                }
            }
        }
    } else if (test_case.object.get("expect")) |expect_list| {
        // Debug: print all storage for debugging
        // var storage_debug_it2 = test_host.storage.iterator();
        // while (storage_debug_it2.next()) |entry| {
        //     std.debug.print("DEBUG: Storage addr={any} slot={} value={}\n", .{entry.key_ptr.address.bytes, entry.key_ptr.slot, entry.value_ptr.*});
        // }

        // Handle expect format (alternative to post)
        if (expect_list == .array) {
            for (expect_list.array.items) |expectation| {
                if (expectation.object.get("result")) |result| {
                    if (result == .object) {
                        var it = result.object.iterator();
                        while (it.next()) |kv| {
                            const address = try parseAddress(kv.key_ptr.*);
                            const expected = kv.value_ptr.*;

                            // Check if account should not exist
                            if (expected.object.get("shouldnotexist")) |sne| {
                                const should_not_exist = try parseIntFromJson(sne);
                                if (should_not_exist == 1) {
                                    // Verify account doesn't exist (no balance, no code, no nonce, no storage)
                                    const balance = test_host.balances.get(address) orelse 0;
                                    const nonce = test_host.getNonce(address);
                                    const code = test_host.code.get(address) orelse &[_]u8{};

                                    try testing.expectEqual(@as(u256, 0), balance);
                                    try testing.expectEqual(@as(u64, 0), nonce);
                                    try testing.expectEqual(@as(usize, 0), code.len);
                                    continue;
                                }
                            }

                            // Check balance
                            if (expected.object.get("balance")) |expected_bal| {
                                const exp = if (expected_bal.string.len == 0) 0 else try std.fmt.parseInt(u256, expected_bal.string, 0);
                                const actual = test_host.balances.get(address) orelse 0;
                                try testing.expectEqual(exp, actual);
                            }

                            // Check nonce
                            if (expected.object.get("nonce")) |expected_nonce| {
                                const exp = try parseIntFromJson(expected_nonce);
                                const actual = test_host.getNonce(address);
                                try testing.expectEqual(exp, actual);
                            }

                            // Check storage
                            if (expected.object.get("storage")) |storage| {
                                if (storage == .object) {
                                    var storage_it = storage.object.iterator();
                                    while (storage_it.next()) |storage_kv| {
                                        const key = try std.fmt.parseInt(u256, storage_kv.key_ptr.*, 0);
                                        const exp_value: u256 = if (std.mem.startsWith(u8, storage_kv.value_ptr.*.string, "<") and std.mem.endsWith(u8, storage_kv.value_ptr.*.string, ">")) blk: {
                                            const addr = try parseAddress(storage_kv.value_ptr.*.string);
                                            const addr_bytes = addr.bytes;
                                            var addr_int: u256 = 0;
                                            for (addr_bytes) |b| {
                                                addr_int = (addr_int << 8) | b;
                                            }
                                            break :blk addr_int;
                                        } else blk: {
                                            break :blk try std.fmt.parseInt(u256, storage_kv.value_ptr.*.string, 0);
                                        };

                                        const slot_key = StorageSlotKey{ .address = address, .slot = key };
                                        const actual_value = test_host.storage.get(slot_key) orelse 0;
                                        // if (exp_value != actual_value) {
                                        //     std.debug.print("Storage mismatch: addr={any} slot={} expected {}, found {}\n", .{address.bytes, key, exp_value, actual_value});
                                        // }
                                        try testing.expectEqual(exp_value, actual_value);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

fn parseIntFromJson(value: std.json.Value) !u64 {
    return switch (value) {
        .string => |s| if (s.len == 0) 0 else try std.fmt.parseInt(u64, s, 0),
        .integer => |i| @intCast(i),
        .number_string => |s| if (s.len == 0) 0 else try std.fmt.parseInt(u64, s, 0),
        else => 1,
    };
}

fn parseAddress(addr: []const u8) !Address {
    var buf: [42]u8 = undefined;
    var clean_addr = addr;

    // Handle placeholder syntax like <contract:0x...> or <eoa:sender:0x...>
    if (std.mem.startsWith(u8, addr, "<") and std.mem.endsWith(u8, addr, ">")) {
        if (std.mem.lastIndexOf(u8, addr, "0x")) |idx| {
            clean_addr = addr[idx..];
            if (std.mem.indexOf(u8, clean_addr, ">")) |end_idx| {
                clean_addr = clean_addr[0..end_idx];
            }
        }
    }

    // Ensure proper format
    var final_addr: []const u8 = undefined;

    if (!std.mem.startsWith(u8, clean_addr, "0x")) {
        buf[0] = '0';
        buf[1] = 'x';
        const expected_len = 40;
        const actual_len = clean_addr.len;

        if (actual_len < expected_len) {
            const zeros_needed = expected_len - actual_len;
            for (0..zeros_needed) |i| {
                buf[2 + i] = '0';
            }
            @memcpy(buf[2 + zeros_needed .. 2 + zeros_needed + actual_len], clean_addr);
            final_addr = buf[0..42];
        } else {
            const copy_len = @min(actual_len, expected_len);
            @memcpy(buf[2 .. 2 + copy_len], clean_addr[0..copy_len]);
            final_addr = buf[0 .. 2 + copy_len];
        }
    } else {
        if (clean_addr.len < 42) {
            @memcpy(buf[0..2], "0x");
            const hex_part = clean_addr[2..];
            const zeros_needed = 40 - hex_part.len;
            for (0..zeros_needed) |i| {
                buf[2 + i] = '0';
            }
            @memcpy(buf[2 + zeros_needed .. 2 + zeros_needed + hex_part.len], hex_part);
            final_addr = buf[0..42];
        } else {
            final_addr = clean_addr;
        }
    }

    return try Address.fromHex(final_addr);
}

fn parseHexData(allocator: std.mem.Allocator, data: []const u8) ![]u8 {
    if (std.mem.eql(u8, data, "0x")) {
        const result = try allocator.alloc(u8, 2);
        @memcpy(result, "0x");
        return result;
    }

    var clean_data = data;
    if (std.mem.startsWith(u8, data, ":raw ")) {
        clean_data = data[5..];
    }

    // Handle placeholders in :raw data
    if (std.mem.indexOf(u8, clean_data, "<") != null) {
        var result = std.ArrayList(u8){};
        defer result.deinit(allocator);

        var hex_data = clean_data;
        if (std.mem.startsWith(u8, clean_data, "0x")) {
            hex_data = clean_data[2..];
        }

        var read_idx: usize = 0;
        while (read_idx < hex_data.len) {
            if (read_idx < hex_data.len and hex_data[read_idx] == '<') {
                if (std.mem.indexOf(u8, hex_data[read_idx..], ">")) |end_offset| {
                    const placeholder = hex_data[read_idx .. read_idx + end_offset + 1];
                    if (std.mem.lastIndexOf(u8, placeholder, "0x")) |addr_idx| {
                        const addr_end = placeholder.len - 1;
                        const addr = placeholder[addr_idx..addr_end];
                        if (addr.len >= 2 and std.mem.startsWith(u8, addr, "0x")) {
                            const addr_hex = addr[2..];
                            const padding_needed = if (addr_hex.len < 40) 40 - addr_hex.len else 0;
                            var j: usize = 0;
                            while (j < padding_needed) : (j += 1) {
                                try result.append(allocator, '0');
                            }
                            try result.appendSlice(allocator, addr_hex);
                        }
                    }
                    read_idx += end_offset + 1;
                    continue;
                }
            }
            try result.append(allocator, hex_data[read_idx]);
            read_idx += 1;
        }

        var final = try allocator.alloc(u8, result.items.len + 2);
        final[0] = '0';
        final[1] = 'x';
        @memcpy(final[2..], result.items);

        if ((final.len - 2) % 2 != 0) {
            const padded = try allocator.alloc(u8, final.len + 1);
            @memcpy(padded[0..2], "0x");
            padded[2] = '0';
            @memcpy(padded[3..], final[2..]);
            allocator.free(final);
            return padded;
        }
        return final;
    }

    // Ensure 0x prefix
    if (!std.mem.startsWith(u8, clean_data, "0x")) {
        const with_prefix = try allocator.alloc(u8, clean_data.len + 2);
        with_prefix[0] = '0';
        with_prefix[1] = 'x';
        @memcpy(with_prefix[2..], clean_data);
        return with_prefix;
    }

    const final_result = try allocator.dupe(u8, clean_data);
    if (final_result.len > 2 and (final_result.len - 2) % 2 != 0) {
        const padded = try allocator.alloc(u8, final_result.len + 1);
        @memcpy(padded[0..2], "0x");
        padded[2] = '0';
        @memcpy(padded[3..], final_result[2..]);
        allocator.free(final_result);
        return padded;
    }

    return final_result;
}
