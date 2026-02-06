import { sqliteTable, text, integer, primaryKey } from "drizzle-orm/sqlite-core";

export const testTable = sqliteTable(
  "test_results",
  {
    runId: text("run_id").notNull(),
    nodeId: text("node_id").notNull(),
    iteration: integer("iteration").notNull().default(0),
    unitTestsPassed: integer("unit_tests_passed", { mode: "boolean" }).notNull(),
    specTestsPassed: integer("spec_tests_passed", { mode: "boolean" }).notNull(),
    integrationTestsPassed: integer("integration_tests_passed", { mode: "boolean" }).notNull(),
    nethermindDiffPassed: integer("nethermind_diff_passed", { mode: "boolean" }).notNull(),
    failingSummary: text("failing_summary"),
    testOutput: text("test_output").notNull(),
  },
  (t) => [
    primaryKey({ columns: [t.runId, t.nodeId, t.iteration] }),
  ]
);
