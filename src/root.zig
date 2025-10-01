//! Guillotine Mini - Minimal EVM implementation
const std = @import("std");

// Export the minimal EVM components
pub const MinimalEvm = @import("minimal_evm.zig").MinimalEvm;
pub const MinimalFrame = @import("minimal_frame.zig").MinimalFrame;
pub const MinimalHost = @import("minimal_host.zig");
pub const Hardfork = @import("hardfork.zig").Hardfork;

// Re-export primitives for convenience
pub const primitives = @import("primitives");

test {
    std.testing.refAllDecls(@This());
}
