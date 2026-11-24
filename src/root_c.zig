/// C wrapper for Evm - minimal interface for WASM
const std = @import("std");
const evm = @import("evm.zig");
const evm_config_mod = @import("evm_config.zig");
const EvmConfig = evm_config_mod.EvmConfig;
const OpcodeOverride = evm_config_mod.OpcodeOverride;
const PrecompileOverride = evm_config_mod.PrecompileOverride;
const PrecompileOutput = evm_config_mod.PrecompileOutput;

// External JavaScript callback functions (provided as WASM imports)
// These are called BY WASM to execute custom handlers defined in JavaScript

const builtin = @import("builtin");

// Only declare extern functions when building for WASM
const js_opcode_callback = if (builtin.target.cpu.arch == .wasm32 or builtin.target.cpu.arch == .wasm64)
    struct {
        extern "env" fn js_opcode_callback(opcode: u8, frame_ptr: usize) c_int;
    }.js_opcode_callback
else
    undefined;

const js_precompile_callback = if (builtin.target.cpu.arch == .wasm32 or builtin.target.cpu.arch == .wasm64)
    struct {
        extern "env" fn js_precompile_callback(
            address_ptr: [*]const u8,
            input_ptr: [*]const u8,
            input_len: usize,
            gas_limit: u64,
            output_len: *usize,
            output_ptr: *[*]u8,
            gas_used: *u64,
        ) c_int;
    }.js_precompile_callback
else
    undefined;

/// Public wrapper to check if JavaScript opcode callback exists and call it
pub fn tryCallJsOpcodeHandler(opcode: u8, frame_ptr: usize) bool {
    if (builtin.target.cpu.arch == .wasm32 or builtin.target.cpu.arch == .wasm64) {
        const result = js_opcode_callback(opcode, frame_ptr);
        return result != 0;
    }
    return false;
}

/// Public wrapper to check if JavaScript precompile callback exists and call it
pub fn tryCallJsPrecompileHandler(
    address_ptr: [*]const u8,
    input_ptr: [*]const u8,
    input_len: usize,
    gas_limit: u64,
    output_len: *usize,
    output_ptr: *[*]u8,
    gas_used: *u64,
) bool {
    if (builtin.target.cpu.arch == .wasm32 or builtin.target.cpu.arch == .wasm64) {
        const result = js_precompile_callback(
            address_ptr,
            input_ptr,
            input_len,
            gas_limit,
            output_len,
            output_ptr,
            gas_used,
        );
        return result != 0;
    }
    return false;
}

// Use default config for C API (hardfork specified at runtime in evm_create)
const Evm = evm.Evm(.{});
const CallResult = Evm.CallResult;
const CallParams = Evm.CallParams;
const StorageKey = evm.StorageKey;
const AccessListStorageKey = primitives.State.StorageKey;
const StorageInjector = @import("storage_injector.zig").StorageInjector;
const primitives = @import("voltaire");
const Address = primitives.Address.Address;
const ZERO_ADDRESS = primitives.ZERO_ADDRESS;

// Global allocator for C interface. A `var` so tests can substitute a
// leak-checking allocator.
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var allocator = gpa.allocator();

/// Alignment of every evm_alloc buffer. Covers `AsyncRequest` and any scalar
/// out-parameter a host places in a transfer buffer.
const transfer_alignment: std.mem.Alignment = .@"16";

/// Allocate a host transfer buffer in the module's linear memory.
/// Returns null for zero length or allocation failure. The buffer is 16-byte
/// aligned. Release with evm_free using the same pointer and length after the
/// C API has copied the input.
export fn evm_alloc(len: usize) ?[*]u8 {
    if (len == 0) return null;
    const buffer = allocator.alignedAlloc(u8, transfer_alignment, len) catch return null;
    return buffer.ptr;
}

/// Release a transfer buffer returned by evm_alloc. Null is a no-op.
export fn evm_free(ptr: ?[*]u8, len: usize) void {
    const buffer = ptr orelse return;
    if (len == 0) return;
    const aligned: [*]align(transfer_alignment.toByteUnits()) u8 = @alignCast(buffer);
    allocator.free(aligned[0..len]);
}

// Opaque handle for EVM instance
const EvmHandle = opaque {};

// Note: Custom handlers are now registered via JavaScript imports (js_opcode_callback, js_precompile_callback)
// No runtime storage needed in Zig since JavaScript manages the handler registry

const AccessListEntry = primitives.AccessList.AccessListEntry;

// Store execution context for later use
const ExecutionContext = struct {
    evm: *Evm,
    bytecode: []const u8,
    gas: i64,
    caller: Address,
    address: Address,
    value: u256,
    calldata: []const u8,
    access_list_addresses: []Address,
    access_list_storage_keys: []AccessListStorageKey,
    blob_versioned_hashes: ?[]const [32]u8,
    result: ?CallResult,
    /// Gas limit of the call that produced `result` (for evm_get_gas_used).
    result_gas_limit: i64 = 0,
    /// Code copies made by evm_set_code. The EVM's code map only borrows them,
    /// so each copy is freed here on replacement and in evm_destroy.
    owned_code: std.AutoHashMapUnmanaged(Address, []u8) = .empty,
    /// Injector created by evm_enable_storage_injector, freed in evm_destroy.
    injector: ?*StorageInjector = null,
    /// True while evm_execute, evm_call_ffi or evm_continue_ffi runs on this
    /// handle. A host callback (js_opcode_callback, js_precompile_callback)
    /// fires inside that window with frames borrowing the handle's buffers, so
    /// execution entries and mutating setters are rejected and evm_destroy is
    /// deferred. Read-only getters stay available.
    in_flight: bool = false,
    /// Set by evm_destroy while `in_flight`; the outermost entry destroys the
    /// handle on exit.
    destroy_pending: bool = false,
};

/// Context for an operation that mutates the handle or starts execution:
/// null for a null handle or while the handle is executing.
fn idleContextOf(handle: ?*EvmHandle) ?*ExecutionContext {
    const ctx = contextOf(handle) orelse return null;
    if (ctx.in_flight) return null;
    return ctx;
}

/// Leave an execution entry. Returns false when evm_destroy was requested
/// during the entry and the handle has now been destroyed.
fn leaveExecution(ctx: *ExecutionContext) bool {
    ctx.in_flight = false;
    if (!ctx.destroy_pending) return true;
    destroyContext(ctx);
    return false;
}

// ----- Boundary helpers: every pointer from C/JS is optional -----

fn contextOf(handle: ?*EvmHandle) ?*ExecutionContext {
    const h = handle orelse return null;
    return @ptrCast(@alignCast(h));
}

fn readAddress(ptr: ?[*]const u8) ?Address {
    const p = ptr orelse return null;
    var address: Address = undefined;
    @memcpy(&address.bytes, p[0..20]);
    return address;
}

/// Read a 32-byte big-endian word.
fn readWord(ptr: ?[*]const u8) ?u256 {
    const p = ptr orelse return null;
    return std.mem.readInt(u256, p[0..32], .big);
}

/// View `len` input bytes. A null pointer is valid only for an empty input.
fn inputSlice(ptr: ?[*]const u8, len: usize) ?[]const u8 {
    if (len == 0) return &.{};
    const p = ptr orelse return null;
    return p[0..len];
}

/// Create a new Evm instance with optional hardfork name (null/empty = default from config)
/// log_level: 0=none, 1=err, 2=warn, 3=info, 4=debug
/// Returns null on allocation failure, an unknown hardfork name, a null name
/// with a non-zero length, or a log level above 4.
pub export fn evm_create(hardfork_name: ?[*]const u8, hardfork_len: usize, log_level: u8) ?*EvmHandle {
    const log = @import("logger.zig");
    const log_level_enum = std.meta.intToEnum(log.LogLevel, log_level) catch return null;

    const Hardfork = primitives.Hardfork;
    const hardfork_slice = inputSlice(hardfork_name, hardfork_len) orelse return null;
    const hardfork: ?Hardfork = if (hardfork_slice.len == 0)
        null
    else
        Hardfork.fromString(hardfork_slice) orelse return null;

    const ctx = allocator.create(ExecutionContext) catch return null;

    const evm_ptr = allocator.create(Evm) catch {
        allocator.destroy(ctx);
        return null;
    };

    Evm.init(evm_ptr, allocator, null, hardfork, null, primitives.ZERO_ADDRESS, 0, log_level_enum) catch {
        allocator.destroy(evm_ptr);
        allocator.destroy(ctx);
        return null;
    };

    ctx.* = ExecutionContext{
        .evm = evm_ptr,
        .bytecode = &[_]u8{},
        .gas = 0,
        .caller = ZERO_ADDRESS,
        .address = ZERO_ADDRESS,
        .value = 0,
        .calldata = &[_]u8{},
        .access_list_addresses = &[_]Address{},
        .access_list_storage_keys = &[_]AccessListStorageKey{},
        .blob_versioned_hashes = null,
        .result = null,
    };

    return @ptrCast(ctx);
}

/// Destroy an EVM instance. Called from a host callback while the handle is
/// executing, destruction is deferred until that execution returns; the
/// handle must not be used after this call either way.
pub export fn evm_destroy(handle: ?*EvmHandle) void {
    const ctx = contextOf(handle) orelse return;
    if (ctx.in_flight) {
        ctx.destroy_pending = true;
        return;
    }
    destroyContext(ctx);
}

fn destroyContext(ctx: *ExecutionContext) void {
    ctx.evm.deinit();
    if (ctx.injector) |injector| {
        injector.deinit();
        allocator.destroy(injector);
    }
    var code_it = ctx.owned_code.valueIterator();
    while (code_it.next()) |code| allocator.free(code.*);
    ctx.owned_code.deinit(allocator);
    allocator.free(ctx.bytecode);
    allocator.free(ctx.calldata);
    allocator.free(ctx.access_list_addresses);
    allocator.free(ctx.access_list_storage_keys);
    if (ctx.blob_versioned_hashes) |hashes| allocator.free(hashes);
    allocator.destroy(ctx.evm);
    allocator.destroy(ctx);
}

/// Set bytecode for execution. `bytecode` may be null when `bytecode_len` is 0.
pub export fn evm_set_bytecode(handle: ?*EvmHandle, bytecode: ?[*]const u8, bytecode_len: usize) bool {
    const ctx = idleContextOf(handle) orelse return false;
    const source = inputSlice(bytecode, bytecode_len) orelse return false;
    const bytecode_copy = allocator.dupe(u8, source) catch return false;

    allocator.free(ctx.bytecode);
    ctx.bytecode = bytecode_copy;
    return true;
}

/// Set execution context.
/// Returns false and leaves the previous context untouched when `gas` is
/// negative, a required pointer is null, or the calldata copy cannot be allocated.
/// `calldata` may be null when `calldata_len` is 0.
pub export fn evm_set_execution_context(
    handle: ?*EvmHandle,
    gas: i64,
    caller_bytes: ?[*]const u8, // 20 bytes
    address_bytes: ?[*]const u8, // 20 bytes
    value_bytes: ?[*]const u8, // 32 bytes representing u256
    calldata: ?[*]const u8,
    calldata_len: usize,
) bool {
    const ctx = idleContextOf(handle) orelse return false;

    // Validate everything and allocate before publishing any field.
    if (gas < 0) return false;
    const caller = readAddress(caller_bytes) orelse return false;
    const address = readAddress(address_bytes) orelse return false;
    const value = readWord(value_bytes) orelse return false;
    const calldata_source = inputSlice(calldata, calldata_len) orelse return false;
    const calldata_copy = allocator.dupe(u8, calldata_source) catch return false;

    allocator.free(ctx.calldata);
    ctx.calldata = calldata_copy;
    ctx.gas = gas;
    ctx.caller = caller;
    ctx.address = address;
    ctx.value = value;
    return true;
}

/// Set the transaction origin reported by ORIGIN and warmed as the sender
/// (EIP-2929). Defaults to the zero address. Persists across calls.
pub export fn evm_set_origin(handle: ?*EvmHandle, origin_bytes: ?[*]const u8) bool {
    const ctx = idleContextOf(handle) orelse return false;
    ctx.evm.origin = readAddress(origin_bytes) orelse return false;
    return true;
}

/// Set the effective gas price reported by GASPRICE (32-byte big-endian).
/// Defaults to zero. Persists across calls.
pub export fn evm_set_gas_price(handle: ?*EvmHandle, gas_price_bytes: ?[*]const u8) bool {
    const ctx = idleContextOf(handle) orelse return false;
    ctx.evm.gas_price = readWord(gas_price_bytes) orelse return false;
    return true;
}

/// Set blockchain context (required before execution).
/// A null handle or any null pointer leaves the context unchanged.
export fn evm_set_blockchain_context(
    handle: ?*EvmHandle,
    chain_id_bytes: ?[*]const u8, // 32 bytes
    block_number: u64,
    block_timestamp: u64,
    block_difficulty_bytes: ?[*]const u8, // 32 bytes
    block_prevrandao_bytes: ?[*]const u8, // 32 bytes
    block_coinbase_bytes: ?[*]const u8, // 20 bytes
    block_gas_limit: u64,
    block_base_fee_bytes: ?[*]const u8, // 32 bytes
    blob_base_fee_bytes: ?[*]const u8, // 32 bytes
) void {
    const ctx = idleContextOf(handle) orelse return;

    const chain_id = readWord(chain_id_bytes) orelse return;
    const block_difficulty = readWord(block_difficulty_bytes) orelse return;
    const block_prevrandao = readWord(block_prevrandao_bytes) orelse return;
    const block_coinbase = readAddress(block_coinbase_bytes) orelse return;
    const block_base_fee = readWord(block_base_fee_bytes) orelse return;
    const blob_base_fee = readWord(blob_base_fee_bytes) orelse return;

    ctx.evm.block_context = .{
        .chain_id = chain_id,
        .block_number = block_number,
        .block_timestamp = block_timestamp,
        .block_difficulty = block_difficulty,
        .block_prevrandao = block_prevrandao,
        .block_coinbase = block_coinbase,
        .block_gas_limit = block_gas_limit,
        .block_base_fee = block_base_fee,
        .blob_base_fee = blob_base_fee,
    };
}

/// Set access list addresses (EIP-2930) - call before execute.
/// On failure the previous list is kept.
export fn evm_set_access_list_addresses(
    handle: ?*EvmHandle,
    addresses: ?[*]const u8, // Packed 20-byte addresses
    count: usize,
) bool {
    const ctx = idleContextOf(handle) orelse return false;

    if (count == 0) {
        allocator.free(ctx.access_list_addresses);
        ctx.access_list_addresses = &[_]Address{};
        return true;
    }
    const source = addresses orelse return false;

    const addr_list = allocator.alloc(Address, count) catch return false;
    for (addr_list, 0..) |*entry, i| {
        @memcpy(&entry.bytes, source[i * 20 ..][0..20]);
    }

    allocator.free(ctx.access_list_addresses);
    ctx.access_list_addresses = addr_list;
    return true;
}

/// Set access list storage keys (EIP-2930) - call before execute.
/// Every key is warmed together with its address, whether or not that address
/// was also passed to evm_set_access_list_addresses. On failure the previous
/// list is kept.
export fn evm_set_access_list_storage_keys(
    handle: ?*EvmHandle,
    addresses: ?[*]const u8, // Packed 20-byte addresses
    slots: ?[*]const u8, // Packed 32-byte slots
    count: usize,
) bool {
    const ctx = idleContextOf(handle) orelse return false;

    if (count == 0) {
        allocator.free(ctx.access_list_storage_keys);
        ctx.access_list_storage_keys = &[_]AccessListStorageKey{};
        return true;
    }
    const address_source = addresses orelse return false;
    const slot_source = slots orelse return false;

    const keys = allocator.alloc(AccessListStorageKey, count) catch return false;
    for (keys, 0..) |*key, i| {
        var address: [20]u8 = undefined;
        @memcpy(&address, address_source[i * 20 ..][0..20]);
        key.* = .{
            .address = address,
            .slot = std.mem.readInt(u256, slot_source[i * 32 ..][0..32], .big),
        };
    }

    allocator.free(ctx.access_list_storage_keys);
    ctx.access_list_storage_keys = keys;
    return true;
}

/// Set blob versioned hashes (EIP-4844) - call before execute.
/// `count == 0` clears them; the next call then sees no blob hashes.
export fn evm_set_blob_hashes(
    handle: ?*EvmHandle,
    hashes: ?[*]const u8, // Packed 32-byte hashes
    count: usize,
) bool {
    const ctx = idleContextOf(handle) orelse return false;

    if (count == 0) {
        if (ctx.blob_versioned_hashes) |old_hashes| allocator.free(old_hashes);
        ctx.blob_versioned_hashes = null;
        return true;
    }
    const source = hashes orelse return false;

    const hash_list = allocator.alloc([32]u8, count) catch return false;
    for (hash_list, 0..) |*hash, i| {
        @memcpy(hash, source[i * 32 ..][0..32]);
    }

    if (ctx.blob_versioned_hashes) |old_hashes| allocator.free(old_hashes);
    ctx.blob_versioned_hashes = hash_list;
    return true;
}

/// Build the EIP-2930 access list from the flat C API format.
///
/// Addresses keep their first-seen order. A storage key whose address was not
/// listed separately still produces an entry for that address. Returns null
/// when both inputs are empty. On error nothing is leaked. Free the result
/// with `freeAccessList`.
pub fn buildAccessList(
    gpa_allocator: std.mem.Allocator,
    addresses: []const Address,
    storage_keys: []const AccessListStorageKey,
) error{OutOfMemory}!?[]AccessListEntry {
    if (addresses.len == 0 and storage_keys.len == 0) return null;

    const Group = struct {
        address: Address,
        keys: std.ArrayListUnmanaged([32]u8) = .empty,
    };
    var groups: std.ArrayListUnmanaged(Group) = .empty;
    defer {
        for (groups.items) |*group| group.keys.deinit(gpa_allocator);
        groups.deinit(gpa_allocator);
    }
    var index_of: std.AutoHashMapUnmanaged(Address, usize) = .empty;
    defer index_of.deinit(gpa_allocator);

    for (addresses) |address| {
        const slot = try index_of.getOrPut(gpa_allocator, address);
        if (slot.found_existing) continue;
        slot.value_ptr.* = groups.items.len;
        try groups.append(gpa_allocator, .{ .address = address });
    }

    for (storage_keys) |storage_key| {
        const address = Address{ .bytes = storage_key.address };
        const slot = try index_of.getOrPut(gpa_allocator, address);
        if (!slot.found_existing) {
            slot.value_ptr.* = groups.items.len;
            try groups.append(gpa_allocator, .{ .address = address });
        }
        var hash: [32]u8 = undefined;
        std.mem.writeInt(u256, &hash, storage_key.slot, .big);
        try groups.items[slot.value_ptr.*].keys.append(gpa_allocator, hash);
    }

    const list = try gpa_allocator.alloc(AccessListEntry, groups.items.len);
    var built: usize = 0;
    errdefer {
        for (list[0..built]) |entry| gpa_allocator.free(entry.storage_keys);
        gpa_allocator.free(list);
    }
    for (groups.items, list) |*group, *entry| {
        entry.* = .{
            .address = group.address,
            .storage_keys = try group.keys.toOwnedSlice(gpa_allocator),
        };
        built += 1;
    }
    return list;
}

/// Free a list returned by `buildAccessList`.
pub fn freeAccessList(gpa_allocator: std.mem.Allocator, access_list: ?[]AccessListEntry) void {
    const list = access_list orelse return;
    for (list) |entry| gpa_allocator.free(entry.storage_keys);
    gpa_allocator.free(list);
}

/// Execute the EVM with current context.
/// Returns the EVM success flag. A false return with no readable result
/// (evm_get_output_len == 0, evm_is_success == false) also covers a null
/// handle, allocation failure, a call made while the handle is already
/// executing, and a handle destroyed by a host callback during the call.
/// Calling an address with no code succeeds.
///
/// Code installed with evm_set_code (including an EIP-7702 delegation
/// designator) takes precedence; evm_set_bytecode supplies the code only for
/// a target that has none. Starting a synchronous call cancels any async
/// transaction suspended by evm_call_ffi.
export fn evm_execute(handle: ?*EvmHandle) bool {
    const ctx = idleContextOf(handle) orelse return false;
    ctx.in_flight = true;
    const success = executeSync(ctx);
    return leaveExecution(ctx) and success;
}

fn executeSync(ctx: *ExecutionContext) bool {
    // A failed call must never leave the previous call's result readable.
    ctx.result = null;
    if (ctx.gas < 0) return false;
    cancelAsync(ctx);

    const access_list = buildAccessList(allocator, ctx.access_list_addresses, ctx.access_list_storage_keys) catch return false;
    defer freeAccessList(allocator, access_list);
    // The EVM only borrows the list. Drop its reference before the list is
    // freed so no later call can read a dangling pending_access_list.
    defer ctx.evm.setAccessList(null);

    // Create CallParams for regular CALL operation
    const call_params = buildCallParams(ctx);

    // Set bytecode, access list, and blob hashes. An empty slice clears hashes
    // left behind by an earlier blob transaction. `call()` consumes the
    // pending bytecode only when the target has no installed code, and never
    // writes it into the code map.
    ctx.evm.setBytecode(ctx.bytecode);
    ctx.evm.setAccessList(access_list);
    ctx.evm.setBlobVersionedHashes(ctx.blob_versioned_hashes orelse &.{});

    const result = ctx.evm.call(call_params);

    ctx.result = result;
    ctx.result_gas_limit = ctx.gas;
    return result.success;
}

/// True when evm_set_code (or a previous transaction) installed nonempty code
/// at the call target. Such code always takes precedence over evm_set_bytecode.
fn hasInstalledCode(ctx: *ExecutionContext) bool {
    const code = ctx.evm.code.get(ctx.address) orelse return false;
    return code.len > 0;
}

/// Abandon an async transaction left suspended (awaiting data or commit) by
/// evm_call_ffi, so a later evm_continue_ffi fails instead of resuming stale
/// frames or replaying the previous transaction's result.
fn cancelAsync(ctx: *ExecutionContext) void {
    ctx.evm.pending_precompile_result = null;
    const executor = ctx.evm.async_executor orelse return;
    if (executor.phase != .idle) {
        ctx.evm.frames.clearRetainingCapacity();
        if (ctx.injector) |injector| injector.clearDirty();
    }
    ctx.evm.storage.clear_async_request();
    ctx.evm.async_executor = null;
}

/// Get gas remaining after execution
export fn evm_get_gas_remaining(handle: ?*EvmHandle) i64 {
    const ctx = contextOf(handle) orelse return 0;
    const result = ctx.result orelse return 0;
    return std.math.cast(i64, result.gas_left) orelse std.math.maxInt(i64);
}

/// Get gas used during execution: the gas limit of the call that produced the
/// current result minus its remaining gas. Changing the execution context for
/// a later call does not alter this value.
export fn evm_get_gas_used(handle: ?*EvmHandle) i64 {
    const ctx = contextOf(handle) orelse return 0;
    const result = ctx.result orelse return 0;
    const gas_left = std.math.cast(i64, result.gas_left) orelse std.math.maxInt(i64);
    return @max(ctx.result_gas_limit - gas_left, 0);
}

/// Check if execution was successful
export fn evm_is_success(handle: ?*EvmHandle) bool {
    const ctx = contextOf(handle) orelse return false;
    const result = ctx.result orelse return false;
    return result.success;
}

/// Get output data length
export fn evm_get_output_len(handle: ?*EvmHandle) usize {
    const ctx = contextOf(handle) orelse return 0;
    const result = ctx.result orelse return 0;
    return result.output.len;
}

/// Copy output data to buffer. Returns the number of bytes copied (0 for a
/// null buffer).
export fn evm_get_output(handle: ?*EvmHandle, buffer: ?[*]u8, buffer_len: usize) usize {
    const ctx = contextOf(handle) orelse return 0;
    const result = ctx.result orelse return 0;
    const out = buffer orelse return 0;
    const copy_len = @min(buffer_len, result.output.len);
    if (copy_len > 0) @memcpy(out[0..copy_len], result.output[0..copy_len]);
    return copy_len;
}

// Custom handlers are now registered via JavaScript import callbacks
// (js_opcode_callback and js_precompile_callback defined at top of file)
// No registration functions needed - JavaScript provides the callbacks at WASM instantiation

/// Set storage value for an address
export fn evm_set_storage(
    handle: ?*EvmHandle,
    address_bytes: ?[*]const u8, // 20 bytes
    slot_bytes: ?[*]const u8, // 32 bytes
    value_bytes: ?[*]const u8, // 32 bytes
) bool {
    const ctx = idleContextOf(handle) orelse return false;
    const address = readAddress(address_bytes) orelse return false;
    const slot = readWord(slot_bytes) orelse return false;
    const value = readWord(value_bytes) orelse return false;

    ctx.evm.storage.storage.put(StorageKey{ .address = address.bytes, .slot = slot }, value) catch return false;
    return true;
}

/// Get storage value for an address
export fn evm_get_storage(
    handle: ?*EvmHandle,
    address_bytes: ?[*]const u8, // 20 bytes
    slot_bytes: ?[*]const u8, // 32 bytes
    value_bytes: ?[*]u8, // 32 bytes output
) bool {
    const ctx = contextOf(handle) orelse return false;
    const address = readAddress(address_bytes) orelse return false;
    const slot = readWord(slot_bytes) orelse return false;
    const out = value_bytes orelse return false;

    std.mem.writeInt(u256, out[0..32], ctx.evm.storage.peek(address, slot), .big);
    return true;
}

/// Set account balance
export fn evm_set_balance(
    handle: ?*EvmHandle,
    address_bytes: ?[*]const u8, // 20 bytes
    balance_bytes: ?[*]const u8, // 32 bytes
) bool {
    const ctx = idleContextOf(handle) orelse return false;
    const address = readAddress(address_bytes) orelse return false;
    const balance = readWord(balance_bytes) orelse return false;

    ctx.evm.balances.put(address, balance) catch return false;
    return true;
}

/// Set account code. `code` may be null when `code_len` is 0.
/// The handle owns its copy: replacing the code of an address frees the
/// previous copy, and evm_destroy frees the rest.
export fn evm_set_code(
    handle: ?*EvmHandle,
    address_bytes: ?[*]const u8, // 20 bytes
    code: ?[*]const u8,
    code_len: usize,
) bool {
    const ctx = idleContextOf(handle) orelse return false;
    const address = readAddress(address_bytes) orelse return false;
    const source = inputSlice(code, code_len) orelse return false;

    const code_copy = allocator.dupe(u8, source) catch return false;
    ctx.owned_code.ensureUnusedCapacity(allocator, 1) catch {
        allocator.free(code_copy);
        return false;
    };
    ctx.evm.code.put(address, code_copy) catch {
        allocator.free(code_copy);
        return false;
    };
    // The EVM map now points at the new copy, so the old one can go.
    if (ctx.owned_code.fetchPutAssumeCapacity(address, code_copy)) |previous| {
        allocator.free(previous.value);
    }
    return true;
}

/// Set account nonce
export fn evm_set_nonce(
    handle: ?*EvmHandle,
    address_bytes: ?[*]const u8, // 20 bytes
    nonce: u64,
) bool {
    const ctx = idleContextOf(handle) orelse return false;
    const address = readAddress(address_bytes) orelse return false;

    ctx.evm.nonces.put(address, nonce) catch return false;
    return true;
}

// ===== Async Protocol FFI Functions =====

/// Inline fast-path capacity of `AsyncRequest.json_data`.
pub const ASYNC_JSON_INLINE_CAPACITY: usize = 16384;

/// Output structure for async requests.
///
/// `output_type`:
///   0   = result: the call finished (success, revert or exceptional halt);
///         read it with evm_is_success / evm_get_output / evm_get_gas_remaining
///   1-4 = need_storage / need_balance / need_code / need_nonce
///   5   = ready_to_commit (only after a successful execution)
///   255 = host-side failure: invalid arguments, a continuation that does not
///         answer the outstanding request, or allocation failure. No result
///         is readable.
///
/// For `output_type == 5` (`ready_to_commit`):
/// - `json_len` ALWAYS holds the true, untruncated byte length of the state-changes JSON.
/// - Fast path (`json_len <= ASYNC_JSON_INLINE_CAPACITY`): `json_data[0..json_len]` holds the
///   complete JSON (trailing bytes zeroed), backwards-compatible with existing callers.
/// - Overflow (`json_len > ASYNC_JSON_INLINE_CAPACITY`): `json_data` is zero-filled (never a
///   truncated prefix). Callers fetch all bytes via `evm_get_state_changes_len` / `evm_get_state_changes`.
pub const AsyncRequest = extern struct {
    output_type: u8, // 0=result, 1=need_storage, 2=need_balance, 3=need_code, 4=need_nonce, 5=ready_to_commit
    address: [20]u8,
    slot: [32]u8, // Only used for storage requests
    // For ready_to_commit: full JSON byte length and inline fast-path buffer
    json_len: u32,
    json_data: [ASYNC_JSON_INLINE_CAPACITY]u8,
};

// Hosts read this struct by offset; keep the layout fixed.
comptime {
    std.debug.assert(@offsetOf(AsyncRequest, "output_type") == 0);
    std.debug.assert(@offsetOf(AsyncRequest, "address") == 1);
    std.debug.assert(@offsetOf(AsyncRequest, "slot") == 21);
    std.debug.assert(@offsetOf(AsyncRequest, "json_len") == 56);
    std.debug.assert(@offsetOf(AsyncRequest, "json_data") == 60);
    std.debug.assert(@sizeOf(AsyncRequest) == 60 + ASYNC_JSON_INLINE_CAPACITY);
    std.debug.assert(@alignOf(AsyncRequest) <= transfer_alignment.toByteUnits());
}

/// Pack state-changes JSON into a `ready_to_commit` request without ever truncating it.
/// Sets `json_len` to the full byte length; inlines bytes when `json.len <= 16384` (zeroing
/// trailing bytes), otherwise zero-fills `json_data`. Returns `false` (and sets `output_type = 255`)
/// only if `json.len` exceeds `maxInt(u32)` on 64-bit native hosts.
pub fn packStateChangesJson(json: []const u8, request_out: *AsyncRequest) bool {
    const full_len = std.math.cast(u32, json.len) orelse {
        request_out.output_type = 255;
        request_out.json_len = 0;
        @memset(&request_out.json_data, 0);
        return false;
    };
    request_out.output_type = 5;
    request_out.json_len = full_len;
    if (json.len <= request_out.json_data.len) {
        if (json.len > 0) {
            @memcpy(request_out.json_data[0..json.len], json);
        }
        if (json.len < request_out.json_data.len) {
            @memset(request_out.json_data[json.len..], 0);
        }
    } else {
        @memset(&request_out.json_data, 0);
    }
    return true;
}

/// All-or-nothing copy used by `evm_get_state_changes`: always returns `json.len`, and copies
/// every byte iff `buffer != null` and `buffer_len >= json.len`.
pub fn copyStateChanges(json: []const u8, buffer: ?[*]u8, buffer_len: usize) usize {
    if (json.len > 0 and buffer_len >= json.len) {
        if (buffer) |out| @memcpy(out[0..json.len], json);
    }
    return json.len;
}

/// Helper: Pack CallOrContinueOutput into AsyncRequest
fn packOutput(output: Evm.CallOrContinueOutput, ctx: *ExecutionContext, request_out: *AsyncRequest) bool {
    switch (output) {
        .result => |r| {
            ctx.result = r;
            request_out.output_type = 0;
            return true;
        },
        .need_storage => |req| {
            request_out.output_type = 1;
            @memcpy(&request_out.address, &req.address.bytes);
            std.mem.writeInt(u256, &request_out.slot, req.slot, .big);
            return true;
        },
        .need_balance => |req| {
            request_out.output_type = 2;
            @memcpy(&request_out.address, &req.address.bytes);
            return true;
        },
        .need_code => |req| {
            request_out.output_type = 3;
            @memcpy(&request_out.address, &req.address.bytes);
            return true;
        },
        .need_nonce => |req| {
            request_out.output_type = 4;
            @memcpy(&request_out.address, &req.address.bytes);
            return true;
        },
        .ready_to_commit => |data| {
            return packStateChangesJson(data.changes_json, request_out);
        },
    }
}

/// Reject a request on a null or currently executing handle without touching
/// the handle's state.
fn rejectRequest(request: *AsyncRequest) bool {
    request.output_type = 255;
    return false;
}

/// Report a host-side failure: tag 255 and no readable result.
fn failRequest(ctx: *ExecutionContext, request_out: *AsyncRequest) bool {
    ctx.result = null;
    request_out.output_type = 255;
    return false;
}

/// Helper: Build CallParams from ExecutionContext. `ctx.gas` is never negative:
/// evm_set_execution_context rejects it and the call entry points re-check.
fn buildCallParams(ctx: *ExecutionContext) CallParams {
    return CallParams{
        .call = .{
            .caller = ctx.caller,
            .to = ctx.address,
            .gas = @intCast(@max(ctx.gas, 0)),
            .value = ctx.value,
            .input = ctx.calldata,
        },
    };
}

/// Start EVM execution (async protocol)
/// Returns request in request_out, or sets output_type=0 if done.
/// A revert or exceptional halt is a completed call: the function returns true
/// with output_type=0 and evm_is_success reports false. A null handle or a
/// handle that is already executing (a re-entrant host callback) returns false
/// with output_type=255 and leaves the handle untouched.
pub export fn evm_call_ffi(
    handle: ?*EvmHandle,
    request_out: ?*AsyncRequest,
) bool {
    const request = request_out orelse return false;
    const ctx = idleContextOf(handle) orelse return rejectRequest(request);
    ctx.in_flight = true;
    const ok = startAsync(ctx, request);
    return leaveExecution(ctx) and ok;
}

fn startAsync(ctx: *ExecutionContext, request: *AsyncRequest) bool {
    // A failed call must never leave the previous call's result readable.
    ctx.result = null;
    if (ctx.gas < 0) return failRequest(ctx, request);

    const access_list = buildAccessList(allocator, ctx.access_list_addresses, ctx.access_list_storage_keys) catch {
        return failRequest(ctx, request);
    };
    defer freeAccessList(allocator, access_list);
    // See evm_execute: never leave a dangling pending_access_list behind.
    defer ctx.evm.setAccessList(null);

    // Set bytecode, access list, and blob hashes BEFORE calling. The executor
    // copies bytecode and calldata, so a suspended frame survives later setters.
    // The executor prefers pending bytecode over account code, so pass it only
    // for a target with no installed code, matching evm_execute.
    ctx.evm.setBytecode(if (hasInstalledCode(ctx)) &.{} else ctx.bytecode);
    ctx.evm.setAccessList(access_list);
    ctx.evm.setBlobVersionedHashes(ctx.blob_versioned_hashes orelse &.{});

    // Start execution with params from ctx
    const params = buildCallParams(ctx);
    ctx.result_gas_limit = ctx.gas;
    const output = ctx.evm.callOrContinue(.{ .call = params }) catch {
        return failRequest(ctx, request);
    };

    return packOutput(output, ctx, request);
}

/// Continue execution with async response
/// Returns next request in request_out, or output_type=0 if done.
/// The reply must answer the outstanding request (same kind, address and
/// slot); anything else returns false with output_type=255 and leaves the
/// suspended execution untouched. `data_ptr` may be null when `data_len` is 0.
pub export fn evm_continue_ffi(
    handle: ?*EvmHandle,
    continue_type: u8, // 1=storage, 2=balance, 3=code, 4=nonce, 5=after_commit
    data_ptr: ?[*]const u8,
    data_len: usize,
    request_out: ?*AsyncRequest,
) bool {
    const request = request_out orelse return false;
    const ctx = idleContextOf(handle) orelse return rejectRequest(request);
    ctx.in_flight = true;
    const ok = continueAsync(ctx, continue_type, data_ptr, data_len, request);
    return leaveExecution(ctx) and ok;
}

fn continueAsync(
    ctx: *ExecutionContext,
    continue_type: u8,
    data_ptr: ?[*]const u8,
    data_len: usize,
    request: *AsyncRequest,
) bool {
    const data = inputSlice(data_ptr, data_len) orelse return failRequest(ctx, request);

    // Build continue input based on type
    const input: Evm.CallOrContinueInput = switch (continue_type) {
        1 => blk: {
            // Storage: address(20) + slot(32) + value(32) = 84 bytes
            if (data.len < 84) return failRequest(ctx, request);
            break :blk .{ .continue_with_storage = .{
                .address = .{ .bytes = data[0..20].* },
                .slot = std.mem.readInt(u256, data[20..52], .big),
                .value = std.mem.readInt(u256, data[52..84], .big),
            } };
        },
        2 => blk: {
            // Balance: address(20) + balance(32) = 52 bytes
            if (data.len < 52) return failRequest(ctx, request);
            break :blk .{ .continue_with_balance = .{
                .address = .{ .bytes = data[0..20].* },
                .balance = std.mem.readInt(u256, data[20..52], .big),
            } };
        },
        3 => blk: {
            // Code: address(20) + code bytes (remainder). Answers a need_code request.
            if (data.len < 20) return failRequest(ctx, request);
            break :blk .{ .continue_with_code = .{
                .address = .{ .bytes = data[0..20].* },
                .code = data[20..],
            } };
        },
        4 => blk: {
            // Nonce: address(20) + nonce(8, big-endian). Answers a need_nonce request.
            if (data.len < 28) return failRequest(ctx, request);
            break :blk .{ .continue_with_nonce = .{
                .address = .{ .bytes = data[0..20].* },
                .nonce = std.mem.readInt(u64, data[20..28], .big),
            } };
        },
        5 => .{ .continue_after_commit = {} },
        else => return failRequest(ctx, request),
    };

    const output = ctx.evm.callOrContinue(input) catch {
        return failRequest(ctx, request);
    };

    return packOutput(output, ctx, request);
}

/// Get the full byte length of the pending state-changes JSON (valid when output_type == 5).
pub export fn evm_get_state_changes_len(handle: ?*EvmHandle) usize {
    const ctx = contextOf(handle) orelse return 0;
    return ctx.evm.getPendingStateChanges().len;
}

/// Get the full state-changes JSON (valid when output_type == 5 / ready_to_commit).
/// Always returns the full required byte length (`full_len`).
/// Copies all `full_len` bytes into `buffer` iff `buffer != null` and `buffer_len >= full_len`;
/// otherwise leaves `buffer` untouched (never writes half-truncated JSON).
pub export fn evm_get_state_changes(
    handle: ?*EvmHandle,
    buffer: ?[*]u8,
    buffer_len: usize,
) usize {
    const ctx = contextOf(handle) orelse return 0;
    return copyStateChanges(ctx.evm.getPendingStateChanges(), buffer, buffer_len);
}

/// Enable async storage injection.
/// Must be called before evm_call_ffi if using StateInterface. Idempotent if already enabled.
pub export fn evm_enable_storage_injector(handle: ?*EvmHandle) bool {
    const ctx = idleContextOf(handle) orelse return false;
    if (ctx.injector != null) return true;

    // The handle owns the injector and releases it in evm_destroy(). The
    // injector frees evicted cache entries itself, so it uses the long-lived
    // allocator, not the EVM arena.
    const injector_ptr = allocator.create(StorageInjector) catch return false;
    injector_ptr.* = StorageInjector.init(allocator) catch {
        allocator.destroy(injector_ptr);
        return false;
    };

    ctx.injector = injector_ptr;
    ctx.evm.pending_storage_injector = injector_ptr;
    ctx.evm.storage.storage_injector = injector_ptr;
    return true;
}

// ===== Result Introspection FFI (logs, refunds, storage changes) =====

/// Get number of log entries in the last execution result
export fn evm_get_log_count(handle: ?*EvmHandle) usize {
    const ctx = contextOf(handle) orelse return 0;
    const result = ctx.result orelse return 0;
    return result.logs.len;
}

/// Get a log entry by index. Returns false if unavailable or if a required
/// output pointer is null. `data_out` may be null when `data_max_len` is 0.
/// topics_out must have capacity for up to 4 topics (4 * 32 bytes)
export fn evm_get_log(
    handle: ?*EvmHandle,
    index: usize,
    address_out: ?[*]u8, // 20 bytes
    topics_count_out: ?*usize, // Number of topics
    topics_out: ?[*]u8, // Up to 4 topics * 32 bytes
    data_len_out: ?*usize, // Data length
    data_out: ?[*]u8, // Data buffer
    data_max_len: usize, // Max data buffer size
) bool {
    const ctx = contextOf(handle) orelse return false;
    const result = ctx.result orelse return false;
    if (index >= result.logs.len) return false;
    const address_dst = address_out orelse return false;
    const topics_count_dst = topics_count_out orelse return false;
    const topics_dst = topics_out orelse return false;
    const data_len_dst = data_len_out orelse return false;
    const lg = result.logs[index];

    // Address
    @memcpy(address_dst[0..20], &lg.address.bytes);

    // Topics
    const topics_len: usize = @min(lg.topics.len, 4);
    topics_count_dst.* = topics_len;
    for (lg.topics[0..topics_len], 0..) |topic, i| {
        std.mem.writeInt(u256, topics_dst[i * 32 ..][0..32], topic, .big);
    }

    // Data
    data_len_dst.* = lg.data.len;
    const copy_len = @min(lg.data.len, data_max_len);
    if (copy_len > 0) {
        const data_dst = data_out orelse return false;
        @memcpy(data_dst[0..copy_len], lg.data[0..copy_len]);
    }
    return true;
}

/// Get gas refund counter from last execution result
export fn evm_get_gas_refund(handle: ?*EvmHandle) u64 {
    const ctx = contextOf(handle) orelse return 0;
    // Live EVM refund counter, maintained during execution. The counter is
    // signed once Evm exposes get_effective_refund(); a negative value reads as 0.
    if (@hasDecl(Evm, "get_effective_refund")) return ctx.evm.get_effective_refund();
    return ctx.evm.gas_refund;
}

/// Get the number of storage slots written by the last transaction. A slot
/// cleared to zero counts; a slot that was only read does not.
export fn evm_get_storage_change_count(handle: ?*EvmHandle) usize {
    const ctx = contextOf(handle) orelse return 0;
    return ctx.evm.storage.original_storage.count();
}

/// Get a written storage slot by index, with its current value (zero for a
/// cleared slot). Returns false if the index is out of range or an output
/// pointer is null. The order is stable until the next call.
export fn evm_get_storage_change(
    handle: ?*EvmHandle,
    index: usize,
    address_out: ?[*]u8, // 20 bytes
    slot_out: ?[*]u8, // 32 bytes (big-endian u256)
    value_out: ?[*]u8, // 32 bytes (big-endian u256)
) bool {
    const ctx = contextOf(handle) orelse return false;
    const address_dst = address_out orelse return false;
    const slot_dst = slot_out orelse return false;
    const value_dst = value_out orelse return false;

    var it = ctx.evm.storage.original_storage.keyIterator();
    var i: usize = 0;
    while (it.next()) |key| : (i += 1) {
        if (i != index) continue;
        const value = ctx.evm.storage.peek(.{ .bytes = key.address }, key.slot);
        @memcpy(address_dst[0..20], &key.address);
        std.mem.writeInt(u256, slot_dst[0..32], key.slot, .big);
        std.mem.writeInt(u256, value_dst[0..32], value, .big);
        return true;
    }
    return false;
}

// ============================================================================
// Tests
// ============================================================================

const testing = std.testing;

/// Route the C API through the leak-checking test allocator for one test.
const TestAllocatorScope = struct {
    previous: std.mem.Allocator,

    fn enter() TestAllocatorScope {
        const scope = TestAllocatorScope{ .previous = allocator };
        allocator = testing.allocator;
        return scope;
    }

    fn exit(self: TestAllocatorScope) void {
        allocator = self.previous;
    }
};

const test_zero_address = [_]u8{0} ** 20;
const test_zero_word = [_]u8{0} ** 32;
const test_target = [_]u8{0} ** 18 ++ [_]u8{ 0x02, 0x00 };

fn testHandle() !*EvmHandle {
    return evm_create("osaka", 5, 0) orelse error.OutOfMemory;
}

fn testSetCall(handle: *EvmHandle, code: []const u8, gas: i64) !void {
    try testing.expect(evm_set_bytecode(handle, code.ptr, code.len));
    try testing.expect(evm_set_execution_context(handle, gas, &test_zero_address, &test_target, &test_zero_word, null, 0));
}

fn testOutput(handle: *EvmHandle, buffer: []u8) []u8 {
    const len = evm_get_output(handle, buffer.ptr, buffer.len);
    return buffer[0..len];
}

test "C ABI - evm_create rejects out-of-range log levels, unknown forks and null names" {
    const scope = TestAllocatorScope.enter();
    defer scope.exit();

    try testing.expect(evm_create("osaka", 5, 5) == null);
    try testing.expect(evm_create("osaka", 5, 255) == null);
    try testing.expect(evm_create("pragueee", 8, 0) == null);
    try testing.expect(evm_create(null, 5, 0) == null);

    // Null or empty name selects the default fork; every valid level works.
    var level: u8 = 0;
    while (level <= 4) : (level += 1) {
        const handle = evm_create(null, 0, level) orelse return error.OutOfMemory;
        evm_destroy(handle);
    }
    const log = @import("logger.zig");
    log.setLogLevel(.none);
}

test "C ABI - negative gas is rejected and leaves the previous context in place" {
    const scope = TestAllocatorScope.enter();
    defer scope.exit();
    const handle = try testHandle();
    defer evm_destroy(handle);

    // MSTORE(0, 42); RETURN(0, 32)
    const code = [_]u8{ 0x60, 0x2a, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
    try testSetCall(handle, &code, 100_000);

    try testing.expect(!evm_set_execution_context(handle, -1, &test_zero_address, &test_target, &test_zero_word, null, 0));
    try testing.expect(!evm_set_execution_context(handle, std.math.minInt(i64), &test_zero_address, &test_target, &test_zero_word, null, 0));

    // The valid context set earlier is still the one that runs.
    try testing.expect(evm_execute(handle));
    try testing.expectEqual(@as(i64, 18), evm_get_gas_used(handle));
    try testing.expectEqual(@as(i64, 100_000 - 18), evm_get_gas_remaining(handle));
}

test "C ABI - null pointers are rejected or treated as empty, never dereferenced" {
    const scope = TestAllocatorScope.enter();
    defer scope.exit();

    var request: AsyncRequest = undefined;
    var word: [32]u8 = undefined;
    var count: usize = 0;

    // Null handle on every entry point.
    evm_destroy(null);
    try testing.expect(!evm_set_bytecode(null, null, 0));
    try testing.expect(!evm_set_execution_context(null, 1, null, null, null, null, 0));
    try testing.expect(!evm_set_origin(null, null));
    try testing.expect(!evm_set_gas_price(null, null));
    evm_set_blockchain_context(null, null, 0, 0, null, null, null, 0, null, null);
    try testing.expect(!evm_set_access_list_addresses(null, null, 0));
    try testing.expect(!evm_set_access_list_storage_keys(null, null, null, 0));
    try testing.expect(!evm_set_blob_hashes(null, null, 0));
    try testing.expect(!evm_execute(null));
    try testing.expectEqual(@as(i64, 0), evm_get_gas_remaining(null));
    try testing.expectEqual(@as(i64, 0), evm_get_gas_used(null));
    try testing.expect(!evm_is_success(null));
    try testing.expectEqual(@as(usize, 0), evm_get_output_len(null));
    try testing.expectEqual(@as(usize, 0), evm_get_output(null, null, 0));
    try testing.expect(!evm_set_storage(null, null, null, null));
    try testing.expect(!evm_get_storage(null, null, null, null));
    try testing.expect(!evm_set_balance(null, null, null));
    try testing.expect(!evm_set_code(null, null, null, 0));
    try testing.expect(!evm_set_nonce(null, null, 0));
    try testing.expect(!evm_call_ffi(null, &request));
    try testing.expect(!evm_continue_ffi(null, 5, null, 0, &request));
    try testing.expectEqual(@as(usize, 0), evm_get_state_changes_len(null));
    try testing.expectEqual(@as(usize, 0), evm_get_state_changes(null, null, 0));
    try testing.expect(!evm_enable_storage_injector(null));
    try testing.expectEqual(@as(usize, 0), evm_get_log_count(null));
    try testing.expect(!evm_get_log(null, 0, null, null, null, null, null, 0));
    try testing.expectEqual(@as(u64, 0), evm_get_gas_refund(null));
    try testing.expectEqual(@as(usize, 0), evm_get_storage_change_count(null));
    try testing.expect(!evm_get_storage_change(null, 0, null, null, null));
    evm_free(null, 0);
    evm_free(null, 64);

    const handle = try testHandle();
    defer evm_destroy(handle);

    // Null data pointer with a non-zero length is an error.
    try testing.expect(!evm_set_bytecode(handle, null, 4));
    try testing.expect(!evm_set_execution_context(handle, 1, &test_zero_address, &test_target, &test_zero_word, null, 4));
    try testing.expect(!evm_set_execution_context(handle, 1, null, &test_target, &test_zero_word, null, 0));
    try testing.expect(!evm_set_execution_context(handle, 1, &test_zero_address, null, &test_zero_word, null, 0));
    try testing.expect(!evm_set_execution_context(handle, 1, &test_zero_address, &test_target, null, null, 0));
    try testing.expect(!evm_set_origin(handle, null));
    try testing.expect(!evm_set_gas_price(handle, null));
    try testing.expect(!evm_set_access_list_addresses(handle, null, 3));
    try testing.expect(!evm_set_access_list_storage_keys(handle, null, &test_zero_word, 1));
    try testing.expect(!evm_set_access_list_storage_keys(handle, &test_zero_address, null, 1));
    try testing.expect(!evm_set_blob_hashes(handle, null, 2));
    try testing.expect(!evm_set_storage(handle, null, &test_zero_word, &test_zero_word));
    try testing.expect(!evm_set_storage(handle, &test_target, null, &test_zero_word));
    try testing.expect(!evm_set_storage(handle, &test_target, &test_zero_word, null));
    try testing.expect(!evm_get_storage(handle, null, &test_zero_word, &word));
    try testing.expect(!evm_get_storage(handle, &test_target, null, &word));
    try testing.expect(!evm_get_storage(handle, &test_target, &test_zero_word, null));
    try testing.expect(!evm_set_balance(handle, null, &test_zero_word));
    try testing.expect(!evm_set_balance(handle, &test_target, null));
    try testing.expect(!evm_set_code(handle, null, null, 0));
    try testing.expect(!evm_set_code(handle, &test_target, null, 3));
    try testing.expect(!evm_set_nonce(handle, null, 1));
    try testing.expect(!evm_call_ffi(handle, null));
    try testing.expect(!evm_continue_ffi(handle, 5, null, 0, null));

    // A null pointer in the block context leaves the context unchanged.
    const chain_before = handle_evm(handle).block_context.chain_id;
    evm_set_blockchain_context(handle, null, 7, 7, null, null, null, 7, null, null);
    try testing.expectEqual(chain_before, handle_evm(handle).block_context.chain_id);
    try testing.expectEqual(@as(u64, 0), handle_evm(handle).block_context.block_number);

    // Null with zero length is a valid empty input.
    try testing.expect(evm_set_bytecode(handle, null, 0));
    try testing.expect(evm_set_execution_context(handle, 21_000, &test_zero_address, &test_target, &test_zero_word, null, 0));
    try testing.expect(evm_set_access_list_addresses(handle, null, 0));
    try testing.expect(evm_set_access_list_storage_keys(handle, null, null, 0));
    try testing.expect(evm_set_blob_hashes(handle, null, 0));
    try testing.expect(evm_set_code(handle, &test_target, null, 0));

    // Calling an account without code is a successful empty call.
    try testing.expect(evm_execute(handle));
    try testing.expectEqual(@as(usize, 0), evm_get_output_len(handle));
    try testing.expectEqual(@as(usize, 0), evm_get_output(handle, null, 16));
    try testing.expectEqual(@as(i64, 0), evm_get_gas_used(handle));

    // Continuation payloads: null with a length, short payloads, unknown types.
    request.output_type = 0;
    try testing.expect(!evm_continue_ffi(handle, 1, null, 84, &request));
    try testing.expectEqual(@as(u8, 255), request.output_type);
    request.output_type = 0;
    try testing.expect(!evm_continue_ffi(handle, 1, &test_zero_word, 32, &request));
    try testing.expectEqual(@as(u8, 255), request.output_type);
    request.output_type = 0;
    try testing.expect(!evm_continue_ffi(handle, 9, null, 0, &request));
    try testing.expectEqual(@as(u8, 255), request.output_type);
    // No transaction is in flight, so a commit acknowledgement is rejected.
    request.output_type = 0;
    try testing.expect(!evm_continue_ffi(handle, 5, null, 0, &request));
    try testing.expectEqual(@as(u8, 255), request.output_type);

    // Log getters with null outputs.
    const log_code = [_]u8{ 0x60, 0x20, 0x60, 0x00, 0xa0, 0x00 }; // LOG0(0, 32)
    try testSetCall(handle, &log_code, 100_000);
    try testing.expect(evm_execute(handle));
    try testing.expectEqual(@as(usize, 1), evm_get_log_count(handle));
    var log_address: [20]u8 = undefined;
    var topics: [128]u8 = undefined;
    var data_len: usize = 0;
    try testing.expect(!evm_get_log(handle, 0, null, &count, &topics, &data_len, null, 0));
    try testing.expect(!evm_get_log(handle, 0, &log_address, null, &topics, &data_len, null, 0));
    try testing.expect(!evm_get_log(handle, 0, &log_address, &count, null, &data_len, null, 0));
    try testing.expect(!evm_get_log(handle, 0, &log_address, &count, &topics, null, null, 0));
    try testing.expect(!evm_get_log(handle, 0, &log_address, &count, &topics, &data_len, null, 32));
    try testing.expect(evm_get_log(handle, 0, &log_address, &count, &topics, &data_len, null, 0));
    try testing.expectEqual(@as(usize, 32), data_len);
    try testing.expectEqualSlices(u8, &test_target, &log_address);
    try testing.expect(!evm_get_storage_change(handle, 0, null, &word, &word));
}

fn handle_evm(handle: *EvmHandle) *Evm {
    return contextOf(handle).?.evm;
}

test "C ABI - repeated evm_set_code frees every replaced copy" {
    const scope = TestAllocatorScope.enter();
    defer scope.exit();
    // testing.allocator fails this test if any copy is still live at the end.
    const handle = try testHandle();
    defer evm_destroy(handle);

    var other = test_target;
    var round: usize = 0;
    while (round < 64) : (round += 1) {
        var code = [_]u8{0x5b} ** 96;
        code[0] = @truncate(round);
        try testing.expect(evm_set_code(handle, &test_target, &code, code.len));
        // A second address, a shrinking size, and an empty replacement.
        other[0] = @truncate(1 + round % 4);
        try testing.expect(evm_set_code(handle, &other, &code, code.len - round));
        if (round % 8 == 0) try testing.expect(evm_set_code(handle, &other, null, 0));
    }
    try testing.expectEqual(@as(usize, 5), contextOf(handle).?.owned_code.count());

    // The handle still owns the copies after a transaction, and replacing them
    // afterwards must not double free or leak. Installed code runs in place of
    // the evm_set_bytecode buffer: STOP succeeds, INVALID halts.
    try testing.expect(evm_set_code(handle, &test_target, &[_]u8{0x00}, 1));
    try testSetCall(handle, &[_]u8{0xfe}, 50_000);
    try testing.expect(evm_execute(handle));
    try testing.expect(evm_set_bytecode(handle, &[_]u8{ 0x00, 0x00 }, 2));
    try testing.expect(evm_set_code(handle, &test_target, &[_]u8{0xfe}, 1));
    try testing.expect(!evm_execute(handle));
    try testing.expectEqual(@as(i64, 50_000), evm_get_gas_used(handle));
}

test "C ABI - create, configure and destroy cycles leak nothing" {
    const scope = TestAllocatorScope.enter();
    defer scope.exit();

    var buffer: [512]u8 = undefined;
    @memset(&buffer, 0x11);
    var cycle: usize = 0;
    while (cycle < 4) : (cycle += 1) {
        const handle = try testHandle();
        try testing.expect(evm_enable_storage_injector(handle));
        try testing.expect(evm_enable_storage_injector(handle));
        try testing.expect(evm_set_bytecode(handle, &buffer, 64));
        try testing.expect(evm_set_bytecode(handle, &buffer, 32));
        try testing.expect(evm_set_execution_context(handle, 100_000, &test_zero_address, &test_target, &test_zero_word, &buffer, 100));
        try testing.expect(evm_set_execution_context(handle, 100_000, &test_zero_address, &test_target, &test_zero_word, &buffer, 10));
        try testing.expect(evm_set_access_list_addresses(handle, &buffer, 4));
        try testing.expect(evm_set_access_list_addresses(handle, &buffer, 2));
        try testing.expect(evm_set_access_list_storage_keys(handle, &buffer, &buffer, 4));
        try testing.expect(evm_set_access_list_storage_keys(handle, &buffer, &buffer, 2));
        try testing.expect(evm_set_blob_hashes(handle, &buffer, 3));
        try testing.expect(evm_set_blob_hashes(handle, &buffer, 1));
        // Install code away from the call target: installed code takes
        // precedence over evm_set_bytecode, and 0x11 bytes would underflow.
        try testing.expect(evm_set_code(handle, buffer[0..20], &buffer, 200));

        // Run a transaction with the access list in place, then inspect the EVM:
        // it must not keep a pointer to the freed list.
        try testSetCall(handle, &[_]u8{0x00}, 100_000);
        var request: AsyncRequest = undefined;
        try testing.expect(evm_call_ffi(handle, &request));
        try testing.expectEqual(@as(u8, 5), request.output_type);
        try testing.expect(handle_evm(handle).pending_access_list == null);
        try testing.expect(evm_execute(handle));
        try testing.expect(handle_evm(handle).pending_access_list == null);
        evm_destroy(handle);
    }
}

test "buildAccessList groups keys by address and keeps keys of unlisted addresses" {
    const a = Address{ .bytes = [_]u8{0xaa} ** 20 };
    const b = Address{ .bytes = [_]u8{0xbb} ** 20 };
    const c = Address{ .bytes = [_]u8{0xcc} ** 20 };

    try testing.expect((try buildAccessList(testing.allocator, &.{}, &.{})) == null);

    const addresses = [_]Address{ a, b, a };
    const keys = [_]AccessListStorageKey{
        .{ .address = b.bytes, .slot = 1 },
        .{ .address = c.bytes, .slot = 2 }, // c was never listed as an address
        .{ .address = b.bytes, .slot = 3 },
    };
    const list = (try buildAccessList(testing.allocator, &addresses, &keys)).?;
    defer freeAccessList(testing.allocator, list);

    try testing.expectEqual(@as(usize, 3), list.len);
    try testing.expectEqualSlices(u8, &a.bytes, &list[0].address.bytes);
    try testing.expectEqual(@as(usize, 0), list[0].storage_keys.len);
    try testing.expectEqualSlices(u8, &b.bytes, &list[1].address.bytes);
    try testing.expectEqual(@as(usize, 2), list[1].storage_keys.len);
    try testing.expectEqual(@as(u8, 1), list[1].storage_keys[0][31]);
    try testing.expectEqual(@as(u8, 3), list[1].storage_keys[1][31]);
    try testing.expectEqualSlices(u8, &c.bytes, &list[2].address.bytes);
    try testing.expectEqual(@as(usize, 1), list[2].storage_keys.len);
    try testing.expectEqual(@as(u8, 2), list[2].storage_keys[0][31]);
}

test "buildAccessList leaks nothing when any allocation fails" {
    const build = struct {
        fn run(gpa_allocator: std.mem.Allocator) !void {
            var addresses: [6]Address = undefined;
            var keys: [12]AccessListStorageKey = undefined;
            for (&addresses, 0..) |*address, i| address.* = .{ .bytes = [_]u8{@intCast(i)} ** 20 };
            for (&keys, 0..) |*key, i| key.* = .{ .address = [_]u8{@intCast(i % 8)} ** 20, .slot = i };
            const list = try buildAccessList(gpa_allocator, &addresses, &keys);
            freeAccessList(gpa_allocator, list);
        }
    }.run;
    try testing.checkAllAllocationFailures(testing.allocator, build, .{});
}

test "C ABI - access list storage keys warm their slot without a separate address entry" {
    const scope = TestAllocatorScope.enter();
    defer scope.exit();
    const handle = try testHandle();
    defer evm_destroy(handle);

    // SLOAD(1): 2100 cold, 100 warm (plus 3 for the PUSH1).
    const code = [_]u8{ 0x60, 0x01, 0x54, 0x00 };
    try testSetCall(handle, &code, 100_000);
    try testing.expect(evm_execute(handle));
    try testing.expectEqual(@as(i64, 2103), evm_get_gas_used(handle));

    const slot_one = [_]u8{0} ** 31 ++ [_]u8{1};
    try testing.expect(evm_set_access_list_storage_keys(handle, &test_target, &slot_one, 1));
    try testing.expect(evm_execute(handle));
    try testing.expectEqual(@as(i64, 103), evm_get_gas_used(handle));

    // Clearing the list makes the slot cold again.
    try testing.expect(evm_set_access_list_storage_keys(handle, null, null, 0));
    try testing.expect(evm_execute(handle));
    try testing.expectEqual(@as(i64, 2103), evm_get_gas_used(handle));
}

test "C ABI - evm_set_origin and evm_set_gas_price reach ORIGIN and GASPRICE" {
    const scope = TestAllocatorScope.enter();
    defer scope.exit();
    const handle = try testHandle();
    defer evm_destroy(handle);

    // MSTORE(0, ORIGIN); MSTORE(32, GASPRICE); RETURN(0, 64)
    const code = [_]u8{ 0x32, 0x60, 0x00, 0x52, 0x3a, 0x60, 0x20, 0x52, 0x60, 0x40, 0x60, 0x00, 0xf3 };
    try testSetCall(handle, &code, 100_000);

    var buffer: [64]u8 = undefined;
    try testing.expect(evm_execute(handle));
    try testing.expect(std.mem.allEqual(u8, testOutput(handle, &buffer), 0));

    const origin = [_]u8{0xab} ** 20;
    const gas_price = [_]u8{0} ** 30 ++ [_]u8{ 0x12, 0x34 };
    try testing.expect(evm_set_origin(handle, &origin));
    try testing.expect(evm_set_gas_price(handle, &gas_price));

    // Both values persist across calls on the handle.
    for (0..2) |_| {
        try testing.expect(evm_execute(handle));
        const output = testOutput(handle, &buffer);
        try testing.expectEqual(@as(usize, 64), output.len);
        try testing.expect(std.mem.allEqual(u8, output[0..12], 0));
        try testing.expectEqualSlices(u8, &origin, output[12..32]);
        try testing.expectEqualSlices(u8, &gas_price, output[32..64]);
    }
}

test "C ABI - blob hashes are replaced and cleared between executions" {
    const scope = TestAllocatorScope.enter();
    defer scope.exit();
    const handle = try testHandle();
    defer evm_destroy(handle);

    // MSTORE(0, BLOBHASH(0)); MSTORE(32, BLOBHASH(1)); RETURN(0, 64)
    const code = [_]u8{ 0x60, 0x00, 0x49, 0x60, 0x00, 0x52, 0x60, 0x01, 0x49, 0x60, 0x20, 0x52, 0x60, 0x40, 0x60, 0x00, 0xf3 };
    try testSetCall(handle, &code, 100_000);

    const two = ([_]u8{0x01} ++ [_]u8{0xaa} ** 31) ++ ([_]u8{0x01} ++ [_]u8{0xbb} ** 31);
    const one = [_]u8{0x01} ++ [_]u8{0xcc} ** 31;
    var buffer: [64]u8 = undefined;
    var request: AsyncRequest = undefined;

    try testing.expect(evm_set_blob_hashes(handle, &two, 2));
    try testing.expect(evm_execute(handle));
    try testing.expectEqualSlices(u8, &two, testOutput(handle, &buffer));

    // A shorter list must not expose the old second hash.
    try testing.expect(evm_set_blob_hashes(handle, &one, 1));
    try testing.expect(evm_execute(handle));
    try testing.expectEqualSlices(u8, &one, testOutput(handle, &buffer)[0..32]);
    try testing.expect(std.mem.allEqual(u8, testOutput(handle, &buffer)[32..64], 0));

    // The async entry point sees the same hashes.
    try testing.expect(evm_call_ffi(handle, &request));
    try testing.expectEqual(@as(u8, 0), request.output_type);
    try testing.expectEqualSlices(u8, &one, testOutput(handle, &buffer)[0..32]);

    // Clearing removes them on both entry points.
    try testing.expect(evm_set_blob_hashes(handle, null, 0));
    try testing.expect(evm_execute(handle));
    try testing.expect(std.mem.allEqual(u8, testOutput(handle, &buffer), 0));
    try testing.expect(evm_call_ffi(handle, &request));
    try testing.expectEqual(@as(u8, 0), request.output_type);
    try testing.expect(std.mem.allEqual(u8, testOutput(handle, &buffer), 0));
}

test "C ABI - async halt returns a failed result and never the previous call's output" {
    const scope = TestAllocatorScope.enter();
    defer scope.exit();
    const handle = try testHandle();
    defer evm_destroy(handle);

    var request: AsyncRequest = undefined;
    var buffer: [32]u8 = undefined;

    const ok = [_]u8{ 0x60, 0x2a, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
    try testSetCall(handle, &ok, 100_000);
    try testing.expect(evm_call_ffi(handle, &request));
    try testing.expectEqual(@as(u8, 0), request.output_type);
    try testing.expect(evm_is_success(handle));
    try testing.expectEqual(@as(u8, 42), testOutput(handle, &buffer)[31]);
    try testing.expectEqual(@as(i64, 18), evm_get_gas_used(handle));

    // Preparing the next call does not change what the finished call reports.
    try testSetCall(handle, &[_]u8{0xfe}, 5_000);
    try testing.expectEqual(@as(i64, 18), evm_get_gas_used(handle));

    // INVALID: a completed call (tag 0) that failed and consumed all gas.
    try testing.expect(evm_call_ffi(handle, &request));
    try testing.expectEqual(@as(u8, 0), request.output_type);
    try testing.expect(!evm_is_success(handle));
    try testing.expectEqual(@as(usize, 0), evm_get_output_len(handle));
    try testing.expectEqual(@as(i64, 0), evm_get_gas_remaining(handle));
    try testing.expectEqual(@as(i64, 5_000), evm_get_gas_used(handle));

    // Nothing awaits a commit after the halt.
    try testing.expect(!evm_continue_ffi(handle, 5, null, 0, &request));
    try testing.expectEqual(@as(u8, 255), request.output_type);
    try testing.expect(!evm_is_success(handle));
    try testing.expectEqual(@as(usize, 0), evm_get_output_len(handle));
}

test "C ABI - async SSTORE commits the new value and a revert offers no commit" {
    const scope = TestAllocatorScope.enter();
    defer scope.exit();
    const handle = try testHandle();
    defer evm_destroy(handle);
    try testing.expect(evm_enable_storage_injector(handle));

    var request: AsyncRequest = undefined;
    var buffer: [32]u8 = undefined;
    // address(20) + slot(32) + value(32): slot 0 currently holds 5.
    var reply = [_]u8{0} ** 84;
    @memcpy(reply[0..20], &test_target);
    reply[83] = 5;

    // SSTORE(0, 7) with operands pushed twice (valid whether the handler probes
    // the slot before or after popping); then RETURN(SLOAD(0)).
    const store = [_]u8{ 0x60, 0x07, 0x60, 0x00, 0x60, 0x07, 0x60, 0x00, 0x55 };
    const commit_code = store ++ [_]u8{ 0x60, 0x00, 0x54, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
    try testSetCall(handle, &commit_code, 100_000);

    try testing.expect(evm_call_ffi(handle, &request));
    try testing.expectEqual(@as(u8, 1), request.output_type);
    try testing.expectEqualSlices(u8, &test_target, &request.address);
    try testing.expect(std.mem.allEqual(u8, &request.slot, 0));

    // A reply for a different slot is rejected and the request stays open.
    var wrong = reply;
    wrong[51] = 9;
    try testing.expect(!evm_continue_ffi(handle, 1, &wrong, wrong.len, &request));
    try testing.expectEqual(@as(u8, 255), request.output_type);
    try testing.expect(!evm_continue_ffi(handle, 5, null, 0, &request));
    try testing.expectEqual(@as(u8, 255), request.output_type);

    try testing.expect(evm_continue_ffi(handle, 1, &reply, reply.len, &request));
    try testing.expectEqual(@as(u8, 5), request.output_type);
    const json = request.json_data[0..request.json_len];
    try testing.expect(std.mem.indexOf(u8, json, "\"slot\":\"0x0\",\"originalValue\":\"0x5\",\"newValue\":\"0x7\"") != null);
    try testing.expectEqual(@as(usize, request.json_len), evm_get_state_changes_len(handle));

    try testing.expect(evm_continue_ffi(handle, 5, null, 0, &request));
    try testing.expectEqual(@as(u8, 0), request.output_type);
    try testing.expect(evm_is_success(handle));
    try testing.expectEqual(@as(u8, 7), testOutput(handle, &buffer)[31]);

    // Same write followed by REVERT(0, 0): the call completes as a failure and
    // no change set exists.
    const revert_code = store ++ [_]u8{ 0x60, 0x00, 0x60, 0x00, 0xfd };
    try testSetCall(handle, &revert_code, 100_000);
    try testing.expect(evm_call_ffi(handle, &request));
    try testing.expectEqual(@as(u8, 1), request.output_type);
    try testing.expect(evm_continue_ffi(handle, 1, &reply, reply.len, &request));
    try testing.expectEqual(@as(u8, 0), request.output_type);
    try testing.expect(!evm_is_success(handle));
    try testing.expectEqual(@as(usize, 0), evm_get_state_changes_len(handle));
    try testing.expect(!evm_continue_ffi(handle, 5, null, 0, &request));
    try testing.expectEqual(@as(u8, 255), request.output_type);
}

test "C ABI - storage change list reports cleared slots and skips slots only read" {
    const scope = TestAllocatorScope.enter();
    defer scope.exit();
    const handle = try testHandle();
    defer evm_destroy(handle);

    // SSTORE(1, 7); SSTORE(1, 0); SLOAD(2); STOP
    const code = [_]u8{ 0x60, 0x07, 0x60, 0x01, 0x55, 0x60, 0x00, 0x60, 0x01, 0x55, 0x60, 0x02, 0x54, 0x00 };
    try testSetCall(handle, &code, 100_000);
    try testing.expect(evm_execute(handle));

    try testing.expectEqual(@as(usize, 1), evm_get_storage_change_count(handle));
    var address: [20]u8 = undefined;
    var slot: [32]u8 = undefined;
    var value = [_]u8{0xff} ** 32;
    try testing.expect(evm_get_storage_change(handle, 0, &address, &slot, &value));
    try testing.expectEqualSlices(u8, &test_target, &address);
    try testing.expectEqual(@as(u8, 1), slot[31]);
    try testing.expect(std.mem.allEqual(u8, &value, 0));
    try testing.expect(!evm_get_storage_change(handle, 1, &address, &slot, &value));
}

test "C ABI - evm_execute keeps evm_set_code and EIP-7702 designators intact" {
    const scope = TestAllocatorScope.enter();
    defer scope.exit();
    const handle = try testHandle();
    defer evm_destroy(handle);
    var buffer: [32]u8 = undefined;

    // Installed code at the target returns 0x2a; the evm_set_bytecode buffer would return 0x07.
    const installed = [_]u8{ 0x60, 0x2a, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
    const supplied = [_]u8{ 0x60, 0x07, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
    try testing.expect(evm_set_code(handle, &test_target, &installed, installed.len));
    const owned = contextOf(handle).?.owned_code.get(.{ .bytes = test_target }).?;
    try testSetCall(handle, &supplied, 100_000);

    try testing.expect(evm_execute(handle));
    try testing.expectEqual(@as(u8, 0x2a), testOutput(handle, &buffer)[31]);
    // The code map still points at the handle-owned copy, not the bytecode buffer.
    const after = handle_evm(handle).code.get(.{ .bytes = test_target }).?;
    try testing.expectEqual(owned.ptr, after.ptr);

    // A later async call sees the same installed code.
    var request: AsyncRequest = undefined;
    try testing.expect(evm_call_ffi(handle, &request));
    try testing.expectEqual(@as(u8, 0), request.output_type);
    try testing.expectEqual(@as(u8, 0x2a), testOutput(handle, &buffer)[31]);

    // An EIP-7702 designator at the target delegates to code at another address.
    var delegate = test_target;
    delegate[0] = 0xd1;
    try testing.expect(evm_set_code(handle, &delegate, &installed, installed.len));
    const designator = [_]u8{ 0xef, 0x01, 0x00 } ++ delegate;
    try testing.expect(evm_set_code(handle, &test_target, &designator, designator.len));
    try testing.expect(evm_execute(handle));
    try testing.expectEqual(@as(u8, 0x2a), testOutput(handle, &buffer)[31]);
    try testing.expectEqualSlices(u8, &designator, handle_evm(handle).code.get(.{ .bytes = test_target }).?);

    // With no installed code, the evm_set_bytecode buffer runs and is never
    // left behind in the code map.
    try testing.expect(evm_set_code(handle, &test_target, null, 0));
    _ = handle_evm(handle).code.remove(.{ .bytes = test_target });
    try testing.expect(evm_execute(handle));
    try testing.expectEqual(@as(u8, 0x07), testOutput(handle, &buffer)[31]);
    try testing.expect(handle_evm(handle).code.get(.{ .bytes = test_target }) == null);
}

test "C ABI - evm_execute cancels a suspended async transaction" {
    const scope = TestAllocatorScope.enter();
    defer scope.exit();
    const handle = try testHandle();
    defer evm_destroy(handle);
    try testing.expect(evm_enable_storage_injector(handle));
    var request: AsyncRequest = undefined;
    var buffer: [32]u8 = undefined;

    // SLOAD(0) suspends for storage.
    const load = [_]u8{ 0x60, 0x00, 0x54, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
    try testSetCall(handle, &load, 100_000);
    try testing.expect(evm_call_ffi(handle, &request));
    try testing.expectEqual(@as(u8, 1), request.output_type);

    const ret = [_]u8{ 0x60, 0x2a, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3 };
    try testSetCall(handle, &ret, 100_000);
    try testing.expect(evm_execute(handle));
    try testing.expectEqual(@as(u8, 0x2a), testOutput(handle, &buffer)[31]);

    // The abandoned request cannot be answered, and the sync result survives.
    var reply = [_]u8{0} ** 84;
    @memcpy(reply[0..20], &test_target);
    reply[83] = 5;
    try testing.expect(!evm_continue_ffi(handle, 1, &reply, reply.len, &request));
    try testing.expectEqual(@as(u8, 255), request.output_type);

    // Same for a transaction awaiting commit: the acknowledgement must not
    // replay the abandoned result.
    try testSetCall(handle, &ret, 100_000);
    try testing.expect(evm_call_ffi(handle, &request));
    try testing.expectEqual(@as(u8, 5), request.output_type);
    try testSetCall(handle, &[_]u8{0x00}, 100_000);
    try testing.expect(evm_execute(handle));
    try testing.expect(!evm_continue_ffi(handle, 5, null, 0, &request));
    try testing.expectEqual(@as(u8, 255), request.output_type);
}

test "C ABI - an executing handle rejects re-entry and mutation and defers destroy" {
    const scope = TestAllocatorScope.enter();
    defer scope.exit();
    const handle = try testHandle();
    try testSetCall(handle, &[_]u8{0x00}, 100_000);
    try testing.expect(evm_set_code(handle, &test_target, &[_]u8{0x00}, 1));
    const ctx = contextOf(handle).?;
    const word = test_zero_word;
    var request: AsyncRequest = undefined;

    // Simulate a host callback running inside evm_execute.
    ctx.in_flight = true;
    try testing.expect(!evm_execute(handle));
    try testing.expect(!evm_call_ffi(handle, &request));
    try testing.expectEqual(@as(u8, 255), request.output_type);
    try testing.expect(!evm_continue_ffi(handle, 5, null, 0, &request));
    try testing.expect(!evm_set_bytecode(handle, &[_]u8{0xfe}, 1));
    try testing.expect(!evm_set_execution_context(handle, 1, &test_zero_address, &test_target, &word, null, 0));
    try testing.expect(!evm_set_code(handle, &test_target, &[_]u8{0xfe}, 1));
    try testing.expect(!evm_set_storage(handle, &test_target, &word, &word));
    try testing.expect(!evm_set_balance(handle, &test_target, &word));
    try testing.expect(!evm_set_nonce(handle, &test_target, 1));
    try testing.expect(!evm_set_origin(handle, &test_target));
    try testing.expect(!evm_set_gas_price(handle, &word));
    try testing.expect(!evm_set_access_list_addresses(handle, null, 0));
    try testing.expect(!evm_set_access_list_storage_keys(handle, null, null, 0));
    try testing.expect(!evm_set_blob_hashes(handle, null, 0));
    try testing.expect(!evm_enable_storage_injector(handle));
    // Read-only getters still work.
    var out: [32]u8 = undefined;
    try testing.expect(evm_get_storage(handle, &test_target, &word, &out));
    // Nothing was replaced.
    try testing.expectEqualSlices(u8, &[_]u8{0x00}, ctx.bytecode);
    try testing.expectEqual(@as(i64, 100_000), ctx.gas);
    try testing.expectEqualSlices(u8, &[_]u8{0x00}, handle_evm(handle).code.get(.{ .bytes = test_target }).?);

    // Destroy is deferred to the end of the outermost entry; testing.allocator
    // fails the test if the handle leaks.
    evm_destroy(handle);
    try testing.expect(ctx.destroy_pending);
    try testing.expect(!leaveExecution(ctx));
}

test "evm_alloc returns 16-byte aligned buffers" {
    const scope = TestAllocatorScope.enter();
    defer scope.exit();

    try testing.expect(evm_alloc(0) == null);
    const sizes = [_]usize{ 1, 7, 60, @sizeOf(AsyncRequest) };
    for (sizes) |size| {
        const ptr = evm_alloc(size) orelse return error.OutOfMemory;
        try testing.expectEqual(@as(usize, 0), @intFromPtr(ptr) % 16);
        evm_free(ptr, size);
    }
}
