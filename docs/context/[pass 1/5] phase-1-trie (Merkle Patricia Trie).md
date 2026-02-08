# [Pass 1/5] Phase 1: Merkle Patricia Trie (MPT) - Context

## Goal (from prd/GUILLOTINE_CLIENT_PLAN.md)
Implement the Merkle Patricia Trie for state storage. Planned modules:
- client/trie/node.zig (node types)
- client/trie/trie.zig (insert/get/delete, root hash)
- client/trie/hash.zig (RLP + keccak256)

## Spec References (from prd/ETHEREUM_SPECS_REFERENCE.md)
Authoritative spec and helpers:
- execution-specs/src/ethereum/forks/frontier/trie.py (reference implementation)
- execution-specs/src/ethereum/rlp.py (RLP encode/decode helpers)
- yellowpaper/Paper.tex (Appendix D - trie spec)

## execution-specs trie.py (frontier)
Key facts confirmed in execution-specs/src/ethereum/forks/frontier/trie.py:
- encode_internal_node returns the unencoded form if RLP length < 32 bytes, else keccak256(RLP)
- EMPTY_TRIE_ROOT is keccak256(RLP(b"")) for an empty trie
- Secure trie hashes keys with keccak256 before nibble conversion

## Nethermind references
Primary architecture reference:
- nethermind/src/Nethermind/Nethermind.Trie/ (PatriciaTree, TrieNode, HexPrefix, Nibbles, NodeStorage, visitors)

Nethermind.Db listing (requested for context):
- IDb.cs, IReadOnlyDb.cs, IColumnsDb.cs, IFullDb.cs
- DbProvider.cs, DbProviderExtensions.cs, DbNames.cs
- RocksDbSettings.cs, RocksDbMergeEnumerator.cs
- MemDb.cs, MemDbFactory.cs, MemColumnsDb.cs
- ReadOnlyDb.cs, ReadOnlyColumnsDb.cs, ReadOnlyDbProvider.cs
- PruningConfig.cs, PruningMode.cs, FullPruning/

## Voltaire primitives to use (never reimplement)
Relevant APIs under /Users/williamcory/voltaire/packages/voltaire-zig/src:
- primitives/trie.zig: Trie, Node, LeafNode, ExtensionNode, BranchNode, TrieMask, keyToNibbles, nibblesToKey, encodePath, decodePath, common_prefix_length
- primitives/Rlp/Rlp.zig: RLP encoding/decoding
- crypto/hash.zig: Keccak256
- primitives/Hash/Hash.zig: Hash type and helpers
- primitives/State/ (State root constants such as EMPTY_TRIE_ROOT)

Voltaire trie implementation notes:
- primitives/trie.zig hash_node always keccak256(RLP(node)) and does not inline nodes < 32 bytes
- This differs from execution-specs encode_internal_node behavior and will affect root hash computation

## Existing Zig files to integrate with
src/host.zig
- Defines HostInterface vtable with get/set balance, code, storage, nonce
- Uses primitives.Address.Address and u256

## Test fixtures
ethereum-tests/TrieTests/
- trietest.json
- trieanyorder.json
- hex_encoded_securetrie_test.json

Additional context from ethereum-tests root:
- ethereum-tests/RLPTests/ (RLP edge cases that may affect trie encoding)

## Paths read in this pass
- prd/GUILLOTINE_CLIENT_PLAN.md
- prd/ETHEREUM_SPECS_REFERENCE.md
- execution-specs/src/ethereum/forks/frontier/trie.py
- src/host.zig
- nethermind/src/Nethermind/Nethermind.Db/
- /Users/williamcory/voltaire/packages/voltaire-zig/src/
- ethereum-tests/
