# [pass 1/5] phase-2-world-state (World State (Journal + Snapshot/Restore))

**Goals (from plan)**

- Implement journaled world state with snapshot/restore for transaction processing.
- Target components: `client/state/account.zig`, `client/state/journal.zig`, `client/state/state.zig`.
- Follow Nethermind state architecture, but implement idiomatically in Zig using comptime DI.

**Spec Files Read**

- `execution-specs/src/ethereum/forks/prague/state.py`

**Spec Details Observed (execution-specs prague)**

- `State` owns a secured main account trie, per-account storage tries, a snapshot stack, and `created_accounts`.
- `TransientStorage` maintains per-address storage tries with its own snapshot stack.
- `begin_transaction` pushes copies of main/storage tries and transient storage tries; `commit_transaction` pops snapshots and clears `created_accounts` at outermost depth; `rollback_transaction` restores prior tries and clears `created_accounts` at outermost depth.
- `get_account` returns `EMPTY_ACCOUNT` when `None`, while `get_account_optional` preserves missing vs empty distinction.
- State transitions are snapshot-based; state root computation is invalid during an open transaction (per docstring).

**Spec References (not yet opened in this pass)**

- `execution-specs/src/ethereum/forks/*/state.py` (other forks)
- Yellow Paper Section 4 (World State)
- EIP-1153 (Transient Storage)

**Nethermind DB (listed for context)**

- `nethermind/src/Nethermind/Nethermind.Db/IDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IColumnsDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/DbProvider.cs`
- `nethermind/src/Nethermind/Nethermind.Db/DbNames.cs`
- `nethermind/src/Nethermind/Nethermind.Db/MemDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDb.cs`

**Nethermind State (from plan, to inspect next)**

- `nethermind/src/Nethermind/Nethermind.State/WorldState.cs`
- `nethermind/src/Nethermind/Nethermind.State/WorldStateManager.cs`
- `nethermind/src/Nethermind/Nethermind.State/StateProvider.cs`
- `nethermind/src/Nethermind/Nethermind.State/StateReader.cs`
- `nethermind/src/Nethermind/Nethermind.State/StorageTree.cs`
- `nethermind/src/Nethermind/Nethermind.State/TransientStorageProvider.cs`

**Voltaire Zig APIs (actual location differs from prompt)**

- Expected path in prompt: `/Users/williamcory/voltaire/packages/voltaire-zig/src/` (not present).
- Found Zig sources at `/Users/williamcory/voltaire/src/`.
- `state-manager/root.zig`: re-exports `StateManager`, `JournaledState`, `StateCache` types, `ForkBackend`.
- `state-manager/JournaledState.zig`: `init`, `getAccount`, `putAccount`, `getStorage`, `putStorage`, `getCode`, `putCode`, `checkpoint`, `revert`, `commit`.
- `state-manager/StateCache.zig`: account/storage/contract caches with journaling.
- `primitives/root.zig`: `AccountState`, `Address`, `Bytes`, `Bytes32`, `Hash`, `Nonce`, `State` and other core types.
- `primitives/trie.zig`: `Trie`, `TrieMask`, `keyToNibbles`, `nibblesToKey` and trie helpers.

**Existing Zig EVM Host Interface**

- `src/host.zig`: `HostInterface` with vtable for `getBalance`, `setBalance`, `getCode`, `setCode`, `getStorage`, `setStorage`, `getNonce`, `setNonce`.

**Test Fixtures**

- `ethereum-tests/fixtures_general_state_tests.tgz` (GeneralStateTests bundle)
- `ethereum-tests/TrieTests/`
- `execution-spec-tests/fixtures/state_tests/` (present in spec mapping; verify contents later)

**Notes**

- Path mismatch for Voltaire Zig sources should be resolved before implementation (confirm correct import path for this repo).
