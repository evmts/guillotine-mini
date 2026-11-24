// Tests for evm.zig - moved from inline tests
const std = @import("std");
const primitives = @import("voltaire");
const errors = @import("errors.zig");
const evm = @import("evm.zig");
const storage = @import("storage.zig");
const Evm = evm.Evm(.{}); // Default config
const StorageInjector = @import("storage_injector.zig").StorageInjector;
const AsyncDataRequest = storage.AsyncDataRequest;

test "AsyncDataRequest - union size and field access" {
    const testing = std.testing;

    // Test none variant
    const req_none = AsyncDataRequest{ .none = {} };
    try testing.expect(req_none == .none);

    // Test storage variant
    const addr = primitives.Address.fromHex("0x1234567890123456789012345678901234567890") catch unreachable;
    const req_storage = AsyncDataRequest{ .storage = .{
        .address = addr,
        .slot = 42,
    } };
    try testing.expect(req_storage == .storage);
    try testing.expect(req_storage.storage.address.equals(addr));
    try testing.expectEqual(42, req_storage.storage.slot);

    // Test balance variant
    const req_balance = AsyncDataRequest{ .balance = .{
        .address = addr,
    } };
    try testing.expect(req_balance == .balance);
    try testing.expect(req_balance.balance.address.equals(addr));

    // Test code variant
    const req_code = AsyncDataRequest{ .code = .{
        .address = addr,
    } };
    try testing.expect(req_code == .code);
    try testing.expect(req_code.code.address.equals(addr));

    // Test nonce variant
    const req_nonce = AsyncDataRequest{ .nonce = .{
        .address = addr,
    } };
    try testing.expect(req_nonce == .nonce);
    try testing.expect(req_nonce.nonce.address.equals(addr));
}

test "AsyncDataRequest - can write and read each variant" {
    const testing = std.testing;

    var request: AsyncDataRequest = .none;

    // Write storage request
    const addr = primitives.Address.fromHex("0xabcdef0123456789abcdef0123456789abcdef01") catch unreachable;
    request = .{ .storage = .{ .address = addr, .slot = 100 } };
    try testing.expect(request == .storage);
    try testing.expectEqual(100, request.storage.slot);

    // Write balance request
    request = .{ .balance = .{ .address = addr } };
    try testing.expect(request == .balance);

    // Write back to none
    request = .none;
    try testing.expect(request == .none);
}

test "error.NeedAsyncData can be caught and identified" {
    const testing = std.testing;

    const TestFn = struct {
        fn needsData() !void {
            return errors.CallError.NeedAsyncData;
        }
    };

    const result = TestFn.needsData();
    try testing.expectError(errors.CallError.NeedAsyncData, result);
}

test "error.NeedAsyncData propagates through call stack" {
    const testing = std.testing;

    const TestFn = struct {
        fn level3() !void {
            return errors.CallError.NeedAsyncData;
        }

        fn level2() !void {
            try level3();
        }

        fn level1() !void {
            try level2();
        }
    };

    const result = TestFn.level1();
    try testing.expectError(errors.CallError.NeedAsyncData, result);
}

test "Evm.async_data_request field initialized to .none" {
    const testing = std.testing;

    var evm_instance: Evm = undefined;

    try evm_instance.init(testing.allocator, null, null, null, primitives.ZERO_ADDRESS, 0, null);
    defer evm_instance.deinit();
    try evm_instance.initTransactionState(null);

    try testing.expect(evm_instance.storage.async_data_request == .none);
}

test "Evm.async_data_request can write/read different request types" {
    const testing = std.testing;

    var evm_instance: Evm = undefined;

    try evm_instance.init(testing.allocator, null, null, null, primitives.ZERO_ADDRESS, 0, null);
    defer evm_instance.deinit();
    try evm_instance.initTransactionState(null);

    const addr = primitives.Address.fromHex("0x1111111111111111111111111111111111111111") catch unreachable;

    // Write storage request
    evm_instance.storage.async_data_request = .{ .storage = .{ .address = addr, .slot = 99 } };
    try testing.expect(evm_instance.storage.async_data_request == .storage);
    try testing.expectEqual(99, evm_instance.storage.async_data_request.storage.slot);

    // Write balance request
    evm_instance.storage.async_data_request = .{ .balance = .{ .address = addr } };
    try testing.expect(evm_instance.storage.async_data_request == .balance);

    // Clear request
    evm_instance.storage.async_data_request = .none;
    try testing.expect(evm_instance.storage.async_data_request == .none);
}

test "Evm.inner_create top-level uses transaction nonce for multi-byte CREATE address" {
    const testing = std.testing;

    const caller = try primitives.Address.fromHex("0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b");
    const expected = try primitives.Address.fromHex("0xecbf9aa676d9e0bbba7e517d1350c1b64f8c6779");

    var evm_instance: Evm = undefined;
    try evm_instance.init(testing.allocator, null, .BERLIN, null, caller, 0, null);
    defer evm_instance.deinit();
    try evm_instance.initTransactionState(null);

    // Transaction processing increments the sender nonce before entering the EVM.
    try evm_instance.nonces.put(caller, 0x0cc7);

    const result = try evm_instance.inner_create(0, &.{}, 100_000, null);
    try testing.expect(result.success);
    try testing.expect(result.address.equals(expected));
}

test "Evm.inner_call rolls back logs when callee errors after emitting LOG" {
    const testing = std.testing;

    var evm_instance: Evm = undefined;
    try evm_instance.init(testing.allocator, null, .BERLIN, null, primitives.ZERO_ADDRESS, 0, null);
    defer evm_instance.deinit();
    try evm_instance.initTransactionState(null);

    const caller = try primitives.Address.fromHex("0x1000000000000000000000000000000000000001");
    const callee = try primitives.Address.fromHex("0x2000000000000000000000000000000000000002");
    const callee_code = [_]u8{
        0x60, 0x01, // PUSH1 0x01 (size)
        0x60, 0x00, // PUSH1 0x00 (offset)
        0xa0, // LOG0
        0x60, 0x01, // PUSH1 0x01 (value)
        0x60, 0x00, // PUSH1 0x00 (slot)
        0x55, // SSTORE (forces OOG with low gas)
        0x00, // STOP
    };
    try evm_instance.code.put(callee, &callee_code);

    const result = evm_instance.inner_call(.{ .call = .{
        .caller = caller,
        .to = callee,
        .value = 0,
        .input = &.{},
        .gas = 1_000,
    } });

    try testing.expect(!result.success);
    try testing.expectEqual(@as(usize, 0), evm_instance.logs.items.len);
}

// ============================================================================
// Tests for Phase 4: callOrContinue() and Async Execution
// ============================================================================

test "CallOrContinueInput/Output - can construct each variant" {
    const testing = std.testing;

    const addr = primitives.Address.fromHex("0x1111111111111111111111111111111111111111") catch unreachable;

    // Test Input variants
    const call_input: Evm.CallOrContinueInput = .{ .call = .{
        .call = .{
            .caller = addr,
            .to = addr,
            .gas = 1000,
            .value = 0,
            .input = &[_]u8{},
        },
    } };
    try testing.expect(call_input == .call);

    const storage_input: Evm.CallOrContinueInput = .{ .continue_with_storage = .{
        .address = addr,
        .slot = 42,
        .value = 100,
    } };
    try testing.expect(storage_input == .continue_with_storage);

    // Test Output variants
    const result_output: Evm.CallOrContinueOutput = .{ .result = .{
        .success = true,
        .gas_left = 500,
        .output = &[_]u8{},
    } };
    try testing.expect(result_output == .result);

    const storage_output: Evm.CallOrContinueOutput = .{ .need_storage = .{
        .address = addr,
        .slot = 99,
    } };
    try testing.expect(storage_output == .need_storage);
}

test "callOrContinue - returns .need_storage on cache miss" {
    const testing = std.testing;

    // Create EVM
    var evm_instance: Evm = undefined;
    try evm_instance.init(testing.allocator, null, null, null, primitives.ZERO_ADDRESS, 0, null);
    defer evm_instance.deinit();
    try evm_instance.initTransactionState(null);

    // Set storage injector before calling
    var injector = try StorageInjector.init(evm_instance.arena.allocator());
    evm_instance.pending_storage_injector = &injector;

    const addr = primitives.Address.fromHex("0x1234567890123456789012345678901234567890") catch unreachable;

    // Bytecode: PUSH1 0x00, SLOAD, STOP - will trigger async request
    const bytecode = [_]u8{ 0x60, 0x00, 0x54, 0x00 }; // PUSH1 0, SLOAD, STOP
    evm_instance.pending_bytecode = &bytecode;

    const params: Evm.CallParams = .{ .call = .{
        .caller = addr,
        .to = addr,
        .gas = 100000,
        .value = 0,
        .input = &[_]u8{},
    } };

    const output = try evm_instance.callOrContinue(.{ .call = params });

    // Should yield with storage request
    try testing.expect(output == .need_storage);
    try testing.expectEqual(@as(u256, 0), output.need_storage.slot);
}

// TODO: Re-enable this test once async resume functionality is fixed
// Currently SLOAD pops the stack before yielding, causing StackUnderflow on resume
// test "callOrContinue - continue_with_storage resumes execution" {
//     const testing = std.testing;
//
//     var evm_instance = try Evm.init(testing.allocator, null, null, null, null);
//     defer evm_instance.deinit();
//
//     // Set storage injector before calling
//     var injector = try StorageInjector.init(evm_instance.arena.allocator());
//     evm_instance.pending_storage_injector = &injector;
//
//     const addr = primitives.Address.fromHex("0x1234567890123456789012345678901234567890") catch unreachable;
//
//     // Bytecode: PUSH1 0x00, SLOAD, STOP
//     const bytecode = [_]u8{ 0x60, 0x00, 0x54, 0x00 };
//     evm_instance.pending_bytecode = &bytecode;
//
//     const params: Evm.CallParams = .{ .call = .{
//         .caller = addr,
//         .to = addr,
//         .gas = 100000,
//         .value = 0,
//         .input = &[_]u8{},
//     } };
//
//     // First call - should yield
//     const output1 = try evm_instance.callOrContinue(.{ .call = params });
//     try testing.expect(output1 == .need_storage);
//
//     // Continue with storage value
//     const output2 = try evm_instance.callOrContinue(.{ .continue_with_storage = .{
//         .address = addr,
//         .slot = 0,
//         .value = 42,
//     } });
//
//     // With storage injector, should return ready_to_commit
//     try testing.expect(output2 == .ready_to_commit);
//
//     // Continue after commit to get final result
//     const output3 = try evm_instance.callOrContinue(.{ .continue_after_commit = {} });
//     try testing.expect(output3 == .result);
//     try testing.expect(output3.result.success);
// }

// ============================================================================
// Synthesized Panel Regression Tests:
//   - Osaka EIP-7951 P256VERIFY (0x0100) & dynamic EIP-2537 BLS12-381 alignment
//   - BUG_HUNT_REPORT #9: untruncated >16 KB async state-changes JSON & C ABI
//   - Salvage #854: zero-undefined safe Evm.init
// ============================================================================

const crypto_mod = @import("crypto");
const precompiles_mod = @import("precompiles");
const host_mod = @import("host.zig");
const root_c = @import("root_c.zig");

const p256_one = [_]u8{0} ** 31 ++ [_]u8{1};

fn hexBytes(comptime hex: []const u8) [hex.len / 2]u8 {
    var out: [hex.len / 2]u8 = undefined;
    _ = std.fmt.hexToBytes(&out, hex) catch unreachable;
    return out;
}

fn p256WordsInput(words: [5]u256) [160]u8 {
    var out: [160]u8 = undefined;
    for (words, 0..) |word, i| {
        std.mem.writeInt(u256, out[i * 32 ..][0..32], word, .big);
    }
    return out;
}

fn writeWordBe(buf: []u8, offset: usize, value: u256) void {
    std.mem.writeInt(u256, buf[offset..][0..32], value, .big);
}

/// Independent P-256 signature (Node/OpenSSL, SHA-256, IEEE P1363): hash || r || s || qx || qy.
const p256_openssl_valid = hexBytes(
    "49d0b78b6ec6645a24cdc6887eac6b46cb7c49e9e9ede372195a3750db01787d" ++
        "055057bb56fda42296f4134949276e210fce5891cb2ce01c606000fd8a47efb4" ++
        "44b4924243c74a947848740404b7ed6e48ae0b536f5e24904e69a032562c7006" ++
        "d88cdde4c489f0723a3b9168d8a571f907b2f0a83c90a79f21e8e5221b7f0f9f" ++
        "bd9734cd3a8512d7bf9a7f537ad420f805c84da8b3721f99e29c25c2c9fc7170",
);

/// EEST test_modular_comparison vector: recovered verification point has x > n (so x mod n == r).
const p256_eest_high_x = hexBytes(
    "bb5a52f42f9c9261ed4361f59422a1e30036e7c32b270c8807a419feca605023" ++
        "000000000000000000000000000000004319055358e8617b0c46353d039cdaab" ++
        "ffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc63254e" ++
        "0ad99500288d466940031d72a9f5445a4d43784640855bf0a69874d2de5fe103" ++
        "c5011e6ef2c42dcd50d5d3d29f99ae6eba2c80c9244f4c5422f0979ff0c3ba5e",
);

/// Independent r || s || qx || qy valid for msg_hash == 0 (mod n): R' = (r * s^-1) * Q.
const p256_zero_hash_tail = hexBytes(
    "dfbf0d7f1a22633fa528a9f77e2eb2153f255f92fc93d8aad6158f3fbffcbde3" ++
        "d6a1108b4c4382ce7a53d9196506cf4e0d815797dc4475d705190a749ad7db30" ++
        "471c3e758c4904285bba7e53118ed0f524adeb0757d25bd2f8e7b0d76dfa714c" ++
        "dd520f7aca8a8b917acc37f51de8f0c9bbe3ad858382e702dc25a12d09f7a858",
);

fn expectP256Direct(input: []const u8, expected: []const u8) !void {
    const result = try evm.executeP256Verify(std.testing.allocator, input, 100_000);
    defer if (result.output.len > 0) std.testing.allocator.free(result.output);
    try std.testing.expectEqual(evm.P256VERIFY_GAS, result.gas_used);
    try std.testing.expectEqualSlices(u8, expected, result.output);
}

test "isPrecompileAddress - P256VERIFY at 0x0100 is Osaka-only and 0x00..0x20 tracks Voltaire" {
    const testing = std.testing;
    const p256_addr = evm.P256VERIFY_ADDRESS;
    try testing.expectEqual(@as(u256, 0x0100), p256_addr.toU256());
    try testing.expect(evm.isPrecompileAddress(p256_addr, .OSAKA));
    try testing.expect(Evm.isPrecompileAddress(p256_addr, .OSAKA));
    try testing.expect(!evm.isPrecompileAddress(p256_addr, .PRAGUE));
    try testing.expect(!evm.isPrecompileAddress(p256_addr, .CANCUN));
    try testing.expect(!evm.isPrecompileAddress(primitives.Address.fromU256(0x0101), .OSAKA));
    try testing.expect(!evm.isPrecompileAddress(primitives.Address.fromU256(0x00ff), .OSAKA));
    try testing.expect(!evm.isPrecompileAddress(primitives.ZERO_ADDRESS, .OSAKA));

    const forks = [_]primitives.Hardfork{
        .FRONTIER,
        .BYZANTIUM,
        .ISTANBUL,
        .BERLIN,
        .CANCUN,
        .PRAGUE,
        .OSAKA,
    };
    for (forks) |fork| {
        var addr_int: u16 = 0;
        while (addr_int <= 0x20) : (addr_int += 1) {
            const addr = primitives.Address.fromU256(addr_int);
            try testing.expectEqual(
                precompiles_mod.isPrecompile(addr, fork),
                evm.isPrecompileAddress(addr, fork),
            );
        }
    }
}

test "P256VERIFY - valid OpenSSL, Voltaire, EEST high-x, high-s, and h mod n == 0 signatures" {
    const testing = std.testing;
    const p256 = crypto_mod.p256;

    // Independent OpenSSL signature
    try expectP256Direct(&p256_openssl_valid, &p256_one);

    // High-s twin (n - s) must also be accepted per EIP-7951
    var high_s = p256_openssl_valid;
    const s_val = std.mem.readInt(u256, high_s[64..96], .big);
    writeWordBe(&high_s, 64, p256.P256_N - s_val);
    try expectP256Direct(&high_s, &p256_one);

    // EEST modular-comparison vector (recovered x > n, x mod n == r)
    try expectP256Direct(&p256_eest_high_x, &p256_one);

    // Signature produced by Voltaire crypto.p256.sign
    const priv = [_]u8{0x07} ** 32;
    const hash = [_]u8{0x42} ** 32;
    const sig = try p256.sign(testing.allocator, &hash, &priv);
    defer testing.allocator.free(sig);
    const pub_key = try p256.publicKeyFromPrivate(testing.allocator, &priv);
    defer testing.allocator.free(pub_key);
    var voltaire_input: [160]u8 = undefined;
    @memcpy(voltaire_input[0..32], &hash);
    @memcpy(voltaire_input[32..96], sig);
    @memcpy(voltaire_input[96..160], pub_key);
    try expectP256Direct(&voltaire_input, &p256_one);

    // EIP-7951: h == 0 and h == n (both congruent to 0 mod n)
    for ([_]u256{ 0, p256.P256_N }) |zero_mod_n| {
        var input: [160]u8 = undefined;
        writeWordBe(&input, 0, zero_mod_n);
        @memcpy(input[32..160], &p256_zero_hash_tail);
        try expectP256Direct(&input, &p256_one);

        // Also Q = G, r = s = G.x satisfies (r/s)*G = G -> x == r
        const gen_zero = p256WordsInput(.{ zero_mod_n, p256.P256_GX, p256.P256_GX, p256.P256_GX, p256.P256_GY });
        try expectP256Direct(&gen_zero, &p256_one);
    }
}

test "P256VERIFY - invalid signatures, scalar/coordinate bounds, infinity, and lengths return empty" {
    const p256 = crypto_mod.p256;
    const n = p256.P256_N;
    const p = p256.P256_P;
    const gx = p256.P256_GX;
    const gy = p256.P256_GY;

    // Bit-flip in each of the 5 words
    for ([_]usize{ 0, 32, 64, 96, 128 }) |offset| {
        var flipped = p256_openssl_valid;
        flipped[offset + 31] ^= 0x01;
        try expectP256Direct(&flipped, &.{});
    }

    // Scalar & coordinate bounds, (0, 0), (0, 1) Zig affine identity, off-curve, and recovered infinity
    const invalid_cases = [_][5]u256{
        .{ 1, 0, gx + 1, gx, gy }, // r == 0
        .{ 1, n, gx + 1, gx, gy }, // r == n
        .{ 1, n + 1, gx + 1, gx, gy }, // r > n
        .{ 1, std.math.maxInt(u256), gx + 1, gx, gy }, // r == 2^256 - 1
        .{ 1, gx, 0, gx, gy }, // s == 0
        .{ 1, gx, n, gx, gy }, // s == n
        .{ 1, gx, n + 1, gx, gy }, // s > n
        .{ 1, gx, gx + 1, 0, 0 }, // Q == (0, 0) EIP-7951 infinity
        .{ 1, gx, gx + 1, 0, 1 }, // Q == (0, 1) Zig affine identity
        .{ 1, gx, gx + 1, p, gy }, // qx == p
        .{ 1, gx, gx + 1, gx, p }, // qy == p
        .{ 1, gx, gx + 1, gx, gy + 1 }, // off-curve point
        .{ n - gx, gx, gx + 1, gx, gy }, // R' = ((n-r)/s)G + (r/s)G = infinity
        .{ 0, gx, gx, 0, 0 }, // h == 0 with (0, 0)
        .{ 0, gx, gx, 0, 1 }, // h == 0 with (0, 1)
        .{ n, 0, gx, gx, gy }, // h == n with r == 0
    };
    for (invalid_cases) |words| {
        const input = p256WordsInput(words);
        try expectP256Direct(&input, &.{});
    }

    // Wrong input lengths all succeed with empty output and charge 6900 gas
    try expectP256Direct(&.{}, &.{});
    try expectP256Direct(p256_openssl_valid[0..159], &.{});
    var len161: [161]u8 = undefined;
    @memcpy(len161[0..160], &p256_openssl_valid);
    len161[160] = 0;
    try expectP256Direct(&len161, &.{});
}

test "P256VERIFY - gas accounting, direct Evm.call, nested STATICCALL, and fork gating" {
    const testing = std.testing;

    // Direct executeP256Verify gas boundary
    try testing.expectError(error.OutOfGas, evm.executeP256Verify(testing.allocator, &p256_openssl_valid, 6899));
    try testing.expectError(error.OutOfGas, evm.executeP256Verify(testing.allocator, &.{}, 6899));
    const exact = try evm.executeP256Verify(testing.allocator, &p256_openssl_valid, 6900);
    defer testing.allocator.free(exact.output);
    try testing.expectEqual(@as(u64, 6900), exact.gas_used);
    try testing.expectEqualSlices(u8, &p256_one, exact.output);

    // Direct Evm.call on Osaka (including maxInt(u64) gas and >4 MiB calldata)
    {
        var vm: Evm = undefined;
        try vm.init(testing.allocator, null, .OSAKA, null, primitives.ZERO_ADDRESS, 0, null);
        defer vm.deinit();

        const ok = vm.call(.{ .call = .{
            .caller = vm.origin,
            .to = evm.P256VERIFY_ADDRESS,
            .gas = 10_000,
            .value = 0,
            .input = &p256_openssl_valid,
        } });
        try testing.expect(ok.success);
        try testing.expectEqual(@as(u64, 10_000 - 6900), ok.gas_left);
        try testing.expectEqualSlices(u8, &p256_one, ok.output);

        const max_gas = vm.call(.{ .call = .{
            .caller = vm.origin,
            .to = evm.P256VERIFY_ADDRESS,
            .gas = std.math.maxInt(u64),
            .value = 0,
            .input = &p256_openssl_valid,
        } });
        try testing.expect(max_gas.success);
        try testing.expectEqual(std.math.maxInt(u64) - 6900, max_gas.gas_left);

        const oog = vm.call(.{ .call = .{
            .caller = vm.origin,
            .to = evm.P256VERIFY_ADDRESS,
            .gas = 6899,
            .value = 0,
            .input = &p256_openssl_valid,
        } });
        try testing.expect(!oog.success);
        try testing.expectEqual(@as(u64, 0), oog.gas_left);
        try testing.expectEqual(@as(usize, 0), oog.output.len);

        const oversized = try testing.allocator.alloc(u8, 4 * 1024 * 1024 + 1);
        defer testing.allocator.free(oversized);
        @memset(oversized, 0);
        const huge = vm.call(.{ .call = .{
            .caller = vm.origin,
            .to = evm.P256VERIFY_ADDRESS,
            .gas = 7000,
            .value = 0,
            .input = oversized,
        } });
        try testing.expect(huge.success);
        try testing.expectEqual(@as(u64, 100), huge.gas_left);
        try testing.expectEqual(@as(usize, 0), huge.output.len);
    }

    // Nested STATICCALL to 0x0100: Osaka (warm 100 + 6900) vs Prague (cold 2600, empty account)
    // CALLDATACOPY; STATICCALL(GAS, 0x0100, 0, CALLDATASIZE, 0xa0, 32); RETURN [word || success || returndatasize]
    const caller_code = hexBytes("366000600037602060a03660006101005afa60c0523d60e052606060a0f3");
    const contract_addr = primitives.Address.fromU256(0x0200);
    const start_gas: u64 = 100_000;

    var osaka_vm: Evm = undefined;
    try osaka_vm.init(testing.allocator, null, .OSAKA, null, primitives.ZERO_ADDRESS, 0, null);
    defer osaka_vm.deinit();
    try osaka_vm.code.put(contract_addr, &caller_code);
    const osaka_res = osaka_vm.call(.{ .call = .{
        .caller = osaka_vm.origin,
        .to = contract_addr,
        .gas = start_gas,
        .value = 0,
        .input = &p256_openssl_valid,
    } });
    try testing.expect(osaka_res.success);
    try testing.expectEqual(@as(usize, 96), osaka_res.output.len);
    try testing.expectEqualSlices(u8, &p256_one, osaka_res.output[0..32]);
    try testing.expectEqual(@as(u8, 1), osaka_res.output[63]);
    try testing.expectEqual(@as(u8, 32), osaka_res.output[95]);

    var prague_vm: Evm = undefined;
    try prague_vm.init(testing.allocator, null, .PRAGUE, null, primitives.ZERO_ADDRESS, 0, null);
    defer prague_vm.deinit();
    try prague_vm.code.put(contract_addr, &caller_code);
    const prague_res = prague_vm.call(.{ .call = .{
        .caller = prague_vm.origin,
        .to = contract_addr,
        .gas = start_gas,
        .value = 0,
        .input = &p256_openssl_valid,
    } });
    try testing.expect(prague_res.success);
    try testing.expectEqual(@as(u8, 1), prague_res.output[63]);
    try testing.expectEqual(@as(u8, 0), prague_res.output[95]);

    // Osaka gas_used - Prague gas_used == (6900 + 100 warm) - 2600 cold == 4400
    const osaka_used = start_gas - osaka_res.gas_left;
    const prague_used = start_gas - prague_res.gas_left;
    try testing.expectEqual(@as(u64, 6900 + 100 - 2600), osaka_used - prague_used);
}

test "pre-warming - initTransactionState and preWarmTransaction match isPrecompileAddress dynamically" {
    const testing = std.testing;
    const forks = [_]primitives.Hardfork{ .ISTANBUL, .BERLIN, .CANCUN, .PRAGUE, .OSAKA };
    const dummy_target = primitives.Address.fromU256(0x1234);

    for (forks) |fork| {
        var vm: Evm = undefined;
        try vm.init(testing.allocator, null, fork, null, primitives.ZERO_ADDRESS, 0, null);
        defer vm.deinit();

        try vm.initTransactionState(null);
        for (0..0x21) |n| {
            const addr = primitives.Address.fromU256(n);
            const expected = fork.isAtLeast(.BERLIN) and evm.isPrecompileAddress(addr, fork);
            try testing.expectEqual(expected, vm.access_list_manager.is_address_warm(addr));
        }
        try testing.expectEqual(
            fork.isAtLeast(.OSAKA),
            vm.access_list_manager.is_address_warm(evm.P256VERIFY_ADDRESS),
        );
        try testing.expect(!vm.access_list_manager.is_address_warm(primitives.Address.fromU256(0x0101)));

        // Standalone preWarmTransaction after clearing must restore exact precompile warm set
        vm.access_list_manager.clear();
        try vm.preWarmTransaction(dummy_target);
        try testing.expectEqual(fork.isAtLeast(.BERLIN), vm.access_list_manager.is_address_warm(dummy_target));
        for (1..0x21) |n| {
            const addr = primitives.Address.fromU256(n);
            const expected = fork.isAtLeast(.BERLIN) and evm.isPrecompileAddress(addr, fork);
            try testing.expectEqual(expected, vm.access_list_manager.is_address_warm(addr));
        }
        try testing.expectEqual(
            fork.isAtLeast(.OSAKA),
            vm.access_list_manager.is_address_warm(evm.P256VERIFY_ADDRESS),
        );
    }
}

test "EIP-161 cleanup - a touched empty account is deleted even at a precompile address" {
    const testing = std.testing;

    const RecordingHost = struct {
        deleted_0100: bool = false,
        deleted_0101: bool = false,

        fn getBalance(_: *anyopaque, _: primitives.Address) u256 {
            return 0;
        }
        fn setBalance(_: *anyopaque, _: primitives.Address, _: u256) void {}
        fn getCode(_: *anyopaque, _: primitives.Address) []const u8 {
            return &.{};
        }
        fn setCode(_: *anyopaque, _: primitives.Address, _: []const u8) void {}
        fn getStorage(_: *anyopaque, _: primitives.Address, _: u256) u256 {
            return 0;
        }
        fn setStorage(_: *anyopaque, _: primitives.Address, _: u256, _: u256) void {}
        fn getNonce(_: *anyopaque, _: primitives.Address) u64 {
            return 0;
        }
        fn setNonce(_: *anyopaque, _: primitives.Address, _: u64) void {}
        fn deleteAccount(ptr: *anyopaque, addr: primitives.Address) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            if (addr.equals(evm.P256VERIFY_ADDRESS)) self.deleted_0100 = true;
            if (addr.equals(primitives.Address.fromU256(0x0101))) self.deleted_0101 = true;
        }
        fn accountExists(_: *anyopaque, _: primitives.Address) bool {
            return true;
        }
        fn interface(self: *@This()) host_mod.HostInterface {
            return .{
                .ptr = self,
                .vtable = &.{
                    .getBalance = getBalance,
                    .setBalance = setBalance,
                    .getCode = getCode,
                    .setCode = setCode,
                    .getStorage = getStorage,
                    .setStorage = setStorage,
                    .getNonce = getNonce,
                    .setNonce = setNonce,
                    .deleteAccount = deleteAccount,
                    .accountExists = accountExists,
                },
            };
        }
    };

    const addr_0101 = primitives.Address.fromU256(0x0101);

    // Osaka: 0x0100 is an active precompile. EELS `destroy_touched_empty_accounts` has no
    // precompile exemption, so its empty backing account is deleted like 0x0101.
    var osaka_host = RecordingHost{};
    var osaka_vm: Evm = undefined;
    try osaka_vm.init(testing.allocator, osaka_host.interface(), .OSAKA, null, primitives.ZERO_ADDRESS, 0, null);
    defer osaka_vm.deinit();
    const osaka_0100 = osaka_vm.call(.{ .call = .{
        .caller = osaka_vm.origin,
        .to = evm.P256VERIFY_ADDRESS,
        .gas = 10_000,
        .value = 0,
        .input = &.{},
    } });
    try testing.expect(osaka_0100.success);
    const osaka_0101 = osaka_vm.call(.{ .call = .{
        .caller = osaka_vm.origin,
        .to = addr_0101,
        .gas = 10_000,
        .value = 0,
        .input = &.{},
    } });
    try testing.expect(osaka_0101.success);
    try testing.expect(osaka_host.deleted_0100);
    try testing.expect(osaka_host.deleted_0101);

    // Prague: both 0x0100 and 0x0101 are empty non-precompile accounts and are deleted
    var prague_host = RecordingHost{};
    var prague_vm: Evm = undefined;
    try prague_vm.init(testing.allocator, prague_host.interface(), .PRAGUE, null, primitives.ZERO_ADDRESS, 0, null);
    defer prague_vm.deinit();
    const prague_0100 = prague_vm.call(.{ .call = .{
        .caller = prague_vm.origin,
        .to = evm.P256VERIFY_ADDRESS,
        .gas = 10_000,
        .value = 0,
        .input = &.{},
    } });
    try testing.expect(prague_0100.success);
    const prague_0101 = prague_vm.call(.{ .call = .{
        .caller = prague_vm.origin,
        .to = addr_0101,
        .gas = 10_000,
        .value = 0,
        .input = &.{},
    } });
    try testing.expect(prague_0101.success);
    try testing.expect(prague_host.deleted_0100);
    try testing.expect(prague_host.deleted_0101);
}

test "Salvage #854 - Evm.init on poisoned memory followed immediately by deinit is safe and leak-free" {
    const testing = std.testing;
    var vm: Evm = undefined;
    @memset(std.mem.asBytes(&vm), 0xAA);
    try vm.init(testing.allocator, null, .OSAKA, null, primitives.ZERO_ADDRESS, 0, null);
    defer vm.deinit();

    // Pre-call accessors and pre-state writes must observe valid empty containers (zero UB)
    try testing.expectEqual(@as(usize, 0), vm.frames.items.len);
    try testing.expectEqual(@as(usize, 0), vm.logs.items.len);
    try testing.expectEqual(@as(usize, 0), vm.storage.storage.count());
    try testing.expectEqual(@as(usize, 0), vm.getPendingStateChanges().len);
    try testing.expectEqual(@as(usize, 0), (try vm.dumpStateChanges()).len);

    const addr = primitives.Address.fromU256(0x4242);
    try vm.balances.put(addr, 1234);
    try vm.nonces.put(addr, 7);
    try vm.code.put(addr, &.{0x00});
    try vm.storage.set(addr, 1, 99);
    try testing.expectEqual(@as(u256, 1234), vm.get_balance(addr));
    try testing.expectEqual(@as(u64, 7), vm.getNonce(addr));
    try testing.expectEqual(@as(u256, 99), try vm.storage.get(addr, 1));
}

test "BUG_HUNT_REPORT #9 - dumpStateChanges preserves >20 KB JSON without truncation, leaks, or stale state" {
    const testing = std.testing;

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .OSAKA, null, primitives.ZERO_ADDRESS, 0, null);
    defer vm.deinit();

    // Use testing.allocator for injector to prove injector.dumpChanges() buffer is always freed
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    vm.pending_storage_injector = &injector;
    try vm.initTransactionState(null);

    const addr = primitives.Address.fromU256(0xBEEF);
    var slot: u256 = 0;
    while (slot < 220) : (slot += 1) {
        try vm.storage.set(addr, slot, slot + 1000);
        try injector.markStorageDirty(addr, slot);
    }

    const dump1 = try vm.dumpStateChanges();
    try testing.expect(dump1.len > 20 * 1024);
    try testing.expectEqualSlices(u8, dump1, vm.getPendingStateChanges());

    // Must be complete, valid JSON containing all 220 storage entries
    var parsed = try std.json.parseFromSlice(std.json.Value, testing.allocator, dump1, .{});
    defer parsed.deinit();
    try testing.expectEqual(@as(usize, 220), parsed.value.object.get("storage").?.array.items.len);

    // Second dump replaces first without leaking the prior allocation
    const dump2 = try vm.dumpStateChanges();
    try testing.expectEqual(dump1.len, dump2.len);

    // Allocation failure returns error.OutOfMemory and leaves pending_state_changes empty (never stale)
    var failing = std.testing.FailingAllocator.init(testing.allocator, .{ .fail_index = 0 });
    var oom_vm: Evm = undefined;
    try oom_vm.init(failing.allocator(), null, .OSAKA, null, primitives.ZERO_ADDRESS, 0, null);
    defer oom_vm.deinit();
    oom_vm.storage.storage_injector = &injector;
    try testing.expectError(error.OutOfMemory, oom_vm.dumpStateChanges());
    try testing.expectEqual(@as(usize, 0), oom_vm.getPendingStateChanges().len);

    // Clearing injector and re-dumping frees prior dump and returns empty slice
    vm.storage.storage_injector = null;
    const empty = try vm.dumpStateChanges();
    try testing.expectEqual(@as(usize, 0), empty.len);
    try testing.expectEqual(@as(usize, 0), vm.getPendingStateChanges().len);
}

test "BUG_HUNT_REPORT #9 - root_c AsyncRequest fast-path, >16 KB overflow, and C ABI lifecycle" {
    const testing = std.testing;

    // 1. Boundary unit checks on packStateChangesJson and copyStateChanges
    var req: root_c.AsyncRequest = undefined;
    @memset(&req.json_data, 0xCC);
    const exact_16k = [_]u8{'a'} ** root_c.ASYNC_JSON_INLINE_CAPACITY;
    try testing.expect(root_c.packStateChangesJson(&exact_16k, &req));
    try testing.expectEqual(@as(u8, 5), req.output_type);
    try testing.expectEqual(@as(u32, 16384), req.json_len);
    try testing.expectEqualSlices(u8, &exact_16k, &req.json_data);

    @memset(&req.json_data, 0xCC);
    const over_16k = [_]u8{'b'} ** (root_c.ASYNC_JSON_INLINE_CAPACITY + 1);
    try testing.expect(root_c.packStateChangesJson(&over_16k, &req));
    try testing.expectEqual(@as(u8, 5), req.output_type);
    try testing.expectEqual(@as(u32, 16385), req.json_len);
    try testing.expect(std.mem.allEqual(u8, &req.json_data, 0));

    // All-or-nothing copy semantics
    var dst = [_]u8{0x55} ** 12;
    try testing.expectEqual(@as(usize, 10), root_c.copyStateChanges("0123456789", null, 0));
    try testing.expectEqual(@as(usize, 10), root_c.copyStateChanges("0123456789", &dst, 9));
    try testing.expect(std.mem.allEqual(u8, &dst, 0x55));
    try testing.expectEqual(@as(usize, 10), root_c.copyStateChanges("0123456789", &dst, 10));
    try testing.expectEqualSlices(u8, "0123456789", dst[0..10]);
    try testing.expectEqual(@as(u8, 0x55), dst[10]);

    // 2. Full C ABI roundtrip including idempotent evm_enable_storage_injector & inline ready_to_commit
    const handle = root_c.evm_create("osaka", 5, 0) orelse return error.OutOfMemory;
    defer root_c.evm_destroy(handle);

    try testing.expectEqual(@as(usize, 0), root_c.evm_get_state_changes_len(handle));
    try testing.expect(root_c.evm_enable_storage_injector(handle));
    try testing.expect(root_c.evm_enable_storage_injector(handle)); // idempotent

    const stop_code = [_]u8{0x00};
    try testing.expect(root_c.evm_set_bytecode(handle, &stop_code, stop_code.len));
    const zero_addr = [_]u8{0} ** 20;
    const zero_word = [_]u8{0} ** 32;
    const target_addr = primitives.Address.fromU256(0x0200).bytes;
    try testing.expect(root_c.evm_set_execution_context(handle, 100_000, &zero_addr, &target_addr, &zero_word, &zero_word, 0));

    @memset(&req.json_data, 0xEE);
    try testing.expect(root_c.evm_call_ffi(handle, &req));
    try testing.expectEqual(@as(u8, 5), req.output_type);
    const expected_empty = "{\"storage\":[],\"balances\":[],\"nonces\":[],\"codes\":[],\"selfDestructs\":[]}";
    try testing.expectEqual(@as(u32, expected_empty.len), req.json_len);
    try testing.expectEqualSlices(u8, expected_empty, req.json_data[0..req.json_len]);
    try testing.expect(std.mem.allEqual(u8, req.json_data[req.json_len..], 0));
    try testing.expectEqual(expected_empty.len, root_c.evm_get_state_changes_len(handle));
    try testing.expectEqual(expected_empty.len, root_c.evm_get_state_changes(handle, null, 0));

    var out_buf: [128]u8 = [_]u8{0xAA} ** 128;
    try testing.expectEqual(expected_empty.len, root_c.evm_get_state_changes(handle, &out_buf, expected_empty.len - 1));
    try testing.expect(std.mem.allEqual(u8, &out_buf, 0xAA));
    try testing.expectEqual(expected_empty.len, root_c.evm_get_state_changes(handle, &out_buf, expected_empty.len));
    try testing.expectEqualSlices(u8, expected_empty, out_buf[0..expected_empty.len]);

    try testing.expect(root_c.evm_continue_ffi(handle, 5, &zero_word, 0, &req));
    try testing.expectEqual(@as(u8, 0), req.output_type);
}

// ============================================================================
// Round 1 fix regressions (FX1): checkpointed rollback for call / inner_call /
// inner_create, call-depth frame safety, pre-state preservation, signed refunds,
// EIP-7702 delegation helpers, EIP-7610 collisions and precompile gas bounds.
// ============================================================================

const evm_config_mod = @import("evm_config.zig");

const r1_caller = primitives.Address{ .bytes = [_]u8{0xca} ** 20 };
const r1_contract = primitives.Address{ .bytes = [_]u8{0xc0} ** 20 };
const r1_other = primitives.Address{ .bytes = [_]u8{0xb0} ** 20 };
const r1_empty = primitives.Address{ .bytes = [_]u8{0xe0} ** 20 };

fn r1Slot(vm: anytype, addr: primitives.Address, slot: u256) u256 {
    return vm.storage.storage.get(.{ .address = addr.bytes, .slot = slot }) orelse 0;
}

fn r1Balance(vm: anytype, addr: primitives.Address) u256 {
    return vm.balances.get(addr) orelse 0;
}

fn r1Word(output: []const u8) !u256 {
    try std.testing.expectEqual(@as(usize, 32), output.len);
    return std.mem.readInt(u256, output[0..32], .big);
}

/// Minimal in-memory host: records deletions so EIP-161 cleanup is observable.
const R1Host = struct {
    arena: std.heap.ArenaAllocator,
    balances: std.AutoHashMap(primitives.Address, u256),
    nonces: std.AutoHashMap(primitives.Address, u64),
    code: std.AutoHashMap(primitives.Address, []const u8),
    storage: std.AutoHashMap(evm.StorageKey, u256),
    existing: std.AutoHashMap(primitives.Address, void),
    deleted: std.AutoHashMap(primitives.Address, void),

    fn init(self: *R1Host, allocator: std.mem.Allocator) void {
        self.arena = std.heap.ArenaAllocator.init(allocator);
        const a = self.arena.allocator();
        self.balances = std.AutoHashMap(primitives.Address, u256).init(a);
        self.nonces = std.AutoHashMap(primitives.Address, u64).init(a);
        self.code = std.AutoHashMap(primitives.Address, []const u8).init(a);
        self.storage = std.AutoHashMap(evm.StorageKey, u256).init(a);
        self.existing = std.AutoHashMap(primitives.Address, void).init(a);
        self.deleted = std.AutoHashMap(primitives.Address, void).init(a);
    }

    fn deinit(self: *R1Host) void {
        self.arena.deinit();
    }

    fn cast(ptr: *anyopaque) *R1Host {
        return @ptrCast(@alignCast(ptr));
    }

    fn getBalance(ptr: *anyopaque, addr: primitives.Address) u256 {
        return cast(ptr).balances.get(addr) orelse 0;
    }
    fn setBalance(ptr: *anyopaque, addr: primitives.Address, balance: u256) void {
        cast(ptr).balances.put(addr, balance) catch @panic("R1Host out of memory");
    }
    fn getCode(ptr: *anyopaque, addr: primitives.Address) []const u8 {
        return cast(ptr).code.get(addr) orelse &.{};
    }
    fn setCode(ptr: *anyopaque, addr: primitives.Address, bytes: []const u8) void {
        const self = cast(ptr);
        if (bytes.len == 0) {
            _ = self.code.remove(addr);
            return;
        }
        const owned = self.arena.allocator().dupe(u8, bytes) catch @panic("R1Host out of memory");
        self.code.put(addr, owned) catch @panic("R1Host out of memory");
    }
    fn getStorage(ptr: *anyopaque, addr: primitives.Address, slot: u256) u256 {
        return cast(ptr).storage.get(.{ .address = addr.bytes, .slot = slot }) orelse 0;
    }
    fn setStorage(ptr: *anyopaque, addr: primitives.Address, slot: u256, value: u256) void {
        const self = cast(ptr);
        const key = evm.StorageKey{ .address = addr.bytes, .slot = slot };
        if (value == 0) {
            _ = self.storage.remove(key);
        } else {
            self.storage.put(key, value) catch @panic("R1Host out of memory");
        }
    }
    fn getNonce(ptr: *anyopaque, addr: primitives.Address) u64 {
        return cast(ptr).nonces.get(addr) orelse 0;
    }
    fn setNonce(ptr: *anyopaque, addr: primitives.Address, nonce: u64) void {
        cast(ptr).nonces.put(addr, nonce) catch @panic("R1Host out of memory");
    }
    fn accountExists(ptr: *anyopaque, addr: primitives.Address) bool {
        const self = cast(ptr);
        return self.existing.contains(addr) or getBalance(ptr, addr) != 0 or getNonce(ptr, addr) != 0 or getCode(ptr, addr).len != 0;
    }
    fn accountHasStorage(ptr: *anyopaque, addr: primitives.Address) bool {
        var it = cast(ptr).storage.keyIterator();
        while (it.next()) |key| {
            if (std.mem.eql(u8, &key.address, &addr.bytes)) return true;
        }
        return false;
    }
    fn deleteAccount(ptr: *anyopaque, addr: primitives.Address) void {
        const self = cast(ptr);
        self.deleted.put(addr, {}) catch @panic("R1Host out of memory");
        _ = self.balances.remove(addr);
        _ = self.nonces.remove(addr);
        _ = self.code.remove(addr);
        _ = self.existing.remove(addr);
    }

    const vtable = host_mod.HostInterface.VTable{
        .getBalance = getBalance,
        .setBalance = setBalance,
        .getCode = getCode,
        .setCode = setCode,
        .getStorage = getStorage,
        .setStorage = setStorage,
        .getNonce = getNonce,
        .setNonce = setNonce,
        .accountExists = accountExists,
        .accountHasStorage = accountHasStorage,
        .deleteAccount = deleteAccount,
    };

    fn interface(self: *R1Host) host_mod.HostInterface {
        return .{ .ptr = self, .vtable = &vtable };
    }
};

// ---- Call depth (F-03 / C-25) ----------------------------------------------

test "R1 depth: recursion stops at depth 1024 and the frame list never reallocates" {
    const testing = std.testing;

    // slot0 += 1; CALL(GAS, ADDRESS, 0, 0, 0, 0, 0); STOP
    const recursive = [_]u8{
        0x60, 0x00, 0x54, 0x60, 0x01, 0x01, 0x60, 0x00, 0x55,
        0x60, 0x00, 0x60, 0x00, 0x60, 0x00, 0x60, 0x00, 0x60,
        0x00, 0x30, 0x5a, 0xf1, 0x00,
    };

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .BERLIN, null, r1_caller, 0, null);
    defer vm.deinit();
    try vm.code.put(r1_contract, &recursive);

    // Enough gas that the 63/64 rule still leaves the SSTORE stipend at depth 1024.
    const result = vm.call(.{ .call = .{
        .caller = r1_caller,
        .to = r1_contract,
        .value = 0,
        .input = &.{},
        .gas = 10_000_000_000_000,
    } });
    try testing.expect(result.success);

    // Depth 0 plus nested depths 1..1024 executed: 1025 frames. The 1026th was refused.
    try testing.expectEqual(@as(u256, Evm.max_frames), r1Slot(&vm, r1_contract, 0));
    try testing.expectEqual(@as(usize, 1025), Evm.max_frames);
    // A reallocation would have grown capacity past the exact reservation.
    try testing.expectEqual(Evm.max_frames, vm.frames.capacity);
    try testing.expectEqual(@as(usize, 0), vm.frames.items.len);
}

test "R1 depth: inner_call and inner_create refuse a full frame list before pushing" {
    const testing = std.testing;

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .BERLIN, null, r1_caller, 0, null);
    defer vm.deinit();
    try vm.initTransactionState(null);
    try testing.expectEqual(Evm.max_frames, vm.frames.capacity);

    const stop = [_]u8{0x00};
    try vm.code.put(r1_other, &stop);
    try vm.balances.put(r1_contract, 1_000);

    while (vm.frames.items.len < Evm.max_frames) {
        vm.frames.appendAssumeCapacity(try @typeInfo(@TypeOf(vm.frames.items)).pointer.child.init(
            vm.tx_arena.allocator(),
            &stop,
            1_000_000,
            r1_caller,
            r1_contract,
            0,
            &.{},
            @as(*anyopaque, @ptrCast(&vm)),
            .BERLIN,
            false,
        ));
    }
    const frames_ptr = vm.frames.items.ptr;

    const call_result = vm.inner_call(.{ .call = .{
        .caller = r1_contract,
        .to = r1_other,
        .value = 1,
        .input = &.{},
        .gas = 50_000,
    } });
    try testing.expect(!call_result.success);
    try testing.expectEqual(@as(u64, 50_000), call_result.gas_left); // gas returned
    try testing.expectEqual(@as(u256, 1_000), r1Balance(&vm, r1_contract)); // no transfer

    const create_result = try vm.inner_create(1, &stop, 50_000, null);
    try testing.expect(!create_result.success);
    try testing.expectEqual(@as(u64, 50_000), create_result.gas_left);
    try testing.expectEqual(@as(u64, 0), vm.nonces.get(r1_contract) orelse 0); // nonce untouched

    try testing.expectEqual(Evm.max_frames, vm.frames.items.len);
    try testing.expectEqual(Evm.max_frames, vm.frames.capacity);
    try testing.expect(frames_ptr == vm.frames.items.ptr);
}

// ---- inner_create rollback (F-04 / C-04 / C-08 / C-09 / R1-002) -------------

/// Side effects every init-code variant performs before its terminating `tail`:
/// SSTORE(0,1); SSTORE(2,1); SSTORE(2,0) (earns a refund); TSTORE(1,9); LOG0;
/// CALL(r1_other), whose code does SSTORE(0,7); LOG0.
const r1_init_effects = [_]u8{
    0x60, 0x01, 0x60, 0x00, 0x55,
    0x60, 0x01, 0x60, 0x02, 0x55,
    0x60, 0x00, 0x60, 0x02, 0x55,
    0x60, 0x09, 0x60, 0x01, 0x5d,
    0x60, 0x00, 0x60, 0x00, 0xa0,
    0x60, 0x00, 0x60, 0x00, 0x60,
    0x00, 0x60, 0x00, 0x60, 0x00,
    0x73,
} ++ r1_other.bytes ++ [_]u8{ 0x61, 0xff, 0xff, 0xf1, 0x50 };

const r1_callee_effects = [_]u8{ 0x60, 0x07, 0x60, 0x00, 0x55, 0x60, 0x00, 0x60, 0x00, 0xa0, 0x00 };

const R1CreateCase = struct {
    vm: Evm,
    new_address: primitives.Address,
    result: Evm.CreateResult,
};

/// Run a creation transaction (depth 0) whose init code is `r1_init_effects ++ tail`,
/// sending 5 wei to a destination that already holds 100 wei.
fn r1RunCreate(case: *R1CreateCase, hardfork: primitives.Hardfork, comptime tail: anytype, gas: u64) !void {
    const init_code = r1_init_effects ++ tail;
    try case.vm.init(std.testing.allocator, null, hardfork, null, r1_caller, 0, null);
    errdefer case.vm.deinit();
    const vm = &case.vm;
    try vm.initTransactionState(null);

    try vm.code.put(r1_other, &r1_callee_effects);
    try vm.balances.put(r1_caller, 1_000);
    // The transaction processor has already incremented the sender nonce (0 -> 1).
    try vm.nonces.put(r1_caller, 1);
    case.new_address = try vm.computeCreateAddress(r1_caller, 0);
    try vm.balances.put(case.new_address, 100);

    case.result = try vm.inner_create(5, &init_code, gas, null);
}

fn r1ExpectCreateRolledBack(case: *R1CreateCase) !void {
    const testing = std.testing;
    const vm = &case.vm;
    const new_address = case.new_address;

    try testing.expect(!case.result.success);
    try testing.expect(case.result.address.equals(primitives.ZERO_ADDRESS));

    // No deployed code, account, storage or endowment at the destination.
    try testing.expectEqual(@as(usize, 0), vm.get_raw_code(new_address).len);
    try testing.expectEqual(@as(u64, 0), vm.getNonce(new_address));
    try testing.expectEqual(@as(u256, 0), r1Slot(vm, new_address, 0));
    try testing.expectEqual(@as(u256, 0), r1Slot(vm, new_address, 2));
    try testing.expect(!vm.accountHasStorage(new_address));
    try testing.expect(!vm.created_accounts.contains(new_address));
    // Pre-existing ETH survives; the endowment went back to the creator.
    try testing.expectEqual(@as(u256, 100), r1Balance(vm, new_address));
    try testing.expectEqual(@as(u256, 1_000), r1Balance(vm, r1_caller));

    // Effects of the nested call made by init code are undone too.
    try testing.expectEqual(@as(u256, 0), r1Slot(vm, r1_other, 0));
    try testing.expectEqual(@as(usize, 0), vm.logs.items.len);
    try testing.expectEqual(@as(usize, 0), vm.storage.transient.count());
    try testing.expectEqual(@as(usize, 0), vm.storage.original_storage.count());
    try testing.expectEqual(@as(i64, 0), vm.gas_refund);
    try testing.expectEqual(@as(usize, 0), vm.touched_accounts.count());
    try testing.expectEqual(@as(usize, 0), vm.selfdestructed_accounts.count());

    // Warm set: the new address stays warm (EIP-2929), the nested callee does not.
    try testing.expect(vm.access_list_manager.is_address_warm(new_address));
    try testing.expect(!vm.access_list_manager.is_address_warm(r1_other));

    // The creator nonce is owned by the transaction processor at depth 0.
    try testing.expectEqual(@as(u64, 1), vm.getNonce(r1_caller));
    try testing.expectEqual(@as(usize, 0), vm.frames.items.len);
}

test "R1 create: successful creation keeps init-code effects (control)" {
    const testing = std.testing;
    var case: R1CreateCase = undefined;
    // RETURN(0, 1): deploys a single 0x00 byte.
    try r1RunCreate(&case, .CANCUN, [_]u8{ 0x60, 0x01, 0x60, 0x00, 0xf3 }, 300_000);
    defer case.vm.deinit();
    const vm = &case.vm;

    try testing.expect(case.result.success);
    try testing.expect(case.result.address.equals(case.new_address));
    try testing.expectEqual(@as(usize, 0), case.result.output.len);
    try testing.expectEqualSlices(u8, &[_]u8{0x00}, vm.get_raw_code(case.new_address));
    try testing.expectEqual(@as(u64, 1), vm.getNonce(case.new_address));
    try testing.expectEqual(@as(u256, 105), r1Balance(vm, case.new_address));
    try testing.expectEqual(@as(u256, 995), r1Balance(vm, r1_caller));
    try testing.expectEqual(@as(u256, 1), r1Slot(vm, case.new_address, 0));
    try testing.expectEqual(@as(u256, 7), r1Slot(vm, r1_other, 0));
    try testing.expectEqual(@as(usize, 2), vm.logs.items.len);
    try testing.expect(vm.gas_refund > 0);
    try testing.expect(vm.created_accounts.contains(case.new_address));
    try testing.expect(vm.access_list_manager.is_address_warm(r1_other));
}

test "R1 create: REVERT in init code rolls back everything and returns only revert data" {
    const testing = std.testing;
    var case: R1CreateCase = undefined;
    // REVERT(0, 1)
    try r1RunCreate(&case, .CANCUN, [_]u8{ 0x60, 0x01, 0x60, 0x00, 0xfd }, 300_000);
    defer case.vm.deinit();

    try r1ExpectCreateRolledBack(&case);
    try testing.expectEqual(@as(usize, 1), case.result.output.len);
    try testing.expect(case.result.gas_left > 0); // REVERT returns unused gas
}

test "R1 create: exceptional halt in init code rolls back everything with empty output" {
    const testing = std.testing;
    var case: R1CreateCase = undefined;
    try r1RunCreate(&case, .CANCUN, [_]u8{0xfe}, 300_000); // INVALID
    defer case.vm.deinit();

    try r1ExpectCreateRolledBack(&case);
    try testing.expectEqual(@as(usize, 0), case.result.output.len);
    try testing.expectEqual(@as(u64, 0), case.result.gas_left);
}

test "R1 create: code-deposit out-of-gas rolls back everything (Homestead+)" {
    const testing = std.testing;
    var case: R1CreateCase = undefined;
    // RETURN(0, 0x1000): 4096 bytes cost 819,200 deposit gas, more than is left.
    try r1RunCreate(&case, .CANCUN, [_]u8{ 0x61, 0x10, 0x00, 0x60, 0x00, 0xf3 }, 300_000);
    defer case.vm.deinit();

    try r1ExpectCreateRolledBack(&case);
    try testing.expectEqual(@as(usize, 0), case.result.output.len);
    try testing.expectEqual(@as(u64, 0), case.result.gas_left);
}

test "R1 create: EIP-3541 0xEF prefix rolls back everything with empty output" {
    const testing = std.testing;
    var case: R1CreateCase = undefined;
    // MSTORE8(0, 0xEF); RETURN(0, 1)
    try r1RunCreate(&case, .CANCUN, [_]u8{ 0x60, 0xef, 0x60, 0x00, 0x53, 0x60, 0x01, 0x60, 0x00, 0xf3 }, 300_000);
    defer case.vm.deinit();

    try r1ExpectCreateRolledBack(&case);
    try testing.expectEqual(@as(usize, 0), case.result.output.len);
    try testing.expectEqual(@as(u64, 0), case.result.gas_left);
}

test "R1 create: EIP-170 oversize code rolls back everything with empty output" {
    const testing = std.testing;
    var case: R1CreateCase = undefined;
    // RETURN(0, 24577): one byte over the limit, with ample gas for the deposit.
    try r1RunCreate(&case, .CANCUN, [_]u8{ 0x61, 0x60, 0x01, 0x60, 0x00, 0xf3 }, 10_000_000);
    defer case.vm.deinit();

    try r1ExpectCreateRolledBack(&case);
    try testing.expectEqual(@as(usize, 0), case.result.output.len);
    try testing.expectEqual(@as(u64, 0), case.result.gas_left);
}

test "R1 create: Frontier keeps the account with empty code on deposit out-of-gas; Homestead fails" {
    const testing = std.testing;
    // RETURN(0, 100): deposit costs 20,000 gas; only 1,000 is supplied.
    const init_code = [_]u8{ 0x60, 0x64, 0x60, 0x00, 0xf3 };

    inline for (.{ primitives.Hardfork.FRONTIER, primitives.Hardfork.HOMESTEAD }) |fork| {
        var vm: Evm = undefined;
        try vm.init(testing.allocator, null, fork, null, r1_caller, 0, null);
        defer vm.deinit();
        try vm.initTransactionState(null);
        try vm.balances.put(r1_caller, 10);
        try vm.nonces.put(r1_caller, 1);
        const new_address = try vm.computeCreateAddress(r1_caller, 0);

        const result = try vm.inner_create(3, &init_code, 1_000, null);
        try testing.expectEqual(@as(usize, 0), vm.get_raw_code(new_address).len);
        try testing.expectEqual(@as(usize, 0), result.output.len);
        // Before Spurious Dragon (EIP-161) a new contract starts at nonce 0.
        try testing.expectEqual(@as(u64, 0), vm.getNonce(new_address));
        if (fork == .FRONTIER) {
            try testing.expect(result.success);
            try testing.expect(result.address.equals(new_address));
            try testing.expect(result.gas_left > 0 and result.gas_left < 1_000); // deposit not charged
            try testing.expectEqual(@as(u256, 3), r1Balance(&vm, new_address));
        } else {
            try testing.expect(!result.success);
            try testing.expectEqual(@as(u64, 0), result.gas_left);
            try testing.expectEqual(@as(u256, 0), r1Balance(&vm, new_address));
            try testing.expectEqual(@as(u256, 10), r1Balance(&vm, r1_caller));
        }
    }
}

test "R1 create: collision on nonce, code or storage (EIP-7610) keeps pre-existing ETH" {
    const testing = std.testing;
    const stop = [_]u8{0x00};
    const Kind = enum { nonce, code, storage };

    inline for (.{ Kind.nonce, Kind.code, Kind.storage }) |kind| {
        var vm: Evm = undefined;
        try vm.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
        defer vm.deinit();
        try vm.initTransactionState(null);
        try vm.balances.put(r1_caller, 1_000);
        try vm.nonces.put(r1_caller, 1);
        const new_address = try vm.computeCreateAddress(r1_caller, 0);
        try vm.balances.put(new_address, 777);
        switch (kind) {
            .nonce => try vm.nonces.put(new_address, 1),
            .code => try vm.code.put(new_address, &stop),
            .storage => try vm.storage.storage.put(.{ .address = new_address.bytes, .slot = 9 }, 1),
        }

        const result = try vm.inner_create(5, &stop, 100_000, null);
        try testing.expect(!result.success);
        try testing.expectEqual(@as(u64, 0), result.gas_left); // collision consumes all gas
        try testing.expectEqual(@as(usize, 0), result.output.len);
        try testing.expectEqual(@as(u256, 777), r1Balance(&vm, new_address));
        try testing.expectEqual(@as(u256, 1_000), r1Balance(&vm, r1_caller));
        try testing.expectEqual(@as(u256, if (kind == .storage) 1 else 0), r1Slot(&vm, new_address, 9));
        try testing.expectEqual(@as(u64, if (kind == .nonce) 1 else 0), vm.getNonce(new_address));
    }
}

test "R1 create: EIP-3860 oversize init code halts before the balance check" {
    const testing = std.testing;
    const oversize = [_]u8{0x00} ** 49153;

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .SHANGHAI, null, r1_caller, 0, null);
    defer vm.deinit();
    try vm.initTransactionState(null);

    // The creator cannot afford the endowment, yet the size check must win.
    try testing.expectError(error.OutOfGas, vm.inner_create(1, &oversize, 1_000_000, null));
    // At the limit the balance check applies: fail softly and return the gas.
    const at_limit = try vm.inner_create(1, oversize[0..49152], 1_000_000, null);
    try testing.expect(!at_limit.success);
    try testing.expectEqual(@as(u64, 1_000_000), at_limit.gas_left);

    // Before Shanghai there is no init code limit.
    var london: Evm = undefined;
    try london.init(testing.allocator, null, .LONDON, null, r1_caller, 0, null);
    defer london.deinit();
    try london.initTransactionState(null);
    const pre_shanghai = try london.inner_create(0, &oversize, 1_000_000, null);
    try testing.expect(pre_shanghai.success);
}

test "R1 create: Evm.call(.create) derives one address from params.caller and deploys there" {
    const testing = std.testing;
    // RETURN(0, 1)
    const init_code = [_]u8{ 0x60, 0x01, 0x60, 0x00, 0xf3 };

    var vm: Evm = undefined;
    // `origin` differs from the creator on purpose.
    try vm.init(testing.allocator, null, .CANCUN, null, r1_other, 0, null);
    defer vm.deinit();
    try vm.balances.put(r1_caller, 50);
    try vm.nonces.put(r1_caller, 5); // already incremented by the transaction processor
    const expected = try vm.computeCreateAddress(r1_caller, 4);

    const result = vm.call(.{ .create = .{
        .caller = r1_caller,
        .value = 7,
        .init_code = &init_code,
        .gas = 200_000,
    } });
    try testing.expect(result.success);
    try testing.expect(result.created_address.?.equals(expected));
    try testing.expectEqualSlices(u8, &[_]u8{0x00}, vm.get_raw_code(expected));
    try testing.expectEqual(@as(u256, 7), r1Balance(&vm, expected));
    try testing.expectEqual(@as(u256, 43), r1Balance(&vm, r1_caller));
    try testing.expectEqual(@as(u64, 5), vm.getNonce(r1_caller));
}

// ---- Top-level call(): rollback, pre-state, per-call inputs (F-07 / C-10 / C-14 / C-16) ----

test "R1 call: REVERT and exceptional halt roll back storage, logs and the value transfer" {
    const testing = std.testing;
    // SSTORE(0,1); LOG0(0,0); <tail>
    const effects = [_]u8{ 0x60, 0x01, 0x60, 0x00, 0x55, 0x60, 0x00, 0x60, 0x00, 0xa0 };
    const reverting = effects ++ [_]u8{ 0x60, 0x01, 0x60, 0x00, 0xfd }; // REVERT(0,1)
    const halting = effects ++ [_]u8{0xfe}; // INVALID
    const committing = effects ++ [_]u8{0x00}; // STOP

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
    defer vm.deinit();
    try vm.balances.put(r1_caller, 100);
    try vm.storage.storage.put(.{ .address = r1_contract.bytes, .slot = 5 }, 42);

    try vm.code.put(r1_contract, &reverting);
    const reverted = vm.call(.{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 10, .input = &.{}, .gas = 100_000 } });
    try testing.expect(!reverted.success);
    try testing.expectEqual(@as(usize, 1), reverted.output.len);
    try testing.expect(reverted.gas_left > 0);
    try testing.expectEqual(@as(usize, 0), reverted.logs.len);
    try testing.expectEqual(@as(u64, 0), reverted.refund_counter);
    try testing.expectEqual(@as(u256, 0), r1Slot(&vm, r1_contract, 0));
    try testing.expectEqual(@as(u256, 42), r1Slot(&vm, r1_contract, 5));
    try testing.expectEqual(@as(u256, 100), r1Balance(&vm, r1_caller));
    try testing.expectEqual(@as(u256, 0), r1Balance(&vm, r1_contract));

    try vm.code.put(r1_contract, &halting);
    const halted = vm.call(.{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 10, .input = &.{}, .gas = 100_000 } });
    try testing.expect(!halted.success);
    try testing.expectEqual(@as(u64, 0), halted.gas_left);
    try testing.expectEqual(@as(usize, 0), halted.output.len);
    try testing.expectEqual(@as(u256, 0), r1Slot(&vm, r1_contract, 0));
    try testing.expectEqual(@as(u256, 100), r1Balance(&vm, r1_caller));
    try testing.expectEqual(@as(u256, 0), r1Balance(&vm, r1_contract));

    try vm.code.put(r1_contract, &committing);
    const committed = vm.call(.{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 10, .input = &.{}, .gas = 100_000 } });
    try testing.expect(committed.success);
    try testing.expectEqual(@as(usize, 1), committed.logs.len);
    try testing.expectEqual(@as(u256, 1), r1Slot(&vm, r1_contract, 0));
    try testing.expectEqual(@as(u256, 90), r1Balance(&vm, r1_caller));
    try testing.expectEqual(@as(u256, 10), r1Balance(&vm, r1_contract));
}

test "R1 call: a reverted self-transfer does not burn ETH (hostless and host-backed)" {
    const testing = std.testing;
    const reverting = [_]u8{ 0x60, 0x00, 0x60, 0x00, 0xfd }; // REVERT(0,0)
    const stop = [_]u8{0x00};
    const self_call: Evm.CallParams = .{ .call = .{ .caller = r1_contract, .to = r1_contract, .value = 10, .input = &.{}, .gas = 100_000 } };

    // Hostless
    {
        var vm: Evm = undefined;
        try vm.init(testing.allocator, null, .CANCUN, null, r1_contract, 0, null);
        defer vm.deinit();
        try vm.balances.put(r1_contract, 100);

        try vm.code.put(r1_contract, &reverting);
        try testing.expect(!vm.call(self_call).success);
        try testing.expectEqual(@as(u256, 100), r1Balance(&vm, r1_contract));

        try vm.code.put(r1_contract, &stop);
        try testing.expect(vm.call(self_call).success);
        try testing.expectEqual(@as(u256, 100), r1Balance(&vm, r1_contract));
    }

    // Host-backed
    {
        var backing: R1Host = undefined;
        backing.init(testing.allocator);
        defer backing.deinit();
        try backing.balances.put(r1_contract, 100);
        try backing.code.put(r1_contract, &reverting);

        var vm: Evm = undefined;
        try vm.init(testing.allocator, backing.interface(), .CANCUN, null, r1_contract, 0, null);
        defer vm.deinit();

        try testing.expect(!vm.call(self_call).success);
        try testing.expectEqual(@as(u256, 100), backing.balances.get(r1_contract).?);

        try backing.code.put(r1_contract, &stop);
        try testing.expect(vm.call(self_call).success);
        try testing.expectEqual(@as(u256, 100), backing.balances.get(r1_contract).?);
    }
}

test "R1 call: host-backed top-level revert restores host storage and balances" {
    const testing = std.testing;
    // SSTORE(0,1); SSTORE(5,0) (clears a pre-existing slot); REVERT(0,0)
    const reverting = [_]u8{ 0x60, 0x01, 0x60, 0x00, 0x55, 0x60, 0x00, 0x60, 0x05, 0x55, 0x60, 0x00, 0x60, 0x00, 0xfd };

    var backing: R1Host = undefined;
    backing.init(testing.allocator);
    defer backing.deinit();
    try backing.balances.put(r1_caller, 100);
    try backing.code.put(r1_contract, &reverting);
    try backing.storage.put(.{ .address = r1_contract.bytes, .slot = 5 }, 42);

    var vm: Evm = undefined;
    try vm.init(testing.allocator, backing.interface(), .CANCUN, null, r1_caller, 0, null);
    defer vm.deinit();

    const result = vm.call(.{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 10, .input = &.{}, .gas = 100_000 } });
    try testing.expect(!result.success);
    try testing.expectEqual(@as(?u256, null), backing.storage.get(.{ .address = r1_contract.bytes, .slot = 0 }));
    try testing.expectEqual(@as(?u256, 42), backing.storage.get(.{ .address = r1_contract.bytes, .slot = 5 }));
    try testing.expectEqual(@as(u256, 100), backing.balances.get(r1_caller).?);
    try testing.expectEqual(@as(u256, 0), backing.balances.get(r1_contract) orelse 0);
    try testing.expectEqual(@as(i64, 0), vm.gas_refund);
}

test "R1 call: hostless value transfer is checked and applied" {
    const testing = std.testing;
    const stop = [_]u8{0x00};

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
    defer vm.deinit();
    try vm.code.put(r1_contract, &stop);

    // An unfunded caller cannot present a positive CALLVALUE.
    const unfunded = vm.call(.{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 1, .input = &.{}, .gas = 50_000 } });
    try testing.expect(!unfunded.success);
    try testing.expectEqual(@as(u256, 0), r1Balance(&vm, r1_contract));

    try vm.balances.put(r1_caller, 5);
    const funded = vm.call(.{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 5, .input = &.{}, .gas = 50_000 } });
    try testing.expect(funded.success);
    try testing.expectEqual(@as(u256, 0), r1Balance(&vm, r1_caller));
    try testing.expectEqual(@as(u256, 5), r1Balance(&vm, r1_contract));
}

test "R1 call: pre-installed state survives transactions and committed writes persist" {
    const testing = std.testing;
    // RETURN(SLOAD(5)) as one word
    const read_slot5 = [_]u8{ 0x60, 0x05, 0x54, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
    // SSTORE(1, 0xAA); STOP
    const write_slot1 = [_]u8{ 0x60, 0xaa, 0x60, 0x01, 0x55, 0x00 };
    // RETURN(SLOAD(1)) as one word
    const read_slot1 = [_]u8{ 0x60, 0x01, 0x54, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
    // RETURN(SELFBALANCE + EXTCODESIZE(r1_other)) as one word
    const read_accounts = [_]u8{ 0x47, 0x73 } ++ r1_other.bytes ++ [_]u8{ 0x3b, 0x01, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
    defer vm.deinit();

    // Pre-state installed the way the C API setters do, before any call.
    try vm.balances.put(r1_contract, 77);
    try vm.nonces.put(r1_caller, 3);
    try vm.code.put(r1_other, &[_]u8{ 0x00, 0x00, 0x00 });
    try vm.storage.storage.put(.{ .address = r1_contract.bytes, .slot = 5 }, 42);

    const call_contract: Evm.CallParams = .{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 0, .input = &.{}, .gas = 100_000 } };

    try vm.code.put(r1_contract, &read_slot5);
    const seeded = vm.call(call_contract);
    try testing.expect(seeded.success);
    try testing.expectEqual(@as(u256, 42), try r1Word(seeded.output));

    try vm.code.put(r1_contract, &read_accounts);
    const accounts = vm.call(call_contract);
    try testing.expect(accounts.success);
    try testing.expectEqual(@as(u256, 77 + 3), try r1Word(accounts.output));

    try vm.code.put(r1_contract, &write_slot1);
    try testing.expect(vm.call(call_contract).success);
    try vm.code.put(r1_contract, &read_slot1);
    const persisted = vm.call(call_contract);
    try testing.expectEqual(@as(u256, 0xaa), try r1Word(persisted.output));

    // Nothing installed up front was lost across four transactions.
    try testing.expectEqual(@as(u256, 77), r1Balance(&vm, r1_contract));
    try testing.expectEqual(@as(u64, 3), vm.getNonce(r1_caller));
    try testing.expectEqual(@as(usize, 3), vm.get_raw_code(r1_other).len);
    try testing.expectEqual(@as(u256, 42), r1Slot(&vm, r1_contract, 5));
}

test "R1 call: gas_refund resets at the start of every transaction" {
    const testing = std.testing;
    // SSTORE(0,1); SSTORE(0,0); STOP  -> refund 19,900 (EIP-3529)
    const set_then_clear = [_]u8{ 0x60, 0x01, 0x60, 0x00, 0x55, 0x60, 0x00, 0x60, 0x00, 0x55, 0x00 };
    const stop = [_]u8{0x00};

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
    defer vm.deinit();
    const call_contract: Evm.CallParams = .{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 0, .input = &.{}, .gas = 100_000 } };

    try vm.code.put(r1_contract, &set_then_clear);
    const first = vm.call(call_contract);
    try testing.expect(first.success);
    try testing.expectEqual(@as(u64, 19_900), first.refund_counter);
    try testing.expectEqual(@as(i64, 19_900), vm.gas_refund); // readable after the call

    const second = vm.call(call_contract);
    try testing.expectEqual(@as(u64, 19_900), second.refund_counter); // not 39,800
    try testing.expectEqual(@as(i64, 19_900), vm.gas_refund);

    try vm.code.put(r1_contract, &stop);
    const third = vm.call(call_contract);
    try testing.expect(third.success);
    try testing.expectEqual(@as(u64, 0), third.refund_counter);
    try testing.expectEqual(@as(i64, 0), vm.gas_refund);

    // initTransactionState alone resets it too (creation transactions enter that way).
    vm.add_refund(123);
    try vm.initTransactionState(null);
    try testing.expectEqual(@as(i64, 0), vm.gas_refund);
}

test "R1 refund: add_refund / sub_refund form a signed, saturating counter" {
    const testing = std.testing;

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
    defer vm.deinit();

    vm.add_refund(100);
    vm.sub_refund(250);
    try testing.expectEqual(@as(i64, -150), vm.gas_refund);
    try testing.expectEqual(@as(u64, 0), vm.get_effective_refund()); // negative reads as zero

    vm.add_refund(200);
    try testing.expectEqual(@as(i64, 50), vm.gas_refund);
    try testing.expectEqual(@as(u64, 50), vm.get_effective_refund());

    vm.add_refund(std.math.maxInt(u64));
    vm.add_refund(std.math.maxInt(u64));
    try testing.expectEqual(@as(i64, std.math.maxInt(i64)), vm.gas_refund);
    try testing.expectEqual(@as(u64, std.math.maxInt(i64)), vm.get_effective_refund());

    vm.sub_refund(std.math.maxInt(u64));
    vm.sub_refund(std.math.maxInt(u64));
    vm.sub_refund(std.math.maxInt(u64));
    try testing.expectEqual(@as(i64, std.math.minInt(i64)), vm.gas_refund);
    try testing.expectEqual(@as(u64, 0), vm.get_effective_refund());
}

test "R1 call: top-level STATICCALL is read-only" {
    const testing = std.testing;
    const writes = [_]u8{ 0x60, 0x01, 0x60, 0x00, 0x55, 0x00 }; // SSTORE(0,1); STOP
    const reads = [_]u8{ 0x60, 0x05, 0x54, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
    defer vm.deinit();
    try vm.storage.storage.put(.{ .address = r1_contract.bytes, .slot = 5 }, 42);

    try vm.code.put(r1_contract, &writes);
    const denied = vm.call(.{ .staticcall = .{ .caller = r1_caller, .to = r1_contract, .input = &.{}, .gas = 100_000 } });
    try testing.expect(!denied.success);
    try testing.expectEqual(@as(u256, 0), r1Slot(&vm, r1_contract, 0));

    try vm.code.put(r1_contract, &reads);
    const allowed = vm.call(.{ .staticcall = .{ .caller = r1_caller, .to = r1_contract, .input = &.{}, .gas = 100_000 } });
    try testing.expect(allowed.success);
    try testing.expectEqual(@as(u256, 42), try r1Word(allowed.output));
}

test "R1 call: setBytecode, setAccessList and blob hashes apply to one call only" {
    const testing = std.testing;
    // RETURN(42) as one word
    const return_42 = [_]u8{ 0x60, 0x2a, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
    // RETURN(BLOBHASH(0)) as one word
    const return_blobhash = [_]u8{ 0x60, 0x00, 0x49, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
    defer vm.deinit();
    const call_empty: Evm.CallParams = .{ .call = .{ .caller = r1_caller, .to = r1_empty, .value = 0, .input = &.{}, .gas = 100_000 } };

    // setBytecode supplies the code for a target without installed code...
    vm.setBytecode(&return_42);
    const with_bytecode = vm.call(call_empty);
    try testing.expect(with_bytecode.success);
    try testing.expectEqual(@as(u256, 42), try r1Word(with_bytecode.output));
    // ...for exactly one call.
    const without_bytecode = vm.call(call_empty);
    try testing.expect(without_bytecode.success);
    try testing.expectEqual(@as(usize, 0), without_bytecode.output.len);
    try testing.expectEqual(@as(usize, 0), vm.get_raw_code(r1_empty).len);

    // Installed account code wins over a pending override.
    try vm.code.put(r1_contract, &return_blobhash);
    vm.setBytecode(&return_42);
    const blob_hash = [_][32]u8{[_]u8{0x01} ** 32};
    vm.setBlobVersionedHashes(&blob_hash);
    const access_entries = [_]primitives.AccessList.AccessListEntry{.{ .address = r1_other, .storage_keys = &.{} }};
    vm.setAccessList(&access_entries);
    const call_contract: Evm.CallParams = .{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 0, .input = &.{}, .gas = 100_000 } };

    const with_blob = vm.call(call_contract);
    try testing.expect(with_blob.success);
    try testing.expectEqual(std.mem.readInt(u256, &blob_hash[0], .big), try r1Word(with_blob.output));

    // None of the per-call inputs leak into the next transaction.
    try testing.expect(vm.pending_access_list == null);
    try testing.expectEqual(@as(usize, 0), vm.pending_bytecode.len);
    try testing.expectEqual(@as(usize, 0), vm.blob_versioned_hashes.len);
    const without_blob = vm.call(call_contract);
    try testing.expect(without_blob.success);
    try testing.expectEqual(@as(u256, 0), try r1Word(without_blob.output));
}

test "R1 call: DELEGATECALL inherits CALLVALUE without moving funds" {
    const testing = std.testing;
    // Implementation: RETURN(CALLVALUE) as one word
    const implementation = [_]u8{ 0x34, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
    // Proxy: DELEGATECALL(GAS, r1_other, 0, 0, 0, 0x20); RETURN(0, 0x20)
    const proxy = [_]u8{ 0x60, 0x20, 0x60, 0x00, 0x60, 0x00, 0x60, 0x00, 0x73 } ++ r1_other.bytes ++
        [_]u8{ 0x5a, 0xf4, 0x50, 0x60, 0x20, 0x60, 0x00, 0xf3 };

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
    defer vm.deinit();
    try vm.balances.put(r1_caller, 100);
    try vm.code.put(r1_contract, &proxy);
    try vm.code.put(r1_other, &implementation);

    const result = vm.call(.{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 7, .input = &.{}, .gas = 200_000 } });
    try testing.expect(result.success);
    try testing.expectEqual(@as(u256, 7), try r1Word(result.output));
    try testing.expectEqual(@as(u256, 7), r1Balance(&vm, r1_contract));
    try testing.expectEqual(@as(u256, 0), r1Balance(&vm, r1_other));
    try testing.expectEqual(@as(u256, 93), r1Balance(&vm, r1_caller));
}

test "R1 touched: an empty account touched only inside a reverted call is not deleted" {
    const testing = std.testing;
    // Child: CALL(GAS, r1_empty, 0, 0, 0, 0, 0); POP; <tail>
    const child_prefix = [_]u8{ 0x60, 0x00, 0x60, 0x00, 0x60, 0x00, 0x60, 0x00, 0x60, 0x00, 0x73 } ++ r1_empty.bytes ++ [_]u8{ 0x5a, 0xf1, 0x50 };
    const child_reverts = child_prefix ++ [_]u8{ 0x60, 0x00, 0x60, 0x00, 0xfd };
    const child_returns = child_prefix ++ [_]u8{0x00};
    // Root: CALL(GAS, r1_other, 0, 0, 0, 0, 0); STOP
    const root = [_]u8{ 0x60, 0x00, 0x60, 0x00, 0x60, 0x00, 0x60, 0x00, 0x60, 0x00, 0x73 } ++ r1_other.bytes ++ [_]u8{ 0x5a, 0xf1, 0x00 };

    inline for (.{ true, false }) |child_should_revert| {
        var backing: R1Host = undefined;
        backing.init(testing.allocator);
        defer backing.deinit();
        try backing.existing.put(r1_empty, {}); // exists and is empty
        try backing.code.put(r1_contract, &root);
        try backing.code.put(r1_other, if (child_should_revert) &child_reverts else &child_returns);

        var vm: Evm = undefined;
        try vm.init(testing.allocator, backing.interface(), .BERLIN, null, r1_caller, 0, null);
        defer vm.deinit();

        const result = vm.call(.{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 0, .input = &.{}, .gas = 1_000_000 } });
        try testing.expect(result.success); // the root catches the child's revert
        try testing.expectEqual(!child_should_revert, backing.deleted.contains(r1_empty));
    }
}

// ---- EIP-7702 delegation helpers (Contract B, F-08 / C-12 / R1-016) ---------

test "R1 7702: get_raw_code and get_delegated_target separate stored code from executable code" {
    const testing = std.testing;
    const designator = [_]u8{ 0xef, 0x01, 0x00 } ++ r1_other.bytes;
    const return_42 = [_]u8{ 0x60, 0x2a, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .PRAGUE, null, r1_caller, 0, null);
    defer vm.deinit();
    try vm.initTransactionState(null);
    try vm.code.put(r1_contract, &designator);

    // Raw code is the 23-byte designator; the target is decoded from it.
    try testing.expectEqualSlices(u8, &designator, vm.get_raw_code(r1_contract));
    try testing.expect(vm.get_delegated_target(r1_contract).?.equals(r1_other));
    try testing.expect(vm.get_delegated_target(r1_other) == null);
    try testing.expect(vm.get_delegated_target(r1_empty) == null);

    // A delegating account is not empty, even while its delegate has no code.
    try testing.expectEqual(@as(usize, 0), vm.get_code(r1_contract).len);
    try testing.expect(!vm.accountIsEmpty(r1_contract));
    try testing.expect(vm.accountExists(r1_contract));

    // Executable code follows one level of delegation.
    try vm.code.put(r1_other, &return_42);
    try testing.expectEqualSlices(u8, &return_42, vm.get_code(r1_contract));

    // Not a designator: wrong length or wrong prefix.
    try vm.code.put(r1_empty, designator[0..22]);
    try testing.expect(vm.get_delegated_target(r1_empty) == null);
    const wrong_prefix = [_]u8{ 0xef, 0x01, 0x01 } ++ r1_other.bytes;
    try vm.code.put(r1_empty, &wrong_prefix);
    try testing.expect(vm.get_delegated_target(r1_empty) == null);

    // setCodeWithSnapshot journals the account's own code, not the delegate's.
    var journal = std.AutoHashMap(primitives.Address, []const u8).init(testing.allocator);
    defer journal.deinit();
    try vm.code_snapshot_stack.append(vm.tx_arena.allocator(), &journal);
    try vm.setCodeWithSnapshot(r1_contract, &.{});
    _ = vm.code_snapshot_stack.pop();
    try testing.expectEqualSlices(u8, &designator, journal.get(r1_contract).?);

    // Before Prague the designator is ordinary code.
    var cancun: Evm = undefined;
    try cancun.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
    defer cancun.deinit();
    try cancun.code.put(r1_contract, &designator);
    try testing.expect(cancun.get_delegated_target(r1_contract) == null);
    try testing.expectEqualSlices(u8, &designator, cancun.get_code(r1_contract));
}

test "R1 7702: calls to a delegating account run the delegate; a precompile delegate runs no precompile" {
    const testing = std.testing;
    const return_42 = [_]u8{ 0x60, 0x2a, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
    const to_contract = [_]u8{ 0xef, 0x01, 0x00 } ++ r1_other.bytes;
    const identity = primitives.Address.fromU256(4);
    const to_identity = [_]u8{ 0xef, 0x01, 0x00 } ++ identity.bytes;
    const payload = [_]u8{ 0xde, 0xad, 0xbe, 0xef };

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .PRAGUE, null, r1_caller, 0, null);
    defer vm.deinit();
    try vm.code.put(r1_other, &return_42);
    try vm.code.put(r1_contract, &to_contract);
    try vm.code.put(r1_empty, &to_identity);

    // Top level: the delegate's code runs in the delegating account's context.
    const delegated = vm.call(.{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 0, .input = &.{}, .gas = 100_000 } });
    try testing.expect(delegated.success);
    try testing.expectEqual(@as(u256, 42), try r1Word(delegated.output));

    // Top level, delegate is the identity precompile: empty code runs, input is not echoed.
    const top_level = vm.call(.{ .call = .{ .caller = r1_caller, .to = r1_empty, .value = 0, .input = &payload, .gas = 100_000 } });
    try testing.expect(top_level.success);
    try testing.expectEqual(@as(usize, 0), top_level.output.len);
    try testing.expectEqual(@as(u64, 100_000), top_level.gas_left);

    // Nested: same rule in inner_call.
    try vm.initTransactionState(null);
    const nested = vm.inner_call(.{ .call = .{ .caller = r1_caller, .to = r1_empty, .value = 0, .input = &payload, .gas = 100_000 } });
    try testing.expect(nested.success);
    try testing.expectEqual(@as(usize, 0), nested.output.len);
    try testing.expectEqual(@as(u64, 100_000), nested.gas_left);

    // Control: the precompile address itself still executes.
    const direct = vm.inner_call(.{ .call = .{ .caller = r1_caller, .to = identity, .value = 0, .input = &payload, .gas = 100_000 } });
    try testing.expect(direct.success);
    try testing.expectEqualSlices(u8, &payload, direct.output);
}

// ---- Precompile dispatch and gas bounds (C-20 / R1-030 / F-16) --------------

const r1_over_gas_precompile = primitives.Address{ .bytes = [_]u8{0xd1} ** 20 };
const r1_failing_precompile = primitives.Address{ .bytes = [_]u8{0xd2} ** 20 };
const r1_good_precompile = primitives.Address{ .bytes = [_]u8{0xd3} ** 20 };

fn r1OverGasPrecompile(_: ?*anyopaque, _: std.mem.Allocator, _: []const u8, gas_limit: u64) anyerror!evm_config_mod.PrecompileOutput {
    return .{ .output = &.{}, .gas_used = gas_limit + 1, .success = true };
}

fn r1FailingPrecompile(_: ?*anyopaque, _: std.mem.Allocator, _: []const u8, _: u64) anyerror!evm_config_mod.PrecompileOutput {
    return .{ .output = &.{}, .gas_used = 0, .success = false };
}

fn r1GoodPrecompile(_: ?*anyopaque, allocator: std.mem.Allocator, _: []const u8, _: u64) anyerror!evm_config_mod.PrecompileOutput {
    return .{ .output = try allocator.dupe(u8, "ok"), .gas_used = 10, .success = true };
}

const R1OverrideEvm = evm.Evm(.{
    .precompile_overrides = &[_]evm_config_mod.PrecompileOverride{
        .{ .address = r1_over_gas_precompile, .execute = r1OverGasPrecompile },
        .{ .address = r1_failing_precompile, .execute = r1FailingPrecompile },
        .{ .address = r1_good_precompile, .execute = r1GoodPrecompile },
    },
});

test "R1 precompile: gas_used above the gas limit fails the call instead of underflowing" {
    const testing = std.testing;

    var vm: R1OverrideEvm = undefined;
    try vm.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
    defer vm.deinit();
    try vm.balances.put(r1_caller, 50);

    // Top-level call() consults overrides, like nested calls do.
    const good = vm.call(.{ .call = .{ .caller = r1_caller, .to = r1_good_precompile, .value = 0, .input = &.{}, .gas = 1_000 } });
    try testing.expect(good.success);
    try testing.expectEqual(@as(u64, 990), good.gas_left);
    try testing.expectEqualSlices(u8, "ok", good.output);

    inline for (.{ r1_over_gas_precompile, r1_failing_precompile }) |target| {
        const top = vm.call(.{ .call = .{ .caller = r1_caller, .to = target, .value = 5, .input = &.{}, .gas = 1_000 } });
        try testing.expect(!top.success);
        try testing.expectEqual(@as(u64, 0), top.gas_left);
        // The value transfer is rolled back with the failed call.
        try testing.expectEqual(@as(u256, 50), r1Balance(&vm, r1_caller));
        try testing.expectEqual(@as(u256, 0), r1Balance(&vm, target));

        try vm.initTransactionState(null);
        const nested = vm.inner_call(.{ .call = .{ .caller = r1_caller, .to = target, .value = 5, .input = &.{}, .gas = 1_000 } });
        try testing.expect(!nested.success);
        try testing.expectEqual(@as(u64, 0), nested.gas_left);
        try testing.expectEqual(@as(u256, 50), r1Balance(&vm, r1_caller));
        try testing.expectEqual(@as(u256, 0), r1Balance(&vm, target));
    }

    try vm.initTransactionState(null);
    const nested_good = vm.inner_call(.{ .call = .{ .caller = r1_caller, .to = r1_good_precompile, .value = 5, .input = &.{}, .gas = 1_000 } });
    try testing.expect(nested_good.success);
    try testing.expectEqual(@as(u64, 990), nested_good.gas_left);
    try testing.expectEqual(@as(u256, 45), r1Balance(&vm, r1_caller));
    try testing.expectEqual(@as(u256, 5), r1Balance(&vm, r1_good_precompile));
}

test "R1 call: gas above i64 max is capped instead of trapping" {
    const testing = std.testing;
    const stop = [_]u8{0x00};

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
    defer vm.deinit();
    try vm.code.put(r1_contract, &stop);

    const result = vm.call(.{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 0, .input = &.{}, .gas = std.math.maxInt(u64) } });
    try testing.expect(result.success);
    try testing.expectEqual(@as(u64, std.math.maxInt(i64)), result.gas_left);

    try vm.initTransactionState(null);
    try vm.nonces.put(r1_caller, 1);
    const created = try vm.inner_create(0, &stop, std.math.maxInt(u64), null);
    try testing.expect(created.success);
}

// ============================================================================
// Round 2 fixes: async root checkpoint, restart-on-miss, transaction arena,
// fork selection, EIP-161 cleanup, root CREATE and result ownership
// ============================================================================

const AsyncPhase = @import("async_executor.zig").AsyncPhase;
const r2_child = primitives.Address{ .bytes = [_]u8{0xc1} ** 20 };

/// PUSH1 ret_size; PUSH1 0; PUSH1 0; PUSH1 0; PUSH1 value; PUSH20 to; PUSH2 gas; CALL
fn r2Call(comptime to: primitives.Address, comptime value: u8, comptime gas: u16, comptime ret_size: u8) [35]u8 {
    return [_]u8{ 0x60, ret_size, 0x60, 0x00, 0x60, 0x00, 0x60, 0x00, 0x60, value, 0x73 } ++ to.bytes ++
        [_]u8{ 0x61, @intCast(gas >> 8), @intCast(gas & 0xff), 0xf1 };
}

/// What the test host holds. Anything not listed is zero / empty.
const R2AsyncHost = struct {
    const Slot = struct { address: primitives.Address, slot: u256, value: u256 };
    const Balance = struct { address: primitives.Address, balance: u256 };
    const Nonce = struct { address: primitives.Address, nonce: u64 };
    const Code = struct { address: primitives.Address, code: []const u8 };

    slots: []const Slot = &.{},
    balances: []const Balance = &.{},
    nonces: []const Nonce = &.{},
    codes: []const Code = &.{},

    storage_requests: usize = 0,
    balance_requests: usize = 0,
    nonce_requests: usize = 0,
    code_requests: usize = 0,

    fn total(self: *const R2AsyncHost) usize {
        return self.storage_requests + self.balance_requests + self.nonce_requests + self.code_requests;
    }

    /// Answer every data request until the transaction reaches a terminal output.
    fn drive(self: *R2AsyncHost, vm: anytype, first: anytype) !@TypeOf(first) {
        var output = first;
        while (true) {
            if (self.total() > 64) return error.TooManyRequests;
            switch (output) {
                .need_storage => |request| {
                    self.storage_requests += 1;
                    var value: u256 = 0;
                    for (self.slots) |entry| {
                        if (entry.address.equals(request.address) and entry.slot == request.slot) value = entry.value;
                    }
                    output = try vm.callOrContinue(.{ .continue_with_storage = .{ .address = request.address, .slot = request.slot, .value = value } });
                },
                .need_balance => |request| {
                    self.balance_requests += 1;
                    var balance: u256 = 0;
                    for (self.balances) |entry| {
                        if (entry.address.equals(request.address)) balance = entry.balance;
                    }
                    output = try vm.callOrContinue(.{ .continue_with_balance = .{ .address = request.address, .balance = balance } });
                },
                .need_nonce => |request| {
                    self.nonce_requests += 1;
                    var nonce: u64 = 0;
                    for (self.nonces) |entry| {
                        if (entry.address.equals(request.address)) nonce = entry.nonce;
                    }
                    output = try vm.callOrContinue(.{ .continue_with_nonce = .{ .address = request.address, .nonce = nonce } });
                },
                .need_code => |request| {
                    self.code_requests += 1;
                    var code: []const u8 = &.{};
                    for (self.codes) |entry| {
                        if (entry.address.equals(request.address)) code = entry.code;
                    }
                    output = try vm.callOrContinue(.{ .continue_with_code = .{ .address = request.address, .code = code } });
                },
                else => return output,
            }
        }
    }
};

fn r2CallParams(value: u256) Evm.CallParams {
    return .{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = value, .input = &.{}, .gas = 200_000 } };
}

// SSTORE(0,0) clears a set slot (refund); SSTORE(1,7); LOG0(0,0); CALL r1_other with 5 wei; POP
const r2_effects = [_]u8{ 0x60, 0x00, 0x60, 0x00, 0x55, 0x60, 0x07, 0x60, 0x01, 0x55, 0x60, 0x00, 0x60, 0x00, 0xa0 } ++
    r2Call(r1_other, 5, 0xffff, 0) ++ [_]u8{0x50};

test "R2 async revert rollback: REVERT and exceptional halt restore the root checkpoint (hostless)" {
    const testing = std.testing;
    const reverting = r2_effects ++ [_]u8{ 0x60, 0x01, 0x60, 0x00, 0xfd }; // REVERT(0,1)
    const halting = r2_effects ++ [_]u8{0xfe}; // INVALID

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
    defer vm.deinit();
    try vm.balances.put(r1_caller, 100);
    try vm.storage.storage.put(.{ .address = r1_contract.bytes, .slot = 0 }, 8);

    inline for (.{ reverting, halting }, 0..) |code, i| {
        vm.setBytecode(&code);
        const done = try vm.callOrContinue(.{ .call = r2CallParams(10) });
        try testing.expect(done == .result);
        try testing.expect(!done.result.success);
        try testing.expectEqual(@as(usize, 0), done.result.logs.len);
        try testing.expectEqual(@as(u64, 0), done.result.refund_counter);
        if (i == 0) {
            try testing.expectEqual(@as(usize, 1), done.result.output.len);
            try testing.expect(done.result.gas_left > 0);
        } else {
            try testing.expectEqual(@as(u64, 0), done.result.gas_left);
            try testing.expect(done.result.error_info != null);
        }

        // Storage, the refund, the logs, the nested transfer and the top-level transfer are gone.
        try testing.expectEqual(@as(u256, 8), r1Slot(&vm, r1_contract, 0));
        try testing.expectEqual(@as(u256, 0), r1Slot(&vm, r1_contract, 1));
        try testing.expectEqual(@as(i64, 0), vm.gas_refund);
        try testing.expectEqual(@as(usize, 0), vm.logs.items.len);
        try testing.expectEqual(@as(u256, 100), r1Balance(&vm, r1_caller));
        try testing.expectEqual(@as(u256, 0), r1Balance(&vm, r1_contract));
        try testing.expectEqual(@as(u256, 0), r1Balance(&vm, r1_other));
        try testing.expectEqual(@as(usize, 0), vm.touched_accounts.count());
        try testing.expectEqual(@as(usize, 0), vm.frames.items.len);
        // The code supplied for the call does not outlive it.
        try testing.expect(!vm.code.contains(r1_contract));
        try testing.expectError(error.InvalidAsyncState, vm.callOrContinue(.{ .continue_after_commit = {} }));
    }

    // Control: the same effects commit when the transaction succeeds.
    const committing = r2_effects ++ [_]u8{0x00};
    vm.setBytecode(&committing);
    const committed = try vm.callOrContinue(.{ .call = r2CallParams(10) });
    try testing.expect(committed.result.success);
    try testing.expectEqual(@as(usize, 1), committed.result.logs.len);
    try testing.expect(committed.result.refund_counter > 0);
    try testing.expectEqual(@as(u256, 0), r1Slot(&vm, r1_contract, 0));
    try testing.expectEqual(@as(u256, 7), r1Slot(&vm, r1_contract, 1));
    try testing.expectEqual(@as(u256, 90), r1Balance(&vm, r1_caller));
    try testing.expectEqual(@as(u256, 5), r1Balance(&vm, r1_contract));
    try testing.expectEqual(@as(u256, 5), r1Balance(&vm, r1_other));
}

test "R2 async revert rollback: with an injector nothing is offered for commit and fetched data is dropped" {
    const testing = std.testing;
    const reverting = r2_effects ++ [_]u8{ 0x60, 0x00, 0x60, 0x00, 0xfd };

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
    defer vm.deinit();
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    vm.pending_storage_injector = &injector;
    try vm.balances.put(r1_caller, 100);

    var host = R2AsyncHost{ .slots = &.{.{ .address = r1_contract, .slot = 0, .value = 8 }} };
    vm.setBytecode(&reverting);
    const done = try host.drive(&vm, try vm.callOrContinue(.{ .call = r2CallParams(10) }));
    try testing.expect(done == .result);
    try testing.expect(!done.result.success);
    try testing.expect(host.storage_requests >= 2);

    try testing.expectEqual(@as(usize, 0), vm.getPendingStateChanges().len);
    try testing.expectEqual(@as(usize, 0), injector.dirty_storage.count());
    try testing.expectEqual(@as(usize, 0), injector.dirty_balances.count());
    try testing.expectEqual(@as(i64, 0), vm.gas_refund);
    // The overlay holds the values the host supplied, not the reverted writes.
    try testing.expectEqual(@as(u256, 8), vm.storage.peek(r1_contract, 0));
    try testing.expectEqual(@as(u256, 0), vm.storage.peek(r1_contract, 1));
    // Locally installed state is restored; host-supplied account data is not kept.
    try testing.expectEqual(@as(u256, 100), r1Balance(&vm, r1_caller));
    try testing.expect(!vm.balances.contains(r1_contract));
    try testing.expect(!vm.balances.contains(r1_other));
    try testing.expect(!vm.code.contains(r1_other));
    try testing.expectError(error.InvalidAsyncState, vm.callOrContinue(.{ .continue_after_commit = {} }));
}

test "R2 async success: SELFDESTRUCT is committed before the result or the change set is produced" {
    const testing = std.testing;
    const destructing = [_]u8{ 0x60, 0x00, 0xff }; // SELFDESTRUCT(0)
    const parent = r2Call(r2_child, 0, 0xffff, 0) ++ [_]u8{0x00};

    // Without an injector the result is final and the account is already gone.
    {
        var vm: Evm = undefined;
        try vm.init(testing.allocator, null, .BERLIN, null, r1_caller, 0, null);
        defer vm.deinit();
        try vm.code.put(r2_child, &destructing);
        try vm.storage.storage.put(.{ .address = r2_child.bytes, .slot = 3 }, 9);

        vm.setBytecode(&parent);
        const done = try vm.callOrContinue(.{ .call = r2CallParams(0) });
        try testing.expect(done == .result);
        try testing.expect(done.result.success);
        try testing.expect(!vm.code.contains(r2_child));
        try testing.expectEqual(@as(u256, 0), r1Slot(&vm, r2_child, 3));
        try testing.expectEqual(@as(usize, 0), vm.selfdestructed_accounts.count());

        // A synchronous EXTCODESIZE on the same instance agrees.
        const probe = [_]u8{0x73} ++ r2_child.bytes ++ [_]u8{ 0x3b, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
        try vm.code.put(r1_other, &probe);
        const size = vm.call(.{ .call = .{ .caller = r1_caller, .to = r1_other, .value = 0, .input = &.{}, .gas = 100_000 } });
        try testing.expectEqual(@as(u256, 0), try r1Word(size.output));
    }

    // With an injector the change set reports the deletion and the local state has it applied.
    {
        var vm: Evm = undefined;
        try vm.init(testing.allocator, null, .BERLIN, null, r1_caller, 0, null);
        defer vm.deinit();
        var injector = try StorageInjector.init(testing.allocator);
        defer injector.deinit();
        vm.pending_storage_injector = &injector;
        try vm.code.put(r2_child, &destructing);

        vm.setBytecode(&parent);
        // SELFDESTRUCT fetches the originator and beneficiary balances before moving value.
        var host = R2AsyncHost{};
        const committed = try host.drive(&vm, try vm.callOrContinue(.{ .call = r2CallParams(0) }));
        try testing.expect(committed == .ready_to_commit);
        try testing.expectEqual(@as(usize, 2), host.balance_requests);
        try testing.expect(!vm.code.contains(r2_child));

        var parsed = try std.json.parseFromSlice(std.json.Value, testing.allocator, committed.ready_to_commit.changes_json, .{});
        defer parsed.deinit();
        const destroyed = parsed.value.object.get("selfDestructs").?.array.items;
        try testing.expectEqual(@as(usize, 1), destroyed.len);
        try testing.expectEqualStrings("0x" ++ "c1" ** 20, destroyed[0].string);
        // The deleted account is reported once, not again as a code change.
        try testing.expectEqual(@as(usize, 0), parsed.value.object.get("codes").?.array.items.len);

        try testing.expect((try vm.callOrContinue(.{ .continue_after_commit = {} })).result.success);
    }
}

test "R2 async message semantics: hostless value transfer, STATICCALL, CALLCODE and DELEGATECALL" {
    const testing = std.testing;
    const stop = [_]u8{0x00};
    const store = [_]u8{ 0x60, 0x07, 0x60, 0x00, 0x55, 0x00 }; // SSTORE(0,7)
    const callvalue = [_]u8{ 0x34, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 }; // RETURN(CALLVALUE)

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
    defer vm.deinit();

    // An unfunded value call fails, exactly as the synchronous call does.
    vm.setBytecode(&stop);
    const unfunded = try vm.callOrContinue(.{ .call = r2CallParams(1) });
    try testing.expect(!unfunded.result.success);
    vm.setBytecode(&stop);
    try testing.expect(!vm.call(r2CallParams(1)).success);

    // A funded one moves the value.
    try vm.balances.put(r1_caller, 10);
    vm.setBytecode(&stop);
    const funded = try vm.callOrContinue(.{ .call = r2CallParams(4) });
    try testing.expect(funded.result.success);
    try testing.expectEqual(@as(u256, 6), r1Balance(&vm, r1_caller));
    try testing.expectEqual(@as(u256, 4), r1Balance(&vm, r1_contract));

    // STATICCALL is read-only.
    vm.setBytecode(&store);
    const static = try vm.callOrContinue(.{ .call = .{ .staticcall = .{ .caller = r1_caller, .to = r1_contract, .input = &.{}, .gas = 100_000 } } });
    try testing.expect(!static.result.success);
    try testing.expectEqual(@as(u256, 0), r1Slot(&vm, r1_contract, 0));

    // CALLCODE and DELEGATECALL run the target's code in the caller's storage and move nothing.
    try vm.code.put(r1_other, &store);
    const callcode = try vm.callOrContinue(.{ .call = .{ .callcode = .{ .caller = r1_caller, .to = r1_other, .value = 3, .input = &.{}, .gas = 100_000 } } });
    try testing.expect(callcode.result.success);
    try testing.expectEqual(@as(u256, 7), r1Slot(&vm, r1_caller, 0));
    try testing.expectEqual(@as(u256, 0), r1Slot(&vm, r1_other, 0));
    try testing.expectEqual(@as(u256, 6), r1Balance(&vm, r1_caller));
    try testing.expectEqual(@as(u256, 0), r1Balance(&vm, r1_other));

    // CALLCODE still requires the caller to hold the value.
    const poor_callcode = try vm.callOrContinue(.{ .call = .{ .callcode = .{ .caller = r1_caller, .to = r1_other, .value = 7, .input = &.{}, .gas = 100_000 } } });
    try testing.expect(!poor_callcode.result.success);

    // DELEGATECALL exposes the inherited value without a balance check or a transfer.
    try vm.code.put(r1_other, &callvalue);
    const delegated = try vm.callOrContinue(.{ .call = .{ .delegatecall = .{ .caller = r1_caller, .to = r1_other, .input = &.{}, .gas = 100_000, .value = 42 } } });
    try testing.expect(delegated.result.success);
    try testing.expectEqual(@as(u256, 42), try r1Word(delegated.result.output));
    try testing.expectEqual(@as(u256, 6), r1Balance(&vm, r1_caller));
}

test "R2 call: top-level DELEGATECALL keeps params.delegatecall.value as CALLVALUE" {
    const testing = std.testing;
    const callvalue = [_]u8{ 0x34, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
    defer vm.deinit();
    try vm.code.put(r1_contract, &callvalue);

    // The caller holds nothing: the inherited value is neither checked nor moved.
    const result = vm.call(.{ .delegatecall = .{ .caller = r1_caller, .to = r1_contract, .input = &.{}, .gas = 100_000, .value = 42 } });
    try testing.expect(result.success);
    try testing.expectEqual(@as(u256, 42), try r1Word(result.output));
    try testing.expectEqual(@as(u256, 0), r1Balance(&vm, r1_caller));
    try testing.expectEqual(@as(u256, 0), r1Balance(&vm, r1_contract));
}

test "R2 nested async storage fetch: a child SLOAD yields need_storage and the call completes" {
    const testing = std.testing;
    // v = SLOAD(0) + 1; SSTORE(0, v); RETURN(v)
    const child = [_]u8{ 0x60, 0x00, 0x54, 0x60, 0x01, 0x01, 0x80, 0x60, 0x00, 0x55, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
    // CALL child into memory[0..32]; MSTORE(32, success); RETURN(0, 64)
    const parent = r2Call(r2_child, 0, 0xffff, 0x20) ++ [_]u8{ 0x60, 0x20, 0x52, 0x60, 0x40, 0x60, 0x00, 0xf3 };

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .OSAKA, null, r1_caller, 0, null);
    defer vm.deinit();
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    vm.pending_storage_injector = &injector;
    try vm.code.put(r2_child, &child);

    vm.setBytecode(&parent);
    const yielded = try vm.callOrContinue(.{ .call = r2CallParams(0) });
    // The miss inside the child reaches the host instead of failing the child.
    try testing.expect(yielded == .need_storage);
    try testing.expect(yielded.need_storage.address.equals(r2_child));
    try testing.expectEqual(@as(u256, 0), yielded.need_storage.slot);
    // Nothing of the interrupted attempt is left behind while the host fetches.
    try testing.expectEqual(@as(usize, 0), vm.frames.items.len);
    try testing.expectEqual(@as(usize, 0), injector.dirty_storage.count());
    try testing.expect(vm.storage.async_data_request == .storage);

    // A reply for another slot is rejected and the request stays outstanding.
    try testing.expectError(error.InvalidAsyncState, vm.callOrContinue(.{ .continue_with_storage = .{ .address = r2_child, .slot = 1, .value = 1 } }));

    const committed = try vm.callOrContinue(.{ .continue_with_storage = .{ .address = r2_child, .slot = 0, .value = 9 } });
    try testing.expect(committed == .ready_to_commit);

    var parsed = try std.json.parseFromSlice(std.json.Value, testing.allocator, committed.ready_to_commit.changes_json, .{});
    defer parsed.deinit();
    const slots = parsed.value.object.get("storage").?.array.items;
    try testing.expectEqual(@as(usize, 1), slots.len);
    try testing.expectEqualStrings("0x" ++ "c1" ** 20, slots[0].object.get("address").?.string);
    try testing.expectEqualStrings("0x9", slots[0].object.get("originalValue").?.string);
    try testing.expectEqualStrings("0xa", slots[0].object.get("newValue").?.string);

    const done = try vm.callOrContinue(.{ .continue_after_commit = {} });
    try testing.expect(done.result.success);
    try testing.expectEqual(@as(usize, 64), done.result.output.len);
    try testing.expectEqual(@as(u256, 10), std.mem.readInt(u256, done.result.output[0..32], .big));
    try testing.expectEqual(@as(u256, 1), std.mem.readInt(u256, done.result.output[32..64], .big));

    // The replayed transaction reports the same gas as a run with the slot known up front.
    var reference: Evm = undefined;
    try reference.init(testing.allocator, null, .OSAKA, null, r1_caller, 0, null);
    defer reference.deinit();
    try reference.code.put(r2_child, &child);
    try reference.code.put(r1_contract, &parent);
    try reference.storage.storage.put(.{ .address = r2_child.bytes, .slot = 0 }, 9);
    const expected = reference.call(r2CallParams(0));
    try testing.expect(expected.success);
    try testing.expectEqual(expected.gas_left, done.result.gas_left);
    try testing.expectEqualSlices(u8, expected.output, done.result.output);
}

test "R2 nested async storage fetch: constructors and CREATE transactions fetch their slots" {
    const testing = std.testing;
    // Init code: SSTORE(0, SLOAD(0) + 7); RETURN(0, 0)
    const init_code = [_]u8{ 0x60, 0x00, 0x54, 0x60, 0x07, 0x01, 0x60, 0x00, 0x55, 0x60, 0x00, 0x60, 0x00, 0xf3 };

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .OSAKA, null, r1_caller, 0, null);
    defer vm.deinit();
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    vm.pending_storage_injector = &injector;

    var host = R2AsyncHost{ .nonces = &.{.{ .address = r1_caller, .nonce = 1 }} };
    const first = try vm.callOrContinue(.{ .call = .{ .create = .{ .caller = r1_caller, .value = 0, .init_code = &init_code, .gas = 200_000 } } });
    const committed = try host.drive(&vm, first);
    try testing.expect(committed == .ready_to_commit);
    // The creator's nonce comes from the host. A nonce-derived destination cannot pre-exist,
    // so nothing is requested for it, and a zero-value creation needs no balance.
    try testing.expectEqual(@as(usize, 1), host.nonce_requests);
    try testing.expectEqual(@as(usize, 0), host.code_requests);
    try testing.expectEqual(@as(usize, 0), host.balance_requests);
    try testing.expectEqual(@as(usize, 1), host.storage_requests);

    const created = try vm.computeCreateAddress(r1_caller, 0);
    var parsed = try std.json.parseFromSlice(std.json.Value, testing.allocator, committed.ready_to_commit.changes_json, .{});
    defer parsed.deinit();
    const slots = parsed.value.object.get("storage").?.array.items;
    try testing.expectEqual(@as(usize, 1), slots.len);
    try testing.expectEqualStrings("0x7", slots[0].object.get("newValue").?.string);
    // The new account's nonce is a change; the creator's fetched nonce is not.
    const nonces = parsed.value.object.get("nonces").?.array.items;
    try testing.expectEqual(@as(usize, 1), nonces.len);
    try testing.expectEqualStrings("0x1", nonces[0].object.get("nonce").?.string);

    const done = try vm.callOrContinue(.{ .continue_after_commit = {} });
    try testing.expect(done.result.success);
    try testing.expect(done.result.created_address.?.equals(created));

    // A CREATE2 destination can pre-exist: its nonce and code are requested, and a contract
    // only the host knows is a collision (EIP-684), not a silent redeployment.
    const destination = try vm.computeCreate2Address(r1_caller, 5, &init_code);
    var occupied = R2AsyncHost{ .codes = &.{.{ .address = destination, .code = &[_]u8{0x00} }} };
    const create2_first = try vm.callOrContinue(.{ .call = .{ .create2 = .{ .caller = r1_caller, .value = 0, .init_code = &init_code, .salt = 5, .gas = 200_000 } } });
    const collided = try occupied.drive(&vm, create2_first);
    try testing.expect(collided == .result);
    try testing.expect(!collided.result.success);
    try testing.expectEqual(@as(usize, 1), occupied.code_requests);
    try testing.expectEqual(@as(usize, 2), occupied.nonce_requests);
    try testing.expectEqual(@as(usize, 0), occupied.storage_requests);

    // A nested CREATE from a contract whose code is installed locally requests no storage,
    // nonce or code. Its init code SELFDESTRUCT(0) fetches the balances it moves.
    // MSTORE(0, 0x6000ff); CREATE(0, 29, 3) x1; STOP  (init code: SELFDESTRUCT(0))
    const factory = [_]u8{ 0x62, 0x60, 0x00, 0xff, 0x60, 0x00, 0x52, 0x60, 0x03, 0x60, 0x1d, 0x60, 0x00, 0xf0, 0x00 };
    var silent = R2AsyncHost{};
    vm.setBytecode(&factory);
    const nested = try silent.drive(&vm, try vm.callOrContinue(.{ .call = r2CallParams(0) }));
    try testing.expect(nested == .ready_to_commit);
    try testing.expectEqual(@as(usize, 2), silent.total());
    try testing.expectEqual(@as(usize, 2), silent.balance_requests);
    try testing.expect((try vm.callOrContinue(.{ .continue_after_commit = {} })).result.success);
}

test "R2 async account lookups: balance and code misses are requested, answered once and not committed" {
    const testing = std.testing;
    // RETURN(BALANCE(r1_other))
    const balance_of = [_]u8{0x73} ++ r1_other.bytes ++ [_]u8{ 0x31, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
    const answer_42 = [_]u8{ 0x60, 0x2a, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
    const parent = r2Call(r2_child, 0, 0xffff, 0x20) ++ [_]u8{ 0x60, 0x20, 0x52, 0x60, 0x40, 0x60, 0x00, 0xf3 };

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .OSAKA, null, r1_caller, 0, null);
    defer vm.deinit();
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    vm.pending_storage_injector = &injector;

    // BALANCE of an account only the host knows.
    vm.setBytecode(&balance_of);
    const need_balance = try vm.callOrContinue(.{ .call = r2CallParams(0) });
    try testing.expect(need_balance == .need_balance);
    try testing.expect(need_balance.need_balance.address.equals(r1_other));
    // A storage reply does not answer a balance request.
    try testing.expectError(error.InvalidAsyncState, vm.callOrContinue(.{ .continue_with_storage = .{ .address = r1_other, .slot = 0, .value = 1 } }));
    const with_balance = try vm.callOrContinue(.{ .continue_with_balance = .{ .address = r1_other, .balance = 77 } });
    try testing.expect(with_balance == .ready_to_commit);
    {
        var parsed = try std.json.parseFromSlice(std.json.Value, testing.allocator, with_balance.ready_to_commit.changes_json, .{});
        defer parsed.deinit();
        // Fetched data is baseline, not a change.
        try testing.expectEqual(@as(usize, 0), parsed.value.object.get("balances").?.array.items.len);
    }
    const balance_result = try vm.callOrContinue(.{ .continue_after_commit = {} });
    try testing.expectEqual(@as(u256, 77), try r1Word(balance_result.result.output));
    // The host stays authoritative: the fetched balance is not kept for the next transaction.
    try testing.expect(!vm.balances.contains(r1_other));

    // A zero reply is remembered within the transaction and requested only once.
    var zero_host = R2AsyncHost{};
    vm.setBytecode(&balance_of);
    const zero = try zero_host.drive(&vm, try vm.callOrContinue(.{ .call = r2CallParams(0) }));
    try testing.expect(zero == .ready_to_commit);
    try testing.expectEqual(@as(usize, 1), zero_host.balance_requests);
    try testing.expectEqual(@as(usize, 1), zero_host.total());
    _ = try vm.callOrContinue(.{ .continue_after_commit = {} });

    // CALL to a contract whose code only the host holds.
    var code_host = R2AsyncHost{ .codes = &.{.{ .address = r2_child, .code = &answer_42 }} };
    vm.setBytecode(&parent);
    const called = try code_host.drive(&vm, try vm.callOrContinue(.{ .call = r2CallParams(0) }));
    try testing.expect(called == .ready_to_commit);
    try testing.expectEqual(@as(usize, 1), code_host.code_requests);
    const call_result = try vm.callOrContinue(.{ .continue_after_commit = {} });
    try testing.expectEqual(@as(u256, 42), std.mem.readInt(u256, call_result.result.output[0..32], .big));
    try testing.expectEqual(@as(u256, 1), std.mem.readInt(u256, call_result.result.output[32..64], .big));
    try testing.expect(!vm.code.contains(r2_child));

    // Locally installed fields are never requested.
    try vm.balances.put(r1_other, 5);
    var local_host = R2AsyncHost{};
    vm.setBytecode(&balance_of);
    const local = try local_host.drive(&vm, try vm.callOrContinue(.{ .call = r2CallParams(0) }));
    try testing.expectEqual(@as(usize, 0), local_host.total());
    try testing.expect(local == .ready_to_commit);
    try testing.expectEqual(@as(u256, 5), try r1Word((try vm.callOrContinue(.{ .continue_after_commit = {} })).result.output));

    // The synchronous call() never requests anything: an unknown account reads as empty.
    _ = vm.balances.remove(r1_other);
    try vm.code.put(r1_contract, &balance_of);
    const sync = vm.call(r2CallParams(0));
    try testing.expect(sync.success);
    try testing.expectEqual(@as(u256, 0), try r1Word(sync.output));
    try testing.expect(!vm.async_restart_pending);
}

test "R2 async precompiles: value transfers are committed and overrides at ordinary addresses run" {
    const testing = std.testing;
    const identity = primitives.Address.fromU256(4);

    var vm: R1OverrideEvm = undefined;
    try vm.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
    defer vm.deinit();
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    vm.pending_storage_injector = &injector;
    try vm.balances.put(r1_caller, 100);

    // Identity precompile with value: the change set carries both balances.
    var host = R2AsyncHost{};
    const first = try vm.callOrContinue(.{ .call = .{ .call = .{ .caller = r1_caller, .to = identity, .value = 11, .input = "abc", .gas = 1_000 } } });
    const committed = try host.drive(&vm, first);
    try testing.expect(committed == .ready_to_commit);
    {
        var parsed = try std.json.parseFromSlice(std.json.Value, testing.allocator, committed.ready_to_commit.changes_json, .{});
        defer parsed.deinit();
        const balances = parsed.value.object.get("balances").?.array.items;
        try testing.expectEqual(@as(usize, 2), balances.len);
        var saw_caller = false;
        var saw_precompile = false;
        for (balances) |entry| {
            const balance = entry.object.get("balance").?.string;
            if (std.mem.eql(u8, balance, "0x59")) saw_caller = true; // 100 - 11
            if (std.mem.eql(u8, balance, "0xb")) saw_precompile = true;
        }
        try testing.expect(saw_caller and saw_precompile);
    }
    const identity_result = try vm.callOrContinue(.{ .continue_after_commit = {} });
    try testing.expect(identity_result.result.success);
    try testing.expectEqualSlices(u8, "abc", identity_result.result.output);

    // A registered override at an ordinary address is dispatched, as in call().
    var override_host = R2AsyncHost{};
    const override_first = try vm.callOrContinue(.{ .call = .{ .call = .{ .caller = r1_caller, .to = r1_good_precompile, .value = 0, .input = &.{}, .gas = 1_000 } } });
    const override_committed = try override_host.drive(&vm, override_first);
    try testing.expect(override_committed == .ready_to_commit);
    const override_result = try vm.callOrContinue(.{ .continue_after_commit = {} });
    try testing.expect(override_result.result.success);
    try testing.expectEqualSlices(u8, "ok", override_result.result.output);
    try testing.expectEqual(@as(u64, 990), override_result.result.gas_left);

    // A failing override rolls back its value transfer and offers no commit.
    const failing_first = try vm.callOrContinue(.{ .call = .{ .call = .{ .caller = r1_caller, .to = r1_failing_precompile, .value = 5, .input = &.{}, .gas = 1_000 } } });
    var failing_host = R2AsyncHost{};
    const failed = try failing_host.drive(&vm, failing_first);
    try testing.expect(failed == .result);
    try testing.expect(!failed.result.success);
    try testing.expectEqual(@as(u256, 89), r1Balance(&vm, r1_caller));
    try testing.expectEqual(@as(usize, 0), vm.getPendingStateChanges().len);
}

test "R2 async protocol: a new transaction invalidates the suspended request and the pending acknowledgement" {
    const testing = std.testing;
    const stop = [_]u8{0x00};
    const store = [_]u8{ 0x60, 0x07, 0x60, 0x00, 0x55, 0x00 };
    const identity = primitives.Address.fromU256(4);

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
    defer vm.deinit();
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    vm.pending_storage_injector = &injector;

    // Two calls reach ready_to_commit; only one acknowledgement is ever owed.
    vm.setBytecode(&stop);
    try testing.expect((try vm.callOrContinue(.{ .call = r2CallParams(0) })) == .ready_to_commit);
    const second = try vm.callOrContinue(.{ .call = .{ .call = .{ .caller = r1_caller, .to = identity, .value = 0, .input = "x", .gas = 1_000 } } });
    try testing.expect(second == .ready_to_commit);
    const acked = try vm.callOrContinue(.{ .continue_after_commit = {} });
    try testing.expectEqualSlices(u8, "x", acked.result.output);
    try testing.expectError(error.InvalidAsyncState, vm.callOrContinue(.{ .continue_after_commit = {} }));

    // A suspended transaction is cancelled by a new asynchronous call.
    vm.setBytecode(&store);
    try testing.expect((try vm.callOrContinue(.{ .call = r2CallParams(0) })) == .need_storage);
    vm.setBytecode(&stop);
    try testing.expect((try vm.callOrContinue(.{ .call = r2CallParams(0) })) == .ready_to_commit);
    try testing.expectError(error.InvalidAsyncState, vm.callOrContinue(.{ .continue_with_storage = .{ .address = r1_contract, .slot = 0, .value = 1 } }));
    _ = try vm.callOrContinue(.{ .continue_after_commit = {} });

    // ...and by a synchronous call(), which also rolls back what it had written.
    const store_after_load = [_]u8{ 0x60, 0x07, 0x60, 0x01, 0x55, 0x60, 0x00, 0x54, 0x00 }; // SSTORE(1,7); SLOAD(0)
    vm.setBytecode(&store_after_load);
    const suspended = try vm.callOrContinue(.{ .call = r2CallParams(0) });
    try testing.expect(suspended == .need_storage);
    const answered = try vm.callOrContinue(.{ .continue_with_storage = .{ .address = r1_contract, .slot = 1, .value = 0 } });
    try testing.expect(answered == .need_storage);
    try testing.expectEqual(@as(u256, 0), answered.need_storage.slot);
    try testing.expectEqual(@as(u256, 7), vm.storage.peek(r1_contract, 1));

    try vm.code.put(r1_other, &stop);
    try testing.expect(vm.call(.{ .call = .{ .caller = r1_caller, .to = r1_other, .value = 0, .input = &.{}, .gas = 10_000 } }).success);
    try testing.expectEqual(AsyncPhase.idle, vm.async_executor.?.phase);
    try testing.expectError(error.InvalidAsyncState, vm.callOrContinue(.{ .continue_with_storage = .{ .address = r1_contract, .slot = 0, .value = 1 } }));
    try testing.expectError(error.InvalidAsyncState, vm.callOrContinue(.{ .continue_after_commit = {} }));
    try testing.expectEqual(@as(usize, 0), injector.dirty_storage.count());
}

test "R2 async memory: completed calls do not grow the long-lived arena" {
    const testing = std.testing;
    // MSTORE(0, 42); LOG0(0, 32); RETURN(0, 32)
    const code = [_]u8{ 0x60, 0x2a, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xa0, 0x60, 0x20, 0x60, 0x00, 0xf3 };

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
    defer vm.deinit();

    var after_warmup: usize = 0;
    var i: usize = 0;
    while (i < 200) : (i += 1) {
        vm.setBytecode(&code);
        const done = try vm.callOrContinue(.{ .call = .{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 0, .input = "calldata", .gas = 100_000 } } });
        try testing.expect(done.result.success);
        try testing.expectEqual(@as(u8, 42), done.result.output[31]);
        // The frame, its stack, the calldata and bytecode copies and the result come from
        // the transaction arena, which the next call recycles.
        const frame_stack_bytes = 1024 * @sizeOf(u256);
        if (i == 8) after_warmup = vm.arena.queryCapacity();
        if (i > 8) try testing.expect(vm.arena.queryCapacity() < after_warmup + frame_stack_bytes);
    }
}

test "R2 getBytecode: returns the raw code of the current frame" {
    const testing = std.testing;
    const code = [_]u8{ 0x60, 0x01, 0x00 };

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
    defer vm.deinit();
    try vm.initTransactionState(null);

    try testing.expectEqual(@as(usize, 0), vm.getBytecode().len);
    try testing.expectEqual(@as(u32, 0), vm.getPC());

    const FrameType = @TypeOf(vm.frames.items[0]);
    const frame = try FrameType.init(vm.tx_arena.allocator(), &code, 1_000, r1_caller, r1_contract, 0, &.{}, @as(*anyopaque, @ptrCast(&vm)), vm.hardfork, false);
    vm.frames.appendAssumeCapacity(frame);

    const bytecode: []const u8 = vm.getBytecode();
    try testing.expectEqualSlices(u8, &code, bytecode);
    try vm.step();
    try testing.expectEqual(@as(u32, 2), vm.getPC());
}

test "R2 fork selection: config.hardfork applies when no override is given, and fork_transition picks per block" {
    const testing = std.testing;
    const push0 = [_]u8{ 0x5f, 0x00 }; // PUSH0 is Shanghai+

    const BerlinEvm = evm.Evm(.{ .hardfork = .BERLIN });
    var configured: BerlinEvm = undefined;
    try configured.init(testing.allocator, null, null, null, r1_caller, 0, null);
    defer configured.deinit();
    try testing.expectEqual(primitives.Hardfork.BERLIN, configured.hardfork);
    try configured.code.put(r1_contract, &push0);
    try testing.expect(!configured.call(.{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 0, .input = &.{}, .gas = 10_000 } }).success);

    // A runtime argument still overrides the configured fork.
    var overridden: BerlinEvm = undefined;
    try overridden.init(testing.allocator, null, .SHANGHAI, null, r1_caller, 0, null);
    defer overridden.deinit();
    try testing.expectEqual(primitives.Hardfork.SHANGHAI, overridden.hardfork);
    try overridden.code.put(r1_contract, &push0);
    try testing.expect(overridden.call(.{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 0, .input = &.{}, .gas = 10_000 } }).success);

    // The default configuration still selects Hardfork.DEFAULT.
    var default_vm: Evm = undefined;
    try default_vm.init(testing.allocator, null, null, null, r1_caller, 0, null);
    defer default_vm.deinit();
    try testing.expectEqual(primitives.Hardfork.DEFAULT, default_vm.hardfork);

    // A schedule selects the fork from the block context at every transaction, on both entry points.
    var scheduled: Evm = undefined;
    try scheduled.init(testing.allocator, null, .BERLIN, null, r1_caller, 0, null);
    defer scheduled.deinit();
    try scheduled.code.put(r1_contract, &push0);
    scheduled.block_context.block_timestamp = 99;
    scheduled.setForkTransition(.{ .from_fork = .BERLIN, .to_fork = .SHANGHAI, .at_block = null, .at_timestamp = 100 });
    try testing.expectEqual(primitives.Hardfork.BERLIN, scheduled.getActiveFork());
    try testing.expect(!scheduled.call(.{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 0, .input = &.{}, .gas = 10_000 } }).success);
    try testing.expect(!(try scheduled.callOrContinue(.{ .call = .{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 0, .input = &.{}, .gas = 10_000 } } })).result.success);

    scheduled.block_context.block_timestamp = 100;
    try testing.expectEqual(primitives.Hardfork.SHANGHAI, scheduled.getActiveFork());
    try testing.expect(scheduled.call(.{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 0, .input = &.{}, .gas = 10_000 } }).success);
    try testing.expectEqual(primitives.Hardfork.SHANGHAI, scheduled.hardfork);
    try testing.expect((try scheduled.callOrContinue(.{ .call = .{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 0, .input = &.{}, .gas = 10_000 } } })).result.success);

    // Moving back before the activation restores the earlier rules.
    scheduled.block_context.block_timestamp = 5;
    try testing.expect(!scheduled.call(.{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 0, .input = &.{}, .gas = 10_000 } }).success);
    try testing.expectEqual(primitives.Hardfork.BERLIN, scheduled.hardfork);
}

test "R2 root CREATE: the last valid sender nonce (2^64 - 2) creates; the opcode guard stays" {
    const testing = std.testing;
    const max_nonce = std.math.maxInt(u64);
    const init_code = [_]u8{ 0x60, 0x01, 0x60, 0x00, 0xf3 }; // deploys one zero byte

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
    defer vm.deinit();
    // The transaction processor admitted nonce 2^64 - 2 and incremented it.
    try vm.nonces.put(r1_caller, max_nonce);

    const result = vm.call(.{ .create = .{ .caller = r1_caller, .value = 0, .init_code = &init_code, .gas = 200_000 } });
    try testing.expect(result.success);
    const expected = try vm.computeCreateAddress(r1_caller, max_nonce - 1);
    try testing.expect(result.created_address.?.equals(expected));
    try testing.expectEqual(@as(usize, 1), vm.get_raw_code(expected).len);
    // A creation transaction does not increment the sender nonce again.
    try testing.expectEqual(@as(u64, max_nonce), vm.getNonce(r1_caller));

    // The CREATE opcode increments the nonce itself, so it still refuses 2^64 - 1.
    // CREATE(0, 0, 0); MSTORE(0); RETURN(0, 32)
    const creator = [_]u8{ 0x60, 0x00, 0x60, 0x00, 0x60, 0x00, 0xf0, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
    try vm.code.put(r1_contract, &creator);
    try vm.nonces.put(r1_contract, max_nonce);
    const from_opcode = vm.call(.{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 0, .input = &.{}, .gas = 200_000 } });
    try testing.expect(from_opcode.success);
    try testing.expectEqual(@as(u256, 0), try r1Word(from_opcode.output));
    try testing.expectEqual(@as(u64, max_nonce), vm.getNonce(r1_contract));
}

test "R2 accountExists: zero-valued storage entries do not make an account exist" {
    const testing = std.testing;

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
    defer vm.deinit();

    try testing.expect(!vm.accountExists(r1_empty));
    try vm.storage.storage.put(.{ .address = r1_empty.bytes, .slot = 1 }, 0);
    try vm.storage.original_storage.put(.{ .address = r1_empty.bytes, .slot = 1 }, 0);
    try testing.expect(!vm.accountExists(r1_empty));
    try testing.expect(!vm.accountHasStorage(r1_empty));

    try vm.storage.storage.put(.{ .address = r1_empty.bytes, .slot = 2 }, 5);
    try testing.expect(vm.accountExists(r1_empty));
    try testing.expect(vm.accountHasStorage(r1_empty));

    // Another account's storage does not count.
    try testing.expect(!vm.accountExists(r1_other));
}

test "R2 EIP-161: empty accounts at precompile addresses are deleted; RIPEMD-160 stays touched after a failed call" {
    const testing = std.testing;
    const sha256 = primitives.Address{ .bytes = [_]u8{0} ** 19 ++ [_]u8{2} };
    const ripemd = primitives.Address{ .bytes = [_]u8{0} ** 19 ++ [_]u8{3} };

    // A successful call to a precompile with an empty backing account deletes that account.
    {
        var vm: Evm = undefined;
        try vm.init(testing.allocator, null, .OSAKA, null, r1_caller, 0, null);
        defer vm.deinit();
        try vm.balances.put(ripemd, 0);
        const result = vm.call(.{ .call = .{ .caller = r1_caller, .to = ripemd, .value = 0, .input = &.{}, .gas = 10_000 } });
        try testing.expect(result.success);
        try testing.expect(!vm.balances.contains(ripemd));
    }

    // A precompile account that holds a balance is not empty and survives.
    {
        var vm: Evm = undefined;
        try vm.init(testing.allocator, null, .OSAKA, null, r1_caller, 0, null);
        defer vm.deinit();
        try vm.balances.put(ripemd, 1);
        try testing.expect(vm.call(.{ .call = .{ .caller = r1_caller, .to = ripemd, .value = 0, .input = &.{}, .gas = 10_000 } }).success);
        try testing.expectEqual(@as(u256, 1), r1Balance(&vm, ripemd));
    }

    // A nested call that runs out of gas un-touches its target, except RIPEMD-160.
    inline for (.{ sha256, ripemd }) |precompile| {
        const starved = r2Call(precompile, 0, 1, 0) ++ [_]u8{ 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
        var vm: Evm = undefined;
        try vm.init(testing.allocator, null, .SPURIOUS_DRAGON, null, r1_caller, 0, null);
        defer vm.deinit();
        try vm.balances.put(precompile, 0);
        try vm.code.put(r1_contract, &starved);
        const result = vm.call(.{ .call = .{ .caller = r1_caller, .to = r1_contract, .value = 0, .input = &.{}, .gas = 100_000 } });
        try testing.expect(result.success);
        try testing.expectEqual(@as(u256, 0), try r1Word(result.output)); // the precompile call failed
        try testing.expectEqual(!precompile.equals(ripemd), vm.balances.contains(precompile));
    }
}

/// Fails exactly one allocator request (allocation, resize or remap), then behaves normally.
const R2SingleFaultAllocator = struct {
    child: std.mem.Allocator,
    fail_at: usize,
    requests: usize = 0,
    faulted: bool = false,

    fn allocator(self: *R2SingleFaultAllocator) std.mem.Allocator {
        return .{ .ptr = self, .vtable = &.{ .alloc = alloc, .resize = resize, .remap = remap, .free = free } };
    }

    fn shouldFail(self: *R2SingleFaultAllocator) bool {
        const index = self.requests;
        self.requests += 1;
        if (index != self.fail_at) return false;
        self.faulted = true;
        return true;
    }

    fn alloc(ctx: *anyopaque, len: usize, alignment: std.mem.Alignment, ret_addr: usize) ?[*]u8 {
        const self: *R2SingleFaultAllocator = @ptrCast(@alignCast(ctx));
        if (self.shouldFail()) return null;
        return self.child.rawAlloc(len, alignment, ret_addr);
    }

    fn resize(ctx: *anyopaque, memory: []u8, alignment: std.mem.Alignment, new_len: usize, ret_addr: usize) bool {
        const self: *R2SingleFaultAllocator = @ptrCast(@alignCast(ctx));
        if (self.shouldFail()) return false;
        return self.child.rawResize(memory, alignment, new_len, ret_addr);
    }

    fn remap(ctx: *anyopaque, memory: []u8, alignment: std.mem.Alignment, new_len: usize, ret_addr: usize) ?[*]u8 {
        const self: *R2SingleFaultAllocator = @ptrCast(@alignCast(ctx));
        if (self.shouldFail()) return null;
        return self.child.rawRemap(memory, alignment, new_len, ret_addr);
    }

    fn free(ctx: *anyopaque, memory: []u8, alignment: std.mem.Alignment, ret_addr: usize) void {
        const self: *R2SingleFaultAllocator = @ptrCast(@alignCast(ctx));
        self.child.rawFree(memory, alignment, ret_addr);
    }
};

test "R2 create: a CREATE that reports failure has committed nothing, whichever allocation fails" {
    const testing = std.testing;
    // LOG0(0, 70000) forces the result's log copy to need fresh memory; then deploy one byte.
    const init_code = [_]u8{ 0x62, 0x01, 0x11, 0x70, 0x60, 0x00, 0xa0, 0x60, 0x01, 0x60, 0x00, 0xf3 };

    var failures_seen: usize = 0;
    var fail_at: usize = 0;
    while (true) : (fail_at += 1) {
        try testing.expect(fail_at < 5_000);
        var faulty = R2SingleFaultAllocator{ .child = testing.allocator, .fail_at = fail_at };

        var vm: Evm = undefined;
        vm.init(faulty.allocator(), null, .CANCUN, null, r1_caller, 0, null) catch continue;
        defer vm.deinit();
        vm.balances.put(r1_caller, 100) catch continue;
        vm.nonces.put(r1_caller, 1) catch continue;

        const result = vm.call(.{ .create = .{ .caller = r1_caller, .value = 5, .init_code = &init_code, .gas = 3_000_000 } });
        const created = try vm.computeCreateAddress(r1_caller, 0);
        if (result.success) {
            try testing.expectEqual(@as(usize, 1), vm.get_raw_code(created).len);
            try testing.expectEqual(@as(u256, 5), r1Balance(&vm, created));
            try testing.expectEqual(@as(usize, 1), result.logs.len);
        } else {
            // No code, no nonce, no endowment and no burned ETH behind a failed result.
            failures_seen += 1;
            try testing.expectEqual(@as(usize, 0), vm.get_raw_code(created).len);
            try testing.expectEqual(@as(u64, 0), vm.getNonce(created));
            try testing.expectEqual(@as(u256, 0), r1Balance(&vm, created));
            try testing.expectEqual(@as(u256, 100), r1Balance(&vm, r1_caller));
        }
        if (!faulty.faulted) break;
    }
    try testing.expect(failures_seen > 0);
}

// ---- Round 3: injector cache vs rollback, teardown rollback, code visibility, commit atomicity ----

// SSTORE(5, 7) with its operands pushed twice (valid whether the handler probes the slot
// before or after popping).
const r3_store_slot5_7 = [_]u8{ 0x60, 0x07, 0x60, 0x05, 0x60, 0x07, 0x60, 0x05, 0x55 };
// SLOAD(5); MSTORE(0); RETURN(0, 32)
const r3_return_slot5 = [_]u8{ 0x60, 0x05, 0x54, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
// EXTCODESIZE(ADDRESS); MSTORE(0); RETURN(0, 32). Ten bytes long.
const r3_own_code_size = [_]u8{ 0x30, 0x3b, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };

/// Run `code` at `r1_contract` asynchronously; the host holds slot 5 = 5.
fn r3RunAsync(vm: *Evm, code: []const u8) !Evm.CallOrContinueOutput {
    var host = R2AsyncHost{ .slots = &.{.{ .address = r1_contract, .slot = 5, .value = 5 }} };
    vm.setBytecode(code);
    return host.drive(vm, try vm.callOrContinue(.{ .call = r2CallParams(0) }));
}

/// SLOAD(5) through the synchronous entry point.
fn r3SyncSlot5(vm: *Evm) !u256 {
    vm.setBytecode(&r3_return_slot5);
    const result = vm.call(r2CallParams(0));
    try std.testing.expect(result.success);
    return r1Word(result.output);
}

test "R3-001: a reverted async SSTORE does not resurface in the next synchronous transaction" {
    const testing = std.testing;

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .OSAKA, null, r1_caller, 0, null);
    defer vm.deinit();
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    vm.pending_storage_injector = &injector;

    // The host supplies the original value 5; the transaction writes 7 and reverts.
    const reverted = try r3RunAsync(&vm, &(r3_store_slot5_7 ++ [_]u8{ 0x60, 0x00, 0x60, 0x00, 0xfd }));
    try testing.expect(reverted == .result);
    try testing.expect(!reverted.result.success);
    try testing.expectEqual(@as(u256, 5), vm.storage.peek(r1_contract, 5));
    // The fetch cache still holds what the host holds.
    try testing.expectEqual(@as(u256, 5), injector.getStorageFromCache(r1_contract, 5).?);

    // The next transaction, on the synchronous entry, reads the original.
    try testing.expectEqual(@as(u256, 5), try r3SyncSlot5(&vm));
    try testing.expectEqual(@as(u256, 5), try r3SyncSlot5(&vm));

    // Same after an exceptional halt...
    const halted = try r3RunAsync(&vm, &(r3_store_slot5_7 ++ [_]u8{0xfe}));
    try testing.expect(halted == .result and !halted.result.success);
    try testing.expectEqual(@as(u256, 5), try r3SyncSlot5(&vm));

    // ...and after a transaction cancelled while suspended: SSTORE(5, 7), then SLOAD(6).
    vm.setBytecode(&(r3_store_slot5_7 ++ [_]u8{ 0x60, 0x06, 0x54, 0x00 }));
    const first = try vm.callOrContinue(.{ .call = r2CallParams(0) });
    try testing.expect(first == .need_storage);
    const second = try vm.callOrContinue(.{ .continue_with_storage = .{ .address = r1_contract, .slot = 5, .value = 5 } });
    try testing.expect(second == .need_storage);
    try testing.expectEqual(@as(u256, 6), second.need_storage.slot);
    try testing.expectEqual(@as(u256, 7), vm.storage.peek(r1_contract, 5));
    try testing.expectEqual(@as(u256, 5), try r3SyncSlot5(&vm));
    try testing.expectEqual(@as(usize, 0), injector.dirty_storage.count());
}

test "R3-001: a committed async SSTORE is what the next synchronous transaction reads" {
    const testing = std.testing;

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .OSAKA, null, r1_caller, 0, null);
    defer vm.deinit();
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    vm.pending_storage_injector = &injector;

    const committed = try r3RunAsync(&vm, &(r3_store_slot5_7 ++ [_]u8{0x00}));
    try testing.expect(committed == .ready_to_commit);
    try testing.expect(std.mem.indexOf(u8, committed.ready_to_commit.changes_json, "\"originalValue\":\"0x5\",\"newValue\":\"0x7\"") != null);
    try testing.expectEqual(@as(u256, 7), injector.getStorageFromCache(r1_contract, 5).?);
    try testing.expect((try vm.callOrContinue(.{ .continue_after_commit = {} })).result.success);

    // Acknowledged or not, the committed value is the one later transactions see.
    try testing.expectEqual(@as(u256, 7), try r3SyncSlot5(&vm));
    try testing.expectEqual(@as(u256, 7), try r3SyncSlot5(&vm));

    // A synchronous write that reverts leaves it alone: SSTORE(5, 7 -> 9); REVERT.
    vm.setBytecode(&[_]u8{ 0x60, 0x09, 0x60, 0x05, 0x55, 0x60, 0x00, 0x60, 0x00, 0xfd });
    try testing.expect(!vm.call(r2CallParams(0)).success);
    try testing.expectEqual(@as(u256, 7), try r3SyncSlot5(&vm));
}

test "R3-002: deinit rolls back a suspended async transaction on an external host" {
    const testing = std.testing;
    // SSTORE(1, 9) through the host, then SLOAD(0) suspends.
    const code = [_]u8{ 0x60, 0x09, 0x60, 0x01, 0x55, 0x60, 0x00, 0x54, 0x00 };

    var backing: R1Host = undefined;
    backing.init(testing.allocator);
    defer backing.deinit();
    try backing.balances.put(r1_caller, 10);
    try backing.balances.put(r1_contract, 20);
    try backing.storage.put(.{ .address = r1_contract.bytes, .slot = 1 }, 4);
    try backing.code.put(r1_contract, &code);

    var injector = try StorageInjector.init(testing.allocator);
    {
        var vm: Evm = undefined;
        try vm.init(testing.allocator, backing.interface(), .CANCUN, null, r1_caller, 0, null);
        vm.pending_storage_injector = &injector;

        var output = try vm.callOrContinue(.{ .call = r2CallParams(1) });
        try testing.expect(output == .need_storage);
        try testing.expectEqual(@as(u256, 1), output.need_storage.slot);
        output = try vm.callOrContinue(.{ .continue_with_storage = .{ .address = r1_contract, .slot = 1, .value = 4 } });
        try testing.expect(output == .need_storage);
        try testing.expectEqual(@as(u256, 0), output.need_storage.slot);

        // The suspended transaction has written to the host.
        try testing.expectEqual(@as(u256, 9), backing.balances.get(r1_caller).?);
        try testing.expectEqual(@as(u256, 21), backing.balances.get(r1_contract).?);
        try testing.expectEqual(@as(u256, 9), backing.storage.get(.{ .address = r1_contract.bytes, .slot = 1 }).?);

        // The embedder frees its injector first; teardown must not touch it.
        injector.deinit();
        vm.deinit();
    }

    try testing.expectEqual(@as(u256, 10), backing.balances.get(r1_caller).?);
    try testing.expectEqual(@as(u256, 20), backing.balances.get(r1_contract).?);
    try testing.expectEqual(@as(u256, 4), backing.storage.get(.{ .address = r1_contract.bytes, .slot = 1 }).?);
}

test "R3-005: supplied bytecode is the target's account code on both entries, for one call only" {
    const testing = std.testing;

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .OSAKA, null, r1_caller, 0, null);
    defer vm.deinit();

    // Synchronous and async entries agree on EXTCODESIZE(ADDRESS).
    vm.setBytecode(&r3_own_code_size);
    const sync_result = vm.call(r2CallParams(0));
    try testing.expect(sync_result.success);
    try testing.expectEqual(@as(u256, r3_own_code_size.len), try r1Word(sync_result.output));
    try testing.expect(!vm.code.contains(r1_contract));
    try testing.expect(vm.async_code_view == null);

    vm.setBytecode(&r3_own_code_size);
    const async_result = try vm.callOrContinue(.{ .call = r2CallParams(0) });
    try testing.expectEqual(@as(u256, r3_own_code_size.len), try r1Word(async_result.result.output));
    try testing.expect(!vm.code.contains(r1_contract));

    // A self-reentrant CALL runs the supplied code: depth 1 returns its CALLVALUE marker.
    // if CALLVALUE == 0: CALL(self, value 1) and return the callee's word; else return 0x2a.
    const reenter = [_]u8{ 0x34, 0x60, 0x2c, 0x57 } ++ // CALLVALUE; PUSH1 44; JUMPI
        [_]u8{ 0x60, 0x20, 0x60, 0x00, 0x60, 0x00, 0x60, 0x00, 0x60, 0x01, 0x30, 0x61, 0xff, 0xff, 0xf1, 0x50 } ++
        [_]u8{ 0x60, 0x20, 0x60, 0x00, 0xf3 } ++ ([_]u8{0x00} ** 19) ++
        [_]u8{ 0x5b, 0x60, 0x2a, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
    try testing.expectEqual(@as(u8, 0x5b), reenter[44]);
    try vm.balances.put(r1_contract, 1);
    vm.setBytecode(&reenter);
    const reentered = vm.call(r2CallParams(0));
    try testing.expect(reentered.success);
    try testing.expectEqual(@as(u256, 0x2a), try r1Word(reentered.output));
    try testing.expect(!vm.code.contains(r1_contract));

    // The view is dropped on failure paths too, and a codeless target stays codeless.
    vm.setBytecode(&[_]u8{0xfe});
    try testing.expect(!vm.call(r2CallParams(0)).success);
    try testing.expect(!vm.code.contains(r1_contract));
    const empty = vm.call(r2CallParams(0));
    try testing.expect(empty.success);
    try testing.expectEqual(@as(usize, 0), empty.output.len);

    // Installed code is never replaced or removed by supplied bytecode.
    const installed = [_]u8{ 0x60, 0x07, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
    try vm.code.put(r1_contract, &installed);
    vm.setBytecode(&r3_own_code_size);
    try testing.expectEqual(@as(u256, 7), try r1Word(vm.call(r2CallParams(0)).output));
    try testing.expectEqualSlices(u8, &installed, vm.code.get(r1_contract).?);
}

test "R3-009: an allocation failure while preparing the async commit rolls the transaction back" {
    const testing = std.testing;
    // The target self-destructs to r1_other, so the commit has deletions to apply.
    const destructing = [_]u8{0x73} ++ r1_other.bytes ++ [_]u8{0xff};

    var failures_seen: usize = 0;
    var commits_seen: usize = 0;
    var fail_at: usize = 0;
    while (true) : (fail_at += 1) {
        try testing.expect(fail_at < 5_000);
        var faulty = R2SingleFaultAllocator{ .child = testing.allocator, .fail_at = fail_at };

        var vm: Evm = undefined;
        vm.init(faulty.allocator(), null, .SHANGHAI, null, r1_caller, 0, null) catch continue;
        defer vm.deinit();
        var injector = StorageInjector.init(faulty.allocator()) catch continue;
        defer injector.deinit();
        vm.pending_storage_injector = &injector;
        vm.balances.put(r1_caller, 100) catch continue;
        vm.balances.put(r1_contract, 20) catch continue;
        vm.balances.put(r1_other, 0) catch continue;

        var host = R2AsyncHost{};
        vm.setBytecode(&destructing);
        const outcome: anyerror!Evm.CallOrContinueOutput = blk: {
            const first = vm.callOrContinue(.{ .call = r2CallParams(7) }) catch |err| break :blk err;
            break :blk host.drive(&vm, first);
        };

        // An allocation failure surfaces as an error or, inside an opcode, as an
        // exceptional halt. Either way nothing of the transaction may remain.
        const committed = if (outcome) |output| output == .ready_to_commit else |_| false;
        if (committed) {
            // Offered for commit: the local state is the committed one.
            const output = try outcome;
            commits_seen += 1;
            try testing.expectEqual(@as(u256, 93), r1Balance(&vm, r1_caller));
            try testing.expectEqual(@as(u256, 27), r1Balance(&vm, r1_other));
            try testing.expect(!vm.balances.contains(r1_contract));
            try testing.expect(std.mem.indexOf(u8, output.ready_to_commit.changes_json, "\"selfDestructs\":[\"0x") != null);
        } else {
            if (outcome) |output| try testing.expect(output == .result and !output.result.success) else |_| {}
            failures_seen += 1;
            try testing.expectEqual(@as(u256, 100), r1Balance(&vm, r1_caller));
            try testing.expectEqual(@as(u256, 20), r1Balance(&vm, r1_contract));
            try testing.expectEqual(@as(u256, 0), r1Balance(&vm, r1_other));
            // No change set is readable and nothing is left to continue.
            try testing.expectEqual(@as(usize, 0), vm.getPendingStateChanges().len);
            try testing.expectEqual(AsyncPhase.idle, vm.async_executor.?.phase);
            try testing.expectEqual(@as(usize, 0), injector.dirty_balances.count());
        }
        if (!faulty.faulted) break;
    }
    try testing.expect(failures_seen > 0);
    try testing.expect(commits_seen > 0);
}

test "R3-009: the prepared commit JSON describes the state after end-of-transaction deletions" {
    const testing = std.testing;
    // SSTORE(5, 7), then SELFDESTRUCT to r1_other: the deletion zeroes the slot in the dump.
    const code = r3_store_slot5_7 ++ [_]u8{0x73} ++ r1_other.bytes ++ [_]u8{0xff};

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .SHANGHAI, null, r1_caller, 0, null);
    defer vm.deinit();
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    vm.pending_storage_injector = &injector;
    try vm.balances.put(r1_caller, 100);
    try vm.balances.put(r1_contract, 20);
    try vm.balances.put(r1_other, 0);

    var host = R2AsyncHost{ .slots = &.{.{ .address = r1_contract, .slot = 5, .value = 5 }} };
    vm.setBytecode(&code);
    const output = try host.drive(&vm, try vm.callOrContinue(.{ .call = r2CallParams(7) }));
    try testing.expect(output == .ready_to_commit);
    const json = output.ready_to_commit.changes_json;

    // The buffer was reserved before the deletion (slot values 0x5 and 0x7), the JSON
    // was written after it, and the two agree on the size bound.
    try testing.expect(json.len <= vm.pending_state_changes_buffer.len);
    try testing.expectEqual(vm.pending_state_changes_buffer.ptr, json.ptr);
    try testing.expectEqualSlices(u8, json, vm.getPendingStateChanges());

    var parsed = try std.json.parseFromSlice(std.json.Value, testing.allocator, json, .{});
    defer parsed.deinit();
    const root = parsed.value.object;
    // The deleted account: listed once, its written slot reads zero, no balance entry.
    const destroyed = root.get("selfDestructs").?.array.items;
    try testing.expectEqual(@as(usize, 1), destroyed.len);
    try testing.expectEqualStrings("0x" ++ "c0" ** 20, destroyed[0].string);
    const slots = root.get("storage").?.array.items;
    try testing.expectEqual(@as(usize, 1), slots.len);
    try testing.expectEqualStrings("0x5", slots[0].object.get("slot").?.string);
    try testing.expectEqualStrings("0x0", slots[0].object.get("newValue").?.string);
    const balances = root.get("balances").?.array.items;
    try testing.expectEqual(@as(usize, 2), balances.len);
    for (balances) |entry| {
        const address = entry.object.get("address").?.string;
        const expected = if (std.mem.eql(u8, address, "0x" ++ "b0" ** 20)) "0x1b" else "0x5d";
        try testing.expectEqualStrings(expected, entry.object.get("balance").?.string);
    }
    try testing.expectEqual(@as(usize, 0), root.get("codes").?.array.items.len);

    // The injector cache follows the commit: the slot of the deleted account is zero.
    try testing.expectEqual(@as(u256, 0), injector.getStorageFromCache(r1_contract, 5).?);
}

test "R3-015: result_allocator keeps synchronous results out of the long-lived arena" {
    const testing = std.testing;
    // LOG0(0, 32); RETURN(0, 1024)
    const code = [_]u8{ 0x60, 0x20, 0x60, 0x00, 0xa0, 0x61, 0x04, 0x00, 0x60, 0x00, 0xf3 };

    var vm: Evm = undefined;
    try vm.init(testing.allocator, null, .CANCUN, null, r1_caller, 0, null);
    defer vm.deinit();
    var results = std.heap.ArenaAllocator.init(testing.allocator);
    defer results.deinit();
    vm.result_allocator = results.allocator();

    var after_warmup: usize = 0;
    var i: usize = 0;
    while (i < 200) : (i += 1) {
        _ = results.reset(.retain_capacity);
        vm.setBytecode(&code);
        const result = vm.call(r2CallParams(0));
        try testing.expect(result.success);
        try testing.expectEqual(@as(usize, 1024), result.output.len);
        try testing.expectEqual(@as(usize, 1), result.logs.len);
        if (i == 8) after_warmup = vm.arena.queryCapacity();
        if (i > 8) try testing.expectEqual(after_warmup, vm.arena.queryCapacity());
    }
}
