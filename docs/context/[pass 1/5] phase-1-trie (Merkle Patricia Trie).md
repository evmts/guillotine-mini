# [Pass 1/5] Phase 1: Merkle Patricia Trie — Context (TypeScript + Effect.ts)

## Phase Goal

Implement the Merkle Patricia Trie (MPT) for state storage in the TypeScript execution client, reusing voltaire-effect primitives and following Nethermind’s trie architecture. This layer must provide correct root computation, node encoding, and secure vs non-secure key handling. It will sit on top of the DB abstraction from `client-ts/db/Db.ts`.

**Key components (from `prd/GUILLOTINE_CLIENT_PLAN.md`):**

- `client/trie/node.zig` — Trie node types (leaf, extension, branch)
- `client/trie/trie.zig` — Main trie implementation
- `client/trie/hash.zig` — Trie hashing (RLP + keccak256)

**TypeScript mapping (to implement in this codebase):**

- `client-ts/trie/Node.ts` — Node types (Leaf/Extension/Branch)
- `client-ts/trie/Trie.ts` — Core MPT operations (get/set/root)
- `client-ts/trie/Hash.ts` — RLP + keccak hashing logic
- `client-ts/trie/encoding.ts` — Nibble encoding helpers

---

## Specs Read (Execution Specs)

### `execution-specs/src/ethereum/forks/frontier/trie.py`

The reference implementation for MPT construction and root computation. Key behaviors:

- **Empty trie root:** `keccak256(RLP(b""))` → `0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421`.
- **Secure vs non-secure keys:** When `trie.secured` is true, keys are hashed once with `keccak256` before nibble conversion.
- **Nibble encoding:**
  - `bytes_to_nibble_list(bytes)` produces nibble bytes (`0..15`) for key traversal.
  - `nibble_list_to_compact(nibbles, is_leaf)` encodes the hex-prefix compact format, including leaf/extension flag and parity bit.
- **Node encoding:** `encode_internal_node(node)` RLP-encodes nodes, inlines if serialized length `< 32`, otherwise stores `keccak256(rlp)`.
- **Root computation:** `root(trie, get_storage_root)` calls `patricialize`, then hashes the root node if its RLP is `< 32` bytes.
- **Patricialize algorithm:**
  - Empty map → `None`.
  - Single entry → `LeafNode(rest_of_key, value)`.
  - Shared prefix → `ExtensionNode(prefix, encode_internal_node(child))`.
  - Otherwise → `BranchNode(16 subnodes + optional value)`.

### `execution-specs/src/ethereum/forks/cancun/trie.py`

Latest fork-specific wrapper; core trie logic matches Frontier. Cancun adds `Withdrawal` and `LegacyTransaction` types but delegates most logic to the previous fork. The MPT structure and encoding behavior remain unchanged.

### Notes on missing specs

- `EIPs/` directory is empty in this workspace (submodule not populated).
- `yellowpaper/` directory is empty, so Appendix D is not locally available.

---

## Nethermind Architecture Reference

### Nethermind Trie Module (`nethermind/src/Nethermind/Nethermind.Trie/`)

Key files to mirror structurally in Effect.ts:

- `PatriciaTree.cs`, `PatriciaTree.BulkSet.cs` — Core trie operations
- `TrieNode.cs`, `TrieNode.Decoder.cs`, `TrieNode.Visitor.cs` — Node representation + encoding/decoding
- `HexPrefix.cs`, `Nibbles.cs`, `NibbleExtensions.cs` — Hex-prefix encoding helpers
- `NodeStorage.cs`, `NodeStorageCache.cs`, `TrieStoreWithReadFlags.cs` — Persistence integration
- `MissingTrieNodeException.cs`, `TrieException.cs`, `TrieNodeException.cs` — Error taxonomy
- `TrieStats.cs`, `TrieStatsCollector.cs`, `Metrics.cs` — Stats + metrics
- `TrieType.cs` — State vs storage trie distinctions

### Nethermind DB Module Listing (`nethermind/src/Nethermind/Nethermind.Db/`)

(Required inventory from step 3 — relevant for persistence integration)

- `IDb.cs`, `IFullDb.cs`, `IDbProvider.cs`, `IDbFactory.cs`
- `IColumnsDb.cs`, `ReadOnlyDb.cs`, `ReadOnlyDbProvider.cs`
- `MemDb.cs`, `MemDbFactory.cs`, `NullDb.cs`
- `DbNames.cs`, `DbProvider.cs`, `Metrics.cs`
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`

---

## Voltaire-Effect Primitives (Must Use)

Relevant modules in `/Users/williamcory/voltaire/voltaire-effect/src/primitives/`:

- `Bytes` — `Bytes.Hex` schema, `BytesType` for typed byte arrays.
- `Hex` — `fromBytes`, `toBytes`, and hex parsing utilities.
- `Hash` — `HashType`, `keccak256`, `merkleRoot`, `Hash.Hex` schema.
- `StateRoot` — `StateRootSchema`, `StateRootType` for MPT root output.
- `Rlp` — `encode`, `decode`, `encodeList`, `encodeBytes` (Effect-returning).
- `MerkleTree` — Merkle tree and proof schemas (not MPT-specific but related).
- `StateProof` — schema for MPT proofs (EIP-1186 context).

These primitives must replace any custom Ethereum types in trie code.

---

## Effect.ts Patterns (from `effect-repo/packages/effect/src/`)

Use these modules for idiomatic implementation:

- `Context.ts` + `Layer.ts` — service definition + DI
- `Effect.ts` — `Effect.gen` for sequential logic, no `runPromise` in library code
- `Schema.ts` — boundary validation (e.g., nibble lists, node encodings)
- `Scope.ts` + `Effect.acquireRelease` — resource-lifetime management

---

## Existing TypeScript Client Code (Reference)

### DB Abstraction (already implemented)

- `client-ts/db/Db.ts` — DB service via `Context.Tag`, `Layer.scoped`, `Schema` validation
- `client-ts/db/Db.test.ts` — uses `@effect/vitest` `it.effect` pattern
- `client-ts/db/testUtils.ts` — hex → bytes helpers

Key design patterns to reuse:

- Branded byte types via `Bytes.Hex` schema.
- `Effect.gen` for sequential composition.
- `Layer.scoped` + `Effect.acquireRelease` for resource lifecycle.

---

## Test Fixtures

Ethereum classic trie fixtures:

- `ethereum-tests/TrieTests/trietest.json`
- `ethereum-tests/TrieTests/trieanyorder.json`
- `ethereum-tests/TrieTests/hex_encoded_securetrie_test.json`
- `ethereum-tests/TrieTests/trieanyorder_secureTrie.json`
- `ethereum-tests/TrieTests/trietest_secureTrie.json`
- `ethereum-tests/TrieTests/trietestnextprev.json`

---

## Summary of Immediate Constraints

- Use voltaire-effect primitives for all Ethereum types (no custom `Address`, `Hash`, `Bytes`, etc.).
- Keep MPT logic aligned with execution-specs (`trie.py`) and Nethermind’s trie module.
- Use `Effect.gen` and typed error channels; no `Effect.runPromise` outside app entry points.
- Validate external inputs with `Schema` at boundaries (keys, nibble lists, RLP).
- Persist nodes through the `Db` service (Context.Tag + Layer), not direct maps.
