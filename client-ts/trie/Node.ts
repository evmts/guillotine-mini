import type { BytesType as VoltaireBytesType } from "@tevm/voltaire/Bytes";
import type { HashType as VoltaireHashType } from "@tevm/voltaire/Hash";
import type { BrandedRlp as VoltaireRlpType } from "@tevm/voltaire/Rlp";

/** Byte array type used by trie nodes. */
export type BytesType = VoltaireBytesType;

/** 32-byte hash type used by trie nodes. */
export type HashType = VoltaireHashType;

/** Branded RLP type used for encoded trie nodes. */
export type RlpType = VoltaireRlpType;

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
      readonly value: RlpType;
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
