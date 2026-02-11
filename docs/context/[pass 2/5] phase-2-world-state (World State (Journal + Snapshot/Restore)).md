# [pass 2/5] phase-2-world-state (World State (Journal + Snapshot/Restore))

## Goal and scope
Source: `prd/GUILLOTINE_CLIENT_PLAN.md` (Phase 2)
- Implement journaled world state with snapshot/restore for transaction processing.
- Planned components: `client/state/account.zig`, `client/state/journal.zig`, `client/state/state.zig`.
- Structural references: `nethermind/src/Nethermind/Nethermind.State/` and `voltaire/packages/voltaire-zig/src/state-manager/`.

## Spec references to follow
Source: `prd/ETHEREUM_SPECS_REFERENCE.md` (Phase 2)
- Primary EL state spec: `execution-specs/src/ethereum/forks/*/state.py`.
- Yellow Paper world state model: Section 4 (`yellowpaper/Paper.tex`).
- Test intent: journal/snapshot unit coverage plus state-manipulation fixtures.

### execution-specs state behavior (implementation-critical)
Primary files inspected:
- `execution-specs/src/ethereum/forks/frontier/state.py`
- `execution-specs/src/ethereum/forks/cancun/state.py`
- Full fork set available at: `execution-specs/src/ethereum/forks/{frontier..prague,osaka}/state.py`

Key semantics to mirror:
- `State` tracks `_main_trie`, `_storage_tries`, `_snapshots`.
- Nested transaction boundaries:
  - `begin_transaction(...)` pushes snapshot copies.
  - `commit_transaction(...)` pops snapshots.
  - `rollback_transaction(...)` restores from snapshot top.
- `state_root`/`storage_root` require no active snapshots.
- Account existence distinction is explicit:
  - non-existent account (`None`) vs `EMPTY_ACCOUNT`.
- `set_account(..., None)` deletes account node; `destroy_account` also removes storage.
- Storage behavior:
  - `get_storage` defaults to zero.
  - `set_storage(..., 0)` deletes slot and prunes empty storage trie.
- Cancun adds tx-scoped `TransientStorage` with its own snapshot stack.
- Cancun adds `created_accounts` and `get_storage_original(...)` semantics for original slot value tracking.

### Relevant EIPs for world-state correctness
Files:
- `EIPs/EIPS/eip-158.md` (state trie clearing)
- `EIPs/EIPS/eip-161.md` (state trie clearing refinements / touched-empty account handling)
- `EIPs/EIPS/eip-2929.md` (state access costs; warm/cold implications)
- `EIPs/EIPS/eip-2930.md` (access lists)
- `EIPs/EIPS/eip-6780.md` (SELFDESTRUCT semantic changes)

### devp2p references (not core for local journal logic, but relevant for later state/sync integration)
Files:
- `devp2p/rlpx.md`
- `devp2p/caps/eth.md`
- `devp2p/caps/snap.md`

## Nethermind Db inventory (requested listing)
Directory listed: `nethermind/src/Nethermind/Nethermind.Db/`

Key files for architecture mapping:
- `IDb.cs`: base key-value DB abstraction with batch support and read-only wrapper creation.
- `IReadOnlyDb.cs`: read-only DB contract with `ClearTempChanges()`.
- `IColumnsDb.cs`: column-family DB abstraction with `StartWriteBatch()` and `CreateSnapshot()`.
- `DbProvider.cs`: DI-based DB resolution (`GetDb`, `GetColumnDb`).
- `ReadOnlyDb.cs`: overlays writes in `MemDb` without mutating base DB.
- `ReadOnlyColumnsDb.cs`: per-column read-only wrappers and temp-change clearing.
- `InMemoryWriteBatch.cs` / `InMemoryColumnBatch.cs`: deferred in-memory batching patterns.
- `MemColumnsDb.cs`: in-memory columns DB (`CreateSnapshot()` currently not supported).

Other notable files from listing:
- `DbNames.cs`, `DbExtensions.cs`, `DbProviderExtensions.cs`, `MetadataDbKeys.cs`
- `BlobTxsColumns.cs`, `ReceiptsColumns.cs`
- `MemDb.cs`, `ReadOnlyDbProvider.cs`, `NullDb.cs`, `RocksDbSettings.cs`
- `FullPruning/*`

## Voltaire-zig source inventory and relevant APIs
Directory listed: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
Top-level modules:
- `state-manager/`, `primitives/`, `evm/`, `blockchain/`, `crypto/`, `jsonrpc/`, `precompiles/`

### state-manager APIs (directly relevant)
Files:
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/state-manager/root.zig`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/state-manager/StateManager.zig`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/state-manager/JournaledState.zig`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/state-manager/StateCache.zig`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/state-manager/ForkBackend.zig`

API surface to mirror in Effect.ts:
- `StateManager`: `getBalance/getNonce/getCode/getStorage`, `setBalance/setNonce/setCode/setStorage`, `checkpoint/revert/commit`, `snapshot/revertToSnapshot`.
- `JournaledState`: dual-cache read cascade, writes to local cache, `checkpoint/revert/commit`.
- `StateCache`: account/storage/code caches with journaling-style checkpoint stack operations.
- `ForkBackend`: optional remote-state fetch path and cache management.

### primitives exports to preserve in TS client
Source: `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/root.zig`
- Canonical primitives include `Address`, `Hash`, `Hex`, plus state/block/tx types.
- Context implication: TS implementation should continue to use `voltaire-effect/primitives` types and avoid custom address/hash/hex wrappers.

## Existing guillotine-mini host interface
File: `src/host.zig`
- Defines `HostInterface` vtable with external world-state operations:
  - `getBalance/setBalance`
  - `getCode/setCode`
  - `getStorage/setStorage`
  - `getNonce/setNonce`
- Comments note nested calls are handled by `EVM.inner_call` directly, so host is focused on external state access.

## Test fixture paths (requested inventory)
Top-level directory listed: `ethereum-tests/`

Available state-relevant paths in this checkout:
- `ethereum-tests/BlockchainTests/ValidBlocks/bcStateTests/`
- `ethereum-tests/BlockchainTests/InvalidBlocks/bcStateTests/`
- `ethereum-tests/BlockchainTests/ValidBlocks/bcEIP1153-transientStorage/`
- `ethereum-tests/TrieTests/`
- `ethereum-tests/fixtures_general_state_tests.tgz` (archive present)

Not present as extracted directory in this checkout:
- `ethereum-tests/GeneralStateTests/` (missing as directory; appears bundled via tgz file)

Execution-spec-tests status:
- `execution-spec-tests/fixtures/` exists but is currently empty in this checkout.

## Implementation guidance derived from gathered context
- Prioritize a journal abstraction that supports nested checkpoints and deterministic rollback.
- Keep account non-existence vs empty-account semantics explicit.
- Include storage deletion-on-zero and empty-trie pruning behavior.
- Keep snapshot/root computation rules strict (no root calc during active snapshots).
- Plan for transient-storage compatibility (EIP-1153 era) even if implemented in later pass.
- Mirror Nethermind-like service boundaries (state provider / storage provider / world state manager) in idiomatic Effect `Context.Tag` + `Layer` services.
