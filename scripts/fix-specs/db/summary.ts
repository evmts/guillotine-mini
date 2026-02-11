import { sqliteTable, text, integer, primaryKey } from "drizzle-orm/sqlite-core";

export const summaryTable = sqliteTable(
  "summary",
  {
    runId: text("run_id").notNull(),
    nodeId: text("node_id").notNull(),
    totalSuites: integer("total_suites").notNull(),
    totalPassed: integer("total_passed").notNull(),
    totalFailed: integer("total_failed").notNull(),
    narrative: text("narrative").notNull(),
  },
  (t) => [
    primaryKey({ columns: [t.runId, t.nodeId] }),
  ]
);
