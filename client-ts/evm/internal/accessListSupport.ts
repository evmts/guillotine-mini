import { Transaction } from "voltaire-effect/primitives";

/** @internal Determine whether a transaction requires access list support. */
export const requiresAccessListSupport = (tx: Transaction.Any): boolean =>
  Transaction.isEIP2930(tx) ||
  Transaction.isEIP1559(tx) ||
  Transaction.isEIP4844(tx) ||
  Transaction.isEIP7702(tx);
