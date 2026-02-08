# Phase 1: Merkle Patricia Trie — Implementation Context

## Goal

Implement the Modified Merkle Patricia Trie (MPT) for Ethereum state storage, matching the authoritative Python execution-specs behavior. The trie provides cryptographic key-value storage used for state roots, storage roots, transaction roots, and receipt roots.

---

## Current Status

Phase 0 (DB Abstraction) is complete. Phase 1 work has started with root hash computation:

| File | Status | Purpose |
|------|--------|---------|
| `client/trie/root.zig` | Done | Module root, re-exports `hash.trie_root` and `EMPTY_TRIE_ROOT` |
| `client/trie/hash.zig` | Done | `patricialize()` algorithm for root hash computation (spec-compliant, uses `EncodedNode` union for inline vs hashed nodes) |
| `client/trie/bench.zig` | Done | Benchmarks |
| `client/trie/node.zig` | TODO | Trie node types (Leaf, Extension, Branch, Empty) |
| `client/trie/trie.zig` | TODO | Main trie: insert, get, delete, secure trie, DB-backed storage |

---

## Target Files to Create

| File | Purpose |
|------|---------|
| `client/trie/node.zig` | Trie node types (Leaf, Extension, Branch, Empty) |
| `client/trie/trie.zig` | Main trie: insert, get, delete, root hash computation |

---

## Voltaire Primitives to Use (NEVER recreate)

| Module | Import Path | What It Provides |
|--------|-------------|------------------|
| **trie.zig** | `voltaire-zig/src/primitives/trie.zig` | `TrieMask`, `Node` (union), `NodeType`, `LeafNode`, `ExtensionNode`, `BranchNode`, `Trie` struct, `key_to_nibbles`, `nibblesToKey`, `encodePath`, `decodePath`, `common_prefix_length` |
| **Rlp.zig** | `voltaire-zig/src/primitives/Rlp/Rlp.zig` | RLP encode/decode (strings, lists, nested structures) |
| **Hash.zig** | `voltaire-zig/src/primitives/Hash/Hash.zig` | `Hash` type (`[32]u8`), `ZERO`, `fromBytes`, `fromHex` |
| **StateRoot.zig** | `voltaire-zig/src/primitives/StateRoot/StateRoot.zig` | `StateRoot` = `Hash` type alias for trie root hashes |
| **Keccak256** | `voltaire-zig/src/crypto/hash.zig` | `crypto.Keccak256.hash(data, &out, .{})` |
| **Address** | `voltaire-zig/src/primitives/Address/` | 20-byte Ethereum address |
| **AccountState** | `voltaire-zig/src/primitives/AccountState/AccountState.zig` | Account state structure |

### Key Insight: Voltaire Already Has a Full Trie Implementation

The file `voltaire-zig/src/primitives/trie.zig` (1924 lines) already contains:
- **Complete node types**: `LeafNode`, `ExtensionNode`, `BranchNode`, `Node` (tagged union)
- **`TrieMask`**: 16-bit bitmap for efficient branch child tracking
- **Nibble utilities**: `key_to_nibbles`, `nibblesToKey`, `encodePath` (hex prefix), `decodePath`
- **Full `Trie` struct** with `put`, `get`, `delete`, `clear`, `root_hash`
- **Node hashing**: RLP encode + Keccak256 (via `hash_node()` function using Rlp and crypto modules)
- **40+ tests**: Comprehensive unit tests covering all operations
- **Fuzz tests**: `trie.fuzz.zig` for property-based testing

**Implementation strategy**: The client trie module should wrap/use the Voltaire `Trie` as the core engine. What we need to add:
1. **Secure trie** (keys hashed with keccak256 before insertion) — needed for state/storage tries
2. **DB-backed node storage** (instead of in-memory `StringHashMap`) — integrate with Phase 0 DB
3. **Root computation matching the spec's `patricialize()` algorithm** — already done in `client/trie/hash.zig`
4. **Account RLP encoding** for state trie values
5. **Proof generation/verification** (Merkle proofs)

### Existing `client/trie/hash.zig` Design

The already-implemented `hash.zig` uses a spec-faithful approach:
- `EncodedNode` union: `.hash` (32-byte keccak), `.raw` (inline RLP < 32 bytes), `.empty` (b"")
- `RlpItem` tagged union for mixed-mode RLP list encoding (string items vs verbatim substructures)
- Custom `rlp_encode_tagged_list()` because Voltaire's `Rlp.encodeList()` would re-encode verbatim items
- Uses Voltaire's `Rlp.encodeBytes()` for individual items and `Rlp.encodeLength()` for list headers

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
| `encode_internal_node(node)` | RLP encode node; hash if >= 32 bytes, inline if < 32 bytes |
| `encode_node(node, storage_root)` | Encode Account/Transaction/Receipt/Bytes for trie storage |
| `bytes_to_nibble_list(bytes)` | Convert bytes to nibble-list |
| `nibble_list_to_compact(x, is_leaf)` | Hex prefix encoding |
| `common_prefix_length(a, b)` | Find longest common prefix |

### Root Computation Algorithm

```
1. Prepare: encode values, hash keys (if secured), convert keys to nibbles
2. Patricialize (recursive):
   - 0 entries -> None (empty)
   - 1 entry -> LeafNode(remaining_nibbles, value)
   - Common prefix -> ExtensionNode(prefix, encode(patricialize(rest)))
   - Diverge -> BranchNode(16 children, optional value)
3. Encode each node to RLP
   - If RLP < 32 bytes -> inline (return raw form, NOT hash)
   - If RLP >= 32 bytes -> return keccak256(RLP)
4. Final root: keccak256(RLP(root_node)) or Root(root_node) if >= 32 bytes
```

### Critical Constants

```python
EMPTY_TRIE_ROOT = keccak256(rlp.encode(b''))
# = 0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421
```

### Hardfork Evolution

- **Frontier -> Paris**: No trie changes (identical implementations)
- **Shanghai**: Adds `Withdrawal` type to `encode_node`
- **Cancun/Prague/Osaka**: Inherit from Shanghai (chain delegation pattern, 508 lines in Cancun)

---

## Nethermind Architecture Reference

### Directory: `nethermind/src/Nethermind/Nethermind.Trie/`

#### Core Trie Files

| File | Purpose | Zig Mapping |
|------|---------|-------------|
| `PatriciaTree.cs` | Main trie class; Set/Get/Commit/RootHash; EmptyTreeHash constant; traversal stack | `client/trie/trie.zig` |
| `PatriciaTree.BulkSet.cs` | Batch insert optimization | Bulk operations |
| `TrieNode.cs` | Sealed node with lazy RLP decoding, dirty/persisted flags, 16 children, BranchesCount=16 | `client/trie/node.zig` |
| `TrieNode.Decoder.cs` | RLP decoding of trie nodes | Node deserialization |
| `TrieNode.Visitor.cs` | Visitor pattern for traversal | Future: proof/dump |
| `NodeType.cs` | `enum { Unknown, Branch, Extension, Leaf }` | Already in Voltaire `NodeType` |
| `NodeData.cs` | Node data abstraction | Internal node data |
| `TrieNodeFactory.cs` | Node creation factory | Node constructors |

#### Encoding/Path Files

| File | Purpose | Zig Mapping |
|------|---------|-------------|
| `HexPrefix.cs` | Hex prefix encoding (nibble <-> compact) with cached arrays for 1-3 nibble paths | Already in Voltaire `encodePath/decodePath` |
| `Nibbles.cs` | `Nibble` struct wrapping a byte (0-15) | Already in Voltaire `key_to_nibbles` |
| `NibbleExtensions.cs` | Extension methods for nibble arrays | Nibble utilities |

#### Storage Interface

| File | Purpose | Zig Mapping |
|------|---------|-------------|
| `INodeStorage.cs` | Interface: `Get(address, path, hash)`, `Set(address, path, hash, data)`, `StartWriteBatch()`, `KeyScheme` enum (Hash/HalfPath) | DB integration layer |
| `NodeStorage.cs` | Implementation of `INodeStorage` | Node persistence |
| `TrieType.cs` | `enum { State, Storage }` — two trie types | Trie type distinction |
| `INodeStorageFactory.cs` | Factory for creating node storage instances | DI pattern |

#### Pruning Subsystem (`Nethermind.Trie/Pruning/`)

| File | Purpose |
|------|---------|
| `ITrieStore.cs` | Full trie store interface with commit, find cached, load RLP |
| `TrieStore.cs` | Main implementation — caches nodes, handles commits, GC, dirty nodes cache |
| `TrieStoreDirtyNodesCache.cs` | Cache for modified nodes pending commit |
| `ScopedTrieStore.cs` | Scoped view for a specific block |
| `OverlayTrieStore.cs` | Layered trie store for pending state |
| `TreePath.cs` | Compact path representation for node lookups |
| `TinyTreePath.cs` | Optimized small path representation |
| `ReadOnlyTrieStore.cs` | Read-only wrapper |
| `NullTrieStore.cs` | Null object pattern |
| Various pruning strategies | `MaxBlockInCachePruneStrategy.cs`, `MinBlockInCachePruneStrategy.cs`, etc. |

#### Other Files

| File | Purpose |
|------|---------|
| `TreeDumper.cs` | Debug visualization of trie structure |
| `TrieException.cs` | Trie-specific exceptions |
| `TrieStats.cs` / `TrieStatsCollector.cs` | Trie statistics |
| `MissingTrieNodeException.cs` | Missing node errors |
| `RangeQueryVisitor.cs` | Range queries (used in snap sync) |
| `BatchedTrieVisitor.cs` | Batched traversal |
| `Utils/WriteBatcher.cs` | Write batching utility |

### Key Nethermind Design Patterns

1. **Lazy node resolution**: Nodes stored as RLP blobs, only decoded when accessed (`ResolveNode`)
2. **Dirty tracking**: Modified nodes marked dirty (`IsDirty`), committed in batch (`Seal()`)
3. **Tree path**: Full nibble path tracked during traversal for DB storage
4. **Scoped stores**: Trie stores scoped to specific accounts (state vs storage)
5. **Write batching**: Commits batched for DB efficiency
6. **Key schemes**: Support both hash-based and half-path-based DB keys
7. **Immutability**: Nodes sealed after commit (`IsSealed = !IsDirty`)
8. **Reference counting**: Thread-safe persistence flags

---

## Existing Zig Files to Connect With

| File | Relevance |
|------|-----------|
| `client/trie/hash.zig` | Already-implemented root hash computation via `patricialize()` |
| `client/trie/root.zig` | Module root, re-exports `trie_root` and `EMPTY_TRIE_ROOT` |
| `client/db/adapter.zig` | `Database` vtable interface for KV storage |
| `client/db/memory.zig` | `MemoryDatabase` — in-memory backend for testing |
| `client/db/root.zig` | DB module root with all re-exports |
| `src/host.zig` | `HostInterface` — the EVM's state backend; Phase 3 will connect trie-backed state to this |
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

### Step 1: Verify Existing Root Hash Computation
- The `client/trie/hash.zig` `trie_root()` function already implements `patricialize()`
- Write a test runner that loads `trietest.json` and `trieanyorder.json`
- Compare computed root hashes against expected values

### Step 2: Add Node Types (`client/trie/node.zig`)
- Either wrap or re-export Voltaire's `trie.Node`, `LeafNode`, `ExtensionNode`, `BranchNode`
- Add DB-backed node persistence (store/load by hash)

### Step 3: Add Mutable Trie (`client/trie/trie.zig`)
- Mutable trie with `put()`, `get()`, `delete()` operations
- Uses node types from Step 2
- Computes root hash matching `trie_root()` from `hash.zig`

### Step 4: Add Secure Trie Support
- Wrap trie with keccak256 key hashing
- Test against `trietest_secureTrie.json` and `trieanyorder_secureTrie.json`

### Step 5: DB-Backed Node Storage
- Replace in-memory storage with DB adapter from Phase 0
- Lazy node loading (load from DB on demand, cache in memory)

### Step 6: Account RLP Encoding
- Encode accounts as: `rlp([nonce, balance, storageRoot, codeHash])`
- This is needed for the state trie in Phase 2

### Step 7: Proof Generation
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

### Critical: Node Inlining (already handled in `client/trie/hash.zig`)

The Python spec's `encode_internal_node` returns **unencoded form** (not hash) when RLP is < 32 bytes:
```python
if len(encoded) < 32:
    return unencoded      # Return raw form, not hash
else:
    return keccak256(encoded)  # Hash only large nodes
```

The Voltaire `trie.zig` implementation's `hash_node()` **always** returns a keccak256 hash — this is incorrect for root computation. However, the `client/trie/hash.zig` implementation correctly handles this via the `EncodedNode` union type (`.raw` for inline, `.hash` for hashed).

---

## Constants to Match

```
EMPTY_TRIE_ROOT = 0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421
                = keccak256(rlp(b''))
                = keccak256(0x80)
```

---

## File Location Quick Reference

| Need to find... | Look here |
|----------------|-----------|
| MPT algorithm spec | `execution-specs/src/ethereum/forks/frontier/trie.py` |
| Cancun trie spec | `execution-specs/src/ethereum/forks/cancun/trie.py` |
| Node type definitions | Voltaire: `voltaire/src/primitives/trie.zig` |
| RLP encoding | Voltaire: `voltaire/src/primitives/Rlp/Rlp.zig` |
| Keccak256 | Voltaire: `voltaire/src/crypto/hash.zig` |
| StateRoot type | Voltaire: `voltaire/src/primitives/StateRoot/StateRoot.zig` |
| Hash type | Voltaire: `voltaire/src/primitives/Hash/Hash.zig` |
| Nethermind trie architecture | `nethermind/src/Nethermind/Nethermind.Trie/` |
| Nethermind PatriciaTree | `nethermind/src/Nethermind/Nethermind.Trie/PatriciaTree.cs` |
| Nethermind TrieNode | `nethermind/src/Nethermind/Nethermind.Trie/TrieNode.cs` |
| Nethermind node storage | `nethermind/src/Nethermind/Nethermind.Trie/INodeStorage.cs` |
| Nethermind pruning/store | `nethermind/src/Nethermind/Nethermind.Trie/Pruning/TrieStore.cs` |
| DB interface | `client/db/adapter.zig` |
| Existing root hash computation | `client/trie/hash.zig` |
| Test vectors | `ethereum-tests/TrieTests/` |
| Host interface (future integration) | `src/host.zig` |
| Fuzz tests | `voltaire/src/primitives/trie.fuzz.zig` |
