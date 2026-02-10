# [Pass 1/5] Phase 0: DB Abstraction Layer - Context

## Phase Goal

Source: `prd/GUILLOTINE_CLIENT_PLAN.md`

- Phase id: `phase-0-db`
- Goal: create a database abstraction layer for persistent storage.
- Planned components:
- `client/db/adapter.zig`
- `client/db/rocksdb.zig`
- `client/db/memory.zig`
- Structural reference: `nethermind/src/Nethermind/Nethermind.Db/`
- Voltaire reference root: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`

## Relevant Specs

Source: `prd/ETHEREUM_SPECS_REFERENCE.md`

- For Phase 0 DB abstraction, normative Ethereum spec dependency is `N/A`.
- Test expectation for this phase: unit tests only.
- Adjacent spec files that drive DB consumers in later phases:
- `execution-specs/src/ethereum/forks/frontier/state.py`
- `execution-specs/src/ethereum/forks/frontier/trie.py`
- `execution-specs/src/ethereum/forks/cancun/state.py`
- `execution-specs/src/ethereum/forks/cancun/trie.py`
- `execution-specs/src/ethereum/forks/prague/state.py`
- `execution-specs/src/ethereum/forks/prague/trie.py`

## Nethermind DB Reference (Key Files)

Listed from: `nethermind/src/Nethermind/Nethermind.Db/`

- `nethermind/src/Nethermind/Nethermind.Db/IDb.cs`
- Core KV interface, batching, metadata (`Flush`, `Clear`, metrics), read helpers.
- `nethermind/src/Nethermind/Nethermind.Db/IColumnsDb.cs`
- Column-family abstraction (`GetColumnDb`), column batching and snapshots.
- `nethermind/src/Nethermind/Nethermind.Db/IDbFactory.cs`
- Backend factory boundary (`CreateDb`, `CreateColumnsDb`, db path resolution).
- `nethermind/src/Nethermind/Nethermind.Db/IDbProvider.cs`
- Named DB provider (`StateDb`, `CodeDb`, `ReceiptsDb`, `BlocksDb`, etc.).
- `nethermind/src/Nethermind/Nethermind.Db/DbNames.cs`
- Canonical logical names: `state`, `storage`, `code`, `headers`, `receipts`, `blobTransactions`, etc.
- `nethermind/src/Nethermind/Nethermind.Db/DbProvider.cs`
- DI-based keyed resolver for DB instances.
- `nethermind/src/Nethermind/Nethermind.Db/MemDb.cs`
- In-memory full DB implementation with read/write counters and batched writes.
- `nethermind/src/Nethermind/Nethermind.Db/MemColumnsDb.cs`
- In-memory columns DB implementation keyed by enum columns.
- `nethermind/src/Nethermind/Nethermind.Db/InMemoryWriteBatch.cs`
- Batch emulation for stores that do not have native batch support.
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDb.cs`
- Read-only wrapper with optional in-memory write overlay.
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDbProvider.cs`
- Provider wrapper that memoizes read-only DB handles.
- `nethermind/src/Nethermind/Nethermind.Db/CompressingDb.cs`
- Wrapper example for transparent value transformation in DB boundary.

## Voltaire Zig APIs (Relevant to DB Consumer Shape)

Listed from: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`

- `/Users/williamcory/voltaire/packages/voltaire-zig/src/state-manager/root.zig`
- Re-exports state APIs used by an execution client: `StateManager`, `JournaledState`, `ForkBackend`, cache types.
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/state-manager/StateManager.zig`
- State-facing contract includes `getBalance`, `getNonce`, `getCode`, `getStorage`, and matching setters plus checkpoint/snapshot.
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/state-manager/StateCache.zig`
- Account/storage/code cache structures with checkpoint/revert/commit semantics.
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/BlockStore.zig`
- Local block persistence abstraction (hash map store + canonical chain mapping).
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/Blockchain.zig`
- Orchestrates local store plus optional remote cache; clear read/write flow separation.
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/root.zig`
- Primitive exports consumed by DB clients (`Address`, `Hash`, `Hex`, `Block`, `Transaction`, etc.).
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/State/state.zig`
- State model primitives.
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/Storage/storage.zig`
- Storage model primitives.

## Existing Guillotine-mini Host Interface

Read from: `src/host.zig`

`HostInterface` methods:
- `getBalance` / `setBalance`
- `getCode` / `setCode`
- `getStorage` / `setStorage`
- `getNonce` / `setNonce`

DB abstraction implication:
- Backends must efficiently support account-level and storage-slot reads/writes used by host/state layers.

## Ethereum Tests Directories (Fixture Paths)

Listed from: `ethereum-tests/`

- `ethereum-tests/BasicTests/`
- `ethereum-tests/BlockchainTests/`
- `ethereum-tests/TrieTests/`
- `ethereum-tests/TransactionTests/`
- `ethereum-tests/RLPTests/`
- `ethereum-tests/EOFTests/`
- `ethereum-tests/GenesisTests/`
- `ethereum-tests/ABITests/`
- `ethereum-tests/DifficultyTests/`
- `ethereum-tests/KeyStoreTests/`
- `ethereum-tests/PoWTests/`
- `ethereum-tests/src/BlockchainTestsFiller/`
- `ethereum-tests/src/TransactionTestsFiller/`
- `ethereum-tests/src/EOFTestsFiller/`

## Phase-0 DB Implementation Guidance (Effect.ts mapping)

- Mirror Nethermind boundaries in TypeScript services:
- DB core service (`get`, `set`, `delete`, `exists`, `batch`, `iterate`, `flush`).
- Columns service (column-aware DB handles and column batch).
- Provider/factory services for named DB instances.
- Keep logical DB names explicit and stable for later state/trie/blockchain integration.
- Treat read-only overlays and optional wrappers (like compression) as composable decorators around the base DB service.
- Keep this phase infra-only: no fork rules, no EVM behavior, no protocol logic.
