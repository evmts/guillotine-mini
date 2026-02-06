import { sqliteTable, text, integer, primaryKey } from "drizzle-orm/sqlite-core";

export const reviewFixTable = sqliteTable(
  "review_fix",
  {
    runId: text("run_id").notNull(),
    nodeId: text("node_id").notNull(),
    iteration: integer("iteration").notNull().default(0),
    fixesMade: text("fixes_made", { mode: "json" }).$type<string[]>(),
    commitMessage: text("commit_message").notNull(),
    summary: text("summary").notNull(),
  },
  (t) => [
    primaryKey({ columns: [t.runId, t.nodeId, t.iteration] }),
  ]
);
