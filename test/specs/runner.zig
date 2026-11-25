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
    if (header_json.object.get("coinbase")) |coinbase| {
        header.beneficiary = .{ .bytes = try parseFixedHexBytes(20, allocator, coinbase) };
    }
    if (header_json.object.get("stateRoot")) |root| {
        header.state_root = try parseFixedHexBytes(Hash.SIZE, allocator, root);
    }
    if (header_json.object.get("transactionsTrie") orelse header_json.object.get("transactionsRoot")) |root| {
        header.transactions_root = try parseFixedHexBytes(Hash.SIZE, allocator, root);
    }
    if (header_json.object.get("receiptTrie") orelse header_json.object.get("receiptsRoot")) |root| {
        header.receipts_root = try parseFixedHexBytes(Hash.SIZE, allocator, root);
    }
    if (header_json.object.get("bloom") orelse header_json.object.get("logsBloom")) |bloom| {
        header.logs_bloom = try parseFixedHexBytes(BlockHeader.BLOOM_SIZE, allocator, bloom);
    }
    if (header_json.object.get("withdrawalsRoot")) |root| {
        header.withdrawals_root = try parseFixedHexBytes(Hash.SIZE, allocator, root);
    }
    if (header_json.object.get("blobGasUsed")) |blob_gas_used| {
        header.blob_gas_used = try parseIntFromJson(blob_gas_used);
    }
    if (header_json.object.get("excessBlobGas")) |excess_blob_gas| {
        header.excess_blob_gas = try parseIntFromJson(excess_blob_gas);
    }
    if (header_json.object.get("parentBeaconBlockRoot")) |root| {
        header.parent_beacon_block_root = try parseFixedHexBytes(Hash.SIZE, allocator, root);
    }
    // Voltaire header types vary across pins.
    if (comptime @hasField(@TypeOf(header.*), "requests_hash")) {
        if (header_json.object.get("requestsHash")) |hash| {
            header.requests_hash = try parseFixedHexBytes(Hash.SIZE, allocator, hash);
        }
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

/// Why the runner refused to include a transaction.
const TxRejection = enum {
    intrinsic_gas,
    insufficient_funds,
    insufficient_max_fee,
    priority_fee_above_max_fee,
    nonce_too_high,
    nonce_too_low,
    nonce_is_max,
    invalid_chain_id,
    initcode_size,
    gas_limit_cap,
    blob_contract_creation,
    blob_count,
    blob_versioned_hash,
    set_code_invalid,

    /// Fixture exception names for this rejection: EEST
    /// `TransactionException.*` and legacy retesteth `TR_*`.
    fn names(self: TxRejection) []const []const u8 {
        return switch (self) {
            .intrinsic_gas => &.{ "INTRINSIC_GAS_TOO_LOW", "INTRINSIC_GAS_BELOW_FLOOR_GAS_COST", "TR_IntrinsicGas" },
            .insufficient_funds => &.{ "INSUFFICIENT_ACCOUNT_FUNDS", "TR_NoFunds" },
            .insufficient_max_fee => &.{ "INSUFFICIENT_MAX_FEE_PER_GAS", "TR_FeeCapLessThanBlocks" },
            .priority_fee_above_max_fee => &.{ "PRIORITY_GREATER_THAN_MAX_FEE_PER_GAS", "TR_TipGtFeeCap" },
            .nonce_too_high => &.{ "NONCE_MISMATCH_TOO_HIGH", "TR_NonceTooHigh" },
            .nonce_too_low => &.{ "NONCE_MISMATCH_TOO_LOW", "TR_NonceTooLow" },
            .nonce_is_max => &.{ "NONCE_IS_MAX", "TR_NonceHasMaxValue" },
            .invalid_chain_id => &.{ "INVALID_CHAINID", "TR_ChainId" },
            .initcode_size => &.{ "INITCODE_SIZE_EXCEEDED", "TR_InitCodeLimitExceeded" },
            .gas_limit_cap => &.{"GAS_LIMIT_EXCEEDS_MAXIMUM"},
            .blob_contract_creation => &.{"TYPE_3_TX_CONTRACT_CREATION"},
            .blob_count => &.{"TYPE_3_TX_BLOB_COUNT_EXCEEDED"},
            .blob_versioned_hash => &.{"TYPE_3_TX_INVALID_BLOB_VERSIONED_HASH"},
            .set_code_invalid => &.{ "TYPE_4_TX_CONTRACT_CREATION", "TYPE_4_EMPTY_AUTHORIZATION_LIST", "TYPE_4_TX_PRE_FORK" },
        };
    }

    /// True when `expected` (an `expectException` value, possibly `A|B`)
    /// names this rejection.
    fn matches(self: TxRejection, expected: []const u8) bool {
        return exceptionNamesAny(expected, self.names());
    }

    fn forNonce(tx_nonce: u256, account_nonce: u64) ?TxRejection {
        if (tx_nonce > account_nonce) return .nonce_too_high;
        if (tx_nonce < account_nonce) return .nonce_too_low;
        return null;
    }
};

/// True when one alternative of `expected` (`A|B`, each optionally prefixed
/// `TransactionException.` or `BlockException.`) is exactly one of `names`.
/// Exact comparison keeps `NONCE_MISMATCH_TOO_LOW` from matching a
/// too-high nonce and `UNKNOWN_PARENT` from matching `UNCLE_UNKNOWN_PARENT`.
fn exceptionNamesAny(expected: []const u8, names: []const []const u8) bool {
    var alternatives = std.mem.splitScalar(u8, expected, '|');
    while (alternatives.next()) |raw| {
        const trimmed = std.mem.trim(u8, raw, " \t\r\n");
        const bare = if (std.mem.lastIndexOfScalar(u8, trimmed, '.')) |dot| trimmed[dot + 1 ..] else trimmed;
        for (names) |name| {
            if (std.mem.eql(u8, bare, name)) return true;
        }
    }
    return false;
}

/// Fixture `BlockException.*` names for a header validation error. Errors
/// without a fixture name (allocation failure) return an empty list, which
/// never matches an expectation.
fn headerErrorNames(err: anyerror) []const []const u8 {
    return switch (err) {
        error.InvalidDifficulty => &.{ "INVALID_DIFFICULTY", "IMPORT_IMPOSSIBLE_DIFFICULTY_OVER_PARIS" },
        error.InvalidNonce => &.{"IMPORT_IMPOSSIBLE_PARIS_WRONG_POW"},
        error.InvalidOmmersHash => &.{ "INVALID_UNCLES_HASH", "IMPORT_IMPOSSIBLE_UNCLES_OVER_PARIS" },
        error.InvalidExtraDataLength => &.{"EXTRA_DATA_TOO_BIG"},
        error.InvalidGasLimit => &.{ "INVALID_GASLIMIT", "GASLIMIT_TOO_BIG" },
        error.InvalidGasUsed => &.{ "INVALID_GAS_USED", "INVALID_GAS_USED_ABOVE_LIMIT", "GAS_USED_OVERFLOW" },
        error.InvalidTimestamp => &.{"INVALID_BLOCK_TIMESTAMP_OLDER_THAN_PARENT"},
        error.InvalidBaseFee, error.MissingBaseFee, error.BaseFeeMath => &.{"INVALID_BASEFEE_PER_GAS"},
        error.InvalidParentHash, error.MissingParentHeader => &.{ "UNKNOWN_PARENT", "UNKNOWN_PARENT_ZERO" },
        error.InvalidBlockNumber => &.{"INVALID_BLOCK_NUMBER"},
        error.InvalidExcessBlobGas => &.{"INCORRECT_EXCESS_BLOB_GAS"},
        error.InvalidBlobGasUsed => &.{ "BLOB_GAS_USED_ABOVE_LIMIT", "INCORRECT_BLOB_GAS_USED" },
        error.MissingBlobGasUsed,
        error.MissingExcessBlobGas,
        error.MissingParentBeaconBlockRoot,
        error.UnexpectedBlobFieldsPreCancun,
        error.MissingWithdrawalsRoot,
        error.UnexpectedWithdrawalsRoot,
        error.MissingRequestsHash,
        error.UnexpectedRequestsHash,
        => &.{"INCORRECT_BLOCK_FORMAT"},
        else => &.{},
    };
}

/// True when `expected` names `rejection`.
fn expectsRejection(expected: ?[]const u8, rejection: TxRejection) bool {
    const want = expected orelse return false;
    return rejection.matches(want);
}

/// Checks one state-test case against its `expectException`: a negative case
/// must be rejected for one of the named reasons, and a positive case must
/// not be rejected at all.
fn checkExpectedException(expected: ?[]const u8, rejection: ?TxRejection) error{
    ExpectedExceptionNotRaised,
    WrongExceptionRaised,
    UnexpectedTransactionRejection,
}!void {
    const want = expected orelse {
        if (rejection) |got| {
            std.debug.print("transaction rejected ({s}) but the fixture expects it to be included\n", .{@tagName(got)});
            return error.UnexpectedTransactionRejection;
        }
        return;
    };
    const got = rejection orelse return error.ExpectedExceptionNotRaised;
    if (!got.matches(want)) {
        std.debug.print("transaction rejected ({s}) but the fixture expects {s}\n", .{ @tagName(got), want });
        return error.WrongExceptionRaised;
    }
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

    if (test_case.object.get("expect")) |expectations| {
        if (test_case.object.get("transaction")) |transaction| {
            if (transaction == .object and expectations == .array) {
                const data = transaction.object.get("data") orelse .null;
                const gas = transaction.object.get("gasLimit") orelse .null;
                const value = transaction.object.get("value") orelse .null;
                if (data == .array and gas == .array and value == .array) {
                    return runStaticStateTest(allocator, test_case, expectations, data.array.items, gas.array.items, value.array.items);
                }
            }
        }
    }

    // A fork-keyed `post` runs every fork it lists, each on a fresh host.
    var forks: std.ArrayList(Hardfork) = .{};
    defer forks.deinit(allocator);
    if (try postForks(allocator, test_case, &forks)) {
        var skipped: usize = 0;
        for (forks.items) |hf| {
            runJsonTestImplForFork(allocator, test_case, null, hf) catch |err| {
                if (err == error.SkipZigTest) {
                    skipped += 1;
                    continue;
                }
                std.debug.print("fork {s} failed: {s}\n", .{ hardforkToString(hf), @errorName(err) });
                generateTraceDiffOnFailure(allocator, test_case, test_file_path, test_name) catch |trace_err| {
                    std.debug.print("Warning: Failed to generate trace diff for failed test: {}\n", .{trace_err});
                };
                return err;
            };
        }
        // Skip only when no fork could be checked.
        if (skipped == forks.items.len) return error.SkipZigTest;
        return;
    }

    // No fork-keyed post section - use original logic
    runJsonTestImpl(allocator, test_case, null) catch |err| {
        if (err == error.SkipZigTest) return err;
        generateTraceDiffOnFailure(allocator, test_case, test_file_path, test_name) catch |trace_err| {
            std.debug.print("Warning: Failed to generate trace diff for failed test: {}\n", .{trace_err});
        };
        return err;
    };
}

fn matchesFixtureFork(fork: Hardfork, constraints: []const u8) !bool {
    var rest = std.mem.trim(u8, constraints, " \t");
    if (rest.len == 0) return error.InvalidFixtureFork;
    while (rest.len != 0) {
        const op_end = std.mem.indexOfNone(u8, rest, "<>=") orelse return error.InvalidFixtureFork;
        const op = rest[0..op_end];
        rest = rest[op_end..];
        const fork_end = std.mem.indexOfAny(u8, rest, "<>=") orelse rest.len;
        const label = std.mem.trim(u8, rest[0..fork_end], " \t");
        const bound = Hardfork.fromString(label) orelse return error.InvalidFixtureFork;
        const order = std.math.order(@intFromEnum(fork), @intFromEnum(bound));
        const matches = if (std.mem.eql(u8, op, ">="))
            order != .lt
        else if (std.mem.eql(u8, op, "<="))
            order != .gt
        else if (std.mem.eql(u8, op, ">"))
            order == .gt
        else if (std.mem.eql(u8, op, "<"))
            order == .lt
        else if (op.len == 0 or std.mem.eql(u8, op, "="))
            order == .eq
        else
            return error.InvalidFixtureFork;
        if (!matches) return false;
        rest = rest[fork_end..];
    }
    return true;
}

fn matchesFixtureIndex(selector: std.json.Value, index: usize, value: std.json.Value) !bool {
    return switch (selector) {
        .integer => |n| n == -1 or (n >= 0 and @as(u64, @intCast(n)) == index),
        .array => |choices| for (choices.items) |choice| {
            if (try matchesFixtureIndex(choice, index, value)) break true;
        } else false,
        .string => |label| blk: {
            if (!std.mem.startsWith(u8, label, ":label ")) return error.InvalidFixtureIndex;
            if (value != .string or !std.mem.startsWith(u8, value.string, label)) break :blk false;
            break :blk value.string.len == label.len or std.ascii.isWhitespace(value.string[label.len]);
        },
        else => error.InvalidFixtureIndex,
    };
}

fn runStaticStateTest(
    allocator: std.mem.Allocator,
    test_case: std.json.Value,
    expectations: std.json.Value,
    data: []const std.json.Value,
    gas: []const std.json.Value,
    value: []const std.json.Value,
) !void {
    var fixture = try test_case.object.cloneWithAllocator(allocator);
    defer fixture.deinit();
    var tx = try test_case.object.get("transaction").?.object.cloneWithAllocator(allocator);
    defer tx.deinit();
    var sender_hex: [42]u8 = undefined;
    if (!tx.contains("sender")) {
        if (tx.get("secretKey")) |key| {
            sender_hex = (try fixtureSenderFromSecretKey(key.string)).toHex();
            try tx.put("sender", .{ .string = &sender_hex });
        }
    }
    var selected_expectation = std.json.Array.init(allocator);
    defer selected_expectation.deinit();
    try selected_expectation.append(.null);

    var covered = false;
    for (expectations.array.items) |expectation| {
        selected_expectation.items[0] = expectation;
        fixture.getPtr("expect").?.* = .{ .array = selected_expectation };
        const network = expectation.object.get("network") orelse return error.MissingFixtureFork;
        const indexes = expectation.object.get("indexes");
        const all = std.json.Value{ .integer = -1 };
        const data_index = if (indexes) |idx| idx.object.get("data") orelse all else all;
        const gas_index = if (indexes) |idx| idx.object.get("gas") orelse all else all;
        const value_index = if (indexes) |idx| idx.object.get("value") orelse all else all;

        for (std.enums.values(Hardfork)) |fork| {
            const applies = if (network == .array) blk: {
                for (network.array.items) |range| {
                    if (try matchesFixtureFork(fork, range.string)) break :blk true;
                }
                break :blk false;
            } else try matchesFixtureFork(fork, network.string);
            if (!applies) continue;

            for (data, 0..) |d, di| {
                if (!try matchesFixtureIndex(data_index, di, d)) continue;
                tx.getPtr("data").?.* = d;
                for (gas, 0..) |g, gi| {
                    if (!try matchesFixtureIndex(gas_index, gi, g)) continue;
                    tx.getPtr("gasLimit").?.* = g;
                    for (value, 0..) |v, vi| {
                        if (!try matchesFixtureIndex(value_index, vi, v)) continue;
                        tx.getPtr("value").?.* = v;
                        fixture.getPtr("transaction").?.* = .{ .object = tx };
                        runJsonTestImplForFork(allocator, .{ .object = fixture }, null, fork) catch |err| {
                            std.debug.print("State fixture variant {s} d{d}g{d}v{d}: {s}\n", .{ @tagName(fork), di, gi, vi, @errorName(err) });
                            return err;
                        };
                        covered = true;
                    }
                }
            }
        }
    }
    if (!covered) return error.NoFixtureVariants;
}

fn staticTransactionException(test_case: std.json.Value, fork: Hardfork) !?[]const u8 {
    const expectations = test_case.object.get("expect") orelse return null;
    if (expectations != .array or expectations.array.items.len == 0) return null;
    const exceptions = expectations.array.items[0].object.get("expectException") orelse return null;
    var entries = exceptions.object.iterator();
    while (entries.next()) |entry| {
        if (try matchesFixtureFork(fork, entry.key_ptr.*)) return entry.value_ptr.string;
    }
    return null;
}

test "static fixture fork and transaction selectors" {
    try testing.expect(try matchesFixtureFork(.CANCUN, ">=Cancun<Osaka"));
    try testing.expect(try matchesFixtureFork(.PRAGUE, ">=Cancun<Osaka"));
    try testing.expect(!try matchesFixtureFork(.OSAKA, ">=Cancun<Osaka"));
    try testing.expect(!try matchesFixtureFork(.CANCUN, "Prague"));

    try testing.expect(try matchesFixtureIndex(.{ .integer = -1 }, 2, .null));
    try testing.expect(!try matchesFixtureIndex(.{ .integer = 0 }, 2, .null));
    try testing.expect(try matchesFixtureIndex(.{ .string = ":label second" }, 2, .{ .string = ":label second :raw 0xff" }));
    try testing.expect(!try matchesFixtureIndex(.{ .string = ":label second" }, 2, .{ .string = ":label secondary :raw 0xff" }));
}

/// Collects the forks of a fork-keyed `post` section into `forks`, in key
/// order. Returns false when `post` is absent or address-keyed. A key that
/// is neither a supported fork nor an address fails the fixture instead of
/// dropping that fork's expectations.
fn postForks(allocator: std.mem.Allocator, test_case: std.json.Value, forks: *std.ArrayList(Hardfork)) !bool {
    const post = test_case.object.get("post") orelse return false;
    if (post != .object) return false;
    var unsupported: ?[]const u8 = null;
    var it = post.object.iterator();
    while (it.next()) |kv| {
        if (Hardfork.fromString(kv.key_ptr.*)) |hf| {
            try forks.append(allocator, hf);
        } else if (parseAddress(kv.key_ptr.*)) |_| {
            // Address-keyed listing.
        } else |_| {
            unsupported = unsupported orelse kv.key_ptr.*;
        }
    }
    if (forks.items.len == 0) {
        if (unsupported) |key| {
            std.debug.print("post section names unsupported fork {s}\n", .{key});
            return error.UnsupportedPostFork;
        }
        return false;
    }
    if (unsupported) |key| {
        std.debug.print("post section names unsupported fork {s}\n", .{key});
        return error.UnsupportedPostFork;
    }
    return true;
}

// Helper to run test with a specific hardfork (for multi-fork tests)
fn runJsonTestImplForFork(allocator: std.mem.Allocator, test_case: std.json.Value, tracer: ?*trace.Tracer, forced_hardfork: Hardfork) !void {
    // Just call runJsonTestImpl with modified extractHardfork behavior
    // We'll modify runJsonTestImpl to accept an optional forced hardfork parameter
    try runJsonTestImplWithOptionalFork(allocator, test_case, tracer, forced_hardfork);
}

fn traceNumber(comptime T: type, value: std.json.Value) !T {
    return switch (value) {
        .integer => |number| std.math.cast(T, number) orelse error.InvalidTraceNumber,
        .string => |number| std.fmt.parseInt(T, number, 0),
        .number_string => |number| std.fmt.parseInt(T, number, 10),
        else => error.InvalidTraceNumber,
    };
}

fn traceHexBytes(allocator: std.mem.Allocator, value: std.json.Value) ![]const u8 {
    if (value != .string) return error.InvalidTraceBytes;
    const hex = if (std.mem.startsWith(u8, value.string, "0x")) value.string[2..] else value.string;
    if (hex.len % 2 != 0) return error.InvalidTraceBytes;
    const bytes = try allocator.alloc(u8, hex.len / 2);
    errdefer allocator.free(bytes);
    return std.fmt.hexToBytes(bytes, hex);
}

fn parseReferenceTraceStep(allocator: std.mem.Allocator, obj: std.json.ObjectMap) !trace.TraceEntry {
    var entry: trace.TraceEntry = .{
        .pc = try traceNumber(u64, obj.get("pc") orelse return error.MissingTraceField),
        .op = try traceNumber(u8, obj.get("op") orelse return error.MissingTraceField),
        .gas = try traceNumber(u64, obj.get("gas") orelse return error.MissingTraceField),
        .gasCost = try traceNumber(u64, obj.get("gasCost") orelse return error.MissingTraceField),
        .memSize = try traceNumber(usize, obj.get("memSize") orelse return error.MissingTraceField),
        .depth = try traceNumber(usize, obj.get("depth") orelse return error.MissingTraceField),
        .refund = try traceNumber(i64, obj.get("refund") orelse .{ .integer = 0 }),
        .memory = null,
        .stack = &.{},
        .returnData = &.{},
        .opName = "",
    };
    errdefer entry.deinit(allocator);

    if (obj.get("stack")) |value| {
        if (value != .array) return error.InvalidTraceStack;
        const stack = try allocator.alloc(u256, value.array.items.len);
        entry.stack = stack;
        for (stack, value.array.items) |*item, number| item.* = try traceNumber(u256, number);
    }
    if (obj.get("returnData")) |value| {
        if (value != .null) entry.returnData = try traceHexBytes(allocator, value);
    }
    if (obj.get("opName")) |value| {
        if (value == .string) {
            entry.opName = try allocator.dupe(u8, value.string);
            entry.op_name_owned = true;
        }
    }
    if (obj.get("error")) |value| {
        if (value == .string) {
            entry.error_msg = try allocator.dupe(u8, value.string);
            entry.error_msg_owned = true;
        }
    }
    return entry;
}

test "reference trace parser preserves stack, return data and faults" {
    const allocator = std.testing.allocator;
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator,
        \\{"pc":3,"op":253,"gas":"0xa","gasCost":0,"memSize":32,"depth":2,"refund":0,
        \\"stack":["0x20","0x0"],"returnData":"0x002a","error":"execution reverted"}
    , .{});
    defer parsed.deinit();

    const entry = try parseReferenceTraceStep(allocator, parsed.value.object);
    defer entry.deinit(allocator);
    try std.testing.expectEqual(@as(u64, 10), entry.gas);
    try std.testing.expectEqualSlices(u256, &.{ 32, 0 }, entry.stack);
    try std.testing.expectEqualSlices(u8, &.{ 0, 42 }, entry.returnData.?);
    try std.testing.expectEqualStrings("execution reverted", entry.error_msg.?);
}

fn generateTraceDiffOnFailure(allocator: std.mem.Allocator, test_case: std.json.Value, opt_test_file_path: ?[]const u8, opt_test_name: ?[]const u8) !void {
    _ = opt_test_name; // Currently unused parameter

    // Re-run with trace capture
    var tracer = trace.Tracer.init(allocator);
    defer tracer.deinit();
    tracer.config.enable_return_data = true;
    tracer.config.disable_memory = true;
    tracer.config.disable_storage = true;
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

        // Summary records do not have a program counter.
        if (parsed.value != .object or !parsed.value.object.contains("pc")) continue;
        const entry = try parseReferenceTraceStep(allocator, parsed.value.object);
        errdefer entry.deinit(allocator);
        try ref_tracer.entries.append(allocator, entry);
    }

    var diff = try trace.TraceDiff.compare(allocator, &tracer, &ref_tracer);
    defer diff.deinit(allocator);

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
        .AMSTERDAM => "Amsterdam",
    };
}

test "hardforkToString names every Hardfork that fromString parses back" {
    for (std.enums.values(Hardfork)) |hf| {
        try testing.expectEqual(@as(?Hardfork, hf), Hardfork.fromString(hardforkToString(hf)));
    }
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

/// One state-test case. A post entry's `indexes` select the data, gas and
/// value alternatives of the shared transaction; `accessLists` follows data.
const Variant = struct {
    data: usize = 0,
    gas: usize = 0,
    value: usize = 0,
    /// The post entry this case is checked against; null for fixtures
    /// without fork-keyed post entries.
    post_entry: ?std.json.Value = null,

    fn fromPostEntry(entry: std.json.Value) !Variant {
        var variant = Variant{ .post_entry = entry };
        if (entry != .object) return variant;
        const indexes = entry.object.get("indexes") orelse return variant;
        if (indexes != .object) return error.InvalidPostIndexes;
        if (indexes.object.get("data")) |i| variant.data = try parseIntFromJson(i);
        if (indexes.object.get("gas")) |i| variant.gas = try parseIntFromJson(i);
        if (indexes.object.get("value")) |i| variant.value = try parseIntFromJson(i);
        return variant;
    }

    fn expectedException(self: Variant) ?[]const u8 {
        const entry = self.post_entry orelse return null;
        if (entry != .object) return null;
        const exception = entry.object.get("expectException") orelse return null;
        return if (exception == .string) exception.string else null;
    }

    /// True when this case expects `rejection`.
    fn expects(self: Variant, rejection: TxRejection) bool {
        const expected = self.expectedException() orelse return false;
        return rejection.matches(expected);
    }
};

/// Returns alternative `index` of a transaction field that is either a
/// scalar or an array of alternatives.
fn selectAlternative(field: std.json.Value, index: usize) !std.json.Value {
    if (field != .array) return field;
    if (index >= field.array.items.len) return error.InvalidVariantIndex;
    return field.array.items[index];
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
            inline for (&[_][]const u8{ "Osaka", "Prague", "Cancun", "Shanghai", "Paris", "Merge", "London", "Berlin", "Istanbul", "ConstantinopleFix", "Constantinople", "Byzantium", "Homestead" }) |fork_name| {
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

/// Base intrinsic gas: 21000, plus the 32000 creation surcharge from
/// Homestead (Frontier charged creation like a call).
fn createAwareBaseGas(hf: Hardfork, is_create: bool) u64 {
    if (is_create and hf.isAtLeast(.HOMESTEAD)) return primitives.GasConstants.TxGasContractCreation;
    return primitives.GasConstants.TxGas;
}

/// Deep copy of a test host's account state, used to prove that a rejected
/// transaction left state untouched.
const HostSnapshot = struct {
    allocator: std.mem.Allocator,
    balances: std.AutoHashMap(Address, u256),
    nonces: std.AutoHashMap(Address, u64),
    code: std.AutoHashMap(Address, []const u8),
    storage: std.AutoHashMap(StorageSlotKey, u256),

    fn capture(allocator: std.mem.Allocator, host: *TestHost) !HostSnapshot {
        var balances = try host.balances.clone();
        errdefer balances.deinit();
        var nonces = try host.nonces.clone();
        errdefer nonces.deinit();
        var storage = try host.storage.clone();
        errdefer storage.deinit();
        var snapshot = HostSnapshot{
            .allocator = allocator,
            .balances = balances,
            .nonces = nonces,
            .code = std.AutoHashMap(Address, []const u8).init(allocator),
            .storage = storage,
        };
        errdefer snapshot.freeCode();
        var it = host.code.iterator();
        while (it.next()) |kv| {
            const owned = try allocator.dupe(u8, kv.value_ptr.*);
            errdefer allocator.free(owned);
            try snapshot.code.put(kv.key_ptr.*, owned);
        }
        return snapshot;
    }

    fn freeCode(self: *HostSnapshot) void {
        var it = self.code.valueIterator();
        while (it.next()) |code| self.allocator.free(code.*);
        self.code.deinit();
    }

    fn deinit(self: *HostSnapshot) void {
        self.freeCode();
        self.balances.deinit();
        self.nonces.deinit();
        self.storage.deinit();
    }

    /// Replaces the host's accounts with the snapshot's, discarding every
    /// change made since `capture` (a rejected block's effects).
    fn restore(self: *const HostSnapshot, host: *TestHost) !void {
        var balances = try self.balances.clone();
        errdefer balances.deinit();
        var nonces = try self.nonces.clone();
        errdefer nonces.deinit();
        var storage = try self.storage.clone();
        errdefer storage.deinit();
        var code = std.AutoHashMap(Address, []const u8).init(host.allocator);
        errdefer {
            var values = code.valueIterator();
            while (values.next()) |bytes| host.allocator.free(bytes.*);
            code.deinit();
        }
        var it = self.code.iterator();
        while (it.next()) |kv| {
            const owned = try host.allocator.dupe(u8, kv.value_ptr.*);
            errdefer host.allocator.free(owned);
            try code.put(kv.key_ptr.*, owned);
        }

        var old_code = host.code.valueIterator();
        while (old_code.next()) |bytes| host.allocator.free(bytes.*);
        host.code.deinit();
        host.balances.deinit();
        host.nonces.deinit();
        host.storage.deinit();
        host.code = code;
        host.balances = balances;
        host.nonces = nonces;
        host.storage = storage;
    }

    /// Fails when any balance, nonce, code or storage slot differs from the
    /// snapshot. Missing entries compare as zero or empty.
    fn expectUnchanged(self: *const HostSnapshot, host: *TestHost) !void {
        if (!sameValues(Address, u256, &self.balances, &host.balances) or
            !sameValues(Address, u64, &self.nonces, &host.nonces) or
            !sameValues(StorageSlotKey, u256, &self.storage, &host.storage) or
            !sameCode(&self.code, &host.code) or !sameCode(&host.code, &self.code))
        {
            std.debug.print("a rejected transaction changed the pre-state\n", .{});
            return error.StateMutatedByRejectedTransaction;
        }
    }

    fn sameValues(comptime K: type, comptime V: type, a: *const std.AutoHashMap(K, V), b: *const std.AutoHashMap(K, V)) bool {
        var it_a = a.iterator();
        while (it_a.next()) |kv| {
            if ((b.get(kv.key_ptr.*) orelse 0) != kv.value_ptr.*) return false;
        }
        var it_b = b.iterator();
        while (it_b.next()) |kv| {
            if ((a.get(kv.key_ptr.*) orelse 0) != kv.value_ptr.*) return false;
        }
        return true;
    }

    fn sameCode(a: *const std.AutoHashMap(Address, []const u8), b: *const std.AutoHashMap(Address, []const u8)) bool {
        var it = a.iterator();
        while (it.next()) |kv| {
            if (!std.mem.eql(u8, b.get(kv.key_ptr.*) orelse &[_]u8{}, kv.value_ptr.*)) return false;
        }
        return true;
    }
};

/// True when the host holds a nonzero balance, nonce, code or storage slot
/// for `address`. Empty accounts are absent from a post-state listing.
fn hostAccountNonEmpty(host: *TestHost, address: Address) bool {
    if ((host.balances.get(address) orelse 0) != 0) return true;
    if (host.getNonce(address) != 0) return true;
    if ((host.code.get(address) orelse &[_]u8{}).len != 0) return true;
    var it = host.storage.iterator();
    while (it.next()) |kv| {
        if (kv.key_ptr.address.equals(address) and kv.value_ptr.* != 0) return true;
    }
    return false;
}

fn postStateLists(expected_state: std.json.Value, address: Address) !bool {
    var it = expected_state.object.iterator();
    while (it.next()) |kv| {
        if ((try parseAddress(kv.key_ptr.*)).equals(address)) return true;
    }
    return false;
}

fn expectListed(host: *TestHost, expected_state: std.json.Value, address: Address) !void {
    if (!hostAccountNonEmpty(host, address)) return;
    if (try postStateLists(expected_state, address)) return;
    std.debug.print("UNEXPECTED ACCOUNT: addr={any} is not in the expected post state\n", .{address.bytes});
    return error.UnexpectedAccountInPostState;
}

/// A post entry's `state` lists every account: fail on any other nonempty
/// account in the host.
fn expectNoUnlistedAccounts(host: *TestHost, expected_state: std.json.Value) !void {
    if (expected_state != .object) return error.InvalidPostState;
    var balances = host.balances.keyIterator();
    while (balances.next()) |address| try expectListed(host, expected_state, address.*);
    var nonces = host.nonces.keyIterator();
    while (nonces.next()) |address| try expectListed(host, expected_state, address.*);
    var code = host.code.keyIterator();
    while (code.next()) |address| try expectListed(host, expected_state, address.*);
    var storage = host.storage.keyIterator();
    while (storage.next()) |key| try expectListed(host, expected_state, key.address);
}

fn expectCode(allocator: std.mem.Allocator, host: *TestHost, address: Address, expected_json: std.json.Value) !void {
    if (expected_json != .string) return error.InvalidPostState;
    const hex = expected_json.string;
    const expected: []u8 = if (hex.len <= 2) try allocator.alloc(u8, 0) else try primitives.Hex.hexToBytes(allocator, hex);
    defer allocator.free(expected);
    const actual = host.code.get(address) orelse &[_]u8{};
    if (!std.mem.eql(u8, expected, actual)) {
        std.debug.print("CODE MISMATCH: addr={any} expected {x}, found {x}\n", .{ address.bytes, expected, actual });
        return error.CodeMismatch;
    }
}

fn freeAccessList(allocator: std.mem.Allocator, entries: []const primitives.AccessList.AccessListEntry) void {
    for (entries) |entry| allocator.free(entry.storage_keys);
    allocator.free(entries);
}

/// Parses a fixture access list (`[{address, storageKeys}]`). Entries
/// without an address are ignored. On error nothing leaks and no
/// uninitialized entry is freed: only the `initialized` prefix owns keys.
fn parseAccessListJson(allocator: std.mem.Allocator, items: []const std.json.Value) ![]primitives.AccessList.AccessListEntry {
    var addr_count: usize = 0;
    for (items) |entry| {
        if (entry != .object) return error.InvalidAccessList;
        if (entry.object.get("address") != null) addr_count += 1;
    }

    const entries = try allocator.alloc(primitives.AccessList.AccessListEntry, addr_count);
    var initialized: usize = 0;
    errdefer {
        for (entries[0..initialized]) |entry| allocator.free(entry.storage_keys);
        allocator.free(entries);
    }

    for (items) |entry| {
        const addr_json = entry.object.get("address") orelse continue;
        if (addr_json != .string) return error.InvalidAccessList;
        const addr = try parseAddress(addr_json.string);

        const keys_json: []const std.json.Value = if (entry.object.get("storageKeys")) |keys|
            if (keys == .array) keys.array.items else &.{}
        else
            &.{};
        const storage_keys = try allocator.alloc([32]u8, keys_json.len);
        errdefer allocator.free(storage_keys);
        for (keys_json, storage_keys) |key_json, *key| {
            if (key_json != .string) return error.InvalidAccessList;
            const slot = try std.fmt.parseInt(u256, key_json.string, 0);
            std.mem.writeInt(u256, key, slot, .big);
        }

        entries[initialized] = .{ .address = addr, .storage_keys = storage_keys };
        initialized += 1;
    }
    return entries;
}

// ---------------------------------------------------------------- RLP

/// One RLP item at the start of a byte string.
const RlpItem = struct {
    /// Header plus payload length.
    encoded_len: usize,
    payload: []const u8,
    is_list: bool,
};

fn rlpItem(bytes: []const u8) !RlpItem {
    if (bytes.len == 0) return error.InvalidRlp;
    const prefix = bytes[0];
    if (prefix < 0x80) return .{ .encoded_len = 1, .payload = bytes[0..1], .is_list = false };
    const is_list = prefix >= 0xc0;
    const short: usize = prefix - @as(u8, if (is_list) 0xc0 else 0x80);
    var header: usize = 1;
    var len: usize = short;
    if (short > 55) {
        const len_of_len = short - 55;
        if (len_of_len > @sizeOf(usize) or bytes.len < 1 + len_of_len) return error.InvalidRlp;
        len = 0;
        for (bytes[1 .. 1 + len_of_len]) |b| len = (len << 8) | b;
        header += len_of_len;
    }
    if (bytes.len - header < len) return error.InvalidRlp;
    return .{ .encoded_len = header + len, .payload = bytes[header .. header + len], .is_list = is_list };
}

/// Splits a list payload into the raw encodings of its items.
fn rlpListItems(allocator: std.mem.Allocator, payload: []const u8) ![]const []const u8 {
    var items: std.ArrayList([]const u8) = .{};
    errdefer items.deinit(allocator);
    var rest = payload;
    while (rest.len > 0) {
        const item = try rlpItem(rest);
        try items.append(allocator, rest[0..item.encoded_len]);
        rest = rest[item.encoded_len..];
    }
    return items.toOwnedSlice(allocator);
}

/// Decodes a big-endian unsigned integer item.
fn rlpUint(comptime T: type, raw: []const u8) !T {
    const item = try rlpItem(raw);
    if (item.is_list or item.payload.len > @sizeOf(T)) return error.InvalidTransactionFormat;
    var value: T = 0;
    for (item.payload) |b| value = (value << 8) | b;
    return value;
}

fn rlpAppendHeader(out: *std.ArrayList(u8), allocator: std.mem.Allocator, offset: u8, len: usize) !void {
    if (len < 56) return out.append(allocator, offset + @as(u8, @intCast(len)));
    var buf: [@sizeOf(usize)]u8 = undefined;
    std.mem.writeInt(usize, &buf, len, .big);
    const skip = @clz(len) / 8;
    try out.append(allocator, offset + 55 + @as(u8, @intCast(buf.len - skip)));
    try out.appendSlice(allocator, buf[skip..]);
}

fn rlpAppendString(out: *std.ArrayList(u8), allocator: std.mem.Allocator, bytes: []const u8) !void {
    if (bytes.len == 1 and bytes[0] < 0x80) return out.append(allocator, bytes[0]);
    try rlpAppendHeader(out, allocator, 0x80, bytes.len);
    try out.appendSlice(allocator, bytes);
}

fn rlpAppendUint(out: *std.ArrayList(u8), allocator: std.mem.Allocator, value: u256) !void {
    var buf: [32]u8 = undefined;
    std.mem.writeInt(u256, &buf, value, .big);
    try rlpAppendString(out, allocator, buf[@clz(value) / 8 ..]);
}

/// keccak256 of `prefix ++ rlp(list(items))`, where items are raw encodings.
fn hashRlpList(allocator: std.mem.Allocator, prefix: []const u8, items: []const []const u8) ![32]u8 {
    var payload_len: usize = 0;
    for (items) |item| payload_len += item.len;
    var out: std.ArrayList(u8) = .{};
    defer out.deinit(allocator);
    try out.appendSlice(allocator, prefix);
    try rlpAppendHeader(&out, allocator, 0xc0, payload_len);
    for (items) |item| try out.appendSlice(allocator, item);
    var hash: [32]u8 = undefined;
    std.crypto.hash.sha3.Keccak256.hash(out.items, &hash, .{});
    return hash;
}

/// keccak256(rlp(logs)), each log encoded as [address, [topics], data].
fn logsHash(allocator: std.mem.Allocator, logs: []const evm_mod.Log) ![32]u8 {
    var encoded: std.ArrayList([]const u8) = .{};
    defer {
        for (encoded.items) |item| allocator.free(item);
        encoded.deinit(allocator);
    }
    for (logs) |log| {
        var topics: std.ArrayList(u8) = .{};
        defer topics.deinit(allocator);
        for (log.topics) |topic| {
            var buf: [32]u8 = undefined;
            std.mem.writeInt(u256, &buf, topic, .big);
            try rlpAppendString(&topics, allocator, &buf);
        }
        var fields: std.ArrayList(u8) = .{};
        defer fields.deinit(allocator);
        try rlpAppendString(&fields, allocator, &log.address.bytes);
        try rlpAppendHeader(&fields, allocator, 0xc0, topics.items.len);
        try fields.appendSlice(allocator, topics.items);
        try rlpAppendString(&fields, allocator, log.data);

        var item: std.ArrayList(u8) = .{};
        errdefer item.deinit(allocator);
        try rlpAppendHeader(&item, allocator, 0xc0, fields.items.len);
        try item.appendSlice(allocator, fields.items);
        const owned = try item.toOwnedSlice(allocator);
        errdefer allocator.free(owned);
        try encoded.append(allocator, owned);
    }
    return hashRlpList(allocator, &.{}, encoded.items);
}

fn expectLogsHash(allocator: std.mem.Allocator, expected_json: std.json.Value, logs: []const evm_mod.Log) !void {
    const expected = try parseFixedHexBytes(32, allocator, expected_json);
    const actual = try logsHash(allocator, logs);
    if (!std.mem.eql(u8, &expected, &actual)) {
        std.debug.print("LOGS HASH MISMATCH: expected {x}, found {x} ({d} logs)\n", .{ expected, actual, logs.len });
        return error.LogsHashMismatch;
    }
}

/// Recovers a transaction sender from its signature over `hash`. Returns
/// null for an invalid signature; from Homestead (EIP-2) s must be low.
fn recoverTxSender(hf: Hardfork, hash: [32]u8, y_parity: u256, r: u256, s: u256) ?Address {
    if (y_parity > 1) return null;
    if (r == 0 or r >= SECP256K1N) return null;
    if (s == 0 or s >= SECP256K1N) return null;
    if (hf.isAtLeast(.HOMESTEAD) and s > SECP256K1N / 2) return null;
    const signature = primitives.crypto.Crypto.Signature{ .r = r, .s = s, .v = @intCast(y_parity) };
    return primitives.crypto.Crypto.unaudited_recoverAddress(hash, signature) catch null;
}

/// A decoded, signature-checked raw transaction (legacy, EIP-2930 or EIP-1559).
const RawTransaction = struct {
    sender: Address,
    /// Signed chain id: typed envelopes and EIP-155 legacy transactions.
    /// Null only for pre-EIP-155 legacy signatures (v = 27 or 28).
    chain_id: ?u256,
    nonce: u64,
    /// Legacy and EIP-2930 use gas_price for both fee fields.
    max_fee_per_gas: u256,
    max_priority_fee_per_gas: u256,
    is_fee_market: bool,
    gas_limit: u64,
    /// Null for contract creation. The zero address is a real destination.
    to: ?Address,
    value: u256,
    data: []const u8,
    access_list: []primitives.AccessList.AccessListEntry,
    storage_key_count: usize,

    fn deinit(self: *RawTransaction, allocator: std.mem.Allocator) void {
        for (self.access_list) |entry| allocator.free(entry.storage_keys);
        allocator.free(self.access_list);
    }
};

/// Decodes a signed transaction envelope and recovers its sender. `raw`
/// must outlive the result (`data` borrows from it).
fn decodeRawTransaction(allocator: std.mem.Allocator, hf: Hardfork, raw: []const u8) !RawTransaction {
    if (raw.len == 0) return error.InvalidTransactionFormat;
    const tx_type: u8 = if (raw[0] < 0x80) raw[0] else 0;
    switch (tx_type) {
        0 => {},
        1 => if (hf.isBefore(.BERLIN)) return error.TransactionTypeNotActive,
        2 => if (hf.isBefore(.LONDON)) return error.TransactionTypeNotActive,
        // Blob and set-code envelopes need sidecar and authorization admission.
        else => return error.UnsupportedTransactionType,
    }
    const body = if (tx_type == 0) raw else raw[1..];
    const outer = try rlpItem(body);
    if (!outer.is_list or outer.encoded_len != body.len) return error.InvalidTransactionFormat;
    const fields = try rlpListItems(allocator, outer.payload);
    defer allocator.free(fields);

    const field_count: usize = switch (tx_type) {
        0 => 9,
        1 => 11,
        else => 12,
    };
    if (fields.len != field_count) return error.InvalidTransactionFormat;

    // Typed fields start with the chain id.
    const base: usize = if (tx_type == 0) 0 else 1;
    const fee_fields: usize = if (tx_type == 2) 2 else 1;
    const gas_limit_idx = base + 1 + fee_fields;

    var tx: RawTransaction = undefined;
    tx.chain_id = if (tx_type == 0) null else try rlpUint(u256, fields[0]);
    tx.nonce = try rlpUint(u64, fields[base]);
    tx.is_fee_market = tx_type == 2;
    if (tx_type == 2) {
        tx.max_priority_fee_per_gas = try rlpUint(u256, fields[2]);
        tx.max_fee_per_gas = try rlpUint(u256, fields[3]);
    } else {
        tx.max_fee_per_gas = try rlpUint(u256, fields[base + 1]);
        tx.max_priority_fee_per_gas = tx.max_fee_per_gas;
    }
    tx.gas_limit = try rlpUint(u64, fields[gas_limit_idx]);
    const to_item = try rlpItem(fields[gas_limit_idx + 1]);
    if (to_item.is_list) return error.InvalidTransactionFormat;
    tx.to = switch (to_item.payload.len) {
        0 => null,
        20 => Address{ .bytes = to_item.payload[0..20].* },
        else => return error.InvalidTransactionFormat,
    };
    tx.value = try rlpUint(u256, fields[gas_limit_idx + 2]);
    const data_item = try rlpItem(fields[gas_limit_idx + 3]);
    if (data_item.is_list) return error.InvalidTransactionFormat;
    tx.data = data_item.payload;

    // Signature and signing hash.
    const v = try rlpUint(u256, fields[field_count - 3]);
    const r = try rlpUint(u256, fields[field_count - 2]);
    const s = try rlpUint(u256, fields[field_count - 1]);
    var y_parity: u256 = undefined;
    var signing_hash: [32]u8 = undefined;
    if (tx_type == 0) {
        if (v == 27 or v == 28) {
            y_parity = v - 27;
            signing_hash = try hashRlpList(allocator, &.{}, fields[0..6]);
        } else if (v >= 35 and hf.isAtLeast(.SPURIOUS_DRAGON)) {
            // EIP-155: sign [nonce, gasPrice, gas, to, value, data, chainId, 0, 0].
            y_parity = (v - 35) % 2;
            tx.chain_id = (v - 35) / 2;
            var chain_fields: std.ArrayList(u8) = .{};
            defer chain_fields.deinit(allocator);
            try rlpAppendUint(&chain_fields, allocator, (v - 35) / 2);
            const chain_id_len = chain_fields.items.len;
            try chain_fields.appendSlice(allocator, &.{ 0x80, 0x80 });
            const items = [_][]const u8{
                fields[0],                           fields[1],                                            fields[2],                               fields[3], fields[4], fields[5],
                chain_fields.items[0..chain_id_len], chain_fields.items[chain_id_len .. chain_id_len + 1], chain_fields.items[chain_id_len + 1 ..],
            };
            signing_hash = try hashRlpList(allocator, &.{}, &items);
        } else return error.InvalidTransactionSignature;
    } else {
        y_parity = v;
        signing_hash = try hashRlpList(allocator, &.{tx_type}, fields[0 .. field_count - 3]);
    }
    tx.sender = recoverTxSender(hf, signing_hash, y_parity, r, s) orelse return error.InvalidTransactionSignature;

    // EIP-2930 access list: [[address, [key, ...]], ...].
    tx.storage_key_count = 0;
    if (tx_type == 0) {
        tx.access_list = try allocator.alloc(primitives.AccessList.AccessListEntry, 0);
        return tx;
    }
    const list_item = try rlpItem(fields[gas_limit_idx + 4]);
    if (!list_item.is_list) return error.InvalidTransactionFormat;
    const raw_entries = try rlpListItems(allocator, list_item.payload);
    defer allocator.free(raw_entries);
    const entries = try allocator.alloc(primitives.AccessList.AccessListEntry, raw_entries.len);
    var filled: usize = 0;
    errdefer {
        for (entries[0..filled]) |entry| allocator.free(entry.storage_keys);
        allocator.free(entries);
    }
    for (raw_entries) |raw_entry| {
        const entry_item = try rlpItem(raw_entry);
        if (!entry_item.is_list) return error.InvalidTransactionFormat;
        const parts = try rlpListItems(allocator, entry_item.payload);
        defer allocator.free(parts);
        if (parts.len != 2) return error.InvalidTransactionFormat;
        const address_item = try rlpItem(parts[0]);
        if (address_item.is_list or address_item.payload.len != 20) return error.InvalidTransactionFormat;
        const keys_item = try rlpItem(parts[1]);
        if (!keys_item.is_list) return error.InvalidTransactionFormat;
        const raw_keys = try rlpListItems(allocator, keys_item.payload);
        defer allocator.free(raw_keys);
        const keys = try allocator.alloc([32]u8, raw_keys.len);
        errdefer allocator.free(keys);
        for (raw_keys, keys) |raw_key, *key| {
            const key_item = try rlpItem(raw_key);
            if (key_item.is_list or key_item.payload.len != 32) return error.InvalidTransactionFormat;
            key.* = key_item.payload[0..32].*;
        }
        entries[filled] = .{ .address = .{ .bytes = address_item.payload[0..20].* }, .storage_keys = keys };
        filled += 1;
        tx.storage_key_count += keys.len;
    }
    tx.access_list = entries;
    return tx;
}

/// Executes one raw block transaction: decode, recover the sender, admit it
/// under the fork's rules, buy gas, run it through `Evm.call` (which moves
/// the value once) and settle. Returns the rejection reason, if any, without
/// changing state.
fn processRlpTransaction(
    allocator: std.mem.Allocator,
    evm_instance: anytype,
    test_host: *TestHost,
    rlp_hex: []const u8,
    block_ctx: ?evm_mod.BlockContext,
) !?TxRejection {
    const hf: Hardfork = evm_instance.hardfork;
    const raw = try primitives.Hex.hexToBytes(allocator, rlp_hex);
    defer allocator.free(raw);
    var tx = try decodeRawTransaction(allocator, hf, raw);
    defer tx.deinit(allocator);

    const is_create = tx.to == null;

    // The signed chain id must be the block's chain (EIP-155, EIP-2718).
    if (tx.chain_id) |chain_id| {
        const block_chain_id: u256 = if (block_ctx) |ctx| ctx.chain_id else 1;
        if (chain_id != block_chain_id) return .invalid_chain_id;
    }

    // Fees (EIP-1559 from London).
    const base_fee: u256 = if (hf.isAtLeast(.LONDON)) (if (block_ctx) |ctx| ctx.block_base_fee else 0) else 0;
    if (tx.max_priority_fee_per_gas > tx.max_fee_per_gas) return .priority_fee_above_max_fee;
    if (tx.max_fee_per_gas < base_fee) return .insufficient_max_fee;
    const priority_fee_per_gas = @min(tx.max_priority_fee_per_gas, tx.max_fee_per_gas - base_fee);
    const effective_gas_price = base_fee + priority_fee_per_gas;

    // Intrinsic gas and EIP-7623 floor.
    var intrinsic_gas: u64 = createAwareBaseGas(hf, is_create);
    const non_zero_gas: u64 = if (hf.isBefore(.ISTANBUL)) 68 else primitives.GasConstants.TxDataNonZeroGas;
    var tokens: u64 = 0;
    for (tx.data) |byte| {
        if (byte == 0) {
            intrinsic_gas += primitives.GasConstants.TxDataZeroGas;
            tokens += 1;
        } else {
            intrinsic_gas += non_zero_gas;
            tokens += 4;
        }
    }
    intrinsic_gas += @as(u64, tx.access_list.len) * primitives.AccessList.ACCESS_LIST_ADDRESS_COST;
    intrinsic_gas += @as(u64, tx.storage_key_count) * primitives.AccessList.ACCESS_LIST_STORAGE_KEY_COST;
    if (is_create and hf.isAtLeast(.SHANGHAI)) {
        intrinsic_gas += @as(u64, (tx.data.len + 31) / 32) * primitives.GasConstants.InitcodeWordGas;
    }
    const calldata_floor: u64 = if (hf.isAtLeast(.PRAGUE)) tokens * 10 + primitives.GasConstants.TxGas else 0;
    if (txGasLimitTooLow(tx.gas_limit, intrinsic_gas, calldata_floor)) return .intrinsic_gas;
    if (tx.nonce >= std.math.maxInt(u64)) return .nonce_is_max;
    if (is_create and hf.isAtLeast(.SHANGHAI) and tx.data.len > primitives.GasConstants.MaxInitcodeSize) return .initcode_size;
    if (exceedsTxGasLimitCap(hf, tx.gas_limit)) return .gas_limit_cap;

    // Sender nonce and balance: affordability includes the value, but only
    // gas is bought here.
    if (TxRejection.forNonce(tx.nonce, test_host.getNonce(tx.sender))) |reason| return reason;
    const max_gas_fee = std.math.mul(u256, tx.gas_limit, tx.max_fee_per_gas) catch return .insufficient_funds;
    const required = std.math.add(u256, max_gas_fee, tx.value) catch return .insufficient_funds;
    const sender_balance = test_host.balances.get(tx.sender) orelse 0;
    if (sender_balance < required) return .insufficient_funds;

    try test_host.setNonce(tx.sender, tx.nonce + 1);
    try test_host.setBalance(tx.sender, sender_balance - @as(u256, tx.gas_limit) * effective_gas_price);

    evm_instance.gas_price = effective_gas_price;
    evm_instance.origin = tx.sender;
    evm_instance.setAccessList(tx.access_list);

    const execution_gas = tx.gas_limit - intrinsic_gas;
    const result = if (tx.to) |to| evm_instance.call(.{ .call = .{
        .caller = tx.sender,
        .to = to,
        .value = tx.value,
        .input = tx.data,
        .gas = execution_gas,
    } }) else evm_instance.call(.{ .create = .{
        .caller = tx.sender,
        .value = tx.value,
        .init_code = tx.data,
        .gas = execution_gas,
    } });

    const execution_gas_used = if (result.gas_left > execution_gas) 0 else execution_gas - result.gas_left;
    const refund_counter: u64 = if (evm_instance.gas_refund > 0) @intCast(evm_instance.gas_refund) else 0;
    const settlement = settleTxGas(hf, tx.gas_limit, intrinsic_gas + execution_gas_used, refund_counter, calldata_floor);

    const balance_after = test_host.balances.get(tx.sender) orelse 0;
    try test_host.setBalance(tx.sender, balance_after + @as(u256, settlement.unused_gas) * effective_gas_price);
    if (block_ctx) |ctx| {
        const coinbase_balance = test_host.balances.get(ctx.block_coinbase) orelse 0;
        try test_host.setBalance(ctx.block_coinbase, coinbase_balance + @as(u256, settlement.gas_used) * priority_fee_per_gas);
    }
    return null;
}

/// Chain id for a blockchain fixture: `config.chainid`, else mainnet.
fn fixtureChainId(test_case: std.json.Value) !u256 {
    const config = test_case.object.get("config") orelse return 1;
    if (config != .object) return 1;
    const chain_id = config.object.get("chainid") orelse config.object.get("chainId") orelse return 1;
    return parseU256FromJson(chain_id);
}

/// Execution context of one blockchain-fixture block, from its own header.
fn blockContextFromHeader(test_case: std.json.Value, hardfork: ?Hardfork, header: std.json.Value) !evm_mod.BlockContext {
    if (header != .object) return error.InvalidBlockHeader;
    const h = header.object;
    return .{
        .chain_id = try fixtureChainId(test_case),
        .block_number = if (h.get("number")) |v| try parseIntFromJson(v) else 0,
        .block_timestamp = if (h.get("timestamp")) |v| try parseIntFromJson(v) else 0,
        .block_difficulty = if (h.get("difficulty")) |v| try parseU256FromJson(v) else 0,
        .block_prevrandao = if (h.get("mixHash")) |v| try parseU256FromJson(v) else 0,
        .block_coinbase = if (h.get("coinbase")) |v| try parseAddress(v.string) else primitives.ZERO_ADDRESS,
        .block_gas_limit = if (h.get("gasLimit")) |v| try parseIntFromJson(v) else 30_000_000,
        .block_base_fee = if (h.get("baseFeePerGas")) |v| try parseU256FromJson(v) else 0,
        .blob_base_fee = if (h.get("excessBlobGas")) |v| blobBaseFee(hardfork, try parseIntFromJson(v)) else 0,
    };
}

const SYSTEM_ADDRESS_HEX = "fffffffffffffffffffffffffffffffffffffffe";
const BEACON_ROOTS_ADDRESS_HEX = "000F3df6D732807Ef1319fB7B8bB8522d0Beac02";
const HISTORY_STORAGE_ADDRESS_HEX = "0000F90827F1C53a10cb7A02335B175320002935";

/// Runs one block-start system call (EIP-4788 beacon root, EIP-2935 block
/// hash history) when the system contract has code. Failures are ignored, as
/// in EELS `process_system_transaction` before Prague's strict variant.
fn runSystemCall(allocator: std.mem.Allocator, evm_instance: anytype, test_host: *TestHost, contract_hex: []const u8, input_hex: []const u8) !void {
    const contract = try parseAddress(contract_hex);
    if (test_host.code.get(contract) == null) return;
    const input = try primitives.Hex.hexToBytes(allocator, input_hex);
    defer allocator.free(input);
    _ = evm_instance.call(.{
        .call = .{
            .caller = try parseAddress(SYSTEM_ADDRESS_HEX),
            .to = contract,
            .value = 0,
            .input = input,
            .gas = 30_000_000, // SYSTEM_TRANSACTION_GAS
        },
    });
}

/// Block-start system calls for a block whose context is installed:
/// EIP-4788 from Cancun with `parent_beacon_root_hex`, EIP-2935 from Prague
/// with `parent_hash_hex`.
fn runBlockSystemCalls(
    allocator: std.mem.Allocator,
    evm_instance: anytype,
    test_host: *TestHost,
    hardfork: ?Hardfork,
    parent_beacon_root_hex: ?[]const u8,
    parent_hash_hex: ?[]const u8,
) !void {
    const hf = hardfork orelse return;
    if (hf.isAtLeast(.CANCUN)) {
        if (parent_beacon_root_hex) |root| try runSystemCall(allocator, evm_instance, test_host, BEACON_ROOTS_ADDRESS_HEX, root);
    }
    if (hf.isAtLeast(.PRAGUE)) {
        if (parent_hash_hex) |hash| try runSystemCall(allocator, evm_instance, test_host, HISTORY_STORAGE_ADDRESS_HEX, hash);
    }
}

/// EIP-4895: credits one block's withdrawals (amounts in Gwei).
fn applyBlockWithdrawals(test_host: *TestHost, block: std.json.Value) !void {
    const withdrawals = block.object.get("withdrawals") orelse return;
    if (withdrawals != .array) return error.InvalidWithdrawals;
    for (withdrawals.array.items) |withdrawal| {
        if (withdrawal != .object) return error.InvalidWithdrawals;
        const address_json = withdrawal.object.get("address") orelse return error.InvalidWithdrawals;
        const amount_json = withdrawal.object.get("amount") orelse return error.InvalidWithdrawals;
        const address = try parseAddress(address_json.string);
        const amount_wei = @as(u256, try parseIntFromJson(amount_json)) * 1_000_000_000;
        const balance = test_host.balances.get(address) orelse 0;
        try test_host.setBalance(address, std.math.add(u256, balance, amount_wei) catch return error.WithdrawalBalanceOverflow);
    }
}

fn jsonString(value: ?std.json.Value) ?[]const u8 {
    const v = value orelse return null;
    return if (v == .string) v.string else null;
}

fn runJsonTestImpl(allocator: std.mem.Allocator, test_case: std.json.Value, tracer: ?*trace.Tracer) !void {
    try runJsonTestImplWithOptionalFork(allocator, test_case, tracer, null);
}

/// Runs every case of a fixture: one per `post.<fork>` entry, each on a fresh
/// host built from `pre`. Fixtures without fork-keyed entries run once.
/// Entries the runner cannot check (only a state root) are skipped; the
/// fixture is skipped only when every entry is.
fn runJsonTestImplWithOptionalFork(allocator: std.mem.Allocator, test_case: std.json.Value, tracer: ?*trace.Tracer, forced_hardfork: ?Hardfork) !void {
    if (test_case != .object) return;

    const hardfork = forced_hardfork orelse extractHardfork(test_case);
    const entries: []const std.json.Value = blk: {
        const post = test_case.object.get("post") orelse break :blk &.{};
        const hf = hardfork orelse break :blk &.{};
        const fork_entries = postForkEntries(post, hf) orelse break :blk &.{};
        if (fork_entries != .array) break :blk &.{};
        break :blk fork_entries.array.items;
    };
    if (entries.len == 0) return runVariant(allocator, test_case, tracer, forced_hardfork, .{});

    var skipped: usize = 0;
    for (entries, 0..) |entry, i| {
        const variant = try Variant.fromPostEntry(entry);
        runVariant(allocator, test_case, tracer, forced_hardfork, variant) catch |err| {
            if (err == error.SkipZigTest) {
                skipped += 1;
                continue;
            }
            std.debug.print("post entry {d} (data {d}, gas {d}, value {d}) failed: {s}\n", .{ i, variant.data, variant.gas, variant.value, @errorName(err) });
            return err;
        };
    }
    if (skipped == entries.len) return error.SkipZigTest;
}

/// Runs one fixture case and checks it against `variant.post_entry`.
fn runVariant(allocator: std.mem.Allocator, test_case: std.json.Value, tracer: ?*trace.Tracer, forced_hardfork: ?Hardfork, variant: Variant) !void {
    if (test_case != .object) return;

    // // std.debug.print("DEBUG: Starting test\n", .{});

    // Create test host
    var test_host = try TestHost.init(allocator);
    defer test_host.deinit();

    // Setup pre-state
    if (test_case.object.get("pre")) |pre| {
        if (pre == .object) {
            var it = pre.object.iterator();
            while (it.next()) |kv| {
                if (std.mem.startsWith(u8, kv.key_ptr.*, "//")) continue;
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
                            const code_bytes = try parseFixtureBytecode(allocator, code_str);
                            defer allocator.free(code_bytes);
                            try test_host.setCode(address, code_bytes);
                        }
                    }
                }

                // Set storage
                if (account.object.get("storage")) |storage| {
                    if (storage == .object) {
                        var storage_it = storage.object.iterator();
                        while (storage_it.next()) |storage_kv| {
                            if (std.mem.startsWith(u8, storage_kv.key_ptr.*, "//")) continue;
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
    } else if (test_case.object.get("blocks")) |blocks_json| blk: {
        // Blockchain tests start from the first block's context; each block
        // installs its own before it runs.
        if (blocks_json != .array or blocks_json.array.items.len == 0) break :blk null;
        const header = extractHeaderJson(blocks_json.array.items[0]) orelse break :blk null;
        break :blk try blockContextFromHeader(test_case, hardfork, header);
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

    // State tests and Engine payloads run as one segment of transactions.
    // Blockchain fixtures run block by block (below).
    var transactions_list = std.ArrayList(std.json.Value){};
    defer transactions_list.deinit(allocator);

    if (has_transactions) {
        try transactions_list.appendSlice(allocator, test_case.object.get("transactions").?.array.items);
    } else if (has_transaction) {
        try transactions_list.append(allocator, test_case.object.get("transaction").?);
    } else if (!has_blocks_field and has_engine_payloads) {
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

    const blocks: []const std.json.Value = if (test_case.object.get("blocks")) |blocks_json| blk: {
        if (blocks_json != .array) return error.InvalidBlocks;
        break :blk blocks_json.array.items;
    } else &.{};

    // Engine payloads: block-start system calls for the first payload
    // (EIP-4788 root from params[2], EIP-2935 parent from the genesis hash).
    if (!has_blocks_field and has_engine_payloads) {
        var beacon_root: ?[]const u8 = null;
        if (test_case.object.get("engineNewPayloads")) |payloads| {
            if (payloads == .array and payloads.array.items.len > 0) {
                if (payloads.array.items[0].object.get("params")) |params| {
                    if (params == .array and params.array.items.len >= 3) beacon_root = jsonString(params.array.items[2]);
                }
            }
        }
        const genesis_hash: ?[]const u8 = if (test_case.object.get("genesisBlockHeader")) |genesis| jsonString(genesis.object.get("hash")) else null;
        try runBlockSystemCalls(allocator, &evm_instance, &test_host, hardfork, beacon_root, genesis_hash);
    }

    // The first transaction the runner refused to include, and why.
    var rejection: ?TxRejection = null;
    // Logs of included transactions, for the post entry's `logs` hash.
    var tx_logs: std.ArrayList(evm_mod.Log) = .{};
    defer tx_logs.deinit(allocator);
    // Base fee the transactions see: block header first, then env.
    var tx_base_fee: u256 = block_header_base_fee orelse if (block_ctx) |ctx| ctx.block_base_fee else 0;
    // A negative case must leave state exactly as `pre` set it.
    var pre_snapshot: ?HostSnapshot = if (variant.expectedException() != null)
        try HostSnapshot.capture(allocator, &test_host)
    else
        null;
    defer if (pre_snapshot) |*snapshot| snapshot.deinit();

    // Blockchain fixtures: the last accepted block is the next one's parent.
    var parent_block: ?std.json.Value = test_case.object.get("genesisBlockHeader");
    const segment_count: usize = if (has_blocks_field) blocks.len else 1;
    block_loop: for (0..segment_count) |segment_index| {
        const block: ?std.json.Value = if (has_blocks_field) blocks[segment_index] else null;
        var segment_txs: []const std.json.Value = transactions_list.items;
        // State tests: the post entry's expectation. Blocks: the block's own.
        var expected_exception: ?[]const u8 = variant.expectedException();
        // Pre-block state, restored when the block is rejected.
        var block_snapshot: ?HostSnapshot = null;
        defer if (block_snapshot) |*snapshot| snapshot.deinit();

        if (block) |b| {
            if (b != .object) return error.InvalidBlock;
            expected_exception = jsonString(b.object.get("expectException"));
            if (hardfork) |hf| {
                validateBlockHeaderConstants(allocator, hf, b, parent_block) catch |err| {
                    const names = headerErrorNames(err);
                    const want = expected_exception orelse return err;
                    if (names.len == 0) return err;
                    if (!exceptionNamesAny(want, names)) {
                        std.debug.print("block {d} header failed ({s}) but the fixture expects {s}\n", .{ segment_index, @errorName(err), want });
                        return error.WrongExceptionRaised;
                    }
                    // Rejected header: no body, no withdrawals, parent unchanged.
                    continue :block_loop;
                };
            }
            segment_txs = if (b.object.get("transactions")) |txs|
                (if (txs == .array) txs.array.items else return error.InvalidBlockTransactions)
            else
                &.{};
            const header = extractHeaderJson(b);
            if (header) |h| {
                const ctx = try blockContextFromHeader(test_case, hardfork, h);
                evm_instance.block_context = ctx;
                coinbase = ctx.block_coinbase;
                block_header_base_fee = ctx.block_base_fee;
                tx_base_fee = ctx.block_base_fee;
            }
            block_snapshot = try HostSnapshot.capture(allocator, &test_host);
            if (header) |h| {
                try runBlockSystemCalls(
                    allocator,
                    &evm_instance,
                    &test_host,
                    hardfork,
                    jsonString(h.object.get("parentBeaconBlockRoot")),
                    jsonString(h.object.get("parentHash")),
                );
            }
        }

        tx_loop: for (segment_txs) |tx| {
            // A block is invalid at its first invalid transaction.
            if (block != null and rejection != null) break;

            // Handle RLP-encoded transactions (Engine API format)
            if (tx == .string) {
                if (try processRlpTransaction(allocator, &evm_instance, &test_host, tx.string, evm_instance.block_context)) |reason| {
                    if (block != null) {
                        rejection = reason;
                        break;
                    }
                    // Transactions of accepted payloads must all be valid.
                    std.debug.print("raw block transaction rejected: {s}\n", .{@tagName(reason)});
                    return error.InvalidBlockTransaction;
                }
                continue;
            }

            // Parse transaction data
            const tx_data = if (tx.object.get("data")) |data| blk: {
                const data_str = (try selectAlternative(data, variant.data)).string;
                break :blk try parseFixtureBytecode(allocator, data_str);
            } else try allocator.alloc(u8, 0);
            defer allocator.free(tx_data);

            // Parse value early for sender selection
            const value = if (tx.object.get("value")) |v| blk: {
                const val_str = (try selectAlternative(v, variant.value)).string;
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
            const gas_limit = if (tx.object.get("gasLimit")) |g|
                try parseIntFromJson(try selectAlternative(g, variant.gas))
            else
                1000000;

            // Determine sender
            var sender: Address = primitives.ZERO_ADDRESS;
            if (tx.object.get("sender")) |s| {
                sender = try parseAddress(s.string);
            } else if (tx.object.get("secretKey")) |key| {
                sender = try fixtureSenderFromSecretKey(key.string);
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

            // EIP-7702: a set-code transaction needs Prague, a destination and
            // at least one authorization.
            if (tx.object.get("authorizationList")) |auth_list_json| {
                const empty = auth_list_json != .array or auth_list_json.array.items.len == 0;
                if (evm_instance.hardfork.isBefore(.PRAGUE) or to == null or empty) {
                    if (expectsRejection(expected_exception, .set_code_invalid)) {
                        rejection = rejection orelse .set_code_invalid;
                        continue;
                    }
                    return error.InvalidSetCodeTransaction;
                }
            }

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
                    if (expectsRejection(expected_exception, .blob_contract_creation)) {
                        rejection = rejection orelse .blob_contract_creation;
                        continue;
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
                    if (expectsRejection(expected_exception, .blob_count)) {
                        rejection = rejection orelse .blob_count;
                        continue;
                    }
                    // If we get here, the test doesn't expect this exception, so fail
                    return error.BlobCountExceeded;
                }

                // Parse blob hashes from JSON
                const blob_hashes_array = try allocator.alloc([32]u8, blob_count);
                errdefer allocator.free(blob_hashes_array);
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
                        if (expectsRejection(expected_exception, .blob_versioned_hash)) {
                            allocator.free(blob_hashes_array);
                            rejection = rejection orelse .blob_versioned_hash;
                            continue :tx_loop;
                        }
                        // If we get here, the test doesn't expect this exception, so fail
                        return error.InvalidBlobHashVersion;
                    }
                }

                blob_hashes_storage = blob_hashes_array;
            }
            defer if (blob_hashes_storage) |hashes| allocator.free(hashes);

            // Calculate intrinsic gas cost
            // Contract creation transactions cost 53000 base gas, regular transactions cost 21000
            var intrinsic_gas: u64 = createAwareBaseGas(evm_instance.hardfork, to == null);

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
                // accessLists holds one access list per data alternative.
                if (access_lists_json == .array and access_lists_json.array.items.len > 0) {
                    const access_list_json = try selectAlternative(access_lists_json, variant.data);
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
                            if (expectsRejection(expected_exception, .initcode_size)) {
                                rejection = rejection orelse .initcode_size;
                                continue;
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

            const static_exception = try staticTransactionException(test_case, evm_instance.hardfork);
            // Ensure gas_limit covers the intrinsic cost and, from Prague, the
            // EIP-7623 calldata floor (EELS: max(intrinsic, floor) > tx.gas).
            if (txGasLimitTooLow(gas_limit, intrinsic_gas, calldata_floor_gas_cost)) {
                if (static_exception) |expected| {
                    if (std.mem.eql(u8, expected, "TransactionException.INTRINSIC_GAS_TOO_LOW")) continue;
                }
                // Transaction is invalid - check if test expects this
                if (expectsRejection(expected_exception, .intrinsic_gas)) {
                    rejection = rejection orelse .intrinsic_gas;
                    continue;
                }
                // If we get here, the test doesn't expect this exception, so fail
                return error.IntrinsicGasTooLow;
            }
            if (static_exception != null) return error.ExpectedStaticTransactionException;

            // EIP-7825 (Osaka+): reject transactions above the per-tx gas cap.
            if (hardfork) |hf| {
                if (exceedsTxGasLimitCap(hf, gas_limit)) {
                    if (expectsRejection(expected_exception, .gas_limit_cap)) {
                        rejection = rejection orelse .gas_limit_cap;
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
                blob_gas_fee_for_validation = std.math.mul(u256, total_blob_gas, max_fee_per_blob_gas) catch std.math.maxInt(u256);
            }

            // EELS `check_transaction`: fee caps against the base fee (London+),
            // then the sender nonce, then the balance.
            if (evm_instance.hardfork.isAtLeast(.LONDON)) {
                if (tx.object.get("maxFeePerGas") != null) {
                    const max_priority_fee: u256 = if (tx.object.get("maxPriorityFeePerGas")) |mpf| try parseU256FromJson(mpf) else 0;
                    if (max_priority_fee > max_fee_per_gas_for_validation) {
                        rejection = rejection orelse .priority_fee_above_max_fee;
                        continue;
                    }
                }
                if (max_fee_per_gas_for_validation < tx_base_fee) {
                    rejection = rejection orelse .insufficient_max_fee;
                    continue;
                }
            }
            if (tx.object.get("nonce")) |nonce_json| {
                const tx_nonce = try parseU256FromJson(nonce_json);
                // EIP-2681: nonces stop at 2^64 - 1.
                if (tx_nonce >= std.math.maxInt(u64)) {
                    rejection = rejection orelse .nonce_is_max;
                    continue;
                }
                if (TxRejection.forNonce(tx_nonce, test_host.getNonce(sender))) |reason| {
                    rejection = rejection orelse reason;
                    continue;
                }
            }

            // Per Ethereum spec: sender must have sufficient funds for upfront gas + blob fee + value
            // Use max_fee_per_gas and max_fee_per_blob_gas for upfront check (worst case)
            const sender_balance = test_host.balances.get(sender) orelse 0;
            const total_required: ?u256 = blk: {
                const gas_cost = std.math.mul(u256, gas_limit, max_fee_per_gas_for_validation) catch break :blk null;
                const with_blob = std.math.add(u256, gas_cost, blob_gas_fee_for_validation) catch break :blk null;
                break :blk std.math.add(u256, with_blob, value) catch null;
            };
            if (total_required == null or sender_balance < total_required.?) {
                // INSUFFICIENT_ACCOUNT_FUNDS: the transaction is not included.
                rejection = rejection orelse .insufficient_funds;
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

            // Parse access list for EIP-2930 (Berlin+)
            var access_list_entries_storage: ?[]primitives.AccessList.AccessListEntry = null;
            defer if (access_list_entries_storage) |entries| freeAccessList(allocator, entries);

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
                    // Handle accessLists (plural): one list per data alternative
                    if (access_list_data == .array and access_list_data.array.items.len > 0) {
                        const selected = try selectAlternative(access_list_data, variant.data);
                        if (selected == .array) {
                            break :blk2 selected.array;
                        }
                    }
                    break :blk null;
                };

                const entries = try parseAccessListJson(allocator, access_list_array.items);
                access_list_entries_storage = entries;
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

                        // Recover the authority from the signature. A tuple
                        // without a complete signature is skipped; the
                        // fixture's "signer" annotation is never trusted.
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
                var initialized: usize = old_entries.len;
                errdefer {
                    for (entries[old_entries.len..initialized]) |entry| allocator.free(entry.storage_keys);
                    allocator.free(entries);
                }
                @memcpy(entries[0..old_entries.len], old_entries);
                for (warm_authorities.items, old_entries.len..) |authority, i| {
                    entries[i] = .{ .address = authority, .storage_keys = try allocator.alloc([32]u8, 0) };
                    initialized += 1;
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
                // The public root CREATE path runs the transaction epilogue
                // (EIP-6780 self-destruct and EIP-161 touched-account cleanup).
                evm_instance.setAccessList(access_list_param);
                const create_result = evm_instance.call(.{ .create = .{
                    .caller = sender,
                    .value = value,
                    .init_code = tx_data,
                    .gas = execution_gas,
                } });
                result_success = create_result.success;
                result_gas_left = create_result.gas_left;
                try tx_logs.appendSlice(allocator, create_result.logs);
            } else {
                // Code is resolved from the host after authorizations apply,
                // so no fallback bytecode is passed.
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
                try tx_logs.appendSlice(allocator, call_result.logs);
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

        const b = block orelse continue;
        if (rejection) |reason| {
            const want = expected_exception orelse {
                std.debug.print("block {d} transaction rejected ({s}) but the block is expected to be valid\n", .{ segment_index, @tagName(reason) });
                return error.InvalidBlockTransaction;
            };
            if (!reason.matches(want)) {
                std.debug.print("block {d} transaction rejected ({s}) but the fixture expects {s}\n", .{ segment_index, @tagName(reason), want });
                return error.WrongExceptionRaised;
            }
            // Rejected block: discard its effects; the parent stays.
            try block_snapshot.?.restore(&test_host);
            rejection = null;
            continue;
        }
        if (expected_exception) |want| {
            // Header and transactions are valid, so the block is invalid for a
            // body rule this runner cannot check. Skip rather than pass.
            std.debug.print("block {d} expects {s}, which its header and transactions do not show; skipping\n", .{ segment_index, want });
            return error.SkipZigTest;
        }
        // EIP-4895: withdrawals apply at the end of their own accepted block.
        try applyBlockWithdrawals(&test_host, b);
        parent_block = b;
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
        var full_state = false;
        const post_state = blk: {
            if (variant.post_entry) |entry| {
                if (entry != .object) return error.InvalidPostEntry;
                const expected_exception = variant.expectedException();
                try checkExpectedException(expected_exception, rejection);
                if (expected_exception != null) {
                    if (pre_snapshot) |*snapshot| try snapshot.expectUnchanged(&test_host);
                }
                if (entry.object.get("logs")) |logs_json| {
                    try expectLogsHash(allocator, logs_json, tx_logs.items);
                }
                if (entry.object.get("state")) |state| {
                    full_state = true;
                    break :blk state;
                }
                if (expected_exception != null) return;
                // Only a state root is given, which this runner cannot compute.
                return error.SkipZigTest;
            }
            // Direct format: a blockchain `postState` is a complete snapshot;
            // an address-keyed `post` lists only the accounts it checks.
            if (test_case.object.get("post") == null) full_state = true;
            break :blk post;
        };

        try checkExpectedAccounts(allocator, &test_host, post_state, .{ .full_state = full_state, .check_code = true });
    } else if (test_case.object.get("expect")) |expect_list| {
        // Filler `expect` format: each expectation's `result` lists accounts.
        if (expect_list == .array) {
            for (expect_list.array.items) |expectation| {
                if (expectation.object.get("result")) |result| {
                    try checkExpectedAccounts(allocator, &test_host, result, .{ .full_state = false, .check_code = false });
                }
            }
        }
    }
}

/// How `checkExpectedAccounts` treats what the expectation leaves out.
const AccountCheck = struct {
    /// The listing is a complete snapshot: every nonempty host account must
    /// be listed, and a listed account without `storage` has none.
    full_state: bool,
    /// Compare `code` (filler `expect` code may be assembly, so it is not).
    check_code: bool,
};

/// Parses an expected storage key or value; `<address>` placeholders are
/// the address as an integer.
fn parseStorageWord(text: []const u8) !u256 {
    if (std.mem.startsWith(u8, text, "<") and std.mem.endsWith(u8, text, ">")) {
        const addr = try parseAddress(text);
        return std.mem.readInt(u160, &addr.bytes, .big);
    }
    return std.fmt.parseInt(u256, text, 0);
}

/// Compares `address`'s storage with `expected` in both directions: every
/// listed slot holds its value, and every nonzero host slot is listed.
fn expectStorage(host: *TestHost, address: Address, expected: std.json.Value) !void {
    if (expected != .object) return error.InvalidPostState;
    var it = expected.object.iterator();
    while (it.next()) |kv| {
        if (kv.value_ptr.* != .string) return error.InvalidPostState;
        const slot = try parseStorageWord(kv.key_ptr.*);
        const want = try parseStorageWord(kv.value_ptr.string);
        const actual = host.storage.get(.{ .address = address, .slot = slot }) orelse 0;
        if (want != actual) {
            std.debug.print("STORAGE MISMATCH: addr={any} slot={} expected {}, found {}\n", .{ address.bytes, slot, want, actual });
            return error.StorageMismatch;
        }
    }
    var host_it = host.storage.iterator();
    while (host_it.next()) |kv| {
        if (!kv.key_ptr.address.equals(address) or kv.value_ptr.* == 0) continue;
        if (try storageLists(expected, kv.key_ptr.slot)) continue;
        std.debug.print("UNEXPECTED STORAGE SLOT: addr={any} slot={} holds {}\n", .{ address.bytes, kv.key_ptr.slot, kv.value_ptr.* });
        return error.UnexpectedStorageSlot;
    }
}

fn storageLists(expected: std.json.Value, slot: u256) !bool {
    var it = expected.object.iterator();
    while (it.next()) |kv| {
        if (try parseStorageWord(kv.key_ptr.*) == slot) return true;
    }
    return false;
}

/// Checks every account in an expected listing (`address -> account`).
fn checkExpectedAccounts(allocator: std.mem.Allocator, host: *TestHost, accounts: std.json.Value, opts: AccountCheck) !void {
    if (accounts != .object) return error.InvalidPostState;
    var it = accounts.object.iterator();
    while (it.next()) |kv| {
        const address = try parseAddress(kv.key_ptr.*);
        const expected = kv.value_ptr.*;
        if (expected != .object) return error.InvalidPostState;

        if (expected.object.get("shouldnotexist")) |sne| {
            if (try parseIntFromJson(sne) == 1) {
                // No balance, nonce, code or nonzero storage.
                if (hostAccountNonEmpty(host, address)) {
                    std.debug.print("ACCOUNT SHOULD NOT EXIST: addr={any}\n", .{address.bytes});
                    return error.AccountShouldNotExist;
                }
                continue;
            }
        }

        if (opts.check_code) {
            if (expected.object.get("code")) |expected_code| try expectCode(allocator, host, address, expected_code);
        }

        if (expected.object.get("balance")) |expected_bal| {
            const want = try parseU256FromJson(expected_bal);
            const actual = host.balances.get(address) orelse 0;
            if (want != actual) {
                std.debug.print("BALANCE MISMATCH: addr={any} expected {}, found {}\n", .{ address.bytes, want, actual });
                return error.BalanceMismatch;
            }
        }

        if (expected.object.get("nonce")) |expected_nonce| {
            const want = try parseIntFromJson(expected_nonce);
            const actual = host.getNonce(address);
            if (want != actual) {
                std.debug.print("NONCE MISMATCH: addr={any} expected {}, found {}\n", .{ address.bytes, want, actual });
                return error.NonceMismatch;
            }
        }

        if (expected.object.get("storage")) |storage| {
            try expectStorage(host, address, storage);
        } else if (opts.full_state) {
            var none = std.json.ObjectMap.init(allocator);
            defer none.deinit();
            try expectStorage(host, address, .{ .object = none });
        }
    }
    // A complete snapshot: no other account may exist.
    if (opts.full_state) try expectNoUnlistedAccounts(host, accounts);
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

fn fixtureSenderFromSecretKey(key: []const u8) !Address {
    const tagged = std.mem.startsWith(u8, key, "<") and std.mem.endsWith(u8, key, ">");
    const key_hex = if (tagged) blk: {
        const start = std.mem.lastIndexOf(u8, key, "0x") orelse return error.InvalidFixtureSecretKey;
        break :blk key[start .. key.len - 1];
    } else key;
    const digits = if (std.mem.startsWith(u8, key_hex, "0x")) key_hex[2..] else key_hex;
    const secret = try std.fmt.parseInt(u256, digits, 16);
    var key_bytes: [32]u8 = undefined;
    std.mem.writeInt(u256, &key_bytes, secret, .big);
    return (try primitives.PublicKey.fromPrivateKey(key_bytes)).toAddress();
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

fn parseFixtureBytecode(allocator: std.mem.Allocator, source: []const u8) ![]u8 {
    var code = std.mem.trim(u8, source, " \t\r\n");
    if (std.mem.startsWith(u8, code, ":label ")) {
        var fields = std.mem.tokenizeAny(u8, code, " \t\r\n");
        _ = fields.next();
        _ = fields.next() orelse return error.InvalidFixtureLabel;
        code = fields.rest();
    }
    if (std.mem.startsWith(u8, code, "{") or std.mem.startsWith(u8, code, "(asm ") or
        std.mem.startsWith(u8, code, ":asm ") or std.mem.startsWith(u8, code, ":yul "))
    {
        return assembler.compileAssembly(allocator, code);
    }
    const hex = try parseHexData(allocator, code);
    defer allocator.free(hex);
    return primitives.Hex.hexToBytes(allocator, hex);
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
    const entries = postForkEntries(parsed.value.object.get("post").?, .OSAKA).?;
    const variant = try Variant.fromPostEntry(entries.array.items[0]);
    try testing.expect(variant.expects(.gas_limit_cap));
    try testing.expect(!variant.expects(.intrinsic_gas));
    try testing.expect(postForkEntries(parsed.value.object.get("post").?, .PRAGUE) == null);
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

test "checkExpectedException matches the rejection to the named exception" {
    const intrinsic = "TransactionException.INTRINSIC_GAS_TOO_LOW";
    try testing.expectError(error.ExpectedExceptionNotRaised, checkExpectedException(intrinsic, null));
    try checkExpectedException(intrinsic, .intrinsic_gas);
    try testing.expectError(error.WrongExceptionRaised, checkExpectedException("TransactionException.NONCE_MISMATCH_TOO_LOW", .insufficient_funds));
    try checkExpectedException("TransactionException.INSUFFICIENT_ACCOUNT_FUNDS|TransactionException.NONCE_MISMATCH_TOO_HIGH", .nonce_too_high);
    // Exact names: the opposite nonce direction is a different exception.
    try testing.expectError(error.WrongExceptionRaised, checkExpectedException("TransactionException.NONCE_MISMATCH_TOO_LOW", .nonce_too_high));
    try testing.expectError(error.WrongExceptionRaised, checkExpectedException("TransactionException.NONCE_MISMATCH_TOO_HIGH", .nonce_too_low));
    try checkExpectedException("TR_NoFunds", .insufficient_funds);
    try checkExpectedException(null, null);
    try testing.expectError(error.UnexpectedTransactionRejection, checkExpectedException(null, .insufficient_funds));
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
        \\  "0x1000000000000000000000000000000000000000": {"balance": "0x00", "nonce": "0x01", "code": "0x5b00"},
        \\  "0x2adc25665018aa1fe0e6bc666dac8fc2697ff9ba": {"balance": "0x033450"}}}]}}
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
        \\  "0x1000000000000000000000000000000000000000": {"balance": "0x01"},
        \\  "0x2adc25665018aa1fe0e6bc666dac8fc2697ff9ba": {"balance": "0x033450"}}}]}}
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

const fixture_pre_sender =
    \\"pre": {"0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {"balance": "0x0de0b6b3a7640000", "nonce": "0x00", "code": "0x", "storage": {}}}
;

/// A Cancun transfer fixture. `tx_extra` adds transaction fields; the nonce
/// defaults to 0.
fn transferFixture(comptime tx_extra: []const u8, comptime post: []const u8) []const u8 {
    const nonce = comptime if (std.mem.indexOf(u8, tx_extra, "\"nonce\"") == null) ", \"nonce\": \"0x00\"" else "";
    return "{" ++ fixture_env ++ "," ++ fixture_pre_sender ++
        \\,"transaction": {"data": ["0x"], "gasPrice": "0x0a",
        \\  "sender": "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b", "to": "0x1000000000000000000000000000000000000000", "value": ["0x00"],
    ++ tx_extra ++ nonce ++ "}, \"post\": {\"Cancun\": [" ++ post ++ "]}}";
}

const transfer_ok_state =
    \\"state": {"0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {"balance": "0x0de0b6b3a760cbb0", "nonce": "0x01"},
    \\  "0x2adc25665018aa1fe0e6bc666dac8fc2697ff9ba": {"balance": "0x033450"}}
;

test "every post entry runs with its own gas index" {
    // Entry 1 selects gas 0x5208, which is valid, but claims INTRINSIC_GAS_TOO_LOW.
    try testing.expectError(error.ExpectedExceptionNotRaised, runFixtureForTest(transferFixture(
        \\"gasLimit": ["0x5208", "0x5208"]
    ,
        \\{"indexes": {"data": 0, "gas": 0, "value": 0},
    ++ transfer_ok_state ++
        \\}, {"indexes": {"data": 0, "gas": 1, "value": 0}, "expectException": "TransactionException.INTRINSIC_GAS_TOO_LOW"}
    )));
    // With gas 1 really too low, both entries pass.
    try runFixtureForTest(transferFixture(
        \\"gasLimit": ["0x5208", "0x5207"]
    ,
        \\{"indexes": {"data": 0, "gas": 0, "value": 0},
    ++ transfer_ok_state ++
        \\}, {"indexes": {"data": 0, "gas": 1, "value": 0}, "expectException": "TransactionException.INTRINSIC_GAS_TOO_LOW"}
    ));
    // An index outside the alternatives is a malformed fixture, not variant 0.
    try testing.expectError(error.InvalidVariantIndex, runFixtureForTest(transferFixture(
        \\"gasLimit": ["0x5208"]
    ,
        \\{"indexes": {"data": 0, "gas": 3, "value": 0},
    ++ transfer_ok_state ++ "}")));
}

test "post state fails on unlisted accounts, wrong code and wrong logs" {
    // Coinbase is paid but missing from the full state.
    try testing.expectError(error.UnexpectedAccountInPostState, runFixtureForTest(transferFixture(
        \\"gasLimit": ["0x5208"]
    ,
        \\{"state": {"0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {"balance": "0x0de0b6b3a760cbb0", "nonce": "0x01"}}}
    )));
    // The sender has no code.
    try testing.expectError(error.CodeMismatch, runFixtureForTest(transferFixture(
        \\"gasLimit": ["0x5208"]
    ,
        \\{"state": {"0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {"balance": "0x0de0b6b3a760cbb0", "nonce": "0x01", "code": "0x6001600155"},
        \\  "0x2adc25665018aa1fe0e6bc666dac8fc2697ff9ba": {"balance": "0x033450"}}}
    )));
    // A plain transfer emits no logs: keccak256(rlp([])) passes, anything else fails.
    try runFixtureForTest(transferFixture(
        \\"gasLimit": ["0x5208"]
    ,
        \\{"logs": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
    ++ transfer_ok_state ++ "}"));
    try testing.expectError(error.LogsHashMismatch, runFixtureForTest(transferFixture(
        \\"gasLimit": ["0x5208"]
    ,
        \\{"logs": "0x0000000000000000000000000000000000000000000000000000000000000001",
    ++ transfer_ok_state ++ "}")));
    // Only a state root: the runner cannot check it, so the case is skipped.
    try testing.expectError(error.SkipZigTest, runFixtureForTest(transferFixture(
        \\"gasLimit": ["0x5208"]
    ,
        \\{"hash": "0x00"}
    )));
}

test "logsHash of no logs is keccak256(rlp([]))" {
    const hash = try logsHash(testing.allocator, &.{});
    var expected: [32]u8 = undefined;
    std.mem.writeInt(u256, &expected, 0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347, .big);
    try testing.expectEqualSlices(u8, &expected, &hash);
}

test "an expected exception must name the actual rejection" {
    // Nonce 1 against sender nonce 0 is a nonce mismatch.
    try runFixtureForTest(transferFixture(
        \\"gasLimit": ["0x5208"], "nonce": "0x01"
    ,
        \\{"expectException": "TransactionException.NONCE_MISMATCH_TOO_HIGH"}
    ));
    try testing.expectError(error.UnexpectedTransactionRejection, runFixtureForTest(transferFixture(
        \\"gasLimit": ["0x5208"], "nonce": "0x01"
    , "{" ++ transfer_ok_state ++ "}")));
    // Insufficient funds is not a nonce error.
    try testing.expectError(error.WrongExceptionRaised, runFixtureForTest(transferFixture(
        \\"gasLimit": ["0x02c68af0bb140000"]
    ,
        \\{"expectException": "TransactionException.NONCE_MISMATCH_TOO_LOW"}
    )));
}

test "a top-level CREATE runs the transaction epilogue" {
    // Init code CALLER SELFDESTRUCT: created and destroyed in one Cancun
    // transaction, so the account is deleted. Gas: 53034 intrinsic + 5002.
    const json = "{" ++ fixture_env ++ "," ++ fixture_pre_sender ++
        \\,"transaction": {"data": ["0x33ff"], "gasLimit": ["0x0186a0"], "gasPrice": "0x0a", "nonce": "0x00",
        \\  "sender": "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b", "to": "", "value": ["0x00"]},
        \\"post": {"Cancun": [{"state": {
        \\  "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {"balance": "0x0de0b6b3a75b24f8", "nonce": "0x01"},
        \\  "0x6295ee1b4f6dd65047762f924ecd367c17eabf8f": {"shouldnotexist": "1"},
        \\  "0x2adc25665018aa1fe0e6bc666dac8fc2697ff9ba": {"balance": "0x08db08"}}}]}}
    ;
    try runFixtureForTest(json);
}

const set_code_sender = "0xd02d72e067e77158444ef2020ff2d325f929b363";

test "clearing a delegation leaves no stale code to execute" {
    // a94f delegates to 0xcc...; a tuple signed by a94f clears it, then the
    // transaction sends a94f 1 wei. Stale designator bytes (0xef) would halt
    // and revert the transfer.
    const allocator = testing.allocator;
    var key: [32]u8 = undefined;
    std.mem.writeInt(u256, &key, 0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8, .big);
    const signed = try primitives.Authorization.createAuthorization(allocator, 1, primitives.ZERO_ADDRESS, 0, key);
    const y_parity: u256 = if (signed.v >= 27) (signed.v - 27) % 2 else signed.v;
    const json = try std.fmt.allocPrint(allocator,
        \\{{"env": {{"currentCoinbase": "0x2adc25665018aa1fe0e6bc666dac8fc2697ff9ba", "currentGasLimit": "0x05f5e100",
        \\  "currentNumber": "0x01", "currentTimestamp": "0x03e8", "currentDifficulty": "0x00", "currentBaseFee": "0x00"}},
        \\"pre": {{"{s}": {{"balance": "0x0de0b6b3a7640000", "nonce": "0x00", "code": "0x", "storage": {{}}}},
        \\  "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {{"balance": "0x00", "nonce": "0x00", "code": "0xef0100cccccccccccccccccccccccccccccccccccccccc", "storage": {{}}}},
        \\  "0xcccccccccccccccccccccccccccccccccccccccc": {{"balance": "0x00", "nonce": "0x01", "code": "0x6001600155", "storage": {{}}}}}},
        \\"transaction": {{"data": ["0x"], "gasLimit": ["0x0186a0"], "gasPrice": "0x0a", "nonce": "0x00",
        \\  "sender": "{s}", "to": "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b", "value": ["0x01"],
        \\  "authorizationList": [{{"chainId": "0x01", "address": "0x0000000000000000000000000000000000000000", "nonce": "0x00",
        \\    "yParity": "0x{x}", "r": "0x{x}", "s": "0x{x}"}}]}},
        \\"post": {{"Prague": [{{"state": {{
        \\  "{s}": {{"balance": "0x0de0b6b3a75e627f", "nonce": "0x01"}},
        \\  "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {{"balance": "0x01", "nonce": "0x01", "code": "0x", "storage": {{}}}},
        \\  "0xcccccccccccccccccccccccccccccccccccccccc": {{"balance": "0x00", "nonce": "0x01", "code": "0x6001600155", "storage": {{}}}},
        \\  "0x2adc25665018aa1fe0e6bc666dac8fc2697ff9ba": {{"balance": "0x059d80"}}}}}}]}}}}
    , .{
        set_code_sender,
        set_code_sender,
        y_parity,
        std.mem.readInt(u256, &signed.r, .big),
        std.mem.readInt(u256, &signed.s, .big),
        set_code_sender,
    });
    defer allocator.free(json);
    try runFixtureForTest(json);
}

test "an unsigned authorization with a signer annotation changes nothing" {
    const json = "{" ++ fixture_env ++
        \\,"pre": {"0xd02d72e067e77158444ef2020ff2d325f929b363": {"balance": "0x0de0b6b3a7640000", "nonce": "0x00", "code": "0x", "storage": {}}},
        \\"transaction": {"data": ["0x"], "gasLimit": ["0x0186a0"], "gasPrice": "0x0a", "nonce": "0x00",
        \\  "sender": "0xd02d72e067e77158444ef2020ff2d325f929b363", "to": "0x1000000000000000000000000000000000000000", "value": ["0x00"],
        \\  "authorizationList": [{"chainId": "0x01", "address": "0xcccccccccccccccccccccccccccccccccccccccc", "nonce": "0x00",
        \\    "signer": "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b"}]},
        \\"post": {"Prague": [{"state": {
        \\  "0xd02d72e067e77158444ef2020ff2d325f929b363": {"balance": "0x0de0b6b3a75cfb20", "nonce": "0x01"},
        \\  "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {"balance": "0x00", "nonce": "0x00", "code": "0x"},
        \\  "0x2adc25665018aa1fe0e6bc666dac8fc2697ff9ba": {"balance": "0x0704e0"}}}]}}
    ;
    try runFixtureForTest(json);
}

test "set-code transactions need Prague and a destination" {
    const json = "{" ++ fixture_env ++ "," ++ fixture_pre_sender ++
        \\,"transaction": {"data": ["0x"], "gasLimit": ["0x0186a0"], "gasPrice": "0x0a", "nonce": "0x00",
        \\  "sender": "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b", "to": "0x1000000000000000000000000000000000000000", "value": ["0x00"],
        \\  "authorizationList": []},
        \\"post": {"Prague": [{"expectException": "TransactionException.TYPE_4_EMPTY_AUTHORIZATION_LIST"}]}}
    ;
    try runFixtureForTest(json);
}

/// Signs an EIP-155 (chain 1) legacy transaction from `key` and returns it as hex.
fn signedLegacyTxHex(allocator: std.mem.Allocator, key: [32]u8, gas_limit: u64, to: ?Address, value: u256) ![]u8 {
    var unsigned: std.ArrayList(u8) = .{};
    defer unsigned.deinit(allocator);
    try rlpAppendUint(&unsigned, allocator, 0); // nonce
    try rlpAppendUint(&unsigned, allocator, 10); // gas price
    try rlpAppendUint(&unsigned, allocator, gas_limit);
    try rlpAppendString(&unsigned, allocator, if (to) |addr| &addr.bytes else &.{});
    try rlpAppendUint(&unsigned, allocator, value);
    try rlpAppendString(&unsigned, allocator, &.{});

    var signing: std.ArrayList(u8) = .{};
    defer signing.deinit(allocator);
    try signing.appendSlice(allocator, unsigned.items);
    try rlpAppendUint(&signing, allocator, 1);
    try rlpAppendUint(&signing, allocator, 0);
    try rlpAppendUint(&signing, allocator, 0);
    const hash = try hashRlpList(allocator, &.{}, &.{signing.items});
    const signature = try primitives.crypto.Crypto.unaudited_signHash(hash, key);

    var fields: std.ArrayList(u8) = .{};
    defer fields.deinit(allocator);
    try fields.appendSlice(allocator, unsigned.items);
    try rlpAppendUint(&fields, allocator, 37 + @as(u256, signature.recoveryId()));
    try rlpAppendUint(&fields, allocator, signature.r);
    try rlpAppendUint(&fields, allocator, signature.s);
    var tx: std.ArrayList(u8) = .{};
    defer tx.deinit(allocator);
    try rlpAppendHeader(&tx, allocator, 0xc0, fields.items.len);
    try tx.appendSlice(allocator, fields.items);
    return std.fmt.allocPrint(allocator, "0x{x}", .{tx.items});
}

test "raw transactions recover the signer, move value once and call the zero address" {
    const allocator = testing.allocator;
    var key: [32]u8 = undefined;
    std.mem.writeInt(u256, &key, 0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8, .big);
    const signer = try Address.fromHex("0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b");
    // Same nonce and balance as the signer: guessing by nonce could pick it.
    const decoy = testAddress(0x0d);
    const coinbase = testAddress(0xc0);

    var host = try TestHost.init(allocator);
    defer host.deinit();
    try host.setBalance(decoy, 1_000_000_000_000_000_000);
    try host.setBalance(signer, 1_000_000_000_000_000_000);

    const Evm = evm_mod.Evm(.{});
    var evm_instance: Evm = undefined;
    const block_ctx = evm_mod.BlockContext{
        .chain_id = 1,
        .block_number = 1,
        .block_timestamp = 1000,
        .block_difficulty = 0,
        .block_prevrandao = 0,
        .block_coinbase = coinbase,
        .block_gas_limit = 30_000_000,
        .block_base_fee = 0,
        .blob_base_fee = 0,
    };
    try evm_instance.init(allocator, host.hostInterface(), .CANCUN, block_ctx, primitives.ZERO_ADDRESS, 0, null);
    defer evm_instance.deinit();

    const tx_hex = try signedLegacyTxHex(allocator, key, 21_000, primitives.ZERO_ADDRESS, 1);
    defer allocator.free(tx_hex);
    try testing.expectEqual(@as(?TxRejection, null), try processRlpTransaction(allocator, &evm_instance, &host, tx_hex, block_ctx));

    try testing.expectEqual(@as(u256, 999_999_999_999_789_999), host.balances.get(signer).?);
    try testing.expectEqual(@as(u64, 1), host.getNonce(signer));
    try testing.expectEqual(@as(u256, 1_000_000_000_000_000_000), host.balances.get(decoy).?);
    try testing.expectEqual(@as(u64, 0), host.getNonce(decoy));
    try testing.expectEqual(@as(u256, 1), host.balances.get(primitives.ZERO_ADDRESS).?);
    try testing.expectEqual(@as(u256, 210_000), host.balances.get(coinbase).?);

    // Replaying nonce 0 is rejected without touching state.
    try testing.expectEqual(@as(?TxRejection, .nonce_too_low), try processRlpTransaction(allocator, &evm_instance, &host, tx_hex, block_ctx));
    try testing.expectEqual(@as(u256, 999_999_999_999_789_999), host.balances.get(signer).?);
}

test "raw transactions signed for another chain are rejected" {
    const allocator = testing.allocator;
    var key: [32]u8 = undefined;
    std.mem.writeInt(u256, &key, 0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8, .big);
    const signer = try Address.fromHex("0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b");

    var host = try TestHost.init(allocator);
    defer host.deinit();
    try host.setBalance(signer, 1_000_000_000_000_000_000);

    const Evm = evm_mod.Evm(.{});
    var evm_instance: Evm = undefined;
    // The transaction signs chain 1 (EIP-155); the block is chain 5.
    const block_ctx = evm_mod.BlockContext{
        .chain_id = 5,
        .block_number = 1,
        .block_timestamp = 1000,
        .block_difficulty = 0,
        .block_prevrandao = 0,
        .block_coinbase = testAddress(0xc0),
        .block_gas_limit = 30_000_000,
        .block_base_fee = 0,
        .blob_base_fee = 0,
    };
    try evm_instance.init(allocator, host.hostInterface(), .CANCUN, block_ctx, primitives.ZERO_ADDRESS, 0, null);
    defer evm_instance.deinit();

    const tx_hex = try signedLegacyTxHex(allocator, key, 21_000, testAddress(0x01), 1);
    defer allocator.free(tx_hex);
    try testing.expectEqual(@as(?TxRejection, .invalid_chain_id), try processRlpTransaction(allocator, &evm_instance, &host, tx_hex, block_ctx));
    try testing.expectEqual(@as(u64, 0), host.getNonce(signer));
    try testing.expectEqual(@as(u256, 1_000_000_000_000_000_000), host.balances.get(signer).?);
}

test "createAwareBaseGas charges the creation surcharge from Homestead" {
    try testing.expectEqual(@as(u64, 21_000), createAwareBaseGas(.FRONTIER, true));
    try testing.expectEqual(@as(u64, 53_000), createAwareBaseGas(.HOMESTEAD, true));
    try testing.expectEqual(@as(u64, 21_000), createAwareBaseGas(.CANCUN, false));
}

test "rlpItem rejects truncated input" {
    try testing.expectError(error.InvalidRlp, rlpItem(&.{ 0x82, 0x01 }));
    try testing.expectError(error.InvalidRlp, rlpItem(&.{ 0xb8, 0x40 }));
    const item = try rlpItem(&.{ 0xc2, 0x01, 0x02 });
    try testing.expect(item.is_list);
    try testing.expectEqual(@as(usize, 3), item.encoded_len);
}

test "exceptionNamesAny matches whole names only" {
    try testing.expect(exceptionNamesAny("BlockException.UNKNOWN_PARENT", &.{"UNKNOWN_PARENT"}));
    try testing.expect(!exceptionNamesAny("BlockException.UNCLE_UNKNOWN_PARENT", &.{"UNKNOWN_PARENT"}));
    try testing.expect(exceptionNamesAny("BlockException.INVALID_GASLIMIT | TransactionException.NONCE_IS_MAX", &.{"NONCE_IS_MAX"}));
    try testing.expect(exceptionNamesAny("TR_NoFunds", &.{ "INSUFFICIENT_ACCOUNT_FUNDS", "TR_NoFunds" }));
    try testing.expect(!exceptionNamesAny("BlockException.INVALID_BASEFEE_PER_GAS", headerErrorNames(error.InvalidGasLimit)));
}

/// Pre-state with the default sender and a contract that runs
/// PUSH1 1 PUSH1 1 SSTORE.
const sstore_pre =
    \\"pre": {"0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {"balance": "0x0de0b6b3a7640000", "nonce": "0x00", "code": "0x", "storage": {}},
    \\  "0x1000000000000000000000000000000000000000": {"balance": "0x00", "nonce": "0x01", "code": "0x6001600155", "storage": {}}}
;

fn sstoreFixture(comptime contract_post: []const u8) []const u8 {
    return "{" ++ fixture_env ++ "," ++ sstore_pre ++
        \\,"transaction": {"data": ["0x"], "gasLimit": ["0x0186a0"], "gasPrice": "0x0a", "nonce": "0x00",
        \\  "sender": "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b", "to": "0x1000000000000000000000000000000000000000", "value": ["0x00"]},
        \\"post": {"Cancun": [{"state": {
        \\  "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {"nonce": "0x01"},
        \\  "0x2adc25665018aa1fe0e6bc666dac8fc2697ff9ba": {},
        \\  "0x1000000000000000000000000000000000000000":
    ++ contract_post ++ "}}]}}";
}

test "post state rejects an unexpected nonzero storage slot" {
    try runFixtureForTest(sstoreFixture(
        \\{"nonce": "0x01", "storage": {"0x01": "0x01"}}
    ));
    // The contract wrote slot 1, but the expectation lists no slots.
    try testing.expectError(error.UnexpectedStorageSlot, runFixtureForTest(sstoreFixture(
        \\{"nonce": "0x01", "storage": {}}
    )));
    // A complete snapshot without `storage` expects none.
    try testing.expectError(error.UnexpectedStorageSlot, runFixtureForTest(sstoreFixture(
        \\{"nonce": "0x01"}
    )));
    // The wrong value in a listed slot.
    try testing.expectError(error.StorageMismatch, runFixtureForTest(sstoreFixture(
        \\{"nonce": "0x01", "storage": {"0x01": "0x02"}}
    )));
    // An account that must not exist may not keep storage either.
    try testing.expectError(error.AccountShouldNotExist, runFixtureForTest(sstoreFixture(
        \\{"shouldnotexist": "1"}
    )));
}

/// Runs a fixture through the public entry point, which expands fork-keyed
/// `post` sections.
fn runFixtureAllForks(json: []const u8) !void {
    const parsed = try std.json.parseFromSlice(std.json.Value, testing.allocator, json, .{});
    defer parsed.deinit();
    try runJsonTestWithPathAndName(testing.allocator, parsed.value, null, null);
}

fn multiForkFixture(comptime post: []const u8) []const u8 {
    return "{" ++ fixture_env ++ "," ++ fixture_pre_sender ++
        \\,"transaction": {"data": ["0x"], "gasLimit": ["0x5208"], "gasPrice": "0x0a", "nonce": "0x00",
        \\  "sender": "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b", "to": "0x1000000000000000000000000000000000000000", "value": ["0x00"]},
        \\"post": {
    ++ post ++ "}}";
}

const transfer_wrong_nonce_state =
    \\"state": {"0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {"balance": "0x0de0b6b3a760cbb0", "nonce": "0x05"},
    \\  "0x2adc25665018aa1fe0e6bc666dac8fc2697ff9ba": {"balance": "0x033450"}}
;

test "multi-fork post runs every fork" {
    try runFixtureAllForks(multiForkFixture(
        \\"Berlin": [{
    ++ transfer_ok_state ++
        \\}], "Istanbul": [{
    ++ transfer_ok_state ++ "}]"));
    // A wrong Istanbul expectation fails even beside a right Berlin one,
    // whichever fork is listed first.
    try testing.expectError(error.NonceMismatch, runFixtureAllForks(multiForkFixture(
        \\"Berlin": [{
    ++ transfer_ok_state ++
        \\}], "Istanbul": [{
    ++ transfer_wrong_nonce_state ++ "}]")));
    try testing.expectError(error.NonceMismatch, runFixtureAllForks(multiForkFixture(
        \\"Istanbul": [{
    ++ transfer_wrong_nonce_state ++
        \\}], "Berlin": [{
    ++ transfer_ok_state ++ "}]")));
    // A hash-only fork does not skip a checkable wrong fork.
    try testing.expectError(error.NonceMismatch, runFixtureAllForks(multiForkFixture(
        \\"Cancun": [{"hash": "0x00"}], "Prague": [{
    ++ transfer_wrong_nonce_state ++ "}]")));
    // Only hash-only forks: nothing is checkable, so the fixture is skipped.
    try testing.expectError(error.SkipZigTest, runFixtureAllForks(multiForkFixture(
        \\"Cancun": [{"hash": "0x00"}]
    )));
    try testing.expectError(error.UnsupportedPostFork, runFixtureAllForks(multiForkFixture(
        \\"Berlin": [{
    ++ transfer_ok_state ++
        \\}], "NotAFork": []
    )));
}

/// Three blocks on the default fork. Block 1 runs NUMBER NUMBER SSTORE and
/// pays a withdrawal to 0xee..ee; block 2 runs the contract again and spends
/// that withdrawal; block 3 is rejected and its withdrawal is dropped.
fn multiBlockFixture(comptime block3: []const u8, comptime post: []const u8) []const u8 {
    return
    \\{"pre": {"0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {"balance": "0x0de0b6b3a7640000", "nonce": "0x00", "code": "0x", "storage": {}},
    \\  "0xc0de000000000000000000000000000000000000": {"balance": "0x00", "nonce": "0x01", "code": "0x434355", "storage": {}}},
    \\"blocks": [
    \\  {"blockHeader": {"number": "0x01", "timestamp": "0x0a", "coinbase": "0xcb00000000000000000000000000000000000000"},
    \\   "transactions": [{"data": "0x", "gasLimit": "0x0186a0", "gasPrice": "0x0a", "nonce": "0x00",
    \\     "sender": "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b", "to": "0xc0de000000000000000000000000000000000000", "value": "0x00"}],
    \\   "withdrawals": [{"index": "0x00", "validatorIndex": "0x00", "address": "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee", "amount": "0x01"}]},
    \\  {"blockHeader": {"number": "0x02", "timestamp": "0x14", "coinbase": "0xcb00000000000000000000000000000000000000"},
    \\   "transactions": [{"data": "0x", "gasLimit": "0x0186a0", "gasPrice": "0x0a", "nonce": "0x01",
    \\     "sender": "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b", "to": "0xc0de000000000000000000000000000000000000", "value": "0x00"},
    \\    {"data": "0x", "gasLimit": "0x5208", "gasPrice": "0x0a", "nonce": "0x00",
    \\     "sender": "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee", "to": "0x1000000000000000000000000000000000000000", "value": "0x00"}]},
    \\  {"blockHeader": {"number": "0x03", "timestamp": "0x1e", "coinbase": "0xcb00000000000000000000000000000000000000"},
    \\   "transactions": [{"data": "0x", "gasLimit": "0x5208", "gasPrice": "0x0a", "nonce": "0x00",
    \\     "sender": "0xdddddddddddddddddddddddddddddddddddddddd", "to": "0x1000000000000000000000000000000000000000", "value": "0x00"}],
    \\   "withdrawals": [{"index": "0x01", "validatorIndex": "0x00", "address": "0xffffffffffffffffffffffffffffffffffffff00", "amount": "0x05"}]
    ++ block3 ++
        \\}],
        \\"postState": {
    ++ post ++ "}}";
}

test "multi-block fixtures run each block in its own context with its own withdrawals" {
    // Slot NUMBER holds NUMBER for blocks 1 and 2 (one shared context would
    // write slot 1 twice). The block-2 transaction spends the block-1
    // withdrawal: 1 gwei - 21000 * 10 wei.
    const post_spent =
        \\"0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {"nonce": "0x02"},
        \\"0xc0de000000000000000000000000000000000000": {"nonce": "0x01", "storage": {"0x01": "0x01", "0x02": "0x02"}},
        \\"0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee": {"nonce": "0x01", "balance": "0x3b9795b0"},
        \\"0xcb00000000000000000000000000000000000000": {}
    ;
    // Block 3 is rejected for the expected reason: its withdrawal to
    // 0xff..00 is not credited, so the complete post state omits it.
    try runFixtureForTest(multiBlockFixture(
        \\, "expectException": "TransactionException.INSUFFICIENT_ACCOUNT_FUNDS"
    , post_spent));
    // The rejected block's withdrawal (5 gwei to 0xff..00) is not credited.
    try testing.expectError(error.BalanceMismatch, runFixtureForTest(multiBlockFixture(
        \\, "expectException": "TransactionException.INSUFFICIENT_ACCOUNT_FUNDS"
    , post_spent ++
        \\, "0xffffffffffffffffffffffffffffffffffffff00": {"balance": "0x012a05f200"}
    )));
    // The wrong exception for the rejected block fails the fixture.
    try testing.expectError(error.WrongExceptionRaised, runFixtureForTest(multiBlockFixture(
        \\, "expectException": "TransactionException.INTRINSIC_GAS_TOO_LOW"
    , post_spent)));
    // A block expected to be valid may not contain an invalid transaction.
    try testing.expectError(error.InvalidBlockTransaction, runFixtureForTest(multiBlockFixture("", post_spent)));
}

/// A Shanghai chain whose only block raises its gas limit far beyond the
/// 1/1024 bound, so header validation fails with INVALID_GASLIMIT.
fn badGasLimitFixture(comptime expect: []const u8) []const u8 {
    return
    \\{"network": "Shanghai",
    \\"genesisBlockHeader": {"number": "0x00", "timestamp": "0x00", "gasLimit": "0x01000000", "gasUsed": "0x00", "baseFeePerGas": "0x07",
    \\  "difficulty": "0x00", "nonce": "0x0000000000000000", "uncleHash": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347"},
    \\"pre": {"0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {"balance": "0x0de0b6b3a7640000", "nonce": "0x00", "code": "0x", "storage": {}}},
    \\"blocks": [{"blockHeader": {"number": "0x01", "timestamp": "0x0c", "gasLimit": "0x7fffffff", "gasUsed": "0x00", "baseFeePerGas": "0x07",
    \\    "difficulty": "0x00", "nonce": "0x0000000000000000", "uncleHash": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
    \\    "withdrawalsRoot": "0x0000000000000000000000000000000000000000000000000000000000000000"},
    \\  "withdrawals": [{"index": "0x00", "validatorIndex": "0x00", "address": "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee", "amount": "0x01"}],
    \\  "expectException": "
    ++ expect ++
        \\"}],
        \\"postState": {"0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {"balance": "0x0de0b6b3a7640000", "nonce": "0x00"}}}
    ;
}

test "a block header error must be the expected one" {
    try runFixtureForTest(badGasLimitFixture("BlockException.INVALID_GASLIMIT"));
    try testing.expectError(error.WrongExceptionRaised, runFixtureForTest(badGasLimitFixture("BlockException.INVALID_BASEFEE_PER_GAS")));
}

test "access-list parse error on entry 2 frees only initialized entries" {
    const json =
        \\[{"address": "0x1000000000000000000000000000000000000000", "storageKeys": ["0x01", "0x02"]},
        \\ {"address": "0x2000000000000000000000000000000000000000", "storageKeys": ["0x01", "0xzz"]},
        \\ {"address": "0x3000000000000000000000000000000000000000", "storageKeys": []}]
    ;
    const parsed = try std.json.parseFromSlice(std.json.Value, testing.allocator, json, .{});
    defer parsed.deinit();
    // testing.allocator fails the test on a leak or an invalid free.
    try testing.expectError(error.InvalidCharacter, parseAccessListJson(testing.allocator, parsed.value.array.items));

    const bad_address =
        \\[{"address": "0x1000000000000000000000000000000000000000", "storageKeys": ["0x01"]}, {"address": "0xzz", "storageKeys": []}]
    ;
    const parsed_bad = try std.json.parseFromSlice(std.json.Value, testing.allocator, bad_address, .{});
    defer parsed_bad.deinit();
    try testing.expect(std.meta.isError(parseAccessListJson(testing.allocator, parsed_bad.value.array.items)));

    const entries = try parseAccessListJson(testing.allocator, parsed.value.array.items[0..1]);
    defer freeAccessList(testing.allocator, entries);
    try testing.expectEqual(@as(usize, 1), entries.len);
    try testing.expectEqual(@as(usize, 2), entries[0].storage_keys.len);
    try testing.expectEqual(@as(u8, 2), entries[0].storage_keys[1][31]);
}

test "failing access-list allocations never free uninitialized entries" {
    const json =
        \\[{"address": "0x1000000000000000000000000000000000000000", "storageKeys": ["0x01"]},
        \\ {"address": "0x2000000000000000000000000000000000000000", "storageKeys": ["0x01", "0x02"]}]
    ;
    const parsed = try std.json.parseFromSlice(std.json.Value, testing.allocator, json, .{});
    defer parsed.deinit();
    try testing.checkAllAllocationFailures(testing.allocator, struct {
        fn run(allocator: std.mem.Allocator, items: []const std.json.Value) !void {
            const entries = try parseAccessListJson(allocator, items);
            freeAccessList(allocator, entries);
        }
    }.run, .{parsed.value.array.items});
}
