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
pub const StorageKey = evm.StorageKey;
pub const StorageSlotKey = evm.StorageSlotKey;
// AccessListParam removed - use primitives.AccessList.AccessList instead
// AccessListStorageKey is now primitives.AccessList.StorageSlotKey
pub const BlockContext = evm.BlockContext;

// Export CallParams and CallResult (polymorphic API with guillotine core)
pub const call_params = @import("call_params.zig");
pub const call_result = @import("call_result.zig");
pub const Log = @import("voltaire").logs.Log;
pub const SelfDestructRecord = call_result.SelfDestructRecord;
pub const StorageAccess = call_result.StorageAccess;
pub const TraceStep = call_result.TraceStep;
pub const ExecutionTrace = call_result.ExecutionTrace;

// Export Frame function
pub const frame = @import("frame.zig");
pub const Frame = frame.Frame;

// Export Host interface and types
pub const host = @import("host.zig");
pub const HostInterface = host.HostInterface;

// Export Hardfork from primitives
const primitives = @import("voltaire");
pub const Hardfork = primitives.Hardfork;
pub const ForkTransition = primitives.ForkTransition;

// Export errors
pub const errors = @import("errors.zig");
pub const CallError = errors.CallError;

// Export tracing functionality (EIP-3155)
pub const trace = @import("trace.zig");
pub const Tracer = trace.Tracer;
pub const TraceEntry = trace.TraceEntry;
pub const TraceSummary = trace.TraceSummary;
pub const TraceDiff = trace.TraceDiff;

pub const inspector = @import("inspector.zig");
pub const Inspector = inspector.Inspector;
pub const MuxInspector = inspector.MuxInspector;
pub const OpcodeMask = inspector.OpcodeMask;
pub const CallType = inspector.CallType;
pub const RevertDecoder = inspector.RevertDecoder;
pub const DecodedRevert = inspector.DecodedRevert;

// Built-in native tracers and profilers
pub const tracers = @import("tracers.zig");
pub const CallTracer = tracers.CallTracer;
pub const FourByteTracer = tracers.FourByteTracer;
pub const PrestateTracer = tracers.PrestateTracer;
pub const AccessListInspector = tracers.AccessListInspector;
pub const GasProfiler = tracers.GasProfiler;
pub const CoverageInspector = tracers.CoverageInspector;

// Simulation engine, state & block overrides, eth_simulateV1
pub const simulation = @import("simulation.zig");
pub const StateOverlayHost = simulation.StateOverlayHost;
pub const AccountOverride = simulation.AccountOverride;
pub const BlockOverride = simulation.BlockOverride;
pub const CallRequest = simulation.CallRequest;

// Live block-level tracing & indexed trace store (trace_filter)
pub const live_tracer = @import("live_tracer.zig");
pub const BlockHooks = live_tracer.BlockHooks;
pub const MuxBlockHooks = live_tracer.MuxBlockHooks;
pub const SupplyTracer = live_tracer.SupplyTracer;
pub const trace_store = @import("trace_store.zig");
pub const TraceStore = trace_store.TraceStore;
pub const TraceFilter = trace_store.TraceFilter;

// Interactive time-travel debugger, flamegraph profiler & EVMC adapter
pub const debugger = @import("debugger.zig");
pub const ExecutionRecorder = debugger.ExecutionRecorder;
pub const DebugSession = debugger.DebugSession;
pub const Breakpoint = debugger.Breakpoint;
pub const flamegraph = @import("flamegraph.zig");
pub const FlamegraphCollector = flamegraph.FlamegraphCollector;
pub const evmc_adapter = @import("evmc_adapter.zig");
pub const EvmcHostBridge = evmc_adapter.EvmcHostBridge;

// Export opcode utilities
pub const opcode = @import("opcode.zig");
pub const getOpName = opcode.getOpName;

// Export Glamsterdam/Osaka hardfork readiness hooks
pub const hardfork_hooks = @import("hardfork_hooks.zig");

// Export instruction dispatcher
pub const dispatcher = @import("instructions/dispatcher.zig");
pub const Dispatcher = dispatcher.Dispatcher;
pub const DispatcherWithConfig = dispatcher.DispatcherWithConfig;

// Export reusable opcode handlers and the frame interface they require
pub const frame_interface = @import("instructions/frame_interface.zig");
pub const checkFrameInterface = frame_interface.checkFrameInterface;
pub const HandlerConfig = frame_interface.HandlerConfig;
pub const handlers = struct {
    pub const arithmetic = @import("instructions/handlers_arithmetic.zig");
    pub const comparison = @import("instructions/handlers_comparison.zig");
    pub const bitwise = @import("instructions/handlers_bitwise.zig");
    pub const keccak = @import("instructions/handlers_keccak.zig");
    pub const context = @import("instructions/handlers_context.zig");
    pub const block = @import("instructions/handlers_block.zig");
    pub const stack = @import("instructions/handlers_stack.zig");
    pub const memory = @import("instructions/handlers_memory.zig");
    pub const storage = @import("instructions/handlers_storage.zig");
    pub const control_flow = @import("instructions/handlers_control_flow.zig");
    pub const log = @import("instructions/handlers_log.zig");
    pub const system = @import("instructions/handlers_system.zig");
};

test {
    std.testing.refAllDecls(@This());
    _ = @import("evm_test.zig");
    _ = @import("inspector.zig");
    _ = @import("trace.zig");
    _ = @import("tracers.zig");
    _ = @import("tracers_test.zig");
    _ = @import("simulation.zig");
    _ = @import("live_tracer.zig");
    _ = @import("trace_store.zig");
    _ = @import("live_tracer_test.zig");
    _ = @import("debugger.zig");
    _ = @import("flamegraph.zig");
    _ = @import("evmc_adapter.zig");
    _ = @import("devtools_test.zig");
    _ = @import("oom_safety_test.zig");
    _ = @import("instructions/handlers_stack_test.zig");
    _ = @import("instructions/frame_interface.zig");
    _ = @import("instructions/handlers_arithmetic_test.zig");
    _ = @import("instructions/handlers_comparison_test.zig");
    _ = @import("instructions/handlers_bitwise_test.zig");
    _ = @import("instructions/clz_test.zig");
    _ = @import("instructions/handlers_keccak_test.zig");
    _ = @import("instructions/handlers_memory_test.zig");
    _ = @import("instructions/handlers_log_test.zig");
    _ = @import("instructions/handlers_control_flow_test.zig");
    _ = @import("instructions/handlers_storage_test.zig");
    _ = @import("instructions/handlers_system_test.zig");
    _ = @import("instructions/handlers_context_test.zig");
    _ = @import("instructions/handlers_block_test.zig");
    _ = @import("instructions/dispatcher.zig");
    _ = @import("instructions/test_helpers.zig");
    _ = @import("instructions/test_helpers_examples.test.zig");
}
