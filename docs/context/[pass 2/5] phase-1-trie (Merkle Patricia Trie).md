# [pass 2/5] Phase 1: Merkle Patricia Trie — Context

## Phase Goal (from PRD)
- Implement the Merkle Patricia Trie for state storage.
- Target components: `client/trie/node.zig`, `client/trie/trie.zig`, `client/trie/hash.zig`.

## Spec References (execution-specs / Yellow Paper)
- `execution-specs/src/ethereum/forks/frontier/trie.py`: authoritative Python trie implementation (patricialize, node encoding, secured trie).
- `execution-specs/src/ethereum/rlp.py`: RLP encoding used by trie node encoding.
- `yellowpaper/Paper.tex`: Appendix “Modified Merkle Patricia Tree” (`\label{app:trie}`) and RLP appendix (`\label{app:rlp}`) for protocol definition.

## Nethermind Architecture Reference
- Directory listing: `nethermind/src/Nethermind/Nethermind.Db/`
  - Key files for DB abstraction patterns: `IDb.cs`, `IReadOnlyDb.cs`, `IColumnsDb.cs`, `IDbFactory.cs`, `DbProvider.cs`, `DbProviderExtensions.cs`, `MemDb.cs`, `MemColumnsDb.cs`, `RocksDbSettings.cs`.
- Trie reference directory (from PRD/spec map): `nethermind/src/Nethermind/Nethermind.Trie/`.

## Voltaire APIs (must use; no custom types)
- Trie primitives: `voltaire/packages/voltaire-zig/src/primitives/trie.zig`.
- RLP: `voltaire/packages/voltaire-zig/src/primitives/Rlp/`.
- Hash: `voltaire/packages/voltaire-zig/src/primitives/Hash/`.
- StateRoot: `voltaire/packages/voltaire-zig/src/primitives/StateRoot/`.
- Address / AccountState (for state trie values): `voltaire/packages/voltaire-zig/src/primitives/Address/`, `voltaire/packages/voltaire-zig/src/primitives/AccountState/`.
- Keccak256: `voltaire/packages/voltaire-zig/src/crypto/hash.zig`.

## Existing Zig References
- `src/host.zig`: defines `HostInterface` (minimal external state access; EVM inner_call does not use this interface for nested calls).

## Test Fixtures
- Directory listing: `ethereum-tests/`
  - Trie fixtures (per spec map):
    - `ethereum-tests/TrieTests/trietest.json`
    - `ethereum-tests/TrieTests/trieanyorder.json`
    - `ethereum-tests/TrieTests/hex_encoded_securetrie_test.json`

## Summary
This pass collects the Phase 1 trie goal, authoritative spec files (execution-specs + Yellow Paper), Nethermind DB abstractions for storage patterns, Voltaire primitives (trie/RLP/hash/state root), the existing Zig host interface, and the canonical Ethereum trie test fixtures.
