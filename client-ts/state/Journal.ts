import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";

/** Classification tag for change entries. */
export const ChangeTag = {
  JustCache: "just_cache",
  Update: "update",
  Create: "create",
  Delete: "delete",
  Touch: "touch",
} as const;

/** Union of supported change tags. */
export type ChangeTagType = (typeof ChangeTag)[keyof typeof ChangeTag];

/** Single change entry in the journal. */
export interface JournalEntry<K, V> {
  readonly key: K;
  readonly value: V | null;
  readonly tag: ChangeTagType;
}

/** Snapshot position returned by takeSnapshot. */
export type JournalSnapshot = number;

/** Sentinel snapshot representing an empty journal. */
export const EMPTY_SNAPSHOT: JournalSnapshot = -1;

/** Error raised when attempting to restore an invalid snapshot. */
export class InvalidSnapshotError extends Data.TaggedError(
  "InvalidSnapshotError",
)<{
  readonly snapshot: JournalSnapshot;
  readonly currentLength: number;
}> {}

const invalidSnapshotError = (
  snapshot: JournalSnapshot,
  currentLength: number,
) => new InvalidSnapshotError({ snapshot, currentLength });

const snapshotToLength = (snapshot: JournalSnapshot): number =>
  snapshot === EMPTY_SNAPSHOT ? 0 : snapshot + 1;

const validateSnapshot = (
  snapshot: JournalSnapshot,
  currentLength: number,
): Effect.Effect<number, InvalidSnapshotError> =>
  Effect.gen(function* () {
    if (snapshot < EMPTY_SNAPSHOT) {
      return yield* Effect.fail(invalidSnapshotError(snapshot, currentLength));
    }

    const targetLength = snapshotToLength(snapshot);

    if (snapshot !== EMPTY_SNAPSHOT && targetLength > currentLength) {
      return yield* Effect.fail(invalidSnapshotError(snapshot, currentLength));
    }

    return targetLength;
  });

/** Journal service interface. */
export interface JournalService<K, V> {
  readonly append: (entry: JournalEntry<K, V>) => Effect.Effect<number>;
  readonly takeSnapshot: () => Effect.Effect<JournalSnapshot>;
  readonly restore: <E = never>(
    snapshot: JournalSnapshot,
    onRevert?: (entry: JournalEntry<K, V>) => Effect.Effect<void, E>,
  ) => Effect.Effect<void, InvalidSnapshotError | E>;
  readonly commit: <E = never>(
    snapshot: JournalSnapshot,
    onCommit?: (entry: JournalEntry<K, V>) => Effect.Effect<void, E>,
  ) => Effect.Effect<void, InvalidSnapshotError | E>;
  readonly clear: () => Effect.Effect<void>;
  readonly entries: () => Effect.Effect<ReadonlyArray<JournalEntry<K, V>>>;
}

/** Context tag for a change-list journal. */
export class Journal extends Context.Tag("Journal")<
  Journal,
  JournalService<unknown, unknown>
>() {}

const makeJournal = <K, V>(): JournalService<K, V> => {
  const entries: Array<JournalEntry<K, V>> = [];

  const append = (entry: JournalEntry<K, V>) =>
    Effect.sync(() => {
      entries.push(entry);
      return entries.length - 1;
    });

  const takeSnapshot = () =>
    Effect.sync(() =>
      entries.length === 0 ? EMPTY_SNAPSHOT : entries.length - 1,
    );

  const restore = <E = never>(
    snapshot: JournalSnapshot,
    onRevert?: (entry: JournalEntry<K, V>) => Effect.Effect<void, E>,
  ): Effect.Effect<void, InvalidSnapshotError | E> =>
    Effect.gen(function* () {
      const currentLength = entries.length;
      const targetLength = yield* validateSnapshot(snapshot, currentLength);

      if (targetLength === currentLength) {
        return;
      }

      const changedKeys = new Set<K>();
      for (let i = targetLength; i < currentLength; i += 1) {
        const entry = entries[i];
        if (entry && entry.tag !== ChangeTag.JustCache) {
          changedKeys.add(entry.key);
        }
      }

      const keptKeys = new Set<K>();
      const kept: Array<JournalEntry<K, V>> = [];
      for (let i = currentLength - 1; i >= targetLength; i -= 1) {
        const entry = entries[i];
        if (!entry) {
          continue;
        }

        if (entry.tag === ChangeTag.JustCache) {
          if (changedKeys.has(entry.key) || keptKeys.has(entry.key)) {
            continue;
          }

          keptKeys.add(entry.key);
          kept.push(entry);
          continue;
        }

        if (onRevert) {
          yield* onRevert(entry);
        }
      }

      entries.length = targetLength;

      for (let i = kept.length - 1; i >= 0; i -= 1) {
        const entry = kept[i];
        if (entry) {
          entries.push(entry);
        }
      }
    });

  const commit = <E = never>(
    snapshot: JournalSnapshot,
    onCommit?: (entry: JournalEntry<K, V>) => Effect.Effect<void, E>,
  ): Effect.Effect<void, InvalidSnapshotError | E> =>
    Effect.gen(function* () {
      const currentLength = entries.length;
      const targetLength = yield* validateSnapshot(snapshot, currentLength);

      if (targetLength === currentLength) {
        return;
      }

      if (onCommit) {
        const committedKeys = new Set<K>();
        for (let i = currentLength - 1; i >= targetLength; i -= 1) {
          const entry = entries[i];
          if (!entry || committedKeys.has(entry.key)) {
            continue;
          }

          committedKeys.add(entry.key);
          yield* onCommit(entry);
        }
      }

      entries.length = targetLength;
    });

  const clear = () =>
    Effect.sync(() => {
      entries.length = 0;
    });

  const allEntries = () => Effect.sync(() => entries.slice());

  return {
    append,
    takeSnapshot,
    restore,
    commit,
    clear,
    entries: allEntries,
  } satisfies JournalService<K, V>;
};

/** Production journal layer. */
export const JournalLive: Layer.Layer<Journal> = Layer.succeed(
  Journal,
  makeJournal<unknown, unknown>(),
);

/** Deterministic journal layer for tests. */
// Provide a fresh journal instance for each provision to avoid test cross-talk
export const JournalTest: Layer.Layer<Journal> = Layer.scoped(
  Journal,
  Effect.sync(() => makeJournal<unknown, unknown>()),
);

const journalService = <K, V>() =>
  Effect.map(Journal, (journal) => journal as JournalService<K, V>);

const withJournal = <K, V, A, E>(
  f: (journal: JournalService<K, V>) => Effect.Effect<A, E>,
) => Effect.flatMap(journalService<K, V>(), f);

/** Append a journal entry and return its index. */
export const append = <K, V>(entry: JournalEntry<K, V>) =>
  withJournal<K, V, number, never>((journal) => journal.append(entry));

/** Capture the current journal snapshot. */
export const takeSnapshot = () =>
  withJournal<unknown, unknown, JournalSnapshot, never>((journal) =>
    journal.takeSnapshot(),
  );

/** Restore the journal to a snapshot, preserving just-cache entries. */
export const restore = <K, V, E = never>(
  snapshot: JournalSnapshot,
  onRevert?: (entry: JournalEntry<K, V>) => Effect.Effect<void, E>,
) =>
  withJournal<K, V, void, InvalidSnapshotError | E>((journal) =>
    journal.restore(snapshot, onRevert),
  );

/** Commit entries since a snapshot and truncate the journal. */
export const commit = <K, V, E = never>(
  snapshot: JournalSnapshot,
  onCommit?: (entry: JournalEntry<K, V>) => Effect.Effect<void, E>,
) =>
  withJournal<K, V, void, InvalidSnapshotError | E>((journal) =>
    journal.commit(snapshot, onCommit),
  );

/** Clear all journal entries. */
export const clear = () =>
  withJournal<unknown, unknown, void, never>((journal) => journal.clear());

/** Read a snapshot of all journal entries. */
export const entries = <K, V>() =>
  withJournal<K, V, ReadonlyArray<JournalEntry<K, V>>, never>((journal) =>
    journal.entries(),
  );
