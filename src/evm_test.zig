// Tests for evm.zig - moved from inline tests
const std = @import("std");
const primitives = @import("voltaire");
const errors = @import("errors.zig");
const evm = @import("evm.zig");
const storage = @import("storage.zig");
const Evm = evm.Evm(.{}); // Default config
const StorageInjector = @import("storage_injector.zig").StorageInjector;
const AsyncDataRequest = storage.AsyncDataRequest;

test "configured stack, memory, message depth, opcode quota, and deployment limits" {
    const testing = std.testing;
    const LimitedEvm = evm.Evm(.{
        .hardfork = .SHANGHAI,
        .stack_size = 7,
        .memory_limit = 32,
        .max_call_depth = 0,
        .loop_quota = 16,
        .max_bytecode_size = 1,
        .max_initcode_size = 4,
    });
    const root = primitives.Address.fromU256(0x100);
    const child = primitives.Address.fromU256(0x200);
    var instance: LimitedEvm = undefined;
    try instance.init(testing.allocator, null, null, null, root, 0, null);
    defer instance.deinit();
    try testing.expectEqual(primitives.Hardfork.SHANGHAI, instance.hardfork);
    const call: LimitedEvm.CallParams = .{ .call = .{ .caller = root, .to = root, .value = 0, .input = &.{}, .gas = 100_000 } };

    const failures = [_]struct { code: []const u8, name: []const u8 }{
        .{ .code = &(.{0x5f} ** 8), .name = "StackOverflow" },
        .{ .code = &.{ 0x5f, 0x60, 32, 0x52 }, .name = "OutOfGas" },
        .{ .code = &(.{0x5b} ** 17), .name = "ExecutionTimeout" },
    };
    for (failures) |failure| {
        const result = instance.callWithBytecodeOverride(call, failure.code);
        try testing.expect(!result.success);
        try testing.expectEqualStrings(failure.name, result.error_info.?);
    }
    try testing.expect(instance.callWithBytecodeOverride(call, &(.{0x5b} ** 16)).success);

    // CALL into an existing child, then return the CALL success flag.
    try instance.code.put(child, &.{0x00});
    const call_child = &.{ 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x61, 0x02, 0x00, 0x61, 0xff, 0xff, 0xf1, 0x5f, 0x52, 0x60, 32, 0x5f, 0xf3 };
    const blocked_child = instance.callWithBytecodeOverride(call, call_child);
    try testing.expect(blocked_child.success);
    try testing.expectEqualSlices(u8, &([_]u8{0} ** 32), blocked_child.output);

    var create: LimitedEvm.CallParams = .{ .create = .{
        .caller = root,
        .value = 0,
        .init_code = &.{ 0x60, 2, 0x5f, 0xf3 },
        .gas = 100_000,
    } };
    const oversized_code = instance.call(create);
    try testing.expect(!oversized_code.success);
    try testing.expectEqualStrings("CreateContractSizeLimit", oversized_code.error_info.?);

    create.create.init_code = &.{ 0x60, 1, 0x5f, 0xf3, 0x00 };
    const oversized_initcode = instance.call(create);
    try testing.expect(!oversized_initcode.success);
    try testing.expectEqualStrings("InvalidInitCodeSize", oversized_initcode.error_info.?);
    try testing.expectError(error.OutOfGas, instance.inner_create(0, create.create.init_code, 100_000, null));

    create.create.init_code = &.{ 0x60, 1, 0x5f, 0xf3 };
    const deployed = instance.call(create);
    try testing.expect(deployed.success);
    try testing.expectEqualSlices(u8, &.{0}, instance.getRawCode(deployed.created_address.?));
}

test "top-level initcode above EIP-3860 size limit is valid before Shanghai" {
    const testing = std.testing;
    const sender = primitives.Address.fromU256(0x100);
    const code = [_]u8{0} ** 49153;
    const params: Evm.CallParams = .{ .create = .{ .caller = sender, .value = 0, .init_code = &code, .gas = 100_000 } };
    for ([_]primitives.Hardfork{ .MERGE, .SHANGHAI }) |fork| {
        var instance: Evm = undefined;
        try instance.init(testing.allocator, null, fork, null, sender, 0, null);
        defer instance.deinit();
        const result = instance.call(params);
        try testing.expectEqual(fork == .MERGE, result.success);
        if (fork == .SHANGHAI) try testing.expectEqualStrings("InvalidInitCodeSize", result.error_info.?);
    }
}

test "transaction startup preserves state and resets storage refund accounting" {
    const testing = std.testing;
    const address = primitives.Address.fromU256(0x100);
    var instance: Evm = undefined;
    try instance.init(testing.allocator, null, .PRAGUE, null, address, 0, null);
    defer instance.deinit();
    try instance.storage.storage.put(.{ .address = address.bytes, .slot = 0 }, 42);
    try instance.balances.put(address, 42);
    try instance.nonces.put(address, 42);
    try instance.code.put(address, &.{ 0x5f, 0x5f, 0x55, 0x00 }); // SSTORE(0, 0)
    const params: Evm.CallParams = .{ .call = .{ .caller = address, .to = address, .value = 0, .input = &.{}, .gas = 100_000 } };

    const first = instance.call(params);
    try testing.expect(first.success);
    try testing.expect(first.refund_counter > 0);
    try testing.expectEqual(@as(u256, 42), instance.storage.get_original(address, 0));

    const second = instance.call(params);
    try testing.expect(second.success);
    try testing.expectEqual(@as(u64, 0), second.refund_counter);
    try testing.expectEqual(@as(u256, 0), instance.storage.get_original(address, 0));
    try testing.expectEqual(@as(u256, 42), instance.get_balance(address));
    try testing.expectEqual(@as(u64, 42), instance.getNonce(address));
}

test "P256VERIFY is pre-warmed at transaction start from Osaka" {
    const testing = std.testing;
    const Address = primitives.Address;
    const gas = primitives.GasConstants;
    const origin = Address.fromU256(0x200);
    const target = Address.fromU256(0x201);

    for ([_]primitives.Hardfork{ .CANCUN, .PRAGUE, .OSAKA }) |fork| {
        var instance: Evm = undefined;
        try instance.init(testing.allocator, null, fork, null, origin, 0, null);
        defer instance.deinit();
        try instance.initTransactionState(null);
        try instance.preWarmTransaction(target);

        const expected = if (fork == .OSAKA) gas.WarmStorageReadCost else gas.ColdAccountAccessCost;
        try testing.expectEqual(expected, try instance.accessAddress(Address.fromU256(0x0100)));
        try testing.expectEqual(gas.ColdAccountAccessCost, try instance.accessAddress(Address.fromU256(0x00ff)));
        try testing.expectEqual(gas.ColdAccountAccessCost, try instance.accessAddress(Address.fromU256(0x0101)));
        try testing.expectEqual(gas.WarmStorageReadCost, try instance.accessAddress(Address.fromU256(0x01)));
    }
}

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

test "injected SSTORE shadows cached state for SLOAD and the state-change dump" {
    const allocator = std.testing.allocator;
    const address = primitives.Address.fromU256(0x123);
    var injector = try StorageInjector.init(allocator);
    defer injector.deinit();
    var instance: Evm = undefined;
    try instance.init(allocator, null, .CANCUN, null, address, 0, null);
    defer instance.deinit();
    instance.pending_storage_injector = &injector;

    // SSTORE(slot=0, new), SLOAD(0), MSTORE(0, value), RETURN(0, 32).
    for ([_]u8{ 2, 0 }) |new_value| {
        try injector.cacheStorage(address, 0, 1);
        const code = [_]u8{ 0x60, new_value, 0x5f, 0x55, 0x5f, 0x54, 0x5f, 0x52, 0x60, 32, 0x5f, 0xf3 };
        try instance.code.put(address, &code);
        const result = instance.call(.{ .call = .{
            .caller = address,
            .to = address,
            .value = 0,
            .input = &.{},
            .gas = 100_000,
        } });
        try std.testing.expect(result.success);
        try std.testing.expectEqual(@as(usize, 32), result.output.len);
        try std.testing.expectEqual(new_value, result.output[31]);
        try std.testing.expectEqual(@as(u256, 1), instance.storage.get_original(address, 0));

        const dump = try injector.dumpChanges(&instance);
        defer allocator.free(dump);
        const parsed = try std.json.parseFromSlice(std.json.Value, allocator, dump, .{});
        defer parsed.deinit();
        const change = parsed.value.object.get("storage").?.array.items[0].object;
        try std.testing.expectEqualStrings("0x1", change.get("originalValue").?.string);
        try std.testing.expectEqualStrings(if (new_value == 0) "0x0" else "0x2", change.get("newValue").?.string);
    }

    try instance.setBalanceWithSnapshot(address, 17);
    try instance.setNonceWithSnapshot(address, 3);
    try instance.setCodeWithSnapshot(address, &.{ 0x5f, 0x00 });
    const dump = try injector.dumpChanges(&instance);
    defer allocator.free(dump);
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, dump, .{});
    defer parsed.deinit();
    try std.testing.expectEqualStrings("0x11", parsed.value.object.get("balances").?.array.items[0].object.get("balance").?.string);
    try std.testing.expectEqualStrings("0x3", parsed.value.object.get("nonces").?.array.items[0].object.get("nonce").?.string);
    try std.testing.expectEqualStrings("0x5f00", parsed.value.object.get("codes").?.array.items[0].object.get("code").?.string);
}

test "inspector observes transaction boundaries, active bytecode and attempted memory gas" {
    const inspector = @import("inspector.zig");
    const trace = @import("trace.zig");
    const target = comptime primitives.Address.fromU256(0x123);
    const code = [_]u8{ 0x60, 42, 0x5f, 0x52, 0x5f, 0x00 };
    const Probe = struct {
        evm: *Evm,
        started: bool = false,
        tx_failed: bool = false,
        entered: bool = false,
        exited: bool = false,
        opcode: bool = false,
        fault: ?inspector.OpcodeEndEvent = null,

        fn start(ptr: *anyopaque, event: inspector.TxStartEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            self.started = event.target.equals(target) and event.gas_limit == 9;
        }
        fn end(ptr: *anyopaque, event: inspector.TxEndEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            self.tx_failed = !event.success and event.gas_used == 9 and std.mem.eql(u8, event.error_name.?, "out of gas");
        }
        fn enter(ptr: *anyopaque, event: inspector.FrameEnterEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            self.entered = self.started and event.frame_id == 0 and event.parent_id == null and event.depth == 1 and std.mem.eql(u8, event.code, &code);
        }
        fn exit(ptr: *anyopaque, event: inspector.FrameExitEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            self.exited = self.fault != null and event.frame_id == 0 and event.reverted and event.gas_left == 0;
        }
        fn op(ptr: *anyopaque, event: inspector.OpcodeEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            self.opcode = self.entered and event.op == 0x52 and event.pc == 3 and
                event.frame_id == 0 and event.memory.?.len == 0 and
                std.mem.eql(u256, event.stack, &.{ 42, 0 }) and std.mem.eql(u8, self.evm.getBytecode(), &code);
        }
        fn onFault(ptr: *anyopaque, event: inspector.OpcodeEndEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            self.fault = event;
        }

        const vtable: inspector.Inspector.VTable = .{
            .onTxStart = start,
            .onTxEnd = end,
            .onEnter = enter,
            .onExit = exit,
            .onOpcode = op,
            .onFault = onFault,
        };
    };
    var instance: Evm = undefined;
    try instance.init(std.testing.allocator, null, .CANCUN, null, target, 0, null);
    defer instance.deinit();
    var tracer = trace.Tracer.init(std.testing.allocator);
    defer tracer.deinit();
    tracer.enable();
    tracer.config.disable_memory = true;
    instance.setTracer(&tracer);
    var probe: Probe = .{ .evm = &instance };
    instance.setInspector(.{
        .ptr = &probe,
        .vtable = &Probe.vtable,
        .capture_memory = true,
        .opcode_mask = inspector.OpcodeMask.fromOpcodes(&.{0x52}),
    });
    try instance.code.put(target, &code);
    const failed = instance.call(.{ .call = .{ .caller = target, .to = target, .value = 0, .input = &.{}, .gas = 9 } });
    try std.testing.expect(!failed.success);
    try std.testing.expect(probe.opcode);
    try std.testing.expect(probe.exited);
    try std.testing.expectEqual(@as(u64, 6), probe.fault.?.gas_cost);
    try std.testing.expectEqual(@as(u64, 3), probe.fault.?.memory_expansion_gas);
    try std.testing.expect(probe.tx_failed);
    try std.testing.expectEqualStrings("out of gas", tracer.entries.items[2].error_msg.?);
    try std.testing.expectEqual(@as(usize, 3), tracer.entries.items.len);
    try std.testing.expectEqualSlices(u8, &.{}, instance.getBytecode());

    instance.clearInspector();
    try instance.code.put(target, &code);
    const success = instance.call(.{ .call = .{ .caller = target, .to = target, .value = 0, .input = &.{}, .gas = 100 } });
    try std.testing.expect(success.success);
    try std.testing.expectEqual(@as(usize, 32), tracer.entries.items[6].memSize);
    try std.testing.expect(tracer.entries.items[6].memory == null);
}

test "inspector traces forwarded CALL gas, delegated reverts, precompile and empty frames" {
    const inspect = @import("inspector.zig");
    const parent = comptime primitives.Address.fromU256(0x120);
    const delegated_account = comptime primitives.Address.fromU256(0x121);
    const delegated_code = comptime primitives.Address.fromU256(0x122);
    const empty = comptime primitives.Address.fromU256(0x123);
    const precompile = comptime primitives.Address.fromU256(4);
    const Probe = struct {
        enter_count: usize = 0,
        exit_count: usize = 0,
        flags: [3]bool = @splat(false),
        call_costs: [3]u64 = @splat(0),
        call_count: usize = 0,
        reverted: bool = false,

        fn enter(ptr: *anyopaque, event: inspect.FrameEnterEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            std.debug.assert(event.frame_id == self.enter_count);
            self.enter_count += 1;
            if (event.parent_id == null) return;
            std.debug.assert(event.parent_id.? == 0 and event.depth == 2);
            if (event.to.equals(delegated_account)) self.flags[0] = event.is_delegated and event.code_address.equals(delegated_code);
            if (event.to.equals(precompile)) self.flags[1] = event.is_precompile and event.code.len == 0;
            if (event.to.equals(empty)) self.flags[2] = !event.is_precompile and event.code.len == 0;
        }
        fn exit(ptr: *anyopaque, event: inspect.FrameExitEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            self.exit_count += 1;
            if (event.frame_id == 1) self.reverted = event.reverted and std.mem.eql(u8, event.error_name.?, "execution reverted");
        }
        fn opcodeEnd(ptr: *anyopaque, event: inspect.OpcodeEndEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            self.call_costs[self.call_count] = event.gas_cost;
            self.call_count += 1;
        }
        const table: inspect.Inspector.VTable = .{ .onEnter = enter, .onExit = exit, .onOpcodeEnd = opcodeEnd };
    };
    var probe: Probe = .{};
    var instance: Evm = undefined;
    try instance.init(std.testing.allocator, null, .PRAGUE, null, parent, 0, null);
    defer instance.deinit();
    try instance.initTransactionState(null);
    try instance.preWarmTransaction(parent);
    instance.setInspector(.{ .ptr = &probe, .vtable = &Probe.table, .opcode_mask = inspect.OpcodeMask.fromOpcodes(&.{0xfa}) });

    var designation = [_]u8{ 0xef, 0x01, 0 } ++ [_]u8{0} ** 20;
    @memcpy(designation[3..], &delegated_code.bytes);
    try instance.code.put(delegated_account, &designation);
    try instance.code.put(delegated_code, &.{ 0x5f, 0x5f, 0xfd });
    try instance.code.put(parent, &.{
        0x5f, 0x5f, 0x5f, 0x5f, 0x61, 1,    0x21, 0x61, 0x03, 0xe8, 0xfa, 0x50,
        0x5f, 0x5f, 0x5f, 0x5f, 0x60, 4,    0x61, 0x03, 0xe8, 0xfa, 0x50, 0x5f,
        0x5f, 0x5f, 0x5f, 0x61, 1,    0x23, 0x61, 0x03, 0xe8, 0xfa, 0x00,
    });
    const result = instance.inner_call(.{ .call = .{ .caller = parent, .to = parent, .value = 0, .input = &.{}, .gas = 100_000 } });
    try std.testing.expect(result.success);
    try std.testing.expectEqual(@as(usize, 4), probe.enter_count);
    try std.testing.expectEqual(@as(usize, 4), probe.exit_count);
    try std.testing.expectEqual(@as(usize, 3), probe.call_count);
    try std.testing.expectEqualDeep([_]bool{ true, true, true }, probe.flags);
    try std.testing.expectEqualDeep([_]u64{ 3600, 1100, 3600 }, probe.call_costs);
    try std.testing.expect(probe.reverted);
}

test "precompile overrides honor success and reject excess gas at either call boundary" {
    const address = comptime primitives.Address.fromU256(0x200);
    const override = struct {
        fn execute(_: ?*anyopaque, _: std.mem.Allocator, input: []const u8, gas: u64) !@import("evm_config.zig").PrecompileOutput {
            return switch (input[0]) {
                0 => .{ .output = &.{}, .success = false, .gas_used = 1 },
                1 => .{ .output = &.{}, .success = true, .gas_used = gas + 1 },
                else => .{ .output = "ok", .success = true, .gas_used = 1 },
            };
        }
    }.execute;
    const Configured = evm.Evm(.{ .precompile_overrides = &.{.{ .address = address, .execute = override }} });
    var instance: Configured = undefined;
    try instance.init(std.testing.allocator, null, .CANCUN, null, address, 0, null);
    defer instance.deinit();
    for ([_]u8{ 0, 1, 2 }) |mode| {
        const params: Configured.CallParams = .{ .call = .{
            .caller = address,
            .to = address,
            .value = 0,
            .input = &.{mode},
            .gas = 100,
        } };
        const top = instance.call(params);
        const nested = instance.inner_call(params);
        for ([_]Configured.CallResult{ top, nested }) |result| {
            try std.testing.expectEqual(mode == 2, result.success);
            try std.testing.expectEqual(@as(u64, if (mode == 2) 99 else 0), result.gas_left);
            if (mode == 2) try std.testing.expectEqualStrings("ok", result.output);
        }
    }
}

test "CREATE and CREATE2 trace opcode charges separately from child execution" {
    const inspect = @import("inspector.zig");
    const trace = @import("trace.zig");
    const parent = primitives.Address.fromU256(0x120);
    const Probe = struct {
        entered: [2]inspect.CallType = undefined,
        exits: usize = 0,
        entries: usize = 0,

        fn enter(ptr: *anyopaque, event: inspect.FrameEnterEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            if (event.parent_id == null) return;
            std.debug.assert(event.parent_id.? == 0 and event.depth == 2);
            std.debug.assert(std.mem.eql(u8, event.input, &.{ 0x5f, 0x50, 0x00 }));
            self.entered[self.entries] = event.call_type;
            self.entries += 1;
        }
        fn exit(ptr: *anyopaque, event: inspect.FrameExitEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            if (event.parent_id == null) return;
            std.debug.assert(event.created_address != null and !event.reverted and event.gas_used == 4);
            self.exits += 1;
        }
        const table: inspect.Inspector.VTable = .{ .onEnter = enter, .onExit = exit };
    };

    var tracer = trace.Tracer.init(std.testing.allocator);
    defer tracer.deinit();
    tracer.enable();
    var probe: Probe = .{};
    var instance: Evm = undefined;
    try instance.init(std.testing.allocator, null, .CANCUN, null, parent, 0, null);
    defer instance.deinit();
    instance.setTracer(&tracer);
    instance.setInspector(.{ .ptr = &probe, .vtable = &Probe.table });
    try instance.code.put(parent, &.{
        0x63, 0x5f, 0x50, 0, 0, 0x5f, 0x52, // Write PUSH0 POP STOP to byte 28.
        0x60, 3, 0x60, 28, 0x5f, 0xf0, // CREATE(length=3, offset=28, value=0).
        0x60, 1, 0x60, 3, 0x60, 28, 0x5f, 0xf5, // The same CREATE2 with salt 1.
        0x00,
    });
    const result = instance.call(.{ .call = .{ .caller = parent, .to = parent, .value = 0, .input = &.{}, .gas = 100_000 } });
    try std.testing.expect(result.success);
    try std.testing.expectEqual(@as(usize, 2), probe.entries);
    try std.testing.expectEqual(@as(usize, 2), probe.exits);
    try std.testing.expectEqualSlices(inspect.CallType, &.{ .create, .create2 }, &probe.entered);
    for (tracer.entries.items) |step| {
        if (step.op == 0xf0) try std.testing.expectEqual(@as(u64, 32_002), step.gasCost);
        if (step.op == 0xf5) try std.testing.expectEqual(@as(u64, 32_008), step.gasCost);
    }
}

test "state hooks report storage, transient slots, logs, balances and SELFDESTRUCT" {
    const inspect = @import("inspector.zig");
    const trace = @import("trace.zig");
    const address = comptime primitives.Address.fromU256(0x242);
    const beneficiary = comptime primitives.Address.fromU256(0x243);
    const Probe = struct {
        storage_count: usize = 0,
        transient_count: usize = 0,
        log_seen: bool = false,
        slot_accesses: usize = 0,
        beneficiary_access: bool = false,
        balance_count: usize = 0,
        selfdestruct_seen: bool = false,

        fn storageEvent(ptr: *anyopaque, event: inspect.StorageChangeEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            std.debug.assert(event.frame_id == 0 and event.address.equals(address) and event.slot == 0);
            std.debug.assert(event.new_value == 42 and event.prev_value == (if (event.is_read) @as(u256, 42) else 0));
            std.debug.assert(event.is_read == (self.storage_count == 1));
            self.storage_count += 1;
        }
        fn transientEvent(ptr: *anyopaque, event: inspect.TransientStorageEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            std.debug.assert(event.frame_id == 0 and event.address.equals(address) and event.slot == 2 and event.value == 0x77);
            std.debug.assert(event.is_write == (self.transient_count == 0));
            self.transient_count += 1;
        }
        fn logEvent(ptr: *anyopaque, event: inspect.LogEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            self.log_seen = event.frame_id == 0 and event.address.equals(address) and
                event.topics.len == 1 and std.mem.readInt(u256, &event.topics[0], .big) == 0x11 and event.data.len == 0;
        }
        fn accessEvent(ptr: *anyopaque, event: inspect.AccessEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            if (event.slot) |slot| {
                std.debug.assert(event.address.equals(address) and slot == 0 and event.was_warm == (self.slot_accesses == 1));
                self.slot_accesses += 1;
            } else if (event.address.equals(beneficiary)) {
                self.beneficiary_access = !event.was_warm;
            }
        }
        fn balanceEvent(ptr: *anyopaque, event: inspect.BalanceChangeEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            std.debug.assert(event.frame_id == 0);
            if (event.address.equals(address)) std.debug.assert(event.prev_balance == 17 and event.new_balance == 0);
            if (event.address.equals(beneficiary)) std.debug.assert(event.prev_balance == 0 and event.new_balance == 17);
            self.balance_count += 1;
        }
        fn selfdestructEvent(ptr: *anyopaque, event: inspect.SelfDestructEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            self.selfdestruct_seen = event.frame_id == 0 and event.address.equals(address) and
                event.beneficiary.equals(beneficiary) and event.value == 17;
        }

        const table: inspect.Inspector.VTable = .{
            .onStorageChange = storageEvent,
            .onTransientStorageChange = transientEvent,
            .onLog = logEvent,
            .onAccess = accessEvent,
            .onBalanceChange = balanceEvent,
            .onSelfDestruct = selfdestructEvent,
        };
    };
    var tracer = trace.Tracer.init(std.testing.allocator);
    defer tracer.deinit();
    tracer.enable();
    var probe: Probe = .{};
    var instance: Evm = undefined;
    try instance.init(std.testing.allocator, null, .CANCUN, null, address, 0, null);
    defer instance.deinit();
    try instance.initTransactionState(null);
    try instance.preWarmTransaction(address);
    try instance.balances.put(address, 17);
    try instance.code.put(address, &.{
        0x60, 42, 0x5f, 0x55, 0x5f, 0x54, 0x50, // SSTORE and SLOAD.
        0x60, 0x77, 0x60, 2, 0x5d, 0x60, 2, 0x5c, 0x50, // TSTORE and TLOAD.
        0x60, 0x11, 0x5f, 0x5f, 0xa1, // LOG1.
        0x61, 2, 0x43, 0xff, // SELFDESTRUCT.
    });
    instance.setTracer(&tracer);
    instance.setInspector(.{ .ptr = &probe, .vtable = &Probe.table });
    const result = instance.inner_call(.{ .call = .{ .caller = address, .to = address, .value = 0, .input = &.{}, .gas = 100_000 } });
    try std.testing.expect(result.success);
    try std.testing.expectEqual(@as(usize, 2), probe.storage_count);
    try std.testing.expectEqual(@as(usize, 2), probe.transient_count);
    try std.testing.expectEqual(@as(usize, 2), probe.slot_accesses);
    try std.testing.expectEqual(@as(usize, 2), probe.balance_count);
    try std.testing.expect(probe.beneficiary_access and probe.log_seen and probe.selfdestruct_seen);
    try std.testing.expectEqualDeep(trace.StorageEntry{ .slot = 0, .value = 42 }, tracer.entries.items[4].storage.?[0]);
}
