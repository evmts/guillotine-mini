const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_frontier_identity_precompile_test_identity_returndatasize_py__test_identity_precompile_returndata_fork_Berlin_state_test_output_size_greater_than_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity_returndatasize/identity_precompile_returndata.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity_returndatasize.py::test_identity_precompile_returndata[fork_Berlin-state_test-output_size_greater_than_input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_returndatasize_py__test_identity_precompile_returndata_fork_Berlin_state_test_output_size_less_than_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity_returndatasize/identity_precompile_returndata.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity_returndatasize.py::test_identity_precompile_returndata[fork_Berlin-state_test-output_size_less_than_input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_returndatasize_py__test_identity_precompile_returndata_fork_Byzantium_state_test_output_size_greater_than_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity_returndatasize/identity_precompile_returndata.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity_returndatasize.py::test_identity_precompile_returndata[fork_Byzantium-state_test-output_size_greater_than_input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_returndatasize_py__test_identity_precompile_returndata_fork_Byzantium_state_test_output_size_less_than_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity_returndatasize/identity_precompile_returndata.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity_returndatasize.py::test_identity_precompile_returndata[fork_Byzantium-state_test-output_size_less_than_input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_returndatasize_py__test_identity_precompile_returndata_fork_Cancun_state_test_output_size_greater_than_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity_returndatasize/identity_precompile_returndata.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity_returndatasize.py::test_identity_precompile_returndata[fork_Cancun-state_test-output_size_greater_than_input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_returndatasize_py__test_identity_precompile_returndata_fork_Cancun_state_test_output_size_less_than_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity_returndatasize/identity_precompile_returndata.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity_returndatasize.py::test_identity_precompile_returndata[fork_Cancun-state_test-output_size_less_than_input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_returndatasize_py__test_identity_precompile_returndata_fork_ConstantinopleFix_state_test_output_size_greater_than_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity_returndatasize/identity_precompile_returndata.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity_returndatasize.py::test_identity_precompile_returndata[fork_ConstantinopleFix-state_test-output_size_greater_than_input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_returndatasize_py__test_identity_precompile_returndata_fork_ConstantinopleFix_state_test_output_size_less_than_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity_returndatasize/identity_precompile_returndata.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity_returndatasize.py::test_identity_precompile_returndata[fork_ConstantinopleFix-state_test-output_size_less_than_input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_returndatasize_py__test_identity_precompile_returndata_fork_Istanbul_state_test_output_size_greater_than_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity_returndatasize/identity_precompile_returndata.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity_returndatasize.py::test_identity_precompile_returndata[fork_Istanbul-state_test-output_size_greater_than_input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_returndatasize_py__test_identity_precompile_returndata_fork_Istanbul_state_test_output_size_less_than_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity_returndatasize/identity_precompile_returndata.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity_returndatasize.py::test_identity_precompile_returndata[fork_Istanbul-state_test-output_size_less_than_input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_returndatasize_py__test_identity_precompile_returndata_fork_London_state_test_output_size_greater_than_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity_returndatasize/identity_precompile_returndata.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity_returndatasize.py::test_identity_precompile_returndata[fork_London-state_test-output_size_greater_than_input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_returndatasize_py__test_identity_precompile_returndata_fork_London_state_test_output_size_less_than_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity_returndatasize/identity_precompile_returndata.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity_returndatasize.py::test_identity_precompile_returndata[fork_London-state_test-output_size_less_than_input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_returndatasize_py__test_identity_precompile_returndata_fork_Paris_state_test_output_size_greater_than_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity_returndatasize/identity_precompile_returndata.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity_returndatasize.py::test_identity_precompile_returndata[fork_Paris-state_test-output_size_greater_than_input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_returndatasize_py__test_identity_precompile_returndata_fork_Paris_state_test_output_size_less_than_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity_returndatasize/identity_precompile_returndata.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity_returndatasize.py::test_identity_precompile_returndata[fork_Paris-state_test-output_size_less_than_input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_returndatasize_py__test_identity_precompile_returndata_fork_Prague_state_test_output_size_greater_than_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity_returndatasize/identity_precompile_returndata.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity_returndatasize.py::test_identity_precompile_returndata[fork_Prague-state_test-output_size_greater_than_input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_returndatasize_py__test_identity_precompile_returndata_fork_Prague_state_test_output_size_less_than_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity_returndatasize/identity_precompile_returndata.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity_returndatasize.py::test_identity_precompile_returndata[fork_Prague-state_test-output_size_less_than_input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_returndatasize_py__test_identity_precompile_returndata_fork_Shanghai_state_test_output_size_greater_than_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity_returndatasize/identity_precompile_returndata.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity_returndatasize.py::test_identity_precompile_returndata[fork_Shanghai-state_test-output_size_greater_than_input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_frontier_identity_precompile_test_identity_returndatasize_py__test_identity_precompile_returndata_fork_Shanghai_state_test_output_size_less_than_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/frontier/identity_precompile/identity_returndatasize/identity_precompile_returndata.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/frontier/identity_precompile/test_identity_returndatasize.py::test_identity_precompile_returndata[fork_Shanghai-state_test-output_size_less_than_input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
