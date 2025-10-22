const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_enough_gas_empty_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-enough_gas-empty_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_enough_gas_multiple_addresses_first_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-enough_gas-multiple_addresses_first_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_enough_gas_multiple_addresses_first_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-enough_gas-multiple_addresses_first_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_enough_gas_multiple_addresses_second_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-enough_gas-multiple_addresses_second_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_enough_gas_multiple_addresses_second_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-enough_gas-multiple_addresses_second_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_enough_gas_multiple_addresses_second_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-enough_gas-multiple_addresses_second_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_enough_gas_repeated_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-enough_gas-repeated_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_enough_gas_repeated_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-enough_gas-repeated_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_enough_gas_repeated_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-enough_gas-repeated_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_enough_gas_single_address_multiple_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-enough_gas-single_address_multiple_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_enough_gas_single_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-enough_gas-single_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_enough_gas_single_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-enough_gas-single_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_not_enough_gas_empty_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-not_enough_gas-empty_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_not_enough_gas_multiple_addresses_first_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-not_enough_gas-multiple_addresses_first_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_not_enough_gas_multiple_addresses_first_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-not_enough_gas-multiple_addresses_first_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_not_enough_gas_multiple_addresses_second_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-not_enough_gas-multiple_addresses_second_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_not_enough_gas_multiple_addresses_second_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-not_enough_gas-multiple_addresses_second_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_not_enough_gas_multiple_addresses_second_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-not_enough_gas-multiple_addresses_second_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_not_enough_gas_repeated_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-not_enough_gas-repeated_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_not_enough_gas_repeated_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-not_enough_gas-repeated_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_not_enough_gas_repeated_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-not_enough_gas-repeated_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_not_enough_gas_single_address_multiple_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-not_enough_gas-single_address_multiple_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_not_enough_gas_single_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-not_enough_gas-single_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Berlin_state_test_not_enough_gas_single_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Berlin-state_test-not_enough_gas-single_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_enough_gas_empty_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-enough_gas-empty_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_enough_gas_multiple_addresses_first_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-enough_gas-multiple_addresses_first_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_enough_gas_multiple_addresses_first_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-enough_gas-multiple_addresses_first_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_enough_gas_multiple_addresses_second_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-enough_gas-multiple_addresses_second_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_enough_gas_multiple_addresses_second_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-enough_gas-multiple_addresses_second_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_enough_gas_multiple_addresses_second_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-enough_gas-multiple_addresses_second_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_enough_gas_repeated_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-enough_gas-repeated_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_enough_gas_repeated_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-enough_gas-repeated_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_enough_gas_repeated_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-enough_gas-repeated_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_enough_gas_single_address_multiple_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-enough_gas-single_address_multiple_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_enough_gas_single_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-enough_gas-single_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_enough_gas_single_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-enough_gas-single_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_not_enough_gas_empty_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-not_enough_gas-empty_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_not_enough_gas_multiple_addresses_first_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-not_enough_gas-multiple_addresses_first_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_not_enough_gas_multiple_addresses_first_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-not_enough_gas-multiple_addresses_first_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_not_enough_gas_multiple_addresses_second_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-not_enough_gas-multiple_addresses_second_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_not_enough_gas_multiple_addresses_second_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-not_enough_gas-multiple_addresses_second_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_not_enough_gas_multiple_addresses_second_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-not_enough_gas-multiple_addresses_second_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_not_enough_gas_repeated_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-not_enough_gas-repeated_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_not_enough_gas_repeated_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-not_enough_gas-repeated_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_not_enough_gas_repeated_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-not_enough_gas-repeated_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_not_enough_gas_single_address_multiple_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-not_enough_gas-single_address_multiple_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_not_enough_gas_single_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-not_enough_gas-single_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Cancun_state_test_not_enough_gas_single_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Cancun-state_test-not_enough_gas-single_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_enough_gas_empty_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-enough_gas-empty_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_enough_gas_multiple_addresses_first_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-enough_gas-multiple_addresses_first_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_enough_gas_multiple_addresses_first_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-enough_gas-multiple_addresses_first_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_enough_gas_multiple_addresses_second_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-enough_gas-multiple_addresses_second_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_enough_gas_multiple_addresses_second_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-enough_gas-multiple_addresses_second_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_enough_gas_multiple_addresses_second_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-enough_gas-multiple_addresses_second_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_enough_gas_repeated_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-enough_gas-repeated_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_enough_gas_repeated_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-enough_gas-repeated_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_enough_gas_repeated_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-enough_gas-repeated_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_enough_gas_single_address_multiple_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-enough_gas-single_address_multiple_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_enough_gas_single_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-enough_gas-single_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_enough_gas_single_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-enough_gas-single_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_not_enough_gas_empty_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-not_enough_gas-empty_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_not_enough_gas_multiple_addresses_first_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-not_enough_gas-multiple_addresses_first_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_not_enough_gas_multiple_addresses_first_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-not_enough_gas-multiple_addresses_first_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_not_enough_gas_multiple_addresses_second_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-not_enough_gas-multiple_addresses_second_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_not_enough_gas_multiple_addresses_second_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-not_enough_gas-multiple_addresses_second_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_not_enough_gas_multiple_addresses_second_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-not_enough_gas-multiple_addresses_second_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_not_enough_gas_repeated_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-not_enough_gas-repeated_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_not_enough_gas_repeated_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-not_enough_gas-repeated_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_not_enough_gas_repeated_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-not_enough_gas-repeated_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_not_enough_gas_single_address_multiple_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-not_enough_gas-single_address_multiple_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_not_enough_gas_single_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-not_enough_gas-single_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_London_state_test_not_enough_gas_single_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_London-state_test-not_enough_gas-single_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_enough_gas_empty_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-enough_gas-empty_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_enough_gas_multiple_addresses_first_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-enough_gas-multiple_addresses_first_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_enough_gas_multiple_addresses_first_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-enough_gas-multiple_addresses_first_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_enough_gas_multiple_addresses_second_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-enough_gas-multiple_addresses_second_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_enough_gas_multiple_addresses_second_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-enough_gas-multiple_addresses_second_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_enough_gas_multiple_addresses_second_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-enough_gas-multiple_addresses_second_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_enough_gas_repeated_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-enough_gas-repeated_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_enough_gas_repeated_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-enough_gas-repeated_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_enough_gas_repeated_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-enough_gas-repeated_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_enough_gas_single_address_multiple_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-enough_gas-single_address_multiple_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_enough_gas_single_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-enough_gas-single_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_enough_gas_single_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-enough_gas-single_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_not_enough_gas_empty_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-not_enough_gas-empty_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_not_enough_gas_multiple_addresses_first_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-not_enough_gas-multiple_addresses_first_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_not_enough_gas_multiple_addresses_first_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-not_enough_gas-multiple_addresses_first_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_not_enough_gas_multiple_addresses_second_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-not_enough_gas-multiple_addresses_second_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_not_enough_gas_multiple_addresses_second_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-not_enough_gas-multiple_addresses_second_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_not_enough_gas_multiple_addresses_second_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-not_enough_gas-multiple_addresses_second_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_not_enough_gas_repeated_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-not_enough_gas-repeated_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_not_enough_gas_repeated_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-not_enough_gas-repeated_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_not_enough_gas_repeated_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-not_enough_gas-repeated_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_not_enough_gas_single_address_multiple_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-not_enough_gas-single_address_multiple_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_not_enough_gas_single_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-not_enough_gas-single_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Paris_state_test_not_enough_gas_single_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Paris-state_test-not_enough_gas-single_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_enough_gas_empty_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-enough_gas-empty_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_enough_gas_multiple_addresses_first_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-enough_gas-multiple_addresses_first_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_enough_gas_multiple_addresses_first_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-enough_gas-multiple_addresses_first_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_enough_gas_multiple_addresses_second_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-enough_gas-multiple_addresses_second_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_enough_gas_multiple_addresses_second_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-enough_gas-multiple_addresses_second_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_enough_gas_multiple_addresses_second_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-enough_gas-multiple_addresses_second_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_enough_gas_repeated_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-enough_gas-repeated_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_enough_gas_repeated_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-enough_gas-repeated_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_enough_gas_repeated_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-enough_gas-repeated_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_enough_gas_single_address_multiple_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-enough_gas-single_address_multiple_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_enough_gas_single_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-enough_gas-single_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_enough_gas_single_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-enough_gas-single_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_not_enough_gas_empty_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-not_enough_gas-empty_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_not_enough_gas_multiple_addresses_first_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-not_enough_gas-multiple_addresses_first_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_not_enough_gas_multiple_addresses_first_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-not_enough_gas-multiple_addresses_first_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_not_enough_gas_multiple_addresses_second_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-not_enough_gas-multiple_addresses_second_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_not_enough_gas_multiple_addresses_second_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-not_enough_gas-multiple_addresses_second_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_not_enough_gas_multiple_addresses_second_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-not_enough_gas-multiple_addresses_second_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_not_enough_gas_repeated_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-not_enough_gas-repeated_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_not_enough_gas_repeated_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-not_enough_gas-repeated_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_not_enough_gas_repeated_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-not_enough_gas-repeated_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_not_enough_gas_single_address_multiple_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-not_enough_gas-single_address_multiple_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_not_enough_gas_single_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-not_enough_gas-single_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Prague_state_test_not_enough_gas_single_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Prague-state_test-not_enough_gas-single_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_enough_gas_empty_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-enough_gas-empty_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_enough_gas_multiple_addresses_first_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-enough_gas-multiple_addresses_first_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_enough_gas_multiple_addresses_first_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-enough_gas-multiple_addresses_first_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_enough_gas_multiple_addresses_second_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-enough_gas-multiple_addresses_second_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_enough_gas_multiple_addresses_second_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-enough_gas-multiple_addresses_second_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_enough_gas_multiple_addresses_second_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-enough_gas-multiple_addresses_second_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_enough_gas_repeated_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-enough_gas-repeated_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_enough_gas_repeated_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-enough_gas-repeated_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_enough_gas_repeated_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-enough_gas-repeated_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_enough_gas_single_address_multiple_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-enough_gas-single_address_multiple_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_enough_gas_single_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-enough_gas-single_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_enough_gas_single_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-enough_gas-single_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_not_enough_gas_empty_access_list_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-not_enough_gas-empty_access_list]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_not_enough_gas_multiple_addresses_first_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-not_enough_gas-multiple_addresses_first_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_not_enough_gas_multiple_addresses_first_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-not_enough_gas-multiple_addresses_first_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_not_enough_gas_multiple_addresses_second_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-not_enough_gas-multiple_addresses_second_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_not_enough_gas_multiple_addresses_second_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-not_enough_gas-multiple_addresses_second_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_not_enough_gas_multiple_addresses_second_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-not_enough_gas-multiple_addresses_second_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_not_enough_gas_repeated_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-not_enough_gas-repeated_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_not_enough_gas_repeated_address_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-not_enough_gas-repeated_address_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_not_enough_gas_repeated_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-not_enough_gas-repeated_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_not_enough_gas_single_address_multiple_no_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-not_enough_gas-single_address_multiple_no_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_not_enough_gas_single_address_multiple_storage_keys_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-not_enough_gas-single_address_multiple_storage_keys]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_berlin_eip2930_access_list_test_acl_py__test_transaction_intrinsic_gas_cost_fork_Shanghai_state_test_not_enough_gas_single_address_single_storage_key_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/berlin/eip2930_access_list/acl/transaction_intrinsic_gas_cost.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/berlin/eip2930_access_list/test_acl.py::test_transaction_intrinsic_gas_cost[fork_Shanghai-state_test-not_enough_gas-single_address_single_storage_key]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
