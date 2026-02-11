import { sqliteTable, text, integer, primaryKey } from "drizzle-orm/sqlite-core";

export const commitResultTable = sqliteTable(
  "commit_result",
  {
    runId: text("run_id").notNull(),
    nodeId: text("node_id").notNull(),
    iteration: integer("iteration").notNull().default(0),
    committed: integer("committed", { mode: "boolean" }).notNull(),
    commitMessage: text("commit_message").notNull(),
  },
  (t) => [
    primaryKey({ columns: [t.runId, t.nodeId, t.iteration] }),
  ]
);
