const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_exceed_tx_gas_cap_fork_Berlin_state_test_Z16_gas_cap_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost_exceed_tx_gas_cap.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost_exceed_tx_gas_cap[fork_Berlin-state_test-Z16-gas-cap-test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_exceed_tx_gas_cap_fork_Cancun_state_test_Z16_gas_cap_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost_exceed_tx_gas_cap.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost_exceed_tx_gas_cap[fork_Cancun-state_test-Z16-gas-cap-test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_exceed_tx_gas_cap_fork_London_state_test_Z16_gas_cap_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost_exceed_tx_gas_cap.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost_exceed_tx_gas_cap[fork_London-state_test-Z16-gas-cap-test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_exceed_tx_gas_cap_fork_Paris_state_test_Z16_gas_cap_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost_exceed_tx_gas_cap.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost_exceed_tx_gas_cap[fork_Paris-state_test-Z16-gas-cap-test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_exceed_tx_gas_cap_fork_Prague_state_test_Z16_gas_cap_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost_exceed_tx_gas_cap.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost_exceed_tx_gas_cap[fork_Prague-state_test-Z16-gas-cap-test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_exceed_tx_gas_cap_fork_Shanghai_state_test_Z16_gas_cap_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost_exceed_tx_gas_cap.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost_exceed_tx_gas_cap[fork_Shanghai-state_test-Z16-gas-cap-test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
