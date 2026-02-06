import { sqliteTable, text, integer, primaryKey } from "drizzle-orm/sqlite-core";

export const implementTable = sqliteTable(
  "implement",
  {
    runId: text("run_id").notNull(),
    nodeId: text("node_id").notNull(),
    iteration: integer("iteration").notNull().default(0),
    filesCreated: text("files_created", { mode: "json" }).$type<string[]>(),
    filesModified: text("files_modified", { mode: "json" }).$type<string[]>(),
    commitMessage: text("commit_message").notNull(),
    whatWasDone: text("what_was_done").notNull(),
    nextSmallestUnit: text("next_smallest_unit").notNull(),
  },
  (t) => [
    primaryKey({ columns: [t.runId, t.nodeId, t.iteration] }),
  ]
);
