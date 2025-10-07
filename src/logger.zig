const std = @import("std");
const builtin = @import("builtin");

const is_wasm = builtin.target.cpu.arch == .wasm32 or builtin.target.cpu.arch == .wasm64;

pub fn print(comptime fmt: []const u8, args: anytype) void {
    if (!is_wasm) {
        std.debug.print(fmt, args);
    }
}

pub fn warn(comptime fmt: []const u8, args: anytype) void {
    if (!is_wasm) {
        std.log.warn(fmt, args);
    }
}

pub fn err(comptime fmt: []const u8, args: anytype) void {
    if (!is_wasm) {
        std.log.err(fmt, args);
    }
}

pub fn info(comptime fmt: []const u8, args: anytype) void {
    if (!is_wasm) {
        std.log.info(fmt, args);
    }
}

pub fn debug(comptime fmt: []const u8, args: anytype) void {
    if (!is_wasm) {
        std.log.debug(fmt, args);
    }
}
