const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_Berlin_state_test_base_heavy_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_Berlin-state_test-base-heavy-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_Berlin_state_test_base_heavy_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_Berlin-state_test-base-heavy-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_Berlin_state_test_base_heavy_call_opcode_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_Berlin-state_test-base-heavy-call_opcode_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_Berlin_state_test_base_heavy_call_opcode_STATICCALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_Berlin-state_test-base-heavy-call_opcode_STATICCALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_Cancun_state_test_base_heavy_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_Cancun-state_test-base-heavy-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_Cancun_state_test_base_heavy_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_Cancun-state_test-base-heavy-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_Cancun_state_test_base_heavy_call_opcode_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_Cancun-state_test-base-heavy-call_opcode_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_Cancun_state_test_base_heavy_call_opcode_STATICCALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_Cancun-state_test-base-heavy-call_opcode_STATICCALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_London_state_test_base_heavy_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_London-state_test-base-heavy-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_London_state_test_base_heavy_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_London-state_test-base-heavy-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_London_state_test_base_heavy_call_opcode_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_London-state_test-base-heavy-call_opcode_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_London_state_test_base_heavy_call_opcode_STATICCALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_London-state_test-base-heavy-call_opcode_STATICCALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_Paris_state_test_base_heavy_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_Paris-state_test-base-heavy-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_Paris_state_test_base_heavy_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_Paris-state_test-base-heavy-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_Paris_state_test_base_heavy_call_opcode_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_Paris-state_test-base-heavy-call_opcode_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_Paris_state_test_base_heavy_call_opcode_STATICCALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_Paris-state_test-base-heavy-call_opcode_STATICCALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_Prague_state_test_base_heavy_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_Prague-state_test-base-heavy-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_Prague_state_test_base_heavy_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_Prague-state_test-base-heavy-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_Prague_state_test_base_heavy_call_opcode_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_Prague-state_test-base-heavy-call_opcode_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_Prague_state_test_base_heavy_call_opcode_STATICCALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_Prague-state_test-base-heavy-call_opcode_STATICCALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_Shanghai_state_test_base_heavy_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_Shanghai-state_test-base-heavy-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_Shanghai_state_test_base_heavy_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_Shanghai-state_test-base-heavy-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_Shanghai_state_test_base_heavy_call_opcode_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_Shanghai-state_test-base-heavy-call_opcode_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_modexp_call_operations_fork_Shanghai_state_test_base_heavy_call_opcode_STATICCALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/modexp_call_operations.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_modexp_call_operations[fork_Shanghai-state_test-base-heavy-call_opcode_STATICCALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
