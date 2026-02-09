/// Full sync request container for block bodies and receipts.
///
/// Mirrors Nethermind's BlocksRequest (BlockDownloadRequest) shape:
/// - separate body + receipt request lists (by block hash)
/// - optional response payloads, in request order
const std = @import("std");
const primitives = @import("primitives");
const BlockHash = primitives.BlockHash;
const BlockBody = primitives.BlockBody;
const Receipt = primitives.Receipt;

/// Block body + receipt request/response container.
///
/// Requests are ordered lists of block hashes. Responses must preserve
/// the same order as requested, per devp2p eth protocol expectations.
pub const BlocksRequest = struct {
    /// Block hashes for GetBlockBodies.
    body_hashes: []const BlockHash.BlockHash,
    /// Block hashes for GetReceipts.
    receipt_hashes: []const BlockHash.BlockHash,
    /// Optional block bodies, aligned with `body_hashes`.
    bodies: ?[]const BlockBody.BlockBody = null,
    /// Optional receipts per block, aligned with `receipt_hashes`.
    receipts: ?[]const []const Receipt.Receipt = null,

    /// Returns an empty request (no body or receipt queries).
    pub fn empty() BlocksRequest {
        return .{
            .body_hashes = &[_]BlockHash.BlockHash{},
            .receipt_hashes = &[_]BlockHash.BlockHash{},
            .bodies = null,
            .receipts = null,
        };
    }

    /// True if there are no body or receipt requests.
    pub fn isEmpty(self: BlocksRequest) bool {
        return self.body_hashes.len == 0 and self.receipt_hashes.len == 0;
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
    const hashes = &[_]BlockHash.BlockHash{BlockHash.ZERO};
    const req = BlocksRequest{
        .body_hashes = hashes,
        .receipt_hashes = &[_]BlockHash.BlockHash{},
        .bodies = null,
        .receipts = null,
    };
    try std.testing.expect(!req.isEmpty());
}

test "BlocksRequest.isEmpty detects pending receipt hashes" {
    const hashes = &[_]BlockHash.BlockHash{BlockHash.ZERO};
    const req = BlocksRequest{
        .body_hashes = &[_]BlockHash.BlockHash{},
        .receipt_hashes = hashes,
        .bodies = null,
        .receipts = null,
    };
    try std.testing.expect(!req.isEmpty());
}
