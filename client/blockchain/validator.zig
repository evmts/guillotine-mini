/// Block header validation helpers for post-merge (PoS) rules.
///
/// Implements post-merge header invariants and base-fee progression per
/// execution-specs and relevant EIPs (e.g., EIP-1559, EIP-4844). No custom
/// primitives are introduced; everything is expressed via Voltaire types.
const std = @import("std");
const primitives = @import("voltaire");
const Blob = primitives.Blob;
const BlockHeader = primitives.BlockHeader;
const Hash = primitives.Hash;
const Hardfork = primitives.Hardfork;

/// Errors returned by PoS header constant validation.
pub const ValidationError = error{
    InvalidDifficulty,
    InvalidNonce,
    InvalidOmmersHash,
    InvalidExtraDataLength,
    InvalidGasLimit,
    InvalidGasUsed,
    InvalidTimestamp,
    InvalidBaseFee,
    MissingBaseFee,
    InvalidParentHash,
    InvalidBlockNumber,
    MissingParentHeader,
    // Arithmetic errors while computing base fee deltas (overflow/underflow)
    BaseFeeMath,
    // Cancun+ header must include blob_gas_used
    MissingBlobGasUsed,
    MissingExcessBlobGas,
    InvalidExcessBlobGas,
    // Cancun+: blob_gas_used above the fork's per-block max or not a multiple
    // of GAS_PER_BLOB
    InvalidBlobGasUsed,
    // Cancun+ header must include parent_beacon_block_root (EIP-4788)
    MissingParentBeaconBlockRoot,
    // Pre-Cancun headers must not carry any 4844 fields
    UnexpectedBlobFieldsPreCancun,
    OutOfMemory,
};

/// Context for validating a block header.
pub const HeaderValidationContext = struct {
    allocator: std.mem.Allocator,
    hardfork: Hardfork,
    parent_header: ?*const BlockHeader.BlockHeader = null,
    terminal_total_difficulty: ?u256 = null,
    header_total_difficulty: ?u256 = null,
    parent_total_difficulty: ?u256 = null,
};

const BASE_FEE_MAX_CHANGE_DENOMINATOR: u64 = 8;
const ELASTICITY_MULTIPLIER: u64 = 2;
const GAS_LIMIT_ADJUSTMENT_FACTOR: u64 = 1024;
const GAS_LIMIT_MINIMUM: u64 = 5000;

/// EIP-4844 `GAS_PER_BLOB` (2^17).
const GAS_PER_BLOB: u64 = Blob.BLOB_GAS_PER_BLOB;
/// EIP-7918 (Osaka) `BLOB_BASE_COST`.
const BLOB_BASE_COST: u256 = 1 << 13;
/// EIP-4844 `MIN_BASE_FEE_PER_BLOB_GAS`.
const MIN_BASE_FEE_PER_BLOB_GAS: u256 = 1;

/// Per-fork blob gas parameters for header validation.
const BlobParams = struct {
    target_blob_gas_per_block: u64,
    max_blob_gas_per_block: u64,
    base_fee_update_fraction: u64,
    /// EIP-7918: excess blob gas is bounded by the execution base fee.
    reserve_price: bool,
};

/// Blob parameters for the child block's fork. Voltaire's
/// `Blob.calculateExcessBlobGas` hardcodes the Cancun target, so the schedule
/// lives here.
/// - Cancun (EIP-4844): target 3 blobs, max 6, fraction 3_338_477.
/// - Prague (EIP-7691): target 6 blobs, max 9, fraction 5_007_716.
/// - Osaka (EIP-7918): Prague schedule plus the blob reserve price. Voltaire's
///   Hardfork enum has no BPO forks, so later forks reuse the Osaka schedule.
fn blob_params(hardfork: Hardfork) BlobParams {
    if (hardfork.isAtLeast(.PRAGUE)) return .{
        .target_blob_gas_per_block = 6 * GAS_PER_BLOB,
        .max_blob_gas_per_block = 9 * GAS_PER_BLOB,
        .base_fee_update_fraction = 5_007_716,
        .reserve_price = hardfork.isAtLeast(.OSAKA),
    };
    return .{
        .target_blob_gas_per_block = 3 * GAS_PER_BLOB,
        .max_blob_gas_per_block = 6 * GAS_PER_BLOB,
        .base_fee_update_fraction = 3_338_477,
        .reserve_price = false,
    };
}

/// EIP-4844 `fake_exponential`. Saturates to maxInt(u256) instead of
/// overflowing (EELS uses unbounded integers).
fn fake_exponential(factor: u256, numerator: u256, denominator: u256) u256 {
    const max = std.math.maxInt(u256);
    var i: u256 = 1;
    var output: u256 = 0;
    var accumulated = std.math.mul(u256, factor, denominator) catch return max;
    while (accumulated > 0) {
        output = std.math.add(u256, output, accumulated) catch return max;
        const product = std.math.mul(u256, accumulated, numerator) catch return max;
        const divisor = std.math.mul(u256, denominator, i) catch return max;
        accumulated = product / divisor;
        i += 1;
    }
    return output / denominator;
}

/// Expected child `excess_blob_gas` per EELS `calculate_excess_blob_gas` for
/// the child's fork. A parent without blob fields counts as zero.
fn calculate_excess_blob_gas(
    hardfork: Hardfork,
    parent: *const BlockHeader.BlockHeader,
) ValidationError!u64 {
    const params = blob_params(hardfork);
    const parent_excess: u64 = parent.excess_blob_gas orelse 0;
    const parent_used: u64 = parent.blob_gas_used orelse 0;
    const parent_blob_gas: u128 = @as(u128, parent_excess) + parent_used;
    if (parent_blob_gas < params.target_blob_gas_per_block) return 0;

    if (params.reserve_price) {
        const parent_base_fee = parent.base_fee_per_gas orelse return ValidationError.MissingBaseFee;
        const blob_gas_price = fake_exponential(
            MIN_BASE_FEE_PER_BLOB_GAS,
            parent_excess,
            params.base_fee_update_fraction,
        );
        const target_blob_gas_price = std.math.mul(u256, GAS_PER_BLOB, blob_gas_price) catch
            std.math.maxInt(u256);
        const base_blob_tx_price = std.math.mul(u256, BLOB_BASE_COST, parent_base_fee) catch
            std.math.maxInt(u256);
        if (base_blob_tx_price > target_blob_gas_price) {
            const delta = params.max_blob_gas_per_block - params.target_blob_gas_per_block;
            const increase = @as(u128, parent_used) * delta / params.max_blob_gas_per_block;
            return std.math.cast(u64, parent_excess + increase) orelse ValidationError.InvalidExcessBlobGas;
        }
    }
    return std.math.cast(u64, parent_blob_gas - params.target_blob_gas_per_block) orelse
        ValidationError.InvalidExcessBlobGas;
}

/// Validate PoS header constants: extraData<=32, difficulty=0, nonce=0, ommers=empty list hash.
fn validate_pos_header_constants(header: *const BlockHeader.BlockHeader) ValidationError!void {
    if (header.extra_data.len > BlockHeader.MAX_EXTRA_DATA_SIZE) {
        return ValidationError.InvalidExtraDataLength;
    }
    if (header.difficulty != 0) return ValidationError.InvalidDifficulty;
    if (!std.mem.allEqual(u8, header.nonce[0..], 0)) return ValidationError.InvalidNonce;
    if (!Hash.equals(&header.ommers_hash, &BlockHeader.EMPTY_OMMERS_HASH)) {
        return ValidationError.InvalidOmmersHash;
    }
}

/// True when `gas_limit` differs from `parent_gas_limit` by strictly less
/// than `parent_gas_limit / 1024`. Both endpoints are forbidden, matching
/// `check_gas_limit` in execution-specs `forks/london/fork.py` (`>=` / `<=`
/// reject). Uses the absolute difference so it cannot overflow or underflow.
fn gas_limit_delta_ok(gas_limit: u64, parent_gas_limit: u64) bool {
    const max_adjustment_delta = parent_gas_limit / GAS_LIMIT_ADJUSTMENT_FACTOR;
    const diff = if (gas_limit > parent_gas_limit) gas_limit - parent_gas_limit else parent_gas_limit - gas_limit;
    return diff < max_adjustment_delta;
}

fn check_gas_limit(gas_limit: u64, parent_gas_limit: u64) bool {
    if (!gas_limit_delta_ok(gas_limit, parent_gas_limit)) return false;
    if (gas_limit < GAS_LIMIT_MINIMUM) return false;
    return true;
}

fn calculate_base_fee_per_gas(
    block_gas_limit: u64,
    parent_gas_limit: u64,
    parent_gas_used: u64,
    parent_base_fee_per_gas: u256,
) ValidationError!u256 {
    if (!check_gas_limit(block_gas_limit, parent_gas_limit)) return ValidationError.InvalidGasLimit;

    const parent_gas_target = parent_gas_limit / ELASTICITY_MULTIPLIER;
    if (parent_gas_target == 0) return ValidationError.InvalidGasLimit;

    if (parent_gas_used == parent_gas_target) return parent_base_fee_per_gas;

    if (parent_gas_used > parent_gas_target) {
        const gas_used_delta = parent_gas_used - parent_gas_target;
        const parent_fee_gas_delta = std.math.mul(
            u256,
            parent_base_fee_per_gas,
            @as(u256, gas_used_delta),
        ) catch return ValidationError.BaseFeeMath;
        const target_fee_gas_delta = parent_fee_gas_delta / @as(u256, parent_gas_target);
        var base_fee_per_gas_delta = target_fee_gas_delta / @as(u256, BASE_FEE_MAX_CHANGE_DENOMINATOR);
        if (base_fee_per_gas_delta == 0) base_fee_per_gas_delta = 1;
        return std.math.add(u256, parent_base_fee_per_gas, base_fee_per_gas_delta) catch
            return ValidationError.BaseFeeMath;
    }

    const gas_used_delta = parent_gas_target - parent_gas_used;
    const parent_fee_gas_delta = std.math.mul(
        u256,
        parent_base_fee_per_gas,
        @as(u256, gas_used_delta),
    ) catch return ValidationError.BaseFeeMath;
    const target_fee_gas_delta = parent_fee_gas_delta / @as(u256, parent_gas_target);
    const base_fee_per_gas_delta = target_fee_gas_delta / @as(u256, BASE_FEE_MAX_CHANGE_DENOMINATOR);
    if (parent_base_fee_per_gas < base_fee_per_gas_delta) return ValidationError.BaseFeeMath;
    return parent_base_fee_per_gas - base_fee_per_gas_delta;
}

fn validate_post_merge_header(
    header: *const BlockHeader.BlockHeader,
    ctx: HeaderValidationContext,
) ValidationError!void {
    if (header.number < 1) return ValidationError.InvalidBlockNumber;

    const parent_header = ctx.parent_header orelse return ValidationError.MissingParentHeader;

    // Enforce EIP-4844/EIP-4788 header fields presence/absence across forks
    if (ctx.hardfork.hasEIP4844()) {
        // Cancun+: blob_gas_used, excess_blob_gas and parent_beacon_block_root
        // must be present.
        const blob_gas_used = header.blob_gas_used orelse return ValidationError.MissingBlobGasUsed;
        const header_excess_blob_gas = header.excess_blob_gas orelse return ValidationError.MissingExcessBlobGas;
        if (header.parent_beacon_block_root == null) return ValidationError.MissingParentBeaconBlockRoot;

        const params = blob_params(ctx.hardfork);
        if (blob_gas_used > params.max_blob_gas_per_block or blob_gas_used % GAS_PER_BLOB != 0) {
            return ValidationError.InvalidBlobGasUsed;
        }
        const expected_excess_blob_gas = try calculate_excess_blob_gas(ctx.hardfork, parent_header);
        if (header_excess_blob_gas != expected_excess_blob_gas) {
            return ValidationError.InvalidExcessBlobGas;
        }
    } else {
        // Pre-Cancun: no 4844 fields must be present
        if (header.blob_gas_used != null or header.excess_blob_gas != null or header.parent_beacon_block_root != null) {
            return ValidationError.UnexpectedBlobFieldsPreCancun;
        }
    }

    if (header.gas_used > header.gas_limit) return ValidationError.InvalidGasUsed;

    // Enforce gas-limit delta rule explicitly before base-fee progression.
    try validate_gas_limit_delta(header, parent_header);

    const parent_base_fee = parent_header.base_fee_per_gas orelse return ValidationError.MissingBaseFee;
    const expected_base_fee = try calculate_base_fee_per_gas(
        header.gas_limit,
        parent_header.gas_limit,
        parent_header.gas_used,
        parent_base_fee,
    );
    const header_base_fee = header.base_fee_per_gas orelse return ValidationError.MissingBaseFee;
    if (expected_base_fee != header_base_fee) return ValidationError.InvalidBaseFee;

    try validate_timestamp_strictly_greater(header, parent_header);
    if (header.number != parent_header.number + 1) return ValidationError.InvalidBlockNumber;

    try validate_pos_header_constants(header);

    const parent_hash = try BlockHeader.hash(parent_header, ctx.allocator);
    if (!Hash.equals(&header.parent_hash, &parent_hash)) return ValidationError.InvalidParentHash;
}

/// Ensures `header.timestamp` is strictly greater than `parent.timestamp`.
///
/// Matches execution-specs invariant across PoW/PoS forks (e.g., London+):
/// child blocks must be created after their parents.
pub fn validate_timestamp_strictly_greater(
    header: *const BlockHeader.BlockHeader,
    parent: *const BlockHeader.BlockHeader,
) ValidationError!void {
    if (header.timestamp <= parent.timestamp) return ValidationError.InvalidTimestamp;
}

/// Decide whether a header is validated under post-merge (PoS) rules.
///
/// Consensus mode comes from trusted inputs only, never from the candidate
/// header: a forged nonzero difficulty must not route a PoS block to the
/// pre-merge validator.
/// - With a terminal total difficulty and the parent's total difficulty,
///   the block is PoS when the parent reached TTD (EIP-3675: the terminal
///   PoW block's children are PoS).
/// - Otherwise the configured fork decides: MERGE and later are PoS.
///
/// The post-merge validator then rejects any nonzero candidate difficulty.
fn is_post_merge(ctx: HeaderValidationContext) bool {
    if (ctx.terminal_total_difficulty) |ttd| {
        if (ctx.parent_total_difficulty) |parent_td| return parent_td >= ttd;
    }
    return ctx.hardfork.isAtLeast(.MERGE);
}

/// Merge-aware header validator that enforces PoS constants post-merge and
/// delegates to a pre-merge validator otherwise.
pub fn merge_header_validator(comptime PreMergeValidator: type) type {
    return struct {
        const validate_fn_info = @typeInfo(@TypeOf(PreMergeValidator.validate));
        const validate_return = switch (validate_fn_info) {
            .@"fn" => |fn_info| fn_info.return_type orelse @compileError(
                "PreMergeValidator.validate must return an error union",
            ),
            else => @compileError("PreMergeValidator.validate must be a function"),
        };
        const validate_return_info = @typeInfo(validate_return);
        const PreMergeError = switch (validate_return_info) {
            .error_union => |error_union| error_union.error_set,
            else => @compileError("PreMergeValidator.validate must return an error union"),
        };

        /// Combined error set for merge-aware validation.
        pub const Error = PreMergeError || ValidationError;

        /// Validate a header under the given hardfork.
        pub fn validate(header: *const BlockHeader.BlockHeader, ctx: HeaderValidationContext) Error!void {
            if (is_post_merge(ctx)) {
                return validate_post_merge_header(header, ctx);
            }
            return PreMergeValidator.validate(header, ctx);
        }
    };
}

test "validate_pos_header_constants - accepts valid PoS constants" {
    var header = BlockHeader.init();
    header.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;

    try validate_pos_header_constants(&header);
}

test "validate_pos_header_constants - rejects non-zero difficulty" {
    var header = BlockHeader.init();
    header.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    header.difficulty = 1;

    try std.testing.expectError(ValidationError.InvalidDifficulty, validate_pos_header_constants(&header));
}

test "validate_pos_header_constants - rejects non-zero nonce" {
    var header = BlockHeader.init();
    header.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    header.nonce = [_]u8{0} ** BlockHeader.NONCE_SIZE;
    header.nonce[BlockHeader.NONCE_SIZE - 1] = 1;

    try std.testing.expectError(ValidationError.InvalidNonce, validate_pos_header_constants(&header));
}

test "validate_pos_header_constants - rejects non-empty ommers hash" {
    var header = BlockHeader.init();
    header.ommers_hash = Hash.ZERO;

    try std.testing.expectError(ValidationError.InvalidOmmersHash, validate_pos_header_constants(&header));
}

test "validate_pos_header_constants - rejects extra data longer than max" {
    var header = BlockHeader.init();
    header.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    var extra = [_]u8{0} ** (BlockHeader.MAX_EXTRA_DATA_SIZE + 1);
    header.extra_data = extra[0..];

    try std.testing.expectError(ValidationError.InvalidExtraDataLength, validate_pos_header_constants(&header));
}

test "validate_pos_header_constants - accepts extra data at max length" {
    var header = BlockHeader.init();
    header.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    var extra = [_]u8{0} ** BlockHeader.MAX_EXTRA_DATA_SIZE;
    header.extra_data = extra[0..];

    try validate_pos_header_constants(&header);
}

test "merge_header_validator - delegates to pre-merge validator" {
    const PreMergeValidator = struct {
        pub fn validate(_: *const BlockHeader.BlockHeader, _: HeaderValidationContext) ValidationError!void {
            return ValidationError.InvalidDifficulty;
        }
    };

    const MergeValidator = merge_header_validator(PreMergeValidator);
    var header = BlockHeader.init();
    header.difficulty = 1;

    const ctx = HeaderValidationContext{
        .allocator = std.testing.allocator,
        .hardfork = .LONDON,
    };
    try std.testing.expectError(ValidationError.InvalidDifficulty, MergeValidator.validate(&header, ctx));
}

test "merge_header_validator - enforces PoS constants post-merge" {
    const PreMergeValidator = struct {
        pub fn validate(_: *const BlockHeader.BlockHeader, _: HeaderValidationContext) ValidationError!void {
            return;
        }
    };

    const MergeValidator = merge_header_validator(PreMergeValidator);
    const allocator = std.testing.allocator;

    var parent = BlockHeader.init();
    parent.number = 1;
    parent.timestamp = 1;
    parent.gas_limit = 10_000;
    parent.gas_used = 0;
    parent.base_fee_per_gas = 100;
    parent.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;

    var header = BlockHeader.init();
    header.number = 2;
    header.timestamp = 2;
    header.gas_limit = parent.gas_limit;
    header.gas_used = 0;
    header.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    header.difficulty = 0;
    header.nonce = [_]u8{0} ** BlockHeader.NONCE_SIZE;
    header.nonce[0] = 1;
    header.parent_hash = try BlockHeader.hash(&parent, allocator);
    header.base_fee_per_gas = try calculate_base_fee_per_gas(
        header.gas_limit,
        parent.gas_limit,
        parent.gas_used,
        parent.base_fee_per_gas.?,
    );

    const ctx = HeaderValidationContext{
        .allocator = allocator,
        .hardfork = .MERGE,
        .parent_header = &parent,
    };
    try std.testing.expectError(ValidationError.InvalidNonce, MergeValidator.validate(&header, ctx));
}

test "validate_timestamp_strictly_greater - accepts strictly greater" {
    var parent = BlockHeader.init();
    parent.timestamp = 10;
    var header = BlockHeader.init();
    header.timestamp = 11;
    try validate_timestamp_strictly_greater(&header, &parent);
}

test "validate_timestamp_strictly_greater - rejects equal" {
    var parent = BlockHeader.init();
    parent.timestamp = 42;
    var header = BlockHeader.init();
    header.timestamp = 42;
    try std.testing.expectError(ValidationError.InvalidTimestamp, validate_timestamp_strictly_greater(&header, &parent));
}

test "validate_timestamp_strictly_greater - rejects less" {
    var parent = BlockHeader.init();
    parent.timestamp = 100;
    var header = BlockHeader.init();
    header.timestamp = 99;
    try std.testing.expectError(ValidationError.InvalidTimestamp, validate_timestamp_strictly_greater(&header, &parent));
}

test "merge_header_validator - treats Shanghai+ as post-merge" {
    const PreMergeValidator = struct {
        pub fn validate(_: *const BlockHeader.BlockHeader, _: HeaderValidationContext) ValidationError!void {
            return;
        }
    };

    const allocator = std.testing.allocator;
    const MergeValidator = merge_header_validator(PreMergeValidator);

    var parent = BlockHeader.init();
    parent.number = 1;
    parent.timestamp = 1;
    parent.gas_limit = 10_000;
    parent.gas_used = 0;
    parent.base_fee_per_gas = 100;
    parent.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;

    var header = BlockHeader.init();
    header.number = 2;
    header.timestamp = 2;
    header.gas_limit = parent.gas_limit;
    header.gas_used = 0;
    header.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    header.difficulty = 0;
    header.nonce = [_]u8{0} ** BlockHeader.NONCE_SIZE;
    header.nonce[BlockHeader.NONCE_SIZE - 1] = 1;
    header.parent_hash = try BlockHeader.hash(&parent, allocator);
    header.base_fee_per_gas = try calculate_base_fee_per_gas(
        header.gas_limit,
        parent.gas_limit,
        parent.gas_used,
        parent.base_fee_per_gas.?,
    );

    const ctx = HeaderValidationContext{
        .allocator = allocator,
        .hardfork = .SHANGHAI,
        .parent_header = &parent,
    };
    try std.testing.expectError(ValidationError.InvalidNonce, MergeValidator.validate(&header, ctx));
}

test "merge_header_validator - prague requires excess blob gas" {
    const PreMergeValidator = struct {
        pub fn validate(_: *const BlockHeader.BlockHeader, _: HeaderValidationContext) ValidationError!void {
            return;
        }
    };

    const MergeValidator = merge_header_validator(PreMergeValidator);
    const allocator = std.testing.allocator;

    var parent = BlockHeader.init();
    parent.number = 1;
    parent.timestamp = 1;
    parent.gas_limit = 10_000;
    parent.gas_used = 0;
    parent.base_fee_per_gas = 100;
    parent.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    parent.excess_blob_gas = 393_216;
    parent.blob_gas_used = 1;

    var header = BlockHeader.init();
    header.number = 2;
    header.timestamp = 2;
    header.gas_limit = parent.gas_limit;
    header.gas_used = 0;
    header.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    header.difficulty = 0;
    header.nonce = [_]u8{0} ** BlockHeader.NONCE_SIZE;
    header.parent_hash = try BlockHeader.hash(&parent, allocator);
    header.base_fee_per_gas = try calculate_base_fee_per_gas(
        header.gas_limit,
        parent.gas_limit,
        parent.gas_used,
        parent.base_fee_per_gas.?,
    );
    // Cancun+: blob_gas_used must also be present; keep it null to trigger error

    const ctx = HeaderValidationContext{
        .allocator = allocator,
        .hardfork = .PRAGUE,
        .parent_header = &parent,
    };
    // blob_gas_used missing takes precedence over excess field presence
    try std.testing.expectError(ValidationError.MissingBlobGasUsed, MergeValidator.validate(&header, ctx));
}

test "merge_header_validator - prague rejects incorrect excess blob gas" {
    const PreMergeValidator = struct {
        pub fn validate(_: *const BlockHeader.BlockHeader, _: HeaderValidationContext) ValidationError!void {
            return;
        }
    };

    const MergeValidator = merge_header_validator(PreMergeValidator);
    const allocator = std.testing.allocator;

    var parent = BlockHeader.init();
    parent.number = 1;
    parent.timestamp = 1;
    parent.gas_limit = 10_000;
    parent.gas_used = 0;
    parent.base_fee_per_gas = 100;
    parent.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    parent.excess_blob_gas = 393_216;
    parent.blob_gas_used = 1;

    var header = BlockHeader.init();
    header.number = 2;
    header.timestamp = 2;
    header.gas_limit = parent.gas_limit;
    header.gas_used = 0;
    header.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    header.difficulty = 0;
    header.nonce = [_]u8{0} ** BlockHeader.NONCE_SIZE;
    header.parent_hash = try BlockHeader.hash(&parent, allocator);
    header.base_fee_per_gas = try calculate_base_fee_per_gas(
        header.gas_limit,
        parent.gas_limit,
        parent.gas_used,
        parent.base_fee_per_gas.?,
    );
    // Required on Cancun+
    header.blob_gas_used = 0;

    header.parent_beacon_block_root = Hash.ZERO;
    const expected_excess_blob_gas = try calculate_excess_blob_gas(.PRAGUE, &parent);
    header.excess_blob_gas = expected_excess_blob_gas + 1;

    const ctx = HeaderValidationContext{
        .allocator = allocator,
        .hardfork = .PRAGUE,
        .parent_header = &parent,
    };
    try std.testing.expectError(ValidationError.InvalidExcessBlobGas, MergeValidator.validate(&header, ctx));
}

test "merge_header_validator - prague accepts correct excess blob gas" {
    const PreMergeValidator = struct {
        pub fn validate(_: *const BlockHeader.BlockHeader, _: HeaderValidationContext) ValidationError!void {
            return;
        }
    };

    const MergeValidator = merge_header_validator(PreMergeValidator);
    const allocator = std.testing.allocator;

    var parent = BlockHeader.init();
    parent.number = 1;
    parent.timestamp = 1;
    parent.gas_limit = 10_000;
    parent.gas_used = 0;
    parent.base_fee_per_gas = 100;
    parent.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    parent.excess_blob_gas = 393_216;
    parent.blob_gas_used = 1;

    var header = BlockHeader.init();
    header.number = 2;
    header.timestamp = 2;
    header.gas_limit = parent.gas_limit;
    header.gas_used = 0;
    header.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    header.difficulty = 0;
    header.nonce = [_]u8{0} ** BlockHeader.NONCE_SIZE;
    header.parent_hash = try BlockHeader.hash(&parent, allocator);
    header.base_fee_per_gas = try calculate_base_fee_per_gas(
        header.gas_limit,
        parent.gas_limit,
        parent.gas_used,
        parent.base_fee_per_gas.?,
    );
    // Required on Cancun+
    header.blob_gas_used = 0;
    header.parent_beacon_block_root = Hash.ZERO;
    header.excess_blob_gas = try calculate_excess_blob_gas(.PRAGUE, &parent);

    const ctx = HeaderValidationContext{
        .allocator = allocator,
        .hardfork = .PRAGUE,
        .parent_header = &parent,
    };
    try MergeValidator.validate(&header, ctx);
}

test "pre-Cancun forbids 4844 blob fields" {
    const PreMergeValidator = struct {
        pub fn validate(_: *const BlockHeader.BlockHeader, _: HeaderValidationContext) ValidationError!void {
            return;
        }
    };

    const allocator = std.testing.allocator;
    const MergeValidator = merge_header_validator(PreMergeValidator);

    var parent = BlockHeader.init();
    parent.number = 1;
    parent.timestamp = 1;
    parent.gas_limit = 10_000;
    parent.gas_used = 0;
    parent.base_fee_per_gas = 100;
    parent.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;

    var header = BlockHeader.init();
    header.number = 2;
    header.timestamp = 2;
    header.gas_limit = parent.gas_limit;
    header.gas_used = 0;
    header.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    header.difficulty = 0;
    header.parent_hash = try BlockHeader.hash(&parent, allocator);
    header.base_fee_per_gas = try calculate_base_fee_per_gas(
        header.gas_limit,
        parent.gas_limit,
        parent.gas_used,
        parent.base_fee_per_gas.?,
    );
    // Illegally set 4844 fields pre-Cancun
    header.blob_gas_used = 0;
    header.excess_blob_gas = 0;

    const ctx = HeaderValidationContext{
        .allocator = allocator,
        .hardfork = .SHANGHAI,
        .parent_header = &parent,
    };
    try std.testing.expectError(ValidationError.UnexpectedBlobFieldsPreCancun, MergeValidator.validate(&header, ctx));
}

test "Cancun+ requires blob_gas_used presence" {
    const PreMergeValidator = struct {
        pub fn validate(_: *const BlockHeader.BlockHeader, _: HeaderValidationContext) ValidationError!void {
            return;
        }
    };

    const allocator = std.testing.allocator;
    const MergeValidator = merge_header_validator(PreMergeValidator);

    var parent = BlockHeader.init();
    parent.number = 1;
    parent.timestamp = 1;
    parent.gas_limit = 10_000;
    parent.gas_used = 0;
    parent.base_fee_per_gas = 100;
    parent.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    parent.excess_blob_gas = 0;
    parent.blob_gas_used = 0;

    var header = BlockHeader.init();
    header.number = 2;
    header.timestamp = 2;
    header.gas_limit = parent.gas_limit;
    header.gas_used = 0;
    header.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    header.difficulty = 0;
    header.parent_hash = try BlockHeader.hash(&parent, allocator);
    header.base_fee_per_gas = try calculate_base_fee_per_gas(
        header.gas_limit,
        parent.gas_limit,
        parent.gas_used,
        parent.base_fee_per_gas.?,
    );
    // Missing blob_gas_used; set only excess to trigger presence validation
    header.excess_blob_gas = 0;

    const ctx = HeaderValidationContext{
        .allocator = allocator,
        .hardfork = .CANCUN,
        .parent_header = &parent,
    };
    try std.testing.expectError(ValidationError.MissingBlobGasUsed, MergeValidator.validate(&header, ctx));
}

test "post-merge: invalid parent hash rejected" {
    const PreMergeValidator = struct {
        pub fn validate(_: *const BlockHeader.BlockHeader, _: HeaderValidationContext) ValidationError!void {
            return;
        }
    };

    const allocator = std.testing.allocator;
    const MergeValidator = merge_header_validator(PreMergeValidator);

    var parent = BlockHeader.init();
    parent.number = 1;
    parent.timestamp = 1;
    parent.gas_limit = 10_000;
    parent.gas_used = 0;
    parent.base_fee_per_gas = 100;
    parent.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;

    var header = BlockHeader.init();
    header.number = 2;
    header.timestamp = 2;
    header.gas_limit = parent.gas_limit;
    header.gas_used = 0;
    header.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    header.difficulty = 0;
    header.nonce = [_]u8{0} ** BlockHeader.NONCE_SIZE;
    // Wrong parent hash on purpose
    header.parent_hash = Hash.ZERO;
    header.base_fee_per_gas = try calculate_base_fee_per_gas(
        header.gas_limit,
        parent.gas_limit,
        parent.gas_used,
        parent.base_fee_per_gas.?,
    );

    const ctx = HeaderValidationContext{
        .allocator = allocator,
        .hardfork = .SHANGHAI,
        .parent_header = &parent,
    };
    try std.testing.expectError(ValidationError.InvalidParentHash, MergeValidator.validate(&header, ctx));
}

test "post-merge: invalid base fee progression rejected" {
    const PreMergeValidator = struct {
        pub fn validate(_: *const BlockHeader.BlockHeader, _: HeaderValidationContext) ValidationError!void {
            return;
        }
    };

    const allocator = std.testing.allocator;
    const MergeValidator = merge_header_validator(PreMergeValidator);

    var parent = BlockHeader.init();
    parent.number = 1;
    parent.timestamp = 1;
    parent.gas_limit = 10_000;
    parent.gas_used = 100; // arbitrary below target
    parent.base_fee_per_gas = 100;
    parent.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;

    var header = BlockHeader.init();
    header.number = 2;
    header.timestamp = 2;
    header.gas_limit = parent.gas_limit;
    header.gas_used = 0;
    header.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    header.difficulty = 0;
    header.nonce = [_]u8{0} ** BlockHeader.NONCE_SIZE;
    header.parent_hash = try BlockHeader.hash(&parent, allocator);
    const expected = try calculate_base_fee_per_gas(
        header.gas_limit,
        parent.gas_limit,
        parent.gas_used,
        parent.base_fee_per_gas.?,
    );
    header.base_fee_per_gas = expected + 1; // force mismatch

    const ctx = HeaderValidationContext{
        .allocator = allocator,
        .hardfork = .MERGE,
        .parent_header = &parent,
    };
    try std.testing.expectError(ValidationError.InvalidBaseFee, MergeValidator.validate(&header, ctx));
}

test "merge validation boundaries cover gas limit and TTD edges" {
    const parent_gas_limit: u64 = 1_000_000;
    const delta = parent_gas_limit / GAS_LIMIT_ADJUSTMENT_FACTOR;

    try std.testing.expect(!check_gas_limit(parent_gas_limit + delta, parent_gas_limit));
    try std.testing.expect(!check_gas_limit(parent_gas_limit - delta, parent_gas_limit));
    try std.testing.expect(check_gas_limit(parent_gas_limit + delta - 1, parent_gas_limit));
    try std.testing.expect(check_gas_limit(parent_gas_limit - delta + 1, parent_gas_limit));

    const parent_gas_used = parent_gas_limit / ELASTICITY_MULTIPLIER;
    const parent_base_fee: u256 = 100;
    try std.testing.expectError(ValidationError.InvalidGasLimit, calculate_base_fee_per_gas(
        parent_gas_limit + delta,
        parent_gas_limit,
        parent_gas_used,
        parent_base_fee,
    ));
    const boundary_fee = try calculate_base_fee_per_gas(
        parent_gas_limit + delta - 1,
        parent_gas_limit,
        parent_gas_used,
        parent_base_fee,
    );
    try std.testing.expectEqual(parent_base_fee, boundary_fee);

    const ttd: u256 = 1000;
    var ctx = HeaderValidationContext{
        .allocator = std.testing.allocator,
        .hardfork = .MERGE,
        .terminal_total_difficulty = ttd,
        .header_total_difficulty = ttd,
        .parent_total_difficulty = ttd - 1,
    };
    // Parent below TTD: the child is the terminal PoW block.
    try std.testing.expect(!is_post_merge(ctx));

    // Parent reached TTD: the child is PoS.
    ctx.parent_total_difficulty = ttd;
    try std.testing.expect(is_post_merge(ctx));
}

/// Ensures the gas limit change from parent to header is strictly less than
/// parent.gas_limit / 1024. Both `parent ± parent / 1024` endpoints are invalid.
///
/// This captures the Yellow Paper rule and EIP-1559 constraint on the
/// maximum change of gas_limit between consecutive blocks. It does not
/// enforce the absolute minimum gas limit (5000).
pub fn validate_gas_limit_delta(
    header: *const BlockHeader.BlockHeader,
    parent: *const BlockHeader.BlockHeader,
) ValidationError!void {
    if (!gas_limit_delta_ok(header.gas_limit, parent.gas_limit))
        return ValidationError.InvalidGasLimit;
}

test "validate_gas_limit_delta - rejects both exclusive endpoints" {
    var parent = BlockHeader.init();
    parent.gas_limit = 1_000_000;

    var header = BlockHeader.init();
    const delta = parent.gas_limit / GAS_LIMIT_ADJUSTMENT_FACTOR;
    try std.testing.expectEqual(@as(u64, 976), delta);

    header.gas_limit = 1_000_976;
    try std.testing.expectError(ValidationError.InvalidGasLimit, validate_gas_limit_delta(&header, &parent));

    header.gas_limit = 999_024;
    try std.testing.expectError(ValidationError.InvalidGasLimit, validate_gas_limit_delta(&header, &parent));
}

test "validate_gas_limit_delta - accepts one inside each endpoint" {
    var parent = BlockHeader.init();
    parent.gas_limit = 1_000_000;

    var header = BlockHeader.init();
    header.gas_limit = 1_000_975;
    try validate_gas_limit_delta(&header, &parent);

    header.gas_limit = 999_025;
    try validate_gas_limit_delta(&header, &parent);

    header.gas_limit = parent.gas_limit;
    try validate_gas_limit_delta(&header, &parent);
}

test "validate_gas_limit_delta - extreme values do not overflow" {
    var parent = BlockHeader.init();
    var header = BlockHeader.init();

    parent.gas_limit = std.math.maxInt(u64);
    header.gas_limit = std.math.maxInt(u64);
    try validate_gas_limit_delta(&header, &parent);

    header.gas_limit = 0;
    try std.testing.expectError(ValidationError.InvalidGasLimit, validate_gas_limit_delta(&header, &parent));
}

test "check_gas_limit - rejects endpoints and enforces minimum" {
    try std.testing.expect(!check_gas_limit(1_000_976, 1_000_000));
    try std.testing.expect(!check_gas_limit(999_024, 1_000_000));
    try std.testing.expect(check_gas_limit(1_000_975, 1_000_000));
    try std.testing.expect(check_gas_limit(999_025, 1_000_000));
    // 5000 / 1024 = 4, so 4999 is within the delta but below GAS_LIMIT_MINIMUM.
    try std.testing.expect(!check_gas_limit(4_999, 5_000));
    try std.testing.expect(check_gas_limit(5_000, 5_000));
}

test "validate_gas_limit_delta - rejects above max delta" {
    var parent = BlockHeader.init();
    parent.gas_limit = 1_000_000;

    var header = BlockHeader.init();
    const delta = parent.gas_limit / GAS_LIMIT_ADJUSTMENT_FACTOR;
    header.gas_limit = parent.gas_limit + delta + 1;

    try std.testing.expectError(ValidationError.InvalidGasLimit, validate_gas_limit_delta(&header, &parent));
}

test "validate_gas_limit_delta - rejects below max delta" {
    var parent = BlockHeader.init();
    parent.gas_limit = 1_000_000;

    var header = BlockHeader.init();
    const delta = parent.gas_limit / GAS_LIMIT_ADJUSTMENT_FACTOR;
    header.gas_limit = parent.gas_limit - delta - 1;

    try std.testing.expectError(ValidationError.InvalidGasLimit, validate_gas_limit_delta(&header, &parent));
}

/// Pre-merge validator that accepts everything, so tests observe routing.
const AcceptAllPreMerge = struct {
    pub fn validate(_: *const BlockHeader.BlockHeader, _: HeaderValidationContext) ValidationError!void {
        return;
    }
};

/// Builds a valid post-merge child of `parent` for `hardfork`, filling blob
/// fields and the parent beacon root from Cancun on.
fn test_post_merge_child(
    hardfork: Hardfork,
    parent: *const BlockHeader.BlockHeader,
    blob_gas_used: u64,
) !BlockHeader.BlockHeader {
    var header = BlockHeader.init();
    header.number = parent.number + 1;
    header.timestamp = parent.timestamp + 1;
    header.gas_limit = parent.gas_limit;
    header.gas_used = 0;
    header.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    header.difficulty = 0;
    header.nonce = [_]u8{0} ** BlockHeader.NONCE_SIZE;
    header.parent_hash = try BlockHeader.hash(parent, std.testing.allocator);
    header.base_fee_per_gas = try calculate_base_fee_per_gas(
        header.gas_limit,
        parent.gas_limit,
        parent.gas_used,
        parent.base_fee_per_gas.?,
    );
    if (hardfork.hasEIP4844()) {
        header.blob_gas_used = blob_gas_used;
        header.excess_blob_gas = try calculate_excess_blob_gas(hardfork, parent);
        header.parent_beacon_block_root = Hash.ZERO;
    }
    return header;
}

fn test_parent(excess_blob_gas: ?u64, blob_gas_used: ?u64) BlockHeader.BlockHeader {
    var parent = BlockHeader.init();
    parent.number = 1;
    parent.timestamp = 1;
    parent.gas_limit = 10_000;
    parent.gas_used = 0;
    parent.base_fee_per_gas = 1;
    parent.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    parent.excess_blob_gas = excess_blob_gas;
    parent.blob_gas_used = blob_gas_used;
    return parent;
}

test "merge_header_validator - fork, not candidate difficulty, selects PoS rules" {
    const MergeValidator = merge_header_validator(AcceptAllPreMerge);
    const parent = test_parent(null, null);
    var header = try test_post_merge_child(.SHANGHAI, &parent, 0);
    try MergeValidator.validate(&header, .{
        .allocator = std.testing.allocator,
        .hardfork = .SHANGHAI,
        .parent_header = &parent,
    });

    // A forged nonzero difficulty must not route to the accept-all pre-merge validator.
    header.difficulty = 1;
    try std.testing.expectError(ValidationError.InvalidDifficulty, MergeValidator.validate(&header, .{
        .allocator = std.testing.allocator,
        .hardfork = .SHANGHAI,
        .parent_header = &parent,
    }));
}

test "merge_header_validator - parent TD at TTD selects PoS rules despite candidate difficulty" {
    const MergeValidator = merge_header_validator(AcceptAllPreMerge);
    const parent = test_parent(null, null);
    var header = try test_post_merge_child(.MERGE, &parent, 0);
    header.difficulty = 1;
    const ttd: u256 = 1000;
    try std.testing.expectError(ValidationError.InvalidDifficulty, MergeValidator.validate(&header, .{
        .allocator = std.testing.allocator,
        .hardfork = .MERGE,
        .parent_header = &parent,
        .terminal_total_difficulty = ttd,
        .header_total_difficulty = ttd + 1,
        .parent_total_difficulty = ttd,
    }));
}

test "calculate_excess_blob_gas - Prague target 6 blobs, Cancun target 3 blobs" {
    // Prague: parent excess 0 + 6 blobs used equals the target, so excess stays 0.
    const prague_parent = test_parent(0, 786_432);
    try std.testing.expectEqual(@as(u64, 0), try calculate_excess_blob_gas(.PRAGUE, &prague_parent));
    // The same parent under Cancun exceeds the 3-blob target by 3 blobs.
    try std.testing.expectEqual(@as(u64, 393_216), try calculate_excess_blob_gas(.CANCUN, &prague_parent));
    // Cancun: 3 blobs used equals the target.
    const cancun_parent = test_parent(0, 393_216);
    try std.testing.expectEqual(@as(u64, 0), try calculate_excess_blob_gas(.CANCUN, &cancun_parent));
    // Parent without blob fields (fork transition) counts as zero.
    const pre_cancun_parent = test_parent(null, null);
    try std.testing.expectEqual(@as(u64, 0), try calculate_excess_blob_gas(.CANCUN, &pre_cancun_parent));
}

test "calculate_excess_blob_gas - Osaka reserve price (EIP-7918)" {
    // Parent base fee 1: BLOB_BASE_COST * 1 = 8192 < GAS_PER_BLOB * 1, so the
    // Prague formula applies.
    var parent = test_parent(0, 9 * GAS_PER_BLOB);
    try std.testing.expectEqual(@as(u64, 3 * GAS_PER_BLOB), try calculate_excess_blob_gas(.OSAKA, &parent));
    // Parent base fee 17: 8192 * 17 > 131072 * 1, so excess grows by
    // blob_gas_used * (max - target) / max = 9 blobs * 3 / 9.
    parent.base_fee_per_gas = 17;
    try std.testing.expectEqual(@as(u64, 3 * GAS_PER_BLOB), try calculate_excess_blob_gas(.OSAKA, &parent));
    parent.excess_blob_gas = 6 * GAS_PER_BLOB;
    parent.blob_gas_used = 6 * GAS_PER_BLOB;
    // Prague formula would give 6 blobs; the reserve price gives 6 + 6 * 3 / 9 = 8 blobs.
    try std.testing.expectEqual(@as(u64, 6 * GAS_PER_BLOB), try calculate_excess_blob_gas(.PRAGUE, &parent));
    try std.testing.expectEqual(@as(u64, 8 * GAS_PER_BLOB), try calculate_excess_blob_gas(.OSAKA, &parent));
}

test "merge_header_validator - Prague accepts excess 0 after 6-blob parent" {
    const MergeValidator = merge_header_validator(AcceptAllPreMerge);
    const parent = test_parent(0, 786_432);
    const header = try test_post_merge_child(.PRAGUE, &parent, 0);
    try std.testing.expectEqual(@as(?u64, 0), header.excess_blob_gas);
    try MergeValidator.validate(&header, .{
        .allocator = std.testing.allocator,
        .hardfork = .PRAGUE,
        .parent_header = &parent,
    });
}

test "merge_header_validator - Cancun accepts excess 0 after 3-blob parent and rejects Prague value" {
    const MergeValidator = merge_header_validator(AcceptAllPreMerge);
    const parent = test_parent(0, 393_216);
    var header = try test_post_merge_child(.CANCUN, &parent, 0);
    const ctx = HeaderValidationContext{
        .allocator = std.testing.allocator,
        .hardfork = .CANCUN,
        .parent_header = &parent,
    };
    try MergeValidator.validate(&header, ctx);

    const six_blob_parent = test_parent(0, 786_432);
    header = try test_post_merge_child(.CANCUN, &six_blob_parent, 0);
    try std.testing.expectEqual(@as(?u64, 393_216), header.excess_blob_gas);
    header.excess_blob_gas = 0;
    try std.testing.expectError(ValidationError.InvalidExcessBlobGas, MergeValidator.validate(&header, .{
        .allocator = std.testing.allocator,
        .hardfork = .CANCUN,
        .parent_header = &six_blob_parent,
    }));
}

test "merge_header_validator - blob_gas_used above per-fork max rejected" {
    const MergeValidator = merge_header_validator(AcceptAllPreMerge);
    const parent = test_parent(0, 0);

    // Cancun max is 6 blobs; Prague max is 9 blobs.
    var cancun = try test_post_merge_child(.CANCUN, &parent, 6 * GAS_PER_BLOB);
    const cancun_ctx = HeaderValidationContext{ .allocator = std.testing.allocator, .hardfork = .CANCUN, .parent_header = &parent };
    try MergeValidator.validate(&cancun, cancun_ctx);
    cancun.blob_gas_used = 7 * GAS_PER_BLOB;
    try std.testing.expectError(ValidationError.InvalidBlobGasUsed, MergeValidator.validate(&cancun, cancun_ctx));

    var prague = try test_post_merge_child(.PRAGUE, &parent, 9 * GAS_PER_BLOB);
    const prague_ctx = HeaderValidationContext{ .allocator = std.testing.allocator, .hardfork = .PRAGUE, .parent_header = &parent };
    try MergeValidator.validate(&prague, prague_ctx);
    prague.blob_gas_used = 10 * GAS_PER_BLOB;
    try std.testing.expectError(ValidationError.InvalidBlobGasUsed, MergeValidator.validate(&prague, prague_ctx));
}

test "merge_header_validator - blob_gas_used not a multiple of GAS_PER_BLOB rejected" {
    const MergeValidator = merge_header_validator(AcceptAllPreMerge);
    const parent = test_parent(0, 0);
    const header = try test_post_merge_child(.PRAGUE, &parent, 1);
    try std.testing.expectError(ValidationError.InvalidBlobGasUsed, MergeValidator.validate(&header, .{
        .allocator = std.testing.allocator,
        .hardfork = .PRAGUE,
        .parent_header = &parent,
    }));
}

test "merge_header_validator - Cancun+ requires parent_beacon_block_root" {
    const MergeValidator = merge_header_validator(AcceptAllPreMerge);
    const parent = test_parent(0, 0);
    var header = try test_post_merge_child(.CANCUN, &parent, 0);
    header.parent_beacon_block_root = null;
    try std.testing.expectError(ValidationError.MissingParentBeaconBlockRoot, MergeValidator.validate(&header, .{
        .allocator = std.testing.allocator,
        .hardfork = .CANCUN,
        .parent_header = &parent,
    }));
}

test "merge_header_validator - pre-Cancun forbids parent_beacon_block_root" {
    const MergeValidator = merge_header_validator(AcceptAllPreMerge);
    const parent = test_parent(null, null);
    var header = try test_post_merge_child(.SHANGHAI, &parent, 0);
    header.parent_beacon_block_root = Hash.ZERO;
    try std.testing.expectError(ValidationError.UnexpectedBlobFieldsPreCancun, MergeValidator.validate(&header, .{
        .allocator = std.testing.allocator,
        .hardfork = .SHANGHAI,
        .parent_header = &parent,
    }));
}
