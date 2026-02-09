# [Pass 1/5] Phase 3: EVM ↔ WorldState Integration (Transaction/Block Processing) — Context

## Goal (from `prd/GUILLOTINE_CLIENT_PLAN.md`)

Connect the EVM to WorldState for transaction and block processing.

Key components (TypeScript client mirrors these responsibilities):

- Host adapter service that exposes WorldState to the EVM.
- Transaction processor that validates, executes, and applies receipts/state updates.

References listed in plan:

- Nethermind: `nethermind/src/Nethermind/Nethermind.Evm/`
- guillotine-mini: `src/` (EVM behavior reference)

## Specs (execution-specs)

Primary fork reference used for this pass: Prague.

Files and roles:

- `execution-specs/src/ethereum/forks/prague/vm/__init__.py`
  Defines `BlockEnvironment`, `BlockOutput`, `TransactionEnvironment`, `Message`, and `Evm` structures for EVM execution context.
- `execution-specs/src/ethereum/forks/prague/fork.py`
  `state_transition` and `process_transaction` are the top-level transaction/block processing flow (system txs, tx loop, withdrawals, requests).
- `execution-specs/src/ethereum/forks/prague/transactions.py`
  `validate_transaction` and `calculate_intrinsic_cost` implement intrinsic gas, calldata floor gas, init-code size checks, and nonce overflow rules.
- `execution-specs/src/ethereum/forks/prague/vm/interpreter.py`
  `process_message` and `process_create_message` show snapshot, rollback, commit boundaries around calls and contract creation.

Notes:

- Fork-specific behavior changes across `execution-specs/src/ethereum/forks/*/`.
- This checkout has an empty `EIPs/` directory; if EIP text is needed (1559/2930/4844/7702, etc.), the submodule must be populated.

## Nethermind Architecture (structural reference)

Nethermind EVM implementation lives in `nethermind/src/Nethermind/Nethermind.Evm/`.
Key areas to mirror structurally in the TypeScript client:

- `TransactionProcessing/` (transaction processor, system tx path, receipts)
- `VirtualMachine.cs`, `IVirtualMachine.cs` (execution entrypoints)
- `ExecutionEnvironment.cs`, `BlockExecutionContext.cs`, `TxExecutionContext.cs` (per-call/per-tx context)
- `IntrinsicGasCalculator.cs`, `GasCostOf.cs` (intrinsic gas and constant lookups)
- `RefundHelper.cs`, `RefundOf.cs` (refund logic)
- `State/` (world state integration interfaces)

Nethermind DB layer (from `nethermind/src/Nethermind/Nethermind.Db/`), useful for naming parity with client-ts DB:

- `IDb.cs`, `IColumnsDb.cs`, `IReadOnlyDb.cs`, `ITunableDb.cs`
- `IDbProvider.cs`, `DbProvider.cs`, `DbNames.cs`
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`, `NullDb.cs`, `MemDb.cs`
- `BlobTxsColumns.cs`, `ReceiptsColumns.cs`, `MetadataDbKeys.cs`

## voltaire-effect APIs (must-use primitives)

Source: `/Users/williamcory/voltaire/voltaire-effect/src/`.

Primitives relevant for Phase 3:

- `primitives/Address`, `primitives/Hash`, `primitives/Hex`, `primitives/Bytes`
- `primitives/AccountState`, `primitives/State`, `primitives/Storage`, `primitives/StorageValue`, `primitives/StateRoot`
- `primitives/Transaction`, `primitives/Receipt`, `primitives/Log`, `primitives/BloomFilter`
- `primitives/Gas`, `primitives/GasPrice`, `primitives/EffectiveGasPrice`, `primitives/Nonce`
- `primitives/Block`, `primitives/BlockHeader`, `primitives/Withdrawal`, `primitives/Blob`

Services (Effect Context.Tag + Layer oriented):

- `services/Provider`, `services/Signer`, `services/TransactionSerializer`, `services/Kzg`
- `services/Contract`, `services/RawProvider`, `services/RpcBatch`

## Effect.ts reference patterns

Source: `effect-repo/packages/effect/src/`.
Important modules used in client-ts:

- `Context.ts`, `Layer.ts`, `Effect.ts` (DI and effect composition)
- `Schema.ts` (boundary validation)
- `Data.ts` (error data types)
- `Option.ts`, `Scope.ts` (optional values, resource lifetime)

## Existing client-ts implementation (Effect.ts)

Location: `client-ts/`.

World state and journaling:

- `client-ts/state/State.ts` defines `WorldState` service with account + storage maps, snapshot stack, and journal integration.
- `client-ts/state/Journal.ts` defines `Journal` service with snapshot/restore/commit semantics.
- `client-ts/state/Account.ts` re-exports `AccountState` and helpers (EMPTY_ACCOUNT, isEmpty, etc.).

Trie and hashing:

- `client-ts/trie/Node.ts`, `client-ts/trie/hash.ts`, `client-ts/trie/encoding.ts` implement MPT nodes and hashing using voltaire-effect primitives.

DB abstraction:

- `client-ts/db/Db.ts` defines a DB service with `Context.Tag`, `Schema`-validated names, read/write flags, snapshots, and batched writes.

Tests already present:

- `client-ts/state/*.test.ts` covers world state + journal behavior.
- `client-ts/db/*.test.ts` and `client-ts/trie/*.test.ts` cover DB and trie primitives.

## Test fixtures (local paths)

- `ethereum-tests/fixtures_general_state_tests.tgz` (GeneralStateTests tarball)
- `ethereum-tests/fixtures_blockchain_tests.tgz` (BlockchainTests tarball)
- `ethereum-tests/BlockchainTests/`, `ethereum-tests/TransactionTests/`, `ethereum-tests/TrieTests/` (existing dirs)
- `execution-spec-tests/` is empty in this checkout (fixtures not present).

## Phase 3 Integration Notes

- Mirror `process_transaction` and message-call snapshot/rollback/commit flow from `execution-specs`.
- Bridge `WorldState` service to the EVM via a Host adapter using voltaire-effect primitives only.
- Keep tx/block processing logic in small Effect services with explicit error channels.
