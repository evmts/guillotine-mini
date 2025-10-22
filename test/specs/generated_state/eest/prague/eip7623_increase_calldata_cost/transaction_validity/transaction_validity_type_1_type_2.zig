const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_multiple_storage_keys__exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_multiple_storage_keys--exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_multiple_storage_keys__exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_multiple_storage_keys--exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_multiple_storage_keys__extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_multiple_storage_keys--extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_multiple_storage_keys__extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_multiple_storage_keys--extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_multiple_storage_keys__insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_multiple_storage_keys--insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_multiple_storage_keys__insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_multiple_storage_keys--insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_multiple_storage_keys_contract_creating_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_multiple_storage_keys-contract_creating-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_multiple_storage_keys_contract_creating_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_multiple_storage_keys-contract_creating-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_multiple_storage_keys_contract_creating_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_multiple_storage_keys-contract_creating-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_multiple_storage_keys_contract_creating_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_multiple_storage_keys-contract_creating-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_multiple_storage_keys_contract_creating_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_multiple_storage_keys-contract_creating-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_multiple_storage_keys_contract_creating_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_multiple_storage_keys-contract_creating-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_multiple_storage_keys_to_eoa_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_multiple_storage_keys-to_eoa-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_multiple_storage_keys_to_eoa_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_multiple_storage_keys-to_eoa-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_multiple_storage_keys_to_eoa_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_multiple_storage_keys-to_eoa-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_multiple_storage_keys_to_eoa_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_multiple_storage_keys-to_eoa-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_multiple_storage_keys_to_eoa_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_multiple_storage_keys-to_eoa-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_multiple_storage_keys_to_eoa_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_multiple_storage_keys-to_eoa-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_no_storage_keys__exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_no_storage_keys--exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_no_storage_keys__exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_no_storage_keys--exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_no_storage_keys__extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_no_storage_keys--extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_no_storage_keys__extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_no_storage_keys--extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_no_storage_keys__insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_no_storage_keys--insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_no_storage_keys__insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_no_storage_keys--insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_no_storage_keys_contract_creating_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_no_storage_keys-contract_creating-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_no_storage_keys_contract_creating_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_no_storage_keys-contract_creating-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_no_storage_keys_contract_creating_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_no_storage_keys-contract_creating-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_no_storage_keys_contract_creating_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_no_storage_keys-contract_creating-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_no_storage_keys_contract_creating_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_no_storage_keys-contract_creating-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_no_storage_keys_contract_creating_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_no_storage_keys-contract_creating-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_no_storage_keys_to_eoa_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_no_storage_keys-to_eoa-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_no_storage_keys_to_eoa_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_no_storage_keys-to_eoa-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_no_storage_keys_to_eoa_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_no_storage_keys-to_eoa-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_no_storage_keys_to_eoa_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_no_storage_keys-to_eoa-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_no_storage_keys_to_eoa_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_no_storage_keys-to_eoa-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_no_storage_keys_to_eoa_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_no_storage_keys-to_eoa-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_single_storage_key__exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_single_storage_key--exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_single_storage_key__exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_single_storage_key--exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_single_storage_key__extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_single_storage_key--extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_single_storage_key__extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_single_storage_key--extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_single_storage_key__insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_single_storage_key--insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_single_storage_key__insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_single_storage_key--insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_single_storage_key_contract_creating_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_single_storage_key-contract_creating-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_single_storage_key_contract_creating_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_single_storage_key-contract_creating-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_single_storage_key_contract_creating_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_single_storage_key-contract_creating-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_single_storage_key_contract_creating_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_single_storage_key-contract_creating-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_single_storage_key_contract_creating_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_single_storage_key-contract_creating-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_single_storage_key_contract_creating_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_single_storage_key-contract_creating-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_single_storage_key_to_eoa_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_single_storage_key-to_eoa-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_single_storage_key_to_eoa_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_single_storage_key-to_eoa-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_single_storage_key_to_eoa_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_single_storage_key-to_eoa-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_single_storage_key_to_eoa_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_single_storage_key-to_eoa-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_single_storage_key_to_eoa_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_single_storage_key-to_eoa-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_multiple_access_lists_single_storage_key_to_eoa_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-multiple_access_lists_single_storage_key-to_eoa-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_no_access_list__exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-no_access_list--exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_no_access_list__exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-no_access_list--exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_no_access_list__extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-no_access_list--extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_no_access_list__extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-no_access_list--extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_no_access_list__insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-no_access_list--insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_no_access_list__insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-no_access_list--insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_no_access_list_contract_creating_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-no_access_list-contract_creating-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_no_access_list_contract_creating_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-no_access_list-contract_creating-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_no_access_list_contract_creating_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-no_access_list-contract_creating-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_no_access_list_contract_creating_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-no_access_list-contract_creating-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_no_access_list_contract_creating_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-no_access_list-contract_creating-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_no_access_list_contract_creating_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-no_access_list-contract_creating-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_no_access_list_to_eoa_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-no_access_list-to_eoa-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_no_access_list_to_eoa_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-no_access_list-to_eoa-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_no_access_list_to_eoa_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-no_access_list-to_eoa-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_no_access_list_to_eoa_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-no_access_list-to_eoa-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_no_access_list_to_eoa_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-no_access_list-to_eoa-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_no_access_list_to_eoa_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-no_access_list-to_eoa-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_multiple_storage_keys__exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_multiple_storage_keys--exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_multiple_storage_keys__exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_multiple_storage_keys--exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_multiple_storage_keys__extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_multiple_storage_keys--extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_multiple_storage_keys__extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_multiple_storage_keys--extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_multiple_storage_keys__insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_multiple_storage_keys--insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_multiple_storage_keys__insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_multiple_storage_keys--insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_multiple_storage_keys_contract_creating_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_multiple_storage_keys-contract_creating-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_multiple_storage_keys_contract_creating_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_multiple_storage_keys-contract_creating-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_multiple_storage_keys_contract_creating_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_multiple_storage_keys-contract_creating-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_multiple_storage_keys_contract_creating_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_multiple_storage_keys-contract_creating-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_multiple_storage_keys_contract_creating_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_multiple_storage_keys-contract_creating-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_multiple_storage_keys_contract_creating_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_multiple_storage_keys-contract_creating-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_multiple_storage_keys_to_eoa_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_multiple_storage_keys-to_eoa-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_multiple_storage_keys_to_eoa_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_multiple_storage_keys-to_eoa-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_multiple_storage_keys_to_eoa_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_multiple_storage_keys-to_eoa-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_multiple_storage_keys_to_eoa_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_multiple_storage_keys-to_eoa-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_multiple_storage_keys_to_eoa_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_multiple_storage_keys-to_eoa-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_multiple_storage_keys_to_eoa_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_multiple_storage_keys-to_eoa-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_no_storage_keys__exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_no_storage_keys--exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_no_storage_keys__exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_no_storage_keys--exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_no_storage_keys__extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_no_storage_keys--extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_no_storage_keys__extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_no_storage_keys--extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_no_storage_keys__insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_no_storage_keys--insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_no_storage_keys__insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_no_storage_keys--insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_no_storage_keys_contract_creating_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_no_storage_keys-contract_creating-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_no_storage_keys_contract_creating_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_no_storage_keys-contract_creating-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_no_storage_keys_contract_creating_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_no_storage_keys-contract_creating-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_no_storage_keys_contract_creating_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_no_storage_keys-contract_creating-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_no_storage_keys_contract_creating_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_no_storage_keys-contract_creating-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_no_storage_keys_contract_creating_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_no_storage_keys-contract_creating-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_no_storage_keys_to_eoa_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_no_storage_keys-to_eoa-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_no_storage_keys_to_eoa_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_no_storage_keys-to_eoa-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_no_storage_keys_to_eoa_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_no_storage_keys-to_eoa-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_no_storage_keys_to_eoa_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_no_storage_keys-to_eoa-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_no_storage_keys_to_eoa_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_no_storage_keys-to_eoa-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_no_storage_keys_to_eoa_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_no_storage_keys-to_eoa-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_single_storage_key__exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_single_storage_key--exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_single_storage_key__exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_single_storage_key--exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_single_storage_key__extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_single_storage_key--extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_single_storage_key__extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_single_storage_key--extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_single_storage_key__insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_single_storage_key--insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_single_storage_key__insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_single_storage_key--insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_single_storage_key_contract_creating_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_single_storage_key-contract_creating-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_single_storage_key_contract_creating_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_single_storage_key-contract_creating-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_single_storage_key_contract_creating_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_single_storage_key-contract_creating-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_single_storage_key_contract_creating_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_single_storage_key-contract_creating-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_single_storage_key_contract_creating_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_single_storage_key-contract_creating-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_single_storage_key_contract_creating_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_single_storage_key-contract_creating-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_single_storage_key_to_eoa_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_single_storage_key-to_eoa-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_single_storage_key_to_eoa_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_single_storage_key-to_eoa-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_single_storage_key_to_eoa_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_single_storage_key-to_eoa-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_single_storage_key_to_eoa_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_single_storage_key-to_eoa-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_single_storage_key_to_eoa_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_single_storage_key-to_eoa-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_1_single_access_list_single_storage_key_to_eoa_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_1-single_access_list_single_storage_key-to_eoa-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_multiple_storage_keys__exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_multiple_storage_keys--exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_multiple_storage_keys__exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_multiple_storage_keys--exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_multiple_storage_keys__extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_multiple_storage_keys--extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_multiple_storage_keys__extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_multiple_storage_keys--extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_multiple_storage_keys__insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_multiple_storage_keys--insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_multiple_storage_keys__insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_multiple_storage_keys--insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_multiple_storage_keys_contract_creating_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_multiple_storage_keys-contract_creating-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_multiple_storage_keys_contract_creating_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_multiple_storage_keys-contract_creating-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_multiple_storage_keys_contract_creating_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_multiple_storage_keys-contract_creating-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_multiple_storage_keys_contract_creating_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_multiple_storage_keys-contract_creating-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_multiple_storage_keys_contract_creating_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_multiple_storage_keys-contract_creating-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_multiple_storage_keys_contract_creating_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_multiple_storage_keys-contract_creating-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_multiple_storage_keys_to_eoa_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_multiple_storage_keys-to_eoa-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_multiple_storage_keys_to_eoa_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_multiple_storage_keys-to_eoa-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_multiple_storage_keys_to_eoa_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_multiple_storage_keys-to_eoa-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_multiple_storage_keys_to_eoa_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_multiple_storage_keys-to_eoa-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_multiple_storage_keys_to_eoa_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_multiple_storage_keys-to_eoa-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_multiple_storage_keys_to_eoa_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_multiple_storage_keys-to_eoa-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_no_storage_keys__exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_no_storage_keys--exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_no_storage_keys__exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_no_storage_keys--exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_no_storage_keys__extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_no_storage_keys--extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_no_storage_keys__extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_no_storage_keys--extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_no_storage_keys__insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_no_storage_keys--insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_no_storage_keys__insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_no_storage_keys--insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_no_storage_keys_contract_creating_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_no_storage_keys-contract_creating-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_no_storage_keys_contract_creating_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_no_storage_keys-contract_creating-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_no_storage_keys_contract_creating_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_no_storage_keys-contract_creating-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_no_storage_keys_contract_creating_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_no_storage_keys-contract_creating-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_no_storage_keys_contract_creating_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_no_storage_keys-contract_creating-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_no_storage_keys_contract_creating_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_no_storage_keys-contract_creating-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_no_storage_keys_to_eoa_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_no_storage_keys-to_eoa-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_no_storage_keys_to_eoa_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_no_storage_keys-to_eoa-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_no_storage_keys_to_eoa_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_no_storage_keys-to_eoa-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_no_storage_keys_to_eoa_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_no_storage_keys-to_eoa-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_no_storage_keys_to_eoa_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_no_storage_keys-to_eoa-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_no_storage_keys_to_eoa_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_no_storage_keys-to_eoa-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_single_storage_key__exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_single_storage_key--exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_single_storage_key__exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_single_storage_key--exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_single_storage_key__extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_single_storage_key--extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_single_storage_key__extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_single_storage_key--extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_single_storage_key__insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_single_storage_key--insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_single_storage_key__insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_single_storage_key--insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_single_storage_key_contract_creating_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_single_storage_key-contract_creating-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_single_storage_key_contract_creating_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_single_storage_key-contract_creating-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_single_storage_key_contract_creating_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_single_storage_key-contract_creating-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_single_storage_key_contract_creating_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_single_storage_key-contract_creating-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_single_storage_key_contract_creating_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_single_storage_key-contract_creating-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_single_storage_key_contract_creating_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_single_storage_key-contract_creating-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_single_storage_key_to_eoa_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_single_storage_key-to_eoa-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_single_storage_key_to_eoa_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_single_storage_key-to_eoa-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_single_storage_key_to_eoa_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_single_storage_key-to_eoa-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_single_storage_key_to_eoa_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_single_storage_key-to_eoa-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_single_storage_key_to_eoa_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_single_storage_key-to_eoa-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_multiple_access_lists_single_storage_key_to_eoa_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-multiple_access_lists_single_storage_key-to_eoa-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_no_access_list__exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-no_access_list--exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_no_access_list__exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-no_access_list--exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_no_access_list__extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-no_access_list--extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_no_access_list__extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-no_access_list--extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_no_access_list__insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-no_access_list--insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_no_access_list__insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-no_access_list--insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_no_access_list_contract_creating_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-no_access_list-contract_creating-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_no_access_list_contract_creating_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-no_access_list-contract_creating-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_no_access_list_contract_creating_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-no_access_list-contract_creating-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_no_access_list_contract_creating_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-no_access_list-contract_creating-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_no_access_list_contract_creating_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-no_access_list-contract_creating-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_no_access_list_contract_creating_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-no_access_list-contract_creating-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_no_access_list_to_eoa_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-no_access_list-to_eoa-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_no_access_list_to_eoa_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-no_access_list-to_eoa-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_no_access_list_to_eoa_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-no_access_list-to_eoa-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_no_access_list_to_eoa_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-no_access_list-to_eoa-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_no_access_list_to_eoa_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-no_access_list-to_eoa-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_no_access_list_to_eoa_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-no_access_list-to_eoa-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_multiple_storage_keys__exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_multiple_storage_keys--exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_multiple_storage_keys__exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_multiple_storage_keys--exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_multiple_storage_keys__extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_multiple_storage_keys--extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_multiple_storage_keys__extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_multiple_storage_keys--extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_multiple_storage_keys__insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_multiple_storage_keys--insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_multiple_storage_keys__insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_multiple_storage_keys--insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_multiple_storage_keys_contract_creating_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_multiple_storage_keys-contract_creating-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_multiple_storage_keys_contract_creating_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_multiple_storage_keys-contract_creating-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_multiple_storage_keys_contract_creating_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_multiple_storage_keys-contract_creating-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_multiple_storage_keys_contract_creating_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_multiple_storage_keys-contract_creating-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_multiple_storage_keys_contract_creating_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_multiple_storage_keys-contract_creating-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_multiple_storage_keys_contract_creating_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_multiple_storage_keys-contract_creating-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_multiple_storage_keys_to_eoa_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_multiple_storage_keys-to_eoa-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_multiple_storage_keys_to_eoa_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_multiple_storage_keys-to_eoa-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_multiple_storage_keys_to_eoa_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_multiple_storage_keys-to_eoa-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_multiple_storage_keys_to_eoa_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_multiple_storage_keys-to_eoa-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_multiple_storage_keys_to_eoa_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_multiple_storage_keys-to_eoa-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_multiple_storage_keys_to_eoa_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_multiple_storage_keys-to_eoa-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_no_storage_keys__exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_no_storage_keys--exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_no_storage_keys__exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_no_storage_keys--exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_no_storage_keys__extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_no_storage_keys--extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_no_storage_keys__extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_no_storage_keys--extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_no_storage_keys__insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_no_storage_keys--insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_no_storage_keys__insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_no_storage_keys--insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_no_storage_keys_contract_creating_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_no_storage_keys-contract_creating-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_no_storage_keys_contract_creating_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_no_storage_keys-contract_creating-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_no_storage_keys_contract_creating_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_no_storage_keys-contract_creating-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_no_storage_keys_contract_creating_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_no_storage_keys-contract_creating-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_no_storage_keys_contract_creating_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_no_storage_keys-contract_creating-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_no_storage_keys_contract_creating_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_no_storage_keys-contract_creating-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_no_storage_keys_to_eoa_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_no_storage_keys-to_eoa-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_no_storage_keys_to_eoa_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_no_storage_keys-to_eoa-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_no_storage_keys_to_eoa_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_no_storage_keys-to_eoa-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_no_storage_keys_to_eoa_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_no_storage_keys-to_eoa-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_no_storage_keys_to_eoa_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_no_storage_keys-to_eoa-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_no_storage_keys_to_eoa_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_no_storage_keys-to_eoa-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_single_storage_key__exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_single_storage_key--exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_single_storage_key__exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_single_storage_key--exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_single_storage_key__extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_single_storage_key--extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_single_storage_key__extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_single_storage_key--extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_single_storage_key__insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_single_storage_key--insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_single_storage_key__insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_single_storage_key--insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_single_storage_key_contract_creating_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_single_storage_key-contract_creating-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_single_storage_key_contract_creating_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_single_storage_key-contract_creating-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_single_storage_key_contract_creating_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_single_storage_key-contract_creating-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_single_storage_key_contract_creating_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_single_storage_key-contract_creating-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_single_storage_key_contract_creating_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_single_storage_key-contract_creating-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_single_storage_key_contract_creating_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_single_storage_key-contract_creating-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_single_storage_key_to_eoa_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_single_storage_key-to_eoa-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_single_storage_key_to_eoa_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_single_storage_key-to_eoa-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_single_storage_key_to_eoa_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_single_storage_key-to_eoa-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_single_storage_key_to_eoa_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_single_storage_key-to_eoa-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_single_storage_key_to_eoa_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_single_storage_key-to_eoa-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_1_type_2_fork_Prague_state_test_type_2_single_access_list_single_storage_key_to_eoa_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_1_type_2.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_1_type_2[fork_Prague-state_test-type_2-single_access_list_single_storage_key-to_eoa-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
