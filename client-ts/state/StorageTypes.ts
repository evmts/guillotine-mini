import * as Schema from effect/Schema;
import { Storage, StorageValue } from voltaire-effect/primitives;

/**
 * Centralized storage type aliases to avoid duplication / drift.
 * Always reference these instead of redeclaring in modules.
 */
export type StorageSlotType = Schema.Schema.Type<
  typeof Storage.StorageSlotSchema
>;

export type StorageValueType = Schema.Schema.Type<
  typeof StorageValue.StorageValueSchema
>;

/**
 * Convenient re-exports for schema-based constructors in tests/benchmarks.
 * Example: Schema.decodeSync(StorageSlotSchema)(bytes)
 */
export const StorageSlotSchema =
  Storage.StorageSlotSchema as unknown as Schema.Schema<
    StorageSlotType,
    Uint8Array | string | number | bigint
  >;

export const StorageValueSchema =
  StorageValue.StorageValueSchema as unknown as Schema.Schema<
    StorageValueType,
    Uint8Array | string | number | bigint
  >;
