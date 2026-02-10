import { assert, describe, it } from "@effect/vitest";
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

  it.effect("returns invalid request when payload is not an object", () =>
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
});
