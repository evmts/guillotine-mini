const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_account_storage_warm_cold_state_fork_Berlin_state_test_account_warm_False_storage_key_warm_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/account_storage_warm_cold_state.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_account_storage_warm_cold_state[fork_Berlin-state_test-account_warm_False-storage_key_warm_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_account_storage_warm_cold_state_fork_Berlin_state_test_account_warm_True_storage_key_warm_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/account_storage_warm_cold_state.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_account_storage_warm_cold_state[fork_Berlin-state_test-account_warm_True-storage_key_warm_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_account_storage_warm_cold_state_fork_Berlin_state_test_account_warm_True_storage_key_warm_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/account_storage_warm_cold_state.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_account_storage_warm_cold_state[fork_Berlin-state_test-account_warm_True-storage_key_warm_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_account_storage_warm_cold_state_fork_Cancun_state_test_account_warm_False_storage_key_warm_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/account_storage_warm_cold_state.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_account_storage_warm_cold_state[fork_Cancun-state_test-account_warm_False-storage_key_warm_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_account_storage_warm_cold_state_fork_Cancun_state_test_account_warm_True_storage_key_warm_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/account_storage_warm_cold_state.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_account_storage_warm_cold_state[fork_Cancun-state_test-account_warm_True-storage_key_warm_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_account_storage_warm_cold_state_fork_Cancun_state_test_account_warm_True_storage_key_warm_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/account_storage_warm_cold_state.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_account_storage_warm_cold_state[fork_Cancun-state_test-account_warm_True-storage_key_warm_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_account_storage_warm_cold_state_fork_London_state_test_account_warm_False_storage_key_warm_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/account_storage_warm_cold_state.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_account_storage_warm_cold_state[fork_London-state_test-account_warm_False-storage_key_warm_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_account_storage_warm_cold_state_fork_London_state_test_account_warm_True_storage_key_warm_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/account_storage_warm_cold_state.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_account_storage_warm_cold_state[fork_London-state_test-account_warm_True-storage_key_warm_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_account_storage_warm_cold_state_fork_London_state_test_account_warm_True_storage_key_warm_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/account_storage_warm_cold_state.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_account_storage_warm_cold_state[fork_London-state_test-account_warm_True-storage_key_warm_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_account_storage_warm_cold_state_fork_Paris_state_test_account_warm_False_storage_key_warm_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/account_storage_warm_cold_state.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_account_storage_warm_cold_state[fork_Paris-state_test-account_warm_False-storage_key_warm_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_account_storage_warm_cold_state_fork_Paris_state_test_account_warm_True_storage_key_warm_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/account_storage_warm_cold_state.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_account_storage_warm_cold_state[fork_Paris-state_test-account_warm_True-storage_key_warm_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_account_storage_warm_cold_state_fork_Paris_state_test_account_warm_True_storage_key_warm_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/account_storage_warm_cold_state.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_account_storage_warm_cold_state[fork_Paris-state_test-account_warm_True-storage_key_warm_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_account_storage_warm_cold_state_fork_Prague_state_test_account_warm_False_storage_key_warm_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/account_storage_warm_cold_state.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_account_storage_warm_cold_state[fork_Prague-state_test-account_warm_False-storage_key_warm_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_account_storage_warm_cold_state_fork_Prague_state_test_account_warm_True_storage_key_warm_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/account_storage_warm_cold_state.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_account_storage_warm_cold_state[fork_Prague-state_test-account_warm_True-storage_key_warm_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_account_storage_warm_cold_state_fork_Prague_state_test_account_warm_True_storage_key_warm_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/account_storage_warm_cold_state.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_account_storage_warm_cold_state[fork_Prague-state_test-account_warm_True-storage_key_warm_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_account_storage_warm_cold_state_fork_Shanghai_state_test_account_warm_False_storage_key_warm_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/account_storage_warm_cold_state.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_account_storage_warm_cold_state[fork_Shanghai-state_test-account_warm_False-storage_key_warm_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_account_storage_warm_cold_state_fork_Shanghai_state_test_account_warm_True_storage_key_warm_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/account_storage_warm_cold_state.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_account_storage_warm_cold_state[fork_Shanghai-state_test-account_warm_True-storage_key_warm_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_account_storage_warm_cold_state_fork_Shanghai_state_test_account_warm_True_storage_key_warm_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/account_storage_warm_cold_state.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_account_storage_warm_cold_state[fork_Shanghai-state_test-account_warm_True-storage_key_warm_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
