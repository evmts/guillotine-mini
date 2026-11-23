/// C wrapper for Evm - minimal interface for WASM
const std = @import("std");
const evm = @import("evm.zig");
const evm_config_mod = @import("evm_config.zig");
const EvmConfig = evm_config_mod.EvmConfig;
const OpcodeOverride = evm_config_mod.OpcodeOverride;
const PrecompileOverride = evm_config_mod.PrecompileOverride;
const PrecompileOutput = evm_config_mod.PrecompileOutput;
const trace = @import("trace.zig");
const tracers = @import("tracers.zig");
const inspector = @import("inspector.zig");

// External JavaScript callback functions (provided as WASM imports)
// These are called BY WASM to execute custom handlers defined in JavaScript

const builtin = @import("builtin");
const is_wasm = builtin.target.cpu.arch == .wasm32 or builtin.target.cpu.arch == .wasm64;
var js_opcode_callbacks_enabled = false;

/// Enable calls to the JS opcode handler for this WASM instance.
export fn evm_set_js_opcode_callbacks_enabled(enabled: bool) void {
    if (is_wasm) js_opcode_callbacks_enabled = enabled;
}

pub fn jsOpcodeCallbacksEnabled() bool {
    return is_wasm and js_opcode_callbacks_enabled;
}

// Only declare extern functions when building for WASM
const js_opcode_callback = if (is_wasm)
    struct {
        extern "env" fn js_opcode_callback(opcode: u8, frame_ptr: usize) c_int;
    }.js_opcode_callback
else
    undefined;

const js_precompile_callback = if (is_wasm)
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
    if (is_wasm) {
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
    if (is_wasm) {
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

// Global allocator for C interface
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var allocator = gpa.allocator();

/// Allocate a host transfer buffer in the module's linear memory.
/// Returns null for zero length or allocation failure. Release with evm_free
/// using the same pointer and length after the C API has copied the input.
export fn evm_alloc(len: usize) ?[*]u8 {
    if (len == 0) return null;
    const buffer = allocator.alloc(u8, len) catch return null;
    return buffer.ptr;
}

/// Release a transfer buffer returned by evm_alloc. Null is a no-op.
export fn evm_free(ptr: ?[*]u8, len: usize) void {
    if (ptr) |buffer| allocator.free(buffer[0..len]);
}

// Opaque handle for EVM instance
const EvmHandle = opaque {};

const TraceKind = enum { opcode, call, access_list };

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
    trace_config: ?primitives.TraceConfig = null,
    call_tracer_options: ?tracers.CallTracer.Options = null,
    track_access_list: bool = false,
    tracer: ?trace.Tracer = null,
    call_tracer: ?tracers.CallTracer = null,
    access_list_tracker: ?tracers.AccessListInspector = null,
    inspectors: [2]inspector.Inspector = undefined,
    mux: inspector.MuxInspector = undefined,
    trace_json: [3]?[]const u8 = @splat(null),
    trace_gas_limit: u64 = 0,

    fn clearTracing(self: *ExecutionContext) void {
        self.evm.tracer = null;
        self.evm.clearInspector();
        if (self.tracer) |*tracer| tracer.deinit();
        if (self.call_tracer) |*tracer| tracer.deinit();
        if (self.access_list_tracker) |*tracker| tracker.deinit();
        self.tracer = null;
        self.call_tracer = null;
        self.access_list_tracker = null;
        for (&self.trace_json) |*cached| {
            if (cached.*) |bytes| allocator.free(bytes);
            cached.* = null;
        }
    }

    fn prepareExecution(self: *ExecutionContext) void {
        self.result = null;
        self.evm.origin = self.caller;
        self.clearTracing();
        self.trace_gas_limit = @intCast(self.gas);
        if (self.trace_config) |config| {
            self.tracer = trace.Tracer.init(allocator);
            self.tracer.?.config = config;
            self.tracer.?.enable();
            self.evm.setTracer(&self.tracer.?);
        }
        var count: usize = 0;
        if (self.call_tracer_options) |options| {
            self.call_tracer = tracers.CallTracer.init(allocator, options);
            self.inspectors[count] = self.call_tracer.?.inspector();
            count += 1;
        }
        if (self.track_access_list) {
            self.access_list_tracker = tracers.AccessListInspector.init(allocator, .{});
            self.inspectors[count] = self.access_list_tracker.?.inspector();
            count += 1;
        }
        switch (count) {
            0 => {},
            1 => self.evm.setInspector(self.inspectors[0]),
            2 => {
                self.mux = inspector.MuxInspector.init(self.inspectors[0..count]);
                self.evm.setInspector(self.mux.inspector());
            },
            else => unreachable,
        }
    }

    fn tracePayload(self: *ExecutionContext, kind: TraceKind) []const u8 {
        const result = self.result orelse return &.{};
        const cached = &self.trace_json[@intFromEnum(kind)];
        if (cached.*) |bytes| return bytes;

        var writer: std.Io.Writer.Allocating = .init(allocator);
        defer writer.deinit();
        switch (kind) {
            .opcode => {
                const tracer = if (self.tracer) |*value| value else return &.{};
                tracer.writeEip3155Jsonl(&writer.writer, .{
                    .output = result.output,
                    .gas_used = self.trace_gas_limit -| result.gas_left,
                    .pass = result.success,
                    .error_msg = Evm.resultErrorName(result),
                }) catch return &.{};
            },
            .call => {
                const tracer = if (self.call_tracer) |*value| value else return &.{};
                tracer.writeGethJson(&writer.writer) catch return &.{};
            },
            .access_list => {
                const tracker = if (self.access_list_tracker) |*value| value else return &.{};
                tracker.writeJson(&writer.writer) catch return &.{};
            },
        }
        cached.* = writer.toOwnedSlice() catch return &.{};
        return cached.*.?;
    }
};

fn getContext(handle: ?*EvmHandle) ?*ExecutionContext {
    return @ptrCast(@alignCast(handle orelse return null));
}

fn copyBytes(bytes: []const u8, buffer: [*]u8, buffer_len: usize) usize {
    const len = @min(bytes.len, buffer_len);
    if (len != 0) @memcpy(buffer[0..len], bytes[0..len]);
    return len;
}

/// Configure EIP-3155 opcode tracing for subsequent executions.
export fn evm_enable_tracing(handle: ?*EvmHandle, enable_memory: bool, disable_stack: bool, disable_storage: bool, enable_return_data: bool) void {
    const ctx = getContext(handle) orelse return;
    ctx.trace_config = primitives.TraceConfig.from();
    ctx.trace_config.?.enable_memory = enable_memory;
    ctx.trace_config.?.disable_memory = !enable_memory;
    ctx.trace_config.?.disable_stack = disable_stack;
    ctx.trace_config.?.disable_storage = disable_storage;
    ctx.trace_config.?.enable_return_data = enable_return_data;
}

/// Disable opcode tracing for subsequent executions.
export fn evm_disable_tracing(handle: ?*EvmHandle) void {
    const ctx = getContext(handle) orelse return;
    ctx.trace_config = null;
}

/// Get the byte length of the last execution's EIP-3155 JSONL trace.
export fn evm_get_trace_json_len(handle: ?*EvmHandle) usize {
    const ctx = getContext(handle) orelse return 0;
    return ctx.tracePayload(.opcode).len;
}

/// Copy JSONL into a caller buffer and return the byte count copied.
export fn evm_get_trace_json(handle: ?*EvmHandle, buffer: [*]u8, buffer_len: usize) usize {
    const ctx = getContext(handle) orelse return 0;
    return copyBytes(ctx.tracePayload(.opcode), buffer, buffer_len);
}

export fn evm_enable_call_tracer(handle: ?*EvmHandle, only_top_call: bool, with_log: bool) void {
    const ctx = getContext(handle) orelse return;
    ctx.call_tracer_options = .{ .only_top_call = only_top_call, .with_log = with_log };
}

export fn evm_get_call_trace_json_len(handle: ?*EvmHandle) usize {
    const ctx = getContext(handle) orelse return 0;
    return ctx.tracePayload(.call).len;
}

export fn evm_get_call_trace_json(handle: ?*EvmHandle, buffer: [*]u8, buffer_len: usize) usize {
    const ctx = getContext(handle) orelse return 0;
    return copyBytes(ctx.tracePayload(.call), buffer, buffer_len);
}

export fn evm_enable_access_list_tracker(handle: ?*EvmHandle) void {
    const ctx = getContext(handle) orelse return;
    ctx.track_access_list = true;
}

export fn evm_get_access_list_json_len(handle: ?*EvmHandle) usize {
    const ctx = getContext(handle) orelse return 0;
    return ctx.tracePayload(.access_list).len;
}

export fn evm_get_access_list_json(handle: ?*EvmHandle, buffer: [*]u8, buffer_len: usize) usize {
    const ctx = getContext(handle) orelse return 0;
    return copyBytes(ctx.tracePayload(.access_list), buffer, buffer_len);
}

/// Create a new Evm instance with optional hardfork name (null/empty = default from config)
/// log_level: 0=none, 1=err, 2=warn, 3=info, 4=debug
export fn evm_create(hardfork_name: [*]const u8, hardfork_len: usize, log_level: u8) ?*EvmHandle {
    const ctx = allocator.create(ExecutionContext) catch return null;

    const evm_ptr = allocator.create(Evm) catch {
        allocator.destroy(ctx);
        return null;
    };

    const Hardfork = primitives.Hardfork;
    const hardfork_slice = hardfork_name[0..hardfork_len];
    const hardfork = if (hardfork_len == 0) null else Hardfork.fromString(hardfork_slice);

    const log = @import("logger.zig");
    const log_level_enum: log.LogLevel = @enumFromInt(log_level);

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

/// Destroy an EVM instance
export fn evm_destroy(handle: ?*EvmHandle) void {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));
        ctx.clearTracing();
        ctx.evm.deinit();
        allocator.free(ctx.bytecode);
        allocator.free(ctx.calldata);
        allocator.free(ctx.access_list_addresses);
        allocator.free(ctx.access_list_storage_keys);
        if (ctx.blob_versioned_hashes) |hashes| allocator.free(hashes);
        allocator.destroy(ctx.evm);
        allocator.destroy(ctx);
    }
}

/// Set bytecode for execution
export fn evm_set_bytecode(handle: ?*EvmHandle, bytecode: [*]const u8, bytecode_len: usize) bool {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));

        // Allocate and copy bytecode
        const bytecode_copy = allocator.alloc(u8, bytecode_len) catch return false;
        @memcpy(bytecode_copy, bytecode[0..bytecode_len]);

        // Free old bytecode if any
        if (ctx.bytecode.len > 0) {
            allocator.free(ctx.bytecode);
        }

        ctx.bytecode = bytecode_copy;
        return true;
    }
    return false;
}

/// Set execution context
export fn evm_set_execution_context(
    handle: ?*EvmHandle,
    gas: i64,
    caller_bytes: [*]const u8,
    address_bytes: [*]const u8,
    value_bytes: [*]const u8, // 32 bytes representing u256
    calldata: [*]const u8,
    calldata_len: usize,
) bool {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));

        ctx.gas = gas;

        @memcpy(&ctx.caller.bytes, caller_bytes[0..20]);
        @memcpy(&ctx.address.bytes, address_bytes[0..20]);

        // Convert bytes to u256 (big-endian)
        var value: u256 = 0;
        var i: usize = 0;
        while (i < 32) : (i += 1) {
            value = (value << 8) | value_bytes[i];
        }
        ctx.value = value;

        // Allocate and copy calldata
        if (calldata_len > 0) {
            const calldata_copy = allocator.alloc(u8, calldata_len) catch return false;
            @memcpy(calldata_copy, calldata[0..calldata_len]);

            // Free old calldata if any
            if (ctx.calldata.len > 0) {
                allocator.free(ctx.calldata);
            }

            ctx.calldata = calldata_copy;
        } else {
            allocator.free(ctx.calldata);
            ctx.calldata = &[_]u8{};
        }

        return true;
    }
    return false;
}

/// Set blockchain context (required before execution)
export fn evm_set_blockchain_context(
    handle: ?*EvmHandle,
    chain_id_bytes: [*]const u8, // 32 bytes
    block_number: u64,
    block_timestamp: u64,
    block_difficulty_bytes: [*]const u8, // 32 bytes
    block_prevrandao_bytes: [*]const u8, // 32 bytes
    block_coinbase_bytes: [*]const u8, // 20 bytes
    block_gas_limit: u64,
    block_base_fee_bytes: [*]const u8, // 32 bytes
    blob_base_fee_bytes: [*]const u8, // 32 bytes
) void {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));

        var block_coinbase: Address = undefined;
        @memcpy(&block_coinbase.bytes, block_coinbase_bytes[0..20]);

        // Convert bytes to u256 (big-endian)
        var chain_id: u256 = 0;
        var block_difficulty: u256 = 0;
        var block_prevrandao: u256 = 0;
        var block_base_fee: u256 = 0;
        var blob_base_fee: u256 = 0;

        var i: usize = 0;
        while (i < 32) : (i += 1) {
            chain_id = (chain_id << 8) | chain_id_bytes[i];
            block_difficulty = (block_difficulty << 8) | block_difficulty_bytes[i];
            block_prevrandao = (block_prevrandao << 8) | block_prevrandao_bytes[i];
            block_base_fee = (block_base_fee << 8) | block_base_fee_bytes[i];
            blob_base_fee = (blob_base_fee << 8) | blob_base_fee_bytes[i];
        }

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
}

/// Set access list addresses (EIP-2930) - call before execute
export fn evm_set_access_list_addresses(
    handle: ?*EvmHandle,
    addresses: [*]const u8, // Packed 20-byte addresses
    count: usize,
) bool {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));

        if (count == 0) {
            allocator.free(ctx.access_list_addresses);
            ctx.access_list_addresses = &[_]Address{};
            return true;
        }

        const addr_list = allocator.alloc(Address, count) catch return false;
        var i: usize = 0;
        while (i < count) : (i += 1) {
            @memcpy(&addr_list[i].bytes, addresses[i * 20 .. (i + 1) * 20]);
        }

        allocator.free(ctx.access_list_addresses);
        ctx.access_list_addresses = addr_list;
        return true;
    }
    return false;
}

/// Set access list storage keys (EIP-2930) - call before execute
export fn evm_set_access_list_storage_keys(
    handle: ?*EvmHandle,
    addresses: [*]const u8, // Packed 20-byte addresses
    slots: [*]const u8, // Packed 32-byte slots
    count: usize,
) bool {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));

        if (count == 0) {
            allocator.free(ctx.access_list_storage_keys);
            ctx.access_list_storage_keys = &[_]AccessListStorageKey{};
            return true;
        }

        const keys = allocator.alloc(AccessListStorageKey, count) catch return false;
        var i: usize = 0;
        while (i < count) : (i += 1) {
            var addr: Address = undefined;
            @memcpy(&addr.bytes, addresses[i * 20 .. (i + 1) * 20]);

            // Convert slot bytes to u256
            var slot: u256 = 0;
            var j: usize = 0;
            while (j < 32) : (j += 1) {
                slot = (slot << 8) | slots[i * 32 + j];
            }

            keys[i] = .{ .address = addr.bytes, .slot = slot };
        }

        allocator.free(ctx.access_list_storage_keys);
        ctx.access_list_storage_keys = keys;
        return true;
    }
    return false;
}

/// Set blob versioned hashes (EIP-4844) - call before execute
export fn evm_set_blob_hashes(
    handle: ?*EvmHandle,
    hashes: [*]const u8, // Packed 32-byte hashes
    count: usize,
) bool {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));

        if (count == 0) {
            if (ctx.blob_versioned_hashes) |old_hashes| allocator.free(old_hashes);
            ctx.blob_versioned_hashes = null;
            return true;
        }

        const hash_list = allocator.alloc([32]u8, count) catch return false;
        var i: usize = 0;
        while (i < count) : (i += 1) {
            @memcpy(&hash_list[i], hashes[i * 32 .. (i + 1) * 32]);
        }

        if (ctx.blob_versioned_hashes) |old_hashes| allocator.free(old_hashes);
        ctx.blob_versioned_hashes = hash_list;
        return true;
    }
    return false;
}

/// Execute the EVM with current context
export fn evm_execute(handle: ?*EvmHandle) bool {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));

        if (ctx.gas < 0) return false;
        if (ctx.bytecode.len == 0 and ctx.evm.getRawCode(ctx.address).len == 0) return false;

        // Build EIP-2930 access list from flat C API format
        var access_list_entries = std.array_list.AlignedManaged(primitives.AccessList.AccessListEntry, null).init(allocator);
        defer access_list_entries.deinit();

        // Add addresses
        for (ctx.access_list_addresses) |addr| {
            // Find storage keys for this address
            var keys = std.array_list.AlignedManaged([32]u8, null).init(allocator);
            defer keys.deinit();

            for (ctx.access_list_storage_keys) |sk| {
                if (std.mem.eql(u8, &sk.address, &addr.bytes)) {
                    var hash: [32]u8 = undefined;
                    std.mem.writeInt(u256, &hash, sk.slot, .big);
                    keys.append(hash) catch return false;
                }
            }

            const keys_slice = keys.toOwnedSlice() catch return false;
            access_list_entries.append(.{
                .address = addr,
                .storage_keys = keys_slice,
            }) catch {
                allocator.free(keys_slice);
                return false;
            };
        }

        const access_list = if (access_list_entries.items.len > 0)
            access_list_entries.toOwnedSlice() catch return false
        else
            null;
        defer if (access_list) |list| {
            for (list) |entry| {
                allocator.free(entry.storage_keys);
            }
            allocator.free(list);
        };

        // Create CallParams for regular CALL operation
        const call_params = CallParams{ .call = .{
            .caller = ctx.caller,
            .to = ctx.address,
            .value = ctx.value,
            .input = ctx.calldata,
            .gas = @intCast(ctx.gas),
        } };

        ctx.prepareExecution();
        ctx.evm.setAccessList(access_list);
        defer ctx.evm.setAccessList(null);
        ctx.evm.setBlobVersionedHashes(ctx.blob_versioned_hashes orelse &.{});

        const bytecode = if (ctx.bytecode.len > 0) ctx.bytecode else null;
        const result = ctx.evm.callWithBytecodeOverride(call_params, bytecode);

        ctx.result = result;
        return result.success;
    }
    return false;
}

/// Get gas remaining after execution
export fn evm_get_gas_remaining(handle: ?*EvmHandle) i64 {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));
        if (ctx.result) |result| {
            return @intCast(result.gas_left);
        }
    }
    return 0;
}

/// Get gas used during execution
export fn evm_get_gas_used(handle: ?*EvmHandle) i64 {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));
        if (ctx.result) |result| {
            // Note: The test runner calculates gas used directly from evm_instance.gas_refund,
            // so this function's refund logic is actually unused. However, we keep it here
            // for consistency with the CallResult API.
            const gas_used = @as(i64, @intCast(ctx.gas)) - @as(i64, @intCast(result.gas_left));
            return gas_used;
        }
    }
    return 0;
}

/// Check if execution was successful
export fn evm_is_success(handle: ?*EvmHandle) bool {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));
        if (ctx.result) |result| {
            return result.success;
        }
    }
    return false;
}

/// Get output data length
export fn evm_get_output_len(handle: ?*EvmHandle) usize {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));
        if (ctx.result) |result| {
            return result.output.len;
        }
    }
    return 0;
}

/// Copy output data to buffer
export fn evm_get_output(handle: ?*EvmHandle, buffer: [*]u8, buffer_len: usize) usize {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));
        if (ctx.result) |result| {
            const copy_len = @min(buffer_len, result.output.len);
            @memcpy(buffer[0..copy_len], result.output[0..copy_len]);
            return copy_len;
        }
    }
    return 0;
}

/// Set storage value for an address
export fn evm_set_storage(
    handle: ?*EvmHandle,
    address_bytes: [*]const u8,
    slot_bytes: [*]const u8, // 32 bytes
    value_bytes: [*]const u8, // 32 bytes
) bool {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));

        var address: Address = undefined;
        @memcpy(&address.bytes, address_bytes[0..20]);

        // Convert slot bytes to u256
        var slot: u256 = 0;
        var i: usize = 0;
        while (i < 32) : (i += 1) {
            slot = (slot << 8) | slot_bytes[i];
        }

        // Convert value bytes to u256
        var value: u256 = 0;
        i = 0;
        while (i < 32) : (i += 1) {
            value = (value << 8) | value_bytes[i];
        }

        ctx.evm.setStoragePrestate(.{ .address = address.bytes, .slot = slot }, value) catch return false;
        return true;
    }
    return false;
}

/// Get storage value for an address
export fn evm_get_storage(
    handle: ?*EvmHandle,
    address_bytes: [*]const u8,
    slot_bytes: [*]const u8, // 32 bytes
    value_bytes: [*]u8, // 32 bytes output
) bool {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));

        var address: Address = undefined;
        @memcpy(&address.bytes, address_bytes[0..20]);

        // Convert slot bytes to u256
        var slot: u256 = 0;
        var i: usize = 0;
        while (i < 32) : (i += 1) {
            slot = (slot << 8) | slot_bytes[i];
        }

        const key = StorageKey{ .address = address.bytes, .slot = slot };
        const value = ctx.evm.storage.storage.get(key) orelse 0;

        // Convert u256 to bytes (big-endian)
        i = 32;
        var temp_value = value;
        while (i > 0) : (i -= 1) {
            value_bytes[i - 1] = @truncate(temp_value & 0xFF);
            temp_value >>= 8;
        }

        return true;
    }
    return false;
}

/// Set account balance
export fn evm_set_balance(
    handle: ?*EvmHandle,
    address_bytes: [*]const u8,
    balance_bytes: [*]const u8, // 32 bytes
) bool {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));

        var address: Address = undefined;
        @memcpy(&address.bytes, address_bytes[0..20]);

        // Convert balance bytes to u256
        var balance: u256 = 0;
        var i: usize = 0;
        while (i < 32) : (i += 1) {
            balance = (balance << 8) | balance_bytes[i];
        }

        ctx.evm.balances.put(address, balance) catch return false;
        return true;
    }
    return false;
}

/// Set account code
export fn evm_set_code(
    handle: ?*EvmHandle,
    address_bytes: [*]const u8,
    code: [*]const u8,
    code_len: usize,
) bool {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));

        var address: Address = undefined;
        @memcpy(&address.bytes, address_bytes[0..20]);

        const arena = ctx.evm.arena.allocator();
        const code_copy = arena.dupe(u8, code[0..code_len]) catch return false;
        ctx.evm.code.put(address, code_copy) catch {
            arena.free(code_copy);
            return false;
        };
        return true;
    }
    return false;
}

/// Set account nonce
export fn evm_set_nonce(
    handle: ?*EvmHandle,
    address_bytes: [*]const u8,
    nonce: u64,
) bool {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));

        var address: Address = undefined;
        @memcpy(&address.bytes, address_bytes[0..20]);

        ctx.evm.nonces.put(address, nonce) catch return false;
        return true;
    }
    return false;
}

// ===== Async Protocol FFI Functions =====

/// Output structure for async requests
pub const AsyncRequest = extern struct {
    output_type: u8, // 0=result, 1=need_storage, 2=need_balance, 5=ready_to_commit
    address: [20]u8,
    slot: [32]u8, // Only used for storage requests
    // For ready_to_commit: JSON length and data
    json_len: u32,
    json_data: [16384]u8, // State changes JSON (inline)
};

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
            // Write address bytes
            var i: usize = 0;
            while (i < 20) : (i += 1) {
                request_out.address[i] = req.address.bytes[i];
            }
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
            request_out.output_type = 5;
            // Pack JSON directly into AsyncRequest
            const json_len = @min(data.changes_json.len, request_out.json_data.len);
            if (json_len > 0) {
                @memcpy(request_out.json_data[0..json_len], data.changes_json[0..json_len]);
            }
            request_out.json_len = @intCast(json_len);
            return true;
        },
    }
}

/// Helper: Build CallParams from ExecutionContext
fn buildCallParams(ctx: *ExecutionContext) CallParams {
    return CallParams{
        .call = .{
            .caller = ctx.caller,
            .to = ctx.address,
            .gas = @intCast(ctx.gas),
            .value = ctx.value,
            .input = ctx.calldata,
        },
    };
}

/// Start EVM execution (async protocol)
/// Returns request in request_out, or sets output_type=0 if done
export fn evm_call_ffi(
    handle: ?*EvmHandle,
    request_out: *AsyncRequest,
) bool {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));

        const bytecode = if (ctx.bytecode.len > 0) ctx.bytecode else ctx.evm.get_code(ctx.address);
        if (bytecode.len == 0 or ctx.gas < 0) {
            request_out.output_type = 255;
            return false;
        }

        // Build EIP-2930 access list from flat C API format
        var access_list_entries = std.array_list.AlignedManaged(primitives.AccessList.AccessListEntry, null).init(allocator);
        defer access_list_entries.deinit();

        for (ctx.access_list_addresses) |addr| {
            var keys = std.array_list.AlignedManaged([32]u8, null).init(allocator);
            defer keys.deinit();

            for (ctx.access_list_storage_keys) |sk| {
                if (std.mem.eql(u8, &sk.address, &addr.bytes)) {
                    var hash: [32]u8 = undefined;
                    std.mem.writeInt(u256, &hash, sk.slot, .big);
                    keys.append(hash) catch {
                        request_out.output_type = 255;
                        return false;
                    };
                }
            }

            const keys_slice = keys.toOwnedSlice() catch {
                request_out.output_type = 255;
                return false;
            };
            access_list_entries.append(.{
                .address = addr,
                .storage_keys = keys_slice,
            }) catch {
                allocator.free(keys_slice);
                request_out.output_type = 255;
                return false;
            };
        }

        const access_list = if (access_list_entries.items.len > 0)
            access_list_entries.toOwnedSlice() catch {
                request_out.output_type = 255;
                return false;
            }
        else
            null;
        defer if (access_list) |list| {
            for (list) |entry| {
                allocator.free(entry.storage_keys);
            }
            allocator.free(list);
        };

        ctx.prepareExecution();
        ctx.evm.setBytecode(bytecode);
        ctx.evm.setAccessList(access_list);
        defer ctx.evm.setAccessList(null);
        ctx.evm.setBlobVersionedHashes(ctx.blob_versioned_hashes orelse &.{});

        // Start execution with params from ctx
        const params = buildCallParams(ctx);
        const output = ctx.evm.callOrContinue(.{ .call = params }) catch |err| {
            ctx.result = .{ .success = false, .gas_left = 0, .output = &.{}, .error_info = @errorName(err) };
            request_out.output_type = 255; // Error
            return false;
        };

        return packOutput(output, ctx, request_out);
    }
    return false;
}

/// Continue execution with async response
/// Returns next request in request_out, or output_type=0 if done
export fn evm_continue_ffi(
    handle: ?*EvmHandle,
    continue_type: u8, // 1=storage, 2=balance, 3=code, 4=nonce, 5=after_commit
    data_ptr: [*]const u8,
    data_len: usize,
    request_out: *AsyncRequest,
) bool {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));

        // Build continue input based on type
        const input: Evm.CallOrContinueInput = switch (continue_type) {
            1 => blk: {
                // Storage: address(20) + slot(32) + value(32) = 84 bytes
                if (data_len < 84) {
                    request_out.output_type = 255;
                    return false;
                }
                var addr: Address = undefined;
                @memcpy(&addr.bytes, data_ptr[0..20]);
                const slot = std.mem.readInt(u256, data_ptr[20..52], .big);
                const value = std.mem.readInt(u256, data_ptr[52..84], .big);
                break :blk .{ .continue_with_storage = .{ .address = addr, .slot = slot, .value = value } };
            },
            2 => blk: {
                // Balance: address(20) + balance(32) = 52 bytes
                if (data_len < 52) {
                    request_out.output_type = 255;
                    return false;
                }
                var addr: Address = undefined;
                @memcpy(&addr.bytes, data_ptr[0..20]);
                const balance = std.mem.readInt(u256, data_ptr[20..52], .big);
                break :blk .{ .continue_with_balance = .{ .address = addr, .balance = balance } };
            },
            3 => blk: {
                // Code: address(20) + code bytes (remainder). Answers a need_code request.
                if (data_len < 20) {
                    request_out.output_type = 255;
                    return false;
                }
                var addr: Address = undefined;
                @memcpy(&addr.bytes, data_ptr[0..20]);
                const code = data_ptr[20..data_len];
                break :blk .{ .continue_with_code = .{ .address = addr, .code = code } };
            },
            4 => blk: {
                // Nonce: address(20) + nonce(8, big-endian). Answers a need_nonce request.
                if (data_len < 28) {
                    request_out.output_type = 255;
                    return false;
                }
                var addr: Address = undefined;
                @memcpy(&addr.bytes, data_ptr[0..20]);
                const nonce = std.mem.readInt(u64, data_ptr[20..28], .big);
                break :blk .{ .continue_with_nonce = .{ .address = addr, .nonce = nonce } };
            },
            5 => .{ .continue_after_commit = {} },
            else => {
                request_out.output_type = 255;
                return false;
            },
        };

        const output = ctx.evm.callOrContinue(input) catch |err| {
            ctx.result = .{ .success = false, .gas_left = 0, .output = &.{}, .error_info = @errorName(err) };
            request_out.output_type = 255;
            return false;
        };

        return packOutput(output, ctx, request_out);
    }
    return false;
}

/// Get the full state changes JSON length (only when output_type = ReadyToCommit).
export fn evm_get_state_changes_len(handle: ?*EvmHandle) usize {
    const ctx = getContext(handle) orelse return 0;
    return ctx.evm.pending_state_changes_len;
}

/// Copy state changes JSON and return the byte count copied.
/// Use evm_get_state_changes_len to allocate enough space for the entire response.
export fn evm_get_state_changes(
    handle: ?*EvmHandle,
    buffer: [*]u8,
    buffer_len: usize,
) usize {
    const ctx = getContext(handle) orelse return 0;
    return copyBytes(ctx.evm.pending_state_changes, buffer, buffer_len);
}

/// Enable async storage injection
/// Must be called before evm_call_ffi if using StateInterface
export fn evm_enable_storage_injector(handle: ?*EvmHandle) bool {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));

        // Create storage injector with arena allocator
        if (ctx.evm.pending_storage_injector != null) return true;
        const arena = ctx.evm.arena.allocator();
        const injector_ptr = arena.create(StorageInjector) catch return false;
        injector_ptr.* = StorageInjector.init(arena) catch {
            arena.destroy(injector_ptr);
            return false;
        };

        ctx.evm.pending_storage_injector = injector_ptr;
        return true;
    }
    return false;
}

// ===== Result Introspection FFI (logs, refunds, storage changes) =====

/// Get number of log entries in the last execution result
export fn evm_get_log_count(handle: ?*EvmHandle) usize {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));
        if (ctx.result) |result| {
            return result.logs.len;
        }
    }
    return 0;
}

/// Get a log entry by index. Returns false if unavailable.
/// topics_out must have capacity for up to 4 topics (4 * 32 bytes)
export fn evm_get_log(
    handle: ?*EvmHandle,
    index: usize,
    address_out: [*]u8, // 20 bytes
    topics_count_out: *usize, // Number of topics
    topics_out: [*]u8, // Up to 4 topics * 32 bytes
    data_len_out: *usize, // Data length
    data_out: [*]u8, // Data buffer
    data_max_len: usize, // Max data buffer size
) bool {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));
        if (ctx.result) |result| {
            if (index >= result.logs.len) return false;
            const lg = result.logs[index];

            // Address
            @memcpy(address_out[0..20], &lg.address.bytes);

            // Topics
            const topics_len: usize = @min(lg.topics.len, 4);
            topics_count_out.* = topics_len;
            var i: usize = 0;
            while (i < topics_len) : (i += 1) {
                var buf: [32]u8 = undefined;
                std.mem.writeInt(u256, &buf, lg.topics[i], .big);
                @memcpy(topics_out[i * 32 .. (i + 1) * 32], &buf);
            }

            // Data
            data_len_out.* = result.logs[index].data.len;
            const copy_len = @min(result.logs[index].data.len, data_max_len);
            if (copy_len > 0) {
                @memcpy(data_out[0..copy_len], result.logs[index].data[0..copy_len]);
            }
            return true;
        }
    }
    return false;
}

/// Get gas refund counter from last execution result
export fn evm_get_gas_refund(handle: ?*EvmHandle) u64 {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));
        // Return live EVM refund counter which is maintained during execution
        return ctx.evm.gas_refund;
    }
    return 0;
}

/// Get number of modified storage slots (entries present in storage map)
export fn evm_get_storage_change_count(handle: ?*EvmHandle) usize {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));
        return ctx.evm.storage.storage.count();
    }
    return 0;
}

/// Get storage change by index. Returns false if index out of range.
export fn evm_get_storage_change(
    handle: ?*EvmHandle,
    index: usize,
    address_out: [*]u8, // 20 bytes
    slot_out: [*]u8, // 32 bytes (big-endian u256)
    value_out: [*]u8, // 32 bytes (big-endian u256)
) bool {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));
        var it = ctx.evm.storage.storage.iterator();
        var i: usize = 0;
        while (it.next()) |entry| {
            if (i == index) {
                const key = entry.key_ptr.*;
                const value = entry.value_ptr.*;

                // Address
                @memcpy(address_out[0..20], &key.address);

                // Slot (u256 -> [32]u8 big-endian)
                var slot_buf: [32]u8 = undefined;
                std.mem.writeInt(u256, &slot_buf, key.slot, .big);
                @memcpy(slot_out[0..32], &slot_buf);

                // Value (u256 -> [32]u8 big-endian)
                var value_buf: [32]u8 = undefined;
                std.mem.writeInt(u256, &value_buf, value, .big);
                @memcpy(value_out[0..32], &value_buf);

                return true;
            }
            i += 1;
        }
    }
    return false;
}

test "destroy releases FFI pre-state, inspectors, and cached JSON" {
    const testing = std.testing;
    const handle = evm_create("prague", "prague".len, 0) orelse return error.OutOfMemory;
    {
        defer evm_destroy(handle);
        const address = Address.fromU256(0x100);
        const zero = [_]u8{0} ** 32;
        const code = &[_]u8{ 0x5f, 0x54, 0x50, 0x5f, 0x5f, 0xa0, 0x00 };
        try testing.expect(evm_set_code(handle, &address.bytes, code, code.len));
        try testing.expect(evm_set_storage(handle, &address.bytes, &zero, &zero));
        try testing.expect(evm_set_execution_context(handle, 100_000, &ZERO_ADDRESS.bytes, &address.bytes, &zero, &zero, 0));
        evm_enable_tracing(handle, true, false, false, true);
        evm_enable_call_tracer(handle, false, true);
        evm_enable_access_list_tracker(handle);
        for (0..2) |_| {
            try testing.expect(evm_execute(handle));
            try testing.expect(evm_get_trace_json_len(handle) > 0);
            try testing.expect(evm_get_call_trace_json_len(handle) > 0);
            try testing.expect(evm_get_access_list_json_len(handle) > 0);
        }
    }
    try testing.expect(!gpa.detectLeaks());
}
