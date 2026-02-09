import type * as Effect from "effect/Effect";

/**
 * Unsafe cast to bridge Effect types across duplicated dependencies.
 */
export const coerceEffect = <A, E, R = never>(
  effect: unknown,
): Effect.Effect<A, E, R> => effect as Effect.Effect<A, E, R>;
