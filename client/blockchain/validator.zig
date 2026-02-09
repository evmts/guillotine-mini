/// Block header validation helpers for post-merge (PoS) rules.
const std = @import("std");
const primitives = @import("primitives");
const BlockHeader = primitives.BlockHeader;
const Hash = primitives.Hash;
const Hardfork = primitives.Hardfork;

/// Errors returned by PoS header constant validation.
pub const ValidationError = error{
    InvalidDifficulty,
    InvalidNonce,
    InvalidOmmersHash,
    InvalidExtraDataLength,
};

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

/// Merge-aware header validator that enforces PoS constants post-merge and
/// delegates to a pre-merge validator otherwise.
pub fn merge_header_validator(comptime PreMergeValidator: type) type {
    return struct {
        /// Validate a header under the given hardfork.
        pub fn validate(header: *const BlockHeader.BlockHeader, hardfork: Hardfork) ValidationError!void {
            if (hardfork.isAtLeast(.MERGE)) {
                return validate_pos_header_constants(header);
            }
            return PreMergeValidator.validate(header, hardfork);
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

test "merge_header_validator - delegates to pre-merge validator" {
    const PreMergeValidator = struct {
        pub fn validate(_: *const BlockHeader.BlockHeader, _: Hardfork) ValidationError!void {
            return ValidationError.InvalidDifficulty;
        }
    };

    const MergeValidator = merge_header_validator(PreMergeValidator);
    var header = BlockHeader.init();
    header.difficulty = 1;

    try std.testing.expectError(ValidationError.InvalidDifficulty, MergeValidator.validate(&header, .LONDON));
}

test "merge_header_validator - enforces PoS constants post-merge" {
    const PreMergeValidator = struct {
        pub fn validate(_: *const BlockHeader.BlockHeader, _: Hardfork) ValidationError!void {
            return;
        }
    };

    const MergeValidator = merge_header_validator(PreMergeValidator);
    var header = BlockHeader.init();
    header.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    header.difficulty = 1;

    try std.testing.expectError(ValidationError.InvalidDifficulty, MergeValidator.validate(&header, .MERGE));
}
