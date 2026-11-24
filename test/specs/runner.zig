const std = @import("std");
const testing = std.testing;
const evm_mod = @import("evm");
const primitives = @import("voltaire");
const client_blockchain = @import("client_blockchain");
const Address = primitives.Address.Address;
const BlockHeader = primitives.BlockHeader;
const Hash = primitives.Hash;
const test_host_mod = @import("test_host.zig");
const TestHost = test_host_mod.TestHost;
const StorageSlotKey = test_host_mod.StorageSlotKey;
const assembler = @import("assembler.zig");
const trace = @import("evm").trace;
const Hardfork = evm_mod.Hardfork;

// Error type for tests that are not yet implemented
pub const TestTodo = error.TestTodo;

// Configuration for test filtering
// Engine API format tests are consensus-layer tests (block validation, Engine API payloads)
// and are not core EVM execution tests. They're disabled by default but can be enabled
// via the INCLUDE_ENGINE_TESTS environment variable for comprehensive testing.
pub const Config = struct {
    include_engine_tests: bool,

    pub fn fromEnv() Config {
        const include_engine = std.process.hasEnvVarConstant("INCLUDE_ENGINE_TESTS");
        return .{ .include_engine_tests = include_engine };
    }
};

fn extractHeaderJson(value: std.json.Value) ?std.json.Value {
    if (value != .object) return null;
    if (value.object.get("blockHeader")) |header| return header;
    if (value.object.get("rlp_decoded")) |decoded| {
        if (decoded.object.get("blockHeader")) |header| return header;
    }
    if (value.object.get("parentHash") != null or value.object.get("number") != null) {
        return value;
    }
    return null;
}

fn fillHeaderFromJson(
    allocator: std.mem.Allocator,
    header_json: std.json.Value,
    header: *BlockHeader.BlockHeader,
) !?[]u8 {
    if (header_json.object.get("difficulty")) |diff| {
        header.difficulty = try parseU256FromJson(diff);
    }
    if (header_json.object.get("nonce")) |nonce| {
        header.nonce = try parseFixedHexBytes(BlockHeader.NONCE_SIZE, allocator, nonce);
    }
    if (header_json.object.get("uncleHash")) |uncle_hash| {
        header.ommers_hash = try parseFixedHexBytes(Hash.SIZE, allocator, uncle_hash);
    } else if (header_json.object.get("ommersHash")) |ommers_hash| {
        header.ommers_hash = try parseFixedHexBytes(Hash.SIZE, allocator, ommers_hash);
    }
    if (header_json.object.get("mixHash")) |mix_hash| {
        header.mix_hash = try parseFixedHexBytes(Hash.SIZE, allocator, mix_hash);
    }
    if (header_json.object.get("gasLimit")) |gas_limit| {
        header.gas_limit = try parseIntFromJson(gas_limit);
    }
    if (header_json.object.get("gasUsed")) |gas_used| {
        header.gas_used = try parseIntFromJson(gas_used);
    }
    if (header_json.object.get("timestamp")) |timestamp| {
        header.timestamp = try parseIntFromJson(timestamp);
    }
    if (header_json.object.get("number")) |number| {
        header.number = try parseIntFromJson(number);
    }
    if (header_json.object.get("baseFeePerGas")) |base_fee| {
        header.base_fee_per_gas = try parseU256FromJson(base_fee);
    }
    if (header_json.object.get("parentHash")) |parent_hash| {
        header.parent_hash = try parseFixedHexBytes(Hash.SIZE, allocator, parent_hash);
    }
    if (header_json.object.get("extraData")) |extra| {
        if (extra == .string) {
            const extra_bytes = try primitives.Hex.hexToBytes(allocator, extra.string);
            header.extra_data = extra_bytes;
            return extra_bytes;
        }
    }
    return null;
}

fn validateBlockHeaderConstants(
    allocator: std.mem.Allocator,
    hardfork: Hardfork,
    block: std.json.Value,
    parent_block: ?std.json.Value,
) !void {
    const header_json = extractHeaderJson(block) orelse return;

    var header = BlockHeader.init();
    const header_extra = try fillHeaderFromJson(allocator, header_json, &header);
    defer if (header_extra) |extra| allocator.free(extra);

    var parent_header_storage = BlockHeader.init();
    var parent_header: ?*const BlockHeader.BlockHeader = null;
    var parent_extra: ?[]u8 = null;
    if (parent_block) |parent| {
        if (extractHeaderJson(parent)) |parent_json| {
            parent_extra = try fillHeaderFromJson(allocator, parent_json, &parent_header_storage);
            parent_header = &parent_header_storage;
        }
    }
    defer if (parent_extra) |extra| allocator.free(extra);

    const PreMergeValidator = struct {
        pub fn validate(
            _: *const BlockHeader.BlockHeader,
            _: client_blockchain.HeaderValidationContext,
        ) client_blockchain.ValidationError!void {
            return;
        }
    };
    const MergeValidator = client_blockchain.merge_header_validator(PreMergeValidator);
    const ctx = client_blockchain.HeaderValidationContext{
        .allocator = allocator,
        .hardfork = hardfork,
        .parent_header = parent_header,
    };
    try MergeValidator.validate(&header, ctx);
}

/// EIP-4844 `fake_exponential`: integer approximation of
/// factor * e^(numerator / denominator).
/// EELS uses unbounded integers; a result that does not fit in u256
/// saturates to maxInt(u256) instead of returning a truncated partial sum.
fn taylorExponential(factor: u256, numerator: u256, denominator: u256) u256 {
    const max = std.math.maxInt(u256);
    var i: u256 = 1;
    var output: u256 = 0;
    var numerator_accumulated: u256 = std.math.mul(u256, factor, denominator) catch return max;

    while (numerator_accumulated > 0) {
        output = std.math.add(u256, output, numerator_accumulated) catch return max;
        const temp = std.math.mul(u256, numerator_accumulated, numerator) catch return max;
        const divisor = std.math.mul(u256, denominator, i) catch return max;
        numerator_accumulated = temp / divisor;
        i += 1;
    }

    return output / denominator;
}

/// EIP-4844 (Cancun) and EIP-7691 (Prague, Osaka) blob base fee update fraction.
fn blobBaseFeeUpdateFraction(hf: ?Hardfork) u256 {
    const fork = hf orelse return 3_338_477;
    return if (fork.isAtLeast(.PRAGUE)) 5_007_716 else 3_338_477;
}

/// Blob base fee for `excess_blob_gas` under `hf` (MIN_BASE_FEE_PER_BLOB_GAS = 1).
fn blobBaseFee(hf: ?Hardfork, excess_blob_gas: u64) u256 {
    return taylorExponential(1, excess_blob_gas, blobBaseFeeUpdateFraction(hf));
}

/// Gas settlement for one transaction, following EELS `process_transaction`.
const TxGasSettlement = struct {
    /// Gas charged to the sender after refunds and the EIP-7623 floor.
    gas_used: u64,
    /// Gas returned to the sender: gas_limit - gas_used.
    unused_gas: u64,
};

/// Settles gas for a transaction. `refund_counter` is the non-negative refund
/// counter; it is capped at 1/2 (pre-London) or 1/5 (London+) of gas used.
/// Every fork, Frontier included, returns unused gas to the sender. From
/// Prague, EIP-7623 raises gas_used to at least `calldata_floor`. gas_used
/// never exceeds gas_limit, so unused_gas cannot underflow.
fn settleTxGas(hf: Hardfork, gas_limit: u64, gas_used_before_refunds: u64, refund_counter: u64, calldata_floor: u64) TxGasSettlement {
    const refund_quotient: u64 = if (hf.isBefore(.LONDON)) 2 else 5;
    const capped_refund = @min(refund_counter, gas_used_before_refunds / refund_quotient);
    var gas_used = gas_used_before_refunds - capped_refund;
    if (hf.isAtLeast(.PRAGUE)) gas_used = @max(gas_used, calldata_floor);
    gas_used = @min(gas_used, gas_limit);
    return .{ .gas_used = gas_used, .unused_gas = gas_limit - gas_used };
}

/// EIP-7623: a transaction is valid only if gas_limit covers both the
/// intrinsic cost and the calldata floor (`floor` is 0 before Prague).
fn txGasLimitTooLow(gas_limit: u64, intrinsic_gas: u64, calldata_floor: u64) bool {
    return gas_limit < @max(intrinsic_gas, calldata_floor);
}

/// A state fixture that names `expectException` passes only if the runner
/// rejected at least one transaction. Otherwise the invalid transaction was
/// accepted and the fixture must fail.
fn checkExpectedException(expects_exception: bool, rejected_tx_count: usize) error{ExpectedExceptionNotRaised}!void {
    if (expects_exception and rejected_tx_count == 0) return error.ExpectedExceptionNotRaised;
}

/// EIP-7702 delegation designator prefix.
const DELEGATION_PREFIX = [3]u8{ 0xef, 0x01, 0x00 };

fn isDelegationDesignator(code: []const u8) bool {
    return code.len == 23 and std.mem.eql(u8, code[0..3], &DELEGATION_PREFIX);
}

/// Replaces `address`'s code in the test host, freeing the previous code.
/// Empty `code` removes the entry.
fn replaceHostCode(host: *TestHost, address: Address, code: []const u8) !void {
    if (host.code.fetchRemove(address)) |old| host.allocator.free(old.value);
    if (code.len == 0) return;
    const owned = try host.allocator.dupe(u8, code);
    errdefer host.allocator.free(owned);
    try host.code.put(address, owned);
}

/// EELS `account_exists` over the test host: any balance, nonce, code or storage.
fn hostAccountExists(host: *TestHost, address: Address) bool {
    if ((host.balances.get(address) orelse 0) != 0) return true;
    if (host.getNonce(address) != 0) return true;
    if ((host.code.get(address) orelse &[_]u8{}).len != 0) return true;
    var it = host.storage.keyIterator();
    while (it.next()) |key| {
        if (key.address.equals(address)) return true;
    }
    return false;
}

/// One EIP-7702 authorization tuple after signature recovery.
/// `authority` is null when the signature does not recover.
const AuthorizationTuple = struct {
    chain_id: u256,
    address: Address,
    nonce: u256,
    authority: ?Address,
};

const AuthorizationOutcome = enum {
    /// Invalid tuple: no state change.
    skipped,
    /// Delegation written to an account that did not exist.
    applied_to_new_account,
    /// Delegation written to an existing account (refund 25000 - 12500).
    applied_to_existing_account,
};

/// Applies one authorization following EELS `set_delegation` (EIP-7702):
/// chain id 0 or tx chain, nonce < 2^64 - 1, recoverable authority whose code
/// is empty or already a delegation, matching nonce. A zero target address
/// clears the delegation. The authority nonce is incremented.
fn applyAuthorization(host: *TestHost, tx_chain_id: u256, auth: AuthorizationTuple) !AuthorizationOutcome {
    if (!authorizationChainIdValid(auth.chain_id, tx_chain_id)) return .skipped;
    if (auth.nonce >= std.math.maxInt(u64)) return .skipped;
    const authority = auth.authority orelse return .skipped;

    const authority_code = host.code.get(authority) orelse &[_]u8{};
    if (authority_code.len != 0 and !isDelegationDesignator(authority_code)) return .skipped;

    const authority_nonce = host.getNonce(authority);
    if (authority_nonce != auth.nonce) return .skipped;

    const existed = hostAccountExists(host, authority);

    if (auth.address.isZero()) {
        try replaceHostCode(host, authority, &.{});
    } else {
        var designator: [23]u8 = undefined;
        @memcpy(designator[0..3], &DELEGATION_PREFIX);
        @memcpy(designator[3..23], &auth.address.bytes);
        try replaceHostCode(host, authority, &designator);
    }
    try host.setNonce(authority, authority_nonce + 1);

    return if (existed) .applied_to_existing_account else .applied_to_new_account;
}

/// secp256k1 group order.
const SECP256K1N: u256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;

/// Recovers an EIP-7702 authority from the tuple's signature. Returns null on
/// any invalid signature (y_parity > 1, r or s out of range, high s, or no
/// recovery), which makes EELS skip the tuple.
fn recoverAuthority(chain_id: u256, address: Address, nonce: u256, y_parity: u256, r: u256, s: u256) ?Address {
    if (y_parity > 1) return null;
    if (r == 0 or r >= SECP256K1N) return null;
    if (s == 0 or s > SECP256K1N / 2) return null;
    // Voltaire's signing hash takes u64 fields; larger values cannot match a
    // valid tuple here (chain id and nonce are range-checked by the caller).
    const chain_id_u64 = std.math.cast(u64, chain_id) orelse return null;
    const nonce_u64 = std.math.cast(u64, nonce) orelse return null;
    var auth = primitives.Authorization.Authorization{
        .chain_id = chain_id_u64,
        .address = address,
        .nonce = nonce_u64,
        .v = @intCast(y_parity),
        .r = undefined,
        .s = undefined,
    };
    std.mem.writeInt(u256, &auth.r, r, .big);
    std.mem.writeInt(u256, &auth.s, s, .big);
    return auth.authority() catch null;
}

// Run a single test case from JSON
pub fn runJsonTest(allocator: std.mem.Allocator, test_case: std.json.Value) !void {
    return runJsonTestWithPath(allocator, test_case, null);
}

pub fn runJsonTestWithPath(allocator: std.mem.Allocator, test_case: std.json.Value, test_file_path: ?[]const u8) !void {
    return runJsonTestWithPathAndName(allocator, test_case, test_file_path, null);
}

pub fn runJsonTestWithPathAndName(allocator: std.mem.Allocator, test_case: std.json.Value, test_file_path: ?[]const u8, test_name: ?[]const u8) !void {
    // Load configuration
    const config = Config.fromEnv();

    // Check if this is an Engine API format test (blockchain_test_engine)
    const is_engine_test = blk: {
        // Check for engineNewPayloads field (primary indicator)
        if (test_case.object.get("engineNewPayloads")) |_| {
            break :blk true;
        }
        // Also check test name/path for "blockchain_test_engine"
        if (test_name) |name| {
            if (std.mem.indexOf(u8, name, "blockchain_test_engine") != null) {
                break :blk true;
            }
        }
        if (test_file_path) |path| {
            if (std.mem.indexOf(u8, path, "blockchain_test_engine") != null) {
                break :blk true;
            }
        }
        break :blk false;
    };

    // Skip engine tests if not explicitly enabled
    if (is_engine_test and !config.include_engine_tests) {
        return error.SkipZigTest;
    }

    // Check if test has multiple hardforks in post section
    const post = test_case.object.get("post");
    if (post) |p| {
        if (p == .object) {
            // Collect all hardforks present in post section
            var hardforks_to_test: std.ArrayList(Hardfork) = .{};
            defer hardforks_to_test.deinit(allocator);

            // Check for each hardfork in order
            inline for (&[_][]const u8{ "Cancun", "Prague", "Osaka", "Shanghai", "Paris", "Merge", "London", "Berlin" }) |fork_name| {
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
                        generateTraceDiffOnFailure(allocator, test_case, test_file_path, test_name) catch |trace_err| {
                            std.debug.print("Warning: Failed to generate trace diff for failed test: {}\n", .{trace_err});
                        };
                        return err;
                    };
                }
                return;
            }
        }
    }

    // Single hardfork or no post section - use original logic
    runJsonTestImpl(allocator, test_case, null) catch |err| {
        generateTraceDiffOnFailure(allocator, test_case, test_file_path, test_name) catch |trace_err| {
            std.debug.print("Warning: Failed to generate trace diff for failed test: {}\n", .{trace_err});
        };
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
    _ = opt_test_name; // Currently unused parameter

    // Re-run with trace capture
    var tracer = trace.Tracer.init(allocator);
    defer tracer.deinit();
    tracer.enable();

    // Capture our trace (ignore errors since we're already in error state)
    runJsonTestImpl(allocator, test_case, &tracer) catch |err| {
        std.debug.print("  Traced re-run failed as expected: {}\n", .{err});
    };

    if (tracer.entries.items.len == 0) {
        std.debug.print("\n  No trace captured (test may have failed before execution)\n", .{});
        return;
    }

    // Use provided test file path if available, otherwise try to derive from _info.source
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
        // Silently skip trace generation when _info.source is not available
        return;
    }

    // Generate reference trace using Python ethereum-spec-evm
    const ref_trace_path = "trace_ref.jsonl";
    defer std.fs.cwd().deleteFile(ref_trace_path) catch |err| {
        std.debug.print("Warning: failed to delete {s}: {}\n", .{ ref_trace_path, err });
    };

    const python_cmd = try std.fmt.allocPrint(
        allocator,
        "execution-specs/.venv/bin/ethereum-spec-evm statetest --json {s} 1>{s} 2>/dev/null",
        .{ test_file_path.?, ref_trace_path },
    );
    defer allocator.free(python_cmd);

    var child = std.process.Child.init(&.{ "sh", "-c", python_cmd }, allocator);
    _ = child.spawnAndWait() catch {
        std.debug.print("\n  Failed to generate reference trace (Python execution-specs error)\n", .{});
        return;
    };

    // Parse reference trace
    const ref_trace_file = std.fs.cwd().openFile(ref_trace_path, .{}) catch {
        std.debug.print("\n  Reference trace file not found\n", .{});
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

        // Zig 0.15 ArrayList API requires an allocator parameter for append
        try ref_tracer.entries.append(allocator, entry);
    }

    // Compare traces and print diff
    const diff = try trace.TraceDiff.compare(allocator, &tracer, &ref_tracer);

    std.debug.print("\n", .{});

    // Print diff using debug output
    if (diff.divergence_index) |idx| {
        std.debug.print("Trace Divergence at step {d}\n", .{idx});

        if (diff.diff_field) |field| {
            std.debug.print("Difference in: {s}\n\n", .{field});
        }

        if (diff.our_entry) |our| {
            std.debug.print("Our EVM:\n", .{});
            std.debug.print("  PC: 0x{x}  Op: 0x{x:0>2} ({s})  Gas: {d}\n", .{
                our.pc,
                our.op,
                our.opName,
                our.gas,
            });
            std.debug.print("  Stack depth: {d}\n", .{our.stack.len});
        }

        if (diff.ref_entry) |ref| {
            std.debug.print("\nReference:\n", .{});
            std.debug.print("  PC: 0x{x}  Op: 0x{x:0>2} ({s})  Gas: {d}\n", .{
                ref.pc,
                ref.op,
                ref.opName,
                ref.gas,
            });
            std.debug.print("  Stack depth: {d}\n", .{ref.stack.len});
        }
    } else {
        std.debug.print("Traces match perfectly!\n", .{});
    }

    std.debug.print("\n", .{});
}

// Helper function to check if opcode is memory-related
fn isMemoryOp(op: u8) bool {
    return switch (op) {
        0x51...0x5f => true, // MLOAD, MSTORE, MSTORE8, etc.
        0x37, 0x39, 0x3c, 0x3e => true, // CALLDATACOPY, CODECOPY, EXTCODECOPY, RETURNDATACOPY
        0xf0...0xf5 => true, // CREATE, CALL, CALLCODE, RETURN, DELEGATECALL, CREATE2, STATICCALL
        0xfd => true, // REVERT
        else => false,
    };
}

// Helper function to check if opcode is storage-related
fn isStorageOp(op: u8) bool {
    return switch (op) {
        0x54, 0x55 => true, // SLOAD, SSTORE
        0x5c, 0x5d => true, // TLOAD, TSTORE
        else => false,
    };
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

/// Returns the `post` entries recorded for `hf`. Fixtures name Merge "Paris"
/// and Petersburg "ConstantinopleFix".
fn postForkEntries(post: std.json.Value, hf: Hardfork) ?std.json.Value {
    if (post != .object) return null;
    if (post.object.get(hardforkToString(hf))) |entries| return entries;
    return switch (hf) {
        .MERGE => post.object.get("Paris"),
        .PETERSBURG => post.object.get("ConstantinopleFix"),
        else => null,
    };
}

/// True when the first `post` entry for `hf` expects an exception containing `needle`.
fn postExpectsException(test_case: std.json.Value, hf: Hardfork, needle: []const u8) bool {
    const post = test_case.object.get("post") orelse return false;
    const entries = postForkEntries(post, hf) orelse return false;
    if (entries != .array or entries.array.items.len == 0) return false;
    const first = entries.array.items[0];
    if (first != .object) return false;
    const exception = first.object.get("expectException") orelse return false;
    if (exception != .string) return false;
    return std.mem.indexOf(u8, exception.string, needle) != null;
}

/// EIP-7825 (Osaka): maximum gas a single transaction may request (2^24).
const TX_MAX_GAS_LIMIT: u64 = 16_777_216;

fn exceedsTxGasLimitCap(hf: Hardfork, gas_limit: u64) bool {
    return hf.isAtLeast(.OSAKA) and gas_limit > TX_MAX_GAS_LIMIT;
}

/// EIP-7702: an authorization applies only on chain 0 (any chain) or the
/// transaction's own chain.
fn authorizationChainIdValid(auth_chain_id: u256, tx_chain_id: u256) bool {
    return auth_chain_id == 0 or auth_chain_id == tx_chain_id;
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
            inline for (&[_][]const u8{ "Cancun", "Prague", "Osaka", "Shanghai", "Paris", "Merge", "London", "Berlin", "Istanbul", "ConstantinopleFix", "Constantinople", "Byzantium", "Homestead" }) |fork_name| {
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

/// Process an RLP-encoded transaction (from blockchain tests)
fn processRlpTransaction(
    allocator: std.mem.Allocator,
    evm_instance: anytype,
    test_host: *TestHost,
    rlp_hex: []const u8,
    block_ctx: ?evm_mod.BlockContext,
) !void {
    // Decode hex to bytes
    const rlp_bytes = try primitives.Hex.hexToBytes(allocator, rlp_hex);
    defer allocator.free(rlp_bytes);

    // Check if transaction is typed (EIP-2718)
    // Typed transactions start with a single byte (0x01 or 0x02) followed by RLP payload
    const is_typed = rlp_bytes.len > 0 and (rlp_bytes[0] == 0x01 or rlp_bytes[0] == 0x02);

    // For typed transactions, decode from byte 1 onwards
    const rlp_to_decode = if (is_typed) rlp_bytes[1..] else rlp_bytes;

    // Decode RLP structure
    const decoded = try primitives.Rlp.decode(allocator, rlp_to_decode, false);
    defer decoded.data.deinit(allocator);

    // Expect a list for transaction
    const tx_list = switch (decoded.data) {
        .List => |items| items,
        else => return error.InvalidTransactionFormat,
    };

    // Legacy transaction format: [nonce, gasPrice, gasLimit, to, value, data, v, r, s] (9 fields)
    // Type 1 (EIP-2930): [chainId, nonce, gasPrice, gasLimit, to, value, data, accessList, yParity, r, s] (11 fields)
    // Type 2 (EIP-1559): [chainId, nonce, maxPriorityFeePerGas, maxFeePerGas, gasLimit, to, value, data, accessList, yParity, r, s] (12 fields)
    const is_legacy = tx_list.len == 9;
    const is_type_1 = tx_list.len == 11;
    const is_type_2 = tx_list.len == 12;

    if (!is_legacy and !is_type_1 and !is_type_2) {
        return error.InvalidTransactionFormat;
    }

    // Extract transaction fields (indices vary by transaction type)
    // Legacy: [nonce(0), gasPrice(1), gasLimit(2), to(3), value(4), data(5), v(6), r(7), s(8)]
    // Type 1: [chainId(0), nonce(1), gasPrice(2), gasLimit(3), to(4), value(5), data(6), accessList(7), yParity(8), r(9), s(10)]
    // Type 2: [chainId(0), nonce(1), maxPriorityFee(2), maxFee(3), gasLimit(4), to(5), value(6), data(7), accessList(8), yParity(9), r(10), s(11)]

    const nonce_idx: usize = if (is_legacy) 0 else 1;
    const gas_price_idx: usize = if (is_legacy) 1 else if (is_type_1) 2 else 3; // Type 2 uses maxFee at index 3
    const gas_limit_idx: usize = if (is_legacy) 2 else if (is_type_1) 3 else 4;
    const to_idx: usize = if (is_legacy) 3 else if (is_type_1) 4 else 5;
    const value_idx: usize = if (is_legacy) 4 else if (is_type_1) 5 else 6;
    const data_idx: usize = if (is_legacy) 5 else if (is_type_1) 6 else 7;
    const access_list_idx: usize = if (is_type_1) 7 else if (is_type_2) 8 else 0; // Only for typed transactions

    const nonce_bytes = switch (tx_list[nonce_idx]) {
        .String => |s| s,
        else => return error.InvalidTransactionFormat,
    };
    const nonce: u64 = if (nonce_bytes.len == 0) 0 else blk: {
        var val: u64 = 0;
        for (nonce_bytes) |b| {
            val = (val << 8) | b;
        }
        break :blk val;
    };

    const gas_price_bytes = switch (tx_list[gas_price_idx]) {
        .String => |s| s,
        else => return error.InvalidTransactionFormat,
    };
    var gas_price: u256 = 0;
    for (gas_price_bytes) |b| {
        gas_price = (gas_price << 8) | b;
    }

    const gas_limit_bytes = switch (tx_list[gas_limit_idx]) {
        .String => |s| s,
        else => return error.InvalidTransactionFormat,
    };
    var gas_limit: u64 = 0;
    for (gas_limit_bytes) |b| {
        gas_limit = (gas_limit << 8) | @as(u64, b);
    }

    const to_bytes = switch (tx_list[to_idx]) {
        .String => |s| s,
        else => return error.InvalidTransactionFormat,
    };
    const to_addr = if (to_bytes.len == 20) blk: {
        var addr_bytes: [20]u8 = undefined;
        for (to_bytes, 0..) |b, i| {
            addr_bytes[i] = b;
        }
        break :blk Address{ .bytes = addr_bytes };
    } else primitives.ZERO_ADDRESS;

    const value_bytes = switch (tx_list[value_idx]) {
        .String => |s| s,
        else => return error.InvalidTransactionFormat,
    };
    var value: u256 = 0;
    for (value_bytes) |b| {
        value = (value << 8) | b;
    }

    const data_bytes = switch (tx_list[data_idx]) {
        .String => |s| s,
        else => return error.InvalidTransactionFormat,
    };
    const tx_data = try allocator.dupe(u8, data_bytes);
    defer allocator.free(tx_data);

    // Signature components (v, r and s) - not currently used for sender recovery
    // Legacy: v(6), r(7), s(8)
    // Type 1: yParity(8), r(9), s(10)
    // Type 2: yParity(9), r(10), s(11)

    // Parse access list if present (Type 1 or Type 2 transactions)
    var access_list_gas_cost: u64 = 0;
    if (is_type_1 or is_type_2) {
        const access_list_data = tx_list[access_list_idx];
        if (access_list_data == .List) {
            const access_list = access_list_data.List;
            for (access_list) |entry| {
                // Each address costs 2400 gas
                access_list_gas_cost += primitives.AccessList.ACCESS_LIST_ADDRESS_COST;

                // Each storage key costs 1900 gas
                if (entry == .List and entry.List.len >= 2) {
                    const storage_keys = entry.List[1];
                    if (storage_keys == .List) {
                        access_list_gas_cost += @as(u64, storage_keys.List.len) * primitives.AccessList.ACCESS_LIST_STORAGE_KEY_COST;
                    }
                }
            }
        }
    }

    // Recover sender from signature
    // For now, we'll use a simple approach: find the first pre-state account with matching nonce
    var sender: Address = primitives.ZERO_ADDRESS;
    var nonces_it = test_host.nonces.iterator();
    while (nonces_it.next()) |entry| {
        if (entry.value_ptr.* == nonce) {
            sender = entry.key_ptr.*;
            break;
        }
    }

    // If no matching account found, use a default test address
    if (std.mem.eql(u8, &sender.bytes, &primitives.ZERO_ADDRESS.bytes)) {
        // Common test sender address
        const test_sender_hex = "a94f5374fce5edbc8e2a8697c15331677e6ebf0b";
        sender = try parseAddress(test_sender_hex);
    }

    // Calculate priority fee (entire gas_price goes to coinbase in legacy transactions)
    const base_fee: u256 = if (block_ctx) |ctx| ctx.block_base_fee else 0;
    const priority_fee_per_gas: u256 = if (gas_price > base_fee) gas_price - base_fee else 0;

    // Deduct transaction cost from sender
    const tx_cost = gas_price * @as(u256, gas_limit) + value;
    const sender_balance = test_host.balances.get(sender) orelse 0;
    if (sender_balance >= tx_cost) {
        try test_host.balances.put(sender, sender_balance - tx_cost);
    } else {
        // Transaction can't afford gas, skip execution
        return;
    }

    // Increment sender nonce
    try test_host.nonces.put(sender, nonce + 1);

    // Set transaction context
    evm_instance.gas_price = gas_price;
    evm_instance.origin = sender;

    // Pre-warm sender and target (EIP-2929, Berlin+)
    if (evm_instance.hardfork.isAtLeast(.BERLIN)) {
        try evm_instance.preWarmTransaction(to_addr);
    }

    // Pre-warm access list addresses and storage keys (EIP-2930, Berlin+)
    if (is_type_1 or is_type_2) {
        const access_list_data = tx_list[access_list_idx];
        if (access_list_data == .List) {
            const access_list = access_list_data.List;
            for (access_list) |entry| {
                if (entry == .List and entry.List.len >= 1) {
                    // Pre-warm address
                    const addr_bytes = switch (entry.List[0]) {
                        .String => |s| s,
                        else => continue,
                    };
                    if (addr_bytes.len == 20) {
                        var addr: Address = undefined;
                        for (addr_bytes, 0..) |b, i| {
                            addr.bytes[i] = b;
                        }
                        _ = try evm_instance.access_list_manager.warm_addresses.getOrPut(addr);

                        // Pre-warm storage keys
                        if (entry.List.len >= 2) {
                            const storage_keys = entry.List[1];
                            if (storage_keys == .List) {
                                for (storage_keys.List) |key_item| {
                                    const key_bytes = switch (key_item) {
                                        .String => |s| s,
                                        else => continue,
                                    };
                                    var key: u256 = 0;
                                    for (key_bytes) |b| {
                                        key = (key << 8) | b;
                                    }
                                    const storage_key = evm_mod.StorageKey{ .address = addr.bytes, .slot = key };
                                    _ = try evm_instance.access_list_manager.warm_storage_slots.getOrPut(storage_key);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Calculate intrinsic gas cost
    // Contract creation transactions cost 53000 base gas, regular transactions cost 21000
    const is_contract_creation = std.mem.eql(u8, &to_addr.bytes, &primitives.ZERO_ADDRESS.bytes);
    var intrinsic_gas: u64 = if (is_contract_creation)
        primitives.GasConstants.TxGasContractCreation // 53000 for contract creation
    else
        primitives.GasConstants.TxGas; // 21000 for regular transactions
    // EIP-2028 (Istanbul): Reduced non-zero calldata cost from 68 to 16 gas
    const non_zero_gas = if (evm_instance.hardfork.isBefore(.ISTANBUL))
        68 // Pre-Istanbul intrinsic gas for non-zero tx data bytes
    else
        primitives.GasConstants.TxDataNonZeroGas; // 16 for Istanbul+
    for (tx_data) |byte| {
        if (byte == 0) {
            intrinsic_gas += primitives.GasConstants.TxDataZeroGas; // 4
        } else {
            intrinsic_gas += non_zero_gas;
        }
    }

    // Add access list cost (EIP-2930, Berlin+)
    intrinsic_gas += access_list_gas_cost;

    // EIP-3860 (Shanghai+): Add init code cost for contract creation transactions
    // Cost is 2 gas per word (32 bytes) of init code
    if (is_contract_creation and evm_instance.hardfork.isAtLeast(.SHANGHAI)) {
        const init_code_words = (tx_data.len + 31) / 32;
        const init_code_cost = @as(u64, @intCast(init_code_words)) * primitives.GasConstants.InitcodeWordGas;
        intrinsic_gas += init_code_cost;
    }

    // Check if gas_limit is sufficient for intrinsic gas
    if (gas_limit < intrinsic_gas) {
        // Transaction cannot afford intrinsic gas, fail immediately
        // No gas refund - all gas is consumed
        if (block_ctx) |ctx| {
            const coinbase_payment = @as(u256, gas_limit) * priority_fee_per_gas;
            const coinbase_balance = test_host.balances.get(ctx.block_coinbase) orelse 0;
            try test_host.balances.put(ctx.block_coinbase, coinbase_balance + coinbase_payment);
        }
        return;
    }

    // Calculate execution gas (gas available after intrinsic cost)
    const execution_gas = gas_limit - intrinsic_gas;

    // Execute the transaction
    const is_create = std.mem.eql(u8, &to_addr.bytes, &primitives.ZERO_ADDRESS.bytes);

    if (is_create) {
        // CREATE transaction - use inner_create
        const result = evm_instance.inner_create(value, tx_data, execution_gas, null) catch |err| {
            // Refund gas on failure
            const refund = @as(u256, gas_limit) * gas_price;
            const new_balance = test_host.balances.get(sender) orelse 0;
            try test_host.balances.put(sender, new_balance + refund);
            return err;
        };

        // Calculate gas used before refunds (intrinsic + execution)
        const execution_gas_used = if (result.gas_left > execution_gas) 0 else execution_gas - result.gas_left;
        const gas_used_before_refunds: u64 = intrinsic_gas + execution_gas_used;

        // Apply gas refunds (EIP-3529: capped at 1/2 pre-London, 1/5 post-London).
        // The refund counter may be signed; only a positive balance refunds gas.
        const refund_counter: u64 = if (evm_instance.gas_refund > 0) @intCast(evm_instance.gas_refund) else 0;
        const settlement = settleTxGas(evm_instance.hardfork, gas_limit, gas_used_before_refunds, refund_counter, 0);
        const gas_used = settlement.gas_used;
        const gas_refund_amount = @as(u256, settlement.unused_gas) * gas_price;
        const new_balance = test_host.balances.get(sender) orelse 0;
        try test_host.balances.put(sender, new_balance + gas_refund_amount);

        // Pay coinbase (miner)
        if (block_ctx) |ctx| {
            const coinbase_payment = @as(u256, gas_used) * priority_fee_per_gas;
            const coinbase_balance = test_host.balances.get(ctx.block_coinbase) orelse 0;
            try test_host.balances.put(ctx.block_coinbase, coinbase_balance + coinbase_payment);
        }
    } else {
        // CALL transaction - use call with bytecode
        const bytecode = test_host.code.get(to_addr) orelse &[_]u8{};
        evm_instance.setBytecode(bytecode);
        const result = evm_instance.call(.{ .call = .{
            .caller = sender,
            .to = to_addr,
            .value = value,
            .input = tx_data,
            .gas = @intCast(execution_gas),
        } });

        // Calculate gas used before refunds (intrinsic + execution)
        const execution_gas_used = if (result.gas_left > execution_gas) 0 else execution_gas - result.gas_left;
        const gas_used_before_refunds: u64 = intrinsic_gas + execution_gas_used;

        // Apply gas refunds (EIP-3529: capped at 1/2 pre-London, 1/5 post-London).
        // The refund counter may be signed; only a positive balance refunds gas.
        const refund_counter: u64 = if (evm_instance.gas_refund > 0) @intCast(evm_instance.gas_refund) else 0;
        const settlement = settleTxGas(evm_instance.hardfork, gas_limit, gas_used_before_refunds, refund_counter, 0);
        const gas_used = settlement.gas_used;
        const gas_refund_amount = @as(u256, settlement.unused_gas) * gas_price;
        const new_balance = test_host.balances.get(sender) orelse 0;
        try test_host.balances.put(sender, new_balance + gas_refund_amount);

        // Pay coinbase (miner)
        if (block_ctx) |ctx| {
            const coinbase_payment = @as(u256, gas_used) * priority_fee_per_gas;
            const coinbase_balance = test_host.balances.get(ctx.block_coinbase) orelse 0;
            try test_host.balances.put(ctx.block_coinbase, coinbase_balance + coinbase_payment);
        }
    }
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
                                    const code_bytes = try primitives.Hex.hexToBytes(allocator, hex_data);
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

    // For blockchain tests, override coinbase and base fee with values from block header or engine payload
    // (env.currentCoinbase is typically ZERO_ADDRESS and env.currentBaseFee may be missing)
    var block_header_base_fee: ?u256 = null;
    const has_blocks_for_coinbase = test_case.object.get("blocks") != null;
    const has_engine_for_coinbase = test_case.object.get("engineNewPayloads") != null;

    if (has_blocks_for_coinbase) {
        if (test_case.object.get("blocks")) |blocks_json| {
            if (blocks_json == .array and blocks_json.array.items.len > 0) {
                const first_block = blocks_json.array.items[0];
                if (first_block.object.get("blockHeader")) |block_header| {
                    if (block_header.object.get("coinbase")) |cb| {
                        coinbase = try parseAddress(cb.string);
                    }
                    if (block_header.object.get("baseFeePerGas")) |bf| {
                        block_header_base_fee = try parseIntFromJson(bf);
                    }
                }
            }
        }
    } else if (has_engine_for_coinbase) {
        if (test_case.object.get("engineNewPayloads")) |payloads_json| {
            if (payloads_json == .array and payloads_json.array.items.len > 0) {
                const first_payload = payloads_json.array.items[0];
                if (first_payload.object.get("params")) |params| {
                    if (params == .array and params.array.items.len > 0) {
                        const block_params = params.array.items[0];
                        if (block_params.object.get("feeRecipient")) |fee_recipient| {
                            coinbase = try parseAddress(fee_recipient.string);
                        }
                        if (block_params.object.get("baseFeePerGas")) |bf| {
                            block_header_base_fee = try parseIntFromJson(bf);
                        }
                    }
                }
            }
        }
    }

    // Extract hardfork from test JSON (or use forced hardfork for multi-fork tests)
    const hardfork = if (forced_hardfork) |hf| hf else extractHardfork(test_case);

    // Build block context from env section or engine payload
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
            .blob_base_fee = if (env.object.get("currentExcessBlobGas")) |excess|
                blobBaseFee(hardfork, try parseIntFromJson(excess))
            else
                0,
        };
    } else if (has_engine_for_coinbase) blk: {
        // Build block context from engine payload if no env
        if (test_case.object.get("engineNewPayloads")) |payloads_json| {
            if (payloads_json == .array and payloads_json.array.items.len > 0) {
                const first_payload = payloads_json.array.items[0];
                if (first_payload.object.get("params")) |params| {
                    if (params == .array and params.array.items.len > 0) {
                        const block_params = params.array.items[0];
                        break :blk .{
                            .chain_id = 1, // Default chain ID
                            .block_number = if (block_params.object.get("blockNumber")) |bn|
                                try parseIntFromJson(bn)
                            else
                                0,
                            .block_timestamp = if (block_params.object.get("timestamp")) |ts|
                                try parseIntFromJson(ts)
                            else
                                0,
                            .block_difficulty = 0, // PoS has no difficulty
                            .block_prevrandao = if (block_params.object.get("prevRandao")) |pr|
                                try std.fmt.parseInt(u256, pr.string, 0)
                            else
                                0,
                            .block_coinbase = coinbase,
                            .block_gas_limit = if (block_params.object.get("gasLimit")) |gl|
                                try parseIntFromJson(gl)
                            else
                                30_000_000,
                            .block_base_fee = if (block_header_base_fee) |bhf| bhf else 0,
                            .blob_base_fee = if (block_params.object.get("excessBlobGas")) |excess|
                                blobBaseFee(hardfork, try parseIntFromJson(excess))
                            else
                                0,
                        };
                    }
                }
            }
        }
        break :blk null;
    } else if (test_case.object.get("blocks") != null) blk: {
        // Build block context from blocks array for blockchain tests
        if (test_case.object.get("blocks")) |blocks_json| {
            if (blocks_json == .array and blocks_json.array.items.len > 0) {
                const first_block = blocks_json.array.items[0];
                if (first_block.object.get("blockHeader")) |block_header| {
                    break :blk .{
                        .chain_id = 1, // Default chain ID
                        .block_number = if (block_header.object.get("number")) |num|
                            try parseIntFromJson(num)
                        else
                            0,
                        .block_timestamp = if (block_header.object.get("timestamp")) |ts|
                            try parseIntFromJson(ts)
                        else
                            0,
                        .block_difficulty = if (block_header.object.get("difficulty")) |diff|
                            try std.fmt.parseInt(u256, diff.string, 0)
                        else
                            0,
                        .block_prevrandao = if (block_header.object.get("mixHash")) |mix|
                            try std.fmt.parseInt(u256, mix.string, 0)
                        else
                            0,
                        .block_coinbase = if (block_header.object.get("coinbase")) |cb|
                            try parseAddress(cb.string)
                        else
                            try parseAddress("0000000000000000000000000000000000000000"),
                        .block_gas_limit = if (block_header.object.get("gasLimit")) |gl|
                            try parseIntFromJson(gl)
                        else
                            30_000_000,
                        .block_base_fee = if (block_header.object.get("baseFeePerGas")) |bf|
                            try parseIntFromJson(bf)
                        else
                            0,
                        .blob_base_fee = if (block_header.object.get("excessBlobGas")) |excess|
                            blobBaseFee(hardfork, try parseIntFromJson(excess))
                        else
                            0,
                    };
                }
            }
        }
        break :blk null;
    } else null;

    // Create EVM with test host and detected hardfork
    const host_interface = test_host.hostInterface();
    const Evm = evm_mod.Evm(.{}); // Use default config
    var evm_instance: Evm = undefined;
    try evm_instance.init(allocator, host_interface, hardfork, block_ctx, primitives.ZERO_ADDRESS, 0, null);
    defer evm_instance.deinit();

    // Attach tracer if provided
    if (tracer) |t| {
        evm_instance.setTracer(t);
    }

    // Execute transaction(s)
    const has_transactions = test_case.object.get("transactions") != null;
    const has_transaction = test_case.object.get("transaction") != null;
    const has_blocks_field = test_case.object.get("blocks") != null;
    const has_engine_payloads = test_case.object.get("engineNewPayloads") != null;

    // Collect all transactions to process
    var transactions_list = std.ArrayList(std.json.Value){};
    defer transactions_list.deinit(allocator);

    if (has_transactions) {
        try transactions_list.appendSlice(allocator, test_case.object.get("transactions").?.array.items);
    } else if (has_transaction) {
        try transactions_list.append(allocator, test_case.object.get("transaction").?);
    } else if (has_blocks_field) {
        // Blockchain tests: collect transactions from all blocks
        if (test_case.object.get("blocks")) |blocks_json| {
            if (blocks_json == .array) {
                var parent_block: ?std.json.Value = null;
                if (test_case.object.get("genesisBlockHeader")) |genesis| {
                    parent_block = genesis;
                }
                for (blocks_json.array.items) |block| {
                    const has_expect_exception = block.object.get("expectException") != null;
                    if (hardfork) |hf| {
                        validateBlockHeaderConstants(allocator, hf, block, parent_block) catch |err| switch (err) {
                            client_blockchain.ValidationError.InvalidDifficulty,
                            client_blockchain.ValidationError.InvalidNonce,
                            client_blockchain.ValidationError.InvalidOmmersHash,
                            client_blockchain.ValidationError.InvalidExtraDataLength,
                            client_blockchain.ValidationError.InvalidGasLimit,
                            client_blockchain.ValidationError.InvalidGasUsed,
                            client_blockchain.ValidationError.InvalidTimestamp,
                            client_blockchain.ValidationError.InvalidBaseFee,
                            client_blockchain.ValidationError.MissingBaseFee,
                            client_blockchain.ValidationError.InvalidParentHash,
                            client_blockchain.ValidationError.InvalidBlockNumber,
                            client_blockchain.ValidationError.MissingParentHeader,
                            client_blockchain.ValidationError.BaseFeeMath,
                            => {
                                if (has_expect_exception) break;
                                return err;
                            },
                            else => return err,
                        };
                    }
                    if (has_expect_exception) break;
                    if (block.object.get("transactions")) |txs| {
                        if (txs == .array) {
                            try transactions_list.appendSlice(allocator, txs.array.items);
                        }
                    }
                    parent_block = block;
                }
            }
        }
    } else if (has_engine_payloads) {
        // Engine API tests: collect transactions from engineNewPayloads
        if (test_case.object.get("engineNewPayloads")) |payloads| {
            if (payloads == .array) {
                for (payloads.array.items) |payload| {
                    if (payload.object.get("params")) |params| {
                        if (params == .array and params.array.items.len > 0) {
                            const block_params = params.array.items[0];
                            if (block_params.object.get("transactions")) |txs| {
                                if (txs == .array) {
                                    try transactions_list.appendSlice(allocator, txs.array.items);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // EIP-4788: Process beacon root system call for blockchain tests (Cancun+)
    const needs_beacon_root = if (hardfork) |hf|
        (hf == .CANCUN or hf == .PRAGUE or hf == .OSAKA)
    else
        false;
    if ((has_engine_payloads or has_blocks_field) and needs_beacon_root) {
        // Beacon roots contract address (EIP-4788)
        const beacon_roots_address = try parseAddress("000F3df6D732807Ef1319fB7B8bB8522d0Beac02");
        // System address that calls the beacon root contract
        const system_address = try parseAddress("fffffffffffffffffffffffffffffffffffffffe");

        var parent_beacon_root_hex: []const u8 = undefined;
        var found_parent_root = false;

        // Get parent beacon block root from engineNewPayloads params[2]
        if (has_engine_payloads) {
            if (test_case.object.get("engineNewPayloads")) |payloads| {
                if (payloads == .array and payloads.array.items.len > 0) {
                    const first_payload = payloads.array.items[0];
                    if (first_payload.object.get("params")) |params| {
                        if (params == .array and params.array.items.len >= 3) {
                            parent_beacon_root_hex = params.array.items[2].string;
                            found_parent_root = true;
                        }
                    }
                }
            }
        } else if (has_blocks_field) {
            // Get parent beacon block root from blocks[0].blockHeader.parentBeaconBlockRoot
            if (test_case.object.get("blocks")) |blocks_json| {
                if (blocks_json == .array and blocks_json.array.items.len > 0) {
                    const first_block = blocks_json.array.items[0];
                    if (first_block.object.get("blockHeader")) |block_header| {
                        if (block_header.object.get("parentBeaconBlockRoot")) |pbr| {
                            parent_beacon_root_hex = pbr.string;
                            found_parent_root = true;
                        }
                    }
                }
            }
        }

        if (found_parent_root) {
            const parent_beacon_root = try primitives.Hex.hexToBytes(allocator, parent_beacon_root_hex);
            defer allocator.free(parent_beacon_root);

            // Extract block timestamp for the beacon root call
            var block_timestamp: u64 = 0;
            if (has_engine_payloads) {
                if (test_case.object.get("engineNewPayloads")) |payloads| {
                    if (payloads == .array and payloads.array.items.len > 0) {
                        const first_payload = payloads.array.items[0];
                        if (first_payload.object.get("params")) |params| {
                            if (params == .array and params.array.items.len > 0) {
                                const block_params = params.array.items[0];
                                if (block_params.object.get("timestamp")) |ts| {
                                    block_timestamp = try std.fmt.parseInt(u64, ts.string, 0);
                                }
                            }
                        }
                    }
                }
            } else if (has_blocks_field) {
                if (test_case.object.get("blocks")) |blocks_json| {
                    if (blocks_json == .array and blocks_json.array.items.len > 0) {
                        const first_block = blocks_json.array.items[0];
                        if (first_block.object.get("blockHeader")) |block_header| {
                            if (block_header.object.get("timestamp")) |ts| {
                                block_timestamp = try std.fmt.parseInt(u64, ts.string, 0);
                            }
                        }
                    }
                }
            }

            // Set block timestamp in EVM instance for the beacon root call
            evm_instance.block_context.block_timestamp = block_timestamp;

            // Get beacon roots contract code from pre-state
            if (test_host.code.get(beacon_roots_address)) |beacon_code| {
                // Execute system call to beacon roots contract
                // This call uses system address as caller and has 30M gas
                _ = beacon_code; // Bytecode is fetched via host interface
                const call_result = evm_instance.call(.{
                    .call = .{
                        .caller = system_address,
                        .to = beacon_roots_address,
                        .value = 0,
                        .input = parent_beacon_root,
                        .gas = 30_000_000, // SYSTEM_TRANSACTION_GAS
                    },
                });
                _ = call_result; // System call failures are ignored per spec
            }
        }
    }

    // EIP-2935: Process history storage system call for Prague+ blockchain tests
    const needs_history_storage = if (hardfork) |hf|
        (hf == .PRAGUE or hf == .OSAKA)
    else
        false;

    if ((has_engine_payloads or has_blocks_field) and needs_history_storage) {
        // History storage contract address (EIP-2935)
        const history_storage_address = try parseAddress("0000F90827F1C53a10cb7A02335B175320002935");
        // System address that calls the history storage contract
        const system_address = try parseAddress("fffffffffffffffffffffffffffffffffffffffe");

        var parent_hash_hex: []const u8 = undefined;
        var found_parent_hash = false;

        // Get parent hash from genesis block header
        if (test_case.object.get("genesisBlockHeader")) |genesis| {
            if (genesis.object.get("hash")) |hash| {
                parent_hash_hex = hash.string;
                found_parent_hash = true;
            }
        }

        if (found_parent_hash) {
            const parent_hash = try primitives.Hex.hexToBytes(allocator, parent_hash_hex);
            defer allocator.free(parent_hash);

            // Get history storage contract code from pre-state
            if (test_host.code.get(history_storage_address)) |history_code| {
                // Execute system call to history storage contract
                // This call uses system address as caller and has 30M gas
                _ = history_code; // Bytecode is fetched via host interface
                const call_result = evm_instance.call(.{
                    .call = .{
                        .caller = system_address,
                        .to = history_storage_address,
                        .value = 0,
                        .input = parent_hash,
                        .gas = 30_000_000, // SYSTEM_TRANSACTION_GAS
                    },
                });
                _ = call_result; // System call failures are ignored per spec
            }
        }
    }

    // Transactions the runner rejected as invalid (not included). A fixture
    // expecting an exception must see at least one rejection.
    var rejected_tx_count: usize = 0;

    if (transactions_list.items.len > 0) {
        tx_loop: for (transactions_list.items) |tx| {
            // Handle RLP-encoded transactions (Engine API format)
            if (tx == .string) {
                // Process RLP-encoded transaction
                try processRlpTransaction(allocator, &evm_instance, &test_host, tx.string, block_ctx);
                continue;
            }

            // Parse transaction data
            const tx_data = if (tx.object.get("data")) |data| blk: {
                const data_str = if (data == .array) data.array.items[0].string else data.string;
                const hex = try parseHexData(allocator, data_str);
                defer allocator.free(hex);
                if (hex.len > 2) {
                    const bytes = try primitives.Hex.hexToBytes(allocator, hex);
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
            // Track max fees for upfront balance check (EIP-1559)
            var max_fee_per_gas_for_validation: u256 = 0;
            // Effective gas price for EVM (used for upfront deduction and refunds)
            var effective_gas_price: u256 = 0;
            if (tx.object.get("gasPrice")) |gp| {
                const gas_price = if (gp.string.len == 0) 0 else try std.fmt.parseInt(u256, gp.string, 0);
                max_fee_per_gas_for_validation = gas_price; // For legacy, max = actual
                effective_gas_price = gas_price;
                // If a base fee is present, only the tip (gas_price - base_fee) goes to coinbase.
                // For blockchain tests, use base fee from block header. Otherwise use env.currentBaseFee.
                const base_fee_for_priority: u256 = if (block_header_base_fee) |bhf|
                    bhf
                else blk: {
                    const base_fee_env: u256 = if (test_case.object.get("env")) |env_val|
                        if (env_val.object.get("currentBaseFee")) |bf|
                            try parseIntFromJson(bf)
                        else
                            0
                    else
                        0;
                    break :blk base_fee_env;
                };
                priority_fee_per_gas = if (gas_price > base_fee_for_priority) gas_price - base_fee_for_priority else 0;
            } else if (tx.object.get("maxFeePerGas")) |max_fee| {
                // EIP-1559 transaction
                const max_fee_per_gas = try parseIntFromJson(max_fee);
                max_fee_per_gas_for_validation = max_fee_per_gas; // Store for upfront check
                const max_priority_fee = if (tx.object.get("maxPriorityFeePerGas")) |mpf|
                    try parseIntFromJson(mpf)
                else
                    0;

                // Get base fee - prefer block header, fallback to env
                const base_fee = if (block_header_base_fee) |bhf|
                    bhf
                else blk: {
                    const base_fee_env: u256 = if (test_case.object.get("env")) |env_val|
                        if (env_val.object.get("currentBaseFee")) |bf|
                            try parseIntFromJson(bf)
                        else
                            0
                    else
                        0;
                    break :blk base_fee_env;
                };

                // Effective gas price = min(maxFeePerGas, baseFee + maxPriorityFeePerGas)
                priority_fee_per_gas = if (max_fee_per_gas > base_fee)
                    @min(max_priority_fee, max_fee_per_gas - base_fee)
                else
                    0;
                effective_gas_price = base_fee + priority_fee_per_gas;
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
                            // Use max_fee_per_gas for affordability check (not effective price)
                            const upfront_gas_cost = @as(u256, gas_limit) * max_fee_per_gas_for_validation;
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

            // Set per-tx origin and gas_price on the EVM instance
            evm_instance.origin = sender;
            evm_instance.gas_price = effective_gas_price;

            // Parse to address
            const to = if (tx.object.get("to")) |to_val| blk: {
                const to_str = to_val.string;
                if (to_str.len == 0) break :blk null;
                break :blk try parseAddress(to_str);
            } else null;

            // Parse maxFeePerBlobGas for EIP-4844 transactions
            var max_fee_per_blob_gas: u256 = 0;
            if (tx.object.get("maxFeePerBlobGas")) |max_blob_fee| {
                max_fee_per_blob_gas = try parseIntFromJson(max_blob_fee);
            }

            // Parse blob versioned hashes if present (EIP-4844)
            var blob_hashes_storage: ?[]const [32]u8 = null;
            if (tx.object.get("blobVersionedHashes")) |blob_hashes_json| {
                // EIP-4844: Blob transactions cannot be used for contract creation
                // Check if this is a contract creation (to is null or empty)
                if (to == null) {
                    // Transaction should be rejected - check if test expects this
                    if (test_case.object.get("post")) |post| {
                        const fork_data = postForkEntries(post, hardfork orelse .CANCUN);

                        if (fork_data) |fd| {
                            if (fd == .array and fd.array.items.len > 0) {
                                const first_item = fd.array.items[0];
                                if (first_item.object.get("expectException")) |exception| {
                                    const exception_str = exception.string;
                                    // If test expects TYPE_3_TX_CONTRACT_CREATION, skip execution
                                    if (std.mem.indexOf(u8, exception_str, "TYPE_3_TX_CONTRACT_CREATION") != null) {
                                        // Transaction is invalid as expected, don't execute
                                        rejected_tx_count += 1;
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
                        const fork_name = hardforkToString(hardfork orelse .CANCUN);

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
                        const fork_data = postForkEntries(post, hardfork orelse .CANCUN);

                        if (fork_data) |fd| {
                            if (fd == .array and fd.array.items.len > 0) {
                                const first_item = fd.array.items[0];
                                if (first_item.object.get("expectException")) |exception| {
                                    const exception_str = exception.string;
                                    // If test expects TYPE_3_TX_BLOB_COUNT_EXCEEDED, skip execution
                                    if (std.mem.indexOf(u8, exception_str, "TYPE_3_TX_BLOB_COUNT_EXCEEDED") != null) {
                                        // Transaction is invalid as expected, don't execute
                                        rejected_tx_count += 1;
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
                    const hash_bytes = try primitives.Hex.hexToBytes(allocator, hash_str);
                    defer allocator.free(hash_bytes);
                    if (hash_bytes.len != 32) {
                        return error.InvalidBlobHash;
                    }
                    @memcpy(&blob_hashes_array[i], hash_bytes);
                }

                // Validate blob hash versions (EIP-4844: must be 0x01)
                for (blob_hashes_array) |hash| {
                    if (hash[0] != 0x01) {
                        // Transaction should be rejected - check if test expects this
                        if (test_case.object.get("post")) |post| {
                            const fork_data = postForkEntries(post, hardfork orelse .CANCUN);

                            if (fork_data) |fd| {
                                if (fd == .array and fd.array.items.len > 0) {
                                    const first_item = fd.array.items[0];
                                    if (first_item.object.get("expectException")) |exception| {
                                        const exception_str = exception.string;
                                        // If test expects TYPE_3_TX_INVALID_BLOB_VERSIONED_HASH, skip execution
                                        if (std.mem.indexOf(u8, exception_str, "TYPE_3_TX_INVALID_BLOB_VERSIONED_HASH") != null) {
                                            // Transaction is invalid as expected: skip the whole
                                            // transaction, not just this hash.
                                            allocator.free(blob_hashes_array);
                                            rejected_tx_count += 1;
                                            continue :tx_loop;
                                        }
                                    }
                                }
                            }
                        }
                        // If we get here, the test doesn't expect this exception, so fail
                        allocator.free(blob_hashes_array);
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

            // Add calldata cost (4 gas per zero byte, 16/68 gas per non-zero byte)
            // Also track counts for EIP-7623 floor calculation (Prague+)
            // EIP-2028 (Istanbul): Reduced non-zero calldata cost from 68 to 16 gas
            const non_zero_gas_cost = if (evm_instance.hardfork.isBefore(.ISTANBUL))
                68 // Pre-Istanbul intrinsic gas for non-zero tx data bytes
            else
                primitives.GasConstants.TxDataNonZeroGas; // 16 for Istanbul+
            var zero_bytes: u64 = 0;
            var non_zero_bytes: u64 = 0;
            for (tx_data) |byte| {
                if (byte == 0) {
                    intrinsic_gas += primitives.GasConstants.TxDataZeroGas; // 4
                    zero_bytes += 1;
                } else {
                    intrinsic_gas += non_zero_gas_cost;
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
                    // Per EIP-7702: PER_EMPTY_ACCOUNT_COST (25000) per authorization in intrinsic gas
                    // (refund of 12500 may occur during execution if authority account exists)
                    const auth_count = auth_list_json.array.items.len;
                    intrinsic_gas += @as(u64, @intCast(auth_count)) * primitives.Authorization.PER_EMPTY_ACCOUNT_COST;
                }
            }

            // Add access list cost if present
            // Note: Some tests use "accessList" (singular), others use "accessLists" (plural)
            if (tx.object.get("accessList")) |access_list_json| {
                // accessList is a single access list (blockchain tests)
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
            } else if (tx.object.get("accessLists")) |access_lists_json| {
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
                                const fork_data = if (hardfork) |fork| postForkEntries(post, fork) else null;

                                if (fork_data) |fd| {
                                    if (fd == .array and fd.array.items.len > 0) {
                                        const first_item = fd.array.items[0];
                                        if (first_item.object.get("expectException")) |exception| {
                                            const exception_str = exception.string;
                                            // If test expects INITCODE_SIZE_EXCEEDED exception, skip execution
                                            if (std.mem.indexOf(u8, exception_str, "INITCODE_SIZE_EXCEEDED") != null) {
                                                // Transaction is invalid as expected, don't execute
                                                rejected_tx_count += 1;
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

            // Ensure gas_limit covers the intrinsic cost and, from Prague, the
            // EIP-7623 calldata floor (EELS: max(intrinsic, floor) > tx.gas).
            if (txGasLimitTooLow(gas_limit, intrinsic_gas, calldata_floor_gas_cost)) {
                // Transaction is invalid - check if test expects this
                if (test_case.object.get("post")) |post| {
                    const fork_data = if (hardfork) |hf| postForkEntries(post, hf) else null;

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
                                    rejected_tx_count += 1;
                                    continue;
                                }
                            }
                        }
                    }
                }
                // If we get here, the test doesn't expect this exception, so fail
                return error.IntrinsicGasTooLow;
            }

            // EIP-7825 (Osaka+): reject transactions above the per-tx gas cap.
            if (hardfork) |hf| {
                if (exceedsTxGasLimitCap(hf, gas_limit)) {
                    if (postExpectsException(test_case, hf, "GAS_LIMIT_EXCEEDS_MAXIMUM")) {
                        rejected_tx_count += 1;
                        continue;
                    }
                    return error.TransactionGasLimitExceedsMaximum;
                }
            }

            // Calculate execution gas (gas available after intrinsic cost)
            const execution_gas = gas_limit - intrinsic_gas;

            // Calculate blob gas fee for EIP-4844 transactions
            // For upfront check: use max_fee_per_blob_gas (worst case)
            // For actual deduction: use actual blob_base_fee (effective price)
            var blob_gas_fee_for_validation: u256 = 0;
            var blob_gas_fee: u256 = 0;
            if (blob_hashes_storage) |blob_hashes| {
                const blob_count = blob_hashes.len;

                // Use blob_base_fee from block context for actual deduction
                const blob_gas_price = evm_instance.block_context.blob_base_fee;

                // Each blob uses 131072 (2^17) gas
                const blob_gas_per_blob: u256 = 131072;
                const total_blob_gas = @as(u256, @intCast(blob_count)) * blob_gas_per_blob;

                // Actual fee for deduction (uses effective blob_gas_price)
                blob_gas_fee = total_blob_gas * blob_gas_price;

                // Max fee for upfront check (uses max_fee_per_blob_gas)
                blob_gas_fee_for_validation = total_blob_gas * max_fee_per_blob_gas;
            }

            // Per Ethereum spec: sender must have sufficient funds for upfront gas + blob fee + value
            // Use max_fee_per_gas and max_fee_per_blob_gas for upfront check (worst case)
            const upfront_gas_cost_for_validation = @as(u256, gas_limit) * max_fee_per_gas_for_validation;
            const sender_balance = test_host.balances.get(sender) orelse 0;
            const total_required = upfront_gas_cost_for_validation + blob_gas_fee_for_validation + value;
            if (sender_balance < total_required) {
                // INSUFFICIENT_ACCOUNT_FUNDS: the transaction is not included.
                rejected_tx_count += 1;
                continue;
            }

            // Actual upfront deduction uses effective gas price
            const upfront_gas_cost = @as(u256, gas_limit) * evm_instance.gas_price;

            // Increment sender's nonce (consumed even on REVERT/OOG after inclusion)
            const current_nonce = test_host.getNonce(sender);
            try test_host.setNonce(sender, current_nonce + 1);

            // Charge sender for full gas limit + blob gas fee upfront (refunds applied after execution)
            const new_balance = sender_balance - upfront_gas_cost - blob_gas_fee;
            try test_host.setBalance(sender, new_balance);

            // The EVM transfers value inside the call's own checkpoint, so a
            // call that fails (for example out of gas at exactly intrinsic gas)
            // also reverts the transfer. The runner never pre-transfers value.
            const target_addr = to orelse primitives.ZERO_ADDRESS;

            // Get contract code
            const bytecode = test_host.code.get(target_addr) orelse &[_]u8{};

            // Parse access list for EIP-2930 (Berlin+)
            var access_list_entries_storage: ?[]primitives.AccessList.AccessListEntry = null;
            defer if (access_list_entries_storage) |entries| {
                // Free storage_keys for each entry
                for (entries) |entry| {
                    allocator.free(entry.storage_keys);
                }
                allocator.free(entries);
            };

            // Parse access list from either "accessList" (blockchain tests) or "accessLists" (state tests)
            const has_access_list_singular = tx.object.get("accessList") != null;
            const access_list_json_opt = tx.object.get("accessList") orelse tx.object.get("accessLists");
            var access_list_param: ?primitives.AccessList.AccessList = if (access_list_json_opt) |access_list_data| blk: {
                // Determine which format we have
                const access_list_array = if (has_access_list_singular) blk2: {
                    // Handle accessList (singular) - direct array
                    if (access_list_data == .array) {
                        break :blk2 access_list_data.array;
                    }
                    break :blk null;
                } else blk2: {
                    // Handle accessLists (plural) - array of arrays, take first
                    if (access_list_data == .array and access_list_data.array.items.len > 0) {
                        const first_item = access_list_data.array.items[0];
                        if (first_item == .array) {
                            break :blk2 first_item.array;
                        }
                    }
                    break :blk null;
                };

                // First pass: count addresses
                var addr_count: usize = 0;
                for (access_list_array.items) |entry| {
                    if (entry.object.get("address")) |_| {
                        addr_count += 1;
                    }
                }

                // Allocate array of entries
                const entries = try allocator.alloc(primitives.AccessList.AccessListEntry, addr_count);
                access_list_entries_storage = entries;

                // Second pass: populate entries
                var entry_idx: usize = 0;
                for (access_list_array.items) |entry| {
                    if (entry.object.get("address")) |addr_json| {
                        const addr = try parseAddress(addr_json.string);

                        // Count storage keys for this address
                        var key_count: usize = 0;
                        if (entry.object.get("storageKeys")) |keys| {
                            if (keys == .array) {
                                key_count = keys.array.items.len;
                            }
                        }

                        // Allocate and populate storage keys
                        const storage_keys = try allocator.alloc([32]u8, key_count);
                        if (entry.object.get("storageKeys")) |keys| {
                            if (keys == .array) {
                                for (keys.array.items, 0..) |key_json, i| {
                                    const slot = try std.fmt.parseInt(u256, key_json.string, 0);
                                    // Convert u256 to [32]u8 (big-endian)
                                    std.mem.writeInt(u256, &storage_keys[i], slot, .big);
                                }
                            }
                        }

                        entries[entry_idx] = .{
                            .address = addr,
                            .storage_keys = storage_keys,
                        };
                        entry_idx += 1;
                    }
                }

                break :blk entries;
            } else null;

            // Process authorization list for EIP-7702 (Prague+), following
            // EELS `set_delegation`. Authorities are warm for the transaction.
            var auth_refund_count: u64 = 0;
            var warm_authorities: std.ArrayList(Address) = .{};
            defer warm_authorities.deinit(allocator);
            if (tx.object.get("authorizationList")) |auth_list_json| {
                if (auth_list_json == .array) {
                    // The transaction's chain ID: explicit on the tx, else the env's.
                    const tx_chain_id: u256 = if (tx.object.get("chainId")) |cid|
                        try parseU256FromJson(cid)
                    else if (block_ctx) |ctx| ctx.chain_id else 1;
                    for (auth_list_json.array.items) |auth_json| {
                        const auth_chain_id = try parseU256FromJson(auth_json.object.get("chainId").?);
                        const auth_addr = try parseAddress(auth_json.object.get("address").?.string);
                        const auth_nonce = try parseU256FromJson(auth_json.object.get("nonce").?);

                        // Recover the authority from the signature. Fixtures
                        // without a signature fall back to the "signer" annotation.
                        const y_parity_json = auth_json.object.get("yParity") orelse auth_json.object.get("v");
                        const authority: ?Address = if (y_parity_json != null and
                            auth_json.object.get("r") != null and auth_json.object.get("s") != null)
                            recoverAuthority(
                                auth_chain_id,
                                auth_addr,
                                auth_nonce,
                                try parseU256FromJson(y_parity_json.?),
                                try parseU256FromJson(auth_json.object.get("r").?),
                                try parseU256FromJson(auth_json.object.get("s").?),
                            )
                        else if (auth_json.object.get("signer")) |signer_json|
                            try parseAddress(signer_json.string)
                        else
                            null;

                        // EELS warms the authority once the tuple passes the
                        // chain id, nonce bound and signature checks.
                        if (authority) |a| {
                            if (authorizationChainIdValid(auth_chain_id, tx_chain_id) and auth_nonce < std.math.maxInt(u64)) {
                                try warm_authorities.append(allocator, a);
                            }
                        }

                        const outcome = try applyAuthorization(&test_host, tx_chain_id, .{
                            .chain_id = auth_chain_id,
                            .address = auth_addr,
                            .nonce = auth_nonce,
                            .authority = authority,
                        });
                        if (outcome == .applied_to_existing_account) auth_refund_count += 1;
                    }
                }
            }

            // Warm authorities by appending them to the EIP-2930 access list
            // handed to the EVM. Intrinsic gas was computed from the original list.
            if (warm_authorities.items.len > 0) {
                const old_entries: []primitives.AccessList.AccessListEntry = access_list_entries_storage orelse &.{};
                const entries = try allocator.alloc(primitives.AccessList.AccessListEntry, old_entries.len + warm_authorities.items.len);
                @memcpy(entries[0..old_entries.len], old_entries);
                for (warm_authorities.items, old_entries.len..) |authority, i| {
                    entries[i] = .{ .address = authority, .storage_keys = try allocator.alloc([32]u8, 0) };
                }
                if (access_list_entries_storage) |old| allocator.free(old);
                access_list_entries_storage = entries;
                access_list_param = entries;
            }

            // Execute transaction
            // Use separate if/else instead of if-else expression to avoid type mismatch issues
            var result_success: bool = undefined;
            var result_gas_left: u64 = undefined;

            if (to == null) {
                // Contract creation transaction - use inner_create
                // First, initialize transaction state (hash maps, etc.)
                try evm_instance.initTransactionState(blob_hashes_storage);

                // Pre-warm the origin/sender for contract creation
                try evm_instance.preWarmTransaction(sender);

                // Pre-warm access list (EIP-2930)
                if (access_list_param) |list| {
                    try evm_instance.access_list_manager.preWarmFromAccessList(list);
                }

                const create_result = try evm_instance.inner_create(
                    value,
                    tx_data, // initcode
                    execution_gas,
                    null, // no salt for regular CREATE (only CREATE2 uses salt)
                );
                result_success = create_result.success;
                result_gas_left = create_result.gas_left;
            } else {
                // Regular call - use call method
                // Set bytecode, access list, and blob hashes before calling
                evm_instance.setBytecode(bytecode);
                evm_instance.setAccessList(access_list_param);
                if (blob_hashes_storage) |hashes| {
                    evm_instance.setBlobVersionedHashes(hashes);
                }
                const call_result = evm_instance.call(.{ .call = .{
                    .caller = sender,
                    .to = target_addr,
                    .value = value,
                    .input = tx_data,
                    .gas = @intCast(execution_gas),
                } });
                result_success = call_result.success;
                result_gas_left = call_result.gas_left;
            }

            const result = .{ .success = result_success, .gas_left = result_gas_left };

            // Calculate gas used BEFORE applying refunds
            // Note: result.gas_left can be > execution_gas if CALL stipend was not fully used
            const execution_gas_used = if (result.gas_left > execution_gas) 0 else execution_gas - result.gas_left;
            const gas_used_before_refunds = intrinsic_gas + execution_gas_used;

            // Add authorization list refunds (EIP-7702, Prague+):
            // PER_EMPTY_ACCOUNT_COST - PER_AUTH_BASE_COST per existing authority.
            if (auth_refund_count > 0 and evm_instance.hardfork.isAtLeast(.PRAGUE)) {
                evm_instance.add_refund(auth_refund_count * primitives.Authorization.PER_AUTH_BASE_COST);
            }

            // The refund counter may be signed; only a positive balance refunds gas.
            const refund_counter: u64 = if (evm_instance.gas_refund > 0) @intCast(evm_instance.gas_refund) else 0;
            const settlement = settleTxGas(evm_instance.hardfork, gas_limit, gas_used_before_refunds, refund_counter, calldata_floor_gas_cost);

            // Refund unused gas to the sender (every fork, Frontier included).
            const gas_refund_amount = @as(u256, settlement.unused_gas) * evm_instance.gas_price;
            const sender_balance_after_exec = test_host.balances.get(sender) orelse 0;
            try test_host.setBalance(sender, sender_balance_after_exec + gas_refund_amount);

            // Pay the coinbase the priority fee for gas actually used. The base
            // fee (EIP-1559) is burned.
            const gas_for_coinbase = settlement.gas_used;
            const coinbase_reward = @as(u256, gas_for_coinbase) * priority_fee_per_gas;
            const coinbase_balance = test_host.balances.get(coinbase) orelse 0;
            try test_host.setBalance(coinbase, coinbase_balance + coinbase_reward);
        }
    }

    // Process withdrawals (EIP-4895, Shanghai+)
    // Withdrawals are processed at the END of block execution (after transactions)
    // For blockchain tests with multiple blocks, we need to apply withdrawals after EACH block's transactions
    const has_blocks = test_case.object.get("blocks") != null;
    if (has_blocks) {
        if (test_case.object.get("blocks")) |blocks_json| {
            if (blocks_json == .array) {
                for (blocks_json.array.items) |block| {
                    if (block.object.get("withdrawals")) |withdrawals_json| {
                        if (withdrawals_json == .array) {
                            for (withdrawals_json.array.items) |withdrawal| {
                                if (withdrawal.object.get("address")) |addr| {
                                    if (withdrawal.object.get("amount")) |amt| {
                                        const withdrawal_address = try parseAddress(addr.string);
                                        const withdrawal_amount_gwei = try parseIntFromJson(amt);

                                        // Convert Gwei to Wei (multiply by 10^9)
                                        const withdrawal_amount_wei: u256 = @as(u256, withdrawal_amount_gwei) * 1_000_000_000;

                                        // Add to recipient balance
                                        const current_balance = test_host.balances.get(withdrawal_address) orelse 0;
                                        try test_host.setBalance(withdrawal_address, current_balance + withdrawal_amount_wei);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Validate post-state
    // Check for both "post" (state tests) and "postState" (blockchain tests)
    const post_opt = test_case.object.get("post") orelse test_case.object.get("postState");
    if (post_opt) |post| {
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
        // Format 2: post -> addresses (for state tests)
        // Format 3: postState -> addresses (for blockchain tests)
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
                        // A fixture expecting an exception passes only if the
                        // runner rejected the transaction.
                        if (first_item.object.get("expectException")) |_| {
                            try checkExpectedException(true, rejected_tx_count);
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
                        std.debug.print("BALANCE MISMATCH: addr={any} expected {}, found {}\n", .{ address.bytes, exp, actual });
                    }
                    try testing.expectEqual(exp, actual);
                }

                // Check nonce
                if (expected.object.get("nonce")) |expected_nonce| {
                    const exp = try parseIntFromJson(expected_nonce);
                    const actual = test_host.getNonce(address);
                    if (exp != actual) {
                        std.debug.print("NONCE MISMATCH: addr={any} expected {}, found {}\n", .{ address.bytes, exp, actual });
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
                                std.debug.print("STORAGE MISMATCH: addr={any} slot={} expected {}, found {}\n", .{ address.bytes, key, exp_value, actual_value });
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
                                    std.debug.print("NONCE MISMATCH: addr={any} expected {}, found {}\n", .{ address.bytes, exp, actual });
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
        else => error.InvalidJsonNumber,
    };
}

fn parseU256FromJson(value: std.json.Value) !u256 {
    return switch (value) {
        .string => |s| if (s.len == 0) 0 else try std.fmt.parseInt(u256, s, 0),
        .integer => |i| @intCast(i),
        .number_string => |s| if (s.len == 0) 0 else try std.fmt.parseInt(u256, s, 0),
        else => error.InvalidJsonNumber,
    };
}

fn parseFixedHexBytes(comptime N: usize, allocator: std.mem.Allocator, value: std.json.Value) ![N]u8 {
    if (value != .string) return primitives.Hex.HexError.InvalidHexFormat;

    const bytes = try primitives.Hex.hexToBytes(allocator, value.string);
    defer allocator.free(bytes);

    if (bytes.len > N) return primitives.Hex.HexError.InvalidLength;

    var out: [N]u8 = [_]u8{0} ** N;
    @memcpy(out[N - bytes.len ..], bytes);
    return out;
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

test "authorizationChainIdValid accepts chain 0 and the tx chain only" {
    try testing.expect(authorizationChainIdValid(0, 1));
    try testing.expect(authorizationChainIdValid(1, 1));
    try testing.expect(authorizationChainIdValid(0x0539, 0x0539));
    try testing.expect(!authorizationChainIdValid(2, 1));
    try testing.expect(!authorizationChainIdValid(std.math.maxInt(u256), 1));
}

test "exceedsTxGasLimitCap applies from Osaka at 2^24" {
    try testing.expect(!exceedsTxGasLimitCap(.PRAGUE, TX_MAX_GAS_LIMIT + 1));
    try testing.expect(!exceedsTxGasLimitCap(.OSAKA, TX_MAX_GAS_LIMIT));
    try testing.expect(exceedsTxGasLimitCap(.OSAKA, TX_MAX_GAS_LIMIT + 1));
}

test "Osaka post sections resolve to the Osaka fork" {
    const json =
        \\{"post": {"Osaka": [{"expectException": "TransactionException.GAS_LIMIT_EXCEEDS_MAXIMUM"}]}}
    ;
    const parsed = try std.json.parseFromSlice(std.json.Value, testing.allocator, json, .{});
    defer parsed.deinit();

    try testing.expectEqual(@as(?Hardfork, .OSAKA), extractHardfork(parsed.value));
    try testing.expect(postExpectsException(parsed.value, .OSAKA, "GAS_LIMIT_EXCEEDS_MAXIMUM"));
    try testing.expect(!postExpectsException(parsed.value, .PRAGUE, "GAS_LIMIT_EXCEEDS_MAXIMUM"));
}

test "postForkEntries resolves fixture fork aliases" {
    const json =
        \\{"Paris": [1], "ConstantinopleFix": [2]}
    ;
    const parsed = try std.json.parseFromSlice(std.json.Value, testing.allocator, json, .{});
    defer parsed.deinit();

    try testing.expect(postForkEntries(parsed.value, .MERGE) != null);
    try testing.expect(postForkEntries(parsed.value, .PETERSBURG) != null);
    try testing.expect(postForkEntries(parsed.value, .OSAKA) == null);
}

test {
    // Compile every runner path, not just the helpers above.
    std.testing.refAllDecls(@This());
}

test "blob base fee update fraction follows EIP-7691 on Prague and Osaka" {
    try testing.expectEqual(@as(u256, 3_338_477), blobBaseFeeUpdateFraction(.CANCUN));
    try testing.expectEqual(@as(u256, 5_007_716), blobBaseFeeUpdateFraction(.PRAGUE));
    try testing.expectEqual(@as(u256, 5_007_716), blobBaseFeeUpdateFraction(.OSAKA));
    try testing.expectEqual(@as(u256, 3_338_477), blobBaseFeeUpdateFraction(null));

    // Zero excess is the minimum fee on every fork.
    try testing.expectEqual(@as(u256, 1), blobBaseFee(.CANCUN, 0));
    try testing.expectEqual(@as(u256, 1), blobBaseFee(.PRAGUE, 0));
    // Values from the EELS fake_exponential with unbounded integers.
    try testing.expectEqual(@as(u256, 19), blobBaseFee(.CANCUN, 10_000_000));
    try testing.expectEqual(@as(u256, 7), blobBaseFee(.PRAGUE, 10_000_000));
    try testing.expectEqual(@as(u256, 7), blobBaseFee(.OSAKA, 10_000_000));
    try testing.expectEqual(@as(u256, 4), blobBaseFee(.CANCUN, 5_000_000));
    try testing.expectEqual(@as(u256, 2), blobBaseFee(.PRAGUE, 5_000_000));
}

test "taylorExponential saturates instead of returning a partial sum" {
    try testing.expectEqual(std.math.maxInt(u256), taylorExponential(1, std.math.maxInt(u64), 3_338_477));
}

test "EIP-7623 floor makes a gas limit between intrinsic and floor invalid" {
    // 1000 non-zero calldata bytes: intrinsic 21000 + 16000, floor 21000 + 4000 * 10.
    const intrinsic: u64 = 37_000;
    const floor: u64 = 61_000;
    try testing.expect(txGasLimitTooLow(intrinsic, intrinsic, floor));
    try testing.expect(txGasLimitTooLow(floor - 1, intrinsic, floor));
    try testing.expect(!txGasLimitTooLow(floor, intrinsic, floor));
    // Before Prague the floor is 0 and only intrinsic gas matters.
    try testing.expect(!txGasLimitTooLow(intrinsic, intrinsic, 0));
    try testing.expect(txGasLimitTooLow(intrinsic - 1, intrinsic, 0));
}

test "settleTxGas never underflows and applies the floor after refunds" {
    // gas_limit below the floor (rejected upstream) still settles without panicking.
    const under = settleTxGas(.PRAGUE, 37_000, 37_000, 0, 61_000);
    try testing.expectEqual(@as(u64, 37_000), under.gas_used);
    try testing.expectEqual(@as(u64, 0), under.unused_gas);

    // Execution below the floor is charged the floor.
    const floored = settleTxGas(.PRAGUE, 100_000, 40_000, 0, 61_000);
    try testing.expectEqual(@as(u64, 61_000), floored.gas_used);
    try testing.expectEqual(@as(u64, 39_000), floored.unused_gas);

    // Refund capped at 1/5 first (70000 - 14000 = 56000), then the floor wins.
    try testing.expectEqual(@as(u64, 61_000), settleTxGas(.OSAKA, 100_000, 70_000, 20_000, 61_000).gas_used);
    // Refund capped at 1/5 (80000 - 16000 = 64000) stays above the floor.
    try testing.expectEqual(@as(u64, 64_000), settleTxGas(.PRAGUE, 100_000, 80_000, 50_000, 61_000).gas_used);

    // Cancun ignores the floor.
    try testing.expectEqual(@as(u64, 40_000), settleTxGas(.CANCUN, 100_000, 40_000, 0, 61_000).gas_used);
    // Pre-London refunds cap at 1/2.
    try testing.expectEqual(@as(u64, 25_000), settleTxGas(.BERLIN, 100_000, 50_000, 30_000, 0).gas_used);
}

test "settleTxGas refunds unused gas on Frontier and Homestead" {
    inline for (.{ Hardfork.FRONTIER, Hardfork.HOMESTEAD }) |hf| {
        const s = settleTxGas(hf, 50_000, 21_000, 0, 0);
        try testing.expectEqual(@as(u64, 21_000), s.gas_used);
        try testing.expectEqual(@as(u64, 29_000), s.unused_gas);
    }
}

test "checkExpectedException fails when no transaction was rejected" {
    try testing.expectError(error.ExpectedExceptionNotRaised, checkExpectedException(true, 0));
    try checkExpectedException(true, 1);
    try checkExpectedException(false, 0);
}

fn testAddress(byte: u8) Address {
    var a = primitives.ZERO_ADDRESS;
    a.bytes[19] = byte;
    return a;
}

test "applyAuthorization to the zero address clears an existing delegation" {
    var host = try TestHost.init(testing.allocator);
    defer host.deinit();

    const authority = testAddress(0xaa);
    const old_target = testAddress(0xbb);
    var designator: [23]u8 = undefined;
    @memcpy(designator[0..3], &DELEGATION_PREFIX);
    @memcpy(designator[3..23], &old_target.bytes);
    try host.setCode(authority, &designator);
    try host.setNonce(authority, 5);

    const outcome = try applyAuthorization(&host, 1, .{
        .chain_id = 1,
        .address = primitives.ZERO_ADDRESS,
        .nonce = 5,
        .authority = authority,
    });
    try testing.expectEqual(AuthorizationOutcome.applied_to_existing_account, outcome);
    try testing.expect(host.code.get(authority) == null);
    try testing.expectEqual(@as(u64, 6), host.getNonce(authority));
}

test "applyAuthorization writes a designator for a new account and redelegates" {
    var host = try TestHost.init(testing.allocator);
    defer host.deinit();

    const authority = testAddress(0xaa);
    const target = testAddress(0xcc);
    try testing.expectEqual(AuthorizationOutcome.applied_to_new_account, try applyAuthorization(&host, 1, .{
        .chain_id = 0,
        .address = target,
        .nonce = 0,
        .authority = authority,
    }));
    const code = host.code.get(authority).?;
    try testing.expect(isDelegationDesignator(code));
    try testing.expectEqualSlices(u8, &target.bytes, code[3..23]);
    try testing.expectEqual(@as(u64, 1), host.getNonce(authority));

    // An existing delegation may be replaced (old code is freed by replaceHostCode).
    try testing.expectEqual(AuthorizationOutcome.applied_to_existing_account, try applyAuthorization(&host, 1, .{
        .chain_id = 1,
        .address = testAddress(0xdd),
        .nonce = 1,
        .authority = authority,
    }));
    try testing.expectEqual(@as(u8, 0xdd), host.code.get(authority).?[22]);
}

test "applyAuthorization skips invalid tuples without changing state" {
    var host = try TestHost.init(testing.allocator);
    defer host.deinit();

    const contract = testAddress(0xaa);
    try host.setCode(contract, &[_]u8{ 0x60, 0x00 });
    const eoa = testAddress(0xab);
    try host.setNonce(eoa, 3);
    const target = testAddress(0xcc);

    // Authority with non-delegation code.
    try testing.expectEqual(AuthorizationOutcome.skipped, try applyAuthorization(&host, 1, .{ .chain_id = 1, .address = target, .nonce = 0, .authority = contract }));
    try testing.expectEqualSlices(u8, &[_]u8{ 0x60, 0x00 }, host.code.get(contract).?);
    // Nonce mismatch.
    try testing.expectEqual(AuthorizationOutcome.skipped, try applyAuthorization(&host, 1, .{ .chain_id = 1, .address = target, .nonce = 2, .authority = eoa }));
    // Wrong chain.
    try testing.expectEqual(AuthorizationOutcome.skipped, try applyAuthorization(&host, 1, .{ .chain_id = 2, .address = target, .nonce = 3, .authority = eoa }));
    // Nonce at 2^64 - 1.
    try testing.expectEqual(AuthorizationOutcome.skipped, try applyAuthorization(&host, 1, .{ .chain_id = 1, .address = target, .nonce = std.math.maxInt(u64), .authority = eoa }));
    // Unrecoverable signature.
    try testing.expectEqual(AuthorizationOutcome.skipped, try applyAuthorization(&host, 1, .{ .chain_id = 1, .address = target, .nonce = 3, .authority = null }));

    try testing.expect(host.code.get(eoa) == null);
    try testing.expectEqual(@as(u64, 3), host.getNonce(eoa));
}

test "recoverAuthority recovers the signer and rejects malformed signatures" {
    // Well-known test key for 0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b.
    var key: [32]u8 = undefined;
    std.mem.writeInt(u256, &key, 0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8, .big);
    const expected = try Address.fromHex("0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b");
    const target = testAddress(0xcc);

    const signed = try primitives.Authorization.createAuthorization(testing.allocator, 1, target, 7, key);
    const y_parity: u256 = if (signed.v >= 27) (signed.v - 27) % 2 else signed.v;
    const r = std.mem.readInt(u256, &signed.r, .big);
    const s = std.mem.readInt(u256, &signed.s, .big);

    try testing.expect(recoverAuthority(1, target, 7, y_parity, r, s).?.equals(expected));
    // A different nonce signs a different message.
    if (recoverAuthority(1, target, 8, y_parity, r, s)) |other| try testing.expect(!other.equals(expected));

    try testing.expect(recoverAuthority(1, target, 7, 2, r, s) == null);
    try testing.expect(recoverAuthority(1, target, 7, y_parity, 0, s) == null);
    try testing.expect(recoverAuthority(1, target, 7, y_parity, r, 0) == null);
    try testing.expect(recoverAuthority(1, target, 7, y_parity, r, SECP256K1N / 2 + 1) == null);
}

/// Runs a fixture JSON through the runner with a forced fork.
fn runFixtureForTest(json: []const u8) !void {
    const parsed = try std.json.parseFromSlice(std.json.Value, testing.allocator, json, .{});
    defer parsed.deinit();
    try runJsonTestImpl(testing.allocator, parsed.value, null);
}

const fixture_sender = "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b";
const fixture_env =
    \\"env": {"currentCoinbase": "0x2adc25665018aa1fe0e6bc666dac8fc2697ff9ba", "currentGasLimit": "0x05f5e100",
    \\  "currentNumber": "0x01", "currentTimestamp": "0x03e8", "currentDifficulty": "0x00", "currentBaseFee": "0x00"}
;

test "fixture expecting an exception fails when the transaction succeeds" {
    const json = "{" ++ fixture_env ++
        \\,"pre": {"0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {"balance": "0x0de0b6b3a7640000", "nonce": "0x00", "code": "0x", "storage": {}}},
        \\"transaction": {"data": ["0x"], "gasLimit": ["0x5208"], "gasPrice": "0x0a", "nonce": "0x00",
        \\  "sender": "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b", "to": "0x1000000000000000000000000000000000000000", "value": ["0x00"]},
        \\"post": {"Cancun": [{"expectException": "TransactionException.INTRINSIC_GAS_TOO_LOW"}]}}
    ;
    try testing.expectError(error.ExpectedExceptionNotRaised, runFixtureForTest(json));
}

test "fixture expecting an exception passes when the transaction is rejected" {
    const json = "{" ++ fixture_env ++
        \\,"pre": {"0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {"balance": "0x0de0b6b3a7640000", "nonce": "0x00", "code": "0x", "storage": {}}},
        \\"transaction": {"data": ["0x"], "gasLimit": ["0x5207"], "gasPrice": "0x0a", "nonce": "0x00",
        \\  "sender": "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b", "to": "0x1000000000000000000000000000000000000000", "value": ["0x00"]},
        \\"post": {"Cancun": [{"expectException": "TransactionException.INTRINSIC_GAS_TOO_LOW"}]}}
    ;
    try runFixtureForTest(json);
}

fn floorFixture(comptime post: []const u8) []const u8 {
    // 1000 non-zero bytes: intrinsic 37000, EIP-7623 floor 61000; gas limit 37000 (0x9088).
    return "{" ++ fixture_env ++
        \\,"pre": {"0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {"balance": "0x0de0b6b3a7640000", "nonce": "0x00", "code": "0x", "storage": {}}},
        \\"transaction": {"data": ["0x
    ++ ("ff" ** 1000) ++
        \\"], "gasLimit": ["0x9088"], "gasPrice": "0x0a", "nonce": "0x00",
        \\  "sender": "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b", "to": "0x1000000000000000000000000000000000000000", "value": ["0x00"]},
        \\"post": {"Prague": [
    ++ post ++ "]}}";
}

test "EIP-7623: gas limit below the calldata floor is rejected, not a panic" {
    @setEvalBranchQuota(10_000);
    try runFixtureForTest(floorFixture(
        \\{"expectException": "TransactionException.INTRINSIC_GAS_BELOW_FLOOR_GAS_COST"}
    ));
    try testing.expectError(error.IntrinsicGasTooLow, runFixtureForTest(floorFixture(
        \\{"state": {}}
    )));
}

test "zero execution gas: a failing call keeps the value with the sender" {
    // Exactly intrinsic gas (21000) leaves no gas for JUMPDEST (1 gas), so the
    // call fails and the value transfer reverts. Sender pays 21000 * 10.
    const json = "{" ++ fixture_env ++
        \\,"pre": {"0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {"balance": "0x0de0b6b3a7640000", "nonce": "0x00", "code": "0x", "storage": {}},
        \\  "0x1000000000000000000000000000000000000000": {"balance": "0x00", "nonce": "0x01", "code": "0x5b00", "storage": {}}},
        \\"transaction": {"data": ["0x"], "gasLimit": ["0x5208"], "gasPrice": "0x0a", "nonce": "0x00",
        \\  "sender": "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b", "to": "0x1000000000000000000000000000000000000000", "value": ["0x01"]},
        \\"post": {"Cancun": [{"state": {
        \\  "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {"balance": "0x0de0b6b3a760cbb0", "nonce": "0x01"},
        \\  "0x1000000000000000000000000000000000000000": {"balance": "0x00"}}}]}}
    ;
    try runFixtureForTest(json);
}

test "zero execution gas: a transfer to an empty account moves the value" {
    const json = "{" ++ fixture_env ++
        \\,"pre": {"0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {"balance": "0x0de0b6b3a7640000", "nonce": "0x00", "code": "0x", "storage": {}}},
        \\"transaction": {"data": ["0x"], "gasLimit": ["0x5208"], "gasPrice": "0x0a", "nonce": "0x00",
        \\  "sender": "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b", "to": "0x1000000000000000000000000000000000000000", "value": ["0x01"]},
        \\"post": {"Cancun": [{"state": {
        \\  "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {"balance": "0x0de0b6b3a760cbaf", "nonce": "0x01"},
        \\  "0x1000000000000000000000000000000000000000": {"balance": "0x01"}}}]}}
    ;
    try runFixtureForTest(json);
}

test "Frontier settlement refunds unused gas and pays the miner for gas used" {
    // gasLimit 50000, 21000 used, gasPrice 10: sender pays 210000, miner gets 210000.
    const json = "{\"network\": \"Frontier\"," ++ fixture_env ++
        \\,"pre": {"0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {"balance": "0x0de0b6b3a7640000", "nonce": "0x00", "code": "0x", "storage": {}}},
        \\"transaction": {"data": ["0x"], "gasLimit": ["0xc350"], "gasPrice": "0x0a", "nonce": "0x00",
        \\  "sender": "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b", "to": "0x1000000000000000000000000000000000000000", "value": ["0x00"]},
        \\"postState": {
        \\  "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {"balance": "0x0de0b6b3a760cbb0", "nonce": "0x01"},
        \\  "0x2adc25665018aa1fe0e6bc666dac8fc2697ff9ba": {"balance": "0x033450"}}}
    ;
    try runFixtureForTest(json);
}
