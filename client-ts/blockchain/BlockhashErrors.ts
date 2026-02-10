import * as Data from "effect/Data";
import { BlockHash } from "voltaire-effect/primitives";

/** Block hash type used for error reporting. */
export type BlockHashType = BlockHash.BlockHashType;

/** Error raised when an expected ancestor hash is missing. */
export class MissingBlockhashError extends Data.TaggedError(
  "MissingBlockhashError",
)<{
  readonly missingHash: BlockHashType;
  readonly missingNumber: bigint;
}> {}
