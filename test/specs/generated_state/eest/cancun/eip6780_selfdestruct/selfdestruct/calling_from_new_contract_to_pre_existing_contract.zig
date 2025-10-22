const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_calling_from_new_contract_to_pre_existing_contract_fork_Cancun_state_test_create_opcode_CREATE_call_opcode_CALLCODE_selfdestruct_contract_initial_balance_0_call_times_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/calling_from_new_contract_to_pre_existing_contract.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_calling_from_new_contract_to_pre_existing_contract[fork_Cancun-state_test-create_opcode_CREATE-call_opcode_CALLCODE-selfdestruct_contract_initial_balance_0-call_times_1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_calling_from_new_contract_to_pre_existing_contract_fork_Cancun_state_test_create_opcode_CREATE_call_opcode_CALLCODE_selfdestruct_contract_initial_balance_1_call_times_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/calling_from_new_contract_to_pre_existing_contract.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_calling_from_new_contract_to_pre_existing_contract[fork_Cancun-state_test-create_opcode_CREATE-call_opcode_CALLCODE-selfdestruct_contract_initial_balance_1-call_times_1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_calling_from_new_contract_to_pre_existing_contract_fork_Cancun_state_test_create_opcode_CREATE_call_opcode_DELEGATECALL_selfdestruct_contract_initial_balance_0_call_times_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/calling_from_new_contract_to_pre_existing_contract.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_calling_from_new_contract_to_pre_existing_contract[fork_Cancun-state_test-create_opcode_CREATE-call_opcode_DELEGATECALL-selfdestruct_contract_initial_balance_0-call_times_1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_calling_from_new_contract_to_pre_existing_contract_fork_Cancun_state_test_create_opcode_CREATE_call_opcode_DELEGATECALL_selfdestruct_contract_initial_balance_1_call_times_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/calling_from_new_contract_to_pre_existing_contract.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_calling_from_new_contract_to_pre_existing_contract[fork_Cancun-state_test-create_opcode_CREATE-call_opcode_DELEGATECALL-selfdestruct_contract_initial_balance_1-call_times_1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_calling_from_new_contract_to_pre_existing_contract_fork_Prague_state_test_create_opcode_CREATE_call_opcode_CALLCODE_selfdestruct_contract_initial_balance_0_call_times_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/calling_from_new_contract_to_pre_existing_contract.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_calling_from_new_contract_to_pre_existing_contract[fork_Prague-state_test-create_opcode_CREATE-call_opcode_CALLCODE-selfdestruct_contract_initial_balance_0-call_times_1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_calling_from_new_contract_to_pre_existing_contract_fork_Prague_state_test_create_opcode_CREATE_call_opcode_CALLCODE_selfdestruct_contract_initial_balance_1_call_times_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/calling_from_new_contract_to_pre_existing_contract.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_calling_from_new_contract_to_pre_existing_contract[fork_Prague-state_test-create_opcode_CREATE-call_opcode_CALLCODE-selfdestruct_contract_initial_balance_1-call_times_1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_calling_from_new_contract_to_pre_existing_contract_fork_Prague_state_test_create_opcode_CREATE_call_opcode_DELEGATECALL_selfdestruct_contract_initial_balance_0_call_times_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/calling_from_new_contract_to_pre_existing_contract.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_calling_from_new_contract_to_pre_existing_contract[fork_Prague-state_test-create_opcode_CREATE-call_opcode_DELEGATECALL-selfdestruct_contract_initial_balance_0-call_times_1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_calling_from_new_contract_to_pre_existing_contract_fork_Prague_state_test_create_opcode_CREATE_call_opcode_DELEGATECALL_selfdestruct_contract_initial_balance_1_call_times_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/calling_from_new_contract_to_pre_existing_contract.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_calling_from_new_contract_to_pre_existing_contract[fork_Prague-state_test-create_opcode_CREATE-call_opcode_DELEGATECALL-selfdestruct_contract_initial_balance_1-call_times_1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_calling_from_new_contract_to_pre_existing_contract_fork_Shanghai_state_test_create_opcode_CREATE_call_opcode_CALLCODE_selfdestruct_contract_initial_balance_0_call_times_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/calling_from_new_contract_to_pre_existing_contract.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_calling_from_new_contract_to_pre_existing_contract[fork_Shanghai-state_test-create_opcode_CREATE-call_opcode_CALLCODE-selfdestruct_contract_initial_balance_0-call_times_1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_calling_from_new_contract_to_pre_existing_contract_fork_Shanghai_state_test_create_opcode_CREATE_call_opcode_CALLCODE_selfdestruct_contract_initial_balance_1_call_times_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/calling_from_new_contract_to_pre_existing_contract.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_calling_from_new_contract_to_pre_existing_contract[fork_Shanghai-state_test-create_opcode_CREATE-call_opcode_CALLCODE-selfdestruct_contract_initial_balance_1-call_times_1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_calling_from_new_contract_to_pre_existing_contract_fork_Shanghai_state_test_create_opcode_CREATE_call_opcode_DELEGATECALL_selfdestruct_contract_initial_balance_0_call_times_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/calling_from_new_contract_to_pre_existing_contract.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_calling_from_new_contract_to_pre_existing_contract[fork_Shanghai-state_test-create_opcode_CREATE-call_opcode_DELEGATECALL-selfdestruct_contract_initial_balance_0-call_times_1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_calling_from_new_contract_to_pre_existing_contract_fork_Shanghai_state_test_create_opcode_CREATE_call_opcode_DELEGATECALL_selfdestruct_contract_initial_balance_1_call_times_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/calling_from_new_contract_to_pre_existing_contract.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_calling_from_new_contract_to_pre_existing_contract[fork_Shanghai-state_test-create_opcode_CREATE-call_opcode_DELEGATECALL-selfdestruct_contract_initial_balance_1-call_times_1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
