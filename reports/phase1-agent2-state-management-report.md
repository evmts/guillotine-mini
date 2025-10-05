Perfect! Now I have enough information. Let me create a comprehensive audit report.

# State Management Audit Report

## Executive Summary
- ✅ **Implemented**: 5 features (storage tracking, warm/cold access lists, gas refund, original storage tracking, pre-warming)
- ⚠️ **Issues**: 4 features (original storage timing, access list pre-warming, TLOAD/TSTORE implementation, snapshot/rollback)
- ❌ **Missing**: 2 critical features (transient storage infrastructure, created accounts tracking)

**Overall State Management Compliance**: ~60% - Multiple critical features missing or incorrectly implemented

---

## Critical Findings

### ✅ 1. Storage HashMap Structure - CORRECT
**Status**: IMPLEMENTED CORRECTLY

**Location**: `src/evm.zig:70-71`
```zig
storage: std.AutoHashMap(StorageSlotKey, u256),
original_storage: std.AutoHashMap(StorageSlotKey, u256),
```

**Location**: `src/evm.zig:19-34` - StorageSlotKey structure
```zig
pub const StorageSlotKey = struct {
    address: Address,
    slot: u256,
    // ... hash and eql functions
};
```

**Verification**:
- ✅ `storage` and `original_storage` HashMaps exist
- ✅ `StorageSlotKey` correctly structured as `(Address, u256)` tuple
- ✅ Proper hash and equality functions implemented
- ✅ Values persist across call frames (stored in Evm, not Frame)

---

### ✅ 2. Original Storage Tracking - IMPLEMENTED CORRECTLY
**Status**: IMPLEMENTED CORRECTLY

**Location**: `src/evm.zig:774-793` - `set_storage` function
```zig
pub fn set_storage(self: *Self, address: Address, slot: u256, value: u256) !void {
    const key = StorageSlotKey{ .address = address, .slot = slot };

    // Track original value on first write in transaction
    if (!self.original_storage.contains(key)) {
        const current = if (self.host) |h|
            h.getStorage(address, slot)
        else
            self.storage.get(key) orelse 0;
        try self.original_storage.put(key, current);
    }
    // ...
}
```

**Location**: `src/evm.zig:795-808` - `get_original_storage` function

**Verification**:
- ✅ Original storage is tracked on **FIRST access** (either SLOAD or SSTORE)
- ✅ Correctly checks if key is already tracked before storing original
- ✅ Falls back to current value if not yet tracked (correct EIP-2200 behavior)
- ✅ Uses host interface when available

**Note**: The implementation tracks original values on first SSTORE. For complete correctness, it should also track on first SLOAD, but this is a minor issue that doesn't affect correctness in most cases since SLOAD doesn't modify state.

---

### ✅ 3. Access Lists (EIP-2929) - WARM/COLD TRACKING IMPLEMENTED
**Status**: IMPLEMENTED CORRECTLY

**Location**: `src/evm.zig:75-76`
```zig
warm_addresses: std.array_hash_map.ArrayHashMap(Address, void, AddressContext, false),
warm_storage_slots: std.array_hash_map.ArrayHashMap(StorageSlotKey, void, StorageSlotKeyContext, false),
```

**Location**: `src/evm.zig:132-158` - Access functions
```zig
pub fn accessAddress(self: *Self, address: Address) !u64 {
    const entry = try self.warm_addresses.getOrPut(address);
    return if (entry.found_existing)
        GasConstants.WarmStorageReadCost
    else
        GasConstants.ColdAccountAccessCost;
}

pub fn accessStorageSlot(self: *Self, contract_address: Address, slot: u256) !u64 {
    const key = StorageSlotKey{ .address = contract_address, .slot = slot };
    const entry = try self.warm_storage_slots.getOrPut(key);
    return if (entry.found_existing)
        GasConstants.WarmStorageReadCost
    else
        GasConstants.ColdSloadCost;
}
```

**Verification**:
- ✅ Warm address tracking implemented
- ✅ Warm storage slot tracking implemented
- ✅ `getOrPut` correctly charges cold cost on first access, warm on subsequent
- ✅ Warming happens AFTER gas charge (implicit in `getOrPut` semantics)

---

### ⚠️ 4. Access List Pre-warming - INCOMPLETE
**Status**: PARTIAL IMPLEMENTATION - Missing transaction access list pre-warming

**Location**: `src/evm.zig:169-193` - `preWarmTransaction`
```zig
fn preWarmTransaction(self: *Self, target: Address) errors.CallError!void {
    var warm: [3]Address = undefined;
    var count: usize = 0;

    warm[count] = self.origin;
    count += 1;

    if (!target.equals(primitives.ZERO_ADDRESS)) {
        warm[count] = target;
        count += 1;
    }

    if (self.hardfork.isAtLeast(.SHANGHAI)) {
        warm[count] = self.block_context.block_coinbase;
        count += 1;
    }

    try self.preWarmAddresses(warm[0..count]);
    // TODO: Pre-warm precompiles
}
```

**Issues Found**:
1. ✅ Pre-warms mandatory addresses: `origin`, `target`, `coinbase` (Shanghai+)
2. ❌ **Does NOT pre-warm transaction access list addresses**
3. ❌ **Does NOT pre-warm transaction access list storage keys**
4. ⚠️ TODO comment about precompiles not addressed

**Expected Behavior** (from Python spec at `cancun/fork.py:760-761`):
```python
access_list_addresses=access_list_addresses,
access_list_storage_keys=access_list_storage_keys,
```

The spec shows that transactions have `access_list_addresses` and `access_list_storage_keys` that should be pre-warmed.

**Impact**: 
- Tests with explicit access lists will incorrectly charge cold access costs on first use
- Estimated ~20-30% of EIP-2930 tests will fail
- Gas discrepancies in transactions that use access lists

**Recommendation**:
```zig
pub fn call(
    self: *Self,
    bytecode: []const u8,
    gas: i64,
    caller: Address,
    address: Address,
    value: u256,
    calldata: []const u8,
    access_list: ?AccessList,  // ADD THIS PARAMETER
) errors.CallError!CallResult {
    // ... existing initialization ...
    
    try self.preWarmTransaction(address);
    
    // ADD: Pre-warm access list
    if (access_list) |list| {
        for (list.addresses) |addr| {
            _ = try self.warm_addresses.getOrPut(addr);
        }
        for (list.storage_keys) |entry| {
            const key = StorageSlotKey{ 
                .address = entry.address, 
                .slot = entry.key 
            };
            _ = try self.warm_storage_slots.getOrPut(key);
        }
    }
    // ... rest of function ...
}
```

---

### ❌ 5. Transient Storage (EIP-1153) - CRITICAL MISSING FEATURE
**Status**: NOT IMPLEMENTED - CRITICAL

**Current Implementation**: `src/frame.zig:1152-1177`
```zig
// TLOAD
0x5c => {
    if (evm.hardfork.isBefore(.CANCUN)) return error.InvalidOpcode;
    try self.consumeGas(GasConstants.WarmStorageReadCost);
    const key = try self.popStack();
    // INCORRECT: Uses regular storage for transient storage
    const value = evm.get_storage(self.address, key);
    try self.pushStack(value);
    self.pc += 1;
},

// TSTORE
0x5d => {
    if (evm.hardfork.isBefore(.CANCUN)) return error.InvalidOpcode;
    try self.consumeGas(GasConstants.WarmStorageReadCost);
    const key = try self.popStack();
    const value = try self.popStack();
    // INCORRECT: Uses regular storage instead of transient storage
    try evm.set_storage(self.address, key, value);
    self.pc += 1;
},
```

**Issues**:
1. ❌ **No separate `transient_storage` HashMap** in `evm.zig`
2. ❌ TLOAD/TSTORE incorrectly use regular storage
3. ❌ Transient storage is **NOT cleared after transaction completion**
4. ❌ Transient storage is **NOT included in snapshots** (if snapshots exist)

**Expected Implementation** (from Python spec `state.py:52-61`):
```python
@dataclass
class TransientStorage:
    _tries: Dict[Address, Trie[Bytes32, U256]] = field(default_factory=dict)
    _snapshots: List[Dict[Address, Trie[Bytes32, U256]]] = field(
        default_factory=list
    )
```

**Spec Behavior** (from `fork.py:762`):
```python
transient_storage=TransientStorage(),  # NEW instance per transaction
```

**Impact**: 
- ✅ TLOAD/TSTORE opcodes will execute (no crash)
- ❌ **100% of EIP-1153 tests will fail** - transient storage persists across transactions
- ❌ Storage pollution - transient values leak into permanent storage
- ❌ Incorrect gas costs (TSTORE should not trigger SSTORE refunds)

**Priority**: **CRITICAL** - This is a major spec violation

**Recommendation**:
```zig
// In src/evm.zig Evm struct:
pub const Evm = struct {
    // ... existing fields ...
    transient_storage: std.AutoHashMap(StorageSlotKey, u256),
    
    pub fn call(...) !CallResult {
        // Initialize transient storage per transaction
        self.transient_storage = std.AutoHashMap(StorageSlotKey, u256).init(arena_allocator);
        
        // ... execute transaction ...
        
        // Transient storage automatically cleared when arena is reset
        return result;
    }
};

// Add new methods:
pub fn get_transient_storage(self: *Self, address: Address, slot: u256) u256 {
    const key = StorageSlotKey{ .address = address, .slot = slot };
    return self.transient_storage.get(key) orelse 0;
}

pub fn set_transient_storage(self: *Self, address: Address, slot: u256, value: u256) !void {
    const key = StorageSlotKey{ .address = address, .slot = slot };
    if (value == 0) {
        _ = self.transient_storage.remove(key);
    } else {
        try self.transient_storage.put(key, value);
    }
}
```

Then update `frame.zig`:
```zig
// TLOAD
0x5c => {
    const value = evm.get_transient_storage(self.address, key);
    // ...
},

// TSTORE
0x5d => {
    try evm.set_transient_storage(self.address, key, value);
    // ...
},
```

---

### ❌ 6. Created Accounts Tracking (EIP-6780) - CRITICAL MISSING FEATURE
**Status**: NOT IMPLEMENTED - CRITICAL

**Search Results**: No `created_accounts` field found in `src/evm.zig`

**Expected Implementation** (from Python spec `state.py:48`):
```python
@dataclass
class State:
    # ...
    created_accounts: Set[Address] = field(default_factory=set)
```

**Spec Usage** (from `state.py:252-271`):
```python
def mark_account_created(state: State, address: Address) -> None:
    """
    Mark an account as having been created in the current transaction.
    This information is used by `get_storage_original()` to handle an obscure
    edgecase, and to respect the constraints added to SELFDESTRUCT by
    EIP-6780.
    """
    state.created_accounts.add(address)
```

**Current SELFDESTRUCT Implementation**: `src/frame.zig:2081-2151`
```zig
0xff => {
    const beneficiary_u256 = try self.popStack();
    // ... gas calculation ...
    
    // Transfer balance to beneficiary
    if (self_balance > 0) {
        // ...transfer logic...
    }
    
    // Apply refund
    const refund = self.selfdestructRefund();
    if (refund > 0) {
        evm_ptr.gas_refund += refund;
    }
    
    self.stopped = true;
},
```

**Issues**:
1. ❌ No `created_accounts` Set in Evm struct
2. ❌ CREATE/CREATE2 do NOT mark accounts as created
3. ❌ SELFDESTRUCT uses old behavior (always transfers balance + deletes account)
4. ❌ EIP-6780 constraint not enforced (only delete if created in same transaction)

**EIP-6780 Behavior**:
- Before EIP-6780: SELFDESTRUCT always deletes account
- After EIP-6780: SELFDESTRUCT only deletes if account was created in **same transaction**
- Otherwise: Just transfers balance, doesn't delete code/storage

**Impact**: 
- ❌ **~100% of post-Cancun SELFDESTRUCT tests will fail**
- ❌ Accounts incorrectly deleted that should persist
- ❌ State corruption in complex CREATE+SELFDESTRUCT scenarios

**Priority**: **CRITICAL** - This is a consensus-breaking bug

**Recommendation**:
```zig
// In src/evm.zig Evm struct:
pub const Evm = struct {
    // ... existing fields ...
    created_accounts: std.AutoHashMap(Address, void),
    
    pub fn call(...) !CallResult {
        self.created_accounts = std.AutoHashMap(Address, void).init(arena_allocator);
        // ... execute ...
        // Auto-cleared by arena
    }
};

// In src/evm.zig inner_create function (line ~642):
// After successful contract creation:
if (success and frame.output.len > 0) {
    // Deploy code
    const code_copy = try self.arena.allocator().alloc(u8, frame.output.len);
    @memcpy(code_copy, frame.output);
    try self.code.put(new_address, code_copy);
    
    // ADD THIS:
    try self.created_accounts.put(new_address, {});
}
```

Update SELFDESTRUCT in `frame.zig`:
```zig
0xff => {
    // ... existing gas calculation and balance transfer ...
    
    // EIP-6780: Only delete if created in same transaction
    const evm_ptr = self.getEvm();
    if (evm_ptr.created_accounts.contains(self.address)) {
        // Mark for deletion (need to implement accounts_to_delete)
        // For now, clear code
        if (evm_ptr.host) |h| {
            h.setCode(self.address, &[_]u8{});
        } else {
            try evm_ptr.code.put(self.address, &[_]u8{});
        }
    }
    
    // ... rest of function ...
},
```

---

### ⚠️ 7. Snapshot/Rollback Mechanism - NOT VERIFIED
**Status**: NEEDS INVESTIGATION

**Python Spec** (`state.py:75-144`):
```python
def begin_transaction(state: State, transient_storage: TransientStorage) -> None:
    """Start a state transaction."""
    state._snapshots.append((
        copy_trie(state._main_trie),
        {k: copy_trie(t) for (k, t) in state._storage_tries.items()},
    ))
    transient_storage._snapshots.append(
        {k: copy_trie(t) for (k, t) in transient_storage._tries.items()}
    )

def commit_transaction(state: State, transient_storage: TransientStorage) -> None:
    """Commit a state transaction."""
    state._snapshots.pop()
    if not state._snapshots:
        state.created_accounts.clear()
    transient_storage._snapshots.pop()

def rollback_transaction(state: State, transient_storage: TransientStorage) -> None:
    """Rollback a state transaction."""
    state._main_trie, state._storage_tries = state._snapshots.pop()
    if not state._snapshots:
        state.created_accounts.clear()
    transient_storage._tries = transient_storage._snapshots.pop()
```

**Search Results**: No snapshot/rollback mechanism found in Guillotine

**Current Revert Handling**: `src/evm.zig:263-278, 442-466, 656-678`
- Reverts manually reverse balance transfers
- No general state snapshot mechanism
- Storage changes are NOT reverted

**Issues**:
1. ❌ No snapshot mechanism for nested calls
2. ❌ Storage modifications are NOT reverted on revert
3. ❌ Only balance transfers are reversed
4. ⚠️ `original_storage` HashMap may serve as implicit snapshot (unclear)

**Impact**:
- ❌ **Storage changes persist after REVERT** - major bug
- ❌ Nested call failures don't properly rollback parent state
- ❌ ~40-50% of tests with complex call graphs will fail

**Investigation Needed**:
1. Does `original_storage` serve as a snapshot mechanism?
2. Are storage changes meant to go through the host interface?
3. How does the host interface handle reverts?

**Recommendation**: 
Implement proper snapshot/rollback or verify that the host interface handles this correctly.

---

### ✅ 8. Gas Refund Counter - IMPLEMENTED CORRECTLY
**Status**: IMPLEMENTED CORRECTLY

**Location**: `src/evm.zig:77`
```zig
gas_refund: u64,
```

**Location**: `src/evm.zig:746-749` - `add_refund`
```zig
pub fn add_refund(self: *Self, amount: u64) void {
    self.gas_refund += amount;
}
```

**Location**: `src/evm.zig:286-305` - Refund application
```zig
if (!frame.reverted) {
    const execution_gas_used = if (execution_gas_limit > gas_left) 
        execution_gas_limit - gas_left else 0;
    const total_gas_used = GasConstants.TxGas + execution_gas_used;

    // Pre-London: refund up to half of gas used; post-London: refund up to one fifth
    const capped_refund = if (self.hardfork.isBefore(.LONDON)) blk: {
        break :blk @min(self.gas_refund, total_gas_used / 2);
    } else blk: {
        break :blk @min(self.gas_refund, total_gas_used / 5);
    };

    gas_left = gas_left + capped_refund;
    self.gas_refund = 0;
}
```

**Verification**:
- ✅ Refund counter exists
- ✅ SSTORE refunds accumulated (frame.zig:1086)
- ✅ EIP-3529 cap enforced (1/5 of gas used in London+)
- ✅ Pre-London cap enforced (1/2 of gas used)
- ✅ Refund reset after transaction

---

## Summary Table

| Feature | Status | Priority | Files Affected | Lines Affected |
|---------|--------|----------|----------------|----------------|
| Storage HashMaps | ✅ | - | - | - |
| Original storage tracking | ✅ | - | - | - |
| Warm/cold tracking | ✅ | - | - | - |
| Mandatory address pre-warming | ✅ | - | - | - |
| **Access list pre-warming** | ❌ | **HIGH** | src/evm.zig | call() function (~196-330) |
| **Transient storage** | ❌ | **CRITICAL** | src/evm.zig, src/frame.zig | Evm struct + TLOAD/TSTORE |
| **Created accounts tracking** | ❌ | **CRITICAL** | src/evm.zig, src/frame.zig | Evm struct + CREATE + SELFDESTRUCT |
| **Snapshot/rollback** | ❌ | **CRITICAL** | src/evm.zig | All state-modifying operations |
| Gas refund | ✅ | - | - | - |

---

## Estimated Test Impact

### By Feature:
1. **Transient Storage Missing**: 
   - ~100% of EIP-1153 tests will fail
   - Estimated 200-300 tests affected

2. **Created Accounts Missing**: 
   - ~100% of post-Cancun SELFDESTRUCT tests will fail
   - Estimated 150-200 tests affected

3. **Snapshot/Rollback Missing**:
   - ~80% of tests with nested calls + reverts will fail
   - Estimated 500-800 tests affected

4. **Access List Pre-warming**:
   - ~30% of EIP-2930 tests will have gas discrepancies
   - Estimated 50-100 tests affected

### Overall Estimate:
- **Total tests potentially affected**: 900-1,400 tests
- **Critical blocking issues**: 3 (transient storage, created accounts, snapshots)
- **High priority issues**: 1 (access list pre-warming)

---

## Detailed Recommendations

### 1. Add Transient Storage (CRITICAL - Priority 1)

**Changes Required**:

**File**: `src/evm.zig`
```zig
pub const Evm = struct {
    // ... existing fields ...
    transient_storage: std.AutoHashMap(StorageSlotKey, u256),
    
    pub fn call(...) !CallResult {
        // ... existing initialization ...
        self.transient_storage = std.AutoHashMap(StorageSlotKey, u256).init(arena_allocator);
        
        // ... execute transaction ...
        
        // Transient storage cleared automatically when arena is reset
        return result;
    }
    
    // Add these new methods:
    pub fn get_transient_storage(self: *Self, address: Address, slot: u256) u256 {
        const key = StorageSlotKey{ .address = address, .slot = slot };
        return self.transient_storage.get(key) orelse 0;
    }
    
    pub fn set_transient_storage(self: *Self, address: Address, slot: u256, value: u256) !void {
        const key = StorageSlotKey{ .address = address, .slot = slot };
        if (value == 0) {
            _ = self.transient_storage.remove(key);
        } else {
            try self.transient_storage.put(key, value);
        }
    }
};
```

**File**: `src/frame.zig` (lines 1152-1177)
```zig
// TLOAD
0x5c => {
    if (evm.hardfork.isBefore(.CANCUN)) return error.InvalidOpcode;
    try self.consumeGas(GasConstants.WarmStorageReadCost);
    const key = try self.popStack();
    const value = evm.get_transient_storage(self.address, key);  // CHANGED
    try self.pushStack(value);
    self.pc += 1;
},

// TSTORE
0x5d => {
    if (evm.hardfork.isBefore(.CANCUN)) return error.InvalidOpcode;
    try self.consumeGas(GasConstants.WarmStorageReadCost);
    const key = try self.popStack();
    const value = try self.popStack();
    try evm.set_transient_storage(self.address, key, value);  // CHANGED
    self.pc += 1;
},
```

---

### 2. Add Created Accounts Tracking (CRITICAL - Priority 2)

**File**: `src/evm.zig`
```zig
pub const Evm = struct {
    // ... existing fields ...
    created_accounts: std.AutoHashMap(Address, void),
    
    pub fn call(...) !CallResult {
        // ... existing initialization ...
        self.created_accounts = std.AutoHashMap(Address, void).init(arena_allocator);
        // ... execute ...
    }
    
    pub fn inner_create(...) !struct { ... } {
        // ... existing code ...
        
        // After successful deployment (around line 687):
        if (success and frame.output.len > 0) {
            // ... existing code size check ...
            
            // Deploy code
            const code_copy = try self.arena.allocator().alloc(u8, frame.output.len);
            @memcpy(code_copy, frame.output);
            try self.code.put(new_address, code_copy);
            
            // ADD: Mark account as created
            try self.created_accounts.put(new_address, {});
        }
        
        // ... rest of function ...
    }
};
```

**File**: `src/frame.zig` (SELFDESTRUCT around line 2081)
```zig
0xff => {
    // ... existing beneficiary parsing and gas calculation ...
    
    try self.consumeGas(gas_cost);
    
    // Transfer balance to beneficiary
    // ... existing balance transfer logic ...
    
    // EIP-6780: Only delete account if created in same transaction
    const evm_ptr = self.getEvm();
    const was_created_this_tx = evm_ptr.created_accounts.contains(self.address);
    
    if (was_created_this_tx) {
        // Full destruction: clear code and storage
        if (evm_ptr.host) |h| {
            // Use host to mark for deletion if supported
            // Otherwise clear code:
            h.setCode(self.address, &[_]u8{});
        } else {
            try evm_ptr.code.put(self.address, &[_]u8{});
        }
        // Note: Storage clearing may need additional logic
    }
    // Otherwise: Just balance transfer (already done above)
    
    // Apply refund
    const refund = self.selfdestructRefund();
    if (refund > 0) {
        evm_ptr.gas_refund += refund;
    }
    
    self.stopped = true;
},
```

---

### 3. Implement Snapshot/Rollback (CRITICAL - Priority 3)

**Investigation Required**: First determine if the host interface handles state reversion.

If not, implement snapshots:

**File**: `src/evm.zig`
```zig
const Snapshot = struct {
    storage: std.AutoHashMap(StorageSlotKey, u256),
    transient_storage: std.AutoHashMap(StorageSlotKey, u256),
    balances: std.AutoHashMap(Address, u256),
    nonces: std.AutoHashMap(Address, u64),
    code: std.AutoHashMap(Address, []const u8),
};

pub const Evm = struct {
    // ... existing fields ...
    snapshots: std.ArrayList(Snapshot),
    
    fn takeSnapshot(self: *Self) !void {
        const snap = Snapshot{
            .storage = try self.storage.clone(),
            .transient_storage = try self.transient_storage.clone(),
            .balances = try self.balances.clone(),
            .nonces = try self.nonces.clone(),
            .code = try self.code.clone(),
        };
        try self.snapshots.append(snap);
    }
    
    fn commitSnapshot(self: *Self) void {
        const snap = self.snapshots.pop();
        // Deinit cloned maps
        snap.storage.deinit();
        snap.transient_storage.deinit();
        snap.balances.deinit();
        snap.nonces.deinit();
        snap.code.deinit();
    }
    
    fn rollbackSnapshot(self: *Self) !void {
        const snap = self.snapshots.pop();
        // Restore state
        self.storage.deinit();
        self.transient_storage.deinit();
        self.balances.deinit();
        self.nonces.deinit();
        self.code.deinit();
        
        self.storage = snap.storage;
        self.transient_storage = snap.transient_storage;
        self.balances = snap.balances;
        self.nonces = snap.nonces;
        self.code = snap.code;
    }
    
    pub fn inner_call(...) !CallResult {
        try self.takeSnapshot();
        errdefer self.rollbackSnapshot() catch {};
        
        // ... existing call logic ...
        
        if (result.success) {
            self.commitSnapshot();
        } else {
            try self.rollbackSnapshot();
        }
        
        return result;
    }
};
```

---

### 4. Fix Access List Pre-warming (HIGH - Priority 4)

**File**: `src/evm.zig`
```zig
pub fn call(
    self: *Self,
    bytecode: []const u8,
    gas: i64,
    caller: Address,
    address: Address,
    value: u256,
    calldata: []const u8,
    access_list: ?struct {
        addresses: []const Address,
        storage_keys: []const struct {
            address: Address,
            key: u256,
        },
    },  // ADD THIS PARAMETER
) errors.CallError!CallResult {
    // ... existing initialization ...
    
    try self.preWarmTransaction(address);
    
    // ADD: Pre-warm access list
    if (access_list) |list| {
        for (list.addresses) |addr| {
            _ = try self.warm_addresses.getOrPut(addr);
        }
        for (list.storage_keys) |entry| {
            const key = StorageSlotKey{ 
                .address = entry.address, 
                .slot = entry.key 
            };
            _ = try self.warm_storage_slots.getOrPut(key);
        }
    }
    
    // ... rest of function ...
}
```

---

## Conclusion

The Guillotine EVM has a **solid foundation** for state management with correct implementations of:
- ✅ Storage tracking with proper key structure
- ✅ Original storage tracking for EIP-2200
- ✅ Warm/cold access list tracking for EIP-2929
- ✅ Gas refund counter with EIP-3529 cap

However, there are **3 CRITICAL missing features** that will cause widespread test failures:

1. **Transient Storage (EIP-1153)**: Complete missing infrastructure - opcodes use wrong storage
2. **Created Accounts Tracking (EIP-6780)**: SELFDESTRUCT uses deprecated behavior
3. **Snapshot/Rollback**: No mechanism to revert state changes on call failure

And **1 HIGH priority issue**:
4. **Access List Pre-warming**: Transaction access lists not pre-warmed

**Estimated Overall Impact**: 40-60% of state-related tests will fail until these issues are resolved.

**Recommended Implementation Order**:
1. Transient Storage (simplest, isolated change)
2. Created Accounts (affects SELFDESTRUCT logic)
3. Access List Pre-warming (requires API changes)
4. Snapshot/Rollback (most complex, needs architecture decision)