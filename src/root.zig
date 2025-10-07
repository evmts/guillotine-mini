//! Guillotine Mini - EVM implementation
const std = @import("std");

// Export the main EVM module
pub const evm = @import("evm.zig");
pub const Evm = evm.Evm;
pub const CallResult = evm.CallResult;
pub const StorageSlotKey = evm.StorageSlotKey;
pub const AccessListParam = evm.AccessListParam;
pub const AccessListStorageKey = evm.AccessListStorageKey;
pub const BlockContext = evm.BlockContext;

// Export Frame
pub const frame = @import("frame.zig");
pub const Frame = frame.Frame;

// Export Host interface and types
pub const host = @import("host.zig");
pub const Host = host.Host;
pub const HostInterface = host.HostInterface;

// Export Hardfork
pub const hardfork = @import("hardfork.zig");
pub const Hardfork = hardfork.Hardfork;

// Export errors
pub const errors = @import("errors.zig");
pub const CallError = errors.CallError;

// Export tracing functionality (EIP-3155)
pub const trace = @import("trace.zig");
pub const Tracer = trace.Tracer;
pub const TraceEntry = trace.TraceEntry;

// Export opcode utilities
pub const opcode = @import("opcode.zig");
pub const getOpName = opcode.getOpName;

test {
    std.testing.refAllDecls(@This());
}
