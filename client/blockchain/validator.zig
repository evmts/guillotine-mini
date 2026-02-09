/// Block header validation helpers for post-merge (PoS) rules.
const std = @import("std");
const primitives = @import("primitives");
const BlockHeader = primitives.BlockHeader;
const Hash = primitives.Hash;

pub const ValidationError = error{
    InvalidDifficulty,
    InvalidNonce,
    InvalidOmmersHash,
};

/// Validate PoS header constants: difficulty=0, nonce=0, ommers=empty list hash.
pub fn validatePosHeaderConstants(header: *const BlockHeader.BlockHeader) ValidationError!void {
    if (header.difficulty != 0) return ValidationError.InvalidDifficulty;
    if (!std.mem.allEqual(u8, header.nonce[0..], 0)) return ValidationError.InvalidNonce;
    if (!Hash.equals(&header.ommers_hash, &BlockHeader.EMPTY_OMMERS_HASH)) {
        return ValidationError.InvalidOmmersHash;
    }
}

test "validatePosHeaderConstants - accepts valid PoS constants" {
    var header = BlockHeader.init();
    header.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;

    try validatePosHeaderConstants(&header);
}

test "validatePosHeaderConstants - rejects non-zero difficulty" {
    var header = BlockHeader.init();
    header.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    header.difficulty = 1;

    try std.testing.expectError(ValidationError.InvalidDifficulty, validatePosHeaderConstants(&header));
}

test "validatePosHeaderConstants - rejects non-zero nonce" {
    var header = BlockHeader.init();
    header.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    header.nonce = [_]u8{0} ** BlockHeader.NONCE_SIZE;
    header.nonce[BlockHeader.NONCE_SIZE - 1] = 1;

    try std.testing.expectError(ValidationError.InvalidNonce, validatePosHeaderConstants(&header));
}

test "validatePosHeaderConstants - rejects non-empty ommers hash" {
    var header = BlockHeader.init();
    header.ommers_hash = Hash.ZERO;

    try std.testing.expectError(ValidationError.InvalidOmmersHash, validatePosHeaderConstants(&header));
}
