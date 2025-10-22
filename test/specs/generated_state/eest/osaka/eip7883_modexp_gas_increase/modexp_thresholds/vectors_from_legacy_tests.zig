const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_10_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-10]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_11_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-11]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_12_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-12]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_13_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-13]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_14_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-14]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_15_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-15]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_16_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-16]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_17_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-17]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_18_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-18]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_19_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-19]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_20_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-20]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_21_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-21]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_22_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-22]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_23_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-23]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_24_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-24]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_25_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-25]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_26_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-26]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_27_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-27]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_31_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-31]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_33_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-33]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_34_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-34]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_7_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-7]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_8_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-8]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Berlin_state_test_legacy_case_9_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Berlin-state_test-legacy-case-9]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_10_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-10]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_11_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-11]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_12_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-12]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_13_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-13]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_14_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-14]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_15_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-15]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_16_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-16]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_17_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-17]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_18_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-18]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_19_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-19]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_20_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-20]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_21_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-21]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_22_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-22]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_23_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-23]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_24_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-24]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_25_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-25]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_26_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-26]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_27_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-27]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_31_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-31]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_33_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-33]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_34_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-34]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_7_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-7]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_8_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-8]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Cancun_state_test_legacy_case_9_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Cancun-state_test-legacy-case-9]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_10_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-10]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_11_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-11]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_12_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-12]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_13_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-13]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_14_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-14]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_15_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-15]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_16_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-16]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_17_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-17]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_18_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-18]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_19_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-19]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_20_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-20]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_21_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-21]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_22_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-22]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_23_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-23]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_24_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-24]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_25_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-25]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_26_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-26]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_27_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-27]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_31_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-31]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_33_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-33]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_34_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-34]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_7_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-7]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_8_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-8]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_London_state_test_legacy_case_9_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_London-state_test-legacy-case-9]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_10_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-10]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_11_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-11]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_12_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-12]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_13_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-13]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_14_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-14]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_15_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-15]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_16_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-16]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_17_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-17]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_18_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-18]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_19_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-19]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_20_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-20]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_21_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-21]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_22_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-22]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_23_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-23]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_24_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-24]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_25_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-25]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_26_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-26]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_27_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-27]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_31_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-31]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_33_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-33]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_34_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-34]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_7_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-7]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_8_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-8]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Paris_state_test_legacy_case_9_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Paris-state_test-legacy-case-9]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_10_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-10]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_11_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-11]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_12_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-12]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_13_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-13]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_14_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-14]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_15_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-15]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_16_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-16]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_17_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-17]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_18_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-18]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_19_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-19]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_20_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-20]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_21_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-21]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_22_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-22]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_23_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-23]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_24_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-24]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_25_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-25]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_26_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-26]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_27_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-27]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_31_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-31]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_33_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-33]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_34_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-34]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_7_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-7]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_8_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-8]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Prague_state_test_legacy_case_9_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Prague-state_test-legacy-case-9]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_10_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-10]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_11_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-11]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_12_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-12]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_13_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-13]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_14_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-14]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_15_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-15]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_16_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-16]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_17_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-17]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_18_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-18]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_19_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-19]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_20_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-20]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_21_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-21]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_22_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-22]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_23_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-23]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_24_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-24]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_25_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-25]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_26_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-26]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_27_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-27]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_31_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-31]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_33_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-33]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_34_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-34]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_7_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-7]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_8_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-8]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_legacy_tests_fork_Shanghai_state_test_legacy_case_9_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_legacy_tests.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_legacy_tests[fork_Shanghai-state_test-legacy-case-9]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
