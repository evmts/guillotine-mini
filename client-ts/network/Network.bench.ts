import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import { Bytes } from "voltaire-effect/primitives";
import { TsBenchSuite } from "../../scripts/bench-ts-utils";
import {
  RlpxSnappyLengthValidatorLive,
  RlpxSnappyLengthValidator,
} from "./RlpxSnappyLengthValidator";
import {
  RlpxHelloCapabilityNegotiatorLive,
  negotiateRlpxHelloCapabilities,
} from "./RlpxHelloCapabilityNegotiator";

const suite = new TsBenchSuite("client-ts/network");
suite.section("RLPx Snappy & Hello Capability Negotiation");

const snappyPayload = new Uint8Array([0x80, 0x80, 0x04, 0x00, 0x00]) as ReturnType<typeof Bytes.random>; // 65536 bytes
const localCaps = [
  { name: "eth", version: 68, messageIdSpaceSize: 17 },
  { name: "eth", version: 69, messageIdSpaceSize: 17 },
  { name: "snap", version: 1, messageIdSpaceSize: 8 },
];
const remoteCaps = [
  { name: "eth", version: 67 },
  { name: "eth", version: 68 },
  { name: "eth", version: 69 },
  { name: "snap", version: 1 },
];

const layer = Layer.mergeAll(
  RlpxSnappyLengthValidatorLive,
  RlpxHelloCapabilityNegotiatorLive,
);

await Effect.runPromise(
  Effect.gen(function* () {
    const validator = yield* RlpxSnappyLengthValidator;

    // Warmup
    for (let i = 0; i < 100; i += 1) {
      yield* validator.validateUncompressedLength(snappyPayload);
      yield* negotiateRlpxHelloCapabilities(localCaps, remoteCaps);
    }

    const snappyIters = 10_000;
    let t0 = Bun.nanoseconds();
    let totalLen = 0;
    for (let i = 0; i < snappyIters; i += 1) {
      totalLen += yield* validator.validateUncompressedLength(snappyPayload);
    }
    let elapsed = Bun.nanoseconds() - t0;
    if (totalLen === 0) throw new Error("unexpected zero");
    suite.record("RlpxSnappyLengthValidator (64KB header)", snappyIters, elapsed);

    const negIters = 2_000;
    t0 = Bun.nanoseconds();
    let capCount = 0;
    for (let i = 0; i < negIters; i += 1) {
      const res = yield* negotiateRlpxHelloCapabilities(localCaps, remoteCaps);
      capCount += res.negotiatedCapabilities.length;
    }
    elapsed = Bun.nanoseconds() - t0;
    if (capCount === 0) throw new Error("unexpected zero");
    suite.record("negotiateRlpxHelloCapabilities (eth+snap)", negIters, elapsed);
  }).pipe(Effect.provide(layer)),
);

suite.finish();
