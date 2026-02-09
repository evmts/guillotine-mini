# [Pass 1/5] Phase 3: EVM ↔ WorldState Integration (Transaction/Block Processing) — Context

## Goal

Connect the EVM to WorldState for transaction and block processing. This phase binds execution to state mutation, using guillotine-mini as the EVM reference while reimplementing behavior in Effect.ts.

**Key deliverables (from `prd/GUILLOTINE_CLIENT_PLAN.md`):**
- `client/evm/host_adapter.zig` — Implement HostInterface using WorldState
- `client/evm/processor.zig` — Transaction processor

---

## Specs to Implement (Authoritative)

**Primary execution spec paths (phase-3):**
- `execution-specs/src/ethereum/forks/*/vm/__init__.py`
- `execution-specs/src/ethereum/forks/*/fork.py` (transaction + block processing)

**Prague fork reference (latest):**
- `execution-specs/src/ethereum/forks/prague/vm/__init__.py`
  - Defines `BlockEnvironment`, `TransactionEnvironment`, `Message`, `Evm` dataclasses.
  - Tracks access list warm sets, transient storage, blob versioned hashes, authorizations (EIP-7702).
  - `incorporate_child_on_success/error` defines how child call results aggregate into parent.
- `execution-specs/src/ethereum/forks/prague/fork.py`
  - `state_transition()` validates header, applies block body, computes roots, compares against header.
  - `apply_body()` runs system txs, loops transactions, processes withdrawals and requests.
  - `process_transaction()` handles intrinsic gas, sender checks, fee payment/refund, access list/authorization setup, message execution, gas refund (EIP-7623), receipts/logs, selfdestruct handling.

**Related spec modules referenced by fork.py (Prague):**
- `execution-specs/src/ethereum/forks/prague/transactions.py` (decode/validate tx, recover sender)
- `execution-specs/src/ethereum/forks/prague/vm/interpreter.py` (message execution)
- `execution-specs/src/ethereum/forks/prague/vm/gas.py` (blob gas, fees)
- `execution-specs/src/ethereum/forks/prague/state.py` (state, transient storage, account/storage helpers)

**Notes for phase 3:**
- Access list warm-up is explicit in `process_transaction` (coinbase + access list entries).
- Gas accounting includes EIP-1559 fee logic + EIP-7623 calldata floor.
- System transactions (beacon roots, history storage, requests) are part of block body.

---

## guillotine-mini EVM (Behavioral Reference)

Key local files to mirror behavior (Zig EVM reference):
- `src/evm.zig` — EVM orchestration, call stack, access list, refunds, storage handling.
- `src/host.zig` — Minimal `HostInterface` vtable for balance/nonce/code/storage access (not used for nested calls).
- `src/storage.zig` — Storage model (persistent/original/transient).
- `src/frame.zig`, `src/call_params.zig`, `src/call_result.zig` — Call execution contracts.

Important behavior notes:
- `HostInterface` is only for external state access (nested calls handled internally in EVM).
- EVM tracks access list, refund counter, created/selfdestructed/touched accounts, and has snapshot stacks.

---

## Existing Effect.ts Client (client-ts/)

### EVM Integration (in-progress)
- `client-ts/evm/HostAdapter.ts`
  - `HostAdapter` Context.Tag + Layer bridging `WorldState` to EVM host calls.
  - Local `codes` map caches runtime code by address; `setCode` updates account `codeHash` via `Hash.keccak256`.
  - Exposes `getBalance/setBalance`, `getNonce/setNonce`, `getCode/setCode`, `getStorage/setStorage` functions.
- `client-ts/evm/IntrinsicGasCalculator.ts`
  - Calculates intrinsic gas + calldata floor, gated by hardfork flags (`ReleaseSpec`).
  - Supports access lists (EIP-2930), init code cost (EIP-3860), calldata floor (EIP-7623), authorization list (EIP-7702).
  - Uses `Schema.decode` at boundaries; error channel is typed (`InvalidTransactionError`, etc.).
- `client-ts/evm/ReleaseSpec.ts`
  - `ReleaseSpec` Context.Tag with `Hardfork` gating feature flags (EIP-2028, 2930, 3860, 7623, 7702).

### World State
- `client-ts/state/State.ts`
  - `WorldState` Context.Tag with account + storage maps, journaled snapshot/restore/commit.
  - `MissingAccountError` for storage writes to non-existent accounts.
  - Tracks `createdAccountFrames` for “account created in tx” checks.
- `client-ts/state/Journal.ts`
  - Generic change-list journal w/ `ChangeTag` and snapshot restore/commit behavior.
- `client-ts/state/Account.ts`
  - Uses `AccountState` from `voltaire-effect`, defines `EMPTY_ACCOUNT`, `EMPTY_CODE_HASH`, `EMPTY_STORAGE_ROOT`.

### Tests (Effect + @effect/vitest)
- `client-ts/evm/HostAdapter.test.ts`
- `client-ts/evm/IntrinsicGasCalculator.test.ts`
- `client-ts/state/*.test.ts` — journaling, state, account behavior

---

## Voltaire-Effect Primitives (MUST USE)

Relevant exports from `voltaire-effect/src/primitives/index.ts`:
- `Address`, `Hash`, `Hex`, `RuntimeCode`, `Storage`, `StorageValue`
- `AccountState`, `Transaction`, `Gas`, `Hardfork`
- `State`, `StateRoot`, `AccessList`, `Authorization` (for EIP-7702)

Path references:
- `/Users/williamcory/voltaire/voltaire-effect/src/primitives/Address/*`
- `/Users/williamcory/voltaire/voltaire-effect/src/primitives/Hash/*`
- `/Users/williamcory/voltaire/voltaire-effect/src/primitives/Transaction/*`
- `/Users/williamcory/voltaire/voltaire-effect/src/primitives/AccountState/*`
- `/Users/williamcory/voltaire/voltaire-effect/src/primitives/Storage/*`
- `/Users/williamcory/voltaire/voltaire-effect/src/primitives/StorageValue/*`
- `/Users/williamcory/voltaire/voltaire-effect/src/primitives/RuntimeCode/*`
- `/Users/williamcory/voltaire/voltaire-effect/src/primitives/Gas/*`
- `/Users/williamcory/voltaire/voltaire-effect/src/primitives/Hardfork/*`

---

## Effect.ts Patterns (Reference)

Relevant Effect modules (see `effect-repo/packages/effect/src/`):
- `Effect.ts` — core Effect API, `Effect.gen`, `Effect.acquireRelease`
- `Context.ts` — `Context.Tag` for DI
- `Layer.ts` — `Layer.effect`, `Layer.succeed`, `Layer.provide`
- `Schema.ts` — boundary validation
- `Data.ts` — typed errors (`Data.TaggedError`)
- `Option.ts`, `Either.ts`, `Cause.ts` — common effect patterns

---

## Nethermind Reference (Architecture)

### DB Layer inventory (required listing)
`nethermind/src/Nethermind/Nethermind.Db/`:
- `DbProvider.cs`, `IDb.cs`, `IDbProvider.cs`, `IColumnsDb.cs`, `IFullDb.cs`
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`, `NullDb.cs`, `MemDb.cs`
- `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/*`
- `ReadOnlyDb*.cs`, `DbExtensions.cs`, `DbNames.cs`

### EVM/State architecture to consult (not yet opened)
- `nethermind/src/Nethermind/Nethermind.Evm/`
- `nethermind/src/Nethermind/Nethermind.State/`

---

## Test Fixtures

**ethereum-tests** (present directories):
- `ethereum-tests/BasicTests/`
- `ethereum-tests/BlockchainTests/`
- `ethereum-tests/TrieTests/`
- `ethereum-tests/TransactionTests/`
- `ethereum-tests/LegacyTests/`
- `ethereum-tests/EOFTests/`
- `ethereum-tests/fixtures_general_state_tests.tgz` (GeneralStateTests are not checked out as a directory)

**execution-spec-tests**
- `execution-spec-tests/` (empty in current checkout)

---

## Implementation Implications for Phase 3

- The EVM host adapter already exists in TS (`client-ts/evm/HostAdapter.ts`) and mirrors the minimal `HostInterface` behavior from Zig; it should be the bridge for world state access.
- The transaction processing logic needs to follow `execution-specs` fork.py semantics: intrinsic gas, sender balance adjustments, gas refunds, access list warming, receipts/logs, and account deletion.
- Use Voltaire primitives at boundaries (`Transaction`, `AccountState`, `Storage`, `StorageValue`) with `Schema.decode` for validation.
- DI wiring is via `Context.Tag` + `Layer` (no `Effect.runPromise` except at app edge).

