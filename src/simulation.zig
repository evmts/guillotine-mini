//! Call simulation over an isolated state overlay.
//!
//! Backs `eth_call`, `eth_estimateGas`, `eth_createAccessList`,
//! `eth_simulateV1`, `debug_traceCall` and `trace_call`. Every API runs on a
//! `StateOverlayHost`: reads fall through to an optional base host, writes stay
//! in the overlay, and the base host is never mutated.
//!
//! Transaction-level rules the EVM leaves to its caller (intrinsic gas, sender
//! nonce, gas purchase, refunds, priority fee) follow
//! `execution-specs/src/ethereum/forks/prague/fork.py:process_transaction`.
const std = @import("std");
const primitives = @import("voltaire");
const evm_mod = @import("evm.zig");
const host_mod = @import("host.zig");
const insp = @import("inspector.zig");
const trace_mod = @import("trace.zig");
const errors_mod = @import("errors.zig");
const crypto = @import("crypto").Crypto;
pub const tracers = @import("tracers.zig");

pub const Address = primitives.Address;
pub const Hardfork = primitives.Hardfork;
pub const HostInterface = host_mod.HostInterface;
pub const BlockContext = evm_mod.BlockContext;
pub const Inspector = insp.Inspector;
pub const MuxInspector = insp.MuxInspector;
pub const RevertDecoder = insp.RevertDecoder;
/// EIP-2930 entry accepted by `CallRequest.access_list`.
pub const AccessListInput = primitives.AccessList.AccessListEntry;
/// EIP-2930 entry produced by `createAccessList`.
pub const AccessListEntry = tracers.AccessListEntry;
pub const freeAccessListEntries = tracers.freeAccessListEntries;

const Allocator = std.mem.Allocator;
const EvmType = evm_mod.Evm(.{});
const ZERO_ADDRESS = primitives.ZERO_ADDRESS;

const TX_BASE_GAS: u64 = 21_000;
const TX_CREATE_GAS: u64 = 32_000;
const TX_DATA_ZERO_GAS: u64 = 4;
const TX_DATA_NONZERO_GAS_ISTANBUL: u64 = 16;
const TX_DATA_NONZERO_GAS_FRONTIER: u64 = 68;
const INITCODE_WORD_GAS: u64 = 2;
const MAX_INITCODE_SIZE: usize = 49_152;
const ACCESS_LIST_ADDRESS_GAS: u64 = 2_400;
const ACCESS_LIST_STORAGE_KEY_GAS: u64 = 1_900;
const FLOOR_CALLDATA_TOKEN_GAS: u64 = 10;
const STANDARD_TOKENS_PER_NONZERO_BYTE: u64 = 4;
const PER_EMPTY_ACCOUNT_COST: u64 = 25_000;
const PER_AUTH_BASE_COST: u64 = 12_500;
const DELEGATION_PREFIX = evm_mod.DELEGATION_PREFIX;
/// Geth `estimateGasErrorRatio`: stop the search once hi is within 1.5% of lo.
const ESTIMATE_ERROR_RATIO_PER_MILLE: u64 = 15;
const MAX_ACCESS_LIST_ITERATIONS: usize = 10;
/// Geth caps `eth_simulateV1` at 256 blocks.
pub const MAX_SIMULATED_BLOCKS: usize = 256;
/// Geth spaces simulated blocks 12 seconds apart unless overridden.
const SIMULATED_BLOCK_TIME: u64 = 12;

// ---------------------------------------------------------------------------
// Overrides
// ---------------------------------------------------------------------------

pub const SlotEntry = struct { slot: u256, value: u256 };

/// Geth `override.OverrideAccount`.
pub const AccountOverride = struct {
    balance: ?u256 = null,
    nonce: ?u64 = null,
    code: ?[]const u8 = null,
    /// Full storage replacement: slots not listed read zero, not the base value.
    state: ?[]const SlotEntry = null,
    /// Sparse patch: slots not listed read through to the base host.
    state_diff: ?[]const SlotEntry = null,
};

pub const AccountOverrideEntry = struct { address: Address, override: AccountOverride };
pub const StateOverride = []const AccountOverrideEntry;

/// Geth `override.BlockOverrides`. Null fields keep the base value.
pub const BlockOverride = struct {
    number: ?u64 = null,
    time: ?u64 = null,
    gas_limit: ?u64 = null,
    fee_recipient: ?Address = null,
    prev_randao: ?u256 = null,
    base_fee: ?u256 = null,
    blob_base_fee: ?u256 = null,

    pub fn apply(self: BlockOverride, base: BlockContext) BlockContext {
        var ctx = base;
        if (self.number) |v| ctx.block_number = v;
        if (self.time) |v| ctx.block_timestamp = v;
        if (self.gas_limit) |v| ctx.block_gas_limit = v;
        if (self.fee_recipient) |v| ctx.block_coinbase = v;
        if (self.prev_randao) |v| ctx.block_prevrandao = v;
        if (self.base_fee) |v| ctx.block_base_fee = v;
        if (self.blob_base_fee) |v| ctx.blob_base_fee = v;
        return ctx;
    }
};

// ---------------------------------------------------------------------------
// StateOverlayHost
// ---------------------------------------------------------------------------

/// Copy-on-write `HostInterface` over an optional base host.
///
/// Writes land in the overlay and are journaled, so `checkpoint`/`revertTo`
/// can discard a failed call while keeping earlier successful ones. Host
/// setters cannot fail; an allocation failure is kept in `err` and callers
/// must check it after execution.
pub const StateOverlayHost = struct {
    const SlotKey = struct { address: [20]u8, slot: u256 };

    const Account = struct {
        balance: ?u256 = null,
        nonce: ?u64 = null,
        code: ?[]const u8 = null,
        /// Storage replaced wholesale: slot misses read zero.
        storage_cleared: bool = false,
        deleted: bool = false,
    };

    const Undo = union(enum) {
        account: struct { address: Address, prev: ?Account },
        slot: struct { key: SlotKey, prev: ?u256 },
    };

    allocator: Allocator,
    /// Owns code bytes; code is never freed before `deinit`, so undo entries
    /// and EVM-held slices stay valid.
    code_arena: std.heap.ArenaAllocator,
    base: ?HostInterface,
    accounts: std.AutoHashMapUnmanaged(Address, Account) = .{},
    slots: std.AutoHashMapUnmanaged(SlotKey, u256) = .{},
    journal: std.ArrayList(Undo) = .{},
    err: ?anyerror = null,

    pub fn init(allocator: Allocator, base: ?HostInterface) StateOverlayHost {
        return .{ .allocator = allocator, .code_arena = std.heap.ArenaAllocator.init(allocator), .base = base };
    }

    pub fn deinit(self: *StateOverlayHost) void {
        self.accounts.deinit(self.allocator);
        self.slots.deinit(self.allocator);
        self.journal.deinit(self.allocator);
        self.code_arena.deinit();
        self.* = undefined;
    }

    pub fn host(self: *StateOverlayHost) HostInterface {
        return .{ .ptr = self, .vtable = &vtable };
    }

    /// Journal position to pass to `revertTo`.
    pub fn checkpoint(self: *const StateOverlayHost) usize {
        return self.journal.items.len;
    }

    /// Undo every overlay write made after `mark`.
    pub fn revertTo(self: *StateOverlayHost, mark: usize) void {
        while (self.journal.items.len > mark) {
            switch (self.journal.pop().?) {
                .account => |u| {
                    if (u.prev) |prev| {
                        self.accounts.getPtr(u.address).?.* = prev;
                    } else {
                        _ = self.accounts.remove(u.address);
                    }
                },
                .slot => |u| {
                    if (u.prev) |prev| {
                        // dropSlots removed it; removal leaves capacity behind.
                        self.slots.getOrPutAssumeCapacity(u.key).value_ptr.* = prev;
                    } else {
                        _ = self.slots.remove(u.key);
                    }
                },
            }
        }
    }

    /// Validate every override, then apply them. `state` and `state_diff`
    /// on one account is rejected before anything changes.
    pub fn applyOverrides(self: *StateOverlayHost, overrides: StateOverride) !void {
        for (overrides) |entry| {
            if (entry.override.state != null and entry.override.state_diff != null) return error.ConflictingStateOverrides;
        }
        for (overrides) |entry| {
            const o = entry.override;
            const acct = try self.mutAccount(entry.address);
            if (o.balance) |v| acct.balance = v;
            if (o.nonce) |v| acct.nonce = v;
            if (o.code) |code| acct.code = try self.code_arena.allocator().dupe(u8, code);
            if (o.state) |slots| {
                try self.dropSlots(entry.address);
                (try self.mutAccount(entry.address)).storage_cleared = true;
                for (slots) |s| try self.putSlot(entry.address, s.slot, s.value);
            }
            if (o.state_diff) |slots| {
                for (slots) |s| try self.putSlot(entry.address, s.slot, s.value);
            }
        }
    }

    // -- reads ---------------------------------------------------------------

    pub fn getBalance(self: *const StateOverlayHost, address: Address) u256 {
        if (self.accounts.get(address)) |acct| if (acct.balance) |v| return v;
        return if (self.base) |b| b.getBalance(address) else 0;
    }

    pub fn getNonce(self: *const StateOverlayHost, address: Address) u64 {
        if (self.accounts.get(address)) |acct| if (acct.nonce) |v| return v;
        return if (self.base) |b| b.getNonce(address) else 0;
    }

    pub fn getCode(self: *const StateOverlayHost, address: Address) []const u8 {
        if (self.accounts.get(address)) |acct| if (acct.code) |v| return v;
        return if (self.base) |b| b.getCode(address) else &.{};
    }

    pub fn getStorage(self: *const StateOverlayHost, address: Address, slot: u256) u256 {
        if (self.slots.get(.{ .address = address.bytes, .slot = slot })) |v| return v;
        if (self.accounts.get(address)) |acct| if (acct.storage_cleared) return 0;
        return if (self.base) |b| b.getStorage(address, slot) else 0;
    }

    pub fn accountExists(self: *const StateOverlayHost, address: Address) bool {
        if (self.getBalance(address) != 0 or self.getNonce(address) != 0 or self.getCode(address).len != 0) return true;
        if (self.accounts.get(address)) |acct| if (acct.deleted) return false;
        return if (self.base) |b| b.accountExists(address) else false;
    }

    pub fn accountHasStorage(self: *const StateOverlayHost, address: Address) bool {
        var it = self.slots.iterator();
        while (it.next()) |entry| {
            if (std.mem.eql(u8, &entry.key_ptr.address, &address.bytes) and entry.value_ptr.* != 0) return true;
        }
        if (self.accounts.get(address)) |acct| if (acct.storage_cleared) return false;
        return if (self.base) |b| b.accountHasStorage(address) else false;
    }

    // -- writes --------------------------------------------------------------

    pub fn setBalance(self: *StateOverlayHost, address: Address, value: u256) void {
        const acct = self.mutAccount(address) catch |e| return self.fail(e);
        acct.balance = value;
    }

    pub fn setNonce(self: *StateOverlayHost, address: Address, value: u64) void {
        const acct = self.mutAccount(address) catch |e| return self.fail(e);
        acct.nonce = value;
    }

    pub fn setCode(self: *StateOverlayHost, address: Address, code: []const u8) void {
        const copy = self.code_arena.allocator().dupe(u8, code) catch |e| return self.fail(e);
        const acct = self.mutAccount(address) catch |e| return self.fail(e);
        acct.code = copy;
    }

    pub fn setStorage(self: *StateOverlayHost, address: Address, slot: u256, value: u256) void {
        self.putSlot(address, slot, value) catch |e| self.fail(e);
    }

    pub fn deleteAccount(self: *StateOverlayHost, address: Address) void {
        self.dropSlots(address) catch |e| return self.fail(e);
        const acct = self.mutAccount(address) catch |e| return self.fail(e);
        acct.* = .{ .balance = 0, .nonce = 0, .code = &.{}, .storage_cleared = true, .deleted = true };
    }

    fn fail(self: *StateOverlayHost, e: anyerror) void {
        if (self.err == null) self.err = e;
    }

    /// Journal the account's current overlay entry, then return it for mutation.
    fn mutAccount(self: *StateOverlayHost, address: Address) !*Account {
        try self.journal.ensureUnusedCapacity(self.allocator, 1);
        const entry = try self.accounts.getOrPut(self.allocator, address);
        if (entry.found_existing) {
            self.journal.appendAssumeCapacity(.{ .account = .{ .address = address, .prev = entry.value_ptr.* } });
            // A write after deletion revives the account.
            entry.value_ptr.deleted = false;
        } else {
            entry.value_ptr.* = .{};
            self.journal.appendAssumeCapacity(.{ .account = .{ .address = address, .prev = null } });
        }
        return entry.value_ptr;
    }

    fn putSlot(self: *StateOverlayHost, address: Address, slot: u256, value: u256) !void {
        try self.journal.ensureUnusedCapacity(self.allocator, 1);
        const key = SlotKey{ .address = address.bytes, .slot = slot };
        const entry = try self.slots.getOrPut(self.allocator, key);
        const prev: ?u256 = if (entry.found_existing) entry.value_ptr.* else null;
        self.journal.appendAssumeCapacity(.{ .slot = .{ .key = key, .prev = prev } });
        entry.value_ptr.* = value;
    }

    /// Remove all overlay slots of `address`, journaling each removal.
    fn dropSlots(self: *StateOverlayHost, address: Address) !void {
        var doomed: std.ArrayList(SlotKey) = .{};
        defer doomed.deinit(self.allocator);
        var it = self.slots.iterator();
        while (it.next()) |entry| {
            if (std.mem.eql(u8, &entry.key_ptr.address, &address.bytes)) try doomed.append(self.allocator, entry.key_ptr.*);
        }
        try self.journal.ensureUnusedCapacity(self.allocator, doomed.items.len);
        for (doomed.items) |key| {
            const removed = self.slots.fetchRemove(key).?;
            self.journal.appendAssumeCapacity(.{ .slot = .{ .key = key, .prev = removed.value } });
        }
    }

    fn from(ptr: *anyopaque) *StateOverlayHost {
        return @ptrCast(@alignCast(ptr));
    }

    const vtable: HostInterface.VTable = .{
        .getBalance = struct {
            fn f(p: *anyopaque, a: Address) u256 {
                return from(p).getBalance(a);
            }
        }.f,
        .setBalance = struct {
            fn f(p: *anyopaque, a: Address, v: u256) void {
                from(p).setBalance(a, v);
            }
        }.f,
        .getCode = struct {
            fn f(p: *anyopaque, a: Address) []const u8 {
                return from(p).getCode(a);
            }
        }.f,
        .setCode = struct {
            fn f(p: *anyopaque, a: Address, c: []const u8) void {
                from(p).setCode(a, c);
            }
        }.f,
        .getStorage = struct {
            fn f(p: *anyopaque, a: Address, s: u256) u256 {
                return from(p).getStorage(a, s);
            }
        }.f,
        .setStorage = struct {
            fn f(p: *anyopaque, a: Address, s: u256, v: u256) void {
                from(p).setStorage(a, s, v);
            }
        }.f,
        .getNonce = struct {
            fn f(p: *anyopaque, a: Address) u64 {
                return from(p).getNonce(a);
            }
        }.f,
        .setNonce = struct {
            fn f(p: *anyopaque, a: Address, n: u64) void {
                from(p).setNonce(a, n);
            }
        }.f,
        .accountExists = struct {
            fn f(p: *anyopaque, a: Address) bool {
                return from(p).accountExists(a);
            }
        }.f,
        .accountHasStorage = struct {
            fn f(p: *anyopaque, a: Address) bool {
                return from(p).accountHasStorage(a);
            }
        }.f,
        .deleteAccount = struct {
            fn f(p: *anyopaque, a: Address) void {
                from(p).deleteAccount(a);
            }
        }.f,
    };
};

// ---------------------------------------------------------------------------
// Requests and results
// ---------------------------------------------------------------------------

/// A transaction-shaped call. `to == null` simulates contract creation.
pub const CallRequest = struct {
    from: Address = ZERO_ADDRESS,
    to: ?Address = null,
    /// Defaults to the block gas limit, capped by what `from` can pay for.
    gas: ?u64 = null,
    gas_price: u256 = 0,
    dynamic_fee: bool = false,
    value: u256 = 0,
    input: []const u8 = &.{},
    access_list: ?[]const AccessListInput = null,
    /// EIP-7702 list. Null means absent. A present list makes the request a
    /// set-code transaction on Prague+, which must not be empty.
    authorization_list: ?[]const AuthorizationTuple = null,
    /// Request fee caps as sent. `gas_price` holds the effective price the
    /// simulation charges; these only describe the transaction.
    max_fee_per_gas: ?u256 = null,
    max_priority_fee_per_gas: ?u256 = null,
    /// EIP-4844 fields. The hashes reach BLOBHASH; blob gas is not charged.
    max_fee_per_blob_gas: ?u256 = null,
    blob_versioned_hashes: ?[]const [32]u8 = null,
    /// Checked only when simulation validation is on.
    nonce: ?u64 = null,

    pub fn transactionType(self: CallRequest, hardfork: Hardfork) u8 {
        if (self.isSetCode(hardfork)) return 4;
        if (self.isBlob(hardfork)) return 3;
        if (self.dynamic_fee) return 2;
        if (self.access_list != null) return 1;
        return 0;
    }

    pub fn isSetCode(self: CallRequest, hardfork: Hardfork) bool {
        return hardfork.isAtLeast(.PRAGUE) and self.authorization_list != null;
    }

    pub fn isBlob(self: CallRequest, hardfork: Hardfork) bool {
        return hardfork.isAtLeast(.CANCUN) and self.blob_versioned_hashes != null;
    }

    pub fn authorizations(self: CallRequest) []const AuthorizationTuple {
        return self.authorization_list orelse &.{};
    }
};

pub const AuthorizationTuple = struct {
    chain_id: u256,
    address: Address,
    nonce: u64,
    /// Test-only: skips signature recovery. RPC parsing never sets it; real
    /// tuples carry `y_parity`, `r` and `s`.
    authority: ?Address = null,
    y_parity: u8 = 0,
    r: u256 = 0,
    s: u256 = 0,

    fn recoverAuthority(self: AuthorizationTuple, allocator: Allocator) !?Address {
        if (self.authority) |address| return address;
        if (self.y_parity > 1 or self.r == 0 or self.r >= crypto.SECP256K1_N or
            self.s == 0 or self.s > crypto.SECP256K1_N / 2) return null;

        const hash = try self.signingHash(allocator);
        return crypto.unaudited_recoverAddress(hash, .{ .v = self.y_parity, .r = self.r, .s = self.s }) catch null;
    }

    fn signingHash(self: AuthorizationTuple, allocator: Allocator) ![32]u8 {
        const chain_id = try primitives.Rlp.encode(allocator, self.chain_id);
        defer allocator.free(chain_id);
        const nonce = try primitives.Rlp.encode(allocator, self.nonce);
        defer allocator.free(nonce);
        const address = try primitives.Rlp.encodeBytes(allocator, &self.address.bytes);
        defer allocator.free(address);

        // These fields encode to at most 63 bytes, so the long list form
        // uses a single length byte.
        const payload_len: u8 = @intCast(chain_id.len + address.len + nonce.len);
        var hash = std.crypto.hash.sha3.Keccak256.init(.{});
        hash.update(&.{0x05});
        if (payload_len < 56) {
            hash.update(&.{0xc0 + payload_len});
        } else {
            hash.update(&.{ 0xf8, payload_len });
        }
        hash.update(chain_id);
        hash.update(address);
        hash.update(nonce);
        var digest: [32]u8 = undefined;
        hash.final(&digest);
        return digest;
    }
};

/// State and block a provider resolves for a block tag.
pub const BlockState = struct {
    host: ?HostInterface,
    block: BlockContext,
    hardfork: Hardfork,
    block_hash: [32]u8 = @splat(0),
};

/// A mined transaction re-executed on the state just before it.
pub const TransactionReplay = struct {
    state: BlockState,
    request: CallRequest,
    tx_hash: [32]u8,
    tx_index: u64,
};

pub const SimLog = struct {
    address: Address,
    topics: []const [32]u8,
    data: []const u8,
};

pub const SimulationCallResult = struct {
    success: bool,
    output: []u8,
    /// Gas charged to the sender: intrinsic + execution - refund, at least the
    /// EIP-7623 floor.
    gas_used: u64,
    gas_limit: u64,
    logs: []SimLog,
    /// Geth-style VM error, e.g. "execution reverted" or "out of gas".
    error_msg: ?[]u8 = null,
    /// Decoded `Error(string)` / `Panic(uint256)` reason for reverts.
    revert_reason: ?[]u8 = null,
    created_address: ?Address = null,

    pub fn reverted(self: *const SimulationCallResult) bool {
        const msg = self.error_msg orelse return false;
        return std.mem.eql(u8, msg, "execution reverted");
    }

    pub fn deinit(self: *SimulationCallResult, allocator: Allocator) void {
        allocator.free(self.output);
        freeLogs(allocator, self.logs);
        if (self.error_msg) |m| allocator.free(m);
        if (self.revert_reason) |m| allocator.free(m);
        self.* = undefined;
    }
};

fn freeLogs(allocator: Allocator, logs: []SimLog) void {
    for (logs) |entry| {
        allocator.free(entry.topics);
        allocator.free(entry.data);
    }
    allocator.free(logs);
}

/// Static transaction cost (execution-specs `calculate_intrinsic_cost`).
pub fn intrinsicGas(req: CallRequest, hardfork: Hardfork) u64 {
    var gas: u64 = TX_BASE_GAS;
    const nonzero_cost = if (hardfork.isAtLeast(.ISTANBUL)) TX_DATA_NONZERO_GAS_ISTANBUL else TX_DATA_NONZERO_GAS_FRONTIER;
    for (req.input) |byte| gas +|= if (byte == 0) TX_DATA_ZERO_GAS else nonzero_cost;
    if (req.to == null) {
        if (hardfork.isAtLeast(.HOMESTEAD)) gas +|= TX_CREATE_GAS;
        if (hardfork.isAtLeast(.SHANGHAI)) gas +|= INITCODE_WORD_GAS * ((req.input.len + 31) / 32);
    }
    if (req.access_list) |list| {
        for (list) |entry| gas +|= ACCESS_LIST_ADDRESS_GAS +| ACCESS_LIST_STORAGE_KEY_GAS * entry.storage_keys.len;
    }
    if (req.isSetCode(hardfork)) gas +|= PER_EMPTY_ACCOUNT_COST *| req.authorizations().len;
    return gas;
}

/// EIP-7623 calldata floor (Prague+), zero before Prague.
pub fn floorDataGas(req: CallRequest, hardfork: Hardfork) u64 {
    if (hardfork.isBefore(.PRAGUE)) return 0;
    var tokens: u64 = 0;
    for (req.input) |byte| tokens +|= if (byte == 0) 1 else STANDARD_TOKENS_PER_NONZERO_BYTE;
    return TX_BASE_GAS +| tokens *| FLOOR_CALLDATA_TOKEN_GAS;
}

/// Lowest gas limit a transaction may carry.
pub fn minimumGas(req: CallRequest, hardfork: Hardfork) u64 {
    return @max(intrinsicGas(req, hardfork), floorDataGas(req, hardfork));
}

pub const ExecOptions = struct {
    /// `eth_simulateV1` `validation: true`: enforce nonce and base fee.
    validation: bool = false,
};

/// Run one transaction on `overlay`. State changes stay in the overlay; the
/// caller decides whether to keep them. Errors mean the transaction is
/// invalid and nothing was executed; VM failures return `success = false`.
pub fn executeOnOverlay(
    allocator: Allocator,
    overlay: *StateOverlayHost,
    block: BlockContext,
    hardfork: Hardfork,
    req: CallRequest,
    observer: ?Inspector,
    step_tracer: ?*trace_mod.Tracer,
    options: ExecOptions,
) !SimulationCallResult {
    if (req.to == null and hardfork.isAtLeast(.SHANGHAI) and req.input.len > MAX_INITCODE_SIZE) return error.InitcodeTooLarge;
    const has_authorizations = req.isSetCode(hardfork);
    if (has_authorizations and req.to == null) return error.AuthorizationRequiresRecipient;
    // EIP-7702: "authorization_list must not be empty".
    if (has_authorizations and req.authorizations().len == 0) return error.EmptyAuthorizationList;
    const sender_nonce = overlay.getNonce(req.from);
    if (options.validation) {
        if (req.nonce) |n| {
            if (n < sender_nonce) return error.NonceTooLow;
            if (n > sender_nonce) return error.NonceTooHigh;
        }
        if (hardfork.isAtLeast(.LONDON) and req.gas_price < block.block_base_fee) return error.FeeCapTooLow;
    }
    if (sender_nonce == std.math.maxInt(u64)) return error.NonceOverflow;

    const balance = overlay.getBalance(req.from);
    const gas_limit = req.gas orelse defaultGas(block.block_gas_limit, balance, req);
    const floor = floorDataGas(req, hardfork);
    const intrinsic = intrinsicGas(req, hardfork);
    if (gas_limit < @max(intrinsic, floor)) return error.IntrinsicGasTooLow;

    const fee = std.math.mul(u256, gas_limit, req.gas_price) catch return error.InsufficientFunds;
    const cost = std.math.add(u256, fee, req.value) catch return error.InsufficientFunds;
    if (balance < cost) return error.InsufficientFunds;

    const transaction_start = overlay.checkpoint();
    errdefer overlay.revertTo(transaction_start);
    // Nonce bump and gas purchase happen before the message, as in Geth.
    overlay.setNonce(req.from, sender_nonce + 1);
    if (observer) |o| o.onNonceChange(.{ .frame_id = 0, .address = req.from, .prev_nonce = sender_nonce, .new_nonce = sender_nonce + 1 });
    if (fee != 0) setObservedBalance(overlay, observer, req.from, balance - fee);

    const exec_gas = gas_limit - intrinsic;
    var evm: EvmType = undefined;
    try evm.init(allocator, overlay.host(), hardfork, block, req.from, req.gas_price, null);
    defer evm.deinit();
    if (req.isBlob(hardfork)) evm.setBlobVersionedHashes(req.blob_versioned_hashes.?);
    const authorization_refund = if (has_authorizations)
        try applyAuthorizations(evm.arena.allocator(), &evm, overlay, block.chain_id, req, observer)
    else blk: {
        evm.setAccessList(req.access_list);
        break :blk 0;
    };
    if (overlay.err) |e| return e;
    const message_start = overlay.checkpoint();
    if (observer) |o| evm.setInspector(o);
    if (step_tracer) |t| evm.setTracer(t);

    const result: EvmType.CallResult = if (exec_gas == 0)
        zeroGasCall(&evm, overlay, req)
    else if (req.to) |to|
        evm.call(.{ .call = .{ .caller = req.from, .to = to, .value = req.value, .input = req.input, .gas = exec_gas } })
    else
        evm.call(.{ .create = .{ .caller = req.from, .value = req.value, .init_code = req.input, .gas = exec_gas } });
    if (overlay.err) |e| return e;
    if (has_authorizations and !result.success) overlay.revertTo(message_start);

    const used_raw = gas_limit - @min(result.gas_left, exec_gas);
    const quotient: u64 = if (hardfork.isBefore(.LONDON)) 2 else 5;
    const message_refund = if (result.success) result.refund_counter else 0;
    const refund = @min(authorization_refund +| message_refund, used_raw / quotient);
    const gas_used = @max(used_raw - refund, floor);

    if (req.gas_price != 0) {
        setObservedBalance(overlay, observer, req.from, overlay.getBalance(req.from) + @as(u256, gas_limit - gas_used) * req.gas_price);
        if (req.gas_price > block.block_base_fee) {
            const coinbase = block.block_coinbase;
            const tip = @as(u256, gas_used) * (req.gas_price - block.block_base_fee);
            setObservedBalance(overlay, observer, coinbase, overlay.getBalance(coinbase) +% tip);
        }
    }
    if (overlay.err) |e| return e;

    return copyResult(allocator, result, gas_used, gas_limit);
}

fn applyAuthorizations(
    allocator: Allocator,
    evm: *EvmType,
    overlay: *StateOverlayHost,
    chain_id: u256,
    req: CallRequest,
    observer: ?Inspector,
) !u64 {
    const access_list = req.access_list orelse &.{};
    const tuples = req.authorizations();
    const warm = try allocator.alloc(AccessListInput, try std.math.add(usize, access_list.len, tuples.len));
    @memcpy(warm[0..access_list.len], access_list);
    var len = access_list.len;
    var refund: u64 = 0;
    for (tuples) |tuple| {
        if (tuple.chain_id != 0 and tuple.chain_id != chain_id) continue;
        if (tuple.nonce == std.math.maxInt(u64)) continue;
        const authority = try tuple.recoverAuthority(allocator) orelse continue;
        // Warming survives even if the authority fails the code or nonce check.
        warm[len] = .{ .address = authority, .storage_keys = &.{} };
        len += 1;

        const previous_code = overlay.getCode(authority);
        if (previous_code.len != 0 and evm_mod.parseDelegation(previous_code) == null) continue;
        if (overlay.getNonce(authority) != tuple.nonce) continue;
        if (overlay.accountExists(authority)) refund +|= PER_EMPTY_ACCOUNT_COST - PER_AUTH_BASE_COST;

        const designation = DELEGATION_PREFIX ++ tuple.address.bytes;
        const code: []const u8 = if (tuple.address.equals(ZERO_ADDRESS)) &.{} else &designation;
        overlay.setCode(authority, code);
        overlay.setNonce(authority, tuple.nonce + 1);
        if (overlay.err) |e| return e;
        if (observer) |o| {
            o.onCodeChange(.{ .frame_id = 0, .address = authority, .prev_code = previous_code, .new_code = overlay.getCode(authority) });
            o.onNonceChange(.{ .frame_id = 0, .address = authority, .prev_nonce = tuple.nonce, .new_nonce = tuple.nonce + 1 });
        }
    }
    evm.setAccessList(warm[0..len]);
    return refund;
}

/// Geth caps an unspecified gas limit by what the sender can afford.
fn defaultGas(block_gas_limit: u64, balance: u256, req: CallRequest) u64 {
    if (req.gas_price == 0) return block_gas_limit;
    const spendable = if (balance > req.value) balance - req.value else 0;
    const allowance = spendable / req.gas_price;
    return if (allowance < block_gas_limit) @intCast(allowance) else block_gas_limit;
}

fn setObservedBalance(overlay: *StateOverlayHost, observer: ?Inspector, address: Address, value: u256) void {
    const prev = overlay.getBalance(address);
    overlay.setBalance(address, value);
    if (observer) |o| o.onBalanceChange(.{ .frame_id = 0, .address = address, .prev_balance = prev, .new_balance = value });
}

/// A transaction whose gas is exactly intrinsic. The EVM rejects a zero-gas
/// message, so model it here: value moves, and only code that starts with
/// STOP (the one zero-cost halting opcode) can succeed.
fn zeroGasCall(evm: *EvmType, overlay: *StateOverlayHost, req: CallRequest) EvmType.CallResult {
    const out_of_gas: EvmType.CallResult = .{ .success = false, .gas_left = 0, .output = &.{}, .error_info = "OutOfGas" };
    const to = req.to orelse return out_of_gas;
    const code = evm.get_code(to);
    if (code.len != 0 and code[0] != 0x00) return out_of_gas;
    if (req.value != 0 and !req.from.equals(to)) {
        overlay.setBalance(req.from, overlay.getBalance(req.from) - req.value);
        overlay.setBalance(to, overlay.getBalance(to) +% req.value);
    }
    return .{ .success = true, .gas_left = 0, .output = &.{} };
}

fn errorMessage(result: EvmType.CallResult) []const u8 {
    const name = result.error_info orelse return insp.formatErrorName(error.RevertExecution);
    inline for (@typeInfo(errors_mod.CallError).error_set.?) |entry| {
        if (std.mem.eql(u8, name, entry.name)) return insp.formatErrorName(@field(anyerror, entry.name));
    }
    inline for (.{ "OutOfGas", "GasZeroError", "InsufficientBalance", "ContractCollision" }) |known| {
        if (std.mem.eql(u8, name, known)) return insp.formatErrorName(@field(anyerror, known));
    }
    return name;
}

fn copyResult(allocator: Allocator, result: EvmType.CallResult, gas_used: u64, gas_limit: u64) !SimulationCallResult {
    const output = try allocator.dupe(u8, result.output);
    errdefer allocator.free(output);
    const logs = try copyLogs(allocator, if (result.success) result.logs else &.{});
    errdefer freeLogs(allocator, logs);
    var out: SimulationCallResult = .{
        .success = result.success,
        .output = output,
        .gas_used = gas_used,
        .gas_limit = gas_limit,
        .logs = logs,
        .created_address = if (result.success) result.created_address else null,
    };
    if (!result.success) {
        const msg = try allocator.dupe(u8, errorMessage(result));
        out.error_msg = msg;
        errdefer allocator.free(msg);
        if (out.reverted()) out.revert_reason = try RevertDecoder.formatAlloc(allocator, result.output);
    }
    return out;
}

fn copyLogs(allocator: Allocator, logs: []const @import("call_result.zig").Log) ![]SimLog {
    const out = try allocator.alloc(SimLog, logs.len);
    var done: usize = 0;
    errdefer freeLogs(allocator, out[0..done]);
    for (logs, out) |entry, *dst| {
        const topics = try allocator.alloc([32]u8, entry.topics.len);
        errdefer allocator.free(topics);
        for (entry.topics, topics) |topic, *word| std.mem.writeInt(u256, word, topic, .big);
        dst.* = .{ .address = entry.address, .topics = topics, .data = try allocator.dupe(u8, entry.data) };
        done += 1;
    }
    return out;
}

// ---------------------------------------------------------------------------
// eth_call
// ---------------------------------------------------------------------------

/// `eth_call`: execute `req` on a throwaway overlay of `base_host`.
pub fn simulateCall(
    allocator: Allocator,
    base_host: ?HostInterface,
    base_block: BlockContext,
    hardfork: Hardfork,
    req: CallRequest,
    state_overrides: ?StateOverride,
    block_override: ?BlockOverride,
    inspector_opt: ?Inspector,
) !SimulationCallResult {
    var overlay = StateOverlayHost.init(allocator, base_host);
    defer overlay.deinit();
    if (state_overrides) |o| try overlay.applyOverrides(o);
    const block = if (block_override) |b| b.apply(base_block) else base_block;
    return executeOnOverlay(allocator, &overlay, block, hardfork, req, inspector_opt, null, .{});
}

// ---------------------------------------------------------------------------
// eth_estimateGas
// ---------------------------------------------------------------------------

pub const EstimateGasOutcome = union(enum) {
    gas: u64,
    /// The call reverts at the gas cap. `data` is the raw revert payload.
    reverted: struct { data: []u8, reason: ?[]u8 },
    /// The call fails at the gas cap for a non-revert reason (e.g. "out of gas").
    failed: []u8,

    pub fn deinit(self: *EstimateGasOutcome, allocator: Allocator) void {
        switch (self.*) {
            .gas => {},
            .reverted => |r| {
                allocator.free(r.data);
                if (r.reason) |m| allocator.free(m);
            },
            .failed => |m| allocator.free(m),
        }
        self.* = undefined;
    }
};

/// `eth_estimateGas`. Returns `error.ExecutionReverted` or
/// `error.ExecutionFailed` when no gas limit up to the cap succeeds; use
/// `estimateGasDetailed` to get the revert data.
pub fn estimateGas(
    allocator: Allocator,
    base_host: ?HostInterface,
    base_block: BlockContext,
    hardfork: Hardfork,
    req: CallRequest,
    state_overrides: ?StateOverride,
    block_override: ?BlockOverride,
) !u64 {
    var outcome = try estimateGasDetailed(allocator, base_host, base_block, hardfork, req, state_overrides, block_override);
    defer outcome.deinit(allocator);
    return switch (outcome) {
        .gas => |g| g,
        .reverted => error.ExecutionReverted,
        .failed => error.ExecutionFailed,
    };
}

/// Binary search between the intrinsic/floor gas and the cap, as Geth's
/// `gasestimator.Estimate`: try the cap, then the gas actually used, then
/// bisect (biased low) until hi is within 1.5% of lo.
pub fn estimateGasDetailed(
    allocator: Allocator,
    base_host: ?HostInterface,
    base_block: BlockContext,
    hardfork: Hardfork,
    req: CallRequest,
    state_overrides: ?StateOverride,
    block_override: ?BlockOverride,
) !EstimateGasOutcome {
    const block = if (block_override) |b| b.apply(base_block) else base_block;
    const floor = minimumGas(req, hardfork);

    var hi: u64 = req.gas orelse block.block_gas_limit;
    if (req.gas_price != 0) {
        var probe = StateOverlayHost.init(allocator, base_host);
        defer probe.deinit();
        if (state_overrides) |o| try probe.applyOverrides(o);
        hi = @min(hi, defaultGas(hi, probe.getBalance(req.from), req));
    }
    if (hi < floor) return error.IntrinsicGasTooLow;

    var top = try tryGas(allocator, base_host, block, hardfork, req, state_overrides, hi);
    defer top.deinit(allocator);
    if (!top.success) {
        if (top.reverted()) {
            const data = try allocator.dupe(u8, top.output);
            errdefer allocator.free(data);
            const reason = if (top.revert_reason) |r| try allocator.dupe(u8, r) else null;
            return .{ .reverted = .{ .data = data, .reason = reason } };
        }
        return .{ .failed = try allocator.dupe(u8, top.error_msg orelse "execution failed") };
    }

    var lo: u64 = floor - 1;
    if (top.gas_used > lo and top.gas_used < hi) {
        if (try succeedsAt(allocator, base_host, block, hardfork, req, state_overrides, top.gas_used)) {
            hi = top.gas_used;
        } else {
            lo = top.gas_used;
        }
    }
    while (lo + 1 < hi) {
        if ((hi - lo) * 1000 / hi < ESTIMATE_ERROR_RATIO_PER_MILLE) break;
        var mid = lo + (hi - lo) / 2;
        if (lo > 0 and mid > lo *| 2) mid = lo *| 2;
        if (try succeedsAt(allocator, base_host, block, hardfork, req, state_overrides, mid)) {
            hi = mid;
        } else {
            lo = mid;
        }
    }
    return .{ .gas = hi };
}

fn tryGas(allocator: Allocator, base_host: ?HostInterface, block: BlockContext, hardfork: Hardfork, req: CallRequest, overrides: ?StateOverride, gas: u64) !SimulationCallResult {
    var run = req;
    run.gas = gas;
    return simulateCall(allocator, base_host, block, hardfork, run, overrides, null, null);
}

fn succeedsAt(allocator: Allocator, base_host: ?HostInterface, block: BlockContext, hardfork: Hardfork, req: CallRequest, overrides: ?StateOverride, gas: u64) !bool {
    var res = tryGas(allocator, base_host, block, hardfork, req, overrides, gas) catch |e| switch (e) {
        error.IntrinsicGasTooLow => return false,
        else => return e,
    };
    defer res.deinit(allocator);
    return res.success;
}

// ---------------------------------------------------------------------------
// eth_createAccessList
// ---------------------------------------------------------------------------

pub const AccessListResult = struct {
    /// Sorted by address, then storage key.
    entries: []AccessListEntry,
    /// Gas used when the transaction carries `entries` as its access list.
    gas_used: u64,
    /// VM error of the final run, if it failed.
    error_msg: ?[]u8 = null,

    pub fn deinit(self: *AccessListResult, allocator: Allocator) void {
        freeAccessListEntries(allocator, self.entries);
        if (self.error_msg) |m| allocator.free(m);
        self.* = undefined;
    }
};

/// `eth_createAccessList`: rerun with the traced list until it stops
/// changing (Geth `AccessList`), so `gas_used` reflects the final list.
pub fn createAccessList(
    allocator: Allocator,
    base_host: ?HostInterface,
    base_block: BlockContext,
    hardfork: Hardfork,
    req: CallRequest,
    state_overrides: ?StateOverride,
    block_override: ?BlockOverride,
) !AccessListResult {
    var current = try cloneInputList(allocator, req.access_list orelse &.{});
    defer freeAccessListEntries(allocator, current);

    var iteration: usize = 0;
    while (true) : (iteration += 1) {
        const as_input = try allocator.alloc(AccessListInput, current.len);
        defer allocator.free(as_input);
        for (current, as_input) |entry, *dst| dst.* = .{ .address = entry.address, .storage_keys = entry.storage_keys };

        var tracer = tracers.AccessListInspector.init(allocator, .{});
        defer tracer.deinit();
        var run = req;
        run.access_list = as_input;
        var res = try simulateCall(allocator, base_host, base_block, hardfork, run, state_overrides, block_override, tracer.inspector());
        defer res.deinit(allocator);

        const next = try tracer.toOwnedEntries(allocator);
        if (entriesEqual(next, current) or iteration + 1 >= MAX_ACCESS_LIST_ITERATIONS) {
            errdefer freeAccessListEntries(allocator, next);
            const msg = if (res.success) null else try allocator.dupe(u8, res.error_msg orelse "execution failed");
            return .{ .entries = next, .gas_used = res.gas_used, .error_msg = msg };
        }
        freeAccessListEntries(allocator, current);
        current = next;
    }
}

fn cloneInputList(allocator: Allocator, list: []const AccessListInput) ![]AccessListEntry {
    const out = try allocator.alloc(AccessListEntry, list.len);
    var done: usize = 0;
    errdefer {
        for (out[0..done]) |e| allocator.free(e.storage_keys);
        allocator.free(out);
    }
    for (list, out) |entry, *dst| {
        dst.* = .{ .address = entry.address, .storage_keys = try allocator.dupe([32]u8, entry.storage_keys) };
        done += 1;
    }
    return out;
}

fn entriesEqual(a: []const AccessListEntry, b: []const AccessListEntry) bool {
    if (a.len != b.len) return false;
    for (a, b) |x, y| {
        if (!x.address.equals(y.address) or x.storage_keys.len != y.storage_keys.len) return false;
        for (x.storage_keys, y.storage_keys) |kx, ky| if (!std.mem.eql(u8, &kx, &ky)) return false;
    }
    return true;
}

// ---------------------------------------------------------------------------
// eth_simulateV1
// ---------------------------------------------------------------------------

pub const SimulatedBlockInput = struct {
    block_override: ?BlockOverride = null,
    state_overrides: ?StateOverride = null,
    calls: []const CallRequest = &.{},
};

pub const SimulateV1Options = struct {
    /// Enforce nonces and base fee; otherwise unspecified base fees are zero.
    validation: bool = false,
    trace_transfers: bool = false,
    return_full_transactions: bool = false,
};

/// `traceTransfers`: one ordered stream of contract logs and synthetic ERC-20
/// style Transfer logs, as Geth's simulate tracer. A transfer is emitted at
/// frame entry or SELFDESTRUCT, a contract log when LOG runs. A reverted frame
/// drops everything it and its descendants emitted.
const TransferTracer = struct {
    const transfer_topic = blk: {
        @setEvalBranchQuota(10_000);
        var topic: [32]u8 = undefined;
        Keccak256.hash("Transfer(address,address,uint256)", &topic, .{});
        break :blk topic;
    };
    const transfer_address: Address = .{ .bytes = @splat(0xee) };

    allocator: Allocator,
    /// Owned topics and data.
    logs: std.ArrayList(SimLog) = .{},
    checkpoints: std.ArrayList(usize) = .{},
    saw_frame: bool = false,
    err: ?error{OutOfMemory} = null,

    fn deinit(self: *TransferTracer) void {
        self.truncate(0);
        self.logs.deinit(self.allocator);
        self.checkpoints.deinit(self.allocator);
    }

    fn inspector(self: *TransferTracer) Inspector {
        return .{ .ptr = self, .vtable = &vtable, .opcode_mask = insp.OpcodeMask.NONE };
    }

    fn truncate(self: *TransferTracer, len: usize) void {
        for (self.logs.items[len..]) |entry| {
            self.allocator.free(entry.topics);
            self.allocator.free(entry.data);
        }
        self.logs.shrinkRetainingCapacity(len);
    }

    fn push(self: *TransferTracer, address: Address, topics: []const [32]u8, data: []const u8) void {
        self.pushOrFail(address, topics, data) catch |err| {
            self.err = err;
        };
    }

    fn pushOrFail(self: *TransferTracer, address: Address, topics: []const [32]u8, data: []const u8) !void {
        try self.logs.ensureUnusedCapacity(self.allocator, 1);
        const owned_topics = try self.allocator.dupe([32]u8, topics);
        errdefer self.allocator.free(owned_topics);
        const owned_data = try self.allocator.dupe(u8, data);
        self.logs.appendAssumeCapacity(.{ .address = address, .topics = owned_topics, .data = owned_data });
    }

    fn record(self: *TransferTracer, from: Address, to: Address, value: u256) void {
        if (value == 0 or from.equals(to)) return;
        var topics: [3][32]u8 = .{ transfer_topic, @splat(0), @splat(0) };
        topics[1][12..].* = from.bytes;
        topics[2][12..].* = to.bytes;
        var data: [32]u8 = undefined;
        std.mem.writeInt(u256, &data, value, .big);
        self.push(transfer_address, &topics, &data);
    }

    fn onEnter(ptr: *anyopaque, event: insp.FrameEnterEvent) void {
        const self: *TransferTracer = @ptrCast(@alignCast(ptr));
        if (self.err != null) return;
        self.saw_frame = true;
        self.checkpoints.append(self.allocator, self.logs.items.len) catch |err| {
            self.err = err;
            return;
        };
        switch (event.call_type) {
            .call, .create, .create2 => self.record(event.from, event.to, event.value),
            else => {},
        }
    }

    fn onExit(ptr: *anyopaque, event: insp.FrameExitEvent) void {
        const self: *TransferTracer = @ptrCast(@alignCast(ptr));
        if (self.err != null) return;
        const checkpoint = self.checkpoints.pop().?;
        if (event.reverted) self.truncate(checkpoint);
    }

    fn onLog(ptr: *anyopaque, event: insp.LogEvent) void {
        const self: *TransferTracer = @ptrCast(@alignCast(ptr));
        if (self.err != null) return;
        self.push(event.address, event.topics, event.data);
    }

    fn onSelfDestruct(ptr: *anyopaque, event: insp.SelfDestructEvent) void {
        const self: *TransferTracer = @ptrCast(@alignCast(ptr));
        if (self.err != null) return;
        self.record(event.address, event.beneficiary, event.value);
    }

    /// Replace `result.logs` with the ordered stream on success.
    fn finish(self: *TransferTracer, result: *SimulationCallResult, req: CallRequest) !void {
        // The intrinsic-gas-only fast path completes without an EVM frame.
        if (result.success and !self.saw_frame and self.err == null) {
            if (req.to) |to| self.record(req.from, to, req.value);
        }
        if (self.err) |err| return err;
        if (!result.success) return;
        const logs = try self.logs.toOwnedSlice(self.allocator);
        freeLogs(self.allocator, result.logs);
        result.logs = logs;
    }

    const vtable: Inspector.VTable = .{
        .onEnter = onEnter,
        .onExit = onExit,
        .onLog = onLog,
        .onSelfDestruct = onSelfDestruct,
    };
};

pub const SimulatedCallError = struct {
    kind: Kind,
    message: []u8,

    pub const Kind = enum {
        /// REVERT; `return_data` holds the payload. JSON-RPC code 3.
        reverted,
        /// Exceptional halt (out of gas, invalid opcode...). Code -32015.
        vm_error,
        /// Invalid transaction (funds, nonce, intrinsic gas). Not executed.
        invalid,
    };
};

pub const SimulatedCallResult = struct {
    status: bool,
    return_data: []u8,
    gas_used: u64,
    logs: []SimLog,
    created_address: ?Address = null,
    err: ?SimulatedCallError = null,
    /// Underlying error for `.invalid` calls.
    invalid_error: ?anyerror = null,
    /// Metadata for a transaction that was included in the simulated block.
    transaction: ?SimulatedTransaction = null,
};

pub const SimulatedTransaction = struct {
    hash: [32]u8,
    nonce: u64,
    gas_limit: u64,
    tx_type: u8,
};

pub const SimulatedBlockResult = struct {
    number: u64,
    timestamp: u64,
    gas_limit: u64,
    gas_used: u64,
    fee_recipient: Address,
    base_fee: u256,
    blob_base_fee: u256,
    prev_randao: u256,
    parent_hash: [32]u8,
    /// Synthetic: keccak256 of the header fields and transaction hashes.
    hash: [32]u8,
    calls: []SimulatedCallResult,
};

pub const SimulateV1Result = struct {
    blocks: []SimulatedBlockResult,

    pub fn deinit(self: *SimulateV1Result, allocator: Allocator) void {
        for (self.blocks) |b| freeBlockCalls(allocator, b.calls);
        allocator.free(self.blocks);
        self.* = undefined;
    }
};

fn freeBlockCalls(allocator: Allocator, calls: []SimulatedCallResult) void {
    freeCallContents(allocator, calls);
    allocator.free(calls);
}

fn freeCallContents(allocator: Allocator, calls: []const SimulatedCallResult) void {
    for (calls) |c| {
        allocator.free(c.return_data);
        freeLogs(allocator, c.logs);
        if (c.err) |e| allocator.free(e.message);
    }
}

/// `eth_simulateV1`: run `blocks` in order on one overlay. A successful call's
/// state is visible to later calls and blocks. Invalid calls are rolled back.
/// Failed set-code transactions retain authorization changes, the sender nonce
/// and gas payment. Other failed calls are rolled back entirely.
pub fn simulateV1(
    allocator: Allocator,
    base_host: ?HostInterface,
    base_block: BlockContext,
    hardfork: Hardfork,
    blocks: []const SimulatedBlockInput,
    options: SimulateV1Options,
) !SimulateV1Result {
    if (blocks.len > MAX_SIMULATED_BLOCKS) return error.TooManyBlocks;
    var overlay = StateOverlayHost.init(allocator, base_host);
    defer overlay.deinit();

    var results: std.ArrayList(SimulatedBlockResult) = .{};
    errdefer {
        for (results.items) |b| freeBlockCalls(allocator, b.calls);
        results.deinit(allocator);
    }
    try results.ensureTotalCapacity(allocator, blocks.len);

    var parent = base_block;
    var parent_hash: [32]u8 = @splat(0);
    for (blocks) |input| {
        var header = parent;
        header.block_number = parent.block_number + 1;
        header.block_timestamp = parent.block_timestamp + SIMULATED_BLOCK_TIME;
        if (!options.validation) header.block_base_fee = 0;
        if (input.block_override) |o| header = o.apply(header);
        if (header.block_number <= parent.block_number) return error.BlockNumberNotIncreasing;
        if (header.block_timestamp <= parent.block_timestamp) return error.BlockTimestampNotIncreasing;
        if (input.state_overrides) |o| try overlay.applyOverrides(o);

        const calls = try allocator.alloc(SimulatedCallResult, input.calls.len);
        var done: usize = 0;
        errdefer {
            freeCallContents(allocator, calls[0..done]);
            allocator.free(calls);
        }
        var block_gas_used: u64 = 0;
        var tx_index: usize = 0;
        for (input.calls, calls) |call, *slot| {
            slot.* = try simulateOne(allocator, &overlay, header, hardfork, call, block_gas_used, options);
            done += 1;
            if (slot.transaction) |*tx| {
                tx.hash = syntheticTransactionHash(header, tx_index, call, tx.*);
                block_gas_used += slot.gas_used;
                tx_index += 1;
            }
        }

        const hash = syntheticHash(header, block_gas_used, parent_hash, calls);
        results.appendAssumeCapacity(.{
            .number = header.block_number,
            .timestamp = header.block_timestamp,
            .gas_limit = header.block_gas_limit,
            .gas_used = block_gas_used,
            .fee_recipient = header.block_coinbase,
            .base_fee = header.block_base_fee,
            .blob_base_fee = header.blob_base_fee,
            .prev_randao = header.block_prevrandao,
            .parent_hash = parent_hash,
            .hash = hash,
            .calls = calls,
        });
        parent = header;
        parent_hash = hash;
    }
    return .{ .blocks = try results.toOwnedSlice(allocator) };
}

fn simulateOne(allocator: Allocator, overlay: *StateOverlayHost, header: BlockContext, hardfork: Hardfork, call: CallRequest, block_gas_used: u64, options: SimulateV1Options) !SimulatedCallResult {
    const remaining = header.block_gas_limit -| block_gas_used;
    var run = call;
    if (run.gas == null) run.gas = remaining;
    const mark = overlay.checkpoint();
    if (run.gas.? > remaining) return invalidCall(allocator, error.BlockGasLimitReached);
    const nonce = overlay.getNonce(call.from);
    var transfers: TransferTracer = .{ .allocator = allocator };
    defer transfers.deinit();
    const observer = if (options.trace_transfers) transfers.inspector() else null;
    var res = executeOnOverlay(allocator, overlay, header, hardfork, run, observer, null, .{ .validation = options.validation }) catch |e| switch (e) {
        error.OutOfMemory => return e,
        else => {
            overlay.revertTo(mark);
            return invalidCall(allocator, e);
        },
    };
    errdefer res.deinit(allocator);
    if (!res.success and !run.isSetCode(hardfork)) overlay.revertTo(mark);
    if (options.trace_transfers) try transfers.finish(&res, run);
    var out: SimulatedCallResult = .{
        .status = res.success,
        .return_data = res.output,
        .gas_used = res.gas_used,
        .logs = res.logs,
        .created_address = res.created_address,
        .transaction = .{ .hash = @splat(0), .nonce = nonce, .gas_limit = res.gas_limit, .tx_type = run.transactionType(hardfork) },
    };
    if (!res.success) {
        out.err = .{ .kind = if (res.reverted()) .reverted else .vm_error, .message = try revertMessage(allocator, &res) };
    }
    if (res.error_msg) |m| allocator.free(m);
    if (res.revert_reason) |m| allocator.free(m);
    return out;
}

/// Geth message: "execution reverted" plus ": <reason>" when decodable.
pub fn revertMessage(allocator: Allocator, res: *const SimulationCallResult) ![]u8 {
    const msg = res.error_msg orelse "execution failed";
    if (res.revert_reason) |reason| return std.fmt.allocPrint(allocator, "{s}: {s}", .{ msg, reason });
    return allocator.dupe(u8, msg);
}

fn invalidCall(allocator: Allocator, e: anyerror) !SimulatedCallResult {
    const message = try allocator.dupe(u8, invalidMessage(e));
    errdefer allocator.free(message);
    const return_data = try allocator.alloc(u8, 0);
    errdefer allocator.free(return_data);
    return .{
        .status = false,
        .return_data = return_data,
        .gas_used = 0,
        .logs = try allocator.alloc(SimLog, 0),
        .err = .{ .kind = .invalid, .message = message },
        .invalid_error = e,
    };
}

/// Geth wording for transaction validation errors.
pub fn invalidMessage(e: anyerror) []const u8 {
    return switch (e) {
        error.IntrinsicGasTooLow => "intrinsic gas too low",
        error.InsufficientFunds => "insufficient funds for gas * price + value",
        error.NonceTooLow => "nonce too low",
        error.NonceTooHigh => "nonce too high",
        error.NonceOverflow => "nonce has max value",
        error.FeeCapTooLow => "max fee per gas less than block base fee",
        error.AuthorizationRequiresRecipient => "authorization list requires a transaction recipient",
        error.EmptyAuthorizationList => "EIP-7702 transaction with empty auth list",
        error.InitcodeTooLarge => "max initcode size exceeded",
        error.BlockGasLimitReached => "block gas limit reached",
        error.ConflictingStateOverrides => "account has both state and stateDiff overrides",
        error.BlockNumberNotIncreasing => "block numbers must be in order",
        error.BlockTimestampNotIncreasing => "block timestamps must be in order",
        error.TooManyBlocks => "too many blocks",
        else => @errorName(e),
    };
}

const Keccak256 = std.crypto.hash.sha3.Keccak256;

fn hashWords(hash: *Keccak256, words: []const u256) void {
    var buf: [32]u8 = undefined;
    for (words) |word| {
        std.mem.writeInt(u256, &buf, word, .big);
        hash.update(&buf);
    }
}

fn syntheticTransactionHash(header: BlockContext, index: usize, call: CallRequest, tx: SimulatedTransaction) [32]u8 {
    var hash = Keccak256.init(.{});
    hashWords(&hash, &.{ header.chain_id, header.block_number, index, tx.tx_type, tx.nonce, tx.gas_limit, call.gas_price, call.value });
    hash.update(&call.from.bytes);
    hash.update(&.{@intFromBool(call.to != null)});
    if (call.to) |to| hash.update(&to.bytes);
    hashWords(&hash, &.{call.input.len});
    hash.update(call.input);
    const access_list = call.access_list orelse &.{};
    hashWords(&hash, &.{access_list.len});
    for (access_list) |entry| {
        hash.update(&entry.address.bytes);
        hashWords(&hash, &.{entry.storage_keys.len});
        for (entry.storage_keys) |key| hash.update(&key);
    }
    hash.update(&.{@intFromBool(call.authorization_list != null)});
    for (call.authorizations()) |auth| {
        hashWords(&hash, &.{ auth.chain_id, auth.nonce, auth.y_parity, auth.r, auth.s });
        hash.update(&auth.address.bytes);
        hash.update(&.{@intFromBool(auth.authority != null)});
        if (auth.authority) |authority| hash.update(&authority.bytes);
    }
    var digest: [32]u8 = undefined;
    hash.final(&digest);
    return digest;
}

fn syntheticHash(header: BlockContext, gas_used: u64, parent_hash: [32]u8, calls: []const SimulatedCallResult) [32]u8 {
    var h = Keccak256.init(.{});
    h.update(&parent_hash);
    hashWords(&h, &.{ header.block_number, header.block_timestamp, header.block_gas_limit, gas_used, header.block_base_fee, header.block_prevrandao });
    h.update(&header.block_coinbase.bytes);
    for (calls) |call| if (call.transaction) |tx| h.update(&tx.hash);
    var digest: [32]u8 = undefined;
    h.final(&digest);
    return digest;
}

// ---------------------------------------------------------------------------
// debug_traceCall / trace_call
// ---------------------------------------------------------------------------

/// Geth struct logger (default `debug_trace*` tracer) options.
pub const StructLoggerOptions = struct {
    disable_stack: bool = false,
    disable_storage: bool = false,
    enable_memory: bool = false,
    enable_return_data: bool = false,
    /// Maximum retained steps; 0 means unlimited.
    limit: usize = 0,
};

pub const MuxEntry = struct { name: []const u8, choice: TracerChoice };

pub const TracerChoice = union(enum) {
    struct_logger: StructLoggerOptions,
    call_tracer: tracers.CallTracer.Options,
    flat_call_tracer: tracers.CallTracer.Options,
    prestate_tracer: tracers.PrestateTracer.Options,
    four_byte_tracer,
    gas_profiler,
    coverage,
    /// Geth `muxTracer`: one result object keyed by `name`. No nesting.
    mux: []const MuxEntry,
};

const TracerInstance = union(enum) {
    struct_logger: *trace_mod.Tracer,
    call_tracer: *tracers.CallTracer,
    flat_call_tracer: *tracers.CallTracer,
    prestate_tracer: *tracers.PrestateTracer,
    four_byte_tracer: *tracers.FourByteTracer,
    gas_profiler: *tracers.GasProfiler,
    coverage: *tracers.CoverageInspector,

    fn create(allocator: Allocator, choice: TracerChoice) !TracerInstance {
        return switch (choice) {
            .struct_logger => |o| blk: {
                const t = try allocator.create(trace_mod.Tracer);
                t.* = trace_mod.Tracer.init(allocator);
                t.config.disable_stack = o.disable_stack;
                t.config.disable_storage = o.disable_storage;
                t.config.enable_memory = o.enable_memory;
                t.config.enable_return_data = o.enable_return_data;
                if (o.limit != 0) t.max_entries = o.limit;
                t.enable();
                break :blk .{ .struct_logger = t };
            },
            .call_tracer => |o| .{ .call_tracer = try boxed(allocator, tracers.CallTracer.init(allocator, o)) },
            .flat_call_tracer => |o| .{ .flat_call_tracer = try boxed(allocator, tracers.CallTracer.init(allocator, o)) },
            .prestate_tracer => |o| .{ .prestate_tracer = try boxed(allocator, tracers.PrestateTracer.init(allocator, o)) },
            .four_byte_tracer => .{ .four_byte_tracer = try boxed(allocator, tracers.FourByteTracer.init(allocator)) },
            .gas_profiler => .{ .gas_profiler = try boxed(allocator, tracers.GasProfiler.init(allocator)) },
            .coverage => .{ .coverage = try boxed(allocator, tracers.CoverageInspector.init(allocator)) },
            .mux => error.NestedMuxTracer,
        };
    }

    fn destroy(self: TracerInstance, allocator: Allocator) void {
        switch (self) {
            inline else => |t| {
                t.deinit();
                allocator.destroy(t);
            },
        }
    }

    fn inspector(self: TracerInstance) ?Inspector {
        return switch (self) {
            .struct_logger => null,
            inline else => |t| t.inspector(),
        };
    }
};

fn boxed(allocator: Allocator, value: anytype) !*@TypeOf(value) {
    const ptr = try allocator.create(@TypeOf(value));
    ptr.* = value;
    return ptr;
}

/// Tracers attached to one traced execution.
const TraceSession = struct {
    allocator: Allocator,
    instances: std.ArrayList(TracerInstance) = .{},
    inspectors: std.ArrayList(Inspector) = .{},
    mux: MuxInspector = undefined,
    step_tracer: ?*trace_mod.Tracer = null,

    fn init(allocator: Allocator, choices: []const TracerChoice) !TraceSession {
        var self: TraceSession = .{ .allocator = allocator };
        errdefer self.deinit();
        for (choices) |choice| {
            const instance = try TracerInstance.create(allocator, choice);
            self.instances.append(allocator, instance) catch |e| {
                instance.destroy(allocator);
                return e;
            };
            if (instance == .struct_logger) {
                if (self.step_tracer != null) return error.DuplicateStructLogger;
                self.step_tracer = instance.struct_logger;
            }
            if (instance.inspector()) |i| try self.inspectors.append(allocator, i);
        }
        return self;
    }

    fn deinit(self: *TraceSession) void {
        for (self.instances.items) |i| i.destroy(self.allocator);
        self.instances.deinit(self.allocator);
        self.inspectors.deinit(self.allocator);
    }

    /// Must be called once the session is at its final address.
    fn observer(self: *TraceSession) ?Inspector {
        return switch (self.inspectors.items.len) {
            0 => null,
            1 => self.inspectors.items[0],
            else => blk: {
                self.mux = MuxInspector.init(self.inspectors.items);
                break :blk self.mux.inspector();
            },
        };
    }

    /// Geth reports the transaction gas limit and receipt gas on the root
    /// frame, and full pre-state for every touched account.
    fn finish(self: *TraceSession, res: *const SimulationCallResult, pre_state: *const StateOverlayHost) !void {
        for (self.instances.items) |instance| switch (instance) {
            .call_tracer, .flat_call_tracer => |t| if (t.root_frame) |root| {
                root.gas = res.gas_limit;
                root.gas_used = res.gas_used;
            },
            .prestate_tracer => |t| try fillPrestate(t, pre_state),
            else => {},
        };
    }
};

/// The PrestateTracer learns balances and nonces only from change events.
/// Fill unobserved fields from the pre-transaction state.
fn fillPrestate(t: *tracers.PrestateTracer, pre_state: *const StateOverlayHost) !void {
    var it = t.accounts.iterator();
    while (it.next()) |entry| {
        const address = entry.key_ptr.*;
        const acct = entry.value_ptr;
        if (acct.pre.balance == null) acct.pre.balance = pre_state.getBalance(address);
        if (acct.pre.nonce == null) acct.pre.nonce = pre_state.getNonce(address);
        if (!t.options.disable_code and acct.pre.code == null and acct.post.code == null) {
            acct.pre.code = try t.allocator.dupe(u8, pre_state.getCode(address));
        }
    }
}

const TracedRun = struct {
    session: TraceSession,
    result: SimulationCallResult,

    fn deinit(self: *TracedRun, allocator: Allocator) void {
        self.result.deinit(allocator);
        self.session.deinit();
    }
};

fn runTraced(
    allocator: Allocator,
    base_host: ?HostInterface,
    base_block: BlockContext,
    hardfork: Hardfork,
    req: CallRequest,
    state_overrides: ?StateOverride,
    block_override: ?BlockOverride,
    choices: []const TracerChoice,
    run: *TracedRun,
) !void {
    var overlay = StateOverlayHost.init(allocator, base_host);
    defer overlay.deinit();
    if (state_overrides) |o| try overlay.applyOverrides(o);
    const block = if (block_override) |b| b.apply(base_block) else base_block;

    run.session = try TraceSession.init(allocator, choices);
    errdefer run.session.deinit();
    const mark = overlay.checkpoint();
    run.result = try executeOnOverlay(allocator, &overlay, block, hardfork, req, run.session.observer(), run.session.step_tracer, .{});
    errdefer run.result.deinit(allocator);
    overlay.revertTo(mark);
    try run.session.finish(&run.result, &overlay);
}

/// `debug_traceCall`: run `req` with `choice` and return the tracer's JSON.
pub fn traceCallJson(
    allocator: Allocator,
    base_host: ?HostInterface,
    base_block: BlockContext,
    hardfork: Hardfork,
    req: CallRequest,
    state_overrides: ?StateOverride,
    block_override: ?BlockOverride,
    choice: TracerChoice,
) ![]u8 {
    var choices: std.ArrayList(TracerChoice) = .{};
    defer choices.deinit(allocator);
    switch (choice) {
        .mux => |entries| for (entries) |e| try choices.append(allocator, e.choice),
        else => try choices.append(allocator, choice),
    }

    var run: TracedRun = undefined;
    try runTraced(allocator, base_host, base_block, hardfork, req, state_overrides, block_override, choices.items, &run);
    defer run.deinit(allocator);

    var aw: std.Io.Writer.Allocating = .init(allocator);
    defer aw.deinit();
    const w = &aw.writer;
    switch (choice) {
        .mux => |entries| {
            try w.writeByte('{');
            for (entries, run.session.instances.items, 0..) |entry, instance, i| {
                if (i > 0) try w.writeByte(',');
                try tracers.writeJsonString(w, entry.name);
                try w.writeByte(':');
                try writeInstance(w, instance, &run.result);
            }
            try w.writeByte('}');
        },
        else => try writeInstance(w, run.session.instances.items[0], &run.result),
    }
    return aw.toOwnedSlice();
}

fn writeInstance(w: *std.Io.Writer, instance: TracerInstance, res: *const SimulationCallResult) !void {
    switch (instance) {
        .struct_logger => |t| try writeStructLogs(w, t, res),
        .call_tracer => |t| try t.writeGethJson(w),
        .flat_call_tracer => |t| try t.writeFlatJson(w),
        .prestate_tracer => |t| try t.writeJson(w),
        .four_byte_tracer => |t| try t.writeJson(w),
        .gas_profiler => |t| try t.writeJson(w),
        .coverage => |t| try t.writeJson(w),
    }
}

/// Geth `logger.ExecutionResult`: gas, failed, returnValue, structLogs.
fn writeStructLogs(w: *std.Io.Writer, t: *const trace_mod.Tracer, res: *const SimulationCallResult) !void {
    try w.print("{{\"gas\":{d},\"failed\":{},\"returnValue\":\"{x}\",\"structLogs\":[", .{ res.gas_used, !res.success, res.output });
    for (t.entries.items, 0..) |entry, i| {
        if (i > 0) try w.writeByte(',');
        try w.print("{{\"pc\":{d},\"op\":", .{entry.pc});
        try tracers.writeJsonString(w, entry.opName);
        try w.print(",\"gas\":{d},\"gasCost\":{d},\"depth\":{d}", .{ entry.gas, entry.gasCost, entry.depth });
        if (entry.refund != 0) try w.print(",\"refund\":{d}", .{entry.refund});
        if (t.config.tracksStack()) {
            try w.writeAll(",\"stack\":[");
            for (entry.stack, 0..) |word, j| {
                if (j > 0) try w.writeByte(',');
                try w.print("\"0x{x}\"", .{word});
            }
            try w.writeByte(']');
        }
        if (entry.memory) |memory| {
            try w.writeAll(",\"memory\":[");
            var offset: usize = 0;
            while (offset < memory.len) : (offset += 32) {
                if (offset > 0) try w.writeByte(',');
                var word: [32]u8 = @splat(0);
                const end = @min(offset + 32, memory.len);
                @memcpy(word[0 .. end - offset], memory[offset..end]);
                try w.print("\"{x}\"", .{@as([]const u8, &word)});
            }
            try w.writeByte(']');
        }
        if (entry.returnData) |data| try w.print(",\"returnData\":\"0x{x}\"", .{data});
        if (entry.error_msg) |msg| {
            try w.writeAll(",\"error\":");
            try tracers.writeJsonString(w, msg);
        }
        try w.writeByte('}');
    }
    try w.writeAll("]}");
}

/// Which Parity `trace_call` sections to produce.
pub const ParityTraceTypes = struct {
    trace: bool = false,
    state_diff: bool = false,
    vm_trace: bool = false,
};

/// Parity/OpenEthereum/Reth `trace_call` result:
/// `{"output","stateDiff","trace","vmTrace"}`. `vmTrace` is always null.
pub fn traceCallParityJson(
    allocator: Allocator,
    base_host: ?HostInterface,
    base_block: BlockContext,
    hardfork: Hardfork,
    req: CallRequest,
    state_overrides: ?StateOverride,
    block_override: ?BlockOverride,
    types: ParityTraceTypes,
) ![]u8 {
    const choices = [_]TracerChoice{ .{ .flat_call_tracer = .{} }, .{ .prestate_tracer = .{ .diff_mode = true } } };
    var run: TracedRun = undefined;
    try runTraced(allocator, base_host, base_block, hardfork, req, state_overrides, block_override, &choices, &run);
    defer run.deinit(allocator);

    var aw: std.Io.Writer.Allocating = .init(allocator);
    defer aw.deinit();
    const w = &aw.writer;
    try w.print("{{\"output\":\"0x{x}\",\"stateDiff\":", .{run.result.output});
    if (types.state_diff) {
        try writeParityStateDiff(allocator, w, run.session.instances.items[1].prestate_tracer);
    } else {
        try w.writeAll("null");
    }
    try w.writeAll(",\"trace\":");
    if (types.trace) {
        try run.session.instances.items[0].flat_call_tracer.writeFlatJson(w);
    } else {
        try w.writeAll("[]");
    }
    try w.writeAll(",\"vmTrace\":null}");
    return aw.toOwnedSlice();
}

fn addressLess(_: void, a: Address, b: Address) bool {
    return std.mem.order(u8, &a.bytes, &b.bytes) == .lt;
}

fn u256Less(_: void, a: u256, b: u256) bool {
    return a < b;
}

const DiffKind = enum { same, changed, born, died };

fn writeDiffQuantity(w: *std.Io.Writer, kind: DiffKind, pre: anytype, post: anytype) !void {
    switch (kind) {
        .same => try w.writeAll("\"=\""),
        .changed => try w.print("{{\"*\":{{\"from\":\"0x{x}\",\"to\":\"0x{x}\"}}}}", .{ pre, post }),
        .born => try w.print("{{\"+\":\"0x{x}\"}}", .{post}),
        .died => try w.print("{{\"-\":\"0x{x}\"}}", .{pre}),
    }
}

fn writeDiffBytes(w: *std.Io.Writer, kind: DiffKind, pre: []const u8, post: []const u8) !void {
    switch (kind) {
        .same => try w.writeAll("\"=\""),
        .changed => try w.print("{{\"*\":{{\"from\":\"0x{x}\",\"to\":\"0x{x}\"}}}}", .{ pre, post }),
        .born => try w.print("{{\"+\":\"0x{x}\"}}", .{post}),
        .died => try w.print("{{\"-\":\"0x{x}\"}}", .{pre}),
    }
}

/// Parity `stateDiff`: per changed account, each of balance/code/nonce is
/// `"="`, `{"*":{from,to}}`, `{"+":v}` (account created) or `{"-":v}`
/// (account destroyed); `storage` lists changed slots only.
fn writeParityStateDiff(allocator: Allocator, w: *std.Io.Writer, t: *const tracers.PrestateTracer) !void {
    const addresses = try allocator.dupe(Address, t.accounts.keys());
    defer allocator.free(addresses);
    std.mem.sort(Address, addresses, {}, addressLess);
    const empty: []const u8 = &.{};

    try w.writeByte('{');
    var first = true;
    for (addresses) |address| {
        const acct = t.accounts.getPtr(address).?;
        const pre_balance = acct.pre.balance orelse 0;
        const post_balance = acct.post.balance orelse pre_balance;
        const pre_nonce = acct.pre.nonce orelse 0;
        const post_nonce = acct.post.nonce orelse pre_nonce;
        const pre_code = acct.pre.code orelse empty;
        const post_code = acct.post.code orelse pre_code;

        var slots: std.ArrayList(u256) = .{};
        defer slots.deinit(allocator);
        var sit = acct.post.storage.iterator();
        while (sit.next()) |e| {
            if (e.value_ptr.* != (acct.pre.storage.get(e.key_ptr.*) orelse 0)) try slots.append(allocator, e.key_ptr.*);
        }
        std.mem.sort(u256, slots.items, {}, u256Less);

        const pre_empty = pre_balance == 0 and pre_nonce == 0 and pre_code.len == 0;
        const destroyed = acct.selfdestructed and post_balance == 0;
        const born = acct.created and pre_empty;
        const any_change = born or destroyed or pre_balance != post_balance or pre_nonce != post_nonce or
            !std.mem.eql(u8, pre_code, post_code) or slots.items.len != 0;
        if (!any_change) continue;

        if (!first) try w.writeByte(',');
        first = false;
        try w.print("\"0x{x}\":{{\"balance\":", .{@as([]const u8, &address.bytes)});
        const field_kind = struct {
            fn of(is_born: bool, is_dead: bool, same: bool) DiffKind {
                if (is_born) return .born;
                if (is_dead) return .died;
                return if (same) .same else .changed;
            }
        }.of;
        try writeDiffQuantity(w, field_kind(born, destroyed, pre_balance == post_balance), pre_balance, post_balance);
        try w.writeAll(",\"code\":");
        try writeDiffBytes(w, field_kind(born, destroyed, std.mem.eql(u8, pre_code, post_code)), pre_code, post_code);
        try w.writeAll(",\"nonce\":");
        try writeDiffQuantity(w, field_kind(born, destroyed, pre_nonce == post_nonce), pre_nonce, post_nonce);
        try w.writeAll(",\"storage\":{");
        for (slots.items, 0..) |slot, i| {
            if (i > 0) try w.writeByte(',');
            var key: [32]u8 = undefined;
            var pre_word: [32]u8 = undefined;
            var post_word: [32]u8 = undefined;
            std.mem.writeInt(u256, &key, slot, .big);
            std.mem.writeInt(u256, &pre_word, acct.pre.storage.get(slot) orelse 0, .big);
            std.mem.writeInt(u256, &post_word, acct.post.storage.get(slot).?, .big);
            try w.print("\"0x{x}\":", .{@as([]const u8, &key)});
            try writeDiffBytes(w, if (born) .born else .changed, &pre_word, &post_word);
        }
        try w.writeAll("}}");
    }
    try w.writeByte('}');
}

// ===========================================================================
// Tests
// ===========================================================================

const testing = std.testing;

/// In-memory base host. Records every write so tests can prove isolation.
const TestHost = struct {
    const SlotKey = struct { address: [20]u8, slot: u256 };

    balances: std.AutoHashMapUnmanaged(Address, u256) = .{},
    nonces: std.AutoHashMapUnmanaged(Address, u64) = .{},
    code: std.AutoHashMapUnmanaged(Address, []const u8) = .{},
    storage: std.AutoHashMapUnmanaged(SlotKey, u256) = .{},
    writes: usize = 0,

    fn deinit(self: *TestHost) void {
        var it = self.code.valueIterator();
        while (it.next()) |c| testing.allocator.free(c.*);
        self.code.deinit(testing.allocator);
        self.balances.deinit(testing.allocator);
        self.nonces.deinit(testing.allocator);
        self.storage.deinit(testing.allocator);
    }

    fn put(self: *TestHost, address: Address, balance: u256, code: []const u8) !void {
        try self.balances.put(testing.allocator, address, balance);
        if (code.len > 0) {
            const copy = try testing.allocator.dupe(u8, code);
            if (try self.code.fetchPut(testing.allocator, address, copy)) |old| testing.allocator.free(old.value);
        }
    }

    fn putSlot(self: *TestHost, address: Address, slot: u256, value: u256) !void {
        try self.storage.put(testing.allocator, .{ .address = address.bytes, .slot = slot }, value);
    }

    fn self_(p: *anyopaque) *TestHost {
        return @ptrCast(@alignCast(p));
    }
    fn getBalance(p: *anyopaque, a: Address) u256 {
        return self_(p).balances.get(a) orelse 0;
    }
    fn getCode(p: *anyopaque, a: Address) []const u8 {
        return self_(p).code.get(a) orelse &.{};
    }
    fn getStorage(p: *anyopaque, a: Address, s: u256) u256 {
        return self_(p).storage.get(.{ .address = a.bytes, .slot = s }) orelse 0;
    }
    fn getNonce(p: *anyopaque, a: Address) u64 {
        return self_(p).nonces.get(a) orelse 0;
    }
    fn setBalance(p: *anyopaque, _: Address, _: u256) void {
        self_(p).writes += 1;
    }
    fn setCode(p: *anyopaque, _: Address, _: []const u8) void {
        self_(p).writes += 1;
    }
    fn setStorage(p: *anyopaque, _: Address, _: u256, _: u256) void {
        self_(p).writes += 1;
    }
    fn setNonce(p: *anyopaque, _: Address, _: u64) void {
        self_(p).writes += 1;
    }

    const vtable: HostInterface.VTable = .{
        .getBalance = getBalance,
        .setBalance = setBalance,
        .getCode = getCode,
        .setCode = setCode,
        .getStorage = getStorage,
        .setStorage = setStorage,
        .getNonce = getNonce,
        .setNonce = setNonce,
    };

    fn iface(self: *TestHost) HostInterface {
        return .{ .ptr = self, .vtable = &vtable };
    }
};

fn testBlock() BlockContext {
    return .{
        .chain_id = 1,
        .block_number = 100,
        .block_timestamp = 1_000,
        .block_difficulty = 0,
        .block_prevrandao = 0,
        .block_coinbase = Address.fromU256(0xc0),
        .block_gas_limit = 30_000_000,
        .block_base_fee = 7,
        .blob_base_fee = 1,
    };
}

const SENDER = Address.fromU256(0x1000);
const CONTRACT = Address.fromU256(0x2000);
const OTHER = Address.fromU256(0x3000);

/// `<op> PUSH0 MSTORE PUSH1 32 PUSH0 RETURN`: return one opcode's result.
fn returnOp(comptime op: u8) [7]u8 {
    return .{ op, 0x5f, 0x52, 0x60, 0x20, 0x5f, 0xf3 };
}

/// `PUSH1 slot SLOAD` then return the word.
fn sloadReturn(comptime slot: u8) [9]u8 {
    return .{ 0x60, slot, 0x54, 0x5f, 0x52, 0x60, 0x20, 0x5f, 0xf3 };
}

/// slot0 += 1; return the new value.
const counter_code = [_]u8{ 0x5f, 0x54, 0x60, 0x01, 0x01, 0x80, 0x5f, 0x55, 0x5f, 0x52, 0x60, 0x20, 0x5f, 0xf3 };
/// `PUSH4 0xdeadbeef PUSH0 MSTORE PUSH1 4 PUSH1 28 REVERT`.
const revert_code = [_]u8{ 0x63, 0xde, 0xad, 0xbe, 0xef, 0x5f, 0x52, 0x60, 0x04, 0x60, 0x1c, 0xfd };

fn wordOf(bytes: []const u8) u256 {
    return std.mem.readInt(u256, bytes[0..32], .big);
}

fn callTo(to: Address) CallRequest {
    return .{ .from = SENDER, .to = to, .gas = 1_000_000 };
}

test "overlay: reads fall through, writes never reach the base host" {
    var base: TestHost = .{};
    defer base.deinit();
    try base.put(CONTRACT, 50, &.{0x00});
    try base.putSlot(CONTRACT, 1, 11);

    var overlay = StateOverlayHost.init(testing.allocator, base.iface());
    defer overlay.deinit();
    const h = overlay.host();
    try testing.expectEqual(@as(u256, 50), h.getBalance(CONTRACT));
    try testing.expectEqual(@as(u256, 11), h.getStorage(CONTRACT, 1));

    h.setBalance(CONTRACT, 99);
    h.setStorage(CONTRACT, 1, 12);
    h.setCode(OTHER, &.{ 0x60, 0x00 });
    h.setNonce(OTHER, 3);
    h.deleteAccount(SENDER);
    try testing.expectEqual(@as(u256, 99), h.getBalance(CONTRACT));
    try testing.expectEqual(@as(u256, 12), h.getStorage(CONTRACT, 1));
    try testing.expectEqualSlices(u8, &.{ 0x60, 0x00 }, h.getCode(OTHER));
    try testing.expectEqual(@as(u64, 3), h.getNonce(OTHER));
    try testing.expect(h.accountExists(OTHER));
    try testing.expect(!h.accountExists(SENDER));
    try testing.expectEqual(@as(usize, 0), base.writes);
    try testing.expectEqual(@as(u256, 50), TestHost.getBalance(&base, CONTRACT));
}

test "overlay: state replaces storage, stateDiff patches it" {
    var base: TestHost = .{};
    defer base.deinit();
    try base.putSlot(CONTRACT, 1, 11);
    try base.putSlot(CONTRACT, 2, 22);
    try base.putSlot(OTHER, 1, 11);
    try base.putSlot(OTHER, 2, 22);

    var overlay = StateOverlayHost.init(testing.allocator, base.iface());
    defer overlay.deinit();
    try overlay.applyOverrides(&.{
        .{ .address = CONTRACT, .override = .{ .state = &.{.{ .slot = 1, .value = 5 }} } },
        .{ .address = OTHER, .override = .{ .state_diff = &.{.{ .slot = 1, .value = 5 }} } },
    });
    try testing.expectEqual(@as(u256, 5), overlay.getStorage(CONTRACT, 1));
    try testing.expectEqual(@as(u256, 0), overlay.getStorage(CONTRACT, 2));
    try testing.expectEqual(@as(u256, 5), overlay.getStorage(OTHER, 1));
    try testing.expectEqual(@as(u256, 22), overlay.getStorage(OTHER, 2));
}

test "overlay: state and stateDiff on one account is rejected before any change" {
    var overlay = StateOverlayHost.init(testing.allocator, null);
    defer overlay.deinit();
    try testing.expectError(error.ConflictingStateOverrides, overlay.applyOverrides(&.{
        .{ .address = OTHER, .override = .{ .balance = 9 } },
        .{ .address = CONTRACT, .override = .{ .state = &.{}, .state_diff = &.{} } },
    }));
    try testing.expectEqual(@as(u256, 0), overlay.getBalance(OTHER));
}

test "overlay: revertTo undoes writes after the checkpoint only" {
    var overlay = StateOverlayHost.init(testing.allocator, null);
    defer overlay.deinit();
    overlay.setBalance(OTHER, 1);
    overlay.setStorage(OTHER, 7, 70);
    const mark = overlay.checkpoint();
    overlay.setBalance(OTHER, 2);
    overlay.setStorage(OTHER, 7, 71);
    overlay.setStorage(OTHER, 8, 80);
    overlay.deleteAccount(OTHER);
    overlay.revertTo(mark);
    try testing.expectEqual(@as(u256, 1), overlay.getBalance(OTHER));
    try testing.expectEqual(@as(u256, 70), overlay.getStorage(OTHER, 7));
    try testing.expectEqual(@as(u256, 0), overlay.getStorage(OTHER, 8));
    try testing.expect(overlay.accountExists(OTHER));
}

test "BlockOverride.apply replaces only set fields" {
    const base = testBlock();
    const ctx = (BlockOverride{ .number = 5, .fee_recipient = OTHER }).apply(base);
    try testing.expectEqual(@as(u64, 5), ctx.block_number);
    try testing.expect(ctx.block_coinbase.equals(OTHER));
    try testing.expectEqual(base.block_timestamp, ctx.block_timestamp);
    try testing.expectEqual(base.block_base_fee, ctx.block_base_fee);
}

test "simulateCall: storage write stays out of the base host" {
    var base: TestHost = .{};
    defer base.deinit();
    try base.put(CONTRACT, 0, &counter_code);
    try base.putSlot(CONTRACT, 0, 41);

    var res = try simulateCall(testing.allocator, base.iface(), testBlock(), .CANCUN, callTo(CONTRACT), null, null, null);
    defer res.deinit(testing.allocator);
    try testing.expect(res.success);
    try testing.expectEqual(@as(u256, 42), wordOf(res.output));
    try testing.expect(res.gas_used > TX_BASE_GAS);
    try testing.expectEqual(@as(usize, 0), base.writes);
    try testing.expectEqual(@as(u256, 41), TestHost.getStorage(&base, CONTRACT, 0));
}

test "simulateCall: balance, nonce, code and storage overrides are visible" {
    var base: TestHost = .{};
    defer base.deinit();
    try base.put(CONTRACT, 0, &.{0x00});
    try base.putSlot(CONTRACT, 3, 1);

    const read_slot = sloadReturn(3);
    var res = try simulateCall(testing.allocator, base.iface(), testBlock(), .CANCUN, callTo(CONTRACT), &.{
        .{ .address = CONTRACT, .override = .{ .code = &read_slot, .state_diff = &.{.{ .slot = 3, .value = 0xabc }} } },
    }, null, null);
    defer res.deinit(testing.allocator);
    try testing.expectEqual(@as(u256, 0xabc), wordOf(res.output));

    const self_balance = returnOp(0x47);
    var bal = try simulateCall(testing.allocator, base.iface(), testBlock(), .CANCUN, callTo(CONTRACT), &.{
        .{ .address = CONTRACT, .override = .{ .code = &self_balance, .balance = 777 } },
    }, null, null);
    defer bal.deinit(testing.allocator);
    try testing.expectEqual(@as(u256, 777), wordOf(bal.output));

    // A nonce override moves the CREATE address.
    var created = try simulateCall(testing.allocator, base.iface(), testBlock(), .CANCUN, .{ .from = SENDER, .gas = 200_000, .input = &.{0x00} }, &.{
        .{ .address = SENDER, .override = .{ .nonce = 5 } },
    }, null, null);
    defer created.deinit(testing.allocator);
    try testing.expect(created.success);
    var evm: EvmType = undefined;
    try evm.init(testing.allocator, null, .CANCUN, null, SENDER, 0, null);
    defer evm.deinit();
    try testing.expect(created.created_address.?.equals(try evm.computeCreateAddress(SENDER, 5)));
}

test "simulateCall: block overrides reach NUMBER, TIMESTAMP, COINBASE, BASEFEE, PREVRANDAO" {
    var base: TestHost = .{};
    defer base.deinit();
    const override = BlockOverride{ .number = 9_999, .time = 123_456, .fee_recipient = OTHER, .base_fee = 3, .prev_randao = 0xfeed };
    const cases = .{ .{ 0x43, @as(u256, 9_999) }, .{ 0x42, @as(u256, 123_456) }, .{ 0x41, OTHER.toU256() }, .{ 0x48, @as(u256, 3) }, .{ 0x44, @as(u256, 0xfeed) } };
    inline for (cases) |case| {
        const code = returnOp(case[0]);
        var res = try simulateCall(testing.allocator, base.iface(), testBlock(), .CANCUN, callTo(CONTRACT), &.{
            .{ .address = CONTRACT, .override = .{ .code = &code } },
        }, override, null);
        defer res.deinit(testing.allocator);
        try testing.expect(res.success);
        try testing.expectEqual(case[1], wordOf(res.output));
    }
}

test "simulateCall: revert returns data and Geth error text" {
    var base: TestHost = .{};
    defer base.deinit();
    try base.put(CONTRACT, 0, &revert_code);
    var res = try simulateCall(testing.allocator, base.iface(), testBlock(), .CANCUN, callTo(CONTRACT), null, null, null);
    defer res.deinit(testing.allocator);
    try testing.expect(!res.success);
    try testing.expect(res.reverted());
    try testing.expectEqualSlices(u8, &.{ 0xde, 0xad, 0xbe, 0xef }, res.output);
    try testing.expectEqualStrings("execution reverted", res.error_msg.?);
}

test "simulateCall: invalid transactions are errors, not results" {
    var base: TestHost = .{};
    defer base.deinit();
    var low = callTo(CONTRACT);
    low.gas = 20_000;
    try testing.expectError(error.IntrinsicGasTooLow, simulateCall(testing.allocator, base.iface(), testBlock(), .CANCUN, low, null, null, null));
    var rich = callTo(CONTRACT);
    rich.value = 1;
    try testing.expectError(error.InsufficientFunds, simulateCall(testing.allocator, base.iface(), testBlock(), .CANCUN, rich, null, null, null));
}

test "simulateCall: gas price is charged, refunded and tipped" {
    var base: TestHost = .{};
    defer base.deinit();
    try base.put(SENDER, 10_000_000, &.{});
    var prestate = tracers.PrestateTracer.init(testing.allocator, .{ .diff_mode = true });
    defer prestate.deinit();
    var req = CallRequest{ .from = SENDER, .to = OTHER, .gas = 30_000, .gas_price = 10, .value = 5 };
    var res = try simulateCall(testing.allocator, base.iface(), testBlock(), .CANCUN, req, null, null, prestate.inspector());
    defer res.deinit(testing.allocator);
    try testing.expectEqual(TX_BASE_GAS, res.gas_used);
    const sender = prestate.account(SENDER).?;
    try testing.expectEqual(@as(u256, 10_000_000 - 21_000 * 10 - 5), sender.post.balance.?);
    try testing.expectEqual(@as(u64, 1), sender.post.nonce.?);
    const coinbase = prestate.account(testBlock().block_coinbase).?;
    try testing.expectEqual(@as(u256, 21_000 * 3), coinbase.post.balance.?);
    req.gas = null;
    var capped = try simulateCall(testing.allocator, base.iface(), testBlock(), .CANCUN, req, null, null, null);
    defer capped.deinit(testing.allocator);
    try testing.expectEqual(@as(u64, (10_000_000 - 5) / 10), capped.gas_limit);
}

test "estimateGas: plain transfer is exactly 21000" {
    var base: TestHost = .{};
    defer base.deinit();
    const gas = try estimateGas(testing.allocator, base.iface(), testBlock(), .CANCUN, .{ .from = SENDER, .to = OTHER }, null, null);
    try testing.expectEqual(@as(u64, 21_000), gas);
}

test "estimateGas: SSTORE estimate succeeds and is near the minimum" {
    var base: TestHost = .{};
    defer base.deinit();
    try base.put(CONTRACT, 0, &counter_code);
    const req = CallRequest{ .from = SENDER, .to = CONTRACT };
    const gas = try estimateGas(testing.allocator, base.iface(), testBlock(), .CANCUN, req, null, null);
    var at = req;
    at.gas = gas;
    var ok = try simulateCall(testing.allocator, base.iface(), testBlock(), .CANCUN, at, null, null, null);
    defer ok.deinit(testing.allocator);
    try testing.expect(ok.success);
    // 1.5% search tolerance above the true minimum.
    var below = req;
    below.gas = gas - gas * 2 / 100;
    var short = try simulateCall(testing.allocator, base.iface(), testBlock(), .CANCUN, below, null, null, null);
    defer short.deinit(testing.allocator);
    try testing.expect(!short.success);
}

test "estimateGas: revert reports data; state override can fix it" {
    var base: TestHost = .{};
    defer base.deinit();
    try base.put(CONTRACT, 0, &revert_code);
    const req = CallRequest{ .from = SENDER, .to = CONTRACT };
    try testing.expectError(error.ExecutionReverted, estimateGas(testing.allocator, base.iface(), testBlock(), .CANCUN, req, null, null));
    var outcome = try estimateGasDetailed(testing.allocator, base.iface(), testBlock(), .CANCUN, req, null, null);
    defer outcome.deinit(testing.allocator);
    try testing.expectEqualSlices(u8, &.{ 0xde, 0xad, 0xbe, 0xef }, outcome.reverted.data);

    const gas = try estimateGas(testing.allocator, base.iface(), testBlock(), .CANCUN, req, &.{
        .{ .address = CONTRACT, .override = .{ .code = &.{0x00} } },
    }, null);
    try testing.expectEqual(@as(u64, 21_000), gas);
}

test "createAccessList: lists touched account and slot; gas reflects the list" {
    var base: TestHost = .{};
    defer base.deinit();
    // PUSH1 1 SLOAD POP PUSH20 OTHER BALANCE POP STOP
    var code: [27]u8 = undefined;
    code[0..4].* = .{ 0x60, 0x01, 0x54, 0x50 };
    code[4] = 0x73;
    code[5..25].* = OTHER.bytes;
    code[25..27].* = .{ 0x31, 0x50 };
    try base.put(CONTRACT, 0, &code);
    const req = CallRequest{ .from = SENDER, .to = CONTRACT, .gas = 100_000 };

    var list = try createAccessList(testing.allocator, base.iface(), testBlock(), .CANCUN, req, null, null);
    defer list.deinit(testing.allocator);
    try testing.expect(list.error_msg == null);
    try testing.expectEqual(@as(usize, 2), list.entries.len);
    try testing.expect(list.entries[0].address.equals(CONTRACT));
    try testing.expectEqual(@as(usize, 1), list.entries[0].storage_keys.len);
    try testing.expectEqual(@as(u256, 1), wordOf(&list.entries[0].storage_keys[0]));
    try testing.expect(list.entries[1].address.equals(OTHER));

    const as_input = [_]AccessListInput{
        .{ .address = list.entries[0].address, .storage_keys = list.entries[0].storage_keys },
        .{ .address = list.entries[1].address, .storage_keys = list.entries[1].storage_keys },
    };
    var with = req;
    with.access_list = &as_input;
    var res = try simulateCall(testing.allocator, base.iface(), testBlock(), .CANCUN, with, null, null, null);
    defer res.deinit(testing.allocator);
    try testing.expectEqual(res.gas_used, list.gas_used);
}

test "createAccessList: reverting call reports error_msg" {
    var base: TestHost = .{};
    defer base.deinit();
    try base.put(CONTRACT, 0, &revert_code);
    var list = try createAccessList(testing.allocator, base.iface(), testBlock(), .CANCUN, callTo(CONTRACT), null, null);
    defer list.deinit(testing.allocator);
    try testing.expectEqualStrings("execution reverted", list.error_msg.?);
}

test "simulateV1: state carries across calls and blocks; reverts are discarded" {
    var base: TestHost = .{};
    defer base.deinit();
    try base.put(CONTRACT, 0, &counter_code);
    try base.put(OTHER, 0, &revert_code);

    const block1_calls = [_]CallRequest{ callTo(CONTRACT), callTo(OTHER), callTo(CONTRACT) };
    const block2_calls = [_]CallRequest{callTo(CONTRACT)};
    const blocks = [_]SimulatedBlockInput{
        .{ .calls = &block1_calls },
        .{
            .block_override = .{ .number = 200, .fee_recipient = OTHER },
            .state_overrides = &.{.{ .address = CONTRACT, .override = .{ .state_diff = &.{.{ .slot = 0, .value = 10 }} } }},
            .calls = &block2_calls,
        },
    };
    var result = try simulateV1(testing.allocator, base.iface(), testBlock(), .CANCUN, &blocks, .{});
    defer result.deinit(testing.allocator);

    try testing.expectEqual(@as(usize, 2), result.blocks.len);
    const b1 = result.blocks[0];
    try testing.expectEqual(@as(u64, 101), b1.number);
    try testing.expectEqual(@as(u64, 1_012), b1.timestamp);
    try testing.expectEqual(@as(u256, 0), b1.base_fee);
    try testing.expectEqual(@as(u256, 1), wordOf(b1.calls[0].return_data));
    try testing.expect(!b1.calls[1].status);
    try testing.expectEqual(SimulatedCallError.Kind.reverted, b1.calls[1].err.?.kind);
    try testing.expectEqual(@as(u256, 2), wordOf(b1.calls[2].return_data));
    try testing.expectEqual(b1.calls[0].gas_used + b1.calls[1].gas_used + b1.calls[2].gas_used, b1.gas_used);

    const b2 = result.blocks[1];
    try testing.expectEqual(@as(u64, 200), b2.number);
    try testing.expect(b2.fee_recipient.equals(OTHER));
    try testing.expectEqualSlices(u8, &b1.hash, &b2.parent_hash);
    try testing.expectEqual(@as(u256, 11), wordOf(b2.calls[0].return_data));
    try testing.expectEqual(@as(usize, 0), base.writes);
}

test "simulateV1: validation enforces nonces; ordering is checked" {
    var base: TestHost = .{};
    defer base.deinit();
    const calls = [_]CallRequest{
        .{ .from = SENDER, .to = OTHER, .nonce = 0, .gas_price = 100 },
        .{ .from = SENDER, .to = OTHER, .nonce = 0, .gas_price = 100 },
    };
    const blocks = [_]SimulatedBlockInput{.{ .calls = &calls, .state_overrides = &.{.{ .address = SENDER, .override = .{ .balance = 1 << 60 } }} }};
    var result = try simulateV1(testing.allocator, base.iface(), testBlock(), .CANCUN, &blocks, .{ .validation = true });
    defer result.deinit(testing.allocator);
    try testing.expect(result.blocks[0].calls[0].status);
    try testing.expectEqual(SimulatedCallError.Kind.invalid, result.blocks[0].calls[1].err.?.kind);
    try testing.expectEqualStrings("nonce too low", result.blocks[0].calls[1].err.?.message);

    const bad = [_]SimulatedBlockInput{ .{ .block_override = .{ .number = 300 } }, .{ .block_override = .{ .number = 300 } } };
    try testing.expectError(error.BlockNumberNotIncreasing, simulateV1(testing.allocator, base.iface(), testBlock(), .CANCUN, &bad, .{}));
}

test "simulateV1: traces top-level and nested contract creation endowments" {
    var host: TestHost = .{};
    defer host.deinit();
    try host.put(SENDER, 100, &.{});
    // CREATE with value 1, followed by CREATE2 with value 2. Both have empty initcode.
    try host.put(CONTRACT, 10, &.{ 0x5f, 0x5f, 0x60, 1, 0xf0, 0x50, 0x60, 9, 0x5f, 0x5f, 0x60, 2, 0xf5, 0x50, 0x00 });
    const blocks: []const SimulatedBlockInput = &.{.{ .calls = &.{
        .{ .from = SENDER, .value = 4 },
        .{ .from = SENDER, .to = CONTRACT, .value = 3 },
        .{ .from = SENDER, .to = OTHER, .value = 5, .gas = TX_BASE_GAS },
    } }};
    var result = try simulateV1(testing.allocator, host.iface(), testBlock(), .PRAGUE, blocks, .{ .trace_transfers = true });
    defer result.deinit(testing.allocator);

    const calls = result.blocks[0].calls;
    try testing.expect(calls[0].status and calls[1].status and calls[2].status);
    try testing.expectEqual(@as(usize, 1), calls[0].logs.len);
    try testing.expectEqual(@as(usize, 3), calls[1].logs.len);
    try testing.expectEqual(@as(usize, 1), calls[2].logs.len);
    try testing.expectEqual(calls[0].created_address.?.bytes, calls[0].logs[0].topics[2][12..].*);
    for (calls[1].logs, [_]u256{ 3, 1, 2 }) |log, value| {
        try testing.expectEqual(value, wordOf(log.data));
    }
    for (calls[1].logs[1..]) |log| try testing.expectEqual(CONTRACT.bytes, log.topics[1][12..].*);
    try testing.expect(!std.mem.eql(u8, &calls[1].logs[1].topics[2], &calls[1].logs[2].topics[2]));
    try testing.expectEqual(OTHER.bytes, calls[2].logs[0].topics[2][12..].*);
}

test "EIP-7702: tuple order, intrinsic gas, refund, warm invalid authority and clearing" {
    var host: TestHost = .{};
    defer host.deinit();
    try host.put(OTHER, 1, &.{});
    try host.put(CONTRACT, 0, &.{ 0x61, 0x30, 0x00, 0x31, 0x5f, 0x52, 0x60, 0x20, 0x5f, 0xf3 });
    var overlay = StateOverlayHost.init(testing.allocator, host.iface());
    defer overlay.deinit();
    const block = testBlock();
    const tuple: AuthorizationTuple = .{ .chain_id = 0, .address = CONTRACT, .nonce = 0, .authority = OTHER };
    var req: CallRequest = .{ .from = SENDER, .to = OTHER, .authorization_list = &.{tuple} };
    try testing.expectEqual(@as(u64, 46_000), intrinsicGas(req, .PRAGUE));
    try testing.expectEqual(@as(u64, TX_BASE_GAS), intrinsicGas(req, .CANCUN));
    const before = overlay.checkpoint();
    var delegated = try executeOnOverlay(testing.allocator, &overlay, block, .PRAGUE, req, null, null, .{});
    defer delegated.deinit(testing.allocator);
    try testing.expect(delegated.success);
    try testing.expectEqual(@as(u256, 1), wordOf(delegated.output));
    try testing.expectEqual(@as(u64, 1), overlay.getNonce(OTHER));
    try testing.expectEqualSlices(u8, &(DELEGATION_PREFIX ++ CONTRACT.bytes), overlay.getCode(OTHER));

    const clear: AuthorizationTuple = .{ .chain_id = 1, .address = ZERO_ADDRESS, .nonce = 1, .authority = OTHER };
    req.authorization_list = &.{ tuple, clear };
    var cleared = try executeOnOverlay(testing.allocator, &overlay, block, .PRAGUE, req, null, null, .{});
    defer cleared.deinit(testing.allocator);
    try testing.expect(cleared.success);
    try testing.expectEqual(@as(usize, 0), cleared.output.len);
    try testing.expectEqual(@as(u64, 2), overlay.getNonce(OTHER));
    try testing.expectEqual(@as(usize, 0), overlay.getCode(OTHER).len);
    try testing.expectEqual(71_000 - 12_500, cleared.gas_used);

    overlay.revertTo(before);
    req.to = CONTRACT;
    var wrong_nonce = tuple;
    wrong_nonce.nonce = 1;
    req.authorization_list = &.{wrong_nonce};
    var warm = try executeOnOverlay(testing.allocator, &overlay, block, .PRAGUE, req, null, null, .{});
    defer warm.deinit(testing.allocator);
    var wrong_chain = tuple;
    wrong_chain.chain_id = 2;
    req.authorization_list = &.{wrong_chain};
    var cold = try executeOnOverlay(testing.allocator, &overlay, block, .PRAGUE, req, null, null, .{});
    defer cold.deinit(testing.allocator);
    try testing.expect(warm.success and cold.success);
    try testing.expectEqual(@as(u64, 2500), cold.gas_used - warm.gas_used);
    try testing.expectEqual(@as(u64, 0), overlay.getNonce(OTHER));
    try testing.expectEqual(@as(usize, 0), overlay.getCode(OTHER).len);
    try testing.expectEqual(@as(usize, 0), host.writes);
}

test "EIP-7702: an explicitly empty authorization list is rejected on Prague only" {
    var host: TestHost = .{};
    defer host.deinit();
    try host.put(CONTRACT, 0, &counter_code);
    var overlay = StateOverlayHost.init(testing.allocator, host.iface());
    defer overlay.deinit();
    var req = callTo(CONTRACT);
    req.authorization_list = &.{};
    try testing.expectEqual(@as(u8, 4), req.transactionType(.PRAGUE));
    try testing.expectError(error.EmptyAuthorizationList, executeOnOverlay(testing.allocator, &overlay, testBlock(), .PRAGUE, req, null, null, .{}));
    try testing.expectEqual(@as(u64, 0), overlay.getNonce(SENDER));

    try testing.expectEqual(@as(u8, 0), req.transactionType(.CANCUN));
    var cancun = try executeOnOverlay(testing.allocator, &overlay, testBlock(), .CANCUN, req, null, null, .{});
    defer cancun.deinit(testing.allocator);
    try testing.expect(cancun.success);

    const blocks: []const SimulatedBlockInput = &.{.{ .calls = &.{req} }};
    var result = try simulateV1(testing.allocator, host.iface(), testBlock(), .PRAGUE, blocks, .{});
    defer result.deinit(testing.allocator);
    const rejected = result.blocks[0].calls[0];
    try testing.expect(rejected.transaction == null);
    try testing.expectEqual(SimulatedCallError.Kind.invalid, rejected.err.?.kind);
    try testing.expectEqual(error.EmptyAuthorizationList, rejected.invalid_error.?);
}

test "EIP-7702: authority code must be empty or an exact 23-byte designation" {
    var host: TestHost = .{};
    defer host.deinit();
    const long_designation = DELEGATION_PREFIX ++ CONTRACT.bytes ++ [_]u8{0x00};
    try host.put(OTHER, 1, &long_designation);
    try host.put(CONTRACT, 0, &counter_code);
    var overlay = StateOverlayHost.init(testing.allocator, host.iface());
    defer overlay.deinit();
    const tuple: AuthorizationTuple = .{ .chain_id = 0, .address = CONTRACT, .nonce = 0, .authority = OTHER };
    const req: CallRequest = .{ .from = SENDER, .to = CONTRACT, .authorization_list = &.{tuple} };
    var res = try executeOnOverlay(testing.allocator, &overlay, testBlock(), .PRAGUE, req, null, null, .{});
    defer res.deinit(testing.allocator);
    try testing.expect(res.success);
    // 24 bytes is not a designation: the tuple is skipped.
    try testing.expectEqualSlices(u8, &long_designation, overlay.getCode(OTHER));
    try testing.expectEqual(@as(u64, 0), overlay.getNonce(OTHER));
}

test "EIP-7702: the destination's delegate target is warm for the transaction" {
    var host: TestHost = .{};
    defer host.deinit();
    // OTHER delegates to CONTRACT; CONTRACT runs `PUSH20 CONTRACT BALANCE POP STOP`.
    try host.put(OTHER, 0, &(DELEGATION_PREFIX ++ CONTRACT.bytes));
    try host.put(CONTRACT, 0, &([_]u8{0x73} ++ CONTRACT.bytes ++ [_]u8{ 0x31, 0x50, 0x00 }));
    var overlay = StateOverlayHost.init(testing.allocator, host.iface());
    defer overlay.deinit();
    var res = try executeOnOverlay(testing.allocator, &overlay, testBlock(), .PRAGUE, callTo(OTHER), null, null, .{});
    defer res.deinit(testing.allocator);
    try testing.expect(res.success);
    // PUSH20 (3) + warm BALANCE (100) + POP (2).
    try testing.expectEqual(@as(u64, TX_BASE_GAS + 105), res.gas_used);

    // Control: BALANCE of an address that was not pre-warmed is cold.
    try host.put(CONTRACT, 0, &([_]u8{0x73} ++ OTHER.bytes ++ [_]u8{ 0x31, 0x50, 0x00 }));
    var cold = try executeOnOverlay(testing.allocator, &overlay, testBlock(), .PRAGUE, callTo(CONTRACT), null, null, .{});
    defer cold.deinit(testing.allocator);
    try testing.expectEqual(@as(u64, TX_BASE_GAS + 3 + 2600 + 2), cold.gas_used);
}

test "simulateV1: traceTransfers orders a value call's Transfer before the callee's LOG" {
    var host: TestHost = .{};
    defer host.deinit();
    try host.put(SENDER, 100, &.{});
    // LOG0 STOP.
    try host.put(CONTRACT, 0, &.{ 0x5f, 0x5f, 0xa0, 0x00 });
    // CALL CONTRACT with value 2, then REVERT: both the transfer and LOG0 roll back.
    try host.put(OTHER, 10, &([_]u8{ 0x5f, 0x5f, 0x5f, 0x5f, 0x60, 2, 0x61, 0x20, 0x00, 0x61, 0xff, 0xff, 0xf1, 0x50, 0x5f, 0x5f, 0xfd }));
    const blocks: []const SimulatedBlockInput = &.{.{ .calls = &.{
        .{ .from = SENDER, .to = CONTRACT, .value = 5 },
        .{ .from = SENDER, .to = OTHER, .value = 1 },
    } }};
    var result = try simulateV1(testing.allocator, host.iface(), testBlock(), .PRAGUE, blocks, .{ .trace_transfers = true });
    defer result.deinit(testing.allocator);
    const logs = result.blocks[0].calls[0].logs;
    try testing.expectEqual(@as(usize, 2), logs.len);
    try testing.expectEqual(TransferTracer.transfer_address, logs[0].address);
    try testing.expectEqual(@as(u256, 5), wordOf(logs[0].data));
    try testing.expectEqual(CONTRACT, logs[1].address);
    try testing.expectEqual(@as(usize, 0), logs[1].topics.len);
    try testing.expect(!result.blocks[0].calls[1].status);
    try testing.expectEqual(@as(usize, 0), result.blocks[0].calls[1].logs.len);
}

test "EIP-7702: full-width chain ID and canonical signer recovery" {
    const private_key = [_]u8{0} ** 31 ++ [_]u8{1};
    const signer = try Address.fromHex("0x7e5f4552091a69125d5dfcb7b8c2659029395bdf");
    var tuple: AuthorizationTuple = .{
        .chain_id = std.math.maxInt(u256),
        .address = CONTRACT,
        .nonce = 0x0102030405060708,
    };
    const preimage = [_]u8{ 0x05, 0xf8, 63, 0xa0 } ++ [_]u8{0xff} ** 32 ++
        [_]u8{0x94} ++ CONTRACT.bytes ++ [_]u8{ 0x88, 1, 2, 3, 4, 5, 6, 7, 8 };
    var digest: [32]u8 = undefined;
    Keccak256.hash(&preimage, &digest, .{});
    const sig = try crypto.unaudited_signHash(digest, private_key);
    tuple.y_parity = sig.yParity();
    tuple.r = sig.r;
    tuple.s = sig.s;
    try testing.expectEqual(signer, (try tuple.recoverAuthority(testing.allocator)).?);

    tuple.y_parity = 2;
    try testing.expect((try tuple.recoverAuthority(testing.allocator)) == null);
    tuple.y_parity = sig.yParity() ^ 1;
    tuple.s = crypto.SECP256K1_N - sig.s;
    try testing.expect((try tuple.recoverAuthority(testing.allocator)) == null);
}

fn parseJson(text: []const u8) !std.json.Parsed(std.json.Value) {
    return std.json.parseFromSlice(std.json.Value, testing.allocator, text, .{});
}

test "traceCallJson: callTracer reports tx gas on the root frame" {
    var base: TestHost = .{};
    defer base.deinit();
    try base.put(CONTRACT, 0, &counter_code);
    const json = try traceCallJson(testing.allocator, base.iface(), testBlock(), .CANCUN, callTo(CONTRACT), null, null, .{ .call_tracer = .{} });
    defer testing.allocator.free(json);
    var parsed = try parseJson(json);
    defer parsed.deinit();
    try testing.expectEqualStrings("CALL", parsed.value.object.get("type").?.string);
    try testing.expectEqualStrings("0xf4240", parsed.value.object.get("gas").?.string);
}

test "traceCallJson: prestateTracer diffMode shows sender nonce and storage write" {
    var base: TestHost = .{};
    defer base.deinit();
    try base.put(CONTRACT, 5, &counter_code);
    try base.putSlot(CONTRACT, 0, 1);
    const json = try traceCallJson(testing.allocator, base.iface(), testBlock(), .CANCUN, callTo(CONTRACT), null, null, .{ .prestate_tracer = .{ .diff_mode = true } });
    defer testing.allocator.free(json);
    var parsed = try parseJson(json);
    defer parsed.deinit();
    const post = parsed.value.object.get("post").?.object;
    const contract_post = post.get("0x0000000000000000000000000000000000002000").?.object;
    const slot0 = "0x0000000000000000000000000000000000000000000000000000000000000000";
    try testing.expectEqualStrings("0x0000000000000000000000000000000000000000000000000000000000000002", contract_post.get("storage").?.object.get(slot0).?.string);
    try testing.expectEqual(@as(i64, 1), post.get("0x0000000000000000000000000000000000001000").?.object.get("nonce").?.integer);

    const plain = try traceCallJson(testing.allocator, base.iface(), testBlock(), .CANCUN, callTo(CONTRACT), null, null, .{ .prestate_tracer = .{} });
    defer testing.allocator.free(plain);
    var parsed_plain = try parseJson(plain);
    defer parsed_plain.deinit();
    try testing.expectEqualStrings("0x5", parsed_plain.value.object.get("0x0000000000000000000000000000000000002000").?.object.get("balance").?.string);
}

test "traceCallJson: 4byte, flat, struct logger and mux" {
    var base: TestHost = .{};
    defer base.deinit();
    try base.put(CONTRACT, 0, &counter_code);
    var req = callTo(CONTRACT);
    req.input = &.{ 0xaa, 0xbb, 0xcc, 0xdd, 0x01 };

    const four = try traceCallJson(testing.allocator, base.iface(), testBlock(), .CANCUN, req, null, null, .four_byte_tracer);
    defer testing.allocator.free(four);
    try testing.expectEqualStrings("{\"0xaabbccdd-1\":1}", four);

    const flat = try traceCallJson(testing.allocator, base.iface(), testBlock(), .CANCUN, req, null, null, .{ .flat_call_tracer = .{} });
    defer testing.allocator.free(flat);
    var parsed_flat = try parseJson(flat);
    defer parsed_flat.deinit();
    try testing.expectEqualStrings("call", parsed_flat.value.array.items[0].object.get("type").?.string);

    const logs = try traceCallJson(testing.allocator, base.iface(), testBlock(), .CANCUN, req, null, null, .{ .struct_logger = .{} });
    defer testing.allocator.free(logs);
    var parsed_logs = try parseJson(logs);
    defer parsed_logs.deinit();
    const steps = parsed_logs.value.object.get("structLogs").?.array.items;
    try testing.expectEqual(@as(usize, 12), steps.len);
    try testing.expectEqualStrings("PUSH0", steps[0].object.get("op").?.string);
    try testing.expectEqual(false, parsed_logs.value.object.get("failed").?.bool);

    const mux = try traceCallJson(testing.allocator, base.iface(), testBlock(), .CANCUN, req, null, null, .{ .mux = &.{
        .{ .name = "callTracer", .choice = .{ .call_tracer = .{} } },
        .{ .name = "4byteTracer", .choice = .four_byte_tracer },
        .{ .name = "structLogger", .choice = .{ .struct_logger = .{ .disable_stack = true } } },
    } });
    defer testing.allocator.free(mux);
    var parsed_mux = try parseJson(mux);
    defer parsed_mux.deinit();
    try testing.expectEqualStrings("CALL", parsed_mux.value.object.get("callTracer").?.object.get("type").?.string);
    try testing.expectEqual(@as(i64, 1), parsed_mux.value.object.get("4byteTracer").?.object.get("0xaabbccdd-1").?.integer);
    try testing.expect(parsed_mux.value.object.get("structLogger").?.object.get("structLogs").?.array.items.len == 12);
}

test "traceCallParityJson: trace and stateDiff" {
    var base: TestHost = .{};
    defer base.deinit();
    try base.put(CONTRACT, 0, &counter_code);
    try base.putSlot(CONTRACT, 0, 4);
    const json = try traceCallParityJson(testing.allocator, base.iface(), testBlock(), .CANCUN, callTo(CONTRACT), null, null, .{ .trace = true, .state_diff = true });
    defer testing.allocator.free(json);
    var parsed = try parseJson(json);
    defer parsed.deinit();
    const root = parsed.value.object;
    try testing.expectEqualStrings("0x0000000000000000000000000000000000000000000000000000000000000005", root.get("output").?.string);
    try testing.expect(root.get("vmTrace").? == .null);
    try testing.expectEqualStrings("call", root.get("trace").?.array.items[0].object.get("type").?.string);
    const diff = root.get("stateDiff").?.object;
    const contract = diff.get("0x0000000000000000000000000000000000002000").?.object;
    try testing.expectEqualStrings("=", contract.get("balance").?.string);
    const slot = contract.get("storage").?.object.get("0x0000000000000000000000000000000000000000000000000000000000000000").?.object.get("*").?.object;
    try testing.expectEqualStrings("0x0000000000000000000000000000000000000000000000000000000000000004", slot.get("from").?.string);
    try testing.expectEqualStrings("0x0000000000000000000000000000000000000000000000000000000000000005", slot.get("to").?.string);
    const sender_nonce = diff.get("0x0000000000000000000000000000000000001000").?.object.get("nonce").?.object.get("*").?.object;
    try testing.expectEqualStrings("0x0", sender_nonce.get("from").?.string);
    try testing.expectEqualStrings("0x1", sender_nonce.get("to").?.string);

    const trace_only = try traceCallParityJson(testing.allocator, base.iface(), testBlock(), .CANCUN, callTo(CONTRACT), null, null, .{ .trace = true });
    defer testing.allocator.free(trace_only);
    var parsed_trace = try parseJson(trace_only);
    defer parsed_trace.deinit();
    try testing.expect(parsed_trace.value.object.get("stateDiff").? == .null);
}
