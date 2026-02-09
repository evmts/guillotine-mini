import { Hex } from "voltaire-effect/primitives";
import type { BytesType } from "./Db";

/** Convert a hex string into a DB byte array for tests. */
export const toBytes = (hex: string): BytesType =>
  Hex.toBytes(hex) as BytesType;
