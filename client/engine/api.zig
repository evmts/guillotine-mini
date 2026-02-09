/// Engine API interface for consensus layer communication.
///
/// Mirrors Nethermind's IEngineRpcModule capability exchange surface and
/// follows the vtable-based dependency injection pattern used in src/host.zig.
const std = @import("std");
const primitives = @import("primitives");
const crypto = @import("crypto");

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
        /// Number of requested entities is too large.
        TooLargeRequest,
        /// Invalid or inconsistent parameters provided by the caller.
        InvalidParams,
        /// Internal execution layer failure.
        InternalError,
        /// Allocation failure.
        OutOfMemory,
    };

    /// Virtual function table for Engine API operations.
    pub const VTable = struct {
        /// Exchange list of supported Engine API methods.
        exchange_capabilities: *const fn (
            ptr: *anyopaque,
            consensus_methods: []const []const u8,
        ) Error![]const []const u8,
    };

    /// Exchange list of supported Engine API methods.
    pub fn exchange_capabilities(
        self: EngineApi,
        consensus_methods: []const []const u8,
    ) Error![]const []const u8 {
        return self.vtable.exchange_capabilities(self.ptr, consensus_methods);
    }
};

// ============================================================================
// Tests
// ============================================================================

test "engine api dispatches capabilities exchange" {
    const DummyEngine = struct {
        const Self = @This();
        result: []const []const u8,
        seen_len: usize = 0,

        fn exchange_capabilities(
            ptr: *anyopaque,
            consensus_methods: []const []const u8,
        ) EngineApi.Error![]const []const u8 {
            const self: *Self = @ptrCast(@alignCast(ptr));
            self.seen_len = consensus_methods.len;
            return self.result;
        }
    };

    const consensus = [_][]const u8{ "engine_newPayloadV1", "engine_forkchoiceUpdatedV1" };
    const execution = [_][]const u8{"engine_newPayloadV1"};

    var dummy = DummyEngine{ .result = execution[0..] };
    const vtable = EngineApi.VTable{ .exchange_capabilities = DummyEngine.exchange_capabilities };
    const api = EngineApi{ .ptr = &dummy, .vtable = &vtable };

    const result = try api.exchange_capabilities(consensus[0..]);
    try std.testing.expectEqual(@as(usize, 2), dummy.seen_len);
    try std.testing.expectEqual(@as(usize, 1), result.len);
    try std.testing.expectEqualStrings("engine_newPayloadV1", result[0]);
}
