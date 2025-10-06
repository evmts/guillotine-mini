const std = @import("std");

// Although this function looks imperative, it does not perform the build
// directly and instead it mutates the build graph (`b`) that will be then
// executed by an external runner. The functions in `std.Build` implement a DSL
// for defining build steps and express dependencies between them, allowing the
// build runner to parallelize the build automatically (and the cache system to
// know when a step doesn't need to be re-run).
pub fn build(b: *std.Build) void {
    // Standard target options allow the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});
    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});
    // It's also possible to define more custom flags to toggle optional features
    // of this build script using `b.option()`. All defined flags (including
    // target and optimize options) will be listed when running `zig build --help`
    // in this directory.

    // Create the primitives module first, as it's a dependency
    const primitives_mod = b.addModule("primitives", .{
        .root_source_file = b.path("src/primitives/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // This creates a module, which represents a collection of source files alongside
    // some compilation options, such as optimization mode and linked system libraries.
    // Zig modules are the preferred way of making Zig code available to consumers.
    // addModule defines a module that we intend to make available for importing
    // to our consumers. We must give it a name because a Zig package can expose
    // multiple modules and consumers will need to be able to specify which
    // module they want to access.
    const mod = b.addModule("guillotine_mini", .{
        // The root source file is the "entry point" of this module. Users of
        // this module will only be able to access public declarations contained
        // in this file, which means that if you have declarations that you
        // intend to expose to consumers that were defined in other files part
        // of this module, you will have to make sure to re-export them from
        // the root file.
        .root_source_file = b.path("src/root.zig"),
        // Later on we'll use this module as the root module of a test executable
        // which requires us to specify a target.
        .target = target,
        .imports = &.{
            .{ .name = "primitives", .module = primitives_mod },
        },
    });

    // Here we define an executable. An executable needs to have a root module
    // which needs to expose a `main` function. While we could add a main function
    // to the module defined above, it's sometimes preferable to split business
    // business logic and the CLI into two separate modules.
    //
    // If your goal is to create a Zig library for others to use, consider if
    // it might benefit from also exposing a CLI tool. A parser library for a
    // data serialization format could also bundle a CLI syntax checker, for example.
    //
    // If instead your goal is to create an executable, consider if users might
    // be interested in also being able to embed the core functionality of your
    // program in their own executable in order to avoid the overhead involved in
    // subprocessing your CLI tool.
    //
    // Main executable removed - this is a library-only package

    // Creates an executable that will run `test` blocks from the provided module.
    // Here `mod` needs to define a target, which is why earlier we made sure to
    // set the releative field.
    const mod_tests = b.addTest(.{
        .root_module = mod,
    });

    // A run step that will run the test executable.
    const run_mod_tests = b.addRunArtifact(mod_tests);

    // A top level step for running all tests
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);

    // Create EVM module for spec tests
    const evm_mod = b.addModule("evm", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "primitives", .module = primitives_mod },
        },
    });

    // Add execution-specs tests
    // Build option to force refreshing the generated Python fixtures
    const refresh_specs_opt = b.option(bool, "refresh-specs", "Force refresh of execution-specs fixtures");
    const force_refresh = refresh_specs_opt orelse false;

    // First, add a build step to generate test fixtures using Python fill command
    const fill_specs = if (force_refresh)
        b.addSystemCommand(&.{
            "sh",
            "-c",
            // Force refresh: always run fill (with --clean) for all deployed forks
            "cd /Users/williamcory/guillotine-mini/execution-specs && "
            ++ "uv run --extra fill --extra test fill tests/eest --output tests/eest/static/state_tests --clean",
        })
    else
        b.addSystemCommand(&.{
            "sh",
            "-c",
            // No-op only if all fork fixtures are present; otherwise fill all
            "ROOT=/Users/williamcory/guillotine-mini/execution-specs; "
            ++ "SRC=\"$ROOT/tests/eest\"; OUT=\"$ROOT/tests/eest/static/state_tests\"; "
            ++ "if [ ! -d \"$OUT\" ]; then NEEDS=1; else NEEDS=0; fi; "
            ++ "FORKS=$(ls -1 \"$SRC\" | grep -Ev '^(static|benchmark|unscheduled|__|\\.)'); "
            ++ "for f in $FORKS; do "
            ++ "  if [ $NEEDS -eq 1 ]; then break; fi; "
            ++ "  if ! (find \"$OUT/state_tests/eest/$f\" -type f -name '*.json' -print -quit 2>/dev/null | grep -q . ";
            ++ "     || find \"$OUT/blockchain_tests/eest/$f\" -type f -name '*.json' -print -quit 2>/dev/null | grep -q . ";
            ++ "     || find \"$OUT/blockchain_tests_engine/eest/$f\" -type f -name '*.json' -print -quit 2>/dev/null | grep -q .); then "
            ++ "    NEEDS=1; fi; "
            ++ "done; "
            ++ "if [ $NEEDS -eq 0 ]; then echo 'All fork fixtures present, skipping fill'; "
            ++ "else cd \"$ROOT\" && uv run --extra fill --extra test fill tests/eest --output tests/eest/static/state_tests --clean; fi",
        });

    const spec_runner_mod = b.addModule("spec_runner", .{
        .root_source_file = b.path("test/specs/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "evm", .module = evm_mod },
            .{ .name = "primitives", .module = primitives_mod },
        },
    });

    const spec_tests = b.addTest(.{
        .root_module = spec_runner_mod,
    });

    // Set log level to error only (suppress debug output from tests)
    const log_options = b.addOptions();
    log_options.addOption(std.log.Level, "log_level", .err);
    spec_tests.root_module.addOptions("build_options", log_options);

    const run_spec_tests = b.addRunArtifact(spec_tests);
    run_spec_tests.setCwd(b.path(".")); // Set working directory to project root for test file paths

    // Make spec tests depend on filling the fixtures first
    run_spec_tests.step.dependOn(&fill_specs.step);

    const spec_test_step = b.step("specs", "Run execution-specs tests");
    spec_test_step.dependOn(&run_spec_tests.step);

    // Add spec tests to main test step
    test_step.dependOn(&run_spec_tests.step);

    // Add trace test executable
    const trace_test_mod = b.addModule("trace_test_mod", .{
        .root_source_file = b.path("test_trace.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "guillotine", .module = mod },
            .{ .name = "primitives", .module = primitives_mod },
        },
    });

    const trace_test = b.addExecutable(.{
        .name = "trace_test",
        .root_module = trace_test_mod,
    });

    const run_trace_test = b.addRunArtifact(trace_test);
    const trace_test_step = b.step("test-trace", "Run trace capture test");
    trace_test_step.dependOn(&run_trace_test.step);

    // Interactive test runner
    const interactive_spec_tests = b.addTest(.{
        .root_module = spec_runner_mod,
        .test_runner = .{
            .path = b.path("interactive_test_runner.zig"),
            .mode = .simple,
        },
    });

    // Set log level to error only (suppress debug output from tests)
    interactive_spec_tests.root_module.addOptions("build_options", log_options);

    const run_interactive_tests = b.addRunArtifact(interactive_spec_tests);
    run_interactive_tests.setCwd(b.path(".")); // Set working directory to project root for test file paths
    const interactive_test_step = b.step("test-watch", "Run interactive test runner");
    interactive_test_step.dependOn(&run_interactive_tests.step);

    // WASM build target with ReleaseSmall optimization
    const wasm_target = b.resolveTargetQuery(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
    });

    // Create WASM module with primitives dependency
    const wasm_mod = b.addModule("guillotine_mini_wasm", .{
        .root_source_file = b.path("src/root_c.zig"),
        .target = wasm_target,
        .optimize = .ReleaseSmall,
        .imports = &.{
            .{ .name = "primitives", .module = primitives_mod },
        },
    });

    const wasm_lib = b.addExecutable(.{
        .name = "guillotine_mini",
        .root_module = wasm_mod,
    });
    wasm_lib.entry = .disabled;
    wasm_lib.export_table = true;

    // Export all functions starting with evm_
    wasm_lib.root_module.export_symbol_names = &.{
        "evm_create",
        "evm_destroy",
        "evm_set_bytecode",
        "evm_set_execution_context",
        "evm_set_blockchain_context",
        "evm_execute",
        "evm_get_gas_remaining",
        "evm_get_gas_used",
        "evm_is_success",
        "evm_get_output_len",
        "evm_get_output",
        "evm_set_storage",
        "evm_get_storage",
        "evm_set_balance",
        "evm_set_code",
    };

    const wasm_install = b.addInstallArtifact(wasm_lib, .{});

    // Add step to log WASM size
    const wasm_size_step = b.addSystemCommand(&.{
        "sh",
        "-c",
        "ls -lh zig-out/bin/guillotine_mini.wasm | awk '{print \"WASM build size: \" $5}'",
    });
    wasm_size_step.step.dependOn(&wasm_install.step);

    const wasm_step = b.step("wasm", "Build WASM library and show bundle size");
    wasm_step.dependOn(&wasm_size_step.step);

    // Make WASM build part of default install step
    b.getInstallStep().dependOn(&wasm_install.step);

    // Just like flags, top level steps are also listed in the `--help` menu.
    //
    // The Zig build system is entirely implemented in userland, which means
    // that it cannot hook into private compiler APIs. All compilation work
    // orchestrated by the build system will result in other Zig compiler
    // subcommands being invoked with the right flags defined. You can observe
    // these invocations when one fails (or you pass a flag to increase
    // verbosity) to validate assumptions and diagnose problems.
    //
    // Lastly, the Zig build system is relatively simple and self-contained,
    // and reading its source code will allow you to master it.
}
