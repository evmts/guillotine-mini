import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import * as Ref from "effect/Ref";
import type { JsonRpcRequest } from "./JsonRpcRequest";
import { JsonRpcErrorRegistryLive } from "./JsonRpcErrors";
import { JsonRpcResponseEncoderLive } from "./JsonRpcResponse";
import { JsonRpcServiceLive, sendJsonRpcRequest } from "./JsonRpcService";

const JsonRpcServiceBaseLayer = JsonRpcResponseEncoderLive.pipe(
  Layer.provide(JsonRpcErrorRegistryLive),
);

const provideService =
  (handlers: Parameters<typeof JsonRpcServiceLive>[0]) =>
  <A, E, R>(effect: Effect.Effect<A, E, R>) =>
    effect.pipe(
      Effect.provide(
        JsonRpcServiceLive(handlers).pipe(
          Layer.provideMerge(JsonRpcServiceBaseLayer),
        ),
      ),
    );

describe("JsonRpcService", () => {
  it.effect("dispatches known methods and encodes success responses", () =>
    provideService({
      web3_clientVersion: () => Effect.succeed("guillotine-mini/v0.0.0"),
    })(
      Effect.gen(function* () {
        const request = {
          jsonrpc: "2.0",
          method: "web3_clientVersion",
          params: [],
          id: 1,
        } satisfies JsonRpcRequest;

        const response = yield* sendJsonRpcRequest(request);
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

  it.effect("returns method-not-found for unknown methods", () =>
    provideService({})(
      Effect.gen(function* () {
        const request = {
          jsonrpc: "2.0",
          method: "eth_notImplementedYet",
          id: 42,
        } satisfies JsonRpcRequest;

        const response = yield* sendJsonRpcRequest(request);
        assert.isTrue(Option.isSome(response));
        if (Option.isSome(response)) {
          assert.deepStrictEqual(response.value, {
            jsonrpc: "2.0",
            id: 42,
            error: {
              code: -32601,
              message: "Method not found",
            },
          });
        }
      }),
    ),
  );

  it.effect(
    "supports method name normalization with surrounding whitespace",
    () =>
      provideService({
        net_version: () => Effect.succeed("1"),
      })(
        Effect.gen(function* () {
          const request = {
            jsonrpc: "2.0",
            method: "  net_version  ",
            id: "abc",
          } satisfies JsonRpcRequest;

          const response = yield* sendJsonRpcRequest(request);
          assert.isTrue(Option.isSome(response));
          if (Option.isSome(response)) {
            assert.deepStrictEqual(response.value, {
              jsonrpc: "2.0",
              result: "1",
              id: "abc",
            });
          }
        }),
      ),
  );

  it.effect(
    "does not return responses for notifications but executes handlers",
    () =>
      Effect.gen(function* () {
        const called = yield* Ref.make(0);
        const serviceLayer = JsonRpcServiceLive({
          net_version: () =>
            Effect.gen(function* () {
              yield* Ref.update(called, (count) => count + 1);
              return "1";
            }),
        }).pipe(Layer.provideMerge(JsonRpcServiceBaseLayer));

        const request = {
          jsonrpc: "2.0",
          method: "net_version",
        } satisfies JsonRpcRequest;

        const response = yield* sendJsonRpcRequest(request).pipe(
          Effect.provide(serviceLayer),
        );
        const callCount = yield* Ref.get(called);

        assert.isTrue(Option.isNone(response));
        assert.strictEqual(callCount, 1);
      }),
  );

  it.effect("does not return errors for unknown method notifications", () =>
    provideService({})(
      Effect.gen(function* () {
        const request = {
          jsonrpc: "2.0",
          method: "eth_notImplementedYet",
        } satisfies JsonRpcRequest;

        const response = yield* sendJsonRpcRequest(request);
        assert.isTrue(Option.isNone(response));
      }),
    ),
  );
});
