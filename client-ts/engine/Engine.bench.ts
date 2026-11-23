import * as Effect from "effect/Effect";
import { TsBenchSuite } from "../../scripts/bench-ts-utils";
import {
  EngineCapabilitiesLive,
  ParisEngineCapabilities,
  exchangeCapabilities,
} from "./EngineCapabilities";

const suite = new TsBenchSuite("client-ts/engine");
suite.section("Engine API Capabilities");

const consensusMethods = [
  "engine_newPayloadV1",
  "engine_newPayloadV2",
  "engine_newPayloadV3",
  "engine_forkchoiceUpdatedV1",
  "engine_forkchoiceUpdatedV2",
  "engine_forkchoiceUpdatedV3",
  "engine_getPayloadV1",
  "engine_getPayloadV2",
  "engine_getPayloadV3",
  "engine_getClientVersionV1",
];

const layer = EngineCapabilitiesLive(ParisEngineCapabilities);

await Effect.runPromise(
  Effect.gen(function* () {
    // Warmup
    for (let i = 0; i < 50; i += 1) {
      yield* exchangeCapabilities(consensusMethods);
    }

    const iters = 2_000;
    const t0 = Bun.nanoseconds();
    let count = 0;
    for (let i = 0; i < iters; i += 1) {
      const res = yield* exchangeCapabilities(consensusMethods);
      count += res.length;
    }
    const elapsed = Bun.nanoseconds() - t0;
    if (count === 0) throw new Error("unexpected empty capabilities");
    suite.record("exchangeCapabilities (10 methods)", iters, elapsed);
  }).pipe(Effect.provide(layer)),
);

suite.finish();
