const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_2q_times_point__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-2q_times_point-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_bls_g2mul__0_g2_inf___" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-bls_g2mul_(0*g2=inf)-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_bls_g2mul__0_p2_inf___" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-bls_g2mul_(0*p2=inf)-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_bls_g2mul__1_g2_g2___" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-bls_g2mul_(1*g2=g2)-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_bls_g2mul__1_p2_p2___" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-bls_g2mul_(1*p2=p2)-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_bls_g2mul__g2_g2_2_g2___" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-bls_g2mul_(g2+g2=2*g2)-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_bls_g2mul__p2_p2_2_p2___" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-bls_g2mul_(p2+p2=2*p2)-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_bls_g2mul__x_inf_inf___" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-bls_g2mul_(x*inf=inf)-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_bls_g2mul_random_g2__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-bls_g2mul_random*g2-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_bls_g2mul_random_g2_unnormalized_scalar__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-bls_g2mul_random*g2_unnormalized_scalar-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_bls_g2mul_random_p2__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-bls_g2mul_random*p2-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_bls_g2mul_random_p2_unnormalized_scalar__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-bls_g2mul_random*p2_unnormalized_scalar-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_large_multiple_of_q_times_point__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-large_multiple_of_q_times_point-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_max_scalar_times_inf__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-max_scalar_times_inf-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_max_scalar_times_point__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-max_scalar_times_point-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_one_times_generator__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-one_times_generator-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_one_times_inf__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-one_times_inf-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_one_times_point__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-one_times_point-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_q_minus_1_times_point__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-q_minus_1_times_point-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_q_plus_1_times_point__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-q_plus_1_times_point-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_q_times_generator__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-q_times_generator-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_q_times_inf__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-q_times_inf-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_q_times_point__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-q_times_point-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_two_times_inf__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-two_times_inf-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_zero_times_generator__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-zero_times_generator-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_zero_times_inf__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-zero_times_inf-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_g2mul_py__test_valid_fork_Prague_state_test_zero_times_point__" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_g2mul/valid.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_g2mul.py::test_valid[fork_Prague-state_test-zero_times_point-]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
