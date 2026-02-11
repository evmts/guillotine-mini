import { sqliteTable, text, integer, primaryKey } from "drizzle-orm/sqlite-core";

export const fixResultTable = sqliteTable(
  "fix_result",
  {
    runId: text("run_id").notNull(),
    nodeId: text("node_id").notNull(),
    iteration: integer("iteration").notNull().default(0),
    success: integer("success", { mode: "boolean" }).notNull(),
    whatWasFixed: text("what_was_fixed").notNull(),
    filesModified: text("files_modified", { mode: "json" }).$type<string[]>(),
  },
  (t) => [
    primaryKey({ columns: [t.runId, t.nodeId, t.iteration] }),
  ]
);
