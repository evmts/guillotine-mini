// Zig's numeric error IDs are local to each linked module.
const Error = @import("builtins").PrecompileError;

const errors = [_]Error{
    error.NotImplemented, error.OutOfGas,       error.InvalidInput,     error.OutOfMemory,
    error.InvalidPoint,   error.InvalidPairing, error.InvalidSignature, error.TrustedSetupNotLoaded,
    error.ExecutionError, error.StateError,     error.MemoryError,      error.InvalidOutputSize,
    error.Unknown,
};

comptime {
    if (errors.len != @typeInfo(Error).error_set.?.len) @compileError("update the WASM precompile error ABI");
}

pub fn encode(err: Error) i32 {
    for (errors, 0..) |value, index| {
        if (value == err) return -1 - @as(i32, @intCast(index));
    }
    unreachable;
}

pub fn decode(code: i32) Error {
    const index: usize = @intCast(-(code + 1));
    return if (index < errors.len) errors[index] else error.Unknown;
}
