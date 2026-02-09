/// JSON-RPC server configuration.
///
/// Mirrors core settings from Nethermind's JsonRpcConfig needed for
/// HTTP and WebSocket transports.
const std = @import("std");

pub const RpcServerConfig = struct {
    /// Enable the JSON-RPC server.
    enabled: bool = false,
    /// Interface to bind (IPv4/IPv6 literal or hostname).
    host: []const u8 = "127.0.0.1",
    /// HTTP JSON-RPC port.
    port: u16 = 8545,
    /// Optional WebSocket port override (defaults to HTTP port when null).
    websocket_port: ?u16 = null,
    /// Optional UNIX domain socket path for IPC transport.
    ipc_unix_domain_socket_path: ?[]const u8 = null,
    /// Per-request timeout in milliseconds.
    timeout_ms: u32 = 20_000,
    /// Maximum number of queued requests.
    request_queue_limit: usize = 500,
    /// Maximum JSON-RPC batch size.
    max_batch_size: usize = 1024,
    /// Maximum request body size in bytes (null to disable the limit).
    max_request_body_size: ?usize = 30_000_000,
    /// Maximum batch response body size in bytes (null to disable the limit).
    max_batch_response_body_size: ?usize = 33_554_432,
    /// Enforce strict hex encoding (EIP-1474 Quantity/Data rules).
    strict_hex_format: bool = true,

    /// Returns the WebSocket port, defaulting to the HTTP port when unset.
    pub fn effective_websocket_port(self: RpcServerConfig) u16 {
        return self.websocket_port orelse self.port;
    }
};

// ============================================================================
// Tests
// ============================================================================

test "rpc server config defaults websocket port to http port" {
    const cfg = RpcServerConfig{};
    try std.testing.expectEqual(@as(u16, 8545), cfg.effective_websocket_port());
}

test "rpc server config respects websocket port override" {
    const cfg = RpcServerConfig{ .websocket_port = 9546 };
    try std.testing.expectEqual(@as(u16, 9546), cfg.effective_websocket_port());
}

test "rpc server config defaults ipc socket path to null" {
    const cfg = RpcServerConfig{};
    try std.testing.expectEqual(@as(?[]const u8, null), cfg.ipc_unix_domain_socket_path);
}

test "rpc server config defaults match Nethermind limits" {
    const cfg = RpcServerConfig{};
    try std.testing.expectEqual(@as(u32, 20_000), cfg.timeout_ms);
    try std.testing.expectEqual(@as(usize, 500), cfg.request_queue_limit);
    try std.testing.expectEqual(@as(usize, 1024), cfg.max_batch_size);
    try std.testing.expectEqual(@as(?usize, 30_000_000), cfg.max_request_body_size);
    try std.testing.expectEqual(@as(?usize, 33_554_432), cfg.max_batch_response_body_size);
    try std.testing.expectEqual(true, cfg.strict_hex_format);
}
