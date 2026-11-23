//! Hardfork readiness hooks: Osaka capability checks and Glamsterdam
//! (Amsterdam) extension points.
//!
//! This module is self-contained. It imports only `std`, so it compiles
//! against any Voltaire pin and can be tested alone:
//!
//! ```sh
//! zig test src/hardfork_hooks.zig
//! ```
//!
//! Nothing in the interpreter calls it yet. It defines the seams that
//! `evm.zig` and `frame.zig` adopt when Amsterdam lands:
//!
//! | Section              | EIP              | What it provides                               |
//! |----------------------|------------------|------------------------------------------------|
//! | Capability helpers   | 7939, 7951, 7825 | `supportsClz`, `supportsP256Verify`, ...       |
//! | `eth_transfer_log`   | 7708             | System log builders and topic0 constants       |
//! | `block_access_list`  | 7928             | Recorder interface, no-op and list recorders   |
//! | `GasSchedule`        | 8037, 8038       | Fork-parameterized state gas table             |
//!
//! ## Zero overhead
//!
//! Every capability helper is generic over the hardfork enum type and
//! resolves fork names with `@hasField` at comptime. Against a Voltaire pin
//! whose `Hardfork` enum has no `AMSTERDAM` tag, `supportsAmsterdam` folds to
//! the constant `false` and every guarded branch is deleted. Against a pin
//! that has the tag, each helper is one integer comparison.
//!
//! The EIP-7928 hook is generic over the recorder type. With `NoopRecorder`
//! every call inlines to nothing.
//!
//! ## Spec status
//!
//! EIP-7708, EIP-7928, EIP-8037 and EIP-8038 were in Last Call when this
//! module was written (2026-11-22) and are scheduled for Glamsterdam in
//! EIP-7773. EIP-8037 states that its numeric values are not final. Treat
//! `GasSchedule.amsterdam` as a draft table: re-verify it against
//! `execution-specs/src/ethereum/forks/amsterdam/vm/gas.py` before enabling
//! the fork.

const std = @import("std");

// ============================================================================
// Shared types
// ============================================================================

/// A 20-byte account address. Convert from Voltaire with `address.bytes`.
pub const Address = [20]u8;

/// EIP-4788 system address. EIP-7708 logs are emitted from this address.
pub const SYSTEM_ADDRESS: Address = [_]u8{0xff} ** 19 ++ [_]u8{0xfe};

fn keccak256(comptime input: []const u8) [32]u8 {
    @setEvalBranchQuota(200_000);
    var out: [32]u8 = undefined;
    std.crypto.hash.sha3.Keccak256.hash(input, &out, .{});
    return out;
}

fn addressToWord(address: Address) u256 {
    return std.mem.readInt(u160, &address, .big);
}

// ============================================================================
// Comptime hardfork capability helpers
// ============================================================================

fn HardforkOf(comptime T: type) type {
    if (@typeInfo(T) != .@"enum") {
        @compileError("hardfork_hooks: expected a hardfork enum, found " ++ @typeName(T));
    }
    return T;
}

/// Returns true when the hardfork enum `H` declares a tag called `name`.
///
/// Use this to write code that compiles on both sides of a Voltaire pin
/// upgrade: `if (comptime hasFork(Hardfork, "AMSTERDAM")) { ... }`.
pub fn hasFork(comptime H: type, comptime name: []const u8) bool {
    return @hasField(HardforkOf(H), name);
}

/// Returns true when `fork` is at or after the fork called `name`.
///
/// Returns false, at comptime, when the enum of `fork` has no such tag. The
/// caller never has to name a tag that an older Voltaire pin lacks.
pub inline fn isAtLeast(fork: anytype, comptime name: []const u8) bool {
    const H = HardforkOf(@TypeOf(fork));
    if (comptime !@hasField(H, name)) return false;
    return @intFromEnum(fork) >= @intFromEnum(@field(H, name));
}

/// EIP-7939 opcode byte for CLZ.
pub const CLZ_OPCODE: u8 = 0x1e;
/// EIP-7939 gas cost for CLZ.
pub const CLZ_GAS: u64 = 5;

/// EIP-7951 P256VERIFY precompile address (0x0100).
pub const P256VERIFY_ADDRESS: Address = [_]u8{0} ** 18 ++ [_]u8{ 0x01, 0x00 };
/// EIP-7951 P256VERIFY gas cost.
pub const P256VERIFY_GAS: u64 = 6900;
/// EIP-7951 P256VERIFY input length: hash || r || s || qx || qy.
pub const P256VERIFY_INPUT_LEN: usize = 160;

/// EIP-7825 per-transaction gas limit cap (2^24).
pub const EIP7825_TX_GAS_LIMIT_CAP: u64 = 16_777_216;

/// EIP-7939: CLZ is valid from Osaka.
pub inline fn supportsClz(fork: anytype) bool {
    return isAtLeast(fork, "OSAKA");
}

/// EIP-7951: P256VERIFY is a precompile from Osaka.
pub inline fn supportsP256Verify(fork: anytype) bool {
    return isAtLeast(fork, "OSAKA");
}

/// EIP-7825: transactions above `EIP7825_TX_GAS_LIMIT_CAP` are invalid from Osaka.
pub inline fn supportsEip7825TxGasCap(fork: anytype) bool {
    return isAtLeast(fork, "OSAKA");
}

/// Returns true when `fork` is Amsterdam (Glamsterdam) or later.
///
/// Folds to `false` when the hardfork enum has no `AMSTERDAM` tag.
pub inline fn supportsAmsterdam(fork: anytype) bool {
    return isAtLeast(fork, "AMSTERDAM");
}

/// EIP-7708: ETH transfers emit a system log from Amsterdam.
pub inline fn supportsEthTransferLogs(fork: anytype) bool {
    return supportsAmsterdam(fork);
}

/// EIP-7928: blocks carry a Block-Level Access List from Amsterdam.
pub inline fn supportsBlockAccessList(fork: anytype) bool {
    return supportsAmsterdam(fork);
}

/// EIP-8037: state creation is metered as a separate state gas dimension
/// from Amsterdam.
pub inline fn supportsStateGas(fork: anytype) bool {
    return supportsAmsterdam(fork);
}

/// Returns the EIP-7825 transaction gas cap for `fork`, or null before Osaka.
pub inline fn txGasLimitCap(fork: anytype) ?u64 {
    return if (supportsEip7825TxGasCap(fork)) EIP7825_TX_GAS_LIMIT_CAP else null;
}

/// Returns true when a transaction gas limit is allowed under EIP-7825.
pub inline fn isTxGasLimitAllowed(fork: anytype, gas_limit: u64) bool {
    const cap = txGasLimitCap(fork) orelse return true;
    return gas_limit <= cap;
}

// ============================================================================
// EIP-7708: ETH transfers emit a log
// ============================================================================

/// System log builders for EIP-7708.
///
/// The EIP defines one log shape: a LOG3 from `SYSTEM_ADDRESS` with the
/// ERC-20 `Transfer` topic. It is emitted for every nonzero value transfer
/// to a different account:
///
/// - the transaction-level transfer, before any other log of the transaction
/// - CALL with value, when the transfer executes
/// - CREATE and CREATE2 endowments, when the transfer executes
/// - SELFDESTRUCT to another account, when the transfer executes
///
/// No log is emitted for zero-value transfers, priority fees, the base fee
/// burn, or withdrawals. Logs follow normal revert semantics: the caller
/// appends them to the frame log list, so a reverted frame drops them.
pub const eth_transfer_log = struct {
    pub const TRANSFER_SIGNATURE = "Transfer(address,address,uint256)";
    /// keccak256("Transfer(address,address,uint256)"), as bytes.
    pub const TRANSFER_TOPIC0_BYTES: [32]u8 = keccak256(TRANSFER_SIGNATURE);
    /// keccak256("Transfer(address,address,uint256)"), as a stack word.
    pub const TRANSFER_TOPIC0: u256 = std.mem.readInt(u256, &TRANSFER_TOPIC0_BYTES, .big);

    /// Draft-only burn signature. See `selfdestructBurnLog`.
    pub const SELFDESTRUCT_BURN_SIGNATURE = "Selfdestruct(address,uint256)";
    /// keccak256("Selfdestruct(address,uint256)"), as bytes. Draft-only.
    pub const SELFDESTRUCT_BURN_TOPIC0_BYTES: [32]u8 = keccak256(SELFDESTRUCT_BURN_SIGNATURE);
    /// keccak256("Selfdestruct(address,uint256)"), as a stack word. Draft-only.
    pub const SELFDESTRUCT_BURN_TOPIC0: u256 = std.mem.readInt(u256, &SELFDESTRUCT_BURN_TOPIC0_BYTES, .big);

    /// EIP-8246 (scheduled with EIP-7708) removes the SELFDESTRUCT burn, so
    /// the Last Call text of EIP-7708 defines no burn log. Devnets that
    /// predate EIP-8246 set this to `.emit_burn_log`.
    pub const SelfdestructToSelfPolicy = enum {
        /// EIP-8246 semantics: SELFDESTRUCT to self burns nothing and logs nothing.
        no_burn,
        /// Pre-EIP-8246 draft semantics: the burned balance emits a burn log.
        emit_burn_log,
    };

    /// A fixed-size system log. It needs no allocation: at most three topics
    /// and a 32-byte data word.
    pub const SystemLog = struct {
        address: Address = SYSTEM_ADDRESS,
        topics_buf: [3]u256,
        topics_len: u8,
        /// Amount in wei, big-endian.
        data: [32]u8,

        /// Topics in emission order. Matches Voltaire `Log.topics` (`[]const u256`).
        pub fn topics(self: *const SystemLog) []const u256 {
            return self.topics_buf[0..self.topics_len];
        }

        /// The logged amount in wei.
        pub fn amount(self: *const SystemLog) u256 {
            return std.mem.readInt(u256, &self.data, .big);
        }

        /// Copies the log to the heap in the field layout of Voltaire's
        /// `Log`. The caller owns the result and frees it with `deinit`.
        pub fn toOwned(self: *const SystemLog, allocator: std.mem.Allocator) std.mem.Allocator.Error!OwnedLog {
            const owned_topics = try allocator.dupe(u256, self.topics());
            errdefer allocator.free(owned_topics);
            const owned_data = try allocator.dupe(u8, &self.data);
            return .{ .address = self.address, .topics = owned_topics, .data = owned_data };
        }
    };

    /// A heap-allocated log with the same fields as Voltaire's `Log`.
    pub const OwnedLog = struct {
        address: Address,
        topics: []const u256,
        data: []const u8,

        pub fn deinit(self: OwnedLog, allocator: std.mem.Allocator) void {
            allocator.free(self.topics);
            allocator.free(self.data);
        }
    };

    fn amountData(amount_wei: u256) [32]u8 {
        var data: [32]u8 = undefined;
        std.mem.writeInt(u256, &data, amount_wei, .big);
        return data;
    }

    /// Builds the transfer log for a value transfer, or returns null when
    /// the EIP requires no log: zero value, or sender equals recipient.
    pub fn transferLog(from: Address, to: Address, amount_wei: u256) ?SystemLog {
        if (amount_wei == 0) return null;
        if (std.mem.eql(u8, &from, &to)) return null;
        return .{
            .topics_buf = .{ TRANSFER_TOPIC0, addressToWord(from), addressToWord(to) },
            .topics_len = 3,
            .data = amountData(amount_wei),
        };
    }

    /// Builds the draft burn log: LOG2 with the `Selfdestruct` topic and the
    /// closed account. Returns null for a zero balance.
    ///
    /// This shape comes from EIP-7708 drafts that predate EIP-8246. The Last
    /// Call text defines no burn log. Call it only through `selfdestructLog`
    /// with `.emit_burn_log`, and re-check the signature against the devnet
    /// spec before relying on it.
    pub fn selfdestructBurnLog(account: Address, amount_wei: u256) ?SystemLog {
        if (amount_wei == 0) return null;
        return .{
            .topics_buf = .{ SELFDESTRUCT_BURN_TOPIC0, addressToWord(account), 0 },
            .topics_len = 2,
            .data = amountData(amount_wei),
        };
    }

    /// Builds the log for a SELFDESTRUCT that moves `amount_wei` from
    /// `account` to `beneficiary`.
    ///
    /// A different beneficiary yields a transfer log. The same account
    /// follows `policy`. Zero balances yield null.
    pub fn selfdestructLog(
        account: Address,
        beneficiary: Address,
        amount_wei: u256,
        policy: SelfdestructToSelfPolicy,
    ) ?SystemLog {
        if (!std.mem.eql(u8, &account, &beneficiary)) {
            return transferLog(account, beneficiary, amount_wei);
        }
        return switch (policy) {
            .no_burn => null,
            .emit_burn_log => selfdestructBurnLog(account, amount_wei),
        };
    }
};

// ============================================================================
// EIP-7928: Block-Level Access Lists
// ============================================================================

/// Recorder interface for EIP-7928 Block-Level Access Lists (BAL).
///
/// The EVM owns a `Hook(Recorder)` and calls it at each state access. The
/// recorder is a comptime type parameter, so there is no vtable and
/// `Hook(NoopRecorder)` compiles to nothing.
///
/// A recorder type declares:
///
/// ```zig
/// pub const Error = error{...};  // error{} when the recorder cannot fail
/// pub fn recordAddressAccess(self: *R, address: Address) Error!void
/// pub fn recordStorageRead(self: *R, address: Address, slot: u256) Error!void
/// pub fn recordStorageWrite(self: *R, index: BlockAccessIndex, address: Address, slot: u256, post_value: u256) Error!void
/// pub fn recordBalanceChange(self: *R, index: BlockAccessIndex, address: Address, post_balance: u256) Error!void
/// ```
///
/// Call sites that the EVM must cover (EIP-7928 "must include"):
///
/// - `recordAddressAccess`: tx sender and recipient (even for zero value),
///   CALL/CALLCODE/DELEGATECALL/STATICCALL targets (even when the call
///   reverts), BALANCE/EXTCODESIZE/EXTCODECOPY/EXTCODEHASH targets,
///   SELFDESTRUCT beneficiaries, created addresses, accessed precompiles,
///   and withdrawal recipients. Skip the call when the opcode runs out of
///   gas before the access.
/// - `recordStorageRead`: every SLOAD.
/// - `Hook.storageWrite`: every SSTORE that passes the stipend and access
///   cost checks. The hook demotes a no-op write to a read.
/// - `recordBalanceChange`: post-transaction balances that differ from the
///   pre-transaction balance.
///
/// The recorder, not the hook, handles revert: on revert it drops writes and
/// balance changes of the frame, keeps address accesses, and turns dropped
/// writes into reads. Nonce and code changes are part of the BAL too. They
/// are tracked in `docs/HARDFORK_ROADMAP.md` and need two more methods.
pub const block_access_list = struct {
    /// Position of a state change within the block.
    pub const BlockAccessIndex = u32;

    /// Index for pre-execution system calls (EIP-2935, EIP-4788).
    pub const PRE_EXECUTION_INDEX: BlockAccessIndex = 0;

    /// Gas-equivalent cost of one BAL item (one address or one storage key).
    pub const ITEM_COST: u64 = 2000;

    /// RLP encoding of an empty BAL.
    pub const EMPTY_RLP = [_]u8{0xc0};
    /// `block_access_list_hash` of an empty BAL: keccak256(0xc0).
    pub const EMPTY_HASH: [32]u8 = keccak256(&EMPTY_RLP);

    /// Index for the transaction at `tx_position` (zero-based) in the block.
    pub fn transactionIndex(tx_position: u32) BlockAccessIndex {
        return tx_position + 1;
    }

    /// Index for post-execution system calls and withdrawals.
    pub fn postExecutionIndex(tx_count: u32) BlockAccessIndex {
        return tx_count + 1;
    }

    /// Maximum number of BAL items (addresses plus storage keys) for a block.
    pub fn maxItems(block_gas_limit: u64) u64 {
        return block_gas_limit / ITEM_COST;
    }

    /// Returns true when the item count respects the block gas limit bound.
    pub fn isWithinItemLimit(address_count: u64, storage_key_count: u64, block_gas_limit: u64) bool {
        const items = std.math.add(u64, address_count, storage_key_count) catch return false;
        return items <= maxItems(block_gas_limit);
    }

    /// Verifies at comptime that `R` implements the recorder interface.
    pub fn assertRecorder(comptime R: type) void {
        comptime {
            if (!@hasDecl(R, "Error")) {
                @compileError(@typeName(R) ++ " must declare `pub const Error`");
            }
            for (.{ "recordAddressAccess", "recordStorageRead", "recordStorageWrite", "recordBalanceChange" }) |name| {
                if (!@hasDecl(R, name)) {
                    @compileError(@typeName(R) ++ " is missing BAL recorder method `" ++ name ++ "`");
                }
            }
        }
    }

    /// The hook the EVM calls. It stamps each change with the current block
    /// access index and applies the EIP-7928 no-op write rule.
    pub fn Hook(comptime Recorder: type) type {
        assertRecorder(Recorder);
        return struct {
            recorder: *Recorder,
            index: BlockAccessIndex = PRE_EXECUTION_INDEX,

            const Self = @This();
            pub const Error = Recorder.Error;

            pub fn init(recorder: *Recorder) Self {
                return .{ .recorder = recorder };
            }

            /// Selects the index that later changes are stamped with.
            pub inline fn setIndex(self: *Self, index: BlockAccessIndex) void {
                self.index = index;
            }

            pub inline fn addressAccess(self: *Self, address: Address) Error!void {
                return self.recorder.recordAddressAccess(address);
            }

            pub inline fn storageRead(self: *Self, address: Address, slot: u256) Error!void {
                return self.recorder.recordStorageRead(address, slot);
            }

            /// Records an SSTORE. A write whose post value equals the pre
            /// value is recorded as a read, as the EIP requires.
            pub inline fn storageWrite(self: *Self, address: Address, slot: u256, pre_value: u256, post_value: u256) Error!void {
                if (pre_value == post_value) {
                    return self.recorder.recordStorageRead(address, slot);
                }
                return self.recorder.recordStorageWrite(self.index, address, slot, post_value);
            }

            /// Records a balance. An unchanged balance records nothing.
            pub inline fn balanceChange(self: *Self, address: Address, pre_balance: u256, post_balance: u256) Error!void {
                if (pre_balance == post_balance) return;
                return self.recorder.recordBalanceChange(self.index, address, post_balance);
            }
        };
    }

    /// Recorder that records nothing. Use it before Amsterdam and whenever
    /// the caller needs no BAL. Every hook call inlines to nothing.
    pub const NoopRecorder = struct {
        pub const Error = error{};

        pub inline fn recordAddressAccess(_: *NoopRecorder, _: Address) Error!void {}
        pub inline fn recordStorageRead(_: *NoopRecorder, _: Address, _: u256) Error!void {}
        pub inline fn recordStorageWrite(_: *NoopRecorder, _: BlockAccessIndex, _: Address, _: u256, _: u256) Error!void {}
        pub inline fn recordBalanceChange(_: *NoopRecorder, _: BlockAccessIndex, _: Address, _: u256) Error!void {}
    };

    /// One recorded access, in call order.
    pub const Event = union(enum) {
        address_access: Address,
        storage_read: struct { address: Address, slot: u256 },
        storage_write: struct { index: BlockAccessIndex, address: Address, slot: u256, post_value: u256 },
        balance_change: struct { index: BlockAccessIndex, address: Address, post_balance: u256 },
    };

    /// Reference recorder that appends every event to a list in call order.
    ///
    /// It does no sorting, deduplication, or revert handling. Use it in
    /// tests and tracing. A consensus BAL builder replaces it with a
    /// recorder that maintains the sorted per-account structure.
    pub const ListRecorder = struct {
        allocator: std.mem.Allocator,
        events: std.ArrayList(Event) = .empty,

        pub const Error = std.mem.Allocator.Error;

        pub fn init(allocator: std.mem.Allocator) ListRecorder {
            return .{ .allocator = allocator };
        }

        pub fn deinit(self: *ListRecorder) void {
            self.events.deinit(self.allocator);
            self.* = undefined;
        }

        pub fn recordAddressAccess(self: *ListRecorder, address: Address) Error!void {
            try self.events.append(self.allocator, .{ .address_access = address });
        }

        pub fn recordStorageRead(self: *ListRecorder, address: Address, slot: u256) Error!void {
            try self.events.append(self.allocator, .{ .storage_read = .{ .address = address, .slot = slot } });
        }

        pub fn recordStorageWrite(self: *ListRecorder, index: BlockAccessIndex, address: Address, slot: u256, post_value: u256) Error!void {
            try self.events.append(self.allocator, .{ .storage_write = .{
                .index = index,
                .address = address,
                .slot = slot,
                .post_value = post_value,
            } });
        }

        pub fn recordBalanceChange(self: *ListRecorder, index: BlockAccessIndex, address: Address, post_balance: u256) Error!void {
            try self.events.append(self.allocator, .{ .balance_change = .{
                .index = index,
                .address = address,
                .post_balance = post_balance,
            } });
        }
    };
};

// ============================================================================
// EIP-8037 / EIP-8038: fork-parameterized state gas schedule
// ============================================================================

/// A gas charge split into the two EIP-8037 dimensions.
pub const GasSplit = struct {
    /// Regular (execution) gas.
    regular: u64,
    /// State gas. Always 0 before Amsterdam.
    state: u64,

    pub fn total(self: GasSplit) u64 {
        return self.regular + self.state;
    }
};

/// State-creation and state-access gas parameters for one fork.
///
/// Select a table with `GasSchedule.forFork(hardfork)` and read fields from
/// it. Opcode handlers stop hardcoding 2600, 20000, 32000 and stay correct
/// across the Amsterdam repricing.
///
/// `prague` holds the EIP-2929/EIP-3529 values in force from London through
/// Osaka. `amsterdam` holds the EIP-8037 and EIP-8038 Last Call values of
/// 2026-11-22, which EIP-8037 marks as not final.
pub const GasSchedule = struct {
    // ---- EIP-8038: state access (regular gas) ----
    /// Cold account access. Was `COLD_ACCOUNT_ACCESS_COST`.
    cold_account_access: u64,
    /// Cold storage slot access. Was `COLD_SLOAD_COST`.
    cold_storage_access: u64,
    /// Warm account or slot access. Was `WARM_STORAGE_READ_COST`.
    warm_access: u64,
    /// Writing an account (balance, nonce or code).
    account_write: u64,
    /// Writing a storage slot.
    storage_write: u64,
    /// CREATE and CREATE2 access cost: `account_write + cold_account_access`.
    create_access: u64,
    /// Refund for clearing a slot. Was `SSTORE_CLEARS_SCHEDULE`.
    storage_clear_refund: u64,
    /// EIP-2930 access list cost per storage key.
    access_list_storage_key: u64,
    /// EIP-2930 access list cost per address.
    access_list_address: u64,
    /// Stipend added to a call that transfers value.
    call_stipend: u64 = 2300,

    // ---- EIP-8037: state creation ----
    /// Cost per state byte (`CPSB`). 0 before Amsterdam.
    cost_per_state_byte: u64,
    /// State bytes charged for a new storage slot.
    state_bytes_per_storage_set: u64 = 64,
    /// State bytes charged for a new account.
    state_bytes_per_new_account: u64 = 120,
    /// State bytes charged for an EIP-7702 authorization.
    state_bytes_per_auth_base: u64 = 23,

    /// `GAS_CREATE`: charged by CREATE, CREATE2 and creation transactions.
    create: GasSplit,
    /// `GAS_NEW_ACCOUNT`: value-bearing call or SELFDESTRUCT to a dead account.
    new_account: GasSplit,
    /// `GAS_STORAGE_SET`: SSTORE from zero to nonzero.
    storage_set: GasSplit,
    /// EIP-7702 `PER_EMPTY_ACCOUNT_COST`.
    per_empty_account: GasSplit,
    /// EIP-7702 `PER_AUTH_BASE_COST`.
    per_auth_base: GasSplit,
    /// Code deposit: regular gas per byte of deployed code.
    code_deposit_regular_per_byte: u64,
    /// Code deposit: regular gas per 32-byte word of deployed code.
    code_deposit_regular_per_word: u64,

    // ---- EIP-8037: transaction limits ----
    /// `TX_MAX_TOTAL_GAS_LIMIT`: bound on `tx.gas` including the state gas
    /// reservoir. Null before Amsterdam.
    tx_max_total_gas_limit: ?u64,

    /// London through Osaka.
    pub const prague: GasSchedule = .{
        .cold_account_access = 2600,
        .cold_storage_access = 2100,
        .warm_access = 100,
        // EIP-8038 lists these three as the derived pre-Amsterdam values.
        .account_write = 6700,
        .storage_write = 2800,
        .create_access = 7000,
        .storage_clear_refund = 4800,
        .access_list_storage_key = 1900,
        .access_list_address = 2400,
        .cost_per_state_byte = 0,
        .create = .{ .regular = 32_000, .state = 0 },
        .new_account = .{ .regular = 25_000, .state = 0 },
        .storage_set = .{ .regular = 20_000, .state = 0 },
        .per_empty_account = .{ .regular = 25_000, .state = 0 },
        .per_auth_base = .{ .regular = 12_500, .state = 0 },
        .code_deposit_regular_per_byte = 200,
        .code_deposit_regular_per_word = 0,
        .tx_max_total_gas_limit = null,
    };

    /// Amsterdam draft (EIP-8037 + EIP-8038 Last Call, 2026-11-22).
    pub const amsterdam: GasSchedule = blk: {
        const cpsb: u64 = 1530;
        const cold_account_access: u64 = 3000;
        const warm_access: u64 = 100;
        const account_write: u64 = 9000;
        const create_access: u64 = 12_000;
        // EXECUTION_PER_AUTH_BASE_COST = calldata (101 bytes * 16)
        //   + PRECOMPILE_ECRECOVER + COLD_ACCOUNT_ACCESS + 2 * WARM_ACCESS.
        const execution_per_auth_base: u64 = 101 * 16 + 3000 + cold_account_access + 2 * warm_access;
        break :blk .{
            .cold_account_access = cold_account_access,
            .cold_storage_access = 2100,
            .warm_access = warm_access,
            .account_write = account_write,
            .storage_write = 10_000,
            .create_access = create_access,
            .storage_clear_refund = 11_616,
            .access_list_storage_key = 2000,
            .access_list_address = 2900,
            .cost_per_state_byte = cpsb,
            .create = .{ .regular = create_access, .state = 120 * cpsb },
            .new_account = .{ .regular = 0, .state = 120 * cpsb },
            .storage_set = .{ .regular = 0, .state = 64 * cpsb },
            .per_empty_account = .{ .regular = account_write, .state = 120 * cpsb },
            .per_auth_base = .{ .regular = execution_per_auth_base, .state = 23 * cpsb },
            .code_deposit_regular_per_byte = 0,
            .code_deposit_regular_per_word = 6,
            .tx_max_total_gas_limit = std.math.maxInt(u32),
        };
    };

    /// Selects the schedule for `fork`. Folds to `prague` at comptime when
    /// the hardfork enum has no `AMSTERDAM` tag.
    pub inline fn forFork(fork: anytype) *const GasSchedule {
        return if (supportsAmsterdam(fork)) &amsterdam else &prague;
    }

    /// `CALL_VALUE`: extra gas for a call that transfers value. EIP-8038
    /// defines it as `ACCOUNT_WRITE + CALL_STIPEND`, which is also 9000
    /// before Amsterdam.
    pub fn callValue(self: *const GasSchedule) u64 {
        return self.account_write + self.call_stipend;
    }

    /// Gas for depositing `code_len` bytes of contract code.
    pub fn codeDeposit(self: *const GasSchedule, code_len: u64) GasSplit {
        const words = (code_len + 31) / 32;
        return .{
            .regular = self.code_deposit_regular_per_byte * code_len + self.code_deposit_regular_per_word * words,
            .state = self.cost_per_state_byte * code_len,
        };
    }

    /// EIP-8037 system call gas limit: 30M plus state gas for
    /// `SYSTEM_MAX_SSTORES_PER_CALL` (16) new slots.
    pub fn systemCallGasLimit(self: *const GasSchedule) u64 {
        return 30_000_000 + 16 * self.storage_set.state;
    }
};

/// The EIP-8037 state gas reservoir of a transaction.
///
/// `tx.gas` above the EIP-7825 execution budget cannot buy execution. It
/// funds state gas only. State gas charges draw from the reservoir first and
/// fall back to `gas_left`.
pub const StateGasReservoir = struct {
    /// Regular gas available to execution.
    gas_left: u64,
    /// Gas reserved for state creation.
    reservoir: u64,

    /// Splits the gas of a transaction after intrinsic gas is known.
    /// Returns null when `intrinsic_gas` exceeds `tx_gas` or the EIP-7825 cap.
    pub fn init(tx_gas: u64, intrinsic_gas: u64) ?StateGasReservoir {
        if (intrinsic_gas > tx_gas or intrinsic_gas > EIP7825_TX_GAS_LIMIT_CAP) return null;
        const evm_gas = tx_gas - intrinsic_gas;
        const execution_gas_budget = EIP7825_TX_GAS_LIMIT_CAP - intrinsic_gas;
        const gas_left = @min(execution_gas_budget, evm_gas);
        return .{ .gas_left = gas_left, .reservoir = evm_gas - gas_left };
    }

    /// Charges state gas: reservoir first, then `gas_left`.
    pub fn chargeState(self: *StateGasReservoir, amount: u64) error{OutOfGas}!void {
        const from_reservoir = @min(self.reservoir, amount);
        const from_gas_left = amount - from_reservoir;
        if (from_gas_left > self.gas_left) return error.OutOfGas;
        self.reservoir -= from_reservoir;
        self.gas_left -= from_gas_left;
    }
};

// ============================================================================
// Tests
// ============================================================================

const testing = std.testing;

/// Mirrors the tail of Voltaire's `Hardfork` enum before commit f2b29c2a.
const ForkWithoutAmsterdam = enum { BERLIN, LONDON, MERGE, SHANGHAI, CANCUN, PRAGUE, OSAKA };
/// Mirrors the tail of Voltaire's `Hardfork` enum from commit f2b29c2a.
const ForkWithAmsterdam = enum { BERLIN, LONDON, MERGE, SHANGHAI, CANCUN, PRAGUE, OSAKA, AMSTERDAM };
/// A pin so old that it has no Osaka tag.
const ForkWithoutOsaka = enum { CANCUN, PRAGUE };

fn testAddress(last_byte: u8) Address {
    var a: Address = [_]u8{0} ** 20;
    a[19] = last_byte;
    return a;
}

fn hex32(comptime hex: *const [64]u8) [32]u8 {
    var out: [32]u8 = undefined;
    _ = std.fmt.hexToBytes(&out, hex) catch unreachable;
    return out;
}

test "hasFork detects enum tags at comptime" {
    try testing.expect(comptime hasFork(ForkWithAmsterdam, "AMSTERDAM"));
    try testing.expect(comptime !hasFork(ForkWithoutAmsterdam, "AMSTERDAM"));
    try testing.expect(comptime hasFork(ForkWithoutAmsterdam, "OSAKA"));
    try testing.expect(comptime !hasFork(ForkWithoutOsaka, "OSAKA"));
}

test "isAtLeast compares forks and is false for unknown tags" {
    try testing.expect(isAtLeast(ForkWithAmsterdam.CANCUN, "CANCUN"));
    try testing.expect(isAtLeast(ForkWithAmsterdam.AMSTERDAM, "BERLIN"));
    try testing.expect(!isAtLeast(ForkWithAmsterdam.BERLIN, "LONDON"));
    try testing.expect(!isAtLeast(ForkWithoutAmsterdam.OSAKA, "AMSTERDAM"));
    try testing.expect(!isAtLeast(ForkWithoutAmsterdam.OSAKA, "NOT_A_FORK"));
}

test "Osaka capabilities start at Osaka" {
    inline for (.{ ForkWithoutAmsterdam, ForkWithAmsterdam }) |H| {
        try testing.expect(!supportsClz(H.PRAGUE));
        try testing.expect(supportsClz(H.OSAKA));
        try testing.expect(!supportsP256Verify(H.PRAGUE));
        try testing.expect(supportsP256Verify(H.OSAKA));
        try testing.expect(!supportsEip7825TxGasCap(H.PRAGUE));
        try testing.expect(supportsEip7825TxGasCap(H.OSAKA));
    }
    try testing.expect(supportsClz(ForkWithAmsterdam.AMSTERDAM));
    try testing.expect(supportsP256Verify(ForkWithAmsterdam.AMSTERDAM));
    try testing.expect(supportsEip7825TxGasCap(ForkWithAmsterdam.AMSTERDAM));
}

test "Osaka capabilities are false on an enum without OSAKA" {
    try testing.expect(!supportsClz(ForkWithoutOsaka.PRAGUE));
    try testing.expect(!supportsP256Verify(ForkWithoutOsaka.PRAGUE));
    try testing.expect(!supportsEip7825TxGasCap(ForkWithoutOsaka.PRAGUE));
    try testing.expect(!supportsAmsterdam(ForkWithoutOsaka.PRAGUE));
}

test "supportsAmsterdam is comptime false without the AMSTERDAM tag" {
    // The call folds at comptime even with a runtime-typed argument: this
    // comptime block fails to compile if the helper reads a missing tag.
    comptime {
        for (std.enums.values(ForkWithoutAmsterdam)) |fork| {
            if (supportsAmsterdam(fork)) @compileError("unexpected Amsterdam support");
            if (supportsEthTransferLogs(fork)) @compileError("unexpected EIP-7708 support");
            if (supportsBlockAccessList(fork)) @compileError("unexpected EIP-7928 support");
            if (supportsStateGas(fork)) @compileError("unexpected EIP-8037 support");
        }
    }
    var runtime_fork = ForkWithoutAmsterdam.OSAKA;
    _ = &runtime_fork;
    try testing.expect(!supportsAmsterdam(runtime_fork));
}

test "supportsAmsterdam is true only at Amsterdam when the tag exists" {
    try testing.expect(!supportsAmsterdam(ForkWithAmsterdam.OSAKA));
    try testing.expect(supportsAmsterdam(ForkWithAmsterdam.AMSTERDAM));
    try testing.expect(supportsEthTransferLogs(ForkWithAmsterdam.AMSTERDAM));
    try testing.expect(supportsBlockAccessList(ForkWithAmsterdam.AMSTERDAM));
    try testing.expect(supportsStateGas(ForkWithAmsterdam.AMSTERDAM));
    try testing.expect(!supportsEthTransferLogs(ForkWithAmsterdam.OSAKA));
    try testing.expect(!supportsBlockAccessList(ForkWithAmsterdam.OSAKA));
    try testing.expect(!supportsStateGas(ForkWithAmsterdam.OSAKA));
}

test "Osaka constants match EIP-7939, EIP-7951 and EIP-7825" {
    try testing.expectEqual(@as(u8, 0x1e), CLZ_OPCODE);
    try testing.expectEqual(@as(u64, 5), CLZ_GAS);
    try testing.expectEqual(@as(u160, 0x100), std.mem.readInt(u160, &P256VERIFY_ADDRESS, .big));
    try testing.expectEqual(@as(u64, 6900), P256VERIFY_GAS);
    try testing.expectEqual(@as(usize, 160), P256VERIFY_INPUT_LEN);
    try testing.expectEqual(@as(u64, 1 << 24), EIP7825_TX_GAS_LIMIT_CAP);
}

test "txGasLimitCap applies from Osaka" {
    try testing.expectEqual(@as(?u64, null), txGasLimitCap(ForkWithAmsterdam.PRAGUE));
    try testing.expectEqual(@as(?u64, 16_777_216), txGasLimitCap(ForkWithAmsterdam.OSAKA));
    try testing.expect(isTxGasLimitAllowed(ForkWithAmsterdam.PRAGUE, 30_000_000));
    try testing.expect(isTxGasLimitAllowed(ForkWithAmsterdam.OSAKA, 16_777_216));
    try testing.expect(!isTxGasLimitAllowed(ForkWithAmsterdam.OSAKA, 16_777_217));
}

test "SYSTEM_ADDRESS is 0xff..fe" {
    try testing.expectEqual(@as(u160, 0xfffffffffffffffffffffffffffffffffffffffe), std.mem.readInt(u160, &SYSTEM_ADDRESS, .big));
}

test "EIP-7708 Transfer topic0 matches the ERC-20 Transfer topic" {
    const expected = hex32("ddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef");
    try testing.expectEqualSlices(u8, &expected, &eth_transfer_log.TRANSFER_TOPIC0_BYTES);
    try testing.expectEqual(std.mem.readInt(u256, &expected, .big), eth_transfer_log.TRANSFER_TOPIC0);
}

test "EIP-7708 draft burn topic0 is the keccak of its signature" {
    var expected: [32]u8 = undefined;
    std.crypto.hash.sha3.Keccak256.hash("Selfdestruct(address,uint256)", &expected, .{});
    try testing.expectEqualSlices(u8, &expected, &eth_transfer_log.SELFDESTRUCT_BURN_TOPIC0_BYTES);
    try testing.expect(eth_transfer_log.SELFDESTRUCT_BURN_TOPIC0 != eth_transfer_log.TRANSFER_TOPIC0);
}

test "transferLog builds a LOG3 from the system address" {
    const from = testAddress(0xaa);
    const to = testAddress(0xbb);
    const log = eth_transfer_log.transferLog(from, to, 1_000_000_000_000_000_000).?;

    try testing.expectEqualSlices(u8, &SYSTEM_ADDRESS, &log.address);
    try testing.expectEqual(@as(usize, 3), log.topics().len);
    try testing.expectEqual(eth_transfer_log.TRANSFER_TOPIC0, log.topics()[0]);
    try testing.expectEqual(@as(u256, 0xaa), log.topics()[1]);
    try testing.expectEqual(@as(u256, 0xbb), log.topics()[2]);
    try testing.expectEqual(@as(u256, 1_000_000_000_000_000_000), log.amount());
    // Data is the 32-byte big-endian amount.
    try testing.expectEqual(@as(u8, 0x0d), log.data[24]);
    try testing.expectEqual(@as(u8, 0), log.data[0]);
}

test "transferLog zero-pads a full 20-byte address into the topic" {
    const from: Address = [_]u8{0xff} ** 20;
    const log = eth_transfer_log.transferLog(from, testAddress(1), 1).?;
    try testing.expectEqual(@as(u256, std.math.maxInt(u160)), log.topics()[1]);
}

test "transferLog emits nothing for zero value or a self transfer" {
    const a = testAddress(1);
    const b = testAddress(2);
    try testing.expect(eth_transfer_log.transferLog(a, b, 0) == null);
    try testing.expect(eth_transfer_log.transferLog(a, a, 5) == null);
    try testing.expect(eth_transfer_log.transferLog(a, b, std.math.maxInt(u256)) != null);
}

test "selfdestructBurnLog builds a LOG2 for a nonzero balance" {
    const account = testAddress(0xcc);
    const log = eth_transfer_log.selfdestructBurnLog(account, 42).?;
    try testing.expectEqualSlices(u8, &SYSTEM_ADDRESS, &log.address);
    try testing.expectEqual(@as(usize, 2), log.topics().len);
    try testing.expectEqual(eth_transfer_log.SELFDESTRUCT_BURN_TOPIC0, log.topics()[0]);
    try testing.expectEqual(@as(u256, 0xcc), log.topics()[1]);
    try testing.expectEqual(@as(u256, 42), log.amount());
    try testing.expect(eth_transfer_log.selfdestructBurnLog(account, 0) == null);
}

test "selfdestructLog picks transfer, burn, or nothing" {
    const account = testAddress(1);
    const beneficiary = testAddress(2);

    const transfer = eth_transfer_log.selfdestructLog(account, beneficiary, 7, .no_burn).?;
    try testing.expectEqual(eth_transfer_log.TRANSFER_TOPIC0, transfer.topics()[0]);
    try testing.expectEqual(@as(u256, 2), transfer.topics()[2]);

    // EIP-8246: SELFDESTRUCT to self burns nothing and logs nothing.
    try testing.expect(eth_transfer_log.selfdestructLog(account, account, 7, .no_burn) == null);

    const burn = eth_transfer_log.selfdestructLog(account, account, 7, .emit_burn_log).?;
    try testing.expectEqual(eth_transfer_log.SELFDESTRUCT_BURN_TOPIC0, burn.topics()[0]);

    try testing.expect(eth_transfer_log.selfdestructLog(account, beneficiary, 0, .emit_burn_log) == null);
    try testing.expect(eth_transfer_log.selfdestructLog(account, account, 0, .emit_burn_log) == null);
}

test "SystemLog.toOwned copies topics and data without leaking" {
    const log = eth_transfer_log.transferLog(testAddress(1), testAddress(2), 99).?;
    const owned = try log.toOwned(testing.allocator);
    defer owned.deinit(testing.allocator);

    try testing.expectEqualSlices(u8, &SYSTEM_ADDRESS, &owned.address);
    try testing.expectEqualSlices(u256, log.topics(), owned.topics);
    try testing.expectEqualSlices(u8, &log.data, owned.data);
    try testing.expect(owned.data.ptr != &log.data);
}

test "SystemLog.toOwned frees partial allocations on failure" {
    const log = eth_transfer_log.transferLog(testAddress(1), testAddress(2), 99).?;
    try testing.checkAllAllocationFailures(testing.allocator, struct {
        fn run(allocator: std.mem.Allocator, l: eth_transfer_log.SystemLog) !void {
            const owned = try l.toOwned(allocator);
            owned.deinit(allocator);
        }
    }.run, .{log});
}

test "BAL indices follow EIP-7928" {
    const bal = block_access_list;
    try testing.expectEqual(@as(u32, 0), bal.PRE_EXECUTION_INDEX);
    try testing.expectEqual(@as(u32, 1), bal.transactionIndex(0));
    try testing.expectEqual(@as(u32, 5), bal.transactionIndex(4));
    try testing.expectEqual(@as(u32, 1), bal.postExecutionIndex(0));
    try testing.expectEqual(@as(u32, 6), bal.postExecutionIndex(5));
}

test "BAL empty hash is keccak256(0xc0)" {
    const expected = hex32("1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347");
    try testing.expectEqualSlices(u8, &expected, &block_access_list.EMPTY_HASH);
}

test "BAL item limit is block_gas_limit / ITEM_COST" {
    const bal = block_access_list;
    try testing.expectEqual(@as(u64, 2000), bal.ITEM_COST);
    try testing.expectEqual(@as(u64, 30_000), bal.maxItems(60_000_000));
    try testing.expect(bal.isWithinItemLimit(10_000, 20_000, 60_000_000));
    try testing.expect(!bal.isWithinItemLimit(10_000, 20_001, 60_000_000));
    try testing.expect(!bal.isWithinItemLimit(std.math.maxInt(u64), 1, 60_000_000));
}

test "Hook(NoopRecorder) cannot fail and runs at comptime" {
    const bal = block_access_list;
    try testing.expectEqual(error{}, bal.Hook(bal.NoopRecorder).Error);
    comptime {
        var recorder: bal.NoopRecorder = .{};
        var hook = bal.Hook(bal.NoopRecorder).init(&recorder);
        hook.setIndex(3);
        hook.addressAccess(testAddress(1)) catch unreachable;
        hook.storageRead(testAddress(1), 1) catch unreachable;
        hook.storageWrite(testAddress(1), 1, 0, 2) catch unreachable;
        hook.balanceChange(testAddress(1), 0, 2) catch unreachable;
    }
}

test "Hook forwards every access to ListRecorder in call order" {
    const bal = block_access_list;
    var recorder = bal.ListRecorder.init(testing.allocator);
    defer recorder.deinit();
    var hook = bal.Hook(bal.ListRecorder).init(&recorder);

    const a = testAddress(0x0a);
    hook.setIndex(bal.transactionIndex(0));
    try hook.addressAccess(a);
    try hook.storageRead(a, 7);
    try hook.storageWrite(a, 8, 0, 123);
    try hook.balanceChange(a, 10, 4);

    const events = recorder.events.items;
    try testing.expectEqual(@as(usize, 4), events.len);
    try testing.expectEqualSlices(u8, &a, &events[0].address_access);
    try testing.expectEqual(@as(u256, 7), events[1].storage_read.slot);
    try testing.expectEqualSlices(u8, &a, &events[1].storage_read.address);
    try testing.expectEqual(@as(u32, 1), events[2].storage_write.index);
    try testing.expectEqual(@as(u256, 8), events[2].storage_write.slot);
    try testing.expectEqual(@as(u256, 123), events[2].storage_write.post_value);
    try testing.expectEqual(@as(u32, 1), events[3].balance_change.index);
    try testing.expectEqual(@as(u256, 4), events[3].balance_change.post_balance);
}

test "Hook records a no-op SSTORE as a read" {
    const bal = block_access_list;
    var recorder = bal.ListRecorder.init(testing.allocator);
    defer recorder.deinit();
    var hook = bal.Hook(bal.ListRecorder).init(&recorder);

    try hook.storageWrite(testAddress(1), 9, 55, 55);
    try testing.expectEqual(@as(usize, 1), recorder.events.items.len);
    try testing.expectEqual(@as(u256, 9), recorder.events.items[0].storage_read.slot);
}

test "Hook records a write that zeroes a slot" {
    const bal = block_access_list;
    var recorder = bal.ListRecorder.init(testing.allocator);
    defer recorder.deinit();
    var hook = bal.Hook(bal.ListRecorder).init(&recorder);

    try hook.storageWrite(testAddress(1), 9, 55, 0);
    try testing.expectEqual(@as(u256, 0), recorder.events.items[0].storage_write.post_value);
}

test "Hook skips an unchanged balance" {
    const bal = block_access_list;
    var recorder = bal.ListRecorder.init(testing.allocator);
    defer recorder.deinit();
    var hook = bal.Hook(bal.ListRecorder).init(&recorder);

    try hook.balanceChange(testAddress(1), 100, 100);
    try testing.expectEqual(@as(usize, 0), recorder.events.items.len);
}

test "Hook stamps changes with the current block access index" {
    const bal = block_access_list;
    var recorder = bal.ListRecorder.init(testing.allocator);
    defer recorder.deinit();
    var hook = bal.Hook(bal.ListRecorder).init(&recorder);

    try hook.storageWrite(testAddress(1), 1, 0, 1);
    hook.setIndex(bal.transactionIndex(2));
    try hook.storageWrite(testAddress(1), 1, 1, 2);
    hook.setIndex(bal.postExecutionIndex(3));
    try hook.balanceChange(testAddress(2), 0, 1);

    try testing.expectEqual(@as(u32, 0), recorder.events.items[0].storage_write.index);
    try testing.expectEqual(@as(u32, 3), recorder.events.items[1].storage_write.index);
    try testing.expectEqual(@as(u32, 4), recorder.events.items[2].balance_change.index);
}

test "ListRecorder propagates allocation failure without leaking" {
    const bal = block_access_list;
    try testing.checkAllAllocationFailures(testing.allocator, struct {
        fn run(allocator: std.mem.Allocator) !void {
            var recorder = bal.ListRecorder.init(allocator);
            defer recorder.deinit();
            var hook = bal.Hook(bal.ListRecorder).init(&recorder);
            for (0..64) |i| {
                try hook.addressAccess(testAddress(@intCast(i)));
                try hook.storageRead(testAddress(@intCast(i)), i);
                try hook.storageWrite(testAddress(@intCast(i)), i, 0, 1);
                try hook.balanceChange(testAddress(@intCast(i)), 0, 1);
            }
        }
    }.run, .{});
}

test "assertRecorder accepts both built-in recorders" {
    comptime block_access_list.assertRecorder(block_access_list.NoopRecorder);
    comptime block_access_list.assertRecorder(block_access_list.ListRecorder);
}

test "GasSchedule.prague matches EIP-2929, EIP-2930 and EIP-3529" {
    const s = GasSchedule.prague;
    try testing.expectEqual(@as(u64, 2600), s.cold_account_access);
    try testing.expectEqual(@as(u64, 2100), s.cold_storage_access);
    try testing.expectEqual(@as(u64, 100), s.warm_access);
    try testing.expectEqual(@as(u64, 4800), s.storage_clear_refund);
    try testing.expectEqual(@as(u64, 1900), s.access_list_storage_key);
    try testing.expectEqual(@as(u64, 2400), s.access_list_address);
    try testing.expectEqual(@as(u64, 9000), s.callValue());
    try testing.expectEqual(s.account_write + s.cold_account_access, s.create_access + 2300);
    try testing.expectEqual(@as(u64, 32_000), s.create.total());
    try testing.expectEqual(@as(u64, 25_000), s.new_account.total());
    try testing.expectEqual(@as(u64, 20_000), s.storage_set.total());
    try testing.expectEqual(@as(u64, 25_000), s.per_empty_account.total());
    try testing.expectEqual(@as(u64, 12_500), s.per_auth_base.total());
    try testing.expectEqual(@as(?u64, null), s.tx_max_total_gas_limit);
}

test "GasSchedule.prague charges no state gas" {
    const s = GasSchedule.prague;
    try testing.expectEqual(@as(u64, 0), s.cost_per_state_byte);
    inline for (.{ s.create, s.new_account, s.storage_set, s.per_empty_account, s.per_auth_base }) |split| {
        try testing.expectEqual(@as(u64, 0), split.state);
    }
    try testing.expectEqual(GasSplit{ .regular = 200 * 24_576, .state = 0 }, s.codeDeposit(24_576));
    try testing.expectEqual(@as(u64, 30_000_000), s.systemCallGasLimit());
}

test "GasSchedule.amsterdam matches the EIP-8038 access table" {
    const s = GasSchedule.amsterdam;
    try testing.expectEqual(@as(u64, 3000), s.cold_account_access);
    try testing.expectEqual(@as(u64, 2100), s.cold_storage_access);
    try testing.expectEqual(@as(u64, 100), s.warm_access);
    try testing.expectEqual(@as(u64, 9000), s.account_write);
    try testing.expectEqual(@as(u64, 10_000), s.storage_write);
    try testing.expectEqual(@as(u64, 12_000), s.create_access);
    try testing.expectEqual(s.account_write + s.cold_account_access, s.create_access);
    try testing.expectEqual(@as(u64, 11_616), s.storage_clear_refund);
    try testing.expectEqual(@as(u64, 2000), s.access_list_storage_key);
    try testing.expectEqual(@as(u64, 2900), s.access_list_address);
    try testing.expectEqual(@as(u64, 11_300), s.callValue());
}

test "GasSchedule.amsterdam matches the EIP-8037 state gas table" {
    const s = GasSchedule.amsterdam;
    try testing.expectEqual(@as(u64, 1530), s.cost_per_state_byte);
    try testing.expectEqual(@as(u64, 64), s.state_bytes_per_storage_set);
    try testing.expectEqual(@as(u64, 120), s.state_bytes_per_new_account);
    try testing.expectEqual(@as(u64, 23), s.state_bytes_per_auth_base);

    try testing.expectEqual(GasSplit{ .regular = 12_000, .state = 183_600 }, s.create);
    try testing.expectEqual(GasSplit{ .regular = 0, .state = 183_600 }, s.new_account);
    try testing.expectEqual(GasSplit{ .regular = 0, .state = 97_920 }, s.storage_set);
    try testing.expectEqual(GasSplit{ .regular = 9000, .state = 183_600 }, s.per_empty_account);
    try testing.expectEqual(GasSplit{ .regular = 7816, .state = 35_190 }, s.per_auth_base);

    // State gas equals state bytes times CPSB for every row.
    try testing.expectEqual(s.state_bytes_per_new_account * s.cost_per_state_byte, s.create.state);
    try testing.expectEqual(s.state_bytes_per_storage_set * s.cost_per_state_byte, s.storage_set.state);
    try testing.expectEqual(s.state_bytes_per_auth_base * s.cost_per_state_byte, s.per_auth_base.state);

    try testing.expectEqual(@as(?u64, 4_294_967_295), s.tx_max_total_gas_limit);
    try testing.expectEqual(@as(u64, 31_566_720), s.systemCallGasLimit());
}

test "GasSchedule.codeDeposit charges per byte and per word at Amsterdam" {
    const s = GasSchedule.amsterdam;
    try testing.expectEqual(GasSplit{ .regular = 0, .state = 0 }, s.codeDeposit(0));
    try testing.expectEqual(GasSplit{ .regular = 6, .state = 1530 }, s.codeDeposit(1));
    try testing.expectEqual(GasSplit{ .regular = 6, .state = 32 * 1530 }, s.codeDeposit(32));
    try testing.expectEqual(GasSplit{ .regular = 12, .state = 33 * 1530 }, s.codeDeposit(33));
    try testing.expectEqual(@as(u64, 12 + 33 * 1530), s.codeDeposit(33).total());
}

test "GasSchedule.forFork selects by fork and folds without the tag" {
    try testing.expectEqual(&GasSchedule.prague, GasSchedule.forFork(ForkWithAmsterdam.OSAKA));
    try testing.expectEqual(&GasSchedule.amsterdam, GasSchedule.forFork(ForkWithAmsterdam.AMSTERDAM));
    inline for (comptime std.enums.values(ForkWithoutAmsterdam)) |fork| {
        try testing.expectEqual(&GasSchedule.prague, comptime GasSchedule.forFork(fork));
    }
}

test "StateGasReservoir.init splits gas at the EIP-7825 budget" {
    // Below the cap: everything is execution gas.
    const small = StateGasReservoir.init(1_000_000, 21_000).?;
    try testing.expectEqual(@as(u64, 979_000), small.gas_left);
    try testing.expectEqual(@as(u64, 0), small.reservoir);

    // Above the cap: the excess funds state gas only.
    const large = StateGasReservoir.init(20_000_000, 21_000).?;
    try testing.expectEqual(@as(u64, 16_777_216 - 21_000), large.gas_left);
    try testing.expectEqual(@as(u64, 20_000_000 - 16_777_216), large.reservoir);
    try testing.expectEqual(@as(u64, 20_000_000 - 21_000), large.gas_left + large.reservoir);

    try testing.expect(StateGasReservoir.init(20_000, 21_000) == null);
    try testing.expect(StateGasReservoir.init(std.math.maxInt(u32), 16_777_217) == null);
}

test "StateGasReservoir.chargeState draws from the reservoir first" {
    var r = StateGasReservoir{ .gas_left = 100, .reservoir = 50 };
    try r.chargeState(30);
    try testing.expectEqual(StateGasReservoir{ .gas_left = 100, .reservoir = 20 }, r);
    try r.chargeState(60);
    try testing.expectEqual(StateGasReservoir{ .gas_left = 60, .reservoir = 0 }, r);
    try testing.expectError(error.OutOfGas, r.chargeState(61));
    // A failed charge changes nothing.
    try testing.expectEqual(StateGasReservoir{ .gas_left = 60, .reservoir = 0 }, r);
    try r.chargeState(60);
    try testing.expectEqual(StateGasReservoir{ .gas_left = 0, .reservoir = 0 }, r);
}
