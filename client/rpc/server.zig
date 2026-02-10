/// JSON-RPC server configuration.
///
/// Mirrors core settings from Nethermind's JsonRpcConfig needed for
/// HTTP and WebSocket transports.
const std = @import("std");
const primitives = @import("primitives");

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

/// JSON-RPC error codes and messages per EIP-1474.
pub const JsonRpcErrorCode = primitives.Int32.Int32;

/// Named EIP-1474 error codes for JSON-RPC responses.
pub const ErrorCode = struct {
    pub const parse_error: JsonRpcErrorCode = -32700;
    pub const invalid_request: JsonRpcErrorCode = -32600;
    pub const method_not_found: JsonRpcErrorCode = -32601;
    pub const invalid_params: JsonRpcErrorCode = -32602;
    pub const internal_error: JsonRpcErrorCode = -32603;
    pub const invalid_input: JsonRpcErrorCode = -32000;
    pub const resource_not_found: JsonRpcErrorCode = -32001;
    pub const resource_unavailable: JsonRpcErrorCode = -32002;
    pub const transaction_rejected: JsonRpcErrorCode = -32003;
    pub const method_not_supported: JsonRpcErrorCode = -32004;
    pub const limit_exceeded: JsonRpcErrorCode = -32005;
    pub const version_not_supported: JsonRpcErrorCode = -32006;
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

test "rpc error codes match EIP-1474" {
    try std.testing.expectEqual(@as(JsonRpcErrorCode, -32700), ErrorCode.parse_error);
    try std.testing.expectEqual(@as(JsonRpcErrorCode, -32600), ErrorCode.invalid_request);
    try std.testing.expectEqual(@as(JsonRpcErrorCode, -32601), ErrorCode.method_not_found);
    try std.testing.expectEqual(@as(JsonRpcErrorCode, -32602), ErrorCode.invalid_params);
    try std.testing.expectEqual(@as(JsonRpcErrorCode, -32603), ErrorCode.internal_error);
    try std.testing.expectEqual(@as(JsonRpcErrorCode, -32000), ErrorCode.invalid_input);
    try std.testing.expectEqual(@as(JsonRpcErrorCode, -32001), ErrorCode.resource_not_found);
    try std.testing.expectEqual(@as(JsonRpcErrorCode, -32002), ErrorCode.resource_unavailable);
    try std.testing.expectEqual(@as(JsonRpcErrorCode, -32003), ErrorCode.transaction_rejected);
    try std.testing.expectEqual(@as(JsonRpcErrorCode, -32004), ErrorCode.method_not_supported);
    try std.testing.expectEqual(@as(JsonRpcErrorCode, -32005), ErrorCode.limit_exceeded);
    try std.testing.expectEqual(@as(JsonRpcErrorCode, -32006), ErrorCode.version_not_supported);
}
