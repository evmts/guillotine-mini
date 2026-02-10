import * as Context from "effect/Context";
import * as Layer from "effect/Layer";
import { Hardfork } from "voltaire-effect/primitives";

/** Hardfork-driven feature flags for EVM behavior. */
export interface ReleaseSpecService {
  readonly hardfork: Hardfork.HardforkType;
  readonly isEip2028Enabled: boolean;
  readonly isEip2930Enabled: boolean;
  readonly isEip3651Enabled: boolean;
  readonly isEip3860Enabled: boolean;
  readonly isEip7623Enabled: boolean;
  readonly isEip7702Enabled: boolean;
}

/** Context tag for the release specification service. */
export class ReleaseSpec extends Context.Tag("ReleaseSpec")<
  ReleaseSpec,
  ReleaseSpecService
>() {}

const makeReleaseSpec = (
  hardfork: Hardfork.HardforkType,
): ReleaseSpecService => ({
  hardfork,
  isEip2028Enabled: Hardfork.isAtLeast(hardfork, Hardfork.ISTANBUL),
  isEip2930Enabled: Hardfork.isAtLeast(hardfork, Hardfork.BERLIN),
  isEip3651Enabled: Hardfork.isAtLeast(hardfork, Hardfork.SHANGHAI),
  isEip3860Enabled: Hardfork.isAtLeast(hardfork, Hardfork.SHANGHAI),
  isEip7623Enabled: Hardfork.isAtLeast(hardfork, Hardfork.PRAGUE),
  isEip7702Enabled: Hardfork.isAtLeast(hardfork, Hardfork.PRAGUE),
});

/** Build a release spec layer for a specific hardfork. */
export const ReleaseSpecLive = (hardfork: Hardfork.HardforkType) =>
  Layer.succeed(ReleaseSpec, makeReleaseSpec(hardfork));

/** Prague hardfork release spec layer. */
export const ReleaseSpecPrague: Layer.Layer<ReleaseSpec> = ReleaseSpecLive(
  Hardfork.PRAGUE,
);
