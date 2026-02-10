import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import {
  FullSyncPeerRequestLimitsLive,
  resolveFullSyncPeerRequestLimits,
} from "./FullSyncPeerRequestLimits";

const provideLimits = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
  effect.pipe(Effect.provide(FullSyncPeerRequestLimitsLive));

describe("FullSyncPeerRequestLimits", () => {
  it.effect("maps Geth-family clients to Geth limits", () =>
    provideLimits(
      Effect.gen(function* () {
        const reth = yield* resolveFullSyncPeerRequestLimits("Reth/v1.3.0");
        assert.deepStrictEqual(reth, {
          maxHeadersPerRequest: 192,
          maxBodiesPerRequest: 128,
          maxReceiptsPerRequest: 256,
        });

        const erigon =
          yield* resolveFullSyncPeerRequestLimits("Erigon/v3.0.0-rc");
        assert.deepStrictEqual(erigon, {
          maxHeadersPerRequest: 192,
          maxBodiesPerRequest: 128,
          maxReceiptsPerRequest: 256,
        });

        const trinity =
          yield* resolveFullSyncPeerRequestLimits("Trinity/v0.1.0");
        assert.deepStrictEqual(trinity, {
          maxHeadersPerRequest: 192,
          maxBodiesPerRequest: 128,
          maxReceiptsPerRequest: 256,
        });
      }),
    ),
  );

  it.effect("maps Besu peers to Besu limits", () =>
    provideLimits(
      Effect.gen(function* () {
        const limits = yield* resolveFullSyncPeerRequestLimits("Besu/v24.1.1");

        assert.deepStrictEqual(limits, {
          maxHeadersPerRequest: 512,
          maxBodiesPerRequest: 128,
          maxReceiptsPerRequest: 256,
        });
      }),
    ),
  );

  it.effect("maps Nethermind peers to Nethermind limits", () =>
    provideLimits(
      Effect.gen(function* () {
        const limits =
          yield* resolveFullSyncPeerRequestLimits("Nethermind/v1.29.0");

        assert.deepStrictEqual(limits, {
          maxHeadersPerRequest: 512,
          maxBodiesPerRequest: 256,
          maxReceiptsPerRequest: 256,
        });
      }),
    ),
  );

  it.effect("maps Parity-family peers to Parity limits", () =>
    provideLimits(
      Effect.gen(function* () {
        const openEthereum = yield* resolveFullSyncPeerRequestLimits(
          "OpenEthereum/v3.3.5",
        );
        assert.deepStrictEqual(openEthereum, {
          maxHeadersPerRequest: 1024,
          maxBodiesPerRequest: 256,
          maxReceiptsPerRequest: 256,
        });

        const parity = yield* resolveFullSyncPeerRequestLimits(
          "Parity-Ethereum/v2.7.2",
        );
        assert.deepStrictEqual(parity, {
          maxHeadersPerRequest: 1024,
          maxBodiesPerRequest: 256,
          maxReceiptsPerRequest: 256,
        });
      }),
    ),
  );

  it.effect("falls back to conservative unknown-client limits", () =>
    provideLimits(
      Effect.gen(function* () {
        const unknown = yield* resolveFullSyncPeerRequestLimits("Lighthouse");
        assert.deepStrictEqual(unknown, {
          maxHeadersPerRequest: 192,
          maxBodiesPerRequest: 32,
          maxReceiptsPerRequest: 128,
        });

        const missing = yield* resolveFullSyncPeerRequestLimits(undefined);
        assert.deepStrictEqual(missing, {
          maxHeadersPerRequest: 192,
          maxBodiesPerRequest: 32,
          maxReceiptsPerRequest: 128,
        });
      }),
    ),
  );

  it.effect(
    "normalizes casing and surrounding whitespace before classification",
    () =>
      provideLimits(
        Effect.gen(function* () {
          const limits = yield* resolveFullSyncPeerRequestLimits(
            "  gEtH/v1.15.11-stable  ",
          );

          assert.deepStrictEqual(limits, {
            maxHeadersPerRequest: 192,
            maxBodiesPerRequest: 128,
            maxReceiptsPerRequest: 256,
          });
        }),
      ),
  );
});
