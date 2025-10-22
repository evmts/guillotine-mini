const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_py__test_mcopy_on_empty_memory_fork_Cancun_evm_code_type_LEGACY_state_test_empty_memory_length_0_src_0_dest_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy/mcopy_on_empty_memory.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy.py::test_mcopy_on_empty_memory[fork_Cancun-evm_code_type_LEGACY-state_test-empty_memory-length_0-src_0-dest_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_py__test_mcopy_on_empty_memory_fork_Cancun_evm_code_type_LEGACY_state_test_empty_memory_length_0_src_0_dest_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy/mcopy_on_empty_memory.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy.py::test_mcopy_on_empty_memory[fork_Cancun-evm_code_type_LEGACY-state_test-empty_memory-length_0-src_0-dest_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_py__test_mcopy_on_empty_memory_fork_Cancun_evm_code_type_LEGACY_state_test_empty_memory_length_0_src_32_dest_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy/mcopy_on_empty_memory.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy.py::test_mcopy_on_empty_memory[fork_Cancun-evm_code_type_LEGACY-state_test-empty_memory-length_0-src_32-dest_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_py__test_mcopy_on_empty_memory_fork_Cancun_evm_code_type_LEGACY_state_test_empty_memory_length_0_src_32_dest_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy/mcopy_on_empty_memory.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy.py::test_mcopy_on_empty_memory[fork_Cancun-evm_code_type_LEGACY-state_test-empty_memory-length_0-src_32-dest_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_py__test_mcopy_on_empty_memory_fork_Cancun_evm_code_type_LEGACY_state_test_empty_memory_length_1_src_0_dest_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy/mcopy_on_empty_memory.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy.py::test_mcopy_on_empty_memory[fork_Cancun-evm_code_type_LEGACY-state_test-empty_memory-length_1-src_0-dest_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_py__test_mcopy_on_empty_memory_fork_Cancun_evm_code_type_LEGACY_state_test_empty_memory_length_1_src_0_dest_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy/mcopy_on_empty_memory.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy.py::test_mcopy_on_empty_memory[fork_Cancun-evm_code_type_LEGACY-state_test-empty_memory-length_1-src_0-dest_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_py__test_mcopy_on_empty_memory_fork_Cancun_evm_code_type_LEGACY_state_test_empty_memory_length_1_src_32_dest_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy/mcopy_on_empty_memory.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy.py::test_mcopy_on_empty_memory[fork_Cancun-evm_code_type_LEGACY-state_test-empty_memory-length_1-src_32-dest_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_py__test_mcopy_on_empty_memory_fork_Cancun_evm_code_type_LEGACY_state_test_empty_memory_length_1_src_32_dest_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy/mcopy_on_empty_memory.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy.py::test_mcopy_on_empty_memory[fork_Cancun-evm_code_type_LEGACY-state_test-empty_memory-length_1-src_32-dest_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_py__test_mcopy_on_empty_memory_fork_Prague_evm_code_type_LEGACY_state_test_empty_memory_length_0_src_0_dest_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy/mcopy_on_empty_memory.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy.py::test_mcopy_on_empty_memory[fork_Prague-evm_code_type_LEGACY-state_test-empty_memory-length_0-src_0-dest_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_py__test_mcopy_on_empty_memory_fork_Prague_evm_code_type_LEGACY_state_test_empty_memory_length_0_src_0_dest_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy/mcopy_on_empty_memory.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy.py::test_mcopy_on_empty_memory[fork_Prague-evm_code_type_LEGACY-state_test-empty_memory-length_0-src_0-dest_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_py__test_mcopy_on_empty_memory_fork_Prague_evm_code_type_LEGACY_state_test_empty_memory_length_0_src_32_dest_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy/mcopy_on_empty_memory.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy.py::test_mcopy_on_empty_memory[fork_Prague-evm_code_type_LEGACY-state_test-empty_memory-length_0-src_32-dest_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_py__test_mcopy_on_empty_memory_fork_Prague_evm_code_type_LEGACY_state_test_empty_memory_length_0_src_32_dest_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy/mcopy_on_empty_memory.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy.py::test_mcopy_on_empty_memory[fork_Prague-evm_code_type_LEGACY-state_test-empty_memory-length_0-src_32-dest_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_py__test_mcopy_on_empty_memory_fork_Prague_evm_code_type_LEGACY_state_test_empty_memory_length_1_src_0_dest_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy/mcopy_on_empty_memory.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy.py::test_mcopy_on_empty_memory[fork_Prague-evm_code_type_LEGACY-state_test-empty_memory-length_1-src_0-dest_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_py__test_mcopy_on_empty_memory_fork_Prague_evm_code_type_LEGACY_state_test_empty_memory_length_1_src_0_dest_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy/mcopy_on_empty_memory.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy.py::test_mcopy_on_empty_memory[fork_Prague-evm_code_type_LEGACY-state_test-empty_memory-length_1-src_0-dest_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_py__test_mcopy_on_empty_memory_fork_Prague_evm_code_type_LEGACY_state_test_empty_memory_length_1_src_32_dest_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy/mcopy_on_empty_memory.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy.py::test_mcopy_on_empty_memory[fork_Prague-evm_code_type_LEGACY-state_test-empty_memory-length_1-src_32-dest_0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip5656_mcopy_test_mcopy_py__test_mcopy_on_empty_memory_fork_Prague_evm_code_type_LEGACY_state_test_empty_memory_length_1_src_32_dest_32_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip5656_mcopy/mcopy/mcopy_on_empty_memory.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip5656_mcopy/test_mcopy.py::test_mcopy_on_empty_memory[fork_Prague-evm_code_type_LEGACY-state_test-empty_memory-length_1-src_32-dest_32]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
