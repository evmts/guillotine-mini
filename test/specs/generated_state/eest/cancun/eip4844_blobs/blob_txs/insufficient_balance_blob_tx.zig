const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Cancun_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Cancun-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_1_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_1-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_100_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_100-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_no_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-no_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_one_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_one_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_0_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_0-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_0_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_0-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_14_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_14-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_insufficient_balance_blob_tx_fork_Prague_state_test__exact_balance_minus_1_tx_max_fee_per_blob_gas_multiplier_10000_single_zero_calldata_tx_value_1_tx_max_priority_fee_per_gas_7_tx_max_fee_per_gas_7_no_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/insufficient_balance_blob_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_insufficient_balance_blob_tx[fork_Prague-state_test--exact_balance_minus_1-tx_max_fee_per_blob_gas_multiplier_10000-single_zero_calldata-tx_value_1-tx_max_priority_fee_per_gas_7-tx_max_fee_per_gas_7-no_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
