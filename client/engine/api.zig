/// Engine API interface for consensus layer communication.
///
/// Mirrors Nethermind's IEngineRpcModule capability exchange surface and
/// follows the vtable-based dependency injection pattern used in src/host.zig.
const std = @import("std");
const jsonrpc = @import("jsonrpc");
const primitives = @import("primitives");

const ExchangeCapabilitiesMethod = @FieldType(jsonrpc.engine.EngineMethod, "engine_exchangeCapabilities");
const ClientVersionV1Method = @FieldType(jsonrpc.engine.EngineMethod, "engine_getClientVersionV1");
/// Parameters for `engine_exchangeCapabilities` requests.
pub const ExchangeCapabilitiesParams = @FieldType(ExchangeCapabilitiesMethod, "params");
/// Result payload for `engine_exchangeCapabilities` responses.
pub const ExchangeCapabilitiesResult = @FieldType(ExchangeCapabilitiesMethod, "result");
/// Parameters for `engine_getClientVersionV1` requests.
pub const ClientVersionV1Params = @FieldType(ClientVersionV1Method, "params");
/// Result payload for `engine_getClientVersionV1` responses.
pub const ClientVersionV1Result = @FieldType(ClientVersionV1Method, "result");
const ClientVersionV1 = @FieldType(ClientVersionV1Params, "consensus_client");

const exchange_capabilities_method = "engine_exchangeCapabilities";
const engine_method_prefix = "engine_";

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
        /// Return execution layer client version information.
        get_client_version_v1: *const fn (
            ptr: *anyopaque,
            params: ClientVersionV1Params,
        ) Error!ClientVersionV1Result,
    };

    /// Exchange list of supported Engine API methods.
    /// Enforces spec invariants (versioned methods; response excludes engine_exchangeCapabilities).
    pub fn exchange_capabilities(
        self: EngineApi,
        params: ExchangeCapabilitiesParams,
    ) Error!ExchangeCapabilitiesResult {
        try validate_capabilities(params.consensus_client_methods, Error.InvalidParams);
        const result = try self.vtable.exchange_capabilities(self.ptr, params);
        try validate_capabilities(result.value, Error.InternalError);
        return result;
    }

    /// Returns execution client version information for `engine_getClientVersionV1`.
    pub fn get_client_version_v1(
        self: EngineApi,
        params: ClientVersionV1Params,
    ) Error!ClientVersionV1Result {
        try validate_client_version_v1_params(params, Error.InvalidParams);
        const result = try self.vtable.get_client_version_v1(self.ptr, params);
        try validate_client_version_v1_result(result, Error.InternalError);
        return result;
    }
};

fn validate_capabilities(list: anytype, comptime invalid_err: EngineApi.Error) EngineApi.Error!void {
    const ListType = @TypeOf(list);
    if (comptime @hasField(ListType, "value")) {
        return validate_capabilities(list.value, invalid_err);
    }

    if (comptime is_slice_of_byte_slices(ListType)) {
        for (list) |method| {
            try validate_method_name(method, invalid_err);
        }
        return;
    }

    if (comptime ListType == std.json.Value) {
        return validate_json_capabilities(list, invalid_err);
    }

    return invalid_err;
}

fn validate_json_capabilities(value: std.json.Value, comptime invalid_err: EngineApi.Error) EngineApi.Error!void {
    switch (value) {
        .array => |array| {
            for (array.items) |item| {
                switch (item) {
                    .string => |method| try validate_method_name(method, invalid_err),
                    else => return invalid_err,
                }
            }
        },
        else => return invalid_err,
    }
}

fn validate_method_name(method: []const u8, comptime invalid_err: EngineApi.Error) EngineApi.Error!void {
    if (!std.mem.startsWith(u8, method, engine_method_prefix)) return invalid_err;
    if (std.mem.eql(u8, method, exchange_capabilities_method)) return invalid_err;
    if (!is_versioned_method(method)) return invalid_err;
    _ = jsonrpc.engine.EngineMethod.fromMethodName(method) catch return invalid_err;
}

fn validate_client_version_v1_params(params: ClientVersionV1Params, comptime invalid_err: EngineApi.Error) EngineApi.Error!void {
    try validate_client_version_v1(params.consensus_client, invalid_err);
}

fn validate_client_version_v1_result(result: ClientVersionV1Result, comptime invalid_err: EngineApi.Error) EngineApi.Error!void {
    if (result.value.len == 0) return invalid_err;
    for (result.value) |client| {
        try validate_client_version_v1(client, invalid_err);
    }
}

fn validate_client_version_v1(client: ClientVersionV1, comptime invalid_err: EngineApi.Error) EngineApi.Error!void {
    if (client.code.len != 2) return invalid_err;
    _ = primitives.Hex.assertSize(client.commit, 4) catch return invalid_err;
}

fn is_versioned_method(method: []const u8) bool {
    if (method.len < 2) return false;

    var idx: usize = method.len;
    while (idx > 0 and std.ascii.isDigit(method[idx - 1])) {
        idx -= 1;
    }

    if (idx == method.len or idx == 0) return false;
    return method[idx - 1] == 'V';
}

fn is_slice_of_byte_slices(comptime T: type) bool {
    const info = @typeInfo(T);
    if (info != .pointer or info.pointer.size != .slice) return false;
    const child_info = @typeInfo(info.pointer.child);
    if (child_info != .pointer or child_info.pointer.size != .slice) return false;
    return child_info.pointer.child == u8;
}

// ============================================================================
// Tests
// ============================================================================

fn deinit_methods_payload(payload: anytype) void {
    if (payload.array) |*array| array.deinit();
}

fn make_methods_payload(comptime MethodsType: type, allocator: std.mem.Allocator, methods: []const []const u8) !struct {
    array: ?std.json.Array,
    value: MethodsType,
} {
    if (comptime is_slice_of_byte_slices(MethodsType)) {
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

const ConsensusType = @FieldType(ExchangeCapabilitiesParams, "consensus_client_methods");
const ResultType = @FieldType(ExchangeCapabilitiesResult, "value");
const dummy_client_version = ClientVersionV1{
    .code = "GM",
    .name = "guillotine-mini",
    .version = "0.0.0",
    .commit = "0x00000000",
};

const DummyEngine = struct {
    const Self = @This();
    result: ExchangeCapabilitiesResult,
    client_version_result: ClientVersionV1Result = ClientVersionV1Result{ .value = &[_]ClientVersionV1{dummy_client_version} },
    called: bool = false,
    client_version_called: bool = false,

    fn exchange_capabilities(
        ptr: *anyopaque,
        params: ExchangeCapabilitiesParams,
    ) EngineApi.Error!ExchangeCapabilitiesResult {
        const self: *Self = @ptrCast(@alignCast(ptr));
        _ = params;
        self.called = true;
        return self.result;
    }

    fn get_client_version_v1(
        ptr: *anyopaque,
        params: ClientVersionV1Params,
    ) EngineApi.Error!ClientVersionV1Result {
        const self: *Self = @ptrCast(@alignCast(ptr));
        _ = params;
        self.client_version_called = true;
        return self.client_version_result;
    }
};

const dummy_vtable = EngineApi.VTable{
    .exchange_capabilities = DummyEngine.exchange_capabilities,
    .get_client_version_v1 = DummyEngine.get_client_version_v1,
};

fn make_api(dummy: *DummyEngine) EngineApi {
    return EngineApi{ .ptr = dummy, .vtable = &dummy_vtable };
}

test "engine api dispatches capabilities exchange" {
    const allocator = std.testing.allocator;

    var consensus_payload = try make_methods_payload(ConsensusType, allocator, &[_][]const u8{
        "engine_newPayloadV1",
        "engine_forkchoiceUpdatedV1",
    });
    defer deinit_methods_payload(&consensus_payload);

    var result_payload = try make_methods_payload(ResultType, allocator, &[_][]const u8{
        "engine_newPayloadV1",
    });
    defer deinit_methods_payload(&result_payload);

    const params = ExchangeCapabilitiesParams{
        .consensus_client_methods = consensus_payload.value,
    };
    const result_value = ExchangeCapabilitiesResult{
        .value = result_payload.value,
    };

    var dummy = DummyEngine{ .result = result_value };
    const api = make_api(&dummy);

    const result = try api.exchange_capabilities(params);
    try std.testing.expect(dummy.called);
    try std.testing.expectEqualDeep(result_value, result);
}

test "engine api rejects unversioned consensus capabilities" {
    const allocator = std.testing.allocator;

    var consensus_payload = try make_methods_payload(ConsensusType, allocator, &[_][]const u8{
        "engine_newPayload",
    });
    defer deinit_methods_payload(&consensus_payload);

    var result_payload = try make_methods_payload(ResultType, allocator, &[_][]const u8{
        "engine_newPayloadV1",
    });
    defer deinit_methods_payload(&result_payload);

    const params = ExchangeCapabilitiesParams{
        .consensus_client_methods = consensus_payload.value,
    };
    const result_value = ExchangeCapabilitiesResult{
        .value = result_payload.value,
    };

    var dummy = DummyEngine{ .result = result_value };
    const api = make_api(&dummy);

    try std.testing.expectError(EngineApi.Error.InvalidParams, api.exchange_capabilities(params));
    try std.testing.expect(!dummy.called);
}

test "engine api rejects non-engine consensus capabilities" {
    const allocator = std.testing.allocator;

    var consensus_payload = try make_methods_payload(ConsensusType, allocator, &[_][]const u8{
        "eth_getBlockByNumberV1",
    });
    defer deinit_methods_payload(&consensus_payload);

    var result_payload = try make_methods_payload(ResultType, allocator, &[_][]const u8{
        "engine_newPayloadV1",
    });
    defer deinit_methods_payload(&result_payload);

    const params = ExchangeCapabilitiesParams{
        .consensus_client_methods = consensus_payload.value,
    };
    const result_value = ExchangeCapabilitiesResult{
        .value = result_payload.value,
    };

    var dummy = DummyEngine{ .result = result_value };
    const api = make_api(&dummy);

    try std.testing.expectError(EngineApi.Error.InvalidParams, api.exchange_capabilities(params));
    try std.testing.expect(!dummy.called);
}

test "engine api rejects unknown engine consensus capabilities" {
    const allocator = std.testing.allocator;

    var consensus_payload = try make_methods_payload(ConsensusType, allocator, &[_][]const u8{
        "engine_fooV1",
    });
    defer deinit_methods_payload(&consensus_payload);

    var result_payload = try make_methods_payload(ResultType, allocator, &[_][]const u8{
        "engine_newPayloadV1",
    });
    defer deinit_methods_payload(&result_payload);

    const params = ExchangeCapabilitiesParams{
        .consensus_client_methods = consensus_payload.value,
    };
    const result_value = ExchangeCapabilitiesResult{
        .value = result_payload.value,
    };

    var dummy = DummyEngine{ .result = result_value };
    const api = make_api(&dummy);

    try std.testing.expectError(EngineApi.Error.InvalidParams, api.exchange_capabilities(params));
    try std.testing.expect(!dummy.called);
}

test "engine api rejects non-array consensus capabilities payload" {
    const allocator = std.testing.allocator;
    var result_payload = try make_methods_payload(ResultType, allocator, &[_][]const u8{
        "engine_newPayloadV1",
    });
    defer deinit_methods_payload(&result_payload);

    const params = ExchangeCapabilitiesParams{
        .consensus_client_methods = jsonrpc.types.Quantity{ .value = .{ .string = "engine_newPayloadV1" } },
    };

    var dummy = DummyEngine{ .result = .{ .value = result_payload.value } };
    const api = make_api(&dummy);

    try std.testing.expectError(EngineApi.Error.InvalidParams, api.exchange_capabilities(params));
    try std.testing.expect(!dummy.called);
}

test "engine api rejects non-string consensus capabilities entries" {
    const allocator = std.testing.allocator;

    var invalid_array = std.json.Array.init(allocator);
    defer invalid_array.deinit();
    try invalid_array.append(.{ .bool = true });
    try invalid_array.append(.{ .string = "engine_newPayloadV1" });

    const params = ExchangeCapabilitiesParams{
        .consensus_client_methods = jsonrpc.types.Quantity{ .value = .{ .array = invalid_array } },
    };

    var result_payload = try make_methods_payload(ResultType, allocator, &[_][]const u8{
        "engine_newPayloadV1",
    });
    defer deinit_methods_payload(&result_payload);

    var dummy = DummyEngine{ .result = .{ .value = result_payload.value } };
    const api = make_api(&dummy);

    try std.testing.expectError(EngineApi.Error.InvalidParams, api.exchange_capabilities(params));
    try std.testing.expect(!dummy.called);
}

test "engine api rejects response containing exchangeCapabilities" {
    const allocator = std.testing.allocator;

    var consensus_payload = try make_methods_payload(ConsensusType, allocator, &[_][]const u8{
        "engine_newPayloadV1",
    });
    defer deinit_methods_payload(&consensus_payload);

    var result_payload = try make_methods_payload(ResultType, allocator, &[_][]const u8{
        "engine_exchangeCapabilities",
    });
    defer deinit_methods_payload(&result_payload);

    const params = ExchangeCapabilitiesParams{
        .consensus_client_methods = consensus_payload.value,
    };
    const result_value = ExchangeCapabilitiesResult{
        .value = result_payload.value,
    };

    var dummy = DummyEngine{ .result = result_value };
    const api = make_api(&dummy);

    try std.testing.expectError(EngineApi.Error.InternalError, api.exchange_capabilities(params));
    try std.testing.expect(dummy.called);
}

test "engine api dispatches client version exchange" {
    const consensus_client = ClientVersionV1{
        .code = "LS",
        .name = "Lodestar",
        .version = "v1.2.3",
        .commit = "0x01020304",
    };
    const params = ClientVersionV1Params{ .consensus_client = consensus_client };
    const result_value = ClientVersionV1Result{ .value = &[_]ClientVersionV1{dummy_client_version} };
    const exchange_result = ExchangeCapabilitiesResult{
        .value = jsonrpc.types.Quantity{ .value = .{ .null = {} } },
    };

    var dummy = DummyEngine{
        .result = exchange_result,
        .client_version_result = result_value,
    };
    const api = make_api(&dummy);

    const result = try api.get_client_version_v1(params);
    try std.testing.expect(dummy.client_version_called);
    try std.testing.expectEqualDeep(result_value, result);
}

test "engine api rejects invalid client version params" {
    const bad_params = ClientVersionV1Params{
        .consensus_client = ClientVersionV1{
            .code = "BAD",
            .name = "Lodestar",
            .version = "v1.2.3",
            .commit = "0x01020304",
        },
    };
    const exchange_result = ExchangeCapabilitiesResult{
        .value = jsonrpc.types.Quantity{ .value = .{ .null = {} } },
    };

    var dummy = DummyEngine{ .result = exchange_result };
    const api = make_api(&dummy);

    try std.testing.expectError(EngineApi.Error.InvalidParams, api.get_client_version_v1(bad_params));
    try std.testing.expect(!dummy.client_version_called);
}

test "engine api rejects invalid client version response" {
    const params = ClientVersionV1Params{ .consensus_client = dummy_client_version };
    const invalid_result = ClientVersionV1Result{ .value = &[_]ClientVersionV1{} };
    const exchange_result = ExchangeCapabilitiesResult{
        .value = jsonrpc.types.Quantity{ .value = .{ .null = {} } },
    };

    var dummy = DummyEngine{
        .result = exchange_result,
        .client_version_result = invalid_result,
    };
    const api = make_api(&dummy);

    try std.testing.expectError(EngineApi.Error.InternalError, api.get_client_version_v1(params));
    try std.testing.expect(dummy.client_version_called);
}
