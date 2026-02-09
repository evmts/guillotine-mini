# [Pass 1/5] Phase 3: EVM ↔ WorldState Integration (Transaction/Block Processing) — Context

## Goal (from `prd/GUILLOTINE_CLIENT_PLAN.md`)

Connect the guillotine-mini EVM to WorldState for transaction and block processing.

**Key components:**
- `client/evm/host_adapter.zig` — HostInterface backed by WorldState
- `client/evm/processor.zig` — Transaction processor

**Reference files:**
- Nethermind: `nethermind/src/Nethermind/Nethermind.Evm/`
- guillotine-mini: `src/evm.zig`, `src/host.zig`

**Test fixtures (plan):**
- `ethereum-tests/GeneralStateTests/`
- `execution-spec-tests/fixtures/state_tests/`

---

## Existing Guillotine-mini EVM Surface

### Host interface (`src/host.zig`)
Minimal vtable for external state access:
- `getBalance`, `setBalance`
- `getCode`, `setCode`
- `getStorage`, `setStorage`
- `getNonce`, `setNonce`

**Note:** HostInterface is *not* used for nested calls. The EVM inner call path handles those directly.

### EVM entrypoint (`src/evm.zig`)
Key integration touchpoints (high level):
- `Evm(comptime config)` uses an optional `host: ?HostInterface`
- Maintains per-tx caches: balances, nonces, code, storage, access list manager, refund counter
- Stores block/tx context in `BlockContext` (chain_id, coinbase, base fee, blob base fee, etc.)
- The EVM is configured via comptime `EvmConfig` and override tables

### Existing host adapter (already implemented)
`client/evm/host_adapter.zig` bridges Voltaire `StateManager` to guillotine-mini `HostInterface`:
- Getters: log errors and return safe default
- Setters: panic on error (consensus-critical)
- This is the expected bridge for Phase 3 transaction processing

---

## Voltaire Primitives (must use these)

Top-level modules (from `/Users/williamcory/voltaire/packages/voltaire-zig/src/`):
- `state-manager/` — canonical state access + snapshot/revert
- `primitives/` — Address, Hash, U256, AccessList, GasConstants, StorageKey, etc.
- `evm/` — EVM helpers and HostInterface (matches guillotine-mini)

### State manager module (`voltaire/packages/voltaire-zig/src/state-manager/`)
Relevant APIs and types:
- `StateManager.zig` — high-level state API (balance/code/storage/nonce + snapshot)
- `JournaledState.zig` — journaling backend for revert/commit
- `StateCache.zig` — `AccountCache`, `StorageCache`, `ContractCache`, `AccountState`, `StorageKey`
- `ForkBackend.zig` — forked read backend
- `root.zig` — re-exports

### Voltaire EVM host (`voltaire/packages/voltaire-zig/src/evm/host.zig`)
Identical HostInterface vtable shape to `src/host.zig`. Use this for cross-module integration.

### Voltaire forked host adapter (`voltaire/packages/voltaire-zig/src/evm/fork_state_manager.zig`)
Example HostInterface implementation that caches balances/code/storage/nonces and calls a remote RPC on cache miss. Useful as a reference for cache lifetime and host glue.

---

## Execution Specs (authoritative)

### VM environment types
`execution-specs/src/ethereum/forks/cancun/vm/__init__.py`
- `BlockEnvironment`, `BlockOutput`
- `TransactionEnvironment`
- `Message`, `Evm`

### Block/tx processing flow
`execution-specs/src/ethereum/forks/cancun/fork.py`
- `apply_body(...)` — processes beacon roots system tx, then each tx, then withdrawals
- `process_transaction(...)` — validate, compute gas, update sender, build access list, run EVM, apply refund, pay coinbase, destroy accounts, add receipt
- `process_withdrawals(...)` — increases account balances and populates withdrawals trie

### Intrinsic gas + validation
`execution-specs/src/ethereum/forks/cancun/transactions.py`
- `validate_transaction(tx)` — intrinsic gas check, nonce overflow, init-code size
- `calculate_intrinsic_cost(tx)` — base + calldata + create + access list costs

### Message call handling (state snapshot/revert)
`execution-specs/src/ethereum/forks/cancun/vm/interpreter.py`
- `process_message_call` dispatches to create/call
- `process_create_message` and `process_message` wrap execution with `begin_transaction`, `commit_transaction`, `rollback_transaction`

**Reminder:** Fork-specific behavior varies across `execution-specs/src/ethereum/forks/*/`. Use the active hardfork (London/Shanghai/Cancun/Prague) to select rules.

---

## Nethermind Architecture Reference (structural guide only)

### Transaction processing (directory: `nethermind/src/Nethermind/Nethermind.Evm/TransactionProcessing/`)
Key files to mirror structurally:
- `ITransactionProcessor.cs` — Execute/CallAndRestore/Trace entrypoints
- `TransactionProcessor.cs` — validate, buy gas, increment nonce, execute EVM, pay fees, commit/rollback
- `SystemTransactionProcessor.cs` — system tx path (e.g., beacon roots)

### EVM execution + gas
Useful files in `nethermind/src/Nethermind/Nethermind.Evm/`:
- `VirtualMachine.cs`, `IVirtualMachine.cs` — VM API
- `ExecutionEnvironment.cs` — per-call context
- `BlockExecutionContext.cs`, `TxExecutionContext.cs` — block/tx context
- `IntrinsicGasCalculator.cs`, `GasCostOf.cs` — intrinsic gas + constants
- `RefundHelper.cs`, `RefundOf.cs` — refund logic

### State integration
`nethermind/src/Nethermind/Nethermind.Evm/State/`
- `IWorldState.cs`, `Snapshot.cs` — state API and snapshot model

---

## Nethermind.Db quick map (from `nethermind/src/Nethermind/Nethermind.Db/`)

Key files (non-exhaustive):
- `IDb.cs`, `IColumnsDb.cs`, `IReadOnlyDb.cs`, `ITunableDb.cs`
- `IDbProvider.cs`, `DbProvider.cs`, `DbNames.cs`
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`, `NullDb.cs`, `MemDb.cs`

This phase does not directly touch DB, but Phase 3 state access ultimately depends on Phase 0/1 DB layers.

---

## Test Fixtures (paths observed)

### ethereum-tests/
Top-level dirs: `ABITests/`, `BasicTests/`, `BlockchainTests/`, `TransactionTests/`, `TrieTests/`, etc.

State test fixtures are not present as loose files in this checkout. Instead, look at:
- `ethereum-tests/fixtures_general_state_tests.tgz` (GeneralStateTests tarball)
- `ethereum-tests/fixtures_blockchain_tests.tgz` (BlockchainTests tarball)
- `ethereum-tests/src/GeneralStateTestsFiller/` (fillers and templates)

### execution-spec-tests/
No `fixtures/state_tests/` directory in this checkout. The repo contains tooling to generate fixtures (see `execution-spec-tests/src/cli/*` and `execution-spec-tests/docs/library/ethereum_test_fixtures.md`).

---

## Phase 3 Focus Checklist

- Build `TransactionProcessor` and `BlockProcessor` to mirror execution-specs flow and Nethermind structure
- Use Voltaire `StateManager` for all state access (no custom state types)
- Integrate HostInterface adapter and existing EVM entrypoint from `src/evm.zig`
- Ensure correct gas accounting, refunds, coinbase payments, and account deletions
- Add fixtures-based tests (GeneralStateTests, execution-spec-tests generated fixtures)
