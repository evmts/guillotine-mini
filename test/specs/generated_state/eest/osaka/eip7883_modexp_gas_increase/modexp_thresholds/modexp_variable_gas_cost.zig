const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_A1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-A1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_A2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-A2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_A3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-A3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_B1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-B1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_B2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-B2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_B4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-B4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_E1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-E1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_E2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-E2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_E3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-E3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_E4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-E4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_IC10_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-IC10]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_IC1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-IC1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_IC3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-IC3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_IC4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-IC4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_IC5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-IC5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_IC6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-IC6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_IC7_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-IC7]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_IC9_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-IC9]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_L0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-L0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_L1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-L1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_L2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-L2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_L3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-L3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_L4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-L4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_L5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-L5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_M1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-M1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_M2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-M2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_M3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-M3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_P2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-P2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_P3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-P3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_S0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-S0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_S1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-S1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_S2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-S2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_S3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-S3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_S4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-S4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_S5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-S5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_S6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-S6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_T2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-T2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_W2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-W2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_Z0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-Z0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_Z10_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-Z10]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_Z11_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-Z11]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_Z12_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-Z12]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_Z13_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-Z13]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_Z14_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-Z14]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_Z15_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-Z15]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_Z1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-Z1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_Z2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-Z2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_Z3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-Z3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_Z4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-Z4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_Z5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-Z5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_Z6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-Z6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_Z7_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-Z7]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_Z8_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-Z8]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Berlin_state_test_Z9_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Berlin-state_test-Z9]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_A1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-A1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_A2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-A2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_A3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-A3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_B1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-B1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_B2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-B2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_B4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-B4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_E1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-E1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_E2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-E2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_E3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-E3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_E4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-E4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_IC10_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-IC10]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_IC1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-IC1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_IC3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-IC3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_IC4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-IC4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_IC5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-IC5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_IC6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-IC6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_IC7_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-IC7]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_IC9_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-IC9]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_L0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-L0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_L1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-L1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_L2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-L2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_L3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-L3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_L4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-L4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_L5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-L5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_M1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-M1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_M2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-M2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_M3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-M3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_P2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-P2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_P3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-P3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_S0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-S0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_S1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-S1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_S2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-S2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_S3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-S3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_S4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-S4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_S5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-S5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_S6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-S6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_T2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-T2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_W2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-W2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_Z0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-Z0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_Z10_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-Z10]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_Z11_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-Z11]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_Z12_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-Z12]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_Z13_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-Z13]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_Z14_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-Z14]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_Z15_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-Z15]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_Z1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-Z1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_Z2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-Z2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_Z3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-Z3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_Z4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-Z4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_Z5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-Z5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_Z6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-Z6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_Z7_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-Z7]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_Z8_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-Z8]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Cancun_state_test_Z9_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Cancun-state_test-Z9]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_A1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-A1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_A2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-A2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_A3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-A3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_B1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-B1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_B2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-B2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_B4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-B4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_E1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-E1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_E2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-E2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_E3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-E3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_E4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-E4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_IC10_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-IC10]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_IC1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-IC1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_IC3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-IC3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_IC4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-IC4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_IC5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-IC5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_IC6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-IC6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_IC7_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-IC7]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_IC9_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-IC9]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_L0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-L0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_L1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-L1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_L2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-L2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_L3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-L3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_L4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-L4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_L5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-L5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_M1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-M1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_M2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-M2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_M3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-M3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_P2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-P2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_P3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-P3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_S0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-S0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_S1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-S1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_S2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-S2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_S3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-S3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_S4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-S4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_S5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-S5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_S6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-S6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_T2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-T2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_W2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-W2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_Z0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-Z0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_Z10_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-Z10]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_Z11_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-Z11]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_Z12_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-Z12]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_Z13_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-Z13]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_Z14_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-Z14]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_Z15_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-Z15]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_Z1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-Z1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_Z2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-Z2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_Z3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-Z3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_Z4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-Z4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_Z5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-Z5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_Z6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-Z6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_Z7_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-Z7]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_Z8_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-Z8]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_London_state_test_Z9_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_London-state_test-Z9]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_A1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-A1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_A2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-A2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_A3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-A3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_B1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-B1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_B2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-B2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_B4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-B4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_E1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-E1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_E2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-E2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_E3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-E3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_E4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-E4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_IC10_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-IC10]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_IC1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-IC1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_IC3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-IC3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_IC4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-IC4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_IC5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-IC5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_IC6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-IC6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_IC7_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-IC7]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_IC9_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-IC9]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_L0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-L0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_L1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-L1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_L2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-L2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_L3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-L3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_L4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-L4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_L5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-L5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_M1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-M1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_M2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-M2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_M3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-M3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_P2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-P2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_P3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-P3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_S0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-S0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_S1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-S1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_S2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-S2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_S3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-S3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_S4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-S4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_S5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-S5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_S6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-S6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_T2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-T2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_W2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-W2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_Z0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-Z0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_Z10_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-Z10]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_Z11_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-Z11]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_Z12_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-Z12]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_Z13_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-Z13]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_Z14_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-Z14]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_Z15_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-Z15]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_Z1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-Z1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_Z2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-Z2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_Z3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-Z3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_Z4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-Z4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_Z5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-Z5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_Z6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-Z6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_Z7_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-Z7]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_Z8_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-Z8]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Paris_state_test_Z9_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Paris-state_test-Z9]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_A1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-A1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_A2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-A2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_A3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-A3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_B1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-B1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_B2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-B2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_B4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-B4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_E1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-E1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_E2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-E2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_E3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-E3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_E4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-E4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_IC10_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-IC10]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_IC1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-IC1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_IC3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-IC3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_IC4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-IC4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_IC5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-IC5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_IC6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-IC6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_IC7_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-IC7]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_IC9_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-IC9]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_L0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-L0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_L1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-L1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_L2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-L2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_L3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-L3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_L4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-L4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_L5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-L5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_M1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-M1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_M2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-M2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_M3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-M3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_P2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-P2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_P3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-P3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_S0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-S0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_S1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-S1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_S2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-S2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_S3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-S3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_S4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-S4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_S5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-S5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_S6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-S6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_T2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-T2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_W2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-W2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_Z0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-Z0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_Z10_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-Z10]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_Z11_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-Z11]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_Z12_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-Z12]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_Z13_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-Z13]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_Z14_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-Z14]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_Z15_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-Z15]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_Z1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-Z1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_Z2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-Z2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_Z3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-Z3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_Z4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-Z4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_Z5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-Z5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_Z6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-Z6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_Z7_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-Z7]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_Z8_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-Z8]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Prague_state_test_Z9_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Prague-state_test-Z9]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_A1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-A1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_A2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-A2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_A3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-A3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_B1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-B1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_B2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-B2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_B4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-B4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_E1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-E1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_E2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-E2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_E3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-E3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_E4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-E4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_IC10_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-IC10]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_IC1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-IC1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_IC3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-IC3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_IC4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-IC4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_IC5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-IC5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_IC6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-IC6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_IC7_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-IC7]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_IC9_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-IC9]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_L0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-L0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_L1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-L1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_L2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-L2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_L3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-L3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_L4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-L4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_L5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-L5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_M1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-M1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_M2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-M2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_M3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-M3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_P2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-P2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_P3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-P3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_S0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-S0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_S1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-S1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_S2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-S2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_S3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-S3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_S4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-S4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_S5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-S5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_S6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-S6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_T2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-T2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_W2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-W2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_Z0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-Z0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_Z10_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-Z10]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_Z11_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-Z11]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_Z12_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-Z12]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_Z13_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-Z13]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_Z14_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-Z14]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_Z15_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-Z15]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_Z1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-Z1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_Z2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-Z2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_Z3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-Z3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_Z4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-Z4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_Z5_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-Z5]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_Z6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-Z6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_Z7_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-Z7]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_Z8_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-Z8]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_variable_gas_cost_fork_Shanghai_state_test_Z9_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_variable_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_variable_gas_cost[fork_Shanghai-state_test-Z9]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
