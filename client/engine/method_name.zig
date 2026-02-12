/// Engine method name utilities shared by Engine API handlers.
///
/// Rules (execution-apis/engine):
/// - Must be in the `engine_` namespace
/// - Must be versioned with a trailing `V<digits>` (e.g., V1..V6)
/// - Must NOT advertise `engine_exchangeCapabilities`
const std = @import("std");

/// Return true iff `name` is an advertisable Engine API method name per spec.
pub fn isValidAdvertisableEngineMethodName(name: []const u8) bool {
    if (!std.mem.startsWith(u8, name, "engine_")) return false;
    if (std.mem.eql(u8, name, "engine_exchangeCapabilities")) return false;
    return hasVersionSuffix(name);
}

/// Return true iff `name` belongs to the `engine_` namespace and carries a
/// trailing `V<digits>` suffix. Unlike
/// `isValidAdvertisableEngineMethodName`, this does not special-case
/// `engine_exchangeCapabilities`. Use for validating consensus requests.
pub fn isEngineVersionedMethodName(name: []const u8) bool {
    if (!std.mem.startsWith(u8, name, "engine_")) return false;
    return hasVersionSuffix(name);
}

/// Check for a trailing `V<digits>` suffix.
fn hasVersionSuffix(name: []const u8) bool {
    if (name.len < 2) return false;

    var i: usize = name.len;
    while (i > 0 and std.ascii.isDigit(name[i - 1])) i -= 1;
    if (i == name.len or i == 0) return false;
    return name[i - 1] == 'V';
}

// ==================
// Tests
// ==================

test "isValidAdvertisableEngineMethodName - valid" {
    try std.testing.expect(isValidAdvertisableEngineMethodName("engine_newPayloadV1"));
    try std.testing.expect(isValidAdvertisableEngineMethodName("engine_getPayloadV6"));
    try std.testing.expect(isValidAdvertisableEngineMethodName("engine_forkchoiceUpdatedV3"));
}

test "isValidAdvertisableEngineMethodName - rejects unversioned or wrong ns" {
    try std.testing.expect(!isValidAdvertisableEngineMethodName("engine_newPayload"));
    try std.testing.expect(!isValidAdvertisableEngineMethodName("eth_getBlockByNumberV1"));
}

test "isValidAdvertisableEngineMethodName - rejects exchangeCapabilities" {
    try std.testing.expect(!isValidAdvertisableEngineMethodName("engine_exchangeCapabilities"));
}

test "isEngineVersionedMethodName - basic" {
    try std.testing.expect(isEngineVersionedMethodName("engine_newPayloadV1"));
    try std.testing.expect(isEngineVersionedMethodName("engine_getPayloadV6"));
    try std.testing.expect(!isEngineVersionedMethodName("engine_newPayload"));
    try std.testing.expect(!isEngineVersionedMethodName("eth_getBlockByNumberV1"));
    try std.testing.expect(!isEngineVersionedMethodName("engine_exchangeCapabilities"));
}
