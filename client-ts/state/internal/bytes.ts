/** Compare two byte arrays for exact equality. */
export const bytesEquals = (left: Uint8Array, right: Uint8Array): boolean => {
  if (left.length !== right.length) {
    return false;
  }
  for (let i = 0; i < left.length; i += 1) {
    if (left[i] !== right[i]) {
      return false;
    }
  }
  return true;
};

/** Backward-compatible alias for 32-byte equality. */
export const bytes32Equals = (left: Uint8Array, right: Uint8Array): boolean =>
  bytesEquals(left, right);

/** Clone a byte array to prevent aliasing between callers. */
export const cloneBytes32 = (value: Uint8Array): Uint8Array => value.slice();
