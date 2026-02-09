import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import { Bytes, Hash } from "voltaire-effect/primitives";
import { TrieHashTest } from "./hash";
import { makeBytesHelpers } from "./internal/primitives";
import { TriePatricializeTest } from "./patricialize";
import { EMPTY_TRIE_ROOT, TrieRootTest } from "./root";
import { TrieMemoryLive, TrieMemoryTest, get, put, remove, root } from "./Trie";

const { bytesFromHex } = makeBytesHelpers((message) => new Error(message));
const EmptyBytes = bytesFromHex("0x");

const BaseLayer = Layer.merge(
  TrieHashTest,
  TriePatricializeTest.pipe(Layer.provide(TrieHashTest)),
);
const RootLayer = TrieRootTest.pipe(Layer.provide(BaseLayer));
const trieLayer = (secured = false) =>
  TrieMemoryTest({ secured, defaultValue: EmptyBytes }).pipe(
    Layer.provide(RootLayer),
  );
const trieLayerLive = (secured = false) =>
  TrieMemoryLive({ secured, defaultValue: EmptyBytes }).pipe(
    Layer.provide(RootLayer),
  );

describe("Trie", () => {
  it.effect("put/get round-trips bytes", () =>
    Effect.gen(function* () {
      const key = bytesFromHex("0x01");
      const value = bytesFromHex("0xdeadbeef");

      yield* put(key, value);
      const result = yield* get(key);

      assert.isTrue(Bytes.equals(result, value));
    }).pipe(Effect.provide(trieLayerLive())),
  );

  it.effect("get returns default for missing keys", () =>
    Effect.gen(function* () {
      const key = bytesFromHex("0x02");
      const result = yield* get(key);
      assert.isTrue(Bytes.equals(result, EmptyBytes));
    }).pipe(Effect.provide(trieLayer())),
  );

  it.effect("remove deletes stored values", () =>
    Effect.gen(function* () {
      const key = bytesFromHex("0x03");
      const value = bytesFromHex("0x1234");

      yield* put(key, value);
      yield* remove(key);
      const result = yield* get(key);

      assert.isTrue(Bytes.equals(result, EmptyBytes));
    }).pipe(Effect.provide(trieLayer())),
  );

  it.effect("put with empty value deletes key", () =>
    Effect.gen(function* () {
      const key = bytesFromHex("0x04");
      const value = bytesFromHex("0x0102");

      yield* put(key, value);
      yield* put(key, EmptyBytes);

      const result = yield* get(key);
      assert.isTrue(Bytes.equals(result, EmptyBytes));
      const hash = yield* root();
      assert.isTrue(Hash.equals(hash, EMPTY_TRIE_ROOT));
    }).pipe(Effect.provide(trieLayer())),
  );

  it.effect("root reflects secured configuration", () =>
    Effect.gen(function* () {
      const key = bytesFromHex("0x05");
      const value = bytesFromHex("0xbeef");

      const plainRoot = yield* Effect.gen(function* () {
        yield* put(key, value);
        return yield* root();
      }).pipe(Effect.provide(trieLayer(false)));

      const securedRoot = yield* Effect.gen(function* () {
        yield* put(key, value);
        return yield* root();
      }).pipe(Effect.provide(trieLayer(true)));

      assert.isFalse(Hash.equals(plainRoot, securedRoot));
    }),
  );
});
