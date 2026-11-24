//! Build wiring for the Lean 4 differential fuzz suite.
//!
//! Integrate from build.zig with one line after `mod` and `primitives_mod` exist:
//!
//!     @import("test/differential/build_steps.zig").registerLeanDiff(b, target, optimize, mod, primitives_mod);
//!
//! Steps:
//!   zig build lean-diff        build spec/lean (when present), then run >= 10,000 vectors
//!   zig build lean-diff-unit   harness unit tests + leak-checked Zig-only smoke (no Lean needed)
//! Options:
//!   LEAN_DIFF_REQUIRE=0        allow `lean-diff` to SKIP when the oracle binary is missing (default: fail)
//!   -Dlean-diff-lake=false     skip `lake build` in spec/lean (use a prebuilt LEAN_SPEC_BIN)
//! Arguments after `--` reach the harness, e.g. `zig build lean-diff -- --seed=7 --scale=4`.
const std = @import("std");

pub const harness_path = "test/differential/lean_diff_fuzz.zig";
pub const oracle_rel_path = "spec/lean/.lake/build/bin/evm-lean-spec";

pub fn registerLeanDiff(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    guillotine_mod: *std.Build.Module,
    primitives_mod: *std.Build.Module,
) void {
    const exe = b.addExecutable(.{
        .name = "lean-diff-fuzz",
        .root_module = harnessModule(b, target, optimize, guillotine_mod, primitives_mod),
    });
    linkRustSupport(exe, target);

    const run = b.addRunArtifact(exe);
    run.has_side_effects = true;
    run.addArg(b.pathFromRoot(oracle_rel_path));
    if (b.args) |args| run.addArgs(args);
    // A missing oracle fails the step instead of exiting 0 with a SKIP. Set
    // LEAN_DIFF_REQUIRE=0 in the environment to opt back into skipping.
    if (std.process.getEnvVarOwned(b.allocator, "LEAN_DIFF_REQUIRE")) |_| {} else |_| {
        run.setEnvironmentVariable("LEAN_DIFF_REQUIRE", "1");
    }

    const has_lean_project = pathExists(b, "spec/lean/lakefile.lean") or pathExists(b, "spec/lean/lakefile.toml");
    const lake = b.option(bool, "lean-diff-lake", "Run `lake build` in spec/lean before lean-diff (default: when spec/lean exists)") orelse has_lean_project;
    if (lake and has_lean_project) {
        const lake_build = b.addSystemCommand(&.{ "lake", "build" });
        lake_build.setCwd(b.path("spec/lean"));
        lake_build.has_side_effects = true;
        run.step.dependOn(&lake_build.step);
    }

    const step = b.step("lean-diff", "Differential fuzz guillotine-mini against the Lean 4 reference spec");
    step.dependOn(&run.step);

    const unit = b.addTest(.{
        .name = "lean-diff-unit",
        .root_module = harnessModule(b, target, optimize, guillotine_mod, primitives_mod),
    });
    linkRustSupport(unit, target);
    const unit_step = b.step("lean-diff-unit", "Lean differential harness unit tests (no Lean oracle required)");
    unit_step.dependOn(&b.addRunArtifact(unit).step);
}

fn harnessModule(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    guillotine_mod: *std.Build.Module,
    primitives_mod: *std.Build.Module,
) *std.Build.Module {
    return b.createModule(.{
        .root_source_file = b.path(harness_path),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "guillotine_mini", .module = guillotine_mod },
            .{ .name = "voltaire", .module = primitives_mod },
        },
    });
}

/// Voltaire's Rust crypto archives need the unwinder on Linux (and Windows GNU).
fn linkRustSupport(compile: *std.Build.Step.Compile, target: std.Build.ResolvedTarget) void {
    switch (target.result.os.tag) {
        .linux => compile.root_module.linkSystemLibrary("gcc_s", .{}),
        .windows => if (target.result.abi.isGnu()) compile.root_module.linkSystemLibrary("gcc_eh", .{}),
        else => {},
    }
}

fn pathExists(b: *std.Build, sub_path: []const u8) bool {
    b.build_root.handle.access(sub_path, .{}) catch return false;
    return true;
}
