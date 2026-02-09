# [pass 1/5] phase-1-trie (Merkle Patricia Trie) Context

## Goals (from `prd/GUILLOTINE_CLIENT_PLAN.md`)
- Implement Merkle Patricia Trie for state storage.
- Key components: `client/trie/node.zig`, `client/trie/trie.zig`, `client/trie/hash.zig`.
- Reference: Nethermind `Nethermind.Trie` module structure + execution-specs trie behavior.
- Test fixtures: `ethereum-tests/TrieTests/`.

## Spec References (from `prd/ETHEREUM_SPECS_REFERENCE.md`)
- Yellow Paper Appendix D (Trie spec).
- `execution-specs/src/ethereum/forks/frontier/trie.py` (authoritative reference implementation).
- RLP reference is via `execution-specs/src/ethereum/rlp.py` in the map, but that file does **not** exist here; execution-specs uses `ethereum_rlp` instead.

## execution-specs Trie Notes (`execution-specs/src/ethereum/forks/frontier/trie.py`)
- `EMPTY_TRIE_ROOT` constant is `keccak256(RLP(b""))` (root for empty trie).
- Node types: `LeafNode`, `ExtensionNode`, `BranchNode` with `encode_internal_node` producing RLP; if RLP-encoded length < 32 bytes, return raw RLP payload; otherwise return `keccak256(rlp)`.
- `nibble_list_to_compact` implements hex-prefix encoding with flag nibble (bit0 parity, bit1 leaf/extension).
- `bytes_to_nibble_list` expands a byte key into nibble list.
- Secure trie path hashing: `_prepare_trie` hashes keys (`keccak256`) before nibble expansion; omits default/empty encodings.
- Root computation uses `encode_internal_node(patricialize(...))` and applies the same <32-byte inline vs hashed behavior.

## Nethermind Reference (Architecture)
- Trie module path: `nethermind/src/Nethermind/Nethermind.Trie/` (Patricia tree, node encoding/decoding, storage boundaries).
- DB module path (per instructions): `nethermind/src/Nethermind/Nethermind.Db/`.
- Key DB files (listing):
  - Interfaces: `IDb.cs`, `IReadOnlyDb.cs`, `IColumnsDb.cs`, `IDbFactory.cs`, `IDbProvider.cs`, `IReadOnlyDbProvider.cs`, `ITunableDb.cs`, `IFullDb.cs`.
  - Providers/settings: `DbProvider.cs`, `DbProviderExtensions.cs`, `DbNames.cs`, `RocksDbSettings.cs`.
  - Implementations: `MemDb.cs`, `MemColumnsDb.cs`, `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `NullDb.cs`.
  - Pruning/metadata: `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/`, `MetadataDbKeys.cs`.

## Voltaire Zig APIs (requested path missing)
- Requested path `/Users/williamcory/voltaire/packages/voltaire-zig/src/` does **not** exist in this environment.
- Zig primitives are available under `/Users/williamcory/voltaire/src/`:
  - Trie utilities: `/Users/williamcory/voltaire/src/primitives/trie.zig` (node types, `Trie`, `TrieMask`, `TrieError`, `keyToNibbles`, `nibblesToKey`, `encodePath`, `decodePath`).
  - RLP: `/Users/williamcory/voltaire/src/primitives/Rlp/Rlp.zig` (RLP encode/decode + errors).
  - Hash types: `/Users/williamcory/voltaire/src/primitives/Hash/Hash.zig` (Hash type, `fromBytes`, `fromHex`, `keccak256`).
  - Roots/types: `/Users/williamcory/voltaire/src/primitives/StateRoot/`, `StorageRoot/`, `MerkleTree/`, `Address/`, `U256/`.
  - Crypto hash utils: `/Users/williamcory/voltaire/src/crypto/hash.zig` (exports `keccak256`, `Hash`, `ZERO_HASH`).

## Existing Zig Host Interface
- `src/host.zig` defines `HostInterface` with a vtable for `getBalance/setBalance`, `getCode/setCode`, `getStorage/setStorage`, `getNonce/setNonce`.
- Uses `primitives.Address.Address` + `u256` types; no error-returning APIs in the interface.

## Test Fixtures (ethereum-tests)
- Root listing includes: `TrieTests`, `BlockchainTests`, `RLPTests`, `TransactionTests`, `BasicTests`, `GenesisTests`, `EOFTests`, etc.
- Trie fixture files under `ethereum-tests/TrieTests/`:
  - `hex_encoded_securetrie_test.json`
  - `trieanyorder.json`
  - `trieanyorder_secureTrie.json`
  - `trietest.json`
  - `trietest_secureTrie.json`
  - `trietestnextprev.json`

## Summary
- Phase-1 trie work is anchored on `execution-specs/src/ethereum/forks/frontier/trie.py` with Yellow Paper Appendix D for spec grounding.
- Nethermind’s trie module guides structure; DB interfaces in `Nethermind.Db` define storage boundaries to mirror.
- The expected `voltaire-zig` path is missing; equivalent Zig primitives live under `/Users/williamcory/voltaire/src/` with trie helpers, RLP, and hash utilities.
- Host interface is a simple vtable in `src/host.zig` and uses `Address`/`u256` primitives.
- Ethereum classic trie fixtures are under `ethereum-tests/TrieTests/` for validation.
