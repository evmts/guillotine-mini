import { assert, describe, it } from "@effect/vitest";
import * as Either from "effect/Either";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import * as Ref from "effect/Ref";
import { JsonRpcErrorRegistryLive } from "./JsonRpcErrors";
import {
  JsonRpcProcessorLive,
  processJsonRpcPayload,
} from "./JsonRpcProcessor";
import { JsonRpcRequestDecoderLive } from "./JsonRpcRequest";
import { JsonRpcResponseEncoderLive } from "./JsonRpcResponse";
import { JsonRpcServiceLive } from "./JsonRpcService";

const JsonRpcResponseLayer = JsonRpcResponseEncoderLive.pipe(
  Layer.provide(JsonRpcErrorRegistryLive),
);

const makeJsonRpcProcessorLayer = (
  handlers: Parameters<typeof JsonRpcServiceLive>[0],
) =>
  JsonRpcProcessorLive.pipe(
    Layer.provideMerge(JsonRpcRequestDecoderLive),
    Layer.provideMerge(JsonRpcResponseLayer),
    Layer.provideMerge(
      JsonRpcServiceLive(handlers).pipe(
        Layer.provideMerge(JsonRpcResponseLayer),
      ),
    ),
  );

const provideProcessor =
  (handlers: Parameters<typeof JsonRpcServiceLive>[0]) =>
  <A, E, R>(effect: Effect.Effect<A, E, R>) =>
    effect.pipe(Effect.provide(makeJsonRpcProcessorLayer(handlers)));

describe("JsonRpcProcessor", () => {
  it.effect("processes valid object payloads through JsonRpcService", () =>
    provideProcessor({
      web3_clientVersion: () => Effect.succeed("guillotine-mini/v0.0.0"),
    })(
      Effect.gen(function* () {
        const response = yield* processJsonRpcPayload({
          jsonrpc: "2.0",
          method: "web3_clientVersion",
          params: [],
          id: 1,
        });

        assert.isTrue(Option.isSome(response));
        if (Option.isSome(response)) {
          assert.deepStrictEqual(response.value, {
            jsonrpc: "2.0",
            result: "guillotine-mini/v0.0.0",
            id: 1,
          });
        }
      }),
    ),
  );

  it.effect("processes valid JSON string payloads", () =>
    provideProcessor({
      net_version: () => Effect.succeed("1"),
    })(
      Effect.gen(function* () {
        const response = yield* processJsonRpcPayload(
          '{"jsonrpc":"2.0","method":"net_version","id":5}',
        );

        assert.isTrue(Option.isSome(response));
        if (Option.isSome(response)) {
          assert.deepStrictEqual(response.value, {
            jsonrpc: "2.0",
            result: "1",
            id: 5,
          });
        }
      }),
    ),
  );

  it.effect("returns parse error for malformed JSON payload strings", () =>
    provideProcessor({})(
      Effect.gen(function* () {
        const response = yield* processJsonRpcPayload(
          '{"jsonrpc":"2.0","method":"web3_clientVersion",',
        );

        assert.isTrue(Option.isSome(response));
        if (Option.isSome(response)) {
          assert.deepStrictEqual(response.value, {
            jsonrpc: "2.0",
            error: {
              code: -32700,
              message: "Parse error",
            },
            id: null,
          });
        }
      }),
    ),
  );

  it.effect(
    "returns invalid request when payload is not an object or batch",
    () =>
      provideProcessor({})(
        Effect.gen(function* () {
          const response = yield* processJsonRpcPayload(42);

          assert.isTrue(Option.isSome(response));
          if (Option.isSome(response)) {
            assert.deepStrictEqual(response.value, {
              jsonrpc: "2.0",
              error: {
                code: -32600,
                message: "Invalid request",
              },
              id: null,
            });
          }
        }),
      ),
  );

  it.effect("returns invalid request when object fails request decoding", () =>
    provideProcessor({})(
      Effect.gen(function* () {
        const response = yield* processJsonRpcPayload({
          jsonrpc: "2.0",
          method: "",
          id: 9,
        });

        assert.isTrue(Option.isSome(response));
        if (Option.isSome(response)) {
          assert.deepStrictEqual(response.value, {
            jsonrpc: "2.0",
            error: {
              code: -32600,
              message: "Invalid request",
            },
            id: null,
          });
        }
      }),
    ),
  );

  it.effect("returns no response for notifications", () =>
    Effect.gen(function* () {
      const called = yield* Ref.make(0);
      const layer = makeJsonRpcProcessorLayer({
        net_listening: () =>
          Effect.gen(function* () {
            yield* Ref.update(called, (count) => count + 1);
            return true;
          }),
      });

      const response = yield* processJsonRpcPayload({
        jsonrpc: "2.0",
        method: "net_listening",
      }).pipe(Effect.provide(layer));

      const callCount = yield* Ref.get(called);
      assert.isTrue(Option.isNone(response));
      assert.strictEqual(callCount, 1);
    }),
  );

  it.effect("processes batch requests and returns a batch response", () =>
    provideProcessor({
      net_version: () => Effect.succeed("1"),
      web3_clientVersion: () => Effect.succeed("guillotine-mini/v0.0.0"),
    })(
      Effect.gen(function* () {
        const response = yield* processJsonRpcPayload([
          {
            jsonrpc: "2.0",
            method: "net_version",
            id: 1,
          },
          {
            jsonrpc: "2.0",
            method: "web3_clientVersion",
            id: 2,
          },
        ]);

        assert.isTrue(Option.isSome(response));
        if (Option.isSome(response)) {
          assert.deepStrictEqual(response.value, [
            {
              jsonrpc: "2.0",
              result: "1",
              id: 1,
            },
            {
              jsonrpc: "2.0",
              result: "guillotine-mini/v0.0.0",
              id: 2,
            },
          ]);
        }
      }),
    ),
  );

  it.effect(
    "processes mixed notification/request batches and omits notification replies",
    () =>
      Effect.gen(function* () {
        const called = yield* Ref.make(0);
        const layer = makeJsonRpcProcessorLayer({
          net_listening: () =>
            Effect.gen(function* () {
              yield* Ref.update(called, (count) => count + 1);
              return true;
            }),
          net_version: () =>
            Effect.gen(function* () {
              yield* Ref.update(called, (count) => count + 1);
              return "1";
            }),
        });

        const response = yield* processJsonRpcPayload([
          {
            jsonrpc: "2.0",
            method: "net_listening",
          },
          {
            jsonrpc: "2.0",
            method: "net_version",
            id: 9,
          },
        ]).pipe(Effect.provide(layer));

        const callCount = yield* Ref.get(called);
        assert.strictEqual(callCount, 2);
        assert.isTrue(Option.isSome(response));
        if (Option.isSome(response)) {
          assert.deepStrictEqual(response.value, [
            {
              jsonrpc: "2.0",
              result: "1",
              id: 9,
            },
          ]);
        }
      }),
  );

  it.effect("returns no response when all batch items are notifications", () =>
    Effect.gen(function* () {
      const called = yield* Ref.make(0);
      const layer = makeJsonRpcProcessorLayer({
        net_listening: () =>
          Effect.gen(function* () {
            yield* Ref.update(called, (count) => count + 1);
            return true;
          }),
      });

      const response = yield* processJsonRpcPayload([
        {
          jsonrpc: "2.0",
          method: "net_listening",
        },
        {
          jsonrpc: "2.0",
          method: "net_listening",
        },
      ]).pipe(Effect.provide(layer));

      const callCount = yield* Ref.get(called);
      assert.strictEqual(callCount, 2);
      assert.isTrue(Option.isNone(response));
    }),
  );

  it.effect("returns invalid request for empty batch payload", () =>
    provideProcessor({})(
      Effect.gen(function* () {
        const response = yield* processJsonRpcPayload([]);

        assert.isTrue(Option.isSome(response));
        if (Option.isSome(response)) {
          assert.deepStrictEqual(response.value, {
            jsonrpc: "2.0",
            error: {
              code: -32600,
              message: "Invalid request",
            },
            id: null,
          });
        }
      }),
    ),
  );

  it.effect("returns per-item invalid request responses in mixed batches", () =>
    provideProcessor({
      net_version: () => Effect.succeed("1"),
    })(
      Effect.gen(function* () {
        const response = yield* processJsonRpcPayload([
          17,
          {
            jsonrpc: "2.0",
            method: "net_version",
            id: 5,
          },
        ]);

        assert.isTrue(Option.isSome(response));
        if (Option.isSome(response)) {
          assert.deepStrictEqual(response.value, [
            {
              jsonrpc: "2.0",
              error: {
                code: -32600,
                message: "Invalid request",
              },
              id: null,
            },
            {
              jsonrpc: "2.0",
              result: "1",
              id: 5,
            },
          ]);
        }
      }),
    ),
  );

  it.effect(
    "normalizes handler defects into internal errors for non-notification requests",
    () =>
      provideProcessor({
        web3_clientVersion: () => Effect.dieMessage("boom"),
      })(
        Effect.gen(function* () {
          const response = yield* processJsonRpcPayload({
            jsonrpc: "2.0",
            method: "web3_clientVersion",
            id: 11,
          });

          assert.isTrue(Option.isSome(response));
          if (Option.isSome(response)) {
            assert.deepStrictEqual(response.value, {
              jsonrpc: "2.0",
              error: {
                code: -32603,
                message: "Internal error",
              },
              id: 11,
            });
          }
        }),
      ),
  );

  it.effect(
    "preserves processor failure-channel errors when response encoding fails",
    () =>
      provideProcessor({
        net_version: () =>
          Effect.succeed(Symbol.for("invalid-json-value") as never),
      })(
        Effect.gen(function* () {
          const result = yield* Effect.either(
            processJsonRpcPayload({
              jsonrpc: "2.0",
              method: "net_version",
              id: 99,
            }),
          );

          assert.isTrue(Either.isLeft(result));
          if (Either.isLeft(result)) {
            assert.strictEqual(result.left._tag, "InvalidJsonRpcResponseError");
          }
        }),
      ),
  );
});
