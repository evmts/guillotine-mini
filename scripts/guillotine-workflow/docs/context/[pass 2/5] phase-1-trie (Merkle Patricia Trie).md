# Context: Phase 1 Trie (Merkle Patricia Trie)

## Goals (from plan)
- Implement the Merkle Patricia Trie for state storage.
- Target components: `client/trie/node.zig`, `client/trie/trie.zig`, `client/trie/hash.zig`.
- Use Nethermind as architecture reference and Voltaire primitives for types/algorithms.
- Tests against `ethereum-tests/TrieTests/`.

## Specs And References

### Execution Specs (authoritative)
- `repo_link/execution-specs/src/ethereum/forks/frontier/trie.py`
  - Defines MPT node encoding (`encode_internal_node`) and hashing rule: RLP-encoded node is hashed with `keccak256` unless serialized length is < 32 bytes, in which case the RLP structure is embedded directly.
  - Empty trie root is `keccak256(RLP(b""))` (state trie empty root).
  - `nibble_list_to_compact` defines hex-prefix encoding: high-nibble flags encode `is_leaf` and odd/even parity.
  - `bytes_to_nibble_list` splits bytes into nibbles (high then low).
  - Secure tries hash keys once (`keccak256(preimage)`) before insertion into the trie.
  - `root` performs `_prepare_trie`, `patricialize`, `encode_internal_node` and applies the <32 byte RLP hashing rule for the final root.

### Spec Map
- `repo_link/prd/ETHEREUM_SPECS_REFERENCE.md`
  - Phase 1 spec pointer: Yellow Paper Appendix D (Trie spec).
  - Phase 1 Python reference: `execution-specs/src/ethereum/forks/frontier/trie.py`.
  - Tests: `ethereum-tests/TrieTests/trietest.json`, `ethereum-tests/TrieTests/trieanyorder.json`, `ethereum-tests/TrieTests/hex_encoded_securetrie_test.json`.

## Nethermind Reference (Db listing per step)
- `repo_link/nethermind/src/Nethermind/Nethermind.Db/`
  - Key files present: `IDb.cs`, `IColumnsDb.cs`, `MemDb.cs`, `RocksDbSettings.cs`, `DbProvider.cs`, `PruningConfig.cs`, `ReadOnlyDb.cs`, `Metrics.cs`.
  - Note: Phase 1 trie architecture reference is under `nethermind/src/Nethermind/Nethermind.Trie/` (not listed here; use when implementing).

## Voltaire Primitives (must use)
- `voltaire/packages/voltaire-zig/src/primitives/trie.zig`
  - Provides MPT implementation, nibble helpers, node types, hashing, and error types (e.g., `TrieError`).
- `voltaire/packages/voltaire-zig/src/primitives/Hash/`, `Bytes/`, `Bytes32/`, `Rlp/`
  - Use Voltaire `Hash`, `Bytes`, and `Rlp` types/utilities instead of custom equivalents.
- `voltaire/packages/voltaire-zig/src/crypto/`
  - Use Voltaire keccak primitives for trie hashing.

## Existing Zig Files
- `repo_link/src/host.zig`
  - Defines `HostInterface` vtable for EVM state access (balances, storage, code, nonce). Relevant for later state integration and trie-backed host implementations.

## Test Fixtures
- `repo_link/ethereum-tests/TrieTests/`
  - `trietest.json`
  - `trieanyorder.json`
  - `hex_encoded_securetrie_test.json`

## Summary
This pass collected the phase-1 trie goals, the authoritative execution-specs trie reference (frontier), the required ethereum-tests fixtures, and the available Voltaire primitives, especially `primitives/trie.zig` which already implements MPT behavior and should be reused. Host interface context was noted for later world-state integration. Nethermind Db files were listed as required; trie architecture reference remains under `Nethermind.Trie` for future implementation.
