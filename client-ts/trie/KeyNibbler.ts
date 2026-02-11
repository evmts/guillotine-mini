import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import { Bytes, Hash } from "voltaire-effect/primitives";
import type { BytesType, NibbleList } from "./Node";
import { bytesToNibbleList } from "./encoding";
import { coerceEffect } from "./internal/effect";
import { makeBytesHelpers } from "./internal/primitives";

/** Error raised when converting keys to nibble paths. */
export class KeyNibblerError extends Data.TaggedError("KeyNibblerError")<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

const { bytesFromUint8Array } = makeBytesHelpers(
  (message) => new KeyNibblerError({ message }),
);

const toBytes = (value: Uint8Array) =>
  Effect.try({
    try: () => bytesFromUint8Array(value),
    catch: (cause) =>
      new KeyNibblerError({ message: "Invalid key bytes", cause }),
  });

const keccak256 = (data: Uint8Array) =>
  coerceEffect<Hash.HashType, never>(Hash.keccak256(data));

/** Key → nibble-path conversion service. */
export interface KeyNibblerService {
  readonly toNibbles: (
    key: BytesType,
    secured: boolean,
  ) => Effect.Effect<NibbleList, KeyNibblerError>;
}

/** Context tag for KeyNibbler. */
export class KeyNibbler extends Context.Tag("KeyNibbler")<
  KeyNibbler,
  KeyNibblerService
>() {}

const makeKeyNibbler = () =>
  ({
    toNibbles: (key: BytesType, secured: boolean) =>
      Effect.gen(function* () {
        const keyBytes = secured
          ? yield* Effect.flatMap(keccak256(key), toBytes)
          : key;
        return yield* bytesToNibbleList(keyBytes);
      }),
  }) satisfies KeyNibblerService;

const KeyNibblerLayer: Layer.Layer<KeyNibbler> = Layer.succeed(
  KeyNibbler,
  makeKeyNibbler(),
);

/** Production layer. */
export const KeyNibblerLive: Layer.Layer<KeyNibbler> = KeyNibblerLayer;

/** Deterministic test layer. */
export const KeyNibblerTest: Layer.Layer<KeyNibbler> = KeyNibblerLayer;

/** Convert a key to its nibble path, optionally securing via keccak256. */
export const toNibbles = (key: BytesType, secured: boolean) =>
  Effect.gen(function* () {
    const svc = yield* KeyNibbler;
    return yield* svc.toNibbles(key, secured);
  });
