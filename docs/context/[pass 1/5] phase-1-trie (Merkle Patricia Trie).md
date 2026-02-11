# [pass 1/5] phase-1-trie (Merkle Patricia Trie) Context

## Phase Goal (`prd/GUILLOTINE_CLIENT_PLAN.md`)
- Phase: `phase-1-trie`.
- Goal: implement Modified Merkle Patricia Trie for state storage.
- Planned components:
  - `client/trie/node.zig`
  - `client/trie/trie.zig`
  - `client/trie/hash.zig`
- Primary references:
  - `nethermind/src/Nethermind/Nethermind.Trie/`
  - `execution-specs/src/ethereum/forks/*/trie.py`
  - `ethereum-tests/TrieTests/`

## Relevant Specs (`prd/ETHEREUM_SPECS_REFERENCE.md`)
- Yellow Paper Appendix D (MPT + hex-prefix encoding).
- `execution-specs/src/ethereum/forks/frontier/trie.py` (core algorithm reference).
- Phase map mentions `execution-specs/src/ethereum/rlp.py`, but that file does not exist in this checkout. Current trie specs import `ethereum_rlp` (`from ethereum_rlp import Extended, rlp`).
- Trie specs exist per fork:
  - `execution-specs/src/ethereum/forks/frontier/trie.py`
  - `execution-specs/src/ethereum/forks/cancun/trie.py`
  - `execution-specs/src/ethereum/forks/prague/trie.py`
  - plus other intermediate forks.

## execution-specs Trie Behavior (implementation anchors)
Source: `execution-specs/src/ethereum/forks/frontier/trie.py`

- Empty root constant:
  - `EMPTY_TRIE_ROOT = keccak256(rlp.encode(b""))`
  - value: `56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421`
- Internal node types:
  - `LeafNode(rest_of_key, value)`
  - `ExtensionNode(key_segment, subnode)`
  - `BranchNode(subnodes[16], value)`
- Encoding rules (`encode_internal_node`):
  - `None -> b""`
  - leaf/extension path uses compact hex-prefix (`nibble_list_to_compact`)
  - branch encodes `16 children + value`
  - if encoded RLP < 32 bytes: inline node into parent
  - else: store `keccak256(rlp(node))`
- Key/path transforms:
  - `bytes_to_nibble_list` splits bytes into high/low nibble sequence.
  - `nibble_list_to_compact` encodes leaf/extension flag + parity in first nibble.
- Trie preprocessing (`_prepare_trie`):
  - omit default values
  - if `secured`, hash key once via `keccak256(preimage)` before nibble expansion
  - account values require `get_storage_root` and `encode_account`
- Root computation (`root`):
  - build internal tree with `patricialize`
  - encode root node
  - if root node RLP < 32 bytes, hash the RLP to produce canonical root
  - otherwise root node is already a 32-byte hash

Fork notes:
- `execution-specs/src/ethereum/forks/cancun/trie.py` and `execution-specs/src/ethereum/forks/prague/trie.py` preserve the same core MPT algorithm and layer fork-specific node payload unions (e.g., withdrawals, legacy tx types) via delegation to previous fork trie implementations.

## Nethermind References

### Requested listing: `nethermind/src/Nethermind/Nethermind.Db/`
Key files to mirror for DB abstraction boundaries:

- Interfaces/contracts:
  - `IDb.cs`
  - `IDbProvider.cs`
  - `IDbFactory.cs`
  - `IReadOnlyDb.cs`
  - `IReadOnlyDbProvider.cs`
  - `IColumnsDb.cs`
  - `ITunableDb.cs`
  - `IFullDb.cs`
- Providers/config:
  - `DbProvider.cs`
  - `DbNames.cs`
  - `DbExtensions.cs`
  - `DbProviderExtensions.cs`
  - `RocksDbSettings.cs`
- Implementations/adapters:
  - `MemDb.cs`
  - `MemColumnsDb.cs`
  - `ReadOnlyDb.cs`
  - `ReadOnlyColumnsDb.cs`
  - `NullDb.cs`
  - `NullRocksDbFactory.cs`
- Batching/in-memory write path:
  - `InMemoryWriteBatch.cs`
  - `InMemoryColumnBatch.cs`
- Pruning/ops metadata:
  - `PruningConfig.cs`
  - `PruningMode.cs`
  - `FullPruning/`
  - `MetadataDbKeys.cs`

### Trie architecture reference (for phase implementation)
- `nethermind/src/Nethermind/Nethermind.Trie/PatriciaTree.cs`
- `nethermind/src/Nethermind/Nethermind.Trie/TrieNode.cs`
- `nethermind/src/Nethermind/Nethermind.Trie/HexPrefix.cs`
- `nethermind/src/Nethermind/Nethermind.Trie/NodeStorage.cs`
- `nethermind/src/Nethermind/Nethermind.Trie/Pruning/`

Observed structure:
- `PatriciaTree` handles mutation, traversal, and commit.
- `TrieNode` models branch/leaf/extension + sealing/persistence flags.
- `HexPrefix` provides compact nibble-path encoding/decoding helpers.
- `NodeStorage` abstracts storage key scheme (hash-based vs half-path).

## Voltaire Zig APIs
Requested path exists:
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/`

Relevant APIs for trie phase:
- Trie primitives:
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/trie.zig`
  - key exports: `TrieError`, `TrieMask`, `NodeType`, `Node`, `LeafNode`, `ExtensionNode`, `BranchNode`, `Trie`
  - key functions: `keyToNibbles`, `nibblesToKey`, `encodePath`, `decodePath`
- RLP:
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/Rlp/Rlp.zig`
  - key functions: `encode`, `decode`, `encodeBytes`, `encodeLength`, `validate`, `isCanonical`
- Hash/hex utilities:
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/Hash/Hash.zig`
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/Hex/Hex.zig`
  - key hash helper: `crypto.Keccak256.hash`
- Aggregated primitive exports:
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/root.zig`
  - exports `Address`, `Hash`, `Hex`, `Rlp`, etc., as canonical primitive entry points.

## Existing Host Interface (`src/host.zig`)
- `HostInterface` is a minimal vtable wrapper over external state access.
- Methods:
  - `getBalance` / `setBalance`
  - `getCode` / `setCode`
  - `getStorage` / `setStorage`
  - `getNonce` / `setNonce`
- Notes:
  - uses `primitives.Address.Address`
  - storage slots/balances use `u256`
  - no explicit error channel in interface methods

## Test Fixture Paths

### Trie fixtures (primary for phase-1)
- `ethereum-tests/TrieTests/trietest.json`
- `ethereum-tests/TrieTests/trietest_secureTrie.json`
- `ethereum-tests/TrieTests/trieanyorder.json`
- `ethereum-tests/TrieTests/trieanyorder_secureTrie.json`
- `ethereum-tests/TrieTests/hex_encoded_securetrie_test.json`
- `ethereum-tests/TrieTests/trietestnextprev.json`

### Other available ethereum-tests directories (inventory)
- `ethereum-tests/BlockchainTests/`
- `ethereum-tests/RLPTests/`
- `ethereum-tests/TransactionTests/`
- `ethereum-tests/BasicTests/`
- `ethereum-tests/GenesisTests/`
- `ethereum-tests/EOFTests/`
- `ethereum-tests/DifficultyTests/`

## Notes on Reference Availability
- `devp2p/` is present but empty in this workspace snapshot.
- `execution-spec-tests/fixtures/` exists but currently has no files in this snapshot.

## Summary
- Phase-1 trie work should follow `execution-specs` trie algorithm (nibble transforms, compact encoding, inline-vs-hash node encoding, secure key hashing).
- Nethermind module boundaries suggest separating trie structure, node encoding, and storage backend concerns.
- Voltaire already exposes trie/RLP/hash utilities under `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/`, which can guide API shape and test vectors.
- Existing `src/host.zig` confirms the minimal external state surface that later state integration must satisfy.
- Canonical JSON trie fixtures are available under `ethereum-tests/TrieTests/`.
