import { sqliteTable, text, integer, primaryKey } from "drizzle-orm/sqlite-core";

export const outputTable = sqliteTable(
  "output",
  {
    runId: text("run_id").notNull(),
    nodeId: text("node_id").notNull(),
    phasesCompleted: text("phases_completed", { mode: "json" }).$type<string[]>(),
    totalIterations: integer("total_iterations").notNull(),
    summary: text("summary").notNull(),
  },
  (t) => [
    primaryKey({ columns: [t.runId, t.nodeId] }),
  ]
);
