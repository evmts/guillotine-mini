# [pass 1/5] phase-1-trie (Merkle Patricia Trie) — Context

This file collects the exact paths and spec references needed to implement Phase 1 (Merkle Patricia Trie) while strictly:
- Using Voltaire primitives (no custom types duplicating Voltaire)
- Following Nethermind’s structure as architectural guidance only
- Preserving our existing EVM design and comptime DI patterns

## Phase Goal (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Implement the Merkle Patricia Trie for state storage.
- Key components to create in our client (wrappers/adapters around Voltaire primitives):
  - `client/trie/node.zig` — node wrappers if/only-if required to adapt to storage
  - `client/trie/trie.zig` — integration façade over Voltaire `primitives.Trie`
  - `client/trie/hash.zig` — adapters that call `primitives.Rlp.Rlp` + `primitives.crypto.Keccak256`
- References: Nethermind Trie, Execution-specs Trie, Voltaire `primitives/trie.zig`.
- Test fixtures: `ethereum-tests/TrieTests/`.

## Spec References (authoritative first)
- execution-specs — reference MPT implementations per fork:
  - execution-specs/src/ethereum/forks/frontier/trie.py
  - execution-specs/src/ethereum/forks/homestead/trie.py
  - execution-specs/src/ethereum/forks/tangerine_whistle/trie.py
  - execution-specs/src/ethereum/forks/spurious_dragon/trie.py
  - execution-specs/src/ethereum/forks/byzantium/trie.py
  - execution-specs/src/ethereum/forks/constantinople/trie.py
  - execution-specs/src/ethereum/forks/istanbul/trie.py
  - execution-specs/src/ethereum/forks/berlin/trie.py
  - execution-specs/src/ethereum/forks/london/trie.py
  - execution-specs/src/ethereum/forks/arrow_glacier/trie.py
  - execution-specs/src/ethereum/forks/gray_glacier/trie.py
  - execution-specs/src/ethereum/forks/paris/trie.py
  - execution-specs/src/ethereum/forks/shanghai/trie.py
  - execution-specs/src/ethereum/forks/cancun/trie.py
  - execution-specs/src/ethereum/forks/prague/trie.py
  - execution-specs/src/ethereum/forks/muir_glacier/trie.py
  - execution-specs/src/ethereum/forks/osaka/trie.py
- RLP reference used by execution-specs: `ethereum_rlp` (we will use Voltaire `primitives.Rlp.Rlp`).
- Yellow Paper: Appendix D (Modified Merkle Patricia Trie).

## Nethermind Reference (architecture only)
- nethermind/src/Nethermind/Nethermind.Db/
  - Core abstractions: `IDb.cs`, `IColumnsDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs`, `IDbFactory.cs`, `IDbProvider.cs`, `IReadOnlyDbProvider.cs`, `ITunableDb.cs`
  - Implementations/utilities: `MemDb.cs`, `MemColumnsDb.cs`, `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `DbProvider.cs`, `DbProviderExtensions.cs`, `DbExtensions.cs`, `CompressingDb.cs`, `RocksDbSettings.cs`, `NullDb.cs`, `NullRocksDbFactory.cs`, `RocksDbMergeEnumerator.cs`, `Metrics.cs`
  - Pruning: `PruningMode.cs`, `PruningConfig.cs`, `FullPruning/`*, `FullPruningCompletionBehavior.cs`, `FullPruningTrigger.cs`
  - Columns/keys: `BlobTxsColumns.cs`, `ReceiptsColumns.cs`, `MetadataDbKeys.cs`
  - Blooms: `Blooms/`* (file store + readers)
- Additional trie guidance (not required by this step, but relevant next):
  - nethermind/src/Nethermind/Nethermind.Trie/
    - Core: `PatriciaTree.cs`, `TrieNode.cs`, `TrieNode.Decoder.cs`, `TrieNode.Visitor.cs`
    - Utilities: `HexPrefix.cs`, `NibbleExtensions.cs`, `Nibbles.cs`, `NodeData.cs`, `TreeDumper.cs`, `RangeQueryVisitor.cs`
    - Storage: `NodeStorage.cs`, `RawTrieStore.cs`, `CachedTrieStore.cs`, `PreCachedTrieStore.cs`, `NodeStorageCache.cs`, `TrieStoreWithReadFlags.cs`, `TrieNodeResolverWithReadFlags.cs`, `INodeStorage.cs`, `INodeStorageFactory.cs`
    - Pruning/Stats: `Pruning/`*, `TrieStats*`

## Voltaire Primitives and APIs to use (no custom duplicates)
- /Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/trie.zig
  - Exposed via `const primitives = @import("voltaire");`
  - Types: `primitives.Trie` (with `put`, `get`, `delete`, `root_hash`), `Node`, `LeafNode`, `ExtensionNode`, `BranchNode`
  - Helpers: `encodePath`, `decodePath`, `keyToNibbles`, `nibblesToKey`
  - Hashing: `hash_node` uses `primitives.Rlp.Rlp` + `primitives.crypto.Keccak256`
- /Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/Rlp/Rlp.zig → `primitives.Rlp.Rlp`
- /Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/Hash/Hash.zig → `primitives.Hash.Hash`
- /Users/williamcory/voltaire/packages/voltaire-zig/src/crypto/root.zig → `primitives.crypto.Keccak256`
- Constants: `primitives.EMPTY_TRIE_ROOT` (from `primitives.State`)

## Host / Integration Surfaces (existing in this repo)
- src/host.zig — `HostInterface` abstraction used by EVM. Phase 1 does not modify EVM; the trie integrates with the state layer later (Phase 2), but storage roots and proofs must match spec now.

## Test Fixtures (local paths)
- ethereum-tests/TrieTests/trietest.json
- ethereum-tests/TrieTests/trieanyorder.json
- ethereum-tests/TrieTests/trietest_secureTrie.json
- ethereum-tests/TrieTests/trieanyorder_secureTrie.json
- ethereum-tests/TrieTests/hex_encoded_securetrie_test.json
- ethereum-tests/TrieTests/trietestnextprev.json

## Notes / Guardrails
- Always use Voltaire primitives (`primitives.Trie`, `primitives.Rlp.Rlp`, `primitives.crypto.Keccak256`, `primitives.Hash.Hash`).
- No silent errors; propagate `!` errors and test every public function.
- Follow Nethermind’s separation of concerns: storage backend vs trie logic vs hashing/encoding.
- Performance: avoid unnecessary allocations; reuse buffers; leverage Voltaire’s RLP and Keccak.
- Security: ensure path encoding/decoding and node hashing match spec; verify against `TrieTests` fixtures.

