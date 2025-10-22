const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_valid_tx_invalid_auth_signature_fork_Prague_state_test_r_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/valid_tx_invalid_auth_signature.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_valid_tx_invalid_auth_signature[fork_Prague-state_test-r=0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_valid_tx_invalid_auth_signature_fork_Prague_state_test_r_2__256_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/valid_tx_invalid_auth_signature.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_valid_tx_invalid_auth_signature[fork_Prague-state_test-r=2**256-1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_valid_tx_invalid_auth_signature_fork_Prague_state_test_r_SECP256K1N_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/valid_tx_invalid_auth_signature.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_valid_tx_invalid_auth_signature[fork_Prague-state_test-r=SECP256K1N+1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_valid_tx_invalid_auth_signature_fork_Prague_state_test_r_SECP256K1N_1__1" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/valid_tx_invalid_auth_signature.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_valid_tx_invalid_auth_signature[fork_Prague-state_test-r=SECP256K1N-1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_valid_tx_invalid_auth_signature_fork_Prague_state_test_r_SECP256K1N_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/valid_tx_invalid_auth_signature.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_valid_tx_invalid_auth_signature[fork_Prague-state_test-r=SECP256K1N]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_valid_tx_invalid_auth_signature_fork_Prague_state_test_s_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/valid_tx_invalid_auth_signature.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_valid_tx_invalid_auth_signature[fork_Prague-state_test-s=0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_valid_tx_invalid_auth_signature_fork_Prague_state_test_s_2__256_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/valid_tx_invalid_auth_signature.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_valid_tx_invalid_auth_signature[fork_Prague-state_test-s=2**256-1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_valid_tx_invalid_auth_signature_fork_Prague_state_test_s_SECP256K1N_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/valid_tx_invalid_auth_signature.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_valid_tx_invalid_auth_signature[fork_Prague-state_test-s=SECP256K1N+1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_valid_tx_invalid_auth_signature_fork_Prague_state_test_s_SECP256K1N_1__1" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/valid_tx_invalid_auth_signature.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_valid_tx_invalid_auth_signature[fork_Prague-state_test-s=SECP256K1N-1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_valid_tx_invalid_auth_signature_fork_Prague_state_test_s_SECP256K1N_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/valid_tx_invalid_auth_signature.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_valid_tx_invalid_auth_signature[fork_Prague-state_test-s=SECP256K1N]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_valid_tx_invalid_auth_signature_fork_Prague_state_test_s_SECP256K1N_OVER_2_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/valid_tx_invalid_auth_signature.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_valid_tx_invalid_auth_signature[fork_Prague-state_test-s=SECP256K1N_OVER_2+1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_valid_tx_invalid_auth_signature_fork_Prague_state_test_s_SECP256K1N_OVER_2_1__1" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/valid_tx_invalid_auth_signature.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_valid_tx_invalid_auth_signature[fork_Prague-state_test-s=SECP256K1N_OVER_2-1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_valid_tx_invalid_auth_signature_fork_Prague_state_test_s_SECP256K1N_OVER_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/valid_tx_invalid_auth_signature.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_valid_tx_invalid_auth_signature[fork_Prague-state_test-s=SECP256K1N_OVER_2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_valid_tx_invalid_auth_signature_fork_Prague_state_test_v_2__8_1_r_s_2__256_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/valid_tx_invalid_auth_signature.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_valid_tx_invalid_auth_signature[fork_Prague-state_test-v=2**8-1,r=s=2**256-1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_valid_tx_invalid_auth_signature_fork_Prague_state_test_v_2__8_1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/valid_tx_invalid_auth_signature.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_valid_tx_invalid_auth_signature[fork_Prague-state_test-v=2**8-1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_valid_tx_invalid_auth_signature_fork_Prague_state_test_v_27_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/valid_tx_invalid_auth_signature.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_valid_tx_invalid_auth_signature[fork_Prague-state_test-v=27]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_valid_tx_invalid_auth_signature_fork_Prague_state_test_v_28_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/valid_tx_invalid_auth_signature.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_valid_tx_invalid_auth_signature[fork_Prague-state_test-v=28]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_valid_tx_invalid_auth_signature_fork_Prague_state_test_v_2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/valid_tx_invalid_auth_signature.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_valid_tx_invalid_auth_signature[fork_Prague-state_test-v=2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_valid_tx_invalid_auth_signature_fork_Prague_state_test_v_35_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/valid_tx_invalid_auth_signature.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_valid_tx_invalid_auth_signature[fork_Prague-state_test-v=35]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_valid_tx_invalid_auth_signature_fork_Prague_state_test_v_36_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/valid_tx_invalid_auth_signature.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_valid_tx_invalid_auth_signature[fork_Prague-state_test-v=36]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_prague_eip7702_set_code_tx_test_set_code_txs_py__test_valid_tx_invalid_auth_signature_fork_Prague_state_test_v_r_s_0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip7702_set_code_tx/set_code_txs/valid_tx_invalid_auth_signature.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip7702_set_code_tx/test_set_code_txs.py::test_valid_tx_invalid_auth_signature[fork_Prague-state_test-v=r=s=0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
