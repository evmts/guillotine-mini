# [pass 1/5] phase-2-world-state (World State (Journal + Snapshot/Restore))

**Goals**

- Implement journaled world state with snapshot/restore for transaction processing.
- Target components from plan: `client/state/account.zig`, `client/state/journal.zig`, `client/state/state.zig` (TypeScript equivalents under `client-ts/`).
- Follow Nethermind state architecture while using Effect.ts `Context.Tag` + `Layer`.

**Specs**

- `execution-specs/src/ethereum/forks/*/state.py` for state structure, snapshotting, and storage semantics.
- Yellow Paper Section 4 (World State) for conceptual model and root calculations.
- EIP-1153 (Transient Storage) appears in Cancun/Prague/Osaka state specs via `TransientStorage`.

**Spec Details Observed (execution-specs)**

- `State` contains a main secured account trie, per-account storage tries, and a snapshot stack; `begin_transaction` copies tries and `commit_transaction`/`rollback_transaction` pops/restores.
- `state_root` and `storage_root` assert no active snapshots; empty storage uses `EMPTY_TRIE_ROOT`.
- `set_storage` requires account presence and deletes storage trie if it becomes empty.
- Cancun adds `created_accounts` and `TransientStorage` with its own snapshot stack; commit/rollback clear `created_accounts` when outermost snapshot completes.
- Account helpers include `get_account_optional` vs `get_account` (EMPTY_ACCOUNT), `account_exists`, `account_has_code_or_nonce`, `account_has_storage`, `touch_account`, and balance/nonce/code setters.

**Nethermind References (architecture)**

- DB interfaces (state persistence hooks): `nethermind/src/Nethermind/Nethermind.Db/IDb.cs`, `IColumnsDb.cs`, `DbProvider.cs`, `DbNames.cs`, `MemDb.cs`.
- World state layout: `nethermind/src/Nethermind/Nethermind.State/WorldState.cs`, `WorldStateManager.cs`, `StateProvider.cs`, `StateReader.cs`, `StorageTree.cs`, `TransientStorageProvider.cs`.

**Voltaire-Effect Primitives/Services To Reuse**

- `voltaire-effect/primitives/AccountState` for account schema + `EMPTY_CODE_HASH` and `EMPTY_STORAGE_ROOT`.
- `voltaire-effect/primitives/State` for `StorageKeyType` and `StorageKeySchema`.
- `voltaire-effect/primitives/Storage`, `StorageValue`, `StorageDiff` for slot/value modeling.
- Core primitives: `Address`, `Bytes`, `Bytes32`, `Hash`, `Hex`, `U256`.
- Hardfork gating: `voltaire-effect/primitives/Hardfork` (`supportsTransientStorage`).

**Effect.ts Patterns (from effect-repo + client-ts)**

- Use `Context.Tag` for services and `Layer.scoped/succeed` for DI.
- Use `Effect.gen(function* () { ... })` for sequential logic; pipe for short chains.
- Use `Effect.acquireRelease` + `Scope` for snapshots and resource lifecycle.
- Use `Schema` at boundaries, typed `Data.TaggedError`, and typed error channels.

**Existing client-ts Code Patterns**

- DB service in `client-ts/db/Db.ts` mirrors Nethermind flags, uses `Context.Tag`, `Layer.scoped`, `Schema`, `Effect.acquireRelease`, and `Effect.gen`.
- Trie hashing in `client-ts/trie/hash.ts` exposes a `TrieHash` service with `Layer.succeed` and typed errors.
- Trie node types in `client-ts/trie/Node.ts` alias Voltaire primitives (`Bytes`, `Hash`, `Rlp`).
- Tests in `client-ts/db/*.test.ts` use `@effect/vitest` `it.effect()` and provide layers via `Effect.provide`.

**Test Fixtures**

- `ethereum-tests/fixtures_general_state_tests.tgz` (GeneralStateTests bundle referenced by plan/specs).
- `ethereum-tests/TrieTests/` (relevant for state trie behavior).
- `execution-spec-tests/` exists but is empty in this repo snapshot.
