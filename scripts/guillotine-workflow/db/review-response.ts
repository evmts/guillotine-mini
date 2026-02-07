import { sqliteTable, text, integer, primaryKey } from "drizzle-orm/sqlite-core";

export const reviewResponseTable = sqliteTable(
  "review_response",
  {
    runId: text("run_id").notNull(),
    nodeId: text("node_id").notNull(),
    iteration: integer("iteration").notNull().default(0),
    fixesAccepted: integer("fixes_accepted", { mode: "boolean" }).notNull(),
    remainingIssues: text("remaining_issues", { mode: "json" }).$type<string[]>(),
    feedback: text("feedback").notNull(),
  },
  (t) => [
    primaryKey({ columns: [t.runId, t.nodeId, t.iteration] }),
  ]
);
