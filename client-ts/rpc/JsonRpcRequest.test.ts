import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import {
  decodeJsonRpcRequest,
  InvalidJsonRpcRequestError,
  JsonRpcRequestDecoderLive,
} from "./JsonRpcRequest";

describe("JsonRpcRequest", () => {
  it.effect("decodes request with array params", () =>
    Effect.gen(function* () {
      const request = yield* decodeJsonRpcRequest({
        jsonrpc: "2.0",
        method: "web3_clientVersion",
        params: [],
        id: 1,
      });

      assert.strictEqual(request.jsonrpc, "2.0");
      assert.strictEqual(request.method, "web3_clientVersion");
      assert.deepStrictEqual(request.params, []);
      assert.strictEqual(request.id, 1);
    }).pipe(Effect.provide(JsonRpcRequestDecoderLive)),
  );

  it.effect("decodes request with object params and no id", () =>
    Effect.gen(function* () {
      const request = yield* decodeJsonRpcRequest({
        jsonrpc: "2.0",
        method: "eth_getBalance",
        params: { address: "0xdeadbeef" },
      });

      assert.deepStrictEqual(request.params, { address: "0xdeadbeef" });
      assert.isUndefined(request.id);
    }).pipe(Effect.provide(JsonRpcRequestDecoderLive)),
  );

  it.effect("rejects invalid jsonrpc version", () =>
    Effect.gen(function* () {
      const outcome = yield* Effect.either(
        decodeJsonRpcRequest({
          jsonrpc: "1.0",
          method: "web3_clientVersion",
          params: [],
        }).pipe(Effect.provide(JsonRpcRequestDecoderLive)),
      );

      assert.isTrue(Either.isLeft(outcome));
      if (Either.isLeft(outcome)) {
        assert.isTrue(outcome.left instanceof InvalidJsonRpcRequestError);
      }
    }),
  );

  it.effect("rejects empty method", () =>
    Effect.gen(function* () {
      const outcome = yield* Effect.either(
        decodeJsonRpcRequest({
          jsonrpc: "2.0",
          method: "",
          params: [],
        }).pipe(Effect.provide(JsonRpcRequestDecoderLive)),
      );

      assert.isTrue(Either.isLeft(outcome));
      if (Either.isLeft(outcome)) {
        assert.isTrue(outcome.left instanceof InvalidJsonRpcRequestError);
      }
    }),
  );
});
