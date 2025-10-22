const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__bls_mapg2_empty_input__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--bls_mapg2_empty_input-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__bls_mapg2_invalid_fq_element__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--bls_mapg2_invalid_fq_element-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__bls_mapg2_long_input__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--bls_mapg2_long_input-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__bls_mapg2_short_input__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--bls_mapg2_short_input-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__bls_mapg2_top_bytes__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--bls_mapg2_top_bytes-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__fp2_above_modulus_c0__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--fp2_above_modulus_c0-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__fp2_above_modulus_c1__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--fp2_above_modulus_c1-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__fp2_invalid_first_byte__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--fp2_invalid_first_byte-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__fp2_large_power_of_2_c0__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--fp2_large_power_of_2_c0-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__fp2_large_power_of_2_c1__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--fp2_large_power_of_2_c1-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__fp2_one_byte_short__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--fp2_one_byte_short-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__fp2_with_extra_byte__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--fp2_with_extra_byte-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__fq_eq_2_512_minus_1__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--fq_eq_2_512_minus_1-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__fq_eq_2_512_minus_1_2__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--fq_eq_2_512_minus_1_2-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__fq_eq_q__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--fq_eq_q-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__fq_eq_q_2__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--fq_eq_q_2-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__g2_inf_input__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--g2_inf_input-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__g2_input__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--g2_input-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__input_too_long__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--input_too_long-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__input_too_short__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--input_too_short-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__invalid_encoding__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--invalid_encoding-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__non_zero_byte_16_boundary_violation_c0__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--non_zero_byte_16_boundary_violation_c0-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__non_zero_byte_16_boundary_violation_c1__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--non_zero_byte_16_boundary_violation_c1-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_map_fp2_to_g2_py__test_invalid_fork_Prague_state_test__zero_length_input__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_map_fp2_to_g2/invalid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_map_fp2_to_g2.py::test_invalid[fork_Prague-state_test--zero_length_input-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
