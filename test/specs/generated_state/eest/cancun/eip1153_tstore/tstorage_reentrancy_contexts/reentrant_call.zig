const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_cancun_eip1153_tstore_test_tstorage_reentrancy_contexts_py__test_reentrant_call_fork_Cancun_state_test_invalid_undoes_all_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_reentrancy_contexts/reentrant_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_reentrancy_contexts.py::test_reentrant_call[fork_Cancun-state_test-invalid_undoes_all]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_reentrancy_contexts_py__test_reentrant_call_fork_Cancun_state_test_invalid_undoes_tstorage_after_successful_call_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_reentrancy_contexts/reentrant_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_reentrancy_contexts.py::test_reentrant_call[fork_Cancun-state_test-invalid_undoes_tstorage_after_successful_call]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_reentrancy_contexts_py__test_reentrant_call_fork_Cancun_state_test_manipulate_in_reentrant_call_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_reentrancy_contexts/reentrant_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_reentrancy_contexts.py::test_reentrant_call[fork_Cancun-state_test-manipulate_in_reentrant_call]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_reentrancy_contexts_py__test_reentrant_call_fork_Cancun_state_test_revert_undoes_all_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_reentrancy_contexts/reentrant_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_reentrancy_contexts.py::test_reentrant_call[fork_Cancun-state_test-revert_undoes_all]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_reentrancy_contexts_py__test_reentrant_call_fork_Cancun_state_test_revert_undoes_tstorage_after_successful_call_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_reentrancy_contexts/reentrant_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_reentrancy_contexts.py::test_reentrant_call[fork_Cancun-state_test-revert_undoes_tstorage_after_successful_call]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_reentrancy_contexts_py__test_reentrant_call_fork_Cancun_state_test_tload_after_reentrant_tstore_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_reentrancy_contexts/reentrant_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_reentrancy_contexts.py::test_reentrant_call[fork_Cancun-state_test-tload_after_reentrant_tstore]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_reentrancy_contexts_py__test_reentrant_call_fork_Cancun_state_test_tstore_before_invalid_has_no_effect_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_reentrancy_contexts/reentrant_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_reentrancy_contexts.py::test_reentrant_call[fork_Cancun-state_test-tstore_before_invalid_has_no_effect]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_reentrancy_contexts_py__test_reentrant_call_fork_Cancun_state_test_tstore_before_revert_has_no_effect_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_reentrancy_contexts/reentrant_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_reentrancy_contexts.py::test_reentrant_call[fork_Cancun-state_test-tstore_before_revert_has_no_effect]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_reentrancy_contexts_py__test_reentrant_call_fork_Cancun_state_test_tstore_in_call_then_tload_return_in_staticcall_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_reentrancy_contexts/reentrant_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_reentrancy_contexts.py::test_reentrant_call[fork_Cancun-state_test-tstore_in_call_then_tload_return_in_staticcall]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_reentrancy_contexts_py__test_reentrant_call_fork_Cancun_state_test_tstore_in_reentrant_call_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_reentrancy_contexts/reentrant_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_reentrancy_contexts.py::test_reentrant_call[fork_Cancun-state_test-tstore_in_reentrant_call]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_reentrancy_contexts_py__test_reentrant_call_fork_Prague_state_test_invalid_undoes_all_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_reentrancy_contexts/reentrant_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_reentrancy_contexts.py::test_reentrant_call[fork_Prague-state_test-invalid_undoes_all]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_reentrancy_contexts_py__test_reentrant_call_fork_Prague_state_test_invalid_undoes_tstorage_after_successful_call_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_reentrancy_contexts/reentrant_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_reentrancy_contexts.py::test_reentrant_call[fork_Prague-state_test-invalid_undoes_tstorage_after_successful_call]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_reentrancy_contexts_py__test_reentrant_call_fork_Prague_state_test_manipulate_in_reentrant_call_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_reentrancy_contexts/reentrant_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_reentrancy_contexts.py::test_reentrant_call[fork_Prague-state_test-manipulate_in_reentrant_call]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_reentrancy_contexts_py__test_reentrant_call_fork_Prague_state_test_revert_undoes_all_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_reentrancy_contexts/reentrant_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_reentrancy_contexts.py::test_reentrant_call[fork_Prague-state_test-revert_undoes_all]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_reentrancy_contexts_py__test_reentrant_call_fork_Prague_state_test_revert_undoes_tstorage_after_successful_call_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_reentrancy_contexts/reentrant_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_reentrancy_contexts.py::test_reentrant_call[fork_Prague-state_test-revert_undoes_tstorage_after_successful_call]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_reentrancy_contexts_py__test_reentrant_call_fork_Prague_state_test_tload_after_reentrant_tstore_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_reentrancy_contexts/reentrant_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_reentrancy_contexts.py::test_reentrant_call[fork_Prague-state_test-tload_after_reentrant_tstore]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_reentrancy_contexts_py__test_reentrant_call_fork_Prague_state_test_tstore_before_invalid_has_no_effect_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_reentrancy_contexts/reentrant_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_reentrancy_contexts.py::test_reentrant_call[fork_Prague-state_test-tstore_before_invalid_has_no_effect]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_reentrancy_contexts_py__test_reentrant_call_fork_Prague_state_test_tstore_before_revert_has_no_effect_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_reentrancy_contexts/reentrant_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_reentrancy_contexts.py::test_reentrant_call[fork_Prague-state_test-tstore_before_revert_has_no_effect]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_reentrancy_contexts_py__test_reentrant_call_fork_Prague_state_test_tstore_in_call_then_tload_return_in_staticcall_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_reentrancy_contexts/reentrant_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_reentrancy_contexts.py::test_reentrant_call[fork_Prague-state_test-tstore_in_call_then_tload_return_in_staticcall]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_reentrancy_contexts_py__test_reentrant_call_fork_Prague_state_test_tstore_in_reentrant_call_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage_reentrancy_contexts/reentrant_call.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage_reentrancy_contexts.py::test_reentrant_call[fork_Prague-state_test-tstore_in_reentrant_call]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
