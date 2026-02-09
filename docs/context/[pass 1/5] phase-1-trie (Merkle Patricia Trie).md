# [pass 1/5] phase-1-trie (Merkle Patricia Trie) Context

## Goals (from `prd/GUILLOTINE_CLIENT_PLAN.md`)

- Implement Merkle Patricia Trie for state storage.
- Key components: trie node types, trie implementation, hashing (RLP + keccak256).
- Reference architecture: Nethermind Trie module; reference behavior: execution-specs trie implementation.
- Test fixtures: `ethereum-tests/TrieTests/`.

## Spec References (Phase 1)

### execution-specs

- `execution-specs/src/ethereum/forks/frontier/trie.py`
  - Defines MPT node types: `LeafNode`, `ExtensionNode`, `BranchNode` and the `Trie` wrapper.
  - `encode_internal_node` RLP-encodes nodes and returns the raw RLP payload if < 32 bytes, otherwise returns `keccak256(rlp)`.
  - `nibble_list_to_compact` and `bytes_to_nibble_list` define hex-prefix encoding rules.
  - `_prepare_trie` maps keys (optionally hashed for secure tries) into nibble lists and encodes values; `root` computes MPT root from prepared nodes.
  - `EMPTY_TRIE_ROOT` constant defines the root hash for an empty trie.
- `execution-specs/src/ethereum/forks/byzantium/trie.py`
  - Same core logic; defers unsupported `encode_node` cases to prior fork implementation.
  - Useful to confirm fork-to-fork stability and fallback behavior.
- RLP reference noted in plan (`execution-specs/src/ethereum/rlp.py`) does not exist here; execution-specs import `ethereum_rlp` instead (see `execution-specs/src/ethereum/forks/byzantium/blocks.py` RLP links).

### Yellow Paper

- Appendix D is referenced in `prd/ETHEREUM_SPECS_REFERENCE.md`, but there is no Yellow Paper copy in `yellowpaper/` (directory is empty). External reference required if needed.

### EIPs

- No specific EIP called out for MPT structure in the plan. Focus on canonical MPT behavior from execution-specs.

## Nethermind Architectural Reference

### Trie module

Path: `nethermind/src/Nethermind/Nethermind.Trie/`

- `PatriciaTree.cs` and `PatriciaTree.BulkSet.cs`: core trie operations.
- `TrieNode.cs`, `TrieNode.Decoder.cs`, `TrieNode.Visitor.cs`: node representation, decoding, traversal.
- `HexPrefix.cs`, `Nibbles.cs`, `NibbleExtensions.cs`: nibble + hex-prefix encoding helpers.
- `NodeStorage.cs`, `NodeStorageCache.cs`, `CachedTrieStore.cs`, `TrieStoreWithReadFlags.cs`: storage and caching boundaries.
- `MissingTrieNodeException.cs`, `TrieException.cs`: error cases to mirror in Effect error channel.

### DB module (storage patterns)

Path: `nethermind/src/Nethermind/Nethermind.Db/`

- `IDb.cs`, `IReadOnlyDb.cs`, `IColumnsDb.cs`: base DB interfaces.
- `DbProvider.cs`, `DbProviderExtensions.cs`, `RocksDbSettings.cs`: DB wiring and options.
- `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `MemDb.cs`: storage variants used by trie stores.

## Voltaire-Effect Primitives and Services

### Primitives (from `/Users/williamcory/voltaire/voltaire-effect/src/primitives/`)

- `Bytes`, `Hex`, `Hash`, `Bytes32`: base byte types and hex conversion.
- `Address`, `StateRoot`, `StorageRoot`, `MerkleTree`: canonical Ethereum primitives for trie roots and hashes.
- `Rlp`: use for RLP encoding/decoding (do not reimplement).
- `U256`, `Uint*`: numeric types used by trie values (accounts, receipts, etc.).

### Services (from `/Users/williamcory/voltaire/voltaire-effect/src/services/`)

- `Provider`, `RawProvider`, `Transport`, `RpcBatch`: external data sources for future phases.
- Keep these in mind for integration layers; not directly needed for phase-1 trie but avoid custom provider types.

## Effect.ts Patterns (from `effect-repo/packages/effect/src/`)

- `Context.ts`, `Layer.ts`: DI via `Context.Tag` + `Layer`.
- `Effect.ts`, `Data.ts`: effectful logic + tagged errors.
- `Schema.ts`: boundary validation for byte inputs and config.
- `Option.ts`, `Either.ts`, `Scope.ts`: common patterns used in existing client-ts code.

## Existing TypeScript Client (client-ts)

- `client-ts/trie/Node.ts`
  - Defines trie node types using `voltaire-effect` primitives.
  - Encoded nodes are `hash` | `raw` | `empty`, and branch subnodes count is 16.
- `client-ts/trie/encoding.ts`
  - Implements nibble encoding and compact hex-prefix encoding using `Effect.gen` + `Schema` validation.
  - Uses `Data.TaggedError` for `NibbleEncodingError`.
- `client-ts/trie/encoding.test.ts`
  - Uses `@effect/vitest` `it.effect()` for Effect-returning tests.
- `client-ts/db/Db.ts`
  - Example of `Context.Tag` service, `Schema` validation at boundaries, and `Effect` error channels.

## Test Fixtures

- `ethereum-tests/TrieTests/`
  - `trietest.json`, `trietest_secureTrie.json`
  - `trieanyorder.json`, `trieanyorder_secureTrie.json`
  - `hex_encoded_securetrie_test.json`
  - `trietestnextprev.json`

## Implementation Notes for Phase-1 Trie

- Keep key hashing (“secure trie”) behavior consistent with execution-specs: hash preimage before nibble encoding.
- Use RLP + keccak rules for node encoding (inline if RLP < 32 bytes, else store hash).
- Reuse `voltaire-effect` primitives (`Bytes`, `Hash`, `Hex`, `Rlp`, `StateRoot`) and avoid custom Ethereum types.
- Mirror Nethermind module boundaries: node encoding/decoding, storage, and trie traversal separate from DB wiring.
