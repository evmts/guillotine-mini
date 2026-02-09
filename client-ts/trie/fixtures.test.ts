import { assert, describe, it } from "@effect/vitest";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import * as fs from "node:fs";
import * as path from "node:path";
import { Bytes, Hash, Hex, Rlp } from "voltaire-effect/primitives";
import type { BytesType, EncodedNode, HashType, NibbleList } from "./Node";
import {
  encodeInternalNode,
  TrieHashTest,
  type TrieHash,
  type TrieHashError,
} from "./hash";
import {
  bytesToNibbleList,
  compactToNibbleList,
  nibbleListToCompact,
} from "./encoding";
import { makeBytesHelpers, makeHashHelpers } from "./internal/primitives";
import {
  PatricializeError,
  TriePatricializeTest,
  patricialize,
  type TriePatricialize,
} from "./patricialize";

class FixtureError extends Data.TaggedError("FixtureError")<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

const { bytesFromHex, bytesFromUint8Array } = makeBytesHelpers(
  (message) => new Error(message),
);
const { hashFromHex } = makeHashHelpers((message) => new Error(message));
const coerceEffect = <A, E>(effect: unknown): Effect.Effect<A, E> =>
  effect as Effect.Effect<A, E>;
const encodeRlp = (data: Parameters<typeof Rlp.encode>[0]) =>
  coerceEffect<Uint8Array, unknown>(Rlp.encode(data));
const keccak256 = (data: Uint8Array) =>
  coerceEffect<HashType, never>(Hash.keccak256(data));
const EmptyBytes = bytesFromHex("0x");
const EmptyTrieRoot = hashFromHex(
  "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
);

const TestLayer = Layer.merge(
  TrieHashTest,
  TriePatricializeTest.pipe(Layer.provide(TrieHashTest)),
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

const encodedNodeToRoot = (
  encoded: EncodedNode,
): Effect.Effect<HashType, TrieHashError | FixtureError> => {
  switch (encoded._tag) {
    case "hash":
      return Effect.succeed(encoded.value);
    case "raw":
      return encodeRlp(encoded.value).pipe(
        Effect.flatMap((encodedNode) => keccak256(encodedNode)),
        Effect.mapError(
          (cause) =>
            new FixtureError({
              message: "Failed to encode root node",
              cause,
            }),
        ),
      );
    case "empty":
      return Effect.succeed(EmptyTrieRoot);
  }
};

const computeRoot = (
  entries: ReadonlyArray<readonly [string, string | null]>,
  secured: boolean,
): Effect.Effect<
  HashType,
  FixtureError | PatricializeError | TrieHashError,
  TrieHash | TriePatricialize
> =>
  Effect.gen(function* () {
    const finalEntries = yield* collectEntries(entries);
    const nibbleMap = new Map<NibbleList, BytesType>();
    for (const { key, value } of finalEntries.values()) {
      const hashedKey = secured
        ? bytesFromUint8Array(yield* keccak256(key))
        : key;
      const nibbleKey = yield* bytesToNibbleList(hashedKey);
      nibbleMap.set(nibbleKey, value);
    }

    const node = yield* patricialize(nibbleMap, 0);
    const encoded = yield* encodeInternalNode(node);
    return yield* encodedNodeToRoot(encoded);
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
