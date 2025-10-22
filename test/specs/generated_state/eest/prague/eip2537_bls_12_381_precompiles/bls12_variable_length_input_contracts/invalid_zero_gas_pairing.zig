const std = @import("std");
const testing = std.testing;
const root = @import("../../../../../root.zig");
const runner = root.runner;

test "tests_eest_prague_eip2537_bls_12_381_precompiles_test_bls12_variable_length_input_contracts_py__test_invalid_zero_gas_pairing_fork_Prague_state_test_precompile_address_15__zero_gas_passed_" {
    const allocator = testing.allocator;

    // Read and parse the JSON test file
    const json_path = "execution-specs/tests/eest/static/state_tests/state_tests/eest/prague/eip2537_bls_12_381_precompiles/bls12_variable_length_input_contracts/invalid_zero_gas_pairing.json";
    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});
    defer parsed.deinit();

    // Get the specific test case
    const test_name = "tests/eest/prague/eip2537_bls_12_381_precompiles/test_bls12_variable_length_input_contracts.py::test_invalid_zero_gas_pairing[fork_Prague-state_test-precompile_address_15--zero_gas_passed]";
    const test_case = parsed.value.object.get(test_name) orelse return error.TestNotFound;

    // Run the test with path and name for trace generation
    try runner.runJsonTestWithPathAndName(allocator, test_case, json_path, test_name);
}
