import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import { Hex } from "voltaire-effect/primitives";
import type { BlockHash } from "voltaire-effect/primitives";
import { TsBenchSuite } from "../../scripts/bench-ts-utils";
import {
  FullSyncPeerRequestLimitsLive,
  resolveFullSyncPeerRequestLimits,
} from "./FullSyncPeerRequestLimits";
import {
  FullSyncRequestPlannerLive,
  planFullSyncHeaderRequests,
  planFullSyncBodyRequests,
  planFullSyncReceiptRequests,
} from "./FullSyncRequestPlanner";

const suite = new TsBenchSuite("client-ts/sync");
suite.section("Full Sync Request Planning");

const hashes = Array.from({ length: 256 }, (_, i) =>
  Hex.toBytes(`0x${i.toString(16).padStart(64, "0")}`) as BlockHash.BlockHashType,
);

const layer = FullSyncRequestPlannerLive.pipe(
  Layer.provideMerge(FullSyncPeerRequestLimitsLive),
);

await Effect.runPromise(
  Effect.gen(function* () {
    // Warmup
    for (let i = 0; i < 50; i += 1) {
      yield* resolveFullSyncPeerRequestLimits("Geth/v1.14.0-stable/linux-amd64");
      yield* planFullSyncHeaderRequests({
        peerClientId: "Geth/v1.14.0",
        protocolVersion: 68,
        startBlockNumber: 1_000_000n,
        totalHeaders: 2048,
        initialRequestId: 1n,
      });
    }

    const limitIters = 10_000;
    let t0 = Bun.nanoseconds();
    let sink = 0;
    for (let i = 0; i < limitIters; i += 1) {
      const lim = yield* resolveFullSyncPeerRequestLimits(
        i % 2 === 0 ? "Geth/v1.14.0" : "Nethermind/v1.28.0",
      );
      sink += lim.maxHeadersPerRequest;
    }
    let elapsed = Bun.nanoseconds() - t0;
    if (sink === 0) throw new Error("unexpected");
    suite.record("resolveFullSyncPeerRequestLimits", limitIters, elapsed);

    const headerIters = 2_000;
    t0 = Bun.nanoseconds();
    let batches = 0;
    for (let i = 0; i < headerIters; i += 1) {
      const res = yield* planFullSyncHeaderRequests({
        peerClientId: "Nethermind/v1.28.0",
        protocolVersion: 68,
        startBlockNumber: 1_000_000n + BigInt(i * 100),
        totalHeaders: 2048,
        initialRequestId: 1n,
      });
      batches += res.length;
    }
    elapsed = Bun.nanoseconds() - t0;
    if (batches === 0) throw new Error("unexpected");
    suite.record("planFullSyncHeaderRequests (2048 headers)", headerIters, elapsed);

    const bodyIters = 2_000;
    t0 = Bun.nanoseconds();
    batches = 0;
    for (let i = 0; i < bodyIters; i += 1) {
      const res = yield* planFullSyncBodyRequests({
        peerClientId: "Geth/v1.14.0",
        protocolVersion: 68,
        blockHashes: hashes,
        initialRequestId: 1n,
      });
      batches += res.length;
    }
    elapsed = Bun.nanoseconds() - t0;
    if (batches === 0) throw new Error("unexpected");
    suite.record("planFullSyncBodyRequests (256 hashes)", bodyIters, elapsed);

    const rcptIters = 2_000;
    t0 = Bun.nanoseconds();
    batches = 0;
    for (let i = 0; i < rcptIters; i += 1) {
      const res = yield* planFullSyncReceiptRequests({
        peerClientId: "Reth/v1.0.0",
        protocolVersion: 70,
        blockHashes: hashes,
        initialRequestId: 1n,
      });
      batches += res.length;
    }
    elapsed = Bun.nanoseconds() - t0;
    if (batches === 0) throw new Error("unexpected");
    suite.record("planFullSyncReceiptRequests (256 hashes, eth/70)", rcptIters, elapsed);
  }).pipe(Effect.provide(layer)),
);

suite.finish();
