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
