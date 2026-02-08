# [Pass 1/5] Phase 2: World State (Journal + Snapshot/Restore) — Context

## Goal

Implement journaled world state with snapshot/restore for transaction processing. This phase sits between the trie layer (Phase 1) and EVM state integration (Phase 3), providing the account/storage state management that the EVM host adapter will consume.

**Key deliverables (from `prd/GUILLOTINE_CLIENT_PLAN.md`):**
- `client/state/account.zig` — Account state structure (NOT YET IMPLEMENTED)
- `client/state/journal.zig` — Journal for tracking state changes (IMPLEMENTED: generic change-list journal)
- `client/state/state.zig` — World state manager with snapshot/restore (NOT YET IMPLEMENTED)

**Already implemented in prior passes:**
- `client/state/journal.zig` — Generic `Journal(K, V)` with `ChangeTag`, snapshot/restore, just_cache preservation
- `client/state/root.zig` — Module root re-exporting journal types
- `client/evm/host_adapter.zig` — `HostAdapter` bridging Voltaire `StateManager` to guillotine-mini `HostInterface`

---

## Existing Infrastructure

### Phase 0: DB Abstraction (complete)
- `client/db/adapter.zig` — Generic database interface
- `client/db/memory.zig` — In-memory backend
- `client/db/rocksdb.zig` — RocksDB backend
- `client/db/null.zig` — Null/no-op backend
- `client/db/read_only.zig` — Read-only wrapper
- `client/db/root.zig` — Module root

### Phase 1: Trie (complete)
- `client/trie/node.zig` — Trie node types
- `client/trie/hash.zig` — Trie hashing (RLP + keccak256)
- `client/trie/root.zig` — Module root

### Phase 3: EVM Host Adapter (partially implemented)
- `client/evm/host_adapter.zig` — Bridges Voltaire `StateManager` to guillotine-mini `HostInterface`
- `client/evm/root.zig` — Module root

### EVM Host Interface (`src/host.zig`)
Minimal vtable for external state access:
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

### EVM Internal State (`src/evm.zig`, `src/storage.zig`)
The EVM currently manages its own state:
- `Storage` struct: persistent storage, original_storage, transient storage (all `AutoHashMap`)
- `Evm` struct fields: `balances`, `nonces`, `code`, `created_accounts`, `selfdestructed_accounts`, `touched_accounts`
- `AccessListManager` for EIP-2929 warm/cold tracking
- `balance_snapshot_stack` for nested call revert
- Arena allocator for transaction-scoped memory

---

## Voltaire Primitives (USE THESE)

### State-Manager Module (`voltaire/packages/voltaire-zig/src/state-manager/`)

| File | Type | Purpose |
|------|------|---------|
| `StateCache.zig` | `AccountCache`, `StorageCache`, `ContractCache`, `AccountState`, `StorageKey` | Per-type caches with checkpoint/revert/commit (snapshot-copy approach) |
| `JournaledState.zig` | `JournaledState` | Dual-cache orchestrator (normal + fork backend), cascading reads |
| `StateManager.zig` | `StateManager` | High-level API: getBalance/setBalance/checkpoint/snapshot/revertToSnapshot |
| `ForkBackend.zig` | `ForkBackend` | Remote state fetcher (for forking) |
| `root.zig` | Re-exports | `AccountCache`, `StorageCache`, `ContractCache`, `AccountState`, `StorageKey`, `JournaledState`, `StateManager`, `ForkBackend` |

**Voltaire AccountState** (`StateCache.zig`):
```zig
pub const AccountState = struct {
    nonce: u64,
    balance: u256,
    code_hash: Hash.Hash,     // [32]u8
    storage_root: Hash.Hash,  // [32]u8
    pub fn init() AccountState; // returns zeroed
};
```

**Voltaire checkpoint strategy (snapshot-copy):**
- `checkpoint()` — Deep clone of maps pushed to stack
- `revert()` — Pop stack, restore previous state
- `commit()` — Pop stack, keep current state

**Voltaire StateManager snapshot system:**
- `snapshot()` — Creates checkpoint, returns ID
- `revertToSnapshot(id)` — Multi-level revert back to snapshot depth
- Separate from low-level checkpoint (testing convenience)

### Other Voltaire Primitives
- `primitives.Address` — 20-byte address
- `primitives.Hash` — 32-byte hash, `Hash.ZERO`
- `primitives.StateRoot` — 32-byte state root
- `primitives.Hardfork` — Hardfork enum
- `primitives.State.StorageKey` — `struct { address: Address, slot: u256 }`
- `primitives.GasConstants` — Gas cost values
- `primitives.Rlp` — RLP encoding/decoding

---

## Nethermind Architecture Reference

### Key Files (in `nethermind/src/Nethermind/Nethermind.State/`)

| File | Size | Role |
|------|------|------|
| `WorldState.cs` | 14KB | Top-level coordinator: delegates to StateProvider + PersistentStorageProvider + TransientStorageProvider |
| `StateProvider.cs` | 40KB | Account state: change tracking, intra-tx cache (`Dict<AddressAsKey, StackList<int>>`), snapshot/restore via change list |
| `PersistentStorageProvider.cs` | 23KB | Persistent storage with original values (EIP-1283), warm-up, trie persistence |
| `TransientStorageProvider.cs` | 1KB | EIP-1153 transient storage (extends PartialStorageProviderBase, returns zero for uncached) |
| `PartialStorageProviderBase.cs` | 10KB | Common base for persistent+transient: `_intraBlockCache`, `_changes` list, `_transactionChangesSnapshots` stack, snapshot/restore |
| `StateTree.cs` | 4.5KB | Account trie |
| `StorageTree.cs` | 6KB | Per-account storage trie |
| `IWorldStateManager.cs` | 1.5KB | Interface for world state management |
| `IStateReader.cs` | 0.8KB | Read-only state access interface |

### Nethermind Snapshot Architecture (change-list approach)

**StateProvider** uses `List<Change>` with index-based snapshots:
```csharp
// Change type classifications
enum ChangeType { Null, JustCache, Touch, Update, New, Delete, RecreateEmpty }

readonly struct Change(Address address, Account? account, ChangeType type);

// Key data structures:
Dictionary<AddressAsKey, StackList<int>> _intraTxCache;  // key -> stack of change indices
List<Change> _changes;  // ordered change log
Dictionary<AddressAsKey, ChangeTrace> _blockChanges;     // block-level tracking
```

**TakeSnapshot()** returns `_changes.Count - 1` (current position index).

**Restore(snapshot)** truncates change list, preserves `JustCache` entries via `_keptInCache`.

**WorldState.TakeSnapshot()** creates composite snapshot:
```csharp
Snapshot TakeSnapshot(bool newTransactionStart = false) {
    int persistentSnapshot = _persistentStorageProvider.TakeSnapshot(newTransactionStart);
    int transientSnapshot = _transientStorageProvider.TakeSnapshot(newTransactionStart);
    int stateSnapshot = _stateProvider.TakeSnapshot();
    return new Snapshot(storageSnapshot, stateSnapshot);
}
```

**PartialStorageProviderBase** (shared by persistent + transient):
- `_intraBlockCache: Dict<StorageCell, StackList<int>>` — maps (address,slot) to change index stack
- `_changes: List<Change>` — ordered change log
- `_transactionChangesSnapshots: Stack<int>` — marks transaction boundaries
- `TryGetCachedValue()` — reads from latest change
- `Restore(snapshot)` — truncates, preserves JustCache, pops transaction markers

**PersistentStorageProvider** adds:
- `_originalValues: Dict<StorageCell, byte[]>` — for SSTORE gas (EIP-1283/2200)
- `_storages: Dict<AddressAsKey, PerContractState>` — per-contract trie state
- `LoadFromTree(storageCell)` — falls through to trie on cache miss
- `GetOriginal(storageCell)` — reads original value, handles transaction boundaries
- `WarmUp(storageCell)` — pre-loads for EIP-2929

**TransientStorageProvider** is minimal:
- Extends `PartialStorageProviderBase`
- `GetCurrentValue()` returns `ZeroBytes` on cache miss (no trie backing)

---

## Execution Specs Reference (Authoritative Source)

### State Model (`execution-specs/src/ethereum/forks/cancun/state.py`)

```python
@dataclass
class State:
    _main_trie: Trie[Address, Optional[Account]]
    _storage_tries: Dict[Address, Trie[Bytes32, U256]]
    _snapshots: List[Tuple[Trie[...], Dict[...]]]  # snapshot stack
    created_accounts: Set[Address]

@dataclass
class TransientStorage:
    _tries: Dict[Address, Trie[Bytes32, U256]]
    _snapshots: List[Dict[Address, Trie[...]]]
```

**Key functions:**
- `begin_transaction(state, transient_storage)` — deep-copies tries to snapshot stack
- `commit_transaction(state, transient_storage)` — pops snapshot (discards backup)
- `rollback_transaction(state, transient_storage)` — restores from snapshot
- `get_account(state, addr)` — returns `EMPTY_ACCOUNT` if not found
- `get_account_optional(state, addr)` — returns `None` if not found
- `set_account(state, addr, account)` — sets in trie (None = delete)
- `destroy_account(state, addr)` — removes account AND storage
- `get_storage(state, addr, key)` — reads storage trie
- `set_storage(state, addr, key, value)` — writes storage trie
- `get_storage_original(state, addr, key)` — reads from `_snapshots[0]` (transaction start), returns 0 for `created_accounts`
- `modify_state(state, addr, f)` — atomic modify with auto-cleanup of empty accounts
- `get_transient_storage(ts, addr, key)` — returns `U256(0)` if not found
- `set_transient_storage(ts, addr, key, value)` — writes transient trie
- `mark_account_created(state, addr)` — for `get_storage_original` edgecase + EIP-6780

### State file paths across hardforks:
All at `execution-specs/src/ethereum/forks/<fork>/state.py`:
- `frontier/state.py` — Base model
- `berlin/state.py` — Added `created_accounts`, `get_storage_original()`
- `cancun/state.py` — Added `TransientStorage` with snapshots
- `prague/state.py` — Same structure as Cancun

### VM Environment (`execution-specs/src/ethereum/forks/cancun/vm/__init__.py`)

```python
@dataclass
class Message:
    # ...
    accessed_addresses: Set[Address]       # EIP-2929
    accessed_storage_keys: Set[Tuple[Address, Bytes32]]
    # ...

@dataclass
class Evm:
    # ...
    accounts_to_delete: Set[Address]       # SELFDESTRUCT
    accessed_addresses: Set[Address]
    accessed_storage_keys: Set[Tuple[Address, Bytes32]]
    # ...
```

**Journaling in Python:** uses **snapshot-copy** (deep clones of tries).
**Nethermind:** uses **change-list** (append-only log with index-based snapshots).
**Our journal.zig:** uses **change-list** (Nethermind style) — already implemented.

---

## Existing Implementation Status

### `client/state/journal.zig` (COMPLETE)
Generic change-list journal with:
- `Journal(K, V)` — comptime-generic journal
- `Entry(K, V)` — `{ key: K, value: ?V, tag: ChangeTag }`
- `ChangeTag` — `just_cache`, `update`, `create`, `delete`, `touch`
- `take_snapshot()` — returns index (or `empty_snapshot` sentinel)
- `restore(snapshot, on_revert_cb)` — truncates, preserves `just_cache` entries
- `commit(snapshot, on_commit_cb)` — commits entries, truncates
- `JournalError` — `InvalidSnapshot`, `OutOfMemory`

### What Remains To Build

1. **`client/state/account.zig`** — Account helpers wrapping Voltaire `AccountState`:
   - `isEmpty()`, `isTotallyEmpty()`, `isContract()`
   - Convenience constructors
   - EIP-158 empty account handling

2. **`client/state/state.zig`** — WorldState coordinator:
   - Account journal (using `Journal(Address, AccountState)`)
   - Persistent storage journal (using `Journal(StorageKey, u256)`)
   - Transient storage journal (using `Journal(StorageKey, u256)`)
   - Per-key caches (`_intraTxCache` equivalent: `AutoHashMap(K, ArrayListUnmanaged(usize))`)
   - Original storage tracking (`_originalValues` equivalent)
   - Created/selfdestructed/touched account sets
   - Composite snapshot (state + persistent + transient positions)
   - State root computation (delegating to trie layer)
   - WarmUp for access lists (EIP-2929)

3. **Integration with HostAdapter** (Phase 3 concern, but state API must support it)

---

## Test Fixtures

### Unit tests (inline `test` blocks):
- Journal snapshot/restore cycles
- Composite snapshot (state + storage)
- Account CRUD with rollback
- Transient storage isolation
- Original storage tracking
- Created account edge cases

### Ethereum test suites (for state root validation after Phase 3 integration):
- `ethereum-tests/GeneralStateTests/stSStoreTest/` — SSTORE gas/refund
- `ethereum-tests/GeneralStateTests/stCallCreateCallCodeTest/` — Nested call state
- `ethereum-tests/GeneralStateTests/stTransactionTest/` — Transaction-level state
- `ethereum-tests/GeneralStateTests/stSpecialTest/` — Edge cases
- `ethereum-tests/GeneralStateTests/stRefundTest/` — Gas refund with storage
- `ethereum-tests/TrieTests/` — Trie correctness (Phase 1)

**Note:** `ethereum-tests/GeneralStateTests/` directory does not exist in current checkout (submodule may need init).

---

## File-to-File Reference Map

| Implementation Target | Nethermind Reference | Spec Reference | Voltaire Primitive |
|----------------------|---------------------|----------------|-------------------|
| `client/state/account.zig` | `StateProvider.cs:GetAccount()` | `cancun/state.py:get_account()` | `StateCache.AccountState` |
| `client/state/journal.zig` (DONE) | `PartialStorageProviderBase.cs` | `cancun/state.py:_snapshots` | — |
| `client/state/state.zig` | `WorldState.cs` | `cancun/state.py:State+TransientStorage` | `StateManager` (pattern) |
| Storage tracking | `PersistentStorageProvider.cs:_originalValues` | `cancun/state.py:get_storage_original()` | `StorageKey` |
| Transient storage | `TransientStorageProvider.cs` | `cancun/state.py:TransientStorage` | — |
| Warm/cold | (in EVM, not state layer) | `cancun/vm/__init__.py:accessed_*` | — |
| Host bridge | — | — | `host_adapter.zig` (DONE) |

---

## Summary

Phase 2 builds the world state layer between trie storage (Phase 1) and EVM execution (Phase 3).

**Already done:**
- Generic `Journal(K, V)` with change-list snapshot/restore (Nethermind pattern)
- `HostAdapter` bridging Voltaire `StateManager` to guillotine-mini `HostInterface`

**Still needed:**
1. `account.zig` — Account helpers wrapping Voltaire `AccountState`
2. `state.zig` — WorldState coordinator with:
   - Account/storage/transient journals (built on `Journal`)
   - Per-key intra-tx caches (for O(1) latest-value lookup)
   - Original storage tracking (for SSTORE gas)
   - Composite snapshots
   - Created/selfdestructed/touched account tracking
   - State root delegation to trie layer

**Key architectural decision:** Use change-list journaling (Nethermind/journal.zig) not snapshot-copy (Voltaire/StateCache), as it's more memory-efficient for large state.
