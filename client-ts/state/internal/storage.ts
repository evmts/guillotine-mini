import { bytes32Equals, cloneBytes32 } from "./bytes";

const ZERO_BYTES32 = new Uint8Array(32);

/** Return a fresh zero-filled 32-byte buffer. */
export const zeroBytes32 = (): Uint8Array => cloneBytes32(ZERO_BYTES32);

/** Clone a 32-byte storage value. */
export const cloneStorageValue = <T extends Uint8Array>(value: T): T =>
  cloneBytes32(value) as T;

/** Check whether a value is zero-filled. */
export const isZeroStorageValue = (value: Uint8Array): boolean =>
  bytes32Equals(value, ZERO_BYTES32);
