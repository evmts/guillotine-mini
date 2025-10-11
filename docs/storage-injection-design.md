# Storage Injection with Async State Interface - Design Document

## Overview

Enable TypeScript to provide **async** storage implementation to the EVM through a proper message-passing protocol. The EVM can read/write state from any async source (RPC, database, cache) while maintaining deterministic execution through explicit suspend/resume cycles.

## Core Requirements

1. ✅ **Async TypeScript → Synchronous Zig**: TypeScript methods are async, Zig execution is sync
2. ✅ **Message Passing Protocol**: Clean abstraction for async communication across WASM boundary
3. ✅ **Suspend/Resume**: WASM execution stops, TypeScript runs async code, then explicitly resumes
4. ✅ **LRU Caching**: Per-transaction cache to minimize async calls
5. ✅ **Change Tracking**: Track all writes for atomic commits at transaction end

---

## Part 1: Async Message Passing Protocol

### The Core Problem

**WASM is synchronous**. Zig cannot `await`. TypeScript storage methods are `async`.

**Solution**: Execution returns to TypeScript when async data needed, then explicitly continues:

```
┌─────────────────────────────────────────────────────────┐
│                    Zig (WASM)                           │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 1. evm_call_ffi() starts                         │  │
│  │ 2. EVM executes bytecode                         │  │
│  │ 3. SLOAD hits → get_storage()                    │  │
│  │ 4. StorageInjector: cache miss                   │  │
│  │ 5. Write to evm.async_data_request               │  │
│  │ 6. return error.NeedAsyncData                    │  │
│  │ 7. Error propagates up, caught in execute loop   │  │
│  │ 8. Read evm.async_data_request                   │  │
│  │ 9. return .need_storage{ addr, slot }            │  │ ← Execution ENDS
│  │    ⏸️  State preserved in WASM heap               │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────┬───────────────────────────────┘
                          │ Returns tagged union in request_out
                          ▼
┌─────────────────────────────────────────────────────────┐
│                  TypeScript                             │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 8. Read: request_out.type = NeedStorage          │  │
│  │ 9. addr/slot already in request_out buffer       │  │
│  │ 10. await stateInterface.getStorage(addr, slot)  │  │
│  │ 11. Get result from RPC/DB                       │  │
│  │ 12. evm_continue_ffi({addr, slot, value})        │  │ ← TypeScript CALLS Zig
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────┬───────────────────────────────┘
                          │ Function called
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    Zig (WASM)                           │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 13. evm_continue_ffi(storage_data)               │  │
│  │ 14. Store value in cache                         │  │
│  │ 15. Continue execution from saved state          │  │
│  │ 16. Frame.execute() continues                    │  │
│  │ 17. If another async request → return .need_X    │  │
│  │ 18. Else → all frames done → return .result      │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Key Insight: No Suspend/Resume - Just Return/Continue

**Instead of suspending in place**, we:

1. **Return early** when async data is needed
2. **Preserve state** in the Evm struct (lives in WASM heap)
3. **TypeScript awaits** the async call
4. **Explicitly continue** by calling back into WASM

This is like a **state machine** with explicit steps, not true coroutines.

### Message Passing Abstraction

#### Zig Side: Execution State Machine

```zig
const std = @import("std");
const primitives = @import("primitives");
const Address = primitives.Address.Address;

/// Async data request - written by get_storage/get_balance/etc when cache miss
/// Read by executeUntilYieldOrComplete to build the return value
pub const AsyncDataRequest = union(enum) {
    none: void,
    storage: struct {
        address: Address,
        slot: u256,
    },
    balance: struct {
        address: Address,
    },
    code: struct {
        address: Address,
    },
    nonce: struct {
        address: Address,
    },
};
```

**NO separate state tracking!** The request is written to `evm.async_data_request` when we need async data, then read when we catch `error.NeedAsyncData`.

#### Zig Side: The Tagged Union API

The `callOrContinue()` method **returns the request directly** - no separate getter needed!

But for C API (WASM), we need to serialize the tagged union. We have two options:

```zig
/// Output structure for async requests
pub const AsyncRequest = extern struct {
    output_type: u8,  // 0=result, 1=need_storage, 2=need_balance, 5=ready_to_commit
    address: [20]u8,
    slot: [32]u8,     // Only used for storage requests
};

/// Start EVM execution
/// Returns request in request_out, or sets output_type=0 if done
export fn evm_call_ffi(
    handle: ?*EvmHandle,
    request_out: *AsyncRequest,
) bool {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));

        // Start execution with params from ctx
        const params = buildCallParams(ctx);
        const output = ctx.evm.callOrContinue(.{ .call = params }) catch {
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
    continue_type: u8,  // 1=storage, 2=balance, 3=code, 4=nonce, 5=after_commit
    data_ptr: [*]const u8,
    data_len: usize,
    request_out: *AsyncRequest,
) bool {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));

        // Build continue input based on type
        const input: Evm.CallOrContinueInput = switch (continue_type) {
            1 => blk: {
                const addr = Address{ .bytes = data_ptr[0..20].* };
                const slot = std.mem.readInt(u256, data_ptr[20..52], .big);
                const value = std.mem.readInt(u256, data_ptr[52..84], .big);
                break :blk .{ .continue_with_storage = .{ .address = addr, .slot = slot, .value = value }};
            },
            2 => blk: {
                const addr = Address{ .bytes = data_ptr[0..20].* };
                const balance = std.mem.readInt(u256, data_ptr[20..52], .big);
                break :blk .{ .continue_with_balance = .{ .address = addr, .balance = balance }};
            },
            5 => .{ .continue_after_commit = {} },
            else => {
                request_out.output_type = 255;
                return false;
            },
        };

        const output = ctx.evm.callOrContinue(input) catch {
            request_out.output_type = 255;
            return false;
        };

        return packOutput(output, ctx, request_out);
    }
    return false;
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
        .ready_to_commit => |data| {
            request_out.output_type = 5;
            ctx.pending_changes_json = data.changes_json;
            return true;
        },
    }
}

/// Get state changes JSON (only when output_type = ReadyToCommit)
export fn evm_get_state_changes(
    handle: ?*EvmHandle,
    buffer: [*]u8,
    buffer_len: usize,
) usize {
    if (handle) |h| {
        const ctx: *ExecutionContext = @ptrCast(@alignCast(h));
        const changes_json = ctx.pending_changes_json;

        const copy_len = @min(changes_json.len, buffer_len);
        @memcpy(buffer[0..copy_len], changes_json[0..copy_len]);
        return copy_len;
    }
    return 0;
}
```

#### TypeScript Side: Execution Loop

```typescript
export interface StateInterface {
  getStorage(address: Address, slot: U256): Promise<U256>;
  getBalance(address: Address): Promise<bigint>;
  getCode(address: Address): Promise<Bytes>;
  getNonce(address: Address): Promise<bigint>;
  commitChanges(changes: StateChanges): Promise<void>;
}

export interface StateChanges {
  storage: Array<{
    address: Address;
    slot: U256;
    originalValue: U256;
    newValue: U256;
  }>;
  balances: Array<{
    address: Address;
    originalBalance: bigint;
    newBalance: bigint;
  }>;
  nonces: Array<{ address: Address; originalNonce: bigint; newNonce: bigint }>;
  codes: Array<{ address: Address; code: Bytes }>;
  selfDestructs: Address[];
}

enum OutputType {
  Result = 0,
  NeedStorage = 1,
  NeedBalance = 2,
  NeedCode = 3,
  NeedNonce = 4,
  ReadyToCommit = 5,
}

enum InputType {
  Call = 0,
  ContinueWithStorage = 1,
  ContinueWithBalance = 2,
  ContinueWithCode = 3,
  ContinueWithNonce = 4,
  ContinueAfterCommit = 5,
}

/**
 * Execute EVM with async state interface
 * Runs in a loop: call/continue → check output → handle async → continue
 */
export async function executeWithAsyncState(
  wasm: WebAssembly.Instance,
  evmHandle: number,
  stateInterface: StateInterface,
): Promise<ExecutionResult> {
  // Start with initial call
  let outputType = (wasm.exports.evm_call_or_continue as Function)(
    evmHandle,
    InputType.Call,
    0, // No data for initial call (params already set)
    0,
  );

  // Loop until we get a result
  while (true) {
    if (outputType === OutputType.Result) {
      // Execution complete - return result
      return {
        success: (wasm.exports.evm_is_success as Function)(evmHandle) !== 0,
        gasRemaining: (wasm.exports.evm_get_gas_remaining as Function)(
          evmHandle,
        ),
        gasUsed: (wasm.exports.evm_get_gas_used as Function)(evmHandle),
        output: getOutputFromWasm(wasm, evmHandle),
      };
    }

    if (outputType === OutputType.NeedStorage) {
      // Get request details
      const addrBytes = new Uint8Array(20);
      const slotBytes = new Uint8Array(32);
      (wasm.exports.evm_get_pending_request as Function)(
        evmHandle,
        addrBytes,
        slotBytes,
      );

      const address = bytesToHex(addrBytes);
      const slot = bytesToHex(slotBytes);

      // Call async state interface
      const value = await stateInterface.getStorage(address, slot);

      // Prepare continue data: address(20) + slot(32) + value(32)
      const continueData = new Uint8Array(84);
      continueData.set(addrBytes, 0);
      continueData.set(slotBytes, 20);
      continueData.set(hexToBytes(value), 52);

      // Continue execution
      outputType = (wasm.exports.evm_call_or_continue as Function)(
        evmHandle,
        InputType.ContinueWithStorage,
        continueData,
        84,
      );
      // Loop continues...
    }

    if (outputType === OutputType.NeedBalance) {
      const addrBytes = new Uint8Array(20);
      (wasm.exports.evm_get_pending_request as Function)(
        evmHandle,
        addrBytes,
        null,
      );
      const address = bytesToHex(addrBytes);

      const balance = await stateInterface.getBalance(address);

      // Prepare continue data: address(20) + balance(32)
      const continueData = new Uint8Array(52);
      continueData.set(addrBytes, 0);
      continueData.set(bigintToU256(balance), 20);

      outputType = (wasm.exports.evm_call_or_continue as Function)(
        evmHandle,
        InputType.ContinueWithBalance,
        continueData,
        52,
      );
    }

    if (outputType === OutputType.ReadyToCommit) {
      // Get state changes JSON
      const changesBuffer = new Uint8Array(1024 * 1024);
      const changesLen = (wasm.exports.evm_get_state_changes as Function)(
        evmHandle,
        changesBuffer,
        changesBuffer.length,
      );

      const changesJson = new TextDecoder().decode(
        changesBuffer.slice(0, changesLen),
      );
      const changes: StateChanges = JSON.parse(changesJson);

      // Commit changes
      await stateInterface.commitChanges(changes);

      // Continue after commit
      outputType = (wasm.exports.evm_call_or_continue as Function)(
        evmHandle,
        InputType.ContinueAfterCommit,
        0,
        0,
      );
    }
  }
}
```

### Why This Approach Works: The Defer Problem

**The Problem**:

```zig
pub fn call(self: *Self, params: CallParams) CallResult {
    try self.frames.append(...);
    defer _ = self.frames.pop();  // ❌ This runs on ANY return!

    try frame.execute();  // If this yields, defer runs = state corrupted
    // ...
}
```

**The Solution**:

```zig
pub fn callOrContinue(self: *Self, input: CallOrContinueInput) !CallOrContinueOutput {
    // NO defer statements!

    switch (input) {
        .call => {
            try self.frames.append(...);
            // No defer - we might return early!
            return try self.executeUntilYieldOrComplete();
        },
        .continue_with_storage => {
            // State already exists from previous call
            // Frames still on stack, just continue
            return try self.executeUntilYieldOrComplete();
        },
    }
}

fn executeUntilYieldOrComplete(self: *Self) !CallOrContinueOutput {
    while (self.frames.items.len > 0) {
        frame.execute() catch |err| {
            if (err == error.NeedAsyncData) {
                // YIELD - return WITHOUT popping frame
                return .{ .need_storage = ... };
            }
            return err;  // Real error
        };

        // Only pop when frame actually completes
        _ = self.frames.pop();
    }

    return .{ .result = ... };
}
```

**Key Properties**:

1. ✅ **No defer statements** in `callOrContinue()` or `executeUntilYieldOrComplete()`
2. ✅ **Frames stay on stack** when yielding (preserved in WASM heap)
3. ✅ **Explicit cleanup** only when truly done
4. ✅ **Arena allocator untouched** during yields
5. ✅ **Tagged unions** make states explicit
6. ✅ **No special WASM features** - just normal function calls
7. ✅ **Backward compatible** - `call()` still exists for sync use

### TypeScript Internal Wrapper - Handles Yields

This is the **internal implementation** that manages the yield loop:

```typescript
/**
 * INTERNAL: Execute with yield handling
 * This handles all the yield/continue logic internally
 * Public API (execute()) just calls this
 */
async function executeWithYieldHandling(
  wasm: WebAssembly.Instance,
  evmHandle: number,
  stateInterface?: StateInterface,
): Promise<ExecutionResult> {
  // If no state interface, use regular execute
  if (!stateInterface) {
    const status = (wasm.exports.evm_call_or_continue as Function)(
      evmHandle,
      InputType.Call,
      0,
      0,
    );
    if (status !== OutputType.Result) {
      throw new Error("Async request but no stateInterface provided");
    }
    return getResult(wasm, evmHandle);
  }

  // Request buffer - receives async request data
  const requestBuffer = new Uint8Array(53); // 1 (type) + 20 (address) + 32 (slot)

  // Start execution
  (wasm.exports.evm_call_ffi as Function)(evmHandle, requestBuffer);

  let outputType = requestBuffer[0];

  // Yield loop - handle async requests until done
  while (outputType !== OutputType.Result) {
    if (outputType === OutputType.NeedStorage) {
      // Request data is IN the requestBuffer!
      const address = bytesToHex(requestBuffer.slice(1, 21));
      const slot = bytesToHex(requestBuffer.slice(21, 53));

      const value = await stateInterface.getStorage(address, slot);

      // Pack continue data: address(20) + slot(32) + value(32)
      const continueData = new Uint8Array(84);
      continueData.set(requestBuffer.slice(1, 21), 0);   // address
      continueData.set(requestBuffer.slice(21, 53), 20); // slot
      continueData.set(hexToBytes(value), 52);            // value

      (wasm.exports.evm_continue_ffi as Function)(
        evmHandle,
        1, // ContinueType.Storage
        continueData,
        84,
        requestBuffer,  // Will receive next request
      );

      outputType = requestBuffer[0];
    } else if (outputType === OutputType.NeedBalance) {
      const address = bytesToHex(requestBuffer.slice(1, 21));
      const balance = await stateInterface.getBalance(address);

      const continueData = new Uint8Array(52);
      continueData.set(requestBuffer.slice(1, 21), 0);   // address
      continueData.set(bigintToU256(balance), 20);        // balance

      (wasm.exports.evm_continue_ffi as Function)(
        evmHandle,
        2, // ContinueType.Balance
        continueData,
        52,
        requestBuffer,
      );

      outputType = requestBuffer[0];
    } else if (outputType === OutputType.ReadyToCommit) {
      // Get changes JSON (too large for requestBuffer)
      const changesBuffer = new Uint8Array(1024 * 1024);
      const changesLen = (wasm.exports.evm_get_state_changes as Function)(
        evmHandle,
        changesBuffer,
        changesBuffer.length,
      );

      const changesJson = new TextDecoder().decode(changesBuffer.slice(0, changesLen));
      const changes: StateChanges = JSON.parse(changesJson);

      await stateInterface.commitChanges(changes);

      (wasm.exports.evm_continue_ffi as Function)(
        evmHandle,
        5, // ContinueType.AfterCommit
        0,
        0,
        requestBuffer,
      );

      outputType = requestBuffer[0];
    } else {
      throw new Error(`Unknown output type: ${outputType}`);
    }
  }

  // Done - return result
  return {
    success: (wasm.exports.evm_is_success as Function)(evmHandle) !== 0,
    gasRemaining: (wasm.exports.evm_get_gas_remaining as Function)(evmHandle),
    gasUsed: (wasm.exports.evm_get_gas_used as Function)(evmHandle),
    output: getOutputFromWasm(wasm, evmHandle),
  };
}

// PUBLIC API - Simple async function
class EvmImpl implements Evm {
  async execute(): Promise<ExecutionResult> {
    await this.ready();
    // The internal function handles all the yield/continue logic
    return executeWithYieldHandling(
      this.wasm,
      this.handle,
      this.stateInterface,
    );
  }
}
```

**Key Points**:

- ✅ **Internal loop** handles all yields transparently
- ✅ **Public API** is just `async execute()` - no generators exposed
- ✅ **State interface optional** - falls back to sync mode if not provided
- ✅ **Clean separation** between internal mechanics and public API

---

## Part 2: Storage Injection Using Message Passing

Now that we have the async protocol, we can build storage injection on top of it.

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      TypeScript Layer                        │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  User-provided StateInterface (async methods)          │ │
│  │  - getStorage(addr, slot): Promise<U256>               │ │
│  │  - getBalance(addr): Promise<bigint>                   │ │
│  │  - getCode(addr): Promise<Bytes>                       │ │
│  │  - getNonce(addr): Promise<bigint>                     │ │
│  │  - commitChanges(changes): Promise<void>               │ │
│  └────────────────────────────────────────────────────────┘ │
│                            ↑                                 │
│                            │ called by                       │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  FFIMessenger (TypeScript)                             │ │
│  │  - handleMessage(msgId, type, payload)                 │ │
│  │  - Calls StateInterface.getStorage()                   │ │
│  │  - Calls wasm.exports.ffi_resume(result)               │ │
│  └────────────────────────────────────────────────────────┘ │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ extern "env" fn ffi_send_message() ← called BY Zig
                           │ export fn ffi_resume() ← called BY TypeScript
                           │
┌──────────────────────────┴──────────────────────────────────┐
│                        Zig Layer                             │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  FFIMessenger (Zig)                                     │ │
│  │  - sendAndAwait(type, payload)                         │ │
│  │  - Calls ffi_send_message() → TypeScript               │ │
│  │  - Suspends on @trap()                                 │ │
│  │  - Resumed by ffi_resume() ← TypeScript                │ │
│  └────────────────────────────────────────────────────────┘ │
│                            ↑                                 │
│                            │ used by                         │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  StorageInjector                                        │ │
│  │  - getStorage() → ffi_messenger.sendAndAwait()         │ │
│  │  - LRU cache (check before sending message)            │ │
│  │  - Dirty tracking (mark writes)                        │ │
│  │  - dumpChanges() (at tx end)                           │ │
│  └────────────────────────────────────────────────────────┘ │
│                            ↑                                 │
│                            │ used by                         │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Evm                                                    │ │
│  │  - get_storage() → StorageInjector.getStorage()        │ │
│  │  - set_storage() → StorageInjector.markDirty()         │ │
│  │  - call() end → StorageInjector.dumpChanges()          │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### StorageInjector Implementation

The `StorageInjector` is now a **thin wrapper** around `FFIMessenger` + LRU cache:

```zig
const std = @import("std");
const primitives = @import("primitives");
const Address = primitives.Address.Address;
const LruCache = @import("../Guillotine/src/storage/lru_cache.zig").LruCache;
const FFIMessenger = @import("ffi_messenger.zig").FFIMessenger;

pub const StorageInjector = struct {
    allocator: std.mem.Allocator,
    arena: *std.heap.ArenaAllocator,
    ffi_messenger: *FFIMessenger,

    // LRU cache (check before sending message)
    storage_cache: LruCache(StorageSlotKey, u256, .{
        .capacity = 1024,
        .HashContext = StorageHashContext,
    }),

    // Dirty tracking (for change dump)
    dirty_storage: std.AutoHashMap(StorageSlotKey, void),
    dirty_balances: std.AutoHashMap(Address, void),
    dirty_nonces: std.AutoHashMap(Address, void),
    dirty_codes: std.AutoHashMap(Address, void),

    pub fn init(arena: *std.heap.ArenaAllocator, ffi_messenger: *FFIMessenger) !StorageInjector {
        const allocator = arena.allocator();
        return StorageInjector{
            .allocator = allocator,
            .arena = arena,
            .ffi_messenger = ffi_messenger,
            .storage_cache = try LruCache(...).init(allocator),
            .dirty_storage = std.AutoHashMap(StorageSlotKey, void).init(allocator),
            .dirty_balances = std.AutoHashMap(Address, void).init(allocator),
            .dirty_nonces = std.AutoHashMap(Address, void).init(allocator),
            .dirty_codes = std.AutoHashMap(Address, void).init(allocator),
        };
    }

    /// Get storage value - check cache, then send async message
    pub fn getStorage(self: *StorageInjector, address: Address, slot: u256) !u256 {
        const key = StorageSlotKey{ .address = address, .slot = slot };

        // Check cache first
        if (self.storage_cache.get(key)) |value| {
            return value;
        }

        // Cache miss - send async message via FFIMessenger
        // This will suspend WASM execution until TypeScript responds
        const response_json = try self.ffi_messenger.getStorage(address.bytes, slot);

        // Parse response
        const value = try self.parseU256FromJson(response_json);

        // Cache the result
        _ = try self.storage_cache.put(key, value);

        return value;
    }

    /// Mark storage slot as dirty (called by Evm.set_storage)
    pub fn markStorageDirty(self: *StorageInjector, address: Address, slot: u256) !void {
        const key = StorageSlotKey{ .address = address, .slot = slot };
        try self.dirty_storage.put(key, {});
    }

    /// Dump all changes and commit via FFIMessenger
    pub fn dumpAndCommitChanges(self: *StorageInjector, evm: anytype) !void {
        // Build changes JSON (same as before)
        const changes_json = try self.buildChangesJson(evm);

        // Send via FFIMessenger - this suspends until TypeScript commits
        try self.ffi_messenger.commitChanges(changes_json);
    }

    /// Clear cache and dirty sets (called at start of new transaction)
    pub fn clearCache(self: *StorageInjector) void {
        self.storage_cache.clear();
        self.dirty_storage.clearRetainingCapacity();
        self.dirty_balances.clearRetainingCapacity();
        self.dirty_nonces.clearRetainingCapacity();
        self.dirty_codes.clearRetainingCapacity();
    }

    // ... helper methods for JSON parsing, change building, etc.
};
```

### Evm Integration with Async API

**Critical Design Decision**: We need a **separate method** for async execution that wraps `call()` but has **NO defer statements** that would corrupt state on early return.

```zig
pub fn Evm(config: EvmConfig) type {
    return struct {
        // ... existing fields ...

        storage_injector: ?*StorageInjector,

        // Async request written by get_storage/etc, read by executeUntilYieldOrComplete
        async_data_request: AsyncDataRequest,

        /// Input to callOrContinue - tagged union for starting or continuing
        pub const CallOrContinueInput = union(enum) {
            call: CallParams,
            continue_with_storage: struct {
                address: Address,
                slot: u256,
                value: u256,
            },
            continue_with_balance: struct {
                address: Address,
                balance: u256,
            },
            continue_with_code: struct {
                address: Address,
                code: []const u8,
            },
            continue_with_nonce: struct {
                address: Address,
                nonce: u64,
            },
            continue_after_commit: void,
        };

        /// Output from callOrContinue - tagged union for result or async request
        pub const CallOrContinueOutput = union(enum) {
            result: CallResult,
            need_storage: struct {
                address: Address,
                slot: u256,
            },
            need_balance: struct {
                address: Address,
            },
            need_code: struct {
                address: Address,
            },
            need_nonce: struct {
                address: Address,
            },
            ready_to_commit: struct {
                changes_json: []const u8,
            },
        };

        /// Main async execution method
        /// This wraps call() but supports yielding for async requests
        /// CRITICAL: NO defer statements that clean up state!
        pub fn callOrContinue(
            self: *Self,
            input: CallOrContinueInput,
        ) !CallOrContinueOutput {
            switch (input) {
                .call => |params| {
                    // Start new call - set up state
                    try self.initTransactionState(null);

                    if (self.storage_injector) |injector| {
                        injector.clearCache();
                    }

                    // Create frame WITHOUT defer
                    try self.frames.append(self.arena.allocator(), Frame.init(
                        self.arena.allocator(),
                        params.bytecode,
                        @intCast(params.gas),
                        params.caller,
                        params.address,
                        params.value,
                        params.calldata,
                        @ptrCast(self),
                        self.hardfork,
                        false,
                    ));

                    // Execute (may yield)
                    return try self.executeUntilYieldOrComplete();
                },

                .continue_with_storage => |data| {
                    // Store value in cache
                    if (self.storage_injector) |injector| {
                        const key = StorageSlotKey{
                            .address = data.address,
                            .slot = data.slot,
                        };
                        _ = try injector.storage_cache.put(key, data.value);
                    }

                    // Clear the request
                    self.async_data_request = .none;

                    // Continue execution
                    return try self.executeUntilYieldOrComplete();
                },

                .continue_with_balance => |data| {
                    if (self.storage_injector) |injector| {
                        try injector.balance_cache.put(data.address, data.balance);
                    }

                    // Clear the request
                    self.async_data_request = .none;

                    return try self.executeUntilYieldOrComplete();
                },

                .continue_after_commit => {
                    // Commit done - finalize and return result
                    return try self.finalizeAndReturnResult();
                },

                else => return error.UnsupportedContinueType,
            }
        }

        /// Execute until we hit a yield point or complete
        /// NO defer statements!
        fn executeUntilYieldOrComplete(self: *Self) !CallOrContinueOutput {
            while (self.frames.items.len > 0) {
                const frame = &self.frames.items[self.frames.items.len - 1];

                // Execute frame - may return error.NeedAsyncData
                frame.execute() catch |err| {
                    if (err == error.NeedAsyncData) {
                        // Read the request from evm.async_data_request
                        return switch (self.async_data_request) {
                            .storage => |req| .{ .need_storage = req },
                            .balance => |req| .{ .need_balance = req },
                            .code => |req| .{ .need_code = req },
                            .nonce => |req| .{ .need_nonce = req },
                            .none => error.InvalidAsyncState,
                        };
                    }

                    // Real error - return it (state preserved for debugging)
                    return err;
                };

                // Frame completed successfully
                // Check if this is the last frame AND we have storage injector
                if (self.frames.items.len == 1 and self.storage_injector != null) {
                    // Don't pop yet - need to dump changes first
                    const changes_json = try self.dumpStateChanges();
                    return .{ .ready_to_commit = .{ .changes_json = changes_json }};
                }

                // Pop frame (safe - not returning early)
                _ = self.frames.pop();
            }

            // All frames complete, no storage injector
            return try self.finalizeAndReturnResult();
        }

        /// Finalize execution and return result
        /// Called only when we're truly done (after commit if needed)
        fn finalizeAndReturnResult(self: *Self) !CallOrContinueOutput {
            // At this point frames should be empty OR we have one frame to finalize
            if (self.frames.items.len > 0) {
                const frame = self.frames.items[self.frames.items.len - 1];
                const output = try self.arena.allocator().dupe(u8, frame.output);
                const gas_left = @as(u64, @intCast(@max(frame.gas_remaining, 0)));
                const success = !frame.reverted;

                // NOW we can pop (we're returning the final result)
                _ = self.frames.pop();

                // Clean up transaction state (safe now)
                self.warm_addresses.clearRetainingCapacity();
                self.warm_storage_slots.clearRetainingCapacity();
                self.transient_storage.clearRetainingCapacity();

                return .{ .result = CallResult{
                    .success = success,
                    .gas_left = gas_left,
                    .output = output,
                }};
            }

            return .{ .result = CallResult{
                .success = true,
                .gas_left = 0,
                .output = &.{},
            }};
        }

        /// Dump state changes to JSON
        fn dumpStateChanges(self: *Self) ![]const u8 {
            if (self.storage_injector) |injector| {
                return try injector.dumpChanges(self);
            }
            return &.{};
        }

        pub fn get_storage(self: *Self, address: Address, slot: u256) !u256 {
            // Check cache first if using injector
            if (self.storage_injector) |injector| {
                const key = StorageSlotKey{ .address = address, .slot = slot };

                if (injector.storage_cache.get(key)) |value| {
                    return value;  // Cache hit
                }

                // Cache miss - write request to evm and yield
                self.async_data_request = .{ .storage = .{
                    .address = address,
                    .slot = slot,
                }};

                return error.NeedAsyncData;
            }

            // No injector - use host or internal HashMap
            if (self.host) |h| {
                return h.getStorage(address, slot);
            }

            const key = StorageSlotKey{ .address = address, .slot = slot };
            return self.storage.get(key) orelse 0;
        }

        pub fn set_storage(self: *Self, address: Address, slot: u256, value: u256) !void {
            const key = StorageSlotKey{ .address = address, .slot = slot };

            // Track original value (for gas refunds)
            if (!self.original_storage.contains(key)) {
                const original = try self.get_storage(address, slot);
                try self.original_storage.put(key, original);
            }

            // Mark dirty if using injector
            if (self.storage_injector) |injector| {
                try injector.markStorageDirty(address, slot);
            }

            // Write to internal map or host
            if (self.host) |h| {
                h.setStorage(address, slot, value);
            } else {
                if (value == 0) {
                    _ = self.storage.remove(key);
                } else {
                    try self.storage.put(key, value);
                }
            }
        }

        /// Original call() method - unchanged for backward compatibility
        pub fn call(self: *Self, params: CallParams) CallResult {
            // Use callOrContinue for async-capable execution
            const result = self.callOrContinue(.{ .call = params }) catch |err| {
                return CallResult.failure(self.arena.allocator(), 0) catch CallResult{
                    .success = false,
                    .gas_left = 0,
                    .output = &.{},
                };
            };

            // If we got an async request, that's an error in sync mode
            return switch (result) {
                .result => |r| r,
                else => CallResult.failure(self.arena.allocator(), 0) catch CallResult{
                    .success = false,
                    .gas_left = 0,
                    .output = &.{},
                },
            };
        }
    };
}
```

### StorageInjector with Pending Requests

```zig
pub const StorageInjector = struct {
    // ... existing fields ...

    // Pending async requests (only one at a time)
    pending_storage_request: ?struct { address: Address, slot: u256 },
    pending_balance_request: ?Address,
    pending_code_request: ?Address,
    pending_nonce_request: ?Address,

    // ... rest of implementation
};
```

### Frame.execute() Error Propagation

When `get_storage()` returns `error.NeedAsyncData`, it propagates up through the call stack:

```zig
// In Frame.execute()
pub fn execute(self: *Frame, evm: *Evm) !void {
    while (self.pc < self.bytecode.len) {
        const opcode = self.bytecode[self.pc];

        switch (opcode) {
            0x54 => { // SLOAD
                const slot = self.stack.pop();
                const value = try evm.get_storage(self.address, slot);
                //                ^^^ This may return error.NeedAsyncData
                try self.stack.push(value);
            },
            // ... other opcodes ...
        }
    }
}

// The error propagates:
// frame.execute(evm) catch |err| {
//     if (err == error.NeedAsyncData) {
//         // execution_status already set to NeedStorage
//         return; // Return to TypeScript
//     }
//     return err; // Real error
// }
```

**Key Point**: `error.NeedAsyncData` is not a failure - it's a **control flow signal** telling the execution loop to return early.

---

## Part 3: Complete Example

### TypeScript Usage

```typescript
import { createEvm, StateInterface, StateChanges } from "@guillotine/sdk";
import { ethers } from "ethers";

// Your async state provider
const provider = new ethers.JsonRpcProvider("https://eth.llamarpc.com");

// Implement the StateInterface with async methods
const stateInterface: StateInterface = {
  async getStorage(address: string, slot: string): Promise<string> {
    console.log(`[RPC] getStorage(${address}, ${slot})`);
    const value = await provider.getStorage(address, slot);
    console.log(`[RPC] → ${value}`);
    return value;
  },

  async getBalance(address: string): Promise<bigint> {
    console.log(`[RPC] getBalance(${address})`);
    return await provider.getBalance(address);
  },

  async getCode(address: string): Promise<string> {
    console.log(`[RPC] getCode(${address})`);
    return await provider.getCode(address);
  },

  async getNonce(address: string): Promise<bigint> {
    console.log(`[RPC] getNonce(${address})`);
    return BigInt(await provider.getTransactionCount(address));
  },

  async commitChanges(changes: StateChanges): Promise<void> {
    console.log("[Commit] Received state changes:", {
      storage: changes.storage.length,
      balances: changes.balances.length,
      nonces: changes.nonces.length,
      codes: changes.codes.length,
      selfDestructs: changes.selfDestructs.length,
    });

    // In a real app: batch write to database
    for (const change of changes.storage) {
      console.log(
        `  SSTORE: ${change.address}[${change.slot}] = ${change.newValue}`,
      );
    }

    console.log("[Commit] Changes committed successfully");
  },
};

// Create EVM with async state interface
const evm = await createEvm({
  hardfork: "CANCUN",
  stateInterface, // Async methods!
});

// Execute transaction
await evm.setExecutionContext({
  gas: 1000000n,
  caller: "0x...",
  address: "0x...",
  value: 0n,
  calldata: "0x...",
});

await evm.setBlockchainContext({
  /* ... */
});

console.log("[Execute] Starting transaction...");
const result = await evm.execute();
console.log("[Execute] Result:", result);

// During execution:
// 1. SLOAD → cache miss → ffi_send_message() → WASM suspends
// 2. TypeScript: await stateInterface.getStorage() → RPC call
// 3. TypeScript: ffi_resume() → WASM resumes with value
// 4. Transaction completes → dumpChanges() → ffi_send_message()
// 5. TypeScript: await stateInterface.commitChanges()
// 6. Done!
```

### Execution Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. evm.execute()                                                 │
└────────────┬────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. Evm.call() starts                                             │
│    - storage_injector.clearCache()                               │
└────────────┬────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. Execute bytecode                                              │
│    - SLOAD at 0x1234[slot=0]                                     │
└────────────┬────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. Evm.get_storage(0x1234, 0)                                    │
│    → storage_injector.getStorage()                               │
│    → Check cache: MISS                                           │
│    → ffi_messenger.getStorage()                                  │
│    → ffi_send_message(msgId=1, type=GetStorage, {addr, slot})   │
│    → @trap() ⏸️  SUSPEND HERE                                    │
└─────────────────────────────────────────────────────────────────┘
                        │
                        │ WASM frozen
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│ 5. TypeScript FFIMessenger.handleMessage()                       │
│    - Parse: { type: "getStorage", addr: "0x1234", slot: "0x0" } │
│    - await stateInterface.getStorage("0x1234", "0x0")            │
│    - RPC call to Ethereum node...                                │
│    - Response: "0x0000...0042"                                   │
│    - Serialize to JSON: {"value": "0x42"}                        │
│    - wasm.ffi_resume(msgId=1, result)                            │
└────────────┬────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 6. Zig ffi_resume() called                                       │
│    → ffi_messenger.resumeMessage(1, "0x42")                      │
│    → storage_injector.getStorage() returns 0x42                  │
│    → Cache: put(0x1234:0, 0x42)                                  │
│    → Execution continues ▶️                                       │
└────────────┬────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 7. Execute SSTORE at 0x1234[slot=0] = 0x99                      │
│    → Evm.set_storage()                                           │
│    → storage_injector.markStorageDirty()                         │
│    → Write to internal HashMap                                   │
└────────────┬────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 8. Transaction ends successfully                                 │
│    → storage_injector.dumpAndCommitChanges()                     │
│    → Build JSON: {storage: [{addr, slot, old: 0x42, new: 0x99}]}│
│    → ffi_messenger.commitChanges(json)                           │
│    → ffi_send_message(msgId=2, type=CommitChanges, json)        │
│    → @trap() ⏸️  SUSPEND HERE                                    │
└─────────────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│ 9. TypeScript FFIMessenger.handleMessage()                       │
│    - Parse: { type: "commitChanges", changes: {...} }           │
│    - await stateInterface.commitChanges(changes)                 │
│    - User writes to database/RPC/cache                           │
│    - Response: {"success": true}                                 │
│    - wasm.ffi_resume(msgId=2, result)                            │
└────────────┬────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 10. Zig resumes, transaction complete                            │
│     → Return CallResult to user                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Part 4: Key Design Decisions

### 1. Message Passing is the Foundation

**Everything** goes through the message passing protocol:

- ✅ Zig stays synchronous (no async/await)
- ✅ TypeScript stays async (natural fit)
- ✅ Clean abstraction boundary
- ✅ Testable in isolation

### 2. FFIMessenger is Reusable

The `FFIMessenger` isn't storage-specific - it's a general async communication layer:

- Can be used for custom opcodes (already done)
- Can be used for custom precompiles (already done)
- Can be used for storage injection (this feature)
- Can be used for future features (logging, debugging, etc.)

### 3. StorageInjector = LRU Cache + Dirty Tracking

`StorageInjector` manages:

- LRU cache (check before requesting)
- Dirty sets (track writes)
- Change dumping (build JSON)

**No message passing logic** - that's handled by the C API and TypeScript loop.

### 4. State Preservation Between Calls

WASM heap persists between function calls:

- ✅ Evm struct preserved in WASM memory
- ✅ Stack frames preserved
- ✅ Cache preserved
- ✅ Pending request/response preserved

When `evm_execute()` returns, the entire `Evm` state is intact. When `evm_continue()` is called, it picks up exactly where it left off.

### 5. Cache is Critical

Without the LRU cache, **every** SLOAD would be an async RPC call:

- ❌ 100+ RPC calls per transaction
- ❌ 10-100ms latency per call
- ❌ 1-10 seconds total execution time

With 1024-entry LRU cache:

- ✅ ~90% cache hit rate (typical transaction)
- ✅ 10-20 RPC calls per transaction
- ✅ 100-200ms total execution time

---

## TDD Implementation Order

### Phase 1: Core Types and Error Handling

**Goal**: Set up the basic types and error infrastructure

1. **Add `AsyncDataRequest` union to `src/evm.zig`**
   - Test: Verify union size and field access
   - Test: Can write and read each variant

2. **Add `error.NeedAsyncData` to error set**
   - Test: Error can be caught and identified
   - Test: Error propagates through call stack

3. **Add `async_data_request` field to Evm struct**
   - Test: Field initialized to `.none`
   - Test: Can write/read different request types

### Phase 2: Storage Injector with LRU Cache

**Goal**: Get caching working without async (using mock data)

4. **Create `src/storage_injector.zig` with LRU cache**
   - Copy LRU cache from `Guillotine/src/storage/lru_cache.zig`
   - Test: Cache init/deinit
   - Test: Cache put/get/clear
   - Test: Cache hit/miss tracking

5. **Add dirty tracking to StorageInjector**
   - Test: `markStorageDirty()` adds to dirty set
   - Test: Dirty set clears on `clearCache()`
   - Test: Multiple marks for same slot (idempotent)

6. **Integrate StorageInjector into Evm.init()**
   - Test: Evm with injector vs without injector
   - Test: Injector created with arena allocator
   - Test: Injector cleaned up on deinit

### Phase 3: Modified get_storage() with Yield

**Goal**: Make `get_storage()` write to `async_data_request` and return error

7. **Update `Evm.get_storage()` to check cache**
   - Test: Cache hit returns immediately
   - Test: Cache miss with no injector uses HashMap
   - Test: Cache miss with injector writes request and returns error

8. **Test error propagation from Frame**
   - Test: SLOAD opcode catches `error.NeedAsyncData`
   - Test: Error propagates through `frame.execute()`
   - Test: Frame state preserved (PC, stack, memory intact)

### Phase 4: callOrContinue() Implementation

**Goal**: Implement the yield/continue logic without defer statements

9. **Add `CallOrContinueInput` and `CallOrContinueOutput` unions**
   - Test: Can construct each variant
   - Test: Can pattern match on each variant

10. **Implement `callOrContinue()` method**
    - Test: `.call` variant starts execution
    - Test: Returns `.need_storage` on cache miss
    - Test: Frames NOT popped when yielding
    - Test: No defer statements executed on yield

11. **Implement `executeUntilYieldOrComplete()`**
    - Test: Reads `async_data_request` when catching error
    - Test: Returns correct output variant
    - Test: Frames preserved on yield
    - Test: Frames popped only when actually complete

12. **Implement continue variants**
    - Test: `.continue_with_storage` caches value
    - Test: `.continue_with_storage` clears request
    - Test: Execution continues from exact same state
    - Test: Can yield multiple times in one transaction

### Phase 5: C API (evm_call_ffi / evm_continue_ffi)

**Goal**: Expose the functionality to WASM/TypeScript

13. **Add `evm_call_ffi()` to `src/root_c.zig`**
    - Test: Returns output_type correctly
    - Test: Packs request into output buffer
    - Test: Result stored in ctx when done

14. **Add `evm_continue_ffi()` to `src/root_c.zig`**
    - Test: Unpacks continue data correctly
    - Test: Calls `callOrContinue()` with right variant
    - Test: Returns next request or result

15. **Add `evm_get_state_changes()`**
    - Test: Returns JSON when ready_to_commit
    - Test: JSON fits in buffer
    - Test: Returns 0 if not ready

### Phase 6: Change Tracking and Dumping

**Goal**: Track writes and dump changes at transaction end

16. **Implement `dumpChanges()` in StorageInjector**
    - Test: Empty dirty set returns empty arrays
    - Test: Storage changes include original and new values
    - Test: Only changed values included (not unchanged)
    - Test: Balance/nonce/code changes tracked

17. **Update `set_storage()` to mark dirty**
    - Test: Write marks slot dirty
    - Test: Original value tracked correctly
    - Test: Multiple writes to same slot (only marked once)

18. **Integrate commit into `callOrContinue()`**
    - Test: Returns `.ready_to_commit` after last frame
    - Test: Changes JSON includes all modifications
    - Test: `.continue_after_commit` finalizes result

### Phase 7: TypeScript SDK Integration

**Goal**: Wire up the TypeScript side

19. **Add `StateInterface` type to `sdks/typescript/src/types.ts`**
    - Test: TypeScript compiles
    - Test: Interface matches expected shape

20. **Implement `executeWithYieldHandling()` in `sdks/typescript/src/evm.ts`**
    - Test: Calls `evm_call_ffi()` to start
    - Test: Handles `NeedStorage` and calls `evm_continue_ffi()`
    - Test: Loops until `Result` received
    - Test: Commits changes when `ReadyToCommit`

21. **Update `EvmImpl.execute()` to use yield handling**
    - Test: With `stateInterface` uses async path
    - Test: Without `stateInterface` uses sync path
    - Test: End-to-end: mock state interface returns values

### Phase 8: Integration Tests

**Goal**: Test the complete flow end-to-end

22. **Test with mock state provider**
    - Test: Simple SLOAD/SSTORE transaction
    - Test: Multiple cache misses in one tx
    - Test: Balance/nonce reads work
    - Test: Commit called with correct changes

23. **Test error handling**
    - Test: State interface throws → execution fails gracefully
    - Test: Invalid continue type → error
    - Test: State preserved on error

24. **Test performance**
    - Test: Cache hit rate measured
    - Test: Number of async calls counted
    - Test: Verify LRU eviction works

### Phase 9: Real RPC Integration

**Goal**: Test with actual Ethereum RPC provider

25. **Example: Ethers.js provider**
    - Test: Can read mainnet storage
    - Test: Can execute real contract calls
    - Test: Changes committed correctly

---

## TDD Order Summary

**Bottom-Up Approach**:
1. ✅ Types & errors (foundation)
2. ✅ LRU cache (isolated, testable)
3. ✅ Yield mechanism (core logic)
4. ✅ callOrContinue (no defer!)
5. ✅ C API (WASM boundary)
6. ✅ Change tracking (dirty sets)
7. ✅ TypeScript wrapper (yield loop)
8. ✅ Integration (end-to-end)
9. ✅ Real RPC (validation)

Each step has **tests written first**, then implementation to make tests pass.

---

## Part 6: Benefits & Trade-offs

### Benefits

1. ✅ **True Async Support**: TypeScript methods can be genuinely async
2. ✅ **Clean Abstraction**: Message passing protocol is reusable
3. ✅ **Synchronous Zig**: No async/await complexity
4. ✅ **Flexible**: Any data source (RPC, DB, cache, custom)
5. ✅ **Performant**: LRU cache minimizes async calls
6. ✅ **Testable**: Each layer testable in isolation
7. ✅ **Backward Compatible**: Existing code unchanged

### Trade-offs

1. ⚠️ **Complexity**: More moving parts (messenger + injector)
2. ⚠️ **Latency**: Async calls add latency (mitigated by cache)
3. ⚠️ **Global State**: `FFIMessenger` needs to be accessible in `ffi_resume()`
4. ⚠️ **Error Handling**: Must handle timeouts, network failures gracefully

### Performance Characteristics

| Operation        | Latency   | Notes              |
| ---------------- | --------- | ------------------ |
| Cache hit        | ~100ns    | LRU lookup         |
| Cache miss + RPC | ~10-100ms | Network call       |
| Mark dirty       | ~200ns    | HashMap insert     |
| Dump changes     | ~1-10ms   | JSON serialization |
| Commit           | ~10-100ms | User-defined       |

**Typical transaction**: 10-20 cache misses → 100-200ms total

---

## Summary

This design implements async storage through a **state machine pattern**:

1. ✅ **Part 1**: Execution state machine (return with status codes, not suspend)
2. ✅ **Part 2**: Storage injector with LRU cache + dirty tracking
3. ✅ **Part 3**: TypeScript execution loop handles async calls
4. ✅ **Part 4**: Complete execution flow with examples
5. ✅ **Part 5**: Phased implementation checklist

**Key Insight**: No `@trap()`, no Asyncify, no magic. Just:

- Zig returns early with status code when async data needed
- TypeScript awaits the async call
- TypeScript calls `evm_continue()` with result
- Zig continues from where it left off (state preserved in WASM heap)

---

**Document Status**: Complete v2 design with proper async protocol
**Last Updated**: 2025-10-08
**Next**: Review and approve → implement phase-by-phase
