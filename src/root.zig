//! Guillotine Mini - EVM implementation
const std = @import("std");

// Export configuration
pub const evm_config = @import("evm_config.zig");
pub const EvmConfig = evm_config.EvmConfig;
pub const OpcodeOverride = evm_config.OpcodeOverride;
pub const PrecompileOverride = evm_config.PrecompileOverride;
pub const PrecompileOutput = evm_config.PrecompileOutput;

// Export the main EVM module
pub const evm = @import("evm.zig");
pub const Evm = evm.Evm;
pub const DefaultEvm = evm.DefaultEvm;
pub const StorageSlotKey = evm.StorageSlotKey;
pub const AccessListParam = evm.AccessListParam;
pub const AccessListStorageKey = evm.AccessListStorageKey;
pub const BlockContext = evm.BlockContext;

// Export CallParams and CallResult (polymorphic API with guillotine core)
pub const call_params = @import("call_params.zig");
pub const call_result = @import("call_result.zig");
pub const CallParams = DefaultEvm.CallParams;
pub const CallResult = DefaultEvm.CallResult;
pub const Log = call_result.Log;
pub const SelfDestructRecord = call_result.SelfDestructRecord;
pub const StorageAccess = call_result.StorageAccess;
pub const TraceStep = call_result.TraceStep;
pub const ExecutionTrace = call_result.ExecutionTrace;

// Export Frame
pub const frame = @import("frame.zig");
pub const Frame = frame.Frame;

// Export Host interface and types
pub const host = @import("host.zig");
pub const HostInterface = host.HostInterface;

// Export Hardfork
pub const hardfork = @import("hardfork.zig");
pub const Hardfork = hardfork.Hardfork;
pub const ForkTransition = hardfork.ForkTransition;

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
    _ = @import("evm_test.zig");
}
