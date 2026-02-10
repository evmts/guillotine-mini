/// JSON-RPC server configuration.
///
/// Mirrors core settings from Nethermind's JsonRpcConfig needed for
/// HTTP and WebSocket transports.
const std = @import("std");

const default_enabled = false;
const default_host: []const u8 = "127.0.0.1";
const default_port: u16 = 8545;
const default_websocket_port: ?u16 = null;
const default_ipc_unix_domain_socket_path: ?[]const u8 = null;
const default_timeout_ms: u32 = 20_000;
const default_request_queue_limit: usize = 500;
const default_max_batch_size: usize = 1024;
const default_max_request_body_size: ?usize = 30_000_000;
const default_max_batch_response_body_size: ?usize = 33_554_432;
const default_strict_hex_format = true;

/// JSON-RPC server configuration options, aligned with Nethermind defaults.
pub const RpcServerConfig = struct {
    /// Enable the JSON-RPC server.
    enabled: bool = default_enabled,
    /// Interface to bind (IPv4/IPv6 literal or hostname).
    host: []const u8 = default_host,
    /// HTTP JSON-RPC port.
    port: u16 = default_port,
    /// Optional WebSocket port override (defaults to HTTP port when null).
    websocket_port: ?u16 = default_websocket_port,
    /// Optional UNIX domain socket path for IPC transport.
    ipc_unix_domain_socket_path: ?[]const u8 = default_ipc_unix_domain_socket_path,
    /// Per-request timeout in milliseconds.
    timeout_ms: u32 = default_timeout_ms,
    /// Maximum number of queued requests.
    request_queue_limit: usize = default_request_queue_limit,
    /// Maximum JSON-RPC batch size.
    max_batch_size: usize = default_max_batch_size,
    /// Maximum request body size in bytes (null to disable the limit).
    max_request_body_size: ?usize = default_max_request_body_size,
    /// Maximum batch response body size in bytes (null to disable the limit).
    max_batch_response_body_size: ?usize = default_max_batch_response_body_size,
    /// Enforce strict hex encoding (EIP-1474 Quantity/Data rules).
    strict_hex_format: bool = default_strict_hex_format,

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
    try std.testing.expectEqual(default_port, cfg.effective_websocket_port());
}

test "rpc server config respects websocket port override" {
    const cfg = RpcServerConfig{ .websocket_port = 9546 };
    try std.testing.expectEqual(@as(u16, 9546), cfg.effective_websocket_port());
}

test "rpc server config defaults match Nethermind core settings" {
    const cfg = RpcServerConfig{};
    try std.testing.expectEqual(default_enabled, cfg.enabled);
    try std.testing.expectEqualStrings(default_host, cfg.host);
    try std.testing.expectEqual(default_port, cfg.port);
    try std.testing.expectEqual(default_websocket_port, cfg.websocket_port);
}

test "rpc server config defaults ipc socket path to null" {
    const cfg = RpcServerConfig{};
    try std.testing.expectEqual(default_ipc_unix_domain_socket_path, cfg.ipc_unix_domain_socket_path);
}

test "rpc server config defaults match Nethermind limits" {
    const cfg = RpcServerConfig{};
    try std.testing.expectEqual(default_timeout_ms, cfg.timeout_ms);
    try std.testing.expectEqual(default_request_queue_limit, cfg.request_queue_limit);
    try std.testing.expectEqual(default_max_batch_size, cfg.max_batch_size);
    try std.testing.expectEqual(default_max_request_body_size, cfg.max_request_body_size);
    try std.testing.expectEqual(default_max_batch_response_body_size, cfg.max_batch_response_body_size);
    try std.testing.expectEqual(default_strict_hex_format, cfg.strict_hex_format);
}
