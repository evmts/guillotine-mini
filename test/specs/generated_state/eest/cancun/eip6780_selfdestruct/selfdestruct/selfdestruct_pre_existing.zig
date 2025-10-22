const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Cancun_state_test_selfdestruct_contract_initial_balance_0_multiple_calls_multiple_repeating_sendall_recipients_including_self_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Cancun-state_test-selfdestruct_contract_initial_balance_0-multiple_calls_multiple_repeating_sendall_recipients_including_self]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Cancun_state_test_selfdestruct_contract_initial_balance_0_multiple_calls_multiple_repeating_sendall_recipients_including_self_last_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Cancun-state_test-selfdestruct_contract_initial_balance_0-multiple_calls_multiple_repeating_sendall_recipients_including_self_last]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Cancun_state_test_selfdestruct_contract_initial_balance_0_multiple_calls_multiple_sendall_recipients_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Cancun-state_test-selfdestruct_contract_initial_balance_0-multiple_calls_multiple_sendall_recipients]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Cancun_state_test_selfdestruct_contract_initial_balance_0_multiple_calls_multiple_sendall_recipients_including_self_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Cancun-state_test-selfdestruct_contract_initial_balance_0-multiple_calls_multiple_sendall_recipients_including_self]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Cancun_state_test_selfdestruct_contract_initial_balance_0_multiple_calls_multiple_sendall_recipients_including_self_last_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Cancun-state_test-selfdestruct_contract_initial_balance_0-multiple_calls_multiple_sendall_recipients_including_self_last]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Cancun_state_test_selfdestruct_contract_initial_balance_0_multiple_calls_single_self_recipient_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Cancun-state_test-selfdestruct_contract_initial_balance_0-multiple_calls_single_self_recipient]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Cancun_state_test_selfdestruct_contract_initial_balance_0_multiple_calls_single_sendall_recipient_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Cancun-state_test-selfdestruct_contract_initial_balance_0-multiple_calls_single_sendall_recipient]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Cancun_state_test_selfdestruct_contract_initial_balance_0_single_call_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Cancun-state_test-selfdestruct_contract_initial_balance_0-single_call]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Cancun_state_test_selfdestruct_contract_initial_balance_0_single_call_self_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Cancun-state_test-selfdestruct_contract_initial_balance_0-single_call_self]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Cancun_state_test_selfdestruct_contract_initial_balance_100000_multiple_calls_multiple_repeating_sendall_recipients_including_self_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Cancun-state_test-selfdestruct_contract_initial_balance_100000-multiple_calls_multiple_repeating_sendall_recipients_including_self]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Cancun_state_test_selfdestruct_contract_initial_balance_100000_multiple_calls_multiple_repeating_sendall_recipients_including_self_last_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Cancun-state_test-selfdestruct_contract_initial_balance_100000-multiple_calls_multiple_repeating_sendall_recipients_including_self_last]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Cancun_state_test_selfdestruct_contract_initial_balance_100000_multiple_calls_multiple_sendall_recipients_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Cancun-state_test-selfdestruct_contract_initial_balance_100000-multiple_calls_multiple_sendall_recipients]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Cancun_state_test_selfdestruct_contract_initial_balance_100000_multiple_calls_multiple_sendall_recipients_including_self_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Cancun-state_test-selfdestruct_contract_initial_balance_100000-multiple_calls_multiple_sendall_recipients_including_self]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Cancun_state_test_selfdestruct_contract_initial_balance_100000_multiple_calls_multiple_sendall_recipients_including_self_last_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Cancun-state_test-selfdestruct_contract_initial_balance_100000-multiple_calls_multiple_sendall_recipients_including_self_last]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Cancun_state_test_selfdestruct_contract_initial_balance_100000_multiple_calls_single_self_recipient_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Cancun-state_test-selfdestruct_contract_initial_balance_100000-multiple_calls_single_self_recipient]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Cancun_state_test_selfdestruct_contract_initial_balance_100000_multiple_calls_single_sendall_recipient_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Cancun-state_test-selfdestruct_contract_initial_balance_100000-multiple_calls_single_sendall_recipient]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Cancun_state_test_selfdestruct_contract_initial_balance_100000_single_call_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Cancun-state_test-selfdestruct_contract_initial_balance_100000-single_call]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Cancun_state_test_selfdestruct_contract_initial_balance_100000_single_call_self_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Cancun-state_test-selfdestruct_contract_initial_balance_100000-single_call_self]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Prague_state_test_selfdestruct_contract_initial_balance_0_multiple_calls_multiple_repeating_sendall_recipients_including_self_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Prague-state_test-selfdestruct_contract_initial_balance_0-multiple_calls_multiple_repeating_sendall_recipients_including_self]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Prague_state_test_selfdestruct_contract_initial_balance_0_multiple_calls_multiple_repeating_sendall_recipients_including_self_last_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Prague-state_test-selfdestruct_contract_initial_balance_0-multiple_calls_multiple_repeating_sendall_recipients_including_self_last]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Prague_state_test_selfdestruct_contract_initial_balance_0_multiple_calls_multiple_sendall_recipients_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Prague-state_test-selfdestruct_contract_initial_balance_0-multiple_calls_multiple_sendall_recipients]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Prague_state_test_selfdestruct_contract_initial_balance_0_multiple_calls_multiple_sendall_recipients_including_self_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Prague-state_test-selfdestruct_contract_initial_balance_0-multiple_calls_multiple_sendall_recipients_including_self]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Prague_state_test_selfdestruct_contract_initial_balance_0_multiple_calls_multiple_sendall_recipients_including_self_last_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Prague-state_test-selfdestruct_contract_initial_balance_0-multiple_calls_multiple_sendall_recipients_including_self_last]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Prague_state_test_selfdestruct_contract_initial_balance_0_multiple_calls_single_self_recipient_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Prague-state_test-selfdestruct_contract_initial_balance_0-multiple_calls_single_self_recipient]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Prague_state_test_selfdestruct_contract_initial_balance_0_multiple_calls_single_sendall_recipient_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Prague-state_test-selfdestruct_contract_initial_balance_0-multiple_calls_single_sendall_recipient]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Prague_state_test_selfdestruct_contract_initial_balance_0_single_call_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Prague-state_test-selfdestruct_contract_initial_balance_0-single_call]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Prague_state_test_selfdestruct_contract_initial_balance_0_single_call_self_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Prague-state_test-selfdestruct_contract_initial_balance_0-single_call_self]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Prague_state_test_selfdestruct_contract_initial_balance_100000_multiple_calls_multiple_repeating_sendall_recipients_including_self_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Prague-state_test-selfdestruct_contract_initial_balance_100000-multiple_calls_multiple_repeating_sendall_recipients_including_self]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Prague_state_test_selfdestruct_contract_initial_balance_100000_multiple_calls_multiple_repeating_sendall_recipients_including_self_last_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Prague-state_test-selfdestruct_contract_initial_balance_100000-multiple_calls_multiple_repeating_sendall_recipients_including_self_last]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Prague_state_test_selfdestruct_contract_initial_balance_100000_multiple_calls_multiple_sendall_recipients_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Prague-state_test-selfdestruct_contract_initial_balance_100000-multiple_calls_multiple_sendall_recipients]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Prague_state_test_selfdestruct_contract_initial_balance_100000_multiple_calls_multiple_sendall_recipients_including_self_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Prague-state_test-selfdestruct_contract_initial_balance_100000-multiple_calls_multiple_sendall_recipients_including_self]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Prague_state_test_selfdestruct_contract_initial_balance_100000_multiple_calls_multiple_sendall_recipients_including_self_last_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Prague-state_test-selfdestruct_contract_initial_balance_100000-multiple_calls_multiple_sendall_recipients_including_self_last]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Prague_state_test_selfdestruct_contract_initial_balance_100000_multiple_calls_single_self_recipient_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Prague-state_test-selfdestruct_contract_initial_balance_100000-multiple_calls_single_self_recipient]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Prague_state_test_selfdestruct_contract_initial_balance_100000_multiple_calls_single_sendall_recipient_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Prague-state_test-selfdestruct_contract_initial_balance_100000-multiple_calls_single_sendall_recipient]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Prague_state_test_selfdestruct_contract_initial_balance_100000_single_call_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Prague-state_test-selfdestruct_contract_initial_balance_100000-single_call]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Prague_state_test_selfdestruct_contract_initial_balance_100000_single_call_self_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Prague-state_test-selfdestruct_contract_initial_balance_100000-single_call_self]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Shanghai_state_test_selfdestruct_contract_initial_balance_0_multiple_calls_multiple_repeating_sendall_recipients_including_self_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Shanghai-state_test-selfdestruct_contract_initial_balance_0-multiple_calls_multiple_repeating_sendall_recipients_including_self]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Shanghai_state_test_selfdestruct_contract_initial_balance_0_multiple_calls_multiple_repeating_sendall_recipients_including_self_last_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Shanghai-state_test-selfdestruct_contract_initial_balance_0-multiple_calls_multiple_repeating_sendall_recipients_including_self_last]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Shanghai_state_test_selfdestruct_contract_initial_balance_0_multiple_calls_multiple_sendall_recipients_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Shanghai-state_test-selfdestruct_contract_initial_balance_0-multiple_calls_multiple_sendall_recipients]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Shanghai_state_test_selfdestruct_contract_initial_balance_0_multiple_calls_multiple_sendall_recipients_including_self_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Shanghai-state_test-selfdestruct_contract_initial_balance_0-multiple_calls_multiple_sendall_recipients_including_self]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Shanghai_state_test_selfdestruct_contract_initial_balance_0_multiple_calls_multiple_sendall_recipients_including_self_last_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Shanghai-state_test-selfdestruct_contract_initial_balance_0-multiple_calls_multiple_sendall_recipients_including_self_last]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Shanghai_state_test_selfdestruct_contract_initial_balance_0_multiple_calls_single_self_recipient_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Shanghai-state_test-selfdestruct_contract_initial_balance_0-multiple_calls_single_self_recipient]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Shanghai_state_test_selfdestruct_contract_initial_balance_0_multiple_calls_single_sendall_recipient_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Shanghai-state_test-selfdestruct_contract_initial_balance_0-multiple_calls_single_sendall_recipient]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Shanghai_state_test_selfdestruct_contract_initial_balance_0_single_call_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Shanghai-state_test-selfdestruct_contract_initial_balance_0-single_call]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Shanghai_state_test_selfdestruct_contract_initial_balance_0_single_call_self_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Shanghai-state_test-selfdestruct_contract_initial_balance_0-single_call_self]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Shanghai_state_test_selfdestruct_contract_initial_balance_100000_multiple_calls_multiple_repeating_sendall_recipients_including_self_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Shanghai-state_test-selfdestruct_contract_initial_balance_100000-multiple_calls_multiple_repeating_sendall_recipients_including_self]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Shanghai_state_test_selfdestruct_contract_initial_balance_100000_multiple_calls_multiple_repeating_sendall_recipients_including_self_last_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Shanghai-state_test-selfdestruct_contract_initial_balance_100000-multiple_calls_multiple_repeating_sendall_recipients_including_self_last]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Shanghai_state_test_selfdestruct_contract_initial_balance_100000_multiple_calls_multiple_sendall_recipients_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Shanghai-state_test-selfdestruct_contract_initial_balance_100000-multiple_calls_multiple_sendall_recipients]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Shanghai_state_test_selfdestruct_contract_initial_balance_100000_multiple_calls_multiple_sendall_recipients_including_self_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Shanghai-state_test-selfdestruct_contract_initial_balance_100000-multiple_calls_multiple_sendall_recipients_including_self]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Shanghai_state_test_selfdestruct_contract_initial_balance_100000_multiple_calls_multiple_sendall_recipients_including_self_last_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Shanghai-state_test-selfdestruct_contract_initial_balance_100000-multiple_calls_multiple_sendall_recipients_including_self_last]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Shanghai_state_test_selfdestruct_contract_initial_balance_100000_multiple_calls_single_self_recipient_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Shanghai-state_test-selfdestruct_contract_initial_balance_100000-multiple_calls_single_self_recipient]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Shanghai_state_test_selfdestruct_contract_initial_balance_100000_multiple_calls_single_sendall_recipient_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Shanghai-state_test-selfdestruct_contract_initial_balance_100000-multiple_calls_single_sendall_recipient]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Shanghai_state_test_selfdestruct_contract_initial_balance_100000_single_call_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Shanghai-state_test-selfdestruct_contract_initial_balance_100000-single_call]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_selfdestruct_py__test_selfdestruct_pre_existing_fork_Shanghai_state_test_selfdestruct_contract_initial_balance_100000_single_call_self_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_selfdestruct.py::test_selfdestruct_pre_existing[fork_Shanghai-state_test-selfdestruct_contract_initial_balance_100000-single_call_self]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
