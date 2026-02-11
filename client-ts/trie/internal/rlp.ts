import type * as Effect from "effect/Effect";
import { Rlp } from "voltaire-effect/primitives";
import { coerceEffect } from "./effect";

/** Encode RLP data into bytes with a typed error channel left generic. */
export const encodeRlp = (data: Parameters<typeof Rlp.encode>[0]) =>
  coerceEffect<Uint8Array, unknown>(Rlp.encode(data));
