# [Pass 1/5] Phase 0: DB Abstraction Layer - Context

## 1) Phase Goal (`prd/GUILLOTINE_CLIENT_PLAN.md`)

`Phase 0: DB Abstraction Layer (phase-0-db)` defines:
- Goal: create a persistent storage abstraction.
- Planned components:
- `client/db/adapter.zig` (generic database interface)
- `client/db/rocksdb.zig` (RocksDB backend)
- `client/db/memory.zig` (in-memory backend for tests)
- Structural reference: `nethermind/src/Nethermind/Nethermind.Db/`
- Voltaire reference in PRD points to `/Users/williamcory/voltaire/packages/voltaire-zig/src/` (path not present locally).

## 2) Relevant Specs (`prd/ETHEREUM_SPECS_REFERENCE.md`)

- Phase 0 has no direct execution-spec normative file dependency.
- Expected tests for this phase: unit tests only.
- Carry-forward references that influence DB shape for later phases:
- `execution-specs/src/ethereum/forks/*/trie.py`
- `execution-specs/src/ethereum/forks/*/state.py`
- `execution-specs/src/ethereum/rlp.py`
- `EIPs/EIPS/eip-4844.md` (blob tx data separation appears in DB column naming, e.g. blob transactions).

## 3) Nethermind DB Inventory (`nethermind/src/Nethermind/Nethermind.Db/`)

Complete directory was listed; key files for Phase 0 interface parity:
- `nethermind/src/Nethermind/Nethermind.Db/IDb.cs`: base key/value API + batching + metadata + read helpers.
- `nethermind/src/Nethermind/Nethermind.Db/IColumnsDb.cs`: column-family abstraction and column write batch/snapshot contracts.
- `nethermind/src/Nethermind/Nethermind.Db/IDbFactory.cs`: backend creation boundary (`CreateDb`, `CreateColumnsDb`).
- `nethermind/src/Nethermind/Nethermind.Db/IDbProvider.cs`: named DB access surface (`StateDb`, `CodeDb`, `ReceiptsDb`, etc).
- `nethermind/src/Nethermind/Nethermind.Db/DbNames.cs`: canonical logical DB names (`state`, `storage`, `code`, `headers`, `blobTransactions`, etc).
- `nethermind/src/Nethermind/Nethermind.Db/DbProvider.cs`: DI/provider resolution pattern for named DB instances.
- `nethermind/src/Nethermind/Nethermind.Db/MemDb.cs`: in-memory implementation with batching-compatible behavior.
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDb.cs`: read-only wrapper with optional in-memory write overlay.
- `nethermind/src/Nethermind/Nethermind.Db/InMemoryWriteBatch.cs`: batch emulation for stores without native batch.
- `nethermind/src/Nethermind/Nethermind.Db/RocksDbSettings.cs`: backend settings object (`DbSettings`).
- `nethermind/src/Nethermind/Nethermind.Db/CompressingDb.cs`: optional wrapper behavior (state value compression extension).
- `nethermind/src/Nethermind/Nethermind.Db/NullRocksDbFactory.cs`: null object backend factory.

Other notable directories for future integration:
- `nethermind/src/Nethermind/Nethermind.Db/Blooms/`
- `nethermind/src/Nethermind/Nethermind.Db/FullPruning/`

## 4) Voltaire APIs (requested path + resolved local sources)

Requested path status:
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/` -> not found locally.

Resolved local source tree:
- `/Users/williamcory/voltaire/src/`

Relevant DB/state APIs identified:
- `/Users/williamcory/voltaire/src/primitives/Db/db.zig`
- Defines shared DB surface compatible with Nethermind concepts:
- `Error`
- `DbName` + `to_string()`
- `ReadFlags`, `WriteFlags`
- `DbMetric`
- `DbValue`, `DbEntry` (explicit release callbacks)
- `DbIterator`, `DbSnapshot`
- `/Users/williamcory/voltaire/src/state-manager/root.zig`
- Re-exports `StateManager`, `JournaledState`, `ForkBackend`, `AccountCache`, `StorageCache`, `ContractCache`.
- `/Users/williamcory/voltaire/src/blockchain/root.zig`
- Re-exports `BlockStore`, `ForkBlockCache`, `Blockchain`.

## 5) Existing Zig EVM Host (`src/host.zig`)

`HostInterface` is a vtable-based bridge with state-facing methods:
- `getBalance` / `setBalance`
- `getCode` / `setCode`
- `getStorage` / `setStorage`
- `getNonce` / `setNonce`

Implication for Phase 0: DB abstractions must support efficient backing for account balance/code/storage/nonce reads and writes used by host/state integration layers.

## 6) Ethereum Tests Fixture Directories (`ethereum-tests/`)

Phase 0 itself is unit-test scoped, but fixture locations were enumerated for later phases:
- `ethereum-tests/TrieTests/`
- `ethereum-tests/RLPTests/`
- `ethereum-tests/TransactionTests/`
- `ethereum-tests/BlockchainTests/`
- `ethereum-tests/EOFTests/`
- `ethereum-tests/BasicTests/`
- `ethereum-tests/GenesisTests/`
- `ethereum-tests/src/BlockchainTestsFiller/`
- `ethereum-tests/src/TransactionTestsFiller/`
- `ethereum-tests/src/EOFTestsFiller/`

## 7) Implementation Guidance Snapshot

- Mirror Nethermind boundaries for DB abstraction:
- core key-value DB interface
- column DB interface
- factory/provider interfaces
- in-memory backend and read-only overlay
- Keep logical DB names stable and explicit (matching `DbNames`/`DbName` mapping).
- Treat this phase as infrastructure: no fork rule logic, but enable future trie/state/blockchain modules to plug in without API churn.
