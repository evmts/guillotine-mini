# Context — [pass 1/5] phase-1-trie (Merkle Patricia Trie)

This document collects the minimum, high-signal references for implementing the Merkle Patricia Trie (MPT) in the Effect.ts execution client, mirroring Nethermind’s structure and using existing Guillotine/Voltaire assets for behavioral truth.

## PRD Goals (from `prd/GUILLOTINE_CLIENT_PLAN.md`)
- Phase: `Phase 1: Merkle Patricia Trie (phase-1-trie)`
- Goal: Implement the Merkle Patricia Trie for state storage.
- Reference pointers called out in PRD:
  - Nethermind: `nethermind/src/Nethermind/Nethermind.Trie/`
  - Test fixtures: `ethereum-tests/TrieTests/`
  - Implementation hints: node types, RLP + keccak256 hashing, nibble/hex‑prefix encoding.

## Spec & Reference Sources
- Execution-specs (authoritative behavior and algorithms):
  - `execution-specs/src/ethereum/forks/shanghai/trie.py`
    - Defines `EMPTY_TRIE_ROOT` (`keccak256(RLP(b""))`), node types (Leaf, Extension, Branch), nibble/hex‑prefix encoding, `patricialize`, and `root()` for secure and non-secure tries.
    - Implements `bytes_to_nibble_list`, `nibble_list_to_compact`, and secure key hashing semantics (hash preimage keys when `secured == True`).
  - Other forks provide the same trie logic (use Shanghai or latest fork for modern reference):
    - `execution-specs/src/ethereum/forks/frontier/trie.py` (baseline), and subsequent forks: berlin, london, shanghai, cancun, etc.
  - Optimized state DB and helpers:
    - `execution-specs/src/ethereum_optimized/state_db.py` (useful for how trie integrates with account/storage roots).
- Yellow Paper: Appendix D (Trie) — conceptual authority for node encoding and hex‑prefix rules.
- RLP and hashing:
  - RLP via `ethereum_rlp` (referenced in execution-specs’ trie files).
  - Keccak256 used for node hashing and secure key hashing.

## Nethermind Structure (mirror module boundaries)
- Trie package: `nethermind/src/Nethermind/Nethermind.Trie/`
  - Key files to mirror conceptually:
    - `PatriciaTree.cs`, `PatriciaTree.BulkSet.cs` — high-level trie operations (set/get/delete/bulk), root computation.
    - `TrieNode.cs`, `TrieNode.Decoder.cs`, `TrieNode.Visitor.cs` — node representation, RLP encode/decode, visitation.
    - `HexPrefix.cs`, `NibbleExtensions.cs`, `Nibbles.cs` — hex‑prefix encoding and nibble handling.
    - `NodeStorage.cs`, `CachedTrieStore.cs`, `RawTrieStore.cs`, `PreCachedTrieStore.cs`, `TrieStoreWithReadFlags.cs` — storage backends/caching.
    - `INodeStorage.cs`, `INodeStorageFactory.cs`, `TrieNodeFactory.cs` — abstractions for persistence/creation.
    - `MissingTrieNodeException.cs`, `TrieException.cs` — error surface.
    - `RangeQueryVisitor.cs`, `TreeDumper.cs`, `TrieStats*.cs` — diagnostics/inspection.
- Database abstractions: `nethermind/src/Nethermind/Nethermind.Db/`
  - Files relevant for how trie persists data:
    - `IDb.cs`, `IColumnsDb.cs`, `IDbProvider.cs`, `DbProvider.cs`, `DbProviderExtensions.cs` — DB provider abstraction.
    - `MemDb.cs`, `MemColumnsDb.cs`, `NullDb.cs` — in‑memory / null implementations.
    - `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs` — example persistent backend configuration.
    - `PruningConfig.cs`, `FullPruning/*`, `FullPruningCompletionBehavior.cs` — pruning strategies affecting trie persistence.

## Voltaire / Guillotine (Zig) — behavioral truth & APIs to wrap
- Root: `/Users/williamcory/voltaire/packages/voltaire-zig/src`
- Relevant modules:
  - `primitives/trie.zig`
    - Node types: `LeafNode`, `ExtensionNode`, `BranchNode`, `Node` union.
    - Nibble/hex‑prefix helpers: `keyToNibbles`, `nibblesToKey`, `encodePath`, `decodePath` with tests.
    - Core operations: insert/get/delete, node storage by hash, `TrieMask`, cloning/deinit discipline.
  - `crypto/keccak256_accel.zig`, `crypto/keccak_asm.zig`, `crypto/keccak256_c.zig` — keccak256 implementations/backends.
  - `state-manager/` — state abstractions that will eventually sit atop the trie (for account/storage tries).
  - `evm/` — not directly used for trie, but establishes how hashes/addresses/bytes are represented.
  - `primitives/Hash`, `primitives/Hex`, `primitives/Address` — canonical primitives used throughout.
- Host interface (this repo) for state access:
  - `src/host.zig` — `HostInterface` with balance/code/storage/nonce getters/setters; guides how the trie-backed state service must expose reads/writes to the EVM.

## Ethereum Test Fixtures (for MPT)
- Root: `ethereum-tests/TrieTests/`
  - `trietest.json`
  - `trietest_secureTrie.json`
  - `trieanyorder.json`
  - `trieanyorder_secureTrie.json`
  - `hex_encoded_securetrie_test.json`
  - `trietestnextprev.json`

## Implementation Notes (Effect.ts target)
- Implement a trie service (Effect Context.Tag + Layer) mirroring Nethermind’s boundaries:
  - Storage abstraction (node storage), nibble/hex‑prefix encoding, node codec (RLP + keccak256), and trie operations.
- Use `voltaire-effect/primitives` for `Address`, `Hash`, `Hex`, etc. Do not introduce custom types.
- Secure vs non-secure tries:
  - Secure trie: hash keys before construction (as per execution-specs’ `_prepare_trie`).
  - Empty trie root must equal `keccak256(RLP(b""))`.
- Encode internal nodes per spec: leaf/extension compact encoding, branch 16 children + optional value; use inlined vs hashed node encoding depending on RLP-encoded length (< 32 bytes → embed; otherwise store hash).
- Tests: Start by replaying `TrieTests` JSON vectors to validate encoding and root computation.

## Quick Path Index
- PRD: `prd/GUILLOTINE_CLIENT_PLAN.md` (phase goal + pointers)
- Specs:
  - `execution-specs/src/ethereum/forks/shanghai/trie.py`
  - Other forks’ `trie.py` (frontier → cancun) for cross-checking
  - `execution-specs/src/ethereum_optimized/state_db.py`
- Nethermind:
  - `nethermind/src/Nethermind/Nethermind.Trie/`
  - `nethermind/src/Nethermind/Nethermind.Db/`
- Voltaire Zig:
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/trie.zig`
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/crypto/keccak256_*.zig`
- Tests:
  - `ethereum-tests/TrieTests/*.json`

