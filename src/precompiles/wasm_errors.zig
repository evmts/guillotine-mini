// Zig's numeric error IDs are local to each linked module.
const Error = @import("builtins").PrecompileError;

const errors = [_]Error{
    Error.NotImplemented, Error.OutOfGas,       Error.InvalidInput,     Error.OutOfMemory,
    Error.InvalidPoint,   Error.InvalidPairing, Error.InvalidSignature, Error.TrustedSetupNotLoaded,
    Error.ExecutionError, Error.StateError,     Error.MemoryError,      Error.InvalidOutputSize,
    Error.Unknown,
};

comptime {
    if (errors.len != @typeInfo(Error).error_set.?.len) {
        @compileError("update the WASM precompile error ABI");
    }
    for (errors, 0..) |err, idx| {
        if (encode(err) != -1 - @as(i32, @intCast(idx))) {
            @compileError("WASM precompile error encode/decode mismatch");
        }
    }
}

pub fn encode(err: Error) i32 {
    return switch (err) {
        Error.NotImplemented => -1,
        Error.OutOfGas => -2,
        Error.InvalidInput => -3,
        Error.OutOfMemory => -4,
        Error.InvalidPoint => -5,
        Error.InvalidPairing => -6,
        Error.InvalidSignature => -7,
        Error.TrustedSetupNotLoaded => -8,
        Error.ExecutionError => -9,
        Error.StateError => -10,
        Error.MemoryError => -11,
        Error.InvalidOutputSize => -12,
        Error.Unknown => -13,
    };
}

pub fn decode(code: i32) Error {
    if (code >= 0) return Error.Unknown;
    const index: usize = @intCast(-(code + 1));
    return if (index < errors.len) errors[index] else Error.Unknown;
}
