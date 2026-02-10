import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import {
  InvalidRpcServerConfigError,
  RpcServerConfigDefaults,
  RpcServerConfigLive,
  effectiveWebsocketPort,
} from "./RpcServerConfig";

describe("RpcServerConfig", () => {
  it.effect("defaults websocket port to http port", () =>
    Effect.gen(function* () {
      const port = yield* effectiveWebsocketPort();
      assert.strictEqual(port, 8545);
    }).pipe(Effect.provide(RpcServerConfigLive(RpcServerConfigDefaults))),
  );

  it.effect("respects websocket port override", () =>
    Effect.gen(function* () {
      const port = yield* effectiveWebsocketPort();
      assert.strictEqual(port, 9546);
    }).pipe(
      Effect.provide(
        RpcServerConfigLive({
          ...RpcServerConfigDefaults,
          websocketPort: 9546,
        }),
      ),
    ),
  );

  it.effect("fails when configuration is invalid", () =>
    Effect.gen(function* () {
      const outcome = yield* Effect.either(
        effectiveWebsocketPort().pipe(
          Effect.provide(
            RpcServerConfigLive({
              ...RpcServerConfigDefaults,
              port: -1,
            }),
          ),
        ),
      );
      assert.isTrue(Either.isLeft(outcome));
      if (Either.isLeft(outcome)) {
        assert.isTrue(outcome.left instanceof InvalidRpcServerConfigError);
      }
    }),
  );
});
