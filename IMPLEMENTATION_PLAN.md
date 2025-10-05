# Guillotine EVM - Implementation Roadmap

Based on the exhaustive 18-agent audit findings.

---

## 📋 Executive Summary

**Yes, the audit did exactly what we expected!** It generated comprehensive reports identifying:
- 4 CRITICAL issues blocking consensus
- 2 HIGH priority gas/performance issues
- 1 MEDIUM transaction type gap
- Specific file:line references for every issue
- Estimated fix times and test impact

**The agents did NOT implement changes** - they only audited and reported. This is correct behavior.

**Now we implement the fixes based on their findings.**

---

## 🎯 Phase 1: Quick Wins (Day 1)

**Goal**: Fix gas constants and pre-warming
**Time**: 4-6 hours
**Expected**: +75-150 tests passing

### Fix 1: Add Missing Gas Constants (30 minutes)

**File**: `src/primitives/gas_constants.zig`

```zig
// Add these constants at the end:

// ============================================================================
// EIP-4844: Blob Transactions
// ============================================================================
pub const GAS_PER_BLOB: u64 = 131072; // 2^17
pub const TARGET_BLOB_GAS_PER_BLOCK: u64 = 786432; // 3 * 2^18
pub const MIN_BLOB_GASPRICE: u64 = 1;
pub const BLOB_BASE_FEE_UPDATE_FRACTION: u64 = 5007716;
pub const GAS_BLOBHASH_OPCODE: u64 = 3;
pub const GAS_POINT_EVALUATION: u64 = 50000;

// ============================================================================
// EIP-2537: BLS12-381 Precompiles
// ============================================================================
pub const GAS_BLS_G1_ADD: u64 = 375;
pub const GAS_BLS_G1_MUL: u64 = 12000;
pub const GAS_BLS_G1_MAP: u64 = 5500;
pub const GAS_BLS_G2_ADD: u64 = 600;
pub const GAS_BLS_G2_MUL: u64 = 22500;
pub const GAS_BLS_G2_MAP: u64 = 23800;
pub const GAS_BLS_PAIRING_BASE: u64 = 43000;
pub const GAS_BLS_PAIRING_PER_PAIR: u64 = 65000;
```

**Validation**: Run `zig build` to ensure it compiles.

---

### Fix 2: Correct Blob Constant (1 minute)

**File**: `src/primitives/blob.zig:14`

```zig
// CHANGE THIS LINE:
pub const BLOB_BASE_FEE_UPDATE_FRACTION = 3338477;

// TO:
pub const BLOB_BASE_FEE_UPDATE_FRACTION = 5007716;
```

---

### Fix 3: Add Access List Pre-warming (2-3 hours)

**File**: `src/evm.zig`

**Step 1**: Add access list parameter to `call()` function (around line 196-330)

```zig
pub fn call(
    self: *Self,
    bytecode: []const u8,
    gas: i64,
    caller: Address,
    address: Address,
    value: u256,
    calldata: []const u8,
    // ADD THIS PARAMETER:
    access_list: ?struct {
        addresses: []const Address,
        storage_keys: []const struct {
            address: Address,
            slot: u256,
        },
    },
) errors.CallError!CallResult {
    // ... existing code ...

    try self.preWarmTransaction(address);

    // ADD THIS BLOCK after preWarmTransaction:
    if (access_list) |list| {
        // Pre-warm all addresses in access list
        for (list.addresses) |addr| {
            _ = try self.warm_addresses.getOrPut(addr);
        }

        // Pre-warm all storage keys in access list
        for (list.storage_keys) |entry| {
            const key = StorageSlotKey{
                .address = entry.address,
                .slot = entry.slot
            };
            _ = try self.warm_storage_slots.getOrPut(key);
        }
    }

    // ... rest of existing code ...
}
```

**Step 2**: Update all callers to pass `null` for now (will be populated later when transaction processing is updated)

**Validation**: `zig build` and verify all call sites compile

---

## 🔴 Phase 2: Critical State Features (Week 1)

**Goal**: Implement transient storage and created accounts
**Time**: 1-2 days
**Expected**: +350-500 tests passing

### Fix 4: Implement Transient Storage (4-6 hours)

**File**: `src/evm.zig`

**Step 1**: Add transient storage to Evm struct (around line 70)

```zig
pub const Evm = struct {
    // ... existing fields ...
    storage: std.AutoHashMap(StorageSlotKey, u256),
    original_storage: std.AutoHashMap(StorageSlotKey, u256),

    // ADD THIS:
    transient_storage: std.AutoHashMap(StorageSlotKey, u256),

    // ... rest of fields ...
```

**Step 2**: Initialize in `call()` function (around line 220)

```zig
pub fn call(...) !CallResult {
    // ... existing initialization ...

    self.storage = std.AutoHashMap(StorageSlotKey, u256).init(arena_allocator);
    self.original_storage = std.AutoHashMap(StorageSlotKey, u256).init(arena_allocator);

    // ADD THIS:
    self.transient_storage = std.AutoHashMap(StorageSlotKey, u256).init(arena_allocator);

    // ... rest of function ...

    // Transient storage will be automatically cleared when arena resets
}
```

**Step 3**: Add helper methods to Evm

```zig
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

**Step 4**: Update TLOAD/TSTORE in `src/frame.zig` (lines 1152-1177)

```zig
// TLOAD (0x5C)
0x5c => {
    if (evm.hardfork.isBefore(.CANCUN)) return error.InvalidOpcode;
    try self.consumeGas(GasConstants.WarmStorageReadCost);
    const key = try self.popStack();

    // CHANGE THIS:
    // const value = evm.get_storage(self.address, key);

    // TO THIS:
    const value = evm.get_transient_storage(self.address, key);

    try self.pushStack(value);
    self.pc += 1;
},

// TSTORE (0x5D)
0x5d => {
    if (evm.hardfork.isBefore(.CANCUN)) return error.InvalidOpcode;
    try self.consumeGas(GasConstants.WarmStorageReadCost);
    const key = try self.popStack();
    const value = try self.popStack();

    // CHANGE THIS:
    // try evm.set_storage(self.address, key, value);

    // TO THIS:
    try evm.set_transient_storage(self.address, key, value);

    self.pc += 1;
},
```

**Validation**:
- `zig build` compiles
- TLOAD returns 0 for unset keys
- TSTORE sets values that TLOAD can read back
- Values cleared after transaction (arena reset)

---

### Fix 5: Implement Created Accounts Tracking (5-7 hours)

**File**: `src/evm.zig`

**Step 1**: Add created_accounts to Evm struct

```zig
pub const Evm = struct {
    // ... existing fields ...
    transient_storage: std.AutoHashMap(StorageSlotKey, u256),

    // ADD THIS:
    created_accounts: std.AutoHashMap(Address, void),

    // ... rest of fields ...
```

**Step 2**: Initialize in `call()`

```zig
pub fn call(...) !CallResult {
    // ... existing initialization ...
    self.transient_storage = std.AutoHashMap(StorageSlotKey, u256).init(arena_allocator);

    // ADD THIS:
    self.created_accounts = std.AutoHashMap(Address, void).init(arena_allocator);

    // ... rest ...
}
```

**Step 3**: Mark accounts in `inner_create()` (around line 687)

```zig
pub fn inner_create(...) !struct { ... } {
    // ... existing CREATE logic ...

    // After successful deployment (when code is set):
    if (success and frame.output.len > 0) {
        // ... existing code size check ...

        // Deploy code
        const code_copy = try self.arena.allocator().alloc(u8, frame.output.len);
        @memcpy(code_copy, frame.output);
        try self.code.put(new_address, code_copy);

        // ADD THIS:
        try self.created_accounts.put(new_address, {});
    }

    // ... rest of function ...
}
```

**Step 4**: Update SELFDESTRUCT in `src/frame.zig` (around line 2081)

```zig
// SELFDESTRUCT (0xFF)
0xff => {
    const beneficiary_u256 = try self.popStack();
    // ... existing gas calculation ...

    try self.consumeGas(gas_cost);

    const self_balance = evm_ptr.balances.get(self.address) orelse 0;

    // Transfer balance (always happens)
    if (self_balance > 0) {
        // ... existing balance transfer logic ...
    }

    // EIP-6780: Only delete account if created in same transaction
    const was_created_this_tx = evm_ptr.created_accounts.contains(self.address);

    if (was_created_this_tx) {
        // Full destruction: clear code
        if (evm_ptr.host) |h| {
            h.setCode(self.address, &[_]u8{});
        } else {
            try evm_ptr.code.put(self.address, &[_]u8{});
        }
        // Note: May need to mark for storage deletion as well
    }
    // Otherwise: Balance transferred above, code persists

    // Apply refund
    const refund = self.selfdestructRefund();
    if (refund > 0) {
        evm_ptr.gas_refund += refund;
    }

    self.stopped = true;
},
```

**Validation**:
- Account created in tx + SELFDESTRUCT = code deleted
- Existing account + SELFDESTRUCT = balance sent, code persists
- Test with simple contract deployment + immediate SELFDESTRUCT

---

## 🔴 Phase 3: State Snapshots (Week 1-2)

**Goal**: Implement snapshot/rollback for nested calls
**Time**: 1-2 days
**Expected**: +500-800 tests passing

### Fix 6: Implement State Snapshots (1-2 days)

This is more complex and requires architectural decisions. Options:

**Option A**: Implement full snapshots
**Option B**: Use copy-on-write for HashMaps
**Option C**: Rely on host interface for state (if available)

**Recommended**: Start with Option A (explicit snapshots)

**File**: `src/evm.zig`

```zig
const Snapshot = struct {
    storage: std.AutoHashMap(StorageSlotKey, u256),
    transient_storage: std.AutoHashMap(StorageSlotKey, u256),
    balances: std.AutoHashMap(Address, u256),
    nonces: std.AutoHashMap(Address, u64),
    code: std.AutoHashMap(Address, []const u8),
    created_accounts: std.AutoHashMap(Address, void),
};

pub const Evm = struct {
    // ... existing fields ...

    snapshots: std.ArrayList(Snapshot),

    // ... methods ...

    fn takeSnapshot(self: *Self) !void {
        const snap = Snapshot{
            .storage = try self.storage.clone(),
            .transient_storage = try self.transient_storage.clone(),
            .balances = try self.balances.clone(),
            .nonces = try self.nonces.clone(),
            .code = try self.code.clone(),
            .created_accounts = try self.created_accounts.clone(),
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
        snap.created_accounts.deinit();
    }

    fn rollbackSnapshot(self: *Self) !void {
        const snap = self.snapshots.pop();

        // Free current state
        self.storage.deinit();
        self.transient_storage.deinit();
        self.balances.deinit();
        self.nonces.deinit();
        self.code.deinit();
        self.created_accounts.deinit();

        // Restore snapshot
        self.storage = snap.storage;
        self.transient_storage = snap.transient_storage;
        self.balances = snap.balances;
        self.nonces = snap.nonces;
        self.code = snap.code;
        self.created_accounts = snap.created_accounts;
    }
};
```

**Update `inner_call()` to use snapshots**:

```zig
pub fn inner_call(...) !CallResult {
    try self.takeSnapshot();
    errdefer self.rollbackSnapshot() catch {};

    // ... existing call logic ...

    if (frame.reverted) {
        try self.rollbackSnapshot();
    } else {
        self.commitSnapshot();
    }

    return result;
}
```

**Validation**: Test with nested CALLs that revert

---

## ⚠️ Phase 4: Precompiles (Weeks 2-3)

**Goal**: Implement all 17 missing precompiles
**Time**: 1-2 weeks
**Expected**: +300-500 tests passing

### Strategy

1. **Use `guillotine-reference/`** as implementation guide
2. Check `guillotine-reference/Cargo.toml` for crypto dependencies
3. Either:
   - Port Rust crypto to Zig
   - Use FFI to call Rust libraries
   - Use existing Zig crypto libraries

### Priority Order

**Week 2** (Essential cryptography):
1. ECRECOVER (0x01) - Essential for signature recovery
2. SHA256 (0x02) - Common hash function
3. RIPEMD160 (0x03) - Bitcoin compatibility
4. MODEXP (0x05) - RSA operations

**Week 3** (Advanced operations):
5. BN254 curve ops (0x06-0x08) - zkSNARK support
6. BLAKE2F (0x09) - Modern hashing
7. Point Evaluation (0x0A) - EIP-4844 KZG proofs
8. BLS12-381 ops (0x0B-0x11) - Ethereum 2.0 crypto

**File**: `src/evm.zig:418-424` (replace TODO)

---

## 🟡 Phase 5: Polish (Week 4)

**Goal**: Fix remaining medium/low priority issues
**Time**: 2-3 days

1. Implement EIP-2930 AccessListTransaction type
2. Rename `v` to `y_parity` in authorization.zig
3. Full audit of address.zig CREATE calculations
4. Full audit of rlp.zig edge cases
5. Integration testing

---

## ✅ Validation Process

After each phase:

1. **Compile**: `zig build` should succeed
2. **Unit tests**: `zig build test` (if available)
3. **Integration tests**: Run official Ethereum tests
4. **Regression check**: Ensure previous fixes still work

---

## 📊 Progress Tracking

Create issues for each fix:
- [ ] Fix 1: Add gas constants
- [ ] Fix 2: Correct blob constant
- [ ] Fix 3: Access list pre-warming
- [ ] Fix 4: Transient storage
- [ ] Fix 5: Created accounts tracking
- [ ] Fix 6: State snapshots
- [ ] Fix 7-23: Precompiles (17 total)
- [ ] Fix 24: Transaction type 1
- [ ] Fix 25+: Polish items

---

## 💡 Next Immediate Steps

**TODAY**:
1. ✅ Review this implementation plan
2. ⏭️ Read detailed reports in `reports/` directory
3. ⏭️ Start with Fix 1 (gas constants) - 30 minutes
4. ⏭️ Commit and test after each fix

**THIS WEEK**:
5. Complete Phase 1 (quick wins)
6. Start Phase 2 (transient storage)
7. Test improvements with official test suite

**NEXT 2-3 WEEKS**:
8. Complete Phase 2-3 (state features)
9. Begin precompile implementation
10. Iterate based on test results

---

## 📝 Summary

**What the audit did**: ✅
- Generated 18 comprehensive reports
- Identified all CRITICAL/HIGH/MEDIUM/LOW issues
- Provided specific file:line references
- Estimated fix times and test impact
- Cross-referenced Python execution-specs

**What the audit did NOT do**: (Correct!)
- Did not implement any changes
- Did not modify source code
- Did not run tests

**Next step**: Implement fixes using this roadmap

**Estimated timeline to 100% compliance**: 3-4 weeks
