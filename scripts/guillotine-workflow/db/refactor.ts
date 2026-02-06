import { sqliteTable, text, integer, primaryKey } from "drizzle-orm/sqlite-core";

export const refactorTable = sqliteTable(
  "refactor",
  {
    runId: text("run_id").notNull(),
    nodeId: text("node_id").notNull(),
    iteration: integer("iteration").notNull().default(0),
    changesDescription: text("changes_description").notNull(),
    commitMessage: text("commit_message").notNull(),
    filesChanged: text("files_changed", { mode: "json" }).$type<string[]>(),
  },
  (t) => [
    primaryKey({ columns: [t.runId, t.nodeId, t.iteration] }),
  ]
);
