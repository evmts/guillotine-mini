# Phase 2: World State (Journal + Snapshot/Restore) — Context

## Goal

Implement journaled world state with snapshot/restore for transaction processing. This sits between the trie layer (Phase 1) and EVM state integration (Phase 3), providing the account/storage state management that the EVM host adapter will consume.

**Key deliverables:**
- `client/state/account.zig` — Account state structure
- `client/state/journal.zig` — Journal for tracking state changes
- `client/state/state.zig` — World state manager with snapshot/restore

---

## Existing Infrastructure (Already Implemented)

### Phase 0: DB Abstraction (complete)
- `client/db/adapter.zig` — Generic database interface
- `client/db/memory.zig` — In-memory backend
- `client/db/rocksdb.zig` — RocksDB backend
- `client/db/null.zig` — Null/no-op backend
- `client/db/root.zig` — Module root

### Phase 1: Trie (complete)
- `client/trie/hash.zig` — Trie hashing (RLP + keccak256)
- `client/trie/root.zig` — Module root

### EVM Host Interface (`src/host.zig`)
The existing EVM uses a minimal `HostInterface` vtable for external state:
```zig
pub const HostInterface = struct {
    ptr: *anyopaque,
    vtable: *const VTable,
    pub const VTable = struct {
        getBalance, setBalance,
        getCode, setCode,
        getStorage, setStorage,
        getNonce, setNonce,
    };
};
```
**Note:** NOT used for nested calls — EVM.inner_call handles those directly.

### EVM State Management (`src/evm.zig`, `src/storage.zig`)
The EVM currently manages its own state internally:
- `Storage` struct in `src/storage.zig`: persistent storage, original_storage, transient storage hashmaps
- `Evm` struct fields: `balances`, `nonces`, `code`, `created_accounts`, `selfdestructed_accounts`, `touched_accounts`
- `AccessListManager` for EIP-2929 warm/cold tracking
- `balance_snapshot_stack` for nested call revert handling
- Arena allocator for transaction-scoped memory

---

## Voltaire Primitives (USE THESE — never create custom types)

### AccountState (`voltaire/packages/voltaire-zig/src/primitives/AccountState/AccountState.zig`)
```zig
pub const AccountState = struct {
    nonce: u64,
    balance: u256,
    storage_root: StateRoot.StateRoot,  // [32]u8
    code_hash: Hash.Hash,               // [32]u8
    pub fn createEmpty() Self;
    pub fn from(opts) Self;
    pub fn isEOA() bool;
    pub fn isContract() bool;
    pub fn equals(*const Self, *const Self) bool;
    pub fn rlpEncode(allocator) ![]u8;
    pub fn rlpDecode(allocator, data) !Self;
};
```
Constants: `EMPTY_CODE_HASH`, `EMPTY_TRIE_ROOT`

### State-Manager Module (`voltaire/packages/voltaire-zig/src/state-manager/`)
Complete journaled state already exists in Voltaire:

| File | Type | Purpose |
|------|------|---------|
| `StateCache.zig` | `AccountCache`, `StorageCache`, `ContractCache` | Per-type caches with checkpoint/revert/commit |
| `JournaledState.zig` | `JournaledState` | Dual-cache orchestrator (normal + fork backend) |
| `StateManager.zig` | `StateManager` | High-level API with snapshot support |
| `ForkBackend.zig` | `ForkBackend` | Remote state fetcher (for forking) |
| `root.zig` | Re-exports | Module root |

**StateCache checkpoint strategy:**
- `checkpoint()` — Shallow clone of maps pushed to stack
- `revert()` — Pop stack, restore previous state
- `commit()` — Pop stack, keep current state (finalize)

**StateManager snapshot vs checkpoint:**
- Checkpoint: Low-level journaling (push/pop state stack)
- Snapshot: High-level testing feature (returns ID for later revert)

**Key difference from what we need:** The Voltaire StateManager is designed for a dev-node/test environment. The full client WorldState needs:
1. Integration with the trie layer for state root computation
2. Proper original-storage tracking for SSTORE gas (EIP-2200)
3. Warm/cold access tracking (EIP-2929)
4. Created/selfdestructed/touched account tracking
5. Transient storage management (EIP-1153)

### Other Relevant Voltaire Primitives
- `Address` — `primitives.Address` (20-byte)
- `Hash` — `primitives.Hash` (32-byte)
- `StateRoot` — `primitives.StateRoot` (32-byte)
- `Hardfork` — `primitives.Hardfork` enum
- `StorageKey` — `primitives.State.StorageKey` (address + slot key)
- `GasConstants` — Gas cost values
- `Rlp` — RLP encoding/decoding
- `Hex` — Hex encoding/decoding

---

## Nethermind Architecture Reference

### Key Files
| File | Role |
|------|------|
| `Nethermind.State/WorldState.cs` | Top-level coordinator: delegates to StateProvider, PersistentStorageProvider, TransientStorageProvider |
| `Nethermind.State/StateProvider.cs` | Account state with change tracking, intra-tx cache, snapshot/restore via change list |
| `Nethermind.State/PersistentStorageProvider.cs` | Storage with original values (EIP-1283), snapshot/restore, trie persistence |
| `Nethermind.State/TransientStorageProvider.cs` | EIP-1153 transient storage (extends PartialStorageProviderBase, returns zero for uncached) |
| `Nethermind.State/PartialStorageProviderBase.cs` | Common base for persistent+transient: intra-block cache, change list, snapshot/restore |
| `Nethermind.State/StateTree.cs` | State trie (accounts) |
| `Nethermind.State/StorageTree.cs` | Storage trie (per-account) |
| `Nethermind.State/IWorldStateManager.cs` | Interface for world state management |
| `Nethermind.State/IStateReader.cs` | Read-only state access interface |

### Nethermind Snapshot Architecture
Nethermind uses a **change-list** approach (not snapshot-copy):
1. `TakeSnapshot()` returns position index in change list
2. `Restore(snapshot)` undoes changes back to that position
3. `Commit()` flushes changes to trie
4. Separate snapshots for state + persistent storage + transient storage

`WorldState.TakeSnapshot()` returns composite `Snapshot`:
```csharp
public Snapshot TakeSnapshot(bool newTransactionStart = false) {
    int persistentSnapshot = _persistentStorageProvider.TakeSnapshot(newTransactionStart);
    int transientSnapshot = _transientStorageProvider.TakeSnapshot(newTransactionStart);
    int stateSnapshot = _stateProvider.TakeSnapshot();
    return new Snapshot(storageSnapshot, stateSnapshot);
}
```

### Key Design Patterns from Nethermind
1. **Scope-based lifecycle** — `BeginScope(baseBlock)` / `Dispose()`
2. **Separate providers** — State, PersistentStorage, TransientStorage are independent
3. **Original values tracking** — `_originalValues` dictionary for SSTORE gas calculation
4. **Change tracking** — `List<Change>` with index-based snapshots
5. **WarmUp** — `WarmUp(accessList)` pre-warms addresses and storage slots
6. **Commit rounds** — `CommitTree(blockNumber)` for block finalization

---

## Execution Specs Reference (Authoritative Source)

### State Model (`execution-specs/src/ethereum/forks/*/state.py`)

**Frontier (base):**
- `State` with `_main_trie` (accounts) and `_storage_tries` (per-account)
- `_snapshots` for transaction rollback
- Functions: `get_account()`, `set_account()`, `destroy_account()`, `get_storage()`, `set_storage()`
- Transaction: `begin_transaction()`, `commit_transaction()`, `rollback_transaction()`

**Berlin (EIP-2929):**
- Added `created_accounts: Set[Address]`
- Added `get_storage_original()` for pre-transaction storage
- Added `account_exists_and_is_empty()` and `destroy_touched_empty_accounts()`

**Cancun (EIP-1153):**
- Added `TransientStorage` dataclass with its own snapshot list
- `begin_transaction(state, transient_storage)` snapshots both
- `get_transient_storage()`, `set_transient_storage()`

**Prague:**
- Identical state structure to Cancun

### VM Context (`execution-specs/src/ethereum/forks/*/vm/__init__.py`)

**Berlin+ Evm fields:**
- `accessed_addresses: Set[Address]` — Warm/cold tracking
- `accessed_storage_keys: Set[Tuple[Address, Bytes32]]` — Storage warm/cold
- `touched_accounts: Set[Address]`

**Cancun+ additions:**
- `blob_versioned_hashes`, `excess_blob_gas`, `transient_storage`

---

## Test Fixtures

### For World State validation:
- Unit tests for journal/snapshot behavior (inline `test` blocks)
- Subset of `ethereum-tests/GeneralStateTests/` (state manipulation):
  - `ethereum-tests/GeneralStateTests/stSStoreTest/` — SSTORE gas/refund tests
  - `ethereum-tests/GeneralStateTests/stCallCreateCallCodeTest/` — Nested call state
  - `ethereum-tests/GeneralStateTests/stTransactionTest/` — Transaction-level state
  - `ethereum-tests/GeneralStateTests/stSpecialTest/` — Edge cases
  - `ethereum-tests/GeneralStateTests/stRefundTest/` — Gas refund with storage
  - `ethereum-tests/GeneralStateTests/stPreCompiledContracts/` — Precompile state effects

### Trie tests (Phase 1, for state root validation):
- `ethereum-tests/TrieTests/trietest.json`
- `ethereum-tests/TrieTests/trieanyorder.json`
- `ethereum-tests/TrieTests/hex_encoded_securetrie_test.json`

---

## Implementation Strategy

### Option A: Wrap Voltaire StateManager
Use `voltaire.StateManager` as-is, extending it with:
- Trie integration for state root computation
- Original storage tracking
- EIP-2929 warm/cold management

**Pros:** Less code, reuses tested journal logic
**Cons:** May need significant extension, coupling to Voltaire internals

### Option B: Build Client-Specific WorldState (Recommended)
Build `client/state/` following Nethermind's architecture but using Voltaire primitives:

1. **`account.zig`** — Thin wrapper around `voltaire.AccountState`, adding client-specific helpers (isEmpty, isTotallyEmpty, hasCode)
2. **`journal.zig`** — Change-list journal (Nethermind style) rather than snapshot-copy (Voltaire style) — more memory efficient for large state
3. **`state.zig`** — WorldState coordinator:
   - Account state management (get/set/create/delete)
   - Persistent storage (with original value tracking)
   - Transient storage (EIP-1153)
   - Snapshot/restore (composite: state + persistent + transient)
   - Warm/cold tracking (EIP-2929)
   - Trie integration (state root computation)

### Key Design Decisions
1. **Change-list vs snapshot-copy journaling** — Change-list (Nethermind) is more efficient for large state
2. **Composite snapshots** — Track state, persistent storage, transient storage separately
3. **Original storage** — Must be captured at transaction start for SSTORE gas
4. **Arena allocation** — Transaction-scoped memory, freed at transaction end
5. **HostInterface bridge** — Phase 3 will implement HostInterface using WorldState

---

## File-to-File Reference Map

| Implementation Target | Nethermind Reference | Spec Reference | Voltaire Primitive |
|----------------------|---------------------|----------------|-------------------|
| `client/state/account.zig` | `StateProvider.cs` (GetAccount) | `frontier/state.py` (get_account) | `AccountState.zig` |
| `client/state/journal.zig` | `PartialStorageProviderBase.cs` (change list) | `frontier/state.py` (_snapshots) | `StateCache.zig` (pattern) |
| `client/state/state.zig` | `WorldState.cs` (coordinator) | `cancun/state.py` (full model) | `StateManager.zig` (pattern) |
| Storage tracking | `PersistentStorageProvider.cs` (_originalValues) | `berlin/state.py` (get_storage_original) | `StorageKey` |
| Transient storage | `TransientStorageProvider.cs` | `cancun/state.py` (TransientStorage) | — |
| Warm/cold | (in EVM, not state) | `berlin/vm/__init__.py` (accessed_*) | — |

---

## Summary

Phase 2 bridges the gap between raw trie storage (Phase 1) and EVM execution (Phase 3). The world state must support:

1. **Account CRUD** with journaling (create, read, update, delete + snapshot/restore)
2. **Persistent storage** with original-value tracking for SSTORE gas calculations
3. **Transient storage** (EIP-1153) with its own snapshot lifecycle
4. **Composite snapshots** — state + persistent + transient can be snapshotted/restored independently
5. **State root computation** — Integration with trie layer for Merkle root
6. **Warm/cold tracking** — EIP-2929 access sets (may live in EVM or state layer)

Use Voltaire's `AccountState`, `Address`, `Hash`, `StorageKey`, `Rlp` primitives throughout. Mirror Nethermind's separation of concerns (StateProvider, PersistentStorageProvider, TransientStorageProvider) but implement idiomatically in Zig with comptime patterns.
