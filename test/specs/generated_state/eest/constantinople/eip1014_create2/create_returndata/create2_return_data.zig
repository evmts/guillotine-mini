const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Berlin_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Berlin-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Cancun_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Cancun-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Istanbul_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Istanbul-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_London_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_London-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Paris_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Paris-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Prague_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Prague-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_RETURN_return_type_RETURN_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_RETURN-return_type_RETURN-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_RETURN_return_type_REVERT_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_RETURN-return_type_REVERT-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_REVERT_return_type_RETURN_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_REVERT-return_type_RETURN-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE2_call_return_size_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE2-call_return_size_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE2_call_return_size_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE2-call_return_size_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_constantinople_eip1014_create2_test_create_returndata_py__test_create2_return_data_fork_Shanghai_state_test_return_type_in_create_REVERT_return_type_REVERT_create_type_CREATE2_call_return_size_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/constantinople/eip1014_create2/create_returndata/create2_return_data.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/constantinople/eip1014_create2/test_create_returndata.py::test_create2_return_data[fork_Shanghai-state_test-return_type_in_create_REVERT-return_type_REVERT-create_type_CREATE2-call_return_size_35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
