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

    // Get the primitives dependency - it handles all crypto lib building internally
    const primitives_dep = b.dependency("voltaire", .{
        .target = target,
        .optimize = optimize,
    });

    // Use primitives package exported modules (pre-configured with all C libs, include paths, etc.)
    const primitives_mod = primitives_dep.module("primitives");
    const crypto_mod = primitives_dep.module("crypto");
    const precompiles_mod = primitives_dep.module("precompiles");
    const evm_options = b.addOptions();
    evm_options.addOption(?[]const u8, "hardfork", b.option([]const u8, "hardfork", "Default EVM hardfork"));
    evm_options.addOption(?u16, "max_call_depth", b.option(u16, "max-call-depth", "EVM message call depth limit"));
    evm_options.addOption(?u12, "stack_size", b.option(u12, "stack-size", "EVM stack size limit"));
    evm_options.addOption(?u32, "max_bytecode_size", b.option(u32, "max-bytecode-size", "EVM deployed bytecode size limit"));
    evm_options.addOption(?u32, "max_initcode_size", b.option(u32, "max-initcode-size", "EVM initcode size limit"));
    evm_options.addOption(?u64, "block_gas_limit", b.option(u64, "block-gas-limit", "Default EVM block gas limit"));
    evm_options.addOption(?usize, "memory_initial_capacity", b.option(usize, "memory-initial-capacity", "EVM initial memory capacity"));
    evm_options.addOption(?u64, "memory_limit", b.option(u64, "memory-limit", "EVM memory size limit"));
    const evm_options_mod = evm_options.createModule();

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
        .optimize = optimize,
        .imports = &.{
            .{ .name = "build_options", .module = evm_options_mod },
            .{ .name = "voltaire", .module = primitives_mod },
            .{ .name = "precompiles", .module = precompiles_mod },
            .{ .name = "crypto", .module = crypto_mod },
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
    // set the relative field.
    const mod_tests = b.addTest(.{
        .root_module = mod,
    });
    linkRustSupport(mod_tests);

    // A run step that will run the test executable.
    const run_mod_tests = b.addRunArtifact(mod_tests);

    // Run native tests and opt in to external differential and spec suites.
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);

    // Unit tests only (fast, no spec tests)
    const unit_test_step = b.step("unit", "Run unit tests only (fast)");
    unit_test_step.dependOn(&run_mod_tests.step);

    const utils_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("test/utils.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_utils_tests = b.addRunArtifact(utils_tests);
    const utils_test_step = b.step("test-utils", "Run test runner utility tests");
    utils_test_step.dependOn(&run_utils_tests.step);
    unit_test_step.dependOn(utils_test_step);
    test_step.dependOn(utils_test_step);

    // Keep the public "evm" name as an alias so both imports share the same types.
    b.modules.put("evm", mod) catch @panic("OOM");

    const examples = b.addExecutable(.{
        .name = "guillotine-examples",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "guillotine_mini", .module = mod },
                .{ .name = "voltaire", .module = primitives_mod },
            },
        }),
    });
    linkRustSupport(examples);
    @import("examples/build.zig").addRunSteps(b, examples);
    b.step("examples", "Compile the Zig examples").dependOn(&examples.step);
    const run_examples = b.step("run-examples", "Run all Zig examples");
    const example_catalog = comptime std.meta.declarations(@import("examples/catalog.zig"));
    inline for (example_catalog) |example| {
        const run_step = &b.top_level_steps.get("run-" ++ example.name).?.step;
        run_examples.dependOn(run_step);
        b.step("run-example-" ++ example.name, "Run the " ++ example.name ++ " example").dependOn(run_step);
    }
    @import("test/differential/build_steps.zig").registerLeanDiff(b, target, optimize, mod, primitives_mod);

    const osaka_properties = b.addTest(.{
        .name = "osaka-properties",
        .root_module = b.createModule(.{
            .root_source_file = b.path("test/osaka_property_fuzz_test.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "evm", .module = mod },
                .{ .name = "voltaire", .module = primitives_mod },
            },
        }),
    });
    linkRustSupport(osaka_properties);
    const run_osaka_properties = b.addRunArtifact(osaka_properties);
    unit_test_step.dependOn(&run_osaka_properties.step);
    test_step.dependOn(&run_osaka_properties.step);
    b.step("test-osaka-properties", "Run Osaka execution and precompile properties").dependOn(&run_osaka_properties.step);

    const header_validator_tests = b.addTest(.{
        .name = "header-validator",
        .root_module = b.createModule(.{
            .root_source_file = b.path("test/specs/header_validator.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "voltaire", .module = primitives_mod },
            },
        }),
    });
    linkRustSupport(header_validator_tests);
    const run_header_validator_tests = b.addRunArtifact(header_validator_tests);
    unit_test_step.dependOn(&run_header_validator_tests.step);
    test_step.dependOn(&run_header_validator_tests.step);
    b.step("test-header-validator", "Run PoS/fork block header validation tests").dependOn(&run_header_validator_tests.step);

    const bench_utils_mod = b.addModule("bench_utils", .{
        .root_source_file = b.path("src/bench_utils.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Core EVM benchmarks (bytecode, frame, opcodes, storage, execution, c-ffi)
    const bench_bytecode_mod = b.addModule("bench_bytecode", .{
        .root_source_file = b.path("src/bench_bytecode.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "bench_utils", .module = bench_utils_mod },
        },
    });
    const bench_bytecode_exe = b.addExecutable(.{ .name = "bench_bytecode", .root_module = bench_bytecode_mod });
    const run_bench_bytecode = b.addRunArtifact(bench_bytecode_exe);
    const bench_bytecode_step = b.step("bench-bytecode", "Run EVM bytecode analysis & JUMPDEST benchmarks");
    bench_bytecode_step.dependOn(&run_bench_bytecode.step);

    const bench_frame_mod = b.addModule("bench_frame", .{
        .root_source_file = b.path("src/bench_frame.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "bench_utils", .module = bench_utils_mod },
            .{ .name = "voltaire", .module = primitives_mod },
            .{ .name = "evm", .module = mod },
        },
    });
    const bench_frame_exe = b.addExecutable(.{ .name = "bench_frame", .root_module = bench_frame_mod });
    linkRustSupport(bench_frame_exe);
    const run_bench_frame = b.addRunArtifact(bench_frame_exe);
    const bench_frame_step = b.step("bench-frame", "Run EVM frame, stack, memory & gas benchmarks");
    bench_frame_step.dependOn(&run_bench_frame.step);

    const bench_opcodes_mod = b.addModule("bench_opcodes", .{
        .root_source_file = b.path("src/bench_opcodes.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "bench_utils", .module = bench_utils_mod },
            .{ .name = "voltaire", .module = primitives_mod },
            .{ .name = "evm", .module = mod },
        },
    });
    const bench_opcodes_exe = b.addExecutable(.{ .name = "bench_opcodes", .root_module = bench_opcodes_mod });
    linkRustSupport(bench_opcodes_exe);
    const run_bench_opcodes = b.addRunArtifact(bench_opcodes_exe);
    const bench_opcodes_step = b.step("bench-opcodes", "Run EVM opcode micro-benchmarks");
    bench_opcodes_step.dependOn(&run_bench_opcodes.step);

    const bench_storage_mod = b.addModule("bench_storage", .{
        .root_source_file = b.path("src/bench_storage.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "bench_utils", .module = bench_utils_mod },
            .{ .name = "voltaire", .module = primitives_mod },
            .{ .name = "crypto", .module = crypto_mod },
            .{ .name = "precompiles", .module = precompiles_mod },
        },
    });
    const bench_storage_exe = b.addExecutable(.{ .name = "bench_storage", .root_module = bench_storage_mod });
    linkRustSupport(bench_storage_exe);
    const run_bench_storage = b.addRunArtifact(bench_storage_exe);
    const bench_storage_step = b.step("bench-storage", "Run EVM storage & EIP-2929 access list benchmarks");
    bench_storage_step.dependOn(&run_bench_storage.step);

    const bench_evm_core_mod = b.addModule("bench_evm_core", .{
        .root_source_file = b.path("src/bench_evm.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "bench_utils", .module = bench_utils_mod },
            .{ .name = "voltaire", .module = primitives_mod },
            .{ .name = "evm", .module = mod },
        },
    });
    const bench_evm_core_exe = b.addExecutable(.{ .name = "bench_evm_core", .root_module = bench_evm_core_mod });
    linkRustSupport(bench_evm_core_exe);
    const run_bench_evm_core = b.addRunArtifact(bench_evm_core_exe);
    const bench_evm_core_step = b.step("bench-evm-core", "Run end-to-end EVM contract, precompile & tracer benchmarks");
    bench_evm_core_step.dependOn(&run_bench_evm_core.step);

    const bench_ffi_mod = b.addModule("bench_ffi", .{
        .root_source_file = b.path("src/bench_ffi.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "bench_utils", .module = bench_utils_mod },
            .{ .name = "voltaire", .module = primitives_mod },
            .{ .name = "crypto", .module = crypto_mod },
            .{ .name = "precompiles", .module = precompiles_mod },
        },
    });
    const bench_ffi_exe = b.addExecutable(.{ .name = "bench_ffi", .root_module = bench_ffi_mod });
    linkRustSupport(bench_ffi_exe);
    const run_bench_ffi = b.addRunArtifact(bench_ffi_exe);
    const bench_ffi_step = b.step("bench-ffi", "Run C-FFI / WASM bridge benchmarks");
    bench_ffi_step.dependOn(&run_bench_ffi.step);

    const check_bench_evm_step = b.step("check-bench-evm", "Compile and link EVM benchmarks");
    check_bench_evm_step.dependOn(&bench_evm_core_exe.step);

    // Aggregate Zig benchmark step
    const bench_all_step = b.step("bench", "Run all core EVM Zig benchmarks");
    bench_all_step.dependOn(&run_bench_bytecode.step);
    bench_all_step.dependOn(&run_bench_frame.step);
    bench_all_step.dependOn(&run_bench_opcodes.step);
    bench_all_step.dependOn(&run_bench_storage.step);
    bench_all_step.dependOn(&run_bench_evm_core.step);
    bench_all_step.dependOn(&run_bench_ffi.step);

    const state_fixture_stamp = "execution-specs/tests/eest/static/state_tests/.filled";
    const force_refresh = b.option(bool, "refresh-specs", "Force refresh of execution-specs state fixtures") orelse false;
    const use_existing = b.option(bool, "specs-use-existing", "Run against an already filled, possibly scoped state fixture directory") orelse false;
    const fill_specs = b.addSystemCommand(&.{
        "sh",               "-eu",               "-c",
        \\if [ "$2" = false ] && [ -f "$1" ]; then
        \\    exit 0
        \\fi
        \\rm -f "$1"
        \\(cd execution-specs && uv run --extra fill --extra test fill tests/eest -m state_test \
        \\    --output tests/eest/static/state_tests --clean)
        \\touch "$1"
        ,
        "fill-state-specs", state_fixture_stamp,
        if (force_refresh) "true" else "false",
    });

    fill_specs.setCwd(b.path("."));

    const spec_runner_options: std.Build.Module.CreateOptions = .{
        .root_source_file = b.path("test/specs/runner.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "evm", .module = mod },
            .{ .name = "voltaire", .module = primitives_mod },
        },
    };
    const spec_runner_mod = b.createModule(spec_runner_options);
    // Preserve the package module and its public runner declaration.
    var exported_spec_runner = spec_runner_options;
    exported_spec_runner.root_source_file = b.path("test/specs/root.zig");
    _ = b.addModule("spec_runner", exported_spec_runner);

    const state_root = generateSpecRoot(b, "state");
    if (force_refresh or !use_existing) state_root.step.dependOn(&fill_specs.step);
    const blockchain_root = generateSpecRoot(b, "blockchain");
    const spec_tests_state = addSpecTests(b, state_root.root, spec_runner_mod, target, optimize);
    const spec_tests_blockchain = addSpecTests(b, blockchain_root.root, spec_runner_mod, target, optimize);

    const run_spec_tests_state = b.addRunArtifact(spec_tests_state);
    run_spec_tests_state.setCwd(b.path("."));

    const run_spec_tests_blockchain = b.addRunArtifact(spec_tests_blockchain);
    run_spec_tests_blockchain.setCwd(b.path("."));

    const spec_test_step = b.step("specs", "Run execution-specs STATE tests");
    spec_test_step.dependOn(&run_spec_tests_state.step);

    const spec_blockchain_test_step = b.step("specs-blockchain", "Run execution-specs BLOCKCHAIN tests");
    spec_blockchain_test_step.dependOn(&run_spec_tests_blockchain.step);

    const include_specs = b.option(bool, "specs", "Run filled state fixtures during zig build test (default: false)") orelse false;
    if (include_specs) test_step.dependOn(&run_spec_tests_state.step);

    const spec_runner_unit_tests = b.addTest(.{ .root_module = spec_runner_mod });
    linkRustSupport(spec_runner_unit_tests);
    const run_spec_runner_unit_tests = b.addRunArtifact(spec_runner_unit_tests);
    test_step.dependOn(&run_spec_runner_unit_tests.step);
    unit_test_step.dependOn(&run_spec_runner_unit_tests.step);
    b.step("test-spec-runner", "Run spec runner unit tests (no fixtures needed)").dependOn(&run_spec_runner_unit_tests.step);

    const test_utils_mod = b.createModule(.{
        .root_source_file = b.path("test/utils.zig"),
        .target = target,
        .optimize = optimize,
    });
    const eest_runner_exe = b.addExecutable(.{
        .name = "eest-runner",
        .root_module = b.createModule(.{
            .root_source_file = b.path("test/specs/eest_cli.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "runner", .module = spec_runner_mod },
                .{ .name = "test_utils", .module = test_utils_mod },
                .{ .name = "evm", .module = mod },
            },
        }),
    });
    linkRustSupport(eest_runner_exe);
    const install_eest_runner = b.addInstallArtifact(eest_runner_exe, .{});
    const run_eest_runner = b.addRunArtifact(eest_runner_exe);
    run_eest_runner.setCwd(b.path("."));
    if (b.args) |args| run_eest_runner.addArgs(args);
    const eest_runner_step = b.step("eest-runner", "Run official EEST JSON fixtures in parallel");
    eest_runner_step.dependOn(&install_eest_runner.step);
    eest_runner_step.dependOn(&run_eest_runner.step);

    // Create hardfork-specific test suites
    const hardforks = [_]struct { name: []const u8, desc: []const u8 }{
        .{ .name = "frontier", .desc = "Frontier hardfork tests - runs all frontier-* sub-targets" },
        .{ .name = "homestead", .desc = "Homestead hardfork tests" },
        .{ .name = "byzantium", .desc = "Byzantium hardfork tests" },
        .{ .name = "constantinople", .desc = "Constantinople hardfork tests" },
        .{ .name = "istanbul", .desc = "Istanbul hardfork tests" },
        .{ .name = "berlin", .desc = "Berlin hardfork tests (EIP-2929, EIP-2930) - runs all berlin-* sub-targets" },
        .{ .name = "paris", .desc = "Paris/Merge hardfork tests" },
        .{ .name = "shanghai", .desc = "Shanghai hardfork tests (EIP-3651, EIP-3855, EIP-3860, EIP-4895)" },
        .{ .name = "cancun", .desc = "Cancun hardfork tests (EIP-1153, EIP-4788, EIP-4844, EIP-5656, EIP-6780, EIP-7516) - runs all cancun-* sub-targets" },
        .{ .name = "prague", .desc = "Prague hardfork tests - runs all prague-* sub-targets" },
        .{ .name = "osaka", .desc = "Osaka hardfork tests - runs all osaka-* sub-targets" },
    };

    // Break up large hardforks into smaller sub-targets for faster test iteration
    // Define a common struct type for all sub-targets
    const SubTarget = struct { name: []const u8, filter: []const u8, desc: []const u8 };

    // Berlin has 2772 tests in tx_intrinsic_gas alone
    const berlin_sub_targets = [_]SubTarget{
        .{ .name = "berlin-acl", .filter = "berlin.*acl.*account_storage_warm_cold_state", .desc = "Berlin EIP-2930 access list account storage tests" },
        .{ .name = "berlin-intrinsic-gas-cost", .filter = "berlin.*acl.*transaction_intrinsic_gas_cost", .desc = "Berlin EIP-2930 transaction intrinsic gas cost tests" },
        .{ .name = "berlin-intrinsic-type0", .filter = "berlin.*tx_intrinsic_gas.*tx_type_0", .desc = "Berlin EIP-2930 intrinsic gas type 0 transaction tests" },
        .{ .name = "berlin-intrinsic-type1", .filter = "berlin.*tx_intrinsic_gas.*tx_type_1", .desc = "Berlin EIP-2930 intrinsic gas type 1 transaction tests" },
    };

    // Frontier has 12k+ lines in stack_overflow.zig and 6k+ in push.zig
    const frontier_sub_targets = [_]SubTarget{
        .{ .name = "frontier-precompiles", .filter = "frontier.*precompile", .desc = "Frontier precompile tests" },
        .{ .name = "frontier-identity", .filter = "frontier.*identity", .desc = "Frontier identity precompile tests" },
        .{ .name = "frontier-create", .filter = "frontier.*create", .desc = "Frontier CREATE tests" },
        .{ .name = "frontier-call", .filter = "frontier.*call", .desc = "Frontier CALL/CALLCODE tests" },
        .{ .name = "frontier-calldata", .filter = "frontier.*calldata", .desc = "Frontier calldata opcode tests" },
        .{ .name = "frontier-dup", .filter = "frontier.*dup", .desc = "Frontier DUP tests" },
        .{ .name = "frontier-push", .filter = "frontier.*push", .desc = "Frontier PUSH tests" },
        .{ .name = "frontier-stack", .filter = "frontier.*stack_overflow", .desc = "Frontier stack overflow tests" },
        .{ .name = "frontier-opcodes", .filter = "frontier.*opcodes.*all_opcodes", .desc = "Frontier all opcodes tests" },
    };

    // Cancun has 20k+ lines in sufficient_balance_blob_tx.zig
    // NOTE: Filters use simple substring matching, not regex
    const cancun_sub_targets = [_]SubTarget{
        .{ .name = "cancun-tstore-basic", .filter = "eip1153_tstore_test_tstorage_py", .desc = "Cancun EIP-1153 basic TLOAD/TSTORE tests" },
        .{ .name = "cancun-tstore-reentrancy", .filter = "eip1153_tstore_test_tstore_reentrancy", .desc = "Cancun EIP-1153 reentrancy tests" },
        // Split contexts into smaller chunks (was 410 tests, now ~60-80 each)
        .{ .name = "cancun-tstore-contexts-execution", .filter = "tstorage_execution_contexts", .desc = "Cancun EIP-1153 execution context tests (60 tests)" },
        .{ .name = "cancun-tstore-contexts-tload-reentrancy", .filter = "tload_reentrancy", .desc = "Cancun EIP-1153 tload reentrancy tests (48 tests)" },
        .{ .name = "cancun-tstore-contexts-reentrancy", .filter = "tstorage_reentrancy_contexts", .desc = "Cancun EIP-1153 reentrancy context tests (20 tests)" },
        .{ .name = "cancun-tstore-contexts-create", .filter = "tstorage_create_contexts", .desc = "Cancun EIP-1153 create context tests (20 tests)" },
        .{ .name = "cancun-tstore-contexts-selfdestruct", .filter = "tstorage_selfdestruct", .desc = "Cancun EIP-1153 selfdestruct tests (12 tests)" },
        .{ .name = "cancun-tstore-contexts-clear", .filter = "tstorage_clear_after_tx", .desc = "Cancun EIP-1153 clear after tx tests (4 tests)" },
        .{ .name = "cancun-mcopy", .filter = "eip5656_mcopy", .desc = "Cancun EIP-5656 MCOPY tests" },
        // Split selfdestruct into smaller chunks (was 1166 tests, now ~50-300 each)
        .{ .name = "cancun-selfdestruct-basic", .filter = "test_selfdestruct_py", .desc = "Cancun EIP-6780 basic SELFDESTRUCT tests (306 tests)" },
        .{ .name = "cancun-selfdestruct-collision", .filter = "dynamic_create2_selfdestruct_collision", .desc = "Cancun EIP-6780 create2 collision tests (52 tests)" },
        .{ .name = "cancun-selfdestruct-reentrancy", .filter = "reentrancy_selfdestruct_revert", .desc = "Cancun EIP-6780 reentrancy revert tests (36 tests)" },
        .{ .name = "cancun-selfdestruct-revert", .filter = "test_selfdestruct_revert_py", .desc = "Cancun EIP-6780 revert tests (12 tests)" },
        .{ .name = "cancun-blobbasefee", .filter = "eip7516_blobgasfee", .desc = "Cancun EIP-7516 BLOBBASEFEE tests" },
        // Split blob precompile into smaller chunks (was 1073 tests, now ~50-310 each)
        .{ .name = "cancun-blob-precompile-basic", .filter = "test_point_evaluation_precompile_py", .desc = "Cancun EIP-4844 point evaluation basic tests (310 tests)" },
        .{ .name = "cancun-blob-precompile-gas", .filter = "test_point_evaluation_precompile_gas_py", .desc = "Cancun EIP-4844 point evaluation gas tests (48 tests)" },
        // Split blob opcodes into smaller chunks (was 282 tests, now ~25-75 each)
        .{ .name = "cancun-blob-opcodes-basic", .filter = "test_blobhash_opcode_py__test_blobhash_", .desc = "Cancun EIP-4844 BLOBHASH basic tests (75 tests)" },
        .{ .name = "cancun-blob-opcodes-contexts", .filter = "blobhash_opcode_contexts", .desc = "Cancun EIP-4844 BLOBHASH context tests (23 tests)" },
        .{ .name = "cancun-blob-tx-small", .filter = "blob_tx_attribute", .desc = "Cancun EIP-4844 small blob transaction tests" },
        .{ .name = "cancun-blob-tx-subtraction", .filter = "blob_gas_subtraction_tx", .desc = "Cancun EIP-4844 blob gas subtraction tests" },
        .{ .name = "cancun-blob-tx-insufficient", .filter = "insufficient_balance_blob_tx", .desc = "Cancun EIP-4844 insufficient balance tests" },
        .{ .name = "cancun-blob-tx-sufficient", .filter = "sufficient_balance_blob_tx", .desc = "Cancun EIP-4844 sufficient balance tests" },
        .{ .name = "cancun-blob-tx-valid-combos", .filter = "valid_blob_tx_combinations", .desc = "Cancun EIP-4844 valid combinations tests" },
    };

    // Prague has 4540 lines in transaction_validity_type_1_type_2.zig and many BLS12-381 tests
    const prague_sub_targets = [_]SubTarget{
        .{ .name = "prague-calldata-cost-type0", .filter = "prague.*eip7623.*type_0", .desc = "Prague EIP-7623 calldata cost type 0 tests" },
        .{ .name = "prague-calldata-cost-type1-2", .filter = "prague.*eip7623.*type_1_type_2", .desc = "Prague EIP-7623 calldata cost type 1/2 tests" },
        .{ .name = "prague-calldata-cost-type3", .filter = "prague.*eip7623.*type_3", .desc = "Prague EIP-7623 calldata cost type 3 tests" },
        .{ .name = "prague-calldata-cost-type4", .filter = "prague.*eip7623.*type_4", .desc = "Prague EIP-7623 calldata cost type 4 tests" },
        .{ .name = "prague-calldata-cost-refunds", .filter = "prague.*eip7623.*(refunds|execution_gas)", .desc = "Prague EIP-7623 refunds and gas tests" },
        .{ .name = "prague-bls-g1", .filter = "prague.*bls12.*(g1add|g1mul|g1msm)", .desc = "Prague EIP-2537 BLS12-381 G1 tests" },
        .{ .name = "prague-bls-g2", .filter = "prague.*bls12.*(g2add|g2mul|g2msm)", .desc = "Prague EIP-2537 BLS12-381 G2 tests" },
        .{ .name = "prague-bls-pairing", .filter = "prague.*bls12.*pairing", .desc = "Prague EIP-2537 BLS12-381 pairing tests" },
        .{ .name = "prague-bls-map", .filter = "prague.*bls12.*map", .desc = "Prague EIP-2537 BLS12-381 map tests" },
        .{ .name = "prague-bls-misc", .filter = "prague.*bls12.*(variable_length|before_fork)", .desc = "Prague EIP-2537 BLS12-381 misc tests" },
        .{ .name = "prague-setcode-calls", .filter = "prague.*eip7702.*calls", .desc = "Prague EIP-7702 set code call tests" },
        .{ .name = "prague-setcode-gas", .filter = "prague.*eip7702.*gas", .desc = "Prague EIP-7702 set code gas tests" },
        .{ .name = "prague-setcode-txs", .filter = "prague.*eip7702.*set_code_txs[^_2]", .desc = "Prague EIP-7702 set code transaction tests" },
        .{ .name = "prague-setcode-advanced", .filter = "prague.*eip7702.*set_code_txs_2", .desc = "Prague EIP-7702 advanced set code tests" },
    };

    // Osaka has 5836 lines in modexp_variable_gas_cost.zig
    const osaka_sub_targets = [_]SubTarget{
        .{ .name = "osaka-modexp-variable-gas", .filter = "osaka.*modexp_variable_gas_cost", .desc = "Osaka EIP-7883 modexp variable gas tests" },
        .{ .name = "osaka-modexp-vectors-eip", .filter = "osaka.*vectors_from_eip", .desc = "Osaka EIP-7883 modexp vectors from EIP tests" },
        .{ .name = "osaka-modexp-vectors-legacy", .filter = "osaka.*vectors_from_legacy", .desc = "Osaka EIP-7883 modexp vectors from legacy tests" },
        .{ .name = "osaka-modexp-misc", .filter = "osaka.*modexp.*(call_operations|gas_usage|invalid|entry_points|exceed)", .desc = "Osaka EIP-7883 modexp misc tests" },
        .{ .name = "osaka-other", .filter = "osaka.*(eip7823|eip7825)", .desc = "Osaka other EIP tests" },
    };

    // Shanghai has 558 tests - split initcode (was 558 tests, now ~160-180 each)
    const shanghai_sub_targets = [_]SubTarget{
        .{ .name = "shanghai-push0", .filter = "eip3855_push0", .desc = "Shanghai EIP-3855 PUSH0 tests" },
        .{ .name = "shanghai-warmcoinbase", .filter = "eip3651_warm_coinbase", .desc = "Shanghai EIP-3651 warm coinbase tests" },
        .{ .name = "shanghai-initcode-basic", .filter = "test_initcode_py", .desc = "Shanghai EIP-3860 initcode basic tests (162 tests)" },
        .{ .name = "shanghai-initcode-eof", .filter = "with_eof", .desc = "Shanghai EIP-3860 initcode EOF tests (24 tests)" },
        .{ .name = "shanghai-withdrawals", .filter = "eip4895_withdrawals", .desc = "Shanghai EIP-4895 withdrawal tests" },
    };

    // Byzantium has 352 tests - all modexp precompile
    const byzantium_sub_targets = [_]SubTarget{
        .{ .name = "byzantium-modexp", .filter = "eip198_modexp", .desc = "Byzantium EIP-198 modexp precompile tests (352 tests)" },
    };

    // Constantinople has 508 tests - split by EIP (was 508 tests, now ~250 each)
    const constantinople_sub_targets = [_]SubTarget{
        .{ .name = "constantinople-bitshift", .filter = "eip145_bitwise_shift", .desc = "Constantinople EIP-145 bitwise shift tests (~250 tests)" },
        .{ .name = "constantinople-create2", .filter = "eip1014_create2", .desc = "Constantinople EIP-1014 CREATE2 tests (~250 tests)" },
    };

    // Istanbul has 2165 tests - split by EIP (was 2165 tests, now smaller chunks)
    const istanbul_sub_targets = [_]SubTarget{
        .{ .name = "istanbul-blake2", .filter = "eip152_blake2", .desc = "Istanbul EIP-152 BLAKE2 precompile tests" },
        .{ .name = "istanbul-chainid", .filter = "eip1344_chainid", .desc = "Istanbul EIP-1344 CHAINID tests" },
    };

    // Helper to create sub-targets for a hardfork
    const SubTargetConfig = struct {
        targets: []const SubTarget,
        fork_name: []const u8,
    };

    const sub_target_configs = [_]SubTargetConfig{
        .{ .targets = &berlin_sub_targets, .fork_name = "berlin" },
        .{ .targets = &frontier_sub_targets, .fork_name = "frontier" },
        .{ .targets = &cancun_sub_targets, .fork_name = "cancun" },
        .{ .targets = &prague_sub_targets, .fork_name = "prague" },
        .{ .targets = &osaka_sub_targets, .fork_name = "osaka" },
        .{ .targets = &shanghai_sub_targets, .fork_name = "shanghai" },
        .{ .targets = &byzantium_sub_targets, .fork_name = "byzantium" },
        .{ .targets = &constantinople_sub_targets, .fork_name = "constantinople" },
        .{ .targets = &istanbul_sub_targets, .fork_name = "istanbul" },
    };

    var fork_sub_steps_map = std.StringHashMap(std.ArrayList(*std.Build.Step)).init(b.allocator);
    defer {
        var it = fork_sub_steps_map.iterator();
        while (it.next()) |entry| {
            entry.value_ptr.deinit(b.allocator);
        }
        fork_sub_steps_map.deinit();
    }

    // Initialize arrays for each fork
    for (sub_target_configs) |config| {
        const steps = std.ArrayList(*std.Build.Step){};
        fork_sub_steps_map.put(config.fork_name, steps) catch @panic("OOM");
    }

    // Create all sub-targets
    for (sub_target_configs) |config| {
        const steps = fork_sub_steps_map.getPtr(config.fork_name).?;

        for (config.targets) |sub_target| {
            const run_sub_tests = b.addRunArtifact(spec_tests_state);
            run_sub_tests.setCwd(b.path("."));
            run_sub_tests.setEnvironmentVariable("TEST_FILTER", sub_target.filter);

            const step_name = b.fmt("specs-{s}", .{sub_target.name});
            const sub_step = b.step(step_name, sub_target.desc);
            sub_step.dependOn(&run_sub_tests.step);

            steps.append(b.allocator, &run_sub_tests.step) catch @panic("OOM");
        }
    }

    for (hardforks) |fork| {
        const run_fork_tests = b.addRunArtifact(spec_tests_state);
        run_fork_tests.setCwd(b.path("."));
        run_fork_tests.setEnvironmentVariable("TEST_FILTER", fork.name);

        const step_name = b.fmt("specs-{s}", .{fork.name});
        const fork_step = b.step(step_name, fork.desc);

        // For hardforks with sub-targets, make the main target depend on all sub-targets
        if (fork_sub_steps_map.get(fork.name)) |sub_steps| {
            for (sub_steps.items) |sub_step| {
                fork_step.dependOn(sub_step);
            }
        } else {
            fork_step.dependOn(&run_fork_tests.step);
        }
    }

    // Create EIP-specific test suites for hardforks without sub-targets
    // (Berlin, Frontier, Cancun, Prague, Osaka, Shanghai, Byzantium, Constantinople, and Istanbul now have sub-targets defined above)
    // This array is now empty - all test suites have been converted to use sub-targets for better granularity
    const eip_suites = [_]struct { name: []const u8, filter: []const u8, desc: []const u8 }{};

    for (eip_suites) |suite| {
        const run_eip_tests = b.addRunArtifact(spec_tests_state);
        run_eip_tests.setCwd(b.path("."));
        run_eip_tests.setEnvironmentVariable("TEST_FILTER", suite.filter);

        const step_name = b.fmt("specs-{s}", .{suite.name});
        const eip_step = b.step(step_name, suite.desc);
        eip_step.dependOn(&run_eip_tests.step);
    }

    // Add trace test executable
    const trace_test_mod = b.addModule("trace_test_mod", .{
        .root_source_file = b.path("test_trace.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "guillotine", .module = mod },
            .{ .name = "voltaire", .module = primitives_mod },
        },
    });

    const trace_test = b.addExecutable(.{
        .name = "trace_test",
        .root_module = trace_test_mod,
    });
    linkRustSupport(trace_test);

    const run_trace_test = b.addRunArtifact(trace_test);
    const trace_test_step = b.step("test-trace", "Run trace capture test");
    trace_test_step.dependOn(&run_trace_test.step);

    // WASM build target with ReleaseSmall optimization
    // Using wasi because primitives package includes C libraries (BLST, C-KZG, BN254)
    const wasm_target = b.resolveTargetQuery(.{
        .cpu_arch = .wasm32,
        .os_tag = .wasi,
    });

    // Get WASM-specific primitives modules from dependency
    const wasm_primitives_dep = b.dependency("voltaire", .{
        .target = wasm_target,
        .optimize = .ReleaseSmall,
    });

    const wasm_primitives_mod = wasm_primitives_dep.module("primitives");
    const wasm_crypto_mod = wasm_primitives_dep.module("crypto");
    const wasm_precompiles_mod = wasm_primitives_dep.module("precompiles");

    const external = b.createModule(.{
        .root_source_file = b.path("src/precompiles/wasm_host.zig"),
        .target = wasm_target,
        .optimize = .ReleaseSmall,
        .imports = &.{
            .{ .name = "voltaire", .module = wasm_primitives_mod },
            .{ .name = "builtins", .module = wasm_precompiles_mod },
        },
    });
    const wasm_lib = addWasmEvm(b, "guillotine_mini", wasm_target, evm_options_mod, wasm_primitives_mod, wasm_crypto_mod, wasm_precompiles_mod);
    const core = addWasmEvm(b, "guillotine_mini_core", wasm_target, evm_options_mod, wasm_primitives_mod, wasm_crypto_mod, external);
    const core_binary = optimizeWasm(b, core);
    const full_binary = optimizeWasm(b, wasm_lib);

    const wasm_step = b.step("wasm", "Build the WASI reactor library");
    wasm_step.dependOn(&b.addInstallBinFile(full_binary, "guillotine_mini.wasm").step);

    // Exercise the real artifact with Node's WASI implementation, including
    // its linked crypto precompiles. No npm dependencies or external fixtures.
    const wasm_test = b.addSystemCommand(&.{"node"});
    wasm_test.addFileArg(b.path("test/wasm.test.mjs"));
    wasm_test.addFileArg(full_binary);
    const wasm_test_step = b.step("test-wasm", "Run WASM execution and crypto regression tests (Node 22+)");
    wasm_test_step.dependOn(&wasm_test.step);

    const core_step = b.step("wasm-core", "Build the small reactor with host-loaded precompiles");
    core_step.dependOn(&b.addInstallBinFile(core_binary, "guillotine_mini_core.wasm").step);
    core_step.dependOn(&b.addInstallBinFile(b.path("wasm/precompiles.mjs"), "precompiles.mjs").step);
    const modular = b.step("wasm-modular", "Build the core and all separately loadable precompiles");
    modular.dependOn(core_step);

    const modular_test = b.addSystemCommand(&.{"node"});
    modular_test.addFileArg(b.path("test/wasm.test.mjs"));
    modular_test.addFileArg(core_binary);
    modular_test.addFileArg(full_binary);
    wasm_test_step.dependOn(&modular_test.step);
    const size_check = b.addSystemCommand(&.{"node"});
    size_check.addFileArg(b.path("test/wasm-size.mjs"));
    size_check.addFileArg(core_binary);
    size_check.addFileArg(full_binary);
    b.step("test-wasm-size", "Check the raw byte budgets of the WASM artifacts").dependOn(&size_check.step);

    const addresses = [_]u16{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 0x100 };
    for (addresses) |address| {
        const options = b.addOptions();
        options.addOption(u16, "address", address);
        const mod_name = b.fmt("precompile-{x:0>2}", .{address});
        const addon = b.addExecutable(.{
            .name = mod_name,
            .root_module = b.createModule(.{
                .root_source_file = b.path("src/precompiles/wasm_module.zig"),
                .target = wasm_target,
                .optimize = .ReleaseSmall,
                .imports = &.{
                    .{ .name = "voltaire", .module = wasm_primitives_mod },
                    .{ .name = "builtins", .module = wasm_precompiles_mod },
                    .{ .name = "options", .module = options.createModule() },
                },
            }),
        });
        addon.entry = .disabled;
        addon.wasi_exec_model = .reactor;
        addon.root_module.export_symbol_names = &.{ "address", "prepare", "execute", "output_ptr", "gas_used" };
        const step = b.step(b.fmt("wasm-{s}", .{mod_name}), "Build this precompile reactor");
        step.dependOn(&b.addInstallArtifact(addon, .{}).step);
        modular_test.addArtifactArg(addon);
        size_check.addArtifactArg(addon);
        modular.dependOn(step);
    }

    // WASM is an explicit cross-compilation target; native installs do not need
    // the Rust WASM standard library. Use `zig build wasm` to build the reactor.

    // Native C library build for Rust FFI integration
    const native_mod = b.addModule("guillotine_mini_native", .{
        .root_source_file = b.path("src/root_c.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "build_options", .module = evm_options_mod },
            .{ .name = "voltaire", .module = primitives_mod },
            .{ .name = "crypto", .module = crypto_mod },
            .{ .name = "precompiles", .module = precompiles_mod },
        },
    });

    const native_lib = b.addLibrary(.{
        .linkage = .static,
        .name = "guillotine_mini",
        .root_module = native_mod,
    });
    linkRustSupport(native_lib);

    const native_install = b.addInstallArtifact(native_lib, .{});

    const native_step = b.step("native", "Build native static library for FFI");
    native_step.dependOn(&native_install.step);

    // EVMC ABI 12 shared library (`libguillotine_mini_evmc.{so,dylib}`)
    const evmc_mod = b.createModule(.{
        .root_source_file = b.path("src/evmc_exports.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "build_options", .module = evm_options_mod },
            .{ .name = "voltaire", .module = primitives_mod },
            .{ .name = "crypto", .module = crypto_mod },
            .{ .name = "precompiles", .module = precompiles_mod },
        },
    });
    const evmc_lib = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "guillotine_mini_evmc",
        .root_module = evmc_mod,
    });
    linkRustSupport(evmc_lib);
    b.step("evmc", "Build EVMC ABI 12 shared library").dependOn(&b.addInstallArtifact(evmc_lib, .{}).step);

    const evmc_tests = b.addTest(.{ .root_module = evmc_mod });
    linkRustSupport(evmc_tests);
    const run_evmc_tests = b.addRunArtifact(evmc_tests);
    unit_test_step.dependOn(&run_evmc_tests.step);
    test_step.dependOn(&run_evmc_tests.step);
    b.step("test-evmc", "Run EVMC ABI 12 unit tests").dependOn(&run_evmc_tests.step);

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

fn optimizeWasm(b: *std.Build, exe: *std.Build.Step.Compile) std.Build.LazyPath {
    exe.lto = .full;
    const shrink = b.addSystemCommand(&.{ "wasm-opt", "-Oz", "--converge", "--enable-bulk-memory", "--enable-sign-ext", "--enable-nontrapping-float-to-int" });
    shrink.addArtifactArg(exe);
    shrink.addArg("-o");
    return shrink.addOutputFileArg(b.fmt("{s}.wasm", .{exe.name}));
}

fn addWasmEvm(
    b: *std.Build,
    name: []const u8,
    wasm_target: std.Build.ResolvedTarget,
    evm_options_mod: *std.Build.Module,
    wasm_primitives_mod: *std.Build.Module,
    wasm_crypto_mod: *std.Build.Module,
    wasm_precompiles_mod: *std.Build.Module,
) *std.Build.Step.Compile {
    const wasm_mod = b.addModule(b.fmt("{s}_wasm", .{name}), .{
        .root_source_file = b.path("src/root_c.zig"),
        .target = wasm_target,
        .optimize = .ReleaseSmall,
        .imports = &.{
            .{ .name = "build_options", .module = evm_options_mod },
            .{ .name = "voltaire", .module = wasm_primitives_mod },
            .{ .name = "crypto", .module = wasm_crypto_mod },
            .{ .name = "precompiles", .module = wasm_precompiles_mod },
        },
    });

    const wasm_lib = b.addExecutable(.{
        .name = name,
        .root_module = wasm_mod,
    });
    wasm_lib.entry = .disabled;
    wasm_lib.wasi_exec_model = .reactor;
    wasm_lib.export_table = true;

    // Export all functions starting with evm_
    wasm_lib.root_module.export_symbol_names = &.{
        "evm_alloc",
        "evm_free",
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
        "evm_set_access_list_addresses",
        "evm_set_access_list_storage_keys",
        "evm_set_blob_hashes",
        // Async protocol functions
        "evm_call_ffi",
        "evm_continue_ffi",
        "evm_get_state_changes",
        "evm_get_state_changes_len",
        "evm_set_origin",
        "evm_set_gas_price",
        "evm_enable_storage_injector",
        "evm_set_nonce",
        "evm_get_log_count",
        "evm_get_log",
        "evm_get_gas_refund",
        "evm_get_storage_change_count",
        "evm_get_storage_change",
        "evm_set_js_opcode_callbacks_enabled",
        "evm_enable_tracing",
        "evm_disable_tracing",
        "evm_get_trace_json_len",
        "evm_get_trace_json",
        "evm_enable_call_tracer",
        "evm_get_call_trace_json_len",
        "evm_get_call_trace_json",
        "evm_enable_access_list_tracker",
        "evm_get_access_list_json_len",
        "evm_get_access_list_json",
        "evm_enable_flamegraph",
        "evm_get_flamegraph_svg_len",
        "evm_get_flamegraph_svg",
        "evm_get_flamegraph_folded_len",
        "evm_get_flamegraph_folded",
        "evm_decode_revert_json_len",
        "evm_decode_revert_json",
    };

    return wasm_lib;
}

fn generateSpecRoot(b: *std.Build, family: []const u8) struct { step: *std.Build.Step, root: std.Build.LazyPath } {
    const generate = b.addSystemCommand(&.{
        "python3", "-B", "-c",
        \\import json
        \\import runpy
        \\import sys
        \\from pathlib import Path
        \\
        \\family, script, output, depfile = sys.argv[1:]
        \\repo = Path.cwd()
        \\generator = runpy.run_path(script)
        \\output = Path(output)
        \\wrappers = output / "generated"
        \\if family == "state":
        \\    fixtures = repo / "execution-specs/tests/eest/static/state_tests"
        \\else:
        \\    fixtures = repo / "execution-spec-tests/fixtures/blockchain_tests"
        \\    legacy = repo / "ethereum-tests/BlockchainTests"
        \\    if not any(fixtures.rglob("*.json")):
        \\        if any(legacy.rglob("*.json")):
        \\            fixtures = legacy
        \\        elif (repo / "ethereum-tests/fixtures_blockchain_tests.tgz").is_file():
        \\            generator["ensure_blockchain_fixtures"](fixtures, repo)
        \\
        \\imports = []
        \\inputs = []
        \\for fixture in sorted(fixtures.rglob("*.json")):
        \\    if ".meta" in fixture.relative_to(fixtures).parts:
        \\        continue
        \\    if not generator["generate_test_file"](fixture, wrappers, fixtures, repo):
        \\        raise SystemExit(f"No tests could be generated from {fixture}")
        \\    wrapper = (wrappers / fixture.relative_to(fixtures).with_suffix(".zig")).relative_to(output)
        \\    imports.append(f'test {{ _ = @import({json.dumps(wrapper.as_posix())}); }}')
        \\    inputs.append(str(fixture))
        \\if not imports:
        \\    raise SystemExit(f"No {family} fixture JSON found in {fixtures}")
        \\
        \\root = 'pub const runner = @import("spec_runner");\n' + "\n".join(imports) + "\n"
        \\(output / "root.zig").write_text(root, encoding="utf-8")
        \\# Track fixture inputs and publish the generated tree through Zig's cache.
        \\Path(depfile).write_text("root.zig: " + " ".join(path.replace(" ", "\\ ") for path in inputs) + "\n")
        ,
        family,
    });
    generate.setCwd(b.path("."));
    generate.addFileArg(b.path("scripts/generate_spec_tests.py"));
    const output = generate.addOutputDirectoryArg(b.fmt("specs-{s}", .{family}));
    _ = generate.addDepFileOutputArg("fixtures.d");
    // Rescan the fixture directory so additions and deletions are picked up.
    generate.has_side_effects = true;
    return .{ .step = &generate.step, .root = output.path(b, "root.zig") };
}

fn addSpecTests(
    b: *std.Build,
    root: std.Build.LazyPath,
    runner: *std.Build.Module,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) *std.Build.Step.Compile {
    const tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = root,
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "spec_runner", .module = runner }},
        }),
        .test_runner = .{ .path = b.path("test_runner.zig"), .mode = .simple },
    });
    linkRustSupport(tests);
    return tests;
}

/// Voltaire's Rust archive (libcrypto_wrappers.a) references the platform
/// unwinder (`_Unwind_*`), which Zig does not link implicitly. Link libgcc_s on
/// Linux and libgcc_eh on Windows GNU. macOS gets the unwinder from libSystem;
/// wasm32 has none and needs none.
fn linkRustSupport(compile: *std.Build.Step.Compile) void {
    const t = compile.rootModuleTarget();
    switch (t.os.tag) {
        .linux => compile.root_module.linkSystemLibrary("gcc_s", .{}),
        .windows => if (t.abi.isGnu()) compile.root_module.linkSystemLibrary("gcc_eh", .{}),
        else => {},
    }
}
