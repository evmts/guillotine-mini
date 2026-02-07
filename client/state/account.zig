/// Account helpers wrapping Voltaire `AccountState`.
///
/// Provides convenience predicates and constants for Ethereum account state
/// that are needed by the world state manager (`state.zig`) and EVM host
/// integration.
///
/// ## Design
///
/// This module does NOT define its own account type. It re-exports Voltaire's
/// `AccountState` and layers on thin helpers that match the semantics from:
///
/// - **Python execution-specs** (`cancun/state.py`):
///   `EMPTY_ACCOUNT`, `is_account_alive()`, `account_has_code_or_nonce()`
/// - **Nethermind** (`Account.cs`):
///   `IsEmpty`, `IsTotallyEmpty`, `IsContract`
///
/// ## Relationship to Voltaire
///
/// Voltaire's `AccountState` already provides `isEOA()`, `isContract()`,
/// `createEmpty()`, `equals()`, and RLP encode/decode.  This module adds:
///
/// | Helper          | Spec equivalent                         | Semantics                                |
/// |-----------------|-----------------------------------------|------------------------------------------|
/// | `isEmpty`       | Python: `account == EMPTY_ACCOUNT`      | nonce=0, balance=0, code=empty           |
/// | `isTotallyEmpty`| Nethermind: `IsTotallyEmpty`            | isEmpty AND storage_root=empty           |
/// | `hasCodeOrNonce`| Python: `account_has_code_or_nonce()`   | nonce!=0 OR code!=empty                  |
///
/// These predicates are critical for EIP-158 (spurious dragon) empty account
/// cleanup and EIP-161 state clearing.
const std = @import("std");
const primitives = @import("primitives");

/// Re-export Voltaire's AccountState — the canonical account type.
pub const AccountState = primitives.AccountState.AccountState;

/// Re-export canonical constants from Voltaire.
pub const EMPTY_CODE_HASH = primitives.AccountState.EMPTY_CODE_HASH;
pub const EMPTY_TRIE_ROOT = primitives.AccountState.EMPTY_TRIE_ROOT;

/// The empty account — equivalent to Python's `EMPTY_ACCOUNT` constant.
///
/// ```python
/// EMPTY_ACCOUNT = Account(nonce=Uint(0), balance=U256(0), code=b"")
/// ```
///
/// In Voltaire's representation, this also includes the canonical
/// `EMPTY_CODE_HASH` and `EMPTY_TRIE_ROOT`.
pub const EMPTY_ACCOUNT: AccountState = AccountState.createEmpty();

/// Check whether an account is "empty" per EIP-161.
///
/// An account is empty when all three conditions hold:
/// - nonce == 0
/// - balance == 0
/// - code_hash == EMPTY_CODE_HASH (no code deployed)
///
/// Equivalent to:
/// - Python: `account == EMPTY_ACCOUNT` (nonce=0, balance=0, code=b"")
/// - Nethermind: `Account.IsEmpty` (`_codeHash is null && Balance.IsZero && Nonce.IsZero`)
///
/// Note: does NOT check `storage_root`. An account with leftover storage but
/// zero nonce/balance/code is still "empty" per EIP-161.  Use `isTotallyEmpty`
/// to also check storage.
pub fn isEmpty(account: *const AccountState) bool {
    return account.nonce == 0 and
        account.balance == 0 and
        std.mem.eql(u8, &account.code_hash, &EMPTY_CODE_HASH);
}

/// Check whether an account is "totally empty" — empty AND has no storage.
///
/// Equivalent to Nethermind's `Account.IsTotallyEmpty`:
/// `_storageRoot is null && IsEmpty`
///
/// This is stronger than `isEmpty` — it also requires that the storage
/// trie root matches the empty trie root (i.e., no storage entries).
pub fn isTotallyEmpty(account: *const AccountState) bool {
    return isEmpty(account) and
        std.mem.eql(u8, &account.storage_root, &EMPTY_TRIE_ROOT);
}

/// Check whether an account has code or a non-zero nonce.
///
/// Equivalent to Python's `account_has_code_or_nonce()`:
/// ```python
/// def account_has_code_or_nonce(state, address):
///     account = get_account(state, address)
///     return account.nonce != Uint(0) or account.code != b""
/// ```
///
/// Used during CREATE to check for address collision (EIP-7610).
pub fn hasCodeOrNonce(account: *const AccountState) bool {
    return account.nonce != 0 or
        !std.mem.eql(u8, &account.code_hash, &EMPTY_CODE_HASH);
}

// =========================================================================
// Tests
// =========================================================================

test "EMPTY_ACCOUNT matches createEmpty" {
    const created = AccountState.createEmpty();
    try std.testing.expect(EMPTY_ACCOUNT.equals(&created));
}

test "EMPTY_ACCOUNT is empty" {
    try std.testing.expect(isEmpty(&EMPTY_ACCOUNT));
}

test "EMPTY_ACCOUNT is totally empty" {
    try std.testing.expect(isTotallyEmpty(&EMPTY_ACCOUNT));
}

test "EMPTY_ACCOUNT has no code or nonce" {
    try std.testing.expect(!hasCodeOrNonce(&EMPTY_ACCOUNT));
}

test "isEmpty: true for zero nonce, zero balance, empty code" {
    const acct = AccountState.from(.{
        .nonce = 0,
        .balance = 0,
        .code_hash = EMPTY_CODE_HASH,
    });
    try std.testing.expect(isEmpty(&acct));
}

test "isEmpty: false when nonce is non-zero" {
    const acct = AccountState.from(.{
        .nonce = 1,
        .balance = 0,
        .code_hash = EMPTY_CODE_HASH,
    });
    try std.testing.expect(!isEmpty(&acct));
}

test "isEmpty: false when balance is non-zero" {
    const acct = AccountState.from(.{
        .nonce = 0,
        .balance = 42,
        .code_hash = EMPTY_CODE_HASH,
    });
    try std.testing.expect(!isEmpty(&acct));
}

test "isEmpty: false when code hash is non-empty" {
    var custom_hash: [32]u8 = undefined;
    @memset(&custom_hash, 0xAB);

    const acct = AccountState.from(.{
        .nonce = 0,
        .balance = 0,
        .code_hash = custom_hash,
    });
    try std.testing.expect(!isEmpty(&acct));
}

test "isEmpty: true even with non-empty storage root" {
    // Per EIP-161, isEmpty does NOT check storage_root.
    var custom_root: [32]u8 = undefined;
    @memset(&custom_root, 0xFF);

    const acct = AccountState.from(.{
        .nonce = 0,
        .balance = 0,
        .code_hash = EMPTY_CODE_HASH,
        .storage_root = custom_root,
    });
    try std.testing.expect(isEmpty(&acct));
}

test "isTotallyEmpty: true for default empty account" {
    const acct = AccountState.createEmpty();
    try std.testing.expect(isTotallyEmpty(&acct));
}

test "isTotallyEmpty: false when storage root is non-empty" {
    var custom_root: [32]u8 = undefined;
    @memset(&custom_root, 0xFF);

    const acct = AccountState.from(.{
        .nonce = 0,
        .balance = 0,
        .code_hash = EMPTY_CODE_HASH,
        .storage_root = custom_root,
    });
    // isEmpty is true, but isTotallyEmpty is false because storage_root != EMPTY_TRIE_ROOT.
    try std.testing.expect(isEmpty(&acct));
    try std.testing.expect(!isTotallyEmpty(&acct));
}

test "isTotallyEmpty: false when nonce is non-zero" {
    const acct = AccountState.from(.{ .nonce = 1 });
    try std.testing.expect(!isTotallyEmpty(&acct));
}

test "hasCodeOrNonce: true when nonce is non-zero" {
    const acct = AccountState.from(.{ .nonce = 5 });
    try std.testing.expect(hasCodeOrNonce(&acct));
}

test "hasCodeOrNonce: true when code is non-empty" {
    var custom_hash: [32]u8 = undefined;
    @memset(&custom_hash, 0xCD);

    const acct = AccountState.from(.{
        .nonce = 0,
        .code_hash = custom_hash,
    });
    try std.testing.expect(hasCodeOrNonce(&acct));
}

test "hasCodeOrNonce: true when both nonce and code are non-empty" {
    var custom_hash: [32]u8 = undefined;
    @memset(&custom_hash, 0xEF);

    const acct = AccountState.from(.{
        .nonce = 3,
        .code_hash = custom_hash,
    });
    try std.testing.expect(hasCodeOrNonce(&acct));
}

test "hasCodeOrNonce: false for empty account" {
    const acct = AccountState.createEmpty();
    try std.testing.expect(!hasCodeOrNonce(&acct));
}

test "hasCodeOrNonce: false when only balance is set" {
    // Balance alone does not make hasCodeOrNonce true.
    const acct = AccountState.from(.{
        .nonce = 0,
        .balance = 1_000_000,
        .code_hash = EMPTY_CODE_HASH,
    });
    try std.testing.expect(!hasCodeOrNonce(&acct));
}

test "isEmpty and hasCodeOrNonce are mutually consistent" {
    // For the EMPTY_ACCOUNT: isEmpty=true, hasCodeOrNonce=false
    try std.testing.expect(isEmpty(&EMPTY_ACCOUNT));
    try std.testing.expect(!hasCodeOrNonce(&EMPTY_ACCOUNT));

    // For an account with nonce: isEmpty=false, hasCodeOrNonce=true
    const with_nonce = AccountState.from(.{ .nonce = 1 });
    try std.testing.expect(!isEmpty(&with_nonce));
    try std.testing.expect(hasCodeOrNonce(&with_nonce));

    // For an account with only balance: isEmpty=false, hasCodeOrNonce=false
    // (balance makes it non-empty, but doesn't give it code or nonce)
    const with_balance = AccountState.from(.{ .balance = 100 });
    try std.testing.expect(!isEmpty(&with_balance));
    try std.testing.expect(!hasCodeOrNonce(&with_balance));
}
