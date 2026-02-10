import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import {
  Address,
  Hardfork,
  Hex,
  Storage,
  Transaction,
} from "voltaire-effect/primitives";
import {
  AccessListBuilderLive,
  AccessListBuilderTest,
  buildAccessList,
  UnsupportedAccessListFeatureError,
} from "./AccessListBuilder";
import { ReleaseSpecLive } from "./ReleaseSpec";

const provideBuilder = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
  effect.pipe(Effect.provide(AccessListBuilderTest));

const AccessListBuilderFrontier = AccessListBuilderLive.pipe(
  Layer.provide(ReleaseSpecLive(Hardfork.FRONTIER)),
);
const AccessListBuilderLondon = AccessListBuilderLive.pipe(
  Layer.provide(ReleaseSpecLive(Hardfork.LONDON)),
);

const provideFrontierBuilder = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
  effect.pipe(Effect.provide(AccessListBuilderFrontier));
const provideLondonBuilder = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
  effect.pipe(Effect.provide(AccessListBuilderLondon));

const LegacySchema = Transaction.LegacySchema as unknown as Schema.Schema<
  Transaction.Legacy,
  unknown
>;
const Eip2930Schema = Transaction.EIP2930Schema as unknown as Schema.Schema<
  Transaction.EIP2930,
  unknown
>;
type StorageSlotType = Schema.Schema.Type<typeof Storage.StorageSlotSchema>;

const makeAddress = (lastByte: number): Address.AddressType => {
  const addr = Address.zero();
  addr[addr.length - 1] = lastByte;
  return addr;
};

const makeSlot = (lastByte: number): StorageSlotType => {
  const slot = new Uint8Array(32);
  slot[slot.length - 1] = lastByte;
  return slot as StorageSlotType;
};

const encodeAddress = (address: Address.AddressType): string =>
  Hex.fromBytes(address);

const EMPTY_SIGNATURE = {
  r: new Uint8Array(32),
  s: new Uint8Array(32),
};

const makeLegacyTx = (): Transaction.Legacy =>
  Schema.decodeSync(LegacySchema)({
    type: Transaction.Type.Legacy,
    nonce: 0n,
    gasPrice: 1n,
    gasLimit: 100_000n,
    to: encodeAddress(Address.zero()),
    value: 0n,
    data: new Uint8Array(0),
    v: 27n,
    r: EMPTY_SIGNATURE.r,
    s: EMPTY_SIGNATURE.s,
  });

const makeAccessListTx = (
  accessList: Transaction.EIP2930["accessList"],
): Transaction.EIP2930 =>
  Schema.decodeSync(Eip2930Schema)({
    type: Transaction.Type.EIP2930,
    chainId: 1n,
    nonce: 0n,
    gasPrice: 1n,
    gasLimit: 100_000n,
    to: encodeAddress(Address.zero()),
    value: 0n,
    data: new Uint8Array(0),
    accessList: accessList.map((entry) => ({
      address: encodeAddress(entry.address),
      storageKeys: entry.storageKeys,
    })),
    yParity: 0,
    r: EMPTY_SIGNATURE.r,
    s: EMPTY_SIGNATURE.s,
  });

describe("AccessListBuilder.buildAccessList", () => {
  it.effect("includes only coinbase for legacy transaction", () =>
    provideBuilder(
      Effect.gen(function* () {
        const coinbase = makeAddress(0xaa);
        const tx = makeLegacyTx();
        const result = yield* buildAccessList(tx, coinbase);

        assert.strictEqual(result.addresses.length, 1);
        const first = result.addresses[0];
        if (!first) {
          throw new Error("missing coinbase address");
        }
        assert.isTrue(Address.equals(first, coinbase));
        assert.strictEqual(result.storageKeys.length, 0);
      }),
    ),
  );

  it.effect("skips coinbase warmup before Shanghai", () =>
    provideLondonBuilder(
      Effect.gen(function* () {
        const coinbase = makeAddress(0xaa);
        const tx = makeLegacyTx();
        const result = yield* buildAccessList(tx, coinbase);

        assert.strictEqual(result.addresses.length, 0);
        assert.strictEqual(result.storageKeys.length, 0);
      }),
    ),
  );

  it.effect("deduplicates addresses and storage keys", () =>
    provideBuilder(
      Effect.gen(function* () {
        const coinbase = makeAddress(0xaa);
        const addr1 = makeAddress(0x01);
        const addr2 = makeAddress(0x02);
        const slot1 = makeSlot(0x01);
        const slot2 = makeSlot(0x02);
        const accessList: Transaction.EIP2930["accessList"] = [
          { address: addr1, storageKeys: [slot1, slot2] },
          { address: addr1, storageKeys: [slot1] },
          { address: addr2, storageKeys: [] },
          { address: coinbase, storageKeys: [] },
        ];
        const tx = makeAccessListTx(accessList);
        const result = yield* buildAccessList(tx, coinbase);

        const addressHexes = result.addresses.map(Hex.fromBytes);
        assert.strictEqual(result.addresses.length, 3);
        assert.isTrue(addressHexes.includes(Hex.fromBytes(coinbase)));
        assert.isTrue(addressHexes.includes(Hex.fromBytes(addr1)));
        assert.isTrue(addressHexes.includes(Hex.fromBytes(addr2)));

        const storageKeyIds = result.storageKeys.map(
          (entry) =>
            `${Hex.fromBytes(entry.address)}:${Hex.fromBytes(entry.slot)}`,
        );
        assert.strictEqual(storageKeyIds.length, 2);
        assert.isTrue(
          storageKeyIds.includes(
            `${Hex.fromBytes(addr1)}:${Hex.fromBytes(slot1)}`,
          ),
        );
        assert.isTrue(
          storageKeyIds.includes(
            `${Hex.fromBytes(addr1)}:${Hex.fromBytes(slot2)}`,
          ),
        );
      }),
    ),
  );

  it.effect("fails when access lists are unsupported", () =>
    provideFrontierBuilder(
      Effect.gen(function* () {
        const coinbase = makeAddress(0xaa);
        const tx = makeAccessListTx([]);
        const outcome = yield* Effect.either(buildAccessList(tx, coinbase));

        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(
            outcome.left instanceof UnsupportedAccessListFeatureError,
          );
        }
      }),
    ),
  );
});
