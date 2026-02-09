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

const exchange_capabilities_method = "engine_exchangeCapabilities";

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
    /// Enforces spec invariants (versioned methods; response excludes engine_exchangeCapabilities).
    pub fn exchange_capabilities(
        self: EngineApi,
        params: ExchangeCapabilitiesParams,
    ) Error!ExchangeCapabilitiesResult {
        try validateCapabilities(params.consensus_client_methods, Error.InvalidParams);
        const result = try self.vtable.exchange_capabilities(self.ptr, params);
        try validateCapabilities(result.value, Error.InternalError);
        return result;
    }
};

fn validateCapabilities(list: anytype, comptime invalid_err: EngineApi.Error) EngineApi.Error!void {
    const ListType = @TypeOf(list);
    if (comptime @hasField(ListType, "value")) {
        return validateCapabilities(list.value, invalid_err);
    }

    if (comptime isSliceOfByteSlices(ListType)) {
        for (list) |method| {
            try validateMethodName(method, invalid_err);
        }
        return;
    }

    if (comptime ListType == std.json.Value) {
        return validateJsonCapabilities(list, invalid_err);
    }

    return invalid_err;
}

fn validateJsonCapabilities(value: std.json.Value, comptime invalid_err: EngineApi.Error) EngineApi.Error!void {
    switch (value) {
        .array => |array| {
            for (array.items) |item| {
                switch (item) {
                    .string => |method| try validateMethodName(method, invalid_err),
                    else => return invalid_err,
                }
            }
        },
        else => return invalid_err,
    }
}

fn validateMethodName(method: []const u8, comptime invalid_err: EngineApi.Error) EngineApi.Error!void {
    if (std.mem.eql(u8, method, exchange_capabilities_method)) return invalid_err;
    if (!isVersionedMethod(method)) return invalid_err;
}

fn isVersionedMethod(method: []const u8) bool {
    if (method.len < 2) return false;

    var idx: usize = method.len;
    while (idx > 0 and std.ascii.isDigit(method[idx - 1])) {
        idx -= 1;
    }

    if (idx == method.len or idx == 0) return false;
    return method[idx - 1] == 'V';
}

fn isSliceOfByteSlices(comptime T: type) bool {
    const info = @typeInfo(T);
    if (info != .pointer or info.pointer.size != .slice) return false;
    const child_info = @typeInfo(info.pointer.child);
    if (child_info != .pointer or child_info.pointer.size != .slice) return false;
    return child_info.pointer.child == u8;
}

// ============================================================================
// Tests
// ============================================================================

fn makeMethodsPayload(comptime MethodsType: type, allocator: std.mem.Allocator, methods: []const []const u8) !struct {
    array: ?std.json.Array,
    value: MethodsType,
} {
    if (comptime isSliceOfByteSlices(MethodsType)) {
        return .{ .array = null, .value = methods };
    }

    if (comptime MethodsType == std.json.Value) {
        var array = std.json.Array.init(allocator);
        for (methods) |method| {
            try array.append(.{ .string = method });
        }
        return .{ .array = array, .value = .{ .array = array } };
    }

    if (comptime @hasField(MethodsType, "value")) {
        const inner_type = @TypeOf(@as(MethodsType, undefined).value);
        if (comptime inner_type == std.json.Value) {
            var array = std.json.Array.init(allocator);
            for (methods) |method| {
                try array.append(.{ .string = method });
            }
            return .{ .array = array, .value = .{ .value = .{ .array = array } } };
        }
    }

    @compileError("Unsupported Engine API capability list type");
}

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

    const allocator = std.testing.allocator;
    const ConsensusType = @FieldType(ExchangeCapabilitiesParams, "consensus_client_methods");
    const ResultType = @FieldType(ExchangeCapabilitiesResult, "value");

    var consensus_payload = try makeMethodsPayload(ConsensusType, allocator, &[_][]const u8{
        "engine_newPayloadV1",
        "engine_forkchoiceUpdatedV1",
    });
    defer if (consensus_payload.array) |*array| array.deinit();

    var result_payload = try makeMethodsPayload(ResultType, allocator, &[_][]const u8{
        "engine_newPayloadV1",
    });
    defer if (result_payload.array) |*array| array.deinit();

    const params = ExchangeCapabilitiesParams{
        .consensus_client_methods = consensus_payload.value,
    };
    const result_value = ExchangeCapabilitiesResult{
        .value = result_payload.value,
    };

    var dummy = DummyEngine{ .result = result_value };
    const vtable = EngineApi.VTable{ .exchange_capabilities = DummyEngine.exchange_capabilities };
    const api = EngineApi{ .ptr = &dummy, .vtable = &vtable };

    const result = try api.exchange_capabilities(params);
    try std.testing.expect(dummy.called);
    try std.testing.expectEqualDeep(result_value, result);
}

test "engine api rejects unversioned consensus capabilities" {
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

    const allocator = std.testing.allocator;
    const ConsensusType = @FieldType(ExchangeCapabilitiesParams, "consensus_client_methods");
    const ResultType = @FieldType(ExchangeCapabilitiesResult, "value");

    var consensus_payload = try makeMethodsPayload(ConsensusType, allocator, &[_][]const u8{
        "engine_newPayload",
    });
    defer if (consensus_payload.array) |*array| array.deinit();

    var result_payload = try makeMethodsPayload(ResultType, allocator, &[_][]const u8{
        "engine_newPayloadV1",
    });
    defer if (result_payload.array) |*array| array.deinit();

    const params = ExchangeCapabilitiesParams{
        .consensus_client_methods = consensus_payload.value,
    };
    const result_value = ExchangeCapabilitiesResult{
        .value = result_payload.value,
    };

    var dummy = DummyEngine{ .result = result_value };
    const vtable = EngineApi.VTable{ .exchange_capabilities = DummyEngine.exchange_capabilities };
    const api = EngineApi{ .ptr = &dummy, .vtable = &vtable };

    try std.testing.expectError(EngineApi.Error.InvalidParams, api.exchange_capabilities(params));
    try std.testing.expect(!dummy.called);
}

test "engine api rejects response containing exchangeCapabilities" {
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

    const allocator = std.testing.allocator;
    const ConsensusType = @FieldType(ExchangeCapabilitiesParams, "consensus_client_methods");
    const ResultType = @FieldType(ExchangeCapabilitiesResult, "value");

    var consensus_payload = try makeMethodsPayload(ConsensusType, allocator, &[_][]const u8{
        "engine_newPayloadV1",
    });
    defer if (consensus_payload.array) |*array| array.deinit();

    var result_payload = try makeMethodsPayload(ResultType, allocator, &[_][]const u8{
        "engine_exchangeCapabilities",
    });
    defer if (result_payload.array) |*array| array.deinit();

    const params = ExchangeCapabilitiesParams{
        .consensus_client_methods = consensus_payload.value,
    };
    const result_value = ExchangeCapabilitiesResult{
        .value = result_payload.value,
    };

    var dummy = DummyEngine{ .result = result_value };
    const vtable = EngineApi.VTable{ .exchange_capabilities = DummyEngine.exchange_capabilities };
    const api = EngineApi{ .ptr = &dummy, .vtable = &vtable };

    try std.testing.expectError(EngineApi.Error.InternalError, api.exchange_capabilities(params));
    try std.testing.expect(dummy.called);
}
