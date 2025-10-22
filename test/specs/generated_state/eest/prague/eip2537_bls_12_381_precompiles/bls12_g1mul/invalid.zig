const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__0_times_rand_not_in_subgroup_3__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--0_times_rand_not_in_subgroup_3-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__2_times_rand_not_in_subgroup_1__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--2_times_rand_not_in_subgroup_1-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__all_zero_96_bytes__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--all_zero_96_bytes-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__bad_inf_flag_with_scalar__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--bad_inf_flag_with_scalar-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__bls_g1mul_empty_input__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--bls_g1mul_empty_input-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__bls_g1mul_g1_not_in_correct_subgroup__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--bls_g1mul_g1_not_in_correct_subgroup-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__bls_g1mul_invalid_field_element__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--bls_g1mul_invalid_field_element-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__bls_g1mul_large_input__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--bls_g1mul_large_input-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__bls_g1mul_point_not_on_curve__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--bls_g1mul_point_not_on_curve-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__bls_g1mul_short_input__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--bls_g1mul_short_input-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__bls_g1mul_violate_top_bytes__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--bls_g1mul_violate_top_bytes-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__comp_instead_of_uncomp_with_scalar__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--comp_instead_of_uncomp_with_scalar-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__doubled_not_in_subgroup_times_1__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--doubled_not_in_subgroup_times_1-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__doubled_not_in_subgroup_times_q__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--doubled_not_in_subgroup_times_q-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__g1_input_invalid_length__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--g1_input_invalid_length-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__g1_truncated_input__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--g1_truncated_input-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__g2_input_invalid_length__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--g2_input_invalid_length-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__inf_with_long_scalar__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--inf_with_long_scalar-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__inf_with_short_scalar__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--inf_with_short_scalar-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__input_too_long__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--input_too_long-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__input_too_short__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--input_too_short-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__invalid_encoding__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--invalid_encoding-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__invalid_point_1__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--invalid_point_1-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__invalid_point_2__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--invalid_point_2-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__invalid_point_3__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--invalid_point_3-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__invalid_point_4__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--invalid_point_4-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__non_zero_byte_16_boundary_violation_x__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--non_zero_byte_16_boundary_violation_x-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__non_zero_byte_16_boundary_violation_y__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--non_zero_byte_16_boundary_violation_y-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__not_in_subgroup_times_0__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--not_in_subgroup_times_0-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__not_in_subgroup_times_1__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--not_in_subgroup_times_1-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__not_in_subgroup_times_2__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--not_in_subgroup_times_2-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__not_in_subgroup_times_3__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--not_in_subgroup_times_3-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__not_in_subgroup_times_q_minus_1__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--not_in_subgroup_times_q_minus_1-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__not_in_subgroup_times_q_plus_1__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--not_in_subgroup_times_q_plus_1-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__point_on_wrong_curve_times_0__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--point_on_wrong_curve_times_0-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__q_times_not_in_subgroup__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--q_times_not_in_subgroup-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__rand_not_in_subgroup_0_times_1__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--rand_not_in_subgroup_0_times_1-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__rand_not_in_subgroup_2_times_q__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--rand_not_in_subgroup_2_times_q-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__rand_not_in_subgroup_4_times_large_scalar__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--rand_not_in_subgroup_4_times_large_scalar-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__rand_not_on_curve_0_times_1__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--rand_not_on_curve_0_times_1-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__rand_not_on_curve_1_times_2__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--rand_not_on_curve_1_times_2-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__rand_not_on_curve_2_times_q__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--rand_not_on_curve_2_times_q-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__rand_not_on_curve_3_times_0__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--rand_not_on_curve_3_times_0-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__rand_not_on_curve_4_times_q_minus_1__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--rand_not_on_curve_4_times_q_minus_1-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__scalar_too_large_bytes__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--scalar_too_large_bytes-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__scalar_too_large_bytes_with_point__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--scalar_too_large_bytes_with_point-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__scalar_too_small_bytes__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--scalar_too_small_bytes-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__swapped_coordinates_times_0__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--swapped_coordinates_times_0-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__two_scalars__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--two_scalars-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__x_above_modulus_times_0__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--x_above_modulus_times_0-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__x_equal_to_p_times_0__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--x_equal_to_p_times_0-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__y_equal_to_p_times_0__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--y_equal_to_p_times_0-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g1mul_py__test_invalid_fork_Prague_state_test__zero_length_input__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g1mul/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g1mul.py::test_invalid[fork_Prague-state_test--zero_length_input-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
