import * as Context from "effect/Context";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import { Address, Hardfork, Hex } from "voltaire-effect/primitives";

/** Hardfork-driven feature flags for EVM behavior. */
export interface ReleaseSpecService {
  readonly hardfork: Hardfork.HardforkType;
  readonly isEip2028Enabled: boolean;
  readonly isEip2930Enabled: boolean;
  readonly isEip3529Enabled: boolean;
  readonly isEip3651Enabled: boolean;
  readonly isEip3860Enabled: boolean;
  readonly isEip2935Enabled: boolean;
  readonly isEip7709Enabled: boolean;
  readonly isBlockHashInStateAvailable: boolean;
  readonly eip2935ContractAddress: Address.AddressType;
  readonly eip2935RingBufferSize: bigint;
  readonly isEip7623Enabled: boolean;
  readonly isEip7702Enabled: boolean;
}

/** Context tag for the release specification service. */
export class ReleaseSpec extends Context.Tag("ReleaseSpec")<
  ReleaseSpec,
  ReleaseSpecService
>() {}

const AddressBytesSchema = Address.Bytes as unknown as Schema.Schema<
  Address.AddressType,
  Uint8Array
>;
const EIP2935_CONTRACT_ADDRESS_HEX =
  "0x0000F90827F1C53a10cb7A02335B175320002935";
export const EIP2935_CONTRACT_ADDRESS = Schema.decodeSync(AddressBytesSchema)(
  Hex.toBytes(EIP2935_CONTRACT_ADDRESS_HEX) as Uint8Array,
);
export const EIP2935_RING_BUFFER_SIZE = 8191n;

export type ReleaseSpecOverrides = Partial<
  Omit<ReleaseSpecService, "hardfork" | "isBlockHashInStateAvailable">
> & {
  readonly isBlockHashInStateAvailable?: boolean;
};

const makeReleaseSpec = (
  hardfork: Hardfork.HardforkType,
  overrides: ReleaseSpecOverrides = {},
): ReleaseSpecService => {
  const base = {
    hardfork,
    isEip2028Enabled: Hardfork.isAtLeast(hardfork, Hardfork.ISTANBUL),
    isEip2930Enabled: Hardfork.isAtLeast(hardfork, Hardfork.BERLIN),
    isEip3529Enabled: Hardfork.isAtLeast(hardfork, Hardfork.LONDON),
    isEip3651Enabled: Hardfork.isAtLeast(hardfork, Hardfork.SHANGHAI),
    isEip3860Enabled: Hardfork.isAtLeast(hardfork, Hardfork.SHANGHAI),
    isEip2935Enabled: Hardfork.isAtLeast(hardfork, Hardfork.PRAGUE),
    isEip7709Enabled: false,
    eip2935ContractAddress: EIP2935_CONTRACT_ADDRESS,
    eip2935RingBufferSize: EIP2935_RING_BUFFER_SIZE,
    isEip7623Enabled: Hardfork.isAtLeast(hardfork, Hardfork.PRAGUE),
    isEip7702Enabled: Hardfork.isAtLeast(hardfork, Hardfork.PRAGUE),
  } satisfies Omit<ReleaseSpecService, "isBlockHashInStateAvailable">;

  const spec = {
    ...base,
    ...overrides,
  } satisfies Omit<ReleaseSpecService, "isBlockHashInStateAvailable">;

  return {
    ...spec,
    isBlockHashInStateAvailable:
      overrides.isBlockHashInStateAvailable ?? spec.isEip7709Enabled,
  } satisfies ReleaseSpecService;
};

/** Build a release spec layer for a specific hardfork. */
export const ReleaseSpecLive = (
  hardfork: Hardfork.HardforkType,
  overrides?: ReleaseSpecOverrides,
) => Layer.succeed(ReleaseSpec, makeReleaseSpec(hardfork, overrides));

/** Prague hardfork release spec layer. */
export const ReleaseSpecPrague: Layer.Layer<ReleaseSpec> = ReleaseSpecLive(
  Hardfork.PRAGUE,
);
