import { AccountState } from "voltaire-effect/primitives";

export type AccountStateType = AccountState.AccountStateType;
export const AccountStateSchema = AccountState.AccountStateSchema;
export const EMPTY_CODE_HASH = AccountState.EMPTY_CODE_HASH;
export const EMPTY_STORAGE_ROOT = AccountState.EMPTY_STORAGE_ROOT;

export const EMPTY_ACCOUNT: AccountStateType = {
  nonce: 0n,
  balance: 0n,
  codeHash: EMPTY_CODE_HASH,
  storageRoot: EMPTY_STORAGE_ROOT,
  __tag: "AccountState",
};

const bytes32Equals = (left: Uint8Array, right: Uint8Array): boolean => {
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

export const isEmpty = (account: AccountStateType): boolean =>
  account.nonce === 0n &&
  account.balance === 0n &&
  bytes32Equals(account.codeHash, EMPTY_CODE_HASH);

export const isTotallyEmpty = (account: AccountStateType): boolean =>
  isEmpty(account) && bytes32Equals(account.storageRoot, EMPTY_STORAGE_ROOT);

export const isAccountAlive = (
  account: AccountStateType | null | undefined,
): boolean => (account ? !isEmpty(account) : false);

export const hasCodeOrNonce = (account: AccountStateType): boolean =>
  account.nonce !== 0n || !bytes32Equals(account.codeHash, EMPTY_CODE_HASH);
