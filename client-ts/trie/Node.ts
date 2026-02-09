import type { BrandedRlp } from "@tevm/voltaire/Rlp";
import type * as Schema from "effect/Schema";
import { Bytes, Hash } from "voltaire-effect/primitives";

export type BytesType = Schema.Schema.Type<typeof Bytes.Hex>;
export type HashType = Schema.Schema.Type<typeof Hash.Hex>;
export type RlpType = BrandedRlp;

export type NibbleList = BytesType;

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

export const BranchChildrenCount = 16 as const;
export type BranchSubnodes = ReadonlyArray<EncodedNode>;

export interface LeafNode {
  readonly _tag: "leaf";
  readonly restOfKey: NibbleList;
  readonly value: BytesType;
}

export interface ExtensionNode {
  readonly _tag: "extension";
  readonly keySegment: NibbleList;
  readonly subnode: EncodedNode;
}

export interface BranchNode {
  readonly _tag: "branch";
  readonly subnodes: BranchSubnodes;
  readonly value: BytesType;
}

export type TrieNode = LeafNode | ExtensionNode | BranchNode;

export const NodeType = {
  Leaf: "leaf",
  Extension: "extension",
  Branch: "branch",
} as const;

export type NodeType = (typeof NodeType)[keyof typeof NodeType];
