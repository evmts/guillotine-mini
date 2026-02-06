import { sqliteTable, text, integer, primaryKey } from "drizzle-orm/sqlite-core";

export const reviewTable = sqliteTable(
  "review",
  {
    runId: text("run_id").notNull(),
    nodeId: text("node_id").notNull(),
    iteration: integer("iteration").notNull().default(0),
    issues: text("issues", { mode: "json" }).$type<string[]>(),
    severity: text("severity").notNull(),
    feedback: text("feedback").notNull(),
  },
  (t) => [
    primaryKey({ columns: [t.runId, t.nodeId, t.iteration] }),
  ]
);
