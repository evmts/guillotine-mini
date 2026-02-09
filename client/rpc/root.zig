//! JSON-RPC server module for the Guillotine execution client.
const std = @import("std");

const server = @import("server.zig");
const errors = @import("error.zig");

/// JSON-RPC server configuration.
pub const RpcServerConfig = server.RpcServerConfig;
/// JSON-RPC error codes per EIP-1474 and Nethermind extensions.
pub const JsonRpcErrorCode = errors.JsonRpcErrorCode;

test {
    std.testing.refAllDecls(@This());
}
