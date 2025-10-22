const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Cancun_state_test_empty_code_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Cancun-state_test-empty_code-opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Cancun_state_test_empty_code_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Cancun-state_test-empty_code-opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Cancun_state_test_empty_initcode_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Cancun-state_test-empty_initcode-opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Cancun_state_test_empty_initcode_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Cancun-state_test-empty_initcode-opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Cancun_state_test_max_code_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Cancun-state_test-max_code-opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Cancun_state_test_max_code_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Cancun-state_test-max_code-opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Cancun_state_test_max_initcode_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Cancun-state_test-max_initcode-opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Cancun_state_test_max_initcode_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Cancun-state_test-max_initcode-opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Prague_state_test_empty_code_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Prague-state_test-empty_code-opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Prague_state_test_empty_code_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Prague-state_test-empty_code-opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Prague_state_test_empty_initcode_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Prague-state_test-empty_initcode-opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Prague_state_test_empty_initcode_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Prague-state_test-empty_initcode-opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Prague_state_test_max_code_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Prague-state_test-max_code-opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Prague_state_test_max_code_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Prague-state_test-max_code-opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Prague_state_test_max_initcode_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Prague-state_test-max_initcode-opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Prague_state_test_max_initcode_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Prague-state_test-max_initcode-opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Shanghai_state_test_empty_code_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Shanghai-state_test-empty_code-opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Shanghai_state_test_empty_code_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Shanghai-state_test-empty_code-opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Shanghai_state_test_empty_initcode_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Shanghai-state_test-empty_initcode-opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Shanghai_state_test_empty_initcode_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Shanghai-state_test-empty_initcode-opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Shanghai_state_test_max_code_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Shanghai-state_test-max_code-opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Shanghai_state_test_max_code_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Shanghai-state_test-max_code-opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Shanghai_state_test_max_initcode_opcode_CREATE2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Shanghai-state_test-max_initcode-opcode_CREATE2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_with_eof_py__test_legacy_create_edge_code_size_fork_Shanghai_state_test_max_initcode_opcode_CREATE_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/with_eof/legacy_create_edge_code_size.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_with_eof.py::test_legacy_create_edge_code_size[fork_Shanghai-state_test-max_initcode-opcode_CREATE]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
