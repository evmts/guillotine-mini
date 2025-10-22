const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_valid_fork_Prague_state_test_bls_g2map___" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_valid[fork_Prague-state_test-bls_g2map_-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_valid_fork_Prague_state_test_bls_g2map_613531325f616161__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_valid[fork_Prague-state_test-bls_g2map_613531325f616161-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_valid_fork_Prague_state_test_bls_g2map_616263__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_valid[fork_Prague-state_test-bls_g2map_616263-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_valid_fork_Prague_state_test_bls_g2map_6162636465663031__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_valid[fork_Prague-state_test-bls_g2map_6162636465663031-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_valid_fork_Prague_state_test_bls_g2map_713132385f717171__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_valid[fork_Prague-state_test-bls_g2map_713132385f717171-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_valid_fork_Prague_state_test_fp_0__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_valid[fork_Prague-state_test-fp_0-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_valid_fork_Prague_state_test_fp_map_to_inf__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_valid[fork_Prague-state_test-fp_map_to_inf-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_valid_fork_Prague_state_test_fp_p_minus_1__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_valid[fork_Prague-state_test-fp_p_minus_1-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
