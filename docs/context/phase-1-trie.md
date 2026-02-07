# Phase 1: Merkle Patricia Trie — Implementation Context

## Goal

Implement the Modified Merkle Patricia Trie (MPT) for Ethereum state storage, matching the authoritative Python execution-specs behavior. The trie provides cryptographic key-value storage used for state roots, storage roots, transaction roots, and receipt roots.

---

## Target Files to Create

| File | Purpose |
|------|---------|
| `client/trie/node.zig` | Trie node types (Leaf, Extension, Branch, Empty) |
| `client/trie/trie.zig` | Main trie: insert, get, delete, root hash computation |
| `client/trie/hash.zig` | RLP encoding of nodes + keccak256 hashing |

---

## Voltaire Primitives to Use (NEVER recreate)

| Module | Import Path | What It Provides |
|--------|-------------|------------------|
| **trie.zig** | `voltaire-zig/src/primitives/trie.zig` | `TrieMask`, `Node` (union), `NodeType`, `LeafNode`, `ExtensionNode`, `BranchNode`, `Trie` struct, `keyToNibbles`, `nibblesToKey`, `encodePath`, `decodePath`, `common_prefix_length` |
| **Rlp.zig** | `voltaire-zig/src/primitives/Rlp/Rlp.zig` | RLP encode/decode (strings, lists, nested structures) |
| **Hash.zig** | `voltaire-zig/src/primitives/Hash/Hash.zig` | `Hash` type (`[32]u8`), `ZERO`, `fromBytes`, `fromHex` |
| **Keccak256** | `voltaire-zig/src/crypto/hash.zig` | `crypto.Keccak256.hash(data, &out, .{})` |
| **Address** | `voltaire-zig/src/primitives/Address/` | 20-byte Ethereum address |
| **AccountState** | `voltaire-zig/src/state-manager/StateCache.zig` | Account state structure (nonce, balance, storageRoot, codeHash) |

### Key Insight: Voltaire Already Has a Full Trie Implementation

The file `voltaire-zig/src/primitives/trie.zig` (1924 lines) already contains:
- **Complete node types**: `LeafNode`, `ExtensionNode`, `BranchNode`, `Node` (tagged union)
- **`TrieMask`**: 16-bit bitmap for efficient branch child tracking
- **Nibble utilities**: `keyToNibbles`, `nibblesToKey`, `encodePath` (hex prefix), `decodePath`
- **Full `Trie` struct** with `put`, `get`, `delete`, `clear`, `root_hash`
- **Node hashing**: RLP encode + Keccak256
- **40+ tests**: Comprehensive unit tests covering all operations

**Implementation strategy**: The client trie module should wrap/use the Voltaire `Trie` as the core engine. What we need to add:
1. **Secure trie** (keys hashed with keccak256 before insertion) — needed for state/storage tries
2. **DB-backed node storage** (instead of in-memory `StringHashMap`) — integrate with Phase 0 DB
3. **Root computation matching the spec's `patricialize()` algorithm** — verify against test fixtures
4. **Account RLP encoding** for state trie values
5. **Proof generation/verification** (Merkle proofs)

---

## Authoritative Spec: Python execution-specs

### Primary File
`execution-specs/src/ethereum/forks/frontier/trie.py` (499 lines)

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
| `encode_internal_node(node)` | RLP encode node; hash if >= 32 bytes |
| `bytes_to_nibble_list(bytes)` | Convert bytes to nibble-list |
| `nibble_list_to_compact(x, is_leaf)` | Hex prefix encoding |
| `common_prefix_length(a, b)` | Find longest common prefix |

### Root Computation Algorithm

```
1. Prepare: encode values, hash keys (if secured), convert keys to nibbles
2. Patricialize (recursive):
   - 0 entries → None (empty)
   - 1 entry → LeafNode(remaining_nibbles, value)
   - Common prefix → ExtensionNode(prefix, encode(patricialize(rest)))
   - Diverge → BranchNode(16 children, optional value)
3. Encode each node to RLP
   - If RLP < 32 bytes → inline (return raw form)
   - If RLP >= 32 bytes → return keccak256(RLP)
4. Final root: keccak256(RLP(root_node)) or Root(root_node) if >= 32 bytes
```

### Critical Constants

```python
EMPTY_TRIE_ROOT = keccak256(rlp.encode(b''))
# = 0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421
```

### Hardfork Evolution

- **Frontier → Paris**: No trie changes (identical implementations)
- **Shanghai**: Adds `Withdrawal` type to `encode_node`
- **Cancun/Prague/Osaka**: Inherit from Shanghai (chain delegation pattern)

---

## Nethermind Architecture Reference

### Directory: `nethermind/src/Nethermind/Nethermind.Trie/`

| File | Purpose | Zig Mapping |
|------|---------|-------------|
| `PatriciaTree.cs` | Main trie class; Set/Get/Commit/RootHash | `client/trie/trie.zig` |
| `TrieNode.cs` | Node with lazy RLP decoding, 16 children, value | `client/trie/node.zig` |
| `TrieNode.Decoder.cs` | RLP decoding of trie nodes | `client/trie/hash.zig` |
| `NodeType.cs` | `enum { Unknown, Branch, Extension, Leaf }` | Already in Voltaire `NodeType` |
| `HexPrefix.cs` | Hex prefix encoding (nibble ↔ compact) | Already in Voltaire `encodePath/decodePath` |
| `Nibbles.cs` | Nibble type (4-bit value) | Already in Voltaire `keyToNibbles` |
| `INodeStorage.cs` | Storage interface: Get/Set by hash+path | DB integration |
| `TrieType.cs` | `enum { State, Storage }` | State vs storage trie distinction |
| `NodeData.cs` | Node data abstraction | Internal node data |
| `TrieNodeFactory.cs` | Node creation factory | Node constructors |
| `ITreeVisitor.cs` | Visitor pattern for trie traversal | Future: proof generation |
| `TrieException.cs` | Trie-specific exceptions | Error types |
| `Pruning/ITrieStore.cs` | Full trie store interface (commit, find cached, load RLP) | DB adapter |
| `Pruning/TrieStore.cs` | Main trie store implementation with caching | DB + cache layer |
| `Pruning/TreePath.cs` | Path tracking through trie traversal | Path management |

### Key Nethermind Design Patterns

1. **Lazy node resolution**: Nodes are decoded from RLP on-demand (not eagerly)
2. **Dirty tracking**: Nodes track modification state for efficient commits
3. **Tree path**: Full nibble path tracked during traversal for DB storage
4. **Scoped stores**: Trie stores can be scoped to specific accounts (state vs storage)
5. **Write batching**: Commits are batched for DB efficiency
6. **Key schemes**: Support both hash-based and half-path-based DB keys

---

## Existing Zig Files to Connect With

| File | Relevance |
|------|-----------|
| `src/host.zig` | `HostInterface` — the EVM's state backend. Phase 3 will connect trie-backed state to this interface |
| `src/evm.zig` | EVM orchestrator — uses `HostInterface` for storage access |
| `build.zig` | Build configuration — will need to add `client/trie/` as a module |

---

## Test Fixtures

### ethereum-tests/TrieTests/

| File | Description | Format |
|------|-------------|--------|
| `trietest.json` | Ordered insert tests (5 tests: emptyValues, branchingTests, jeff, insert-middle-leaf, branch-value-update) | `{name: {in: [[key, value], ...], root: "0x..."}}` |
| `trieanyorder.json` | Unordered insert tests (7 tests: singleItem, dogs, puppy, foo, smallValues, testy, hex) | `{name: {in: {key: value, ...}, root: "0x..."}}` |
| `trietest_secureTrie.json` | Secure trie (keccak256 hashed keys) ordered tests | Same format as trietest.json |
| `trieanyorder_secureTrie.json` | Secure trie unordered tests | Same format as trieanyorder.json |
| `hex_encoded_securetrie_test.json` | Hex-encoded secure trie tests (3 tests: test1, test2, test3) | Hex-encoded keys and values |
| `trietestnextprev.json` | Next/prev traversal tests | Additional traversal testing |

### Test Format: `trietest.json`

```json
{
  "emptyValues": {
    "in": [
      ["do", "verb"],
      ["ether", "wookiedoo"],
      ["horse", "stallion"],
      ["ether", null],       // null = delete
      ["dog", "puppy"]
    ],
    "root": "0x5991bb8c6514148a29db676a14ac506cd2cd5775ace63c30a4fe457715e9ac84"
  }
}
```

### Test Format: `trieanyorder.json`

```json
{
  "singleItem": {
    "in": { "A": "aaaa..." },
    "root": "0xd23786fb4a010da3ce639d66d5e904a11dbc02746d1ce25029e53290cabf28ab"
  }
}
```

### Validation Strategy

1. For each test: insert all key-value pairs (null = delete)
2. Compute root hash
3. Assert root hash matches expected `root` field
4. For `secureTrie` variants: hash keys with keccak256 before insertion

---

## Implementation Priority

### Step 1: Verify Voltaire Trie Produces Correct Root Hashes
- Write a test runner that loads `trietest.json`
- Use existing `Trie` from Voltaire's `trie.zig`
- Compare computed root hashes against expected values
- If mismatches: fix the root hash computation to match the spec's `patricialize()` algorithm

### Step 2: Add Secure Trie Support
- Wrap Voltaire `Trie` with keccak256 key hashing
- Test against `trietest_secureTrie.json` and `trieanyorder_secureTrie.json`

### Step 3: Add Account RLP Encoding
- Encode accounts as: `rlp([nonce, balance, storageRoot, codeHash])`
- This is needed for the state trie in Phase 2

### Step 4: DB-Backed Node Storage
- Replace in-memory `StringHashMap` with DB adapter from Phase 0
- Lazy node loading (load from DB on demand, cache in memory)

### Step 5: Proof Generation
- Generate Merkle proofs for account/storage values
- Verify proofs against known root hashes

---

## Key Differences: Python Spec vs Voltaire Implementation

| Aspect | Python Spec | Voltaire trie.zig |
|--------|-------------|-------------------|
| **Storage** | In-memory dict `_data` | In-memory `StringHashMap(Node)` keyed by hash hex string |
| **Secured mode** | `trie.secured: bool` — keys hashed with keccak256 | Not implemented (raw keys only) |
| **Root computation** | `patricialize()` builds MPT from all key-value pairs at once | Incremental insert/delete updates root hash |
| **Node inlining** | Nodes < 32 bytes RLP are inlined (not hashed) | Always hashes nodes (potential mismatch!) |
| **Default value** | `trie.default` — deleted when value == default | No default concept |
| **Value type** | Generic `V` (Account, Bytes, Transaction, etc.) | `[]u8` (raw bytes) |

### Critical Potential Issue: Node Inlining

The Python spec's `encode_internal_node` returns **unencoded form** (not hash) when RLP is < 32 bytes:
```python
if len(encoded) < 32:
    return unencoded      # Return raw form, not hash
else:
    return keccak256(encoded)  # Hash only large nodes
```

The Voltaire implementation in `hash_node()` **always** returns a keccak256 hash. This will cause root hash mismatches for tries with small nodes. **This must be fixed** to match the spec.

---

## Constants to Match

```
EMPTY_TRIE_ROOT = 0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421
                = keccak256(rlp(b''))
                = keccak256(0x80)
```

---

## Nethermind Key Files for Reference

### Core Trie Files
- `PatriciaTree.cs` — Main Set/Get/Commit logic
- `TrieNode.cs` — Node structure, lazy decode, children management
- `TrieNode.Decoder.cs` — RLP decoding
- `NodeType.cs` — `enum { Unknown, Branch, Extension, Leaf }`
- `HexPrefix.cs` — Hex prefix encoding with caching optimizations

### Storage Interface
- `INodeStorage.cs` — Get/Set by address+path+hash
- `Pruning/ITrieStore.cs` — Full store with commit/find/load
- `Pruning/TrieStore.cs` — Implementation with dirty tracking

### Supporting Files
- `Nibbles.cs` — Nibble type
- `TrieType.cs` — `enum { State, Storage }`
- `TrieNodeFactory.cs` — Node creation
- `TrieException.cs` — Error handling
