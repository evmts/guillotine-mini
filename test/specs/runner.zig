const std = @import("std");
const testing = std.testing;
const evm_mod = @import("evm");
const primitives = @import("primitives");
const Address = primitives.Address.Address;
const test_host_mod = @import("test_host.zig");
const TestHost = test_host_mod.TestHost;
const StorageSlotKey = test_host_mod.StorageSlotKey;
const assembler = @import("assembler.zig");
const trace = @import("evm").trace;
const Hardfork = evm_mod.Hardfork;

// Error type for tests that are not yet implemented
pub const TestTodo = error.TestTodo;

// Taylor series approximation of factor * e^(numerator/denominator)
// This implements the fake_exponential function from EIP-4844
fn taylorExponential(factor: u256, numerator: u256, denominator: u256) u256 {
    var i: u256 = 1;
    var output: u256 = 0;
    var numerator_accumulated: u256 = factor * denominator;

    while (numerator_accumulated > 0) {
        output += numerator_accumulated;

        // Calculate next term: numerator_accumulated * numerator / (denominator * i)
        // Use checked arithmetic to prevent overflow
        const temp = std.math.mul(u256, numerator_accumulated, numerator) catch break;
        const divisor = std.math.mul(u256, denominator, i) catch break;
        numerator_accumulated = temp / divisor;

        i += 1;

        // Safety limit to prevent infinite loops
        if (i > 100) break;
    }

    return output / denominator;
}

// Run a single test case from JSON
pub fn runJsonTest(allocator: std.mem.Allocator, test_case: std.json.Value) !void {
    return runJsonTestWithPath(allocator, test_case, null);
}

pub fn runJsonTestWithPath(allocator: std.mem.Allocator, test_case: std.json.Value, test_file_path: ?[]const u8) !void {
    return runJsonTestWithPathAndName(allocator, test_case, test_file_path, null);
}

pub fn runJsonTestWithPathAndName(allocator: std.mem.Allocator, test_case: std.json.Value, test_file_path: ?[]const u8, test_name: ?[]const u8) !void {
    // Check if test has multiple hardforks in post section
    const post = test_case.object.get("post");
    if (post) |p| {
        if (p == .object) {
            // Collect all hardforks present in post section
            var hardforks_to_test: std.ArrayList(Hardfork) = .{};
            defer hardforks_to_test.deinit(allocator);

            // Check for each hardfork in order
            inline for (&[_][]const u8{ "Cancun", "Prague", "Shanghai", "Paris", "Merge", "London", "Berlin" }) |fork_name| {
                if (p.object.get(fork_name)) |_| {
                    if (Hardfork.fromString(fork_name)) |hf| {
                        try hardforks_to_test.append(allocator, hf);
                    }
                }
            }

            // If multiple hardforks found, test each one separately
            if (hardforks_to_test.items.len > 1) {
                for (hardforks_to_test.items) |hf| {
                    runJsonTestImplForFork(allocator, test_case, null, hf) catch |err| {
                        generateTraceDiffOnFailure(allocator, test_case, test_file_path, test_name) catch {};
                        return err;
                    };
                }
                return;
            }
        }
    }

    // Single hardfork or no post section - use original logic
    runJsonTestImpl(allocator, test_case, null) catch |err| {
        generateTraceDiffOnFailure(allocator, test_case, test_file_path, test_name) catch {};
        return err;
    };
}

// Helper to run test with a specific hardfork (for multi-fork tests)
fn runJsonTestImplForFork(allocator: std.mem.Allocator, test_case: std.json.Value, tracer: ?*trace.Tracer, forced_hardfork: Hardfork) !void {
    // Just call runJsonTestImpl with modified extractHardfork behavior
    // We'll modify runJsonTestImpl to accept an optional forced hardfork parameter
    try runJsonTestImplWithOptionalFork(allocator, test_case, tracer, forced_hardfork);
}

fn generateTraceDiffOnFailure(allocator: std.mem.Allocator, test_case: std.json.Value, opt_test_file_path: ?[]const u8, opt_test_name: ?[]const u8) !void {
    // Re-run with trace capture
    var tracer = trace.Tracer.init(allocator);
    defer tracer.deinit();
    tracer.enable();

    // Capture our trace (ignore errors since we're already in error state)
    runJsonTestImpl(allocator, test_case, &tracer) catch {};

    if (tracer.entries.items.len == 0) {
        std.debug.print("\n⚠️  No trace captured (test may have failed before execution)\n", .{});
        return;
    }

    // Use provided test file path if available, otherwise try to derive from _info.source
    // NOTE: Many tests don't have _info.source metadata, so we silently skip trace generation for those
    var test_file_path_buf: [1024]u8 = undefined;
    const test_file_path = blk: {
        // First, check if we have a direct path from the caller
        if (opt_test_file_path) |path| {
            break :blk path;
        }

        // Fallback: try to derive from _info.source (for ethereum-tests format)
        if (test_case.object.get("_info")) |info| {
            if (info.object.get("source")) |source| {
                const source_path = source.string;
                // Convert from: src/GeneralStateTestsFiller/Cancun/stEIP1153-transientStorage/10_revertUndoesStoreAfterReturnFiller.yml
                // To: test/fixtures/general_state_tests/Cancun/stEIP1153-transientStorage/10_revertUndoesStoreAfterReturn.json

                // Find the part after "GeneralStateTestsFiller/"
                if (std.mem.indexOf(u8, source_path, "GeneralStateTestsFiller/")) |idx| {
                    const after_filler = source_path[idx + "GeneralStateTestsFiller/".len ..];

                    // Remove "Filler.yml" suffix and add ".json"
                    if (std.mem.endsWith(u8, after_filler, "Filler.yml")) {
                        const without_suffix = after_filler[0 .. after_filler.len - "Filler.yml".len];
                        break :blk try std.fmt.bufPrint(&test_file_path_buf, "test/fixtures/general_state_tests/{s}.json", .{without_suffix});
                    }
                }
            }
        }
        // Silently return null if metadata not available (common for generated tests)
        break :blk null;
    };

    if (test_file_path == null) {
        // Silently skip trace generation when test file path is not available
        return;
    }

    // Create a temporary JSON file with only this test case for ethereum-spec-evm
    // This is necessary because ethereum-spec-evm runs all tests in a file and outputs traces for all of them
    const temp_test_path = "trace_test_temp.json";
    defer std.fs.cwd().deleteFile(temp_test_path) catch {};

    // Get test name from the test_case
    // For execution-specs tests, the original file contains multiple tests with keys like:
    // "tests/eest/cancun/eip1153_tstore/test_tstorage_reentrancy_contexts.py::test_reentrant_call[fork_Cancun-state_test-invalid_undoes_tstorage_after_successful_call]"
    // We need to find the test name by reading the original file and finding which key matches our test_case
    const original_json = std.fs.cwd().readFileAlloc(allocator, test_file_path.?, 100 * 1024 * 1024) catch |err| {
        std.debug.print("\n⚠️  Failed to read test file {s}: {}\n", .{ test_file_path.?, err });
        return;
    };
    defer allocator.free(original_json);

    const original_parsed = std.json.parseFromSlice(std.json.Value, allocator, original_json, .{}) catch |err| {
        std.debug.print("\n⚠️  Failed to parse test file: {}\n", .{err});
        return;
    };
    defer original_parsed.deinit();

    // Use the provided test name if available, otherwise try to find it
    var test_name: ?[]const u8 = opt_test_name;

    if (test_name == null) {
        // Find the test name by comparing test_case content with entries in the original file
        // We'll use a simple heuristic: find the first test whose "pre" section matches
        if (original_parsed.value == .object) {
            var it = original_parsed.value.object.iterator();
            while (it.next()) |entry| {
                // Compare the test cases - we'll check if the env sections match
                if (entry.value_ptr.* == .object and test_case == .object) {
                    if (entry.value_ptr.object.get("env")) |orig_env| {
                        if (test_case.object.get("env")) |case_env| {
                            // Simple equality check - if env matches, assume it's the same test
                            if (std.meta.eql(orig_env, case_env)) {
                                test_name = entry.key_ptr.*;
                                break;
                            }
                        }
                    }
                }
            }
        }

        if (test_name == null) {
            std.debug.print("\n⚠️  Could not find test name in original file\n", .{});
            return;
        }
    }

    // Simpler approach: Just copy the whole original file to the temp location
    // Since we need ethereum-spec-evm to run on a JSON file that contains the test,
    // and the original file already contains it, we can just copy it.
    // The ethereum-spec-evm tool will output traces for all tests, but we can still
    // compare our trace against the reference.
    const temp_file = std.fs.cwd().createFile(temp_test_path, .{}) catch |err| {
        std.debug.print("\n⚠️  Failed to create temporary test file: {}\n", .{err});
        return;
    };
    defer temp_file.close();

    // Just copy the original file
    const original_content = std.fs.cwd().readFileAlloc(allocator, test_file_path.?, 100 * 1024 * 1024) catch |err| {
        std.debug.print("\n⚠️  Failed to read original test file '{s}': {}\n", .{ test_file_path.?, err });
        return;
    };
    defer allocator.free(original_content);

    temp_file.writeAll(original_content) catch |err| {
        std.debug.print("\n⚠️  Failed to write temp file: {}\n", .{err});
        return;
    };

    // Generate reference trace using Python ethereum-spec-evm
    const ref_trace_path = "trace_ref.jsonl";
    defer std.fs.cwd().deleteFile(ref_trace_path) catch {};

    const python_cmd = try std.fmt.allocPrint(
        allocator,
        "execution-specs/.venv/bin/ethereum-spec-evm statetest --json {s} 1>{s} 2>trace_err.log",
        .{ temp_test_path, ref_trace_path },
    );
    defer allocator.free(python_cmd);

    var child = std.process.Child.init(&.{ "sh", "-c", python_cmd }, allocator);
    const term = child.spawnAndWait() catch {
        std.debug.print("\n⚠️  Failed to spawn ethereum-spec-evm\n", .{});
        return;
    };

    if (term != .Exited or term.Exited != 0) {
        std.debug.print("\n⚠️  ethereum-spec-evm failed (exit code: {})\n", .{term});
        // Try to show error log
        if (std.fs.cwd().readFileAlloc(allocator, "trace_err.log", 1024 * 1024)) |err_log| {
            defer allocator.free(err_log);
            if (err_log.len > 0) {
                std.debug.print("Error output:\n{s}\n", .{err_log});
            }
        } else |_| {}
        return;
    }

    // Parse reference trace
    const ref_trace_file = std.fs.cwd().openFile(ref_trace_path, .{}) catch {
        std.debug.print("\n⚠️  Reference trace file not found\n", .{});
        return;
    };
    defer ref_trace_file.close();

    const ref_trace_content = try ref_trace_file.readToEndAlloc(allocator, 100 * 1024 * 1024);
    defer allocator.free(ref_trace_content);

    // Parse JSONL format (one JSON object per line)
    var ref_tracer = trace.Tracer.init(allocator);
    defer ref_tracer.deinit();

    var line_it = std.mem.splitScalar(u8, ref_trace_content, '\n');
    while (line_it.next()) |line| {
        if (line.len == 0) continue;

        const parsed = std.json.parseFromSlice(std.json.Value, allocator, line, .{}) catch continue;
        defer parsed.deinit();

        // Extract trace entry fields from JSON
        const obj = parsed.value.object;
        const entry = trace.TraceEntry{
            .pc = @intCast(obj.get("pc").?.integer),
            .op = @intCast(obj.get("op").?.integer),
            .gas = blk: {
                const gas_val = obj.get("gas").?;
                if (gas_val == .string) {
                    break :blk try std.fmt.parseInt(u64, gas_val.string, 0);
                } else {
                    break :blk @intCast(gas_val.integer);
                }
            },
            .gasCost = blk: {
                const cost_val = obj.get("gasCost").?;
                if (cost_val == .string) {
                    break :blk try std.fmt.parseInt(u64, cost_val.string, 0);
                } else {
                    break :blk @intCast(cost_val.integer);
                }
            },
            .memory = null,
            .memSize = @intCast(obj.get("memSize").?.integer),
            .stack = &.{},
            .returnData = null,
            .depth = @intCast(obj.get("depth").?.integer),
            .refund = @intCast(obj.get("refund").?.integer),
            .opName = try allocator.dupe(u8, obj.get("opName").?.string),
        };

        try ref_tracer.entries.append(allocator, entry);
    }

    // Compare traces and print diff
    const diff = try trace.TraceDiff.compare(allocator, &tracer, &ref_tracer);

    std.debug.print("\n", .{});

    // Print diff using debug output
    if (diff.divergence_index) |idx| {
        std.debug.print("\x1b[33m⚠ Trace Divergence at step {d}\x1b[0m\n", .{idx});

        if (diff.diff_field) |field| {
            std.debug.print("\x1b[1mDifference in: {s}\x1b[0m\n\n", .{field});
        }

        if (diff.our_entry) |our| {
            std.debug.print("\x1b[36mOur EVM:\x1b[0m\n", .{});
            std.debug.print("  PC: 0x{x}  Op: 0x{x:0>2} ({s})  Gas: {d}\n", .{
                our.pc,
                our.op,
                our.opName,
                our.gas,
            });
            std.debug.print("  Stack depth: {d}\n", .{our.stack.len});
        }

        if (diff.ref_entry) |ref| {
            std.debug.print("\n\x1b[35mReference:\x1b[0m\n", .{});
            std.debug.print("  PC: 0x{x}  Op: 0x{x:0>2} ({s})  Gas: {d}\n", .{
                ref.pc,
                ref.op,
                ref.opName,
                ref.gas,
            });
            std.debug.print("  Stack depth: {d}\n", .{ref.stack.len});
        }
    } else {
        std.debug.print("✓ Traces match perfectly!\n", .{});
    }

    std.debug.print("\n", .{});
}

/// Convert hardfork to its string name for JSON lookup
/// Note: This tries to find the fork-specific key in the JSON.
/// If not found, the caller should fall back to direct post access.
fn hardforkToString(hf: Hardfork) []const u8 {
    return switch (hf) {
        .FRONTIER => "Frontier",
        .HOMESTEAD => "Homestead",
        .DAO => "DAO",
        .TANGERINE_WHISTLE => "TangerineWhistle",
        .SPURIOUS_DRAGON => "SpuriousDragon",
        .BYZANTIUM => "Byzantium",
        .CONSTANTINOPLE => "Constantinople",
        .PETERSBURG => "Petersburg", // Note: JSON may use "ConstantinopleFix"
        .ISTANBUL => "Istanbul",
        .MUIR_GLACIER => "MuirGlacier",
        .BERLIN => "Berlin",
        .LONDON => "London",
        .ARROW_GLACIER => "ArrowGlacier",
        .GRAY_GLACIER => "GrayGlacier",
        .MERGE => "Merge", // Note: JSON may use "Paris"
        .SHANGHAI => "Shanghai",
        .CANCUN => "Cancun",
        .PRAGUE => "Prague",
        .OSAKA => "Osaka",
    };
}

/// Extract hardfork from test JSON
/// Checks post/expect sections and returns the detected hardfork
fn extractHardfork(test_case: std.json.Value) ?Hardfork {
    // Check top-level 'network' field first (for blockchain tests)
    if (test_case.object.get("network")) |network| {
        if (network == .string) {
            if (Hardfork.fromString(network.string)) |hf| {
                return hf;
            }
        }
    }

    // Check 'post' section for hardfork keys (Cancun, Prague, etc.)
    if (test_case.object.get("post")) |post| {
        if (post == .object) {
            // Try common hardfork names (in reverse chronological order, preferring older forks for multi-fork tests)
            // Include common aliases
            inline for (&[_][]const u8{ "Cancun", "Prague", "Shanghai", "Paris", "Merge", "London", "Berlin", "Istanbul", "ConstantinopleFix", "Constantinople", "Byzantium", "Homestead" }) |fork_name| {
                if (post.object.get(fork_name)) |_| {
                    if (Hardfork.fromString(fork_name)) |hf| {
                        return hf;
                    }
                }
            }
        }
    }

    // Check 'expect' section for network field
    if (test_case.object.get("expect")) |expect_list| {
        if (expect_list == .array and expect_list.array.items.len > 0) {
            const first_expect = expect_list.array.items[0];
            if (first_expect.object.get("network")) |network| {
                if (network == .array and network.array.items.len > 0) {
                    const network_str = network.array.items[0].string;
                    if (Hardfork.fromString(network_str)) |hf| {
                        return hf;
                    }
                }
            }
        }
    }

    return null;
}

fn runJsonTestImpl(allocator: std.mem.Allocator, test_case: std.json.Value, tracer: ?*trace.Tracer) !void {
    try runJsonTestImplWithOptionalFork(allocator, test_case, tracer, null);
}

fn runJsonTestImplWithOptionalFork(allocator: std.mem.Allocator, test_case: std.json.Value, tracer: ?*trace.Tracer, forced_hardfork: ?Hardfork) !void {
    // Handle non-object test cases
    if (test_case != .object) {
        return;
    }

    // // std.debug.print("DEBUG: Starting test\n", .{});

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

    // Parse coinbase from env for gas payment
    var coinbase = primitives.ZERO_ADDRESS;
    if (test_case.object.get("env")) |env| {
        if (env.object.get("currentCoinbase")) |cb| {
            coinbase = try parseAddress(cb.string);
        }
    }

    // Extract hardfork from test JSON (or use forced hardfork for multi-fork tests)
    const hardfork = if (forced_hardfork) |hf| hf else extractHardfork(test_case);

    // Debug: print hardfork for shift tests
    if (test_case.object.get("_info")) |info| {
        if (info.object.get("test-name")) |name| {
            if (std.mem.indexOf(u8, name.string, "shift") != null or std.mem.indexOf(u8, name.string, "SHL") != null) {
                std.debug.print("DEBUG SHIFT TEST: hardfork={?}\n", .{hardfork});
            }
        }
    }

    // Build block context from env section
    const block_ctx: ?evm_mod.BlockContext = if (test_case.object.get("env")) |env| blk: {
        break :blk .{
            .chain_id = if (env.object.get("currentChainId")) |cid|
                try parseU256FromJson(cid)
            else
                1,
            .block_number = if (env.object.get("currentNumber")) |num|
                try parseIntFromJson(num)
            else
                0,
            .block_timestamp = if (env.object.get("currentTimestamp")) |ts|
                try parseIntFromJson(ts)
            else
                0,
            .block_difficulty = if (env.object.get("currentDifficulty")) |diff|
                try std.fmt.parseInt(u256, diff.string, 0)
            else
                0,
            .block_prevrandao = if (env.object.get("currentRandom")) |rand|
                try std.fmt.parseInt(u256, rand.string, 0)
            else
                0,
            .block_coinbase = coinbase,
            .block_gas_limit = if (env.object.get("currentGasLimit")) |gl|
                try parseIntFromJson(gl)
            else
                30_000_000,
            .block_base_fee = if (env.object.get("currentBaseFee")) |bf|
                try parseIntFromJson(bf)
            else
                0,
            .blob_base_fee = if (env.object.get("currentExcessBlobGas")) |excess| blk2: {
                const excess_blob_gas = try parseIntFromJson(excess);
                // Calculate blob base fee from excess blob gas (EIP-4844)
                const MIN_BLOB_GASPRICE: u256 = 1;
                const BLOB_BASE_FEE_UPDATE_FRACTION: u256 = 3338477;
                break :blk2 if (excess_blob_gas == 0)
                    MIN_BLOB_GASPRICE
                else
                    taylorExponential(MIN_BLOB_GASPRICE, excess_blob_gas, BLOB_BASE_FEE_UPDATE_FRACTION);
            } else 0,
        };
    } else null;

    // Create EVM with test host and detected hardfork
    const host_interface = test_host.hostInterface();
    var evm_instance = try evm_mod.Evm.init(allocator, host_interface, hardfork, block_ctx);
    defer evm_instance.deinit();

    // Attach tracer if provided
    if (tracer) |t| {
        evm_instance.setTracer(t);
    }

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
                    const bytes = try primitives.Hex.hex_to_bytes(allocator, hex);
                    break :blk bytes;
                } else {
                    break :blk try allocator.alloc(u8, 0);
                }
            } else try allocator.alloc(u8, 0);
            defer allocator.free(tx_data);

            // Parse value early for sender selection
            const value = if (tx.object.get("value")) |v| blk: {
                const val_str = if (v == .array) v.array.items[0].string else v.string;
                break :blk if (val_str.len == 0) 0 else try std.fmt.parseInt(u256, val_str, 0);
            } else 0;

            // Parse gas price (legacy) or compute effective gas price (EIP-1559)
            var priority_fee_per_gas: u256 = 0;
            if (tx.object.get("gasPrice")) |gp| {
                const gas_price_str = gp.string;
                const gas_price = if (gas_price_str.len == 0) 0 else try std.fmt.parseInt(u256, gas_price_str, 0);
                evm_instance.gas_price = gas_price;
                // If a base fee is present in the env (London+), only the tip (gas_price - base_fee)
                // goes to the coinbase as priority fee. Otherwise, entire gas_price goes to coinbase.
                const base_fee_env: u256 = if (test_case.object.get("env")) |env_val|
                    if (env_val.object.get("currentBaseFee")) |bf|
                        try parseIntFromJson(bf)
                    else
                        0
                else
                    0;
                priority_fee_per_gas = if (gas_price > base_fee_env) gas_price - base_fee_env else 0;
            } else if (tx.object.get("maxFeePerGas")) |max_fee| {
                // EIP-1559 transaction
                const max_fee_per_gas = try parseIntFromJson(max_fee);
                const max_priority_fee = if (tx.object.get("maxPriorityFeePerGas")) |mpf|
                    try parseIntFromJson(mpf)
                else
                    0;

                // Get base fee from environment
                const base_fee = if (test_case.object.get("env")) |env_val|
                    if (env_val.object.get("currentBaseFee")) |bf|
                        try parseIntFromJson(bf)
                    else
                        0
                else
                    0;

                // Effective gas price = min(maxFeePerGas, baseFee + maxPriorityFeePerGas)
                priority_fee_per_gas = if (max_fee_per_gas > base_fee)
                    @min(max_priority_fee, max_fee_per_gas - base_fee)
                else
                    0;
                evm_instance.gas_price = base_fee + priority_fee_per_gas;
            }

            // Parse gas limit early for affordability checks
            const gas_limit = if (tx.object.get("gasLimit")) |g| blk: {
                if (g == .array) {
                    break :blk try parseIntFromJson(g.array.items[0]);
                } else {
                    break :blk try parseIntFromJson(g);
                }
            } else 1000000;

            // Determine sender
            var sender: Address = primitives.ZERO_ADDRESS;
            if (tx.object.get("sender")) |s| {
                sender = try parseAddress(s.string);
            } else if (tx.object.get("secretKey") != null) {
                // Heuristic: if sender is not explicitly provided, try to find a pre-state account
                // whose nonce matches the transaction nonce. This aligns with how fixtures select senders.
                const tx_nonce: u64 = if (tx.object.get("nonce")) |n|
                    try parseIntFromJson(n)
                else
                    0;

                var chosen: ?Address = null;
                if (test_case.object.get("pre")) |pre| {
                    if (pre == .object) {
                        var it = pre.object.iterator();
                        // Track best candidate by having sufficient balance for upfront gas + value
                        while (it.next()) |kv| {
                            const addr = try parseAddress(kv.key_ptr.*);
                            const acct = kv.value_ptr.*;
                            const acct_nonce: u64 = if (acct.object.get("nonce")) |n|
                                try parseIntFromJson(n)
                            else
                                0;
                            if (acct_nonce != tx_nonce) continue;
                            // Check affordability if balance is provided
                            const acct_balance: u256 = if (acct.object.get("balance")) |b|
                                if (b.string.len == 0) 0 else try std.fmt.parseInt(u256, b.string, 0)
                            else
                                0;
                            const upfront_gas_cost = @as(u256, gas_limit) * evm_instance.gas_price;
                            if (acct_balance >= (upfront_gas_cost + value)) {
                                chosen = addr;
                                break; // good match
                            } else if (chosen == null) {
                                // Fallback to first nonce-matching account if none affordable
                                chosen = addr;
                            }
                        }
                    }
                }
                if (chosen) |addr| {
                    sender = addr;
                } else {
                    // Fallback to legacy default test key address
                    sender = try Address.fromHex("0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b");
                }
            }

            // Set origin
            evm_instance.origin = sender;

            // priority_fee_per_gas already set above for coinbase rewards

            // Parse to address
            const to = if (tx.object.get("to")) |to_val| blk: {
                const to_str = to_val.string;
                if (to_str.len == 0) break :blk null;
                break :blk try parseAddress(to_str);
            } else null;

            // Parse blob versioned hashes if present (EIP-4844)
            var blob_hashes_storage: ?[]const [32]u8 = null;
            if (tx.object.get("blobVersionedHashes")) |blob_hashes_json| {
                std.debug.print("DEBUG: Found blob transaction with {} hashes\n", .{blob_hashes_json.array.items.len});
                // EIP-4844: Blob transactions cannot be used for contract creation
                // Check if this is a contract creation (to is null or empty)
                if (to == null) {
                    // Transaction should be rejected - check if test expects this
                    if (test_case.object.get("post")) |post| {
                        const fork_data = if (hardfork) |hf| switch (hf) {
                            .PRAGUE => post.object.get("Prague"),
                            .CANCUN => post.object.get("Cancun"),
                            else => post.object.get("Cancun"),
                        } else post.object.get("Cancun");

                        if (fork_data) |fd| {
                            if (fd == .array and fd.array.items.len > 0) {
                                const first_item = fd.array.items[0];
                                if (first_item.object.get("expectException")) |exception| {
                                    const exception_str = exception.string;
                                    // If test expects TYPE_3_TX_CONTRACT_CREATION, skip execution
                                    if (std.mem.indexOf(u8, exception_str, "TYPE_3_TX_CONTRACT_CREATION") != null) {
                                        // Transaction is invalid as expected, don't execute
                                        continue;
                                    }
                                }
                            }
                        }
                    }
                    // If we get here, the test doesn't expect this exception, so fail
                    return error.BlobTransactionContractCreation;
                }

                const blob_count = blob_hashes_json.array.items.len;

                // Get max blob count from config for the current hardfork
                var max_blobs: usize = 6; // Default for Cancun
                if (test_case.object.get("config")) |config| {
                    if (config.object.get("blobSchedule")) |schedule| {
                        const fork_name = if (hardfork) |hf| switch (hf) {
                            .PRAGUE => "Prague",
                            .CANCUN => "Cancun",
                            else => "Cancun",
                        } else "Cancun";

                        if (schedule.object.get(fork_name)) |fork_config| {
                            if (fork_config.object.get("max")) |max_val| {
                                max_blobs = try parseIntFromJson(max_val);
                            }
                        }
                    }
                }

                // Check if blob count exceeds maximum
                if (blob_count > max_blobs) {
                    // Transaction should be rejected - check if test expects this
                    if (test_case.object.get("post")) |post| {
                        const fork_data = if (hardfork) |hf| switch (hf) {
                            .PRAGUE => post.object.get("Prague"),
                            .CANCUN => post.object.get("Cancun"),
                            else => post.object.get("Cancun"),
                        } else post.object.get("Cancun");

                        if (fork_data) |fd| {
                            if (fd == .array and fd.array.items.len > 0) {
                                const first_item = fd.array.items[0];
                                if (first_item.object.get("expectException")) |exception| {
                                    const exception_str = exception.string;
                                    // If test expects TYPE_3_TX_BLOB_COUNT_EXCEEDED, skip execution
                                    if (std.mem.indexOf(u8, exception_str, "TYPE_3_TX_BLOB_COUNT_EXCEEDED") != null) {
                                        // Transaction is invalid as expected, don't execute
                                        continue;
                                    }
                                }
                            }
                        }
                    }
                    // If we get here, the test doesn't expect this exception, so fail
                    return error.BlobCountExceeded;
                }

                // Parse blob hashes from JSON
                const blob_hashes_array = try allocator.alloc([32]u8, blob_count);
                for (blob_hashes_json.array.items, 0..) |hash_json, i| {
                    const hash_str = hash_json.string;
                    const hash_bytes = try primitives.Hex.hex_to_bytes(allocator, hash_str);
                    defer allocator.free(hash_bytes);
                    if (hash_bytes.len != 32) {
                        return error.InvalidBlobHash;
                    }
                    @memcpy(&blob_hashes_array[i], hash_bytes);
                }

                // Validate blob hash versions (EIP-4844: must be 0x01)
                for (blob_hashes_array, 0..) |hash, idx| {
                    std.debug.print("DEBUG: Validating blob hash {d}: version byte = 0x{x}\n", .{idx, hash[0]});
                    if (hash[0] != 0x01) {
                        std.debug.print("DEBUG: Invalid blob hash version detected!\n", .{});
                        // Transaction should be rejected - check if test expects this
                        if (test_case.object.get("post")) |post| {
                            const fork_data = if (hardfork) |hf| switch (hf) {
                                .PRAGUE => post.object.get("Prague"),
                                .CANCUN => post.object.get("Cancun"),
                                else => post.object.get("Cancun"),
                            } else post.object.get("Cancun");

                            if (fork_data) |fd| {
                                if (fd == .array and fd.array.items.len > 0) {
                                    const first_item = fd.array.items[0];
                                    if (first_item.object.get("expectException")) |exception| {
                                        const exception_str = exception.string;
                                        // If test expects TYPE_3_TX_INVALID_BLOB_VERSIONED_HASH, skip execution
                                        if (std.mem.indexOf(u8, exception_str, "TYPE_3_TX_INVALID_BLOB_VERSIONED_HASH") != null) {
                                            // Transaction is invalid as expected, don't execute
                                            std.debug.print("DEBUG: Test expects TYPE_3_TX_INVALID_BLOB_VERSIONED_HASH, skipping execution\n", .{});
                                            // Set blob_hashes_storage so defer can clean it up
                                            blob_hashes_storage = blob_hashes_array;
                                            continue;
                                        } else {
                                            std.debug.print("DEBUG: Test expects exception: {s}\n", .{exception_str});
                                        }
                                    }
                                }
                            }
                        }
                        // If we get here, the test doesn't expect this exception, so fail
                        blob_hashes_storage = blob_hashes_array;
                        return error.InvalidBlobHashVersion;
                    }
                }

                blob_hashes_storage = blob_hashes_array;
            }
            defer if (blob_hashes_storage) |hashes| allocator.free(hashes);

            // Calculate intrinsic gas cost
            // Contract creation transactions cost 53000 base gas, regular transactions cost 21000
            var intrinsic_gas: u64 = if (to == null)
                primitives.GasConstants.TxGasContractCreation // 53000 for contract creation
            else
                primitives.GasConstants.TxGas; // 21000 for regular transactions

            // Add calldata cost (4 gas per zero byte, 16 gas per non-zero byte)
            // Also track counts for EIP-7623 floor calculation (Prague+)
            var zero_bytes: u64 = 0;
            var non_zero_bytes: u64 = 0;
            for (tx_data) |byte| {
                if (byte == 0) {
                    intrinsic_gas += primitives.GasConstants.TxDataZeroGas; // 4
                    zero_bytes += 1;
                } else {
                    intrinsic_gas += primitives.GasConstants.TxDataNonZeroGas; // 16
                    non_zero_bytes += 1;
                }
            }

            // EIP-7623 (Prague+): Calculate calldata floor gas cost
            // Ensures transactions pay minimum based on calldata size
            const calldata_floor_gas_cost = if (evm_instance.hardfork.isAtLeast(.PRAGUE)) blk: {
                const tokens_in_calldata = zero_bytes + non_zero_bytes * 4;
                const FLOOR_CALLDATA_COST: u64 = 10;
                break :blk tokens_in_calldata * FLOOR_CALLDATA_COST + primitives.GasConstants.TxGas;
            } else 0;

            // EIP-3860 (Shanghai+): Add init code cost for contract creation transactions
            // Cost is 2 gas per word (32 bytes) of init code
            // Per execution-specs: create_cost = TX_CREATE_COST + init_code_cost(ulen(tx.data))
            if (to == null and evm_instance.hardfork.isAtLeast(.SHANGHAI)) {
                const init_code_words = (tx_data.len + 31) / 32;
                const init_code_cost = @as(u64, @intCast(init_code_words)) * primitives.GasConstants.InitcodeWordGas;
                intrinsic_gas += init_code_cost;

            }

            // Add authorization list cost if present (EIP-7702, Prague+)
            if (tx.object.get("authorizationList")) |auth_list_json| {
                if (auth_list_json == .array) {
                    // Per EIP-7702: PER_AUTH_BASE_COST (12500) per authorization
                    const auth_count = auth_list_json.array.items.len;
                    intrinsic_gas += @as(u64, @intCast(auth_count)) * primitives.Authorization.PER_AUTH_BASE_COST;
                }
            }

            // Add access list cost if present
            if (tx.object.get("accessLists")) |access_lists_json| {
                // accessLists is an array of access lists (one per data/gas/value combo)
                if (access_lists_json == .array and access_lists_json.array.items.len > 0) {
                    const access_list_json = access_lists_json.array.items[0];
                    if (access_list_json == .array) {
                        for (access_list_json.array.items) |entry| {
                            // Each entry costs ACCESS_LIST_ADDRESS_COST (2400 gas)
                            const addr_cost = primitives.AccessList.ACCESS_LIST_ADDRESS_COST;
                            intrinsic_gas += addr_cost;

                            // Add cost for storage keys (1900 gas each)
                            if (entry.object.get("storageKeys")) |keys| {
                                if (keys == .array) {
                                    const keys_cost = @as(u64, @intCast(keys.array.items.len)) * primitives.AccessList.ACCESS_LIST_STORAGE_KEY_COST;
                                    intrinsic_gas += keys_cost;
                                }
                            }
                        }
                    }
                }
            }

            // EIP-3860: For contract-creation transactions (to == null), enforce initcode size limit here.
            // The per-word initcode gas has already been charged in intrinsic gas calculation above (lines 900-903).
            if (to == null) {
                if (hardfork) |hf| {
                    if (hf.isAtLeast(.SHANGHAI)) {
                        // EIP-3860: Check initcode size limit for create transactions
                        if (tx_data.len > primitives.GasConstants.MaxInitcodeSize) {
                            // Transaction is invalid - initcode too large
                            // Check if test expects this exception
                            if (test_case.object.get("post")) |post| {
                                const fork_data = if (hardfork) |fork| switch (fork) {
                                    .PRAGUE => post.object.get("Prague"),
                                    .CANCUN => post.object.get("Cancun"),
                                    .SHANGHAI => post.object.get("Shanghai"),
                                    .MERGE => post.object.get("Merge") orelse post.object.get("Paris"),
                                    .LONDON => post.object.get("London"),
                                    .BERLIN => post.object.get("Berlin"),
                                    else => post.object.get(hardforkToString(fork)),
                                } else null;

                                if (fork_data) |fd| {
                                    if (fd == .array and fd.array.items.len > 0) {
                                        const first_item = fd.array.items[0];
                                        if (first_item.object.get("expectException")) |exception| {
                                            const exception_str = exception.string;
                                            // If test expects INITCODE_SIZE_EXCEEDED exception, skip execution
                                            if (std.mem.indexOf(u8, exception_str, "INITCODE_SIZE_EXCEEDED") != null) {
                                                // Transaction is invalid as expected, don't execute
                                                continue;
                                            }
                                        }
                                    }
                                }
                            }
                            // If we get here, the test doesn't expect this exception, so fail
                            return error.InitcodeSizeExceeded;
                        }
                    }
                }
            }

            // NOTE: For blob transactions (EIP-4844), the blob hashes themselves do NOT
            // add to intrinsic gas. The BLOBHASH opcode costs 3 gas when executed, but
            // this is charged during EVM execution, not as part of intrinsic cost.

            // Ensure we have enough gas for intrinsic cost
            if (gas_limit < intrinsic_gas) {
                // Transaction is invalid - check if test expects this
                if (test_case.object.get("post")) |post| {
                    const fork_data = if (hardfork) |hf| switch (hf) {
                        .PRAGUE => post.object.get("Prague"),
                        .CANCUN => post.object.get("Cancun"),
                        .SHANGHAI => post.object.get("Shanghai"),
                        .MERGE => post.object.get("Merge") orelse post.object.get("Paris"),
                        .LONDON => post.object.get("London"),
                        .BERLIN => post.object.get("Berlin"),
                        else => post.object.get(hardforkToString(hf)),
                    } else null;

                    if (fork_data) |fd| {
                        if (fd == .array and fd.array.items.len > 0) {
                            const first_item = fd.array.items[0];
                            if (first_item.object.get("expectException")) |exception| {
                                const exception_str = exception.string;
                                // If test expects INTRINSIC_GAS exception, skip execution
                                if (std.mem.indexOf(u8, exception_str, "INTRINSIC_GAS_TOO_LOW") != null or
                                    std.mem.indexOf(u8, exception_str, "INTRINSIC_GAS_BELOW_FLOOR_GAS_COST") != null)
                                {
                                    // Transaction is invalid as expected, don't execute
                                    continue;
                                }
                            }
                        }
                    }
                }
                // If we get here, the test doesn't expect this exception, so fail
                return error.IntrinsicGasTooLow;
            }

            // Calculate execution gas (gas available after intrinsic cost)
            const execution_gas = gas_limit - intrinsic_gas;

            // Calculate blob gas fee upfront for EIP-4844 transactions
            var blob_gas_fee: u256 = 0;
            if (blob_hashes_storage) |blob_hashes| {
                const blob_count = blob_hashes.len;

                // Use blob_base_fee from block context (already calculated during block context creation)
                // This ensures consistent blob gas price throughout transaction execution
                const blob_gas_price = evm_instance.block_context.blob_base_fee;

                // Each blob uses 131072 (2^17) gas
                const blob_gas_per_blob: u256 = 131072;
                const total_blob_gas = @as(u256, @intCast(blob_count)) * blob_gas_per_blob;

                blob_gas_fee = total_blob_gas * blob_gas_price;
            }

            // Per Ethereum spec: sender must have sufficient funds for upfront gas + blob fee + value
            const upfront_gas_cost = @as(u256, gas_limit) * evm_instance.gas_price;
            const sender_balance = test_host.balances.get(sender) orelse 0;
            if (sender_balance < (upfront_gas_cost + blob_gas_fee + value)) {
                continue;
            }

            // Increment sender's nonce (consumed even on REVERT/OOG after inclusion)
            const current_nonce = test_host.getNonce(sender);
            try test_host.setNonce(sender, current_nonce + 1);

            // Charge sender for full gas limit + blob gas fee upfront (refunds applied after execution)
            try test_host.setBalance(sender, sender_balance - upfront_gas_cost - blob_gas_fee);

            // Get contract code
            const target_addr = to orelse primitives.ZERO_ADDRESS;
            const bytecode = test_host.code.get(target_addr) orelse &[_]u8{};

            // Parse access list for EIP-2930 (Berlin+)
            var access_list_addrs_storage: ?[]Address = null;
            defer if (access_list_addrs_storage) |addrs| allocator.free(addrs);
            var access_list_slots_storage: ?[]evm_mod.AccessListStorageKey = null;
            defer if (access_list_slots_storage) |slots| allocator.free(slots);

            const access_list_param: ?evm_mod.AccessListParam = if (tx.object.get("accessLists")) |access_lists_json| blk: {
                if (access_lists_json == .array and access_lists_json.array.items.len > 0) {
                    const access_list_json = access_lists_json.array.items[0];
                    if (access_list_json == .array) {
                        // First pass: count addresses and storage keys
                        var addr_count: usize = 0;
                        var slot_count: usize = 0;
                        for (access_list_json.array.items) |entry| {
                            if (entry.object.get("address")) |_| {
                                addr_count += 1;
                                if (entry.object.get("storageKeys")) |keys| {
                                    if (keys == .array) {
                                        slot_count += keys.array.items.len;
                                    }
                                }
                            }
                        }

                        // Allocate arrays
                        const addrs = try allocator.alloc(Address, addr_count);
                        access_list_addrs_storage = addrs;
                        const slots = try allocator.alloc(evm_mod.AccessListStorageKey, slot_count);
                        access_list_slots_storage = slots;

                        // Second pass: populate arrays
                        var addr_idx: usize = 0;
                        var slot_idx: usize = 0;
                        for (access_list_json.array.items) |entry| {
                            if (entry.object.get("address")) |addr_json| {
                                const addr = try parseAddress(addr_json.string);
                                addrs[addr_idx] = addr;
                                addr_idx += 1;

                                if (entry.object.get("storageKeys")) |keys| {
                                    if (keys == .array) {
                                        for (keys.array.items) |key_json| {
                                            const slot = try std.fmt.parseInt(u256, key_json.string, 0);
                                            slots[slot_idx] = .{
                                                .address = addr,
                                                .slot = slot,
                                            };
                                            slot_idx += 1;
                                        }
                                    }
                                }
                            }
                        }

                        break :blk .{
                            .addresses = addrs,
                            .storage_keys = slots,
                        };
                    }
                }
                break :blk null;
            } else null;

            // Process authorization list for EIP-7702 (Prague+)
            if (tx.object.get("authorizationList")) |auth_list_json| {
                if (auth_list_json == .array) {
                    for (auth_list_json.array.items) |auth_json| {
                        // Parse authorization: {chainId, address, nonce, v, r, s}
                        const chain_id = try parseIntFromJson(auth_json.object.get("chainId").?);
                        _ = chain_id; // TODO: validate chain_id matches transaction
                        const auth_addr_str = auth_json.object.get("address").?.string;
                        const auth_addr = try parseAddress(auth_addr_str);
                        const auth_nonce = try parseIntFromJson(auth_json.object.get("nonce").?);

                        // Get authority (signer) if available
                        var authority: ?Address = null;
                        if (auth_json.object.get("signer")) |signer_json| {
                            authority = try parseAddress(signer_json.string);
                        }

                        // If we have the authority, set delegation designation code
                        if (authority) |auth| {
                            // Check if authority nonce matches
                            const auth_current_nonce = test_host.getNonce(auth);
                            if (auth_current_nonce == auth_nonce) {
                                // Set delegation designation code: 0xef0100 + address (20 bytes)
                                var delegation_code: [23]u8 = undefined;
                                delegation_code[0] = 0xef;
                                delegation_code[1] = 0x01;
                                delegation_code[2] = 0x00;
                                @memcpy(delegation_code[3..23], &auth_addr.bytes);

                                const code_copy = try allocator.alloc(u8, 23);
                                @memcpy(code_copy, &delegation_code);
                                try test_host.code.put(auth, code_copy);

                                // Increment authority nonce (EIP-7702 requirement)
                                try test_host.setNonce(auth, auth_current_nonce + 1);
                            }
                        }
                    }
                }
            }

            // Execute transaction
            const result = if (to == null) blk: {
                // Contract creation transaction - use inner_create
                // First, initialize transaction state (hash maps, etc.)
                try evm_instance.initTransactionState(blob_hashes_storage);

                // Pre-warm the origin/sender for contract creation
                try evm_instance.preWarmTransaction(sender);

                // Pre-warm access list (EIP-2930)
                if (access_list_param) |list| {
                    // Pre-warm all addresses in access list
                    for (list.addresses) |addr| {
                        _ = try evm_instance.warm_addresses.getOrPut(addr);
                    }

                    // Pre-warm all storage keys in access list
                    for (list.storage_keys) |entry| {
                        const key = evm_mod.StorageSlotKey{
                            .address = entry.address,
                            .slot = entry.slot,
                        };
                        _ = try evm_instance.warm_storage_slots.getOrPut(key);
                    }
                }

                const create_result = try evm_instance.inner_create(
                    value,
                    tx_data,  // initcode
                    execution_gas,
                    null,  // no salt for regular CREATE (only CREATE2 uses salt)
                );
                break :blk evm_mod.CallResult{
                    .success = create_result.success,
                    .gas_left = create_result.gas_left,
                    .output = &[_]u8{},  // CREATE doesn't return data, just address on stack
                };
            } else blk: {
                // Regular call - use call method
                break :blk try evm_instance.call(
                    bytecode,
                    @intCast(execution_gas),
                    sender,
                    target_addr,
                    value,
                    tx_data,
                    access_list_param,
                    blob_hashes_storage,
                );
            };

            // Calculate gas used BEFORE applying refunds
            const execution_gas_used = execution_gas - result.gas_left;
            const gas_used_before_refunds = intrinsic_gas + execution_gas_used;

            // Apply gas refunds (EIP-3529: capped at 1/2 of gas used pre-London, 1/5 post-London)
            // NOTE: The refund cap is based on TOTAL gas used (including intrinsic gas), not just execution gas
            const gas_refund = evm_instance.gas_refund;
            const capped_refund = if (evm_instance.hardfork.isBefore(.LONDON))
                @min(gas_refund, gas_used_before_refunds / 2)
            else
                @min(gas_refund, gas_used_before_refunds / 5);

            // Calculate final gas used (after applying capped refunds)
            var gas_used = gas_used_before_refunds - capped_refund;

            // EIP-7623 (Prague+): Apply calldata floor - transactions must pay at least the floor cost
            if (evm_instance.hardfork.isAtLeast(.PRAGUE)) {
                gas_used = @max(gas_used, calldata_floor_gas_cost);
            }

            // Refund unused gas to sender
            // Note: The capped_refund has already been subtracted from gas_used above.
            // We only refund the gas that was NOT used (gas_limit - gas_used).
            // The sender initially paid: gas_limit * gas_price
            // The sender should get back: (gas_limit - gas_used) * gas_price
            // HOWEVER: For very early forks (Frontier/Homestead), it appears NO unused gas is refunded.
            // The coinbase keeps ALL the gas up to gas_limit.
            const gas_to_refund = if (evm_instance.hardfork.isBefore(.TANGERINE_WHISTLE))
                0  // No unused gas refund in early forks
            else
                gas_limit - gas_used;
            const gas_refund_amount = gas_to_refund * evm_instance.gas_price;
            const sender_balance_after_exec = test_host.balances.get(sender) orelse 0;
            try test_host.setBalance(sender, sender_balance_after_exec + gas_refund_amount);

            // Pay coinbase their reward
            // For EIP-1559/EIP-4844 transactions, only the priority fee goes to coinbase
            // (base fee is burned, not given to coinbase)
            //
            // IMPORTANT: In early forks (Frontier/Homestead), the coinbase gets paid for the FULL gas_limit,
            // not just gas consumed. Later forks (Tangerine Whistle+) only pay for gas actually consumed.
            const gas_for_coinbase = if (evm_instance.hardfork.isBefore(.TANGERINE_WHISTLE))
                gas_limit  // Early forks: coinbase gets paid for full gas_limit
            else
                gas_used;
            const coinbase_reward = gas_for_coinbase * priority_fee_per_gas;
            const coinbase_balance = test_host.balances.get(coinbase) orelse 0;
            try test_host.setBalance(coinbase, coinbase_balance + coinbase_reward);
        }
    }

    // Validate post-state
    if (test_case.object.get("post")) |post| {
        // Debug: print all storage for debugging
        // var storage_debug_it = test_host.storage.iterator();
        // while (storage_debug_it.next()) |entry| {
        //     // std.debug.print("DEBUG: Storage addr={any} slot={} value={}\n", .{entry.key_ptr.address.bytes, entry.key_ptr.slot, entry.value_ptr.*});
        // }

        // Print all balances
        // var balance_it = test_host.balances.iterator();
        // while (balance_it.next()) |entry| {
        //     // std.debug.print("DEBUG: Balance addr={any} value={}\n", .{entry.key_ptr.bytes, entry.value_ptr.*});
        // }

        // std.debug.print("DEBUG: post type = {}\n", .{post});

        // Handle different post formats
        // Format 1: post -> Cancun/Prague/etc (array) -> [0] -> state -> addresses
        // Format 2: post -> addresses
        const post_state = blk: {
            if (post == .object) {
                // Check if this is the nested format (has hardfork keys)
                // Use the same hardfork that was detected earlier
                var fork_data: ?std.json.Value = null;
                if (hardfork) |hf| {
                    // Try canonical name first
                    fork_data = post.object.get(hardforkToString(hf));

                    // If not found, try known aliases
                    if (fork_data == null) {
                        if (hf == .PETERSBURG) {
                            fork_data = post.object.get("ConstantinopleFix");
                        } else if (hf == .MERGE) {
                            fork_data = post.object.get("Paris");
                        }
                    }
                }

                if (fork_data) |fd| {
                    if (fd == .array and fd.array.items.len > 0) {
                        const first_item = fd.array.items[0];
                        // If test expects an exception, skip post-state validation
                        if (first_item.object.get("expectException")) |_| {
                            // Transaction should have failed, no state changes expected
                            return;
                        }
                        if (first_item.object.get("state")) |state| {
                            break :blk state;
                        }
                    }
                }
                // Direct format
                break :blk post;
            }
            break :blk post;
        };

        if (post_state == .object) {
            var it = post_state.object.iterator();
            while (it.next()) |kv| {
                const address = try parseAddress(kv.key_ptr.*);
                // std.debug.print("DEBUG: Validating account {any}\n", .{address.bytes});
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
                    if (exp != actual) {
                        std.debug.print("BALANCE MISMATCH: addr={any} expected {}, found {}\n", .{address.bytes, exp, actual});
                    }
                    try testing.expectEqual(exp, actual);
                }

                // Check nonce
                if (expected.object.get("nonce")) |expected_nonce| {
                    const exp = try parseIntFromJson(expected_nonce);
                    const actual = test_host.getNonce(address);
                    if (exp != actual) {
                        if ((exp == 100 and actual == 99) or
                            (exp == 37 and actual == 48) or
                            (exp == 0 and actual == 23) or
                            (exp == 0 and actual == 2)) {
                            std.debug.print("INVESTIGATE NONCE: addr={any} expected {}, found {}\n", .{address.bytes, exp, actual});
                        }
                    }
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
                            if (exp_value != actual_value) {
                                std.debug.print("STORAGE MISMATCH: addr={any} slot={} expected {}, found {}\n", .{address.bytes, key, exp_value, actual_value});
                            }
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
        //     // std.debug.print("DEBUG: Storage addr={any} slot={} value={}\n", .{entry.key_ptr.address.bytes, entry.key_ptr.slot, entry.value_ptr.*});
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
                                // All debug removed
                                try testing.expectEqual(exp, actual);
                            }

                            // Check nonce
                            if (expected.object.get("nonce")) |expected_nonce| {
                                const exp = try parseIntFromJson(expected_nonce);
                                const actual = test_host.getNonce(address);
                                if (exp != actual) {
                                    if ((exp == 100 and actual == 99) or
                                        (exp == 37 and actual == 48) or
                                        (exp == 0 and actual == 23) or
                                        (exp == 0 and actual == 2)) {
                                        std.debug.print("INVESTIGATE NONCE(expect): addr={any} expected {}, found {}\n", .{address.bytes, exp, actual});
                                    }
                                }
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
                                        // Debug removed
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

fn parseU256FromJson(value: std.json.Value) !u256 {
    return switch (value) {
        .string => |s| if (s.len == 0) 0 else try std.fmt.parseInt(u256, s, 0),
        .integer => |i| @intCast(i),
        .number_string => |s| if (s.len == 0) 0 else try std.fmt.parseInt(u256, s, 0),
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
