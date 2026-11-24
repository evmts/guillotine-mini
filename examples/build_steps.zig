const std = @import("std");

pub fn registerExamples(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    guillotine_mod: *std.Build.Module,
    primitives_mod: *std.Build.Module,
) void {
    const all = b.step("run-examples", "Run all Zig examples");
    const examples = [_]struct { name: []const u8, source: []const u8 }{
        .{ .name = "simple-call", .source = "examples/simple_call.zig" },
        .{ .name = "access-list", .source = "examples/access_list.zig" },
        .{ .name = "precompiles", .source = "examples/precompiles.zig" },
        .{ .name = "tracing", .source = "examples/tracing.zig" },
        .{ .name = "transient-storage", .source = "examples/transient_storage.zig" },
        .{ .name = "hardfork-features", .source = "examples/hardfork_features.zig" },
    };
    for (examples) |example| {
        const exe = b.addExecutable(.{
            .name = example.name,
            .root_module = b.createModule(.{
                .root_source_file = b.path(example.source),
                .target = target,
                .optimize = optimize,
                .imports = &.{
                    .{ .name = "guillotine_mini", .module = guillotine_mod },
                    .{ .name = "voltaire", .module = primitives_mod },
                },
            }),
        });
        switch (target.result.os.tag) {
            .linux => exe.root_module.linkSystemLibrary("gcc_s", .{}),
            .windows => if (target.result.abi.isGnu()) exe.root_module.linkSystemLibrary("gcc_eh", .{}),
            else => {},
        }
        const run = b.addRunArtifact(exe);
        if (std.mem.eql(u8, example.name, "tracing")) {
            if (b.args) |args| run.addArgs(args);
        }
        const step = b.step(b.fmt("run-example-{s}", .{example.name}), b.fmt("Run the {s} example", .{example.name}));
        step.dependOn(&run.step);
        all.dependOn(&run.step);
    }
}
