/// JSON-RPC server module for the Guillotine execution client.
const std = @import("std");

const server = @import("server.zig");
const errors = @import("error.zig");

/// Re-exported JSON-RPC server configuration.
pub const RpcServerConfig = server.RpcServerConfig;
pub const JsonRpcErrorCode = errors.JsonRpcErrorCode;

test {
    std.testing.refAllDecls(@This());
}
