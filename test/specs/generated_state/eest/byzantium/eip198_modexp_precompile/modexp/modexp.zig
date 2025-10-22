const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Berlin_state_test_EIP_198_case1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Berlin-state_test-EIP-198-case1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Berlin_state_test_EIP_198_case2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Berlin-state_test-EIP-198-case2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Berlin_state_test_EIP_198_case3_raw_input_out_of_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Berlin-state_test-EIP-198-case3-raw-input-out-of-gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Berlin_state_test_EIP_198_case4_extra_data_07_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Berlin-state_test-EIP-198-case4-extra-data_07]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Berlin_state_test_EIP_198_case5_raw_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Berlin-state_test-EIP-198-case5-raw-input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Berlin_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x_ModExpOutput_returned_data_0x_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Berlin-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x-ModExpOutput_returned_data_0x]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Berlin_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x00_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Berlin-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x00-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Berlin_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x0001_ModExpOutput_returned_data_0x0000_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Berlin-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x0001-ModExpOutput_returned_data_0x0000]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Berlin_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x0002_ModExpOutput_returned_data_0x0001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Berlin-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x0002-ModExpOutput_returned_data_0x0001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Berlin_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x01_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Berlin-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x01-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Berlin_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Berlin-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Berlin_state_test_ModExpInput_base_0x_exponent_0x01_modulus_0x02_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Berlin-state_test-ModExpInput_base_0x-exponent_0x01-modulus_0x02-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Berlin_state_test_ModExpInput_base_0x00_exponent_0x00_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Berlin-state_test-ModExpInput_base_0x00-exponent_0x00-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Berlin_state_test_ModExpInput_base_0x01_exponent_0x01_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Berlin-state_test-ModExpInput_base_0x01-exponent_0x01-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Berlin_state_test_ModExpInput_base_0x02_exponent_0x01_modulus_0x03_ModExpOutput_returned_data_0x02_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Berlin-state_test-ModExpInput_base_0x02-exponent_0x01-modulus_0x03-ModExpOutput_returned_data_0x02]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Berlin_state_test_ModExpInput_base_0x02_exponent_0x02_modulus_0x05_ModExpOutput_returned_data_0x04_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Berlin-state_test-ModExpInput_base_0x02-exponent_0x02-modulus_0x05-ModExpOutput_returned_data_0x04]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Byzantium_state_test_EIP_198_case1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Byzantium-state_test-EIP-198-case1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Byzantium_state_test_EIP_198_case2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Byzantium-state_test-EIP-198-case2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Byzantium_state_test_EIP_198_case3_raw_input_out_of_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Byzantium-state_test-EIP-198-case3-raw-input-out-of-gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Byzantium_state_test_EIP_198_case4_extra_data_07_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Byzantium-state_test-EIP-198-case4-extra-data_07]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Byzantium_state_test_EIP_198_case5_raw_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Byzantium-state_test-EIP-198-case5-raw-input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Byzantium_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x_ModExpOutput_returned_data_0x_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Byzantium-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x-ModExpOutput_returned_data_0x]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Byzantium_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x00_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Byzantium-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x00-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Byzantium_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x0001_ModExpOutput_returned_data_0x0000_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Byzantium-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x0001-ModExpOutput_returned_data_0x0000]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Byzantium_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x0002_ModExpOutput_returned_data_0x0001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Byzantium-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x0002-ModExpOutput_returned_data_0x0001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Byzantium_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x01_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Byzantium-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x01-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Byzantium_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Byzantium-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Byzantium_state_test_ModExpInput_base_0x_exponent_0x01_modulus_0x02_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Byzantium-state_test-ModExpInput_base_0x-exponent_0x01-modulus_0x02-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Byzantium_state_test_ModExpInput_base_0x00_exponent_0x00_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Byzantium-state_test-ModExpInput_base_0x00-exponent_0x00-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Byzantium_state_test_ModExpInput_base_0x01_exponent_0x01_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Byzantium-state_test-ModExpInput_base_0x01-exponent_0x01-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Byzantium_state_test_ModExpInput_base_0x02_exponent_0x01_modulus_0x03_ModExpOutput_returned_data_0x02_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Byzantium-state_test-ModExpInput_base_0x02-exponent_0x01-modulus_0x03-ModExpOutput_returned_data_0x02]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Byzantium_state_test_ModExpInput_base_0x02_exponent_0x02_modulus_0x05_ModExpOutput_returned_data_0x04_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Byzantium-state_test-ModExpInput_base_0x02-exponent_0x02-modulus_0x05-ModExpOutput_returned_data_0x04]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Cancun_state_test_EIP_198_case1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Cancun-state_test-EIP-198-case1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Cancun_state_test_EIP_198_case2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Cancun-state_test-EIP-198-case2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Cancun_state_test_EIP_198_case3_raw_input_out_of_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Cancun-state_test-EIP-198-case3-raw-input-out-of-gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Cancun_state_test_EIP_198_case4_extra_data_07_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Cancun-state_test-EIP-198-case4-extra-data_07]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Cancun_state_test_EIP_198_case5_raw_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Cancun-state_test-EIP-198-case5-raw-input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Cancun_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x_ModExpOutput_returned_data_0x_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Cancun-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x-ModExpOutput_returned_data_0x]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Cancun_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x00_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Cancun-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x00-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Cancun_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x0001_ModExpOutput_returned_data_0x0000_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Cancun-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x0001-ModExpOutput_returned_data_0x0000]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Cancun_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x0002_ModExpOutput_returned_data_0x0001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Cancun-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x0002-ModExpOutput_returned_data_0x0001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Cancun_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x01_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Cancun-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x01-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Cancun_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Cancun-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Cancun_state_test_ModExpInput_base_0x_exponent_0x01_modulus_0x02_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Cancun-state_test-ModExpInput_base_0x-exponent_0x01-modulus_0x02-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Cancun_state_test_ModExpInput_base_0x00_exponent_0x00_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Cancun-state_test-ModExpInput_base_0x00-exponent_0x00-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Cancun_state_test_ModExpInput_base_0x01_exponent_0x01_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Cancun-state_test-ModExpInput_base_0x01-exponent_0x01-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Cancun_state_test_ModExpInput_base_0x02_exponent_0x01_modulus_0x03_ModExpOutput_returned_data_0x02_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Cancun-state_test-ModExpInput_base_0x02-exponent_0x01-modulus_0x03-ModExpOutput_returned_data_0x02]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Cancun_state_test_ModExpInput_base_0x02_exponent_0x02_modulus_0x05_ModExpOutput_returned_data_0x04_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Cancun-state_test-ModExpInput_base_0x02-exponent_0x02-modulus_0x05-ModExpOutput_returned_data_0x04]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_ConstantinopleFix_state_test_EIP_198_case1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_ConstantinopleFix-state_test-EIP-198-case1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_ConstantinopleFix_state_test_EIP_198_case2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_ConstantinopleFix-state_test-EIP-198-case2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_ConstantinopleFix_state_test_EIP_198_case3_raw_input_out_of_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_ConstantinopleFix-state_test-EIP-198-case3-raw-input-out-of-gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_ConstantinopleFix_state_test_EIP_198_case4_extra_data_07_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_ConstantinopleFix-state_test-EIP-198-case4-extra-data_07]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_ConstantinopleFix_state_test_EIP_198_case5_raw_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_ConstantinopleFix-state_test-EIP-198-case5-raw-input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_ConstantinopleFix_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x_ModExpOutput_returned_data_0x_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_ConstantinopleFix-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x-ModExpOutput_returned_data_0x]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_ConstantinopleFix_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x00_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_ConstantinopleFix-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x00-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_ConstantinopleFix_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x0001_ModExpOutput_returned_data_0x0000_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_ConstantinopleFix-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x0001-ModExpOutput_returned_data_0x0000]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_ConstantinopleFix_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x0002_ModExpOutput_returned_data_0x0001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_ConstantinopleFix-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x0002-ModExpOutput_returned_data_0x0001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_ConstantinopleFix_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x01_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_ConstantinopleFix-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x01-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_ConstantinopleFix_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_ConstantinopleFix-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_ConstantinopleFix_state_test_ModExpInput_base_0x_exponent_0x01_modulus_0x02_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_ConstantinopleFix-state_test-ModExpInput_base_0x-exponent_0x01-modulus_0x02-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_ConstantinopleFix_state_test_ModExpInput_base_0x00_exponent_0x00_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_ConstantinopleFix-state_test-ModExpInput_base_0x00-exponent_0x00-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_ConstantinopleFix_state_test_ModExpInput_base_0x01_exponent_0x01_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_ConstantinopleFix-state_test-ModExpInput_base_0x01-exponent_0x01-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_ConstantinopleFix_state_test_ModExpInput_base_0x02_exponent_0x01_modulus_0x03_ModExpOutput_returned_data_0x02_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_ConstantinopleFix-state_test-ModExpInput_base_0x02-exponent_0x01-modulus_0x03-ModExpOutput_returned_data_0x02]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_ConstantinopleFix_state_test_ModExpInput_base_0x02_exponent_0x02_modulus_0x05_ModExpOutput_returned_data_0x04_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_ConstantinopleFix-state_test-ModExpInput_base_0x02-exponent_0x02-modulus_0x05-ModExpOutput_returned_data_0x04]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Istanbul_state_test_EIP_198_case1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Istanbul-state_test-EIP-198-case1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Istanbul_state_test_EIP_198_case2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Istanbul-state_test-EIP-198-case2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Istanbul_state_test_EIP_198_case3_raw_input_out_of_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Istanbul-state_test-EIP-198-case3-raw-input-out-of-gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Istanbul_state_test_EIP_198_case4_extra_data_07_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Istanbul-state_test-EIP-198-case4-extra-data_07]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Istanbul_state_test_EIP_198_case5_raw_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Istanbul-state_test-EIP-198-case5-raw-input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Istanbul_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x_ModExpOutput_returned_data_0x_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Istanbul-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x-ModExpOutput_returned_data_0x]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Istanbul_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x00_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Istanbul-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x00-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Istanbul_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x0001_ModExpOutput_returned_data_0x0000_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Istanbul-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x0001-ModExpOutput_returned_data_0x0000]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Istanbul_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x0002_ModExpOutput_returned_data_0x0001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Istanbul-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x0002-ModExpOutput_returned_data_0x0001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Istanbul_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x01_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Istanbul-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x01-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Istanbul_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Istanbul-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Istanbul_state_test_ModExpInput_base_0x_exponent_0x01_modulus_0x02_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Istanbul-state_test-ModExpInput_base_0x-exponent_0x01-modulus_0x02-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Istanbul_state_test_ModExpInput_base_0x00_exponent_0x00_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Istanbul-state_test-ModExpInput_base_0x00-exponent_0x00-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Istanbul_state_test_ModExpInput_base_0x01_exponent_0x01_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Istanbul-state_test-ModExpInput_base_0x01-exponent_0x01-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Istanbul_state_test_ModExpInput_base_0x02_exponent_0x01_modulus_0x03_ModExpOutput_returned_data_0x02_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Istanbul-state_test-ModExpInput_base_0x02-exponent_0x01-modulus_0x03-ModExpOutput_returned_data_0x02]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Istanbul_state_test_ModExpInput_base_0x02_exponent_0x02_modulus_0x05_ModExpOutput_returned_data_0x04_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Istanbul-state_test-ModExpInput_base_0x02-exponent_0x02-modulus_0x05-ModExpOutput_returned_data_0x04]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_London_state_test_EIP_198_case1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_London-state_test-EIP-198-case1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_London_state_test_EIP_198_case2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_London-state_test-EIP-198-case2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_London_state_test_EIP_198_case3_raw_input_out_of_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_London-state_test-EIP-198-case3-raw-input-out-of-gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_London_state_test_EIP_198_case4_extra_data_07_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_London-state_test-EIP-198-case4-extra-data_07]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_London_state_test_EIP_198_case5_raw_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_London-state_test-EIP-198-case5-raw-input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_London_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x_ModExpOutput_returned_data_0x_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_London-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x-ModExpOutput_returned_data_0x]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_London_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x00_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_London-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x00-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_London_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x0001_ModExpOutput_returned_data_0x0000_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_London-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x0001-ModExpOutput_returned_data_0x0000]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_London_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x0002_ModExpOutput_returned_data_0x0001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_London-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x0002-ModExpOutput_returned_data_0x0001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_London_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x01_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_London-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x01-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_London_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_London-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_London_state_test_ModExpInput_base_0x_exponent_0x01_modulus_0x02_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_London-state_test-ModExpInput_base_0x-exponent_0x01-modulus_0x02-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_London_state_test_ModExpInput_base_0x00_exponent_0x00_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_London-state_test-ModExpInput_base_0x00-exponent_0x00-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_London_state_test_ModExpInput_base_0x01_exponent_0x01_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_London-state_test-ModExpInput_base_0x01-exponent_0x01-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_London_state_test_ModExpInput_base_0x02_exponent_0x01_modulus_0x03_ModExpOutput_returned_data_0x02_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_London-state_test-ModExpInput_base_0x02-exponent_0x01-modulus_0x03-ModExpOutput_returned_data_0x02]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_London_state_test_ModExpInput_base_0x02_exponent_0x02_modulus_0x05_ModExpOutput_returned_data_0x04_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_London-state_test-ModExpInput_base_0x02-exponent_0x02-modulus_0x05-ModExpOutput_returned_data_0x04]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Paris_state_test_EIP_198_case1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Paris-state_test-EIP-198-case1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Paris_state_test_EIP_198_case2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Paris-state_test-EIP-198-case2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Paris_state_test_EIP_198_case3_raw_input_out_of_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Paris-state_test-EIP-198-case3-raw-input-out-of-gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Paris_state_test_EIP_198_case4_extra_data_07_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Paris-state_test-EIP-198-case4-extra-data_07]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Paris_state_test_EIP_198_case5_raw_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Paris-state_test-EIP-198-case5-raw-input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Paris_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x_ModExpOutput_returned_data_0x_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Paris-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x-ModExpOutput_returned_data_0x]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Paris_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x00_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Paris-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x00-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Paris_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x0001_ModExpOutput_returned_data_0x0000_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Paris-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x0001-ModExpOutput_returned_data_0x0000]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Paris_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x0002_ModExpOutput_returned_data_0x0001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Paris-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x0002-ModExpOutput_returned_data_0x0001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Paris_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x01_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Paris-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x01-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Paris_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Paris-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Paris_state_test_ModExpInput_base_0x_exponent_0x01_modulus_0x02_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Paris-state_test-ModExpInput_base_0x-exponent_0x01-modulus_0x02-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Paris_state_test_ModExpInput_base_0x00_exponent_0x00_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Paris-state_test-ModExpInput_base_0x00-exponent_0x00-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Paris_state_test_ModExpInput_base_0x01_exponent_0x01_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Paris-state_test-ModExpInput_base_0x01-exponent_0x01-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Paris_state_test_ModExpInput_base_0x02_exponent_0x01_modulus_0x03_ModExpOutput_returned_data_0x02_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Paris-state_test-ModExpInput_base_0x02-exponent_0x01-modulus_0x03-ModExpOutput_returned_data_0x02]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Paris_state_test_ModExpInput_base_0x02_exponent_0x02_modulus_0x05_ModExpOutput_returned_data_0x04_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Paris-state_test-ModExpInput_base_0x02-exponent_0x02-modulus_0x05-ModExpOutput_returned_data_0x04]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Prague_state_test_EIP_198_case1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Prague-state_test-EIP-198-case1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Prague_state_test_EIP_198_case2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Prague-state_test-EIP-198-case2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Prague_state_test_EIP_198_case3_raw_input_out_of_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Prague-state_test-EIP-198-case3-raw-input-out-of-gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Prague_state_test_EIP_198_case4_extra_data_07_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Prague-state_test-EIP-198-case4-extra-data_07]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Prague_state_test_EIP_198_case5_raw_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Prague-state_test-EIP-198-case5-raw-input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Prague_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x_ModExpOutput_returned_data_0x_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Prague-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x-ModExpOutput_returned_data_0x]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Prague_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x00_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Prague-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x00-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Prague_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x0001_ModExpOutput_returned_data_0x0000_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Prague-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x0001-ModExpOutput_returned_data_0x0000]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Prague_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x0002_ModExpOutput_returned_data_0x0001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Prague-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x0002-ModExpOutput_returned_data_0x0001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Prague_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x01_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Prague-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x01-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Prague_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Prague-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Prague_state_test_ModExpInput_base_0x_exponent_0x01_modulus_0x02_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Prague-state_test-ModExpInput_base_0x-exponent_0x01-modulus_0x02-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Prague_state_test_ModExpInput_base_0x00_exponent_0x00_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Prague-state_test-ModExpInput_base_0x00-exponent_0x00-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Prague_state_test_ModExpInput_base_0x01_exponent_0x01_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Prague-state_test-ModExpInput_base_0x01-exponent_0x01-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Prague_state_test_ModExpInput_base_0x02_exponent_0x01_modulus_0x03_ModExpOutput_returned_data_0x02_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Prague-state_test-ModExpInput_base_0x02-exponent_0x01-modulus_0x03-ModExpOutput_returned_data_0x02]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Prague_state_test_ModExpInput_base_0x02_exponent_0x02_modulus_0x05_ModExpOutput_returned_data_0x04_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Prague-state_test-ModExpInput_base_0x02-exponent_0x02-modulus_0x05-ModExpOutput_returned_data_0x04]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Shanghai_state_test_EIP_198_case1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Shanghai-state_test-EIP-198-case1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Shanghai_state_test_EIP_198_case2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Shanghai-state_test-EIP-198-case2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Shanghai_state_test_EIP_198_case3_raw_input_out_of_gas_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Shanghai-state_test-EIP-198-case3-raw-input-out-of-gas]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Shanghai_state_test_EIP_198_case4_extra_data_07_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Shanghai-state_test-EIP-198-case4-extra-data_07]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Shanghai_state_test_EIP_198_case5_raw_input_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Shanghai-state_test-EIP-198-case5-raw-input]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Shanghai_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x_ModExpOutput_returned_data_0x_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Shanghai-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x-ModExpOutput_returned_data_0x]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Shanghai_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x00_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Shanghai-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x00-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Shanghai_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x0001_ModExpOutput_returned_data_0x0000_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Shanghai-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x0001-ModExpOutput_returned_data_0x0000]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Shanghai_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x0002_ModExpOutput_returned_data_0x0001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Shanghai-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x0002-ModExpOutput_returned_data_0x0001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Shanghai_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x01_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Shanghai-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x01-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Shanghai_state_test_ModExpInput_base_0x_exponent_0x_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Shanghai-state_test-ModExpInput_base_0x-exponent_0x-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Shanghai_state_test_ModExpInput_base_0x_exponent_0x01_modulus_0x02_ModExpOutput_returned_data_0x00_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Shanghai-state_test-ModExpInput_base_0x-exponent_0x01-modulus_0x02-ModExpOutput_returned_data_0x00]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Shanghai_state_test_ModExpInput_base_0x00_exponent_0x00_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Shanghai-state_test-ModExpInput_base_0x00-exponent_0x00-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Shanghai_state_test_ModExpInput_base_0x01_exponent_0x01_modulus_0x02_ModExpOutput_returned_data_0x01_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Shanghai-state_test-ModExpInput_base_0x01-exponent_0x01-modulus_0x02-ModExpOutput_returned_data_0x01]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Shanghai_state_test_ModExpInput_base_0x02_exponent_0x01_modulus_0x03_ModExpOutput_returned_data_0x02_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Shanghai-state_test-ModExpInput_base_0x02-exponent_0x01-modulus_0x03-ModExpOutput_returned_data_0x02]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_byzantium_eip198_modexp_precompile_test_modexp_py__test_modexp_fork_Shanghai_state_test_ModExpInput_base_0x02_exponent_0x02_modulus_0x05_ModExpOutput_returned_data_0x04_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/byzantium/eip198_modexp_precompile/modexp/modexp.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/byzantium/eip198_modexp_precompile/test_modexp.py::test_modexp[fork_Shanghai-state_test-ModExpInput_base_0x02-exponent_0x02-modulus_0x05-ModExpOutput_returned_data_0x04]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
