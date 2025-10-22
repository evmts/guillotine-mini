const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_shanghai_eip3855_push0_test_push0_py__TestPush0CallContext__test_push0_contract_during_call_contexts_fork_Cancun_state_test_call_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3855_push0/push0/push0_contract_during_call_contexts.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3855_push0/test_push0.py::TestPush0CallContext::test_push0_contract_during_call_contexts[fork_Cancun-state_test-call]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3855_push0_test_push0_py__TestPush0CallContext__test_push0_contract_during_call_contexts_fork_Cancun_state_test_callcode_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3855_push0/push0/push0_contract_during_call_contexts.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3855_push0/test_push0.py::TestPush0CallContext::test_push0_contract_during_call_contexts[fork_Cancun-state_test-callcode]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3855_push0_test_push0_py__TestPush0CallContext__test_push0_contract_during_call_contexts_fork_Cancun_state_test_delegatecall_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3855_push0/push0/push0_contract_during_call_contexts.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3855_push0/test_push0.py::TestPush0CallContext::test_push0_contract_during_call_contexts[fork_Cancun-state_test-delegatecall]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3855_push0_test_push0_py__TestPush0CallContext__test_push0_contract_during_call_contexts_fork_Cancun_state_test_staticcall_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3855_push0/push0/push0_contract_during_call_contexts.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3855_push0/test_push0.py::TestPush0CallContext::test_push0_contract_during_call_contexts[fork_Cancun-state_test-staticcall]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3855_push0_test_push0_py__TestPush0CallContext__test_push0_contract_during_call_contexts_fork_Prague_state_test_call_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3855_push0/push0/push0_contract_during_call_contexts.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3855_push0/test_push0.py::TestPush0CallContext::test_push0_contract_during_call_contexts[fork_Prague-state_test-call]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3855_push0_test_push0_py__TestPush0CallContext__test_push0_contract_during_call_contexts_fork_Prague_state_test_callcode_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3855_push0/push0/push0_contract_during_call_contexts.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3855_push0/test_push0.py::TestPush0CallContext::test_push0_contract_during_call_contexts[fork_Prague-state_test-callcode]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3855_push0_test_push0_py__TestPush0CallContext__test_push0_contract_during_call_contexts_fork_Prague_state_test_delegatecall_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3855_push0/push0/push0_contract_during_call_contexts.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3855_push0/test_push0.py::TestPush0CallContext::test_push0_contract_during_call_contexts[fork_Prague-state_test-delegatecall]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3855_push0_test_push0_py__TestPush0CallContext__test_push0_contract_during_call_contexts_fork_Prague_state_test_staticcall_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3855_push0/push0/push0_contract_during_call_contexts.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3855_push0/test_push0.py::TestPush0CallContext::test_push0_contract_during_call_contexts[fork_Prague-state_test-staticcall]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3855_push0_test_push0_py__TestPush0CallContext__test_push0_contract_during_call_contexts_fork_Shanghai_state_test_call_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3855_push0/push0/push0_contract_during_call_contexts.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3855_push0/test_push0.py::TestPush0CallContext::test_push0_contract_during_call_contexts[fork_Shanghai-state_test-call]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3855_push0_test_push0_py__TestPush0CallContext__test_push0_contract_during_call_contexts_fork_Shanghai_state_test_callcode_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3855_push0/push0/push0_contract_during_call_contexts.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3855_push0/test_push0.py::TestPush0CallContext::test_push0_contract_during_call_contexts[fork_Shanghai-state_test-callcode]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3855_push0_test_push0_py__TestPush0CallContext__test_push0_contract_during_call_contexts_fork_Shanghai_state_test_delegatecall_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3855_push0/push0/push0_contract_during_call_contexts.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3855_push0/test_push0.py::TestPush0CallContext::test_push0_contract_during_call_contexts[fork_Shanghai-state_test-delegatecall]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3855_push0_test_push0_py__TestPush0CallContext__test_push0_contract_during_call_contexts_fork_Shanghai_state_test_staticcall_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3855_push0/push0/push0_contract_during_call_contexts.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3855_push0/test_push0.py::TestPush0CallContext::test_push0_contract_during_call_contexts[fork_Shanghai-state_test-staticcall]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
