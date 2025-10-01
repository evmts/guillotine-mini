//! Guillotine Mini - EVM implementation
const std = @import("std");

// Export the EVM components
pub const Evm = @import("evm.zig").Evm;
pub const Frame = @import("frame.zig").Frame;
pub const Host = @import("host.zig");
pub const Hardfork = @import("hardfork.zig").Hardfork;

// Re-export primitives for convenience
pub const primitives = @import("primitives");

test {
    std.testing.refAllDecls(@This());
}
