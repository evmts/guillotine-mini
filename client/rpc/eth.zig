//! Ethereum JSON-RPC (eth_*) minimal handlers.
//!
//! Implements `eth_chainId` per EIP-1474 using Voltaire JSON-RPC types
//! and allocation-free response serializers. Configuration is injected
//! via a small comptime provider with a `getChainId() u64` method.
const std = @import("std");
const jsonrpc = @import("jsonrpc");
const envelope = @import("envelope.zig");
const errors = @import("error.zig");
const Response = @import("response.zig").Response;

/// Generic ETH API surface (comptime-injected provider).
///
/// The `Provider` type must define:
/// - `pub fn getChainId(self: *const Provider) u64`
pub fn EthApi(comptime Provider: type) type {
    // Compile-time contract for Provider
    comptime {
        if (!@hasDecl(Provider, "getChainId")) {
            @compileError("EthApi Provider must define getChainId() u64");
        }
    }

    return struct {
        const Self = @This();

        provider: *const Provider,

        /// Handle `eth_chainId` and write a full JSON-RPC envelope.
        ///
        /// - Extracts the request `id` allocation-free.
        /// - On success, returns QUANTITY(u64) per EIP-1474.
        /// - On malformed/unsupported envelope, returns an EIP-1474 error with id=null.
        pub fn handleChainId(self: *const Self, writer: anytype, request_bytes: []const u8) !void {
            // Keep shapes aligned with Voltaire types for eth_chainId
            const EthMethod = jsonrpc.eth.EthMethod;
            const ChainIdShape = @FieldType(EthMethod, "eth_chainId"); // { params, result }
            _ = ChainIdShape; // referenced to ensure compile-time coupling

            const id_res = envelope.extractRequestId(request_bytes);
            switch (id_res) {
                .id => |id| {
                    const chain_id: u64 = self.provider.getChainId();
                    try Response.writeSuccessQuantityU64(writer, id, chain_id);
                },
                .err => |code| {
                    // Per EIP-1474, when id cannot be determined, respond with id:null
                    try Response.writeError(writer, .null, code, code.defaultMessage(), null);
                },
            }
        }
    };
}

// ============================================================================
// Tests
// ============================================================================

test "EthApi.handleChainId: number id -> QUANTITY result" {
    const Provider = struct {
        pub fn getChainId(_: *const Provider) u64 {
            return 1;
        }
    };
    const Api = EthApi(Provider);
    const provider = Provider{};
    var api = Api{ .provider = &provider };

    const req =
        "{\n" ++
        "  \"jsonrpc\": \"2.0\",\n" ++
        "  \"id\": 7,\n" ++
        "  \"method\": \"eth_chainId\",\n" ++
        "  \"params\": []\n" ++
        "}";

    var buf = std.ArrayList(u8){};
    defer buf.deinit(std.testing.allocator);
    try api.handleChainId(buf.writer(std.testing.allocator), req);
    try std.testing.expectEqualStrings(
        "{\"jsonrpc\":\"2.0\",\"id\":7,\"result\":\"0x1\"}",
        buf.items,
    );
}

test "EthApi.handleChainId: string id preserved; QUANTITY encoding" {
    const Provider = struct {
        pub fn getChainId(_: *const Provider) u64 {
            return 26;
        }
    };
    const Api = EthApi(Provider);
    const provider = Provider{};
    var api = Api{ .provider = &provider };

    const req =
        "{\n" ++
        "  \"jsonrpc\": \"2.0\",\n" ++
        "  \"id\": \"abc-123\",\n" ++
        "  \"method\": \"eth_chainId\",\n" ++
        "  \"params\": []\n" ++
        "}";

    var buf = std.ArrayList(u8){};
    defer buf.deinit(std.testing.allocator);
    try api.handleChainId(buf.writer(std.testing.allocator), req);
    try std.testing.expectEqualStrings(
        "{\"jsonrpc\":\"2.0\",\"id\":\"abc-123\",\"result\":\"0x1a\"}",
        buf.items,
    );
}

test "EthApi.handleChainId: invalid envelope -> EIP-1474 error with id:null" {
    const Provider = struct {
        pub fn getChainId(_: *const Provider) u64 {
            return 1;
        }
    };
    const Api = EthApi(Provider);
    const provider = Provider{};
    var api = Api{ .provider = &provider };

    // Batch array at top level is not handled here
    const bad = "[ { \"jsonrpc\": \"2.0\", \"id\": 1, \"method\": \"eth_chainId\", \"params\": [] } ]";

    var buf = std.ArrayList(u8){};
    defer buf.deinit(std.testing.allocator);
    try api.handleChainId(buf.writer(std.testing.allocator), bad);

    const code = errors.JsonRpcErrorCode.invalid_request;
    var expect_buf: [256]u8 = undefined;
    var fba = std.io.fixedBufferStream(&expect_buf);
    try Response.writeError(fba.writer(), .null, code, code.defaultMessage(), null);
    try std.testing.expectEqualStrings(fba.getWritten(), buf.items);
}
