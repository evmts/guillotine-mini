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
///
/// ## Modules
///
/// - `Journal`       — Generic change-list journal (append-only log + snapshot/restore)
/// - `ChangeTag`     — Change classification enum (just_cache, update, create, delete, touch)
/// - `Entry`         — Single change record (key + value + tag)
/// - `JournalError`  — Error set for journal operations (InvalidSnapshot, OutOfMemory)
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
/// const snap = journal.takeSnapshot();
/// // ... more mutations ...
/// try journal.restore(snap, null); // undo mutations after snapshot
/// journal.commit(snap, null);      // finalise changes since snapshot
/// ```
const journal = @import("journal.zig");

// -- Public API: flat re-exports -------------------------------------------

/// Generic change-list journal with index-based snapshot/restore.
pub const Journal = journal.Journal;

/// Single change entry in a journal.
pub const Entry = journal.Entry;

/// Classification tag for change entries.
pub const ChangeTag = journal.ChangeTag;

/// Error set for journal operations.
pub const JournalError = journal.JournalError;

test {
    // Ensure all sub-modules compile and their tests run.
    @import("std").testing.refAllDecls(@This());
}
