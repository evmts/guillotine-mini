const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Cancun_state_test_call_create2_contract_in_between_False_call_create2_contract_at_the_end_True_create2_dest_already_in_state_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Cancun-state_test-call_create2_contract_in_between_False-call_create2_contract_at_the_end_True-create2_dest_already_in_state_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Cancun_state_test_call_create2_contract_in_between_False_call_create2_contract_at_the_end_True_create2_dest_already_in_state_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Cancun-state_test-call_create2_contract_in_between_False-call_create2_contract_at_the_end_True-create2_dest_already_in_state_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Cancun_state_test_call_create2_contract_in_between_True_call_create2_contract_at_the_end_False_create2_dest_already_in_state_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Cancun-state_test-call_create2_contract_in_between_True-call_create2_contract_at_the_end_False-create2_dest_already_in_state_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Cancun_state_test_call_create2_contract_in_between_True_call_create2_contract_at_the_end_False_create2_dest_already_in_state_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Cancun-state_test-call_create2_contract_in_between_True-call_create2_contract_at_the_end_False-create2_dest_already_in_state_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Cancun_state_test_call_create2_contract_in_between_True_call_create2_contract_at_the_end_True_create2_dest_already_in_state_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Cancun-state_test-call_create2_contract_in_between_True-call_create2_contract_at_the_end_True-create2_dest_already_in_state_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Cancun_state_test_call_create2_contract_in_between_True_call_create2_contract_at_the_end_True_create2_dest_already_in_state_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Cancun-state_test-call_create2_contract_in_between_True-call_create2_contract_at_the_end_True-create2_dest_already_in_state_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Paris_state_test_call_create2_contract_in_between_False_call_create2_contract_at_the_end_True_create2_dest_already_in_state_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Paris-state_test-call_create2_contract_in_between_False-call_create2_contract_at_the_end_True-create2_dest_already_in_state_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Paris_state_test_call_create2_contract_in_between_False_call_create2_contract_at_the_end_True_create2_dest_already_in_state_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Paris-state_test-call_create2_contract_in_between_False-call_create2_contract_at_the_end_True-create2_dest_already_in_state_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Paris_state_test_call_create2_contract_in_between_True_call_create2_contract_at_the_end_False_create2_dest_already_in_state_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Paris-state_test-call_create2_contract_in_between_True-call_create2_contract_at_the_end_False-create2_dest_already_in_state_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Paris_state_test_call_create2_contract_in_between_True_call_create2_contract_at_the_end_False_create2_dest_already_in_state_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Paris-state_test-call_create2_contract_in_between_True-call_create2_contract_at_the_end_False-create2_dest_already_in_state_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Paris_state_test_call_create2_contract_in_between_True_call_create2_contract_at_the_end_True_create2_dest_already_in_state_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Paris-state_test-call_create2_contract_in_between_True-call_create2_contract_at_the_end_True-create2_dest_already_in_state_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Paris_state_test_call_create2_contract_in_between_True_call_create2_contract_at_the_end_True_create2_dest_already_in_state_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Paris-state_test-call_create2_contract_in_between_True-call_create2_contract_at_the_end_True-create2_dest_already_in_state_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Prague_state_test_call_create2_contract_in_between_False_call_create2_contract_at_the_end_True_create2_dest_already_in_state_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Prague-state_test-call_create2_contract_in_between_False-call_create2_contract_at_the_end_True-create2_dest_already_in_state_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Prague_state_test_call_create2_contract_in_between_False_call_create2_contract_at_the_end_True_create2_dest_already_in_state_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Prague-state_test-call_create2_contract_in_between_False-call_create2_contract_at_the_end_True-create2_dest_already_in_state_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Prague_state_test_call_create2_contract_in_between_True_call_create2_contract_at_the_end_False_create2_dest_already_in_state_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Prague-state_test-call_create2_contract_in_between_True-call_create2_contract_at_the_end_False-create2_dest_already_in_state_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Prague_state_test_call_create2_contract_in_between_True_call_create2_contract_at_the_end_False_create2_dest_already_in_state_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Prague-state_test-call_create2_contract_in_between_True-call_create2_contract_at_the_end_False-create2_dest_already_in_state_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Prague_state_test_call_create2_contract_in_between_True_call_create2_contract_at_the_end_True_create2_dest_already_in_state_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Prague-state_test-call_create2_contract_in_between_True-call_create2_contract_at_the_end_True-create2_dest_already_in_state_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Prague_state_test_call_create2_contract_in_between_True_call_create2_contract_at_the_end_True_create2_dest_already_in_state_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Prague-state_test-call_create2_contract_in_between_True-call_create2_contract_at_the_end_True-create2_dest_already_in_state_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Shanghai_state_test_call_create2_contract_in_between_False_call_create2_contract_at_the_end_True_create2_dest_already_in_state_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Shanghai-state_test-call_create2_contract_in_between_False-call_create2_contract_at_the_end_True-create2_dest_already_in_state_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Shanghai_state_test_call_create2_contract_in_between_False_call_create2_contract_at_the_end_True_create2_dest_already_in_state_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Shanghai-state_test-call_create2_contract_in_between_False-call_create2_contract_at_the_end_True-create2_dest_already_in_state_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Shanghai_state_test_call_create2_contract_in_between_True_call_create2_contract_at_the_end_False_create2_dest_already_in_state_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Shanghai-state_test-call_create2_contract_in_between_True-call_create2_contract_at_the_end_False-create2_dest_already_in_state_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Shanghai_state_test_call_create2_contract_in_between_True_call_create2_contract_at_the_end_False_create2_dest_already_in_state_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Shanghai-state_test-call_create2_contract_in_between_True-call_create2_contract_at_the_end_False-create2_dest_already_in_state_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Shanghai_state_test_call_create2_contract_in_between_True_call_create2_contract_at_the_end_True_create2_dest_already_in_state_False_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Shanghai-state_test-call_create2_contract_in_between_True-call_create2_contract_at_the_end_True-create2_dest_already_in_state_False]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip6780_selfdestruct_test_dynamic_create2_selfdestruct_collision_py__test_dynamic_create2_selfdestruct_collision_fork_Shanghai_state_test_call_create2_contract_in_between_True_call_create2_contract_at_the_end_True_create2_dest_already_in_state_True_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip6780_selfdestruct/dynamic_create2_selfdestruct_collision/dynamic_create2_selfdestruct_collision.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip6780_selfdestruct/test_dynamic_create2_selfdestruct_collision.py::test_dynamic_create2_selfdestruct_collision[fork_Shanghai-state_test-call_create2_contract_in_between_True-call_create2_contract_at_the_end_True-create2_dest_already_in_state_True]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
