const std = @import("std");
const client_trie = @import("client_trie");
const Rlp = @import("primitives").Rlp;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const key_a = [_]u8{
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
        0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
        0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
        0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f,
    };
    const key_b = [_]u8{
        0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27,
        0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f,
        0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
        0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f,
    };

    const value_a_preimage = [_]u8{ 0xde, 0xad, 0xbe, 0xef };
    const value_b_preimage = [_]u8{ 0x01, 0x02, 0x03 };

    const value_a = try Rlp.encodeBytes(allocator, &value_a_preimage);
    defer allocator.free(value_a);
    const value_b = try Rlp.encodeBytes(allocator, &value_b_preimage);
    defer allocator.free(value_b);

    const keys = [_][]const u8{ &key_a, &key_b };
    const values = [_][]const u8{ value_a, value_b };

    const root = try client_trie.trie_root(allocator, &keys, &values);

    const hex = std.fmt.bytesToHex(root, .lower);
    const zig_root = try std.fmt.allocPrint(allocator, "0x{s}", .{hex[0..]});
    defer allocator.free(zig_root);

    const nethermind_root = runNethermind(allocator) catch |err| {
        if (err == error.FileNotFound) {
            std.debug.print("Nethermind diff skipped: dotnet not found\n", .{});
            return;
        }
        return err;
    };
    defer allocator.free(nethermind_root);

    if (!std.ascii.eqlIgnoreCase(zig_root, nethermind_root)) {
        std.debug.print(
            "Nethermind trie diff failed\n  zig: {s}\n  nethermind: {s}\n",
            .{ zig_root, nethermind_root },
        );
        return error.RootMismatch;
    }

    std.debug.print("Nethermind trie diff passed: {s}\n", .{zig_root});
}

fn runNethermind(allocator: std.mem.Allocator) ![]u8 {
    const argv = [_][]const u8{
        "dotnet",
        "run",
        "--project",
        "scripts/nethermind-diff-trie/NethermindTrieDiff.csproj",
        "--configuration",
        "Release",
    };

    var child = std.process.Child.init(&argv, allocator);
    child.stdin_behavior = .Ignore;
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;

    child.spawn() catch |err| {
        if (err == error.FileNotFound) {
            std.debug.print("dotnet not found; install the .NET SDK to run nethermind diff\\n", .{});
        }
        return err;
    };

    const stdout = try child.stdout.?.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(stdout);
    const stderr = try child.stderr.?.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(stderr);

    const term = child.wait() catch |err| {
        if (err == error.FileNotFound) {
            std.debug.print("dotnet not found; install the .NET SDK to run nethermind diff\n", .{});
        }
        return err;
    };
    switch (term) {
        .Exited => |code| if (code != 0) {
            std.debug.print("Nethermind diff process failed ({d}): {s}\n", .{ code, stderr });
            return error.NethermindFailed;
        },
        else => {
            std.debug.print("Nethermind diff process terminated: {any}\n", .{term});
            return error.NethermindFailed;
        },
    }

    return allocator.dupe(u8, std.mem.trim(u8, stdout, " \r\n\t"));
}
