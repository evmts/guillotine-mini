/// Async execution orchestrator for the EVM.
///
/// Runs one transaction-level message and yields to the host whenever it needs
/// data the host has not supplied (storage slots, balances, code, nonces).
///
/// Protocol state machine:
///
///     idle --call--> awaiting_data --matching continue_with_*--> (resume or replay)
///      ^   \                |
///      |    \               +--> awaiting_commit --continue_after_commit--> idle
///      |     \                        ^
///      |      +--success + injector---+
///      +---- revert / exceptional halt / no injector: `.result` directly
///
/// Transaction semantics (identical to the synchronous `Evm.call`):
///
///   - A root `Checkpoint` is taken before the message runs. REVERT, an
///     exceptional halt, a host-side error and cancellation all restore it:
///     storage, balances, nonces, code, logs, self-destruct and touched sets,
///     warm sets and the refund counter. `ready_to_commit` is never emitted
///     for a failed transaction.
///   - On success the result is copied and the commit JSON buffer is reserved
///     first, while a failure still rolls the transaction back. Then
///     `Evm.commitTransaction` (self-destruct and EIP-161 deletions) runs, and
///     the changes are serialized into the reserved buffer without allocating.
///   - CALL, CALLCODE, DELEGATECALL, STATICCALL, CREATE and CREATE2 use the
///     same caller, execution address, CALLVALUE, static flag and value
///     transfer rules as `Evm.call`, with or without a host. Standard
///     precompiles, registered overrides and JavaScript handlers dispatch
///     through the shared `Evm.runPrecompile`.
///   - Frames, calldata, bytecode copies and results live in `evm.tx_arena`.
///     A result stays valid until the next transaction starts on the EVM.
///
/// Missing data is handled in one of two ways:
///
///   - Resume: a storage miss in the top-level frame keeps that frame and the
///     root checkpoint, and re-runs the interrupted opcode after the reply.
///   - Restart: a miss in a nested call, a constructor or an account lookup
///     rolls back to the root checkpoint and replays the whole message after
///     the reply. Replies are cached for the transaction, so every replay
///     gets further; execution is deterministic, so the result is the same as
///     if the data had been present from the start.
///
/// There is exactly one pending operation. Starting a new call (async or
/// synchronous) cancels a suspended transaction, rolls back its writes and
/// invalidates its outstanding request and commit acknowledgement. A
/// continuation that does not answer the outstanding request (wrong kind,
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

        const MessageKind = enum { call, callcode, delegatecall, staticcall, create, create2 };

        /// The transaction-level message, with every buffer copied into
        /// `evm.tx_arena` so it survives suspension and can be replayed.
        const Message = struct {
            kind: MessageKind,
            caller: primitives.Address,
            /// Call target; unused for creations.
            to: primitives.Address,
            /// CALLVALUE (CALL, CALLCODE, inherited for DELEGATECALL) or endowment.
            value: u256,
            gas: u64,
            /// Calldata, or init code for creations.
            input: []const u8,
            salt: ?u256,
            /// Code supplied for this call with `Evm.setBytecode`; empty when the
            /// target's own code runs. On the async path supplied code takes
            /// precedence over installed code (the C ABI contract of
            /// `evm_set_bytecode` + `evm_call_ffi`).
            bytecode: []const u8,
        };

        /// How a suspended transaction continues once the host replies.
        const ResumeMode = enum {
            /// Re-run the interrupted opcode of the kept top-level frame.
            resume_frame,
            /// Replay the message from the root checkpoint.
            restart,
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

        /// The message in flight. Valid while `phase != .idle` or during a run.
        message: Message,

        resume_mode: ResumeMode,

        /// Revert point for the whole transaction. The EVM's snapshot stacks
        /// point into it while `root_open`, so the executor must not move then.
        root: EvmType.Checkpoint,
        root_open: bool,

        /// Initialize async executor
        pub fn init(evm: *EvmType) Self {
            return Self{
                .evm = evm,
                .async_data_request = .none,
                .phase = .idle,
                .pending_result = null,
                .message = undefined,
                .resume_mode = .resume_frame,
                .root = undefined,
                .root_open = false,
            };
        }

        /// Main async execution method - supports yielding for async requests
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
                    self.evm.storage.put_in_cache(data.address, data.slot, data.value) catch |err| return self.fail(err);
                    return self.continueAfterReply();
                },

                .continue_with_balance => |data| {
                    const request = try self.outstandingRequest();
                    if (request != .balance) return error.InvalidAsyncState;
                    if (!sameAddress(request.balance.address, data.address)) return error.InvalidAsyncState;

                    self.supplyBalance(data.address, data.balance) catch |err| return self.fail(err);
                    return self.continueAfterReply();
                },

                .continue_with_code => |data| {
                    const request = try self.outstandingRequest();
                    if (request != .code) return error.InvalidAsyncState;
                    if (!sameAddress(request.code.address, data.address)) return error.InvalidAsyncState;

                    self.supplyCode(data.address, data.code) catch |err| return self.fail(err);
                    return self.continueAfterReply();
                },

                .continue_with_nonce => |data| {
                    const request = try self.outstandingRequest();
                    if (request != .nonce) return error.InvalidAsyncState;
                    if (!sameAddress(request.nonce.address, data.address)) return error.InvalidAsyncState;

                    self.supplyNonce(data.address, data.nonce) catch |err| return self.fail(err);
                    return self.continueAfterReply();
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

        // Host replies are state the host already holds: they extend the commit
        // baseline and are never part of the transaction's own changes.

        fn supplyBalance(self: *Self, address: primitives.Address, balance: u256) !void {
            if (self.evm.storage.storage_injector) |injector| {
                try injector.cacheBalance(address, balance);
                try injector.noteBaselineBalance(address, balance);
            }
            try self.evm.supplyAsyncBalance(address, balance);
        }

        fn supplyNonce(self: *Self, address: primitives.Address, nonce: u64) !void {
            if (self.evm.storage.storage_injector) |injector| {
                try injector.cacheNonce(address, nonce);
                try injector.noteBaselineNonce(address, nonce);
            }
            try self.evm.supplyAsyncNonce(address, nonce);
        }

        fn supplyCode(self: *Self, address: primitives.Address, code: []const u8) !void {
            if (self.evm.storage.storage_injector) |injector| {
                // The cache copies with its own allocator and frees that copy itself.
                try injector.cacheCode(address, code);
                try injector.noteBaselineCode(address, code);
            }
            // The EVM's code map borrows a transaction-arena copy for this transaction.
            try self.evm.supplyAsyncCode(address, code);
        }

        /// The outstanding request was answered: clear it and carry on.
        fn continueAfterReply(self: *Self) !CallOrContinueOutput {
            self.async_data_request = .none;
            self.evm.storage.clear_async_request();
            self.phase = .idle;

            switch (self.resume_mode) {
                .resume_frame => return self.executeUntilYieldOrComplete() catch |err| return self.fail(err),
                .restart => {
                    self.openRoot() catch |err| return self.fail(err);
                    return self.runMessage() catch |err| return self.fail(err);
                },
            }
        }

        /// Drop every trace of the transaction in flight.
        fn resetProtocolState(self: *Self) void {
            self.async_data_request = .none;
            self.evm.storage.clear_async_request();
            self.phase = .idle;
            self.pending_result = null;
            self.resume_mode = .resume_frame;
        }

        fn openRoot(self: *Self) !void {
            try self.evm.takeCheckpoint(&self.root);
            self.root_open = true;
        }

        /// Keep the transaction's writes: close the root checkpoint without restoring it.
        fn closeRoot(self: *Self) void {
            if (!self.root_open) return;
            self.evm.releaseCheckpoint(&self.root);
            self.root_open = false;
        }

        /// Undo everything the transaction did since the root checkpoint.
        fn rollbackRoot(self: *Self) void {
            if (!self.root_open) return;
            self.evm.revertToCheckpoint(&self.root) catch |err| {
                log.err("AsyncExecutor: root rollback failed: {s}", .{@errorName(err)});
            };
            self.evm.releaseCheckpoint(&self.root);
            self.root_open = false;
            // The root checkpoint is taken at a zero refund; no refund survives a failure.
            self.evm.gas_refund = 0;
        }

        /// Cancel the transaction in flight, if any: roll back its uncommitted
        /// writes and invalidate its outstanding request and its pending commit
        /// acknowledgement. Called when a new transaction (async or synchronous)
        /// starts on the EVM. A transaction awaiting its commit acknowledgement
        /// has already been applied; only the acknowledgement is dropped.
        pub fn cancel(self: *Self) void {
            if (self.phase == .idle and !self.root_open) return;
            self.rollbackRoot();
            self.evm.frames.clearRetainingCapacity();
            if (self.evm.storage.storage_injector) |injector| injector.clearDirty();
            self.resetProtocolState();
        }

        /// Abandon the transaction after a host-side failure (allocation or
        /// protocol error): everything is rolled back, nothing stays suspended
        /// and nothing is offered for commit.
        fn abort(self: *Self) void {
            self.rollbackRoot();
            self.evm.frames.clearRetainingCapacity();
            if (self.evm.storage.storage_injector) |injector| injector.clearDirty();
            self.endTransaction();
            self.resetProtocolState();
        }

        fn fail(self: *Self, err: anyerror) anyerror {
            self.abort();
            return err;
        }

        fn failedResult(self: *Self, error_name: ?[]const u8) CallResult {
            const tx_alloc = self.evm.tx_arena.allocator();
            if (error_name) |name| {
                if (CallResult.failure_with_error(tx_alloc, 0, name)) |result| return result else |_| {}
            }
            return CallResult{ .success = false, .gas_left = 0, .output = &.{} };
        }

        /// Reset transaction-scoped EVM state, as the synchronous `call()` does
        /// when it returns, and drop everything fetched for this transaction.
        fn endTransaction(self: *Self) void {
            self.evm.finishTransaction();
            self.evm.endAsyncTransaction();
        }

        /// A successful transaction: apply the end-of-transaction effects, then
        /// hand the result to the host. With an injector the changes are offered
        /// for commit first, otherwise the result is final.
        fn finishSuccess(self: *Self, gas_left: u64, output: []const u8, created_address: ?primitives.Address) !CallOrContinueOutput {
            const evm = self.evm;

            // Own the result before anything is committed: a failure here still rolls back.
            var result = try CallResult.success_with_logs(evm.tx_arena.allocator(), gas_left, output, evm.logs.items);
            result.refund_counter = evm.get_effective_refund();
            result.created_address = created_address;

            // End-of-transaction reads must not ask the host for anything.
            evm.async_active = false;

            // Everything that can fail runs while the root checkpoint is open, so
            // a failed allocation rolls the whole transaction back (R3-009): the
            // changed accounts are marked and the commit JSON buffer is reserved.
            const offers_commit = evm.storage.storage_injector != null;
            if (offers_commit) try evm.prepareStateChanges();

            // Commit point. Self-destructed and touched empty accounts are deleted
            // before the changes are serialized, so the host commits the final
            // state. Deletions cannot be undone, so nothing below allocates.
            evm.commitTransaction();
            self.closeRoot();

            var changes_json: ?[]const u8 = null;
            if (offers_commit) {
                log.debug("AsyncExecutor: transaction succeeded, dumping changes", .{});
                changes_json = try evm.writePreparedStateChanges();
            }

            self.endTransaction();
            self.async_data_request = .none;
            if (changes_json) |json| {
                self.pending_result = result;
                self.phase = .awaiting_commit;
                return .{ .ready_to_commit = .{ .changes_json = json } };
            }
            self.phase = .idle;
            return .{ .result = result };
        }

        /// A reverted or halted transaction: every state change is rolled back,
        /// the terminal result is returned directly and no change set is ever
        /// offered for commit.
        fn finishFailure(self: *Self, result: CallResult) CallOrContinueOutput {
            self.rollbackRoot();
            self.evm.frames.clearRetainingCapacity();
            if (self.evm.storage.storage_injector) |injector| injector.clearDirty();
            self.endTransaction();
            self.resetProtocolState();
            return .{ .result = result };
        }

        fn needOutput(request: AsyncDataRequest) ?CallOrContinueOutput {
            return switch (request) {
                .storage => |req| .{ .need_storage = .{ .address = req.address, .slot = req.slot } },
                .balance => |req| .{ .need_balance = .{ .address = req.address } },
                .code => |req| .{ .need_code = .{ .address = req.address } },
                .nonce => |req| .{ .need_nonce = .{ .address = req.address } },
                .none => null,
            };
        }

        /// Restart-on-miss: roll the transaction back to its root checkpoint and
        /// ask the host for the data the first miss needed. The reply replays
        /// the message from the start.
        fn suspendForRestart(self: *Self) !CallOrContinueOutput {
            const evm = self.evm;
            const request = evm.async_restart_request;

            self.rollbackRoot();
            evm.frames.clearRetainingCapacity();
            // The rollback restored every written slot in the overlay, so the
            // marks of the abandoned attempt are stale.
            if (evm.storage.storage_injector) |injector| injector.clearDirty();
            evm.clearAsyncRestart();
            // Suspended: reads between continuations must not register requests.
            evm.async_active = false;

            const output = needOutput(request) orelse return error.InvalidAsyncState;
            self.async_data_request = request;
            evm.storage.async_data_request = request;
            self.phase = .awaiting_data;
            self.resume_mode = .restart;
            return output;
        }

        /// Start a new call and begin execution
        pub fn startNewCall(self: *Self, params: CallParams) !CallOrContinueOutput {
            // A new call supersedes whatever was suspended or awaiting commit.
            self.cancel();

            params.validate() catch |err| {
                return .{ .result = self.failedResult(@errorName(err)) };
            };

            self.begin(params) catch |err| return self.fail(err);
            return self.runMessage() catch |err| return self.fail(err);
        }

        /// Set up the transaction: scratch state, the message copy, warm sets,
        /// the commit baseline and the root checkpoint.
        fn begin(self: *Self, params: CallParams) !void {
            const evm = self.evm;

            // One-shot inputs apply to this call only, as in `Evm.call`. The
            // access list is borrowed and consumed here; bytecode is copied.
            const access_list = evm.pending_access_list;
            const pending_bytecode = evm.pending_bytecode;
            evm.pending_access_list = null;
            evm.pending_bytecode = &.{};

            // The blob hashes set for this call must survive it (an empty list
            // clears the previous ones).
            const blob_hashes: ?[]const [32]u8 = if (evm.blob_versioned_hashes.len > 0) evm.blob_versioned_hashes else null;
            try evm.initTransactionState(blob_hashes);

            // A suspended or replayed message outlives this function, and the
            // host may replace its buffers meanwhile: keep transaction-arena copies.
            const tx_alloc = evm.tx_arena.allocator();
            const is_create = params.isCreate();
            const to = params.get_to() orelse primitives.ZERO_ADDRESS;
            self.message = .{
                .kind = switch (params) {
                    .call => .call,
                    .callcode => .callcode,
                    .delegatecall => .delegatecall,
                    .staticcall => .staticcall,
                    .create => .create,
                    .create2 => .create2,
                },
                .caller = params.getCaller(),
                .to = to,
                .value = switch (params) {
                    .call => |p| p.value,
                    .callcode => |p| p.value,
                    .delegatecall => |p| p.value,
                    .staticcall => 0,
                    .create => |p| p.value,
                    .create2 => |p| p.value,
                },
                .gas = params.getGas(),
                .input = try tx_alloc.dupe(u8, params.getInput()),
                .salt = switch (params) {
                    .create2 => |p| p.salt,
                    else => null,
                },
                .bytecode = &.{},
            };

            if (!is_create and pending_bytecode.len > 0) {
                // `setBytecode` supplies the code this call runs. When the target
                // has no code of its own on a hostless EVM, it also becomes the
                // account's code for this call, so EXTCODE* and re-entrant calls
                // see it. A host owns its accounts and installed code is never
                // replaced, so in those cases the frame alone runs it.
                if (evm.suppliedCodeIsAccountCode(to, pending_bytecode)) {
                    self.message.bytecode = try evm.installAsyncCodeView(to, pending_bytecode);
                } else {
                    self.message.bytecode = try tx_alloc.dupe(u8, pending_bytecode);
                }
            }

            if (evm.storage.storage_injector) |injector| {
                log.debug("AsyncExecutor: storage injector enabled, clearing cache", .{});
                injector.clearCache();
                // Captured for every message kind (precompiles and creations
                // included), after the code view, which is not a state change.
                try injector.captureBaseline(evm);
            }

            // Warm sets (EIP-2929, EIP-3651, EIP-2930). A creation warms its
            // new address itself.
            try evm.preWarmParticipants(if (is_create) self.message.caller else to);
            if (access_list) |list| try evm.access_list_manager.pre_warm_from_access_list(list);

            // Everything from here is rolled back on REVERT, halt, error or cancel.
            try self.openRoot();
        }

        /// Run the message from the root checkpoint. Called once per attempt:
        /// at the start and after every restart.
        fn runMessage(self: *Self) !CallOrContinueOutput {
            const evm = self.evm;
            const msg = self.message;
            evm.clearAsyncRestart();
            evm.async_active = true;

            if (msg.kind == .create or msg.kind == .create2) return self.runCreate();

            // One builder for every variant, as in `Evm.call`:
            //   CALL / STATICCALL: code and storage of `to`; STATICCALL is read-only.
            //   CALLCODE / DELEGATECALL: code of `to` in the caller's storage; no transfer.
            const is_static = msg.kind == .staticcall;
            const execution_address = switch (msg.kind) {
                .callcode, .delegatecall => msg.caller,
                else => msg.to,
            };

            // Resolve the code to run. Active precompiles always dispatch as precompiles.
            const target_is_precompile = EvmType.isPrecompileAddress(msg.to, evm.hardfork);
            var bytecode: []const u8 = &.{};
            if (!target_is_precompile) {
                if (msg.bytecode.len > 0) {
                    // Code supplied for this call (`Evm.setBytecode`) runs as given.
                    bytecode = msg.bytecode;
                } else if (evm.get_delegated_target(msg.to)) |delegate| {
                    // EIP-7702: warm the delegate and run its code.
                    try evm.pre_warm_addresses(&[_]primitives.Address{delegate});
                    bytecode = evm.get_raw_code(delegate);
                } else {
                    bytecode = evm.get_raw_code(msg.to);
                }
            }
            if (evm.async_restart_pending) return self.suspendForRestart();

            // Only CALL and CALLCODE require the caller to hold `value`; only CALL moves it.
            if (msg.value > 0 and (msg.kind == .call or msg.kind == .callcode)) {
                const insufficient = evm.get_balance(msg.caller) < msg.value;
                if (evm.async_restart_pending) return self.suspendForRestart();
                if (insufficient) return self.finishFailure(self.failedResult("InsufficientBalance"));
                if (msg.kind == .call) {
                    evm.transferValue(msg.caller, msg.to, msg.value) catch |err| {
                        if (evm.async_restart_pending) return self.suspendForRestart();
                        if (err == error.OutOfMemory) return err;
                        return self.finishFailure(self.failedResult(@errorName(err)));
                    };
                    if (evm.async_restart_pending) return self.suspendForRestart();
                }
            }

            if (bytecode.len == 0) {
                // No code: JavaScript handler, registered override, standard
                // precompile, or a plain account (success, no output).
                var gas_left = msg.gas;
                var output: []const u8 = &.{};
                switch (evm.runPrecompile(evm.tx_arena.allocator(), msg.to, msg.input, msg.gas, target_is_precompile)) {
                    .failure => return self.finishFailure(self.failedResult("PrecompileError")),
                    .success => |done| {
                        gas_left = done.gas_left;
                        output = done.output;
                    },
                    .none => {},
                }
                if (msg.kind == .call) try evm.touchCallTarget(msg.to);
                return self.finishSuccess(gas_left, output, null);
            }

            // Gas above i64::MAX cannot be spent; cap instead of trapping on the cast.
            const frame_gas = std.math.cast(i64, msg.gas) orelse std.math.maxInt(i64);
            if (!evm.canPushFrame()) return error.OutOfMemory;
            const FrameType = @TypeOf(evm.frames.items[0]);
            const frame = try FrameType.init(
                evm.tx_arena.allocator(),
                bytecode,
                frame_gas,
                msg.caller,
                execution_address,
                msg.value,
                msg.input,
                @as(*anyopaque, @ptrCast(evm)),
                evm.hardfork,
                is_static,
            );
            // `canPushFrame` reserved the slot: this never reallocates `frames`.
            evm.frames.appendAssumeCapacity(frame);

            return self.executeUntilYieldOrComplete();
        }

        /// CREATE / CREATE2 transaction. The constructor runs inside
        /// `Evm.createFrom`; any data it misses restarts the creation.
        fn runCreate(self: *Self) !CallOrContinueOutput {
            const evm = self.evm;
            const msg = self.message;

            const created = evm.createFrom(msg.caller, msg.value, msg.input, msg.gas, msg.salt, true) catch |err| {
                if (evm.async_restart_pending) return self.suspendForRestart();
                if (err == error.OutOfMemory) return err;
                // For example init code over the EIP-3860 limit.
                return self.finishFailure(self.failedResult(@errorName(err)));
            };
            if (evm.async_restart_pending) return self.suspendForRestart();

            if (!created.success) {
                const result = try CallResult.revert_with_data(evm.tx_arena.allocator(), created.gas_left, created.output);
                return self.finishFailure(result);
            }
            return self.finishSuccess(created.gas_left, &.{}, created.address);
        }

        /// Execute the top-level frame until it suspends, halts or completes.
        ///
        /// Outcomes:
        ///   - storage miss in this frame: `.need_storage`, frame and root
        ///     checkpoint kept, phase `awaiting_data` (resume)
        ///   - miss in a nested frame, constructor or account lookup: `.need_*`,
        ///     transaction rolled back, phase `awaiting_data` (restart)
        ///   - success with an injector: `.ready_to_commit`, phase `awaiting_commit`
        ///   - success without an injector: `.result` with output, gas, logs and refund
        ///   - REVERT: `.result` (failure, revert data, remaining gas), rolled back
        ///   - exceptional halt (OutOfGas, InvalidOpcode, ...): `.result` (failure,
        ///     zero gas, `error_info`), rolled back
        ///   - host allocation failure: an error; the transaction is abandoned
        fn executeUntilYieldOrComplete(self: *Self) !CallOrContinueOutput {
            const evm = self.evm;
            if (evm.frames.items.len == 0 or !self.root_open) return error.InvalidAsyncState;
            evm.async_active = true;

            // Don't cache the frame pointer across execute(); nested calls may move it.
            evm.frames.items[0].execute() catch |err| {
                if (evm.async_restart_pending) return self.suspendForRestart();
                if (err == error.NeedAsyncData) {
                    // The top-level frame probed a slot before mutating anything:
                    // keep it and re-run the opcode after the reply.
                    const request = evm.storage.async_data_request;
                    const output = needOutput(request) orelse return error.InvalidAsyncState;
                    self.async_data_request = request;
                    self.phase = .awaiting_data;
                    self.resume_mode = .resume_frame;
                    evm.async_active = false;
                    return output;
                }
                if (err == error.OutOfMemory) return err;

                // An exceptional halt is a normal EVM outcome, not a protocol error.
                return self.finishFailure(self.failedResult(@errorName(err)));
            };
            if (evm.async_restart_pending) return self.suspendForRestart();

            const frame = &evm.frames.items[0];
            const gas_left = @as(u64, @intCast(@max(frame.gas_remaining, 0)));

            if (frame.reverted) {
                const result = try CallResult.revert_with_data(evm.tx_arena.allocator(), gas_left, frame.output);
                return self.finishFailure(result);
            }

            return self.finishSuccess(gas_left, frame.output, null);
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
