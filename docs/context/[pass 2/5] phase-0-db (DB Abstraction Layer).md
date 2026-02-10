# [Pass 2/5] Phase 0: DB Abstraction Layer — Context

## 1) Phase goals to implement

Source: `prd/GUILLOTINE_CLIENT_PLAN.md` (`Phase 0: DB Abstraction Layer (phase-0-db)`).

- Goal: build a persistent-storage abstraction with interchangeable backends.
- Planned components:
  - `client/db/adapter.zig` (generic DB interface)
  - `client/db/rocksdb.zig` (RocksDB backend)
  - `client/db/memory.zig` (in-memory backend for tests)

## 2) Relevant specs and references

Source: `prd/ETHEREUM_SPECS_REFERENCE.md` (`Phase 0: DB Abstraction (phase-0-db)`).

- External protocol specs: **N/A** for this phase (internal abstraction).
- Primary architectural reference: `nethermind/src/Nethermind/Nethermind.Db/`.
- Test guidance: unit tests only for phase 0.

## 3) Nethermind DB architecture inventory

Directory scanned: `nethermind/src/Nethermind/Nethermind.Db/`.
Subdirectories present: `Blooms/`, `FullPruning/`.

Key files to mirror structurally:

- `nethermind/src/Nethermind/Nethermind.Db/IDb.cs`
  - Core key/value DB interface (`IKeyValueStoreWithBatching`, metadata, `Dispose`, enumeration).
- `nethermind/src/Nethermind/Nethermind.Db/IColumnsDb.cs`
  - Column-family abstraction (`GetColumnDb`, column batch, snapshot).
- `nethermind/src/Nethermind/Nethermind.Db/IDbFactory.cs`
  - Backend factory (`CreateDb`, `CreateColumnsDb`, path resolution).
- `nethermind/src/Nethermind/Nethermind.Db/MemDb.cs`
  - In-memory implementation with batching, metrics, and optional read/write delay for tests.

Additional module boundary signals:

- Provider layer: `DbProvider.cs`, `IDbProvider.cs`, `ReadOnlyDbProvider.cs`.
- Read-only wrappers: `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `IReadOnlyDb.cs`, `IReadOnlyDbProvider.cs`.
- Backend/config hooks: `RocksDbSettings.cs`, `ITunableDb.cs`, `IMergeOperator.cs`, `NullRocksDbFactory.cs`.
- Batching utilities: `InMemoryWriteBatch.cs`, `InMemoryColumnBatch.cs`.
- Pruning surface: `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/*`.

## 4) Voltaire Zig APIs to reference

Top-level directory scanned: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`.
Relevant modules present:

- `primitives/`
- `state-manager/`
- `blockchain/`

Concrete exports relevant to DB-key/value modeling (from `.../primitives/root.zig`):

- `primitives.Address`
- `primitives.Hash`
- `primitives.Hex`
- `primitives.Bytes`
- `primitives.Bytes32`
- `primitives.BlockHash`
- `primitives.TransactionHash`
- `primitives.Slot`
- `primitives.StorageValue`
- `primitives.StateRoot`
- `primitives.AccountState`
- `primitives.Rlp`

Related state/block modules that may consume DB services:

- `state-manager/StateManager.zig`
- `state-manager/JournaledState.zig`
- `blockchain/BlockStore.zig`

## 5) Existing host integration contract

Source: `src/host.zig`.

- `HostInterface` uses ptr + vtable.
- Required state-facing operations:
  - `getBalance` / `setBalance`
  - `getCode` / `setCode`
  - `getStorage` / `setStorage`
  - `getNonce` / `setNonce`
- `Address` is imported from primitives (`const Address = primitives.Address.Address`).
- Comment in file notes nested EVM calls are handled internally by EVM and not routed through this host interface.

## 6) Ethereum test fixture directories (inventory)

Root scanned: `ethereum-tests/`.
Top-level fixture families:

- `ethereum-tests/BlockchainTests/`
- `ethereum-tests/TrieTests/`
- `ethereum-tests/TransactionTests/`
- `ethereum-tests/RLPTests/`
- `ethereum-tests/DifficultyTests/`
- `ethereum-tests/EOFTests/`
- `ethereum-tests/ABITests/`
- `ethereum-tests/BasicTests/`
- `ethereum-tests/GenesisTests/`
- `ethereum-tests/KeyStoreTests/`
- `ethereum-tests/LegacyTests/`
- `ethereum-tests/PoWTests/`

Notable subpaths found while scanning:

- `ethereum-tests/BlockchainTests/ValidBlocks/`
- `ethereum-tests/BlockchainTests/InvalidBlocks/`
- `ethereum-tests/TransactionTests/ttEIP1559/`
- `ethereum-tests/TransactionTests/ttEIP2930/`
- `ethereum-tests/TransactionTests/ttEIP3860/`

Phase-0-db remains unit-test focused, but these fixtures are relevant downstream once DB-backed state/block modules are wired.

## 7) Implementation implications for client-ts

- Mirror Nethermind boundaries in Effect.ts:
  - core DB service
  - column DB service
  - provider/factory services
  - read-only wrappers
  - in-memory backend first
- Keep phase-0-db protocol-agnostic (no consensus/execution rule coupling yet).
- Use Voltaire primitives and avoid custom key/address/hash wrappers in future client-ts code.
