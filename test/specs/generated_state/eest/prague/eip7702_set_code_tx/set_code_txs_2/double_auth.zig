const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_2_py__test_double_auth_fork_Prague_state_test_second_delegation_DelegationTo_CONTRACT_A_first_delegation_DelegationTo_CONTRACT_A_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs_2/double_auth.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs_2.py::test_double_auth[fork_Prague-state_test-second_delegation_DelegationTo.CONTRACT_A-first_delegation_DelegationTo.CONTRACT_A]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_2_py__test_double_auth_fork_Prague_state_test_second_delegation_DelegationTo_CONTRACT_A_first_delegation_DelegationTo_CONTRACT_B_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs_2/double_auth.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs_2.py::test_double_auth[fork_Prague-state_test-second_delegation_DelegationTo.CONTRACT_A-first_delegation_DelegationTo.CONTRACT_B]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_2_py__test_double_auth_fork_Prague_state_test_second_delegation_DelegationTo_CONTRACT_A_first_delegation_DelegationTo_RESET_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs_2/double_auth.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs_2.py::test_double_auth[fork_Prague-state_test-second_delegation_DelegationTo.CONTRACT_A-first_delegation_DelegationTo.RESET]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_2_py__test_double_auth_fork_Prague_state_test_second_delegation_DelegationTo_CONTRACT_B_first_delegation_DelegationTo_CONTRACT_A_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs_2/double_auth.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs_2.py::test_double_auth[fork_Prague-state_test-second_delegation_DelegationTo.CONTRACT_B-first_delegation_DelegationTo.CONTRACT_A]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_2_py__test_double_auth_fork_Prague_state_test_second_delegation_DelegationTo_CONTRACT_B_first_delegation_DelegationTo_CONTRACT_B_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs_2/double_auth.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs_2.py::test_double_auth[fork_Prague-state_test-second_delegation_DelegationTo.CONTRACT_B-first_delegation_DelegationTo.CONTRACT_B]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_2_py__test_double_auth_fork_Prague_state_test_second_delegation_DelegationTo_CONTRACT_B_first_delegation_DelegationTo_RESET_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs_2/double_auth.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs_2.py::test_double_auth[fork_Prague-state_test-second_delegation_DelegationTo.CONTRACT_B-first_delegation_DelegationTo.RESET]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_2_py__test_double_auth_fork_Prague_state_test_second_delegation_DelegationTo_RESET_first_delegation_DelegationTo_CONTRACT_A_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs_2/double_auth.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs_2.py::test_double_auth[fork_Prague-state_test-second_delegation_DelegationTo.RESET-first_delegation_DelegationTo.CONTRACT_A]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_2_py__test_double_auth_fork_Prague_state_test_second_delegation_DelegationTo_RESET_first_delegation_DelegationTo_CONTRACT_B_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs_2/double_auth.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs_2.py::test_double_auth[fork_Prague-state_test-second_delegation_DelegationTo.RESET-first_delegation_DelegationTo.CONTRACT_B]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_2_py__test_double_auth_fork_Prague_state_test_second_delegation_DelegationTo_RESET_first_delegation_DelegationTo_RESET_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs_2/double_auth.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs_2.py::test_double_auth[fork_Prague-state_test-second_delegation_DelegationTo.RESET-first_delegation_DelegationTo.RESET]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
