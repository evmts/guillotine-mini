/// Full sync request container for block bodies and receipts.
///
/// Mirrors Nethermind's BlocksRequest (BlockDownloadRequest) shape:
/// - separate body + receipt request lists (by block header)
/// - optional response payloads, in request order
const std = @import("std");
const primitives = @import("primitives");
const BlockHeader = primitives.BlockHeader;
const BlockBody = primitives.BlockBody;
const Hash = primitives.Hash;
const Receipt = primitives.Receipt;

/// Block body + receipt request/response container.
///
/// Requests are ordered lists of block headers. Responses must preserve
/// the same order as requested, per devp2p eth protocol expectations.
pub const BlocksRequest = struct {
    /// Block headers for GetBlockBodies.
    body_headers: []const BlockHeader.BlockHeader,
    /// Block headers for GetReceipts.
    receipt_headers: []const BlockHeader.BlockHeader,
    /// Optional block bodies, aligned with `body_headers`.
    /// Missing bodies are represented as null entries.
    /// Responses may be shorter than the request; missing tail entries are treated as unavailable.
    bodies: ?[]const ?BlockBody.BlockBody = null,
    /// Optional receipts per block, aligned with `receipt_headers`.
    /// Missing receipts are represented as null entries.
    /// Responses may be shorter than the request; missing tail entries are treated as unavailable.
    receipts: ?[]const ?[]const Receipt.Receipt = null,
    /// Optional arena owning response buffers. Must be deinit'd by caller.
    response_arena: ?std.heap.ArenaAllocator = null,

    /// Errors returned when response slices do not align with requested headers.
    pub const ResponseAlignmentError = error{
        BodyAlignmentMismatch,
        ReceiptAlignmentMismatch,
    };

    /// Returns an empty request (no body or receipt queries).
    pub fn empty() BlocksRequest {
        return .{
            .body_headers = &[_]BlockHeader.BlockHeader{},
            .receipt_headers = &[_]BlockHeader.BlockHeader{},
            .bodies = null,
            .receipts = null,
            .response_arena = null,
        };
    }

    /// Initialize a request that owns response buffers via an arena allocator.
    /// Call `deinit` when the response data is no longer needed.
    pub fn init_owned(
        body_headers: []const BlockHeader.BlockHeader,
        receipt_headers: []const BlockHeader.BlockHeader,
        allocator: std.mem.Allocator,
    ) BlocksRequest {
        return .{
            .body_headers = body_headers,
            .receipt_headers = receipt_headers,
            .bodies = null,
            .receipts = null,
            .response_arena = std.heap.ArenaAllocator.init(allocator),
        };
    }

    /// True if there are no body or receipt requests.
    pub fn is_empty(self: BlocksRequest) bool {
        return self.body_headers.len == 0 and self.receipt_headers.len == 0;
    }

    /// Compute block hashes for the body request headers.
    /// Caller owns the returned slice.
    pub fn body_hashes(self: BlocksRequest, allocator: std.mem.Allocator) ![]const Hash.Hash {
        return headers_to_hashes(self.body_headers, allocator);
    }

    /// Return the allocator backing the owned response arena, if present.
    pub fn response_allocator(self: *BlocksRequest) ?std.mem.Allocator {
        if (self.response_arena) |*arena| {
            return arena.allocator();
        }
        return null;
    }

    /// Release owned response buffers and clear response slices.
    pub fn deinit(self: *BlocksRequest) void {
        if (self.response_arena) |*arena| {
            arena.deinit();
        }
        self.response_arena = null;
        self.bodies = null;
        self.receipts = null;
    }

    /// Set bodies response, allowing truncated responses.
    /// Responses must not exceed the requested length; use nulls to represent missing middle entries.
    pub fn set_bodies(self: *BlocksRequest, bodies: []const ?BlockBody.BlockBody) ResponseAlignmentError!void {
        try ensure_alignment(self.body_headers.len, bodies.len, ResponseAlignmentError.BodyAlignmentMismatch);
        self.bodies = bodies;
    }

    /// Set receipts response, allowing truncated responses.
    /// Responses must not exceed the requested length; use nulls to represent missing middle entries.
    pub fn set_receipts(self: *BlocksRequest, receipts: []const ?[]const Receipt.Receipt) ResponseAlignmentError!void {
        try ensure_alignment(self.receipt_headers.len, receipts.len, ResponseAlignmentError.ReceiptAlignmentMismatch);
        self.receipts = receipts;
    }

    fn ensure_alignment(expected_len: usize, actual_len: usize, err: ResponseAlignmentError) ResponseAlignmentError!void {
        if (actual_len > expected_len) {
            return err;
        }
    }

    fn headers_to_hashes(headers: []const BlockHeader.BlockHeader, allocator: std.mem.Allocator) ![]const Hash.Hash {
        var hashes = try allocator.alloc(Hash.Hash, headers.len);
        for (headers, 0..) |_, index| {
            hashes[index] = try BlockHeader.hash(&headers[index], allocator);
        }
        return hashes;
    }
};

// ============================================================================
// Tests
// ============================================================================

test "BlocksRequest.empty returns empty slices and null responses" {
    const req = BlocksRequest.empty();
    try std.testing.expect(req.is_empty());
    try std.testing.expect(req.bodies == null);
    try std.testing.expect(req.receipts == null);
}

test "BlocksRequest.is_empty detects pending body hashes" {
    const headers = &[_]BlockHeader.BlockHeader{BlockHeader.init()};
    const req = BlocksRequest{
        .body_headers = headers,
        .receipt_headers = &[_]BlockHeader.BlockHeader{},
        .bodies = null,
        .receipts = null,
    };
    try std.testing.expect(!req.is_empty());
}

test "BlocksRequest.is_empty detects pending receipt hashes" {
    const headers = &[_]BlockHeader.BlockHeader{BlockHeader.init()};
    const req = BlocksRequest{
        .body_headers = &[_]BlockHeader.BlockHeader{},
        .receipt_headers = headers,
        .bodies = null,
        .receipts = null,
    };
    try std.testing.expect(!req.is_empty());
}

test "BlocksRequest.body_hashes returns ordered hashes" {
    var header1 = BlockHeader.init();
    header1.number = 1;
    var header2 = BlockHeader.init();
    header2.number = 2;
    const headers = &[_]BlockHeader.BlockHeader{ header1, header2 };

    const req = BlocksRequest{
        .body_headers = headers,
        .receipt_headers = &[_]BlockHeader.BlockHeader{},
        .bodies = null,
        .receipts = null,
    };

    const allocator = std.testing.allocator;
    const hashes = try req.body_hashes(allocator);
    defer allocator.free(hashes);

    const expected1 = try BlockHeader.hash(&headers[0], allocator);
    const expected2 = try BlockHeader.hash(&headers[1], allocator);

    try std.testing.expectEqual(@as(usize, headers.len), hashes.len);
    try std.testing.expect(Hash.equals(&hashes[0], &expected1));
    try std.testing.expect(Hash.equals(&hashes[1], &expected2));
}

test "BlocksRequest.body_hashes returns owned empty slice" {
    const req = BlocksRequest.empty();
    const allocator = std.testing.allocator;
    const hashes = try req.body_hashes(allocator);
    try std.testing.expectEqual(@as(usize, 0), hashes.len);
    allocator.free(hashes);
}

test "BlocksRequest.set_bodies allows truncated responses and missing entries" {
    const headers = &[_]BlockHeader.BlockHeader{ BlockHeader.init(), BlockHeader.init() };
    var req = BlocksRequest{
        .body_headers = headers,
        .receipt_headers = &[_]BlockHeader.BlockHeader{},
        .bodies = null,
        .receipts = null,
    };

    const oversized = &[_]?BlockBody.BlockBody{ null, null, BlockBody.init() };
    try std.testing.expectError(BlocksRequest.ResponseAlignmentError.BodyAlignmentMismatch, req.set_bodies(oversized));

    const truncated = &[_]?BlockBody.BlockBody{BlockBody.init()};
    try req.set_bodies(truncated);
    try std.testing.expect(req.bodies != null);
    try std.testing.expect(req.bodies.?.len == 1);

    const aligned = &[_]?BlockBody.BlockBody{ null, BlockBody.init() };
    try req.set_bodies(aligned);
    try std.testing.expect(req.bodies != null);
    try std.testing.expect(req.bodies.?.len == headers.len);
    try std.testing.expect(req.bodies.?[0] == null);
}

test "BlocksRequest.set_receipts allows truncated responses and missing entries" {
    const headers = &[_]BlockHeader.BlockHeader{ BlockHeader.init(), BlockHeader.init() };
    var req = BlocksRequest{
        .body_headers = &[_]BlockHeader.BlockHeader{},
        .receipt_headers = headers,
        .bodies = null,
        .receipts = null,
    };

    const oversized = &[_]?[]const Receipt.Receipt{ null, null, &[_]Receipt.Receipt{} };
    try std.testing.expectError(BlocksRequest.ResponseAlignmentError.ReceiptAlignmentMismatch, req.set_receipts(oversized));

    const truncated = &[_]?[]const Receipt.Receipt{null};
    try req.set_receipts(truncated);
    try std.testing.expect(req.receipts != null);
    try std.testing.expect(req.receipts.?.len == 1);

    const empty_receipts = &[_]Receipt.Receipt{};
    const aligned = &[_]?[]const Receipt.Receipt{ null, empty_receipts };
    try req.set_receipts(aligned);
    try std.testing.expect(req.receipts != null);
    try std.testing.expect(req.receipts.?.len == headers.len);
    try std.testing.expect(req.receipts.?[0] == null);
}

test "BlocksRequest.response_allocator is null for unowned requests" {
    var req = BlocksRequest.empty();
    try std.testing.expect(req.response_allocator() == null);
}

test "BlocksRequest.init_owned provisions response arena and deinit clears it" {
    const headers = &[_]BlockHeader.BlockHeader{BlockHeader.init()};
    var req = BlocksRequest.init_owned(headers, &[_]BlockHeader.BlockHeader{}, std.testing.allocator);
    const arena_alloc = req.response_allocator().?;
    const buffer = try arena_alloc.alloc(u8, 4);
    buffer[0] = 1;

    req.deinit();
    try std.testing.expect(req.response_allocator() == null);
    try std.testing.expect(req.bodies == null);
    try std.testing.expect(req.receipts == null);
}
