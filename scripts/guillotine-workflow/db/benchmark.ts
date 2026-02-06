import { sqliteTable, text, integer, primaryKey } from "drizzle-orm/sqlite-core";

export const benchmarkTable = sqliteTable(
  "benchmark",
  {
    runId: text("run_id").notNull(),
    nodeId: text("node_id").notNull(),
    iteration: integer("iteration").notNull().default(0),
    results: text("results").notNull(),
    meetsTargets: integer("meets_targets", { mode: "boolean" }).notNull(),
    suggestions: text("suggestions"),
  },
  (t) => [
    primaryKey({ columns: [t.runId, t.nodeId, t.iteration] }),
  ]
);
