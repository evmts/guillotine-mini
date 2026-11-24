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
};

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
    if (hardfork.isAtLeast(.OSAKA) and address.equals(P256VERIFY_ADDRESS)) return true;
    return precompiles.isPrecompile(address, hardfork);
}

/// Execute the standard precompile at `address`. Caller must check `isPrecompileAddress()`.
pub fn executePrecompile(
    allocator: std.mem.Allocator,
    address: Address,
    input: []const u8,
    gas_limit: u64,
    hardfork: Hardfork,
) precompiles.PrecompileError!precompiles.PrecompileResult {
    if (hardfork.isAtLeast(.OSAKA) and address.equals(P256VERIFY_ADDRESS)) {
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
) precompiles.PrecompileError!precompiles.PrecompileResult {
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

    return struct {
        const Self = @This();

        const AddressSet = std.AutoHashMap(primitives.Address, void);
        const SlotMap = std.AutoHashMap(StorageKey, u256);

        /// EVM stack depth limit: a message at depth 1024 cannot call or create.
        pub const stack_depth_limit: usize = 1024;
        /// Most frames alive at once: the top-level frame (depth 0) plus depths 1..1024.
        /// `frames` reserves exactly this capacity per transaction and never grows past it.
        pub const max_frames: usize = stack_depth_limit + 1;
        /// Scratch memory kept between transactions; anything above this is returned to the OS.
        const tx_arena_retain_limit: usize = 8 * 1024 * 1024;

        /// Result of `inner_create`. `output` is non-empty only when init code ended in REVERT.
        pub const CreateResult = struct {
            address: primitives.Address,
            success: bool,
            gas_left: u64,
            output: []const u8,
        };

        /// Outcome of the shared precompile dispatch used by `call` and `inner_call`.
        pub const PrecompileOutcome = union(enum) {
            /// No precompile path handles this address.
            none,
            success: struct { gas_left: u64, output: []const u8 },
            /// The precompile failed; all forwarded gas is consumed.
            failure,
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
        };

        /// Account field an async transaction can ask the host for.
        pub const AsyncAccountField = enum(u8) { balance, nonce, code };
        pub const AsyncKnownKey = struct { field: AsyncAccountField, address: [20]u8 };
        /// Transaction-scoped account code, owned by `allocator`.
        pub const AsyncCodeView = struct { address: primitives.Address, bytes: []u8 };

        pub const CallParams = call_params.CallParams(config);
        pub const CallResult = call_result.CallResult(config);

        // Create AsyncExecutor type for this EVM
        pub const AsyncExecutorType = async_executor_mod.AsyncExecutor(Self, CallParams, CallResult);

        // Re-export async types from executor
        pub const CallOrContinueInput = AsyncExecutorType.CallOrContinueInput;
        pub const CallOrContinueOutput = AsyncExecutorType.CallOrContinueOutput;

        frames: std.ArrayList(FrameType),
        storage: Storage,
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
        /// Code installed at the call target for one async call (see `installAsyncCodeView`).
        async_code_view: ?AsyncCodeView = null,

        // Accumulated logs for current transaction
        logs: std.ArrayList(call_result.Log),

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
            self.balances = std.AutoHashMap(primitives.Address, u256).init(arena_alloc);
            self.nonces = std.AutoHashMap(primitives.Address, u64).init(arena_alloc);
            self.code = std.AutoHashMap(primitives.Address, []const u8).init(arena_alloc);
            self.created_accounts = AddressSet.init(tx_alloc);
            self.selfdestructed_accounts = AddressSet.init(tx_alloc);
            self.touched_accounts = AddressSet.init(tx_alloc);
            self.access_list_manager = AccessListManager.init(tx_alloc);
            self.async_known = std.AutoHashMap(AsyncKnownKey, void).init(tx_alloc);
        }

        fn freePendingStateChanges(self: *Self) void {
            if (self.pending_state_changes.len > 0) self.allocator.free(self.pending_state_changes);
            self.pending_state_changes = &.{};
        }

        /// Return the full pending state-changes JSON slice (empty slice if none).
        pub fn getPendingStateChanges(self: *const Self) []const u8 {
            return self.pending_state_changes;
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
        pub fn deinit(self: *Self) void {
            self.releaseAsyncCodeView();
            self.freePendingStateChanges();
            self.blob_hashes_owned.deinit(self.allocator);
            self.tx_arena.deinit();
            self.arena.deinit();
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
            if (self.host != null or injector != null) self.storage.storage.clearRetainingCapacity();

            self.gas_refund = 0;
            self.access_list_manager = AccessListManager.init(tx_alloc);
            try self.preWarmPrecompiles();

            // Frames never reallocate during a transaction: ancestors hold `*Frame` across nested
            // calls, so the full depth budget is reserved up front.
            self.frames = .empty;
            try self.frames.ensureTotalCapacityPrecise(tx_alloc, max_frames);

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

        /// Make `bytes` the code of `address` for one async call, so EXTCODE* and re-entrant
        /// calls see the code the call runs (as the synchronous C entry point does). Hostless
        /// only. Released by `endAsyncTransaction`.
        pub fn installAsyncCodeView(self: *Self, address: primitives.Address, bytes: []const u8) ![]const u8 {
            self.releaseAsyncCodeView();
            const owned = try self.allocator.dupe(u8, bytes);
            errdefer self.allocator.free(owned);
            try self.code.put(address, owned);
            self.async_code_view = .{ .address = address, .bytes = owned };
            return owned;
        }

        fn releaseAsyncCodeView(self: *Self) void {
            const view = self.async_code_view orelse return;
            self.async_code_view = null;
            // Leave the entry alone when the transaction replaced or deleted the code.
            if (self.code.get(view.address)) |current| {
                if (current.ptr == view.bytes.ptr) _ = self.code.remove(view.address);
            }
            self.allocator.free(view.bytes);
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

        pub fn accessAddress(self: *Self, address: primitives.Address) !u64 {
            if (self.hardfork.isBefore(.BERLIN)) {
                @branchHint(.cold);
                // Pre-Berlin: No warm/cold access costs (EIP-2929 introduced in Berlin)
                // The base call cost is already charged in the CALL opcode
                return 0;
            }

            return try self.access_list_manager.access_address(address);
        }

        /// Access a storage slot and return the gas cost (EIP-2929 warm/cold)
        pub fn accessStorageSlot(self: *Self, contract_address: primitives.Address, slot: u256) !u64 {
            if (self.hardfork.isBefore(.BERLIN)) {
                @branchHint(.cold);
                if (self.hardfork.isAtLeast(.ISTANBUL)) return 800;
                if (self.hardfork.isAtLeast(.TANGERINE_WHISTLE)) return 200;
                return 50;
            }

            return try self.access_list_manager.access_storage_slot(contract_address, slot);
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

            // Now set the new balance
            if (self.host) |h| {
                h.setBalance(addr, new_balance);
            } else {
                try self.balances.put(addr, new_balance);
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

            if (self.host) |h| {
                h.setNonce(addr, new_nonce);
            } else if (new_nonce == 0) {
                _ = self.nonces.remove(addr);
            } else {
                try self.nonces.put(addr, new_nonce);
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

            try self.writeCodeRaw(addr, new_code, true);
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
            if (self.get_balance(addr) != 0 or (self.nonces.get(addr) orelse 0) != 0 or self.get_raw_code(addr).len != 0) return true;
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

        fn deleteAccountState(self: *Self, addr: primitives.Address) void {
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
            self.access_list_manager.pre_warm_addresses(addresses) catch {
                return errors.CallError.StorageError;
            };
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
            if (!self.hardfork.isAtLeast(.BERLIN)) return;

            var precompile_addrs: [MAX_CONTIGUOUS_PRECOMPILE + 1]primitives.Address = undefined;
            var count: usize = 0;
            var addr_int: u16 = 1;
            while (addr_int <= MAX_CONTIGUOUS_PRECOMPILE) : (addr_int += 1) {
                const candidate = primitives.Address.fromU256(addr_int);
                if (Self.isPrecompileAddress(candidate, self.hardfork)) {
                    precompile_addrs[count] = candidate;
                    count += 1;
                }
            }
            if (Self.isPrecompileAddress(P256VERIFY_ADDRESS, self.hardfork)) {
                precompile_addrs[count] = P256VERIFY_ADDRESS;
                count += 1;
            }
            try self.pre_warm_addresses(precompile_addrs[0..count]);
        }

        /// Warm the transaction participants: origin, `target` (every real destination,
        /// including the zero address) and, from Shanghai, the coinbase.
        pub fn preWarmParticipants(self: *Self, target: primitives.Address) errors.CallError!void {
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
        /// code for a target that has none installed. `gas_refund` stays readable after the call
        /// and is reset when the next transaction starts.
        ///
        /// CREATE convention: like `inner_create` at depth 0, the transaction processor has
        /// already incremented the sender nonce, so the address derives from `nonce - 1`.
        pub fn call(
            self: *Self,
            params: CallParams,
        ) CallResult {
            const access_list = self.pending_access_list;
            const pending_bytecode = self.pending_bytecode;
            self.pending_access_list = null;
            self.pending_bytecode = &[_]u8{};
            defer self.finishTransaction();

            return self.executeTransaction(params, access_list, pending_bytecode);
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

        fn executeTransaction(
            self: *Self,
            params: CallParams,
            access_list: ?primitives.AccessList.AccessList,
            pending_bytecode: []const u8,
        ) CallResult {
            const result_alloc = self.arena.allocator();

            const target = params.get_to();

            // Validate parameters
            params.validate() catch return failedResult(0);

            const caller = params.getCaller();
            const gas = params.getGas();
            const calldata = params.getInput();
            const blob_versioned_hashes: ?[]const [32]u8 = if (self.blob_versioned_hashes.len > 0) self.blob_versioned_hashes else null;

            // Initialize transaction state (warms active precompiles on Berlin+)
            self.initTransactionState(blob_versioned_hashes) catch return failedResult(0);

            // Resolved only now: `initTransactionState` selects the fork for this block.
            const target_is_precompile = if (target) |addr| Self.isPrecompileAddress(addr, self.hardfork) else false;

            // Pre-warm access list (EIP-2929/EIP-2930)
            if (access_list) |list| {
                self.access_list_manager.pre_warm_from_access_list(list) catch return failedResult(0);
            }

            if (params.isCreate()) {
                // The new address is warmed by the create itself, from the single derivation.
                self.preWarmParticipants(caller) catch return failedResult(0);

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
                self.takeCheckpoint(&create_cp) catch return failedResult(0);
                defer self.releaseCheckpoint(&create_cp);

                const created = self.createFrom(caller, create_value, calldata, gas, salt, true) catch |err| {
                    self.revertBestEffort(&create_cp);
                    return CallResult.failure_with_error(result_alloc, 0, @errorName(err)) catch failedResult(0);
                };
                if (!created.success) {
                    return CallResult.revert_with_data(result_alloc, created.gas_left, created.output) catch failedResult(created.gas_left);
                }

                var result = CallResult.success_with_logs(result_alloc, created.gas_left, &.{}, self.logs.items) catch {
                    return self.failAndRevert(&create_cp);
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
            const transfers_value = params == .call;
            const requires_balance = params == .call or params == .callcode;
            const is_static = params == .staticcall;
            const execution_address = switch (params) {
                .callcode, .delegatecall => caller,
                else => address,
            };

            self.preWarmParticipants(address) catch return failedResult(0);

            // Resolve the code to run. Active precompiles always dispatch as precompiles.
            var bytecode: []const u8 = &[_]u8{};
            if (!target_is_precompile) {
                if (self.get_delegated_target(address)) |delegate| {
                    // EIP-7702: a transaction to a delegating account warms the delegate and
                    // runs its code with precompile dispatch disabled.
                    self.pre_warm_addresses(&[_]primitives.Address{delegate}) catch return failedResult(0);
                    bytecode = self.get_raw_code(delegate);
                } else {
                    bytecode = self.get_raw_code(address);
                    if (bytecode.len == 0) bytecode = pending_bytecode;
                }
            }

            // Everything from here is rolled back on REVERT or an exceptional halt.
            var cp: Checkpoint = undefined;
            self.takeCheckpoint(&cp) catch return failedResult(0);
            defer self.releaseCheckpoint(&cp);

            if (value > 0 and requires_balance) {
                if (self.get_balance(caller) < value) return failedResult(0);
                if (transfers_value) {
                    self.transferValue(caller, address, value) catch return self.failAndRevert(&cp);
                }
            }

            // Note: intrinsic gas is deducted by the caller before this function runs.

            if (bytecode.len == 0) {
                var gas_left = gas;
                var output: []const u8 = &[_]u8{};
                switch (self.runPrecompile(result_alloc, address, calldata, gas, target_is_precompile)) {
                    .failure => return self.failAndRevert(&cp),
                    .success => |done| {
                        gas_left = done.gas_left;
                        output = done.output;
                    },
                    // A plain account without code: the call succeeds with no output.
                    .none => {},
                }
                if (transfers_value) {
                    self.touchCallTarget(address) catch return self.failAndRevert(&cp);
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
            const top_frame = FrameType.init(
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
            ) catch return self.failAndRevert(&cp);
            self.frames.appendAssumeCapacity(top_frame);

            self.frames.items[0].execute() catch |err| {
                // Exceptional halt: all gas is consumed and every state change is undone.
                self.revertBestEffort(&cp);
                return CallResult.failure_with_error(result_alloc, 0, @errorName(err)) catch failedResult(0);
            };

            const frame = &self.frames.items[0];
            const gas_left = @as(u64, @intCast(@max(frame.gas_remaining, 0)));

            if (frame.reverted) {
                self.revertToCheckpoint(&cp) catch return failedResult(0);
                return CallResult.revert_with_data(result_alloc, gas_left, frame.output) catch failedResult(gas_left);
            }

            // Gas refunds are not applied here: the caller applies them after computing the
            // gas actually consumed, reading `refund_counter` (or `get_effective_refund()`).
            var result = CallResult.success_with_logs(result_alloc, gas_left, frame.output, self.logs.items) catch {
                return self.failAndRevert(&cp);
            };
            result.refund_counter = self.get_effective_refund();
            self.commitTransaction();
            return result;
        }

        /// End-of-transaction effects that apply only when the transaction succeeded:
        /// delete self-destructed accounts (EIP-6780) and touched empty accounts (EIP-161).
        pub fn commitTransaction(self: *Self) void {
            self.cleanup_selfdestructed_accounts_end_of_tx();
            self.cleanup_touched_empty_accounts_end_of_tx();
        }

        /// Drop everything scoped to the finished transaction so nothing leaks into the next
        /// call on this instance. Runs on every exit path. `gas_refund` is left readable.
        pub fn finishTransaction(self: *Self) void {
            self.access_list_manager.clear();
            self.storage.clear_transient();
            self.logs.clearRetainingCapacity();
            self.frames.clearRetainingCapacity();
            self.created_accounts.clearRetainingCapacity();
            self.selfdestructed_accounts.clearRetainingCapacity();
            self.touched_accounts.clearRetainingCapacity();
            self.touched_journal.clearRetainingCapacity();
            self.pending_access_list = null;
            self.pending_bytecode = &[_]u8{};
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
                if (js_gas_used > gas) return .failure;
                // Copy out of the handler's buffer, which it may reuse on the next call.
                const output: []const u8 = if (output_len > 0)
                    out_alloc.dupe(u8, output_ptr[0..output_len]) catch return .failure
                else
                    &[_]u8{};
                return .{ .success = .{ .gas_left = gas - js_gas_used, .output = output } };
            }

            if (self.getPrecompileOverride(address)) |override| {
                const result = override.execute(override.context, out_alloc, input, gas) catch return .failure;
                if (!result.success or result.gas_used > gas) return .failure;
                return .{ .success = .{ .gas_left = gas - result.gas_used, .output = result.output } };
            }

            if (is_standard) {
                const result = executePrecompile(out_alloc, address, input, gas, self.hardfork) catch return .failure;
                if (result.gas_used > gas) return .failure;
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

            self.pending_state_changes = try self.allocator.dupe(u8, raw);
            return self.pending_state_changes;
        }

        /// Delete accounts marked via SELFDESTRUCT at end of transaction (EIP-6780).
        /// Handles both host-backed and in-memory modes. Must be called only after
        /// transient storage is cleared and logs are finalized.
        fn cleanup_selfdestructed_accounts_end_of_tx(self: *Self) void {
            var it = self.selfdestructed_accounts.iterator();
            while (it.next()) |entry| {
                const addr = entry.key_ptr.*;
                self.deleteAccountState(addr);
            }
            // The set is kept until `finishTransaction`: the async commit dump still reports it.
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
                // as an explicit entry: a missing one would fall back to the fetch cache,
                // which still holds the reverted write.
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
            const tx_alloc = self.tx_arena.allocator();

            var access_list = try self.access_list_manager.snapshot();
            errdefer access_list.deinit();

            // Current value of every slot written so far in this transaction.
            var storage_values = SlotMap.init(tx_alloc);
            var written_it = self.storage.original_storage.keyIterator();
            while (written_it.next()) |key| {
                try storage_values.put(key.*, self.currentStorageValue(key.*));
            }

            cp.* = .{
                .refund = self.gas_refund,
                .logs_len = self.logs.items.len,
                .touched_len = self.touched_journal.items.len,
                .access_list = access_list,
                .original_storage = try self.storage.original_storage.cloneWithAllocator(tx_alloc),
                .storage = storage_values,
                .transient = try self.storage.transient.cloneWithAllocator(tx_alloc),
                .selfdestructed = try self.selfdestructed_accounts.cloneWithAllocator(tx_alloc),
                .created = try self.created_accounts.cloneWithAllocator(tx_alloc),
                .balances = std.AutoHashMap(primitives.Address, u256).init(tx_alloc),
                .nonces = std.AutoHashMap(primitives.Address, u64).init(tx_alloc),
                .code = std.AutoHashMap(primitives.Address, []const u8).init(tx_alloc),
            };

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
        }

        /// Whether another frame may be pushed. Guarantees `frames` never reallocates while
        /// ancestors hold `*Frame`: the depth budget is reserved when no frame is live, and a
        /// list built by other means is never grown past its capacity.
        pub fn canPushFrame(self: *Self) bool {
            if (self.frames.items.len >= max_frames) return false;
            if (self.frames.items.len == 0 and self.frames.capacity < max_frames) {
                self.frames.ensureTotalCapacityPrecise(self.tx_arena.allocator(), max_frames) catch return false;
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
        pub fn inner_call(
            self: *Self,
            params: CallParams,
        ) CallResult {
            const tx_alloc = self.tx_arena.allocator();

            const address: primitives.Address = switch (params) {
                .call => |p| p.to,
                .callcode => |p| p.to,
                .delegatecall => |p| p.to,
                .staticcall => |p| p.to,
                .create => unreachable, // CREATE should use inner_create
                .create2 => unreachable, // CREATE2 should use inner_create
            };

            const input: []const u8 = params.getInput();
            const gas: u64 = params.getGas();

            const call_type: enum { Call, CallCode, DelegateCall, StaticCall } = switch (params) {
                .call => .Call,
                .callcode => .CallCode,
                .delegatecall => .DelegateCall,
                .staticcall => .StaticCall,
                else => unreachable,
            };

            // Depth limit (EELS: `depth + 1 > STACK_DEPTH_LIMIT`), checked before anything is
            // pushed or snapshotted. The forwarded gas returns to the caller.
            if (!self.canPushFrame()) return failedResult(gas);

            // Caller and execution address by call type:
            //   CALL / STATICCALL: caller = current frame, runs at the target address.
            //   CALLCODE:          caller = current frame, runs target code at the current address.
            //   DELEGATECALL:      caller and value inherited, runs target code at the current address.
            const current_frame = self.getCurrentFrame();
            const frame_caller = if (current_frame) |frame| frame.address else self.origin;
            const frame_caller_caller = if (current_frame) |frame| frame.caller else self.origin;
            const parent_value: u256 = if (current_frame) |frame| frame.value else 0;
            // STATICCALL creates a static context, and static context propagates to all nested calls
            const parent_is_static = if (current_frame) |frame| frame.is_static else false;
            const is_static = parent_is_static or call_type == .StaticCall;

            // CALLVALUE seen by the callee. DELEGATECALL inherits the parent's value (EIP-7)
            // without moving funds.
            const value: u256 = switch (params) {
                .call => |p| p.value,
                .callcode => |p| p.value,
                .delegatecall => parent_value,
                else => 0,
            };

            const execution_caller: primitives.Address = switch (call_type) {
                .Call, .StaticCall, .CallCode => frame_caller,
                .DelegateCall => frame_caller_caller,
            };
            const execution_address: primitives.Address = switch (call_type) {
                .Call, .StaticCall => address,
                .DelegateCall, .CallCode => frame_caller,
            };

            // Only CALL and CALLCODE require the caller to hold `value`.
            if (value > 0 and (call_type == .Call or call_type == .CallCode)) {
                if (self.get_balance(frame_caller) < value) return failedResult(gas);
            }

            var cp: Checkpoint = undefined;
            self.takeCheckpoint(&cp) catch return failedResult(gas);
            defer self.releaseCheckpoint(&cp);

            if (value > 0 and call_type == .Call) {
                self.transferValue(frame_caller, address, value) catch return self.failAndRevert(&cp);
            }

            // Code for the target (active precompiles always dispatch as precompiles).
            // `get_code` follows an EIP-7702 designator; a delegate that is a precompile
            // address contributes its (empty) account code and never runs the precompile.
            const is_precompile = Self.isPrecompileAddress(address, self.hardfork);
            const code = if (is_precompile) &[_]u8{} else self.get_code(address);
            if (code.len == 0) {
                var gas_left = gas;
                var output: []const u8 = &[_]u8{};
                switch (self.runPrecompile(tx_alloc, address, input, gas, is_precompile)) {
                    // A failed precompile consumes its gas and undoes the value transfer.
                    .failure => {
                        const failed = self.failAndRevert(&cp);
                        // EELS touches the target before running it and keeps the touch of
                        // RIPEMD-160 when the call fails (see `revertToCheckpoint`).
                        if (call_type == .Call and address.equals(RIPEMD160_ADDRESS)) {
                            self.touchAccount(address) catch return failedResult(0);
                        }
                        return failed;
                    },
                    .success => |done| {
                        gas_left = done.gas_left;
                        output = done.output;
                    },
                    // A plain account without code: the call succeeds with no output.
                    .none => {},
                }
                if (call_type == .Call) {
                    self.touchCallTarget(address) catch return self.failAndRevert(&cp);
                }
                return CallResult{ .success = true, .gas_left = gas_left, .output = output };
            }

            // Gas above i64::MAX cannot be spent; cap instead of trapping on the cast.
            const frame_gas = std.math.cast(i64, gas) orelse std.math.maxInt(i64);
            const child_frame = FrameType.init(
                tx_alloc,
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
            // Resolving the callee already hit missing async data: do not run it on a guess.
            if (self.async_restart_pending) return self.failAndRevert(&cp);
            // `canPushFrame` reserved the slot: this never reallocates `frames`.
            self.frames.appendAssumeCapacity(child_frame);
            const frame_index = self.frames.items.len - 1;

            self.frames.items[frame_index].execute() catch |err| {
                self.frames.shrinkRetainingCapacity(frame_index);
                // Missing async data is not a failure of the callee. This function cannot
                // return an error, so the request is recorded, every ancestor frame is stopped
                // and the executor replays the transaction once the host has answered. In a
                // synchronous `call()` nothing can answer, so the callee fails as before.
                if (err == error.NeedAsyncData) self.requestAsyncRestart(self.storage.async_data_request);
                // Exceptional halt: all forwarded gas is consumed.
                return self.failAndRevert(&cp);
            };
            if (self.async_restart_pending) {
                // The callee (or a descendant) was stopped for missing data; its result is void.
                self.frames.shrinkRetainingCapacity(frame_index);
                return self.failAndRevert(&cp);
            }

            const frame = &self.frames.items[frame_index];
            const reverted = frame.reverted;
            const gas_left = @as(u64, @intCast(@max(frame.gas_remaining, 0)));
            const output: []const u8 = if (frame.output.len > 0)
                (tx_alloc.dupe(u8, frame.output) catch {
                    self.frames.shrinkRetainingCapacity(frame_index);
                    return self.failAndRevert(&cp);
                })
            else
                &[_]u8{};
            self.frames.shrinkRetainingCapacity(frame_index);

            if (reverted) {
                self.revertToCheckpoint(&cp) catch return failedResult(0);
                return CallResult{ .success = false, .gas_left = gas_left, .output = output };
            }

            if (call_type == .Call) {
                self.touchCallTarget(address) catch return self.failAndRevert(&cp);
            }
            return CallResult{ .success = true, .gas_left = gas_left, .output = output };
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
            const failed_all_gas = CreateResult{
                .address = primitives.ZERO_ADDRESS,
                .success = false,
                .gas_left = 0,
                .output = &[_]u8{},
            };
            const failed_gas_returned = CreateResult{
                .address = primitives.ZERO_ADDRESS,
                .success = false,
                .gas_left = gas,
                .output = &[_]u8{},
            };

            // 1. EIP-3860 (Shanghai+): oversize init code is an out-of-gas halt of the calling
            //    frame. It is checked before balance, nonce and depth, which only push 0.
            if (self.hardfork.isAtLeast(.SHANGHAI) and init_code.len > primitives.GasConstants.MaxInitcodeSize) {
                return error.OutOfGas;
            }

            // 2. Insufficient balance, nonce overflow or depth limit: fail, gas is returned.
            const sender_nonce = self.getNonce(caller);
            //    The nonce guard belongs to whoever increments it: the opcode does so below,
            //    while a creation transaction arrives already incremented (possibly to 2^64-1
            //    from the last valid nonce 2^64-2) and is not incremented again.
            if ((value > 0 and self.get_balance(caller) < value) or
                (!is_top_level_create and sender_nonce == std.math.maxInt(u64)) or
                !self.canPushFrame())
            {
                return failed_gas_returned;
            }

            // 3. Derive the new address once.
            const new_address = if (salt) |s|
                try self.computeCreate2Address(caller, s, init_code)
            else blk: {
                // Creation transaction: the processor already incremented the sender nonce
                // (EELS message.py uses `nonce - 1`). Opcode: the current nonce.
                const address_nonce = if (is_top_level_create and sender_nonce > 0) sender_nonce - 1 else sender_nonce;
                break :blk try self.computeCreateAddress(caller, address_nonce);
            };

            // 4. EIP-2929 (Berlin): the new address is warm from here on, even if creation fails.
            if (self.hardfork.isAtLeast(.BERLIN)) {
                try self.access_list_manager.pre_warm_addresses(&[_]primitives.Address{new_address});
            }

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
                return failed_all_gas;
            }

            self.clearExistingEmptyAccountForCreate(new_address);

            // 6. Creator-side nonce increment survives a failed creation, so it happens
            //    before the checkpoint (opcodes only; transactions are handled by the processor).
            if (!is_top_level_create) try self.setNonceWithSnapshot(caller, sender_nonce + 1);

            // 7. Everything below is one unit: any failure restores storage, original and
            //    transient storage, logs, balances, nonces, code, created/self-destructed/touched
            //    sets, warm sets and the refund counter to this point.
            var cp: Checkpoint = undefined;
            try self.takeCheckpoint(&cp);
            defer self.releaseCheckpoint(&cp);
            errdefer self.revertBestEffort(&cp);

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

            // Gas above i64::MAX cannot be spent; cap instead of trapping on the cast.
            const frame_gas = std.math.cast(i64, gas) orelse std.math.maxInt(i64);
            const init_frame = try FrameType.init(
                self.tx_arena.allocator(),
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
            // The balance, nonce or collision checks above ran on missing async data: unwind
            // (the `errdefer` rolls back) and let the executor fetch it and replay.
            if (self.async_restart_pending) return error.NeedAsyncData;
            // `canPushFrame` reserved the slot: this never reallocates `frames`.
            self.frames.appendAssumeCapacity(init_frame);
            const frame_index = self.frames.items.len - 1;

            self.frames.items[frame_index].execute() catch |err| {
                self.frames.shrinkRetainingCapacity(frame_index);
                try self.revertToCheckpoint(&cp);
                if (err == error.NeedAsyncData and self.async_active) {
                    // Init code needs data the host has not supplied: propagate instead of
                    // failing the creation, so the transaction is replayed with the data.
                    self.requestAsyncRestart(self.storage.async_data_request);
                    return error.NeedAsyncData;
                }
                // Exceptional halt in init code: all gas consumed, no return data.
                return failed_all_gas;
            };
            if (self.async_restart_pending) {
                self.frames.shrinkRetainingCapacity(frame_index);
                return error.NeedAsyncData;
            }

            const frame = &self.frames.items[frame_index];
            const reverted = frame.reverted;
            var gas_left = @as(u64, @intCast(@max(frame.gas_remaining, 0)));
            const frame_output = frame.output;
            self.frames.shrinkRetainingCapacity(frame_index);

            if (reverted) {
                // REVERT is the only failure that returns data and unused gas.
                try self.revertToCheckpoint(&cp);
                return .{
                    .address = primitives.ZERO_ADDRESS,
                    .success = false,
                    .gas_left = gas_left,
                    .output = frame_output,
                };
            }

            // 8. Code deposit. EIP-3541 (London): code may not start with 0xEF. Deposit costs
            //    200 gas per byte. EIP-170 (Spurious Dragon): code may not exceed 24576 bytes.
            //    Any violation is an exceptional halt of the creation: full rollback, all gas
            //    consumed, empty return data.
            var deployed_code = frame_output;
            const deposit_cost = std.math.mul(u64, @as(u64, @intCast(frame_output.len)), GasConstants.CreateDataGas) catch std.math.maxInt(u64);
            const deposit_out_of_gas = gas_left < deposit_cost;
            const ef_prefix = self.hardfork.isAtLeast(.LONDON) and frame_output.len > 0 and frame_output[0] == 0xEF;
            const exceeds_size = self.hardfork.isAtLeast(.SPURIOUS_DRAGON) and frame_output.len > 24576;

            if (deposit_out_of_gas and self.hardfork.isBefore(.HOMESTEAD)) {
                // Frontier: an unaffordable deposit still creates the account, with empty code
                // and without charging the deposit (EIP-2 changed this in Homestead).
                deployed_code = &[_]u8{};
            } else if (ef_prefix or deposit_out_of_gas or exceeds_size) {
                try self.revertToCheckpoint(&cp);
                return failed_all_gas;
            } else {
                gas_left -= deposit_cost;
            }

            try self.setCodeWithSnapshot(new_address, deployed_code);

            return .{
                .address = new_address,
                .success = true,
                .gas_left = gas_left,
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
        pub fn get_delegated_target(self: *Self, address: primitives.Address) ?primitives.Address {
            if (!self.hardfork.isAtLeast(.PRAGUE)) return null;
            const raw_code = self.get_raw_code(address);
            if (raw_code.len != 23 or raw_code[0] != 0xef or raw_code[1] != 0x01 or raw_code[2] != 0x00) return null;
            var target: primitives.Address = undefined;
            @memcpy(&target.bytes, raw_code[3..23]);
            return target;
        }

        /// Executable code for `address`: follows one level of EIP-7702 delegation.
        /// A delegate that itself holds a designator is returned as-is (no chaining).
        /// Use `get_raw_code` to inspect what the account actually stores.
        pub fn get_code(self: *Self, address: primitives.Address) []const u8 {
            if (self.get_delegated_target(address)) |delegate| return self.get_raw_code(delegate);
            return self.get_raw_code(address);
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
