import { Bytes, Hash, Rlp } from "voltaire-effect/primitives";

/** Byte array type used by trie nodes. */
export type BytesType = Parameters<typeof Bytes.equals>[0];

/** 32-byte hash type used by trie nodes. */
export type HashType = Parameters<typeof Hash.equals>[0];

/** Branded RLP type used for encoded trie nodes. */
export type RlpType = Parameters<typeof Rlp.equals>[0];

/** Nibble list represented as bytes (values 0x0-0xf). */
export type NibbleList = BytesType;

/** Encoded node reference used in trie hashing. */
export type EncodedNode =
  | {
      readonly _tag: "hash";
      readonly value: HashType;
    }
  | {
      readonly _tag: "raw";
      /** RLP structure (kept for compatibility with existing callers). */
      readonly value: RlpType;
      /** Optional pre-encoded bytes of `value` to avoid re-encoding. */
      readonly encoded?: BytesType;
    }
  | {
      readonly _tag: "empty";
    };

/** Number of children in a branch node. */
export const BranchChildrenCount = 16 as const;

/** Encoded child references for branch nodes. */
export type BranchSubnodes = ReadonlyArray<EncodedNode>;

/** Leaf node with terminal key remainder and value. */
export interface LeafNode {
  readonly _tag: "leaf";
  readonly restOfKey: NibbleList;
  readonly value: BytesType;
}

/** Extension node with shared key segment and a child reference. */
export interface ExtensionNode {
  readonly _tag: "extension";
  readonly keySegment: NibbleList;
  readonly subnode: EncodedNode;
}

/** Branch node with 16 children and optional value. */
export interface BranchNode {
  readonly _tag: "branch";
  readonly subnodes: BranchSubnodes;
  readonly value: BytesType;
}

/** Trie node union. */
export type TrieNode = LeafNode | ExtensionNode | BranchNode;
