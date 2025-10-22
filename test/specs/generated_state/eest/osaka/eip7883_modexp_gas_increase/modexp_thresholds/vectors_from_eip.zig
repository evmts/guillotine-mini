const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_256byte_all_params_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-256byte-all-params]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_32byte_boundary_31_32_33_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-32byte-boundary-31-32-33]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_33byte_base_32byte_exp_33byte_mod_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-33byte-base-32byte-exp-33byte-mod]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_33byte_exponent_last_2bytes_ff_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-33byte-exponent-last-2bytes-ff]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_64byte_base_1byte_exp_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-64byte-base-1byte-exp]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_exponent_72bytes_msb_at_33_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-exponent-72bytes-msb-at-33]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_exponent_with_leading_zeros_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-exponent-with-leading-zeros]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_geth_fail_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-geth-fail-length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_guido_1_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-guido-1-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_guido_2_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-guido-2-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_guido_3_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-guido-3-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_guido_4_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-guido-4-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_large_exponent_128bytes_lsb_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-large-exponent-128bytes-lsb]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_large_exponent_80bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-large-exponent-80bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_marcin_1_balanced_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-marcin-1-balanced]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_marcin_1_base_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-marcin-1-base-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_marcin_1_exp_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-marcin-1-exp-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_marcin_2_balanced_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-marcin-2-balanced]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_marcin_2_base_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-marcin-2-base-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_marcin_2_exp_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-marcin-2-exp-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_marcin_3_balanced_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-marcin-3-balanced]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_marcin_3_base_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-marcin-3-base-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_marcin_3_exp_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-marcin-3-exp-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_marius_1_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-marius-1-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_minimal_1byte_all_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-minimal-1byte-all]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_nagydani_1_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-nagydani-1-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_nagydani_1_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-nagydani-1-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_nagydani_1_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-nagydani-1-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_nagydani_2_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-nagydani-2-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_nagydani_2_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-nagydani-2-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_nagydani_2_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-nagydani-2-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_nagydani_3_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-nagydani-3-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_nagydani_3_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-nagydani-3-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_nagydani_3_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-nagydani-3-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_nagydani_4_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-nagydani-4-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_nagydani_4_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-nagydani-4-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_nagydani_4_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-nagydani-4-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_nagydani_5_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-nagydani-5-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_nagydani_5_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-nagydani-5-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_nagydani_5_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-nagydani-5-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_unequal_base_mod_lengths_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-unequal-base-mod-lengths]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_word_boundary_7bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-word-boundary-7bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_word_boundary_9bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-word-boundary-9bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_zero_exponent_32bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-zero-exponent-32bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_zero_exponent_64bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-zero-exponent-64bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Berlin_state_test_zero_length_base_mod_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Berlin-state_test-zero-length-base-mod]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_256byte_all_params_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-256byte-all-params]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_32byte_boundary_31_32_33_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-32byte-boundary-31-32-33]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_33byte_base_32byte_exp_33byte_mod_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-33byte-base-32byte-exp-33byte-mod]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_33byte_exponent_last_2bytes_ff_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-33byte-exponent-last-2bytes-ff]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_64byte_base_1byte_exp_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-64byte-base-1byte-exp]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_exponent_72bytes_msb_at_33_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-exponent-72bytes-msb-at-33]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_exponent_with_leading_zeros_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-exponent-with-leading-zeros]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_geth_fail_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-geth-fail-length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_guido_1_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-guido-1-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_guido_2_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-guido-2-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_guido_3_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-guido-3-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_guido_4_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-guido-4-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_large_exponent_128bytes_lsb_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-large-exponent-128bytes-lsb]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_large_exponent_80bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-large-exponent-80bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_marcin_1_balanced_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-marcin-1-balanced]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_marcin_1_base_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-marcin-1-base-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_marcin_1_exp_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-marcin-1-exp-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_marcin_2_balanced_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-marcin-2-balanced]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_marcin_2_base_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-marcin-2-base-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_marcin_2_exp_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-marcin-2-exp-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_marcin_3_balanced_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-marcin-3-balanced]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_marcin_3_base_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-marcin-3-base-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_marcin_3_exp_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-marcin-3-exp-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_marius_1_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-marius-1-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_minimal_1byte_all_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-minimal-1byte-all]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_nagydani_1_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-nagydani-1-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_nagydani_1_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-nagydani-1-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_nagydani_1_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-nagydani-1-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_nagydani_2_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-nagydani-2-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_nagydani_2_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-nagydani-2-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_nagydani_2_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-nagydani-2-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_nagydani_3_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-nagydani-3-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_nagydani_3_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-nagydani-3-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_nagydani_3_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-nagydani-3-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_nagydani_4_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-nagydani-4-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_nagydani_4_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-nagydani-4-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_nagydani_4_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-nagydani-4-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_nagydani_5_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-nagydani-5-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_nagydani_5_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-nagydani-5-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_nagydani_5_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-nagydani-5-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_unequal_base_mod_lengths_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-unequal-base-mod-lengths]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_word_boundary_7bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-word-boundary-7bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_word_boundary_9bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-word-boundary-9bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_zero_exponent_32bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-zero-exponent-32bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_zero_exponent_64bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-zero-exponent-64bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Cancun_state_test_zero_length_base_mod_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Cancun-state_test-zero-length-base-mod]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_256byte_all_params_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-256byte-all-params]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_32byte_boundary_31_32_33_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-32byte-boundary-31-32-33]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_33byte_base_32byte_exp_33byte_mod_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-33byte-base-32byte-exp-33byte-mod]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_33byte_exponent_last_2bytes_ff_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-33byte-exponent-last-2bytes-ff]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_64byte_base_1byte_exp_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-64byte-base-1byte-exp]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_exponent_72bytes_msb_at_33_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-exponent-72bytes-msb-at-33]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_exponent_with_leading_zeros_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-exponent-with-leading-zeros]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_geth_fail_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-geth-fail-length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_guido_1_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-guido-1-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_guido_2_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-guido-2-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_guido_3_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-guido-3-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_guido_4_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-guido-4-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_large_exponent_128bytes_lsb_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-large-exponent-128bytes-lsb]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_large_exponent_80bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-large-exponent-80bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_marcin_1_balanced_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-marcin-1-balanced]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_marcin_1_base_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-marcin-1-base-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_marcin_1_exp_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-marcin-1-exp-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_marcin_2_balanced_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-marcin-2-balanced]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_marcin_2_base_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-marcin-2-base-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_marcin_2_exp_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-marcin-2-exp-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_marcin_3_balanced_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-marcin-3-balanced]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_marcin_3_base_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-marcin-3-base-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_marcin_3_exp_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-marcin-3-exp-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_marius_1_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-marius-1-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_minimal_1byte_all_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-minimal-1byte-all]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_nagydani_1_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-nagydani-1-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_nagydani_1_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-nagydani-1-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_nagydani_1_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-nagydani-1-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_nagydani_2_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-nagydani-2-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_nagydani_2_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-nagydani-2-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_nagydani_2_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-nagydani-2-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_nagydani_3_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-nagydani-3-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_nagydani_3_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-nagydani-3-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_nagydani_3_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-nagydani-3-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_nagydani_4_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-nagydani-4-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_nagydani_4_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-nagydani-4-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_nagydani_4_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-nagydani-4-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_nagydani_5_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-nagydani-5-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_nagydani_5_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-nagydani-5-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_nagydani_5_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-nagydani-5-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_unequal_base_mod_lengths_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-unequal-base-mod-lengths]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_word_boundary_7bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-word-boundary-7bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_word_boundary_9bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-word-boundary-9bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_zero_exponent_32bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-zero-exponent-32bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_zero_exponent_64bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-zero-exponent-64bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_London_state_test_zero_length_base_mod_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_London-state_test-zero-length-base-mod]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_256byte_all_params_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-256byte-all-params]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_32byte_boundary_31_32_33_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-32byte-boundary-31-32-33]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_33byte_base_32byte_exp_33byte_mod_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-33byte-base-32byte-exp-33byte-mod]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_33byte_exponent_last_2bytes_ff_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-33byte-exponent-last-2bytes-ff]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_64byte_base_1byte_exp_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-64byte-base-1byte-exp]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_exponent_72bytes_msb_at_33_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-exponent-72bytes-msb-at-33]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_exponent_with_leading_zeros_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-exponent-with-leading-zeros]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_geth_fail_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-geth-fail-length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_guido_1_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-guido-1-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_guido_2_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-guido-2-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_guido_3_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-guido-3-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_guido_4_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-guido-4-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_large_exponent_128bytes_lsb_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-large-exponent-128bytes-lsb]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_large_exponent_80bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-large-exponent-80bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_marcin_1_balanced_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-marcin-1-balanced]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_marcin_1_base_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-marcin-1-base-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_marcin_1_exp_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-marcin-1-exp-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_marcin_2_balanced_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-marcin-2-balanced]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_marcin_2_base_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-marcin-2-base-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_marcin_2_exp_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-marcin-2-exp-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_marcin_3_balanced_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-marcin-3-balanced]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_marcin_3_base_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-marcin-3-base-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_marcin_3_exp_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-marcin-3-exp-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_marius_1_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-marius-1-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_minimal_1byte_all_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-minimal-1byte-all]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_nagydani_1_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-nagydani-1-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_nagydani_1_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-nagydani-1-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_nagydani_1_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-nagydani-1-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_nagydani_2_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-nagydani-2-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_nagydani_2_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-nagydani-2-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_nagydani_2_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-nagydani-2-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_nagydani_3_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-nagydani-3-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_nagydani_3_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-nagydani-3-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_nagydani_3_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-nagydani-3-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_nagydani_4_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-nagydani-4-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_nagydani_4_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-nagydani-4-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_nagydani_4_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-nagydani-4-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_nagydani_5_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-nagydani-5-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_nagydani_5_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-nagydani-5-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_nagydani_5_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-nagydani-5-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_unequal_base_mod_lengths_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-unequal-base-mod-lengths]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_word_boundary_7bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-word-boundary-7bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_word_boundary_9bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-word-boundary-9bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_zero_exponent_32bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-zero-exponent-32bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_zero_exponent_64bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-zero-exponent-64bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Paris_state_test_zero_length_base_mod_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Paris-state_test-zero-length-base-mod]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_256byte_all_params_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-256byte-all-params]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_32byte_boundary_31_32_33_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-32byte-boundary-31-32-33]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_33byte_base_32byte_exp_33byte_mod_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-33byte-base-32byte-exp-33byte-mod]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_33byte_exponent_last_2bytes_ff_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-33byte-exponent-last-2bytes-ff]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_64byte_base_1byte_exp_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-64byte-base-1byte-exp]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_exponent_72bytes_msb_at_33_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-exponent-72bytes-msb-at-33]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_exponent_with_leading_zeros_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-exponent-with-leading-zeros]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_geth_fail_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-geth-fail-length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_guido_1_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-guido-1-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_guido_2_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-guido-2-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_guido_3_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-guido-3-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_guido_4_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-guido-4-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_large_exponent_128bytes_lsb_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-large-exponent-128bytes-lsb]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_large_exponent_80bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-large-exponent-80bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_marcin_1_balanced_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-marcin-1-balanced]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_marcin_1_base_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-marcin-1-base-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_marcin_1_exp_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-marcin-1-exp-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_marcin_2_balanced_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-marcin-2-balanced]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_marcin_2_base_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-marcin-2-base-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_marcin_2_exp_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-marcin-2-exp-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_marcin_3_balanced_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-marcin-3-balanced]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_marcin_3_base_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-marcin-3-base-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_marcin_3_exp_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-marcin-3-exp-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_marius_1_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-marius-1-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_minimal_1byte_all_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-minimal-1byte-all]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_nagydani_1_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-nagydani-1-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_nagydani_1_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-nagydani-1-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_nagydani_1_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-nagydani-1-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_nagydani_2_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-nagydani-2-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_nagydani_2_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-nagydani-2-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_nagydani_2_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-nagydani-2-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_nagydani_3_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-nagydani-3-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_nagydani_3_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-nagydani-3-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_nagydani_3_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-nagydani-3-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_nagydani_4_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-nagydani-4-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_nagydani_4_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-nagydani-4-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_nagydani_4_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-nagydani-4-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_nagydani_5_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-nagydani-5-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_nagydani_5_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-nagydani-5-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_nagydani_5_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-nagydani-5-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_unequal_base_mod_lengths_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-unequal-base-mod-lengths]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_word_boundary_7bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-word-boundary-7bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_word_boundary_9bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-word-boundary-9bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_zero_exponent_32bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-zero-exponent-32bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_zero_exponent_64bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-zero-exponent-64bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Prague_state_test_zero_length_base_mod_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Prague-state_test-zero-length-base-mod]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_256byte_all_params_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-256byte-all-params]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_32byte_boundary_31_32_33_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-32byte-boundary-31-32-33]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_33byte_base_32byte_exp_33byte_mod_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-33byte-base-32byte-exp-33byte-mod]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_33byte_exponent_last_2bytes_ff_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-33byte-exponent-last-2bytes-ff]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_64byte_base_1byte_exp_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-64byte-base-1byte-exp]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_exponent_72bytes_msb_at_33_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-exponent-72bytes-msb-at-33]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_exponent_with_leading_zeros_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-exponent-with-leading-zeros]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_geth_fail_length_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-geth-fail-length]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_guido_1_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-guido-1-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_guido_2_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-guido-2-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_guido_3_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-guido-3-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_guido_4_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-guido-4-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_large_exponent_128bytes_lsb_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-large-exponent-128bytes-lsb]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_large_exponent_80bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-large-exponent-80bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_marcin_1_balanced_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-marcin-1-balanced]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_marcin_1_base_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-marcin-1-base-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_marcin_1_exp_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-marcin-1-exp-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_marcin_2_balanced_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-marcin-2-balanced]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_marcin_2_base_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-marcin-2-base-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_marcin_2_exp_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-marcin-2-exp-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_marcin_3_balanced_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-marcin-3-balanced]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_marcin_3_base_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-marcin-3-base-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_marcin_3_exp_heavy_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-marcin-3-exp-heavy]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_marius_1_even_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-marius-1-even]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_minimal_1byte_all_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-minimal-1byte-all]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_nagydani_1_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-nagydani-1-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_nagydani_1_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-nagydani-1-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_nagydani_1_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-nagydani-1-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_nagydani_2_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-nagydani-2-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_nagydani_2_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-nagydani-2-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_nagydani_2_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-nagydani-2-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_nagydani_3_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-nagydani-3-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_nagydani_3_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-nagydani-3-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_nagydani_3_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-nagydani-3-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_nagydani_4_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-nagydani-4-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_nagydani_4_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-nagydani-4-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_nagydani_4_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-nagydani-4-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_nagydani_5_pow0x10001_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-nagydani-5-pow0x10001]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_nagydani_5_qube_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-nagydani-5-qube]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_nagydani_5_square_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-nagydani-5-square]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_unequal_base_mod_lengths_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-unequal-base-mod-lengths]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_word_boundary_7bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-word-boundary-7bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_word_boundary_9bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-word-boundary-9bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_zero_exponent_32bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-zero-exponent-32bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_zero_exponent_64bytes_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-zero-exponent-64bytes]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_osaka_eip7883_modexp_gas_increase_test_modexp_thresholds_py__test_vectors_from_eip_fork_Shanghai_state_test_zero_length_base_mod_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/osaka/eip7883_modexp_gas_increase/modexp_thresholds/vectors_from_eip.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/osaka/eip7883_modexp_gas_increase/test_modexp_thresholds.py::test_vectors_from_eip[fork_Shanghai-state_test-zero-length-base-mod]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
