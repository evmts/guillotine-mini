# [pass 1/5] phase-0-db (DB Abstraction Layer)

## Goal
Create a database abstraction layer for persistent storage.

## Plan References
- `repo_link/prd/GUILLOTINE_CLIENT_PLAN.md`: Phase 0 goals and key components (adapter, RocksDB, memory).
- `repo_link/prd/ETHEREUM_SPECS_REFERENCE.md`: Phase 0 has no external specs; unit tests only.

## Nethermind Reference (DB Architecture)
Source directory: `repo_link/nethermind/src/Nethermind/Nethermind.Db/`

Key files (interfaces + patterns to mirror in Zig):
- `repo_link/nethermind/src/Nethermind/Nethermind.Db/IDb.cs`: core DB interface.
- `repo_link/nethermind/src/Nethermind/Nethermind.Db/IReadOnlyDb.cs`: read-only API separation.
- `repo_link/nethermind/src/Nethermind/Nethermind.Db/IColumnsDb.cs`: column-family layout.
- `repo_link/nethermind/src/Nethermind/Nethermind.Db/ITunableDb.cs`: configuration hooks.
- `repo_link/nethermind/src/Nethermind/Nethermind.Db/DbProvider.cs`: DB provider orchestration.
- `repo_link/nethermind/src/Nethermind/Nethermind.Db/DbProviderExtensions.cs`: provider helpers.
- `repo_link/nethermind/src/Nethermind/Nethermind.Db/MemDb.cs`: in-memory DB reference.
- `repo_link/nethermind/src/Nethermind/Nethermind.Db/MemColumnsDb.cs`: in-memory columns.
- `repo_link/nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDb.cs`: read-only wrapper.
- `repo_link/nethermind/src/Nethermind/Nethermind.Db/RocksDbSettings.cs`: RocksDB config knobs.

## Voltaire Primitives (Types to Reuse)
Base path: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`

Likely primitives to use for DB keys/values and hashes (avoid custom types):
- `.../primitives/Bytes` (byte sequences)
- `.../primitives/Bytes32` (fixed-size keys)
- `.../primitives/Hash` (hash identifiers)
- `.../primitives/Rlp` (encoding helpers if needed later)
- `.../primitives/Address` (account keys if required by DB layer)

No explicit DB abstractions were found in Voltaire source; use primitives only.

## Existing Zig Code (Host Interface)
- `repo_link/src/host.zig`: current HostInterface vtable pattern and comptime DI style.

## Spec Files (Phase 0)
- N/A (internal abstraction). See `repo_link/prd/ETHEREUM_SPECS_REFERENCE.md`.

## Test Fixtures
- Phase 0 uses unit tests only; no ethereum-tests fixtures are required.
- Available fixture roots for later phases: `repo_link/ethereum-tests/` (e.g., TrieTests, GeneralStateTests).

## Notes
- Maintain Nethermind-style module boundaries but implement idiomatic Zig.
- Prefer small, testable units with explicit error handling (no silent catches).
