# [Pass 2/5] Phase 1: Merkle Patricia Trie (MPT) - Context

## Goal (from prd/GUILLOTINE_CLIENT_PLAN.md)
Implement the Merkle Patricia Trie for state storage.
Planned modules:
- client/trie/node.zig (node types)
- client/trie/trie.zig (insert/get/delete, root hash)
- client/trie/hash.zig (RLP + keccak256)

## Spec Files Reviewed (execution-specs/, yellowpaper/)

### execution-specs/src/ethereum/forks/frontier/trie.py
Key behaviors to mirror:
- Node types: Leaf (rest_of_key, value), Extension (key_segment, subnode), Branch (16 subnodes + value).
- encode_internal_node: RLP encode; if encoded length < 32 bytes return raw RLP object, else keccak256(RLP).
- EMPTY_TRIE_ROOT = keccak256(RLP(b"")) (empty trie root).
- Hex-prefix encoding via nibble_list_to_compact; bytes_to_nibble_list for key expansion.
- Secured trie: hash keys with keccak256 before nibble conversion.

### execution-specs/src/ethereum_spec_tests/ethereum_test_types/trie.py
Fixture-focused reference for trie encoding:
- FrontierAccount + encode_account (RLP of nonce, balance, storage_root, keccak256(code)).
- encode_internal_node and encode_node mirror frontier/trie.py behavior.
- Uses keccak256 from Crypto.Hash.keccak (fixtures expect spec-correct hashes).

### yellowpaper/Paper.tex (Trie section)
Trie formalism and constraints:
- TRIE(I) = KEC(RLP(c(I,0))) and node-cap rule: inline node if RLP length < 32, otherwise store keccak256 hash.
- Node types and structure: Leaf (HP(...,1)), Extension (HP(...,0)), Branch (16 children + value).
- Hex-prefix encoding (HP) and nibble handling described in the "Trie Database"/"Trie" section.

### RLP reference note
prd/ETHEREUM_SPECS_REFERENCE.md points to execution-specs/src/ethereum/rlp.py, but no such file exists in this repo.
RLP helpers are imported as the external package `ethereum_rlp` in execution-specs.

## Nethermind Architecture References

### nethermind/src/Nethermind/Nethermind.Db/ (requested listing)
Key files seen:
- IDb.cs, IReadOnlyDb.cs, IColumnsDb.cs, IFullDb.cs
- DbProvider.cs, DbProviderExtensions.cs, DbNames.cs
- RocksDbSettings.cs, RocksDbMergeEnumerator.cs
- MemDb.cs, MemDbFactory.cs, MemColumnsDb.cs
- ReadOnlyDb.cs, ReadOnlyColumnsDb.cs, ReadOnlyDbProvider.cs
- PruningConfig.cs, PruningMode.cs, FullPruning/

### nethermind/src/Nethermind/Nethermind.Trie/
Relevant trie structures and utilities:
- PatriciaTree.cs / PatriciaTree.BulkSet.cs (core trie + batch insert)
- TrieNode.cs + TrieNode.Decoder.cs + TrieNode.Visitor.cs (node structure, RLP decode, traversal)
- HexPrefix.cs, Nibbles.cs, NibbleExtensions.cs (hex-prefix/nibble logic)
- NodeStorage.cs + INodeStorage.cs (persistent node storage)
- TrieType.cs (State vs Storage)
- CachedTrieStore.cs / RawTrieStore.cs / TrieStore* (caching + pruning)

## Voltaire Primitives (must use, never reimplement)
Paths under /Users/williamcory/voltaire/packages/voltaire-zig/src:
- primitives/trie.zig
  - TrieMask, Node union, LeafNode, ExtensionNode, BranchNode
  - keyToNibbles, nibblesToKey, encodePath/decodePath (hex-prefix)
  - Trie struct with put/get/delete, in-memory node store
  - hash_node uses Rlp + crypto.Keccak256 (note: currently always hashes; no <32 inline shortcut)
- primitives/Rlp/Rlp.zig (RLP encode/decode utilities)
- crypto/hash.zig (Keccak256.hash)
- primitives/Hash/Hash.zig (Hash type helpers)
- primitives/StateRoot/StateRoot.zig (StateRoot alias for trie roots)
- primitives/AccountState/AccountState.zig (account state type for trie values)

## Existing Zig Files to Integrate With
- src/host.zig
  - HostInterface vtable (get/set balance, code, storage, nonce)
  - Uses Voltaire primitives.Address and u256

## Test Fixtures
- ethereum-tests/TrieTests/
  - trietest.json
  - trieanyorder.json
  - hex_encoded_securetrie_test.json
- ethereum-tests/RLPTests/ (RLP edge cases for encoding behavior)

## Paths Read This Pass
- prd/GUILLOTINE_CLIENT_PLAN.md
- prd/ETHEREUM_SPECS_REFERENCE.md
- execution-specs/src/ethereum/forks/frontier/trie.py
- execution-specs/src/ethereum_spec_tests/ethereum_test_types/trie.py
- yellowpaper/Paper.tex
- src/host.zig
- nethermind/src/Nethermind/Nethermind.Db/
- nethermind/src/Nethermind/Nethermind.Trie/
- /Users/williamcory/voltaire/packages/voltaire-zig/src/
- ethereum-tests/
