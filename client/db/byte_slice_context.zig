/// Byte-slice hashing/equality context for DB hash maps.
///
/// Shared by DB backends that store raw byte slice keys in hash maps.
const std = @import("std");
const primitives = @import("primitives");
const Bytes = primitives.Bytes;

/// Hash/equality context for byte slices.
pub const ByteSliceContext = struct {
    /// Hash a byte slice using Wyhash.
    pub fn hash(_: ByteSliceContext, key: []const u8) u64 {
        return std.hash.Wyhash.hash(0, key);
    }

    /// Compare byte slices for equality using Voltaire Bytes.
    pub fn eql(_: ByteSliceContext, a: []const u8, b: []const u8) bool {
        return Bytes.equals(a, b);
    }
};
