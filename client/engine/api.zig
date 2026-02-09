/// Engine API interface for consensus layer communication.
///
/// Mirrors Nethermind's IEngineRpcModule capability exchange surface and
/// follows the vtable-based dependency injection pattern used in src/host.zig.
const std = @import("std");
const primitives = @import("primitives");
const crypto = @import("crypto");
const jsonrpc = @import("jsonrpc");

const ExchangeCapabilitiesMethod = @FieldType(jsonrpc.engine.EngineMethod, "engine_exchangeCapabilities");
pub const ExchangeCapabilitiesParams = @FieldType(ExchangeCapabilitiesMethod, "params");
pub const ExchangeCapabilitiesResult = @FieldType(ExchangeCapabilitiesMethod, "result");

/// Vtable-based Engine API interface.
///
/// Currently exposes `engine_exchangeCapabilities` only. The handler is
/// responsible for enforcing spec rules (e.g., versioned method names and
/// excluding `engine_exchangeCapabilities` from responses).
pub const EngineApi = struct {
    /// Type-erased pointer to the concrete Engine API implementation.
    ptr: *anyopaque,
    /// Pointer to the static vtable for the concrete Engine API implementation.
    vtable: *const VTable,

    /// Errors surfaced by Engine API handlers.
    ///
    /// These map to Engine API JSON-RPC error responses at the RPC layer.
    pub const Error = error{
        /// -32700: Invalid JSON was received by the server.
        ParseError,
        /// -32600: The JSON sent is not a valid Request object.
        InvalidRequest,
        /// -32601: The method does not exist / is not available.
        MethodNotFound,
        /// -32602: Invalid method parameter(s).
        InvalidParams,
        /// -32603: Internal JSON-RPC error.
        InternalError,
        /// -32000: Generic client error while processing request.
        ServerError,
        /// -38001: Payload does not exist / is not available.
        UnknownPayload,
        /// -38002: Forkchoice state is invalid / inconsistent.
        InvalidForkchoiceState,
        /// -38003: Payload attributes are invalid / inconsistent.
        InvalidPayloadAttributes,
        /// -38004: Number of requested entities is too large.
        TooLargeRequest,
        /// -38005: Payload belongs to a fork that is not supported.
        UnsupportedFork,
    };

    /// Virtual function table for Engine API operations.
    pub const VTable = struct {
        /// Exchange list of supported Engine API methods.
        exchange_capabilities: *const fn (
            ptr: *anyopaque,
            params: ExchangeCapabilitiesParams,
        ) Error!ExchangeCapabilitiesResult,
    };

    /// Exchange list of supported Engine API methods.
    pub fn exchange_capabilities(
        self: EngineApi,
        params: ExchangeCapabilitiesParams,
    ) Error!ExchangeCapabilitiesResult {
        return self.vtable.exchange_capabilities(self.ptr, params);
    }
};

// ============================================================================
// Tests
// ============================================================================

test "engine api dispatches capabilities exchange" {
    const DummyEngine = struct {
        const Self = @This();
        result: ExchangeCapabilitiesResult,
        called: bool = false,

        fn exchange_capabilities(
            ptr: *anyopaque,
            params: ExchangeCapabilitiesParams,
        ) EngineApi.Error!ExchangeCapabilitiesResult {
            const self: *Self = @ptrCast(@alignCast(ptr));
            _ = params;
            self.called = true;
            return self.result;
        }
    };

    const null_value = std.json.Value{ .null = {} };
    const params = ExchangeCapabilitiesParams{
        .consensus_client_methods = .{ .value = null_value },
    };
    const result_value = ExchangeCapabilitiesResult{
        .value = .{ .value = null_value },
    };

    var dummy = DummyEngine{ .result = result_value };
    const vtable = EngineApi.VTable{ .exchange_capabilities = DummyEngine.exchange_capabilities };
    const api = EngineApi{ .ptr = &dummy, .vtable = &vtable };

    const result = try api.exchange_capabilities(params);
    try std.testing.expect(dummy.called);
    try std.testing.expectEqualDeep(result_value, result);
}
