/// Engine API interface for consensus layer communication.
///
/// Mirrors Nethermind's IEngineRpcModule capability exchange surface and
/// follows the vtable-based dependency injection pattern used in src/host.zig.
const std = @import("std");
const jsonrpc = @import("jsonrpc");
const primitives = @import("primitives");
const method_name = @import("method_name.zig");

const ExchangeCapabilitiesMethod = @FieldType(jsonrpc.engine.EngineMethod, "engine_exchangeCapabilities");
const ExchangeTransitionConfigurationV1Method =
    @FieldType(jsonrpc.engine.EngineMethod, "engine_exchangeTransitionConfigurationV1");
/// Parameters for `engine_exchangeCapabilities` requests.
pub const ExchangeCapabilitiesParams = @FieldType(ExchangeCapabilitiesMethod, "params");
/// Result payload for `engine_exchangeCapabilities` responses.
pub const ExchangeCapabilitiesResult = @FieldType(ExchangeCapabilitiesMethod, "result");

/// ClientVersionV1 per execution-apis/src/engine/identification.md.
pub const ClientVersionV1 = jsonrpc.types.Quantity;

/// Parameters for `engine_getClientVersionV1` requests.
pub const ClientVersionV1Params = struct {
    consensus_client: ClientVersionV1,
};

/// Result payload for `engine_getClientVersionV1` responses.
pub const ClientVersionV1Result = struct {
    value: []const ClientVersionV1,
};

/// Parameters for `engine_exchangeTransitionConfigurationV1` requests.
pub const ExchangeTransitionConfigurationV1Params = @FieldType(ExchangeTransitionConfigurationV1Method, "params");
/// Result payload for `engine_exchangeTransitionConfigurationV1` responses.
pub const ExchangeTransitionConfigurationV1Result = @FieldType(ExchangeTransitionConfigurationV1Method, "result");

// Method-name validation logic is centralized in client/engine/method_name.zig

/// Vtable-based Engine API interface.
///
/// Exposes `engine_exchangeCapabilities` and
/// `engine_exchangeTransitionConfigurationV1`. Each handler validates its
/// inputs/outputs per execution-apis: capability lists must be engine_*
/// and versioned (and responses must exclude `engine_exchangeCapabilities`).
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

    /// Engine API error codes per execution-apis common definitions.
    pub const ErrorCode = struct {
        /// JSON-RPC error code integer type.
        /// Use plain i32 to avoid an unnecessary re-export indirection.
        pub const Code = i32;

        /// -32700: Invalid JSON was received by the server.
        pub const parse_error: Code = -32700;
        /// -32600: The JSON sent is not a valid Request object.
        pub const invalid_request: Code = -32600;
        /// -32601: The method does not exist / is not available.
        pub const method_not_found: Code = -32601;
        /// -32602: Invalid method parameter(s).
        pub const invalid_params: Code = -32602;
        /// -32603: Internal JSON-RPC error.
        pub const internal_error: Code = -32603;
        /// -32000: Generic client error while processing request.
        pub const server_error: Code = -32000;
        /// -38001: Payload does not exist / is not available.
        pub const unknown_payload: Code = -38001;
        /// -38002: Forkchoice state is invalid / inconsistent.
        pub const invalid_forkchoice_state: Code = -38002;
        /// -38003: Payload attributes are invalid / inconsistent.
        pub const invalid_payload_attributes: Code = -38003;
        /// -38004: Number of requested entities is too large.
        pub const too_large_request: Code = -38004;
        /// -38005: Payload belongs to a fork that is not supported.
        pub const unsupported_fork: Code = -38005;
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
        /// Exchange transition configuration for Paris (EIP-3675).
        /// Note: Deprecated since Cancun; retained for compatibility per execution-apis.
        exchange_transition_configuration_v1: *const fn (
            ptr: *anyopaque,
            params: ExchangeTransitionConfigurationV1Params,
        ) Error!ExchangeTransitionConfigurationV1Result,
    };

    /// Exchange list of supported Engine API methods.
    /// Enforces spec invariants (versioned methods; response excludes engine_exchangeCapabilities).
    pub fn exchange_capabilities(
        self: EngineApi,
        params: ExchangeCapabilitiesParams,
    ) Error!ExchangeCapabilitiesResult {
        try validate_capabilities(params.consensus_client_methods, Error.InvalidParams);
        const result = try self.vtable.exchange_capabilities(self.ptr, params);
        // Response list must satisfy full advertisable rules
        try validate_response_capabilities(result.value, Error.InternalError);
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

    /// Exchanges transition configuration with the consensus client.
    /// Validates JSON shapes per execution-apis Paris spec (TransitionConfigurationV1).
    pub fn exchange_transition_configuration_v1(
        self: EngineApi,
        params: ExchangeTransitionConfigurationV1Params,
    ) Error!ExchangeTransitionConfigurationV1Result {
        try validate_transition_configuration_params(params, Error.InvalidParams);
        const result = try self.vtable.exchange_transition_configuration_v1(self.ptr, params);
        try validate_transition_configuration_result(result, Error.InternalError);
        return result;
    }

    /// Generic dispatcher for EngineMethod calls using Voltaire's EngineMethod schema.
    ///
    /// Partial coverage: currently handles `engine_exchangeCapabilities` and
    /// `engine_exchangeTransitionConfigurationV1`. All other Engine methods
    /// return `Error.MethodNotFound` until implemented.
    ///
    /// Example:
    /// const Result = try api.dispatch("engine_exchangeCapabilities", params);
    pub fn dispatch(
        self: EngineApi,
        comptime Method: type,
        params: @FieldType(Method, "params"),
    ) Error!@FieldType(Method, "result") {
        if (comptime Method == ExchangeCapabilitiesMethod) {
            return self.exchange_capabilities(params);
        } else if (comptime Method == ExchangeTransitionConfigurationV1Method) {
            return self.exchange_transition_configuration_v1(params);
        } else {
            return Error.MethodNotFound;
        }
    }
};

fn validate_string_list(list: anytype, comptime invalid_err: EngineApi.Error, comptime pred: fn ([]const u8) bool) EngineApi.Error!void {
    const ListType = @TypeOf(list);
    if (comptime @hasField(ListType, "value")) return validate_string_list(list.value, invalid_err, pred);
    if (comptime is_slice_of_byte_slices(ListType)) {
        for (list) |name| if (!pred(name)) return invalid_err;
        return;
    }
    if (comptime ListType == std.json.Value) return validate_json_string_array(list, invalid_err, pred);
    return invalid_err;
}

fn validate_capabilities(list: anytype, comptime invalid_err: EngineApi.Error) EngineApi.Error!void {
    return validate_string_list(list, invalid_err, method_name.isEngineVersionedMethodName);
}

/// Validate a JSON array of strings using a predicate .
/// Returns  if the JSON shape is not an array of strings or if any
/// string fails the predicate.
fn validate_json_string_array(
    value: std.json.Value,
    comptime invalid_err: EngineApi.Error,
    comptime pred: fn ([]const u8) bool,
) EngineApi.Error!void {
    if (value != .array) return invalid_err;
    const items = value.array.items;
    var i: usize = 0;
    while (i < items.len) : (i += 1) {
        const item = items[i];
        if (item != .string) return invalid_err;
        if (!pred(item.string)) return invalid_err;
    }
}

fn validate_json_capabilities(value: std.json.Value, comptime invalid_err: EngineApi.Error) EngineApi.Error!void {
    return validate_json_string_array(value, invalid_err, method_name.isEngineVersionedMethodName);
}

fn validate_response_capabilities(list: anytype, comptime invalid_err: EngineApi.Error) EngineApi.Error!void {
    return validate_string_list(list, invalid_err, method_name.isValidAdvertisableEngineMethodName);
}

fn validate_json_response_capabilities(value: std.json.Value, comptime invalid_err: EngineApi.Error) EngineApi.Error!void {
    return validate_json_string_array(value, invalid_err, method_name.isValidAdvertisableEngineMethodName);
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
    const v = client.value;
    if (v != .object) return invalid_err;
    const obj = v.object;
    const code_val = obj.get("code") orelse return invalid_err;
    if (code_val != .string) return invalid_err;
    if (code_val.string.len != 2) return invalid_err;
    // Enforce two ASCII letters for ClientCode per identification.md examples.
    // Accept either case to accommodate future additions.
    {
        const s = code_val.string;
        inline for (0..2) |i| {
            const c = s[i];
            if (!(std.ascii.isAlphabetic(c))) return invalid_err;
        }
    }

    // name: required string
    const name_val = obj.get("name") orelse return invalid_err;
    if (name_val != .string) return invalid_err;
    // version: required string
    const version_val = obj.get("version") orelse return invalid_err;
    if (version_val != .string) return invalid_err;

    const commit_val = obj.get("commit") orelse return invalid_err;
    if (commit_val != .string) return invalid_err;
    // Must be 0x-prefixed 4-byte DATA, per spec.
    _ = primitives.Hex.assertSize(commit_val.string, 4) catch return invalid_err;
}

fn validate_transition_configuration_params(
    params: ExchangeTransitionConfigurationV1Params,
    comptime invalid_err: EngineApi.Error,
) EngineApi.Error!void {
    // Voltaire JSON-RPC typing wraps dynamic values in Quantity.value: std.json.Value
    return validate_transition_configuration_json(params.consensus_client_configuration.value, invalid_err);
}

fn validate_transition_configuration_result(
    result: ExchangeTransitionConfigurationV1Result,
    comptime invalid_err: EngineApi.Error,
) EngineApi.Error!void {
    return validate_transition_configuration_json(result.value.value, invalid_err);
}

fn validate_transition_configuration_json(value: std.json.Value, comptime invalid_err: EngineApi.Error) EngineApi.Error!void {
    // TransitionConfigurationV1 object with fields:
    // - terminalTotalDifficulty: QUANTITY (u256)
    // - terminalBlockHash: DATA (32 bytes)
    // - terminalBlockNumber: QUANTITY (u64)
    if (value != .object) return invalid_err;

    const obj = value.object;

    const ttd_val = obj.get("terminalTotalDifficulty") orelse return invalid_err;
    const tbh_val = obj.get("terminalBlockHash") orelse return invalid_err;
    const tbn_val = obj.get("terminalBlockNumber") orelse return invalid_err;

    // Validate terminalTotalDifficulty as QUANTITY (hex) parsable to u256
    switch (ttd_val) {
        .string => |s| _ = primitives.Hex.hexToU256(s) catch return invalid_err,
        else => return invalid_err,
    }

    // Validate terminalBlockHash is 32-byte DATA hex string
    switch (tbh_val) {
        .string => |s| _ = primitives.Hex.assertSize(s, 32) catch return invalid_err,
        else => return invalid_err,
    }

    // Validate terminalBlockNumber fits in 64-bit QUANTITY
    switch (tbn_val) {
        .string => |s| {
            const v: u256 = primitives.Hex.hexToU256(s) catch return invalid_err;
            if (v > std.math.maxInt(u64)) return invalid_err;
        },
        else => return invalid_err,
    }
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

test "engine api error codes match engine api spec" {
    const Code = EngineApi.ErrorCode.Code;
    try std.testing.expectEqual(@as(Code, -32700), EngineApi.ErrorCode.parse_error);
    try std.testing.expectEqual(@as(Code, -32600), EngineApi.ErrorCode.invalid_request);
    try std.testing.expectEqual(@as(Code, -32601), EngineApi.ErrorCode.method_not_found);
    try std.testing.expectEqual(@as(Code, -32602), EngineApi.ErrorCode.invalid_params);
    try std.testing.expectEqual(@as(Code, -32603), EngineApi.ErrorCode.internal_error);
    try std.testing.expectEqual(@as(Code, -32000), EngineApi.ErrorCode.server_error);
    try std.testing.expectEqual(@as(Code, -38001), EngineApi.ErrorCode.unknown_payload);
    try std.testing.expectEqual(@as(Code, -38002), EngineApi.ErrorCode.invalid_forkchoice_state);
    try std.testing.expectEqual(@as(Code, -38003), EngineApi.ErrorCode.invalid_payload_attributes);
    try std.testing.expectEqual(@as(Code, -38004), EngineApi.ErrorCode.too_large_request);
    try std.testing.expectEqual(@as(Code, -38005), EngineApi.ErrorCode.unsupported_fork);
}

fn deinit_methods_payload(payload: anytype) void {
    if (payload.array) |*array| array.deinit();
}

fn make_json_methods_array(allocator: std.mem.Allocator, methods: []const []const u8) !std.json.Array {
    var array = std.json.Array.init(allocator);
    for (methods) |method| {
        try array.append(.{ .string = method });
    }
    return array;
}

fn make_methods_payload(comptime MethodsType: type, allocator: std.mem.Allocator, methods: []const []const u8) !struct {
    array: ?std.json.Array,
    value: MethodsType,
} {
    if (comptime is_slice_of_byte_slices(MethodsType)) {
        return .{ .array = null, .value = methods };
    }

    if (comptime MethodsType == std.json.Value) {
        const array = try make_json_methods_array(allocator, methods);
        return .{ .array = array, .value = .{ .array = array } };
    }

    if (comptime @hasField(MethodsType, "value") or MethodsType == jsonrpc.types.Quantity) {
        const array = try make_json_methods_array(allocator, methods);
        const val: std.json.Value = .{ .array = array };
        const typed = try std.json.innerParseFromValue(MethodsType, allocator, val, .{});
        return .{ .array = array, .value = typed };
    }

    @compileError("Unsupported Engine API capability list type");
}

const ConsensusType = @FieldType(ExchangeCapabilitiesParams, "consensus_client_methods");
const ResultType = @FieldType(ExchangeCapabilitiesResult, "value");
fn make_dummy_client_version(allocator: std.mem.Allocator) !ClientVersionV1 {
    var obj = std.json.ObjectMap.init(allocator);
    try obj.put("code", .{ .string = "GM" });
    try obj.put("name", .{ .string = "guillotine-mini" });
    try obj.put("version", .{ .string = "0.0.0" });
    try obj.put("commit", .{ .string = "0x00000000" });
    const val: std.json.Value = .{ .object = obj };
    return try std.json.innerParseFromValue(ClientVersionV1, allocator, val, .{});
}

const DummyEngine = struct {
    const Self = @This();
    result: ExchangeCapabilitiesResult,
    client_version_result: ClientVersionV1Result = undefined,
    transition_result: ExchangeTransitionConfigurationV1Result = undefined,
    called: bool = false,
    client_version_called: bool = false,
    transition_called: bool = false,

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

    fn exchange_transition_configuration_v1(
        ptr: *anyopaque,
        params: ExchangeTransitionConfigurationV1Params,
    ) EngineApi.Error!ExchangeTransitionConfigurationV1Result {
        const self: *Self = @ptrCast(@alignCast(ptr));
        _ = params;
        self.transition_called = true;
        return self.transition_result;
    }
};

const dummy_vtable = EngineApi.VTable{
    .exchange_capabilities = DummyEngine.exchange_capabilities,
    .get_client_version_v1 = DummyEngine.get_client_version_v1,
    .exchange_transition_configuration_v1 = DummyEngine.exchange_transition_configuration_v1,
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
    // initialize default client_version_result using dummy client JSON
    {
        const alloc = std.testing.allocator;
        const client_const = try make_dummy_client_version(alloc);
        var client = client_const; // allow deinit of inner ObjectMap
        defer if (client.value == .object) client.value.object.deinit();
        dummy.client_version_result = .{ .value = &[_]ClientVersionV1{client_const} };
    }
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

test "engine api allows unknown engine consensus capabilities" {
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

    _ = try api.exchange_capabilities(params);
    try std.testing.expect(dummy.called);
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

test "engine api rejects response containing non-engine methods" {
    const allocator = std.testing.allocator;

    var consensus_payload = try make_methods_payload(ConsensusType, allocator, &[_][]const u8{
        "engine_newPayloadV1",
    });
    defer deinit_methods_payload(&consensus_payload);

    // Execution client must not advertise non-engine namespace methods
    var result_payload = try make_methods_payload(ResultType, allocator, &[_][]const u8{
        "eth_getBlockByNumberV1",
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

    // Violation must surface as InternalError (bad executor response)
    try std.testing.expectError(EngineApi.Error.InternalError, api.exchange_capabilities(params));
    try std.testing.expect(dummy.called);
}

test "engine api rejects response containing unversioned engine methods" {
    const allocator = std.testing.allocator;

    var consensus_payload = try make_methods_payload(ConsensusType, allocator, &[_][]const u8{
        "engine_newPayloadV1",
    });
    defer deinit_methods_payload(&consensus_payload);

    // Execution client must only advertise versioned engine_* methods
    var result_payload = try make_methods_payload(ResultType, allocator, &[_][]const u8{
        "engine_newPayload",
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

    // Violation must surface as InternalError (bad executor response)
    try std.testing.expectError(EngineApi.Error.InternalError, api.exchange_capabilities(params));
    try std.testing.expect(dummy.called);
}

test "engine api dispatches client version exchange" {
    const alloc = std.testing.allocator;
    var obj = std.json.ObjectMap.init(alloc);
    defer obj.deinit();
    try obj.put("code", .{ .string = "LS" });
    try obj.put("name", .{ .string = "Lodestar" });
    try obj.put("version", .{ .string = "v1.2.3" });
    try obj.put("commit", .{ .string = "0x01020304" });
    const consensus_client = ClientVersionV1{ .value = .{ .object = obj } };
    const params = ClientVersionV1Params{ .consensus_client = consensus_client };

    const dummy_resp_const = try make_dummy_client_version(alloc);
    var dummy_resp = dummy_resp_const;
    defer if (dummy_resp.value == .object) dummy_resp.value.object.deinit();
    const result_value = ClientVersionV1Result{ .value = &[_]ClientVersionV1{dummy_resp_const} };
    const exchange_result = ExchangeCapabilitiesResult{ .value = jsonrpc.types.Quantity{ .value = .{ .null = {} } } };

    var dummy = DummyEngine{ .result = exchange_result, .client_version_result = result_value };
    const api = make_api(&dummy);

    const result = try api.get_client_version_v1(params);
    try std.testing.expect(dummy.client_version_called);
    try std.testing.expectEqualDeep(result_value, result);
}

fn make_transition_config_object(
    allocator: std.mem.Allocator,
    ttd_hex: []const u8,
    hash_hex: []const u8,
    number_hex: []const u8,
) !std.json.ObjectMap {
    var obj = std.json.ObjectMap.init(allocator);
    try obj.put("terminalTotalDifficulty", .{ .string = ttd_hex });
    try obj.put("terminalBlockHash", .{ .string = hash_hex });
    try obj.put("terminalBlockNumber", .{ .string = number_hex });
    return obj;
}

test "engine api dispatches exchangeTransitionConfigurationV1" {
    const allocator = std.testing.allocator;
    var obj = try make_transition_config_object(
        allocator,
        "0x0",
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x1",
    );
    defer obj.deinit();

    const params = ExchangeTransitionConfigurationV1Params{
        .consensus_client_configuration = jsonrpc.types.Quantity{ .value = .{ .object = obj } },
    };
    var ret_obj = try make_transition_config_object(
        allocator,
        "0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc00",
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x0",
    );
    defer ret_obj.deinit();
    const result_value = ExchangeTransitionConfigurationV1Result{
        .value = jsonrpc.types.Quantity{ .value = .{ .object = ret_obj } },
    };

    const exchange_result = ExchangeCapabilitiesResult{ .value = jsonrpc.types.Quantity{ .value = .{ .null = {} } } };
    var dummy = DummyEngine{ .result = exchange_result, .transition_result = result_value };
    const api = make_api(&dummy);

    const out = try api.exchange_transition_configuration_v1(params);
    try std.testing.expect(dummy.transition_called);
    try std.testing.expectEqualDeep(result_value, out);
}

test "engine api rejects invalid transition config params" {
    const allocator = std.testing.allocator;
    // Missing terminalBlockHash
    var obj = std.json.ObjectMap.init(allocator);
    try obj.put("terminalTotalDifficulty", .{ .string = "0x0" });
    try obj.put("terminalBlockNumber", .{ .string = "0x1" });
    defer obj.deinit();

    const params = ExchangeTransitionConfigurationV1Params{
        .consensus_client_configuration = jsonrpc.types.Quantity{ .value = .{ .object = obj } },
    };

    const exchange_result = ExchangeCapabilitiesResult{ .value = jsonrpc.types.Quantity{ .value = .{ .null = {} } } };
    var dummy = DummyEngine{ .result = exchange_result };
    const api = make_api(&dummy);

    try std.testing.expectError(EngineApi.Error.InvalidParams, api.exchange_transition_configuration_v1(params));
    try std.testing.expect(!dummy.transition_called);
}

test "engine api rejects invalid transition config response" {
    const allocator = std.testing.allocator;
    var good_obj = try make_transition_config_object(
        allocator,
        "0x1",
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x2",
    );
    defer good_obj.deinit();
    const params = ExchangeTransitionConfigurationV1Params{
        .consensus_client_configuration = jsonrpc.types.Quantity{ .value = .{ .object = good_obj } },
    };

    // Invalid response: terminalBlockNumber not a string hex
    var bad_obj = std.json.ObjectMap.init(allocator);
    try bad_obj.put("terminalTotalDifficulty", .{ .string = "0x1" });
    try bad_obj.put("terminalBlockHash", .{ .string = "0x0000000000000000000000000000000000000000000000000000000000000000" });
    try bad_obj.put("terminalBlockNumber", .{ .float = 3.14 });
    defer bad_obj.deinit();
    const bad_result = ExchangeTransitionConfigurationV1Result{
        .value = jsonrpc.types.Quantity{ .value = .{ .object = bad_obj } },
    };

    const exchange_result = ExchangeCapabilitiesResult{ .value = jsonrpc.types.Quantity{ .value = .{ .null = {} } } };
    var dummy = DummyEngine{ .result = exchange_result, .transition_result = bad_result };
    const api = make_api(&dummy);

    try std.testing.expectError(EngineApi.Error.InternalError, api.exchange_transition_configuration_v1(params));
    try std.testing.expect(dummy.transition_called);
}

test "engine api generic dispatcher routes exchangeCapabilities" {
    const allocator = std.testing.allocator;

    var consensus_payload = try make_methods_payload(ConsensusType, allocator, &[_][]const u8{
        "engine_newPayloadV1",
    });
    defer deinit_methods_payload(&consensus_payload);

    var result_payload = try make_methods_payload(ResultType, allocator, &[_][]const u8{
        "engine_newPayloadV1",
    });
    defer deinit_methods_payload(&result_payload);

    const params = ExchangeCapabilitiesParams{ .consensus_client_methods = consensus_payload.value };
    const result_value = ExchangeCapabilitiesResult{ .value = result_payload.value };

    var dummy = DummyEngine{ .result = result_value };
    const api = make_api(&dummy);

    const out = try api.dispatch(ExchangeCapabilitiesMethod, params);
    try std.testing.expectEqualDeep(result_value, out);
}

// Note: generic dispatcher does not route non-Voltaire-declared methods like
// engine_getClientVersionV1. That method is invoked directly via the vtable.

test "engine api generic dispatcher routes exchangeTransitionConfigurationV1" {
    const allocator = std.testing.allocator;
    var obj = try make_transition_config_object(
        allocator,
        "0x0",
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x1",
    );
    defer obj.deinit();

    const params = ExchangeTransitionConfigurationV1Params{
        .consensus_client_configuration = jsonrpc.types.Quantity{ .value = .{ .object = obj } },
    };

    var ret_obj = try make_transition_config_object(
        allocator,
        "0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc00",
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x0",
    );
    defer ret_obj.deinit();
    const result_value = ExchangeTransitionConfigurationV1Result{
        .value = jsonrpc.types.Quantity{ .value = .{ .object = ret_obj } },
    };

    const exchange_result = ExchangeCapabilitiesResult{ .value = jsonrpc.types.Quantity{ .value = .{ .null = {} } } };
    var dummy = DummyEngine{ .result = exchange_result, .transition_result = result_value };
    const api = make_api(&dummy);

    const out = try api.dispatch(ExchangeTransitionConfigurationV1Method, params);
    try std.testing.expectEqualDeep(result_value, out);
}

test "engine api generic dispatcher rejects unknown method" {
    const GetPayloadV1 = @FieldType(jsonrpc.engine.EngineMethod, "engine_getPayloadV1");
    const GetPayloadV1Params = @FieldType(GetPayloadV1, "params");
    const params = GetPayloadV1Params{ .payload_id = jsonrpc.types.Quantity{ .value = .{ .string = "0x01" } } };
    const exchange_result = ExchangeCapabilitiesResult{ .value = jsonrpc.types.Quantity{ .value = .{ .null = {} } } };

    var dummy = DummyEngine{ .result = exchange_result };
    const api = make_api(&dummy);

    try std.testing.expectError(EngineApi.Error.MethodNotFound, api.dispatch(GetPayloadV1, params));
}

test "engine api rejects invalid client version params" {
    const alloc = std.testing.allocator;
    var obj = std.json.ObjectMap.init(alloc);
    defer obj.deinit();
    try obj.put("code", .{ .string = "BAD" });
    try obj.put("name", .{ .string = "Lodestar" });
    try obj.put("version", .{ .string = "v1.2.3" });
    try obj.put("commit", .{ .string = "0x01020304" });
    const consensus_client = ClientVersionV1{ .value = .{ .object = obj } };
    const bad_params = ClientVersionV1Params{ .consensus_client = consensus_client };
    const exchange_result = ExchangeCapabilitiesResult{
        .value = jsonrpc.types.Quantity{ .value = .{ .null = {} } },
    };

    var dummy = DummyEngine{ .result = exchange_result };
    const api = make_api(&dummy);

    try std.testing.expectError(EngineApi.Error.InvalidParams, api.get_client_version_v1(bad_params));
    try std.testing.expect(!dummy.client_version_called);
}

test "engine api rejects client version params with invalid commit length" {
    const alloc = std.testing.allocator;
    var obj = std.json.ObjectMap.init(alloc);
    defer obj.deinit();
    try obj.put("code", .{ .string = "LS" });
    try obj.put("name", .{ .string = "Lodestar" });
    try obj.put("version", .{ .string = "v1.2.3" });
    try obj.put("commit", .{ .string = "0x010203" });
    const consensus_client = ClientVersionV1{ .value = .{ .object = obj } };
    const bad_params = ClientVersionV1Params{ .consensus_client = consensus_client };
    const exchange_result = ExchangeCapabilitiesResult{
        .value = jsonrpc.types.Quantity{ .value = .{ .null = {} } },
    };

    var dummy = DummyEngine{ .result = exchange_result };
    const api = make_api(&dummy);

    try std.testing.expectError(EngineApi.Error.InvalidParams, api.get_client_version_v1(bad_params));
    try std.testing.expect(!dummy.client_version_called);
}

test "engine api rejects client version response with invalid commit format" {
    const alloc = std.testing.allocator;
    const dummy_client_version_const = try make_dummy_client_version(alloc);
    var dummy_client_version = dummy_client_version_const;
    defer if (dummy_client_version.value == .object) dummy_client_version.value.object.deinit();
    const params = ClientVersionV1Params{ .consensus_client = dummy_client_version_const };
    var bad = std.json.ObjectMap.init(alloc);
    defer bad.deinit();
    try bad.put("code", .{ .string = "LS" });
    try bad.put("name", .{ .string = "Lodestar" });
    try bad.put("version", .{ .string = "v1.2.3" });
    try bad.put("commit", .{ .string = "01020304" });
    const bad_cv = ClientVersionV1{ .value = .{ .object = bad } };
    const invalid_result = ClientVersionV1Result{ .value = &[_]ClientVersionV1{bad_cv} };
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

test "engine api rejects invalid client version response" {
    const alloc = std.testing.allocator;
    const dummy_client_version_const = try make_dummy_client_version(alloc);
    var dummy_client_version = dummy_client_version_const;
    defer if (dummy_client_version.value == .object) dummy_client_version.value.object.deinit();
    const params = ClientVersionV1Params{ .consensus_client = dummy_client_version_const };
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
