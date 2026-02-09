/// World state management for the Guillotine execution client.
///
/// Provides journaled state with snapshot/restore for transaction processing,
/// sitting between the trie layer (Phase 1) and EVM state integration (Phase 3).
///
/// ## Architecture (Nethermind parity)
///
/// Follows Nethermind's separation of concerns:
///
/// | Module          | Nethermind equivalent            | Purpose                                    |
/// |-----------------|----------------------------------|--------------------------------------------|
/// | `journal`       | `PartialStorageProviderBase`     | Change-list journal with snapshot/restore   |
/// | `account`       | `Account.cs`                     | Account helpers (is_empty, has_code_or_nonce) |
///
/// ## Modules
///
/// - `Journal`       — Generic change-list journal (append-only log + snapshot/restore)
/// - `ChangeTag`     — Change classification enum (just_cache, update, create, delete, touch)
/// - `Entry`         — Single change record (key + value + tag)
/// - `JournalError`  — Error set for journal operations (InvalidSnapshot, OutOfMemory)
/// - `AccountState`  — Voltaire account state type (re-exported)
/// - `is_empty`       — EIP-161 empty account predicate
/// - `is_totally_empty` — Empty account with empty storage predicate
/// - `is_account_alive` — Exists + not empty predicate (account != EMPTY_ACCOUNT)
/// - `has_code_or_nonce` — Code-or-nonce predicate (for CREATE collision check)
///
/// ## Usage
///
/// ```zig
/// const state = @import("client/state/root.zig");
///
/// var journal = state.Journal(Address, AccountState).init(allocator);
/// defer journal.deinit();
///
/// const idx = try journal.append(.{ .key = addr, .value = acct, .tag = .create });
/// const snap = journal.take_snapshot();
/// // ... more mutations ...
/// try journal.restore(snap, null); // undo mutations after snapshot
/// journal.commit(snap, null);      // finalise changes since snapshot
/// ```
const journal = @import("journal.zig");
const account = @import("account.zig");
const state = @import("state.zig");

// -- Public API: flat re-exports -------------------------------------------

// Journal types
/// Generic change-list journal with index-based snapshot/restore.
pub const Journal = journal.Journal;

/// Single change entry in a journal.
pub const Entry = journal.Entry;

/// Classification tag for change entries.
pub const ChangeTag = journal.ChangeTag;

/// Error set for journal operations.
pub const JournalError = journal.JournalError;

// Account types and helpers
/// Voltaire account state type — the canonical Ethereum account representation.
pub const AccountState = account.AccountState;

/// The empty account constant (nonce=0, balance=0, empty code/storage).
pub const EMPTY_ACCOUNT = account.EMPTY_ACCOUNT;

/// Canonical hash of empty EVM bytecode (keccak256 of empty bytes).
pub const EMPTY_CODE_HASH = account.EMPTY_CODE_HASH;

/// Root hash of an empty Merkle Patricia Trie.
pub const EMPTY_TRIE_ROOT = account.EMPTY_TRIE_ROOT;

/// Check whether an account is "empty" per EIP-161.
pub const is_empty = account.is_empty;

/// Check whether an account is "totally empty" (empty AND no storage).
pub const is_totally_empty = account.is_totally_empty;

/// Check whether an account has code or a non-zero nonce.
pub const has_code_or_nonce = account.has_code_or_nonce;

/// Check whether an account exists and is not empty.
pub const is_account_alive = account.is_account_alive;

// State utilities
/// Tracks accounts created during the current transaction.
pub const CreatedAccounts = state.CreatedAccounts;

test {
    // Ensure all sub-modules compile and their tests run.
    @import("std").testing.refAllDecls(@This());
}
