/// Block header validation helpers for post-merge (PoS) rules.
const std = @import("std");
const primitives = @import("primitives");
const Blob = primitives.Blob;
const BlockHeader = primitives.BlockHeader;
const Hash = primitives.Hash;
const Hardfork = primitives.Hardfork;

/// Errors returned by PoS header constant validation.
pub const ValidationError = error{
    InvalidDifficulty,
    InvalidMixHash,
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
    BaseFeeOverflow,
    MissingExcessBlobGas,
    InvalidExcessBlobGas,
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

fn check_gas_limit(gas_limit: u64, parent_gas_limit: u64) bool {
    const max_adjustment_delta = parent_gas_limit / GAS_LIMIT_ADJUSTMENT_FACTOR;
    if (gas_limit > parent_gas_limit + max_adjustment_delta) return false;
    if (gas_limit < parent_gas_limit - max_adjustment_delta) return false;
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
        ) catch return ValidationError.BaseFeeOverflow;
        const target_fee_gas_delta = parent_fee_gas_delta / @as(u256, parent_gas_target);
        var base_fee_per_gas_delta = target_fee_gas_delta / @as(u256, BASE_FEE_MAX_CHANGE_DENOMINATOR);
        if (base_fee_per_gas_delta == 0) base_fee_per_gas_delta = 1;
        return std.math.add(u256, parent_base_fee_per_gas, base_fee_per_gas_delta) catch
            return ValidationError.BaseFeeOverflow;
    }

    const gas_used_delta = parent_gas_target - parent_gas_used;
    const parent_fee_gas_delta = std.math.mul(
        u256,
        parent_base_fee_per_gas,
        @as(u256, gas_used_delta),
    ) catch return ValidationError.BaseFeeOverflow;
    const target_fee_gas_delta = parent_fee_gas_delta / @as(u256, parent_gas_target);
    const base_fee_per_gas_delta = target_fee_gas_delta / @as(u256, BASE_FEE_MAX_CHANGE_DENOMINATOR);
    if (parent_base_fee_per_gas < base_fee_per_gas_delta) return ValidationError.BaseFeeOverflow;
    return parent_base_fee_per_gas - base_fee_per_gas_delta;
}

fn validate_post_merge_header(
    header: *const BlockHeader.BlockHeader,
    ctx: HeaderValidationContext,
) ValidationError!void {
    if (header.number < 1) return ValidationError.InvalidBlockNumber;

    const parent_header = ctx.parent_header orelse return ValidationError.MissingParentHeader;

    if (ctx.hardfork.hasEIP4844()) {
        const header_excess_blob_gas = header.excess_blob_gas orelse return ValidationError.MissingExcessBlobGas;
        const parent_excess_blob_gas = parent_header.excess_blob_gas orelse 0;
        const parent_blob_gas_used = parent_header.blob_gas_used orelse 0;
        const expected_excess_blob_gas = Blob.calculateExcessBlobGas(parent_excess_blob_gas, parent_blob_gas_used);
        if (header_excess_blob_gas != expected_excess_blob_gas) {
            return ValidationError.InvalidExcessBlobGas;
        }
    }

    if (header.gas_used > header.gas_limit) return ValidationError.InvalidGasUsed;

    const parent_base_fee = parent_header.base_fee_per_gas orelse return ValidationError.MissingBaseFee;
    const expected_base_fee = try calculate_base_fee_per_gas(
        header.gas_limit,
        parent_header.gas_limit,
        parent_header.gas_used,
        parent_base_fee,
    );
    const header_base_fee = header.base_fee_per_gas orelse return ValidationError.MissingBaseFee;
    if (expected_base_fee != header_base_fee) return ValidationError.InvalidBaseFee;

    if (header.timestamp <= parent_header.timestamp) return ValidationError.InvalidTimestamp;
    if (header.number != parent_header.number + 1) return ValidationError.InvalidBlockNumber;

    try validate_pos_header_constants(header);

    const parent_hash = try BlockHeader.hash(parent_header, ctx.allocator);
    if (!Hash.equals(&header.parent_hash, &parent_hash)) return ValidationError.InvalidParentHash;
}

fn is_post_merge(header: *const BlockHeader.BlockHeader, ctx: HeaderValidationContext) bool {
    if (ctx.terminal_total_difficulty) |ttd| {
        if (ctx.header_total_difficulty) |td| {
            if (td < ttd) return false;
            if (header.difficulty != 0) return false;
            if (ctx.parent_total_difficulty) |parent_td| {
                if (parent_td < ttd) return false;
            }
            return true;
        }
        return header.difficulty == 0;
    }
    return ctx.hardfork.isAtLeast(.MERGE) and header.difficulty == 0;
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
            if (is_post_merge(header, ctx)) {
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

    const ctx = HeaderValidationContext{
        .allocator = allocator,
        .hardfork = .PRAGUE,
        .parent_header = &parent,
    };
    try std.testing.expectError(ValidationError.MissingExcessBlobGas, MergeValidator.validate(&header, ctx));
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

    const expected_excess_blob_gas = Blob.calculateExcessBlobGas(
        parent.excess_blob_gas.?,
        parent.blob_gas_used.?,
    );
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
    header.excess_blob_gas = Blob.calculateExcessBlobGas(
        parent.excess_blob_gas.?,
        parent.blob_gas_used.?,
    );

    const ctx = HeaderValidationContext{
        .allocator = allocator,
        .hardfork = .PRAGUE,
        .parent_header = &parent,
    };
    try MergeValidator.validate(&header, ctx);
}
