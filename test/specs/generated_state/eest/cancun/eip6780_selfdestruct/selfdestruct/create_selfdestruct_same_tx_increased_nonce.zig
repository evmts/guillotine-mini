const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Cancun_state_test_multiple_calls_single_beneficiary_selfdestruct_contract_initial_balance_0_create_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Cancun-state_test-multiple_calls_single beneficiary-selfdestruct_contract_initial_balance_0-create_opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Cancun_state_test_multiple_calls_single_beneficiary_selfdestruct_contract_initial_balance_0_create_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Cancun-state_test-multiple_calls_single beneficiary-selfdestruct_contract_initial_balance_0-create_opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Cancun_state_test_multiple_calls_single_beneficiary_selfdestruct_contract_initial_balance_100000_create_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Cancun-state_test-multiple_calls_single beneficiary-selfdestruct_contract_initial_balance_100000-create_opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Cancun_state_test_multiple_calls_single_beneficiary_selfdestruct_contract_initial_balance_100000_create_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Cancun-state_test-multiple_calls_single beneficiary-selfdestruct_contract_initial_balance_100000-create_opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Cancun_state_test_single_call_selfdestruct_contract_initial_balance_0_create_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Cancun-state_test-single_call-selfdestruct_contract_initial_balance_0-create_opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Cancun_state_test_single_call_selfdestruct_contract_initial_balance_0_create_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Cancun-state_test-single_call-selfdestruct_contract_initial_balance_0-create_opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Cancun_state_test_single_call_selfdestruct_contract_initial_balance_100000_create_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Cancun-state_test-single_call-selfdestruct_contract_initial_balance_100000-create_opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Cancun_state_test_single_call_selfdestruct_contract_initial_balance_100000_create_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Cancun-state_test-single_call-selfdestruct_contract_initial_balance_100000-create_opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Prague_state_test_multiple_calls_single_beneficiary_selfdestruct_contract_initial_balance_0_create_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Prague-state_test-multiple_calls_single beneficiary-selfdestruct_contract_initial_balance_0-create_opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Prague_state_test_multiple_calls_single_beneficiary_selfdestruct_contract_initial_balance_0_create_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Prague-state_test-multiple_calls_single beneficiary-selfdestruct_contract_initial_balance_0-create_opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Prague_state_test_multiple_calls_single_beneficiary_selfdestruct_contract_initial_balance_100000_create_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Prague-state_test-multiple_calls_single beneficiary-selfdestruct_contract_initial_balance_100000-create_opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Prague_state_test_multiple_calls_single_beneficiary_selfdestruct_contract_initial_balance_100000_create_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Prague-state_test-multiple_calls_single beneficiary-selfdestruct_contract_initial_balance_100000-create_opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Prague_state_test_single_call_selfdestruct_contract_initial_balance_0_create_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Prague-state_test-single_call-selfdestruct_contract_initial_balance_0-create_opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Prague_state_test_single_call_selfdestruct_contract_initial_balance_0_create_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Prague-state_test-single_call-selfdestruct_contract_initial_balance_0-create_opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Prague_state_test_single_call_selfdestruct_contract_initial_balance_100000_create_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Prague-state_test-single_call-selfdestruct_contract_initial_balance_100000-create_opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Prague_state_test_single_call_selfdestruct_contract_initial_balance_100000_create_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Prague-state_test-single_call-selfdestruct_contract_initial_balance_100000-create_opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Shanghai_state_test_multiple_calls_single_beneficiary_selfdestruct_contract_initial_balance_0_create_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Shanghai-state_test-multiple_calls_single beneficiary-selfdestruct_contract_initial_balance_0-create_opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Shanghai_state_test_multiple_calls_single_beneficiary_selfdestruct_contract_initial_balance_0_create_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Shanghai-state_test-multiple_calls_single beneficiary-selfdestruct_contract_initial_balance_0-create_opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Shanghai_state_test_multiple_calls_single_beneficiary_selfdestruct_contract_initial_balance_100000_create_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Shanghai-state_test-multiple_calls_single beneficiary-selfdestruct_contract_initial_balance_100000-create_opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Shanghai_state_test_multiple_calls_single_beneficiary_selfdestruct_contract_initial_balance_100000_create_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Shanghai-state_test-multiple_calls_single beneficiary-selfdestruct_contract_initial_balance_100000-create_opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Shanghai_state_test_single_call_selfdestruct_contract_initial_balance_0_create_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Shanghai-state_test-single_call-selfdestruct_contract_initial_balance_0-create_opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Shanghai_state_test_single_call_selfdestruct_contract_initial_balance_0_create_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Shanghai-state_test-single_call-selfdestruct_contract_initial_balance_0-create_opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Shanghai_state_test_single_call_selfdestruct_contract_initial_balance_100000_create_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Shanghai-state_test-single_call-selfdestruct_contract_initial_balance_100000-create_opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_create_selfdestruct_same_tx_increased_nonce_fork_Shanghai_state_test_single_call_selfdestruct_contract_initial_balance_100000_create_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/create_selfdestruct_same_tx_increased_nonce.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_create_selfdestruct_same_tx_increased_nonce[fork_Shanghai-state_test-single_call-selfdestruct_contract_initial_balance_100000-create_opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
