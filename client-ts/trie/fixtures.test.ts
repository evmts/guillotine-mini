import { assert, describe, it } from "@effect/vitest";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import * as fs from "node:fs";
import * as path from "node:path";
import { Bytes, Hex } from "voltaire-effect/primitives";
import type { BytesType, HashType } from "./Node";
import { TrieHashTest } from "./hash";
import { compactToNibbleList, nibbleListToCompact } from "./encoding";
import { makeBytesHelpers } from "./internal/primitives";
import { TriePatricializeTest } from "./patricialize";
import { KeyNibblerTest } from "./KeyNibbler";
import { TrieRoot, TrieRootTest, trieRoot } from "./root";

class FixtureError extends Data.TaggedError("FixtureError")<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

const { bytesFromHex, bytesFromUint8Array } = makeBytesHelpers(
  (message) => new Error(message),
);
const EmptyBytes = bytesFromHex("0x");

const BaseLayer = Layer.merge(
  TrieHashTest,
  TriePatricializeTest.pipe(Layer.provide(TrieHashTest)),
);
const TestLayer = TrieRootTest.pipe(
  Layer.provide(BaseLayer),
  Layer.provide(KeyNibblerTest),
);

type HexPrefixFixture = Readonly<
  Record<
    string,
    {
      readonly seq: ReadonlyArray<number>;
      readonly term: boolean;
      readonly out: string;
    }
  >
>;

type TrieFixtureInput =
  | ReadonlyArray<readonly [string, string | null]>
  | Readonly<Record<string, string | null>>;

type TrieFixture = Readonly<
  Record<
    string,
    {
      readonly in: TrieFixtureInput;
      readonly root: string;
    }
  >
>;

const HexPrefixFixtureSchema: Schema.Schema<HexPrefixFixture> = Schema.Record({
  key: Schema.String,
  value: Schema.Struct({
    seq: Schema.Array(Schema.Number),
    term: Schema.Boolean,
    out: Schema.String,
  }),
});

const TrieFixtureSchema: Schema.Schema<TrieFixture> = Schema.Record({
  key: Schema.String,
  value: Schema.Struct({
    in: Schema.Union(
      Schema.Array(Schema.Tuple(Schema.String, Schema.NullOr(Schema.String))),
      Schema.Record({
        key: Schema.String,
        value: Schema.NullOr(Schema.String),
      }),
    ),
    root: Schema.String,
  }),
});

const loadFixture = <A>(
  filePath: string,
  schema: Schema.Schema<A>,
): Effect.Effect<A, FixtureError> =>
  Effect.try({
    try: () => JSON.parse(fs.readFileSync(filePath, "utf8")),
    catch: (cause) =>
      new FixtureError({
        message: `Failed to read fixture ${filePath}`,
        cause,
      }),
  }).pipe(
    Effect.flatMap((json) =>
      Schema.decodeUnknown(schema)(json).pipe(
        Effect.mapError(
          (cause) =>
            new FixtureError({
              message: `Fixture schema mismatch for ${filePath}`,
              cause,
            }),
        ),
      ),
    ),
  );

const toBytes = (
  value: string | null,
): Effect.Effect<BytesType, FixtureError> =>
  Effect.try({
    try: () => {
      if (value === null) {
        return EmptyBytes;
      }
      if (value.startsWith("0x")) {
        return bytesFromHex(value);
      }
      return bytesFromUint8Array(new TextEncoder().encode(value));
    },
    catch: (cause) =>
      new FixtureError({ message: "Invalid bytes in fixture", cause }),
  });

const normalizeEntries = (
  input: TrieFixtureInput,
): ReadonlyArray<readonly [string, string | null]> =>
  Array.isArray(input) ? input : Object.entries(input);

const collectEntries = (
  entries: ReadonlyArray<readonly [string, string | null]>,
): Effect.Effect<
  Map<string, { key: BytesType; value: BytesType }>,
  FixtureError
> =>
  Effect.gen(function* () {
    const map = new Map<string, { key: BytesType; value: BytesType }>();
    for (const [rawKey, rawValue] of entries) {
      const key = yield* toBytes(rawKey);
      const value = yield* toBytes(rawValue);
      const keyHex = Hex.fromBytes(key);
      if (value.length === 0) {
        map.delete(keyHex);
      } else {
        map.set(keyHex, { key, value });
      }
    }
    return map;
  });

const computeRoot = (
  entries: ReadonlyArray<readonly [string, string | null]>,
  secured: boolean,
): Effect.Effect<HashType, FixtureError, TrieRoot> =>
  Effect.gen(function* () {
    const finalEntries = yield* collectEntries(entries);
    return yield* trieRoot(Array.from(finalEntries.values()), { secured }).pipe(
      Effect.mapError(
        (cause) =>
          new FixtureError({
            message: "Failed to compute trie root",
            cause,
          }),
      ),
    );
  });

describe("trie fixture harness", () => {
  it.effect("matches Nethermind hex-prefix vectors", () =>
    Effect.gen(function* () {
      const repoRoot = path.resolve(process.cwd(), "..");
      const fixturePath = path.join(
        repoRoot,
        "ethereum-tests",
        "BasicTests",
        "hexencodetest.json",
      );
      const fixtures = yield* loadFixture(fixturePath, HexPrefixFixtureSchema);

      for (const [name, fixture] of Object.entries(fixtures)) {
        const sequence = bytesFromUint8Array(new Uint8Array(fixture.seq));
        const encoded = yield* nibbleListToCompact(sequence, fixture.term);
        const encodedHex = Hex.fromBytes(encoded).slice(2);
        assert.strictEqual(encodedHex, fixture.out, name);

        const compact = bytesFromHex(`0x${fixture.out}`);
        const decoded = yield* compactToNibbleList(compact);
        assert.isTrue(Bytes.equals(decoded.nibbles, sequence), name);
        assert.strictEqual(decoded.isLeaf, fixture.term, name);
      }
    }),
  );

  it.effect("matches Ethereum trie root fixtures", () =>
    Effect.gen(function* () {
      const repoRoot = path.resolve(process.cwd(), "..");
      const triePath = path.join(repoRoot, "ethereum-tests", "TrieTests");
      const testMatrix: ReadonlyArray<{
        readonly file: string;
        readonly secured: boolean;
      }> = [
        { file: "trietest.json", secured: false },
        { file: "trieanyorder.json", secured: false },
        { file: "trietest_secureTrie.json", secured: true },
        { file: "trieanyorder_secureTrie.json", secured: true },
        { file: "hex_encoded_securetrie_test.json", secured: true },
      ];

      for (const { file, secured } of testMatrix) {
        const fixturePath = path.join(triePath, file);
        const fixtures = yield* loadFixture(fixturePath, TrieFixtureSchema);

        for (const [name, fixture] of Object.entries(fixtures)) {
          const entries = normalizeEntries(fixture.in);
          const root = yield* computeRoot(entries, secured);
          const rootHex = Hex.fromBytes(root);
          assert.strictEqual(rootHex, fixture.root, `${file}:${name}`);
        }
      }
    }).pipe(Effect.provide(TestLayer)),
  );
});
