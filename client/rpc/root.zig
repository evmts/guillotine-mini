//! JSON-RPC server module for the Guillotine execution client.
const std = @import("std");

const server = @import("server.zig");
const errors = @import("error.zig");
const envelope = @import("envelope.zig");
const response = @import("response.zig");
const eth = @import("eth.zig");
const dispatch = @import("dispatch.zig");
const codec = @import("codec.zig");
const simulation = @import("simulation.zig");
const debug = @import("debug.zig");
const trace = @import("trace.zig");

/// JSON-RPC server configuration.
pub const RpcServerConfig = server.RpcServerConfig;
/// JSON-RPC error codes per EIP-1474 and Nethermind extensions.
pub const JsonRpcErrorCode = errors.JsonRpcErrorCode;
/// JSON-RPC envelope utilities (ID extraction, zero-copy)
pub const Envelope = envelope;
/// JSON-RPC response serializers
pub const Response = response.Response;
/// ETH namespace API surface (comptime DI)
pub const EthApi = eth.EthApi;
/// Method-name to namespace routing.
pub const Dispatch = dispatch;
pub const RpcNamespace = dispatch.RpcNamespace;
/// Block selector passed to simulation providers.
pub const BlockTag = codec.BlockTag;
/// Simulation-method param parsers and encoders.
pub const Codec = codec;
/// `eth_call`, `eth_estimateGas`, `eth_createAccessList`, `eth_simulateV1`.
/// Instantiate with `SimulationApi(@import("evm").simulation, Provider)`.
pub const SimulationApi = simulation.SimulationApi;
/// `debug_traceCall`, `debug_traceTransaction`.
pub const DebugApi = debug.DebugApi;
/// Parity-style `trace_call`, `trace_transaction`.
pub const TraceApi = trace.TraceApi;

test {
    std.testing.refAllDecls(@This());
    _ = @import("sim_integration_test.zig");
}
