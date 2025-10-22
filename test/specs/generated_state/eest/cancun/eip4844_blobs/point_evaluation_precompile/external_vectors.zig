const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_02e696ada7d4631d_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_02e696ada7d4631d]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_05c1f3685f3393f0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_05c1f3685f3393f0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_08f9e2f1cb3d39db_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_08f9e2f1cb3d39db]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_0cf79b17cb5f4ea2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_0cf79b17cb5f4ea2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_177b58dc7a46b08f_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_177b58dc7a46b08f]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_1ce8e4f69d5df899_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_1ce8e4f69d5df899]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_26b753dec0560daa_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_26b753dec0560daa]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_2b76dc9e3abf42f3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_2b76dc9e3abf42f3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_31ebd010e6098750_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_31ebd010e6098750]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_3208425794224c3f_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_3208425794224c3f]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_36817bfd67de97a8_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_36817bfd67de97a8]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_392169c16a2e5ef6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_392169c16a2e5ef6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_395cf6d697d1a743_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_395cf6d697d1a743]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_3ac8dc31e9aa6a70_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_3ac8dc31e9aa6a70]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_3c1e8b38219e3e12_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_3c1e8b38219e3e12]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_3c87ec986c2656c2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_3c87ec986c2656c2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_3cd183d0bab85fb7_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_3cd183d0bab85fb7]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_420f2a187ce77035_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_420f2a187ce77035]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_444b73ff54a19b44_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_444b73ff54a19b44]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_53a9bdf4f75196da_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_53a9bdf4f75196da]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_585454b31673dd62_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_585454b31673dd62]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_7db4f140a955dd1a_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_7db4f140a955dd1a]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_83e53423a2dd93fe_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_83e53423a2dd93fe]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_9b24f8997145435c_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_9b24f8997145435c]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_9b754afb690c47e1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_9b754afb690c47e1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_a0be66af9a97ea52_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_a0be66af9a97ea52]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_af669445747d2585_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_af669445747d2585]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_af8b75f664ed7d43_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_af8b75f664ed7d43]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_b6cb6698327d9835_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_b6cb6698327d9835]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_b6ec3736f9ff2c62_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_b6ec3736f9ff2c62]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_becf2e1641bbd4e6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_becf2e1641bbd4e6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_c3d4322ec17fe7cd_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_c3d4322ec17fe7cd]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_c5e1490d672d026d_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_c5e1490d672d026d]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_cae5d3491190b777_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_cae5d3491190b777]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_d0992bc0387790a4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_d0992bc0387790a4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_d736268229bd87ec_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_d736268229bd87ec]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_e68d7111a2364a49_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_e68d7111a2364a49]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_ed6b180ec759bcf6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_ed6b180ec759bcf6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_f0ed3dc11cdeb130_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_f0ed3dc11cdeb130]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_f47eb9fc139f6bfd_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_f47eb9fc139f6bfd]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_f7f44e1e864aa967_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_f7f44e1e864aa967]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_ffa6e97b97146517_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_ffa6e97b97146517]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_05c1f3685f3393f0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_05c1f3685f3393f0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_177b58dc7a46b08f_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_177b58dc7a46b08f]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_2b76dc9e3abf42f3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_2b76dc9e3abf42f3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_395cf6d697d1a743_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_395cf6d697d1a743]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_585454b31673dd62_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_585454b31673dd62]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_a0be66af9a97ea52_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_a0be66af9a97ea52]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_02e696ada7d4631d_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_02e696ada7d4631d]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_0cf79b17cb5f4ea2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_0cf79b17cb5f4ea2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_3208425794224c3f_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_3208425794224c3f]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_3ac8dc31e9aa6a70_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_3ac8dc31e9aa6a70]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_c3d4322ec17fe7cd_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_c3d4322ec17fe7cd]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_ffa6e97b97146517_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_ffa6e97b97146517]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_02e696ada7d4631d_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_02e696ada7d4631d]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_05c1f3685f3393f0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_05c1f3685f3393f0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_08f9e2f1cb3d39db_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_08f9e2f1cb3d39db]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_0cf79b17cb5f4ea2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_0cf79b17cb5f4ea2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_177b58dc7a46b08f_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_177b58dc7a46b08f]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_1ce8e4f69d5df899_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_1ce8e4f69d5df899]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_26b753dec0560daa_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_26b753dec0560daa]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_2b76dc9e3abf42f3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_2b76dc9e3abf42f3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_31ebd010e6098750_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_31ebd010e6098750]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_3208425794224c3f_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_3208425794224c3f]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_36817bfd67de97a8_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_36817bfd67de97a8]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_392169c16a2e5ef6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_392169c16a2e5ef6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_395cf6d697d1a743_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_395cf6d697d1a743]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_3ac8dc31e9aa6a70_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_3ac8dc31e9aa6a70]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_3c1e8b38219e3e12_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_3c1e8b38219e3e12]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_3c87ec986c2656c2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_3c87ec986c2656c2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_3cd183d0bab85fb7_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_3cd183d0bab85fb7]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_420f2a187ce77035_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_420f2a187ce77035]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_444b73ff54a19b44_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_444b73ff54a19b44]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_53a9bdf4f75196da_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_53a9bdf4f75196da]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_585454b31673dd62_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_585454b31673dd62]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_7db4f140a955dd1a_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_7db4f140a955dd1a]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_83e53423a2dd93fe_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_83e53423a2dd93fe]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_9b24f8997145435c_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_9b24f8997145435c]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_9b754afb690c47e1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_9b754afb690c47e1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_a0be66af9a97ea52_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_a0be66af9a97ea52]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_af669445747d2585_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_af669445747d2585]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_af8b75f664ed7d43_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_af8b75f664ed7d43]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_b6cb6698327d9835_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_b6cb6698327d9835]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_b6ec3736f9ff2c62_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_b6ec3736f9ff2c62]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_becf2e1641bbd4e6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_becf2e1641bbd4e6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_c3d4322ec17fe7cd_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_c3d4322ec17fe7cd]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_c5e1490d672d026d_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_c5e1490d672d026d]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_cae5d3491190b777_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_cae5d3491190b777]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_d0992bc0387790a4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_d0992bc0387790a4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_d736268229bd87ec_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_d736268229bd87ec]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_e68d7111a2364a49_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_e68d7111a2364a49]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_ed6b180ec759bcf6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_ed6b180ec759bcf6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_f0ed3dc11cdeb130_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_f0ed3dc11cdeb130]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_f47eb9fc139f6bfd_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_f47eb9fc139f6bfd]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_f7f44e1e864aa967_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_f7f44e1e864aa967]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_ffa6e97b97146517_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_ffa6e97b97146517]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_point_at_infinity_392169c16a2e5ef6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_point_at_infinity_392169c16a2e5ef6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_point_at_infinity_3c1e8b38219e3e12_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_point_at_infinity_3c1e8b38219e3e12]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_point_at_infinity_3c87ec986c2656c2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_point_at_infinity_3c87ec986c2656c2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_point_at_infinity_420f2a187ce77035_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_point_at_infinity_420f2a187ce77035]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_point_at_infinity_83e53423a2dd93fe_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_point_at_infinity_83e53423a2dd93fe]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_point_at_infinity_ed6b180ec759bcf6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_point_at_infinity_ed6b180ec759bcf6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_commitment_1b44e341d56c757d_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_commitment_1b44e341d56c757d]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_commitment_32afa9561a4b3b91_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_commitment_32afa9561a4b3b91]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_commitment_3e55802a5ed3c757_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_commitment_3e55802a5ed3c757]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_commitment_e9d3e9ec16fbc15f_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_commitment_e9d3e9ec16fbc15f]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_proof_1b44e341d56c757d_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_proof_1b44e341d56c757d]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_proof_32afa9561a4b3b91_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_proof_32afa9561a4b3b91]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_proof_3e55802a5ed3c757_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_proof_3e55802a5ed3c757]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_proof_e9d3e9ec16fbc15f_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_proof_e9d3e9ec16fbc15f]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_y_35d08d612aad2197_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_y_35d08d612aad2197]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_y_4aa6def8c35c9097_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_y_4aa6def8c35c9097]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_y_4e51cef08a61606f_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_y_4e51cef08a61606f]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_y_64b9ff2b8f7dddee_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_y_64b9ff2b8f7dddee]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_y_b358a2e763727b70_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_y_b358a2e763727b70]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_y_eb0601fec84cc5e9_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_y_eb0601fec84cc5e9]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_z_35d08d612aad2197_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_z_35d08d612aad2197]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_z_4aa6def8c35c9097_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_z_4aa6def8c35c9097]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_z_4e51cef08a61606f_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_z_4e51cef08a61606f]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_z_64b9ff2b8f7dddee_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_z_64b9ff2b8f7dddee]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_z_b358a2e763727b70_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_z_b358a2e763727b70]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Cancun_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_z_eb0601fec84cc5e9_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Cancun-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_z_eb0601fec84cc5e9]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_02e696ada7d4631d_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_02e696ada7d4631d]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_05c1f3685f3393f0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_05c1f3685f3393f0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_08f9e2f1cb3d39db_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_08f9e2f1cb3d39db]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_0cf79b17cb5f4ea2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_0cf79b17cb5f4ea2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_177b58dc7a46b08f_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_177b58dc7a46b08f]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_1ce8e4f69d5df899_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_1ce8e4f69d5df899]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_26b753dec0560daa_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_26b753dec0560daa]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_2b76dc9e3abf42f3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_2b76dc9e3abf42f3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_31ebd010e6098750_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_31ebd010e6098750]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_3208425794224c3f_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_3208425794224c3f]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_36817bfd67de97a8_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_36817bfd67de97a8]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_392169c16a2e5ef6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_392169c16a2e5ef6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_395cf6d697d1a743_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_395cf6d697d1a743]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_3ac8dc31e9aa6a70_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_3ac8dc31e9aa6a70]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_3c1e8b38219e3e12_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_3c1e8b38219e3e12]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_3c87ec986c2656c2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_3c87ec986c2656c2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_3cd183d0bab85fb7_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_3cd183d0bab85fb7]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_420f2a187ce77035_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_420f2a187ce77035]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_444b73ff54a19b44_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_444b73ff54a19b44]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_53a9bdf4f75196da_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_53a9bdf4f75196da]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_585454b31673dd62_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_585454b31673dd62]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_7db4f140a955dd1a_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_7db4f140a955dd1a]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_83e53423a2dd93fe_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_83e53423a2dd93fe]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_9b24f8997145435c_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_9b24f8997145435c]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_9b754afb690c47e1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_9b754afb690c47e1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_a0be66af9a97ea52_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_a0be66af9a97ea52]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_af669445747d2585_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_af669445747d2585]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_af8b75f664ed7d43_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_af8b75f664ed7d43]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_b6cb6698327d9835_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_b6cb6698327d9835]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_b6ec3736f9ff2c62_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_b6ec3736f9ff2c62]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_becf2e1641bbd4e6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_becf2e1641bbd4e6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_c3d4322ec17fe7cd_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_c3d4322ec17fe7cd]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_c5e1490d672d026d_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_c5e1490d672d026d]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_cae5d3491190b777_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_cae5d3491190b777]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_d0992bc0387790a4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_d0992bc0387790a4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_d736268229bd87ec_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_d736268229bd87ec]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_e68d7111a2364a49_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_e68d7111a2364a49]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_ed6b180ec759bcf6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_ed6b180ec759bcf6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_f0ed3dc11cdeb130_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_f0ed3dc11cdeb130]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_f47eb9fc139f6bfd_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_f47eb9fc139f6bfd]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_f7f44e1e864aa967_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_f7f44e1e864aa967]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_ffa6e97b97146517_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_ffa6e97b97146517]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_05c1f3685f3393f0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_05c1f3685f3393f0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_177b58dc7a46b08f_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_177b58dc7a46b08f]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_2b76dc9e3abf42f3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_2b76dc9e3abf42f3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_395cf6d697d1a743_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_395cf6d697d1a743]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_585454b31673dd62_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_585454b31673dd62]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_a0be66af9a97ea52_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_twos_poly_a0be66af9a97ea52]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_02e696ada7d4631d_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_02e696ada7d4631d]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_0cf79b17cb5f4ea2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_0cf79b17cb5f4ea2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_3208425794224c3f_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_3208425794224c3f]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_3ac8dc31e9aa6a70_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_3ac8dc31e9aa6a70]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_c3d4322ec17fe7cd_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_c3d4322ec17fe7cd]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_ffa6e97b97146517_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_correct_proof_point_at_infinity_for_zero_poly_ffa6e97b97146517]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_02e696ada7d4631d_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_02e696ada7d4631d]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_05c1f3685f3393f0_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_05c1f3685f3393f0]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_08f9e2f1cb3d39db_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_08f9e2f1cb3d39db]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_0cf79b17cb5f4ea2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_0cf79b17cb5f4ea2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_177b58dc7a46b08f_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_177b58dc7a46b08f]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_1ce8e4f69d5df899_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_1ce8e4f69d5df899]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_26b753dec0560daa_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_26b753dec0560daa]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_2b76dc9e3abf42f3_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_2b76dc9e3abf42f3]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_31ebd010e6098750_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_31ebd010e6098750]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_3208425794224c3f_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_3208425794224c3f]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_36817bfd67de97a8_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_36817bfd67de97a8]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_392169c16a2e5ef6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_392169c16a2e5ef6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_395cf6d697d1a743_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_395cf6d697d1a743]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_3ac8dc31e9aa6a70_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_3ac8dc31e9aa6a70]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_3c1e8b38219e3e12_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_3c1e8b38219e3e12]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_3c87ec986c2656c2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_3c87ec986c2656c2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_3cd183d0bab85fb7_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_3cd183d0bab85fb7]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_420f2a187ce77035_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_420f2a187ce77035]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_444b73ff54a19b44_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_444b73ff54a19b44]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_53a9bdf4f75196da_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_53a9bdf4f75196da]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_585454b31673dd62_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_585454b31673dd62]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_7db4f140a955dd1a_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_7db4f140a955dd1a]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_83e53423a2dd93fe_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_83e53423a2dd93fe]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_9b24f8997145435c_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_9b24f8997145435c]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_9b754afb690c47e1_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_9b754afb690c47e1]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_a0be66af9a97ea52_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_a0be66af9a97ea52]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_af669445747d2585_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_af669445747d2585]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_af8b75f664ed7d43_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_af8b75f664ed7d43]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_b6cb6698327d9835_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_b6cb6698327d9835]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_b6ec3736f9ff2c62_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_b6ec3736f9ff2c62]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_becf2e1641bbd4e6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_becf2e1641bbd4e6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_c3d4322ec17fe7cd_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_c3d4322ec17fe7cd]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_c5e1490d672d026d_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_c5e1490d672d026d]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_cae5d3491190b777_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_cae5d3491190b777]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_d0992bc0387790a4_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_d0992bc0387790a4]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_d736268229bd87ec_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_d736268229bd87ec]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_e68d7111a2364a49_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_e68d7111a2364a49]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_ed6b180ec759bcf6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_ed6b180ec759bcf6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_f0ed3dc11cdeb130_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_f0ed3dc11cdeb130]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_f47eb9fc139f6bfd_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_f47eb9fc139f6bfd]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_f7f44e1e864aa967_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_f7f44e1e864aa967]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_ffa6e97b97146517_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_ffa6e97b97146517]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_point_at_infinity_392169c16a2e5ef6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_point_at_infinity_392169c16a2e5ef6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_point_at_infinity_3c1e8b38219e3e12_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_point_at_infinity_3c1e8b38219e3e12]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_point_at_infinity_3c87ec986c2656c2_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_point_at_infinity_3c87ec986c2656c2]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_point_at_infinity_420f2a187ce77035_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_point_at_infinity_420f2a187ce77035]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_point_at_infinity_83e53423a2dd93fe_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_point_at_infinity_83e53423a2dd93fe]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_incorrect_proof_point_at_infinity_ed6b180ec759bcf6_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_incorrect_proof_point_at_infinity_ed6b180ec759bcf6]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_commitment_1b44e341d56c757d_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_commitment_1b44e341d56c757d]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_commitment_32afa9561a4b3b91_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_commitment_32afa9561a4b3b91]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_commitment_3e55802a5ed3c757_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_commitment_3e55802a5ed3c757]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_commitment_e9d3e9ec16fbc15f_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_commitment_e9d3e9ec16fbc15f]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_proof_1b44e341d56c757d_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_proof_1b44e341d56c757d]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_proof_32afa9561a4b3b91_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_proof_32afa9561a4b3b91]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_proof_3e55802a5ed3c757_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_proof_3e55802a5ed3c757]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_proof_e9d3e9ec16fbc15f_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_proof_e9d3e9ec16fbc15f]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_y_35d08d612aad2197_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_y_35d08d612aad2197]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_y_4aa6def8c35c9097_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_y_4aa6def8c35c9097]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_y_4e51cef08a61606f_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_y_4e51cef08a61606f]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_y_64b9ff2b8f7dddee_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_y_64b9ff2b8f7dddee]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_y_b358a2e763727b70_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_y_b358a2e763727b70]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_y_eb0601fec84cc5e9_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_y_eb0601fec84cc5e9]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_z_35d08d612aad2197_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_z_35d08d612aad2197]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_z_4aa6def8c35c9097_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_z_4aa6def8c35c9097]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_z_4e51cef08a61606f_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_z_4e51cef08a61606f]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_z_64b9ff2b8f7dddee_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_z_64b9ff2b8f7dddee]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_z_b358a2e763727b70_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_z_b358a2e763727b70]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}

test "tests_eest_cancun_eip4844_blobs_test_point_evaluation_precompile_py__test_external_vectors_fork_Prague_state_test_versioned_hash_None_verify_kzg_proof_case_invalid_z_eb0601fec84cc5e9_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/eip4844_blobs/point_evaluation_precompile/external_vectors.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/cancun/eip4844_blobs/test_point_evaluation_precompile.py::test_external_vectors[fork_Prague-state_test-versioned_hash_None-verify_kzg_proof_case_invalid_z_eb0601fec84cc5e9]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
