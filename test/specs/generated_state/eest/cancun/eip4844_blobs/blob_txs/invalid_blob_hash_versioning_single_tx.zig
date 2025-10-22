const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_invalid_blob_hash_versioning_single_tx_fork_Cancun_state_test__multiple_blobs_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/invalid_blob_hash_versioning_single_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_invalid_blob_hash_versioning_single_tx[fork_Cancun-state_test--multiple_blobs]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_invalid_blob_hash_versioning_single_tx_fork_Cancun_state_test__multiple_blobs_single_bad_hash_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/invalid_blob_hash_versioning_single_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_invalid_blob_hash_versioning_single_tx[fork_Cancun-state_test--multiple_blobs_single_bad_hash_1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_invalid_blob_hash_versioning_single_tx_fork_Cancun_state_test__multiple_blobs_single_bad_hash_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/invalid_blob_hash_versioning_single_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_invalid_blob_hash_versioning_single_tx[fork_Cancun-state_test--multiple_blobs_single_bad_hash_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_invalid_blob_hash_versioning_single_tx_fork_Cancun_state_test__single_blob_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/invalid_blob_hash_versioning_single_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_invalid_blob_hash_versioning_single_tx[fork_Cancun-state_test--single_blob]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_invalid_blob_hash_versioning_single_tx_fork_Prague_state_test__multiple_blobs_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/invalid_blob_hash_versioning_single_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_invalid_blob_hash_versioning_single_tx[fork_Prague-state_test--multiple_blobs]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_invalid_blob_hash_versioning_single_tx_fork_Prague_state_test__multiple_blobs_single_bad_hash_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/invalid_blob_hash_versioning_single_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_invalid_blob_hash_versioning_single_tx[fork_Prague-state_test--multiple_blobs_single_bad_hash_1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_invalid_blob_hash_versioning_single_tx_fork_Prague_state_test__multiple_blobs_single_bad_hash_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/invalid_blob_hash_versioning_single_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_invalid_blob_hash_versioning_single_tx[fork_Prague-state_test--multiple_blobs_single_bad_hash_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_blob_txs_py__test_invalid_blob_hash_versioning_single_tx_fork_Prague_state_test__single_blob_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/blob_txs/invalid_blob_hash_versioning_single_tx.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_blob_txs.py::test_invalid_blob_hash_versioning_single_tx[fork_Prague-state_test--single_blob]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
