import { sqliteTable, text, integer, primaryKey } from "drizzle-orm/sqlite-core";

export const finalReviewTable = sqliteTable(
  "final_review",
  {
    runId: text("run_id").notNull(),
    nodeId: text("node_id").notNull(),
    iteration: integer("iteration").notNull().default(0),
    readyToMoveOn: integer("ready_to_move_on", { mode: "boolean" }).notNull(),
    remainingIssues: text("remaining_issues", { mode: "json" }).$type<string[]>(),
    reasoning: text("reasoning").notNull(),
  },
  (t) => [
    primaryKey({ columns: [t.runId, t.nodeId, t.iteration] }),
  ]
);
