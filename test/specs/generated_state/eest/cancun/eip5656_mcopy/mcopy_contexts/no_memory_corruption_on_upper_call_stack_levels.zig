const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_contexts_py__test_no_memory_corruption_on_upper_call_stack_levels_fork_Cancun_call_opcode_CALL_evm_code_type_LEGACY_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_contexts/no_memory_corruption_on_upper_call_stack_levels.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_contexts.py::test_no_memory_corruption_on_upper_call_stack_levels[fork_Cancun-call_opcode_CALL-evm_code_type_LEGACY-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_contexts_py__test_no_memory_corruption_on_upper_call_stack_levels_fork_Cancun_call_opcode_CALLCODE_evm_code_type_LEGACY_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_contexts/no_memory_corruption_on_upper_call_stack_levels.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_contexts.py::test_no_memory_corruption_on_upper_call_stack_levels[fork_Cancun-call_opcode_CALLCODE-evm_code_type_LEGACY-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_contexts_py__test_no_memory_corruption_on_upper_call_stack_levels_fork_Cancun_call_opcode_DELEGATECALL_evm_code_type_LEGACY_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_contexts/no_memory_corruption_on_upper_call_stack_levels.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_contexts.py::test_no_memory_corruption_on_upper_call_stack_levels[fork_Cancun-call_opcode_DELEGATECALL-evm_code_type_LEGACY-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_contexts_py__test_no_memory_corruption_on_upper_call_stack_levels_fork_Cancun_call_opcode_STATICCALL_evm_code_type_LEGACY_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_contexts/no_memory_corruption_on_upper_call_stack_levels.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_contexts.py::test_no_memory_corruption_on_upper_call_stack_levels[fork_Cancun-call_opcode_STATICCALL-evm_code_type_LEGACY-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_contexts_py__test_no_memory_corruption_on_upper_call_stack_levels_fork_Prague_call_opcode_CALL_evm_code_type_LEGACY_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_contexts/no_memory_corruption_on_upper_call_stack_levels.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_contexts.py::test_no_memory_corruption_on_upper_call_stack_levels[fork_Prague-call_opcode_CALL-evm_code_type_LEGACY-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_contexts_py__test_no_memory_corruption_on_upper_call_stack_levels_fork_Prague_call_opcode_CALLCODE_evm_code_type_LEGACY_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_contexts/no_memory_corruption_on_upper_call_stack_levels.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_contexts.py::test_no_memory_corruption_on_upper_call_stack_levels[fork_Prague-call_opcode_CALLCODE-evm_code_type_LEGACY-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_contexts_py__test_no_memory_corruption_on_upper_call_stack_levels_fork_Prague_call_opcode_DELEGATECALL_evm_code_type_LEGACY_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_contexts/no_memory_corruption_on_upper_call_stack_levels.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_contexts.py::test_no_memory_corruption_on_upper_call_stack_levels[fork_Prague-call_opcode_DELEGATECALL-evm_code_type_LEGACY-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_contexts_py__test_no_memory_corruption_on_upper_call_stack_levels_fork_Prague_call_opcode_STATICCALL_evm_code_type_LEGACY_state_test_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_contexts/no_memory_corruption_on_upper_call_stack_levels.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_contexts.py::test_no_memory_corruption_on_upper_call_stack_levels[fork_Prague-call_opcode_STATICCALL-evm_code_type_LEGACY-state_test]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
