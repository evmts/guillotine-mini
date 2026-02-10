# [pass 2/5] phase-1-trie (Merkle Patricia Trie) - Context

## Phase Goal (from PRD)
Source: `prd/GUILLOTINE_CLIENT_PLAN.md`

- Phase 1 goal is to implement a Modified Merkle Patricia Trie (MPT) for state storage.
- Planned components:
  - `client/trie/node.zig` (node types: leaf, extension, branch)
  - `client/trie/trie.zig` (trie operations)
  - `client/trie/hash.zig` (RLP + keccak256 hashing rules)
- Architectural guidance:
  - Structure inspired by Nethermind (`nethermind/src/Nethermind/Nethermind.Trie/`)
  - Spec behavior aligned with `execution-specs` trie implementation
  - Trie fixtures from `ethereum-tests/TrieTests/`

## Ethereum Spec References (read first)
Source: `prd/ETHEREUM_SPECS_REFERENCE.md`

### Primary execution spec files
- `execution-specs/src/ethereum/forks/frontier/trie.py`
  - Defines canonical trie node types (`LeafNode`, `ExtensionNode`, `BranchNode`), compact-hex encoding, nibble handling, recursive patricia composition, and root derivation.
  - Key functions to mirror semantically: `encode_internal_node`, `nibble_list_to_compact`, `bytes_to_nibble_list`, `_prepare_trie`, `root`, `patricialize`.
- `execution-specs/src/ethereum/forks/prague/trie.py`
  - Maintains the same trie core algorithm and extends node typing for newer fork objects (eg withdrawals/typed tx variants via fork chaining).
  - Useful to confirm behavior continuity across hardforks.
- `execution-specs/src/ethereum/forks/*/trie.py`
  - Trie implementation exists per fork; phase implementation should preserve fork-agnostic MPT behavior.

### Important trie constants/rules
- `EMPTY_TRIE_ROOT` value in trie spec:
  - `56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421`
- Inline-vs-hash rule for internal nodes:
  - RLP-encoded node `< 32` bytes is inlined.
  - Otherwise store/reference `keccak256(rlp(node))`.

### Note on RLP reference path in PRD
- `prd/ETHEREUM_SPECS_REFERENCE.md` points to `execution-specs/src/ethereum/rlp.py`, but that file does not exist in this checkout.
- Trie spec imports RLP from `ethereum_rlp` package (`from ethereum_rlp import ...`), so canonical behavior is still defined by trie.py + Ethereum RLP rules.

### EIPs relevant to phase-1 trie behavior/surface
- `EIPs/EIPS/eip-161.md` - state trie clearing semantics (empty account deletion and state-root implications).
- `EIPs/EIPS/eip-1186.md` - `eth_getProof` account/storage proof format; useful for proof API compatibility.
- `EIPs/EIPS/eip-2929.md` and `EIPs/EIPS/eip-2930.md` - not trie-structure specs, but important for state-access/proof/witness context and future integration.

### devp2p references (adjacent, not core for trie write path)
- `devp2p/caps/snap.md`
  - Defines account/storage range proofs and trie-node-by-path retrieval used in state sync.
  - Important for future proof-serving and trie-node retrieval boundaries.

## Nethermind References

### Required listing reviewed
Directory listed: `nethermind/src/Nethermind/Nethermind.Db/`

Key files to mirror conceptually in Effect service boundaries:
- `nethermind/src/Nethermind/Nethermind.Db/IDb.cs`
  - Core key-value interface + metadata/flush semantics.
- `nethermind/src/Nethermind/Nethermind.Db/IDbProvider.cs`
  - Named DB provider abstraction for State/Code/Headers/etc.
- `nethermind/src/Nethermind/Nethermind.Db/IColumnsDb.cs`
  - Column-family abstraction + batched writes/snapshots.
- `nethermind/src/Nethermind/Nethermind.Db/DbNames.cs`
  - Canonical DB namespace names (`state`, `code`, `receipts`, etc.).
- `nethermind/src/Nethermind/Nethermind.Db/MemDb.cs`
  - In-memory implementation used for testing/reference behavior.
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDb.cs`
  - Read-only overlay with optional in-memory write layer.
- `nethermind/src/Nethermind/Nethermind.Db/PruningConfig.cs`, `IPruningConfig.cs`, `FullPruning/`
  - Pruning mode/config shape for later trie lifecycle work.

### Trie architecture companion (phase-specific)
Directory listed: `nethermind/src/Nethermind/Nethermind.Trie/`

Key structure files:
- `PatriciaTree.cs`, `PatriciaTree.BulkSet.cs`
- `TrieNode.cs`, `TrieNode.Decoder.cs`, `TrieNode.Visitor.cs`, `TrieNodeFactory.cs`
- `HexPrefix.cs`, `Nibbles.cs`, `NibbleExtensions.cs`
- `NodeStorage.cs`, `CachedTrieStore.cs`, `RawTrieStore.cs`
- `MissingTrieNodeException.cs`

## Voltaire Zig APIs (relevant for primitive parity)
Directory listed: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`

### Core primitives export surface
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/root.zig`
  - Exports core branded types (`Address`, `Hash`, `Hex`, `StateRoot`, etc.), plus `Rlp`, `StateProof`, and `trie` module.

### Trie module
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/trie.zig`
  - Node/path helpers: `keyToNibbles`, `nibblesToKey`, `encodePath`, `decodePath`
  - Node model: `NodeType`, `Node`, `LeafNode`, `ExtensionNode`, `BranchNode`
  - Trie API: `Trie.init`, `Trie.put`, `Trie.get`, `Trie.delete`, `Trie.root_hash`, `Trie.clear`

### RLP module
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/Rlp/Rlp.zig`
  - `encode`, `decode`, `encodeBytes`, `encodeLength`, `validate`, `isCanonical`

### Proof model
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/StateProof/state_proof.zig`
  - EIP-1186 style account proof type and verification helpers.

## Existing Guillotine-mini EVM Host Interface
File read: `src/host.zig`

- `HostInterface` defines minimal external state vtable operations:
  - `getBalance` / `setBalance`
  - `getCode` / `setCode`
  - `getStorage` / `setStorage`
  - `getNonce` / `setNonce`
- Note in file: nested/internal calls are handled directly in EVM (`inner_call`), not through this host interface.
- This implies trie/state services should focus on canonical state access semantics rather than call orchestration.

## Test Fixture Paths

### Ethereum trie fixtures
- `ethereum-tests/TrieTests/trietest.json`
- `ethereum-tests/TrieTests/trietest_secureTrie.json`
- `ethereum-tests/TrieTests/trieanyorder.json`
- `ethereum-tests/TrieTests/trieanyorder_secureTrie.json`
- `ethereum-tests/TrieTests/hex_encoded_securetrie_test.json`
- `ethereum-tests/TrieTests/trietestnextprev.json`

### Broader fixture directories (for later integration)
- `ethereum-tests/BlockchainTests/`
- `ethereum-tests/GeneralStateTests/` (not present in this checkout listing; confirm submodule sync if needed)
- `execution-spec-tests/fixtures/` (currently empty in this checkout)

## Implementation Notes for next step
- Implement MPT semantics strictly from `execution-specs` trie behavior (nibble encoding, branch/extension/leaf construction, short-node inline rule, empty trie root).
- Keep module boundaries close to Nethermind Trie/Db split while writing idiomatic Effect services.
- Use Voltaire primitives and RLP/Hash helpers as canonical primitive layer.
