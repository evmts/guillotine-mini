const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_empty_memory_successful_False_huge_dest_huge_src_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_empty_memory-successful_False-huge_dest_huge_src_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_empty_memory_successful_False_huge_dest_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_empty_memory-successful_False-huge_dest_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_empty_memory_successful_False_huge_src_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_empty_memory-successful_False-huge_src_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_empty_memory_successful_False_multi_word_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_empty_memory-successful_False-multi_word_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_empty_memory_successful_False_multi_word_expansion_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_empty_memory-successful_False-multi_word_expansion_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_empty_memory_successful_False_single_byte_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_empty_memory-successful_False-single_byte_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_empty_memory_successful_False_single_byte_expansion_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_empty_memory-successful_False-single_byte_expansion_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_empty_memory_successful_False_single_byte_expansion_word_boundary_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_empty_memory-successful_False-single_byte_expansion_word_boundary]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_empty_memory_successful_False_single_byte_expansion_word_boundary_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_empty_memory-successful_False-single_byte_expansion_word_boundary_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_empty_memory_successful_False_zero_length_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_empty_memory-successful_False-zero_length_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_empty_memory_successful_True_huge_dest_huge_src_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_empty_memory-successful_True-huge_dest_huge_src_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_empty_memory_successful_True_huge_dest_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_empty_memory-successful_True-huge_dest_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_empty_memory_successful_True_huge_src_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_empty_memory-successful_True-huge_src_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_empty_memory_successful_True_multi_word_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_empty_memory-successful_True-multi_word_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_empty_memory_successful_True_multi_word_expansion_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_empty_memory-successful_True-multi_word_expansion_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_empty_memory_successful_True_single_byte_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_empty_memory-successful_True-single_byte_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_empty_memory_successful_True_single_byte_expansion_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_empty_memory-successful_True-single_byte_expansion_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_empty_memory_successful_True_single_byte_expansion_word_boundary_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_empty_memory-successful_True-single_byte_expansion_word_boundary]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_empty_memory_successful_True_single_byte_expansion_word_boundary_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_empty_memory-successful_True-single_byte_expansion_word_boundary_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_empty_memory_successful_True_zero_length_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_empty_memory-successful_True-zero_length_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_existent_memory_successful_False_huge_dest_huge_src_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_existent_memory-successful_False-huge_dest_huge_src_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_existent_memory_successful_False_huge_dest_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_existent_memory-successful_False-huge_dest_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_existent_memory_successful_False_huge_src_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_existent_memory-successful_False-huge_src_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_existent_memory_successful_False_multi_word_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_existent_memory-successful_False-multi_word_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_existent_memory_successful_False_multi_word_expansion_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_existent_memory-successful_False-multi_word_expansion_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_existent_memory_successful_False_single_byte_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_existent_memory-successful_False-single_byte_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_existent_memory_successful_False_single_byte_expansion_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_existent_memory-successful_False-single_byte_expansion_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_existent_memory_successful_False_single_byte_expansion_word_boundary_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_existent_memory-successful_False-single_byte_expansion_word_boundary]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_existent_memory_successful_False_single_byte_expansion_word_boundary_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_existent_memory-successful_False-single_byte_expansion_word_boundary_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_existent_memory_successful_False_zero_length_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_existent_memory-successful_False-zero_length_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_existent_memory_successful_True_huge_dest_huge_src_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_existent_memory-successful_True-huge_dest_huge_src_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_existent_memory_successful_True_huge_dest_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_existent_memory-successful_True-huge_dest_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_existent_memory_successful_True_huge_src_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_existent_memory-successful_True-huge_src_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_existent_memory_successful_True_multi_word_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_existent_memory-successful_True-multi_word_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_existent_memory_successful_True_multi_word_expansion_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_existent_memory-successful_True-multi_word_expansion_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_existent_memory_successful_True_single_byte_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_existent_memory-successful_True-single_byte_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_existent_memory_successful_True_single_byte_expansion_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_existent_memory-successful_True-single_byte_expansion_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_existent_memory_successful_True_single_byte_expansion_word_boundary_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_existent_memory-successful_True-single_byte_expansion_word_boundary]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_existent_memory_successful_True_single_byte_expansion_word_boundary_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_existent_memory-successful_True-single_byte_expansion_word_boundary_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Cancun_evm_code_type_LEGACY_state_test_from_existent_memory_successful_True_zero_length_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Cancun-evm_code_type_LEGACY-state_test-from_existent_memory-successful_True-zero_length_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_empty_memory_successful_False_huge_dest_huge_src_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_empty_memory-successful_False-huge_dest_huge_src_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_empty_memory_successful_False_huge_dest_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_empty_memory-successful_False-huge_dest_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_empty_memory_successful_False_huge_src_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_empty_memory-successful_False-huge_src_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_empty_memory_successful_False_multi_word_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_empty_memory-successful_False-multi_word_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_empty_memory_successful_False_multi_word_expansion_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_empty_memory-successful_False-multi_word_expansion_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_empty_memory_successful_False_single_byte_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_empty_memory-successful_False-single_byte_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_empty_memory_successful_False_single_byte_expansion_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_empty_memory-successful_False-single_byte_expansion_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_empty_memory_successful_False_single_byte_expansion_word_boundary_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_empty_memory-successful_False-single_byte_expansion_word_boundary]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_empty_memory_successful_False_single_byte_expansion_word_boundary_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_empty_memory-successful_False-single_byte_expansion_word_boundary_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_empty_memory_successful_False_zero_length_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_empty_memory-successful_False-zero_length_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_empty_memory_successful_True_huge_dest_huge_src_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_empty_memory-successful_True-huge_dest_huge_src_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_empty_memory_successful_True_huge_dest_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_empty_memory-successful_True-huge_dest_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_empty_memory_successful_True_huge_src_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_empty_memory-successful_True-huge_src_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_empty_memory_successful_True_multi_word_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_empty_memory-successful_True-multi_word_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_empty_memory_successful_True_multi_word_expansion_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_empty_memory-successful_True-multi_word_expansion_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_empty_memory_successful_True_single_byte_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_empty_memory-successful_True-single_byte_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_empty_memory_successful_True_single_byte_expansion_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_empty_memory-successful_True-single_byte_expansion_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_empty_memory_successful_True_single_byte_expansion_word_boundary_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_empty_memory-successful_True-single_byte_expansion_word_boundary]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_empty_memory_successful_True_single_byte_expansion_word_boundary_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_empty_memory-successful_True-single_byte_expansion_word_boundary_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_empty_memory_successful_True_zero_length_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_empty_memory-successful_True-zero_length_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_existent_memory_successful_False_huge_dest_huge_src_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_existent_memory-successful_False-huge_dest_huge_src_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_existent_memory_successful_False_huge_dest_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_existent_memory-successful_False-huge_dest_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_existent_memory_successful_False_huge_src_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_existent_memory-successful_False-huge_src_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_existent_memory_successful_False_multi_word_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_existent_memory-successful_False-multi_word_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_existent_memory_successful_False_multi_word_expansion_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_existent_memory-successful_False-multi_word_expansion_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_existent_memory_successful_False_single_byte_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_existent_memory-successful_False-single_byte_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_existent_memory_successful_False_single_byte_expansion_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_existent_memory-successful_False-single_byte_expansion_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_existent_memory_successful_False_single_byte_expansion_word_boundary_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_existent_memory-successful_False-single_byte_expansion_word_boundary]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_existent_memory_successful_False_single_byte_expansion_word_boundary_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_existent_memory-successful_False-single_byte_expansion_word_boundary_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_existent_memory_successful_False_zero_length_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_existent_memory-successful_False-zero_length_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_existent_memory_successful_True_huge_dest_huge_src_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_existent_memory-successful_True-huge_dest_huge_src_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_existent_memory_successful_True_huge_dest_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_existent_memory-successful_True-huge_dest_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_existent_memory_successful_True_huge_src_zero_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_existent_memory-successful_True-huge_src_zero_length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_existent_memory_successful_True_multi_word_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_existent_memory-successful_True-multi_word_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_existent_memory_successful_True_multi_word_expansion_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_existent_memory-successful_True-multi_word_expansion_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_existent_memory_successful_True_single_byte_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_existent_memory-successful_True-single_byte_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_existent_memory_successful_True_single_byte_expansion_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_existent_memory-successful_True-single_byte_expansion_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_existent_memory_successful_True_single_byte_expansion_word_boundary_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_existent_memory-successful_True-single_byte_expansion_word_boundary]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_existent_memory_successful_True_single_byte_expansion_word_boundary_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_existent_memory-successful_True-single_byte_expansion_word_boundary_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_memory_expansion_py__test_mcopy_memory_expansion_fork_Prague_evm_code_type_LEGACY_state_test_from_existent_memory_successful_True_zero_length_expansion_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy_memory_expansion/mcopy_memory_expansion.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy_memory_expansion.py::test_mcopy_memory_expansion[fork_Prague-evm_code_type_LEGACY-state_test-from_existent_memory-successful_True-zero_length_expansion]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
