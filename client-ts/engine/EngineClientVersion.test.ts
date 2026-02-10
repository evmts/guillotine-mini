import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import { Hex } from "voltaire-effect/primitives";
import {
  DefaultExecutionClientVersionsV1,
  EngineClientVersionLive,
  InvalidClientVersionV1Error,
  type ClientVersionV1,
  getClientVersionV1,
} from "./EngineClientVersion";

const makeClientVersion = (
  overrides: Partial<ClientVersionV1> = {},
): ClientVersionV1 => ({
  code: "LH",
  name: "lighthouse",
  version: "5.1.0",
  commit: Hex.fromBytes(new Uint8Array([0xfa, 0x4f, 0xf9, 0x22])),
  ...overrides,
});

const provideClientVersion =
  (executionClientVersions: ReadonlyArray<ClientVersionV1>) =>
  <A, E, R>(effect: Effect.Effect<A, E, R>) =>
    effect.pipe(
      Effect.provide(EngineClientVersionLive(executionClientVersions)),
    );

describe("EngineClientVersion", () => {
  it.effect(
    "returns configured execution client versions for valid request payload",
    () =>
      provideClientVersion([...DefaultExecutionClientVersionsV1])(
        Effect.gen(function* () {
          const result = yield* getClientVersionV1(
            makeClientVersion({ code: "ZZ" }),
          );

          assert.deepStrictEqual(result, [...DefaultExecutionClientVersionsV1]);
        }),
      ),
  );

  it.effect("rejects request payloads with invalid client code", () =>
    provideClientVersion([...DefaultExecutionClientVersionsV1])(
      Effect.gen(function* () {
        const outcome = yield* getClientVersionV1(
          makeClientVersion({ code: "LHH" }),
        ).pipe(Effect.either);

        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          const error = outcome.left;
          assert.isTrue(error instanceof InvalidClientVersionV1Error);
          assert.strictEqual(error.source, "request");
          assert.strictEqual(error.reason, "InvalidCode");
          assert.strictEqual(error.value, "LHH");
        }
      }),
    ),
  );

  it.effect("accepts request payloads with empty client metadata fields", () =>
    provideClientVersion([...DefaultExecutionClientVersionsV1])(
      Effect.gen(function* () {
        const result = yield* getClientVersionV1(
          makeClientVersion({ name: "   ", version: "  " }),
        );

        assert.deepStrictEqual(result, [...DefaultExecutionClientVersionsV1]);
      }),
    ),
  );

  it.effect("accepts request payloads with non-4-byte commit", () =>
    provideClientVersion([...DefaultExecutionClientVersionsV1])(
      Effect.gen(function* () {
        const result = yield* getClientVersionV1(
          makeClientVersion({ commit: Hex.fromBytes(new Uint8Array([0x01])) }),
        );

        assert.deepStrictEqual(result, [...DefaultExecutionClientVersionsV1]);
      }),
    ),
  );

  it.effect("accepts malformed commit hex in request payload", () =>
    provideClientVersion([...DefaultExecutionClientVersionsV1])(
      Effect.gen(function* () {
        const result = yield* getClientVersionV1(
          makeClientVersion({
            commit: "invalid" as unknown as ClientVersionV1["commit"],
          }),
        );

        assert.deepStrictEqual(result, [...DefaultExecutionClientVersionsV1]);
      }),
    ),
  );

  it.effect("rejects empty configured response client-version list", () =>
    Effect.gen(function* () {
      const outcome = yield* getClientVersionV1(makeClientVersion()).pipe(
        Effect.provide(EngineClientVersionLive([])),
        Effect.either,
      );

      assert.isTrue(Either.isLeft(outcome));
      if (Either.isLeft(outcome)) {
        const error = outcome.left;
        assert.isTrue(error instanceof InvalidClientVersionV1Error);
        assert.strictEqual(error.source, "response");
        assert.strictEqual(error.reason, "EmptyResponse");
      }
    }),
  );

  it.effect("rejects invalid configured response payload entries", () =>
    Effect.gen(function* () {
      const outcome = yield* getClientVersionV1(makeClientVersion()).pipe(
        Effect.provide(
          EngineClientVersionLive([
            makeClientVersion({
              commit: Hex.fromBytes(new Uint8Array([0xaa])),
            }),
          ]),
        ),
        Effect.either,
      );

      assert.isTrue(Either.isLeft(outcome));
      if (Either.isLeft(outcome)) {
        const error = outcome.left;
        assert.isTrue(error instanceof InvalidClientVersionV1Error);
        assert.strictEqual(error.source, "response");
        assert.strictEqual(error.reason, "InvalidCommitLength");
        assert.strictEqual(error.index, 0);
      }
    }),
  );

  it.effect("rejects configured response payloads with empty version", () =>
    Effect.gen(function* () {
      const outcome = yield* getClientVersionV1(makeClientVersion()).pipe(
        Effect.provide(
          EngineClientVersionLive([
            makeClientVersion({
              version: "  ",
            }),
          ]),
        ),
        Effect.either,
      );

      assert.isTrue(Either.isLeft(outcome));
      if (Either.isLeft(outcome)) {
        const error = outcome.left;
        assert.isTrue(error instanceof InvalidClientVersionV1Error);
        assert.strictEqual(error.source, "response");
        assert.strictEqual(error.reason, "EmptyVersion");
        assert.strictEqual(error.index, 0);
      }
    }),
  );

  it.effect(
    "rejects multi-entry response configuration for single-client mode",
    () =>
      Effect.gen(function* () {
        const outcome = yield* getClientVersionV1(makeClientVersion()).pipe(
          Effect.provide(
            EngineClientVersionLive([makeClientVersion(), makeClientVersion()]),
          ),
          Effect.either,
        );

        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          const error = outcome.left;
          assert.isTrue(error instanceof InvalidClientVersionV1Error);
          assert.strictEqual(error.source, "response");
          assert.strictEqual(error.reason, "InvalidResponseCardinality");
        }
      }),
  );
});
