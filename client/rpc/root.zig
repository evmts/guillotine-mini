/// JSON-RPC server module for the Guillotine execution client.
const std = @import("std");

const server = @import("server.zig");

/// Re-exported JSON-RPC server configuration.
pub const RpcServerConfig = server.RpcServerConfig;

test {
    std.testing.refAllDecls(@This());
}
