/// Async execution orchestrator for the EVM
/// Handles yielding for async data requests (storage, balance, code, nonce)
/// and resuming execution when data is provided
///
/// Protocol state machine:
///
///     idle --call--> awaiting_data --matching continue_with_*--> (resume)
///      ^   \                |
///      |    \               +--> awaiting_commit --continue_after_commit--> idle
///      |     \                        ^
///      |      +--success + injector---+
///      +---- revert / exceptional halt / no injector: `.result` directly
///
/// A continuation that does not answer the outstanding request (wrong kind,
/// address or slot, or no request at all) fails with `error.InvalidAsyncState`
/// and leaves all state untouched, so the correct reply can still be sent.
const std = @import("std");
const primitives = @import("voltaire");
const log = @import("logger.zig");
const errors = @import("errors.zig");
const storage_mod = @import("storage.zig");

pub const StorageKey = primitives.State.StorageKey;

/// Async data request - written when cache miss occurs
pub const AsyncDataRequest = union(enum) {
    none: void,
    storage: struct {
        address: primitives.Address,
        slot: u256,
    },
    balance: struct {
        address: primitives.Address,
    },
    code: struct {
        address: primitives.Address,
    },
    nonce: struct {
        address: primitives.Address,
    },
};

/// Where the async protocol currently stands.
pub const AsyncPhase = enum {
    /// No transaction in flight.
    idle,
    /// A frame is suspended until the host answers `async_data_request`.
    awaiting_data,
    /// Execution succeeded; the host must commit, then `continue_after_commit`.
    awaiting_commit,
};

/// AsyncExecutor - manages async execution state and control flow
pub fn AsyncExecutor(comptime EvmType: type, comptime CallParams: type, comptime CallResult: type) type {
    return struct {
        const Self = @This();

        /// Input to callOrContinue - tagged union for starting or continuing execution
        pub const CallOrContinueInput = union(enum) {
            call: CallParams,
            continue_with_storage: struct {
                address: primitives.Address,
                slot: u256,
                value: u256,
            },
            continue_with_balance: struct {
                address: primitives.Address,
                balance: u256,
            },
            continue_with_code: struct {
                address: primitives.Address,
                code: []const u8,
            },
            continue_with_nonce: struct {
                address: primitives.Address,
                nonce: u64,
            },
            continue_after_commit: void,
        };

        /// Output from callOrContinue - tagged union for result or async request
        pub const CallOrContinueOutput = union(enum) {
            result: CallResult,
            need_storage: struct {
                address: primitives.Address,
                slot: u256,
            },
            need_balance: struct {
                address: primitives.Address,
            },
            need_code: struct {
                address: primitives.Address,
            },
            need_nonce: struct {
                address: primitives.Address,
            },
            ready_to_commit: struct {
                changes_json: []const u8,
            },
        };

        /// Value moved by the top-level call, kept so a revert or halt can undo it.
        const Transfer = struct {
            caller: primitives.Address,
            recipient: primitives.Address,
            value: u256,
        };

        /// Reference to parent EVM instance
        evm: *EvmType,

        /// The request the host must answer while `phase == .awaiting_data`.
        /// Mirrors `evm.storage.async_data_request`; both are cleared together.
        async_data_request: AsyncDataRequest,

        /// Protocol phase.
        phase: AsyncPhase,

        /// Terminal result held back until the host acknowledges the commit.
        pending_result: ?CallResult,

        /// Top-level value transfer of the transaction in flight.
        transfer: ?Transfer,

        /// Initialize async executor
        pub fn init(evm: *EvmType) Self {
            return Self{
                .evm = evm,
                .async_data_request = .none,
                .phase = .idle,
                .pending_result = null,
                .transfer = null,
            };
        }

        /// Main async execution method - supports yielding for async requests
        /// CRITICAL: NO defer statements that clean up state!
        pub fn callOrContinue(
            self: *Self,
            input: CallOrContinueInput,
        ) !CallOrContinueOutput {
            switch (input) {
                .call => |params| {
                    return try self.startNewCall(params);
                },

                .continue_with_storage => |data| {
                    const request = try self.outstandingRequest();
                    if (request != .storage) return error.InvalidAsyncState;
                    if (!sameAddress(request.storage.address, data.address) or request.storage.slot != data.slot) {
                        return error.InvalidAsyncState;
                    }

                    // Stores the value in the injector cache and the storage overlay.
                    try self.evm.storage.put_in_cache(data.address, data.slot, data.value);

                    self.clearRequest();
                    return try self.executeUntilYieldOrComplete();
                },

                .continue_with_balance => |data| {
                    const request = try self.outstandingRequest();
                    if (request != .balance) return error.InvalidAsyncState;
                    if (!sameAddress(request.balance.address, data.address)) return error.InvalidAsyncState;

                    if (self.evm.storage.storage_injector) |injector| {
                        try injector.cacheBalance(data.address, data.balance);
                        try injector.noteBaselineBalance(data.address, data.balance);
                    }
                    try self.evm.balances.put(data.address, data.balance);

                    self.clearRequest();
                    return try self.executeUntilYieldOrComplete();
                },

                .continue_with_code => |data| {
                    const request = try self.outstandingRequest();
                    if (request != .code) return error.InvalidAsyncState;
                    if (!sameAddress(request.code.address, data.address)) return error.InvalidAsyncState;

                    if (self.evm.storage.storage_injector) |injector| {
                        // The cache copies with its own allocator and frees that
                        // copy itself; it never takes ownership of arena memory.
                        try injector.cacheCode(data.address, data.code);
                        try injector.noteBaselineCode(data.address, data.code);
                    }

                    // The EVM's code map borrows a transaction-arena copy.
                    const code_copy = try self.evm.arena.allocator().dupe(u8, data.code);
                    try self.evm.code.put(data.address, code_copy);

                    self.clearRequest();
                    return try self.executeUntilYieldOrComplete();
                },

                .continue_with_nonce => |data| {
                    const request = try self.outstandingRequest();
                    if (request != .nonce) return error.InvalidAsyncState;
                    if (!sameAddress(request.nonce.address, data.address)) return error.InvalidAsyncState;

                    if (self.evm.storage.storage_injector) |injector| {
                        try injector.cacheNonce(data.address, data.nonce);
                        try injector.noteBaselineNonce(data.address, data.nonce);
                    }
                    try self.evm.nonces.put(data.address, data.nonce);

                    self.clearRequest();
                    return try self.executeUntilYieldOrComplete();
                },

                .continue_after_commit => {
                    if (self.phase != .awaiting_commit) return error.InvalidAsyncState;
                    const result = self.pending_result orelse return error.InvalidAsyncState;
                    self.pending_result = null;
                    self.phase = .idle;
                    return .{ .result = result };
                },
            }
        }

        fn sameAddress(a: primitives.Address, b: primitives.Address) bool {
            return std.mem.eql(u8, &a.bytes, &b.bytes);
        }

        /// The request a continuation must answer, or InvalidAsyncState when
        /// nothing is suspended.
        fn outstandingRequest(self: *Self) error{InvalidAsyncState}!AsyncDataRequest {
            if (self.phase != .awaiting_data) return error.InvalidAsyncState;
            if (self.async_data_request == .none) return error.InvalidAsyncState;
            return self.async_data_request;
        }

        /// Clear the outstanding request on the executor and on the live
        /// `Storage` field the opcode handlers write to.
        fn clearRequest(self: *Self) void {
            self.async_data_request = .none;
            self.evm.storage.clear_async_request();
            self.phase = .idle;
        }

        /// Drop every trace of the transaction in flight.
        fn resetProtocolState(self: *Self) void {
            self.async_data_request = .none;
            self.evm.storage.clear_async_request();
            self.phase = .idle;
            self.pending_result = null;
            self.transfer = null;
        }

        /// Abandon the transaction after a host-side failure (allocation or
        /// protocol error): nothing stays suspended and nothing is offered for commit.
        fn abort(self: *Self) void {
            self.undoTransfer();
            self.evm.frames.clearRetainingCapacity();
            if (self.evm.storage.storage_injector) |injector| injector.clearDirty();
            self.endTransaction();
            self.resetProtocolState();
        }

        fn effectiveRefund(self: *Self) u64 {
            // Contract A turns Evm.gas_refund into a signed counter read through
            // get_effective_refund(); support both shapes.
            if (@hasDecl(EvmType, "get_effective_refund")) return self.evm.get_effective_refund();
            return self.evm.gas_refund;
        }

        fn failedResult(self: *Self, error_name: ?[]const u8) CallResult {
            const arena = self.evm.arena.allocator();
            if (error_name) |name| {
                if (CallResult.failure_with_error(arena, 0, name)) |result| return result else |_| {}
            }
            return CallResult{ .success = false, .gas_left = 0, .output = &.{} };
        }

        /// Reverse the top-level value transfer after a revert or halt.
        fn undoTransfer(self: *Self) void {
            const transfer = self.transfer orelse return;
            self.transfer = null;
            const h = self.evm.host orelse return;
            h.setBalance(transfer.caller, h.getBalance(transfer.caller) + transfer.value);
            h.setBalance(transfer.recipient, h.getBalance(transfer.recipient) - transfer.value);
        }

        /// Reset transaction-scoped EVM state, as the synchronous `call()` does
        /// when it returns.
        fn endTransaction(self: *Self) void {
            self.evm.access_list_manager.clear();
            self.evm.storage.clear_transient();
            self.evm.logs.clearRetainingCapacity();
            self.evm.created_accounts.clearRetainingCapacity();
            self.evm.selfdestructed_accounts.clearRetainingCapacity();
            self.evm.touched_accounts.clearRetainingCapacity();
        }

        /// Hand a successful result to the host: with an injector the changes
        /// are offered for commit first, otherwise the result is final.
        fn finishSuccess(self: *Self, result: CallResult, changes_json: ?[]const u8) CallOrContinueOutput {
            self.transfer = null;
            if (changes_json) |json| {
                self.pending_result = result;
                self.phase = .awaiting_commit;
                return .{ .ready_to_commit = .{ .changes_json = json } };
            }
            self.phase = .idle;
            return .{ .result = result };
        }

        /// A reverted or halted transaction: the terminal result is returned
        /// directly and no change set is ever offered for commit.
        fn finishFailure(self: *Self, result: CallResult) CallOrContinueOutput {
            self.undoTransfer();
            self.evm.frames.clearRetainingCapacity();
            if (self.evm.storage.storage_injector) |injector| injector.clearDirty();
            self.endTransaction();
            self.resetProtocolState();
            return .{ .result = result };
        }

        /// Run a transaction through the synchronous engine. Used for CREATE and
        /// CREATE2, whose lifecycle (collision checks, constructor context, code
        /// deposit) lives in `Evm.call`. Storage reads inside cannot suspend.
        fn runSynchronously(self: *Self, params: CallParams) !CallOrContinueOutput {
            const injector = self.evm.pending_storage_injector orelse self.evm.storage.storage_injector;
            if (injector) |inj| {
                inj.clearCache();
                try inj.captureBaseline(self.evm);
            }

            const result = self.evm.call(params);
            if (result.success and self.evm.storage.storage_injector != null) {
                const json = try self.evm.dumpStateChanges();
                return self.finishSuccess(result, json);
            }
            if (self.evm.storage.storage_injector) |inj| inj.clearDirty();
            return .{ .result = result };
        }

        /// Start a new call and begin execution
        pub fn startNewCall(self: *Self, params: CallParams) !CallOrContinueOutput {
            const evm = self.evm;

            // A new call abandons whatever was suspended or awaiting commit.
            self.resetProtocolState();

            if (params.isCreate()) return try self.runSynchronously(params);

            params.validate() catch |err| {
                return .{ .result = self.failedResult(@errorName(err)) };
            };

            // Initialize transaction state in EVM. The blob hashes set for this
            // call must survive it (an empty list clears the previous ones).
            const blob_hashes: ?[]const [32]u8 = if (evm.blob_versioned_hashes.len > 0) evm.blob_versioned_hashes else null;
            try evm.initTransactionState(blob_hashes);
            self.async_data_request = .none;

            if (evm.storage.storage_injector) |injector| {
                log.debug("callOrContinue: Storage injector enabled, clearing cache", .{});
                injector.clearCache();
                try injector.captureBaseline(evm);
            } else {
                log.debug("callOrContinue: No storage injector", .{});
            }

            // Extract common parameters (same as call() method)
            const caller = params.getCaller();
            const gas: i64 = @intCast(@min(params.getGas(), @as(u64, std.math.maxInt(i64))));
            const address: primitives.Address = params.get_to().?;

            const value = switch (params) {
                .call => |p| p.value,
                .callcode => |p| p.value,
                .create => |p| p.value,
                .create2 => |p| p.value,
                .delegatecall, .staticcall => 0,
            };

            // A suspended frame outlives this function, and the host may replace
            // its buffers before it continues. Give the frame its own copies.
            const arena = evm.arena.allocator();
            const calldata = try arena.dupe(u8, params.getInput());
            const source_code = if (evm.pending_bytecode.len > 0) evm.pending_bytecode else evm.get_code(address);
            const bytecode = try arena.dupe(u8, source_code);

            try evm.preWarmTransaction(address);

            // Pre-warm access list if present (EIP-2929/EIP-2930). The list is
            // borrowed for this call only; drop the reference so it cannot leak
            // into a later transaction or dangle once the caller frees it.
            if (evm.pending_access_list) |list| {
                evm.pending_access_list = null;
                try evm.access_list_manager.pre_warm_from_access_list(list);
            }

            // Transfer value if needed
            if (value > 0) {
                if (evm.host) |h| {
                    const sender_balance = h.getBalance(caller);
                    if (sender_balance < value) {
                        return self.finishFailure(self.failedResult("InsufficientBalance"));
                    }
                    h.setBalance(caller, sender_balance - value);
                    h.setBalance(address, h.getBalance(address) + value);
                    self.transfer = .{ .caller = caller, .recipient = address, .value = value };
                }
            }

            // Create frame WITHOUT defer (critical!)
            log.debug("callOrContinue: Creating frame with address={any}", .{address.bytes});
            const FrameType = @TypeOf(evm.frames.items[0]);
            const frame = FrameType.init(
                arena,
                bytecode,
                gas,
                caller,
                address,
                value,
                calldata,
                @as(*anyopaque, @ptrCast(evm)),
                evm.hardfork,
                false, // Top-level is never static
            ) catch |err| {
                self.abort();
                return err;
            };
            evm.frames.append(arena, frame) catch |err| {
                self.abort();
                return err;
            };

            // Execute (may yield)
            return try self.executeUntilYieldOrComplete();
        }

        /// Execute the top-level frame until it suspends, halts or completes.
        /// NO defer statements!
        ///
        /// Outcomes:
        ///   - missing data: `.need_*`, frame kept, phase `awaiting_data`
        ///   - success with an injector: `.ready_to_commit`, phase `awaiting_commit`
        ///   - success without an injector: `.result` with output, gas, logs and refund
        ///   - REVERT: `.result` (failure, revert data, remaining gas), nothing to commit
        ///   - exceptional halt (OutOfGas, InvalidOpcode, ...): `.result` (failure,
        ///     zero gas, `error_info`), nothing to commit
        ///   - host allocation failure: an error; the transaction is abandoned
        fn executeUntilYieldOrComplete(self: *Self) !CallOrContinueOutput {
            const evm = self.evm;
            if (evm.frames.items.len == 0) return error.InvalidAsyncState;

            // Don't cache the frame pointer across execute(); nested calls may move it.
            evm.frames.items[evm.frames.items.len - 1].execute() catch |err| {
                if (err == error.NeedAsyncData) {
                    const request = evm.storage.async_data_request;
                    self.async_data_request = request;
                    self.phase = .awaiting_data;
                    return switch (request) {
                        .storage => |req| .{ .need_storage = .{
                            .address = req.address,
                            .slot = req.slot,
                        } },
                        .balance => |req| .{ .need_balance = .{ .address = req.address } },
                        .code => |req| .{ .need_code = .{ .address = req.address } },
                        .nonce => |req| .{ .need_nonce = .{ .address = req.address } },
                        .none => {
                            self.abort();
                            return error.InvalidAsyncState;
                        },
                    };
                }
                if (err == error.OutOfMemory) {
                    self.abort();
                    return err;
                }

                // An exceptional halt is a normal EVM outcome, not a protocol error.
                return self.finishFailure(self.failedResult(@errorName(err)));
            };

            const arena = evm.arena.allocator();
            const frame = &evm.frames.items[evm.frames.items.len - 1];
            const gas_left = @as(u64, @intCast(@max(frame.gas_remaining, 0)));

            if (frame.reverted) {
                const result = CallResult.revert_with_data(arena, gas_left, frame.output) catch |err| {
                    self.abort();
                    return err;
                };
                return self.finishFailure(result);
            }

            var result = CallResult.success_with_logs(arena, gas_left, frame.output, evm.logs.items) catch |err| {
                self.abort();
                return err;
            };
            result.refund_counter = self.effectiveRefund();

            // Dump before the end-of-transaction reset: the dump reads the
            // self-destruct set and the account maps.
            var changes_json: ?[]const u8 = null;
            if (evm.storage.storage_injector != null) {
                log.debug("executeUntilYieldOrComplete: top frame succeeded, dumping changes", .{});
                changes_json = evm.dumpStateChanges() catch |err| {
                    self.abort();
                    return err;
                };
            }

            _ = evm.frames.pop();
            self.endTransaction();
            return self.finishSuccess(result, changes_json);
        }
    };
}

// ============================================================================
// Tests
// ============================================================================

const testing = std.testing;
const TestEvm = @import("evm.zig").Evm(.{});
const StorageInjector = @import("storage_injector.zig").StorageInjector;

const test_address = primitives.Address{ .bytes = [_]u8{0} ** 18 ++ [_]u8{ 0x02, 0x00 } };

fn testCall(gas: u64) TestEvm.CallParams {
    return .{ .call = .{
        .caller = test_address,
        .to = test_address,
        .gas = gas,
        .value = 0,
        .input = &[_]u8{},
    } };
}

// SSTORE(0, 7) with its operands pushed twice. A handler that probes the slot
// before popping (Contract C) leaves the spare pair on the stack; a handler
// that pops before yielding consumes it on resume. The stored value is the
// same either way, so these tests do not depend on which handler is linked.
const sstore_slot0_7 = [_]u8{ 0x60, 0x07, 0x60, 0x00, 0x60, 0x07, 0x60, 0x00, 0x55 };
// SLOAD(0); MSTORE(0); RETURN(0, 32)
const return_slot0 = [_]u8{ 0x60, 0x00, 0x54, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
// REVERT(0, 0)
const revert_empty = [_]u8{ 0x60, 0x00, 0x60, 0x00, 0xfd };

test "AsyncExecutor - SSTORE then SLOAD sees the write and the commit JSON carries the new value" {
    var vm: TestEvm = undefined;
    try vm.init(testing.allocator, null, .OSAKA, null, primitives.ZERO_ADDRESS, 0, null);
    defer vm.deinit();
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    vm.pending_storage_injector = &injector;

    const bytecode = sstore_slot0_7 ++ return_slot0;
    vm.pending_bytecode = &bytecode;

    const yielded = try vm.callOrContinue(.{ .call = testCall(100_000) });
    try testing.expect(yielded == .need_storage);
    try testing.expectEqual(@as(u256, 0), yielded.need_storage.slot);
    try testing.expectEqualSlices(u8, &test_address.bytes, &yielded.need_storage.address.bytes);

    // Host says slot 0 currently holds 5.
    const committed = try vm.callOrContinue(.{ .continue_with_storage = .{ .address = test_address, .slot = 0, .value = 5 } });
    try testing.expect(committed == .ready_to_commit);

    var parsed = try std.json.parseFromSlice(std.json.Value, testing.allocator, committed.ready_to_commit.changes_json, .{});
    defer parsed.deinit();
    const slots = parsed.value.object.get("storage").?.array.items;
    try testing.expectEqual(@as(usize, 1), slots.len);
    try testing.expectEqualStrings("0x0", slots[0].object.get("slot").?.string);
    try testing.expectEqualStrings("0x5", slots[0].object.get("originalValue").?.string);
    try testing.expectEqualStrings("0x7", slots[0].object.get("newValue").?.string);

    const done = try vm.callOrContinue(.{ .continue_after_commit = {} });
    try testing.expect(done == .result);
    try testing.expect(done.result.success);
    try testing.expectEqual(@as(usize, 32), done.result.output.len);
    try testing.expectEqual(@as(u8, 7), done.result.output[31]);

    // The commit acknowledgement is consumed exactly once.
    try testing.expectError(error.InvalidAsyncState, vm.callOrContinue(.{ .continue_after_commit = {} }));
}

test "AsyncExecutor - reverted transaction returns the result and never offers a commit" {
    var vm: TestEvm = undefined;
    try vm.init(testing.allocator, null, .OSAKA, null, primitives.ZERO_ADDRESS, 0, null);
    defer vm.deinit();
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    vm.pending_storage_injector = &injector;

    // SSTORE(0, 7); MSTORE(0, 0xdeadbeef); REVERT(28, 4)
    const bytecode = sstore_slot0_7 ++ [_]u8{ 0x63, 0xde, 0xad, 0xbe, 0xef, 0x60, 0x00, 0x52, 0x60, 0x04, 0x60, 0x1c, 0xfd };
    vm.pending_bytecode = &bytecode;

    const yielded = try vm.callOrContinue(.{ .call = testCall(100_000) });
    try testing.expect(yielded == .need_storage);

    const done = try vm.callOrContinue(.{ .continue_with_storage = .{ .address = test_address, .slot = 0, .value = 5 } });
    try testing.expect(done == .result);
    try testing.expect(!done.result.success);
    try testing.expectEqualSlices(u8, &[_]u8{ 0xde, 0xad, 0xbe, 0xef }, done.result.output);
    try testing.expect(done.result.gas_left > 0);

    // Nothing is pending for the host to commit.
    try testing.expectEqual(@as(usize, 0), injector.dirty_storage.count());
    try testing.expectEqual(@as(usize, 0), vm.getPendingStateChanges().len);
    try testing.expectError(error.InvalidAsyncState, vm.callOrContinue(.{ .continue_after_commit = {} }));
}

test "AsyncExecutor - exceptional halt is a failed result, not a protocol error" {
    var vm: TestEvm = undefined;
    try vm.init(testing.allocator, null, .OSAKA, null, primitives.ZERO_ADDRESS, 0, null);
    defer vm.deinit();
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    vm.pending_storage_injector = &injector;

    // A successful call first, so a stale result would be observable.
    const ok_code = [_]u8{0x00};
    vm.pending_bytecode = &ok_code;
    try testing.expect((try vm.callOrContinue(.{ .call = testCall(100_000) })) == .ready_to_commit);
    try testing.expect((try vm.callOrContinue(.{ .continue_after_commit = {} })).result.success);

    const invalid = [_]u8{0xfe};
    vm.pending_bytecode = &invalid;
    const halted = try vm.callOrContinue(.{ .call = testCall(100_000) });
    try testing.expect(halted == .result);
    try testing.expect(!halted.result.success);
    try testing.expectEqual(@as(u64, 0), halted.result.gas_left);
    try testing.expectEqual(@as(usize, 0), halted.result.output.len);
    try testing.expect(halted.result.error_info != null);
    try testing.expectEqual(@as(usize, 0), vm.frames.items.len);
    try testing.expectError(error.InvalidAsyncState, vm.callOrContinue(.{ .continue_after_commit = {} }));

    // Out of gas takes the same path.
    const add = [_]u8{ 0x60, 0x01, 0x60, 0x01, 0x01, 0x00 };
    vm.pending_bytecode = &add;
    const exhausted = try vm.callOrContinue(.{ .call = testCall(2) });
    try testing.expect(exhausted == .result);
    try testing.expect(!exhausted.result.success);
    try testing.expectEqual(@as(u64, 0), exhausted.result.gas_left);
}

test "AsyncExecutor - without an injector the terminal result keeps output, gas and logs" {
    var vm: TestEvm = undefined;
    try vm.init(testing.allocator, null, .OSAKA, null, primitives.ZERO_ADDRESS, 0, null);
    defer vm.deinit();

    // MSTORE(0, 42); LOG0(0, 32); RETURN(0, 32)
    const bytecode = [_]u8{ 0x60, 0x2a, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xa0, 0x60, 0x20, 0x60, 0x00, 0xf3 };
    vm.pending_bytecode = &bytecode;

    const done = try vm.callOrContinue(.{ .call = testCall(100_000) });
    try testing.expect(done == .result);
    try testing.expect(done.result.success);
    try testing.expectEqual(@as(usize, 32), done.result.output.len);
    try testing.expectEqual(@as(u8, 42), done.result.output[31]);
    try testing.expect(done.result.gas_left > 0 and done.result.gas_left < 100_000);
    try testing.expectEqual(@as(usize, 1), done.result.logs.len);
    try testing.expectEqual(@as(usize, 32), done.result.logs[0].data.len);

    // A revert without an injector keeps its data too.
    const reverting = [_]u8{ 0x60, 0x2a, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xfd };
    vm.pending_bytecode = &reverting;
    const reverted = try vm.callOrContinue(.{ .call = testCall(100_000) });
    try testing.expect(reverted == .result);
    try testing.expect(!reverted.result.success);
    try testing.expectEqual(@as(u8, 42), reverted.result.output[31]);
}

test "AsyncExecutor - continuations must answer the outstanding request" {
    var vm: TestEvm = undefined;
    try vm.init(testing.allocator, null, .OSAKA, null, primitives.ZERO_ADDRESS, 0, null);
    defer vm.deinit();
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    vm.pending_storage_injector = &injector;

    // Nothing is in flight on a fresh EVM.
    try testing.expectError(error.InvalidAsyncState, vm.callOrContinue(.{ .continue_after_commit = {} }));
    try testing.expectError(error.InvalidAsyncState, vm.callOrContinue(.{ .continue_with_storage = .{ .address = test_address, .slot = 0, .value = 1 } }));

    const bytecode = sstore_slot0_7 ++ return_slot0;
    vm.pending_bytecode = &bytecode;
    try testing.expect((try vm.callOrContinue(.{ .call = testCall(100_000) })) == .need_storage);

    const other_address = primitives.Address{ .bytes = [_]u8{0xab} ** 20 };
    // Wrong slot, wrong address, wrong kind, and a premature commit acknowledgement.
    try testing.expectError(error.InvalidAsyncState, vm.callOrContinue(.{ .continue_with_storage = .{ .address = test_address, .slot = 1, .value = 9 } }));
    try testing.expectError(error.InvalidAsyncState, vm.callOrContinue(.{ .continue_with_storage = .{ .address = other_address, .slot = 0, .value = 9 } }));
    try testing.expectError(error.InvalidAsyncState, vm.callOrContinue(.{ .continue_with_balance = .{ .address = test_address, .balance = 9 } }));
    try testing.expectError(error.InvalidAsyncState, vm.callOrContinue(.{ .continue_with_nonce = .{ .address = test_address, .nonce = 9 } }));
    try testing.expectError(error.InvalidAsyncState, vm.callOrContinue(.{ .continue_with_code = .{ .address = test_address, .code = &[_]u8{0x00} } }));
    try testing.expectError(error.InvalidAsyncState, vm.callOrContinue(.{ .continue_after_commit = {} }));

    // Rejected replies changed nothing: no cached values, request still outstanding.
    try testing.expect(injector.getStorageFromCache(test_address, 1) == null);
    try testing.expect(injector.getStorageFromCache(other_address, 0) == null);
    try testing.expect(injector.getBalanceFromCache(test_address) == null);
    try testing.expect(vm.storage.async_data_request == .storage);
    try testing.expectEqual(AsyncPhase.awaiting_data, vm.async_executor.?.phase);

    // The matching reply still resumes, and both request fields are cleared.
    const committed = try vm.callOrContinue(.{ .continue_with_storage = .{ .address = test_address, .slot = 0, .value = 5 } });
    try testing.expect(committed == .ready_to_commit);
    try testing.expect(vm.storage.async_data_request == .none);
    try testing.expect(vm.async_executor.?.async_data_request == .none);
    try testing.expectEqual(AsyncPhase.awaiting_commit, vm.async_executor.?.phase);

    // A late duplicate of the storage reply is rejected while awaiting commit.
    try testing.expectError(error.InvalidAsyncState, vm.callOrContinue(.{ .continue_with_storage = .{ .address = test_address, .slot = 0, .value = 5 } }));
    try testing.expect((try vm.callOrContinue(.{ .continue_after_commit = {} })).result.success);
}

test "AsyncExecutor - blob hashes set for the call reach BLOBHASH and an empty list clears them" {
    var vm: TestEvm = undefined;
    try vm.init(testing.allocator, null, .OSAKA, null, primitives.ZERO_ADDRESS, 0, null);
    defer vm.deinit();

    // BLOBHASH(0); MSTORE(0); RETURN(0, 32)
    const bytecode = [_]u8{ 0x60, 0x00, 0x49, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
    vm.pending_bytecode = &bytecode;

    const hashes = [_][32]u8{[_]u8{0x01} ++ [_]u8{0x77} ** 31};
    vm.setBlobVersionedHashes(&hashes);
    const with_blob = try vm.callOrContinue(.{ .call = testCall(100_000) });
    try testing.expectEqualSlices(u8, &hashes[0], with_blob.result.output);

    vm.setBlobVersionedHashes(&.{});
    const without_blob = try vm.callOrContinue(.{ .call = testCall(100_000) });
    try testing.expect(std.mem.allEqual(u8, without_blob.result.output, 0));
}

test "AsyncExecutor - a suspended frame owns its bytecode and calldata" {
    var vm: TestEvm = undefined;
    try vm.init(testing.allocator, null, .OSAKA, null, primitives.ZERO_ADDRESS, 0, null);
    defer vm.deinit();
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    vm.pending_storage_injector = &injector;

    const bytecode = try testing.allocator.dupe(u8, &(sstore_slot0_7 ++ return_slot0));
    vm.pending_bytecode = bytecode;
    try testing.expect((try vm.callOrContinue(.{ .call = testCall(100_000) })) == .need_storage);

    // The host reuses its buffer for the next job while the frame is suspended.
    @memset(bytecode, 0xfe);
    testing.allocator.free(bytecode);
    vm.pending_bytecode = &.{};

    const committed = try vm.callOrContinue(.{ .continue_with_storage = .{ .address = test_address, .slot = 0, .value = 5 } });
    try testing.expect(committed == .ready_to_commit);
    const done = try vm.callOrContinue(.{ .continue_after_commit = {} });
    try testing.expectEqual(@as(u8, 7), done.result.output[31]);
}
