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
const PeerInfoModule = primitives.PeerInfo;
const PeerInfo = PeerInfoModule.PeerInfo;
const Receipt = primitives.Receipt;

fn has_prefix_ci(name: []const u8, prefix: []const u8) bool {
    return name.len >= prefix.len and std.ascii.eqlIgnoreCase(name[0..prefix.len], prefix);
}

const LimitCase = struct { prefix: []const u8, value: usize };

// File-scope tables to avoid re-initializing on every call.
const bodies_limit_table = [_]LimitCase{
    .{ .prefix = "Besu", .value = 128 },
    .{ .prefix = "Geth", .value = 128 },
    .{ .prefix = "Nethermind", .value = 256 },
    .{ .prefix = "Parity", .value = 256 },
    .{ .prefix = "OpenEthereum", .value = 256 },
    .{ .prefix = "Trinity", .value = 128 },
    .{ .prefix = "Erigon", .value = 128 },
    .{ .prefix = "Reth", .value = 128 },
};

const receipts_limit_table = [_]LimitCase{
    .{ .prefix = "Besu", .value = 256 },
    .{ .prefix = "Geth", .value = 256 },
    .{ .prefix = "Nethermind", .value = 256 },
    .{ .prefix = "Parity", .value = 256 },
    .{ .prefix = "OpenEthereum", .value = 256 },
    .{ .prefix = "Trinity", .value = 256 },
    .{ .prefix = "Erigon", .value = 256 },
    .{ .prefix = "Reth", .value = 256 },
};

const headers_limit_table = [_]LimitCase{
    .{ .prefix = "Besu", .value = 512 },
    .{ .prefix = "Geth", .value = 192 },
    .{ .prefix = "Nethermind", .value = 512 },
    .{ .prefix = "Parity", .value = 1024 },
    .{ .prefix = "OpenEthereum", .value = 1024 },
    .{ .prefix = "Trinity", .value = 192 },
    .{ .prefix = "Erigon", .value = 192 },
    .{ .prefix = "Reth", .value = 192 },
};

/// Lookup utility for per-client request limits.
/// Iterates a small compile-time case table and returns the matching value
/// by case-insensitive prefix on the peer's client name. Falls back to
/// `default_value` when no prefix matches.
fn limit_by_client_name(name: []const u8, cases: []const LimitCase, default_value: usize) usize {
    var i: usize = 0;
    while (i < cases.len) : (i += 1) {
        const case = cases[i];
        if (has_prefix_ci(name, case.prefix)) return case.value;
    }
    return default_value;
}

/// Return the maximum number of block bodies to request from a peer.
/// Mirrors Nethermind per-client sync limits for GetBlockBodies.
pub fn max_bodies_per_request(peer: PeerInfo) usize {
    const name = peer.name;
    return limit_by_client_name(name, &bodies_limit_table, 32);
}

/// Return the maximum number of block receipts to request from a peer.
/// Mirrors Nethermind per-client sync limits for GetReceipts.
pub fn max_receipts_per_request(peer: PeerInfo) usize {
    const name = peer.name;
    return limit_by_client_name(name, &receipts_limit_table, 128);
}

/// Return the maximum number of block headers to request from a peer.
/// Mirrors Nethermind per-client sync limits for GetBlockHeaders.
pub fn max_headers_per_request(peer: PeerInfo) usize {
    const name = peer.name;
    return limit_by_client_name(name, &headers_limit_table, 192);
}

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
    /// Optional arena owning response buffers. Stored via pointer to avoid arena copies.
    /// Must be deinit'd by caller.
    response_arena: ?*std.heap.ArenaAllocator = null,
    /// Allocator used to create the owned arena (if any).
    response_arena_allocator: ?std.mem.Allocator = null,

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
            .response_arena_allocator = null,
        };
    }

    /// Initialize a request that owns response buffers via an arena allocator.
    /// Call `deinit` when the response data is no longer needed.
    /// Do not copy the returned struct; treat it as move-only when owning an arena.
    pub fn init_owned(
        body_headers: []const BlockHeader.BlockHeader,
        receipt_headers: []const BlockHeader.BlockHeader,
        allocator: std.mem.Allocator,
    ) !BlocksRequest {
        const arena = try allocator.create(std.heap.ArenaAllocator);
        arena.* = std.heap.ArenaAllocator.init(allocator);
        return .{
            .body_headers = body_headers,
            .receipt_headers = receipt_headers,
            .bodies = null,
            .receipts = null,
            .response_arena = arena,
            .response_arena_allocator = allocator,
        };
    }

    /// True if there are no body or receipt requests.
    pub fn is_empty(self: *const BlocksRequest) bool {
        return self.body_headers.len == 0 and self.receipt_headers.len == 0;
    }

    /// Compute block hashes for the body request headers.
    /// Caller owns the returned slice.
    pub fn body_hashes(self: *const BlocksRequest, allocator: std.mem.Allocator) ![]const Hash.Hash {
        return headers_to_hashes(self.body_headers, allocator);
    }

    /// Return the allocator backing the owned response arena, if present.
    pub fn response_allocator(self: *BlocksRequest) ?std.mem.Allocator {
        if (self.response_arena) |arena| {
            return arena.allocator();
        }
        return null;
    }

    /// Release owned response buffers and clear response slices.
    pub fn deinit(self: *BlocksRequest) void {
        if (self.response_arena) |arena| {
            arena.deinit();
            if (self.response_arena_allocator) |alloc| {
                alloc.destroy(arena);
            }
        }
        self.response_arena = null;
        self.response_arena_allocator = null;
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
        errdefer allocator.free(hashes);
        for (headers, 0..) |*header, index| {
            hashes[index] = try BlockHeader.hash(header, allocator);
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
    var req = try BlocksRequest.init_owned(headers, &[_]BlockHeader.BlockHeader{}, std.testing.allocator);
    const arena_alloc = req.response_allocator().?;
    const buffer = try arena_alloc.alloc(u8, 4);
    buffer[0] = 1;

    req.deinit();
    try std.testing.expect(req.response_allocator() == null);
    try std.testing.expect(req.bodies == null);
    try std.testing.expect(req.receipts == null);
}

test "max_bodies_per_request uses client-specific limits" {
    const peer_id: primitives.PeerId.PeerId = [_]u8{0} ** 64;
    const caps = &[_][]const u8{};
    const network = PeerInfoModule.NetworkInfo{
        .local_address = "",
        .remote_address = "",
        .inbound = false,
        .trusted = false,
        .static = false,
    };
    const protocols = PeerInfoModule.Protocols{ .eth = null };

    const cases = [_]struct { name: []const u8, expected: usize }{
        .{ .name = "Besu/v23.4.0", .expected = 128 },
        .{ .name = "Geth/v1.13.0", .expected = 128 },
        .{ .name = "Nethermind/v1.18.0", .expected = 256 },
        .{ .name = "Parity-Ethereum/v2.7.2", .expected = 256 },
        .{ .name = "OpenEthereum/v3.3.5", .expected = 256 },
        .{ .name = "Trinity/v0.1.0", .expected = 128 },
        .{ .name = "Erigon/v2.43.1", .expected = 128 },
        .{ .name = "Reth/v0.2.0", .expected = 128 },
        .{ .name = "UnknownClient/0.0.1", .expected = 32 },
    };

    for (cases) |case| {
        const peer = PeerInfoModule.init(peer_id, case.name, caps, network, protocols);
        try std.testing.expectEqual(case.expected, max_bodies_per_request(peer));
    }
}

test "max_receipts_per_request uses client-specific limits" {
    const peer_id: primitives.PeerId.PeerId = [_]u8{0} ** 64;
    const caps = &[_][]const u8{};
    const network = PeerInfoModule.NetworkInfo{
        .local_address = "",
        .remote_address = "",
        .inbound = false,
        .trusted = false,
        .static = false,
    };
    const protocols = PeerInfoModule.Protocols{ .eth = null };

    const cases = [_]struct { name: []const u8, expected: usize }{
        .{ .name = "Besu/v23.4.0", .expected = 256 },
        .{ .name = "Geth/v1.13.0", .expected = 256 },
        .{ .name = "Nethermind/v1.18.0", .expected = 256 },
        .{ .name = "Parity-Ethereum/v2.7.2", .expected = 256 },
        .{ .name = "OpenEthereum/v3.3.5", .expected = 256 },
        .{ .name = "Trinity/v0.1.0", .expected = 256 },
        .{ .name = "Erigon/v2.43.1", .expected = 256 },
        .{ .name = "Reth/v0.2.0", .expected = 256 },
        .{ .name = "UnknownClient/0.0.1", .expected = 128 },
    };

    for (cases) |case| {
        const peer = PeerInfoModule.init(peer_id, case.name, caps, network, protocols);
        try std.testing.expectEqual(case.expected, max_receipts_per_request(peer));
    }
}

test "max_headers_per_request uses client-specific limits" {
    const peer_id: primitives.PeerId.PeerId = [_]u8{0} ** 64;
    const caps = &[_][]const u8{};
    const network = PeerInfoModule.NetworkInfo{
        .local_address = "",
        .remote_address = "",
        .inbound = false,
        .trusted = false,
        .static = false,
    };
    const protocols = PeerInfoModule.Protocols{ .eth = null };

    const cases = [_]struct { name: []const u8, expected: usize }{
        .{ .name = "Besu/v23.4.0", .expected = 512 },
        .{ .name = "Geth/v1.13.0", .expected = 192 },
        .{ .name = "Nethermind/v1.18.0", .expected = 512 },
        .{ .name = "Parity-Ethereum/v2.7.2", .expected = 1024 },
        .{ .name = "OpenEthereum/v3.3.5", .expected = 1024 },
        .{ .name = "Trinity/v0.1.0", .expected = 192 },
        .{ .name = "Erigon/v2.43.1", .expected = 192 },
        .{ .name = "Reth/v0.2.0", .expected = 192 },
        .{ .name = "UnknownClient/0.0.1", .expected = 192 },
    };

    for (cases) |case| {
        const peer = PeerInfoModule.init(peer_id, case.name, caps, network, protocols);
        try std.testing.expectEqual(case.expected, max_headers_per_request(peer));
    }
}
