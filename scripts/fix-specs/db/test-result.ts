import { sqliteTable, text, integer, primaryKey } from "drizzle-orm/sqlite-core";

export const testResultTable = sqliteTable(
  "test_result",
  {
    runId: text("run_id").notNull(),
    nodeId: text("node_id").notNull(),
    iteration: integer("iteration").notNull().default(0),
    passed: integer("passed", { mode: "boolean" }).notNull(),
    output: text("output").notNull(),
    passedCount: integer("passed_count").notNull(),
    failedCount: integer("failed_count").notNull(),
  },
  (t) => [
    primaryKey({ columns: [t.runId, t.nodeId, t.iteration] }),
  ]
);
