const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_self_destructing_account_deployed_in_same_tx_fork_Prague_state_test_create_opcode_CREATE_call_set_code_first_False_balance_0_external_sendall_recipient_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_self_destructing_account_deployed_in_same_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_self_destructing_account_deployed_in_same_tx[fork_Prague-state_test-create_opcode_CREATE-call_set_code_first_False-balance_0-external_sendall_recipient_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_self_destructing_account_deployed_in_same_tx_fork_Prague_state_test_create_opcode_CREATE_call_set_code_first_False_balance_0_external_sendall_recipient_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_self_destructing_account_deployed_in_same_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_self_destructing_account_deployed_in_same_tx[fork_Prague-state_test-create_opcode_CREATE-call_set_code_first_False-balance_0-external_sendall_recipient_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_self_destructing_account_deployed_in_same_tx_fork_Prague_state_test_create_opcode_CREATE_call_set_code_first_False_balance_1_external_sendall_recipient_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_self_destructing_account_deployed_in_same_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_self_destructing_account_deployed_in_same_tx[fork_Prague-state_test-create_opcode_CREATE-call_set_code_first_False-balance_1-external_sendall_recipient_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_self_destructing_account_deployed_in_same_tx_fork_Prague_state_test_create_opcode_CREATE_call_set_code_first_False_balance_1_external_sendall_recipient_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_self_destructing_account_deployed_in_same_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_self_destructing_account_deployed_in_same_tx[fork_Prague-state_test-create_opcode_CREATE-call_set_code_first_False-balance_1-external_sendall_recipient_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_self_destructing_account_deployed_in_same_tx_fork_Prague_state_test_create_opcode_CREATE_call_set_code_first_True_balance_0_external_sendall_recipient_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_self_destructing_account_deployed_in_same_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_self_destructing_account_deployed_in_same_tx[fork_Prague-state_test-create_opcode_CREATE-call_set_code_first_True-balance_0-external_sendall_recipient_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_self_destructing_account_deployed_in_same_tx_fork_Prague_state_test_create_opcode_CREATE_call_set_code_first_True_balance_0_external_sendall_recipient_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_self_destructing_account_deployed_in_same_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_self_destructing_account_deployed_in_same_tx[fork_Prague-state_test-create_opcode_CREATE-call_set_code_first_True-balance_0-external_sendall_recipient_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_self_destructing_account_deployed_in_same_tx_fork_Prague_state_test_create_opcode_CREATE_call_set_code_first_True_balance_1_external_sendall_recipient_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_self_destructing_account_deployed_in_same_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_self_destructing_account_deployed_in_same_tx[fork_Prague-state_test-create_opcode_CREATE-call_set_code_first_True-balance_1-external_sendall_recipient_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_self_destructing_account_deployed_in_same_tx_fork_Prague_state_test_create_opcode_CREATE_call_set_code_first_True_balance_1_external_sendall_recipient_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_self_destructing_account_deployed_in_same_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_self_destructing_account_deployed_in_same_tx[fork_Prague-state_test-create_opcode_CREATE-call_set_code_first_True-balance_1-external_sendall_recipient_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_self_destructing_account_deployed_in_same_tx_fork_Prague_state_test_create_opcode_CREATE2_call_set_code_first_False_balance_0_external_sendall_recipient_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_self_destructing_account_deployed_in_same_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_self_destructing_account_deployed_in_same_tx[fork_Prague-state_test-create_opcode_CREATE2-call_set_code_first_False-balance_0-external_sendall_recipient_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_self_destructing_account_deployed_in_same_tx_fork_Prague_state_test_create_opcode_CREATE2_call_set_code_first_False_balance_0_external_sendall_recipient_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_self_destructing_account_deployed_in_same_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_self_destructing_account_deployed_in_same_tx[fork_Prague-state_test-create_opcode_CREATE2-call_set_code_first_False-balance_0-external_sendall_recipient_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_self_destructing_account_deployed_in_same_tx_fork_Prague_state_test_create_opcode_CREATE2_call_set_code_first_False_balance_1_external_sendall_recipient_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_self_destructing_account_deployed_in_same_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_self_destructing_account_deployed_in_same_tx[fork_Prague-state_test-create_opcode_CREATE2-call_set_code_first_False-balance_1-external_sendall_recipient_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_self_destructing_account_deployed_in_same_tx_fork_Prague_state_test_create_opcode_CREATE2_call_set_code_first_False_balance_1_external_sendall_recipient_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_self_destructing_account_deployed_in_same_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_self_destructing_account_deployed_in_same_tx[fork_Prague-state_test-create_opcode_CREATE2-call_set_code_first_False-balance_1-external_sendall_recipient_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_self_destructing_account_deployed_in_same_tx_fork_Prague_state_test_create_opcode_CREATE2_call_set_code_first_True_balance_0_external_sendall_recipient_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_self_destructing_account_deployed_in_same_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_self_destructing_account_deployed_in_same_tx[fork_Prague-state_test-create_opcode_CREATE2-call_set_code_first_True-balance_0-external_sendall_recipient_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_self_destructing_account_deployed_in_same_tx_fork_Prague_state_test_create_opcode_CREATE2_call_set_code_first_True_balance_0_external_sendall_recipient_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_self_destructing_account_deployed_in_same_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_self_destructing_account_deployed_in_same_tx[fork_Prague-state_test-create_opcode_CREATE2-call_set_code_first_True-balance_0-external_sendall_recipient_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_self_destructing_account_deployed_in_same_tx_fork_Prague_state_test_create_opcode_CREATE2_call_set_code_first_True_balance_1_external_sendall_recipient_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_self_destructing_account_deployed_in_same_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_self_destructing_account_deployed_in_same_tx[fork_Prague-state_test-create_opcode_CREATE2-call_set_code_first_True-balance_1-external_sendall_recipient_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_self_destructing_account_deployed_in_same_tx_fork_Prague_state_test_create_opcode_CREATE2_call_set_code_first_True_balance_1_external_sendall_recipient_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_self_destructing_account_deployed_in_same_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_self_destructing_account_deployed_in_same_tx[fork_Prague-state_test-create_opcode_CREATE2-call_set_code_first_True-balance_1-external_sendall_recipient_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
