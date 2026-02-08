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
/// | Helper             | Spec equivalent                         | Semantics                                |
/// |--------------------|-----------------------------------------|------------------------------------------|
/// | `is_empty`         | Python: `account == EMPTY_ACCOUNT`      | nonce=0, balance=0, code=empty           |
/// | `is_totally_empty` | Nethermind: `IsTotallyEmpty`            | is_empty AND storage_root=empty          |
/// | `is_account_alive` | Python: `is_account_alive()`            | exists AND NOT totally empty             |
/// | `has_code_or_nonce`| Python: `account_has_code_or_nonce()`   | nonce!=0 OR code!=empty                  |
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
/// zero nonce/balance/code is still "empty" per EIP-161.  Use `is_totally_empty`
/// to also check storage.
pub fn is_empty(account: *const AccountState) bool {
    return account.nonce == 0 and
        account.balance == 0 and
        std.mem.eql(u8, &account.code_hash, &EMPTY_CODE_HASH);
}

/// Check whether an account is "totally empty" — empty AND has no storage.
///
/// Equivalent to Nethermind's `Account.IsTotallyEmpty`:
/// `_storageRoot is null && IsEmpty`
///
/// This is stronger than `is_empty` — it also requires that the storage
/// trie root matches the empty trie root (i.e., no storage entries).
pub fn is_totally_empty(account: *const AccountState) bool {
    return is_empty(account) and
        std.mem.eql(u8, &account.storage_root, &EMPTY_TRIE_ROOT);
}

/// Check whether an account is "alive" per execution-specs.
///
/// Equivalent to Python's `is_account_alive()`:
/// ```python
/// account = get_account_optional(state, address)
/// return account is not None and account != EMPTY_ACCOUNT
/// ```
///
/// This is stronger than `!is_empty` because it requires the account to be
/// present and not totally empty (i.e. not equal to `EMPTY_ACCOUNT`).
pub fn is_account_alive(account: ?AccountState) bool {
    if (account) |acct| {
        return !is_totally_empty(&acct);
    }
    return false;
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
pub fn has_code_or_nonce(account: *const AccountState) bool {
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
    try std.testing.expect(is_empty(&EMPTY_ACCOUNT));
}

test "EMPTY_ACCOUNT is totally empty" {
    try std.testing.expect(is_totally_empty(&EMPTY_ACCOUNT));
}

test "is_account_alive: false for null account" {
    const account: ?AccountState = null;
    try std.testing.expect(!is_account_alive(account));
}

test "is_account_alive: false for EMPTY_ACCOUNT" {
    try std.testing.expect(!is_account_alive(EMPTY_ACCOUNT));
}

test "is_account_alive: true for non-zero nonce" {
    const account = AccountState.from(.{ .nonce = 1 });
    try std.testing.expect(is_account_alive(account));
}

test "is_account_alive: true when storage root is non-empty" {
    var custom_root: [32]u8 = undefined;
    @memset(&custom_root, 0xAB);

    const account = AccountState.from(.{
        .nonce = 0,
        .balance = 0,
        .code_hash = EMPTY_CODE_HASH,
        .storage_root = custom_root,
    });

    // Not totally empty because storage_root != EMPTY_TRIE_ROOT.
    try std.testing.expect(is_account_alive(account));
    try std.testing.expect(!is_totally_empty(&account));
}

test "EMPTY_ACCOUNT has no code or nonce" {
    try std.testing.expect(!has_code_or_nonce(&EMPTY_ACCOUNT));
}

test "is_empty: true for zero nonce, zero balance, empty code" {
    const acct = AccountState.from(.{
        .nonce = 0,
        .balance = 0,
        .code_hash = EMPTY_CODE_HASH,
    });
    try std.testing.expect(is_empty(&acct));
}

test "is_empty: false when nonce is non-zero" {
    const acct = AccountState.from(.{
        .nonce = 1,
        .balance = 0,
        .code_hash = EMPTY_CODE_HASH,
    });
    try std.testing.expect(!is_empty(&acct));
}

test "is_empty: false when balance is non-zero" {
    const acct = AccountState.from(.{
        .nonce = 0,
        .balance = 42,
        .code_hash = EMPTY_CODE_HASH,
    });
    try std.testing.expect(!is_empty(&acct));
}

test "is_empty: false when code hash is non-empty" {
    var custom_hash: [32]u8 = undefined;
    @memset(&custom_hash, 0xAB);

    const acct = AccountState.from(.{
        .nonce = 0,
        .balance = 0,
        .code_hash = custom_hash,
    });
    try std.testing.expect(!is_empty(&acct));
}

test "is_empty: true even with non-empty storage root" {
    // Per EIP-161, is_empty does NOT check storage_root.
    var custom_root: [32]u8 = undefined;
    @memset(&custom_root, 0xFF);

    const acct = AccountState.from(.{
        .nonce = 0,
        .balance = 0,
        .code_hash = EMPTY_CODE_HASH,
        .storage_root = custom_root,
    });
    try std.testing.expect(is_empty(&acct));
}

test "is_totally_empty: true for default empty account" {
    const acct = AccountState.createEmpty();
    try std.testing.expect(is_totally_empty(&acct));
}

test "is_totally_empty: false when storage root is non-empty" {
    var custom_root: [32]u8 = undefined;
    @memset(&custom_root, 0xFF);

    const acct = AccountState.from(.{
        .nonce = 0,
        .balance = 0,
        .code_hash = EMPTY_CODE_HASH,
        .storage_root = custom_root,
    });
    // is_empty is true, but is_totally_empty is false because storage_root != EMPTY_TRIE_ROOT.
    try std.testing.expect(is_empty(&acct));
    try std.testing.expect(!is_totally_empty(&acct));
}

test "is_totally_empty: false when nonce is non-zero" {
    const acct = AccountState.from(.{ .nonce = 1 });
    try std.testing.expect(!is_totally_empty(&acct));
}

test "has_code_or_nonce: true when nonce is non-zero" {
    const acct = AccountState.from(.{ .nonce = 5 });
    try std.testing.expect(has_code_or_nonce(&acct));
}

test "has_code_or_nonce: true when code is non-empty" {
    var custom_hash: [32]u8 = undefined;
    @memset(&custom_hash, 0xCD);

    const acct = AccountState.from(.{
        .nonce = 0,
        .code_hash = custom_hash,
    });
    try std.testing.expect(has_code_or_nonce(&acct));
}

test "has_code_or_nonce: true when both nonce and code are non-empty" {
    var custom_hash: [32]u8 = undefined;
    @memset(&custom_hash, 0xEF);

    const acct = AccountState.from(.{
        .nonce = 3,
        .code_hash = custom_hash,
    });
    try std.testing.expect(has_code_or_nonce(&acct));
}

test "has_code_or_nonce: false for empty account" {
    const acct = AccountState.createEmpty();
    try std.testing.expect(!has_code_or_nonce(&acct));
}

test "has_code_or_nonce: false when only balance is set" {
    // Balance alone does not make has_code_or_nonce true.
    const acct = AccountState.from(.{
        .nonce = 0,
        .balance = 1_000_000,
        .code_hash = EMPTY_CODE_HASH,
    });
    try std.testing.expect(!has_code_or_nonce(&acct));
}

test "is_empty and has_code_or_nonce are mutually consistent" {
    // For the EMPTY_ACCOUNT: is_empty=true, has_code_or_nonce=false
    try std.testing.expect(is_empty(&EMPTY_ACCOUNT));
    try std.testing.expect(!has_code_or_nonce(&EMPTY_ACCOUNT));

    // For an account with nonce: is_empty=false, has_code_or_nonce=true
    const with_nonce = AccountState.from(.{ .nonce = 1 });
    try std.testing.expect(!is_empty(&with_nonce));
    try std.testing.expect(has_code_or_nonce(&with_nonce));

    // For an account with only balance: is_empty=false, has_code_or_nonce=false
    // (balance makes it non-empty, but doesn't give it code or nonce)
    const with_balance = AccountState.from(.{ .balance = 100 });
    try std.testing.expect(!is_empty(&with_balance));
    try std.testing.expect(!has_code_or_nonce(&with_balance));
}
