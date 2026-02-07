# [Pass 1/5] Phase 1: Merkle Patricia Trie — Context Gathering

## Goal

Implement the Modified Merkle Patricia Trie (MPT) for Ethereum state storage, matching the authoritative Python execution-specs behavior. The trie provides cryptographic key-value storage used for state roots, storage roots, transaction roots, and receipt roots.

---

## Target Files to Create

| File | Purpose |
|------|---------|
| `client/trie/node.zig` | Trie node types (Leaf, Extension, Branch, Empty) |
| `client/trie/trie.zig` | Main trie: insert, get, delete, root hash computation |
| `client/trie/hash.zig` | RLP encoding of nodes + keccak256 hashing |
| `client/trie/root.zig` | Module root file |

---

## Voltaire Primitives to Use (NEVER recreate)

| Module | Import Path | What It Provides |
|--------|-------------|------------------|
| **trie.zig** | `voltaire-zig/src/primitives/trie.zig` | `TrieMask`, `Node` (union), `NodeType`, `LeafNode`, `ExtensionNode`, `BranchNode`, `Trie` struct, `keyToNibbles`, `nibblesToKey`, `encodePath`, `decodePath`, `common_prefix_length` |
| **Rlp.zig** | `voltaire-zig/src/primitives/Rlp/Rlp.zig` | RLP encode/decode (strings, lists, nested structures) |
| **Hash.zig** | `voltaire-zig/src/primitives/Hash/Hash.zig` | `Hash` type (`[32]u8`), `ZERO`, `fromBytes`, `fromHex` |
| **Keccak256** | `voltaire-zig/src/crypto/hash.zig` via `crypto` dep | `crypto.Keccak256.hash(data, &out, .{})` |
| **Address** | `voltaire-zig/src/primitives/Address/` | 20-byte Ethereum address |
| **AccountState** | `voltaire-zig/src/primitives/AccountState/AccountState.zig` | `AccountState` struct (nonce, balance, storage_root, code_hash), `EMPTY_CODE_HASH`, `EMPTY_TRIE_ROOT` |
| **State** | `voltaire-zig/src/primitives/State/state.zig` | `EMPTY_CODE_HASH`, `EMPTY_TRIE_ROOT` constants (compiled with keccak256 validation) |
| **JournaledState** | `voltaire-zig/src/state-manager/JournaledState.zig` | Dual-cache state orchestrator with checkpoint/revert/commit |
| **StateCache** | `voltaire-zig/src/state-manager/StateCache.zig` | Account/storage/contract cache |

### Voltaire Trie — Already Implemented (1924 lines)

`voltaire-zig/src/primitives/trie.zig` already contains:
- **Complete node types**: `LeafNode`, `ExtensionNode`, `BranchNode`, `Node` (tagged union with deinit/clone)
- **`TrieMask`**: 16-bit bitmap for efficient branch child tracking (set/unset/is_set/bit_count/is_empty)
- **Nibble utilities**: `keyToNibbles(allocator, key)`, `nibblesToKey(allocator, nibbles)`
- **Hex prefix encoding**: `encodePath(allocator, nibbles, is_leaf)`, `decodePath(allocator, encoded)`
- **Full `Trie` struct** with `put`, `get`, `delete`, `clear`, `root_hash`
- **Node hashing**: `hash_node()` — RLP encode + Keccak256
- **Storage**: In-memory `StringHashMap(Node)` keyed by hex hash string
- **40+ tests**: Comprehensive unit tests + fuzz tests (`trie.fuzz.zig`)

### Critical Issue: Node Inlining Mismatch

The Python spec's `encode_internal_node` returns **unencoded form** (not hash) when RLP is < 32 bytes:
```python
if len(encoded) < 32:
    return unencoded      # Return raw form, not hash
else:
    return keccak256(encoded)  # Hash only large nodes
```

The Voltaire `hash_node()` **always** returns a keccak256 hash regardless of node size. This **will cause root hash mismatches**. The Voltaire `Trie` uses an incremental approach (insert/delete) whereas the spec uses `patricialize()` which builds the entire tree from scratch from a dict. The root hash computation must be fixed.

### Implementation Strategy

The client trie module should either:
1. **Wrap Voltaire `Trie`** and add secure trie + correct root computation on top, OR
2. **Implement a new `patricialize()`-based root computation** that takes a key-value mapping and produces the correct root hash, using Voltaire's node types and nibble utilities as building blocks

Option 2 is recommended because it exactly matches the spec behavior.

---

## Authoritative Spec: Python execution-specs

### Primary File
`execution-specs/src/ethereum/forks/frontier/trie.py` (499 lines)

### All trie.py Locations (identical core algorithm, chain-delegated)
- `execution-specs/src/ethereum/forks/frontier/trie.py` — Base implementation
- `execution-specs/src/ethereum/forks/homestead/trie.py`
- `execution-specs/src/ethereum/forks/tangerine_whistle/trie.py`
- `execution-specs/src/ethereum/forks/spurious_dragon/trie.py`
- `execution-specs/src/ethereum/forks/constantinople/trie.py`
- `execution-specs/src/ethereum/forks/istanbul/trie.py`
- `execution-specs/src/ethereum/forks/paris/trie.py`
- `execution-specs/src/ethereum/forks/gray_glacier/trie.py`
- `execution-specs/src/ethereum/forks/shanghai/trie.py` — Adds Withdrawal type
- `execution-specs/src/ethereum/forks/cancun/trie.py` — Inherits from Shanghai
- `execution-specs/src/ethereum/forks/osaka/trie.py`

### Key Data Structures

```python
@dataclass
class Trie(Generic[K, V]):
    secured: bool       # Whether keys are hashed (keccak256)
    default: V          # Default value for missing keys
    _data: Dict[K, V]   # Underlying key-value storage

@dataclass
class LeafNode:
    rest_of_key: Bytes
    value: Extended

@dataclass
class ExtensionNode:
    key_segment: Bytes
    subnode: Extended   # Hash or inline node

@dataclass
class BranchNode:
    subnodes: Tuple[Extended, ...]  # 16 children
    value: Extended
```

### Key Functions

| Function | Purpose |
|----------|---------|
| `trie_set(trie, key, value)` | Insert/update; deletes if value == default |
| `trie_get(trie, key)` | Retrieve; returns default if missing |
| `root(trie, get_storage_root)` | Compute MPT root hash |
| `_prepare_trie(trie, get_storage_root)` | Encode values, hash keys if secured, convert to nibbles |
| `patricialize(obj, level)` | Recursively build MPT from key-value pairs |
| `encode_internal_node(node)` | RLP encode node; hash if >= 32 bytes, inline if < 32 |
| `encode_node(node, storage_root)` | Encode value (Account, Tx, Receipt, Bytes) for storage |
| `bytes_to_nibble_list(bytes)` | Convert bytes to nibble-list |
| `nibble_list_to_compact(x, is_leaf)` | Hex prefix encoding |
| `common_prefix_length(a, b)` | Find longest common prefix |

### Root Computation Algorithm

```
1. _prepare_trie():
   a. For each key-value pair in trie._data:
      - Encode value via encode_node() (Account → RLP, Bytes → as-is, etc.)
      - If secured: key = keccak256(original_key)
      - Convert key to nibble-list: bytes_to_nibble_list(key)
   b. Return mapping: nibble_key → encoded_value

2. patricialize(obj, level=0):
   a. 0 entries → return None (empty)
   b. 1 entry → LeafNode(key[level:], value)
   c. Find common prefix among all keys at current level
      - If prefix_length > 0 → ExtensionNode(prefix, encode_internal_node(patricialize(rest, level+prefix_length)))
      - If prefix_length == 0 → BranchNode:
        - Split entries into 16 buckets by nibble at current level
        - Entries ending at current level → branch value
        - Each bucket → encode_internal_node(patricialize(bucket, level+1))

3. encode_internal_node(node):
   a. None → b""
   b. LeafNode → (nibble_list_to_compact(rest, True), value)
   c. ExtensionNode → (nibble_list_to_compact(segment, False), subnode)
   d. BranchNode → [child0, ..., child15, value]
   e. RLP encode the above
   f. If len(RLP) < 32 → return unencoded form (INLINE)
   g. If len(RLP) >= 32 → return keccak256(RLP)

4. root():
   root_node = encode_internal_node(patricialize(prepared, 0))
   If len(rlp.encode(root_node)) < 32:
       return keccak256(rlp.encode(root_node))  # Small root still hashed
   else:
       return Root(root_node)  # Already a 32-byte hash
```

### Secure Trie

```python
if trie.secured:
    key = keccak256(preimage)  # Hash key once before trie construction
else:
    key = preimage
```

- **State trie**: `secured=True` (keys are account addresses → keccak256'd)
- **Storage trie**: `secured=True` (keys are storage slots → keccak256'd)
- **Transaction/receipt trie**: `secured=False` (keys are RLP-encoded indices)

---

## Nethermind Architecture Reference

### Directory: `nethermind/src/Nethermind/Nethermind.Trie/`

#### Core Files (42 files)

| File | Purpose | Relevance |
|------|---------|-----------|
| `PatriciaTree.cs` | Main trie: Get, Set, Delete, Commit, UpdateRootHash | Primary reference |
| `PatriciaTree.BulkSet.cs` | Bulk set operations | Performance optimization |
| `TrieNode.cs` | Node wrapper (1510 lines): RLP, children, hash, dirty tracking | Node lifecycle |
| `TrieNode.Decoder.cs` | RLP encoding: EncodeLeaf, EncodeExtension, RlpEncodeBranch | RLP format |
| `TrieNode.Visitor.cs` | Visitor pattern for node traversal | Proof generation |
| `NodeType.cs` | `enum { Unknown, Branch, Extension, Leaf }` | Node types |
| `NodeData.cs` | BranchData (16 refs), ExtensionData (key+child), LeafData (key+value) | Node internals |
| `HexPrefix.cs` | Hex prefix encoding (300 lines, heavily optimized) | Path encoding |
| `Nibbles.cs` | SIMD-optimized byte→nibble conversion (280 lines) | Nibble ops |
| `NibbleExtensions.cs` | Nibble manipulation helpers | Path manipulation |
| `INodeStorage.cs` | Storage interface: Get/Set by hash+path | DB integration |
| `NodeStorage.cs` | Storage implementation | DB operations |
| `TrieType.cs` | `enum { State, Storage }` | Trie type distinction |
| `TrieNodeFactory.cs` | Node creation factory | Node constructors |
| `ITreeVisitor.cs` | Visitor interface: VisitBranch, VisitExtension, VisitLeaf | Traversal |
| `TrieException.cs` | Trie-specific exceptions | Error types |
| `TrieStats.cs` | Statistics collector | Metrics |

#### Pruning Directory (`Pruning/`, 40 files)

| File | Purpose |
|------|---------|
| `ITrieStore.cs` | Full trie store interface (commit, find cached, load RLP) |
| `TrieStore.cs` | Main implementation with caching and dirty node tracking |
| `ITrieNodeResolver.cs` | Interface to resolve nodes by hash |
| `TreePath.cs` | Path tracking through trie traversal |
| `ScopedTrieStore.cs` | Scoped store for specific accounts |
| `OverlayTrieStore.cs` | Overlay store for temporary modifications |
| `ReadOnlyTrieStore.cs` | Read-only wrapper |
| `NullTrieStore.cs` | Null object pattern |

### Key Nethermind Design Patterns

1. **Lazy node resolution**: Nodes loaded as `Unknown` type, decoded from RLP on-demand
2. **Dirty tracking**: Nodes track modification state for efficient batch commits
3. **Post-order stack unwinding**: Set operation uses explicit stack (simulated recursion)
4. **Node lifecycle**: Created(dirty) → Populated → RLP Encoded → Sealed → Committed → Persisted → Pruned
5. **Inlining**: Nodes < 32 bytes RLP → stored inline in parent (not hashed separately)
6. **Concurrent read safety**: Write-in-progress flag prevents parallel mutations
7. **Branch collapse**: After delete, branches with 1 child → converted to Extension

---

## Existing Zig Files to Connect With

| File | Relevance |
|------|-----------|
| `src/host.zig` | `HostInterface` — Phase 3 connects trie-backed state to this vtable |
| `src/evm.zig` | EVM orchestrator — uses `HostInterface` for storage access |
| `client/db/adapter.zig` | DB adapter interface (Phase 0) — trie nodes stored via this |
| `client/db/memory.zig` | In-memory DB backend for testing |
| `client/db/rocksdb.zig` | RocksDB backend for production |
| `build.zig` | Build configuration — needs `client/trie/` module |

---

## Test Fixtures

### ethereum-tests/TrieTests/ (6 files)

| File | Description | Format |
|------|-------------|--------|
| `trietest.json` | Ordered insert tests (5 tests: emptyValues, branchingTests, jeff, insert-middle-leaf, branch-value-update) | `{name: {in: [[key, value], ...], root: "0x..."}}` — null value = delete |
| `trieanyorder.json` | Unordered insert tests (7 tests: singleItem, dogs, puppy, foo, smallValues, testy, hex) | `{name: {in: {key: value, ...}, root: "0x..."}}` |
| `trietest_secureTrie.json` | Secure trie ordered tests (same tests but keys keccak256'd) | Same format as trietest.json |
| `trieanyorder_secureTrie.json` | Secure trie unordered tests | Same format as trieanyorder.json |
| `hex_encoded_securetrie_test.json` | Hex-encoded secure trie tests (3 tests) | Hex-encoded keys and values |
| `trietestnextprev.json` | Next/prev traversal tests | Additional traversal |

### Test Format Examples

**trietest.json** (ordered, sequential inserts):
```json
{
  "emptyValues": {
    "in": [
      ["do", "verb"],
      ["ether", "wookiedoo"],
      ["horse", "stallion"],
      ["ether", null],       // null = delete key "ether"
      ["dog", "puppy"]
    ],
    "root": "0x5991bb8c6514148a29db676a14ac506cd2cd5775ace63c30a4fe457715e9ac84"
  }
}
```

**trieanyorder.json** (unordered, all inserts at once):
```json
{
  "dogs": {
    "in": {
      "doe": "reindeer",
      "dog": "puppy",
      "dogglesworth": "cat"
    },
    "root": "0x8aad789dff2f538bca5d8ea56e8abe10f4c7ba3a5dea95fea4cd6e7c3a1168d3"
  }
}
```

**branchingTests** — important: inserts 25 hex addresses then deletes all of them:
```json
{
  "branchingTests": {
    "in": [ ["0x04110d...", "something"], ..., ["0x04110d...", null], ... ],
    "root": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"
  }
}
```
Root should equal `EMPTY_TRIE_ROOT` since all entries are deleted.

### Validation Strategy

1. Parse JSON test fixtures
2. For each test: apply all operations (insert/delete)
3. Compute root hash using `patricialize()` algorithm
4. Assert root hash matches expected value
5. For `secureTrie` variants: keccak256 hash keys before insertion

---

## Implementation Priority

### Step 1: `patricialize()` Root Hash Computation
- Implement the spec's `patricialize()` algorithm in Zig
- Use Voltaire's nibble utilities (`keyToNibbles`, `encodePath`)
- Use Voltaire's RLP encoder
- Implement `encode_internal_node` with correct < 32 byte inlining
- Test against `trietest.json` and `trieanyorder.json`

### Step 2: Secure Trie
- Add keccak256 key hashing before insertion
- Test against `trietest_secureTrie.json` and `trieanyorder_secureTrie.json`
- Test against `hex_encoded_securetrie_test.json`

### Step 3: Account RLP Encoding
- Encode accounts as: `rlp([nonce, balance, storageRoot, codeHash])`
- Use Voltaire's `AccountState` type
- Needed for state trie in Phase 2

### Step 4: DB-Backed Node Storage
- Integrate with Phase 0 DB adapter
- Replace in-memory node storage with DB-backed storage
- Support lazy node loading

### Step 5: Proof Generation
- Generate Merkle proofs for account/storage values
- Verify proofs against known root hashes

---

## Critical Constants

```
EMPTY_TRIE_ROOT = 0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421
                = keccak256(rlp(b''))
                = keccak256(0x80)

EMPTY_CODE_HASH = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470
                = keccak256(b'')
```

Both are already defined in Voltaire's `State/state.zig` with comptime keccak256 validation.

---

## Key Differences: Python Spec vs Voltaire Implementation

| Aspect | Python Spec | Voltaire trie.zig | What To Do |
|--------|-------------|-------------------|------------|
| **Root computation** | `patricialize()` — builds tree from scratch from dict | Incremental insert/delete updates root | Implement `patricialize()` separately |
| **Node inlining** | < 32 bytes RLP → inline (return raw form) | Always hashes (always 32-byte hash) | **Must fix** — implement inlining |
| **Secured mode** | `trie.secured: bool` — keys keccak256'd | Not implemented | Add secure trie wrapper |
| **Storage** | In-memory dict `_data` | In-memory `StringHashMap(Node)` | OK for now, DB later |
| **Default value** | `trie.default` — deleted when value == default | No default concept | Implement for correctness |
| **Value type** | Generic `V` (Account, Bytes, Tx, etc.) | `[]u8` (raw bytes) | Encode before storing |

---

## Summary of All Referenced Files

### Spec Files
- `execution-specs/src/ethereum/forks/frontier/trie.py` — Primary trie spec (499 lines)
- `execution-specs/src/ethereum/forks/cancun/trie.py` — Latest fork trie
- `execution-specs/src/ethereum/forks/shanghai/trie.py` — Adds Withdrawal support
- `execution-specs/src/ethereum/crypto/hash.py` — keccak256 reference

### Nethermind Files
- `nethermind/src/Nethermind/Nethermind.Trie/PatriciaTree.cs` — Main trie operations
- `nethermind/src/Nethermind/Nethermind.Trie/TrieNode.cs` — Node structure (1510 lines)
- `nethermind/src/Nethermind/Nethermind.Trie/TrieNode.Decoder.cs` — RLP encoding
- `nethermind/src/Nethermind/Nethermind.Trie/NodeType.cs` — Node type enum
- `nethermind/src/Nethermind/Nethermind.Trie/NodeData.cs` — BranchData, ExtensionData, LeafData
- `nethermind/src/Nethermind/Nethermind.Trie/HexPrefix.cs` — Hex prefix encoding
- `nethermind/src/Nethermind/Nethermind.Trie/Nibbles.cs` — Nibble operations
- `nethermind/src/Nethermind/Nethermind.Trie/INodeStorage.cs` — Storage interface
- `nethermind/src/Nethermind/Nethermind.Trie/ITreeVisitor.cs` — Visitor pattern
- `nethermind/src/Nethermind/Nethermind.Trie/Pruning/ITrieStore.cs` — Store interface
- `nethermind/src/Nethermind/Nethermind.Trie/Pruning/TrieStore.cs` — Store impl
- `nethermind/src/Nethermind/Nethermind.Trie/Pruning/TreePath.cs` — Path tracking

### Voltaire APIs
- `voltaire-zig/src/primitives/trie.zig` — Full trie impl (TrieMask, Node types, Trie struct)
- `voltaire-zig/src/primitives/Rlp/Rlp.zig` — RLP encode/decode
- `voltaire-zig/src/primitives/Hash/Hash.zig` — Hash type, fromBytes, fromHex
- `voltaire-zig/src/primitives/State/state.zig` — EMPTY_TRIE_ROOT, EMPTY_CODE_HASH
- `voltaire-zig/src/primitives/AccountState/AccountState.zig` — AccountState struct
- `voltaire-zig/src/primitives/trie.fuzz.zig` — Fuzz tests
- `voltaire-zig/src/crypto/hash.zig` — Keccak256

### Existing Zig Files
- `src/host.zig` — HostInterface (Phase 3 will connect trie state to this)
- `src/evm.zig` — EVM orchestrator
- `client/db/adapter.zig` — DB adapter interface
- `client/db/memory.zig` — In-memory DB backend
- `build.zig` — Build configuration

### Test Fixtures
- `ethereum-tests/TrieTests/trietest.json`
- `ethereum-tests/TrieTests/trieanyorder.json`
- `ethereum-tests/TrieTests/trietest_secureTrie.json`
- `ethereum-tests/TrieTests/trieanyorder_secureTrie.json`
- `ethereum-tests/TrieTests/hex_encoded_securetrie_test.json`
- `ethereum-tests/TrieTests/trietestnextprev.json`
