const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_precompile_not_enough_gas_for_precompile_execution_fork_Prague_precompile_0x0000000000000000000000000000000000000001_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_precompile_not_enough_gas_for_precompile_execution.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_precompile_not_enough_gas_for_precompile_execution[fork_Prague-precompile_0x0000000000000000000000000000000000000001-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_precompile_not_enough_gas_for_precompile_execution_fork_Prague_precompile_0x0000000000000000000000000000000000000002_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_precompile_not_enough_gas_for_precompile_execution.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_precompile_not_enough_gas_for_precompile_execution[fork_Prague-precompile_0x0000000000000000000000000000000000000002-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_precompile_not_enough_gas_for_precompile_execution_fork_Prague_precompile_0x0000000000000000000000000000000000000003_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_precompile_not_enough_gas_for_precompile_execution.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_precompile_not_enough_gas_for_precompile_execution[fork_Prague-precompile_0x0000000000000000000000000000000000000003-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_precompile_not_enough_gas_for_precompile_execution_fork_Prague_precompile_0x0000000000000000000000000000000000000004_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_precompile_not_enough_gas_for_precompile_execution.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_precompile_not_enough_gas_for_precompile_execution[fork_Prague-precompile_0x0000000000000000000000000000000000000004-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_precompile_not_enough_gas_for_precompile_execution_fork_Prague_precompile_0x0000000000000000000000000000000000000005_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_precompile_not_enough_gas_for_precompile_execution.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_precompile_not_enough_gas_for_precompile_execution[fork_Prague-precompile_0x0000000000000000000000000000000000000005-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_precompile_not_enough_gas_for_precompile_execution_fork_Prague_precompile_0x0000000000000000000000000000000000000006_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_precompile_not_enough_gas_for_precompile_execution.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_precompile_not_enough_gas_for_precompile_execution[fork_Prague-precompile_0x0000000000000000000000000000000000000006-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_precompile_not_enough_gas_for_precompile_execution_fork_Prague_precompile_0x0000000000000000000000000000000000000007_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_precompile_not_enough_gas_for_precompile_execution.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_precompile_not_enough_gas_for_precompile_execution[fork_Prague-precompile_0x0000000000000000000000000000000000000007-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_precompile_not_enough_gas_for_precompile_execution_fork_Prague_precompile_0x0000000000000000000000000000000000000008_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_precompile_not_enough_gas_for_precompile_execution.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_precompile_not_enough_gas_for_precompile_execution[fork_Prague-precompile_0x0000000000000000000000000000000000000008-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_precompile_not_enough_gas_for_precompile_execution_fork_Prague_precompile_0x0000000000000000000000000000000000000009_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_precompile_not_enough_gas_for_precompile_execution.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_precompile_not_enough_gas_for_precompile_execution[fork_Prague-precompile_0x0000000000000000000000000000000000000009-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_precompile_not_enough_gas_for_precompile_execution_fork_Prague_precompile_0x000000000000000000000000000000000000000a_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_precompile_not_enough_gas_for_precompile_execution.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_precompile_not_enough_gas_for_precompile_execution[fork_Prague-precompile_0x000000000000000000000000000000000000000a-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_precompile_not_enough_gas_for_precompile_execution_fork_Prague_precompile_0x000000000000000000000000000000000000000b_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_precompile_not_enough_gas_for_precompile_execution.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_precompile_not_enough_gas_for_precompile_execution[fork_Prague-precompile_0x000000000000000000000000000000000000000b-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_precompile_not_enough_gas_for_precompile_execution_fork_Prague_precompile_0x000000000000000000000000000000000000000c_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_precompile_not_enough_gas_for_precompile_execution.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_precompile_not_enough_gas_for_precompile_execution[fork_Prague-precompile_0x000000000000000000000000000000000000000c-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_precompile_not_enough_gas_for_precompile_execution_fork_Prague_precompile_0x000000000000000000000000000000000000000d_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_precompile_not_enough_gas_for_precompile_execution.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_precompile_not_enough_gas_for_precompile_execution[fork_Prague-precompile_0x000000000000000000000000000000000000000d-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_precompile_not_enough_gas_for_precompile_execution_fork_Prague_precompile_0x000000000000000000000000000000000000000e_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_precompile_not_enough_gas_for_precompile_execution.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_precompile_not_enough_gas_for_precompile_execution[fork_Prague-precompile_0x000000000000000000000000000000000000000e-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_precompile_not_enough_gas_for_precompile_execution_fork_Prague_precompile_0x000000000000000000000000000000000000000f_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_precompile_not_enough_gas_for_precompile_execution.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_precompile_not_enough_gas_for_precompile_execution[fork_Prague-precompile_0x000000000000000000000000000000000000000f-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_precompile_not_enough_gas_for_precompile_execution_fork_Prague_precompile_0x0000000000000000000000000000000000000010_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_precompile_not_enough_gas_for_precompile_execution.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_precompile_not_enough_gas_for_precompile_execution[fork_Prague-precompile_0x0000000000000000000000000000000000000010-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_set_code_to_precompile_not_enough_gas_for_precompile_execution_fork_Prague_precompile_0x0000000000000000000000000000000000000011_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/set_code_to_precompile_not_enough_gas_for_precompile_execution.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_set_code_to_precompile_not_enough_gas_for_precompile_execution[fork_Prague-precompile_0x0000000000000000000000000000000000000011-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
