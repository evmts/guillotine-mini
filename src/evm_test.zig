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

test "EIP-161 cleanup - touched empty 0x0100 survives on Osaka and is deleted on Prague" {
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

    // Osaka: calling 0x0100 preserves it (active precompile), calling 0x0101 deletes it (empty)
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
    try testing.expect(!osaka_host.deleted_0100);
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
