import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import { Hardfork } from "voltaire-effect/primitives";
import { ReleaseSpec, ReleaseSpecLive, ReleaseSpecPrague } from "./ReleaseSpec";

const provideSpec =
  (hardfork: Hardfork.HardforkType) =>
  <A, E, R>(effect: Effect.Effect<A, E, R>) =>
    effect.pipe(Effect.provide(ReleaseSpecLive(hardfork)));

const providePrague = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
  effect.pipe(Effect.provide(ReleaseSpecPrague));

describe("ReleaseSpec", () => {
  it.effect("sets feature flags for Frontier", () =>
    provideSpec(Hardfork.FRONTIER)(
      Effect.gen(function* () {
        const spec = yield* ReleaseSpec;
        assert.strictEqual(spec.hardfork, Hardfork.FRONTIER);
        assert.strictEqual(spec.isEip2028Enabled, false);
        assert.strictEqual(spec.isEip2930Enabled, false);
        assert.strictEqual(spec.isEip3529Enabled, false);
        assert.strictEqual(spec.isEip3651Enabled, false);
        assert.strictEqual(spec.isEip3860Enabled, false);
        assert.strictEqual(spec.isEip7623Enabled, false);
        assert.strictEqual(spec.isEip7702Enabled, false);
      }),
    ),
  );

  it.effect("exposes Prague hardfork flags", () =>
    providePrague(
      Effect.gen(function* () {
        const spec = yield* ReleaseSpec;
        assert.strictEqual(spec.hardfork, Hardfork.PRAGUE);
        assert.strictEqual(spec.isEip2028Enabled, true);
        assert.strictEqual(spec.isEip2930Enabled, true);
        assert.strictEqual(spec.isEip3529Enabled, true);
        assert.strictEqual(spec.isEip3651Enabled, true);
        assert.strictEqual(spec.isEip3860Enabled, true);
        assert.strictEqual(spec.isEip7623Enabled, true);
        assert.strictEqual(spec.isEip7702Enabled, true);
      }),
    ),
  );
});
