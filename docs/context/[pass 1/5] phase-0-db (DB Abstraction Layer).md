# [pass 1/5] phase-0-db (DB Abstraction Layer) — Context

This document gathers the essential references to implement Phase 0 (DB Abstraction Layer) of the Guillotine client. It collates goals, spec touchpoints, architectural references (Nethermind), Voltaire primitives to use, current Zig host interface notes, and test fixture directories.

## Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Phase: `phase-0-db`
- Goal: Create a database abstraction layer for persistent storage.
- Key components to introduce:
  - `client/db/adapter.zig` — generic DB interface (traits/vtable at comptime)
  - `client/db/rocksdb.zig` — RocksDB backend (production)
  - `client/db/memory.zig` — in-memory backend (testing)
- References: `nethermind/src/Nethermind/Nethermind.Db/`
- Tests: Unit tests only for this phase (no ethereum-tests dependency yet)

## Relevant Specs (from prd/ETHEREUM_SPECS_REFERENCE.md)
- Specs: N/A — internal abstraction (no normative EL spec for DB internals)
- Architectural Reference: Nethermind DB package

## Nethermind reference (nethermind/src/Nethermind/Nethermind.Db/)
Focus on interface boundaries and providers; defer blooms/pruning for later iterations.
- Core interfaces/types:
  - `IDb.cs`, `IReadOnlyDb.cs`, `IColumnsDb.cs`, `IFullDb.cs`, `ITunableDb.cs`
  - `IDbProvider.cs`, `IReadOnlyDbProvider.cs`, `DbProvider.cs`, `DbProviderExtensions.cs`
  - `IDbFactory.cs`, `MemDbFactory.cs`, `NullRocksDbFactory.cs`
- Implementations/utilities:
  - `MemDb.cs`, `MemColumnsDb.cs`, `InMemoryWriteBatch.cs`, `InMemoryColumnBatch.cs`, `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `ReadOnlyDbProvider.cs`
  - `CompressingDb.cs`, `RocksDbMergeEnumerator.cs`, `RocksDbSettings.cs`
  - `DbNames.cs`, `MetadataDbKeys.cs`, `ReceiptsColumns.cs`, `Metrics.cs`, `PruningConfig.cs`, `PruningMode.cs`
- Subpackages (defer):
  - `Blooms/` (bloom storage infra)
  - `FullPruning/` (`FullPruningDb.cs`, `FullPruningInnerDbFactory.cs`, etc.)

Implications for Zig:
- Provide a small, composable `Db` interface with column families and batched writes.
- Provide `DbProvider` abstraction to resolve named column groups.
- Backends: in-memory and RocksDB. Keep merge-operator hooks as extension points.

## Voltaire primitives to use (NEVER create custom types)
- Identifiers/keys/values:
  - `primitives.Address.Address` — account addressing
  - `primitives.Hash.Hash` — content/keys (e.g., block hashes, code hash)
  - `primitives.Bytes.Bytes` — raw value buffers where appropriate
  - `primitives.Rlp.Rlp` — canonical encoding for persisted structures
  - `primitives.Uint.Uint` / builtin `u256` — numeric fields; prefer Voltaire wrappers when branded semantics help
  - `primitives.State.StorageKey`, `primitives.StateRoot` — state-related keys/roots
  - Constants: `primitives.EMPTY_TRIE_ROOT`, `primitives.EMPTY_CODE_HASH`
- Utilities:
  - `primitives.Hex` for hex I/O
  - `primitives.crypto` for `keccak256` (key derivations where needed)

Notes:
- Keys/column names should be compile-time constants; avoid heap allocs on hot paths.
- All serialization goes through Voltaire RLP/Hex; no ad-hoc encoders.

## Existing Zig EVM host surface (src/host.zig)
- File: `src/host.zig`
- Pattern: vtable-based host with `ptr: *anyopaque` + explicit `VTable` — matches comptime DI style used in EVM.
- Methods exposed (external state only; nested calls are internal to EVM):
  - `getBalance(Address) -> u256`, `setBalance(Address, u256)`
  - `getCode(Address) -> []const u8`, `setCode(Address, []const u8)`
  - `getStorage(Address, slot: u256) -> u256`, `setStorage(Address, slot: u256, value: u256)`
  - `getNonce(Address) -> u64`, `setNonce(Address, u64)`
- Implication: DB layer must be capable of backing a future `WorldState` that implements this interface without re-typing primitives.

## ethereum-tests directories (for later phases)
Top-level of interest:
- `ethereum-tests/TrieTests/` — Phase 1
- `ethereum-tests/RLPTests/` (incl. `RandomRLPTests/`) — helpful for encoding correctness
- `ethereum-tests/BlockchainTests/{ValidBlocks,InvalidBlocks}` — Phase 4
- `ethereum-tests/TransactionTests/tt*` — Phase 3/5

Full list snapshot captured via `find` for quick lookup:
- Root: `ethereum-tests/`
- Selected subdirs: `ABITests/`, `BasicTests/`, `BlockchainTests/`, `DifficultyTests/`, `EOFTests/`, `GenesisTests/`, `JSONSchema/`, `KeyStoreTests/`, `LegacyTests/`, `PoWTests/`, `RLPTests/`, `TransactionTests/`, `TrieTests/`, `docs/`, `src/`

## Implementation guidance (phase-0-db)
- Mirror Nethermind structure: `Db`, `ColumnsDb`, `DbProvider`, `ReadOnlyDb`, `MemDb`, `RocksDb`.
- Keep interfaces minimal; expose batches and snapshots as separate tiny units.
- Zero silent error handling: every fallible op returns `!Error` and is handled.
- Performance: avoid allocations in hot paths; reuse buffers; small structs.
- Tests: Public functions must have `test` blocks; mock the DB via in-memory backend.
- Security: no logging of secrets; validate lengths/types on every boundary.

## Paths referenced in this context
- Plan: `prd/GUILLOTINE_CLIENT_PLAN.md`
- Specs map: `prd/ETHEREUM_SPECS_REFERENCE.md`
- Nethermind DB: `nethermind/src/Nethermind/Nethermind.Db/`
- Voltaire primitives root: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- guillotine-mini host: `src/host.zig`

