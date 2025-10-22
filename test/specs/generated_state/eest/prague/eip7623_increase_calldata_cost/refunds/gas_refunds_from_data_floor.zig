const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_prague_eip7623_increase_calldata_cost_test_refunds_py__test_gas_refunds_from_data_floor_fork_Prague_state_test_refund_type_RefundType_AUTHORIZATION_EXISTING_AUTHORITY_refund_test_type_RefundTestType_EXECUTION_GAS_MINUS_REFUND_EQUAL_TO_DATA_FLOOR_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/refunds/gas_refunds_from_data_floor.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_refunds.py::test_gas_refunds_from_data_floor[fork_Prague-state_test-refund_type_RefundType.AUTHORIZATION_EXISTING_AUTHORITY-refund_test_type_RefundTestType.EXECUTION_GAS_MINUS_REFUND_EQUAL_TO_DATA_FLOOR]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_refunds_py__test_gas_refunds_from_data_floor_fork_Prague_state_test_refund_type_RefundType_AUTHORIZATION_EXISTING_AUTHORITY_refund_test_type_RefundTestType_EXECUTION_GAS_MINUS_REFUND_GREATER_THAN_DATA_FLOOR_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/refunds/gas_refunds_from_data_floor.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_refunds.py::test_gas_refunds_from_data_floor[fork_Prague-state_test-refund_type_RefundType.AUTHORIZATION_EXISTING_AUTHORITY-refund_test_type_RefundTestType.EXECUTION_GAS_MINUS_REFUND_GREATER_THAN_DATA_FLOOR]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_refunds_py__test_gas_refunds_from_data_floor_fork_Prague_state_test_refund_type_RefundType_AUTHORIZATION_EXISTING_AUTHORITY_refund_test_type_RefundTestType_EXECUTION_GAS_MINUS_REFUND_LESS_THAN_DATA_FLOOR_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/refunds/gas_refunds_from_data_floor.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_refunds.py::test_gas_refunds_from_data_floor[fork_Prague-state_test-refund_type_RefundType.AUTHORIZATION_EXISTING_AUTHORITY-refund_test_type_RefundTestType.EXECUTION_GAS_MINUS_REFUND_LESS_THAN_DATA_FLOOR]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_refunds_py__test_gas_refunds_from_data_floor_fork_Prague_state_test_refund_type_RefundType_STORAGE_CLEAR_refund_test_type_RefundTestType_EXECUTION_GAS_MINUS_REFUND_EQUAL_TO_DATA_FLOOR_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/refunds/gas_refunds_from_data_floor.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_refunds.py::test_gas_refunds_from_data_floor[fork_Prague-state_test-refund_type_RefundType.STORAGE_CLEAR-refund_test_type_RefundTestType.EXECUTION_GAS_MINUS_REFUND_EQUAL_TO_DATA_FLOOR]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_refunds_py__test_gas_refunds_from_data_floor_fork_Prague_state_test_refund_type_RefundType_STORAGE_CLEAR_refund_test_type_RefundTestType_EXECUTION_GAS_MINUS_REFUND_GREATER_THAN_DATA_FLOOR_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/refunds/gas_refunds_from_data_floor.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_refunds.py::test_gas_refunds_from_data_floor[fork_Prague-state_test-refund_type_RefundType.STORAGE_CLEAR-refund_test_type_RefundTestType.EXECUTION_GAS_MINUS_REFUND_GREATER_THAN_DATA_FLOOR]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_refunds_py__test_gas_refunds_from_data_floor_fork_Prague_state_test_refund_type_RefundType_STORAGE_CLEAR_refund_test_type_RefundTestType_EXECUTION_GAS_MINUS_REFUND_LESS_THAN_DATA_FLOOR_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/refunds/gas_refunds_from_data_floor.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_refunds.py::test_gas_refunds_from_data_floor[fork_Prague-state_test-refund_type_RefundType.STORAGE_CLEAR-refund_test_type_RefundTestType.EXECUTION_GAS_MINUS_REFUND_LESS_THAN_DATA_FLOOR]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_refunds_py__test_gas_refunds_from_data_floor_fork_Prague_state_test_refund_type_RefundType_STORAGE_CLEAR_AUTHORIZATION_EXISTING_AUTHORITY_refund_test_type_RefundTestType_EXECUTION_GAS_MINUS_REFUND_EQUAL_TO_DATA_FLOOR_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/refunds/gas_refunds_from_data_floor.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_refunds.py::test_gas_refunds_from_data_floor[fork_Prague-state_test-refund_type_RefundType.STORAGE_CLEAR|AUTHORIZATION_EXISTING_AUTHORITY-refund_test_type_RefundTestType.EXECUTION_GAS_MINUS_REFUND_EQUAL_TO_DATA_FLOOR]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_refunds_py__test_gas_refunds_from_data_floor_fork_Prague_state_test_refund_type_RefundType_STORAGE_CLEAR_AUTHORIZATION_EXISTING_AUTHORITY_refund_test_type_RefundTestType_EXECUTION_GAS_MINUS_REFUND_GREATER_THAN_DATA_FLOOR_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/refunds/gas_refunds_from_data_floor.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_refunds.py::test_gas_refunds_from_data_floor[fork_Prague-state_test-refund_type_RefundType.STORAGE_CLEAR|AUTHORIZATION_EXISTING_AUTHORITY-refund_test_type_RefundTestType.EXECUTION_GAS_MINUS_REFUND_GREATER_THAN_DATA_FLOOR]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7623_increase_calldata_cost_test_refunds_py__test_gas_refunds_from_data_floor_fork_Prague_state_test_refund_type_RefundType_STORAGE_CLEAR_AUTHORIZATION_EXISTING_AUTHORITY_refund_test_type_RefundTestType_EXECUTION_GAS_MINUS_REFUND_LESS_THAN_DATA_FLOOR_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7623_increase_calldata_cost/refunds/gas_refunds_from_data_floor.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7623_increase_calldata_cost/test_refunds.py::test_gas_refunds_from_data_floor[fork_Prague-state_test-refund_type_RefundType.STORAGE_CLEAR|AUTHORIZATION_EXISTING_AUTHORITY-refund_test_type_RefundTestType.EXECUTION_GAS_MINUS_REFUND_LESS_THAN_DATA_FLOOR]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
