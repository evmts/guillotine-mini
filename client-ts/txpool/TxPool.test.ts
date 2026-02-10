import { assert, describe, it } from "@effect/vitest";
import * as Either from "effect/Either";
import * as Effect from "effect/Effect";
import {
  InvalidTxPoolConfigError,
  TxPoolConfigDefaults,
  TxPoolLive,
  getPendingBlobCount,
  getPendingCount,
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
