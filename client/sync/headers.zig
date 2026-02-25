/// GetBlockHeaders request helper (Nethermind-aligned shape).
///
/// Encodes the four parameters of the eth/69 GetBlockHeaders request:
/// - startblock: by block number or block hash (canonical chain)
/// - limit: maximum headers to return (soft-limited per peer)
/// - skip: number of headers to skip between results (step = skip + 1)
/// - reverse: 0 = ascending numbers, 1 = descending numbers
///
/// This module provides small, allocation-free constructors for common patterns:
/// - ascending/descending contiguous ranges (skip = 0)
/// - explicit stride requests for header skeleton building
const std = @import("std");
const primitives = @import("voltaire");
const Hash = primitives.Hash;
const BlockNumber = primitives.BlockNumber;

/// Origin discriminator: number or hash (per devp2p eth spec).
pub const Origin = union(enum) {
    number: BlockNumber.BlockNumber,
    hash: Hash.Hash,
};

/// Request container matching eth GetBlockHeaders semantics.
pub const HeadersRequest = struct {
    origin: Origin,
    limit: usize,
    skip: usize,
    reverse: bool,

    /// Construct from block number.
    pub fn fromNumber(number: BlockNumber.BlockNumber, limit: usize, skip: usize, reverse: bool) HeadersRequest {
        return .{ .origin = .{ .number = number }, .limit = limit, .skip = skip, .reverse = reverse };
    }

    /// Construct from block hash.
    pub fn fromHash(hash: Hash.Hash, limit: usize, skip: usize, reverse: bool) HeadersRequest {
        return .{ .origin = .{ .hash = hash }, .limit = limit, .skip = skip, .reverse = reverse };
    }

    /// Contiguous ascending range starting at `start` with `count` headers.
    pub fn ascendingFrom(start: BlockNumber.BlockNumber, count: usize) HeadersRequest {
        return HeadersRequest.fromNumber(start, count, 0, false);
    }

    /// Contiguous descending range starting at `start` with `count` headers.
    pub fn descendingFrom(start: BlockNumber.BlockNumber, count: usize) HeadersRequest {
        return HeadersRequest.fromNumber(start, count, 0, true);
    }

    /// Skeleton-style request using explicit `stride` (step = stride = skip+1).
    /// Returns error.InvalidStride if `stride` is zero.
    /// Caller provides `stride >= 1`; internally we store `skip = stride - 1`.
    pub fn skeletonFrom(start: BlockNumber.BlockNumber, stride: usize, count: usize, reverse: bool) error{InvalidStride}!HeadersRequest {
        if (stride == 0) return error.InvalidStride;
        return HeadersRequest.fromNumber(start, count, stride - 1, reverse);
    }
};

// ============================================================================
// Tests
// ============================================================================

test "HeadersRequest.fromNumber assigns fields" {
    const req = HeadersRequest.fromNumber(100, 192, 0, true);
    try std.testing.expect(req.reverse);
    try std.testing.expectEqual(@as(usize, 192), req.limit);
    try std.testing.expectEqual(@as(usize, 0), req.skip);
    try std.testing.expect(req.origin == .number);
    try std.testing.expectEqual(@as(u64, 100), req.origin.number);
}

test "HeadersRequest.fromHash assigns fields" {
    var h: Hash.Hash = [_]u8{0xaa} ** 32;
    const req = HeadersRequest.fromHash(h, 64, 7, false);
    try std.testing.expect(!req.reverse);
    try std.testing.expectEqual(@as(usize, 64), req.limit);
    try std.testing.expectEqual(@as(usize, 7), req.skip);
    try std.testing.expect(req.origin == .hash);
    try std.testing.expectEqualSlices(u8, &h, &req.origin.hash);
}

test "HeadersRequest.ascendingFrom and descendingFrom set skip=0 and direction" {
    const asc = HeadersRequest.ascendingFrom(5, 10);
    try std.testing.expect(!asc.reverse);
    try std.testing.expectEqual(@as(usize, 0), asc.skip);
    try std.testing.expectEqual(@as(usize, 10), asc.limit);
    try std.testing.expect(asc.origin == .number);
    try std.testing.expectEqual(@as(u64, 5), asc.origin.number);

    const desc = HeadersRequest.descendingFrom(500, 3);
    try std.testing.expect(desc.reverse);
    try std.testing.expectEqual(@as(usize, 0), desc.skip);
    try std.testing.expectEqual(@as(usize, 3), desc.limit);
    try std.testing.expect(desc.origin == .number);
    try std.testing.expectEqual(@as(u64, 500), desc.origin.number);
}

test "HeadersRequest.skeletonFrom stores skip=stride-1" {
    const sk = try HeadersRequest.skeletonFrom(1000, 193, 512, true);
    try std.testing.expect(sk.reverse);
    try std.testing.expectEqual(@as(usize, 512), sk.limit);
    try std.testing.expectEqual(@as(usize, 192), sk.skip); // stride - 1
    try std.testing.expect(sk.origin == .number);
    try std.testing.expectEqual(@as(u64, 1000), sk.origin.number);
}

test "HeadersRequest.skeletonFrom rejects stride=0" {
    try std.testing.expectError(error.InvalidStride, HeadersRequest.skeletonFrom(100, 0, 10, false));
}
