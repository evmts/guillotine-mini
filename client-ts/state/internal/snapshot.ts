import * as Effect from "effect/Effect";

/** Locate a snapshot by id, searching from newest to oldest. */
export const lookupSnapshotEntry = <
  SnapshotId extends number,
  Entry extends { readonly id: SnapshotId },
  E,
>(
  snapshots: ReadonlyArray<Entry>,
  snapshot: SnapshotId,
  onMissing: (snapshot: SnapshotId, depth: number) => E,
): Effect.Effect<{ readonly index: number; readonly entry: Entry }, E> =>
  Effect.gen(function* () {
    for (let i = snapshots.length - 1; i >= 0; i -= 1) {
      const entry = snapshots[i];
      if (entry && entry.id === snapshot) {
        return { index: i, entry };
      }
    }
    return yield* Effect.fail(onMissing(snapshot, snapshots.length));
  });
