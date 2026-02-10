import * as Data from "effect/Data";

/** Error raised by DB operations. */
export class DbError extends Data.TaggedError("DbError")<{
  readonly message: string;
  readonly cause?: unknown;
}> {}
