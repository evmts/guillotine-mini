/// EVM orchestrator: world state, storage, gas refunds, warm/cold tracking and nested calls.
/// `Evm` owns transaction and message lifecycle (checkpoints, rollback, end-of-transaction
/// cleanup); `Frame` interprets bytecode for one message.
const std = @import("std");
const log = @import("logger.zig");
const primitives = @import("voltaire");
const GasConstants = primitives.GasConstants;
const Address = primitives.Address;
const Frame = @import("frame.zig").Frame;
const Hardfork = primitives.Hardfork;
const host = @import("host.zig");
const errors = @import("errors.zig");
const trace = @import("trace.zig");
const inspector_mod = @import("inspector.zig");
const precompiles = @import("precompiles");
const crypto = @import("crypto");
const evm_config = @import("evm_config.zig");
const EvmConfig = evm_config.EvmConfig;
const storage_injector = @import("storage_injector.zig");
const StorageInjector = storage_injector.StorageInjector;
const storage_mod = @import("storage.zig");
const async_executor_mod = @import("async_executor.zig");
const access_list_manager_mod = @import("access_list_manager.zig");
const AccessListManager = access_list_manager_mod.AccessListManager;
const AccessListSnapshot = access_list_manager_mod.AccessListSnapshot;
const hardfork_hooks = @import("hardfork_hooks.zig");

pub const BalRecorder = hardfork_hooks.block_access_list.BalRecorder;
pub const BlockAccessIndex = hardfork_hooks.block_access_list.BlockAccessIndex;

// Re-export StorageKey from Voltaire primitives (canonical path)
pub const StorageKey = primitives.State.StorageKey;
pub const StorageSlotKey = StorageKey; // Backwards compatibility alias

// Re-export from storage module
pub const Storage = storage_mod.Storage;
pub const AsyncDataRequest = storage_mod.AsyncDataRequest;

// For creating snapshots we need access to the snapshot API
// The manager provides snapshot() and restore() methods

pub const BlockContext = struct {
    chain_id: u256,
    block_number: u64,
    block_timestamp: u64,
    block_difficulty: u256,
    block_prevrandao: u256,
    block_coinbase: primitives.Address,
    block_gas_limit: u64,
    block_base_fee: u256,
    blob_base_fee: u256,
    /// Array of recent block hashes (last 256 blocks)
    /// Per Python reference (cancun/vm/__init__.py:42): block_hashes: List[Hash32]
    /// Python access pattern: block_hashes[-(current_block - target_block)]
    /// Empty slice if no block hashes available
    block_hashes: []const [32]u8 = &[_][32]u8{},
    /// EIP-7843 (Amsterdam+): current beacon slot number returned by SLOTNUM (0x4b).
    slot_num: u64 = 0,
};

/// EIP-7702 delegation designation prefix.
pub const DELEGATION_PREFIX = [_]u8{ 0xef, 0x01, 0x00 };
/// `0xef0100 || address`.
pub const DELEGATION_CODE_LENGTH = DELEGATION_PREFIX.len + 20;

/// The delegate of an EIP-7702 designation, or null. Only the exact 23-byte
/// form counts (execution-specs prague `is_valid_delegation`).
pub fn parseDelegation(code: []const u8) ?primitives.Address {
    if (code.len != DELEGATION_CODE_LENGTH or !std.mem.eql(u8, code[0..3], &DELEGATION_PREFIX)) return null;
    return .{ .bytes = code[3..23].* };
}

/// RIPEMD-160 precompile. Its EIP-161 touch survives a reverted call (EELS).
pub const RIPEMD160_ADDRESS: Address = Address.fromU256(0x03);
/// EIP-7951 (Osaka): address of the P256VERIFY precompile.
pub const P256VERIFY_ADDRESS: Address = Address.fromU256(0x0100);
/// EIP-7951: fixed gas cost for P256VERIFY regardless of input validity.
pub const P256VERIFY_GAS: u64 = 6900;
/// EIP-7951: input layout is `msg_hash(32) || r(32) || s(32) || qx(32) || qy(32)`.
pub const P256VERIFY_INPUT_LEN: usize = 160;
const P256VERIFY_SUCCESS_OUTPUT = [_]u8{0} ** 31 ++ [_]u8{1};

/// Highest address in the contiguous 0x01.. precompile range that Voltaire may report
/// (0x01..0x13 covers both Voltaire's current BLS12-381 table and the final 7-operation
/// EIP-2537 table 0x0b..0x11 without hardcoding a per-fork count).
const MAX_CONTIGUOUS_PRECOMPILE: u16 = 0x13;

/// Single source of truth for precompile address membership across call dispatch,
/// transaction-start pre-warming (EIP-2929), and end-of-tx empty-account cleanup (EIP-161).
pub fn isPrecompileAddress(address: Address, hardfork: Hardfork) bool {
    if (address.equals(P256VERIFY_ADDRESS)) return hardfork.isAtLeast(.OSAKA);
    return precompiles.isPrecompile(address, hardfork);
}

const PrecompileExecution = @typeInfo(@TypeOf(precompiles.execute)).@"fn".return_type.?;

/// Execute the standard precompile at `address`. Caller must check `isPrecompileAddress()`.
pub fn executePrecompile(
    allocator: std.mem.Allocator,
    address: Address,
    input: []const u8,
    gas_limit: u64,
    hardfork: Hardfork,
) PrecompileExecution {
    // Older native tables lack EIP-7951. The pinned and modular tables handle it
    // through their regular dispatcher, keeping crypto out of the modular core.
    if (@hasDecl(precompiles, "PrecompileResult") and !@hasDecl(precompiles, "p256verify") and
        hardfork.isAtLeast(.OSAKA) and address.equals(P256VERIFY_ADDRESS))
    {
        return executeP256Verify(allocator, input, gas_limit);
    }
    return precompiles.execute(allocator, address, input, gas_limit, hardfork);
}

/// Execute EIP-7951 P256VERIFY (secp256r1 / NIST P-256 ECDSA prehashed verification).
///
/// Charges a fixed `P256VERIFY_GAS` (6900) and fails only with `error.OutOfGas` (or OOM).
/// A valid signature returns a 32-byte big-endian 1; wrong length, invalid scalars/points,
/// or a signature mismatch succeed with 0-byte empty output.
pub fn executeP256Verify(
    allocator: std.mem.Allocator,
    input: []const u8,
    gas_limit: u64,
) PrecompileExecution {
    if (gas_limit < P256VERIFY_GAS) return error.OutOfGas;
    const valid = input.len == P256VERIFY_INPUT_LEN and verifyP256Signature(input[0..P256VERIFY_INPUT_LEN]);
    return .{
        .output = if (valid) try allocator.dupe(u8, &P256VERIFY_SUCCESS_OUTPUT) else &.{},
        .gas_used = P256VERIFY_GAS,
    };
}

/// EIP-7951 input validation and secp256r1 ECDSA verification over a 160-byte input.
fn verifyP256Signature(input: *const [P256VERIFY_INPUT_LEN]u8) bool {
    const p256 = crypto.p256;
    const msg_hash = input[0..32];
    const r_bytes = input[32..64];
    const s_bytes = input[64..96];
    const qx_bytes = input[96..128];
    const qy_bytes = input[128..160];

    // EIP-7951 bounds: r, s in [1, n-1] (high-s permitted); qx, qy in [0, p-1]; Q != (0, 0).
    const r_int = std.mem.readInt(u256, r_bytes, .big);
    const s_int = std.mem.readInt(u256, s_bytes, .big);
    if (r_int == 0 or r_int >= p256.P256_N or s_int == 0 or s_int >= p256.P256_N) return false;

    const qx_int = std.mem.readInt(u256, qx_bytes, .big);
    const qy_int = std.mem.readInt(u256, qy_bytes, .big);
    if (qx_int >= p256.P256_P or qy_int >= p256.P256_P) return false;
    if (qx_int == 0 and qy_int == 0) return false;

    // Explicit on-curve and non-identity check (also rejects Zig's affine (0, 1) identity).
    const P256 = p256.P256;
    const pub_point = P256.fromSerializedAffineCoordinates(qx_bytes.*, qy_bytes.*, .big) catch return false;
    pub_point.rejectIdentity() catch return false;

    // Zig 0.15 std.crypto.sign.ecdsa rejects h == 0 (mod n), whereas EIP-7951 permits it:
    // when h == 0 (mod n), u1 = 0 so R' = (r * s^-1) * Q, valid iff R' != infinity and R'.x mod n == r.
    const h_int = std.mem.readInt(u256, msg_hash, .big);
    if (h_int % p256.P256_N != 0) {
        return p256.verify(msg_hash, r_bytes, s_bytes, input[96..160]) catch false;
    }

    const r_scalar = P256.scalar.Scalar.fromBytes(r_bytes.*, .big) catch return false;
    const s_scalar = P256.scalar.Scalar.fromBytes(s_bytes.*, .big) catch return false;
    const u2_scalar = r_scalar.mul(s_scalar.invert()).toBytes(.little);
    const r_point = pub_point.mulPublic(u2_scalar, .little) catch return false;
    r_point.rejectIdentity() catch return false;
    const rx_bytes = r_point.affineCoordinates().x.toBytes(.big);
    const rx_mod_n = std.mem.readInt(u256, &rx_bytes, .big) % p256.P256_N;
    return rx_mod_n == r_int;
}

/// Creates a configured EVM instance type.
pub fn Evm(comptime config: EvmConfig) type {
    // Import Frame with matching config
    const frame_mod = @import("frame.zig");
    const FrameType = frame_mod.Frame(config);

    // Import new API types with config
    const call_params = @import("call_params.zig");
    const call_result = @import("call_result.zig");
    const compiled_code = @import("compiled_code.zig");

    return struct {
        const Self = @This();

        const AddressSet = std.AutoHashMap(primitives.Address, void);
        const SlotMap = std.AutoHashMap(StorageKey, u256);

        /// EVM stack depth limit: a message at depth 1024 cannot call or create.
        pub const stack_depth_limit: usize = config.max_call_depth;
        /// Most frames alive at once: the top-level frame (depth 0) plus depths 1..1024.
        /// `frames` reserves exactly this capacity per transaction and never grows past it.
        pub const max_frames: usize = stack_depth_limit + 1;
        /// Scratch memory kept between transactions; anything above this is returned to the OS.
        const tx_arena_retain_limit: usize = 8 * 1024 * 1024;

        /// Result of `inner_create`. `output` is non-empty only when init code ended in REVERT.
        pub const CreateResult = struct {
            address: Address = primitives.ZERO_ADDRESS,
            success: bool = false,
            gas_left: u64 = 0,
            output: []const u8 = &.{},
            err: ?errors.CallError = null,
        };

        /// Outcome of the shared precompile dispatch used by `call` and `inner_call`.
        pub const PrecompileOutcome = union(enum) {
            /// No precompile path handles this address.
            none,
            success: struct { gas_left: u64, output: []const u8 },
            /// The precompile failed; all forwarded gas is consumed.
            failure: anyerror,
        };

        /// Revert point for one message (top-level call, nested call or create).
        ///
        /// Storage is captured through `original_storage`: every slot written this transaction
        /// has an entry there, so the snapshot costs O(slots written), not O(state). Balances,
        /// nonces and code are copy-on-write through the `*_snapshot_stack` lists, which hold
        /// pointers into this struct, so a live checkpoint must not move.
        pub const Checkpoint = struct {
            refund: i64,
            logs_len: usize,
            touched_len: usize,
            access_list: AccessListSnapshot,
            original_storage: SlotMap,
            storage: SlotMap,
            transient: SlotMap,
            selfdestructed: AddressSet,
            created: AddressSet,
            balances: std.AutoHashMap(primitives.Address, u256),
            nonces: std.AutoHashMap(primitives.Address, u64),
            code: std.AutoHashMap(primitives.Address, []const u8),
            bal_snapshot: ?BalRecorder.Snapshot = null,
        };

        /// Account field an async transaction can ask the host for.
        pub const AsyncAccountField = enum(u8) { balance, nonce, code };
        pub const AsyncKnownKey = struct { field: AsyncAccountField, address: [20]u8 };
        /// Transaction-scoped account code. `owned` bytes belong to `allocator`; borrowed
        /// bytes belong to the caller of the synchronous `call()` and outlive it.
        pub const AsyncCodeView = struct { address: primitives.Address, bytes: []const u8, owned: bool = true };

        pub const CallParams = call_params.CallParams(config);
        pub const CallResult = call_result.CallResult(config);

        // Create AsyncExecutor type for this EVM
        pub const AsyncExecutorType = async_executor_mod.AsyncExecutor(Self, CallParams, CallResult);

        // Re-export async types from executor
        pub const CallOrContinueInput = AsyncExecutorType.CallOrContinueInput;
        pub const CallOrContinueOutput = AsyncExecutorType.CallOrContinueOutput;

        frames: std.ArrayList(FrameType),
        storage: Storage,
        // Explicitly seeded slots are also the baseline for injector-backed transactions.
        storage_prestate: std.AutoHashMap(StorageKey, u256),
        created_accounts: std.AutoHashMap(primitives.Address, void),
        selfdestructed_accounts: std.AutoHashMap(primitives.Address, void), // EIP-6780: Track accounts marked for deletion
        touched_accounts: std.AutoHashMap(primitives.Address, void), // EIP-161 (Spurious Dragon+): touched accounts, deleted at transaction end if empty
        balances: std.AutoHashMap(primitives.Address, u256),
        nonces: std.AutoHashMap(primitives.Address, u64),
        code: std.AutoHashMap(primitives.Address, []const u8),
        access_list_manager: AccessListManager,
        /// Signed refund counter (EELS `refund_counter`). It may go negative mid-transaction;
        /// read the committed value through `get_effective_refund()`.
        gas_refund: i64,
        // Stack of balance snapshots for nested calls (for SELFDESTRUCT revert handling)
        // Each call pushes a snapshot, and on revert we restore from that snapshot
        balance_snapshot_stack: std.ArrayList(*std.AutoHashMap(primitives.Address, u256)),
        nonce_snapshot_stack: std.ArrayList(*std.AutoHashMap(primitives.Address, u64)),
        code_snapshot_stack: std.ArrayList(*std.AutoHashMap(primitives.Address, []const u8)),
        hardfork: Hardfork = Hardfork.DEFAULT,
        fork_transition: ?primitives.ForkTransition = null,
        origin: primitives.Address,
        gas_price: u256,
        host: ?host.HostInterface,
        /// Long-lived arena: world state (balances, nonces, code, storage) and returned results.
        arena: std.heap.ArenaAllocator,
        /// Per-transaction scratch arena: frames, stacks, checkpoints and warm sets. Recycled at
        /// the start of every transaction by `initTransactionState`.
        tx_arena: std.heap.ArenaAllocator,
        /// Insertion-ordered journal of `touched_accounts`, so a checkpoint is one length.
        touched_journal: std.ArrayList(primitives.Address),
        /// Owned copy (backed by `allocator`) of the current transaction's blob hashes.
        blob_hashes_owned: std.ArrayList([32]u8),
        allocator: std.mem.Allocator,
        tracer: ?*trace.Tracer = null,
        inspector: ?inspector_mod.Inspector = null,
        next_frame_id: u64 = 0,
        inspector_frame_id: ?u64 = null,
        block_context: BlockContext,
        blob_versioned_hashes: []const [32]u8 = &[_][32]u8{},
        // Stored state for call() - set via setter methods
        pending_bytecode: []const u8 = &[_]u8{},
        pending_access_list: ?primitives.AccessList.AccessList = null,
        pending_storage_injector: ?*storage_injector.StorageInjector = null,

        // Config-provided overrides (comptime known)
        opcode_overrides: []const evm_config.OpcodeOverride,
        precompile_overrides: []const evm_config.PrecompileOverride,

        // Full state-changes JSON from the latest dumpStateChanges(), owned by `allocator`
        // (not the arena) at its exact size so large dumps are never truncated (BUG_HUNT_REPORT #9).
        // Freed on the next dump, transaction init, and deinit().
        pending_state_changes: []u8 = &.{},

        // Async executor (initialized after Self is fully constructed)
        async_executor: ?AsyncExecutorType = null,
        async_observation: ?ObservedFrame = null,
        async_observed_gas: ?u64 = null,
        /// Unused: async precompile calls now run through `AsyncExecutor`, which holds the one
        /// pending result. Kept (always null) so embedders that reset it still compile.
        pending_precompile_result: ?CallResult = null,

        /// True only while `AsyncExecutor` is running a message (not while it is suspended).
        /// Only then do missing injector data restart the transaction (see
        /// `requestAsyncRestart`); synchronous `call()` and getters used between
        /// continuations never request account data.
        async_active: bool = false,
        /// A nested frame, constructor or account lookup needs data the host has not supplied.
        /// The executor rolls the transaction back, asks for `async_restart_request` and
        /// replays the transaction once the host answers.
        async_restart_pending: bool = false,
        async_restart_request: AsyncDataRequest = .none,
        /// Account fields the host supplied during the async transaction in flight
        /// (transaction-arena backed). Fetched fields are dropped when it ends.
        async_known: std.AutoHashMap(AsyncKnownKey, void),
        /// Code installed at the call target for one call, synchronous or async (see
        /// `installCallCodeView` and `installAsyncCodeView`).
        async_code_view: ?AsyncCodeView = null,
        /// Where the synchronous `call()` allocates the result it returns (output, logs,
        /// error text). Null selects the long-lived arena, which keeps every result until
        /// `deinit`. An embedder that reuses one instance for many calls sets an allocator it
        /// resets itself between calls, so results do not accumulate (R3-015).
        result_allocator: ?std.mem.Allocator = null,
        /// Allocation behind `pending_state_changes` (the JSON may be shorter).
        pending_state_changes_buffer: []u8 = &.{},

        // Accumulated logs for current transaction
        logs: std.ArrayList(call_result.Log),
        /// Direct-mapped compiled-bytecode cache (owned by `self.allocator`, cleaned up in `deinit`).
        code_cache: compiled_code.CodeCache = .{},
        /// EIP-8037 (Amsterdam+): initial state gas reservoir configured for the next `call()`.
        pending_state_gas_reservoir: u64 = 0,
        /// EIP-8037 (Amsterdam+): remaining state gas reservoir after the last `call()`.
        state_gas_reservoir: u64 = 0,
        /// EIP-8037 (Amsterdam+): committed state gas consumed by the last `call()`.
        state_gas_used: u64 = 0,
        /// EIP-7928 (Amsterdam+): optional revert-aware Block-Level Access List recorder.
        bal_recorder: ?*BalRecorder = null,
        /// EIP-7928 (Amsterdam+): block access index stamped onto BAL state changes.
        bal_index: BlockAccessIndex = hardfork_hooks.block_access_list.transactionIndex(0),

        /// Single source of truth for precompile address membership (delegates to module helper).
        pub fn isPrecompileAddress(address: Address, hardfork: Hardfork) bool {
            return @import("evm.zig").isPrecompileAddress(address, hardfork);
        }

        /// Initialize a new EVM instance with every field in a valid empty/default state.
        /// Calling `init` followed immediately by `deinit` (or pre-call accessors) is always safe and leak-free.
        /// `hardfork == null` selects `config.hardfork`; a non-null value overrides it at runtime.
        /// A schedule set with `setForkTransition` then picks the fork per transaction.
        pub fn init(self: *Self, allocator: std.mem.Allocator, h: ?host.HostInterface, hardfork: ?Hardfork, block_context: ?BlockContext, origin: primitives.Address, gas_price: u256, log_level: ?log.LogLevel) !void {
            // Set log level if provided
            if (log_level) |level| {
                log.setLogLevel(level);
            }

            // Initialize every field without `undefined`. Empty containers do not allocate on
            // init; arena-backed maps are rebound below once `self.arena` is in its final address.
            self.* = Self{
                .frames = .empty,
                .storage = Storage.init(allocator, h, null),
                .storage_prestate = .init(allocator),
                .created_accounts = std.AutoHashMap(primitives.Address, void).init(allocator),
                .selfdestructed_accounts = std.AutoHashMap(primitives.Address, void).init(allocator),
                .touched_accounts = std.AutoHashMap(primitives.Address, void).init(allocator),
                .balances = std.AutoHashMap(primitives.Address, u256).init(allocator),
                .nonces = std.AutoHashMap(primitives.Address, u64).init(allocator),
                .code = std.AutoHashMap(primitives.Address, []const u8).init(allocator),
                .access_list_manager = AccessListManager.init(allocator),
                .gas_refund = 0,
                .balance_snapshot_stack = .empty,
                .nonce_snapshot_stack = .empty,
                .code_snapshot_stack = .empty,
                .hardfork = hardfork orelse config.hardfork,
                .fork_transition = null,
                .block_context = block_context orelse .{
                    .chain_id = 1,
                    .block_number = 0,
                    .block_timestamp = 0,
                    .block_difficulty = 0,
                    .block_prevrandao = 0,
                    .block_coinbase = primitives.ZERO_ADDRESS,
                    .block_gas_limit = config.block_gas_limit,
                    .block_base_fee = 0,
                    .blob_base_fee = 0,
                },
                .origin = origin,
                .gas_price = gas_price,
                .host = h,
                .arena = std.heap.ArenaAllocator.init(allocator),
                .tx_arena = std.heap.ArenaAllocator.init(allocator),
                .touched_journal = .empty,
                .blob_hashes_owned = .empty,
                .allocator = allocator,
                .tracer = null,
                .blob_versioned_hashes = &[_][32]u8{},
                .pending_bytecode = &[_]u8{},
                .pending_access_list = null,
                .pending_storage_injector = null,
                .opcode_overrides = config.opcode_overrides,
                .precompile_overrides = config.precompile_overrides,
                .pending_state_changes = &.{},
                .async_executor = null, // Initialized when needed
                .pending_precompile_result = null,
                .async_active = false,
                .async_restart_pending = false,
                .async_restart_request = .none,
                .async_known = std.AutoHashMap(AsyncKnownKey, void).init(allocator),
                .async_code_view = null,
                .logs = .empty,
            };

            // World state lives in the long-lived arena so it survives across transactions;
            // per-transaction sets are bound to the scratch arena.
            const arena_alloc = self.arena.allocator();
            const tx_alloc = self.tx_arena.allocator();
            self.storage = Storage.init(arena_alloc, h, null);
            self.storage_prestate = .init(arena_alloc);
            self.balances = std.AutoHashMap(primitives.Address, u256).init(arena_alloc);
            self.nonces = std.AutoHashMap(primitives.Address, u64).init(arena_alloc);
            self.code = std.AutoHashMap(primitives.Address, []const u8).init(arena_alloc);
            self.created_accounts = AddressSet.init(tx_alloc);
            self.selfdestructed_accounts = AddressSet.init(tx_alloc);
            self.touched_accounts = AddressSet.init(tx_alloc);
            self.access_list_manager = AccessListManager.init(tx_alloc);
            self.async_known = std.AutoHashMap(AsyncKnownKey, void).init(tx_alloc);
        }

        pub fn freePendingStateChanges(self: *Self) void {
            if (self.pending_state_changes_buffer.len > 0) self.allocator.free(self.pending_state_changes_buffer);
            self.pending_state_changes_buffer = &.{};
            self.pending_state_changes = &.{};
        }

        /// Return the full pending state-changes JSON slice (empty slice if none).
        pub fn getPendingStateChanges(self: *const Self) []const u8 {
            return self.pending_state_changes;
        }

        /// Seed a storage slot without counting it as a transaction write.
        pub fn setStoragePrestate(self: *Self, key: StorageKey, value: u256) !void {
            try self.storage_prestate.ensureUnusedCapacity(1);
            try self.storage.storage.put(key, value);
            self.storage_prestate.putAssumeCapacity(key, value);
        }

        /// Look up custom opcode handler override
        /// Returns null if no override exists for this opcode
        pub fn getOpcodeOverride(self: *const Self, opcode: u8) ?*const anyopaque {
            for (self.opcode_overrides) |override| {
                if (override.opcode == opcode) {
                    return override.handler;
                }
            }
            return null;
        }

        /// Look up custom precompile override
        /// Returns null if no override exists for this address
        pub fn getPrecompileOverride(self: *const Self, address: primitives.Address) ?*const evm_config.PrecompileOverride {
            for (self.precompile_overrides) |*override| {
                if (override.address.equals(address)) {
                    return override;
                }
            }
            return null;
        }

        /// Clean up resources. Safe to call directly after `init`, without `call()`.
        ///
        /// An async transaction still suspended is cancelled first: its uncommitted writes
        /// are rolled back while the host and its root checkpoint are alive, so an external
        /// host is not left holding the writes of a transaction that never finished.
        pub fn deinit(self: *Self) void {
            // The injector belongs to the embedder and may already be gone; the rollback
            // must not touch it.
            self.storage.storage_injector = null;
            self.pending_storage_injector = null;
            if (self.async_executor) |*executor| {
                executor.evm = self;
                executor.cancel();
            }
            self.async_executor = null;
            self.releaseAsyncCodeView();
            self.freePendingStateChanges();
            self.blob_hashes_owned.deinit(self.allocator);
            self.code_cache.deinit(self.allocator);
            self.tx_arena.deinit();
            self.arena.deinit();
        }

        /// Reconfigure a long-lived `Evm` instance for a new transaction without
        /// re-allocating the frame stack, arenas, or compiled bytecode cache.
        /// Routes `CallResult` allocations to `tx_arena` so repeated calls never
        /// leak into the long-lived `arena`.
        pub fn reconfigureForTx(
            self: *Self,
            host_iface: ?host.HostInterface,
            hardfork: Hardfork,
            block_context: BlockContext,
            origin: Address,
            gas_price: u256,
            precompile_overrides: []const evm_config.PrecompileOverride,
        ) void {
            self.host = host_iface;
            self.storage.host = host_iface;
            self.hardfork = hardfork;
            self.fork_transition = null;
            self.block_context = block_context;
            self.origin = origin;
            self.gas_price = gas_price;
            self.precompile_overrides = precompile_overrides;
            self.result_allocator = self.tx_arena.allocator();
        }

        /// Attach (or clear) a fork schedule. Every transaction then runs under the fork the
        /// schedule selects for the current block number and timestamp.
        pub fn setForkTransition(self: *Self, transition: ?primitives.ForkTransition) void {
            self.fork_transition = transition;
            self.hardfork = self.getActiveFork();
        }

        /// The fork a transaction started now would run under: the `fork_transition`
        /// schedule applied to the block context, or the configured fork without one.
        /// `initTransactionState` stores it in `hardfork`, which every rule reads.
        pub fn getActiveFork(self: *const Self) Hardfork {
            if (self.fork_transition) |transition| {
                return transition.getActiveFork(self.block_context.block_number, self.block_context.block_timestamp);
            }
            return self.hardfork;
        }

        /// Begin a transaction: reset every transaction-scoped structure and recycle the scratch arena.
        ///
        /// World state installed before the call (`balances`, `nonces`, `code`, and hostless
        /// `storage`) is preserved. Reset: refund counter, warm sets, frames, logs, created,
        /// self-destructed and touched sets, original and transient storage, checkpoints.
        /// Must run before `inner_create`/`inner_call` are used directly; `call()` runs it itself.
        ///
        /// `blob_versioned_hashes` is copied; `null` means the transaction carries no blobs.
        pub fn initTransactionState(self: *Self, blob_versioned_hashes: ?[]const [32]u8) !void {
            try self.initTransactionStateInternal(blob_versioned_hashes, true);
        }

        fn initTransactionStateInternal(self: *Self, blob_versioned_hashes: ?[]const [32]u8, reserve_frames: bool) !void {
            // A new transaction supersedes an async one still suspended or awaiting its commit
            // acknowledgement: its uncommitted writes are rolled back and it can no longer be
            // continued. Must run before the scratch arena (which holds its checkpoint) resets.
            if (self.async_executor) |*executor| executor.cancel();
            self.endAsyncTransaction();

            self.freePendingStateChanges();
            self.pending_precompile_result = null;

            // Fork schedule: frames, gas rules and precompile dispatch all read `hardfork`.
            self.hardfork = self.getActiveFork();

            // Copy blob hashes (EIP-4844) before anything is recycled: the caller may free its
            // slice after this call, and may also hand back our own previous copy.
            if (blob_versioned_hashes) |hashes| {
                const buf = &self.blob_hashes_owned;
                const buf_start = @intFromPtr(buf.items.ptr);
                const aliases_own_buffer = hashes.len > 0 and buf.capacity > 0 and
                    @intFromPtr(hashes.ptr) >= buf_start and
                    @intFromPtr(hashes.ptr) < buf_start + buf.capacity * @sizeOf([32]u8);
                if (aliases_own_buffer) {
                    std.mem.copyForwards([32]u8, buf.items.ptr[0..hashes.len], hashes);
                    buf.items.len = hashes.len;
                } else {
                    buf.clearRetainingCapacity();
                    try buf.appendSlice(self.allocator, hashes);
                }
                self.blob_versioned_hashes = buf.items;
            } else {
                self.blob_hashes_owned.clearRetainingCapacity();
                self.blob_versioned_hashes = &[_][32]u8{};
            }

            _ = self.tx_arena.reset(.{ .retain_with_limit = tx_arena_retain_limit });
            const tx_alloc = self.tx_arena.allocator();

            // Storage: keep the persistent map, drop transaction-scoped tracking. With a host or
            // an injector the backing store is external and the local map is only a per-tx cache.
            const injector = self.pending_storage_injector orelse self.storage.storage_injector;
            self.storage.host = self.host;
            self.storage.storage_injector = injector;
            self.storage.async_data_request = .none;
            self.storage.original_storage.clearRetainingCapacity();
            self.storage.transient.clearRetainingCapacity();
            self.storage.trace_slots.clearRetainingCapacity();
            if (self.host != null or injector != null) {
                try self.storage.storage.ensureTotalCapacity(self.storage_prestate.count());
                self.storage.storage.clearRetainingCapacity();
                var seeds = self.storage_prestate.iterator();
                while (seeds.next()) |entry| self.storage.storage.putAssumeCapacity(entry.key_ptr.*, entry.value_ptr.*);
            }
            // No write is in flight any more. The injector cache keeps what the host holds
            // (fetched values and committed writes); a rolled back write never reached it.
            if (injector) |active| active.clearDirty();

            self.gas_refund = 0;
            self.state_gas_reservoir = 0;
            self.state_gas_used = 0;
            self.access_list_manager = AccessListManager.init(tx_alloc);
            try self.preWarmPrecompiles();

            // Frames live in the long-lived arena so repeated calls on a reused Evm never
            // reallocate or munmap the 1025-slot frame array. Precompile/EOA calls pass
            // reserve_frames = false and skip allocating it altogether.
            self.frames.clearRetainingCapacity();
            if (self.frames.items.len == 0) {
                self.code_cache.reclaimEvicted(self.allocator);
            }
            if (reserve_frames and self.frames.capacity < max_frames) {
                try self.frames.ensureTotalCapacityPrecise(self.arena.allocator(), max_frames);
            }

            self.logs = .empty;
            self.created_accounts = AddressSet.init(tx_alloc);
            self.selfdestructed_accounts = AddressSet.init(tx_alloc);
            self.touched_accounts = AddressSet.init(tx_alloc);
            self.touched_journal = .empty;
            self.balance_snapshot_stack = .empty;
            self.nonce_snapshot_stack = .empty;
            self.code_snapshot_stack = .empty;
            self.async_known = std.AutoHashMap(AsyncKnownKey, void).init(tx_alloc);
        }

        // ---- Async (storage injector) account lookups -------------------------------------
        //
        // Exact behavior, for an `AsyncExecutor` transaction on a hostless EVM with a storage
        // injector attached (in every other configuration lookups are synchronous and final):
        //
        //   - `get_balance`, `getNonce` and `get_raw_code` (and so `get_code`,
        //     `get_delegated_target`, `accountIsEmpty`, value transfers, CALL-family code
        //     resolution and CREATE collision checks) answer from the local account maps. A
        //     field that is in neither the local map nor `async_known` is a miss.
        //   - These getters cannot fail, so a miss is handled by restart: the getter returns
        //     zero/empty, `requestAsyncRestart` records the first missing field and stops every
        //     live frame, the executor rolls the transaction back to its root checkpoint,
        //     yields `.need_balance` / `.need_nonce` / `.need_code`, and replays the
        //     transaction from the start once the host replies. Zero and empty replies are
        //     remembered, so each field is requested at most once per transaction.
        //   - A storage miss in a nested call or constructor takes the same restart path
        //     (`.need_storage`). A storage miss in the top-level frame suspends and resumes
        //     that frame in place.
        //   - Fetched fields live for one transaction and are dropped when it ends; the host
        //     stays authoritative. Fields the embedder installed locally are never requested.
        //   - Never requested: the nonce of an account whose code is installed locally (the
        //     account is locally defined); the nonce and code of an account created by this
        //     transaction; the destination of a nonce-derived CREATE (its address cannot
        //     pre-exist short of a hash collision, so EIP-684 is checked on local data);
        //     the creator's balance for a zero-value creation. CREATE2 destinations, which
        //     can pre-exist, are requested.
        //   - Not covered: opcode handlers that read `balances`/`nonces`/`code` directly
        //     (EXTCODESIZE, EXTCODECOPY, EXTCODEHASH, SELFDESTRUCT and the EIP-161 liveness
        //     probe of CALL) see only local and already-fetched data.

        /// Record that the transaction in flight cannot finish without `request` and stop
        /// every live frame. The first request wins; later ones come from execution that
        /// already ran on missing data. No-op outside an async transaction.
        pub fn requestAsyncRestart(self: *Self, request: AsyncDataRequest) void {
            if (!self.async_active or self.async_restart_pending or request == .none) return;
            self.async_restart_pending = true;
            self.async_restart_request = request;
            for (self.frames.items) |*frame| frame.stopped = true;
        }

        pub fn clearAsyncRestart(self: *Self) void {
            self.async_restart_pending = false;
            self.async_restart_request = .none;
        }

        fn noteAccountMiss(self: *Self, comptime field: AsyncAccountField, address: primitives.Address) void {
            if (!self.async_active or self.storage.storage_injector == null) return;
            if (self.async_known.contains(.{ .field = field, .address = address.bytes })) return;
            if (field != .balance) {
                // An account created by this transaction has exactly the nonce and code the
                // transaction gave it.
                if (self.created_accounts.contains(address)) return;
            }
            if (field == .nonce) {
                // An account whose code the embedder installed (or supplied for this call) is
                // defined locally, nonce included. Code fetched from the host does not count.
                const code_is_local = self.code.contains(address) and
                    !self.async_known.contains(.{ .field = .code, .address = address.bytes });
                if (code_is_local) return;
            }
            self.requestAsyncRestart(switch (field) {
                .balance => .{ .balance = .{ .address = address } },
                .nonce => .{ .nonce = .{ .address = address } },
                .code => .{ .code = .{ .address = address } },
            });
        }

        /// Store a host reply for an account field. Fetched values are baseline state, not
        /// transaction writes, so they bypass the revert journal.
        pub fn supplyAsyncBalance(self: *Self, address: primitives.Address, balance: u256) !void {
            try self.async_known.put(.{ .field = .balance, .address = address.bytes }, {});
            try self.balances.put(address, balance);
        }

        pub fn supplyAsyncNonce(self: *Self, address: primitives.Address, nonce: u64) !void {
            try self.async_known.put(.{ .field = .nonce, .address = address.bytes }, {});
            if (nonce != 0) try self.nonces.put(address, nonce);
        }

        /// `code` is copied into the transaction arena.
        pub fn supplyAsyncCode(self: *Self, address: primitives.Address, code: []const u8) !void {
            try self.async_known.put(.{ .field = .code, .address = address.bytes }, {});
            if (code.len != 0) try self.code.put(address, try self.tx_arena.allocator().dupe(u8, code));
        }

        /// Whether code supplied with `setBytecode` also becomes the account code of `address`
        /// for the one call that runs it, so EXTCODE* and re-entrant calls see the code the
        /// call executes. True only on a hostless EVM for a target that has no code of its
        /// own and is not an active precompile: a host owns its accounts, and installed code
        /// is never replaced. The synchronous and the async entry point share this rule, so
        /// `EXTCODESIZE(ADDRESS)` agrees between them.
        pub fn suppliedCodeIsAccountCode(self: *Self, address: primitives.Address, supplied: []const u8) bool {
            if (supplied.len == 0 or self.host != null) return false;
            if ((self.code.get(address) orelse &[_]u8{}).len != 0) return false;
            return !Self.isPrecompileAddress(address, self.hardfork) or self.getPrecompileOverride(address) != null;
        }

        /// Make `bytes` the code of `address` for one async call (see
        /// `suppliedCodeIsAccountCode`). The view owns a copy, because the call can stay
        /// suspended after the caller's buffer is gone. Released by `endAsyncTransaction`;
        /// the account's code is never changed past the transaction.
        pub fn installAsyncCodeView(self: *Self, address: primitives.Address, bytes: []const u8) ![]const u8 {
            self.releaseAsyncCodeView();
            const owned = try self.allocator.dupe(u8, bytes);
            errdefer self.allocator.free(owned);
            try self.code.put(address, owned);
            self.async_code_view = .{ .address = address, .bytes = owned };
            return owned;
        }

        /// Synchronous counterpart of `installAsyncCodeView`: `bytes` is borrowed, since
        /// `call()` returns before its caller can free it. Released when `call()` returns.
        fn installCallCodeView(self: *Self, address: primitives.Address, bytes: []const u8) !void {
            self.releaseAsyncCodeView();
            try self.code.put(address, bytes);
            self.async_code_view = .{ .address = address, .bytes = bytes, .owned = false };
        }

        fn releaseAsyncCodeView(self: *Self) void {
            const view = self.async_code_view orelse return;
            self.async_code_view = null;
            // Leave the entry alone when the transaction replaced or deleted the code.
            if (self.code.get(view.address)) |current| {
                if (current.ptr == view.bytes.ptr) _ = self.code.remove(view.address);
            }
            if (view.owned) self.allocator.free(view.bytes);
        }

        /// Drop everything scoped to an async transaction: the restart request, the code view
        /// and every account field fetched from the host. Idempotent.
        pub fn endAsyncTransaction(self: *Self) void {
            self.async_active = false;
            self.clearAsyncRestart();
            self.releaseAsyncCodeView();
            var it = self.async_known.keyIterator();
            while (it.next()) |key| {
                const address = primitives.Address{ .bytes = key.address };
                switch (key.field) {
                    .balance => _ = self.balances.remove(address),
                    .nonce => _ = self.nonces.remove(address),
                    .code => _ = self.code.remove(address),
                }
            }
            self.async_known.clearRetainingCapacity();
        }

        /// Set tracer for EIP-3155 trace capture
        pub fn setTracer(self: *Self, tracer: *trace.Tracer) void {
            self.tracer = tracer;
        }

        pub fn setInspector(self: *Self, inspector: inspector_mod.Inspector) void {
            self.inspector = inspector;
        }

        pub fn clearInspector(self: *Self) void {
            self.inspector = null;
            self.async_observation = null;
            self.async_observed_gas = null;
            self.inspector_frame_id = null;
        }

        fn activeFrameId(self: *const Self) u64 {
            return self.inspector_frame_id orelse 0;
        }

        const ObservedFrame = struct {
            sink: inspector_mod.Inspector,
            frame_id: u64,
            parent_id: ?u64,
            depth: usize,
            gas: u64,
        };

        fn enterFrame(self: *Self, event: inspector_mod.FrameEnterEvent) ?ObservedFrame {
            @branchHint(.unlikely);
            const sink = self.inspector orelse return null;
            var view = event;
            view.frame_id = self.next_frame_id;
            self.next_frame_id += 1;
            view.parent_id = self.inspector_frame_id;
            view.depth = self.frames.items.len + 1;
            self.inspector_frame_id = view.frame_id;
            sink.onEnter(view);
            return .{ .sink = sink, .frame_id = view.frame_id, .parent_id = view.parent_id, .depth = view.depth, .gas = view.gas };
        }

        fn exitFrame(self: *Self, frame: ObservedFrame, result: CallResult, error_name: ?[]const u8) void {
            frame.sink.onExit(.{
                .frame_id = frame.frame_id,
                .parent_id = frame.parent_id,
                .depth = frame.depth,
                .output = result.output,
                .gas_used = frame.gas -| result.gas_left,
                .gas_left = result.gas_left,
                .reverted = !result.success,
                .error_name = error_name,
                .created_address = result.created_address,
            });
            self.inspector_frame_id = frame.parent_id;
        }

        fn enterCall(self: *Self, params: CallParams, from: Address, resolved: ResolvedCode, value: u256, is_static: bool) ?ObservedFrame {
            return self.observeCall(callType(params), from, params.get_to() orelse resolved.address, resolved, params.getInput(), value, params.getGas(), is_static);
        }

        fn observeCall(self: *Self, kind: inspector_mod.CallType, from: Address, target: Address, resolved: ResolvedCode, input: []const u8, value: u256, gas: u64, is_static: bool) ?ObservedFrame {
            @branchHint(.unlikely);
            if (self.inspector == null) return null;
            return self.enterFrame(.{
                .frame_id = 0,
                .parent_id = null,
                .depth = 0,
                .call_type = kind,
                .from = from,
                .to = target,
                .code_address = resolved.address,
                .value = value,
                .gas = gas,
                .input = input,
                .is_static = is_static,
                .is_precompile = self.canExecutePrecompile(target, resolved),
                .is_delegated = resolved.is_delegated,
                .code = resolved.code,
            });
        }

        fn callType(params: CallParams) inspector_mod.CallType {
            return switch (params) {
                .call => .call,
                .callcode => .callcode,
                .delegatecall => .delegatecall,
                .staticcall => .staticcall,
                .create => .create,
                .create2 => .create2,
            };
        }

        fn attachFrame(self: *Self, observation: ?ObservedFrame, code_address: Address) void {
            const frame = &self.frames.items[self.frames.items.len - 1];
            frame.code_address = code_address;
            if (observation) |observed| {
                frame.frame_id = observed.frame_id;
                frame.parent_frame_id = observed.parent_id;
            }
        }

        pub fn resultErrorName(result: CallResult) ?[]const u8 {
            if (result.success) return null;
            const name = result.error_info orelse return inspector_mod.formatErrorName(error.RevertExecution);
            const names = comptime blk: {
                const Name = struct { raw: []const u8, display: []const u8 };
                var table: []const Name = &.{};
                for (@typeInfo(errors.CallError).error_set.?) |entry| {
                    const display = inspector_mod.formatErrorName(@field(anyerror, entry.name));
                    if (!std.mem.eql(u8, entry.name, display))
                        table = table ++ [_]Name{.{ .raw = entry.name, .display = display }};
                }
                break :blk table;
            };
            for (names) |entry| if (std.mem.eql(u8, name, entry.raw)) return entry.display;
            return name;
        }

        fn failed(self: *Self, gas_left: u64, err: anyerror) CallResult {
            return CallResult.failure_with_error(self.result_allocator orelse self.arena.allocator(), gas_left, @errorName(err)) catch
                .{ .success = false, .gas_left = gas_left, .output = &.{}, .error_info = @errorName(err) };
        }

        /// EIP-8037 (Amsterdam+): set initial state gas reservoir for the next `call()`.
        pub fn setStateGasReservoir(self: *Self, reservoir: u64) void {
            self.pending_state_gas_reservoir = reservoir;
        }

        /// EIP-8037 (Amsterdam+): remaining state gas reservoir after execution.
        pub fn getStateGasReservoir(self: *const Self) u64 {
            return self.state_gas_reservoir;
        }

        /// EIP-8037 (Amsterdam+): committed state gas consumed by execution.
        pub fn getStateGasUsed(self: *const Self) u64 {
            return self.state_gas_used;
        }

        /// EIP-7928 (Amsterdam+): attach or clear a revert-aware BAL recorder.
        pub fn setBlockAccessListRecorder(self: *Self, recorder: ?*BalRecorder, index: BlockAccessIndex) void {
            self.bal_recorder = recorder;
            self.bal_index = index;
        }

        inline fn balHook(self: *Self) ?hardfork_hooks.block_access_list.Hook(BalRecorder) {
            const rec = self.bal_recorder orelse return null;
            return .{ .recorder = rec, .index = self.bal_index };
        }

        /// EIP-8037 (Amsterdam+): apply child/top frame state gas outcome to parent or EVM.
        fn applyChildStateGas(
            self: *Self,
            parent_idx: ?usize,
            initial_reservoir: u64,
            child_reservoir: u64,
            child_spilled: u64,
            child_used: i64,
            reverted_or_halted: bool,
        ) void {
            if (parent_idx) |idx| {
                const parent = &self.frames.items[idx];
                if (reverted_or_halted) {
                    parent.state_gas_reservoir = initial_reservoir;
                } else {
                    parent.mergeChildStateGas(child_reservoir, child_spilled, child_used);
                }
                return;
            }
            if (reverted_or_halted) {
                self.state_gas_reservoir = initial_reservoir;
                self.state_gas_used = 0;
            } else {
                self.state_gas_reservoir = child_reservoir;
                self.state_gas_used = if (child_used > 0) @intCast(child_used) else 0;
            }
        }

        fn validateCallParamsForHardfork(params: CallParams, hardfork: Hardfork) CallParams.ValidationError!void {
            if (hardfork_hooks.supportsAmsterdam(hardfork)) {
                try params.validate();
                const max_init = hardfork_hooks.maxInitcodeSize(hardfork, config.max_initcode_size);
                if (params.isCreate() and params.getInput().len > max_init) {
                    return error.InvalidInitCodeSize;
                }
                return;
            }
            try params.validateForHardfork(hardfork);
        }

        /// EIP-7708 (Amsterdam+): append a system Transfer log to the revert-safe tx log list.
        /// Emits nothing for zero value or self-transfers (`from == to`).
        pub fn emitEthTransferLog(
            self: *Self,
            from: primitives.Address,
            to: primitives.Address,
            value: u256,
        ) errors.CallError!void {
            const sys_log = hardfork_hooks.eth_transfer_log.transferLog(from.bytes, to.bytes, value) orelse return;
            const alloc = self.tx_arena.allocator();
            const topics_slice = try alloc.dupe(u256, sys_log.topics());
            const data_slice = try alloc.dupe(u8, &sys_log.data);
            const log_addr = primitives.Address{ .bytes = sys_log.address };
            try self.logs.append(alloc, call_result.Log{
                .address = log_addr,
                .topics = topics_slice,
                .data = data_slice,
            });
            if (self.inspector) |sink| {
                @branchHint(.unlikely);
                var raw_topics: [3][32]u8 = undefined;
                for (topics_slice, 0..) |topic, idx| {
                    std.mem.writeInt(u256, &raw_topics[idx], topic, .big);
                }
                sink.onLog(.{
                    .frame_id = self.activeFrameId(),
                    .address = log_addr,
                    .topics = raw_topics[0..topics_slice.len],
                    .data = data_slice,
                });
            }
        }

        pub fn accessAddress(self: *Self, address: Address) !u64 {
            const berlin = self.hardfork.isAtLeast(.BERLIN);
            const cost = if (berlin) try self.access_list_manager.access_address(address) else 0;
            const warm_cost = hardfork_hooks.GasSchedule.forFork(self.hardfork).warm_access;
            self.observeAccess(address, null, berlin and cost == warm_cost);
            if (self.bal_recorder) |rec| {
                @branchHint(.unlikely);
                try rec.recordAddressAccess(address.bytes);
            }
            return cost;
        }

        /// Access a storage slot and return the gas cost (EIP-2929 warm/cold).
        pub fn accessStorageSlot(self: *Self, address: Address, slot: u256) !u64 {
            const berlin = self.hardfork.isAtLeast(.BERLIN);
            const cost: u64 = if (berlin)
                try self.access_list_manager.access_storage_slot(address, slot)
            else if (self.hardfork.isAtLeast(.ISTANBUL))
                800
            else if (self.hardfork.isAtLeast(.TANGERINE_WHISTLE))
                200
            else
                50;
            const warm_cost = hardfork_hooks.GasSchedule.forFork(self.hardfork).warm_access;
            self.observeAccess(address, slot, berlin and cost == warm_cost);
            return cost;
        }

        fn observeAccess(self: *Self, address: Address, slot: ?u256, was_warm: bool) void {
            if (self.inspector) |sink| {
                @branchHint(.unlikely);
                sink.onAccess(.{ .frame_id = self.activeFrameId(), .address = address, .slot = slot, .was_warm = was_warm });
            }
        }

        pub fn observeStorage(self: *Self, frame: *FrameType, slot: u256, previous: u256, value: u256, is_read: bool) !void {
            if (self.inspector) |sink| {
                @branchHint(.unlikely);
                sink.onStorageChange(.{
                    .frame_id = frame.frame_id,
                    .address = frame.address,
                    .slot = slot,
                    .prev_value = previous,
                    .new_value = value,
                    .is_read = is_read,
                });
            }
            if (self.tracer) |tracer| {
                if (tracer.willCapture() and tracer.config.tracksStorage()) {
                    try self.storage.trace_slots.put(.{ .address = frame.address.bytes, .slot = slot }, {});
                }
            }
            if (self.balHook()) |*hook| {
                @branchHint(.unlikely);
                if (is_read) {
                    try hook.storageRead(frame.address.bytes, slot);
                } else {
                    try hook.storageWrite(frame.address.bytes, slot, previous, value);
                }
            }
        }

        /// Set balance with copy-on-write snapshot for revert handling
        ///
        /// This should be called instead of direct host.setBalance() when inside a frame.
        /// Uses copy-on-write semantics to track balance changes for proper revert handling.
        ///
        /// IMPORTANT: Snapshots the balance in ALL active snapshots on the stack, not just the current one.
        /// This ensures that parent frames can restore state when they revert, even if the balance
        /// was modified in a nested call.
        ///
        /// Parameters:
        ///   - addr: The address whose balance to modify
        ///   - new_balance: The new balance value to set
        ///
        /// Returns: void
        ///
        /// Errors:
        ///   - OutOfMemory: If snapshot allocation fails
        pub fn setBalanceWithSnapshot(self: *Self, addr: primitives.Address, new_balance: u256) !void {
            // Snapshot in ALL active snapshots (from outermost to innermost)
            // This ensures parent frames can restore state even if modified in nested calls
            for (self.balance_snapshot_stack.items) |snapshot| {
                if (!snapshot.contains(addr)) {
                    // Snapshot the current balance before modifying
                    const current_balance = if (self.host) |h|
                        h.getBalance(addr)
                    else
                        self.balances.get(addr) orelse 0;
                    try snapshot.put(addr, current_balance);
                }
            }

            const observer = self.inspector;
            const track_before = observer != null or self.bal_recorder != null;
            const before = if (track_before) self.peekBalance(addr) else 0;
            if (self.pending_storage_injector) |injector| {
                if (!injector.baseline_active) try injector.markBalanceDirty(addr);
            }
            if (self.host) |h| {
                h.setBalance(addr, new_balance);
            } else {
                try self.balances.put(addr, new_balance);
            }
            if (observer) |sink| {
                @branchHint(.unlikely);
                if (before != new_balance) sink.onBalanceChange(.{
                    .frame_id = self.activeFrameId(),
                    .address = addr,
                    .prev_balance = before,
                    .new_balance = new_balance,
                });
            }
            if (self.balHook()) |*hook| {
                @branchHint(.unlikely);
                try hook.balanceChange(addr.bytes, before, new_balance);
            }
        }

        pub fn setNonceWithSnapshot(self: *Self, addr: primitives.Address, new_nonce: u64) !void {
            for (self.nonce_snapshot_stack.items) |snapshot| {
                if (!snapshot.contains(addr)) {
                    const current_nonce = if (self.host) |h|
                        h.getNonce(addr)
                    else
                        self.nonces.get(addr) orelse 0;
                    try snapshot.put(addr, current_nonce);
                }
            }

            const observer = self.inspector;
            const track_before = observer != null or self.bal_recorder != null;
            const before = if (track_before) self.peekNonce(addr) else 0;
            if (self.pending_storage_injector) |injector| {
                if (!injector.baseline_active) try injector.markNonceDirty(addr);
            }
            if (self.host) |h| {
                h.setNonce(addr, new_nonce);
            } else if (new_nonce == 0) {
                _ = self.nonces.remove(addr);
            } else {
                try self.nonces.put(addr, new_nonce);
            }
            if (observer) |sink| {
                @branchHint(.unlikely);
                if (before != new_nonce) sink.onNonceChange(.{
                    .frame_id = self.activeFrameId(),
                    .address = addr,
                    .prev_nonce = before,
                    .new_nonce = new_nonce,
                });
            }
            if (self.balHook()) |*hook| {
                @branchHint(.unlikely);
                try hook.nonceChange(addr.bytes, before, new_nonce);
            }
        }

        pub fn setCodeWithSnapshot(self: *Self, addr: primitives.Address, new_code: []const u8) !void {
            for (self.code_snapshot_stack.items) |snapshot| {
                if (!snapshot.contains(addr)) {
                    // Snapshot the account's own code. Following an EIP-7702 designator here
                    // would restore the delegate's code into the delegating account.
                    const current_code = self.get_raw_code(addr);
                    // A host may free its slice when the code is replaced; hostless code slices
                    // are immutable and long-lived.
                    const current_copy = if (current_code.len > 0 and self.host != null)
                        try self.arena.allocator().dupe(u8, current_code)
                    else
                        current_code;
                    try snapshot.put(addr, current_copy);
                }
            }

            const bal_changed = if (self.bal_recorder != null)
                !std.mem.eql(u8, self.peekRawCode(addr), new_code)
            else
                false;
            const previous = if (self.inspector) |sink| blk: {
                if (sink.vtable.onCodeChange == null) break :blk null;
                const old_code = self.peekRawCode(addr);
                if (std.mem.eql(u8, old_code, new_code)) break :blk null;
                break :blk try self.allocator.dupe(u8, old_code);
            } else null;
            defer if (previous) |bytes| self.allocator.free(bytes);
            if (self.pending_storage_injector) |injector| {
                if (!injector.baseline_active) try injector.markCodeDirty(addr);
            }
            try self.writeCodeRaw(addr, new_code, true);
            if (previous) |bytes| self.inspector.?.onCodeChange(.{
                .frame_id = self.activeFrameId(),
                .address = addr,
                .prev_code = bytes,
                .new_code = self.peekRawCode(addr),
            });
            if (bal_changed) {
                if (self.bal_recorder) |rec| {
                    @branchHint(.unlikely);
                    try rec.recordCodeChange(self.bal_index, addr.bytes, self.peekRawCode(addr));
                }
            }
        }

        /// Write account code without journaling. `copy` duplicates the bytes into the
        /// long-lived arena for the hostless map (hosts own their copy).
        fn writeCodeRaw(self: *Self, addr: primitives.Address, bytes: []const u8, copy: bool) !void {
            if (self.host) |h| {
                h.setCode(addr, bytes);
            } else if (bytes.len == 0) {
                _ = self.code.remove(addr);
            } else {
                const stored = if (copy) try self.arena.allocator().dupe(u8, bytes) else bytes;
                try self.code.put(addr, stored);
            }
        }

        fn writeBalanceRaw(self: *Self, addr: primitives.Address, balance: u256) !void {
            if (self.host) |h| {
                h.setBalance(addr, balance);
            } else if (balance == 0 and self.storage.storage_injector != null) {
                // Injector mode: a zero pre-image may be an account whose balance was never
                // fetched. Leaving an explicit zero would make it look locally known; without
                // an entry it reads as zero when fetched (`async_known`) and is requested from
                // the host otherwise.
                _ = self.balances.remove(addr);
            } else {
                try self.balances.put(addr, balance);
            }
        }

        fn writeNonceRaw(self: *Self, addr: primitives.Address, nonce: u64) !void {
            if (self.host) |h| {
                h.setNonce(addr, nonce);
            } else if (nonce == 0) {
                _ = self.nonces.remove(addr);
            } else {
                try self.nonces.put(addr, nonce);
            }
        }

        /// Move `value` wei from `from` to `to` through the balance journal.
        /// Reads the recipient after debiting the sender, so a self-transfer is a no-op.
        pub fn transferValue(self: *Self, from: primitives.Address, to: primitives.Address, value: u256) errors.CallError!void {
            const from_balance = self.get_balance(from);
            if (from_balance < value) return error.InsufficientBalance;
            try self.setBalanceWithSnapshot(from, from_balance - value);
            const to_balance = self.get_balance(to);
            // A credit that overflows u256 cannot occur with a real supply; fail the message.
            const credited = std.math.add(u256, to_balance, value) catch return error.StorageError;
            try self.setBalanceWithSnapshot(to, credited);
            if (hardfork_hooks.supportsEthTransferLogs(self.hardfork)) {
                try self.emitEthTransferLog(from, to, value);
            }
        }

        /// Record `addr` as touched (EIP-161). Journaled so a reverted message un-touches it.
        pub fn touchAccount(self: *Self, addr: primitives.Address) !void {
            const entry = try self.touched_accounts.getOrPut(addr);
            if (entry.found_existing) return;
            self.touched_journal.append(self.tx_arena.allocator(), addr) catch |err| {
                _ = self.touched_accounts.remove(addr);
                return err;
            };
        }

        pub fn touchCallTarget(self: *Self, addr: primitives.Address) !void {
            try self.touchAccount(addr);

            // Before EIP-161, a successful zero-value CALL to an otherwise empty
            // account leaves that empty account in the state trie.
            if (self.hardfork.isBefore(.SPURIOUS_DRAGON)) {
                if (self.host) |h| {
                    try self.setBalanceWithSnapshot(addr, h.getBalance(addr));
                } else if (!self.balances.contains(addr)) {
                    try self.setBalanceWithSnapshot(addr, 0);
                }
            }
        }

        pub fn accountIsEmpty(self: *Self, addr: primitives.Address) bool {
            const balance = self.get_balance(addr);
            const nonce = self.getNonce(addr);
            // Raw code: an account holding an EIP-7702 designator is not empty even when its
            // delegate has no code.
            return balance == 0 and nonce == 0 and self.get_raw_code(addr).len == 0;
        }

        /// Hostless: an account exists when it has a balance, a nonce, code or a non-zero
        /// storage slot. Zero-valued storage entries (cleared slots, or slots the async overlay
        /// holds explicitly) do not make an account exist.
        pub fn accountExists(self: *Self, addr: primitives.Address) bool {
            if (self.host) |h| return h.accountExists(addr);
            if (self.balances.contains(addr) or self.nonces.contains(addr) or self.code.contains(addr)) return true;
            if (self.get_balance(addr) != 0 or self.getNonce(addr) != 0 or self.get_raw_code(addr).len != 0) return true;
            return self.accountHasStorage(addr);
        }

        /// EIP-7610: whether `addr` currently has any non-zero storage slot.
        pub fn accountHasStorage(self: *Self, addr: primitives.Address) bool {
            if (self.host) |h| return h.accountHasStorage(addr);
            var storage_it = self.storage.storage.iterator();
            while (storage_it.next()) |entry| {
                if (entry.value_ptr.* != 0 and std.mem.eql(u8, &entry.key_ptr.*.address, &addr.bytes)) return true;
            }
            return false;
        }

        fn deleteAccountState(self: *Self, addr: Address) void {
            if (self.inspector) |sink| {
                const id = self.activeFrameId();
                const balance = self.peekBalance(addr);
                const nonce = self.peekNonce(addr);
                const code = self.peekRawCode(addr);
                if (balance != 0) sink.onBalanceChange(.{ .frame_id = id, .address = addr, .prev_balance = balance, .new_balance = 0 });
                if (nonce != 0) sink.onNonceChange(.{ .frame_id = id, .address = addr, .prev_nonce = nonce, .new_nonce = 0 });
                // A host may release its code bytes in deleteAccount.
                if (code.len != 0) sink.onCodeChange(.{ .frame_id = id, .address = addr, .prev_code = code, .new_code = &.{} });
            }
            if (self.host) |h| {
                h.deleteAccount(addr);
            } else {
                var storage_it = self.storage.storage.iterator();
                while (storage_it.next()) |storage_entry| {
                    const key = storage_entry.key_ptr.*;
                    if (std.mem.eql(u8, &key.address, &addr.bytes)) {
                        _ = self.storage.storage.fetchRemove(key);
                    }
                }
                var original_storage_it = self.storage.original_storage.iterator();
                while (original_storage_it.next()) |storage_entry| {
                    const key = storage_entry.key_ptr.*;
                    if (std.mem.eql(u8, &key.address, &addr.bytes)) {
                        _ = self.storage.original_storage.fetchRemove(key);
                    }
                }
                _ = self.balances.fetchRemove(addr);
                _ = self.code.fetchRemove(addr);
                _ = self.nonces.fetchRemove(addr);
            }
        }

        /// Nonce and code as held right now (host or local map), never requesting async data.
        fn peekNonce(self: *Self, addr: primitives.Address) u64 {
            if (self.host) |h| return h.getNonce(addr);
            return self.nonces.get(addr) orelse 0;
        }

        fn peekRawCode(self: *Self, addr: primitives.Address) []const u8 {
            if (self.host) |h| return h.getCode(addr);
            return self.code.get(addr) orelse &[_]u8{};
        }

        fn peekBalance(self: *Self, addr: primitives.Address) u256 {
            if (self.host) |h| return h.getBalance(addr);
            return self.balances.get(addr) orelse 0;
        }

        /// Drop a locally held, existing-but-empty destination before a creation. Works on
        /// the data at hand: it only tidies local entries, so it never requests async data.
        fn clearExistingEmptyAccountForCreate(self: *Self, addr: primitives.Address) void {
            const is_empty = self.peekBalance(addr) == 0 and self.peekNonce(addr) == 0 and self.peekRawCode(addr).len == 0;
            if (!is_empty) return;
            const exists = if (self.host) |h| h.accountExists(addr) else self.accountHasStorage(addr);
            if (!exists) return;
            self.deleteAccountState(addr);
        }

        /// EIP-161: delete every account touched by the transaction that is empty at its end.
        fn cleanup_touched_empty_accounts_end_of_tx(self: *Self) void {
            if (self.hardfork.isBefore(.SPURIOUS_DRAGON)) return;

            var it = self.touched_accounts.iterator();
            while (it.next()) |entry| {
                const addr = entry.key_ptr.*;
                // EELS `destroy_touched_empty_accounts` has no precompile exemption: an empty
                // account that happens to sit at a precompile address is deleted like any other.
                if (self.accountIsEmpty(addr)) {
                    self.deleteAccountState(addr);
                }
            }
        }

        /// Pre-warm addresses for transaction initialization
        pub fn pre_warm_addresses(self: *Self, addresses: []const primitives.Address) !void {
            try self.access_list_manager.pre_warm_addresses(addresses);
        }

        /// Get nonce for an address
        pub fn getNonce(self: *Self, address: primitives.Address) u64 {
            if (self.host) |h| {
                return h.getNonce(address);
            }
            if (self.nonces.get(address)) |nonce| return nonce;
            self.noteAccountMiss(.nonce, address);
            return 0;
        }

        /// Compute CREATE address: keccak256(rlp([sender, nonce]))[12:]
        ///
        /// Calculates the address for a new contract created via CREATE opcode or
        /// contract creation transaction. Uses RLP encoding of [sender_address, nonce]
        /// and takes the last 20 bytes of the keccak256 hash.
        ///
        /// Parameters:
        ///   - sender: Address of the account creating the contract
        ///   - nonce: Nonce value of the sender at creation time
        ///
        /// Returns: The computed contract address
        ///
        /// Errors:
        ///   - OutOfMemory: If RLP buffer allocation fails
        pub fn computeCreateAddress(self: *Self, sender: primitives.Address, nonce: u64) !primitives.Address {
            _ = self;
            // RLP encoding of [sender (20 bytes), nonce]
            // For simplicity, use a fixed buffer (max size for nonce encoding is small)
            var buffer: [64]u8 = undefined;
            var fbs = std.io.fixedBufferStream(&buffer);
            const writer = fbs.writer();

            // Calculate nonce encoding length
            const nonce_len: usize = blk: {
                if (nonce == 0) break :blk 1;
                if (nonce < 128) break :blk 1;
                var n = nonce;
                var len: usize = 0;
                while (n > 0) : (n >>= 8) {
                    len += 1;
                }
                break :blk len + 1; // +1 for length prefix
            };

            // RLP list prefix
            const list_len = 21 + nonce_len;
            try writer.writeByte(0xc0 + @as(u8, @intCast(list_len)));

            // RLP encode sender address (20 bytes, so 0x80 + 20 = 0x94)
            try writer.writeByte(0x94);
            try writer.writeAll(&sender.bytes);

            // RLP encode nonce
            if (nonce == 0) {
                try writer.writeByte(0x80);
            } else if (nonce < 128) {
                try writer.writeByte(@intCast(nonce));
            } else {
                var nonce_bytes: [8]u8 = undefined;
                std.mem.writeInt(u64, &nonce_bytes, nonce, .big);
                var start: usize = 0;
                while (start < 8 and nonce_bytes[start] == 0) : (start += 1) {}
                const nonce_byte_len = 8 - start;
                try writer.writeByte(0x80 + @as(u8, @intCast(nonce_byte_len)));
                try writer.writeAll(nonce_bytes[start..]);
            }

            const rlp_data = fbs.getWritten();

            // Compute keccak256 hash
            var hash: [32]u8 = undefined;
            std.crypto.hash.sha3.Keccak256.hash(rlp_data, &hash, .{});

            // Take last 20 bytes as address
            var addr: primitives.Address = undefined;
            @memcpy(&addr.bytes, hash[12..32]);
            return addr;
        }

        /// Compute CREATE2 address: keccak256(0xff ++ sender ++ salt ++ keccak256(init_code))[12:]
        pub fn computeCreate2Address(self: *Self, sender: primitives.Address, salt: u256, init_code: []const u8) !primitives.Address {
            _ = self;
            // Compute keccak256(init_code)
            var init_code_hash: [32]u8 = undefined;
            std.crypto.hash.sha3.Keccak256.hash(init_code, &init_code_hash, .{});

            // Compute keccak256(0xff ++ sender ++ salt ++ init_code_hash)
            var buffer: [85]u8 = undefined; // 1 + 20 + 32 + 32
            buffer[0] = 0xff;
            @memcpy(buffer[1..21], &sender.bytes);

            // Convert salt to bytes (big-endian)
            var salt_bytes: [32]u8 = undefined;
            std.mem.writeInt(u256, &salt_bytes, salt, .big);
            @memcpy(buffer[21..53], &salt_bytes);

            @memcpy(buffer[53..85], &init_code_hash);

            var hash: [32]u8 = undefined;
            std.crypto.hash.sha3.Keccak256.hash(&buffer, &hash, .{});

            // Take last 20 bytes as address
            var addr: primitives.Address = undefined;
            @memcpy(&addr.bytes, hash[12..32]);
            return addr;
        }

        /// EIP-2929: mark every precompile active at `self.hardfork` as warm.
        ///
        /// Derived dynamically from `isPrecompileAddress` so the warm set tracks Voltaire's
        /// EIP-2537 BLS12-381 table (whether 0x0b..0x13 or 7-op 0x0b..0x11) and includes
        /// Osaka+ EIP-7951 P256VERIFY at 0x0100.
        fn preWarmPrecompiles(self: *Self) errors.CallError!void {
            if (!self.hardfork.isAtLeast(.BERLIN)) {
                self.access_list_manager.precompile_hardfork = null;
                return;
            }
            self.access_list_manager.precompile_hardfork = self.hardfork;
        }

        /// Warm the transaction participants: origin, `target` (every real destination,
        /// including the zero address) and, from Shanghai, the coinbase.
        pub fn preWarmParticipants(self: *Self, target: primitives.Address) errors.CallError!void {
            if (self.bal_recorder) |rec| {
                @branchHint(.unlikely);
                try rec.recordAddressAccess(self.origin.bytes);
                try rec.recordAddressAccess(target.bytes);
            }
            if (!self.hardfork.isAtLeast(.BERLIN)) return;

            var warm: [3]primitives.Address = undefined;
            var count: usize = 0;

            warm[count] = self.origin;
            count += 1;

            warm[count] = target;
            count += 1;

            if (self.hardfork.isAtLeast(.SHANGHAI)) {
                @branchHint(.likely);
                warm[count] = self.block_context.block_coinbase;
                count += 1;
            }

            try self.pre_warm_addresses(warm[0..count]);
        }

        /// Pre-warm addresses at transaction start (EIP-2929, EIP-3651)
        ///
        /// Marks origin, target, coinbase (Shanghai+), and all active precompiles
        /// (via `isPrecompileAddress`) as warm. Idempotent when called after `initTransactionState`.
        /// Pre-Berlin: No-op.
        pub fn preWarmTransaction(self: *Self, target: primitives.Address) errors.CallError!void {
            try self.preWarmParticipants(target);
            try self.preWarmPrecompiles();
        }

        /// Set bytecode for the next call() invocation
        pub fn setBytecode(self: *Self, bytecode: []const u8) void {
            self.pending_bytecode = bytecode;
        }

        /// Set access list for the next call() invocation
        pub fn setAccessList(self: *Self, access_list: ?primitives.AccessList.AccessList) void {
            self.pending_access_list = access_list;
        }

        /// Set blob versioned hashes for the next call() invocation
        pub fn setBlobVersionedHashes(self: *Self, hashes: []const [32]u8) void {
            self.blob_versioned_hashes = hashes;
        }

        /// Execute one transaction-level message (the main entry point).
        ///
        /// `gas` is execution gas: the caller charges intrinsic gas and applies refunds. State
        /// installed before the call is preserved; on REVERT or an exceptional halt every state
        /// change made by the message, including the value transfer, is rolled back.
        ///
        /// Inputs registered with `setBytecode`, `setAccessList` and `setBlobVersionedHashes`
        /// apply to this call only and are cleared when it returns. `setBytecode` supplies the
        /// code for a target that has none installed. On a hostless EVM that code is also the
        /// target's account code while the call runs, so EXTCODE* and re-entrant calls see it,
        /// exactly as on the async entry point; it is removed again when the call returns.
        /// `gas_refund` stays readable after the call and is reset when the next transaction
        /// starts.
        ///
        /// The result's buffers come from `result_allocator`, or from the long-lived arena
        /// when none is set.
        ///
        /// CREATE convention: like `inner_create` at depth 0, the transaction processor has
        /// already incremented the sender nonce, so the address derives from `nonce - 1`.
        pub fn call(self: *Self, params: CallParams) CallResult {
            return self.callWithBytecodeOverride(params, null);
        }

        pub fn callWithBytecodeOverride(
            self: *Self,
            params: CallParams,
            bytecode: ?[]const u8,
        ) CallResult {
            const access_list = self.pending_access_list;
            const pending_bytecode = self.pending_bytecode;
            self.pending_access_list = null;
            self.pending_bytecode = &[_]u8{};
            defer self.finishTransaction();
            // The supplied code is account code for this call only (see `installCallCodeView`).
            // Only this call's borrowed view is dropped here: a call rejected before it
            // starts a transaction must leave a suspended async transaction's view alone.
            defer if (self.async_code_view) |view| {
                if (!view.owned) self.releaseAsyncCodeView();
            };

            if (self.async_executor) |*executor| executor.cancel();
            if (self.inspector) |sink| self.notifyTxStart(sink, params, self.transactionTarget(params), callValue(params));
            const result = self.executeTransaction(params, access_list, pending_bytecode, bytecode);
            if (self.inspector) |sink| notifyTxEnd(sink, params.getGas(), result);
            return result;
        }

        fn notifyTxStart(self: *Self, sink: inspector_mod.Inspector, params: CallParams, target: Address, value: u256) void {
            sink.onTxStart(.{
                .hardfork = self.getActiveFork(),
                .origin = self.origin,
                .target = target,
                .coinbase = self.block_context.block_coinbase,
                .is_create = params.isCreate(),
                .value = value,
                .gas_limit = params.getGas(),
                .gas_price = self.gas_price,
                .input = params.getInput(),
                .block_number = self.block_context.block_number,
                .block_timestamp = self.block_context.block_timestamp,
                .chain_id = self.block_context.chain_id,
                .blob_base_fee = self.block_context.blob_base_fee,
                .blob_hash_count = self.blob_versioned_hashes.len,
            });
        }

        fn notifyTxEnd(sink: inspector_mod.Inspector, gas_limit: u64, result: CallResult) void {
            sink.onTxEnd(.{
                .success = result.success,
                .gas_used = gas_limit -| result.gas_left,
                .gas_left = result.gas_left,
                .gas_refund = result.refund_counter,
                .output = result.output,
                .error_name = resultErrorName(result),
                .created_address = result.created_address,
            });
        }

        fn callValue(params: CallParams) u256 {
            return switch (params) {
                .call => |p| p.value,
                .callcode => |p| p.value,
                .create => |p| p.value,
                .create2 => |p| p.value,
                .delegatecall => |p| p.value,
                .staticcall => 0,
            };
        }

        pub fn transactionTarget(self: *Self, params: CallParams) Address {
            if (params.get_to()) |address| return address;
            const caller = params.getCaller();
            if (params == .create2) return self.computeCreate2Address(caller, params.create2.salt, params.getInput()) catch primitives.ZERO_ADDRESS;
            return self.computeCreateAddress(caller, self.peekNonce(caller) -| 1) catch primitives.ZERO_ADDRESS;
        }

        fn failedResult(gas_left: u64) CallResult {
            return CallResult{ .success = false, .gas_left = gas_left, .output = &.{} };
        }

        /// Roll back to `cp`, logging (not hiding) a rollback that itself fails.
        fn revertBestEffort(self: *Self, cp: *const Checkpoint) void {
            self.revertToCheckpoint(cp) catch |err| {
                log.err("EVM: state rollback failed: {s}", .{@errorName(err)});
            };
        }

        /// Roll back to `cp` and report a failed message that consumed all of its gas.
        fn failAndRevert(self: *Self, cp: *const Checkpoint) CallResult {
            self.revertBestEffort(cp);
            return failedResult(0);
        }

        /// Roll back to `cp` and report a failed message with preserved error metadata.
        fn failAndRevertWithError(self: *Self, cp: *const Checkpoint, err: anyerror) CallResult {
            self.revertBestEffort(cp);
            return self.failed(0, err);
        }

        fn executeTransaction(
            self: *Self,
            params: CallParams,
            access_list: ?primitives.AccessList.AccessList,
            pending_bytecode: []const u8,
            bytecode_override: ?[]const u8,
        ) CallResult {
            const result_alloc = self.result_allocator orelse self.arena.allocator();

            const target = params.get_to();
            const initial_reservoir = self.pending_state_gas_reservoir;
            self.pending_state_gas_reservoir = 0;

            // Validate parameters
            validateCallParamsForHardfork(params, self.getActiveFork()) catch |err| return self.failed(0, err);

            const caller = params.getCaller();
            const gas = params.getGas();
            const calldata = params.getInput();
            const blob_versioned_hashes: ?[]const [32]u8 = if (self.blob_versioned_hashes.len > 0) self.blob_versioned_hashes else null;

            // Initialize transaction state (warms active precompiles on Berlin+ in O(1)
            // and defers reserving the 1025-frame array until EVM bytecode actually runs).
            self.initTransactionStateInternal(blob_versioned_hashes, false) catch |err| return self.failed(0, err);
            self.state_gas_reservoir = if (hardfork_hooks.supportsStateGas(self.hardfork)) initial_reservoir else 0;

            // Pre-warm access list (EIP-2929/EIP-2930)
            if (access_list) |list| {
                self.access_list_manager.pre_warm_from_access_list(list) catch |err| return self.failed(0, err);
            }

            if (params.isCreate()) {
                // The new address is warmed by the create itself, from the single derivation.
                self.preWarmParticipants(caller) catch |err| return self.failed(0, err);

                const create_value: u256 = switch (params) {
                    .create => |p| p.value,
                    .create2 => |p| p.value,
                    else => 0,
                };
                const salt: ?u256 = switch (params) {
                    .create2 => |p| p.salt,
                    else => null,
                };
                // The creation commits only once the result is owned by the caller: a failure
                // while building it must not leave the new contract behind a failed result.
                var create_cp: Checkpoint = undefined;
                self.takeCheckpoint(&create_cp) catch |err| return self.failed(0, err);
                defer self.releaseCheckpoint(&create_cp);

                const created = self.createFrom(caller, create_value, calldata, gas, salt, true) catch |err| {
                    return self.failAndRevertWithError(&create_cp, err);
                };
                if (!created.success) {
                    if (created.err) |err| return self.failed(created.gas_left, err);
                    return CallResult.revert_with_data(result_alloc, created.gas_left, created.output) catch |err| return self.failed(created.gas_left, err);
                }

                var result = CallResult.success_with_logs(result_alloc, created.gas_left, &.{}, self.logs.items) catch |err| {
                    return self.failAndRevertWithError(&create_cp, err);
                };
                result.refund_counter = self.get_effective_refund();
                result.created_address = created.address;
                self.commitTransaction();
                return result;
            }

            // Message call. One builder for every public variant:
            //   CALL / STATICCALL: code and storage of `to`; STATICCALL is read-only.
            //   CALLCODE / DELEGATECALL: code of `to` in the caller's storage; no transfer.
            const address = target.?;
            // CALLVALUE of the frame. DELEGATECALL carries the value it inherits (EIP-7); it is
            // visible to the code but never checked against a balance or transferred.
            const value: u256 = switch (params) {
                .call => |p| p.value,
                .callcode => |p| p.value,
                .delegatecall => |p| p.value,
                else => 0,
            };
            const is_static = params == .staticcall;
            const execution_address = switch (params) {
                .callcode, .delegatecall => caller,
                else => address,
            };

            self.preWarmParticipants(address) catch |err| return self.failed(0, err);

            var resolved = if (bytecode_override) |bytes| self.resolveCodeBytes(address, bytes) else self.resolveCallCode(address);
            if (bytecode_override == null and !resolved.is_delegated and resolved.code.len == 0 and pending_bytecode.len != 0 and
                (!Self.isPrecompileAddress(address, self.hardfork) or self.getPrecompileOverride(address) != null))
            {
                if (self.suppliedCodeIsAccountCode(address, pending_bytecode))
                    self.installCallCodeView(address, pending_bytecode) catch |err| return self.failed(0, err);
                resolved = self.resolveCodeBytes(address, pending_bytecode);
            }
            if (resolved.is_delegated) self.pre_warm_addresses(&.{resolved.address}) catch |err| return self.failed(0, err);
            const observed = self.enterCall(params, caller, resolved, value, is_static);
            const result = self.executeTopMessage(params, resolved, observed, execution_address);
            if (observed) |frame| self.exitFrame(frame, result, resultErrorName(result));
            return result;
        }

        fn executeTopMessage(self: *Self, params: CallParams, resolved: ResolvedCode, observed: ?ObservedFrame, execution_address: Address) CallResult {
            const result_alloc = self.result_allocator orelse self.arena.allocator();
            const bytecode = resolved.code;
            const address = params.get_to().?;
            const value = callValue(params);
            const gas = params.getGas();
            const caller = params.getCaller();
            const calldata = params.getInput();
            const transfers_value = params == .call;
            const requires_balance = transfers_value or params == .callcode;
            const is_static = params == .staticcall;
            // Everything from here is rolled back on REVERT or an exceptional halt.
            var cp: Checkpoint = undefined;
            self.takeCheckpoint(&cp) catch |err| return self.failed(0, err);
            defer self.releaseCheckpoint(&cp);

            if (value > 0 and requires_balance) {
                if (self.get_balance(caller) < value) return self.failed(0, error.InsufficientBalance);
                if (transfers_value) {
                    self.transferValue(caller, address, value) catch |err| return self.failAndRevertWithError(&cp, err);
                }
            }

            // Note: intrinsic gas is deducted by the caller before this function runs.

            if (bytecode.len == 0) {
                var gas_left = gas;
                var output: []const u8 = &[_]u8{};
                switch (if (resolved.is_delegated) PrecompileOutcome.none else self.runPrecompile(result_alloc, address, calldata, gas, Self.isPrecompileAddress(address, self.hardfork))) {
                    .failure => |err| {
                        self.revertBestEffort(&cp);
                        return self.failed(0, err);
                    },
                    .success => |done| {
                        gas_left = done.gas_left;
                        output = done.output;
                    },
                    // A plain account without code: the call succeeds with no output.
                    .none => {},
                }
                if (transfers_value) {
                    self.touchCallTarget(address) catch |err| return self.failAndRevertWithError(&cp, err);
                }
                if (self.logs.items.len > 0) {
                    var result = CallResult.success_with_logs(
                        result_alloc,
                        gas_left,
                        output,
                        self.logs.items,
                    ) catch |err| return self.failAndRevertWithError(&cp, err);
                    result.refund_counter = self.get_effective_refund();
                    self.commitTransaction();
                    return result;
                }
                self.commitTransaction();
                return CallResult{
                    .success = true,
                    .gas_left = gas_left,
                    .output = output,
                    .refund_counter = self.get_effective_refund(),
                };
            }

            // Gas above i64::MAX cannot be spent; cap instead of trapping on the cast.
            const frame_gas = std.math.cast(i64, gas) orelse std.math.maxInt(i64);
            if (!self.canPushFrame()) return self.failAndRevertWithError(&cp, error.OutOfMemory);
            const initial_reservoir = self.state_gas_reservoir;
            var top_frame = FrameType.initLazy(
                self.tx_arena.allocator(),
                bytecode,
                frame_gas,
                caller,
                execution_address,
                value,
                calldata,
                @as(*anyopaque, @ptrCast(self)),
                self.hardfork,
                is_static,
            ) catch |err| return self.failAndRevertWithError(&cp, err);
            top_frame.state_gas_reservoir = initial_reservoir;
            self.frames.appendAssumeCapacity(top_frame);
            self.attachFrame(observed, resolved.address);

            self.frames.items[0].execute() catch |err| {
                // Exceptional halt: all gas is consumed and every state change is undone.
                self.applyChildStateGas(null, initial_reservoir, 0, 0, 0, true);
                return self.failAndRevertWithError(&cp, err);
            };

            const frame = &self.frames.items[0];
            const raw_gas_left = @as(u64, @intCast(@max(frame.gas_remaining, 0)));

            if (frame.reverted) {
                const gas_left = raw_gas_left +| frame.state_gas_spilled;
                self.applyChildStateGas(null, initial_reservoir, 0, 0, 0, true);
                self.revertToCheckpoint(&cp) catch |err| return self.failed(0, err);
                return CallResult.revert_with_data(result_alloc, gas_left, frame.output) catch |err| return self.failed(gas_left, err);
            }

            self.applyChildStateGas(
                null,
                initial_reservoir,
                frame.state_gas_reservoir,
                frame.state_gas_spilled,
                frame.state_gas_used,
                false,
            );
            // Gas refunds are not applied here: the caller applies them after computing the
            // gas actually consumed, reading `refund_counter` (or `get_effective_refund()`).
            var result = CallResult.success_with_logs(
                result_alloc,
                raw_gas_left,
                frame.output,
                self.logs.items,
            ) catch |err| {
                return self.failAndRevertWithError(&cp, err);
            };
            result.refund_counter = self.get_effective_refund();
            self.commitTransaction();
            return result;
        }

        /// End-of-transaction effects that apply only when the transaction succeeded:
        /// delete self-destructed accounts (EIP-6780) and touched empty accounts (EIP-161),
        /// then let the injector cache follow the committed storage writes. Never fails.
        pub fn commitTransaction(self: *Self) void {
            self.cleanup_selfdestructed_accounts_end_of_tx();
            self.cleanup_touched_empty_accounts_end_of_tx();
            self.storage.commitInjectorWrites();
        }

        /// Drop everything scoped to the finished transaction so nothing leaks into the next
        /// call on this instance. Runs on every exit path. `gas_refund` is left readable.
        pub fn finishTransaction(self: *Self) void {
            self.access_list_manager.clear();
            self.storage.clear_transient();
            self.logs.clearRetainingCapacity();
            self.frames.clearRetainingCapacity();
            self.code_cache.reclaimEvicted(self.allocator);
            self.created_accounts.clearRetainingCapacity();
            self.selfdestructed_accounts.clearRetainingCapacity();
            self.touched_accounts.clearRetainingCapacity();
            self.touched_journal.clearRetainingCapacity();
            self.pending_access_list = null;
            self.pending_bytecode = &[_]u8{};
            self.pending_state_gas_reservoir = 0;
            self.blob_hashes_owned.clearRetainingCapacity();
            self.blob_versioned_hashes = &[_][32]u8{};
        }

        /// Shared precompile dispatch for top-level and nested calls: JavaScript handler,
        /// then configured override, then the standard precompile when `is_standard`.
        /// A handler that reports failure, or more gas than it was given, fails the call.
        pub fn runPrecompile(
            self: *Self,
            out_alloc: std.mem.Allocator,
            address: primitives.Address,
            input: []const u8,
            gas: u64,
            is_standard: bool,
        ) PrecompileOutcome {
            const root_c = @import("root_c.zig");
            var output_len: usize = 0;
            var output_ptr: [*]u8 = undefined;
            var js_gas_used: u64 = 0;

            if (root_c.tryCallJsPrecompileHandler(
                &address.bytes,
                input.ptr,
                input.len,
                gas,
                &output_len,
                &output_ptr,
                &js_gas_used,
            )) {
                if (js_gas_used > gas) return .{ .failure = error.OutOfGas };
                // Copy out of the handler's buffer, which it may reuse on the next call.
                const output: []const u8 = if (output_len > 0)
                    out_alloc.dupe(u8, output_ptr[0..output_len]) catch |err| return .{ .failure = err }
                else
                    &[_]u8{};
                return .{ .success = .{ .gas_left = gas - js_gas_used, .output = output } };
            }

            if (self.getPrecompileOverride(address)) |override| {
                const result = override.execute(override.context, out_alloc, input, gas) catch |err| return .{ .failure = err };
                if (!result.success) return .{ .failure = error.PrecompileError };
                if (result.gas_used > gas) return .{ .failure = error.OutOfGas };
                return .{ .success = .{ .gas_left = gas - result.gas_used, .output = result.output } };
            }

            if (is_standard) {
                const result = executePrecompile(out_alloc, address, input, gas, self.hardfork) catch |err| return .{ .failure = err };
                if (result.gas_used > gas) return .{ .failure = error.OutOfGas };
                return .{ .success = .{ .gas_left = gas - result.gas_used, .output = result.output } };
            }

            return .none;
        }

        /// Asynchronous entry point: start a transaction or continue a suspended one.
        ///
        /// Every variant (calls to code, precompiles and overrides, CREATE and CREATE2) runs
        /// through the one `AsyncExecutor`, which owns the root checkpoint, the single pending
        /// request and the single pending commit acknowledgement. See `async_executor.zig`.
        pub fn callOrContinue(
            self: *Self,
            input: CallOrContinueInput,
        ) !CallOrContinueOutput {
            if (self.async_executor == null) {
                self.async_executor = AsyncExecutorType.init(self);
            }
            return try self.async_executor.?.callOrContinue(input);
        }

        pub fn executeUntilYieldOrComplete(self: *Self) !CallOrContinueOutput {
            if (self.async_executor) |*executor| return executor.poll();
            return error.InvalidAsyncState;
        }

        pub fn finalizeAndReturnResult(self: *Self) !CallOrContinueOutput {
            return self.callOrContinue(.{ .continue_after_commit = {} });
        }

        pub fn startAsyncObservation(self: *Self, params: CallParams, target: Address, bytecode: []const u8) void {
            if (self.inspector == null) return;
            self.beginAsyncObservation(params, target);
            self.async_observation = self.enterCall(params, params.getCaller(), self.resolveCodeBytes(target, bytecode), callValue(params), params == .staticcall);
        }

        pub fn beginAsyncObservation(self: *Self, params: CallParams, target: Address) void {
            const sink = self.inspector orelse return;
            self.async_observed_gas = params.getGas();
            self.notifyTxStart(sink, params, target, callValue(params));
        }

        pub fn enterAsyncCall(self: *Self, kind: inspector_mod.CallType, caller: Address, target: Address, resolved: ResolvedCode, input: []const u8, value: u256, gas: u64) void {
            if (self.async_observation == null)
                self.async_observation = self.observeCall(kind, caller, target, resolved, input, value, gas, kind == .staticcall);
        }

        pub fn attachAsyncFrame(self: *Self, address: Address) void {
            self.attachFrame(self.async_observation, address);
        }

        pub fn finishAsyncObservation(self: *Self, result: CallResult) void {
            const gas = self.async_observed_gas orelse return;
            self.async_observed_gas = null;
            if (self.async_observation) |frame| self.exitFrame(frame, result, resultErrorName(result));
            self.async_observation = null;
            if (self.inspector) |sink| notifyTxEnd(sink, gas, result);
        }

        /// Dump state changes to JSON into a heap-allocated owned slice on `self`
        /// (freed on the next dump, transaction init, or `deinit()`). Never truncates.
        pub fn dumpStateChanges(self: *Self) ![]const u8 {
            // Release any previous dump first so a failed dump never leaves stale changes behind.
            self.freePendingStateChanges();

            const injector = self.storage.storage_injector orelse {
                log.debug("dumpStateChanges: No injector, returning empty", .{});
                return &.{};
            };
            const raw = try injector.dumpChanges(self);
            defer injector.allocator.free(raw);
            log.debug("dumpStateChanges: Got {} bytes from injector", .{raw.len});
            if (raw.len == 0) return &.{};

            self.pending_state_changes_buffer = try self.allocator.dupe(u8, raw);
            self.pending_state_changes = self.pending_state_changes_buffer;
            return self.pending_state_changes;
        }

        /// First half of a commit dump that cannot fail past the commit point (R3-009).
        ///
        /// Call while the transaction can still be rolled back, before `commitTransaction`.
        /// Does every fallible step: marks the changed accounts and reserves the buffer the
        /// final JSON is written into. `commitTransaction` only deletes accounts, which can
        /// only shorten the JSON (a value becomes `0x0`, code becomes empty), so the size
        /// measured here bounds the final one. Finish with `writePreparedStateChanges`.
        /// On error nothing is reserved and no state changed.
        pub fn prepareStateChanges(self: *Self) !void {
            self.freePendingStateChanges();
            const injector = self.storage.storage_injector orelse return;
            try injector.markChangedAccounts(self);

            var counter = storage_injector.CountingWriter{};
            try injector.writeChanges(self, counter.writer());
            self.pending_state_changes_buffer = try self.allocator.alloc(u8, counter.bytes_written);
        }

        /// Second half: serialize the committed state into the buffer reserved by
        /// `prepareStateChanges`. Allocates nothing. Returns the JSON, owned like the result
        /// of `dumpStateChanges`; empty without an injector.
        pub fn writePreparedStateChanges(self: *Self) ![]const u8 {
            const injector = self.storage.storage_injector orelse return &.{};
            var fixed = storage_injector.FixedWriter{ .buffer = self.pending_state_changes_buffer };
            // `error.NoSpaceLeft` would mean a commit made the JSON longer, which deletions
            // cannot do; it is reported, never truncated.
            try injector.writeChanges(self, fixed.writer());
            self.pending_state_changes = fixed.written();
            return self.pending_state_changes;
        }

        /// Delete accounts marked via SELFDESTRUCT at end of transaction (EIP-6780).
        /// On Amsterdam+ (EIP-8246), clears code, nonce, and storage while preserving
        /// any remaining balance (deleting the account only if its balance is zero).
        fn cleanup_selfdestructed_accounts_end_of_tx(self: *Self) void {
            const no_burn = hardfork_hooks.selfdestructToSelfPolicy(self.hardfork) == .no_burn;
            var it = self.selfdestructed_accounts.iterator();
            while (it.next()) |entry| {
                const addr = entry.key_ptr.*;
                if (no_burn) {
                    self.clearSelfdestructedPreserveBalance(addr);
                } else {
                    self.deleteAccountState(addr);
                }
            }
            // The set is kept until `finishTransaction`: the async commit dump still reports it.
        }

        /// EIP-8246 (Amsterdam+): clear code, nonce, and storage of a same-tx self-destructed
        /// account while keeping any positive balance intact.
        fn clearSelfdestructedPreserveBalance(self: *Self, addr: Address) void {
            const preserved_balance = self.peekBalance(addr);
            if (preserved_balance == 0) {
                self.deleteAccountState(addr);
                return;
            }
            if (self.inspector) |sink| {
                const id = self.activeFrameId();
                const nonce = self.peekNonce(addr);
                const code = self.peekRawCode(addr);
                if (nonce != 0) sink.onNonceChange(.{
                    .frame_id = id,
                    .address = addr,
                    .prev_nonce = nonce,
                    .new_nonce = 0,
                });
                if (code.len != 0) sink.onCodeChange(.{
                    .frame_id = id,
                    .address = addr,
                    .prev_code = code,
                    .new_code = &.{},
                });
            }
            if (self.host) |h| {
                h.deleteAccount(addr);
                h.setBalance(addr, preserved_balance);
                return;
            }
            var storage_it = self.storage.storage.iterator();
            while (storage_it.next()) |storage_entry| {
                const key = storage_entry.key_ptr.*;
                if (std.mem.eql(u8, &key.address, &addr.bytes)) {
                    _ = self.storage.storage.fetchRemove(key);
                }
            }
            var original_storage_it = self.storage.original_storage.iterator();
            while (original_storage_it.next()) |storage_entry| {
                const key = storage_entry.key_ptr.*;
                if (std.mem.eql(u8, &key.address, &addr.bytes)) {
                    _ = self.storage.original_storage.fetchRemove(key);
                }
            }
            _ = self.code.fetchRemove(addr);
            _ = self.nonces.fetchRemove(addr);
        }

        fn currentStorageValue(self: *Self, key: StorageKey) u256 {
            if (self.storage.storage_injector != null) {
                if (self.storage.storage.get(key)) |value| return value;
            }
            if (self.host) |h| return h.getStorage(primitives.Address{ .bytes = key.address }, key.slot);
            return self.storage.storage.get(key) orelse 0;
        }

        fn writeStorageRaw(self: *Self, key: StorageKey, value: u256) !void {
            if (self.host) |h| h.setStorage(primitives.Address{ .bytes = key.address }, key.slot, value);
            if (self.storage.storage_injector != null) {
                // Injector mode reads the overlay first, so a rollback must restore it too,
                // as an explicit entry: a missing entry for a written slot reads as zero
                // (see `Storage.injectedValue`).
                try self.storage.storage.put(key, value);
            } else if (self.host != null) {
                return;
            } else if (value == 0) {
                _ = self.storage.storage.remove(key);
            } else {
                try self.storage.storage.put(key, value);
            }
        }

        /// Open a revert point. `cp` must stay at a fixed address until `releaseCheckpoint`.
        pub fn takeCheckpoint(self: *Self, cp: *Checkpoint) !void {
            const alloc = self.allocator;
            const tx_alloc = self.tx_arena.allocator();

            var access_list = try self.access_list_manager.snapshot();
            errdefer access_list.deinit();

            // Current value of every slot written so far in this transaction.
            var storage_values = SlotMap.init(alloc);
            errdefer storage_values.deinit();
            if (self.storage.original_storage.count() > 0) {
                var written_it = self.storage.original_storage.keyIterator();
                while (written_it.next()) |key| {
                    try storage_values.put(key.*, self.currentStorageValue(key.*));
                }
            }

            var original_storage = if (self.storage.original_storage.count() > 0)
                try self.storage.original_storage.cloneWithAllocator(alloc)
            else
                SlotMap.init(alloc);
            errdefer original_storage.deinit();
            var transient = if (self.storage.transient.count() > 0)
                try self.storage.transient.cloneWithAllocator(alloc)
            else
                SlotMap.init(alloc);
            errdefer transient.deinit();
            var selfdestructed = if (self.selfdestructed_accounts.count() > 0)
                try self.selfdestructed_accounts.cloneWithAllocator(alloc)
            else
                std.AutoHashMap(primitives.Address, void).init(alloc);
            errdefer selfdestructed.deinit();
            var created = if (self.created_accounts.count() > 0)
                try self.created_accounts.cloneWithAllocator(alloc)
            else
                std.AutoHashMap(primitives.Address, void).init(alloc);
            errdefer created.deinit();

            cp.* = .{
                .refund = self.gas_refund,
                .logs_len = self.logs.items.len,
                .touched_len = self.touched_journal.items.len,
                .access_list = access_list,
                .original_storage = original_storage,
                .storage = storage_values,
                .transient = transient,
                .selfdestructed = selfdestructed,
                .created = created,
                .balances = std.AutoHashMap(primitives.Address, u256).init(alloc),
                .nonces = std.AutoHashMap(primitives.Address, u64).init(alloc),
                .code = std.AutoHashMap(primitives.Address, []const u8).init(alloc),
                .bal_snapshot = if (self.bal_recorder) |rec| rec.snapshot() else null,
            };
            errdefer {
                cp.balances.deinit();
                cp.nonces.deinit();
                cp.code.deinit();
            }

            // Register the copy-on-write maps so nested writes record their pre-images here.
            try self.balance_snapshot_stack.append(tx_alloc, &cp.balances);
            errdefer _ = self.balance_snapshot_stack.pop();
            try self.nonce_snapshot_stack.append(tx_alloc, &cp.nonces);
            errdefer _ = self.nonce_snapshot_stack.pop();
            try self.code_snapshot_stack.append(tx_alloc, &cp.code);
        }

        /// Close a revert point (after commit or revert). Checkpoints nest strictly.
        pub fn releaseCheckpoint(self: *Self, cp: *Checkpoint) void {
            _ = self.code_snapshot_stack.pop();
            _ = self.nonce_snapshot_stack.pop();
            _ = self.balance_snapshot_stack.pop();
            cp.code.deinit();
            cp.nonces.deinit();
            cp.balances.deinit();
            cp.created.deinit();
            cp.selfdestructed.deinit();
            cp.transient.deinit();
            cp.storage.deinit();
            cp.original_storage.deinit();
            cp.access_list.deinit();
        }

        /// Restore every piece of mutable state to what it was at `takeCheckpoint`:
        /// refund counter, logs, touched accounts, warm sets, storage, original storage,
        /// transient storage, self-destructed and created sets, balances, nonces and code.
        /// Per EELS `incorporate_child_on_error`, nothing of a failed message survives.
        pub fn revertToCheckpoint(self: *Self, cp: *const Checkpoint) !void {
            self.gas_refund = cp.refund;
            self.logs.shrinkRetainingCapacity(cp.logs_len);

            // EELS `incorporate_child_on_error`: a reverted message un-touches its accounts,
            // except RIPEMD-160 (0x03), which stays touched to preserve mainnet block 2675119.
            var keep_ripemd = false;
            while (self.touched_journal.items.len > cp.touched_len) {
                const addr = self.touched_journal.pop().?;
                if (addr.equals(RIPEMD160_ADDRESS)) {
                    keep_ripemd = true;
                    continue;
                }
                _ = self.touched_accounts.remove(addr);
            }
            if (keep_ripemd) try self.touched_journal.append(self.tx_arena.allocator(), RIPEMD160_ADDRESS);

            // Warm addresses and slots (EIP-2929) propagate to the parent only on success.
            try self.access_list_manager.restore(cp.access_list);

            // Storage. Slots first written after the checkpoint go back to their original
            // value; slots written before it go back to the value captured at the checkpoint.
            var written_it = self.storage.original_storage.iterator();
            while (written_it.next()) |entry| {
                const key = entry.key_ptr.*;
                try self.writeStorageRaw(key, cp.storage.get(key) orelse entry.value_ptr.*);
            }
            // Drop original-value entries added after the checkpoint, so later SSTOREs price
            // against the right original.
            self.storage.original_storage.clearRetainingCapacity();
            var original_it = cp.original_storage.iterator();
            while (original_it.next()) |entry| {
                try self.storage.original_storage.put(entry.key_ptr.*, entry.value_ptr.*);
            }

            // Transient storage (EIP-1153)
            self.storage.clear_transient();
            var transient_it = cp.transient.iterator();
            while (transient_it.next()) |entry| {
                try self.storage.transient.put(entry.key_ptr.*, entry.value_ptr.*);
            }

            // SELFDESTRUCT marks (EIP-6780) and same-transaction creation marks
            self.selfdestructed_accounts.clearRetainingCapacity();
            var selfdestruct_it = cp.selfdestructed.keyIterator();
            while (selfdestruct_it.next()) |addr| {
                try self.selfdestructed_accounts.put(addr.*, {});
            }
            self.created_accounts.clearRetainingCapacity();
            var created_it = cp.created.keyIterator();
            while (created_it.next()) |addr| {
                try self.created_accounts.put(addr.*, {});
            }

            // Balances, nonces and code: write the recorded pre-images back, bypassing the
            // journal (enclosing checkpoints already hold their own pre-images).
            var balance_it = cp.balances.iterator();
            while (balance_it.next()) |entry| {
                try self.writeBalanceRaw(entry.key_ptr.*, entry.value_ptr.*);
            }
            var nonce_it = cp.nonces.iterator();
            while (nonce_it.next()) |entry| {
                try self.writeNonceRaw(entry.key_ptr.*, entry.value_ptr.*);
            }
            var code_it = cp.code.iterator();
            while (code_it.next()) |entry| {
                try self.writeCodeRaw(entry.key_ptr.*, entry.value_ptr.*, false);
            }

            // EIP-7928: roll back BAL state mutations while preserving address accesses and
            // demoting reverted storage writes to reads.
            if (self.bal_recorder) |rec| {
                if (cp.bal_snapshot) |snap| try rec.rollback(snap);
            }
        }

        /// Whether another frame may be pushed. Guarantees `frames` never reallocates while
        /// ancestors hold `*Frame`: the depth budget is reserved when no frame is live, and a
        /// list built by other means is never grown past its capacity.
        pub fn canPushFrame(self: *Self) bool {
            if (self.frames.items.len >= max_frames) return false;
            if (self.frames.items.len == 0 and self.frames.capacity < max_frames) {
                self.frames.ensureTotalCapacityPrecise(self.arena.allocator(), max_frames) catch return false;
            }
            return self.frames.items.len < self.frames.capacity;
        }

        /// Execute a nested message call (CALL, CALLCODE, DELEGATECALL, STATICCALL opcodes).
        ///
        /// A failed call (REVERT, exceptional halt or precompile failure) rolls back every state
        /// change it made. `output` carries return data on success and revert data on REVERT.
        ///
        /// Async transactions: when the callee needs data the host has not supplied, the call
        /// reports failure, `async_restart_pending` is set and all frames stop; the result is
        /// discarded and the transaction replayed (see `requestAsyncRestart`).
        pub fn inner_call(self: *Self, params: CallParams) CallResult {
            const address = params.get_to().?;
            const resolved = self.resolveCallCode(address);
            const parent = self.getCurrentFrame();
            const caller = if (parent) |frame| frame.address else self.origin;
            const is_static = params == .staticcall or (parent != null and parent.?.is_static);
            const value = if (params == .delegatecall and parent != null) parent.?.value else callValue(params);
            const observed = self.enterCall(params, caller, resolved, value, is_static);
            const result = self.executeInnerCall(params, resolved, value, is_static, observed);
            if (observed) |observation| self.exitFrame(observation, result, resultErrorName(result));
            return result;
        }

        fn executeInnerCall(self: *Self, params: CallParams, resolved: ResolvedCode, value: u256, is_static: bool, observed: ?ObservedFrame) CallResult {
            const tx_alloc = self.tx_arena.allocator();

            const address = params.get_to().?;
            const input: []const u8 = params.getInput();
            const gas: u64 = params.getGas();

            const call_type = callType(params);

            // Depth limit (EELS: `depth + 1 > STACK_DEPTH_LIMIT`), checked before anything is
            // pushed or snapshotted. The forwarded gas returns to the caller.
            if (!self.canPushFrame()) return self.failed(gas, error.CallDepthExceeded);

            // Caller and execution address by call type:
            //   CALL / STATICCALL: caller = current frame, runs at the target address.
            //   CALLCODE:          caller = current frame, runs target code at the current address.
            //   DELEGATECALL:      caller and value inherited, runs target code at the current address.
            const parent_frame_idx: ?usize = if (self.frames.items.len > 0) self.frames.items.len - 1 else null;
            const current_frame = self.getCurrentFrame();
            const frame_caller = if (current_frame) |frame| frame.address else self.origin;
            const frame_caller_caller = if (current_frame) |frame| frame.caller else self.origin;
            const execution_caller: primitives.Address = switch (call_type) {
                .call, .staticcall, .callcode => frame_caller,
                .delegatecall => frame_caller_caller,
                else => return self.failed(gas, error.InvalidOpcode),
            };
            const execution_address: primitives.Address = switch (call_type) {
                .call, .staticcall => address,
                .delegatecall, .callcode => frame_caller,
                else => return self.failed(gas, error.InvalidOpcode),
            };

            // Only CALL and CALLCODE require the caller to hold `value`.
            if (value > 0 and (call_type == .call or call_type == .callcode)) {
                if (self.get_balance(frame_caller) < value) return self.failed(gas, error.InsufficientBalance);
            }

            var cp: Checkpoint = undefined;
            self.takeCheckpoint(&cp) catch return failedResult(gas);
            defer self.releaseCheckpoint(&cp);

            if (value > 0 and call_type == .call) {
                self.transferValue(frame_caller, address, value) catch return self.failAndRevert(&cp);
            }

            const code = resolved.code;
            if (self.async_restart_pending) return self.failAndRevert(&cp);
            if (code.len == 0) {
                var gas_left = gas;
                var output: []const u8 = &[_]u8{};
                switch (if (resolved.is_delegated) PrecompileOutcome.none else self.runPrecompile(tx_alloc, address, input, gas, Self.isPrecompileAddress(address, self.hardfork))) {
                    // A failed precompile consumes its gas and undoes the value transfer.
                    .failure => |err| {
                        self.revertBestEffort(&cp);
                        // EELS touches the target before running it and keeps the touch of
                        // RIPEMD-160 when the call fails (see `revertToCheckpoint`).
                        if (call_type == .call and address.equals(RIPEMD160_ADDRESS)) {
                            self.touchAccount(address) catch return failedResult(0);
                        }
                        return self.failed(0, err);
                    },
                    .success => |done| {
                        gas_left = done.gas_left;
                        output = done.output;
                    },
                    // A plain account without code: the call succeeds with no output.
                    .none => {},
                }
                if (call_type == .call) {
                    self.touchCallTarget(address) catch return self.failAndRevert(&cp);
                }
                return CallResult{ .success = true, .gas_left = gas_left, .output = output };
            }

            // Resolving the callee already hit missing async data: do not run it on a guess.
            if (self.async_restart_pending) return self.failAndRevert(&cp);
            // Gas above i64::MAX cannot be spent; cap instead of trapping on the cast.
            const frame_gas = std.math.cast(i64, gas) orelse std.math.maxInt(i64);
            const initial_reservoir = if (parent_frame_idx) |idx|
                self.frames.items[idx].state_gas_reservoir
            else
                self.state_gas_reservoir;
            var child_frame = FrameType.initLazy(
                self.allocator,
                code,
                frame_gas,
                execution_caller,
                execution_address,
                value,
                input,
                @as(*anyopaque, @ptrCast(self)),
                self.hardfork,
                is_static,
            ) catch return self.failAndRevert(&cp);
            child_frame.state_gas_reservoir = initial_reservoir;
            // `canPushFrame` reserved the slot: this never reallocates `frames`.
            self.frames.appendAssumeCapacity(child_frame);
            self.attachFrame(observed, resolved.address);
            const frame_index = self.frames.items.len - 1;
            defer {
                self.frames.items[frame_index].deinit();
                self.frames.shrinkRetainingCapacity(frame_index);
            }

            self.frames.items[frame_index].execute() catch |err| {
                // Missing async data is not a failure of the callee. This function cannot
                // return an error, so the request is recorded, every ancestor frame is stopped
                // and the executor replays the transaction once the host has answered. In a
                // synchronous `call()` nothing can answer, so the callee fails as before.
                if (err == error.NeedAsyncData) self.requestAsyncRestart(self.storage.async_data_request);
                // Exceptional halt: all forwarded gas is consumed; restore parent reservoir.
                self.applyChildStateGas(parent_frame_idx, initial_reservoir, 0, 0, 0, true);
                self.revertBestEffort(&cp);
                return self.failed(0, err);
            };
            if (self.async_restart_pending) {
                // The callee (or a descendant) was stopped for missing data; its result is void.
                self.applyChildStateGas(parent_frame_idx, initial_reservoir, 0, 0, 0, true);
                return self.failAndRevert(&cp);
            }

            const frame = &self.frames.items[frame_index];
            const reverted = frame.reverted;
            const raw_gas_left = @as(u64, @intCast(@max(frame.gas_remaining, 0)));
            const child_reservoir = frame.state_gas_reservoir;
            const child_spilled = frame.state_gas_spilled;
            const child_used = frame.state_gas_used;
            const output: []const u8 = if (frame.output.len > 0)
                (tx_alloc.dupe(u8, frame.output) catch {
                    self.applyChildStateGas(parent_frame_idx, initial_reservoir, 0, 0, 0, true);
                    return self.failAndRevert(&cp);
                })
            else
                &[_]u8{};

            if (reverted) {
                const gas_left = raw_gas_left +| child_spilled;
                self.applyChildStateGas(parent_frame_idx, initial_reservoir, 0, 0, 0, true);
                self.revertToCheckpoint(&cp) catch return failedResult(0);
                return CallResult{ .success = false, .gas_left = gas_left, .output = output };
            }

            if (call_type == .call) {
                self.touchCallTarget(address) catch {
                    self.applyChildStateGas(parent_frame_idx, initial_reservoir, 0, 0, 0, true);
                    return self.failAndRevert(&cp);
                };
            }
            self.applyChildStateGas(
                parent_frame_idx,
                initial_reservoir,
                child_reservoir,
                child_spilled,
                child_used,
                false,
            );
            return CallResult{ .success = true, .gas_left = raw_gas_left, .output = output };
        }

        /// Handle CREATE / CREATE2 (contract creation).
        ///
        /// The creator is the current frame's address, or `origin` when no frame is live
        /// (a contract-creation transaction). In that depth-0 case the transaction processor
        /// has already incremented the sender nonce, so the address derives from `nonce - 1`
        /// and the nonce is not incremented again here.
        ///
        /// Returns `error.OutOfGas` for init code over the EIP-3860 limit, which halts the
        /// calling frame, and `error.NeedAsyncData` when an async transaction must fetch data
        /// before the creation can run (the caller's frame unwinds; nothing is committed).
        /// Every other failure returns `success = false` with the destination account,
        /// endowment and all init-code effects rolled back.
        pub fn inner_create(
            self: *Self,
            value: u256,
            init_code: []const u8,
            gas: u64,
            salt: ?u256,
        ) errors.CallError!CreateResult {
            const is_top_level_create = self.frames.items.len == 0;
            const caller = if (self.getCurrentFrame()) |frame| frame.address else self.origin;
            return self.createFrom(caller, value, init_code, gas, salt, is_top_level_create);
        }

        /// Shared creation path for the CREATE/CREATE2 opcodes and creation transactions.
        /// Check order follows EELS `generic_create` and `process_create_message`.
        pub fn createFrom(
            self: *Self,
            caller: primitives.Address,
            value: u256,
            init_code: []const u8,
            gas: u64,
            salt: ?u256,
            is_top_level_create: bool,
        ) errors.CallError!CreateResult {
            const sender_nonce = self.getNonce(caller);
            const new_address = if (salt) |s|
                try self.computeCreate2Address(caller, s, init_code)
            else
                try self.computeCreateAddress(caller, if (is_top_level_create) sender_nonce -| 1 else sender_nonce);

            const early = self.beginCreate(caller, new_address, value, init_code, gas, salt, is_top_level_create, sender_nonce);
            const observed = if (self.inspector != null) self.enterFrame(.{
                .frame_id = 0,
                .parent_id = null,
                .depth = 0,
                .call_type = if (salt != null) .create2 else .create,
                .from = caller,
                .to = new_address,
                .code_address = new_address,
                .value = value,
                .gas = gas,
                .input = init_code,
                .is_static = false,
                .is_precompile = false,
                .is_delegated = false,
                .code = init_code,
            }) else null;
            const outcome: errors.CallError!CreateResult = if (early) |maybe_result|
                maybe_result orelse self.executeCreate(
                    caller,
                    new_address,
                    value,
                    init_code,
                    gas,
                    is_top_level_create,
                    observed,
                )
            else |err|
                err;
            if (observed) |observation| {
                @branchHint(.unlikely);
                const created = outcome catch |err| CreateResult{ .err = err };
                const failure = if (created.success) null else inspector_mod.formatErrorName(created.err orelse error.RevertExecution);
                self.exitFrame(observation, .{
                    .success = created.success,
                    .gas_left = created.gas_left,
                    .output = if (created.success) self.getRawCode(new_address) else created.output,
                    .created_address = if (created.success) new_address else null,
                }, failure);
            }
            return outcome;
        }

        fn beginCreate(self: *Self, caller: Address, new_address: Address, value: u256, init_code: []const u8, gas: u64, salt: ?u256, is_top_level_create: bool, sender_nonce: u64) errors.CallError!?CreateResult {
            // 1. EIP-3860 (Shanghai+) / EIP-7954 (Amsterdam+): oversize init code is an
            //    out-of-gas halt of the calling frame. Checked before balance, nonce and depth.
            const max_initcode = hardfork_hooks.maxInitcodeSize(self.hardfork, config.max_initcode_size);
            if (self.hardfork.isAtLeast(.SHANGHAI) and init_code.len > max_initcode) {
                return error.OutOfGas;
            }

            // 2. Insufficient balance, nonce overflow or depth limit: fail, gas is returned.
            //    The nonce guard belongs to whoever increments it: the opcode does so below,
            //    while a creation transaction arrives already incremented (possibly to 2^64-1
            //    from the last valid nonce 2^64-2) and is not incremented again.
            if (value > 0 and self.get_balance(caller) < value) return .{ .gas_left = gas, .err = error.InsufficientBalance };
            if (!is_top_level_create and sender_nonce == std.math.maxInt(u64)) return .{ .gas_left = gas, .err = error.NonceOverflow };
            if (!self.canPushFrame()) return .{ .gas_left = gas, .err = error.CallDepthExceeded };

            // 4. EIP-2929 (Berlin): the new address is warm from here on, even if creation fails.
            _ = try self.accessAddress(new_address);

            // 5. Collision (EIP-684, EIP-7610): the destination has a nonce, code or storage.
            //    The creator nonce is still incremented and all forwarded gas is consumed.
            //    Nothing at the destination is modified, so a pre-existing balance is kept.
            //    A CREATE2 address can pre-exist (same salt and init code), so in an async
            //    transaction its nonce and code are requested from the host. A nonce-derived
            //    address cannot, short of a hash collision: it is checked on the data at hand.
            const destination_nonce = if (salt != null) self.getNonce(new_address) else self.peekNonce(new_address);
            const destination_code = if (salt != null) self.get_raw_code(new_address) else self.peekRawCode(new_address);
            const has_collision = destination_nonce > 0 or
                destination_code.len > 0 or
                self.accountHasStorage(new_address);
            if (has_collision) {
                if (!is_top_level_create) try self.setNonceWithSnapshot(caller, sender_nonce + 1);
                return .{ .err = error.ContractCollision };
            }

            self.clearExistingEmptyAccountForCreate(new_address);

            // 6. Creator-side nonce increment survives a failed creation, so it happens
            //    before the checkpoint (opcodes only; transactions are handled by the processor).
            if (!is_top_level_create) try self.setNonceWithSnapshot(caller, sender_nonce + 1);

            return null;
        }

        const CodeDepositResult = union(enum) {
            ok: struct {
                deployed_code: []const u8,
                gas_left: u64,
                reservoir: u64,
                spilled: u64,
                state_used: i64,
            },
            err: errors.CallError,
        };

        /// Evaluate code deposit rules (EIP-170, EIP-3541, EIP-7954, EIP-8037).
        fn evaluateCodeDeposit(
            self: *const Self,
            frame_output: []const u8,
            gas_left: u64,
            reservoir: u64,
            spilled: u64,
            state_used: i64,
        ) CodeDepositResult {
            const max_code = hardfork_hooks.maxCodeSize(self.hardfork, config.max_bytecode_size);
            const ef_prefix = self.hardfork.isAtLeast(.LONDON) and frame_output.len > 0 and frame_output[0] == 0xEF;
            const exceeds_size = self.hardfork.isAtLeast(.SPURIOUS_DRAGON) and frame_output.len > max_code;

            if (hardfork_hooks.supportsAmsterdam(self.hardfork)) {
                if (ef_prefix) return .{ .err = error.InvalidBytecode };
                if (exceeds_size) return .{ .err = error.CreateContractSizeLimit };
                const split = hardfork_hooks.GasSchedule.forFork(self.hardfork).codeDeposit(frame_output.len);
                if (gas_left < split.regular) return .{ .err = error.CodeStoreOutOfGas };
                const after_regular = gas_left - split.regular;
                const from_res = @min(reservoir, split.state);
                const from_gas = split.state - from_res;
                if (from_gas > after_regular) return .{ .err = error.CodeStoreOutOfGas };
                return .{ .ok = .{
                    .deployed_code = frame_output,
                    .gas_left = after_regular - from_gas,
                    .reservoir = reservoir - from_res,
                    .spilled = spilled +| from_gas,
                    .state_used = state_used +| @as(i64, @intCast(@min(split.state, std.math.maxInt(i64)))),
                } };
            }

            const code_len: u64 = @intCast(frame_output.len);
            const deposit_cost = std.math.mul(u64, code_len, GasConstants.CreateDataGas) catch std.math.maxInt(u64);
            const deposit_out_of_gas = gas_left < deposit_cost;
            if (deposit_out_of_gas and self.hardfork.isBefore(.HOMESTEAD)) {
                return .{ .ok = .{
                    .deployed_code = &[_]u8{},
                    .gas_left = gas_left,
                    .reservoir = reservoir,
                    .spilled = spilled,
                    .state_used = state_used,
                } };
            }
            if (ef_prefix or deposit_out_of_gas or exceeds_size) {
                return .{ .err = if (ef_prefix)
                    error.InvalidBytecode
                else if (exceeds_size)
                    error.CreateContractSizeLimit
                else
                    error.CodeStoreOutOfGas };
            }
            return .{ .ok = .{
                .deployed_code = frame_output,
                .gas_left = gas_left - deposit_cost,
                .reservoir = reservoir,
                .spilled = spilled,
                .state_used = state_used,
            } };
        }

        fn executeCreate(
            self: *Self,
            caller: Address,
            new_address: Address,
            value: u256,
            init_code: []const u8,
            gas: u64,
            is_top_level_create: bool,
            observed: ?ObservedFrame,
        ) errors.CallError!CreateResult {
            // 7. Everything below is one unit: any failure restores storage, original and
            //    transient storage, logs, balances, nonces, code, created/self-destructed/touched
            //    sets, warm sets and the refund counter to this point.
            const parent_frame_idx: ?usize = if (self.frames.items.len > 0) self.frames.items.len - 1 else null;
            const initial_reservoir = if (parent_frame_idx) |idx|
                self.frames.items[idx].state_gas_reservoir
            else
                self.state_gas_reservoir;

            var cp: Checkpoint = undefined;
            try self.takeCheckpoint(&cp);
            defer self.releaseCheckpoint(&cp);
            errdefer {
                self.applyChildStateGas(parent_frame_idx, initial_reservoir, 0, 0, 0, true);
                self.revertBestEffort(&cp);
            }

            // EIP-8037 (Amsterdam+): top-level creation charges NEW_ACCOUNT state gas in the
            // creation frame when the destination account is not already alive.
            var start_gas = gas;
            var start_reservoir = initial_reservoir;
            var start_spilled: u64 = 0;
            var start_used: i64 = 0;
            if (is_top_level_create and hardfork_hooks.supportsAmsterdam(self.hardfork)) {
                const dest_alive = !self.accountIsEmpty(new_address);
                if (!dest_alive) {
                    const create_state = hardfork_hooks.GasSchedule.forFork(self.hardfork).create.state;
                    const from_res = @min(start_reservoir, create_state);
                    const from_gas = create_state - from_res;
                    if (from_gas > start_gas) {
                        self.applyChildStateGas(parent_frame_idx, initial_reservoir, 0, 0, 0, true);
                        try self.revertToCheckpoint(&cp);
                        return .{ .err = error.OutOfGas };
                    }
                    start_reservoir -= from_res;
                    start_gas -= from_gas;
                    start_spilled = from_gas;
                    start_used = @intCast(create_state);
                }
            }

            // EIP-6780: mark as created in this transaction before running init code.
            try self.created_accounts.put(new_address, {});
            // EIP-161 (Spurious Dragon): a new contract starts at nonce 1; earlier forks at 0.
            if (self.hardfork.isAtLeast(.SPURIOUS_DRAGON)) {
                try self.setNonceWithSnapshot(new_address, 1);
            } else {
                // With nonce 0, no code and no endowment nothing else would record the new
                // account; before EIP-161 it exists even when empty, so materialize it.
                try self.setBalanceWithSnapshot(new_address, self.get_balance(new_address));
            }
            if (value > 0) try self.transferValue(caller, new_address, value);

            // The balance, nonce or collision checks above ran on missing async data: unwind
            // (the `errdefer` rolls back) and let the executor fetch it and replay.
            if (self.async_restart_pending) return error.NeedAsyncData;
            // Gas above i64::MAX cannot be spent; cap instead of trapping on the cast.
            const frame_gas = std.math.cast(i64, start_gas) orelse std.math.maxInt(i64);
            var init_frame = try FrameType.initLazy(
                self.allocator,
                init_code,
                frame_gas,
                caller,
                new_address,
                value,
                &[_]u8{}, // no calldata for CREATE
                @as(*anyopaque, @ptrCast(self)),
                self.hardfork,
                false, // creation is never static
            );
            init_frame.state_gas_reservoir = start_reservoir;
            init_frame.state_gas_spilled = start_spilled;
            init_frame.state_gas_used = start_used;
            // `canPushFrame` reserved the slot: this never reallocates `frames`.
            self.frames.appendAssumeCapacity(init_frame);
            self.attachFrame(observed, new_address);
            const frame_index = self.frames.items.len - 1;
            const frame_outcome = blk: {
                defer {
                    self.frames.items[frame_index].deinit();
                    self.frames.shrinkRetainingCapacity(frame_index);
                }

                self.frames.items[frame_index].execute() catch |err| {
                    self.applyChildStateGas(parent_frame_idx, initial_reservoir, 0, 0, 0, true);
                    try self.revertToCheckpoint(&cp);
                    if (err == error.NeedAsyncData and self.async_active) {
                        // Init code needs data the host has not supplied: propagate instead of
                        // failing the creation, so the transaction is replayed with the data.
                        self.requestAsyncRestart(self.storage.async_data_request);
                        return error.NeedAsyncData;
                    }
                    // Exceptional halt in init code: all gas consumed, no return data.
                    return .{ .err = err };
                };
                if (self.async_restart_pending) {
                    return error.NeedAsyncData;
                }

                const frame = &self.frames.items[frame_index];
                const out: []const u8 = if (frame.output.len > 0)
                    try self.tx_arena.allocator().dupe(u8, frame.output)
                else
                    &[_]u8{};
                break :blk .{
                    .reverted = frame.reverted,
                    .gas_left = @as(u64, @intCast(@max(frame.gas_remaining, 0))),
                    .reservoir = frame.state_gas_reservoir,
                    .spilled = frame.state_gas_spilled,
                    .state_used = frame.state_gas_used,
                    .output = out,
                };
            };

            if (frame_outcome.reverted) {
                // REVERT is the only failure that returns data and unused (plus LIFO spilled) gas.
                const gas_left = frame_outcome.gas_left +| frame_outcome.spilled;
                self.applyChildStateGas(parent_frame_idx, initial_reservoir, 0, 0, 0, true);
                try self.revertToCheckpoint(&cp);
                return .{
                    .address = primitives.ZERO_ADDRESS,
                    .success = false,
                    .gas_left = gas_left,
                    .output = frame_outcome.output,
                };
            }

            // 8. Code deposit (EIP-170, EIP-3541, EIP-7954, EIP-8037).
            const deposit = self.evaluateCodeDeposit(
                frame_outcome.output,
                frame_outcome.gas_left,
                frame_outcome.reservoir,
                frame_outcome.spilled,
                frame_outcome.state_used,
            );
            const committed = switch (deposit) {
                .ok => |ok| ok,
                .err => |err| {
                    self.applyChildStateGas(parent_frame_idx, initial_reservoir, 0, 0, 0, true);
                    try self.revertToCheckpoint(&cp);
                    return .{ .err = err };
                },
            };

            try self.setCodeWithSnapshot(new_address, committed.deployed_code);
            self.applyChildStateGas(
                parent_frame_idx,
                initial_reservoir,
                committed.reservoir,
                committed.spilled,
                committed.state_used,
                false,
            );

            return .{
                .address = new_address,
                .success = true,
                .gas_left = committed.gas_left,
                .output = &[_]u8{},
            };
        }

        /// Add to the signed refund counter (EELS `refund_counter += amount`).
        pub fn add_refund(self: *Self, amount: u64) void {
            self.gas_refund +|= @as(i64, @intCast(@min(amount, std.math.maxInt(i64))));
        }

        /// Subtract from the signed refund counter. The counter may go negative mid-transaction
        /// (net gas metering removes refunds granted earlier); it is clamped only when read.
        pub fn sub_refund(self: *Self, amount: u64) void {
            self.gas_refund -|= @as(i64, @intCast(@min(amount, std.math.maxInt(i64))));
        }

        /// Refund counter as applied at transaction end: negative values count as zero.
        pub fn get_effective_refund(self: *const Self) u64 {
            return if (self.gas_refund > 0) @intCast(self.gas_refund) else 0;
        }

        /// Get balance of an address (called by frame)
        pub fn get_balance(self: *Self, address: primitives.Address) u256 {
            if (self.host) |h| return h.getBalance(address);
            if (self.balances.get(address)) |balance| return balance;
            self.noteAccountMiss(.balance, address);
            return 0;
        }

        /// Code stored at `address`, exactly as stored. An EIP-7702 delegation designator
        /// (`0xef0100 ++ target`) is returned as-is, not followed.
        pub fn get_raw_code(self: *Self, address: primitives.Address) []const u8 {
            if (self.host) |h| return h.getCode(address);
            if (self.code.get(address)) |code| return code;
            self.noteAccountMiss(.code, address);
            return &[_]u8{};
        }

        /// EIP-7702 (Prague+): the delegation target of `address`, or null when its code is
        /// not a 23-byte `0xef0100 ++ target` designator.
        pub fn get_delegated_target(self: *Self, address: Address) ?Address {
            return if (self.hardfork.isAtLeast(.PRAGUE)) parseDelegation(self.get_raw_code(address)) else null;
        }

        /// Executable code for `address`: follows one level of EIP-7702 delegation.
        /// A delegate that itself holds a designator is returned as-is (no chaining).
        /// Use `get_raw_code` to inspect what the account actually stores.
        pub const ResolvedCode = struct {
            code: []const u8,
            address: Address,
            is_delegated: bool = false,
        };

        pub fn getRawCode(self: *Self, address: Address) []const u8 {
            return self.get_raw_code(address);
        }

        fn resolveCode(self: *Self, address: Address) ResolvedCode {
            return self.resolveCodeBytes(address, self.getRawCode(address));
        }

        /// Resolves the code a message to `address` runs. An active native
        /// precompile wins over account code at its address, as EELS
        /// `execute_code` checks `PRECOMPILED_CONTRACTS` first. EIP-7702
        /// delegation disables precompiles, so it still resolves to the delegate.
        /// A precompile override at `address` supersedes the native precompile:
        /// if the account also has bytecode, that bytecode runs; if not,
        /// `canExecutePrecompile`/`executePrecompile` will pick up the override.
        pub fn resolveCallCode(self: *Self, address: Address) ResolvedCode {
            // A native precompile can run without requesting code from an async host.
            // A configured override retains main's account-code and delegation precedence.
            if (Self.isPrecompileAddress(address, self.hardfork) and self.getPrecompileOverride(address) == null) {
                if (self.hardfork.isAtLeast(.PRAGUE)) {
                    if (parseDelegation(self.peekRawCode(address))) |delegate| {
                        return .{ .code = self.get_raw_code(delegate), .address = delegate, .is_delegated = true };
                    }
                }
                return .{ .code = &.{}, .address = address };
            }
            return self.resolveCode(address);
        }

        pub fn resolveCodeBytes(self: *Self, address: Address, code: []const u8) ResolvedCode {
            // EIP-7702 resolves one delegation designation.
            if (self.hardfork.isAtLeast(.PRAGUE)) {
                if (parseDelegation(code)) |delegated| {
                    return .{ .code = self.getRawCode(delegated), .address = delegated, .is_delegated = true };
                }
            }
            return .{ .code = code, .address = address };
        }

        pub fn get_code(self: *Self, address: Address) []const u8 {
            return self.resolveCode(address).code;
        }

        fn canExecutePrecompile(self: *Self, address: Address, resolved: ResolvedCode) bool {
            return resolved.code.len == 0 and !resolved.is_delegated and
                (self.getPrecompileOverride(address) != null or Self.isPrecompileAddress(address, self.hardfork));
        }

        /// Get current frame (top of the frame stack)
        pub fn getCurrentFrame(self: *Self) ?*FrameType {
            if (self.frames.items.len > 0) return &self.frames.items[self.frames.items.len - 1];
            return null;
        }

        /// Get current frame's PC (for tracer)
        pub fn getPC(self: *const Self) u32 {
            if (self.frames.items.len > 0) {
                return self.frames.items[self.frames.items.len - 1].pc;
            }
            return 0;
        }

        /// Raw code bytes of the current frame (for tracers); empty when no frame is live.
        pub fn getBytecode(self: *const Self) []const u8 {
            if (self.frames.items.len > 0) {
                return self.frames.items[self.frames.items.len - 1].bytecode.code;
            }
            return &[_]u8{};
        }

        /// Execute a single step (for tracer)
        pub fn step(self: *Self) !void {
            if (self.getCurrentFrame()) |frame| {
                try frame.step();
            }
        }
    };
}

test "parseDelegation accepts only the exact 23-byte designation" {
    const target = primitives.Address{ .bytes = @splat(0xab) };
    const designation = DELEGATION_PREFIX ++ target.bytes;
    try std.testing.expectEqual(target, parseDelegation(&designation).?);
    try std.testing.expect(parseDelegation(&(designation ++ [_]u8{0x00})) == null);
    try std.testing.expect(parseDelegation(designation[0..22]) == null);
    try std.testing.expect(parseDelegation(&([_]u8{ 0xef, 0x01, 0x01 } ++ target.bytes)) == null);
    try std.testing.expect(parseDelegation(&.{}) == null);
}
