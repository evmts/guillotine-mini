import { assert, describe, it } from "@effect/vitest";
import * as Either from "effect/Either";
import * as Effect from "effect/Effect";
import {
  BlobsSupportMode,
  InvalidTxPoolConfigError,
  TxPoolConfigDefaults,
  TxPoolLive,
  acceptTxWhenNotSynced,
  getPendingBlobCount,
  getPendingCount,
  supportsBlobs,
} from "./TxPool";

describe("TxPool", () => {
  it.effect("returns pending transaction count", () =>
    Effect.gen(function* () {
      const count = yield* getPendingCount();
      assert.strictEqual(count, 0);
    }).pipe(Effect.provide(TxPoolLive(TxPoolConfigDefaults))),
  );

  it.effect("returns pending blob transaction count", () =>
    Effect.gen(function* () {
      const count = yield* getPendingBlobCount();
      assert.strictEqual(count, 0);
    }).pipe(Effect.provide(TxPoolLive(TxPoolConfigDefaults))),
  );

  it.effect("derives blob support from configuration", () =>
    Effect.gen(function* () {
      const enabled = yield* supportsBlobs();
      assert.isTrue(enabled);
    }).pipe(Effect.provide(TxPoolLive(TxPoolConfigDefaults))),
  );

  it.effect("returns false when blob support is disabled", () =>
    Effect.gen(function* () {
      const enabled = yield* supportsBlobs();
      assert.isFalse(enabled);
    }).pipe(
      Effect.provide(
        TxPoolLive({
          ...TxPoolConfigDefaults,
          blobsSupport: BlobsSupportMode.Disabled,
        }),
      ),
    ),
  );

  it.effect("derives accept-tx-when-not-synced from configuration", () =>
    Effect.gen(function* () {
      const allowed = yield* acceptTxWhenNotSynced();
      assert.isFalse(allowed);
    }).pipe(Effect.provide(TxPoolLive(TxPoolConfigDefaults))),
  );

  it.effect("returns true when accept-tx-when-not-synced is enabled", () =>
    Effect.gen(function* () {
      const allowed = yield* acceptTxWhenNotSynced();
      assert.isTrue(allowed);
    }).pipe(
      Effect.provide(
        TxPoolLive({
          ...TxPoolConfigDefaults,
          acceptTxWhenNotSynced: true,
        }),
      ),
    ),
  );

  it.effect("fails when configuration is invalid", () =>
    Effect.gen(function* () {
      const outcome = yield* Effect.either(
        getPendingCount().pipe(
          Effect.provide(TxPoolLive({ ...TxPoolConfigDefaults, size: -1 })),
        ),
      );
      assert.isTrue(Either.isLeft(outcome));
      if (Either.isLeft(outcome)) {
        assert.isTrue(outcome.left instanceof InvalidTxPoolConfigError);
      }
    }),
  );
});
