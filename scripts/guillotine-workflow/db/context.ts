import { sqliteTable, text, integer, primaryKey } from "drizzle-orm/sqlite-core";

export const contextTable = sqliteTable(
  "context",
  {
    runId: text("run_id").notNull(),
    nodeId: text("node_id").notNull(),
    iteration: integer("iteration").notNull().default(0),
    contextFilePath: text("context_file_path").notNull(),
    nethermindFiles: text("nethermind_files", { mode: "json" }).$type<string[]>(),
    specFiles: text("spec_files", { mode: "json" }).$type<string[]>(),
    voltaireApis: text("voltaire_apis", { mode: "json" }).$type<string[]>(),
    existingZigFiles: text("existing_zig_files", { mode: "json" }).$type<string[]>(),
    testFixtures: text("test_fixtures", { mode: "json" }).$type<string[]>(),
    summary: text("summary").notNull(),
  },
  (t) => [
    primaryKey({ columns: [t.runId, t.nodeId, t.iteration] }),
  ]
);
