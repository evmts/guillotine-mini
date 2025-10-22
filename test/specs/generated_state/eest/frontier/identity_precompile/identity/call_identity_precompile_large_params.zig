const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Berlin_state_test_tx_gas_limit_10000000_identity_5_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Berlin-state_test-tx_gas_limit_10000000-identity_5-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Berlin_state_test_tx_gas_limit_10000000_identity_5_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Berlin-state_test-tx_gas_limit_10000000-identity_5-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Berlin_state_test_tx_gas_limit_10000000_identity_6_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Berlin-state_test-tx_gas_limit_10000000-identity_6-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Berlin_state_test_tx_gas_limit_10000000_identity_6_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Berlin-state_test-tx_gas_limit_10000000-identity_6-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Byzantium_state_test_tx_gas_limit_10000000_identity_5_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Byzantium-state_test-tx_gas_limit_10000000-identity_5-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Byzantium_state_test_tx_gas_limit_10000000_identity_5_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Byzantium-state_test-tx_gas_limit_10000000-identity_5-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Byzantium_state_test_tx_gas_limit_10000000_identity_6_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Byzantium-state_test-tx_gas_limit_10000000-identity_6-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Byzantium_state_test_tx_gas_limit_10000000_identity_6_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Byzantium-state_test-tx_gas_limit_10000000-identity_6-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Cancun_state_test_tx_gas_limit_10000000_identity_5_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Cancun-state_test-tx_gas_limit_10000000-identity_5-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Cancun_state_test_tx_gas_limit_10000000_identity_5_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Cancun-state_test-tx_gas_limit_10000000-identity_5-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Cancun_state_test_tx_gas_limit_10000000_identity_6_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Cancun-state_test-tx_gas_limit_10000000-identity_6-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Cancun_state_test_tx_gas_limit_10000000_identity_6_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Cancun-state_test-tx_gas_limit_10000000-identity_6-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_ConstantinopleFix_state_test_tx_gas_limit_10000000_identity_5_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_ConstantinopleFix-state_test-tx_gas_limit_10000000-identity_5-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_ConstantinopleFix_state_test_tx_gas_limit_10000000_identity_5_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_ConstantinopleFix-state_test-tx_gas_limit_10000000-identity_5-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_ConstantinopleFix_state_test_tx_gas_limit_10000000_identity_6_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_ConstantinopleFix-state_test-tx_gas_limit_10000000-identity_6-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_ConstantinopleFix_state_test_tx_gas_limit_10000000_identity_6_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_ConstantinopleFix-state_test-tx_gas_limit_10000000-identity_6-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Istanbul_state_test_tx_gas_limit_10000000_identity_5_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Istanbul-state_test-tx_gas_limit_10000000-identity_5-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Istanbul_state_test_tx_gas_limit_10000000_identity_5_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Istanbul-state_test-tx_gas_limit_10000000-identity_5-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Istanbul_state_test_tx_gas_limit_10000000_identity_6_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Istanbul-state_test-tx_gas_limit_10000000-identity_6-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Istanbul_state_test_tx_gas_limit_10000000_identity_6_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Istanbul-state_test-tx_gas_limit_10000000-identity_6-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_London_state_test_tx_gas_limit_10000000_identity_5_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_London-state_test-tx_gas_limit_10000000-identity_5-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_London_state_test_tx_gas_limit_10000000_identity_5_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_London-state_test-tx_gas_limit_10000000-identity_5-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_London_state_test_tx_gas_limit_10000000_identity_6_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_London-state_test-tx_gas_limit_10000000-identity_6-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_London_state_test_tx_gas_limit_10000000_identity_6_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_London-state_test-tx_gas_limit_10000000-identity_6-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Paris_state_test_tx_gas_limit_10000000_identity_5_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Paris-state_test-tx_gas_limit_10000000-identity_5-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Paris_state_test_tx_gas_limit_10000000_identity_5_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Paris-state_test-tx_gas_limit_10000000-identity_5-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Paris_state_test_tx_gas_limit_10000000_identity_6_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Paris-state_test-tx_gas_limit_10000000-identity_6-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Paris_state_test_tx_gas_limit_10000000_identity_6_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Paris-state_test-tx_gas_limit_10000000-identity_6-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Prague_state_test_tx_gas_limit_10000000_identity_5_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Prague-state_test-tx_gas_limit_10000000-identity_5-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Prague_state_test_tx_gas_limit_10000000_identity_5_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Prague-state_test-tx_gas_limit_10000000-identity_5-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Prague_state_test_tx_gas_limit_10000000_identity_6_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Prague-state_test-tx_gas_limit_10000000-identity_6-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Prague_state_test_tx_gas_limit_10000000_identity_6_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Prague-state_test-tx_gas_limit_10000000-identity_6-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Shanghai_state_test_tx_gas_limit_10000000_identity_5_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Shanghai-state_test-tx_gas_limit_10000000-identity_5-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Shanghai_state_test_tx_gas_limit_10000000_identity_5_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Shanghai-state_test-tx_gas_limit_10000000-identity_5-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Shanghai_state_test_tx_gas_limit_10000000_identity_6_call_type_CALLCODE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Shanghai-state_test-tx_gas_limit_10000000-identity_6-call_type_CALLCODE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_py__test_call_identity_precompile_large_params_fork_Shanghai_state_test_tx_gas_limit_10000000_identity_6_call_type_CALL_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity/call_identity_precompile_large_params.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity.py::test_call_identity_precompile_large_params[fork_Shanghai-state_test-tx_gas_limit_10000000-identity_6-call_type_CALL]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
