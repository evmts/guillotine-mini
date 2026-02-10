import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as fs from "node:fs";
import * as path from "node:path";
import { Bytes, Hash, Hex } from "voltaire-effect/primitives";
import type { BytesType } from "./Node";
import { TrieHashTest } from "./hash";
import { coerceEffect } from "./internal/effect";
import { makeBytesHelpers } from "./internal/primitives";
import { TriePatricializeTest } from "./patricialize";
import { EMPTY_TRIE_ROOT, TrieRootTest } from "./root";
import {
  TrieError,
  TrieMemoryLive,
  TrieMemoryTest,
  get,
  put,
  remove,
  root,
} from "./Trie";

const { bytesFromHex, bytesFromUint8Array } = makeBytesHelpers(
  (message) => new Error(message),
);
const EmptyBytes = bytesFromHex("0x");
const encodeFixtureBytes = (value: string): BytesType =>
  value.startsWith("0x")
    ? bytesFromHex(value)
    : bytesFromUint8Array(new TextEncoder().encode(value));

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

  it.effect("rejects invalid key input", () =>
    Effect.gen(function* () {
      const invalidKey = null as unknown as BytesType;
      const result = yield* get(invalidKey).pipe(Effect.either);
      if (result._tag === "Left") {
        assert.isTrue(result.left instanceof TrieError);
        return;
      }
      assert.fail("Expected TrieError for invalid key");
    }).pipe(Effect.provide(trieLayer())),
  );

  it.effect("rejects invalid value input", () =>
    Effect.gen(function* () {
      const key = bytesFromHex("0x07");
      const invalidValue = null as unknown as BytesType;
      const result = yield* put(key, invalidValue).pipe(Effect.either);
      if (result._tag === "Left") {
        assert.isTrue(result.left instanceof TrieError);
        return;
      }
      assert.fail("Expected TrieError for invalid value");
    }).pipe(Effect.provide(trieLayer())),
  );

  it.effect("get returns default for missing keys", () =>
    Effect.gen(function* () {
      const key = bytesFromHex("0x02");
      const result = yield* get(key);
      assert.isTrue(Bytes.equals(result, EmptyBytes));
    }).pipe(Effect.provide(trieLayer())),
  );

  it.effect("empty trie root matches the canonical empty hash", () =>
    Effect.gen(function* () {
      const hash = yield* root();
      assert.isTrue(
        yield* coerceEffect<boolean, never>(Hash.equals(hash, EMPTY_TRIE_ROOT)),
      );
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
      assert.isTrue(
        yield* coerceEffect<boolean, never>(Hash.equals(hash, EMPTY_TRIE_ROOT)),
      );
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

      assert.isFalse(
        yield* coerceEffect<boolean, never>(
          Hash.equals(plainRoot, securedRoot),
        ),
      );
    }),
  );

  it.effect("matches Ethereum trie fixture (emptyValues)", () =>
    Effect.gen(function* () {
      const repoRoot = path.resolve(process.cwd(), "..");
      const fixturePath = path.join(
        repoRoot,
        "ethereum-tests",
        "TrieTests",
        "trietest.json",
      );
      const raw = JSON.parse(fs.readFileSync(fixturePath, "utf8")) as Record<
        string,
        {
          readonly in: ReadonlyArray<readonly [string, string | null]>;
          root: string;
        }
      >;
      const fixture = raw.emptyValues;
      if (!fixture) {
        throw new Error("Missing emptyValues fixture");
      }

      for (const [rawKey, rawValue] of fixture.in) {
        const key = encodeFixtureBytes(rawKey);
        const value =
          rawValue === null ? EmptyBytes : encodeFixtureBytes(rawValue);
        yield* put(key, value);
      }

      const hash = yield* root();
      assert.strictEqual(Hex.fromBytes(hash), fixture.root);
    }).pipe(Effect.provide(trieLayer(false))),
  );
});
