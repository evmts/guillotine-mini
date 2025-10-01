const std = @import("std");
const guillotine_mini = @import("guillotine_mini");

pub fn main() !void {
    std.debug.print("Guillotine Mini EVM v0.1.0\n", .{});
    std.debug.print("Mini EVM implementation extracted from guillotine\n", .{});
}

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa);
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
