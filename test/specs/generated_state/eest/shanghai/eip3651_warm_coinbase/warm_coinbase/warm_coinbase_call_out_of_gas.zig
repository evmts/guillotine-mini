const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Cancun_state_test_CALL_insufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Cancun-state_test-CALL-insufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Cancun_state_test_CALL_sufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Cancun-state_test-CALL-sufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Cancun_state_test_CALLCODE_insufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Cancun-state_test-CALLCODE-insufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Cancun_state_test_CALLCODE_sufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Cancun-state_test-CALLCODE-sufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Cancun_state_test_DELEGATECALL_insufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Cancun-state_test-DELEGATECALL-insufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Cancun_state_test_DELEGATECALL_sufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Cancun-state_test-DELEGATECALL-sufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Cancun_state_test_STATICCALL_insufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Cancun-state_test-STATICCALL-insufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Cancun_state_test_STATICCALL_sufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Cancun-state_test-STATICCALL-sufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Prague_state_test_CALL_insufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Prague-state_test-CALL-insufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Prague_state_test_CALL_sufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Prague-state_test-CALL-sufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Prague_state_test_CALLCODE_insufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Prague-state_test-CALLCODE-insufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Prague_state_test_CALLCODE_sufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Prague-state_test-CALLCODE-sufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Prague_state_test_DELEGATECALL_insufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Prague-state_test-DELEGATECALL-insufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Prague_state_test_DELEGATECALL_sufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Prague-state_test-DELEGATECALL-sufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Prague_state_test_STATICCALL_insufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Prague-state_test-STATICCALL-insufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Prague_state_test_STATICCALL_sufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Prague-state_test-STATICCALL-sufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Shanghai_state_test_CALL_insufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Shanghai-state_test-CALL-insufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Shanghai_state_test_CALL_sufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Shanghai-state_test-CALL-sufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Shanghai_state_test_CALLCODE_insufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Shanghai-state_test-CALLCODE-insufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Shanghai_state_test_CALLCODE_sufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Shanghai-state_test-CALLCODE-sufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Shanghai_state_test_DELEGATECALL_insufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Shanghai-state_test-DELEGATECALL-insufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Shanghai_state_test_DELEGATECALL_sufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Shanghai-state_test-DELEGATECALL-sufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Shanghai_state_test_STATICCALL_insufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Shanghai-state_test-STATICCALL-insufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3651_warm_coinbase_test_warm_coinbase_py__test_warm_coinbase_call_out_of_gas_fork_Shanghai_state_test_STATICCALL_sufficient_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3651_warm_coinbase/warm_coinbase/warm_coinbase_call_out_of_gas.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3651_warm_coinbase/test_warm_coinbase.py::test_warm_coinbase_call_out_of_gas[fork_Shanghai-state_test-STATICCALL-sufficient_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
