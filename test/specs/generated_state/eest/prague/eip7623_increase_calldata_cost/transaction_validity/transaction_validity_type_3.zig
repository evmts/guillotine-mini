const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_multiple_access_lists_multiple_storage_keys_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-multiple_access_lists_multiple_storage_keys-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_multiple_access_lists_multiple_storage_keys_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-multiple_access_lists_multiple_storage_keys-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_multiple_access_lists_multiple_storage_keys_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-multiple_access_lists_multiple_storage_keys-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_multiple_access_lists_multiple_storage_keys_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-multiple_access_lists_multiple_storage_keys-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_multiple_access_lists_multiple_storage_keys_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-multiple_access_lists_multiple_storage_keys-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_multiple_access_lists_multiple_storage_keys_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-multiple_access_lists_multiple_storage_keys-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_multiple_access_lists_no_storage_keys_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-multiple_access_lists_no_storage_keys-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_multiple_access_lists_no_storage_keys_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-multiple_access_lists_no_storage_keys-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_multiple_access_lists_no_storage_keys_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-multiple_access_lists_no_storage_keys-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_multiple_access_lists_no_storage_keys_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-multiple_access_lists_no_storage_keys-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_multiple_access_lists_no_storage_keys_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-multiple_access_lists_no_storage_keys-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_multiple_access_lists_no_storage_keys_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-multiple_access_lists_no_storage_keys-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_multiple_access_lists_single_storage_key_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-multiple_access_lists_single_storage_key-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_multiple_access_lists_single_storage_key_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-multiple_access_lists_single_storage_key-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_multiple_access_lists_single_storage_key_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-multiple_access_lists_single_storage_key-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_multiple_access_lists_single_storage_key_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-multiple_access_lists_single_storage_key-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_multiple_access_lists_single_storage_key_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-multiple_access_lists_single_storage_key-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_multiple_access_lists_single_storage_key_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-multiple_access_lists_single_storage_key-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_no_access_list_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-no_access_list-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_no_access_list_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-no_access_list-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_no_access_list_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-no_access_list-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_no_access_list_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-no_access_list-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_no_access_list_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-no_access_list-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_no_access_list_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-no_access_list-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_single_access_list_multiple_storage_keys_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-single_access_list_multiple_storage_keys-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_single_access_list_multiple_storage_keys_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-single_access_list_multiple_storage_keys-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_single_access_list_multiple_storage_keys_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-single_access_list_multiple_storage_keys-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_single_access_list_multiple_storage_keys_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-single_access_list_multiple_storage_keys-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_single_access_list_multiple_storage_keys_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-single_access_list_multiple_storage_keys-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_single_access_list_multiple_storage_keys_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-single_access_list_multiple_storage_keys-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_single_access_list_no_storage_keys_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-single_access_list_no_storage_keys-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_single_access_list_no_storage_keys_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-single_access_list_no_storage_keys-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_single_access_list_no_storage_keys_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-single_access_list_no_storage_keys-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_single_access_list_no_storage_keys_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-single_access_list_no_storage_keys-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_single_access_list_no_storage_keys_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-single_access_list_no_storage_keys-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_single_access_list_no_storage_keys_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-single_access_list_no_storage_keys-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_single_access_list_single_storage_key_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-single_access_list_single_storage_key-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_single_access_list_single_storage_key_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-single_access_list_single_storage_key-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_single_access_list_single_storage_key_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-single_access_list_single_storage_key-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_single_access_list_single_storage_key_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-single_access_list_single_storage_key-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_single_access_list_single_storage_key_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-single_access_list_single_storage_key-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_multiple_blobs_single_access_list_single_storage_key_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-multiple_blobs-single_access_list_single_storage_key-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_multiple_access_lists_multiple_storage_keys_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-multiple_access_lists_multiple_storage_keys-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_multiple_access_lists_multiple_storage_keys_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-multiple_access_lists_multiple_storage_keys-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_multiple_access_lists_multiple_storage_keys_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-multiple_access_lists_multiple_storage_keys-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_multiple_access_lists_multiple_storage_keys_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-multiple_access_lists_multiple_storage_keys-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_multiple_access_lists_multiple_storage_keys_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-multiple_access_lists_multiple_storage_keys-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_multiple_access_lists_multiple_storage_keys_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-multiple_access_lists_multiple_storage_keys-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_multiple_access_lists_no_storage_keys_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-multiple_access_lists_no_storage_keys-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_multiple_access_lists_no_storage_keys_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-multiple_access_lists_no_storage_keys-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_multiple_access_lists_no_storage_keys_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-multiple_access_lists_no_storage_keys-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_multiple_access_lists_no_storage_keys_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-multiple_access_lists_no_storage_keys-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_multiple_access_lists_no_storage_keys_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-multiple_access_lists_no_storage_keys-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_multiple_access_lists_no_storage_keys_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-multiple_access_lists_no_storage_keys-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_multiple_access_lists_single_storage_key_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-multiple_access_lists_single_storage_key-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_multiple_access_lists_single_storage_key_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-multiple_access_lists_single_storage_key-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_multiple_access_lists_single_storage_key_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-multiple_access_lists_single_storage_key-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_multiple_access_lists_single_storage_key_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-multiple_access_lists_single_storage_key-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_multiple_access_lists_single_storage_key_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-multiple_access_lists_single_storage_key-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_multiple_access_lists_single_storage_key_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-multiple_access_lists_single_storage_key-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_no_access_list_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-no_access_list-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_no_access_list_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-no_access_list-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_no_access_list_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-no_access_list-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_no_access_list_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-no_access_list-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_no_access_list_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-no_access_list-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_no_access_list_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-no_access_list-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_single_access_list_multiple_storage_keys_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-single_access_list_multiple_storage_keys-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_single_access_list_multiple_storage_keys_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-single_access_list_multiple_storage_keys-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_single_access_list_multiple_storage_keys_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-single_access_list_multiple_storage_keys-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_single_access_list_multiple_storage_keys_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-single_access_list_multiple_storage_keys-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_single_access_list_multiple_storage_keys_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-single_access_list_multiple_storage_keys-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_single_access_list_multiple_storage_keys_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-single_access_list_multiple_storage_keys-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_single_access_list_no_storage_keys_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-single_access_list_no_storage_keys-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_single_access_list_no_storage_keys_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-single_access_list_no_storage_keys-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_single_access_list_no_storage_keys_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-single_access_list_no_storage_keys-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_single_access_list_no_storage_keys_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-single_access_list_no_storage_keys-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_single_access_list_no_storage_keys_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-single_access_list_no_storage_keys-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_single_access_list_no_storage_keys_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-single_access_list_no_storage_keys-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_single_access_list_single_storage_key_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-single_access_list_single_storage_key-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_single_access_list_single_storage_key_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-single_access_list_single_storage_key-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_single_access_list_single_storage_key_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-single_access_list_single_storage_key-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_single_access_list_single_storage_key_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-single_access_list_single_storage_key-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_single_access_list_single_storage_key_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-single_access_list_single_storage_key-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_3_fork_Prague_state_test_type_3_single_blob_single_access_list_single_storage_key_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_3.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_3[fork_Prague-state_test-type_3-single_blob-single_access_list_single_storage_key-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
