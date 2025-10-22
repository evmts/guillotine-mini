const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_OOG_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_OOG-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_OOG_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_OOG-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_OOG_call_type_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_OOG-call_type_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_OOG_call_type_STATICCALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_OOG-call_type_STATICCALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_RETURN_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_RETURN-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_RETURN_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_RETURN-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_RETURN_call_type_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_RETURN-call_type_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_RETURN_call_type_STATICCALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_RETURN-call_type_STATICCALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_REVERT_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_REVERT-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_REVERT_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_REVERT-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_REVERT_call_type_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_REVERT-call_type_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_REVERT_call_type_STATICCALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_REVERT-call_type_STATICCALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_OOG_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_OOG-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_OOG_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_OOG-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_OOG_call_type_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_OOG-call_type_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_OOG_call_type_STATICCALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_OOG-call_type_STATICCALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_RETURN_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_RETURN-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_RETURN_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_RETURN-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_RETURN_call_type_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_RETURN-call_type_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_RETURN_call_type_STATICCALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_RETURN-call_type_STATICCALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_REVERT_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_REVERT-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_REVERT_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_REVERT-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_REVERT_call_type_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_REVERT-call_type_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Cancun_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_REVERT_call_type_STATICCALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Cancun-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_REVERT-call_type_STATICCALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_OOG_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_OOG-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_OOG_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_OOG-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_OOG_call_type_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_OOG-call_type_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_OOG_call_type_STATICCALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_OOG-call_type_STATICCALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_RETURN_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_RETURN-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_RETURN_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_RETURN-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_RETURN_call_type_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_RETURN-call_type_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_RETURN_call_type_STATICCALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_RETURN-call_type_STATICCALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_REVERT_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_REVERT-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_REVERT_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_REVERT-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_REVERT_call_type_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_REVERT-call_type_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_EXTERNAL_CALL_call_return_REVERT_call_type_STATICCALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.EXTERNAL_CALL-call_return_REVERT-call_type_STATICCALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_OOG_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_OOG-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_OOG_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_OOG-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_OOG_call_type_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_OOG-call_type_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_OOG_call_type_STATICCALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_OOG-call_type_STATICCALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_RETURN_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_RETURN-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_RETURN_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_RETURN-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_RETURN_call_type_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_RETURN-call_type_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_RETURN_call_type_STATICCALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_RETURN-call_type_STATICCALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_REVERT_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_REVERT-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_REVERT_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_REVERT-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_REVERT_call_type_DELEGATECALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_REVERT-call_type_DELEGATECALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstore_reentrancy_py__test_tstore_reentrancy_fork_Prague_state_test_call_dest_type_CallDestType_REENTRANCY_call_return_REVERT_call_type_STATICCALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstore_reentrancy/tstore_reentrancy.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstore_reentrancy.py::test_tstore_reentrancy[fork_Prague-state_test-call_dest_type_CallDestType.REENTRANCY-call_return_REVERT-call_type_STATICCALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
