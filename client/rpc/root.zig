//! JSON-RPC server module for the Guillotine execution client.
const std = @import("std");

const server = @import("server.zig");
const errors = @import("error.zig");
const envelope = @import("envelope.zig");

/// JSON-RPC server configuration.
pub const RpcServerConfig = server.RpcServerConfig;
/// JSON-RPC error codes per EIP-1474 and Nethermind extensions.
pub const JsonRpcErrorCode = errors.JsonRpcErrorCode;
/// JSON-RPC envelope utilities (ID extraction, zero-copy)
pub const Envelope = envelope;

test {
    std.testing.refAllDecls(@This());
}
