/// Full sync request container for block bodies and receipts.
///
/// Mirrors Nethermind's BlocksRequest (BlockDownloadRequest) shape:
/// - separate body + receipt request lists (by block header)
/// - optional response payloads, in request order
const std = @import("std");
const primitives = @import("primitives");
const BlockHeader = primitives.BlockHeader;
const BlockBody = primitives.BlockBody;
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
    bodies: ?[]const ?BlockBody.BlockBody = null,
    /// Optional receipts per block, aligned with `receipt_headers`.
    /// Missing receipts are represented as null entries.
    receipts: ?[]const ?[]const Receipt.Receipt = null,

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
        };
    }

    /// True if there are no body or receipt requests.
    pub fn isEmpty(self: BlocksRequest) bool {
        return self.body_headers.len == 0 and self.receipt_headers.len == 0;
    }

    /// Set bodies response, enforcing alignment with `body_headers`.
    pub fn setBodies(self: *BlocksRequest, bodies: []const ?BlockBody.BlockBody) ResponseAlignmentError!void {
        if (bodies.len != self.body_headers.len) {
            return ResponseAlignmentError.BodyAlignmentMismatch;
        }
        self.bodies = bodies;
    }

    /// Set receipts response, enforcing alignment with `receipt_headers`.
    pub fn setReceipts(self: *BlocksRequest, receipts: []const ?[]const Receipt.Receipt) ResponseAlignmentError!void {
        if (receipts.len != self.receipt_headers.len) {
            return ResponseAlignmentError.ReceiptAlignmentMismatch;
        }
        self.receipts = receipts;
    }
};

// ============================================================================
// Tests
// ============================================================================

test "BlocksRequest.empty returns empty slices and null responses" {
    const req = BlocksRequest.empty();
    try std.testing.expect(req.isEmpty());
    try std.testing.expect(req.bodies == null);
    try std.testing.expect(req.receipts == null);
}

test "BlocksRequest.isEmpty detects pending body hashes" {
    const headers = &[_]BlockHeader.BlockHeader{BlockHeader.init()};
    const req = BlocksRequest{
        .body_headers = headers,
        .receipt_headers = &[_]BlockHeader.BlockHeader{},
        .bodies = null,
        .receipts = null,
    };
    try std.testing.expect(!req.isEmpty());
}

test "BlocksRequest.isEmpty detects pending receipt hashes" {
    const headers = &[_]BlockHeader.BlockHeader{BlockHeader.init()};
    const req = BlocksRequest{
        .body_headers = &[_]BlockHeader.BlockHeader{},
        .receipt_headers = headers,
        .bodies = null,
        .receipts = null,
    };
    try std.testing.expect(!req.isEmpty());
}

test "BlocksRequest.setBodies enforces alignment and allows missing entries" {
    const headers = &[_]BlockHeader.BlockHeader{ BlockHeader.init(), BlockHeader.init() };
    var req = BlocksRequest{
        .body_headers = headers,
        .receipt_headers = &[_]BlockHeader.BlockHeader{},
        .bodies = null,
        .receipts = null,
    };

    const misaligned = &[_]?BlockBody.BlockBody{BlockBody.init()};
    try std.testing.expectError(BlocksRequest.ResponseAlignmentError.BodyAlignmentMismatch, req.setBodies(misaligned));

    const aligned = &[_]?BlockBody.BlockBody{ null, BlockBody.init() };
    try req.setBodies(aligned);
    try std.testing.expect(req.bodies != null);
    try std.testing.expect(req.bodies.?.len == headers.len);
    try std.testing.expect(req.bodies.?[0] == null);
}

test "BlocksRequest.setReceipts enforces alignment and allows missing entries" {
    const headers = &[_]BlockHeader.BlockHeader{ BlockHeader.init(), BlockHeader.init() };
    var req = BlocksRequest{
        .body_headers = &[_]BlockHeader.BlockHeader{},
        .receipt_headers = headers,
        .bodies = null,
        .receipts = null,
    };

    const misaligned = &[_]?[]const Receipt.Receipt{null};
    try std.testing.expectError(BlocksRequest.ResponseAlignmentError.ReceiptAlignmentMismatch, req.setReceipts(misaligned));

    const empty_receipts = &[_]Receipt.Receipt{};
    const aligned = &[_]?[]const Receipt.Receipt{ null, empty_receipts };
    try req.setReceipts(aligned);
    try std.testing.expect(req.receipts != null);
    try std.testing.expect(req.receipts.?.len == headers.len);
    try std.testing.expect(req.receipts.?[0] == null);
}
