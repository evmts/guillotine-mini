const std = @import("std");
const catalog = @import("catalog.zig");
const examples = std.meta.declarations(catalog);

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var buffer: [4096]u8 = undefined;
    var stdout = std.fs.File.stdout().writer(&buffer);
    const out = &stdout.interface;
    if (args.len == 1 or (args.len == 2 and std.mem.eql(u8, args[1], "--help"))) {
        try out.writeAll("Usage: zig build run-example -- <name>\n");
        inline for (examples) |example| try out.writeAll("  " ++ example.name ++ "\n");
    } else if (args.len == 2) {
        inline for (examples) |example| {
            if (std.mem.eql(u8, args[1], example.name)) {
                try @field(catalog, example.name).run(allocator, out);
                return out.flush();
            }
        }
        std.log.err("unknown example '{s}'; list examples with zig build run-example", .{args[1]});
        return error.UnknownExample;
    } else {
        std.log.err("usage: zig build run-example -- <name>", .{});
        return error.InvalidArguments;
    }
    try out.flush();
}
