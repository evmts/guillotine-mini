import { AccountState } from "voltaire-effect/primitives";
import { bytes32Equals, cloneBytes32 } from "./internal/bytes";

/** Canonical AccountState type from voltaire-effect. */
export type AccountStateType = AccountState.AccountStateType;
/** Schema for decoding/encoding account state at boundaries. */
export const AccountStateSchema = AccountState.AccountStateSchema;
/** Keccak-256 hash of empty code, per Ethereum specification. */
export const EMPTY_CODE_HASH = AccountState.EMPTY_CODE_HASH;
/** Empty storage trie root hash, per Ethereum specification. */
export const EMPTY_STORAGE_ROOT = AccountState.EMPTY_STORAGE_ROOT;

/** Optional overrides when constructing an account state. */
export type AccountOverrides = Partial<Omit<AccountStateType, "__tag">>;

/** Convenience constructor for canonical account values. */
export const makeAccount = (
  overrides: AccountOverrides = {},
): AccountStateType => ({
  nonce: overrides.nonce ?? 0n,
  balance: overrides.balance ?? 0n,
  codeHash: cloneBytes32(
    overrides.codeHash ?? EMPTY_CODE_HASH,
  ) as AccountStateType["codeHash"],
  storageRoot: cloneBytes32(
    overrides.storageRoot ?? EMPTY_STORAGE_ROOT,
  ) as AccountStateType["storageRoot"],
  __tag: "AccountState",
});

/** Default empty account value. */
export const EMPTY_ACCOUNT: AccountStateType = makeAccount();

/** True if the account has zero nonce and balance with empty code. */
export const isEmpty = (account: AccountStateType): boolean =>
  account.nonce === 0n &&
  account.balance === 0n &&
  bytes32Equals(account.codeHash, EMPTY_CODE_HASH);

/** True if the account is empty and its storage root is empty. */
export const isTotallyEmpty = (account: AccountStateType): boolean =>
  isEmpty(account) && bytes32Equals(account.storageRoot, EMPTY_STORAGE_ROOT);

/** True when the account exists and is not empty. */
export const isAccountAlive = (
  account: AccountStateType | null | undefined,
): boolean => (account ? !isEmpty(account) : false);

/** True when the account has non-zero nonce or non-empty code. */
export const hasCodeOrNonce = (account: AccountStateType): boolean =>
  account.nonce !== 0n || !bytes32Equals(account.codeHash, EMPTY_CODE_HASH);

/** True when the account represents a contract (non-empty code hash). */
export const isContract = (account: AccountStateType): boolean =>
  !bytes32Equals(account.codeHash, EMPTY_CODE_HASH);
