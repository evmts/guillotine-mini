const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_32_bytes_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_32_bytes-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_32_bytes_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_32_bytes-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_32_bytes_too_little_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_32_bytes-too_little_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_32_bytes_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_32_bytes-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_33_bytes_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_33_bytes-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_33_bytes_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_33_bytes-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_33_bytes_too_little_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_33_bytes-too_little_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_33_bytes_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_33_bytes-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_49120_bytes_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_49120_bytes-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_49120_bytes_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_49120_bytes-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_49120_bytes_too_little_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_49120_bytes-too_little_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_49120_bytes_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_49120_bytes-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_49121_bytes_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_49121_bytes-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_49121_bytes_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_49121_bytes-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_49121_bytes_too_little_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_49121_bytes-too_little_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_49121_bytes_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_49121_bytes-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_empty_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_empty-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_empty_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_empty-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_empty_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_empty-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_max_size_ones_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_max_size_ones-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_max_size_ones_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_max_size_ones-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_max_size_ones_too_little_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_max_size_ones-too_little_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_max_size_ones_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_max_size_ones-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_max_size_zeros_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_max_size_zeros-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_max_size_zeros_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_max_size_zeros-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_max_size_zeros_too_little_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_max_size_zeros-too_little_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_max_size_zeros_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_max_size_zeros-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_single_byte_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_single_byte-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_single_byte_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_single_byte-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Cancun_state_test_initcode_single_byte_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Cancun-state_test-initcode_single_byte-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_32_bytes_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_32_bytes-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_32_bytes_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_32_bytes-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_32_bytes_too_little_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_32_bytes-too_little_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_32_bytes_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_32_bytes-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_33_bytes_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_33_bytes-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_33_bytes_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_33_bytes-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_33_bytes_too_little_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_33_bytes-too_little_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_33_bytes_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_33_bytes-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_49120_bytes_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_49120_bytes-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_49120_bytes_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_49120_bytes-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_49120_bytes_too_little_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_49120_bytes-too_little_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_49120_bytes_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_49120_bytes-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_49121_bytes_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_49121_bytes-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_49121_bytes_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_49121_bytes-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_49121_bytes_too_little_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_49121_bytes-too_little_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_49121_bytes_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_49121_bytes-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_empty_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_empty-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_empty_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_empty-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_empty_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_empty-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_max_size_ones_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_max_size_ones-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_max_size_ones_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_max_size_ones-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_max_size_ones_too_little_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_max_size_ones-too_little_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_max_size_ones_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_max_size_ones-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_max_size_zeros_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_max_size_zeros-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_max_size_zeros_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_max_size_zeros-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_max_size_zeros_too_little_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_max_size_zeros-too_little_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_max_size_zeros_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_max_size_zeros-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_single_byte_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_single_byte-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_single_byte_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_single_byte-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Prague_state_test_initcode_single_byte_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Prague-state_test-initcode_single_byte-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_32_bytes_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_32_bytes-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_32_bytes_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_32_bytes-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_32_bytes_too_little_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_32_bytes-too_little_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_32_bytes_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_32_bytes-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_33_bytes_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_33_bytes-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_33_bytes_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_33_bytes-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_33_bytes_too_little_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_33_bytes-too_little_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_33_bytes_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_33_bytes-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_49120_bytes_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_49120_bytes-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_49120_bytes_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_49120_bytes-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_49120_bytes_too_little_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_49120_bytes-too_little_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_49120_bytes_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_49120_bytes-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_49121_bytes_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_49121_bytes-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_49121_bytes_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_49121_bytes-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_49121_bytes_too_little_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_49121_bytes-too_little_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_49121_bytes_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_49121_bytes-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_empty_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_empty-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_empty_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_empty-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_empty_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_empty-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_max_size_ones_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_max_size_ones-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_max_size_ones_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_max_size_ones-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_max_size_ones_too_little_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_max_size_ones-too_little_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_max_size_ones_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_max_size_ones-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_max_size_zeros_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_max_size_zeros-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_max_size_zeros_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_max_size_zeros-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_max_size_zeros_too_little_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_max_size_zeros-too_little_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_max_size_zeros_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_max_size_zeros-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_single_byte_exact_execution_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_single_byte-exact_execution_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_single_byte_exact_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_single_byte-exact_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_shanghai_eip3860_initcode_test_initcode_py__TestContractCreationGasUsage__test_gas_usage_fork_Shanghai_state_test_initcode_single_byte_too_little_intrinsic_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/shanghai/eip3860_initcode/initcode/gas_usage.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/shanghai/eip3860_initcode/test_initcode.py::TestContractCreationGasUsage::test_gas_usage[fork_Shanghai-state_test-initcode_single_byte-too_little_intrinsic_gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
