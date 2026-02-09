/// Block header validation helpers for post-merge (PoS) rules.
const std = @import("std");
const primitives = @import("primitives");
const BlockHeader = primitives.BlockHeader;
const Hash = primitives.Hash;

/// Validate PoS header constants: difficulty=0, nonce=0, ommers=empty list hash.
pub fn validatePosHeaderConstants(header: *const BlockHeader.BlockHeader) !void {
    if (header.difficulty != 0) return error.InvalidDifficulty;
    if (!std.mem.allEqual(u8, header.nonce[0..], 0)) return error.InvalidNonce;
    if (!Hash.equals(&header.ommers_hash, &BlockHeader.EMPTY_OMMERS_HASH)) {
        return error.InvalidOmmersHash;
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

    try std.testing.expectError(error.InvalidDifficulty, validatePosHeaderConstants(&header));
}

test "validatePosHeaderConstants - rejects non-zero nonce" {
    var header = BlockHeader.init();
    header.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
    header.nonce = [_]u8{0} ** BlockHeader.NONCE_SIZE;
    header.nonce[BlockHeader.NONCE_SIZE - 1] = 1;

    try std.testing.expectError(error.InvalidNonce, validatePosHeaderConstants(&header));
}

test "validatePosHeaderConstants - rejects non-empty ommers hash" {
    var header = BlockHeader.init();
    header.ommers_hash = Hash.ZERO;

    try std.testing.expectError(error.InvalidOmmersHash, validatePosHeaderConstants(&header));
}
