# [pass 1/5] phase-1-trie (Merkle Patricia Trie) Context

## Goals (from `prd/GUILLOTINE_CLIENT_PLAN.md`)

- Implement Merkle Patricia Trie for state storage.
- Key components: `client/trie/node.zig`, `client/trie/trie.zig`, `client/trie/hash.zig`.
- Use Nethermind Trie module as architecture reference.
- Use execution-specs trie implementation as behavioral reference.
- Test fixtures: `ethereum-tests/TrieTests/`.

## Spec References (read)

- `execution-specs/src/ethereum/forks/frontier/trie.py`
- RLP reference in `prd/ETHEREUM_SPECS_REFERENCE.md` points to `execution-specs/src/ethereum/rlp.py`, but that file does not exist in this repo. Execution-specs import `ethereum_rlp` instead.
- Yellow Paper Appendix D is referenced by the plan, but `yellowpaper/` is empty here.

## execution-specs Notes (`execution-specs/src/ethereum/forks/frontier/trie.py`)

- Defines `LeafNode`, `ExtensionNode`, `BranchNode` and `Trie` wrapper.
- `encode_internal_node` RLP-encodes nodes; returns raw (unhashed) RLP payload if encoded length < 32 bytes, otherwise returns `keccak256(rlp)`.
- `nibble_list_to_compact` implements hex-prefix encoding. Flag nibble: bit0 = parity, bit1 = leaf vs extension.
- `bytes_to_nibble_list` expands bytes into high/low nibbles.
- `_prepare_trie` hashes keys for secure tries (`keccak256(preimage)`) before nibble expansion, encodes values, and rejects empty encodings.
- `root` uses `encode_internal_node(patricialize(...))`; if the RLP of the root node is < 32 bytes it hashes the RLP, otherwise it uses the already-hashed node bytes as the root.
- `patricialize` constructs extension/branch/leaf nodes and encodes subnodes via `encode_internal_node`.

## Nethermind Architectural Reference

- Trie module path: `nethermind/src/Nethermind/Nethermind.Trie/`.
- Key files for structure and encoding: `PatriciaTree.cs`, `PatriciaTree.BulkSet.cs`, `TrieNode.cs`, `TrieNode.Decoder.cs`, `TrieNode.Visitor.cs`.
- Nibble/hex-prefix helpers: `HexPrefix.cs`, `Nibbles.cs`, `NibbleExtensions.cs`.
- Storage boundaries: `NodeStorage.cs`, `NodeStorageCache.cs`, `CachedTrieStore.cs`, `TrieStoreWithReadFlags.cs`.
- Errors and stats: `TrieException.cs`, `MissingTrieNodeException.cs`, `TrieStats.cs`.
- DB module path (listed per instructions): `nethermind/src/Nethermind/Nethermind.Db/`.
- DB key files: `IDb.cs`, `IReadOnlyDb.cs`, `IColumnsDb.cs`, `DbProvider.cs`, `DbProviderExtensions.cs`, `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `MemDb.cs`, `RocksDbSettings.cs`.

## Voltaire Zig Primitives

- Expected path `/Users/williamcory/voltaire/packages/voltaire-zig/src/` does not exist on disk in this environment.
- Closest Zig primitives found at `/Users/williamcory/voltaire/src/primitives/`.
- `/Users/williamcory/voltaire/src/primitives/trie.zig` (TrieMask, nibble helpers, base trie utilities).
- `/Users/williamcory/voltaire/src/primitives/Rlp/Rlp.zig` (RLP encoding/decoding).
- `/Users/williamcory/voltaire/src/primitives/Hash`, `/Users/williamcory/voltaire/src/primitives/Bytes`, `/Users/williamcory/voltaire/src/primitives/Bytes32` (hash and byte primitives).
- `/Users/williamcory/voltaire/src/primitives/StateRoot`, `/Users/williamcory/voltaire/src/primitives/StorageRoot`, `/Users/williamcory/voltaire/src/primitives/MerkleTree` (root and trie primitives).
- `/Users/williamcory/voltaire/src/primitives/Address`, `/Users/williamcory/voltaire/src/primitives/U256` (address and numeric types).

## Existing Zig Host Interface

- `src/host.zig` defines `HostInterface` with a vtable for `getBalance/setBalance`, `getCode/setCode`, `getStorage/setStorage`, `getNonce/setNonce`.
- Uses `primitives.Address.Address` and `u256` types; no error-returning APIs, so trie/state callers must not silently suppress errors.

## Test Fixtures

- `ethereum-tests/TrieTests/hex_encoded_securetrie_test.json`
- `ethereum-tests/TrieTests/trieanyorder.json`
- `ethereum-tests/TrieTests/trieanyorder_secureTrie.json`
- `ethereum-tests/TrieTests/trietest.json`
- `ethereum-tests/TrieTests/trietest_secureTrie.json`
- `ethereum-tests/TrieTests/trietestnextprev.json`

## Summary

- Phase-1 trie behavior is anchored on `execution-specs/src/ethereum/forks/frontier/trie.py` and Nethermind’s trie module structure.
- RLP spec file referenced in the plan is missing in this repo; use Voltaire RLP implementation instead.
- Voltaire Zig primitives path in the plan is missing; current primitives live under `/Users/williamcory/voltaire/src/primitives/` and include trie helpers and RLP.
