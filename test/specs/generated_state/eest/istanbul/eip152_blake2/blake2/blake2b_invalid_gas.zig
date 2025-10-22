const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Berlin_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Berlin-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Cancun_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Cancun-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Istanbul_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Istanbul-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_London_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_London-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Paris_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Paris-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Prague_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Prague-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data0_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data0-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data1_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data1-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data10_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data10-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data2_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data2-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data3_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data3-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_110000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_110000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_110000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_110000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_200000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_200000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_200000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_200000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_90000_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_90000-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_invalid_gas_fork_Shanghai_state_test_EIP_152_case1_data9_invalid_low_gas_gas_limit_90000_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_invalid_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_invalid_gas[fork_Shanghai-state_test-EIP-152-case1-data9-invalid-low-gas-gas_limit_90000-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
