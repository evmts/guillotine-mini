const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_blob_tx_attribute_gasprice_opcode_fork_Cancun_state_test_tx_gas_500000_opcode_GASPRICE_tx_max_fee_per_gas_100_tx_max_fee_per_blob_gas_delta_0_tx_max_priority_fee_per_gas_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/blob_tx_attribute_gasprice_opcode.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_blob_tx_attribute_gasprice_opcode[fork_Cancun-state_test-tx_gas_500000-opcode_GASPRICE-tx_max_fee_per_gas_100-tx_max_fee_per_blob_gas_delta_0-tx_max_priority_fee_per_gas_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_blob_tx_attribute_gasprice_opcode_fork_Cancun_state_test_tx_gas_500000_opcode_GASPRICE_tx_max_fee_per_gas_100_tx_max_fee_per_blob_gas_delta_0_tx_max_priority_fee_per_gas_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/blob_tx_attribute_gasprice_opcode.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_blob_tx_attribute_gasprice_opcode[fork_Cancun-state_test-tx_gas_500000-opcode_GASPRICE-tx_max_fee_per_gas_100-tx_max_fee_per_blob_gas_delta_0-tx_max_priority_fee_per_gas_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_blob_tx_attribute_gasprice_opcode_fork_Cancun_state_test_tx_gas_500000_opcode_GASPRICE_tx_max_fee_per_gas_100_tx_max_fee_per_blob_gas_delta_1_tx_max_priority_fee_per_gas_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/blob_tx_attribute_gasprice_opcode.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_blob_tx_attribute_gasprice_opcode[fork_Cancun-state_test-tx_gas_500000-opcode_GASPRICE-tx_max_fee_per_gas_100-tx_max_fee_per_blob_gas_delta_1-tx_max_priority_fee_per_gas_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_blob_tx_attribute_gasprice_opcode_fork_Cancun_state_test_tx_gas_500000_opcode_GASPRICE_tx_max_fee_per_gas_100_tx_max_fee_per_blob_gas_delta_1_tx_max_priority_fee_per_gas_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/blob_tx_attribute_gasprice_opcode.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_blob_tx_attribute_gasprice_opcode[fork_Cancun-state_test-tx_gas_500000-opcode_GASPRICE-tx_max_fee_per_gas_100-tx_max_fee_per_blob_gas_delta_1-tx_max_priority_fee_per_gas_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_blob_tx_attribute_gasprice_opcode_fork_Prague_state_test_tx_gas_500000_opcode_GASPRICE_tx_max_fee_per_gas_100_tx_max_fee_per_blob_gas_delta_0_tx_max_priority_fee_per_gas_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/blob_tx_attribute_gasprice_opcode.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_blob_tx_attribute_gasprice_opcode[fork_Prague-state_test-tx_gas_500000-opcode_GASPRICE-tx_max_fee_per_gas_100-tx_max_fee_per_blob_gas_delta_0-tx_max_priority_fee_per_gas_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_blob_tx_attribute_gasprice_opcode_fork_Prague_state_test_tx_gas_500000_opcode_GASPRICE_tx_max_fee_per_gas_100_tx_max_fee_per_blob_gas_delta_0_tx_max_priority_fee_per_gas_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/blob_tx_attribute_gasprice_opcode.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_blob_tx_attribute_gasprice_opcode[fork_Prague-state_test-tx_gas_500000-opcode_GASPRICE-tx_max_fee_per_gas_100-tx_max_fee_per_blob_gas_delta_0-tx_max_priority_fee_per_gas_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_blob_tx_attribute_gasprice_opcode_fork_Prague_state_test_tx_gas_500000_opcode_GASPRICE_tx_max_fee_per_gas_100_tx_max_fee_per_blob_gas_delta_1_tx_max_priority_fee_per_gas_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/blob_tx_attribute_gasprice_opcode.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_blob_tx_attribute_gasprice_opcode[fork_Prague-state_test-tx_gas_500000-opcode_GASPRICE-tx_max_fee_per_gas_100-tx_max_fee_per_blob_gas_delta_1-tx_max_priority_fee_per_gas_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_blob_tx_attribute_gasprice_opcode_fork_Prague_state_test_tx_gas_500000_opcode_GASPRICE_tx_max_fee_per_gas_100_tx_max_fee_per_blob_gas_delta_1_tx_max_priority_fee_per_gas_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/blob_tx_attribute_gasprice_opcode.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_blob_tx_attribute_gasprice_opcode[fork_Prague-state_test-tx_gas_500000-opcode_GASPRICE-tx_max_fee_per_gas_100-tx_max_fee_per_blob_gas_delta_1-tx_max_priority_fee_per_gas_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
