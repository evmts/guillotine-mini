const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_log_fork_Prague_evm_code_type_LEGACY_state_test_log_opcode_LOG0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_log.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_log[fork_Prague-evm_code_type_LEGACY-state_test-log_opcode_LOG0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_log_fork_Prague_evm_code_type_LEGACY_state_test_log_opcode_LOG1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_log.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_log[fork_Prague-evm_code_type_LEGACY-state_test-log_opcode_LOG1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_log_fork_Prague_evm_code_type_LEGACY_state_test_log_opcode_LOG2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_log.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_log[fork_Prague-evm_code_type_LEGACY-state_test-log_opcode_LOG2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_log_fork_Prague_evm_code_type_LEGACY_state_test_log_opcode_LOG3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_log.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_log[fork_Prague-evm_code_type_LEGACY-state_test-log_opcode_LOG3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_log_fork_Prague_evm_code_type_LEGACY_state_test_log_opcode_LOG4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_log.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_log[fork_Prague-evm_code_type_LEGACY-state_test-log_opcode_LOG4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
