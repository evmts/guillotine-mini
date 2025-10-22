const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_cancun_eip1153_tstore_test_tstorage_selfdestruct_py__test_reentrant_selfdestructing_call_fork_Cancun_state_test_tload_after_inner_selfdestruct_new_contract_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_selfdestruct/reentrant_selfdestructing_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_selfdestruct.py::test_reentrant_selfdestructing_call[fork_Cancun-state_test-tload_after_inner_selfdestruct_new_contract]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_selfdestruct_py__test_reentrant_selfdestructing_call_fork_Cancun_state_test_tload_after_inner_selfdestruct_pre_existing_contract_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_selfdestruct/reentrant_selfdestructing_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_selfdestruct.py::test_reentrant_selfdestructing_call[fork_Cancun-state_test-tload_after_inner_selfdestruct_pre_existing_contract]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_selfdestruct_py__test_reentrant_selfdestructing_call_fork_Cancun_state_test_tload_after_selfdestruct_new_contract_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_selfdestruct/reentrant_selfdestructing_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_selfdestruct.py::test_reentrant_selfdestructing_call[fork_Cancun-state_test-tload_after_selfdestruct_new_contract]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_selfdestruct_py__test_reentrant_selfdestructing_call_fork_Cancun_state_test_tload_after_selfdestruct_pre_existing_contract_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_selfdestruct/reentrant_selfdestructing_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_selfdestruct.py::test_reentrant_selfdestructing_call[fork_Cancun-state_test-tload_after_selfdestruct_pre_existing_contract]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_selfdestruct_py__test_reentrant_selfdestructing_call_fork_Cancun_state_test_tstore_after_selfdestruct_new_contract_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_selfdestruct/reentrant_selfdestructing_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_selfdestruct.py::test_reentrant_selfdestructing_call[fork_Cancun-state_test-tstore_after_selfdestruct_new_contract]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_selfdestruct_py__test_reentrant_selfdestructing_call_fork_Cancun_state_test_tstore_after_selfdestruct_pre_existing_contract_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_selfdestruct/reentrant_selfdestructing_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_selfdestruct.py::test_reentrant_selfdestructing_call[fork_Cancun-state_test-tstore_after_selfdestruct_pre_existing_contract]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_selfdestruct_py__test_reentrant_selfdestructing_call_fork_Prague_state_test_tload_after_inner_selfdestruct_new_contract_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_selfdestruct/reentrant_selfdestructing_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_selfdestruct.py::test_reentrant_selfdestructing_call[fork_Prague-state_test-tload_after_inner_selfdestruct_new_contract]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_selfdestruct_py__test_reentrant_selfdestructing_call_fork_Prague_state_test_tload_after_inner_selfdestruct_pre_existing_contract_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_selfdestruct/reentrant_selfdestructing_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_selfdestruct.py::test_reentrant_selfdestructing_call[fork_Prague-state_test-tload_after_inner_selfdestruct_pre_existing_contract]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_selfdestruct_py__test_reentrant_selfdestructing_call_fork_Prague_state_test_tload_after_selfdestruct_new_contract_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_selfdestruct/reentrant_selfdestructing_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_selfdestruct.py::test_reentrant_selfdestructing_call[fork_Prague-state_test-tload_after_selfdestruct_new_contract]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_selfdestruct_py__test_reentrant_selfdestructing_call_fork_Prague_state_test_tload_after_selfdestruct_pre_existing_contract_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_selfdestruct/reentrant_selfdestructing_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_selfdestruct.py::test_reentrant_selfdestructing_call[fork_Prague-state_test-tload_after_selfdestruct_pre_existing_contract]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_selfdestruct_py__test_reentrant_selfdestructing_call_fork_Prague_state_test_tstore_after_selfdestruct_new_contract_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_selfdestruct/reentrant_selfdestructing_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_selfdestruct.py::test_reentrant_selfdestructing_call[fork_Prague-state_test-tstore_after_selfdestruct_new_contract]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_selfdestruct_py__test_reentrant_selfdestructing_call_fork_Prague_state_test_tstore_after_selfdestruct_pre_existing_contract_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_selfdestruct/reentrant_selfdestructing_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_selfdestruct.py::test_reentrant_selfdestructing_call[fork_Prague-state_test-tstore_after_selfdestruct_pre_existing_contract]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
