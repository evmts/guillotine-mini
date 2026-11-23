import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import { TsBenchSuite } from "../../scripts/bench-ts-utils";
import { JsonRpcErrorRegistryLive } from "./JsonRpcErrors";
import { JsonRpcRequestDecoderLive } from "./JsonRpcRequest";
import { JsonRpcResponseEncoderLive } from "./JsonRpcResponse";
import { JsonRpcServiceLive } from "./JsonRpcService";
import { JsonRpcProcessorLive, processJsonRpcPayload } from "./JsonRpcProcessor";

const suite = new TsBenchSuite("client-ts/rpc");
suite.section("JSON-RPC Decode, Dispatch & Encode");

const encoderLayer = JsonRpcResponseEncoderLive.pipe(
  Layer.provideMerge(JsonRpcErrorRegistryLive),
);
const serviceLayer = JsonRpcServiceLive({
  eth_chainId: () => Effect.succeed("0x1"),
  eth_blockNumber: () => Effect.succeed("0x123456"),
  eth_gasPrice: () => Effect.succeed("0x3b9aca00"),
}).pipe(Layer.provideMerge(encoderLayer));

const processorLayer = JsonRpcProcessorLive.pipe(
  Layer.provideMerge(JsonRpcRequestDecoderLive),
  Layer.provideMerge(serviceLayer),
);

const singleJson = JSON.stringify({
  jsonrpc: "2.0",
  method: "eth_blockNumber",
  params: [],
  id: 1,
});
const batchJson = JSON.stringify(
  Array.from({ length: 10 }, (_, i) => ({
    jsonrpc: "2.0",
    method: i % 2 === 0 ? "eth_blockNumber" : "eth_chainId",
    params: [],
    id: i + 1,
  })),
);

await Effect.runPromise(
  Effect.gen(function* () {
    // Warmup
    for (let i = 0; i < 50; i += 1) {
      yield* processJsonRpcPayload(singleJson);
      yield* processJsonRpcPayload(batchJson);
    }

    const singleIters = 2_000;
    let t0 = Bun.nanoseconds();
    let count = 0;
    for (let i = 0; i < singleIters; i += 1) {
      const res = yield* processJsonRpcPayload(singleJson);
      if (Option.isSome(res)) count += 1;
    }
    let elapsed = Bun.nanoseconds() - t0;
    if (count !== singleIters) throw new Error("unexpected");
    suite.record("processJsonRpcPayload (single eth_blockNumber)", singleIters, elapsed);

    const batchIters = 300;
    t0 = Bun.nanoseconds();
    count = 0;
    for (let i = 0; i < batchIters; i += 1) {
      const res = yield* processJsonRpcPayload(batchJson);
      if (Option.isSome(res)) count += 1;
    }
    elapsed = Bun.nanoseconds() - t0;
    if (count !== batchIters) throw new Error("unexpected");
    suite.record("processJsonRpcPayload (10-item JSON-RPC batch)", batchIters, elapsed);
  }).pipe(Effect.provide(processorLayer)),
);

suite.finish();
