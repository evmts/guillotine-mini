# Agent 2: State Management Auditor & Implementer

## Objective
Audit the EVM's state management system against the Python spec, focusing on storage tracking, access lists (EIP-2929), transient storage (EIP-1153), and snapshot/rollback mechanisms.

## Scope
- `src/evm.zig` - State tracking fields
- `src/primitives/state.zig`
- Reference: `execution-specs/src/ethereum/forks/prague/state.py`

## Critical Systems to Audit

### 1. Storage Management
**Reference**: `execution-specs/.../state.py:State._storage_tries`

**Check in `evm.zig`**:
```zig
storage: std.AutoHashMap(StorageSlotKey, u256)
original_storage: std.AutoHashMap(StorageSlotKey, u256)
```

**Questions to Answer**:
1. Is `original_storage` populated correctly?
   - **When**: On FIRST access to a slot in the transaction (either SLOAD or SSTORE)
   - **Not**: On every SSTORE
2. Is `StorageSlotKey` correctly structured?
   - Should be: `(Address, u256)` tuple
3. Are values persisted across call frames?

**Spec Behavior** (from Python):
```python
def get_storage(state: State, address: Address, key: Bytes32) -> U256:
    # Returns value from storage trie

def set_storage(state: State, address: Address, key: Bytes32, value: U256):
    # Sets value in storage trie

# For gas calculation (EIP-2200):
original_value = get_storage_original(state, address, key)  # Unchanged since tx start
current_value = get_storage(state, address, key)           # Current value
new_value = value                                          # Value being set
```

**Action**:
- Read `evm.zig` storage-related code
- Verify original_storage is tracked correctly
- Check when original values are captured

---

### 2. Access Lists - EIP-2929
**Reference**: `execution-specs/.../vm/gas.py`, opcode implementations

**Check in `evm.zig`**:
```zig
warm_addresses: std.array_hash_map.ArrayHashMap(Address, void, AddressContext, false)
warm_storage_slots: std.array_hash_map.ArrayHashMap(StorageSlotKey, void, StorageSlotKeyContext, false)
```

**Critical Checks**:

**2.1 Pre-warming from Transaction Access List**
```python
# Spec: execution-specs/.../fork.py
# Before executing transaction:
for address in tx.access_list.addresses:
    evm.accessed_addresses.add(address)
for (address, key) in tx.access_list.storage_keys:
    evm.accessed_storage_keys.add((address, key))
```

**Question**: Is this done in Guillotine's transaction processing?

**2.2 Pre-warmed Addresses**
```python
# From spec - these are ALWAYS warm:
evm.accessed_addresses.add(tx.origin)           # Transaction sender
evm.accessed_addresses.add(tx.to)               # Transaction recipient
evm.accessed_addresses.add(block.coinbase)      # Block beneficiary
```

**Question**: Are these three addresses added to warm set before execution?

**2.3 Runtime Warming**
- SLOAD: After charging cold cost, mark slot warm
- SSTORE: After charging cold cost, mark slot warm
- BALANCE/EXT*: After charging cold cost, mark address warm
- CALL family: After charging cold cost, mark target address warm

**Question**: Is warming done AFTER gas charge, not before?

**Action**:
- Search for where warm sets are populated
- Verify pre-warming logic
- Check timing of warming (after gas charge)

---

### 3. Transient Storage - EIP-1153 (CRITICAL)
**Reference**: `execution-specs/.../state.py:TransientStorage`

**Spec Structure**:
```python
@dataclass
class TransientStorage:
    _tries: Dict[Address, Trie[Bytes32, U256]] = field(default_factory=dict)
    _snapshots: List[Dict[...]] = field(default_factory=list)
```

**Behavior**:
- Storage that persists within a transaction
- Cleared at end of transaction (before next transaction)
- Supports snapshots for call frame reverts
- No gas refunds
- TLOAD (0x5c): 100 gas
- TSTORE (0x5d): 100 gas

**Questions**:
1. **Does `evm.zig` have a `transient_storage` field?**
2. If yes, is it cleared after transaction completion?
3. If no, this is a CRITICAL missing feature

**Action**:
- Search `evm.zig` for "transient"
- Check if TLOAD/TSTORE opcodes can access it
- Verify it's cleared after transaction

---

### 4. Snapshot/Rollback Mechanism
**Reference**: `execution-specs/.../state.py`

**Spec Functions**:
```python
def begin_transaction(state: State, transient_storage: TransientStorage):
    # Save snapshot of state and transient storage
    state._snapshots.append((
        copy_trie(state._main_trie),
        {k: copy_trie(t) for (k, t) in state._storage_tries.items()}
    ))
    transient_storage._snapshots.append(...)

def commit_transaction(state: State, transient_storage: TransientStorage):
    # Discard snapshot (keep changes)
    state._snapshots.pop()
    transient_storage._snapshots.pop()

def rollback_transaction(state: State, transient_storage: TransientStorage):
    # Restore from snapshot (discard changes)
    (main_trie, storage_tries) = state._snapshots.pop()
    state._main_trie = main_trie
    state._storage_tries = storage_tries
    # ... restore transient storage
```

**When Called**:
- `begin_transaction()`: Before executing message call
- `commit_transaction()`: After successful execution
- `rollback_transaction()`: After revert or error

**Questions**:
1. Does Guillotine implement snapshots?
2. Are snapshots taken before every call frame (including nested CALLs)?
3. Is transient storage included in snapshots?

**Action**:
- Search for snapshot/rollback logic in `evm.zig`
- Check if it's called appropriately in CALL opcodes
- Verify transient storage is snapshotted

---

### 5. Created Accounts Tracking - EIP-6780
**Reference**: `execution-specs/.../state.py:State.created_accounts`

**Spec**:
```python
@dataclass
class State:
    created_accounts: Set[Address] = field(default_factory=set)

# In CREATE/CREATE2 execution:
def process_create_message(message: Message) -> Evm:
    # ...
    mark_account_created(state, message.current_target)
    # ...

# In SELFDESTRUCT:
def selfdestruct(evm: Evm) -> None:
    if evm.message.current_target in evm.message.state.created_accounts:
        # Full destruction (EIP-6780: same-transaction creation)
        evm.accounts_to_delete.add(address)
    else:
        # Just send balance, don't delete
        pass
```

**Critical**: This set tracks which accounts were created in the CURRENT transaction, used by SELFDESTRUCT to determine deletion behavior.

**Questions**:
1. Does `evm.zig` have a `created_accounts` set?
2. Is it populated during CREATE/CREATE2?
3. Is it used by SELFDESTRUCT?
4. Is it cleared at transaction boundaries?

**Action**:
- Search for "created_accounts" or similar tracking
- Check CREATE/CREATE2 implementations
- Check SELFDESTRUCT implementation

---

### 6. Account State Maps
**Check in `evm.zig`**:
```zig
balances: std.AutoHashMap(Address, u256)
nonces: std.AutoHashMap(Address, u64)
code: std.AutoHashMap(Address, []const u8)
```

**Questions**:
1. Are these updated correctly?
2. Do they interact with the host interface appropriately?
3. Are they snapshotted for reverts?

---

### 7. Gas Refund Counter
**Reference**: `execution-specs/.../vm/__init__.py:Evm.refund_counter`

**Check in `evm.zig`**:
```zig
gas_refund: u64
```

**Questions**:
1. Is refund accumulated during SSTORE clear operations?
2. Is it applied correctly at transaction end?
3. Is the EIP-3529 cap enforced? `min(refund, gas_used / 5)`

**Action**: Verify refund counter usage

---

## Output Format

```markdown
# State Management Audit Report

## Executive Summary
- ✅ Implemented: X features
- ⚠️ Issues: Y features
- ❌ Missing: Z features

## Critical Findings

### ✅ Storage HashMap Structure - CORRECT
- `storage` and `original_storage` HashMaps exist
- StorageSlotKey structure correct (address, slot)

### ⚠️ Original Storage Tracking - POTENTIAL ISSUE
**Issue**: original_storage population timing unclear
- **Location**: Need to check SLOAD/SSTORE implementation
- **Expected**: Populated on FIRST access to slot
- **Impact**: EIP-2200 gas calculations may be wrong
- **Verification Needed**: Check SLOAD/SSTORE opcodes

### ❌ Transient Storage - MISSING (CRITICAL)
**Missing Feature**: EIP-1153 transient storage
- **Current State**: No `transient_storage` HashMap found in `evm.zig`
- **Required**:
  ```zig
  transient_storage: std.AutoHashMap(StorageSlotKey, u256)
  ```
- **Impact**: TLOAD/TSTORE opcodes cannot function
- **Spec Reference**: `execution-specs/.../state.py:TransientStorage`
- **Action Items**:
  1. Add transient_storage HashMap to Evm struct
  2. Clear it after each transaction completes
  3. Include in snapshot/rollback mechanism
  4. Implement TLOAD (0x5c) and TSTORE (0x5d) opcodes
- **Priority**: CRITICAL

### ❌ Created Accounts Tracking - MISSING (CRITICAL)
**Missing Feature**: EIP-6780 created accounts tracking
- **Current State**: No `created_accounts` Set found
- **Required**:
  ```zig
  created_accounts: std.AutoHashMap(Address, void)
  ```
- **Impact**: SELFDESTRUCT will use old behavior (always delete)
- **Spec Reference**: `execution-specs/.../state.py:State.created_accounts`
- **Action Items**:
  1. Add created_accounts Set to Evm struct
  2. Populate in CREATE/CREATE2 execution
  3. Check in SELFDESTRUCT to determine deletion
  4. Clear at transaction boundaries
- **Priority**: CRITICAL

### ⚠️ Access List Pre-warming - NEEDS VERIFICATION
**Issue**: Unclear if transaction access lists pre-warm the sets
- **Expected Behavior**:
  - Before transaction execution, add all access list addresses to warm_addresses
  - Add all access list storage keys to warm_storage_slots
  - Pre-warm: origin, target, coinbase addresses
- **Location to Check**: Transaction processing entry point
- **Impact**: First access incorrectly charged cold cost
- **Priority**: HIGH

### ⚠️ Snapshot/Rollback - NEEDS VERIFICATION
**Issue**: Need to verify snapshot mechanism
- **Questions**:
  1. Are snapshots taken before EVERY call frame?
  2. Is transient storage included in snapshots?
  3. Is rollback called on revert/error?
- **Location to Check**: CALL opcode implementations
- **Priority**: HIGH

## Detailed Recommendations

### 1. Add Transient Storage (CRITICAL)
```zig
// In evm.zig Evm struct:
transient_storage: std.AutoHashMap(StorageSlotKey, u256)

// In transaction processing:
pub fn executeTransaction(...) {
    // ... execute ...

    // After transaction completes (success or failure):
    self.transient_storage.clearRetainingCapacity();
}
```

### 2. Add Created Accounts Tracking (CRITICAL)
```zig
// In evm.zig Evm struct:
created_accounts: std.AutoHashMap(Address, void)

// In CREATE/CREATE2 implementation:
try self.evm_ptr.created_accounts.put(new_address, {});

// In SELFDESTRUCT:
const was_created = self.getEvm().created_accounts.contains(address);
if (was_created) {
    // Full destruction
    try self.getEvm().accounts_to_delete.put(address, {});
} else {
    // Just send balance
}
```

### 3. Verify Access List Pre-warming
Check transaction entry point for:
```zig
// Before execution:
for (tx.access_list.addresses) |addr| {
    try evm.warm_addresses.put(addr, {});
}
for (tx.access_list.storage_keys) |key| {
    try evm.warm_storage_slots.put(key, {});
}
// Pre-warm mandatory addresses:
try evm.warm_addresses.put(tx.origin, {});
try evm.warm_addresses.put(tx.to, {});
try evm.warm_addresses.put(block_context.block_coinbase, {});
```

## Summary Table

| Feature | Status | Priority | Lines Affected |
|---------|--------|----------|----------------|
| Storage tracking | ✅ | - | - |
| Original storage | ⚠️ | HIGH | SLOAD/SSTORE opcodes |
| Warm/cold tracking | ✅ | - | - |
| Access list pre-warm | ⚠️ | HIGH | Transaction entry |
| Transient storage | ❌ | CRITICAL | evm.zig + TLOAD/TSTORE |
| Created accounts | ❌ | CRITICAL | evm.zig + CREATE/SELFDESTRUCT |
| Snapshot/rollback | ⚠️ | HIGH | CALL opcodes |
| Gas refund | ✅ | - | - |

## Estimated Impact
- **Transient storage missing**: All TLOAD/TSTORE tests fail (100% failure)
- **Created accounts missing**: All SELFDESTRUCT tests fail (~150 tests)
- **Access list**: ~30% of tests may have gas discrepancies
- **Total**: ~40-50% of tests likely affected by state management issues
