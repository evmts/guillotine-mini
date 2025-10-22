const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test__type_0_protected_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test--type_0-protected-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test__type_0_protected_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test--type_0-protected-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test__type_0_protected_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test--type_0-protected-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test__type_0_protected_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test--type_0-protected-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test__type_0_protected_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test--type_0-protected-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test__type_0_protected_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test--type_0-protected-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test__type_0_unprotected_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test--type_0-unprotected-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test__type_0_unprotected_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test--type_0-unprotected-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test__type_0_unprotected_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test--type_0-unprotected-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test__type_0_unprotected_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test--type_0-unprotected-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test__type_0_unprotected_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test--type_0-unprotected-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test__type_0_unprotected_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test--type_0-unprotected-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_contract_creating_type_0_protected_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-contract_creating-type_0-protected-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_contract_creating_type_0_protected_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-contract_creating-type_0-protected-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_contract_creating_type_0_protected_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-contract_creating-type_0-protected-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_contract_creating_type_0_protected_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-contract_creating-type_0-protected-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_contract_creating_type_0_protected_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-contract_creating-type_0-protected-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_contract_creating_type_0_protected_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-contract_creating-type_0-protected-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_contract_creating_type_0_unprotected_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-contract_creating-type_0-unprotected-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_contract_creating_type_0_unprotected_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-contract_creating-type_0-unprotected-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_contract_creating_type_0_unprotected_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-contract_creating-type_0-unprotected-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_contract_creating_type_0_unprotected_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-contract_creating-type_0-unprotected-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_contract_creating_type_0_unprotected_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-contract_creating-type_0-unprotected-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_contract_creating_type_0_unprotected_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-contract_creating-type_0-unprotected-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_to_eoa_type_0_protected_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-to_eoa-type_0-protected-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_to_eoa_type_0_protected_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-to_eoa-type_0-protected-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_to_eoa_type_0_protected_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-to_eoa-type_0-protected-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_to_eoa_type_0_protected_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-to_eoa-type_0-protected-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_to_eoa_type_0_protected_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-to_eoa-type_0-protected-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_to_eoa_type_0_protected_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-to_eoa-type_0-protected-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_to_eoa_type_0_unprotected_exact_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-to_eoa-type_0-unprotected-exact_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_to_eoa_type_0_unprotected_exact_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-to_eoa-type_0-unprotected-exact_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_to_eoa_type_0_unprotected_extra_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-to_eoa-type_0-unprotected-extra_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_to_eoa_type_0_unprotected_extra_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-to_eoa-type_0-unprotected-extra_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_to_eoa_type_0_unprotected_insufficient_gas_floor_gas_greater_than_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-to_eoa-type_0-unprotected-insufficient_gas-floor_gas_greater_than_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_transaction_validity_py__test_transaction_validity_type_0_fork_Prague_state_test_to_eoa_type_0_unprotected_insufficient_gas_floor_gas_less_than_or_equal_to_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/transaction_validity/transaction_validity_type_0.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_transaction_validity.py::test_transaction_validity_type_0[fork_Prague-state_test-to_eoa-type_0-unprotected-insufficient_gas-floor_gas_less_than_or_equal_to_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
