# [Pass 2/5] Phase 0: DB Abstraction Layer — Implementation Context

## Pass Goal

Build the generic DB interface (`client/db/adapter.zig`) using the same vtable pattern as `src/host.zig`. This pass defines the public DB surface that all backends (memory, RocksDB, null, etc.) must implement and will be consumed by higher layers (trie, state, blockchain). Keep types minimal and reuse Voltaire primitives only.

**Scope (this pass):**
- DB interface vtable (get/put/delete/contains/batch/etc.)
- Error model (no silent suppression)
- Comptime DI hooks consistent with existing EVM code
- Unit tests for every public function

**Specs:** N/A for Phase 0 (internal abstraction only). `prd/ETHEREUM_SPECS_REFERENCE.md` confirms no execution-specs/EIPs/devp2p references for this phase.

---

## Plan Reference (Phase 0)

From `prd/GUILLOTINE_CLIENT_PLAN.md`:
- `client/db/adapter.zig` — Generic database interface
- `client/db/rocksdb.zig` — RocksDB backend implementation
- `client/db/memory.zig` — In-memory backend for testing

---

## Nethermind Architecture Reference (DB Module)

Listing from `nethermind/src/Nethermind/Nethermind.Db/` (key files to mirror structurally):
- `IDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs` — core DB interface surfaces
- `IDbFactory.cs`, `IDbProvider.cs`, `DbProvider.cs` — factory/provider pattern
- `IColumnsDb.cs`, `ReadOnlyColumnsDb.cs` — column-family abstraction
- `MemDb.cs`, `MemDbFactory.cs`, `NullDb.cs`, `ReadOnlyDb.cs` — reference backends
- `DbNames.cs` — canonical database name constants
- `InMemoryWriteBatch.cs`, `InMemoryColumnBatch.cs` — write batch semantics
- `Metrics.cs` — DB metrics collection
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs` — RocksDB config/behavior

Use these as structural guidance, but implement idiomatically in Zig using the guillotine-mini vtable style.

---

## Voltaire Primitives (Use These, No Custom Types)

Voltaire root: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`

Relevant modules likely used by DB consumers (keys/values):
- `primitives/Bytes/Bytes.zig` — byte utilities
- `primitives/Bytes32/Bytes32.zig` — 32-byte fixed-size value
- `primitives/Hash/Hash.zig` — 32-byte hash type
- `primitives/Address/address.zig` — 20-byte address
- `primitives/State/state.zig` — EMPTY_CODE_HASH / EMPTY_TRIE_ROOT
- `primitives/Rlp/Rlp.zig` — encoding/decoding for stored values

No DB-specific primitives found in Voltaire; DB interface should remain raw byte-slice based and let higher layers use Voltaire types.

---

## Existing Guillotine-Mini Pattern to Follow

File: `src/host.zig`
- Uses `ptr: *anyopaque` + `vtable: *const VTable` pattern
- Provides simple forwarding methods with no allocation

This is the canonical interface style to match for the DB adapter.

---

## Test Fixtures (for awareness)

Phase 0 has **no external fixtures**. Unit tests only.

Available ethereum-tests directories (future phases):
- `ethereum-tests/TrieTests`
- `ethereum-tests/GeneralStateTests` (in fixtures archive)
- `ethereum-tests/BlockchainTests`
- `ethereum-tests/TransactionTests`

---

## Implementation Notes for Pass 2

- **Interface shape**: minimal key/value API + batch writer, modeled after Nethermind’s `IKeyValueStore`/`IWriteBatch` but Zig vtable-based.
- **Errors**: propagate all errors; never `catch {}` or silent suppression.
- **Performance**: no per-call allocations in adapter; thin vtable dispatch only.
- **DI**: comptime injection of backend implementation where possible, consistent with existing EVM patterns.
- **Testing**: every public function needs a unit test.

