import type * as Effect from "effect/Effect";
import { Hash } from "voltaire-effect/primitives";
import type { HashType } from "../Node";
import { coerceEffect } from "./effect";

/**
 * Typed crypto utilities shared across trie modules.
 *
 * Note: Some submodules load a separate copy of Effect at runtime; we coerce
 * the return type using `coerceEffect` to avoid duplicating dependency wiring
 * at call sites while preserving precise types in our APIs.
 */

/** Keccak-256 digest returning a branded `HashType`. */
export const keccak256 = (data: Uint8Array): Effect.Effect<HashType, never> =>
  coerceEffect<HashType, never>(Hash.keccak256(data));
