import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import { TxPoolLive, getPendingBlobCount, getPendingCount } from "./TxPool";

describe("TxPool", () => {
  it.effect("returns pending transaction count", () =>
    Effect.gen(function* () {
      const count = yield* getPendingCount();
      assert.strictEqual(count, 12);
    }).pipe(
      Effect.provide(TxPoolLive({ pendingCount: 12, pendingBlobCount: 4 })),
    ),
  );

  it.effect("returns pending blob transaction count", () =>
    Effect.gen(function* () {
      const count = yield* getPendingBlobCount();
      assert.strictEqual(count, 6);
    }).pipe(
      Effect.provide(TxPoolLive({ pendingCount: 3, pendingBlobCount: 6 })),
    ),
  );
});
