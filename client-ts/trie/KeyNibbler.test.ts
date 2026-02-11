import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import { Bytes, Hash, Hex } from "voltaire-effect/primitives";
import type { BytesType, NibbleList } from "./Node";
import { bytesToNibbleList } from "./encoding";
import { KeyNibblerLive, KeyNibblerTest, toNibbles } from "./KeyNibbler";

const toBytes = (hex: string): BytesType => Hex.toBytes(hex) as BytesType;

const nibbles = (...values: number[]): NibbleList => {
  const out = new Uint8Array(values.length);
  for (let i = 0; i < values.length; i += 1) out[i] = values[i]!;
  return Bytes.concat(out) as NibbleList;
};

describe("KeyNibbler", () => {
  const provide = (live = true) =>
    (live ? KeyNibblerLive : KeyNibblerTest) as Layer.Layer<any>;

  it.effect("toNibbles expands bytes without securing", () =>
    Effect.gen(function* () {
      const key = toBytes("0x12ab");
      const expected = yield* bytesToNibbleList(key);

      const actual = yield* toNibbles(key, false);
      assert.isTrue(Bytes.equals(actual, expected));
    }).pipe(Effect.provide(provide())),
  );

  it.effect("toNibbles expands keccak256(key) when secured", () =>
    Effect.gen(function* () {
      const key = toBytes("0x01");
      const hashed = (yield* Hash.keccak256(key)) as BytesType;
      const expected = yield* bytesToNibbleList(hashed);

      const actual = yield* toNibbles(key, true);
      assert.isTrue(Bytes.equals(actual, expected));
    }).pipe(Effect.provide(provide())),
  );
});
