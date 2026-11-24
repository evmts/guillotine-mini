const std = @import("std");
const examples = std.meta.declarations(@import("catalog.zig"));

pub fn addRunSteps(b: *std.Build, exe: *std.Build.Step.Compile) void {
    const cli = b.addRunArtifact(exe);
    if (b.args) |args| cli.addArgs(args);
    b.step("run-example", "List examples or run one by name").dependOn(&cli.step);

    inline for (examples) |example| {
        const name = example.name;
        const run = b.addRunArtifact(exe);
        run.addArg(name);
        b.step("run-" ++ name, "Run the " ++ name ++ " example").dependOn(&run.step);
    }
}
