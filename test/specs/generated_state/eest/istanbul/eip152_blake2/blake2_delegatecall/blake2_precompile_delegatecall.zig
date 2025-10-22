const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_istanbul_eip152_blake2_test_blake2_delegatecall_py__test_blake2_precompile_delegatecall_fork_Berlin_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2_delegatecall/blake2_precompile_delegatecall.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2_delegatecall.py::test_blake2_precompile_delegatecall[fork_Berlin-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_delegatecall_py__test_blake2_precompile_delegatecall_fork_Cancun_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2_delegatecall/blake2_precompile_delegatecall.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2_delegatecall.py::test_blake2_precompile_delegatecall[fork_Cancun-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_delegatecall_py__test_blake2_precompile_delegatecall_fork_ConstantinopleFix_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2_delegatecall/blake2_precompile_delegatecall.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2_delegatecall.py::test_blake2_precompile_delegatecall[fork_ConstantinopleFix-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_delegatecall_py__test_blake2_precompile_delegatecall_fork_Istanbul_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2_delegatecall/blake2_precompile_delegatecall.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2_delegatecall.py::test_blake2_precompile_delegatecall[fork_Istanbul-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_delegatecall_py__test_blake2_precompile_delegatecall_fork_London_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2_delegatecall/blake2_precompile_delegatecall.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2_delegatecall.py::test_blake2_precompile_delegatecall[fork_London-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_delegatecall_py__test_blake2_precompile_delegatecall_fork_Paris_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2_delegatecall/blake2_precompile_delegatecall.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2_delegatecall.py::test_blake2_precompile_delegatecall[fork_Paris-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_delegatecall_py__test_blake2_precompile_delegatecall_fork_Prague_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2_delegatecall/blake2_precompile_delegatecall.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2_delegatecall.py::test_blake2_precompile_delegatecall[fork_Prague-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_istanbul_eip152_blake2_test_blake2_delegatecall_py__test_blake2_precompile_delegatecall_fork_Shanghai_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/istanbul/eip152_blake2/blake2_delegatecall/blake2_precompile_delegatecall.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/istanbul/eip152_blake2/test_blake2_delegatecall.py::test_blake2_precompile_delegatecall[fork_Shanghai-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
