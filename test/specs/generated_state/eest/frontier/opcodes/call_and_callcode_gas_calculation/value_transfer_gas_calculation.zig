const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_frontier_opcodes_test_call_and_callcode_gas_calculation_py__test_value_transfer_gas_calculation_fork_Cancun_state_test_callee_opcode_CALL_caller_gas_limit_36619_is_sufficient_gas_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/opcodes/call_and_callcode_gas_calculation/value_transfer_gas_calculation.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/opcodes/test_call_and_callcode_gas_calculation.py::test_value_transfer_gas_calculation[fork_Cancun-state_test-callee_opcode_CALL-caller_gas_limit_36619-is_sufficient_gas_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_opcodes_test_call_and_callcode_gas_calculation_py__test_value_transfer_gas_calculation_fork_Cancun_state_test_callee_opcode_CALL_caller_gas_limit_36620_is_sufficient_gas_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/opcodes/call_and_callcode_gas_calculation/value_transfer_gas_calculation.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/opcodes/test_call_and_callcode_gas_calculation.py::test_value_transfer_gas_calculation[fork_Cancun-state_test-callee_opcode_CALL-caller_gas_limit_36620-is_sufficient_gas_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_opcodes_test_call_and_callcode_gas_calculation_py__test_value_transfer_gas_calculation_fork_Cancun_state_test_callee_opcode_CALLCODE_caller_gas_limit_11619_is_sufficient_gas_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/opcodes/call_and_callcode_gas_calculation/value_transfer_gas_calculation.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/opcodes/test_call_and_callcode_gas_calculation.py::test_value_transfer_gas_calculation[fork_Cancun-state_test-callee_opcode_CALLCODE-caller_gas_limit_11619-is_sufficient_gas_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_opcodes_test_call_and_callcode_gas_calculation_py__test_value_transfer_gas_calculation_fork_Cancun_state_test_callee_opcode_CALLCODE_caller_gas_limit_11620_is_sufficient_gas_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/opcodes/call_and_callcode_gas_calculation/value_transfer_gas_calculation.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/opcodes/test_call_and_callcode_gas_calculation.py::test_value_transfer_gas_calculation[fork_Cancun-state_test-callee_opcode_CALLCODE-caller_gas_limit_11620-is_sufficient_gas_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_opcodes_test_call_and_callcode_gas_calculation_py__test_value_transfer_gas_calculation_fork_London_state_test_callee_opcode_CALL_caller_gas_limit_36619_is_sufficient_gas_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/opcodes/call_and_callcode_gas_calculation/value_transfer_gas_calculation.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/opcodes/test_call_and_callcode_gas_calculation.py::test_value_transfer_gas_calculation[fork_London-state_test-callee_opcode_CALL-caller_gas_limit_36619-is_sufficient_gas_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_opcodes_test_call_and_callcode_gas_calculation_py__test_value_transfer_gas_calculation_fork_London_state_test_callee_opcode_CALL_caller_gas_limit_36620_is_sufficient_gas_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/opcodes/call_and_callcode_gas_calculation/value_transfer_gas_calculation.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/opcodes/test_call_and_callcode_gas_calculation.py::test_value_transfer_gas_calculation[fork_London-state_test-callee_opcode_CALL-caller_gas_limit_36620-is_sufficient_gas_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_opcodes_test_call_and_callcode_gas_calculation_py__test_value_transfer_gas_calculation_fork_London_state_test_callee_opcode_CALLCODE_caller_gas_limit_11619_is_sufficient_gas_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/opcodes/call_and_callcode_gas_calculation/value_transfer_gas_calculation.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/opcodes/test_call_and_callcode_gas_calculation.py::test_value_transfer_gas_calculation[fork_London-state_test-callee_opcode_CALLCODE-caller_gas_limit_11619-is_sufficient_gas_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_opcodes_test_call_and_callcode_gas_calculation_py__test_value_transfer_gas_calculation_fork_London_state_test_callee_opcode_CALLCODE_caller_gas_limit_11620_is_sufficient_gas_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/opcodes/call_and_callcode_gas_calculation/value_transfer_gas_calculation.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/opcodes/test_call_and_callcode_gas_calculation.py::test_value_transfer_gas_calculation[fork_London-state_test-callee_opcode_CALLCODE-caller_gas_limit_11620-is_sufficient_gas_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_opcodes_test_call_and_callcode_gas_calculation_py__test_value_transfer_gas_calculation_fork_Paris_state_test_callee_opcode_CALL_caller_gas_limit_36619_is_sufficient_gas_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/opcodes/call_and_callcode_gas_calculation/value_transfer_gas_calculation.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/opcodes/test_call_and_callcode_gas_calculation.py::test_value_transfer_gas_calculation[fork_Paris-state_test-callee_opcode_CALL-caller_gas_limit_36619-is_sufficient_gas_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_opcodes_test_call_and_callcode_gas_calculation_py__test_value_transfer_gas_calculation_fork_Paris_state_test_callee_opcode_CALL_caller_gas_limit_36620_is_sufficient_gas_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/opcodes/call_and_callcode_gas_calculation/value_transfer_gas_calculation.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/opcodes/test_call_and_callcode_gas_calculation.py::test_value_transfer_gas_calculation[fork_Paris-state_test-callee_opcode_CALL-caller_gas_limit_36620-is_sufficient_gas_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_opcodes_test_call_and_callcode_gas_calculation_py__test_value_transfer_gas_calculation_fork_Paris_state_test_callee_opcode_CALLCODE_caller_gas_limit_11619_is_sufficient_gas_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/opcodes/call_and_callcode_gas_calculation/value_transfer_gas_calculation.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/opcodes/test_call_and_callcode_gas_calculation.py::test_value_transfer_gas_calculation[fork_Paris-state_test-callee_opcode_CALLCODE-caller_gas_limit_11619-is_sufficient_gas_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_opcodes_test_call_and_callcode_gas_calculation_py__test_value_transfer_gas_calculation_fork_Paris_state_test_callee_opcode_CALLCODE_caller_gas_limit_11620_is_sufficient_gas_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/opcodes/call_and_callcode_gas_calculation/value_transfer_gas_calculation.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/opcodes/test_call_and_callcode_gas_calculation.py::test_value_transfer_gas_calculation[fork_Paris-state_test-callee_opcode_CALLCODE-caller_gas_limit_11620-is_sufficient_gas_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_opcodes_test_call_and_callcode_gas_calculation_py__test_value_transfer_gas_calculation_fork_Prague_state_test_callee_opcode_CALL_caller_gas_limit_36619_is_sufficient_gas_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/opcodes/call_and_callcode_gas_calculation/value_transfer_gas_calculation.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/opcodes/test_call_and_callcode_gas_calculation.py::test_value_transfer_gas_calculation[fork_Prague-state_test-callee_opcode_CALL-caller_gas_limit_36619-is_sufficient_gas_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_opcodes_test_call_and_callcode_gas_calculation_py__test_value_transfer_gas_calculation_fork_Prague_state_test_callee_opcode_CALL_caller_gas_limit_36620_is_sufficient_gas_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/opcodes/call_and_callcode_gas_calculation/value_transfer_gas_calculation.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/opcodes/test_call_and_callcode_gas_calculation.py::test_value_transfer_gas_calculation[fork_Prague-state_test-callee_opcode_CALL-caller_gas_limit_36620-is_sufficient_gas_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_opcodes_test_call_and_callcode_gas_calculation_py__test_value_transfer_gas_calculation_fork_Prague_state_test_callee_opcode_CALLCODE_caller_gas_limit_11619_is_sufficient_gas_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/opcodes/call_and_callcode_gas_calculation/value_transfer_gas_calculation.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/opcodes/test_call_and_callcode_gas_calculation.py::test_value_transfer_gas_calculation[fork_Prague-state_test-callee_opcode_CALLCODE-caller_gas_limit_11619-is_sufficient_gas_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_opcodes_test_call_and_callcode_gas_calculation_py__test_value_transfer_gas_calculation_fork_Prague_state_test_callee_opcode_CALLCODE_caller_gas_limit_11620_is_sufficient_gas_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/opcodes/call_and_callcode_gas_calculation/value_transfer_gas_calculation.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/opcodes/test_call_and_callcode_gas_calculation.py::test_value_transfer_gas_calculation[fork_Prague-state_test-callee_opcode_CALLCODE-caller_gas_limit_11620-is_sufficient_gas_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_opcodes_test_call_and_callcode_gas_calculation_py__test_value_transfer_gas_calculation_fork_Shanghai_state_test_callee_opcode_CALL_caller_gas_limit_36619_is_sufficient_gas_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/opcodes/call_and_callcode_gas_calculation/value_transfer_gas_calculation.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/opcodes/test_call_and_callcode_gas_calculation.py::test_value_transfer_gas_calculation[fork_Shanghai-state_test-callee_opcode_CALL-caller_gas_limit_36619-is_sufficient_gas_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_opcodes_test_call_and_callcode_gas_calculation_py__test_value_transfer_gas_calculation_fork_Shanghai_state_test_callee_opcode_CALL_caller_gas_limit_36620_is_sufficient_gas_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/opcodes/call_and_callcode_gas_calculation/value_transfer_gas_calculation.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/opcodes/test_call_and_callcode_gas_calculation.py::test_value_transfer_gas_calculation[fork_Shanghai-state_test-callee_opcode_CALL-caller_gas_limit_36620-is_sufficient_gas_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_opcodes_test_call_and_callcode_gas_calculation_py__test_value_transfer_gas_calculation_fork_Shanghai_state_test_callee_opcode_CALLCODE_caller_gas_limit_11619_is_sufficient_gas_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/opcodes/call_and_callcode_gas_calculation/value_transfer_gas_calculation.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/opcodes/test_call_and_callcode_gas_calculation.py::test_value_transfer_gas_calculation[fork_Shanghai-state_test-callee_opcode_CALLCODE-caller_gas_limit_11619-is_sufficient_gas_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_opcodes_test_call_and_callcode_gas_calculation_py__test_value_transfer_gas_calculation_fork_Shanghai_state_test_callee_opcode_CALLCODE_caller_gas_limit_11620_is_sufficient_gas_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/opcodes/call_and_callcode_gas_calculation/value_transfer_gas_calculation.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/opcodes/test_call_and_callcode_gas_calculation.py::test_value_transfer_gas_calculation[fork_Shanghai-state_test-callee_opcode_CALLCODE-caller_gas_limit_11620-is_sufficient_gas_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
