const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_0x055d4a80_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_0x055d4a80-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_0x055d4a80_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_0x055d4a80-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_0x055d4a80_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_0x055d4a80-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_0x055d4a80_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_0x055d4a80-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_0x055d4a80_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_0x055d4a80-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_0x055d4a80_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_0x055d4a80-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_0x055d4a80_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_0x055d4a80-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_0x055d4a80_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_0x055d4a80-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_0x055d4a80_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_0x055d4a80-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_0x055d4a80_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_0x055d4a80-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_110000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_110000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_110000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_110000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_110000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_110000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_110000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_110000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_110000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_110000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_110000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_110000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_110000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_110000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_110000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_110000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_110000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_110000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_110000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_110000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_200000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_200000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_200000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_200000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_200000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_200000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_200000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_200000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_200000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_200000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_200000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_200000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_200000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_200000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_200000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_200000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_200000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_200000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_200000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_200000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_90000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_90000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_90000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_90000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_90000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_90000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_90000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_90000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_90000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_90000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_90000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_90000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_90000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_90000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_90000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_90000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_90000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_90000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Berlin_gas_limit_90000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Berlin-gas_limit_90000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_0x055d4a80_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_0x055d4a80-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_0x055d4a80_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_0x055d4a80-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_0x055d4a80_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_0x055d4a80-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_0x055d4a80_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_0x055d4a80-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_0x055d4a80_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_0x055d4a80-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_0x055d4a80_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_0x055d4a80-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_0x055d4a80_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_0x055d4a80-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_0x055d4a80_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_0x055d4a80-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_0x055d4a80_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_0x055d4a80-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_0x055d4a80_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_0x055d4a80-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_110000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_110000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_110000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_110000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_110000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_110000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_110000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_110000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_110000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_110000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_110000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_110000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_110000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_110000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_110000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_110000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_110000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_110000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_110000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_110000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_200000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_200000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_200000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_200000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_200000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_200000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_200000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_200000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_200000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_200000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_200000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_200000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_200000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_200000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_200000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_200000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_200000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_200000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_200000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_200000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_90000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_90000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_90000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_90000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_90000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_90000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_90000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_90000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_90000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_90000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_90000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_90000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_90000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_90000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_90000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_90000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_90000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_90000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Cancun_gas_limit_90000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Cancun-gas_limit_90000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_0x055d4a80_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_0x055d4a80-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_0x055d4a80_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_0x055d4a80-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_0x055d4a80_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_0x055d4a80-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_0x055d4a80_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_0x055d4a80-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_0x055d4a80_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_0x055d4a80-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_0x055d4a80_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_0x055d4a80-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_0x055d4a80_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_0x055d4a80-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_0x055d4a80_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_0x055d4a80-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_0x055d4a80_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_0x055d4a80-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_0x055d4a80_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_0x055d4a80-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_110000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_110000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_110000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_110000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_110000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_110000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_110000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_110000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_110000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_110000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_110000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_110000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_110000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_110000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_110000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_110000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_110000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_110000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_110000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_110000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_200000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_200000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_200000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_200000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_200000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_200000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_200000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_200000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_200000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_200000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_200000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_200000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_200000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_200000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_200000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_200000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_200000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_200000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_200000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_200000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_90000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_90000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_90000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_90000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_90000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_90000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_90000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_90000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_90000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_90000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_90000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_90000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_90000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_90000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_90000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_90000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_90000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_90000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Istanbul_gas_limit_90000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Istanbul-gas_limit_90000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_0x055d4a80_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_0x055d4a80-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_0x055d4a80_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_0x055d4a80-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_0x055d4a80_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_0x055d4a80-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_0x055d4a80_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_0x055d4a80-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_0x055d4a80_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_0x055d4a80-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_0x055d4a80_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_0x055d4a80-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_0x055d4a80_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_0x055d4a80-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_0x055d4a80_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_0x055d4a80-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_0x055d4a80_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_0x055d4a80-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_0x055d4a80_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_0x055d4a80-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_110000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_110000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_110000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_110000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_110000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_110000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_110000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_110000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_110000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_110000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_110000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_110000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_110000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_110000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_110000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_110000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_110000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_110000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_110000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_110000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_200000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_200000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_200000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_200000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_200000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_200000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_200000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_200000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_200000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_200000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_200000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_200000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_200000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_200000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_200000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_200000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_200000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_200000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_200000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_200000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_90000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_90000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_90000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_90000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_90000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_90000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_90000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_90000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_90000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_90000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_90000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_90000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_90000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_90000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_90000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_90000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_90000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_90000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_London_gas_limit_90000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_London-gas_limit_90000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_0x055d4a80_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_0x055d4a80-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_0x055d4a80_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_0x055d4a80-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_0x055d4a80_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_0x055d4a80-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_0x055d4a80_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_0x055d4a80-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_0x055d4a80_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_0x055d4a80-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_0x055d4a80_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_0x055d4a80-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_0x055d4a80_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_0x055d4a80-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_0x055d4a80_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_0x055d4a80-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_0x055d4a80_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_0x055d4a80-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_0x055d4a80_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_0x055d4a80-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_110000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_110000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_110000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_110000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_110000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_110000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_110000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_110000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_110000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_110000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_110000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_110000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_110000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_110000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_110000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_110000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_110000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_110000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_110000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_110000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_200000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_200000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_200000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_200000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_200000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_200000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_200000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_200000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_200000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_200000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_200000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_200000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_200000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_200000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_200000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_200000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_200000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_200000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_200000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_200000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_90000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_90000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_90000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_90000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_90000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_90000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_90000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_90000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_90000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_90000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_90000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_90000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_90000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_90000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_90000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_90000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_90000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_90000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Paris_gas_limit_90000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Paris-gas_limit_90000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_0x055d4a80_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_0x055d4a80-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_0x055d4a80_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_0x055d4a80-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_0x055d4a80_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_0x055d4a80-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_0x055d4a80_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_0x055d4a80-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_0x055d4a80_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_0x055d4a80-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_0x055d4a80_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_0x055d4a80-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_0x055d4a80_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_0x055d4a80-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_0x055d4a80_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_0x055d4a80-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_0x055d4a80_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_0x055d4a80-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_0x055d4a80_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_0x055d4a80-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_110000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_110000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_110000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_110000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_110000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_110000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_110000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_110000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_110000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_110000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_110000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_110000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_110000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_110000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_110000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_110000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_110000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_110000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_110000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_110000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_200000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_200000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_200000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_200000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_200000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_200000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_200000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_200000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_200000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_200000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_200000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_200000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_200000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_200000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_200000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_200000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_200000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_200000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_200000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_200000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_90000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_90000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_90000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_90000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_90000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_90000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_90000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_90000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_90000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_90000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_90000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_90000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_90000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_90000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_90000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_90000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_90000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_90000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Prague_gas_limit_90000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Prague-gas_limit_90000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_0x055d4a80_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_0x055d4a80-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_0x055d4a80_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_0x055d4a80-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_0x055d4a80_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_0x055d4a80-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_0x055d4a80_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_0x055d4a80-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_0x055d4a80_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_0x055d4a80-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_0x055d4a80_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_0x055d4a80-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_0x055d4a80_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_0x055d4a80-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_0x055d4a80_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_0x055d4a80-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_0x055d4a80_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_0x055d4a80-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_0x055d4a80_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_0x055d4a80-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_110000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_110000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_110000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_110000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_110000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_110000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_110000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_110000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_110000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_110000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_110000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_110000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_110000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_110000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_110000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_110000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_110000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_110000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_110000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_110000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_200000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_200000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_200000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_200000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_200000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_200000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_200000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_200000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_200000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_200000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_200000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_200000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_200000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_200000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_200000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_200000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_200000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_200000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_200000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_200000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_90000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_90000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_90000_state_test_EIP_152_case3_data4_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_90000-state_test-EIP-152-case3-data4-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_90000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_90000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_90000_state_test_EIP_152_case4_data5_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_90000-state_test-EIP-152-case4-data5-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_90000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_90000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_90000_state_test_EIP_152_case5_data6_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_90000-state_test-EIP-152-case5-data6-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_90000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_90000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_90000_state_test_EIP_152_case6_data7_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_90000-state_test-EIP-152-case6-data7-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_90000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_90000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_py__test_blake2b_gas_limit_fork_Shanghai_gas_limit_90000_state_test_EIP_152_case7_data8_gas_limit_call_opcode_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2/blake2b_gas_limit.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2.py::test_blake2b_gas_limit[fork_Shanghai-gas_limit_90000-state_test-EIP-152-case7-data8-gas-limit-call_opcode_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
