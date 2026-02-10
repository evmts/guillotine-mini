import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import { Address, Hex, Storage, Transaction } from "voltaire-effect/primitives";
import {
  ReleaseSpec,
  ReleaseSpecPrague,
  type ReleaseSpecService,
} from "./ReleaseSpec";

/** Hex-encoded key for access list indexing. */
type HexKey = Parameters<typeof Hex.equals>[0];
/** Canonical storage slot type. */
type StorageSlotType = Schema.Schema.Type<typeof Storage.StorageSlotSchema>;

/** Access list storage key entry (address + slot). */
export type AccessListStorageKey = {
  readonly address: Address.AddressType;
  readonly slot: StorageSlotType;
};

/** Access list prewarm result. */
export type TransactionAccessList = {
  readonly addresses: ReadonlyArray<Address.AddressType>;
  readonly storageKeys: ReadonlyArray<AccessListStorageKey>;
};

const TransactionSchema = Transaction.Schema as unknown as Schema.Schema<
  Transaction.Any,
  unknown
>;

/** Error raised when transaction decoding fails. */
export class InvalidTransactionError extends Data.TaggedError(
  "InvalidTransactionError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Error raised when access list features are unavailable. */
export class UnsupportedAccessListFeatureError extends Data.TaggedError(
  "UnsupportedAccessListFeatureError",
)<{
  readonly feature: string;
  readonly hardfork: ReleaseSpecService["hardfork"];
}> {}

/** Union of access list builder errors. */
export type AccessListBuilderError =
  | InvalidTransactionError
  | UnsupportedAccessListFeatureError;

/** Access list builder service interface. */
export interface AccessListBuilderService {
  readonly buildAccessList: (
    tx: Transaction.Any,
    coinbase: Address.AddressType,
  ) => Effect.Effect<TransactionAccessList, AccessListBuilderError>;
}

/** Context tag for the access list builder service. */
export class AccessListBuilder extends Context.Tag("AccessListBuilder")<
  AccessListBuilder,
  AccessListBuilderService
>() {}

const decodeTransaction = (tx: Transaction.Any) =>
  Schema.validate(TransactionSchema)(tx).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidTransactionError({
          message: "Invalid transaction",
          cause,
        }),
    ),
  );

const requiresAccessListSupport = (tx: Transaction.Any): boolean =>
  Transaction.isEIP2930(tx) ||
  Transaction.isEIP1559(tx) ||
  Transaction.isEIP4844(tx) ||
  Transaction.isEIP7702(tx);

const ensureAccessListSupport = (
  tx: Transaction.Any,
  spec: ReleaseSpecService,
): Effect.Effect<void, UnsupportedAccessListFeatureError> =>
  requiresAccessListSupport(tx) && !spec.isEip2930Enabled
    ? Effect.fail(
        new UnsupportedAccessListFeatureError({
          feature: "EIP-2930 access lists",
          hardfork: spec.hardfork,
        }),
      )
    : Effect.succeed(undefined);

const addressKey = (address: Address.AddressType): HexKey =>
  Hex.fromBytes(address);

const storageSlotKey = (slot: StorageSlotType): HexKey => Hex.fromBytes(slot);

const storageKey = (address: Address.AddressType, slot: StorageSlotType) =>
  `${addressKey(address)}:${storageSlotKey(slot)}`;

const makeAccessListBuilder = Effect.gen(function* () {
  const spec = yield* ReleaseSpec;

  const buildAccessList = (
    tx: Transaction.Any,
    coinbase: Address.AddressType,
  ) =>
    Effect.gen(function* () {
      const parsedTx = yield* decodeTransaction(tx);
      yield* ensureAccessListSupport(parsedTx, spec);

      const addresses = new Map<HexKey, Address.AddressType>();
      const storageKeys = new Map<string, AccessListStorageKey>();

      const addAddress = (address: Address.AddressType) => {
        addresses.set(addressKey(address), address);
      };

      const addStorageKey = (
        address: Address.AddressType,
        slot: StorageSlotType,
      ) => {
        const key = storageKey(address, slot);
        if (!storageKeys.has(key)) {
          storageKeys.set(key, { address, slot });
        }
      };

      addAddress(coinbase);

      if (
        Transaction.isEIP2930(parsedTx) ||
        Transaction.isEIP1559(parsedTx) ||
        Transaction.isEIP4844(parsedTx) ||
        Transaction.isEIP7702(parsedTx)
      ) {
        for (const entry of parsedTx.accessList) {
          addAddress(entry.address);
          for (const slot of entry.storageKeys) {
            addStorageKey(entry.address, slot as StorageSlotType);
          }
        }
      }

      return {
        addresses: Array.from(addresses.values()),
        storageKeys: Array.from(storageKeys.values()),
      };
    });

  return { buildAccessList } satisfies AccessListBuilderService;
});

/** Production access list builder layer. */
export const AccessListBuilderLive: Layer.Layer<
  AccessListBuilder,
  never,
  ReleaseSpec
> = Layer.effect(AccessListBuilder, makeAccessListBuilder);

/** Deterministic access list builder layer for tests. */
export const AccessListBuilderTest: Layer.Layer<AccessListBuilder> =
  AccessListBuilderLive.pipe(Layer.provide(ReleaseSpecPrague));

/** Build access list prewarm sets for a transaction. */
export const buildAccessList = (
  tx: Transaction.Any,
  coinbase: Address.AddressType,
) =>
  Effect.gen(function* () {
    const builder = yield* AccessListBuilder;
    return yield* builder.buildAccessList(tx, coinbase);
  });
