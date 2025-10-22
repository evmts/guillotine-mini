const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_cancun_eip1153_tstore_test_tstorage_py__test_run_until_out_of_gas_fork_Cancun_tx_gas_limit_0x055d4a80_state_test_tstore_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage/run_until_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage.py::test_run_until_out_of_gas[fork_Cancun-tx_gas_limit_0x055d4a80-state_test-tstore]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_py__test_run_until_out_of_gas_fork_Cancun_tx_gas_limit_0x055d4a80_state_test_tstore_tload_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage/run_until_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage.py::test_run_until_out_of_gas[fork_Cancun-tx_gas_limit_0x055d4a80-state_test-tstore_tload]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_py__test_run_until_out_of_gas_fork_Cancun_tx_gas_limit_0x055d4a80_state_test_tstore_wide_address_space_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage/run_until_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage.py::test_run_until_out_of_gas[fork_Cancun-tx_gas_limit_0x055d4a80-state_test-tstore_wide_address_space]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_py__test_run_until_out_of_gas_fork_Prague_tx_gas_limit_0x055d4a80_state_test_tstore_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage/run_until_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage.py::test_run_until_out_of_gas[fork_Prague-tx_gas_limit_0x055d4a80-state_test-tstore]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_py__test_run_until_out_of_gas_fork_Prague_tx_gas_limit_0x055d4a80_state_test_tstore_tload_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage/run_until_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage.py::test_run_until_out_of_gas[fork_Prague-tx_gas_limit_0x055d4a80-state_test-tstore_tload]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip1153_tstore_test_tstorage_py__test_run_until_out_of_gas_fork_Prague_tx_gas_limit_0x055d4a80_state_test_tstore_wide_address_space_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip1153_tstore/tstorage/run_until_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip1153_tstore/test_tstorage.py::test_run_until_out_of_gas[fork_Prague-tx_gas_limit_0x055d4a80-state_test-tstore_wide_address_space]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
