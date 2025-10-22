const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Cancun_state_test_second_suicide_CALL_first_suicide_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Cancun-state_test-second_suicide_CALL-first_suicide_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Cancun_state_test_second_suicide_CALL_first_suicide_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Cancun-state_test-second_suicide_CALL-first_suicide_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Cancun_state_test_second_suicide_CALL_first_suicide_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Cancun-state_test-second_suicide_CALL-first_suicide_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Cancun_state_test_second_suicide_CALLCODE_first_suicide_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Cancun-state_test-second_suicide_CALLCODE-first_suicide_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Cancun_state_test_second_suicide_CALLCODE_first_suicide_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Cancun-state_test-second_suicide_CALLCODE-first_suicide_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Cancun_state_test_second_suicide_CALLCODE_first_suicide_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Cancun-state_test-second_suicide_CALLCODE-first_suicide_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Cancun_state_test_second_suicide_DELEGATECALL_first_suicide_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Cancun-state_test-second_suicide_DELEGATECALL-first_suicide_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Cancun_state_test_second_suicide_DELEGATECALL_first_suicide_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Cancun-state_test-second_suicide_DELEGATECALL-first_suicide_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Cancun_state_test_second_suicide_DELEGATECALL_first_suicide_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Cancun-state_test-second_suicide_DELEGATECALL-first_suicide_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Paris_state_test_second_suicide_CALL_first_suicide_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Paris-state_test-second_suicide_CALL-first_suicide_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Paris_state_test_second_suicide_CALL_first_suicide_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Paris-state_test-second_suicide_CALL-first_suicide_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Paris_state_test_second_suicide_CALL_first_suicide_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Paris-state_test-second_suicide_CALL-first_suicide_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Paris_state_test_second_suicide_CALLCODE_first_suicide_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Paris-state_test-second_suicide_CALLCODE-first_suicide_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Paris_state_test_second_suicide_CALLCODE_first_suicide_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Paris-state_test-second_suicide_CALLCODE-first_suicide_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Paris_state_test_second_suicide_CALLCODE_first_suicide_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Paris-state_test-second_suicide_CALLCODE-first_suicide_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Paris_state_test_second_suicide_DELEGATECALL_first_suicide_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Paris-state_test-second_suicide_DELEGATECALL-first_suicide_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Paris_state_test_second_suicide_DELEGATECALL_first_suicide_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Paris-state_test-second_suicide_DELEGATECALL-first_suicide_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Paris_state_test_second_suicide_DELEGATECALL_first_suicide_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Paris-state_test-second_suicide_DELEGATECALL-first_suicide_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Prague_state_test_second_suicide_CALL_first_suicide_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Prague-state_test-second_suicide_CALL-first_suicide_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Prague_state_test_second_suicide_CALL_first_suicide_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Prague-state_test-second_suicide_CALL-first_suicide_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Prague_state_test_second_suicide_CALL_first_suicide_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Prague-state_test-second_suicide_CALL-first_suicide_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Prague_state_test_second_suicide_CALLCODE_first_suicide_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Prague-state_test-second_suicide_CALLCODE-first_suicide_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Prague_state_test_second_suicide_CALLCODE_first_suicide_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Prague-state_test-second_suicide_CALLCODE-first_suicide_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Prague_state_test_second_suicide_CALLCODE_first_suicide_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Prague-state_test-second_suicide_CALLCODE-first_suicide_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Prague_state_test_second_suicide_DELEGATECALL_first_suicide_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Prague-state_test-second_suicide_DELEGATECALL-first_suicide_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Prague_state_test_second_suicide_DELEGATECALL_first_suicide_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Prague-state_test-second_suicide_DELEGATECALL-first_suicide_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Prague_state_test_second_suicide_DELEGATECALL_first_suicide_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Prague-state_test-second_suicide_DELEGATECALL-first_suicide_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Shanghai_state_test_second_suicide_CALL_first_suicide_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Shanghai-state_test-second_suicide_CALL-first_suicide_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Shanghai_state_test_second_suicide_CALL_first_suicide_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Shanghai-state_test-second_suicide_CALL-first_suicide_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Shanghai_state_test_second_suicide_CALL_first_suicide_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Shanghai-state_test-second_suicide_CALL-first_suicide_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Shanghai_state_test_second_suicide_CALLCODE_first_suicide_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Shanghai-state_test-second_suicide_CALLCODE-first_suicide_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Shanghai_state_test_second_suicide_CALLCODE_first_suicide_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Shanghai-state_test-second_suicide_CALLCODE-first_suicide_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Shanghai_state_test_second_suicide_CALLCODE_first_suicide_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Shanghai-state_test-second_suicide_CALLCODE-first_suicide_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Shanghai_state_test_second_suicide_DELEGATECALL_first_suicide_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Shanghai-state_test-second_suicide_DELEGATECALL-first_suicide_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Shanghai_state_test_second_suicide_DELEGATECALL_first_suicide_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Shanghai-state_test-second_suicide_DELEGATECALL-first_suicide_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_reentrancy_selfdestruct_revert_py__test_reentrancy_selfdestruct_revert_fork_Shanghai_state_test_second_suicide_DELEGATECALL_first_suicide_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/reentrancy_selfdestruct_revert/reentrancy_selfdestruct_revert.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_reentrancy_selfdestruct_revert.py::test_reentrancy_selfdestruct_revert[fork_Shanghai-state_test-second_suicide_DELEGATECALL-first_suicide_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
