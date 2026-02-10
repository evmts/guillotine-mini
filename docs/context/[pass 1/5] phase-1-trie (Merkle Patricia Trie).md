# [pass 1/5] phase-1-trie (Merkle Patricia Trie) Context

## Goals (from `prd/GUILLOTINE_CLIENT_PLAN.md`)
- Implement Merkle Patricia Trie for state storage.
- Key components: `client/trie/node.zig`, `client/trie/trie.zig`, `client/trie/hash.zig`.
- References: Nethermind `Nethermind.Trie` module and execution-specs trie behavior.
- Test fixtures: `ethereum-tests/TrieTests/`.

## Spec References (from `prd/ETHEREUM_SPECS_REFERENCE.md`)
- Yellow Paper Appendix D (Trie spec).
- `execution-specs/src/ethereum/forks/frontier/trie.py` (authoritative reference implementation).
- RLP reference in the map is `execution-specs/src/ethereum/rlp.py`, but that file is not present here; execution-specs imports `ethereum_rlp` instead.

## execution-specs Trie Notes (`execution-specs/src/ethereum/forks/frontier/trie.py`)
- `EMPTY_TRIE_ROOT` is `keccak256(rlp.encode(b""))` with fixed value `56e81f...3b421`.
- Node types: `LeafNode(rest_of_key, value)`, `ExtensionNode(key_segment, subnode)`, `BranchNode(subnodes[16], value)`.
- `encode_internal_node`:
  - `None` encodes to `b""`.
  - Leaf and extension nodes use `nibble_list_to_compact` for hex-prefix encoding.
  - Branch nodes are `list(subnodes) + [value]`.
  - If `len(rlp.encode(unencoded)) < 32`, return the unencoded node (embedded in parent); otherwise return `keccak256(rlp)`.
- `nibble_list_to_compact` implements hex-prefix encoding with a flag nibble:
  - Lowest bit encodes odd/even length parity.
  - Second-lowest bit distinguishes leaf vs extension.
- `bytes_to_nibble_list` expands each byte into two nibbles (high, low).
- `_prepare_trie`:
  - Removes default values (stored as omission).
  - For `secured` tries, hashes keys with `keccak256` before nibble expansion.
  - Encodes values; accounts require `get_storage_root` and `encode_account`.
- `root`:
  - `root_node = encode_internal_node(patricialize(...))`.
  - If `len(rlp.encode(root_node)) < 32`, returns `keccak256(rlp.encode(root_node))`.
  - Else returns the 32-byte `root_node` (already a hash).
- `patricialize` recursively builds leaf, extension, and branch nodes based on common prefixes and branch splits.

## Nethermind Reference (Architecture)
- Trie module path: `nethermind/src/Nethermind/Nethermind.Trie/`.
- DB module path (per instructions): `nethermind/src/Nethermind/Nethermind.Db/`.
- Key DB files (from listing):
  - Interfaces: `IDb.cs`, `IReadOnlyDb.cs`, `IColumnsDb.cs`, `IDbFactory.cs`, `IDbProvider.cs`, `IReadOnlyDbProvider.cs`, `ITunableDb.cs`, `IFullDb.cs`.
  - Providers/settings: `DbProvider.cs`, `DbProviderExtensions.cs`, `DbNames.cs`, `RocksDbSettings.cs`.
  - Implementations: `MemDb.cs`, `MemColumnsDb.cs`, `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `NullDb.cs`.
  - Pruning/metadata: `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/`, `MetadataDbKeys.cs`.

## Voltaire Zig APIs (requested path missing)
- Requested path `/Users/williamcory/voltaire/packages/voltaire-zig/src/` does not exist in this environment.
- Zig primitives are available under `/Users/williamcory/voltaire/src/`.
- Trie helpers in `/Users/williamcory/voltaire/src/primitives/trie.zig`:
  - Errors/types: `TrieError`, `TrieMask`, `NodeType`, `Node`, `LeafNode`, `ExtensionNode`, `BranchNode`.
  - Nibble/path helpers: `keyToNibbles`, `nibblesToKey`, `encodePath`, `decodePath`.
  - Trie API: `Trie.init`, `Trie.deinit`, `Trie.root_hash`, `Trie.put`, `Trie.get`, `Trie.delete`, `Trie.clear`.
- Hash/RLP utilities:
  - Hash: `/Users/williamcory/voltaire/src/crypto/hash.zig` and `/Users/williamcory/voltaire/src/primitives/Hash/Hash.zig`.
  - RLP: `/Users/williamcory/voltaire/src/primitives/Rlp/Rlp.zig`.

## Existing Zig Host Interface
- `src/host.zig` defines `HostInterface` with a vtable for `getBalance/setBalance`, `getCode/setCode`, `getStorage/setStorage`, `getNonce/setNonce`.
- Uses `primitives.Address.Address` and `u256` without error returns.

## Test Fixtures (ethereum-tests)
- Root directories include: `TrieTests`, `BlockchainTests`, `RLPTests`, `TransactionTests`, `BasicTests`, `GenesisTests`, `EOFTests`, etc.
- Trie fixture files under `ethereum-tests/TrieTests/`:
  - `hex_encoded_securetrie_test.json`
  - `trieanyorder.json`
  - `trieanyorder_secureTrie.json`
  - `trietest.json`
  - `trietest_secureTrie.json`
  - `trietestnextprev.json`

## Summary
- Phase-1 trie work is anchored on `execution-specs/src/ethereum/forks/frontier/trie.py` plus Yellow Paper Appendix D.
- Nethermind `Nethermind.Trie` is the architecture reference; `Nethermind.Db` lists storage interfaces to mirror.
- The requested `voltaire-zig` path is missing; equivalent Zig trie helpers, RLP, and hash utilities live under `/Users/williamcory/voltaire/src/`.
- Host interface in `src/host.zig` is a minimal state access vtable (no error channel).
- Classic JSON trie fixtures are under `ethereum-tests/TrieTests/`.
